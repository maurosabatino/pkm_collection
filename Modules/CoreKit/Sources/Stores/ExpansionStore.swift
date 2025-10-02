//
//  ExpansionModel.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 11/07/25.
//

import SwiftUI
import Combine

@MainActor
final class ExpansionStore: ObservableObject {
    @Published var expansions: [Expansion] = []
    @Published var searchText = ""

    // Computed property per raggruppare e filtrare le espansioni.
    var groupedAndFilteredExpansions: [String: [Expansion]] {
        let filteredExpansions = expansions.filter { expansion in
            searchText.isEmpty ||
            expansion.name.localizedCaseInsensitiveContains(searchText) ||
            expansion.series.localizedCaseInsensitiveContains(searchText) ||
            expansion.abbr.localizedCaseInsensitiveContains(searchText)
        }
        // Raggruppa le espansioni filtrate per serie.
        return Dictionary(grouping: filteredExpansions, by: { $0.series })
    }

    // Computed property per ottenere le chiavi delle serie ordinate alfabeticamente.
    var sortedSeriesKeys: [String] {
        groupedAndFilteredExpansions.keys.sorted()
    }
    
    private let fetchExpansionUseCase: FetchExpansionUseCase

    init(fetchExpansionUseCase: FetchExpansionUseCase = FetchExpansionUseCaseImpl()) {
        self.fetchExpansionUseCase = fetchExpansionUseCase
        Task {
            await load()
        }
    }
    

    func load() async {
        do {
            expansions = try await fetchExpansionUseCase.execute()

        } catch {
            print(
                "Errore durante il caricamento delle espansioni: \(error.localizedDescription)"
            )
        }
        
    }
}
