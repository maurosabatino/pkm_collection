import Foundation
import CoreModels
import GRDB

// Decks
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
        case id, name, format, notes, updatedAt = "updated_at", dirty, deleted
    }

    public typealias CodingKeys = Columns
}

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
        case deckId = "deck_id", cardId = "card_id", quantity, role, updatedAt = "updated_at", dirty, deleted
    }

    public typealias CodingKeys = Columns
}

// Wishlist
public struct WishlistRecord: Codable, FetchableRecord, PersistableRecord {
    public var id: String
    public var name: String
    public var notes: String?
    public var updatedAt: TimeInterval
    public var dirty: Bool
    public var deleted: Bool

    public static let databaseTableName = "wishlists"

    public enum Columns: String, CodingKey, ColumnExpression {
        case id, name, notes, updatedAt = "updated_at", dirty, deleted
    }

    public typealias CodingKeys = Columns
}

public struct WishlistItemRecord: Codable, FetchableRecord, PersistableRecord {
    public var wishlistId: String
    public var cardId: String
    public var quantity: Int
    public var updatedAt: TimeInterval
    public var dirty: Bool
    public var deleted: Bool

    public static let databaseTableName = "wishlist_items"

    public enum Columns: String, CodingKey, ColumnExpression {
        case wishlistId = "wishlist_id", cardId = "card_id", quantity, updatedAt = "updated_at", dirty, deleted
    }

    public typealias CodingKeys = Columns
}

// Owned
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
        case cardId = "card_id", quantity, notes, lastUpdated = "last_updated", isWishlist = "is_wishlist", dirty, deleted
    }

    public typealias CodingKeys = Columns
}

// MARK: - Conversions

public extension OwnedCardRecord {
    init(from owned: OwnedCard, dirty: Bool, deleted: Bool) {
        self.cardId = owned.cardId
        self.quantity = owned.quantity
        self.notes = owned.notes
        self.lastUpdated = owned.lastUpdated.timeIntervalSince1970
        self.isWishlist = owned.isWishlist
        self.dirty = dirty
        self.deleted = deleted
    }

    func toModel() -> OwnedCard {
        OwnedCard(
            cardId: cardId,
            quantity: quantity,
            notes: notes,
            lastUpdated: Date(timeIntervalSince1970: lastUpdated),
            isWishlist: isWishlist
        )
    }
}
