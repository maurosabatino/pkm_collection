
import SwiftUI
import CoreKit
import UIComponents

// MARK: - ExpansionDetailView

/// Schermata di dettaglio espansione con grid carte filtrabili, ricerca e progressi possesso.
struct ExpansionDetailView: View {
    let expansion: Expansion
    @StateObject private var cardListStore: CardListStore
    @State private var selectedCardForModal: CardViewModel? = nil
    @EnvironmentObject private var ownedCardsStore: OwnedCardsStore
    @State private var ownershipFilter: OwnershipFilter = .all
    @State private var selectedRarities: Set<Designation> = []
    @State private var isFilterSheetPresented = false

    init(expansion: Expansion, store: CardListStore? = nil) {
        self.expansion = expansion
        _cardListStore = StateObject(wrappedValue: store ?? CardListStore(expansionPath: expansion.path))
    }

    private var filteredCards: [CardViewModel] {
        cardListStore.displayedCards.filter { card in
            switch ownershipFilter {
            case .all:
                true
            case .owned:
                ownedCardsStore.isOwned(cardId: card.id)
            case .missing:
                !ownedCardsStore.isOwned(cardId: card.id)
            }
        }
        .filter { card in
            guard !selectedRarities.isEmpty else { return true }
            guard let rarity = card.rarityDesignation else { return false }
            return selectedRarities.contains(rarity)
        }
    }

    private var availableRarities: [Designation] {
        let rarities = Set(cardListStore.allCardData.compactMap { $0.rarity?.designation })
        return rarities.sorted { $0.rawValue < $1.rawValue }
    }

    var body: some View {
        VStack {
            content
        }
        .navigationTitle(expansion.name)
        .onAppear {
            Task {
                await cardListStore.loadCards()
            }
        }
        .sheet(item: $selectedCardForModal) { card in
            FullCardModalView(card: card, isShowingModal: Binding(
                get: { selectedCardForModal != nil },
                set: { newValue in
                    if !newValue { selectedCardForModal = nil }
                }
            ))
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    isFilterSheetPresented = true
                } label: {
                    Image(systemName: (ownershipFilter != .all || !selectedRarities.isEmpty) ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                }
                .accessibilityLabel(Text(FeatureExpansionStrings.filtersTitle))
            }
        }
        .sheet(isPresented: $isFilterSheetPresented) {
            ExpansionFiltersView(
                ownershipFilter: $ownershipFilter,
                selectedRarities: $selectedRarities,
                availableRarities: availableRarities,
                displayMode: $cardListStore.displayMode
            )
        }
    }

    private var snapshot: ProgressSnapshot? {
        guard !cardListStore.allCardData.isEmpty else { return nil }
        return cardListStore.progressSnapshot(using: ownedCardsStore)
    }

    @ViewBuilder
    private var content: some View {
        if cardListStore.isLoading {
            ProgressView(FeatureExpansionStrings.loadingCards)
        } else if let error = cardListStore.error {
            ErrorStateView(error: error) {
                Task { await cardListStore.loadCards() }
            }
        } else if cardListStore.displayedCards.isEmpty {
            ContentUnavailableView(
                FeatureExpansionStrings.noCardsFound,
                systemImage: "tray.fill",
                description: Text(FeatureExpansionStrings.checkJsonOrLogic)
            )
        } else {
            CardCatalogGrid(
                cards: filteredCards,
                selectedCard: $selectedCardForModal,
                displayMode: cardListStore.displayMode
            ) {
                VStack(alignment: .leading, spacing: UIConstants.paddingMedium) {
                    CollapsibleSearchBar(
                        text: $cardListStore.searchText,
                        prompt: FeatureExpansionStrings.searchCardsPlaceholder
                    )

                    if let snapshot {
                        ExpansionDetailHeader(expansion: expansion, snapshot: snapshot)
                    }
                }
            }
        }
    }
}

// MARK: - Preview for ExpansionDetailView
struct ExpansionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleExpansion = FeatureExpansionSamples.sampleExpansion
        let mockCardListStore = CardListStore(expansionPath: sampleExpansion.path)
        mockCardListStore.allCardData = FeatureExpansionSamples.sampleCardData

        return NavigationStack {
            ExpansionDetailView(expansion: sampleExpansion, store: mockCardListStore)
                .environmentObject(OwnedCardsStore())
        }
    }
}
