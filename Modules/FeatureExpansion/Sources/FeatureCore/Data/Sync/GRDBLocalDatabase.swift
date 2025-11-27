import Foundation
import Persistence

public final class GRDBLocalDatabase: LocalDatabase {
    private let dbQueue: DatabaseQueue
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init?(manager: DatabaseManager? = DatabaseManager.shared) {
        guard let manager else { return nil }
        self.dbQueue = manager.dbQueue
    }

    public func saveMutations(_ mutations: [SyncMutation<Data>]) throws {
        try dbQueue.write { db in
            for mutation in mutations {
                switch mutation.table {
                case "ownership":
                    let record = try decoder.decode(OwnedCardRecord.self, from: mutation.record)
                    if mutation.operation == .delete || record.deleted {
                        try OwnedCardRecord.deleteOne(db, key: record.cardId)
                    } else {
                        try record.insert(db, onConflict: .replace)
                    }
                case "wishlists":
                    let record = try decoder.decode(WishlistRecord.self, from: mutation.record)
                    if mutation.operation == .delete || record.deleted {
                        try WishlistRecord.deleteOne(db, key: record.id)
                    } else {
                        try record.insert(db, onConflict: .replace)
                    }
                case "wishlist_items":
                    let record = try decoder.decode(WishlistItemRecord.self, from: mutation.record)
                    if mutation.operation == .delete || record.deleted {
                        try WishlistItemRecord.deleteOne(db, key: ["wishlist_id": record.wishlistId, "card_id": record.cardId])
                    } else {
                        try record.insert(db, onConflict: .replace)
                    }
                case "decks":
                    let record = try decoder.decode(DeckRecord.self, from: mutation.record)
                    if mutation.operation == .delete || record.deleted {
                        try DeckRecord.deleteOne(db, key: record.id)
                    } else {
                        try record.insert(db, onConflict: .replace)
                    }
                case "deck_cards":
                    let record = try decoder.decode(DeckCardRecord.self, from: mutation.record)
                    if mutation.operation == .delete || record.deleted {
                        try DeckCardRecord.deleteOne(db, key: ["deck_id": record.deckId, "card_id": record.cardId, "role": record.role])
                    } else {
                        try record.insert(db, onConflict: .replace)
                    }
                default:
                    break
                }
            }
        }
    }

    public func pendingMutations() throws -> [SyncMutation<Data>] {
        try dbQueue.read { db in
            var mutations: [SyncMutation<Data>] = []

            let ownedRecords = try OwnedCardRecord.filter(Column("dirty") == true).fetchAll(db)
            mutations.append(contentsOf: ownedRecords.map { record in
                let data = (try? encoder.encode(record)) ?? Data()
                let op: SyncOperation = record.deleted ? .delete : .update
                return SyncMutation(table: "ownership", operation: op, record: data, updatedAt: Date(timeIntervalSince1970: record.lastUpdated))
            })

            let wishlistRecords = try WishlistRecord.filter(Column("dirty") == true).fetchAll(db)
            mutations.append(contentsOf: wishlistRecords.map { record in
                let data = (try? encoder.encode(record)) ?? Data()
                let op: SyncOperation = record.deleted ? .delete : .update
                return SyncMutation(table: "wishlists", operation: op, record: data, updatedAt: Date(timeIntervalSince1970: record.updatedAt))
            })

            let wishlistItemRecords = try WishlistItemRecord.filter(Column("dirty") == true).fetchAll(db)
            mutations.append(contentsOf: wishlistItemRecords.map { record in
                let data = (try? encoder.encode(record)) ?? Data()
                let op: SyncOperation = record.deleted ? .delete : .update
                return SyncMutation(table: "wishlist_items", operation: op, record: data, updatedAt: Date(timeIntervalSince1970: record.updatedAt))
            })

            let deckRecords = try DeckRecord.filter(Column("dirty") == true).fetchAll(db)
            mutations.append(contentsOf: deckRecords.map { record in
                let data = (try? encoder.encode(record)) ?? Data()
                let op: SyncOperation = record.deleted ? .delete : .update
                return SyncMutation(table: "decks", operation: op, record: data, updatedAt: Date(timeIntervalSince1970: record.updatedAt))
            })

            let deckCardRecords = try DeckCardRecord.filter(Column("dirty") == true).fetchAll(db)
            mutations.append(contentsOf: deckCardRecords.map { record in
                let data = (try? encoder.encode(record)) ?? Data()
                let op: SyncOperation = record.deleted ? .delete : .update
                return SyncMutation(table: "deck_cards", operation: op, record: data, updatedAt: Date(timeIntervalSince1970: record.updatedAt))
            })

            return mutations
        }
    }

    public func markMutationsAsSynced(_ mutations: [SyncMutation<Data>]) throws {
        try dbQueue.write { db in
            for mutation in mutations {
                switch mutation.table {
                case "ownership":
                    if var dbRecord = try? decoder.decode(OwnedCardRecord.self, from: mutation.record) {
                        dbRecord.dirty = false
                        dbRecord.deleted = false
                        try dbRecord.insert(db, onConflict: .replace)
                    }
                case "wishlists":
                    if var dbRecord = try? decoder.decode(WishlistRecord.self, from: mutation.record) {
                        dbRecord.dirty = false
                        dbRecord.deleted = false
                        try dbRecord.insert(db, onConflict: .replace)
                    }
                case "wishlist_items":
                    if var dbRecord = try? decoder.decode(WishlistItemRecord.self, from: mutation.record) {
                        dbRecord.dirty = false
                        dbRecord.deleted = false
                        try dbRecord.insert(db, onConflict: .replace)
                    }
                case "decks":
                    if var dbRecord = try? decoder.decode(DeckRecord.self, from: mutation.record) {
                        dbRecord.dirty = false
                        dbRecord.deleted = false
                        try dbRecord.insert(db, onConflict: .replace)
                    }
                case "deck_cards":
                    if var dbRecord = try? decoder.decode(DeckCardRecord.self, from: mutation.record) {
                        dbRecord.dirty = false
                        dbRecord.deleted = false
                        try dbRecord.insert(db, onConflict: .replace)
                    }
                default:
                    break
                }
            }
        }
    }

    public func loadSyncState(for resource: String) throws -> SyncState {
        try dbQueue.read { db in
            if let row = try Row.fetchOne(db, sql: "SELECT * FROM sync_state WHERE resource = ?", arguments: [resource]) {
                let cursor: String? = row["last_cursor"]
                let pulledAt: Double? = row["last_pulled_at"]
                return SyncState(resource: resource, lastCursor: cursor, lastPulledAt: pulledAt.map(Date.init(timeIntervalSince1970:)))
            }
            return SyncState(resource: resource)
        }
    }

    public func saveSyncState(_ state: SyncState) throws {
        try dbQueue.write { db in
            try db.execute(
                sql: """
                INSERT OR REPLACE INTO sync_state(resource, last_cursor, last_pulled_at)
                VALUES (?, ?, ?)
                """,
                arguments: [state.resource, state.lastCursor, state.lastPulledAt?.timeIntervalSince1970]
            )
        }
    }
}
