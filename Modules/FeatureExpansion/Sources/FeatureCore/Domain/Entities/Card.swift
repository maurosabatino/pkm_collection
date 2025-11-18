import Foundation

// MARK: - CardData (Main Structure)
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
        case foil // Nuovo campo
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

// MARK: - Foil
public struct Foil: Codable {
    public let type: FoilType
    public let mask: FoilMask

    public init(type: FoilType, mask: FoilMask) {
        self.type = type
        self.mask = mask
    }
}

// MARK: - FoilType
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
    case svHolo = "SV_HOLO" // Questo è il valore che causava l'errore!
    case svUltraScodix = "SV_ULTRA_SCODIX"
    case svUltra = "SV_ULTRA"
}

// MARK: - FoilMask
public enum FoilMask: String, Codable {
    case holo = "HOLO"
    case reverse = "REVERSE"
    case etched = "ETCHED"
    case stamped = "STAMPED"
    
}

// MARK: - Back
public enum Back: String, Codable {
    case pokemon1999 = "POKEMON_1999"
  
}

// MARK: - CardType
public enum CardType: String, Codable {
    case pokemon = "POKEMON"
    case trainer = "TRAINER"
    case energy = "ENERGY"
    case specialEnergy = "SPECIAL_ENERGY"
    // Dal dataset ho notato anche TRASPASO
    case traspaso = "TRASPASO" // Se è un tipo specifico in italiano
}

// MARK: - CollectorNumber
public struct CollectorNumber: Codable {
    public let full, numerator, denominator: String?
    public let numeric: Int

    public init(full: String?, numerator: String?, denominator: String?, numeric: Int) {
        self.full = full
        self.numerator = numerator
        self.denominator = denominator
        self.numeric = numeric
    }
}

// MARK: - Extension
public struct Extension: Codable {
    public let tcgl: TcglExtension

    public init(tcgl: TcglExtension) {
        self.tcgl = tcgl
    }
}

// MARK: - TcglExtension
public struct TcglExtension: Codable {
    public let cardID, longFormID, archetypeID, reldate: String
    public let key: String

    public init(cardID: String, longFormID: String, archetypeID: String, reldate: String, key: String) {
        self.cardID = cardID
        self.longFormID = longFormID
        self.archetypeID = archetypeID
        self.reldate = reldate
        self.key = key
    }

    enum CodingKeys: String, CodingKey {
        case cardID = "cardID"
        case longFormID = "longFormID"
        case archetypeID = "archetypeID"
        case reldate
        case key
    }
}

// MARK: - Images
public struct Images: Codable {
    public let tcgl: TcglImages

    public init(tcgl: TcglImages) {
        self.tcgl = tcgl
    }
}

// MARK: - TcglImages
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

// MARK: - ImagePaths (tex, png, jpg hanno la stessa sottostruttura, ora con foil)
public struct ImagePaths: Codable {
    public let front: String
    public let back: String?
    public let foil: String?
    public let etch: String?

    public init(front: String, back: String?, foil: String?, etch: String?) {
        self.front = front
        self.back = back
        self.foil = foil
        self.etch = etch
    }
}

// MARK: - PokemonType (Energie)
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

// MARK: - Rarity
public struct Rarity: Codable {
    public let designation: Designation
    public let icon: Icon

    public init(designation: Designation, icon: Icon) {
        self.designation = designation
        self.icon = icon
    }
}

// MARK: - Designation
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

// MARK: - Icon
public enum Icon: String, Codable {
    // Valori esistenti:
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

// MARK: - Size
public enum Size: String, Codable {
    case standard = "STANDARD"
    case jumbo = "JUMBO"
    case mini = "MINI"
}

// MARK: - Stage
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

// MARK: - TextElement
public struct TextElement: Codable {
    public let kind: TextKind
    public let name: String?
    public let text: String?
    public let cost: [PokemonType]?
    public let damage: Damage?

    public init(kind: TextKind, name: String?, text: String?, cost: [PokemonType]?, damage: Damage?) {
        self.kind = kind
        self.name = name
        self.text = text
        self.cost = cost
        self.damage = damage
    }
}

// MARK: - Damage
public struct Damage: Codable {
    public let amount: Int

    public init(amount: Int) {
        self.amount = amount
    }
}

// MARK: - TextKind (Tipo di elemento testuale)
public enum TextKind: String, Codable {
    
    case ability = "ABILITY"
    case attack = "ATTACK"
    case effect = "EFFECT"
    case reminder = "REMINDER"
    case ruleBox = "RULE_BOX"
    case textBox = "TEXT_BOX"
}

// MARK: - Weakness
public struct Weakness: Codable {
    public let types: [PokemonType]
    public let `operator`: String
    public let amount: Int

    public init(types: [PokemonType], operator: String, amount: Int) {
        self.types = types
        self.`operator` = `operator`
        self.amount = amount
    }
}

// MARK: - Resistance
public struct Resistance: Codable {
    public let types: [PokemonType]
    public let `operator`: String
    public let amount: Int

    public init(types: [PokemonType], operator: String, amount: Int) {
        self.types = types
        self.`operator` = `operator`
        self.amount = amount
    }
}

// MARK: - Ability (se le abilità sono un campo separato)
public struct Ability: Codable {
    public let name: String
    public let text: String
    public let kind: AbilityKind

    public init(name: String, text: String, kind: AbilityKind) {
        self.name = name
        self.text = text
        self.kind = kind
    }
}

// MARK: - AbilityKind
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


