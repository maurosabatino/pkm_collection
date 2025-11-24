import Foundation
import GRDB

public enum DatabaseError: Error {
    case initializationFailed
}

/// Gestisce la connessione GRDB e le migrazioni.
public final class DatabaseManager {
    public static let shared = try? DatabaseManager()
    public let dbQueue: DatabaseQueue

    public init(inMemory: Bool = false) throws {
        if inMemory {
            dbQueue = try DatabaseQueue()
        } else {
            let fileManager = FileManager.default
            let baseURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory
            let directoryURL = baseURL.appendingPathComponent("Database", isDirectory: true)
            if !fileManager.fileExists(atPath: directoryURL.path) {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            }
            let dbURL = directoryURL.appendingPathComponent("pkm_collection.sqlite")
            dbQueue = try DatabaseQueue(path: dbURL.path)
        }
        try migrate()
    }

    private func migrate() throws {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("v1_core") { db in
            // Master data (placeholders per design)
            try db.create(table: "expansions", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("series", .text)
                t.column("abbr", .text)
                t.column("release_date", .text)
                t.column("logo_url", .text)
                t.column("symbol_url", .text)
                t.column("num_master", .integer)
                t.column("num_regular", .integer)
                t.column("hash", .text)
                t.column("updated_at", .double)
                t.column("json_data", .blob)
            }

            try db.create(table: "cards", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("expansion_id", .text).notNull().indexed()
                t.column("name", .text).notNull()
                t.column("collector_number", .text)
                t.column("rarity", .text)
                t.column("types", .text)
                t.column("stage", .text)
                t.column("hp", .integer)
                t.column("lang", .text)
                t.column("image_url", .text)
                t.column("foil_url", .text)
                t.column("etch_url", .text)
                t.column("data_hash", .text)
                t.column("updated_at", .double)
                t.column("json_data", .blob)
                t.foreignKey(["expansion_id"], references: "expansions", onDelete: .cascade)
            }

            // User data
            try db.create(table: "ownership", ifNotExists: true) { t in
                t.column("card_id", .text).primaryKey()
                t.column("quantity", .integer).notNull().defaults(to: 0)
                t.column("notes", .text)
                t.column("last_updated", .double).notNull().defaults(to: 0)
                t.column("is_wishlist", .boolean).notNull().defaults(to: false)
                t.column("dirty", .boolean).notNull().defaults(to: false)
                t.column("deleted", .boolean).notNull().defaults(to: false)
            }

            try db.create(table: "wishlists", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("notes", .text)
                t.column("updated_at", .double).notNull().defaults(to: 0)
                t.column("dirty", .boolean).notNull().defaults(to: false)
                t.column("deleted", .boolean).notNull().defaults(to: false)
            }

            try db.create(table: "wishlist_items", ifNotExists: true) { t in
                t.column("wishlist_id", .text).notNull()
                t.column("card_id", .text).notNull()
                t.column("quantity", .integer).notNull().defaults(to: 0)
                t.column("updated_at", .double).notNull().defaults(to: 0)
                t.column("dirty", .boolean).notNull().defaults(to: false)
                t.column("deleted", .boolean).notNull().defaults(to: false)
                t.primaryKey(["wishlist_id", "card_id"])
            }

            try db.create(table: "decks", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("format", .text)
                t.column("notes", .text)
                t.column("updated_at", .double).notNull().defaults(to: 0)
                t.column("dirty", .boolean).notNull().defaults(to: false)
                t.column("deleted", .boolean).notNull().defaults(to: false)
            }

            try db.create(table: "deck_cards", ifNotExists: true) { t in
                t.column("deck_id", .text).notNull()
                t.column("card_id", .text).notNull()
                t.column("quantity", .integer).notNull().defaults(to: 0)
                t.column("role", .text).notNull().defaults(to: "main")
                t.column("updated_at", .double).notNull().defaults(to: 0)
                t.column("dirty", .boolean).notNull().defaults(to: false)
                t.column("deleted", .boolean).notNull().defaults(to: false)
                t.primaryKey(["deck_id", "card_id", "role"])
            }

            try db.create(table: "sync_state", ifNotExists: true) { t in
                t.column("resource", .text).primaryKey()
                t.column("last_cursor", .text)
                t.column("last_pulled_at", .double)
            }
        }

        migrator.registerMigration("v2_add_json_columns") { db in
            let expansionColumns = try db.columns(in: "expansions").map(\.name)
            if expansionColumns.contains("json_data") == false {
                try db.alter(table: "expansions") { t in
                    t.add(column: "json_data", .blob)
                }
            }

            let cardColumns = try db.columns(in: "cards").map(\.name)
            if cardColumns.contains("json_data") == false {
                try db.alter(table: "cards") { t in
                    t.add(column: "json_data", .blob)
                }
            }
        }

        try migrator.migrate(dbQueue)
    }
}
