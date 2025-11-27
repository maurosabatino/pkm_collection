import SwiftUI
import CoreModels
import CoreKit
import Persistence

public final class FeatureExpansionModule: FeatureModule {
    private enum Entry: String {
        case explore
    }

    private let expansionStore: ExpansionStore
    private let ownedCardsStore: OwnedCardsStore

    private let moduleId = "feature.expansion"

    @MainActor
    public init(
        expansionStore: ExpansionStore,
        ownedCardsStore: OwnedCardsStore
    ) {
        self.expansionStore = expansionStore
        self.ownedCardsStore = ownedCardsStore
    }

    @MainActor
    public convenience init(
        ownedCardsStore: OwnedCardsStore,
        languageSettings: LanguageSettings = .shared
    ) {
        self.init(
            expansionStore: ExpansionStore(languageSettings: languageSettings),
            ownedCardsStore: ownedCardsStore
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
