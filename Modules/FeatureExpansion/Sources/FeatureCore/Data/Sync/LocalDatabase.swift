import Foundation

public protocol LocalDatabase {
    func saveMutations(_ mutations: [SyncMutation<Data>]) throws
    func pendingMutations() throws -> [SyncMutation<Data>]
    func markMutationsAsSynced(_ mutations: [SyncMutation<Data>]) throws
    func loadSyncState(for resource: String) throws -> SyncState
    func saveSyncState(_ state: SyncState) throws
}

/// Stub in-memory per lavorare offline con il coordinatore.
public final class InMemoryDatabase: LocalDatabase {
    private var pending: [SyncMutation<Data>] = []
    public private(set) var applied: [SyncMutation<Data>] = []
    private var syncStates: [String: SyncState] = [:]

    public init() {}

    public func enqueuePending(_ mutations: [SyncMutation<Data>]) {
        pending.append(contentsOf: mutations)
    }

    public func saveMutations(_ mutations: [SyncMutation<Data>]) throws {
        applied.append(contentsOf: mutations)
    }

    public func pendingMutations() throws -> [SyncMutation<Data>] {
        pending
    }

    public func markMutationsAsSynced(_ mutations: [SyncMutation<Data>]) throws {
        let ids = Set(mutations.map { $0.updatedAt.timeIntervalSince1970 })
        pending.removeAll { ids.contains($0.updatedAt.timeIntervalSince1970) }
    }

    public func loadSyncState(for resource: String) throws -> SyncState {
        syncStates[resource] ?? SyncState(resource: resource)
    }

    public func saveSyncState(_ state: SyncState) throws {
        syncStates[state.resource] = state
    }
}
