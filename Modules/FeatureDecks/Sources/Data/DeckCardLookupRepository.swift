import Foundation
import CoreModels
import Persistence
import GRDB
import CoreKit

public protocol DeckCardLookupRepository {
    func fetchCards(ids: [String]) async throws -> [String: CardData]
}

public struct DatabaseDeckCardLookupRepository: DeckCardLookupRepository {
    private let dbQueue: DatabaseQueue?
    private let languageProvider: () -> String

    public init(
        databaseManager: DatabaseManager? = DatabaseManager.shared,
        languageSettings: LanguageSettings = .shared
    ) {
        self.dbQueue = databaseManager?.cardArchiveQueue ?? databaseManager?.dbQueue
        self.languageProvider = { languageSettings.language.rawValue }
    }

    public func fetchCards(ids: [String]) async throws -> [String: CardData] {
        guard let dbQueue, ids.isEmpty == false else { return [:] }
        let lang = languageProvider()
        return try await dbQueue.read { db in
            let placeholders = ids.map { _ in "?" }.joined(separator: ",")
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
            WHERE cl.lang = ?
              AND cp.id IN (\(placeholders))
            """
            let args: [DatabaseValueConvertible] = [lang] + ids
            let records = try CardRecord.fetchAll(db, sql: sql, arguments: StatementArguments(args))
            var map: [String: CardData] = [:]
            for record in records {
                let card = record.toModel()
                map[record.id] = card
            }
            return map
        }
    }
}
