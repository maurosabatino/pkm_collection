import Foundation
import GRDB
import CoreModels

public final class GRDBOwnedCardsPersistence: OwnedCardsPersistence {
    private let dbQueue: DatabaseQueue

    public init(databaseManager: DatabaseManager? = DatabaseManager.shared) {
        if let manager = databaseManager {
            self.dbQueue = manager.userDbQueue
        } else if let inMemory = try? DatabaseQueue() {
            self.dbQueue = inMemory
        } else {
            fatalError("DatabaseManager not initialized")
        }
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
