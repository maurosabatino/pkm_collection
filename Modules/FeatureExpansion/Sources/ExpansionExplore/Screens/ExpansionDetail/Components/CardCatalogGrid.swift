import SwiftUI
import CoreKit
import Persistence

/// Griglia di carte con header opzionale scrollabile e azioni di proprietà.
struct CardCatalogGrid<Header: View>: View {
    let cards: [CardViewModel]
    @Binding var selectedCard: CardViewModel?
    var displayMode: CardDisplayMode
    let header: Header
    @EnvironmentObject private var ownedCardsStore: OwnedCardsStore


    init(
        cards: [CardViewModel],
        selectedCard: Binding<CardViewModel?>,
        displayMode: CardDisplayMode,
        @ViewBuilder header: () -> Header
    ) {
        self.cards = cards
        _selectedCard = selectedCard
        self.displayMode = displayMode
        self.header = header()
    }

    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width - (UIConstants.paddingMedium * 2)
            let itemWidth = UIConstants.cardGridMinimumItemSize
            let columnsCount = max(Int(screenWidth / itemWidth), 1)

            let dynamicColumns = Array(
                repeating: GridItem(.flexible(), spacing: UIConstants.gridSpacing),
                count: columnsCount
            )

            ScrollView {
                VStack(alignment: .leading, spacing: UIConstants.paddingMedium) {
                    header

                    LazyVGrid(columns: dynamicColumns, spacing: UIConstants.gridSpacing) {
                        ForEach(cards, id: \.id) { card in
                            let props = CardTileProps(
                                id: card.id,
                                name: card.name,
                                expansionName: card.expansionName,
                                foilDescription: card.foilDescription,
                                displayMode: displayMode,
                                isOwned: ownedCardsStore.isOwned(cardId: card.id),
                                quantity: ownedCardsStore.quantity(for: card.id)
                            )

                            CardGridTileView(
                                card: card,
                                props: props,
                                onSelect: { selectedCard = card },
                                onToggleOwned: { ownedCardsStore.toggleOwnership(for: card.id) },
                                onAddCopy: { ownedCardsStore.increment(cardId: card.id, step: 1) },
                                onRemoveCopy: { ownedCardsStore.increment(cardId: card.id, step: -1) }
                            )
                            .equatable()
                        }
                    }
                }
                .padding(.horizontal, UIConstants.paddingMedium)
                .padding(.vertical, UIConstants.paddingMedium)
            }
        }
    }
}

extension CardCatalogGrid where Header == EmptyView {
    init(
        cards: [CardViewModel],
        selectedCard: Binding<CardViewModel?>,
        displayMode: CardDisplayMode
    ) {
        self.init(
            cards: cards,
            selectedCard: selectedCard,
            displayMode: displayMode,
            header: { EmptyView() }
        )
    }
}
