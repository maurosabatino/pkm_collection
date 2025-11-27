import Foundation
import CoreModels

protocol FetchCardListUseCase {
    func execute(path: String, language: String) async throws -> [CardData]
}

struct FetchCardListUseCaseImpl: FetchCardListUseCase {
    private let repository: CardListRepository

    init(repository: CardListRepository = CardListRepositoryAdapter()) {
        self.repository = repository
    }

    func execute(path: String, language: String) async throws -> [CardData] {
        try await repository.fetchCardList(path: path, language: language)
    }
}
