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
        NavigationStack {
            ExpansionListView()
                .navigationDestination(for: Expansion.self) { expansion in
                    ExpansionDetailView(expansion: expansion)
                }
        }
    }
}
