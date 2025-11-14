//
//  CardViewModel.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 27/07/25.
//
import Foundation

public struct CardViewModel: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let imageUrl: URL?
    public let foilDescription: String?
    public let collectorNumberNumeric: Int
    public let foilImageUrl: URL?
    public let etchImageUrl: URL?

    public init(cardData: CardData) {
        self.id = cardData.id
        self.name = cardData.name
        self.imageUrl = URL(string: cardData.images?.tcgl.png?.front ?? "")
        self.collectorNumberNumeric = cardData.collectorNumber.numeric
        self.foilImageUrl = URL(string: cardData.images?.tcgl.png?.foil ?? "")
        self.etchImageUrl = URL(string: cardData.images?.tcgl.png?.etch ?? "")

        if let foil = cardData.foil {
            let foilType = foil.type.rawValue.replacingOccurrences(of: "_", with: " ").capitalized
            let foilMask = foil.mask.rawValue.replacingOccurrences(of: "_", with: " ").capitalized
            self.foilDescription = "\(foilType) (\(foilMask))"
        } else {
            self.foilDescription = FeatureExpansionStrings.noFoil
        }
    }
}


public enum CardDisplayMode: String, CaseIterable, Identifiable {
    case regular = "Regular Set"
    case master = "Master Set"

    public var id: String { rawValue }
}
