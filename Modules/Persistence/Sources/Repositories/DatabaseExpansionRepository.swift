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
            try ExpansionRecord
                .filter(ExpansionRecord.Columns.lang == language)
                .fetchAll(db)
                .compactMap { $0.toModel() }
        }

        if !existing.isEmpty {
            return existing.sorted { $0.releaseDate > $1.releaseDate }
        }

        let fetched = try await fallback.fetchExpansions(language: language)
        try await archiveQueue.write { db in
            for expansion in fetched {
                let record = ExpansionRecord(expansion: expansion, lang: language, overrideId: expansion.path)
                try record.insert(db, onConflict: .replace)
            }
        }
        return fetched.sorted { $0.releaseDate > $1.releaseDate }
    }
}
