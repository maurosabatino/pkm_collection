//
//  CardStore.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 27/07/25.
//
import SwiftUI
import Combine

@MainActor
class CardListStore: ObservableObject {
    @Published var allCardData: [CardData] = [] // Memorizza tutti i dati grezzi delle carte
    @Published var isLoading: Bool = false
    @Published var error: Error? = nil
    @Published var displayMode: CardDisplayMode = .regular // Modalità di visualizzazione predefinita
    @Published var searchText: String = "" // Nuovo: testo di ricerca per le carte

    private let expansionPath: String
    private let fetchCardListUseCase: FetchCardListUseCase

    init(expansionPath: String, fetchCardListUseCase: FetchCardListUseCase = FetchCardListUseCaseImpl()) {
        self.expansionPath = expansionPath
        self.fetchCardListUseCase = fetchCardListUseCase
    }

    // Computed property che restituisce le carte da visualizzare in base alla modalità e al testo di ricerca
    var displayedCards: [CardViewModel] {
        var processedCards: [CardViewModel] = []

        // Filtra prima per testo di ricerca su tutti i dati grezzi
        let filteredBySearch = allCardData.filter { cardData in
            searchText.isEmpty || cardData.name.localizedCaseInsensitiveContains(searchText) ||
            (cardData.foil?.type.rawValue.localizedCaseInsensitiveContains(searchText) ?? false) ||
            (cardData.foil?.mask.rawValue.localizedCaseInsensitiveContains(searchText) ?? false)
        }

        switch displayMode {
        case .master:
            // In modalità Master Set, mostra tutte le carte filtrate, ordinate per numero del collezionista.
            processedCards = filteredBySearch
                .map { CardViewModel(cardData: $0) }
                .sorted { $0.collectorNumberNumeric < $1.collectorNumberNumeric }
        case .regular:
            // In modalità Regular Set, mostra una singola versione di ogni carta filtrata.
            let groupedByCollectorNumber = Dictionary(grouping: filteredBySearch) { $0.collectorNumber.numeric }

            for (_, cardsForNumber) in groupedByCollectorNumber.sorted(by: { $0.key < $1.key }) {
                // Prova a trovare una versione non-foil per prima.
                if let regularCard = cardsForNumber.first(where: { $0.foil == nil }) {
                    processedCards.append(CardViewModel(cardData: regularCard))
                } else {
                    // Se non c'è una versione non-foil, prendi la prima disponibile.
                    if let firstCard = cardsForNumber.first {
                        processedCards.append(CardViewModel(cardData: firstCard))
                    }
                }
            }
        }
        return processedCards
    }

    func loadCards() async {
        isLoading = true
        error = nil
        do {
            let fetchedCardData = try await fetchCardListUseCase.execute(path: expansionPath)
            self.allCardData = fetchedCardData // Salva tutti i dati grezzi
        } catch {
            self.error = error
            print(AppStrings.errorLoadingCards(expansionPath: expansionPath, error: error.localizedDescription))
        }
        isLoading = false
    }
}
