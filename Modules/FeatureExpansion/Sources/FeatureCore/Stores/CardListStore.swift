import SwiftUI
import Combine
import CoreKit

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
    private var cancellables: Set<AnyCancellable> = []

    init(expansionPath: String, fetchCardListUseCase: FetchCardListUseCase = FetchCardListUseCaseImpl()) {
        self.expansionPath = expansionPath
        self.fetchCardListUseCase = fetchCardListUseCase

        recomputeDisplayedCards()

        $allCardData
            .combineLatest($searchText, $displayMode)
            .map { [weak self] _, _, _ in
                self?.recomputeDisplayedCards()
                return true
            }
            .sink { _ in }
            .store(in: &cancellables)
    }

    var displayedCards: [CardViewModel] { displayedCardsCache }

    private struct CardGroupKey: Hashable {
        let number: Int
        let lang: String
    }

    private func recomputeDisplayedCards() {
        var processedCards: [CardViewModel] = []
        let query = searchText.foldedForSearch
        let filteredBySearch = allCardData.filter { cardData in
            if query.isEmpty { return true }
            let nameMatch = cardData.name.foldedForSearch.contains(query)
            let foilTypeMatch = cardData.foil?.type.rawValue.foldedForSearch.contains(query) ?? false
            let foilMaskMatch = cardData.foil?.mask.rawValue.foldedForSearch.contains(query) ?? false
            return nameMatch || foilTypeMatch || foilMaskMatch
        }

        switch displayMode {
        case .master:
            processedCards = filteredBySearch
                .map { CardViewModel(cardData: $0) }
                .sorted {
                    if $0.collectorNumberNumeric == $1.collectorNumberNumeric {
                        return $0.name < $1.name
                    }
                    return $0.collectorNumberNumeric < $1.collectorNumberNumeric
                }
        case .regular:
            let grouped = Dictionary(grouping: filteredBySearch) {
                CardGroupKey(number: $0.collectorNumber.numeric, lang: $0.lang)
            }
            for (_, cardsForKey) in grouped.sorted(by: { $0.key.number < $1.key.number }) {
                if let regularCard = cardsForKey.first(where: { $0.foil == nil }) {
                    processedCards.append(CardViewModel(cardData: regularCard))
                } else if let firstCard = cardsForKey.first {
                    processedCards.append(CardViewModel(cardData: firstCard))
                }
            }
        }

        displayedCardsCache = processedCards
    }

    func loadCards() async {
        isLoading = true
        error = nil
        do {
            let fetched = try await fetchCardListUseCase.execute(path: expansionPath)
            allCardData = fetched
            recomputeDisplayedCards()
        } catch {
            self.error = error
            print(FeatureExpansionStrings.errorLoadingCards(for: expansionPath, error: error.localizedDescription))
        }
        isLoading = false
    }
}
