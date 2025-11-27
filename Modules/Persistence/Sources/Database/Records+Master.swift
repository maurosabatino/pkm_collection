import Foundation
import GRDB
import CoreModels

// Read-only records matching the new card archive schema (expansions + localizations + prints/variants/localizations).

public struct ExpansionRecord: FetchableRecord, Decodable {
    public let id: String
    public let lang: String
    public let name: String
    public let seriesId: String?
    public let abbr: String?
    public let releaseDate: TimeInterval?
    public let logoUrl: String?
    public let symbolUrl: String?
    public let numMaster: Int?
    public let numRegular: Int?
    public let hash: String?

    public func toModel() -> Expansion {
        let cleanName = name.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
        return Expansion(
            id: id,
            series: seriesId ?? "",
            path: id,
            name: cleanName,
            num: NumInfo(master: numMaster ?? 0, regular: numRegular ?? 0),
            hash: hash ?? "",
            abbr: abbr ?? "",
            releaseDate: Date(timeIntervalSince1970: releaseDate ?? 0),
            symbolUrl: symbolUrl ?? "",
            logoUrl: logoUrl ?? ""
        )
    }
}

public struct CardRecord: FetchableRecord, Decodable {
    // Manual init to avoid decode failures on mixed SQLite types.
    public let id: String
    public let lang: String
    public let expansionId: String
    public let name: String
    public let collectorNumber: String?
    public let rarity: String?
    public let types: String?
    public let stage: String?
    public let hp: Int?
    public let cardType: String?
    public let imageUrl: String?
    public let foilUrl: String?
    public let etchUrl: String?
    public let dataHash: String?
    public let regulationMark: String?

    public init(row: Row) throws {
        id = row["id"]
        lang = row["lang"]
        expansionId = row["expansionId"]
        name = row["name"]
        collectorNumber = row["collectorNumber"]
        rarity = row["rarity"]
        types = row["types"]
        stage = row["stage"]
        hp = row["hp"]
        cardType = row["cardType"]
        imageUrl = row["imageUrl"]
        foilUrl = row["foilUrl"]
        etchUrl = row["etchUrl"]
        dataHash = row["dataHash"]
        regulationMark = row["regulationMark"]
    }

    public func toModel() -> CardData {
        let collector = CollectorNumber(
            full: collectorNumber ?? "",
            numerator: collectorNumber,
            denominator: nil,
            numeric: Int(collectorNumber ?? "0") ?? 0
        )
        let rarityModel = rarity.map { raw in
            Rarity(designation: Designation(rawValue: raw) ?? .common, icon: .noIcon)
        }
        let typesModel = types?.split(separator: ",").compactMap { PokemonType(rawValue: String($0)) }
        let cardType = cardType.flatMap { CardType(rawValue: $0) } ?? .pokemon
        let tex = ImagePaths(front: imageUrl ?? "", back: nil, foil: foilUrl, etch: etchUrl)
        // Bundle tex into png/jpg as well so existing UI can read from `images.tcgl.png`.
        let imageSet = TcglImages(tex: tex, png: tex, jpg: tex)
        return CardData(
            name: name,
            cardType: cardType,
            lang: lang,
            foil: nil,
            size: .standard,
            back: .pokemon1999,
            regulationMark: regulationMark,
            setIcon: "",
            collectorNumber: collector,
            rarity: rarityModel,
            stage: stage.flatMap { Stage(rawValue: $0) },
            hp: hp,
            types: typesModel,
            weakness: nil,
            resistance: nil,
            retreat: nil,
            text: nil,
            abilities: nil,
            rules: nil,
            flavorText: nil,
            ext: Extension(
                tcgl: TcglExtension(
                    cardID: id,
                    longFormID: "",
                    archetypeID: "",
                    reldate: "",
                    key: dataHash ?? ""
                )
            ),
            images: Images(tcgl: imageSet)
        )
    }
}
