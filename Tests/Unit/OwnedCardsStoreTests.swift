import XCTest
@testable import PKMCollection

final class OwnedCardsStoreTests: XCTestCase {
    private final class InMemoryPersistence: OwnedCardsPersistence {
        var storage: [OwnedCard] = []

        func load() throws -> [OwnedCard] { storage }
        func save(_ cards: [OwnedCard]) throws { storage = cards }
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
}
