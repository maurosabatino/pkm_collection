import SwiftUI
import CoreKit
import Persistence

public final class CollectionFeatureModule: FeatureModule {
    private enum Entry: String {
        case collections
    }

    public let metadata: ModuleMetadata = .init(
        id: "feature.collection",
        title: LocalizedStringKey("Collection"),
        systemImage: "tray.full.fill"
    )

    private let wishlistStore: WishlistStore

    public init(wishlistStore: WishlistStore) {
        self.wishlistStore = wishlistStore
    }

    public func entryPoints(using navigator: ModuleNavigator) -> [ModuleEntryDescriptor] {
        [
            ModuleEntryDescriptor(
                moduleId: metadata.id,
                id: Entry.collections.rawValue,
                title: metadata.title,
                systemImage: metadata.systemImage
            ) { _ in
                AnyView(
                    NavigationStack {
                        WishlistEntryView(wishlistStore: self.wishlistStore)
                    }
                )
            }
        ]
    }
}
