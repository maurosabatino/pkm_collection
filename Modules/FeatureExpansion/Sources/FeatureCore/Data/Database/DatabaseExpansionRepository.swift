import Foundation
import CoreKit
import GRDB

struct DatabaseExpansionRepository: ExpansionRepository {
    private let fallback: ExpansionRepository
    private let dbQueue: DatabaseQueue?

    init(
        fallback: ExpansionRepository = DefaultExpansionRepository(fileName: "set-it-IT"),
        databaseManager: DatabaseManager? = DatabaseManager.shared
    ) {
        self.fallback = fallback
        self.dbQueue = databaseManager?.dbQueue
    }

    func fetchExpansions() async throws -> [Expansion] {
        guard let dbQueue else {
            return try await fallback.fetchExpansions()
        }

        let existing: [Expansion] = try await dbQueue.read { db in
            try ExpansionRecord.fetchAll(db).compactMap { $0.toModel() }
        }

        if !existing.isEmpty {
            return existing.sorted { $0.releaseDate > $1.releaseDate }
        }

        let seeded = try await fallback.fetchExpansions()
        try await dbQueue.write { db in
            for expansion in seeded {
                let record = ExpansionRecord(expansion: expansion)
                try record.insert(db)
            }
        }
        return seeded.sorted { $0.releaseDate > $1.releaseDate }
    }
}
