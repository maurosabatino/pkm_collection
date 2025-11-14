import Foundation
import CoreKit

protocol FetchCardListUseCase {
    func execute(path: String) async throws -> [CardData]
}

struct FetchCardListUseCaseImpl: FetchCardListUseCase {
    private let repository: CardListRepository

    init(repository: CardListRepository = DefaultCardListRepository()) {
        self.repository = repository
    }

    func execute(path: String) async throws -> [CardData] {
        try await repository.fetchCardList(path: path)
    }
}
