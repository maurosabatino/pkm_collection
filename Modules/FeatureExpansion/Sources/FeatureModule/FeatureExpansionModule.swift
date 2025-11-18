import SwiftUI
import CoreKit

public final class FeatureExpansionModule: FeatureModule {
    private enum Entry: String {
        case explore
    }

    private let expansionStore: ExpansionStore
    private let ownedCardsStore: OwnedCardsStore

    init(
        expansionStore: ExpansionStore,
        ownedCardsStore: OwnedCardsStore
    ) {
        self.expansionStore = expansionStore
        self.ownedCardsStore = ownedCardsStore
    }

    @MainActor
    public convenience init() {
        self.init(
            expansionStore: ExpansionStore(),
            ownedCardsStore: OwnedCardsStore()
        )
    }

    public var metadata: ModuleMetadata {
        ModuleMetadata(
            id: "feature.expansion",
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
                        expansionStore: expansionStore,
                        ownedCardsStore: ownedCardsStore
                    )
                    .environmentObject(navigator)
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
