import Foundation
import GRDB

public struct OwnedCardRecord: Codable, FetchableRecord, PersistableRecord {
    public var cardId: String
    public var quantity: Int
    public var notes: String?
    public var lastUpdated: TimeInterval
    public var isWishlist: Bool
    public var dirty: Bool
    public var deleted: Bool

    public static let databaseTableName = "ownership"

    public enum Columns: String, CodingKey, ColumnExpression {
        case cardId = "card_id"
        case quantity
        case notes
        case lastUpdated = "last_updated"
        case isWishlist = "is_wishlist"
        case dirty
        case deleted
    }

    public typealias CodingKeys = Columns

    public init(from model: OwnedCard, dirty: Bool = false, deleted: Bool = false) {
        self.cardId = model.cardId
        self.quantity = model.quantity
        self.notes = model.notes
        self.lastUpdated = model.lastUpdated.timeIntervalSince1970
        self.isWishlist = model.isWishlist
        self.dirty = dirty
        self.deleted = deleted
    }

    public func toModel() -> OwnedCard {
        OwnedCard(
            cardId: cardId,
            quantity: quantity,
            notes: notes,
            lastUpdated: Date(timeIntervalSince1970: lastUpdated),
            isWishlist: isWishlist
        )
    }
}
