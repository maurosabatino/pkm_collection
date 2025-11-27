import Foundation
import CoreModels
import Persistence
import CoreKit
import GRDB

struct DeckCardResolver {
    private let dbQueue: DatabaseQueue?
    private let languageProvider: () -> String

    init(
        databaseManager: DatabaseManager? = DatabaseManager.shared,
        languageSettings: LanguageSettings = .shared
    ) {
        self.dbQueue = databaseManager?.cardArchiveQueue ?? databaseManager?.dbQueue
        self.languageProvider = { languageSettings.language.rawValue }
    }

    func resolve(_ parsed: [ParsedDeckCard]) async -> [ResolvedImportCard] {
        guard let dbQueue, parsed.isEmpty == false else { return parsed.map { ResolvedImportCard(parsed: $0, resolvedId: nil, card: nil) } }

        return await (try? dbQueue.read { db -> [ResolvedImportCard] in
            var results: [ResolvedImportCard] = []
            for item in parsed {
                let match = (try? resolveOne(item, db: db)) ?? ResolvedImportCard(parsed: item, resolvedId: nil, card: nil)
                results.append(match)
            }
            return results
        }) ?? parsed.map { ResolvedImportCard(parsed: $0, resolvedId: nil, card: nil) }
    }

    private func resolveOne(_ item: ParsedDeckCard, db: Database) throws -> ResolvedImportCard {
        let lang = languageProvider()
        let setCode = item.setCode.lowercased()
        let expansions = try ExpansionRecord.fetchAll(
            db,
            sql: """
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
            WHERE el.lang = ? AND LOWER(e.abbr) = ?
            """,
            arguments: [lang, setCode]
        )

        guard let expansionId = expansions.first?.id else {
            return ResolvedImportCard(parsed: item, resolvedId: nil, card: nil)
        }

        let number = item.number
        let padded = number.count < 3 ? String(format: "%03d", Int(number) ?? 0) : number
        let likePattern = "%\(number)%"

        let sql = """
        WITH pref AS (
            SELECT print_id, MIN(variant) AS variant
            FROM card_variants
            GROUP BY print_id
        )
        SELECT cp.id,
               cl.lang,
               cp.expansion_id AS expansionId,
               cl.name,
               cp.collector_number AS collectorNumber,
               cp.rarity,
               cp.types,
               cp.stage,
               cp.hp,
               cv.image_front AS imageUrl,
               cv.image_foil AS foilUrl,
               cv.image_etch AS etchUrl,
               cp.tcgl_card_id AS dataHash,
               cp.regulation_mark AS regulationMark
        FROM card_prints cp
        JOIN pref p ON p.print_id = cp.id
        JOIN card_variants cv ON cv.print_id = cp.id AND cv.variant = p.variant
        JOIN card_localizations cl ON cl.variant_id = cv.id
        WHERE cp.expansion_id = ?
          AND cl.lang = ?
          AND (cp.collector_number = ? OR cp.collector_number = ? OR cp.collector_number LIKE ?)
        LIMIT 1
        """

        if let record = try CardRecord.fetchOne(db, sql: sql, arguments: [expansionId, lang, number, padded, likePattern]) {
            return ResolvedImportCard(parsed: item, resolvedId: record.id, card: record.toModel())
        }

        return ResolvedImportCard(parsed: item, resolvedId: nil, card: nil)
    }
}

struct ResolvedImportCard: Identifiable, Equatable {
    let parsed: ParsedDeckCard
    let resolvedId: String?
    let card: CardData?

    var id: String { resolvedId ?? parsed.cardId }

    static func == (lhs: ResolvedImportCard, rhs: ResolvedImportCard) -> Bool {
        lhs.id == rhs.id && lhs.parsed == rhs.parsed && lhs.resolvedId == rhs.resolvedId
    }
}
