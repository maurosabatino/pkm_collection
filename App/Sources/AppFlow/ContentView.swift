//
//  ContentView.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 26/07/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selection: AppScreen? = .expansion
    // Aggiungi un NavigationPath per gestire la navigazione nella colonna di dettaglio
    @State private var detailNavigationPath = NavigationPath()

    @Environment(\.prefersTabNavigation) private var prefersTabNavigation

    // Accedi a ExpansionStore come EnvironmentObject
    @EnvironmentObject var expansionStore: ExpansionStore

    var body: some View {
        if prefersTabNavigation {
            AppTabView(selection: $selection)
        } else {
            NavigationSplitView {
                AppSidebarList(selection: $selection)
            } detail: {
                // Passa il binding al NavigationPath alla colonna di dettaglio
                AppDetailColumn(screen: selection, navigationPath: $detailNavigationPath)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ExpansionStore())
}
