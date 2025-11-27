import Foundation
import CoreModels
import Persistence
import CoreKit

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
        let expansions = try ExpansionRecord
            .filter(ExpansionRecord.Columns.lang == lang)
            .filter(sql: "LOWER(abbr) = ?", arguments: [setCode])
            .fetchAll(db)

        guard let expansionId = expansions.first?.id else {
            return ResolvedImportCard(parsed: item, resolvedId: nil, card: nil)
        }

        let number = item.number
        let padded = number.count < 3 ? String(format: "%03d", Int(number) ?? 0) : number
        let likePattern = "%\(number)%"

        if let record = try CardRecord
            .filter(CardRecord.Columns.expansionId == expansionId)
            .filter(CardRecord.Columns.lang == lang)
            .filter(
                CardRecord.Columns.collectorNumber == number ||
                CardRecord.Columns.collectorNumber == padded ||
                CardRecord.Columns.collectorNumber.like(likePattern)
            )
            .limit(1)
            .fetchOne(db),
           let model = record.toModel() {
            return ResolvedImportCard(parsed: item, resolvedId: record.id, card: model)
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
