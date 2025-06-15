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
    
    private let fetchCardListUseCase: FetchCardListUseCase
    private let expansion: Expansion
    
    init(
        fetchCardListUseCase: FetchCardListUseCase,
        expansion: Expansion
    ) {
        self.fetchCardListUseCase = fetchCardListUseCase
        self.expansion = expansion
    }

    func load() async {
        isLoading = true
        do {
            cards = try await fetchCardListUseCase.execute(path: expansion.path)
        } catch {
            print(error.localizedDescription)
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}
