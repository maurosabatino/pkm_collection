//
//  CardStore.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 27/07/25.
//
import SwiftUI
import Combine

@MainActor
class CardListStore: ObservableObject { 
    @Published var cards: [CardData] = []
    @Published var isLoading: Bool = false
    @Published var error: Error? = nil

    private let expansionPath: String
    private let fetchCardListUseCase: FetchCardListUseCase

    init(expansionPath: String, fetchCardListUseCase: FetchCardListUseCase = FetchCardListUseCaseImpl()) {
        self.expansionPath = expansionPath
        self.fetchCardListUseCase = fetchCardListUseCase
    }

    func loadCards() async {
        isLoading = true
        error = nil
        do {
            cards = try await fetchCardListUseCase.execute(path: expansionPath)
        } catch {
            self.error = error
            print("Errore durante il caricamento delle carte per \(expansionPath): \(error.localizedDescription)")
        }
        isLoading = false
    }
}
