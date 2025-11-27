import CoreModels

public protocol OwnedCardsPersistence {
    func load() throws -> [OwnedCard]
    func save(_ cards: [OwnedCard]) throws
}

public protocol CardListRepository {
    func fetchCardList(path: String, language: String) async throws -> [CardData]
}

public protocol ExpansionRepository {
    func fetchExpansions(language: String) async throws -> [Expansion]
}
