import XCTest
@testable import Persistence

final class PersistenceTests: XCTestCase {
    func testDefaultExpansionRepositoryLoadsFile() async throws {
        let repository = DefaultExpansionRepository()
        let expansions = try await repository.fetchExpansions(language: "it-IT")

        XCTAssertFalse(expansions.isEmpty)
    }

    func testDefaultCardListRepositoryLoadsFile() async throws {
        let repository = DefaultCardListRepository()
        let cards = try await repository.fetchCardList(path: "sv1", language: "it-IT")

        XCTAssertFalse(cards.isEmpty)
    }
}
