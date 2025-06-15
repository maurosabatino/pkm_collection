import Foundation

protocol FetchExpansionUseCase {
    func execute() async throws -> [Expansion]
}

final class FetchExpansionUseCaseImpl: FetchExpansionUseCase {
    private let reposiroty: ExpansionRepository
    
    init(reposiroty: ExpansionRepository) {
        self.reposiroty = reposiroty
    }
    
    func execute() async throws -> [Expansion] {
        do {
            let expansios: [Expansion] = try await reposiroty.fetchExpansions()
            return expansios
        } catch {
            throw error
        }
    }
}
