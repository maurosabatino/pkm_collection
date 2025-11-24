import Foundation
import GRDB

public struct WishlistItemRecord: Codable, FetchableRecord, PersistableRecord {
    public var wishlistId: String
    public var cardId: String
    public var quantity: Int
    public var updatedAt: TimeInterval
    public var dirty: Bool
    public var deleted: Bool

    public static let databaseTableName = "wishlist_items"

    public enum Columns: String, CodingKey, ColumnExpression {
        case wishlistId = "wishlist_id"
        case cardId = "card_id"
        case quantity
        case updatedAt = "updated_at"
        case dirty
        case deleted
    }

    public typealias CodingKeys = Columns
}
