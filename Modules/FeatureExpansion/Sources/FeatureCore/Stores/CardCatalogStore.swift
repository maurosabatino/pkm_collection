import SwiftUI
import Combine
import CoreKit

@MainActor
final class CardCatalogStore: ObservableObject {
    @Published private(set) var displayedCards: [CardViewModel] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published var searchText: String = ""
    @Published var selectedPokemonTypes: Set<PokemonType> = []
    @Published var selectedRarities: Set<Designation> = []

    private var allCards: [CardData] = []
    private let fetchCardListUseCase: FetchCardListUseCase
    private var cancellables: Set<AnyCancellable> = []
    private var availableTypesCache: [PokemonType] = []
    private var availableRaritiesCache: [Designation] = []

    init(fetchCardListUseCase: FetchCardListUseCase = FetchCardListUseCaseImpl()) {
        self.fetchCardListUseCase = fetchCardListUseCase

        $searchText
            .combineLatest($selectedPokemonTypes, $selectedRarities)
            .sink { [weak self] _ in
                self?.recomputeDisplayedCards()
            }
            .store(in: &cancellables)
    }

    func loadCards(for expansions: [Expansion]) async {
        guard !expansions.isEmpty else {
            allCards = []
            displayedCards = []
            return
        }

        isLoading = true
        error = nil

        do {
            var aggregated: [CardData] = []
            for expansion in expansions {
                let cards = try await fetchCardListUseCase.execute(path: expansion.path)
                aggregated.append(contentsOf: cards)
            }
            allCards = aggregated
            refreshAvailableFilters()
            recomputeDisplayedCards()
        } catch {
            self.error = error
            displayedCards = []
        }

        isLoading = false
    }

    func applySample(cards: [CardData]) {
        allCards = cards
        refreshAvailableFilters()
        recomputeDisplayedCards()
    }

    func toggleType(_ type: PokemonType) {
        if selectedPokemonTypes.contains(type) {
            selectedPokemonTypes.remove(type)
        } else {
            selectedPokemonTypes.insert(type)
        }
        recomputeDisplayedCards()
    }

    func toggleRarity(_ rarity: Designation) {
        if selectedRarities.contains(rarity) {
            selectedRarities.remove(rarity)
        } else {
            selectedRarities.insert(rarity)
        }
        recomputeDisplayedCards()
    }

    func resetFilters() {
        searchText = ""
        selectedPokemonTypes = []
        selectedRarities = []
        recomputeDisplayedCards()
    }

    var availablePokemonTypes: [PokemonType] { availableTypesCache }
    var availableRarities: [Designation] { availableRaritiesCache }

    private func refreshAvailableFilters() {
        let types = Set(allCards.compactMap { $0.types }.flatMap { $0 })
        let rarities = Set(allCards.compactMap { $0.rarity?.designation })
        availableTypesCache = types.sorted { $0.rawValue < $1.rawValue }
        availableRaritiesCache = rarities.sorted { $0.rawValue < $1.rawValue }
    }

    private func recomputeDisplayedCards() {
        let query = searchText.foldedForSearch

        let filtered = allCards.filter { card in
            var matches = true

            if !query.isEmpty {
                matches = card.name.foldedForSearch.contains(query)
            }

            if matches, !selectedPokemonTypes.isEmpty {
                let cardTypes = Set(card.types ?? [])
                matches = !cardTypes.isDisjoint(with: selectedPokemonTypes)
            }

            if matches, !selectedRarities.isEmpty, let rarity = card.rarity?.designation {
                matches = selectedRarities.contains(rarity)
            }

            return matches
        }

        displayedCards = filtered.map { CardViewModel(cardData: $0) }
    }
}

private extension String {
    var foldedForSearch: String {
        folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    }
}
