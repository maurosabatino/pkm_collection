//
//  ExpansionsViewModel.swift
//  PKM Collection
//
//  Created by Mauro on 03/06/25.
//

import Foundation

@MainActor
final class ExpansionListViewModel: ObservableObject {
    @Published var allExpansions: [Expansion] = []
    @Published var expansions: [Expansion] = []
    @Published var selectedLanguage: Language = .itIT
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    @Published var searchText: String = "" {
            didSet {
                applyFiltersAndSort() // Apply filters whenever search text changes
            }
        }
    @Published var selectedFilter: String? = nil // e.g., "Completed", "Incomplete"
    @Published var sortBy: SortOption = .releaseDate // Default sort option

    private let fetchExpansionUseCase: FetchExpansionUseCase = FetchExpansionUseCaseImpl()

    func load() async {
        isLoading = true
        do {
            expansions = try await fetchExpansionUseCase.execute()
    
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
    
    func applyFiltersAndSort() {
            var filteredExpansions = allExpansions

            // Apply Search Filter
            if !searchText.isEmpty {
                filteredExpansions = filteredExpansions.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
            }

            // Apply other filters (e.g., "Completed", "Incomplete")
//            if let filter = selectedFilter {
//                if filter == "Completato" {
//                    filteredExpansions = filteredExpansions.filter { $0.completionPercentage == 1.0 }
//                } else if filter == "Incompleto" {
//                    filteredExpansions = filteredExpansions.filter { $0.completionPercentage < 1.0 }
//                }
//            }

            // Apply Sorting
            switch sortBy {
            case .releaseDate:
                filteredExpansions.sort { $0.releaseDate > $1.releaseDate }
            case .cardCount:
                filteredExpansions.sort { $0.num.regular > $1.num.regular }
//            case .completionPercentage:
//                filteredExpansions.sort { $0.completionPercentage ?? 0.0 > $1.completionPercentage ?? 0.0 }
            }

            self.expansions = filteredExpansions
        }
    
}

extension ExpansionListViewModel {
    enum SortOption: String, CaseIterable, Identifiable {
          case releaseDate = "Data Uscita"
          case cardCount = "Num. Carte"
//          case completionPercentage = "Completamento"

          var id: String { self.rawValue }
      }
}

