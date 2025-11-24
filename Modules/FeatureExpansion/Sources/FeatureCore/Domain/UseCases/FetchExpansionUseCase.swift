import Foundation
import CoreKit

protocol FetchExpansionUseCase {
    func execute() async throws -> [Expansion]
}

struct FetchExpansionUseCaseImpl: FetchExpansionUseCase {
    private let repository: ExpansionRepository

    init(repository: ExpansionRepository = DatabaseExpansionRepository()) {
        self.repository = repository
    }

    func execute() async throws -> [Expansion] {
        try await repository.fetchExpansions()
    }
}
