import Foundation

public struct OwnedCard: Codable, Identifiable, Equatable {
    public let cardId: String
    public var quantity: Int
    public var notes: String?
    public var lastUpdated: Date
    public var isWishlist: Bool

    public var id: String { cardId }

    public init(cardId: String, quantity: Int = 1, notes: String? = nil, lastUpdated: Date = Date(), isWishlist: Bool = false) {
        self.cardId = cardId
        self.quantity = quantity
        self.notes = notes
        self.lastUpdated = lastUpdated
        self.isWishlist = isWishlist
    }
}
