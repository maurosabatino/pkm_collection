import SwiftUI
import CoreKit

@MainActor
final class ExpansionStore: ObservableObject {
    @Published var expansions: [Expansion] = []
    @Published var searchText = ""

    var groupedAndFilteredExpansions: [String: [Expansion]] {
        let filteredExpansions = expansions.filter { expansion in
            searchText.isEmpty ||
            expansion.name.localizedCaseInsensitiveContains(searchText) ||
            expansion.series.localizedCaseInsensitiveContains(searchText) ||
            expansion.abbr.localizedCaseInsensitiveContains(searchText)
        }
        return Dictionary(grouping: filteredExpansions, by: { $0.series })
    }

    var sortedSeriesKeys: [String] {
        groupedAndFilteredExpansions.keys.sorted()
    }

    private let fetchExpansionUseCase: FetchExpansionUseCase

    init(fetchExpansionUseCase: FetchExpansionUseCase = FetchExpansionUseCaseImpl()) {
        self.fetchExpansionUseCase = fetchExpansionUseCase
        Task { await load() }
    }

    func load() async {
        do {
            expansions = try await fetchExpansionUseCase.execute()
        } catch {
            print(FeatureExpansionStrings.errorLoadingExpansions(error.localizedDescription))
        }
    }
}
