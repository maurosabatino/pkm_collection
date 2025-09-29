//
//  TabItem.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 22/06/25.
//

import SwiftUI

enum TabItem: String, CaseIterable, Identifiable {
    case expansions = "Espansioni"
    case myCollection = "La Mia Collezione"
    case settings = "Impostazioni"

    var id: String { self.rawValue }

    var systemImage: String {
        switch self {
        case .expansions: return "books.vertical.fill" // Icona per le espansioni
        case .myCollection: return "star.fill" // Icona per la collezione
        case .settings: return "gear" // Icona per le impostazioni
        }
    }
    
    // Una semplice view per ogni tab/sidebar item
    @ViewBuilder
    func view() -> some View {
        switch self {
        case .expansions:
            // La tua ExpansionListView aggiornata
            ExpansionListView()
        case .myCollection:
            Text("La Mia Collezione")
                .font(.largeTitle)
                .navigationTitle("La Mia Collezione") // Titolo per la pagina della collezione
        case .settings:
            Text("Impostazioni dell'App")
                .font(.largeTitle)
                .navigationTitle("Impostazioni") // Titolo per la pagina delle impostazioni
        }
    }
}
