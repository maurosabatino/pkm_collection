import Foundation

/// Gestisce il ciclo push/pull tra DB locale e backend.
public final class SyncCoordinator {
    private let database: LocalDatabase
    private let remote: RemoteAPI

    public init(database: LocalDatabase, remote: RemoteAPI) {
        self.database = database
        self.remote = remote
    }

    public func sync(resource: String) async throws {
        // Push
        let pending = try database.pendingMutations()
        let pushCursor = try await remote.pushMutations(pending)
        try database.markMutationsAsSynced(pending)

        var state = try database.loadSyncState(for: resource)
        state.lastCursor = pushCursor ?? state.lastCursor
        state.lastPulledAt = Date()
        try database.saveSyncState(state)

        // Pull
        let pull = try await remote.pullMutations(cursor: state.lastCursor)
        try database.saveMutations(pull.mutations)

        state.lastCursor = pull.cursor ?? state.lastCursor
        state.lastPulledAt = Date()
        try database.saveSyncState(state)
    }
}
