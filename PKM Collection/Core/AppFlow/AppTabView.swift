//
//  AppTabView.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 26/07/25.
//


import SwiftUI

struct AppTabView: View {
    @Binding var selection: AppScreen?
    @EnvironmentObject var expansionStore: ExpansionStore

    var body: some View {
        TabView(selection: $selection) {
            ForEach(AppScreen.allCases) { screen in
                // Ogni tab presenta la sua destinazione, che ora include la NavigationStack interna
                screen.destination
                    .tag(screen as AppScreen?)
                    .tabItem { screen.label }
            }
        }
    }
}

#Preview {
    AppTabView(selection: .constant(.expansion))
}
