import Foundation
import CoreModels
import Persistence

public protocol CardListRepository {
    func fetchCardList(path: String, language: String) async throws -> [CardData]
}

public struct CardListRepositoryAdapter: CardListRepository {
    private let repository: Persistence.CardListRepository

    public init(repository: Persistence.CardListRepository = DatabaseCardListRepository()) {
        self.repository = repository
    }

    public func fetchCardList(path: String, language: String) async throws -> [CardData] {
        try await repository.fetchCardList(path: path, language: language)
    }
}
