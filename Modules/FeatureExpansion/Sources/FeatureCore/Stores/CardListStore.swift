import SwiftUI
import Combine
import CoreKit
import CoreModels
import Persistence

extension String {
    fileprivate var foldedForSearch: String {
        folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    }
}

@MainActor
final class CardListStore: ObservableObject {
    @Published var allCardData: [CardData] = []
    @Published var isLoading: Bool = false
    @Published var error: Error? = nil
    @Published var displayMode: CardDisplayMode = .regular
    @Published var searchText: String = ""
    @Published private(set) var displayedCardsCache: [CardViewModel] = []

    private let expansionPath: String
    private let fetchCardListUseCase: FetchCardListUseCase
    private let languageSettings: LanguageSettings
    private var cancellables: Set<AnyCancellable> = []

    init(
        expansionPath: String,
        fetchCardListUseCase: FetchCardListUseCase = FetchCardListUseCaseImpl(),
        languageSettings: LanguageSettings = .shared
    ) {
        self.expansionPath = expansionPath
        self.fetchCardListUseCase = fetchCardListUseCase
        self.languageSettings = languageSettings

        recomputeDisplayedCards()

        $allCardData
            .combineLatest($searchText, $displayMode)
            .map { [weak self] _, _, _ in
                self?.recomputeDisplayedCards()
                return true
            }
            .sink { _ in }
            .store(in: &cancellables)

        languageSettings.$language
            .removeDuplicates()
            .sink { [weak self] _ in
                Task { await self?.loadCards() }
            }
            .store(in: &cancellables)
    }

    var displayedCards: [CardViewModel] { displayedCardsCache }

    private struct CardGroupKey: Hashable {
        let number: Int
        let lang: String
    }

    private func recomputeDisplayedCards() {
        let query = searchText.foldedForSearch
        let filteredBySearch = allCardData.filter { cardData in
            if query.isEmpty { return true }
            let nameMatch = cardData.name.foldedForSearch.contains(query)
            let foilTypeMatch = cardData.foil?.type.rawValue.foldedForSearch.contains(query) ?? false
            let foilMaskMatch = cardData.foil?.mask.rawValue.foldedForSearch.contains(query) ?? false
            return nameMatch || foilTypeMatch || foilMaskMatch
        }

        let canonical = canonicalCards(from: filteredBySearch, mode: displayMode)
            .map { CardViewModel(cardData: $0) }
            .sorted {
                if $0.collectorNumberNumeric == $1.collectorNumberNumeric {
                    return $0.name < $1.name
                }
                return $0.collectorNumberNumeric < $1.collectorNumberNumeric
            }

        displayedCardsCache = canonical
    }

    func loadCards() async {
        isLoading = true
        error = nil
        do {
            let fetched = try await fetchCardListUseCase.execute(
                path: expansionPath,
                language: languageSettings.language.rawValue
            )
            allCardData = fetched
            recomputeDisplayedCards()
        } catch {
            self.error = error
            print(FeatureExpansionStrings.errorLoadingCards(for: expansionPath, error: error.localizedDescription))
        }
        isLoading = false
    }

    func progressSnapshot(using ownedStore: OwnedCardsStore) -> ProgressSnapshot {
        let canonical = canonicalCards(from: allCardData, mode: displayMode)
        let ids = canonical.map(\.id)
        let owned = ownedStore.ownedCount(for: ids)
        let wishlist = ownedStore.wishlistCount(for: ids)
        let duplicates = ownedStore.duplicateCount(for: ids)
        let total = canonical.count
        let percentage = total > 0 ? Double(owned) / Double(total) : 0
        return ProgressSnapshot(
            totalCards: total,
            ownedCards: owned,
            wishlistCards: wishlist,
            duplicateCards: duplicates,
            completionPercentage: percentage
        )
    }

    private func canonicalCards(from cards: [CardData], mode: CardDisplayMode) -> [CardData] {
        switch mode {
        case .master:
            return cards
        case .regular:
            let grouped = Dictionary(grouping: cards) {
                CardGroupKey(number: $0.collectorNumber.numeric, lang: $0.lang)
            }
            return grouped
                .sorted(by: { $0.key.number < $1.key.number })
                .compactMap { (_, cardsForKey) in
                    if let regularCard = cardsForKey.first(where: { $0.foil == nil }) {
                        return regularCard
                    }
                    return cardsForKey.first
                }
        }
    }
}

struct ProgressSnapshot {
    let totalCards: Int
    let ownedCards: Int
    let wishlistCards: Int
    let duplicateCards: Int
    let completionPercentage: Double
}
