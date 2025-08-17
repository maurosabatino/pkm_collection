//
//  CardViewModel.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 27/07/25.
//
import Foundation

struct CardViewModel: Identifiable, Hashable {
    let id: String
    let name: String
    let imageUrl: URL?
    let foilDescription: String? // Stringa che accorpa tipo e maschera del foil
    let collectorNumberNumeric: Int // Aggiunto per l'ordinamento
    let foilImageUrl: URL? // Nuovo: URL dell'immagine foil
    let etchImageUrl: URL? // Nuovo: URL dell'immagine etch

    init(cardData: CardData) {
        self.id = cardData.id
        self.name = cardData.name
        self.imageUrl = URL(string: cardData.images?.tcgl.png?.front ?? "")
        self.collectorNumberNumeric = cardData.collectorNumber.numeric // Inizializza
        self.foilImageUrl = URL(string: cardData.images?.tcgl.png?.foil ?? "") // Inizializza foilImageUrl
        self.etchImageUrl = URL(string: cardData.images?.tcgl.png?.etch ?? "") // Inizializza etchImageUrl


        if let foil = cardData.foil {
            // Formatta la stringa del foil: es. "Flat Silver (Holo)"
            let foilType = foil.type.rawValue.replacingOccurrences(of: "_", with: " ").capitalized
            let foilMask = foil.mask.rawValue.replacingOccurrences(of: "_", with: " ").capitalized
            self.foilDescription = "\(foilType) (\(foilMask))"
        } else {
            self.foilDescription = AppStrings.noFoil // "No Foil" se non presente
        }
    }
}


enum CardDisplayMode: String, CaseIterable, Identifiable {
    case regular = "Regular Set" // Mostra una singola versione per ogni carta (es. non-foil preferita)
    case master = "Master Set" // Mostra tutte le varianti (incluse le foil)

    var id: String { self.rawValue }
}
