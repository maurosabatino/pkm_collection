import Foundation
import CoreModels

public protocol FetchExpansionUseCase {
    func execute(language: String) async throws -> [Expansion]
}

public struct FetchExpansionUseCaseImpl: FetchExpansionUseCase {
    private let repository: ExpansionRepository

    public init(repository: ExpansionRepository = ExpansionRepositoryAdapter()) {
        self.repository = repository
    }

    public func execute(language: String) async throws -> [Expansion] {
        try await repository.fetchExpansions(language: language)
    }
}
