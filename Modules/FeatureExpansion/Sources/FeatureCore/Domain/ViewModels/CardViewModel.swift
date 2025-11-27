//
//  CardViewModel.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 27/07/25.
//
import Foundation
import CoreModels

public struct CardViewModel: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let imageUrl: URL?
    public let foilDescription: String?
    public let collectorNumberNumeric: Int
    public let collectorNumberFull: String?
    public let foilImageUrl: URL?
    public let etchImageUrl: URL?
    public let cardTypeDisplay: String
    public let sizeDisplay: String
    public let languageDisplay: String
    public let regulationMark: String?
    public let expansionName: String?
    public let expansionPath: String?
    public let rarityDisplay: String?
    public let stageDisplay: String?
    public let hpDisplay: String?
    public let typeDisplay: String?
    public let weaknessDisplay: String?
    public let resistanceDisplay: String?
    public let retreatDisplay: String?
    public let flavorText: String?
    public let weaknesses: [String]
    public let resistances: [String]
    public let retreatCost: Int?
    public let rarityDesignation: Designation?
    public let moves: [CardMoveViewModel]

    public init(
        cardData: CardData,
        expansionName: String? = nil,
        expansionPath: String? = nil
    ) {
        self.id = cardData.id
        self.name = cardData.name
        self.imageUrl = URL(string: cardData.images?.tcgl.png?.front ?? "")
        self.collectorNumberNumeric = cardData.collectorNumber.numeric
        self.collectorNumberFull = cardData.collectorNumber.full
        self.foilImageUrl = URL(string: cardData.images?.tcgl.png?.foil ?? "")
        self.etchImageUrl = URL(string: cardData.images?.tcgl.png?.etch ?? "")
        self.cardTypeDisplay = Self.formatDisplayText(cardData.cardType.rawValue)
        self.sizeDisplay = Self.formatDisplayText(cardData.size.rawValue)
        self.languageDisplay = cardData.lang.uppercased()
        self.regulationMark = cardData.regulationMark
        self.expansionName = expansionName
        self.expansionPath = expansionPath
        self.rarityDesignation = cardData.rarity?.designation
        self.rarityDisplay = cardData.rarity.map { Self.formatDisplayText($0.designation.rawValue) }
        self.stageDisplay = cardData.stage.map { Self.formatDisplayText($0.rawValue) }
        self.hpDisplay = cardData.hp.map { "\($0) HP" }
        if let pokemonTypes = cardData.types, !pokemonTypes.isEmpty {
            self.typeDisplay = pokemonTypes.map { Self.formatDisplayText($0.rawValue) }.joined(separator: ", ")
        } else {
            self.typeDisplay = nil
        }
        self.weaknessDisplay = Self.describe(weakness: cardData.weakness)
        self.resistanceDisplay = Self.describe(resistance: cardData.resistance)
        self.weaknesses = cardData.weakness.map { $0.types.map { Self.formatDisplayText($0.rawValue) } } ?? []
        self.resistances = cardData.resistance.map { $0.types.map { Self.formatDisplayText($0.rawValue) } } ?? []
        self.retreatCost = cardData.retreat
        self.retreatDisplay = cardData.retreat.map { value in
            value == 1 ? "1 energia" : "\(value) energie"
        }
        self.flavorText = cardData.flavorText?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.moves = Self.buildMoves(
            cardId: cardData.id,
            textElements: cardData.text,
            abilities: cardData.abilities
        )

        if let foil = cardData.foil {
            let foilType = foil.type.rawValue.replacingOccurrences(of: "_", with: " ").capitalized
            let foilMask = foil.mask.rawValue.replacingOccurrences(of: "_", with: " ").capitalized
            self.foilDescription = "\(foilType) (\(foilMask))"
        } else {
            self.foilDescription = FeatureExpansionStrings.noFoil
        }
    }

    private static func formatDisplayText(_ rawValue: String) -> String {
        rawValue.replacingOccurrences(of: "_", with: " ").capitalized
    }

    private static func describe(weakness: Weakness?) -> String? {
        guard let weakness else { return nil }
        return describe(types: weakness.types, symbol: weakness.`operator`, amount: weakness.amount)
    }

    private static func describe(resistance: Resistance?) -> String? {
        guard let resistance else { return nil }
        return describe(types: resistance.types, symbol: resistance.`operator`, amount: resistance.amount)
    }

    private static func describe(types: [PokemonType], symbol: String, amount: Int) -> String {
        let names = types.map { formatDisplayText($0.rawValue) }.joined(separator: ", ")
        let modifier = "\(symbol)\(amount)"
        return [names.isEmpty ? nil : names, modifier]
            .compactMap { $0 }
            .joined(separator: " ")
    }

    private static func buildMoves(cardId: String, textElements: [TextElement]?, abilities: [Ability]?) -> [CardMoveViewModel] {
        var result: [CardMoveViewModel] = []

        if let abilities {
            for (index, ability) in abilities.enumerated() {
                let id = "\(cardId)-ability-\(index)"
                let badge = formatDisplayText(ability.kind.rawValue)
                result.append(
                    CardMoveViewModel(
                        id: id,
                        title: ability.name,
                        description: ability.text,
                        energyCost: nil,
                        damage: nil,
                        badgeText: badge
                    )
                )
            }
        }

        if let textElements {
            for (index, element) in textElements.enumerated() {
                guard let move = renderMove(element, cardId: cardId, index: index) else { continue }
                result.append(move)
            }
        }

        return result
    }

    private static func renderMove(_ element: TextElement, cardId: String, index: Int) -> CardMoveViewModel? {
        switch element.kind {
        case .attack:
            let id = "\(cardId)-attack-\(index)"
            let energy = describeEnergyCost(element.cost)
            let damage = element.damage.map { "\($0.amount)" }
            return CardMoveViewModel(
                id: id,
                title: element.name ?? "Attacco",
                description: element.text,
                energyCost: energy,
                damage: damage,
                badgeText: "Attacco"
            )
        case .ability:
            let id = "\(cardId)-ability-text-\(index)"
            return CardMoveViewModel(
                id: id,
                title: element.name ?? "Abilità",
                description: element.text,
                energyCost: describeEnergyCost(element.cost),
                damage: element.damage.map { "\($0.amount)" },
                badgeText: "Abilità"
            )
        case .effect, .reminder, .ruleBox, .textBox:
            let id = "\(cardId)-effect-\(index)"
            return CardMoveViewModel(
                id: id,
                title: element.name ?? localizedLabel(for: element.kind),
                description: element.text,
                energyCost: describeEnergyCost(element.cost),
                damage: element.damage.map { "\($0.amount)" },
                badgeText: localizedLabel(for: element.kind)
            )
        }
    }

    private static func describeEnergyCost(_ cost: [PokemonType]?) -> String? {
        guard let cost, !cost.isEmpty else { return nil }
        return cost
            .map { formatDisplayText($0.rawValue) }
            .joined(separator: " + ")
    }

    private static func localizedLabel(for kind: TextKind) -> String {
        switch kind {
        case .attack:
            return "Attacco"
        case .ability:
            return "Abilità"
        case .effect:
            return "Effetto"
        case .reminder:
            return "Promemoria"
        case .ruleBox:
            return "Regola"
        case .textBox:
            return "Testo"
        }
    }
}

public struct CardMoveViewModel: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let description: String?
    public let energyCost: String?
    public let damage: String?
    public let badgeText: String?
}


public enum CardDisplayMode: String, CaseIterable, Identifiable {
    case regular = "Regular Set"
    case master = "Master Set"

    public var id: String { rawValue }
}
