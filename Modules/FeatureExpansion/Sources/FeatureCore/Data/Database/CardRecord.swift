import Foundation
import GRDB
import CoreKit

struct CardRecord: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var expansionId: String
    var name: String
    var collectorNumber: String?
    var rarity: String?
    var types: String?
    var stage: String?
    var hp: Int?
    var lang: String?
    var imageUrl: String?
    var foilUrl: String?
    var etchUrl: String?
    var dataHash: String?
    var updatedAt: TimeInterval?
    var jsonData: Data?

    static let databaseTableName = "cards"

    enum Columns: String, CodingKey, ColumnExpression {
        case id
        case expansionId = "expansion_id"
        case name
        case collectorNumber = "collector_number"
        case rarity
        case types
        case stage
        case hp
        case lang
        case imageUrl = "image_url"
        case foilUrl = "foil_url"
        case etchUrl = "etch_url"
        case dataHash = "data_hash"
        case updatedAt = "updated_at"
        case jsonData = "json_data"
    }

    typealias CodingKeys = Columns

    init(card: CardData, expansionId: String) {
        self.id = card.id
        self.expansionId = expansionId
        self.name = card.name
        self.collectorNumber = card.collectorNumber.full
        self.rarity = card.rarity?.designation.rawValue
        self.types = card.types?.map(\.rawValue).joined(separator: ",")
        self.stage = card.stage?.rawValue
        self.hp = card.hp
        self.lang = card.lang
        self.imageUrl = card.images?.tcgl.tex?.front
        self.foilUrl = card.images?.tcgl.tex?.foil
        self.etchUrl = card.images?.tcgl.tex?.etch
        self.dataHash = card.ext?.tcgl.key
        self.updatedAt = Date().timeIntervalSince1970
        self.jsonData = try? JSONEncoder().encode(card)
    }

    func toModel() -> CardData? {
        if let jsonData, let decoded = try? JSONDecoder().decode(CardData.self, from: jsonData) {
            return decoded
        }
        return nil
    }
}
