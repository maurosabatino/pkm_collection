import Foundation
import CoreKit
import FeatureExpansion
import FeatureCollection
import FeatureDecks
import FeatureSettings
import Persistence

@MainActor
final class AppModuleRegistry: ObservableObject {
    let navigator = ModuleNavigator()
    let modules: [AnyFeatureModule]
    let entries: [ModuleEntryDescriptor]
    let ownedCardsStore: OwnedCardsStore
    let wishlistStore: WishlistStore
    let deckStore: DeckStore
    let languageSettings: LanguageSettings

    init() {
        self.ownedCardsStore = OwnedCardsStore()
        self.wishlistStore = WishlistStore()
        self.deckStore = DeckStore()
        self.languageSettings = LanguageSettings.shared

        let cardDetailBridge = CardDetailBridgeAdapter()

        let expansionModule = FeatureExpansionModule(ownedCardsStore: ownedCardsStore, languageSettings: languageSettings)
        let collectionModule = CollectionFeatureModule(wishlistStore: wishlistStore)
        let decksModule = DecksFeatureModule(
            ownedCardsStore: ownedCardsStore,
            deckStore: deckStore,
            cardDetailBridge: cardDetailBridge
        )

        let settingsModule = FeatureSettingsModule(languageSettings: languageSettings)

        let featureModules = [
            AnyFeatureModule(expansionModule),
            AnyFeatureModule(collectionModule),
            AnyFeatureModule(decksModule),
            AnyFeatureModule(settingsModule)
        ]
        self.modules = featureModules
        let localNavigator = navigator
        self.entries = featureModules.flatMap { $0.entryPoints(using: localNavigator) }
    }
}
