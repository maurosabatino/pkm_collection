import Foundation

protocol FetchExpansionUseCase {
    func execute() async throws -> [Expansion]
}

struct FetchExpansionUseCaseImpl: FetchExpansionUseCase {
    private let repository: ExpansionRepository

    init(repository: ExpansionRepository = DefaultExpansionRepository(fileName: "set-it-IT")) {
        self.repository = repository
    }

    func execute() async throws -> [Expansion] {
        try await repository.fetchExpansions()
    }
}
