//
//  PKM_CollectionApp.swift
//  PKM Collection
//
//  Created by Mauro on 03/06/25.
//

import SwiftUI

@main
struct PKMCollectionApp: App {
    
    private static let appContainer = AppContainer()
    
    
    var body: some Scene {
        WindowGroup {
            ExpansionListView()
                .environmentObject(Self.appContainer.makeExpansionListViewModel())
        }
    }
}
