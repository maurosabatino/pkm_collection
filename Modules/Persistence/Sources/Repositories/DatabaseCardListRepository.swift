import Foundation
import CoreModels
import GRDB

public final class DatabaseCardListRepository: CardListRepository {
    private let fallback: CardListRepository
    private let expansionRepository: ExpansionRepository
    private let archiveQueue: DatabaseQueue?
    private var cache: [String: [CardData]] = [:]

    public init(
        fallback: CardListRepository = DefaultCardListRepository(),
        expansionRepository: ExpansionRepository = DatabaseExpansionRepository(),
        databaseManager: DatabaseManager? = DatabaseManager.shared
    ) {
        self.fallback = fallback
        self.expansionRepository = expansionRepository
        self.archiveQueue = databaseManager?.cardArchiveQueue ?? databaseManager?.dbQueue
    }

    public func fetchCardList(path: String, language: String) async throws -> [CardData] {
        let cacheKey = "\(language)|\(path)"

        if let cached = cache[cacheKey] {
            return cached
        }

        guard let archiveQueue = archiveQueue else {
            let fetched = try await fallback.fetchCardList(path: path, language: language)
            cache[cacheKey] = fetched
            return fetched
        }

        let existing: [CardData] = try await archiveQueue.read { db in
            try CardRecord
                .filter(Column("expansion_id") == path)
                .filter(CardRecord.Columns.lang == language)
                .fetchAll(db)
                .compactMap { $0.toModel() }
        }

        if !existing.isEmpty {
            return existing
        }

        let fetched = try await fallback.fetchCardList(path: path, language: language)
        let expansions = try? await expansionRepository.fetchExpansions(language: language)

        try await archiveQueue.write { db in
            try upsertExpansionIfNeeded(path: path, language: language, expansions: expansions ?? [], db: db)
            for card in fetched {
                try CardRecord(card: card, expansionId: path).insert(db, onConflict: .replace)
            }
        }
        cache[cacheKey] = fetched
        return fetched
    }

    private func upsertExpansionIfNeeded(path: String, language: String, expansions: [Expansion], db: Database) throws {
        if try ExpansionRecord
            .filter(ExpansionRecord.Columns.id == path)
            .filter(ExpansionRecord.Columns.lang == language)
            .fetchOne(db) != nil {
            return
        }

        // Remove conflicting base-id rows (e.g., "exp-base" vs "exp-base.it-IT") for same language.
        if let base = path.split(separator: ".").first, base != path {
            try ExpansionRecord
                .filter(ExpansionRecord.Columns.id == String(base))
                .filter(ExpansionRecord.Columns.lang == language)
                .deleteAll(db)
        }

        if let expansion = expansions.first(where: { $0.path == path || $0.id == path }) {
            let record = ExpansionRecord(expansion: expansion, lang: language, overrideId: path)
            try record.insert(db, onConflict: .replace)
            return
        }

        let placeholder = ExpansionRecord.placeholder(id: path, lang: language)
        try placeholder.insert(db, onConflict: .replace)
    }
}
