import Foundation
import GRDB

public struct DeckCardRecord: Codable, FetchableRecord, PersistableRecord {
    public var deckId: String
    public var cardId: String
    public var quantity: Int
    public var role: String
    public var updatedAt: TimeInterval
    public var dirty: Bool
    public var deleted: Bool

    public static let databaseTableName = "deck_cards"

    public enum Columns: String, CodingKey, ColumnExpression {
        case deckId = "deck_id"
        case cardId = "card_id"
        case quantity
        case role
        case updatedAt = "updated_at"
        case dirty
        case deleted
    }

    public typealias CodingKeys = Columns
}
