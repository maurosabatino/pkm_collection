import Foundation
import GRDB

public struct DeckRecord: Codable, FetchableRecord, PersistableRecord {
    public var id: String
    public var name: String
    public var format: String?
    public var notes: String?
    public var updatedAt: TimeInterval
    public var dirty: Bool
    public var deleted: Bool

    public static let databaseTableName = "decks"

    public enum Columns: String, CodingKey, ColumnExpression {
        case id
        case name
        case format
        case notes
        case updatedAt = "updated_at"
        case dirty
        case deleted
    }

    public typealias CodingKeys = Columns
}
