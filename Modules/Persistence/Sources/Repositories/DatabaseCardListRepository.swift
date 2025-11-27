import Foundation
import CoreModels
import GRDB

public final class DatabaseCardListRepository: CardListRepository {
    private let fallback: CardListRepository
    private let archiveQueue: DatabaseQueue?
    private var cache: [String: [CardData]] = [:]
    private let localizationHasImages: Bool

    public init(
        fallback: CardListRepository = DefaultCardListRepository(),
        databaseManager: DatabaseManager? = DatabaseManager.shared
    ) {
        self.fallback = fallback
        self.archiveQueue = databaseManager?.cardArchiveQueue ?? databaseManager?.dbQueue
        self.localizationHasImages = Self.hasLocalizationImages(queue: archiveQueue)
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
            let imageFront = localizationHasImages ? "COALESCE(cl.image_front, cv.image_front)" : "cv.image_front"
            let imageFoil = localizationHasImages ? "COALESCE(cl.image_foil, cv.image_foil)" : "cv.image_foil"
            let imageEtch = localizationHasImages ? "COALESCE(cl.image_etch, cv.image_etch)" : "cv.image_etch"
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
                   json_extract(cp.json_data, '$.card_type') AS cardType,
                   \(imageFront) AS imageUrl,
                   \(imageFoil) AS foilUrl,
                   \(imageEtch) AS etchUrl,
                   cp.tcgl_card_id AS dataHash,
                   cp.regulation_mark AS regulationMark
            FROM card_prints cp
            JOIN pref p ON p.print_id = cp.id
            JOIN card_variants cv ON cv.print_id = cp.id AND cv.variant = p.variant
            JOIN card_localizations cl ON cl.variant_id = cv.id
            WHERE cp.expansion_id = ?
              AND cl.lang = ?
              AND \(imageFront) IS NOT NULL
              AND \(imageFront) != ''
            ORDER BY cp.collector_number
            """
            let rows = try Row.fetchAll(db, sql: sql, arguments: [path, language])
            return rows.compactMap { row in
                do {
                    return try CardRecord(row: row).toModel()
                } catch {
                    print("[db] skipping card row decode error: \(error) for expansion \(path)")
                    return nil
                }
            }
        }

        cache[cacheKey] = existing
        return existing
    }

    private static func hasLocalizationImages(queue: DatabaseQueue?) -> Bool {
        guard let queue else { return false }
        return (try? queue.read { db in
            let rows = try Row.fetchAll(db, sql: "PRAGMA table_info(card_localizations)")
            let columns = rows.compactMap { $0["name"] as String? }
            return columns.contains("image_front")
        }) ?? false
    }
}
