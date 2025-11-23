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
    @Published var selectedExpansions: Set<String> = []
    @Published var sortOption: CardSortOption = .collectorNumber

    private var allCards: [CardWithExpansion] = []
    private let fetchCardListUseCase: FetchCardListUseCase
    private let preferencesStorage: CardCatalogPreferencesPersisting
    private var storedPreferences: CardCatalogPreferences
    private var cancellables: Set<AnyCancellable> = []
    private var availableTypesCache: [PokemonType] = []
    private var availableRaritiesCache: [Designation] = []
    private var availableExpansionsCache: [Expansion] = []
    private var latestShowOwnedOnly = false
    private var latestDisplayMode: CardDisplayMode = .regular
    private var recomputeWorkItem: DispatchWorkItem?
    private let filterQueue = DispatchQueue(label: "CardCatalogStore.filter", qos: .userInitiated)

    init(
        fetchCardListUseCase: FetchCardListUseCase = FetchCardListUseCaseImpl(),
        preferencesStorage: CardCatalogPreferencesPersisting = UserDefaultsCardCatalogPreferences()
    ) {
        self.fetchCardListUseCase = fetchCardListUseCase
        self.preferencesStorage = preferencesStorage
        self.storedPreferences = preferencesStorage.load() ?? CardCatalogPreferences()

        searchText = storedPreferences.searchText
        selectedPokemonTypes = Set(storedPreferences.selectedPokemonTypes.compactMap(PokemonType.init(rawValue:)))
        selectedRarities = Set(storedPreferences.selectedRarities.compactMap(Designation.init(rawValue:)))
        selectedExpansions = Set(storedPreferences.selectedExpansions)
        sortOption = CardSortOption(rawValue: storedPreferences.sortOption) ?? .collectorNumber
        latestShowOwnedOnly = storedPreferences.showOwnedOnly
        latestDisplayMode = CardDisplayMode(rawValue: storedPreferences.displayMode) ?? .regular

        subscribeToChanges()
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
            availableExpansionsCache = expansions
            let defaultExpansionSelection = normalizedExpansionsSelection(from: expansions)
            if selectedExpansions.isEmpty {
                selectedExpansions = defaultExpansionSelection
            } else {
                let filteredSelection = selectedExpansions.intersection(defaultExpansionSelection)
                selectedExpansions = filteredSelection.isEmpty ? defaultExpansionSelection : filteredSelection
            }

            var aggregated: [CardWithExpansion] = []
            for expansion in expansions {
                let cards = try await fetchCardListUseCase.execute(path: expansion.path)
                let enriched = cards.map { card in
                    CardWithExpansion(
                        card: card,
                        expansionPath: expansion.path,
                        expansionName: expansion.name,
                        expansionReleaseDate: expansion.releaseDate
                    )
                }
                aggregated.append(contentsOf: enriched)
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

    func applySample(cards: [CardData], expansions: [Expansion] = [FeatureExpansionSamples.sampleExpansion]) {
        availableExpansionsCache = expansions
        selectedExpansions = normalizedExpansionsSelection(from: expansions)
        allCards = zip(cards, expansions.cycledSequence()).map { card, expansion in
            CardWithExpansion(
                card: card,
                expansionPath: expansion.path,
                expansionName: expansion.name,
                expansionReleaseDate: expansion.releaseDate
            )
        }
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

    func toggleExpansion(path: String) {
        if selectedExpansions.contains(path) {
            selectedExpansions.remove(path)
        } else {
            selectedExpansions.insert(path)
        }
        recomputeDisplayedCards()
    }

    func setSortOption(_ option: CardSortOption) {
        sortOption = option
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
        selectedExpansions = normalizedExpansionsSelection(from: availableExpansionsCache)
        recomputeDisplayedCards()
    }

    var availablePokemonTypes: [PokemonType] { availableTypesCache }
    var availableRarities: [Designation] { availableRaritiesCache }
    var availableExpansions: [Expansion] { availableExpansionsCache }

    var viewPreferences: (showOwnedOnly: Bool, displayMode: CardDisplayMode) {
        (latestShowOwnedOnly, latestDisplayMode)
    }

    func persistViewPreferences(showOwnedOnly: Bool, displayMode: CardDisplayMode) {
        latestShowOwnedOnly = showOwnedOnly
        latestDisplayMode = displayMode
        savePreferences()
    }

    private func subscribeToChanges() {
        $searchText
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .combineLatest($selectedPokemonTypes, $selectedRarities)
            .sink { [weak self] _ in
                self?.recomputeDisplayedCards()
            }
            .store(in: &cancellables)

        $selectedExpansions
            .sink { [weak self] _ in
                self?.recomputeDisplayedCards()
            }
            .store(in: &cancellables)

        $sortOption
            .sink { [weak self] _ in
                self?.recomputeDisplayedCards()
            }
            .store(in: &cancellables)
    }

    private func refreshAvailableFilters() {
        let types = Set(allCards.compactMap { $0.card.types }.flatMap { $0 })
        let rarities = Set(allCards.compactMap { $0.card.rarity?.designation })
        availableTypesCache = types.sorted { $0.rawValue < $1.rawValue }
        availableRaritiesCache = rarities.sorted { $0.rawValue < $1.rawValue }
    }

    private func recomputeDisplayedCards() {
        let query = searchText.foldedForSearch
        let selectedTypes = selectedPokemonTypes
        let selectedRarities = selectedRarities
        let selectedExpansions = selectedExpansions
        let sortOption = sortOption
        let cards = allCards

        recomputeWorkItem?.cancel()
        var workItem: DispatchWorkItem?
        let newWorkItem = DispatchWorkItem { [weak self] in
            let filtered = cards.filter { item in
                var matches = true

                if !query.isEmpty {
                    matches = item.card.name.foldedForSearch.contains(query)
                }

                if matches, !selectedTypes.isEmpty {
                    let cardTypes = Set(item.card.types ?? [])
                    matches = !cardTypes.isDisjoint(with: selectedTypes)
                }

                if matches, !selectedRarities.isEmpty, let rarity = item.card.rarity?.designation {
                    matches = selectedRarities.contains(rarity)
                }

                if matches, !selectedExpansions.isEmpty {
                    matches = selectedExpansions.contains(item.expansionPath)
                }

                return matches
            }

            let sorted = filtered.sorted { lhs, rhs in
                switch sortOption {
                case .collectorNumber:
                    return lhs.card.collectorNumber.numeric < rhs.card.collectorNumber.numeric
                case .name:
                    return lhs.card.name.foldedForSearch < rhs.card.name.foldedForSearch
                case .rarity:
                    let leftRank = self?.rarityRank(lhs.card.rarity?.designation) ?? Int.max
                    let rightRank = self?.rarityRank(rhs.card.rarity?.designation) ?? Int.max
                    if leftRank == rightRank {
                        return lhs.card.collectorNumber.numeric < rhs.card.collectorNumber.numeric
                    }
                    return leftRank < rightRank
                case .releaseDate:
                    if lhs.expansionReleaseDate == rhs.expansionReleaseDate {
                        return lhs.card.collectorNumber.numeric < rhs.card.collectorNumber.numeric
                    }
                    return lhs.expansionReleaseDate > rhs.expansionReleaseDate
                }
            }

            let viewModels = sorted.map {
                CardViewModel(
                    cardData: $0.card,
                    expansionName: $0.expansionName,
                    expansionPath: $0.expansionPath
                )
            }

            DispatchQueue.main.async { [weak self] in
                guard
                    let self,
                    let workItem,
                    self.recomputeWorkItem === workItem,
                    !workItem.isCancelled
                else { return }
                self.displayedCards = viewModels
                self.savePreferences()
            }
        }

        workItem = newWorkItem
        recomputeWorkItem = newWorkItem
        filterQueue.async(execute: newWorkItem)
    }

    private func rarityRank(_ designation: Designation?) -> Int {
        guard let designation else { return Int.max }
        let order: [Designation] = [
            .rareSecret, .rareRainbow, .goldRare, .hyperRare, .specialIllustrationRare,
            .illustrationRare, .rareUltra, .ultraRare, .rareShiny, .rareShinyGx,
            .rareShiny, .rareAmazing, .rarePrime, .rareLegend, .rareShining,
            .rareBreak, .doubleRare, .rareHolo, .rareReverseHolo, .rare,
            .uncommon, .common, .promo, .rarePromo, .leaguePromo, .staffPromo,
            .tournamentPromo, .aceSpecRare, .shinyRare, .shinyUltraRare
        ]
        return order.firstIndex(of: designation) ?? order.count + 1
    }

    private func normalizedExpansionsSelection(from expansions: [Expansion]) -> Set<String> {
        Set(expansions.map { $0.path })
    }

    private func savePreferences() {
        let preferences = CardCatalogPreferences(
            searchText: searchText,
            selectedPokemonTypes: selectedPokemonTypes.map(\.rawValue),
            selectedRarities: selectedRarities.map(\.rawValue),
            selectedExpansions: Array(selectedExpansions),
            sortOption: sortOption.rawValue,
            showOwnedOnly: latestShowOwnedOnly,
            displayMode: latestDisplayMode.rawValue
        )
        storedPreferences = preferences
        preferencesStorage.save(preferences)
    }
}

private struct CardWithExpansion {
    let card: CardData
    let expansionPath: String
    let expansionName: String
    let expansionReleaseDate: Date
}

private extension String {
    var foldedForSearch: String {
        folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
    }
}

private extension Array {
    func cycledSequence() -> AnySequence<Element> {
        AnySequence {
            var iterator = makeIterator()
            return AnyIterator {
                if let next = iterator.next() {
                    return next
                }
                iterator = makeIterator()
                return iterator.next()
            }
        }
    }
}
