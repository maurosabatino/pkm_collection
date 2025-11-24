import SwiftUI
import CoreKit

public final class FeatureExpansionModule: FeatureModule {
    private enum Entry: String {
        case explore
        case collections
        case deckImport
    }

    private let expansionStore: ExpansionStore
    private let ownedCardsStore: OwnedCardsStore
    private let wishlistStore: WishlistStore
    private let deckStore: DeckStore

    private let moduleId = "feature.expansion"

    init(
        expansionStore: ExpansionStore,
        ownedCardsStore: OwnedCardsStore,
        wishlistStore: WishlistStore,
        deckStore: DeckStore
    ) {
        self.expansionStore = expansionStore
        self.ownedCardsStore = ownedCardsStore
        self.wishlistStore = wishlistStore
        self.deckStore = deckStore
    }

    @MainActor
    public convenience init() {
        self.init(
            expansionStore: ExpansionStore(),
            ownedCardsStore: OwnedCardsStore(),
            wishlistStore: WishlistStore(),
            deckStore: DeckStore()
        )
    }

    public var metadata: ModuleMetadata {
        ModuleMetadata(
            id: moduleId,
            title: LocalizedStringKey(FeatureExpansionStrings.moduleTitle),
            systemImage: "books.vertical.fill"
        )
    }

    public func entryPoints(using navigator: ModuleNavigator) -> [ModuleEntryDescriptor] {
        [
            ModuleEntryDescriptor(
                moduleId: metadata.id,
                id: Entry.explore.rawValue,
                title: LocalizedStringKey(FeatureExpansionStrings.tabLabel),
                systemImage: metadata.systemImage
            ) { [weak self] navigator in
                guard let self else { return AnyView(EmptyView()) }
                return AnyView(
                    ExpansionFeatureEntryView(
                        expansionStore: self.expansionStore,
                        ownedCardsStore: self.ownedCardsStore
                    )
                    .environmentObject(navigator)
                )
            }
        ,
            ModuleEntryDescriptor(
                moduleId: metadata.id,
                id: Entry.collections.rawValue,
                title: "Collection",
                systemImage: "tray.full.fill"
            ) { [weak self] _ in
                guard let self else { return AnyView(EmptyView()) }
                return AnyView(
                    NavigationStack {
                        WishlistEntryView(wishlistStore: self.wishlistStore)
                    }
                )
            }
        ,
            ModuleEntryDescriptor(
                moduleId: metadata.id,
                id: Entry.deckImport.rawValue,
                title: "Mazzi",
                systemImage: "rectangle.stack.badge.plus"
            ) { [weak self] _ in
                guard let self else { return AnyView(EmptyView()) }
                return AnyView(
                    NavigationStack {
                        DecksEntryView(deckStore: self.deckStore, ownedCardsStore: self.ownedCardsStore)
                    }
                    .environmentObject(self.ownedCardsStore)
                )
            }
        ]
    }
}

private struct ExpansionFeatureEntryView: View {
    @ObservedObject var expansionStore: ExpansionStore
    @ObservedObject var ownedCardsStore: OwnedCardsStore

    var body: some View {
        ExpansionsNavigationStack()
            .environmentObject(expansionStore)
            .environmentObject(ownedCardsStore)
    }
}
