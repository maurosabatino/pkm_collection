import Foundation

enum FeatureExpansionStrings {
    private static let bundle = Bundle(for: BundleToken.self)
    private static let table = "FeatureExpansion"

    static var moduleTitle: String { localized("featureExpansion.title") }
    static var tabLabel: String { localized("featureExpansion.tab.label") }
    static var releaseDatePrefix: String { localized("featureExpansion.expansion.releaseDatePrefix") }
    static var cardsPrefix: String { localized("featureExpansion.expansion.cardsPrefix") }
    static var searchExpansionsPlaceholder: String { localized("featureExpansion.search.expansions.placeholder") }
    static var searchCardsPlaceholder: String { localized("featureExpansion.search.cards.placeholder") }
    static var expansionDetailsPrefix: String { localized("featureExpansion.details.title.prefix") }
    static var displayModeLabel: String { localized("featureExpansion.displayMode.title") }
    static var regularSetMode: String { localized("featureExpansion.displayMode.regular") }
    static var masterSetMode: String { localized("featureExpansion.displayMode.master") }
    static var loadingCards: String { localized("featureExpansion.loading.cards") }
    static var cardCatalogTitle: String { localized("featureExpansion.catalog.title") }
    static var filtersTitle: String { localized("featureExpansion.filters.title") }
    static var filterTypesTitle: String { localized("featureExpansion.filters.types") }
    static var filterRaritiesTitle: String { localized("featureExpansion.filters.rarities") }
    static var filterExpansionsTitle: String { localized("featureExpansion.filters.expansions") }
    static var filtersClear: String { localized("featureExpansion.filters.clear") }
    static var filtersApply: String { localized("featureExpansion.filters.apply") }
    static var filtersUnavailable: String { localized("featureExpansion.filters.unavailable") }
    static var showOwnedOnly: String { localized("featureExpansion.filters.showOwnedOnly") }
    static var sortTitle: String { localized("featureExpansion.sort.title") }
    static var sortByNumber: String { localized("featureExpansion.sort.number") }
    static var sortByName: String { localized("featureExpansion.sort.name") }
    static var sortByRarity: String { localized("featureExpansion.sort.rarity") }
    static var sortByReleaseDate: String { localized("featureExpansion.sort.release") }
    static var errorLoadingCardsPrefix: String { localized("featureExpansion.error.loadingCardsPrefix") }
    static var retry: String { localized("featureExpansion.action.retry") }
    static var noCardsFound: String { localized("featureExpansion.empty.title") }
    static var checkJsonOrLogic: String { localized("featureExpansion.empty.description") }
    static var noFoil: String { localized("featureExpansion.card.noFoil") }

    static func errorLoadingExpansions(_ error: String) -> String {
        String(format: localized("featureExpansion.error.loadingExpansions"), locale: Locale.current, error)
    }

    static func errorLoadingCards(for expansionPath: String, error: String) -> String {
        String(format: localized("featureExpansion.error.loadingCardsForSet"), locale: Locale.current, expansionPath, error)
    }

    static func jsonFileNotFound(_ fileName: String) -> String {
        String(format: localized("featureExpansion.error.jsonNotFound"), locale: Locale.current, fileName)
    }

    static func cardsJsonFileNotFound(_ fileName: String) -> String {
        String(format: localized("featureExpansion.error.cardsJsonNotFound"), locale: Locale.current, fileName)
    }

    private static func localized(_ key: String) -> String {
        bundle.localizedString(forKey: key, value: nil, table: table)
    }

    private final class BundleToken {}
}
