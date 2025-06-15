//
//  ExpansionsViewModel.swift
//  PKM Collection
//
//  Created by Mauro on 03/06/25.
//

import Foundation

@MainActor
final class ExpansionListViewModel: ObservableObject {
    
    @Published var expansions: [Expansion] = []
    @Published var selectedLanguage: Language = .itIT
    @Published var isLoading: Bool = false
    @Published var error: String?

    private let fetchExpansionUseCase: FetchExpansionUseCase

    init(fetchExpansionUseCase: FetchExpansionUseCase) {
        self.fetchExpansionUseCase = fetchExpansionUseCase
    }
    
    
    func load() async {
        isLoading = true
        do {
            expansions = try await fetchExpansionUseCase.execute()
    
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}

