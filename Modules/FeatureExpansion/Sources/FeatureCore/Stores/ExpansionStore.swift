import SwiftUI
import Combine
import CoreKit
import CoreModels
import Persistence

@MainActor
public final class ExpansionStore: ObservableObject {
    @Published public var expansions: [Expansion] = []
    @Published public var searchText = ""
    private let languageSettings: LanguageSettings
    private var cancellables: Set<AnyCancellable> = []

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

    public init(
        fetchExpansionUseCase: FetchExpansionUseCase = FetchExpansionUseCaseImpl(),
        languageSettings: LanguageSettings = .shared
    ) {
        self.fetchExpansionUseCase = fetchExpansionUseCase
        self.languageSettings = languageSettings
        subscribeToLanguageChanges()
        Task { await load() }
    }

    public func load() async {
        do {
            let language = languageSettings.language.rawValue
            expansions = try await fetchExpansionUseCase.execute(language: language)
        } catch {
            print(FeatureExpansionStrings.errorLoadingExpansions(error.localizedDescription))
        }
    }

    private func subscribeToLanguageChanges() {
        languageSettings.$language
            .removeDuplicates()
            .sink { [weak self] _ in
                Task { await self?.load() }
            }
            .store(in: &cancellables)
    }
}
