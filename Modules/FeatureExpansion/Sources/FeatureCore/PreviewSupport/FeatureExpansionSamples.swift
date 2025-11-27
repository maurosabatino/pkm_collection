import Foundation
import CoreModels

enum FeatureExpansionSamples {
    static let expansionName1 = "Spada e Scudo"
    static let expansionSeries1 = "Sword & Shield"
    static let expansionName2 = "Sole e Luna"
    static let expansionSeries2 = "Sole e Luna"
    static let expansionName3 = "XY"
    static let expansionSeries3 = "XY"
    static let expansionName4 = "Evoluzioni a Paldea"
    static let expansionSeries4 = "Scarlatto e Violetto"
    static let expansionName5 = "Destino di Paldea"
    static let expansionSeries5 = "Scarlatto e Violetto"
    static let expansionName6 = "Zenit Regale"
    static let expansionSeries6 = "Spada e Scudo"

    static let cardName1 = "Pikachu"
    static let cardName2 = "Charizard"
    static let cardName3 = "Mewtwo"

    static let sampleExpansion = Expansion(
        id: "swsh1",
        series: FeatureExpansionSamples.expansionSeries1,
        path: "swsh1",
        name: FeatureExpansionSamples.expansionName1,
        num: NumInfo(master: 202, regular: 150),
        hash: "abc",
        abbr: "SSH",
        releaseDate: Date(),
        symbolUrl: "https://images.pokemontcg.io/swsh1/symbol.png",
        logoUrl: "https://images.pokemontcg.io/swsh1/logo.png"
    )

    static let sampleCardData: [CardData] = [
        CardData(
            name: FeatureExpansionSamples.cardName1,
            cardType: .pokemon,
            lang: "en",
            foil: nil,
            size: .standard,
            back: .pokemon1999,
            regulationMark: nil,
            setIcon: "",
            collectorNumber: CollectorNumber(full: "1/100", numerator: "1", denominator: "100", numeric: 1),
            rarity: nil,
            stage: .basic,
            hp: 60,
            types: [.lightning],
            weakness: nil,
            resistance: nil,
            retreat: 1,
            text: nil,
            abilities: nil,
            rules: nil,
            flavorText: nil,
            ext: nil,
            images: nil
        ),
        CardData(
            name: FeatureExpansionSamples.cardName2,
            cardType: .pokemon,
            lang: "en",
            foil: nil,
            size: .standard,
            back: .pokemon1999,
            regulationMark: nil,
            setIcon: "",
            collectorNumber: CollectorNumber(full: "2/100", numerator: "2", denominator: "100", numeric: 2),
            rarity: nil,
            stage: .stage2,
            hp: 160,
            types: [.fire],
            weakness: nil,
            resistance: nil,
            retreat: 3,
            text: nil,
            abilities: nil,
            rules: nil,
            flavorText: nil,
            ext: nil,
            images: nil
        ),
        CardData(
            name: FeatureExpansionSamples.cardName3,
            cardType: .pokemon,
            lang: "en",
            foil: nil,
            size: .standard,
            back: .pokemon1999,
            regulationMark: nil,
            setIcon: "",
            collectorNumber: CollectorNumber(full: "3/100", numerator: "3", denominator: "100", numeric: 3),
            rarity: nil,
            stage: .basic,
            hp: 130,
            types: [.psychic],
            weakness: nil,
            resistance: nil,
            retreat: 2,
            text: nil,
            abilities: nil,
            rules: nil,
            flavorText: nil,
            ext: nil,
            images: nil
        )
    ]

    static var sampleCardViewModels: [CardViewModel] {
        sampleCardData.map { CardViewModel(cardData: $0) }
    }

    static let sampleExpansions: [Expansion] = [
        Expansion(
            id: "swsh1",
            series: expansionSeries1,
            path: "swsh1",
            name: expansionName1,
            num: NumInfo(master: 202, regular: 150),
            hash: "hash_swsh1",
            abbr: "SSH",
            releaseDate: Date(),
            symbolUrl: "https://images.pokemontcg.io/swsh1/symbol.png",
            logoUrl: "https://images.pokemontcg.io/swsh1/logo.png"
        ),
        Expansion(
            id: "sm1",
            series: expansionSeries2,
            path: "sm1",
            name: expansionName2,
            num: NumInfo(master: 214, regular: 149),
            hash: "hash_sm1",
            abbr: "SUM",
            releaseDate: Date().addingTimeInterval(-60 * 60 * 24 * 400),
            symbolUrl: "https://images.pokemontcg.io/sm1/symbol.png",
            logoUrl: "https://images.pokemontcg.io/sm1/logo.png"
        ),
        Expansion(
            id: "xy1",
            series: expansionSeries3,
            path: "xy1",
            name: expansionName3,
            num: NumInfo(master: 146, regular: 116),
            hash: "hash_xy1",
            abbr: "XY",
            releaseDate: Date().addingTimeInterval(-60 * 60 * 24 * 800),
            symbolUrl: "https://images.pokemontcg.io/xy1/symbol.png",
            logoUrl: "https://images.pokemontcg.io/xy1/logo.png"
        ),
        Expansion(
            id: "sv1",
            series: expansionSeries4,
            path: "sv1",
            name: expansionName4,
            num: NumInfo(master: 198, regular: 180),
            hash: "hash_sv1",
            abbr: "SVP",
            releaseDate: Date().addingTimeInterval(-60 * 60 * 24 * 100),
            symbolUrl: "https://images.pokemontcg.io/sv1/symbol.png",
            logoUrl: "https://images.pokemontcg.io/sv1/logo.png"
        )
    ]
}
