import XCTest
import FeatureExpansion
import CoreKit

final class SyncCoordinatorTests: XCTestCase {
    func test_syncPushesPendingAndUpdatesCursor() async throws {
        let localDB = InMemoryDatabase()
        let api = StubRemoteAPI()
        let coordinator = SyncCoordinator(database: localDB, remote: api)

        let owned = OwnedCard(cardId: "test", quantity: 2, notes: "note", lastUpdated: Date(), isWishlist: true)
        let record = try JSONEncoder().encode(owned)
        let mutation = SyncMutation(table: "ownership", operation: .insert, record: record, updatedAt: owned.lastUpdated)

        localDB.enqueuePending([mutation])

        try await coordinator.sync(resource: "ownership")

        XCTAssertTrue(try localDB.pendingMutations().isEmpty)
        let state = try localDB.loadSyncState(for: "ownership")
        XCTAssertNotNil(state.lastCursor)
    }
}
