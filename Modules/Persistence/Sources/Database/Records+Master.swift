import Foundation
import GRDB
import CoreModels

public struct ExpansionRecord: Codable, FetchableRecord, PersistableRecord {
    public var id: String
    public var lang: String
    public var name: String
    public var series: String?
    public var abbr: String?
    public var releaseDate: TimeInterval?
    public var logoUrl: String?
    public var symbolUrl: String?
    public var numMaster: Int?
    public var numRegular: Int?
    public var hash: String?
    public var updatedAt: TimeInterval?
    public var jsonData: Data?

    public static let databaseTableName = "expansions"

    public enum Columns: String, CodingKey, ColumnExpression {
        case id, lang, name, series, abbr, releaseDate = "release_date", logoUrl = "logo_url", symbolUrl = "symbol_url", numMaster = "num_master", numRegular = "num_regular", hash, updatedAt = "updated_at", jsonData = "json_data"
    }

    public typealias CodingKeys = Columns

    public init(
        id: String,
        lang: String,
        name: String,
        series: String?,
        abbr: String?,
        releaseDate: TimeInterval?,
        logoUrl: String?,
        symbolUrl: String?,
        numMaster: Int?,
        numRegular: Int?,
        hash: String?,
        updatedAt: TimeInterval?,
        jsonData: Data?
    ) {
        self.id = id
        self.lang = lang
        self.name = name
        self.series = series
        self.abbr = abbr
        self.releaseDate = releaseDate
        self.logoUrl = logoUrl
        self.symbolUrl = symbolUrl
        self.numMaster = numMaster
        self.numRegular = numRegular
        self.hash = hash
        self.updatedAt = updatedAt
        self.jsonData = jsonData
    }

    init(expansion: Expansion, lang: String, overrideId: String? = nil) {
        id = overrideId ?? expansion.id
        self.lang = lang
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

    public func toModel() -> Expansion? {
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

public extension ExpansionRecord {
    static func placeholder(id: String, lang: String) -> ExpansionRecord {
        ExpansionRecord(
            id: id,
            lang: lang,
            name: id,
            series: nil,
            abbr: nil,
            releaseDate: nil,
            logoUrl: nil,
            symbolUrl: nil,
            numMaster: nil,
            numRegular: nil,
            hash: nil,
            updatedAt: Date().timeIntervalSince1970,
            jsonData: nil
        )
    }
}

public struct CardRecord: Codable, FetchableRecord, PersistableRecord {
    public var id: String
    public var lang: String
    public var expansionId: String
    public var name: String
    public var collectorNumber: String?
    public var rarity: String?
    public var types: String?
    public var stage: String?
    public var hp: Int?
    public var imageUrl: String?
    public var foilUrl: String?
    public var etchUrl: String?
    public var dataHash: String?
    public var updatedAt: TimeInterval?
    public var jsonData: Data?

    public static let databaseTableName = "cards"

    public enum Columns: String, CodingKey, ColumnExpression {
        case id, lang, expansionId = "expansion_id", name, collectorNumber = "collector_number", rarity, types, stage, hp, imageUrl = "image_url", foilUrl = "foil_url", etchUrl = "etch_url", dataHash = "data_hash", updatedAt = "updated_at", jsonData = "json_data"
    }

    public typealias CodingKeys = Columns

    public init(card: CardData, expansionId: String) {
        self.id = card.id
        self.lang = card.lang
        self.expansionId = expansionId
        self.name = card.name
        self.collectorNumber = card.collectorNumber.full
        self.rarity = card.rarity?.designation.rawValue
        self.types = card.types?.map(\.rawValue).joined(separator: ",")
        self.stage = card.stage?.rawValue
        self.hp = card.hp
        self.imageUrl = card.images?.tcgl.tex?.front
        self.foilUrl = card.images?.tcgl.tex?.foil
        self.etchUrl = card.images?.tcgl.tex?.etch
        self.dataHash = card.ext?.tcgl.key
        self.updatedAt = Date().timeIntervalSince1970
        self.jsonData = try? JSONEncoder().encode(card)
    }

    public func toModel() -> CardData? {
        if let jsonData, let decoded = try? JSONDecoder().decode(CardData.self, from: jsonData) {
            return decoded
        }
        return nil
    }
}
