import Foundation
import CoreKit

protocol CardListRepository {
    func fetchCardList(path: String) async throws -> [CardData]
}

struct DefaultCardListRepository: CardListRepository {
    func fetchCardList(path: String) async throws -> [CardData] {
        guard let url = Bundle.main.url(forResource: path, withExtension: "json") else {
            throw DomainError.dataNotFound(message: FeatureExpansionStrings.cardsJsonFileNotFound(path))
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([CardData].self, from: data)
        } catch let decodingError as DecodingError {
            throw DomainError.decodingError(decodingError)
        } catch {
            throw DomainError.unknownError
        }
    }
}
