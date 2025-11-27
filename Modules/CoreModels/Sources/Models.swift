import Foundation

// MARK: - Expansions

public struct NumInfo: Codable, Hashable, Identifiable {
    public let id: UUID
    public let master: Int
    public let regular: Int

    public init(id: UUID = UUID(), master: Int, regular: Int) {
        self.id = id
        self.master = master
        self.regular = regular
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self.id = UUID()
            self.master = intValue
            self.regular = intValue
        } else {
            let objectContainer = try decoder.container(keyedBy: CodingKeys.self)
            self.id = UUID()
            self.master = try objectContainer.decode(Int.self, forKey: .master)
            self.regular = try objectContainer.decode(Int.self, forKey: .regular)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case master
        case regular
    }
}

public struct Expansion: Codable, Identifiable, Hashable {
    public let id: String
    public let series: String
    public let path: String
    public let name: String
    public let num: NumInfo
    public let hash: String
    public let abbr: String
    public let releaseDate: Date
    public let symbolUrl: String
    public let logoUrl: String

    private enum CodingKeys: String, CodingKey {
        case id = "key"
        case series
        case path
        case name
        case num
        case hash
        case abbr
        case releaseDate
        case symbolUrl
        case logoUrl
    }

    public init(
        id: String,
        series: String,
        path: String,
        name: String,
        num: NumInfo,
        hash: String,
        abbr: String,
        releaseDate: Date,
        symbolUrl: String,
        logoUrl: String
    ) {
        self.id = id
        self.series = series
        self.path = path
        self.name = name
        self.num = num
        self.hash = hash
        self.abbr = abbr
        self.releaseDate = releaseDate
        self.symbolUrl = symbolUrl
        self.logoUrl = logoUrl
    }
}

public struct CollectorNumber: Codable, Hashable {
    public let full, numerator, denominator: String?
    public let numeric: Int

    public init(full: String?, numerator: String?, denominator: String?, numeric: Int) {
        self.full = full
        self.numerator = numerator
        self.denominator = denominator
        self.numeric = numeric
    }
}

// MARK: - Ownership & Lists

public struct OwnedCard: Codable, Identifiable, Hashable {
    public var id: String { cardId }
    public let cardId: String
    public var quantity: Int
    public var notes: String?
    public var lastUpdated: Date
    public var isWishlist: Bool

    public init(cardId: String, quantity: Int = 1, notes: String? = nil, lastUpdated: Date = Date(), isWishlist: Bool = false) {
        self.cardId = cardId
        self.quantity = quantity
        self.notes = notes
        self.lastUpdated = lastUpdated
        self.isWishlist = isWishlist
    }
}

public struct Deck: Codable, Identifiable, Equatable {
    public let id: String
    public var name: String
    public var format: String?
    public var notes: String?
    public var updatedAt: Date
    public var deleted: Bool

    public init(id: String, name: String, format: String?, notes: String?, updatedAt: Date, deleted: Bool) {
        self.id = id
        self.name = name
        self.format = format
        self.notes = notes
        self.updatedAt = updatedAt
        self.deleted = deleted
    }
}

public struct DeckCard: Codable, Identifiable, Equatable {
    public var id: String { "\(deckId)-\(cardId)-\(role)" }
    public let deckId: String
    public let cardId: String
    public var quantity: Int
    public var role: String // "main" | "side"
    public var updatedAt: Date
    public var deleted: Bool

    public init(deckId: String, cardId: String, quantity: Int, role: String, updatedAt: Date, deleted: Bool) {
        self.deckId = deckId
        self.cardId = cardId
        self.quantity = quantity
        self.role = role
        self.updatedAt = updatedAt
        self.deleted = deleted
    }
}

public struct Wishlist: Codable, Identifiable, Equatable {
    public let id: String
    public var name: String
    public var notes: String?
    public var updatedAt: Date
    public var deleted: Bool

    public init(id: String = UUID().uuidString, name: String, notes: String?, updatedAt: Date, deleted: Bool) {
        self.id = id
        self.name = name
        self.notes = notes
        self.updatedAt = updatedAt
        self.deleted = deleted
    }
}

public struct WishlistItem: Codable, Identifiable, Equatable {
    public var id: String { "\(wishlistId)-\(cardId)" }
    public let wishlistId: String
    public let cardId: String
    public var quantity: Int
    public var updatedAt: Date
    public var deleted: Bool

    public init(wishlistId: String, cardId: String, quantity: Int, updatedAt: Date, deleted: Bool) {
        self.wishlistId = wishlistId
        self.cardId = cardId
        self.quantity = quantity
        self.updatedAt = updatedAt
        self.deleted = deleted
    }
}

// MARK: - Card Catalog

public struct CardData: Codable, Identifiable {
    public var id: String {
        ext?.tcgl.cardID ?? UUID().uuidString
    }

    public let name: String
    public let cardType: CardType
    public let lang: String
    public let foil: Foil?
    public let size: Size
    public let back: Back
    public let regulationMark: String?
    public let setIcon: String
    public let collectorNumber: CollectorNumber
    public let rarity: Rarity?
    public let stage: Stage?
    public let hp: Int?
    public let types: [PokemonType]?
    public let weakness: Weakness?
    public let resistance: Resistance?
    public let retreat: Int?
    public let text: [TextElement]?
    public let abilities: [Ability]?
    public let rules: [String]?
    public let flavorText: String?
    public let ext: Extension?
    public let images: Images?

    enum CodingKeys: String, CodingKey {
        case name
        case cardType = "card_type"
        case lang
        case foil
        case size
        case back
        case regulationMark = "regulation_mark"
        case setIcon = "set_icon"
        case collectorNumber = "collector_number"
        case rarity
        case stage
        case hp
        case types
        case weakness
        case resistance
        case retreat
        case text
        case abilities
        case rules
        case flavorText = "flavor_text"
        case ext
        case images
    }

    public init(
        name: String,
        cardType: CardType,
        lang: String,
        foil: Foil?,
        size: Size,
        back: Back,
        regulationMark: String?,
        setIcon: String,
        collectorNumber: CollectorNumber,
        rarity: Rarity?,
        stage: Stage?,
        hp: Int?,
        types: [PokemonType]?,
        weakness: Weakness?,
        resistance: Resistance?,
        retreat: Int?,
        text: [TextElement]?,
        abilities: [Ability]?,
        rules: [String]?,
        flavorText: String?,
        ext: Extension?,
        images: Images?
    ) {
        self.name = name
        self.cardType = cardType
        self.lang = lang
        self.foil = foil
        self.size = size
        self.back = back
        self.regulationMark = regulationMark
        self.setIcon = setIcon
        self.collectorNumber = collectorNumber
        self.rarity = rarity
        self.stage = stage
        self.hp = hp
        self.types = types
        self.weakness = weakness
        self.resistance = resistance
        self.retreat = retreat
        self.text = text
        self.abilities = abilities
        self.rules = rules
        self.flavorText = flavorText
        self.ext = ext
        self.images = images
    }
}

public struct Foil: Codable {
    public let type: FoilType
    public let mask: FoilMask

    public init(type: FoilType, mask: FoilMask) {
        self.type = type
        self.mask = mask
    }
}

public enum FoilType: String, Codable {
    case flatSilver = "FLAT_SILVER"
    case cosmos = "COSMOS"
    case dots = "DOTS"
    case galaxy = "GALAXY"
    case gold = "GOLD"
    case etched = "ETCHED"
    case aceFoil = "ACE_FOIL"
    case crackedIce = "CRACKED_ICE"
    case rainbow = "RAINBOW"
    case stamped = "STAMPED"
    case sunPillar = "SUN_PILLAR"
    case svHolo = "SV_HOLO"
    case svUltraScodix = "SV_ULTRA_SCODIX"
    case svUltra = "SV_ULTRA"
}

public enum FoilMask: String, Codable {
    case holo = "HOLO"
    case reverse = "REVERSE"
    case etched = "ETCHED"
    case stamped = "STAMPED"
}

public enum Back: String, Codable {
    case pokemon1999 = "POKEMON_1999"
}

public enum CardType: String, Codable {
    case pokemon = "POKEMON"
    case trainer = "TRAINER"
    case energy = "ENERGY"
    case specialEnergy = "SPECIAL_ENERGY"
    case traspaso = "TRASPASO"
}

public struct Extension: Codable {
    public let tcgl: TcglExtension

    public init(tcgl: TcglExtension) {
        self.tcgl = tcgl
    }
}

public struct TcglExtension: Codable {
    public let cardID: String
    public let longFormID: String
    public let archetypeID: String
    public let reldate: String
    public let key: String
}

public struct Images: Codable {
    public let tcgl: TcglImages

    public init(tcgl: TcglImages) {
        self.tcgl = tcgl
    }
}

public struct TcglImages: Codable {
    public let tex: ImagePaths?
    public let png: ImagePaths?
    public let jpg: ImagePaths?

    public init(tex: ImagePaths?, png: ImagePaths?, jpg: ImagePaths?) {
        self.tex = tex
        self.png = png
        self.jpg = jpg
    }
}

public struct ImagePaths: Codable {
    public let front: String
    public let back: String?
    public let foil: String?
    public let etch: String?
}

public enum PokemonType: String, Codable {
    case colorless = "COLORLESS"
    case grass = "GRASS"
    case fire = "FIRE"
    case water = "WATER"
    case lightning = "LIGHTNING"
    case psychic = "PSYCHIC"
    case fighting = "FIGHTING"
    case darkness = "DARKNESS"
    case metal = "METAL"
    case dragon = "DRAGON"
    case fairy = "FAIRY"
    case free = "FREE"
}

public struct Rarity: Codable {
    public let designation: Designation
    public let icon: Icon
}

public enum Designation: String, Codable {
    case common = "COMMON"
    case uncommon = "UNCOMMON"
    case rare = "RARE"
    case rareHolo = "RARE_HOLO"
    case rareReverseHolo = "RARE_REVERSE_HOLOL"
    case rareUltra = "RARE_ULTRA"
    case rareSecret = "RARE_SECRET"
    case rareRainbow = "RARE_RAINBOW"
    case rareShiny = "RARE_SHINY"
    case promo = "PROMO"
    case rarePromo = "RARE_PROMO"
    case rareAmazing = "RARE_AMAZING"
    case rareShinyGx = "RARE_SHINY_GX"
    case rareHyper = "RARE_HYPER"
    case rarePrime = "RARE_PRIME"
    case rareLegend = "RARE_LEGEND"
    case rareShining = "RARE_SHINING"
    case rareBreak = "RARE_BREAK"
    case illustrationRare = "ILLUSTRATION_RARE"
    case specialIllustrationRare = "SPECIAL_ILLUSTRATION_RARE"
    case doubleRare = "DOUBLE_RARE"
    case ultraRare = "ULTRA_RARE"
    case hyperRare = "HYPER_RARE"
    case goldRare = "GOLD_RARE"
    case leaguePromo = "LEAGUE_PROMO"
    case staffPromo = "STAFF_PROMO"
    case tournamentPromo = "TOURNAMENT_PROMO"
    case aceSpecRare = "ACE_SPEC_RARE"
    case shinyRare = "SHINY_RARE"
    case shinyUltraRare = "SHINY_ULTRA_RARE"
}

public enum Icon: String, Codable {
    case solidCircle = "SOLID_CIRCLE"
    case solidDiamond = "SOLID_DIAMOND"
    case solidStar = "SOLID_STAR"
    case goldStar = "GOLD_STAR"
    case shinyStar = "SHINY_STAR"
    case rareHolo = "RARE_HOLO"
    case reverseHolo = "REVERSE_HOLO"
    case noIcon = "NO_ICON"
    case blackStarPromo = "BLACK_STAR_PROMO"
    case twoBlackStars = "TWO_BLACK_STARS"
    case twoSilverStars = "TWO_SILVER_STARS"
    case twoGoldStars = "TWO_GOLD_STARS"
    case threeGoldStars = "THREE_GOLD_STARS"
    case twoShinyStars = "TWO_SHINY_STARS"
    case pinkStar = "PINK_STAR"
}

public enum Size: String, Codable {
    case standard = "STANDARD"
    case jumbo = "JUMBO"
    case mini = "MINI"
}

public enum Stage: String, Codable {
    case basic = "BASIC"
    case stage1 = "STAGE1"
    case stage2 = "STAGE2"
    case restoration = "RESTORATION"
    case mega = "MEGA"
    case gx = "GX"
    case v = "V"
    case vmax = "VMAX"
    case vstar = "VSTAR"
    case ex = "EX"
    case singleStrike = "SINGLE_STRIKE"
    case rapidStrike = "RAPID_STRIKE"
    case fusionStrike = "FUSION_STRIKE"
    case tera = "TERA"
    case legend = "LEGEND"
    case baby = "BABY"
}

public struct TextElement: Codable {
    public let kind: TextKind
    public let name: String?
    public let text: String?
    public let cost: [PokemonType]?
    public let damage: Damage?
}

public struct Damage: Codable {
    public let amount: Int
}

public enum TextKind: String, Codable {
    case ability = "ABILITY"
    case attack = "ATTACK"
    case effect = "EFFECT"
    case reminder = "REMINDER"
    case ruleBox = "RULE_BOX"
    case textBox = "TEXT_BOX"
}

public struct Weakness: Codable {
    public let types: [PokemonType]
    public let `operator`: String
    public let amount: Int
}

public struct Resistance: Codable {
    public let types: [PokemonType]
    public let `operator`: String
    public let amount: Int
}

public struct Ability: Codable {
    public let name: String
    public let text: String
    public let kind: AbilityKind
}

public enum AbilityKind: String, Codable {
    case ability = "ABILITY"
    case pokemonPower = "POKEMON_POWER"
    case pokemonBody = "POKEMON_BODY"
    case pokemonPokePower = "POKEMON_POKE_POWER"
    case pokemonPokeBody = "POKEMON_POKE_BODY"
    case vstarPower = "VSTAR_POWER"
    case vstarAbility = "VSTAR_ABILITY"
    case vstarAttack = "VSTAR_ATTACK"
    case vmaxPower = "VMAX_POWER"
    case gxAttack = "GX_ATTACK"
    case gxAbility = "GX_ABILITY"
    case ancientTrait = "ANCIENT_TRAIT"
}
