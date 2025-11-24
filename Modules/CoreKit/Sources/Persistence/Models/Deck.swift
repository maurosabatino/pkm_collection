import Foundation

public struct Deck: Codable, Identifiable, Equatable {
    public let id: String
    public var name: String
    public var format: String?
    public var notes: String?
    public var updatedAt: Date
    public var deleted: Bool

    public init(
        id: String = UUID().uuidString,
        name: String,
        format: String? = nil,
        notes: String? = nil,
        updatedAt: Date = Date(),
        deleted: Bool = false
    ) {
        self.id = id
        self.name = name
        self.format = format
        self.notes = notes
        self.updatedAt = updatedAt
        self.deleted = deleted
    }
}

public struct DeckCard: Codable, Identifiable, Equatable {
    public var id: String { "\(deckId)-\(cardId)-\(role)" }
    public let deckId: String
    public let cardId: String
    public var quantity: Int
    public var role: String // "main" | "side"
    public var updatedAt: Date
    public var deleted: Bool

    public init(
        deckId: String,
        cardId: String,
        quantity: Int,
        role: String = "main",
        updatedAt: Date = Date(),
        deleted: Bool = false
    ) {
        self.deckId = deckId
        self.cardId = cardId
        self.quantity = quantity
        self.role = role
        self.updatedAt = updatedAt
        self.deleted = deleted
    }
}
