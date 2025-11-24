import Foundation
import GRDB

public struct WishlistRecord: Codable, FetchableRecord, PersistableRecord {
    public var id: String
    public var name: String
    public var notes: String?
    public var updatedAt: TimeInterval
    public var dirty: Bool
    public var deleted: Bool

    public static let databaseTableName = "wishlists"

    public enum Columns: String, CodingKey, ColumnExpression {
        case id
        case name
        case notes
        case updatedAt = "updated_at"
        case dirty
        case deleted
    }

    public typealias CodingKeys = Columns
}
