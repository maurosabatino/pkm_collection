//
//  ExpansionsViewModel.swift
//  PKM Collection
//
//  Created by Mauro on 03/06/25.
//

import Foundation

@MainActor
final class ExpansionsViewModel: ObservableObject {
    
    @Published var expansions: [SetInfo] = []
    @Published var selectedLanguage: Language = .itIT
    @Published var isLoading = false
    @Published var error: String?

    func load() async {
        isLoading = true
        do {
            let expansion = try await APIClient.shared.fetchExpansionData()
            expansions = expansion.sets(for: selectedLanguage).sorted { $0.name < $1.name }
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}

