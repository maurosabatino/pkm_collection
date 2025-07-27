//
//  ExpansionsNavigationStack.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 26/07/25.
//
import SwiftUI

struct ExpansionsNavigationStack: View {
    @EnvironmentObject var expansionStore: ExpansionStore

    var body: some View {
        // Questa è la NavigationStack specifica per la feature delle espansioni.
        NavigationStack {
            ExpansionListView()
                // Il navigationDestination per Expansion.self è qui,
                // perché è qui che inizia la navigazione specifica delle espansioni.
                .navigationDestination(for: Expansion.self) { expansion in
                    ExpansionDetailView(expansion: expansion)
                }
        }
    }
}
