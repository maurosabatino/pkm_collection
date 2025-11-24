import Foundation
import CoreKit
import GRDB

struct DatabaseCardListRepository: CardListRepository {
    private let fallback: CardListRepository
    private let expansionRepository: ExpansionRepository?
    private let dbQueue: DatabaseQueue?

    init(
        fallback: CardListRepository = DefaultCardListRepository(),
        expansionRepository: ExpansionRepository = DefaultExpansionRepository(fileName: "set-it-IT"),
        databaseManager: DatabaseManager? = DatabaseManager.shared
    ) {
        self.fallback = fallback
        self.expansionRepository = expansionRepository
        self.dbQueue = databaseManager?.dbQueue
    }

    func fetchCardList(path: String) async throws -> [CardData] {
        guard let dbQueue else {
            return try await fallback.fetchCardList(path: path)
        }

        let existing: [CardData] = try await dbQueue.read { db in
            try CardRecord
                .filter(Column("expansion_id") == path)
                .fetchAll(db)
                .compactMap { $0.toModel() }
        }

        if !existing.isEmpty {
            return existing
        }

        let seeded = try await fallback.fetchCardList(path: path)
        let expansion = try? await expansionRepository?.fetchExpansions().first(where: { $0.id == path || $0.path == path })
        try await dbQueue.write { db in
            let expansionRecord = expansion.map { ExpansionRecord(expansion: $0, overrideId: path) } ?? ExpansionRecord(placeholderWithId: path)
            let idsToDelete = Set(
                [expansion?.id, path, path.components(separatedBy: ".").first]
                    .compactMap { $0 }
                    .filter { $0 != path }
            )
            if idsToDelete.isEmpty == false {
                try ExpansionRecord
                    .filter(idsToDelete.contains(ExpansionRecord.Columns.id))
                    .deleteAll(db)
            }
            try expansionRecord.insert(db, onConflict: .replace)

            for card in seeded {
                let record = CardRecord(card: card, expansionId: path)
                try record.insert(db, onConflict: .replace)
            }
        }
        return seeded
    }
}
