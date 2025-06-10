//
//  ExpansionDetailViewModel.swift
//  PKM Collection
//
//  Created by Mauro on 03/06/25.
//

import SwiftUI

@MainActor
final class ExpansionDetailViewModel: ObservableObject {
    @Published var cards: [CardData] = []

    @Published var isLoading = false
    @Published var error: String?
    
    

    func load(setInfo: SetInfo) async {
        isLoading = true
        do {
            cards = try await APIClient.shared.fetchSetData(setInfo)
        } catch {
            print(error.localizedDescription)
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
