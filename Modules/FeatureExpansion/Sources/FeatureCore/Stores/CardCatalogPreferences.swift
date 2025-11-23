import Foundation

struct CardCatalogPreferences: Codable, Equatable {
    var searchText: String = ""
    var selectedPokemonTypes: [String] = []
    var selectedRarities: [String] = []
    var selectedExpansions: [String] = []
    var sortOption: String = CardSortOption.collectorNumber.rawValue
    var showOwnedOnly: Bool = false
    var displayMode: String = CardDisplayMode.regular.rawValue
}

protocol CardCatalogPreferencesPersisting {
    func load() -> CardCatalogPreferences?
    func save(_ preferences: CardCatalogPreferences)
}

final class UserDefaultsCardCatalogPreferences: CardCatalogPreferencesPersisting {
    private let key = "featureExpansion.cardCatalog.preferences"
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func load() -> CardCatalogPreferences? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(CardCatalogPreferences.self, from: data)
    }

    func save(_ preferences: CardCatalogPreferences) {
        guard let data = try? JSONEncoder().encode(preferences) else { return }
        userDefaults.set(data, forKey: key)
    }
}
