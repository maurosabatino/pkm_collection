import Foundation
import CoreKit
import GRDB

protocol DeckCardLookupRepository {
    func fetchCards(ids: [String]) async throws -> [String: CardData]
}

struct DatabaseDeckCardLookupRepository: DeckCardLookupRepository {
    private let dbQueue: DatabaseQueue?

    init(databaseManager: DatabaseManager? = DatabaseManager.shared) {
        self.dbQueue = databaseManager?.dbQueue
    }

    func fetchCards(ids: [String]) async throws -> [String: CardData] {
        guard let dbQueue, ids.isEmpty == false else { return [:] }
        return try await dbQueue.read { db in
            let records = try CardRecord
                .filter(ids.contains(CardRecord.Columns.id))
                .fetchAll(db)
            var map: [String: CardData] = [:]
            for record in records {
                if let card = record.toModel() {
                    map[record.id] = card
                }
            }
            return map
        }
    }
}
