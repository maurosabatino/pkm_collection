import Foundation
import GRDB
import CoreModels

public final class DeckDAO {
    private let dbQueue: DatabaseQueue

    public init?(manager: DatabaseManager? = DatabaseManager.shared) {
        guard let manager else { return nil }
        dbQueue = manager.dbQueue
    }

    public func fetchAll() throws -> [Deck] {
        try dbQueue.read { db in
            try DeckRecord
                .filter(Column("deleted") == false)
                .fetchAll(db)
                .map { record in
                    Deck(
                        id: record.id,
                        name: record.name,
                        format: record.format,
                        notes: record.notes,
                        updatedAt: Date(timeIntervalSince1970: record.updatedAt),
                        deleted: record.deleted
                    )
                }
        }
    }

    public func save(_ deck: Deck, dirty: Bool = true) throws {
        try dbQueue.write { db in
            let record = DeckRecord(
                id: deck.id,
                name: deck.name,
                format: deck.format,
                notes: deck.notes,
                updatedAt: deck.updatedAt.timeIntervalSince1970,
                dirty: dirty,
                deleted: deck.deleted
            )
            try record.insert(db, onConflict: .replace)
        }
    }

    public func delete(id: String) throws {
        try dbQueue.write { db in
            try db.execute(sql: "UPDATE decks SET deleted = 1, dirty = 1 WHERE id = ?", arguments: [id])
        }
    }
}
