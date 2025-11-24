import Foundation
import GRDB
import CoreKit

struct ExpansionRecord: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var name: String
    var series: String?
    var abbr: String?
    var releaseDate: TimeInterval?
    var logoUrl: String?
    var symbolUrl: String?
    var numMaster: Int?
    var numRegular: Int?
    var hash: String?
    var updatedAt: TimeInterval?
    var jsonData: Data?

    static let databaseTableName = "expansions"

    enum Columns: String, CodingKey, ColumnExpression {
        case id
        case name
        case series
        case abbr
        case releaseDate = "release_date"
        case logoUrl = "logo_url"
        case symbolUrl = "symbol_url"
        case numMaster = "num_master"
        case numRegular = "num_regular"
        case hash
        case updatedAt = "updated_at"
        case jsonData = "json_data"
    }

    typealias CodingKeys = Columns

    init(placeholderWithId id: String, name: String? = nil, releaseDate: Date = Date()) {
        self.id = id
        self.name = name ?? id
        self.series = nil
        self.abbr = nil
        self.releaseDate = releaseDate.timeIntervalSince1970
        self.logoUrl = nil
        self.symbolUrl = nil
        self.numMaster = nil
        self.numRegular = nil
        self.hash = nil
        self.updatedAt = releaseDate.timeIntervalSince1970
        self.jsonData = nil
    }

    init(expansion: Expansion, overrideId: String? = nil) {
        id = overrideId ?? expansion.id
        name = expansion.name
        series = expansion.series
        abbr = expansion.abbr
        releaseDate = expansion.releaseDate.timeIntervalSince1970
        logoUrl = expansion.logoUrl
        symbolUrl = expansion.symbolUrl
        numMaster = expansion.num.master
        numRegular = expansion.num.regular
        hash = expansion.hash
        updatedAt = Date().timeIntervalSince1970
        jsonData = try? JSONEncoder().encode(expansion)
    }

    func toModel() -> Expansion? {
        if let jsonData, let decoded = try? JSONDecoder().decode(Expansion.self, from: jsonData) {
            return decoded
        }
        guard let releaseDate else { return nil }
        return Expansion(
            id: id,
            series: series ?? "",
            path: id,
            name: name,
            num: NumInfo(master: numMaster ?? 0, regular: numRegular ?? 0),
            hash: hash ?? "",
            abbr: abbr ?? "",
            releaseDate: Date(timeIntervalSince1970: releaseDate),
            symbolUrl: symbolUrl ?? "",
            logoUrl: logoUrl ?? ""
        )
    }
}
