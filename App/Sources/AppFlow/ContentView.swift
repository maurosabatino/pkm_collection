//
//  ContentView.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 26/07/25.
//

import SwiftUI
import CoreKit

struct ContentView: View {
    @EnvironmentObject private var moduleRegistry: AppModuleRegistry
    @Environment(\.prefersTabNavigation) private var prefersTabNavigation
    @State private var selection: ModuleEntryDescriptor?
    @State private var detailNavigationPath = NavigationPath()

    var body: some View {
        let entries = moduleRegistry.entries

        Group {
            if prefersTabNavigation {
                AppTabView(entries: entries, selection: $selection, navigator: moduleRegistry.navigator)
            } else {
                NavigationSplitView {
                    AppSidebarList(entries: entries, selection: $selection)
                        .navigationTitle(AppStrings.appTitle)
                } detail: {
                    AppDetailColumn(
                        selection: selection,
                        navigationPath: $detailNavigationPath,
                        navigator: moduleRegistry.navigator
                    )
                }
            }
        }
        .onAppear {
            if selection == nil {
                selection = entries.first
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppModuleRegistry())
        .environmentObject(ModuleNavigator())
}
