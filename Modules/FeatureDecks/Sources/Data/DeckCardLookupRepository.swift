import Foundation
import CoreModels
import Persistence
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
            let records = try CardRecord
                .filter(ids.contains(CardRecord.Columns.id))
                .filter(CardRecord.Columns.lang == lang)
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
