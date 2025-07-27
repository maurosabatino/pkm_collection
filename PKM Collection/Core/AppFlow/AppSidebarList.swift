//
//  AppSidebarList.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 26/07/25.
//

import SwiftUI

struct AppSidebarList: View {
    @Binding var selection: AppScreen?
    @EnvironmentObject var expansionStore: ExpansionStore

    var body: some View {
        List(AppScreen.allCases, selection: $selection) { screen in
            NavigationLink(value: screen) {
                screen.label
            }
        }
        .navigationTitle("Pokémon Collection")
    }
}

#Preview {
    NavigationSplitView {
        AppSidebarList(selection: .constant(.expansion))
    } detail: {
        Text(verbatim: "Check out that sidebar!")
    }
}
