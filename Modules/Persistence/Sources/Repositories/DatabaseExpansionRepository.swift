import Foundation
import CoreModels
import GRDB

public struct DatabaseExpansionRepository: ExpansionRepository {
    private let fallback: ExpansionRepository
    private let archiveQueue: DatabaseQueue?

    public init(
        fallback: ExpansionRepository = DefaultExpansionRepository(),
        databaseManager: DatabaseManager? = DatabaseManager.shared
    ) {
        self.fallback = fallback
        self.archiveQueue = databaseManager?.cardArchiveQueue ?? databaseManager?.dbQueue
    }

    public func fetchExpansions(language: String) async throws -> [Expansion] {
        guard let archiveQueue else {
            return try await fallback.fetchExpansions(language: language)
        }

        let existing: [Expansion] = try await archiveQueue.read { db in
            let sql = """
            SELECT e.id,
                   el.lang,
                   el.name,
                   e.series_id AS seriesId,
                   e.abbr,
                   e.release_date AS releaseDate,
                   e.logo_url AS logoUrl,
                   e.symbol_url AS symbolUrl,
                   e.num_master AS numMaster,
                   e.num_regular AS numRegular,
                   e.hash
            FROM expansions e
            JOIN expansion_localizations el ON el.expansion_id = e.id
            WHERE el.lang = ?
            """
            return try ExpansionRecord.fetchAll(db, sql: sql, arguments: [language]).map { $0.toModel() }
        }

        if !existing.isEmpty {
            return existing.sorted { $0.releaseDate > $1.releaseDate }
        }

        // Fallback to remote if db missing (unlikely with bundled archive)
        let fetched = try await fallback.fetchExpansions(language: language)
        return fetched.sorted { $0.releaseDate > $1.releaseDate }
    }
}
