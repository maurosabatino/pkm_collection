import XCTest
@testable import PKMCollection
@testable import CoreKit

final class OwnedCardsStoreTests: XCTestCase {
    private final class InMemoryPersistence: OwnedCardsPersistence {
        var storage: [OwnedCard] = []
        var shouldThrowOnLoad = false
        var saveCallCount = 0

        func load() throws -> [OwnedCard] {
            if shouldThrowOnLoad { throw NSError(domain: "test", code: -1) }
            return storage
        }

        func save(_ cards: [OwnedCard]) throws {
            storage = cards
            saveCallCount += 1
        }
    }

    func testToggleOwnershipAddsAndRemovesCard() async {
        let persistence = InMemoryPersistence()
        let store = await MainActor.run { OwnedCardsStore(persistence: persistence) }

        await MainActor.run { store.toggleOwnership(for: "card-1") }
        let added = await MainActor.run { store.isOwned(cardId: "card-1") }
        XCTAssertTrue(added)

        await MainActor.run { store.toggleOwnership(for: "card-1") }
        let removed = await MainActor.run { store.isOwned(cardId: "card-1") }
        XCTAssertFalse(removed)
    }

    func testIncrementUpdatesQuantity() async {
        let persistence = InMemoryPersistence()
        let store = await MainActor.run { OwnedCardsStore(persistence: persistence) }

        await MainActor.run { store.increment(cardId: "card-2") }
        await MainActor.run { store.increment(cardId: "card-2") }

        let quantityAfterIncrement = await MainActor.run { store.quantity(for: "card-2") }
        XCTAssertEqual(quantityAfterIncrement, 2)

        await MainActor.run { store.increment(cardId: "card-2", step: -1) }
        let quantityAfterDecrement = await MainActor.run { store.quantity(for: "card-2") }
        XCTAssertEqual(quantityAfterDecrement, 1)

        await MainActor.run { store.increment(cardId: "card-2", step: -1) }
        let isOwned = await MainActor.run { store.isOwned(cardId: "card-2") }
        XCTAssertFalse(isOwned)
    }

    func testUpdateNotesPersistsAndUpdatesTimestamp() async {
        let persistence = InMemoryPersistence()
        let pastDate = Date(timeIntervalSince1970: 1)
        persistence.storage = [OwnedCard(cardId: "card-3", quantity: 2, notes: nil, lastUpdated: pastDate)]

        let store = await MainActor.run { OwnedCardsStore(persistence: persistence) }
        await MainActor.run { store.updateNotes(for: "card-3", notes: "Keep sealed") }

        let storedCard = persistence.storage.first { $0.cardId == "card-3" }
        XCTAssertEqual(storedCard?.notes, "Keep sealed")
        XCTAssertNotEqual(storedCard?.lastUpdated, pastDate)
        XCTAssertEqual(persistence.saveCallCount, 1)
    }

    func testLoadErrorResetsOwnedCards() async {
        let persistence = InMemoryPersistence()
        persistence.shouldThrowOnLoad = true
        persistence.storage = [OwnedCard(cardId: "card-4")]

        let store = await MainActor.run { OwnedCardsStore(persistence: persistence) }
        let isOwned = await MainActor.run { store.isOwned(cardId: "card-4") }

        XCTAssertFalse(isOwned)
    }
}
