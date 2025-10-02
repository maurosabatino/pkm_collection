//
//  CollectionItem.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 29/06/25.
//

import Foundation

// MARK: - CollectionItem
struct CollectionItem: Codable, Identifiable {
    let id: String
    let cardId: String
    let expansionId: String
    let quantity: Int
    let condition: CardCondition
    let isHolo: Bool
    let dateAdded: Date
    let notes: String?
    
    init(
        cardId: String,
        expansionId: String,
        quantity: Int = 1,
        condition: CardCondition = .nearMint,
        isHolo: Bool = false,
        notes: String? = nil
    ) {
        self.id = UUID().uuidString
        self.cardId = cardId
        self.expansionId = expansionId
        self.quantity = quantity
        self.condition = condition
        self.isHolo = isHolo
        self.dateAdded = Date()
        self.notes = notes
    }
}

// MARK: - CardCondition
enum CardCondition: String, CaseIterable, Codable {
    case mint = "Mint"
    case nearMint = "Near Mint"
    case lightlyPlayed = "Lightly Played"
    case moderatelyPlayed = "Moderately Played"
    case heavilyPlayed = "Heavily Played"
    case damaged = "Damaged"
    
    var localizedName: String {
        switch self {
        case .mint: return "Perfetta"
        case .nearMint: return "Quasi Perfetta"
        case .lightlyPlayed: return "Leggermente Giocata"
        case .moderatelyPlayed: return "Moderatamente Giocata"
        case .heavilyPlayed: return "Molto Giocata"
        case .damaged: return "Danneggiata"
        }
    }
    
    var color: String {
        switch self {
        case .mint, .nearMint: return "green"
        case .lightlyPlayed, .moderatelyPlayed: return "orange"
        case .heavilyPlayed, .damaged: return "red"
        }
    }
}

// MARK: - CollectionStats
struct CollectionStats {
    let totalCards: Int
    let totalValue: Double
    let completedSets: Int
    let totalSets: Int
    let recentAdditions: [CollectionItem]
    
    var completionPercentage: Double {
        guard totalSets > 0 else { return 0.0 }
        return Double(completedSets) / Double(totalSets)
    }
}

// MARK: - ExpansionProgress
struct ExpansionProgress: Identifiable {
    let id: String
    let expansion: Expansion
    let ownedCards: Int
    let totalCards: Int
    let completionPercentage: Double
    let missingCards: [CardData]
    
    init(expansion: Expansion, ownedCards: Int, totalCards: Int, missingCards: [CardData] = []) {
        self.id = expansion.id
        self.expansion = expansion
        self.ownedCards = ownedCards
        self.totalCards = totalCards
        self.completionPercentage = totalCards > 0 ? Double(ownedCards) / Double(totalCards) : 0.0
        self.missingCards = missingCards
    }
}
