import SwiftUI
import CoreKit
import CoreModels
import Persistence

public final class DecksFeatureModule: FeatureModule {
    private enum Entry: String {
        case decks
    }

    public let metadata: ModuleMetadata = .init(
        id: "feature.decks",
        title: LocalizedStringKey("Mazzi"),
        systemImage: "rectangle.stack.badge.plus"
    )

    private let ownedCardsStore: OwnedCardsStore
    private let deckStore: DeckStore
    private let cardDetailBridge: CardDetailBridge?

    public init(ownedCardsStore: OwnedCardsStore, deckStore: DeckStore, cardDetailBridge: CardDetailBridge? = nil) {
        self.ownedCardsStore = ownedCardsStore
        self.deckStore = deckStore
        self.cardDetailBridge = cardDetailBridge
    }

    public func entryPoints(using navigator: ModuleNavigator) -> [ModuleEntryDescriptor] {
        [
            ModuleEntryDescriptor(
                moduleId: metadata.id,
                id: Entry.decks.rawValue,
                title: metadata.title,
                systemImage: metadata.systemImage
            ) { [ownedCardsStore, deckStore, cardDetailBridge] _ in
                AnyView(
                    NavigationStack {
                        DecksEntryView(
                            deckStore: deckStore,
                            ownedCardsStore: ownedCardsStore,
                            cardDetailBridge: cardDetailBridge
                        )
                    }
                    .environmentObject(ownedCardsStore)
                )
            }
        ]
    }
}
