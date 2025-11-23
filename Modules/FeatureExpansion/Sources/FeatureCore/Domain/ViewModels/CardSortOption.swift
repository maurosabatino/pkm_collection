import Foundation

enum CardSortOption: String, CaseIterable, Identifiable, Codable {
    case collectorNumber
    case name
    case rarity
    case releaseDate

    var id: String { rawValue }

    var title: String {
        switch self {
        case .collectorNumber:
            return FeatureExpansionStrings.sortByNumber
        case .name:
            return FeatureExpansionStrings.sortByName
        case .rarity:
            return FeatureExpansionStrings.sortByRarity
        case .releaseDate:
            return FeatureExpansionStrings.sortByReleaseDate
        }
    }
}
