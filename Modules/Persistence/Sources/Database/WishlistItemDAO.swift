import Foundation
import GRDB
import CoreModels

public final class WishlistItemDAO {
    private let dbQueue: DatabaseQueue

    public init?(manager: DatabaseManager? = DatabaseManager.shared) {
        guard let manager else { return nil }
        dbQueue = manager.dbQueue
    }

    public func items(for wishlistId: String) throws -> [WishlistItem] {
        try dbQueue.read { db in
            try WishlistItemRecord
                .filter(Column("wishlist_id") == wishlistId && Column("deleted") == false)
                .fetchAll(db)
                .map { record in
                    WishlistItem(
                        wishlistId: record.wishlistId,
                        cardId: record.cardId,
                        quantity: record.quantity,
                        updatedAt: Date(timeIntervalSince1970: record.updatedAt),
                        deleted: record.deleted
                    )
                }
        }
    }

    public func upsert(_ item: WishlistItem, dirty: Bool = true) throws {
        try dbQueue.write { db in
            let record = WishlistItemRecord(
                wishlistId: item.wishlistId,
                cardId: item.cardId,
                quantity: item.quantity,
                updatedAt: item.updatedAt.timeIntervalSince1970,
                dirty: dirty,
                deleted: item.deleted
            )
            try record.insert(db, onConflict: .replace)
        }
    }

    public func delete(wishlistId: String, cardId: String) throws {
        try dbQueue.write { db in
            try db.execute(
                sql: "UPDATE wishlist_items SET deleted = 1, dirty = 1 WHERE wishlist_id = ? AND card_id = ?",
                arguments: [wishlistId, cardId]
            )
        }
    }
}
