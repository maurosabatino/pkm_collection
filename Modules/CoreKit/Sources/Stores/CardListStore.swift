//
//  CardStore.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 27/07/25.
//
import SwiftUI
import Combine

extension String {
    var foldedForSearch: String {
        folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    }
}

@MainActor
final class CardListStore: ObservableObject {
    @Published var allCardData: [CardData] = [] // Memorizza tutti i dati grezzi delle carte
    @Published var isLoading: Bool = false
    @Published var error: Error? = nil
    @Published var displayMode: CardDisplayMode = .regular // Modalità di visualizzazione predefinita
    @Published var searchText: String = "" // Nuovo: testo di ricerca per le carte
    @Published private(set) var displayedCardsCache: [CardViewModel] = []

    private let expansionPath: String
    private let fetchCardListUseCase: FetchCardListUseCase

    private var cancellables: Set<AnyCancellable> = []

    init(expansionPath: String, fetchCardListUseCase: FetchCardListUseCase = FetchCardListUseCaseImpl()) {
        self.expansionPath = expansionPath
        self.fetchCardListUseCase = fetchCardListUseCase

        // Initial compute
        self.recomputeDisplayedCards()

        // React to changes in inputs
        $allCardData
            .combineLatest($searchText, $displayMode)
            .map { [weak self] _, _, _ in
                self?.recomputeDisplayedCards()
                return true
            }
            .sink { _ in }
            .store(in: &cancellables)
    }

    // Computed property that returns the cached displayed cards
    var displayedCards: [CardViewModel] { displayedCardsCache }

    private struct CardGroupKey: Hashable {
        let number: Int
        let lang: String
    }

    private func recomputeDisplayedCards() {
        var processedCards: [CardViewModel] = []

        // Prepare folded search text once
        let query = searchText.foldedForSearch

        // Filter by search on raw data
        let filteredBySearch = allCardData.filter { cardData in
            if query.isEmpty { return true }
            let nameMatch = cardData.name.foldedForSearch.contains(query)
            let foilTypeMatch = cardData.foil?.type.stringValue.foldedForSearch.contains(query) ?? false
            let foilMaskMatch = cardData.foil?.mask.rawValue.foldedForSearch.contains(query) ?? false
            return nameMatch || foilTypeMatch || foilMaskMatch
        }

        switch displayMode {
        case .master:
            processedCards = filteredBySearch
                .map { CardViewModel(cardData: $0) }
                .sorted { (lhs, rhs) in
                    // Stable tie-breaker on name
                    if lhs.collectorNumberNumeric == rhs.collectorNumberNumeric {
                        return lhs.name < rhs.name
                    }
                    return lhs.collectorNumberNumeric < rhs.collectorNumberNumeric
                }
        case .regular:
            // Group by collector number + language to avoid mixing languages
            let grouped = Dictionary(grouping: filteredBySearch) { CardGroupKey(number: $0.collectorNumber.numeric, lang: $0.lang) }
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
            let fetchedCardData = try await fetchCardListUseCase.execute(path: expansionPath)
            self.allCardData = fetchedCardData // Salva tutti i dati grezzi
            self.recomputeDisplayedCards()
        } catch {
            self.error = error
            print(AppStrings.errorLoadingCards(expansionPath: expansionPath, error: error.localizedDescription))
        }
        isLoading = false
    }
}
