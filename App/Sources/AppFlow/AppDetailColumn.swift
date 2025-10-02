//
//  AppDetailColumn.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 26/07/25.
//

import SwiftUI

struct AppDetailColumn: View {
    var screen: AppScreen?
    // Riceve il NavigationPath come binding
    @Binding var navigationPath: NavigationPath
    @EnvironmentObject var expansionStore: ExpansionStore

    var body: some View {
        Group {
            if let screen = screen {
                // La NavigationStack è ora interna a ExpansionsNavigationStack,
                // quindi qui si presenta solo la destinazione.
                // Se questa colonna deve avere una NavigationStack propria per gestire
                // una pila di navigazione indipendente per ogni elemento della sidebar,
                // allora la NavigationStack(path: $navigationPath) dovrebbe avvolgere screen.destination.
                // Per ora, assumiamo che ExpansionsNavigationStack gestisca la sua pila.
                screen.destination // Questo sarà ExpansionsNavigationStack()
            } else {
                ContentUnavailableView("Select an expansion", systemImage: "folder", description: Text("Pick something from the list."))
            }
        }
        #if os(macOS)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background()
        #endif
    }
}
