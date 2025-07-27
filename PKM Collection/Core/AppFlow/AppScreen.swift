//
//  AppScreen.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 26/07/25.
//

import SwiftUI

enum AppScreen: Codable, Hashable, Identifiable, CaseIterable {
    case expansion

    var id: AppScreen { self }
}

extension AppScreen {
    @ViewBuilder
    var label: some View {
        switch self {
        case .expansion:
            Label("Expansions", systemImage: "folder")
        }
    }
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .expansion:
            ExpansionsNavigationStack()
        }
    }
}
