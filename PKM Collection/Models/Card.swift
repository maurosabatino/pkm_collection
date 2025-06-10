import Foundation

// MARK: - CardData (Main Structure)
struct CardData: Codable, Identifiable {

    var id: String {
        return ext?.tcgl.cardID ?? UUID().uuidString // Fallback a UUID se cardID non c'è
    }

    let name: String
    let cardType: CardType
    let lang: String
    let foil: Foil? // Aggiunto il campo foil, reso opzionale
    let size: Size
    let back: Back
    let regulationMark: String?
    let setIcon: String
    let collectorNumber: CollectorNumber
    let rarity: Rarity
    let stage: Stage?
    let hp: Int?
    let types: [PokemonType]?
    let weakness: Weakness?
    let resistance: Resistance?
    let retreat: Int?
    let text: [TextElement]?
    let abilities: [Ability]?
    let rules: [String]?
    let flavorText: String?

    let ext: Extension? // Reso opzionale, anche se presente nell'esempio
    let images: Images? // Reso opzionale, anche se presente nell'esempio

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
}

// MARK: - Foil
struct Foil: Codable {
    let type: FoilType
    let mask: FoilMask
}

// MARK: - FoilType
enum FoilType: String, Codable {
    // Valori già presenti/ipotizzati:
    case flatSilver = "FLAT_SILVER"
    case cosmos = "COSMOS"
    case dots = "DOTS"
    case galaxy = "GALAXY"
    case gold = "GOLD"
    case etched = "ETCHED"

    // NUOVI VALORI AGGIUNTI BASANDOSI SUL TUO OUTPUT E DOCUMENTAZIONE:
    case aceFoil = "ACE_FOIL"
    case crackedIce = "CRACKED_ICE"
    case rainbow = "RAINBOW"
    case stamped = "STAMPED"
    case sunPillar = "SUN_PILLAR"
    case svHolo = "SV_HOLO" // Questo è il valore che causava l'errore!
    case svUltraScodix = "SV_ULTRA_SCODIX"
    case svUltra = "SV_ULTRA"
    // Aggiungi altri tipi di foil che trovi nel dataset, es. "STARRY", "HOLOLIVE"
}

// MARK: - FoilMask
enum FoilMask: String, Codable {
    case holo = "HOLO"
    case reverse = "REVERSE"
    case etched = "ETCHED"
    case stamped = "STAMPED"
    
}

// MARK: - Back
enum Back: String, Codable {
    case pokemon1999 = "POKEMON_1999"
  
}

// MARK: - CardType
enum CardType: String, Codable {
    case pokemon = "POKEMON"
    case trainer = "TRAINER"
    case energy = "ENERGY"
    case specialEnergy = "SPECIAL_ENERGY"
    // Dal dataset ho notato anche TRASPASO
    case traspaso = "TRASPASO" // Se è un tipo specifico in italiano
}

// MARK: - CollectorNumber
struct CollectorNumber: Codable {
    let full, numerator, denominator: String?
    let numeric: Int
}

// MARK: - Extension
struct Extension: Codable {
    let tcgl: TcglExtension
}

// MARK: - TcglExtension
struct TcglExtension: Codable {
    let cardID, longFormID, archetypeID, reldate: String
    let key: String

    enum CodingKeys: String, CodingKey {
        case cardID = "cardID"
        case longFormID = "longFormID"
        case archetypeID = "archetypeID"
        case reldate
        case key
    }
}

// MARK: - Images
struct Images: Codable {
    let tcgl: TcglImages
}

// MARK: - TcglImages
struct TcglImages: Codable {
    let tex: ImagePaths?
    let png: ImagePaths?
    let jpg: ImagePaths?
}

// MARK: - ImagePaths (tex, png, jpg hanno la stessa sottostruttura, ora con foil)
struct ImagePaths: Codable {
    let front: String
    let back: String?
    let foil: String? // Aggiunto l'URL per il foil
}

// MARK: - PokemonType (Energie)
enum PokemonType: String, Codable {
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
struct Rarity: Codable {
    let designation: Designation
    let icon: Icon
}

// MARK: - Designation
enum Designation: String, Codable {
    case common = "COMMON"
    case uncommon = "UNCOMMON"
    case rare = "RARE"
    case rareHolo = "RARE_HOLO"
    case rareReverseHolo = "RARE_REVERSE_HOLOL" // Controlla la doc esatta per questo. Potrebbe essere solo RARE_REVERSE_HOLOL.
    case rareUltra = "RARE_ULTRA"
    case rareSecret = "RARE_SECRET"
    case rareRainbow = "RARE_RAINBOW"
    case rareShiny = "RARE_SHINY"
    case promo = "PROMO"
    case rarePromo = "RARE_PROMO" // Esiste anche in alcuni dataset
    case rareAmazing = "RARE_AMAZING" // Tipo raro "Amazing Rare"
    case rareShinyGx = "RARE_SHINY_GX"
    case rareHyper = "RARE_HYPER"
    case rarePrime = "RARE_PRIME"
    case rareLegend = "RARE_LEGEND"
    case rareShining = "RARE_SHINING"
    case rareBreak = "RARE_BREAK"
    case illustrationRare = "ILLUSTRATION_RARE"
    case specialIllustrationRare = "SPECIAL_ILLUSTRATION_RARE"
    case doubleRare = "DOUBLE_RARE"
    case ultraRare = "ULTRA_RARE" // A volte usato al posto di RARE_ULTRA
    case hyperRare = "HYPER_RARE" // A volte usato al posto di RARE_RAINBOW
    case goldRare = "GOLD_RARE" // A volte usato per carte gold
    case leaguePromo = "LEAGUE_PROMO"
    case staffPromo = "STAFF_PROMO"
    case tournamentPromo = "TOURNAMENT_PROMO"
    case aceSpecRare = "ACE_SPEC_RARE"
    case shinyRare = "SHINY_RARE"
    case shinyUltraRare = "SHINY_ULTRA_RARE"
}

// MARK: - Icon
enum Icon: String, Codable {
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
enum Size: String, Codable {
    case standard = "STANDARD"
    case jumbo = "JUMBO"
    case mini = "MINI"
}

// MARK: - Stage
enum Stage: String, Codable {
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

// MARK: - TextElement (per Attacchi, Abilità, Regole integrate nel campo "text")
struct TextElement: Codable {
    let kind: TextKind
    let name: String?
    let text: String?
    let cost: [PokemonType]?
    let damage: Damage?
}

// MARK: - Damage
struct Damage: Codable {
    let amount: Int
}

// MARK: - TextKind (Tipo di elemento testuale)
enum TextKind: String, Codable {
    
    case ability = "ABILITY"
    case attack = "ATTACK"
    case effect = "EFFECT"
    case reminder = "REMINDER"
    case ruleBox = "RULE_BOX"
    case textBox = "TEXT_BOX"
}

// MARK: - Weakness
struct Weakness: Codable {
    let types: [PokemonType]
    let `operator`: String
    let amount: Int // Se l'amount può essere String, cambialo qui
}

// MARK: - Resistance
struct Resistance: Codable {
    let types: [PokemonType]
    let `operator`: String
    let amount: Int // Se l'amount può essere String, cambialo qui
}

// MARK: - Ability (se le abilità sono un campo separato)
struct Ability: Codable {
    let name: String
    let text: String
    let kind: AbilityKind
}

// MARK: - AbilityKind
enum AbilityKind: String, Codable {
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

/*
// MARK: - Esempio di utilizzo per il decoding (con il nuovo JSON)

let jsonStringWithFoil = """
{
    "name": "Pineco",
    "card_type": "POKEMON",
    "lang": "it-IT",
    "foil": {
      "type": "FLAT_SILVER",
      "mask": "REVERSE"
    },
    "size": "STANDARD",
    "back": "POKEMON_1999",
    "regulation_mark": "G",
    "set_icon": "SVI_IT",
    "collector_number": {
      "full": "001/198",
      "numerator": "001",
      "denominator": "198",
      "numeric": 1
    },
    "rarity": {
      "designation": "COMMON",
      "icon": "SOLID_CIRCLE"
    },
    "stage": "BASIC",
    "hp": 60,
    "types": [
      "GRASS"
    ],
    "weakness": {
      "types": [
        "FIRE"
      ],
      "operator": "×",
      "amount": 2
    },
    "retreat": 2,
    "text": [
      {
        "kind": "ATTACK",
        "name": "Pressadifesa",
        "text": "Durante il prossimo turno del tuo avversario, questo Pokémon subisce 30 danni in meno dagli attacchi, dopo aver applicato debolezza e resistenza.",
        "cost": [
          "COLORLESS",
          "COLORLESS"
        ],
        "damage": {
          "amount": 10
        }
      }
    ],
    "ext": {
      "tcgl": {
        "cardID": "sv1_1_ph",
        "longFormID": "Pineco_sv1_1_ph_Common_FlatSilver_Reverse",
        "archetypeID": "0x2d44991a",
        "reldate": "2023-03-30 17:00:00+00:00",
        "key": "sv1"
      }
    },
    "images": {
      "tcgl": {
        "tex": {
          "front": "https://cdn.malie.io/file/malie-io/tcgl/cards/tex/it/sv1/sv1_it_001_std.png",
          "foil": "https://cdn.malie.io/file/malie-io/tcgl/cards/tex/it/sv1/sv1_it_001_ph.foil.png"
        },
        "png": {
          "front": "https://cdn.malie.io/file/malie-io/tcgl/cards/png/it/sv1/sv1_it_001_std.png",
          "foil": "https://cdn.malie.io/file/malie-io/tcgl/cards/png/it/sv1/sv1_it_001_ph.foil.png"
        },
        "jpg": {
          "front": "https://cdn.malie.io/file/malie-io/tcgl/cards/jpg/it/sv1/sv1_it_001_std.jpg"
        }
      }
    }
  }
"""

do {
    let jsonData = jsonStringWithFoil.data(using: .utf8)!
    let decoder = JSONDecoder()
    let card = try decoder.decode(CardData.self, from: jsonData)

    print("Nome Pokémon: \(card.name)")
    print("Tipo di carta: \(card.cardType.rawValue)")
    print("Foil Type: \(card.foil?.type.rawValue ?? "N/A")")
    print("Foil Mask: \(card.foil?.mask.rawValue ?? "N/A")")
    print("URL immagine JPG (front): \(card.images?.tcgl.jpg?.front ?? "N/A")")
    print("URL immagine JPG (foil): \(card.images?.tcgl.jpg?.foil ?? "N/A")")


} catch {
    print("Errore durante il decoding: \(error)")
    if let decodingError = error as? DecodingError {
        switch decodingError {
        case .typeMismatch(let type, let context):
            print("Type Mismatch for type \(type) in context: \(context.debugDescription)")
            print("Coding Path: \(context.codingPath)")
        case .valueNotFound(let type, let context):
            print("Value Not Found for type \(type) in context: \(context.debugDescription)")
            print("Coding Path: \(context.codingPath)")
        case .keyNotFound(let key, let context):
            print("Key Not Found: \(key.stringValue) in context: \(context.debugDescription)")
            print("Coding Path: \(context.codingPath)")
        case .dataCorrupted(let context):
            print("Data Corrupted: \(context.debugDescription)")
            print("Coding Path: \(context.codingPath)")
        @unknown default:
            print("Unknown decoding error: \(decodingError)")
        }
    }
}
*/
