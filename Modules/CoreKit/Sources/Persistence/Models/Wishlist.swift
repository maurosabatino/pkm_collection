import Foundation

public struct Wishlist: Codable, Identifiable, Equatable {
    public let id: String
    public var name: String
    public var notes: String?
    public var updatedAt: Date
    public var deleted: Bool

    public init(
        id: String = UUID().uuidString,
        name: String,
        notes: String? = nil,
        updatedAt: Date = Date(),
        deleted: Bool = false
    ) {
        self.id = id
        self.name = name
        self.notes = notes
        self.updatedAt = updatedAt
        self.deleted = deleted
    }
}

public struct WishlistItem: Codable, Identifiable, Equatable {
    public var id: String { "\(wishlistId)-\(cardId)" }
    public let wishlistId: String
    public let cardId: String
    public var quantity: Int
    public var updatedAt: Date
    public var deleted: Bool

    public init(
        wishlistId: String,
        cardId: String,
        quantity: Int = 0,
        updatedAt: Date = Date(),
        deleted: Bool = false
    ) {
        self.wishlistId = wishlistId
        self.cardId = cardId
        self.quantity = quantity
        self.updatedAt = updatedAt
        self.deleted = deleted
    }
}
