import XCTest
import CoreModels
@testable import Persistence

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

    func testWishlistToggleKeepsEntryWithoutQuantity() async {
        let persistence = InMemoryPersistence()
        let store = await MainActor.run { OwnedCardsStore(persistence: persistence) }

        await MainActor.run { store.toggleWishlist(for: "card-wish") }
        let isWish = await MainActor.run { store.isWishlist(cardId: "card-wish") }
        let isOwned = await MainActor.run { store.isOwned(cardId: "card-wish") }

        XCTAssertTrue(isWish)
        XCTAssertFalse(isOwned)

        await MainActor.run { store.toggleWishlist(for: "card-wish") }
        let existsAfter = await MainActor.run { store.isWishlist(cardId: "card-wish") }
        XCTAssertFalse(existsAfter)
    }

    func testAggregatesCounts() async {
        let persistence = InMemoryPersistence()
        let store = await MainActor.run { OwnedCardsStore(persistence: persistence) }

        await MainActor.run {
            store.increment(cardId: "owned-1")
            store.increment(cardId: "owned-dup", step: 2)
            store.toggleWishlist(for: "wish-1")
        }

        let ownedCount = await MainActor.run { store.ownedCount(for: ["owned-1", "owned-dup", "missing"]) }
        let duplicateCount = await MainActor.run { store.duplicateCount(for: ["owned-dup"]) }
        let wishlistCount = await MainActor.run { store.wishlistCount(for: ["wish-1", "owned-1"]) }

        XCTAssertEqual(ownedCount, 2)
        XCTAssertEqual(duplicateCount, 1)
        XCTAssertEqual(wishlistCount, 1)
    }
}
