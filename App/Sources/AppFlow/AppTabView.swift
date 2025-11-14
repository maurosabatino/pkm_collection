//
//  AppTabView.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 26/07/25.
//


import SwiftUI
import CoreKit

struct AppTabView: View {
    let entries: [ModuleEntryDescriptor]
    @Binding var selection: ModuleEntryDescriptor?
    let navigator: ModuleNavigator

    var body: some View {
        TabView(selection: $selection) {
            ForEach(entries) { entry in
                entry.makeView(navigator: navigator)
                    .tag(entry as ModuleEntryDescriptor?)
                    .tabItem {
                        Label(entry.title, systemImage: entry.systemImage)
                    }
            }
        }
    }
}

#Preview {
    AppTabView(
        entries: AppModuleRegistry().entries,
        selection: .constant(nil),
        navigator: ModuleNavigator()
    )
}
