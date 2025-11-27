import Foundation
import GRDB
import CoreModels

public final class DeckCardDAO {
    private let dbQueue: DatabaseQueue

    public init?(manager: DatabaseManager? = DatabaseManager.shared) {
        guard let manager else { return nil }
        dbQueue = manager.dbQueue
    }

    public func cards(for deckId: String) throws -> [DeckCard] {
        try dbQueue.read { db in
            try DeckCardRecord
                .filter(Column("deck_id") == deckId && Column("deleted") == false)
                .fetchAll(db)
                .map { record in
                    DeckCard(
                        deckId: record.deckId,
                        cardId: record.cardId,
                        quantity: record.quantity,
                        role: record.role,
                        updatedAt: Date(timeIntervalSince1970: record.updatedAt),
                        deleted: record.deleted
                    )
                }
        }
    }

    public func upsert(_ card: DeckCard, dirty: Bool = true) throws {
        try dbQueue.write { db in
            let record = DeckCardRecord(
                deckId: card.deckId,
                cardId: card.cardId,
                quantity: card.quantity,
                role: card.role,
                updatedAt: card.updatedAt.timeIntervalSince1970,
                dirty: dirty,
                deleted: card.deleted
            )
            try record.insert(db, onConflict: .replace)
        }
    }

    public func delete(deckId: String, cardId: String, role: String) throws {
        try dbQueue.write { db in
            try db.execute(
                sql: "UPDATE deck_cards SET deleted = 1, dirty = 1 WHERE deck_id = ? AND card_id = ? AND role = ?",
                arguments: [deckId, cardId, role]
            )
        }
    }

    public func deleteDeck(id: String) throws {
        try dbQueue.write { db in
            try db.execute(
                sql: "UPDATE deck_cards SET deleted = 1, dirty = 1 WHERE deck_id = ?",
                arguments: [id]
            )
        }
    }
}
