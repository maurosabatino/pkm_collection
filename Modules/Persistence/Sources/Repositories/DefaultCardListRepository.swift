import Foundation
import CoreModels

public struct DefaultCardListRepository: CardListRepository {
    public init() {}

    public func fetchCardList(path: String, language: String) async throws -> [CardData] {
        let fileName = "\(path).\(language)"
        let subdir = "db/\(language)"
        guard let url = ResourceLocator.url(forResource: fileName, withExtension: "json", subdirectory: subdir) else {
            throw NSError(domain: "cardlist-json-missing", code: -1, userInfo: ["fileName": fileName, "lang": language])
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([CardData].self, from: data)
    }
}
