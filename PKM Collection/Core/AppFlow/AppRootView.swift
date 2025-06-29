//
//  AppRootView.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 22/06/25.
//

import SwiftUI

struct AppRootView: View {
    @State private var selectedTab: TabItem = .expansions // Stato per la TabBar (iOS)
    @State private var selectedSidebarItem: TabItem? = .expansions // Stato per la Sidebar (macOS)

    var body: some View {
        #if os(iOS)
        // --- Tab Bar per iOS ---
        TabView(selection: $selectedTab) {
            ForEach(TabItem.allCases) { tabItem in
                NavigationStack { // Ogni tab ha il suo NavigationStack
                    tabItem.view()
                }
                .tabItem {
                    Label(tabItem.rawValue, systemImage: tabItem.systemImage)
                }
                .tag(tabItem)
            }
        }
        #elseif os(macOS)
        // --- Sidebar (NavigationSplitView) per macOS ---
        // NavigationSplitView è il modo moderno per le sidebar su macOS (macOS 13+)
        NavigationSplitView {
            List(selection: $selectedSidebarItem) {
                ForEach(TabItem.allCases) { item in
                    NavigationLink(value: item) {
                        Label(item.rawValue, systemImage: item.systemImage)
                    }
                }
            }
            .navigationTitle("PKM Collection") // Titolo della sidebar
            // Imposta l'elemento di default selezionato nella sidebar
            .onAppear {
                if selectedSidebarItem == nil {
                    selectedSidebarItem = .expansions
                }
            }
        } detail: {
            if let selectedItem = selectedSidebarItem {
                selectedItem.view()
            } else {
                Text("Seleziona una categoria dalla sidebar.")
            }
        }
        #else
        // --- Fallback per altre piattaforme (es. watchOS, tvOS) ---
        Text("Piattaforma non supportata.")
        #endif
    }
}
