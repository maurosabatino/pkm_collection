import Foundation
import CoreModels
import Persistence

public protocol ExpansionRepository {
    func fetchExpansions(language: String) async throws -> [Expansion]
}

public struct ExpansionRepositoryAdapter: ExpansionRepository {
    private let repository: Persistence.ExpansionRepository

    public init(repository: Persistence.ExpansionRepository = DatabaseExpansionRepository()) {
        self.repository = repository
    }

    public func fetchExpansions(language: String) async throws -> [Expansion] {
        try await repository.fetchExpansions(language: language)
    }
}
