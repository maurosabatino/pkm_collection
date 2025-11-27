import Foundation
import GRDB
import CoreModels

public final class WishlistDAO {
    private let dbQueue: DatabaseQueue

    public init?(manager: DatabaseManager? = DatabaseManager.shared) {
        guard let manager else { return nil }
        dbQueue = manager.dbQueue
    }

    public func fetchAll() throws -> [Wishlist] {
        try dbQueue.read { db in
            try WishlistRecord
                .filter(Column("deleted") == false)
                .fetchAll(db)
                .map { record in
                    Wishlist(
                        id: record.id,
                        name: record.name,
                        notes: record.notes,
                        updatedAt: Date(timeIntervalSince1970: record.updatedAt),
                        deleted: record.deleted
                    )
                }
        }
    }

    public func save(_ wishlist: Wishlist, dirty: Bool = true) throws {
        try dbQueue.write { db in
            let record = WishlistRecord(
                id: wishlist.id,
                name: wishlist.name,
                notes: wishlist.notes,
                updatedAt: wishlist.updatedAt.timeIntervalSince1970,
                dirty: dirty,
                deleted: wishlist.deleted
            )
            try record.insert(db, onConflict: .replace)
        }
    }

    public func delete(id: String) throws {
        try dbQueue.write { db in
            try db.execute(sql: "UPDATE wishlists SET deleted = 1, dirty = 1 WHERE id = ?", arguments: [id])
        }
    }
}
