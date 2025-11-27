import Foundation
import GRDB

public enum DatabaseError: Error {
    case initializationFailed
}

/// Gestisce la connessione GRDB e le migrazioni.
public final class DatabaseManager {
    public static let shared: DatabaseManager? = DatabaseManager.makeShared()
    /// Database utente in lettura/scrittura (mazzi, preferiti, ownership, ecc).
    public let userDbQueue: DatabaseQueue
    /// Archivio carte in sola lettura (seed da bundle o da copia locale).
    public let cardArchiveQueue: DatabaseQueue?
    /// Compat per codice esistente: punta al database utente.
    public var dbQueue: DatabaseQueue { userDbQueue }

    public init(inMemory: Bool = false) throws {
        userDbQueue = try DatabaseManager.makeUserDatabase(inMemory: inMemory)
        cardArchiveQueue = try DatabaseManager.makeCardArchiveDatabase(inMemory: inMemory)
        try DatabaseManager.migrate(userDbQueue)
    }

    private static func makeShared() -> DatabaseManager? {
        if let manager = try? DatabaseManager() {
            return manager
        }
        // Fallback to an in-memory DB rather than crashing if filesystem init fails.
        return try? DatabaseManager(inMemory: true)
    }

    private static func makeUserDatabase(inMemory: Bool) throws -> DatabaseQueue {
        if inMemory {
            return try DatabaseQueue()
        }

        let fileManager = FileManager.default
        let baseURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory
        let directoryURL = baseURL.appendingPathComponent("Database", isDirectory: true)
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
        let dbURL = directoryURL.appendingPathComponent("pkm_collection.sqlite")
        return try DatabaseQueue(path: dbURL.path)
    }

    private static func makeCardArchiveDatabase(inMemory: Bool) throws -> DatabaseQueue? {
        guard inMemory == false else { return nil }

        let fileManager = FileManager.default
        let baseURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory
        let directoryURL = baseURL.appendingPathComponent("DatabaseArchive", isDirectory: true)
        if !fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }

        // Always refresh from bundled archive to avoid WAL dependencies and stale data.
        let candidates = ["cards.db", "cards.sqlite"]
        guard let bundled = candidates.compactMap({ name -> URL? in
            let ext = URL(fileURLWithPath: name).pathExtension
            let base = URL(fileURLWithPath: name).deletingPathExtension().lastPathComponent
            return ResourceLocator.url(forResource: base, withExtension: ext, subdirectory: "db")
        }).first else {
            return nil
        }

        let archiveURL = directoryURL.appendingPathComponent(bundled.lastPathComponent)
        // Clean old copies and WAL/SHM if present.
        try? fileManager.removeItem(at: archiveURL)
        try? fileManager.removeItem(at: archiveURL.appendingPathExtension("wal"))
        try? fileManager.removeItem(at: archiveURL.appendingPathExtension("shm"))
        try fileManager.copyItem(at: bundled, to: archiveURL)

        var config = Configuration()
        // Open read-write to allow forcing DELETE journal mode (no WAL file required).
        config.readonly = false
        let queue = try DatabaseQueue(path: archiveURL.path, configuration: config)
        try? queue.write { db in
            try db.execute(sql: "PRAGMA journal_mode=DELETE;")
        }
        return queue
    }

    private static func migrate(_ dbQueue: DatabaseQueue) throws {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("v1_core") { db in
            // Master data (placeholders per design)
            try db.create(table: "expansions", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("lang", .text)
                t.column("name", .text).notNull()
                t.column("series", .text)
                t.column("abbr", .text)
                t.column("release_date", .double)
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

        migrator.registerMigration("v3_multilang_master_data") { db in
            try db.create(table: "expansions_new") { t in
                t.column("id", .text).notNull()
                t.column("lang", .text).notNull()
                t.column("name", .text).notNull()
                t.column("series", .text)
                t.column("abbr", .text)
                t.column("release_date", .double)
                t.column("logo_url", .text)
                t.column("symbol_url", .text)
                t.column("num_master", .integer)
                t.column("num_regular", .integer)
                t.column("hash", .text)
                t.column("updated_at", .double)
                t.column("json_data", .blob)
                t.primaryKey(["id", "lang"])
            }

            try db.create(table: "cards_new") { t in
                t.column("id", .text).notNull()
                t.column("lang", .text).notNull()
                t.column("expansion_id", .text).notNull()
                t.column("name", .text).notNull()
                t.column("collector_number", .text)
                t.column("rarity", .text)
                t.column("types", .text)
                t.column("stage", .text)
                t.column("hp", .integer)
                t.column("image_url", .text)
                t.column("foil_url", .text)
                t.column("etch_url", .text)
                t.column("data_hash", .text)
                t.column("updated_at", .double)
                t.column("json_data", .blob)
                t.primaryKey(["id", "lang"])
                t.foreignKey(["expansion_id", "lang"], references: "expansions_new", onDelete: .cascade)
            }

            if try db.tableExists("expansions") {
                try db.execute(
                    sql: """
                    INSERT INTO expansions_new(id, lang, name, series, abbr, release_date, logo_url, symbol_url, num_master, num_regular, hash, updated_at, json_data)
                    SELECT id, COALESCE(lang, 'it-IT'), name, series, abbr, release_date, logo_url, symbol_url, num_master, num_regular, hash, updated_at, json_data
                    FROM expansions
                    """
                )
            }

            if try db.tableExists("cards") {
                try db.execute(
                    sql: """
                    INSERT INTO cards_new(
                        id, lang, expansion_id, name, collector_number, rarity, types, stage, hp, image_url, foil_url, etch_url, data_hash, updated_at, json_data
                    )
                    SELECT id, COALESCE(lang, 'it-IT'), expansion_id, name, collector_number, rarity, types, stage, hp, image_url, foil_url, etch_url, data_hash, updated_at, json_data
                    FROM cards
                    """
                )
            }

            if try db.tableExists("cards") {
                try db.drop(table: "cards")
            }
            if try db.tableExists("expansions") {
                try db.drop(table: "expansions")
            }

            try db.rename(table: "expansions_new", to: "expansions")
            try db.rename(table: "cards_new", to: "cards")

            try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_cards_expansion ON cards(expansion_id)")
            try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_cards_lang ON cards(lang)")
            try db.execute(sql: "CREATE INDEX IF NOT EXISTS idx_cards_collector ON cards(collector_number)")
        }

        try migrator.migrate(dbQueue)
    }
}
