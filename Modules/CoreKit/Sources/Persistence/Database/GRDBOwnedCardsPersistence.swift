import Foundation
import GRDB

public final class GRDBOwnedCardsPersistence: OwnedCardsPersistence {
    private let dbQueue: DatabaseQueue

    public init(databaseManager: DatabaseManager? = DatabaseManager.shared) {
        guard let manager = databaseManager else {
            fatalError("DatabaseManager not initialized")
        }
        self.dbQueue = manager.dbQueue
    }

    public func load() throws -> [OwnedCard] {
        try dbQueue.read { db in
            try OwnedCardRecord.fetchAll(db).map { $0.toModel() }
        }
    }

    public func save(_ cards: [OwnedCard]) throws {
        try dbQueue.write { db in
            try OwnedCardRecord.deleteAll(db)
            for card in cards {
                let record = OwnedCardRecord(from: card, dirty: true, deleted: false)
                try record.insert(db)
            }
        }
    }
}
