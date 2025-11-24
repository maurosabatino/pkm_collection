import Foundation

public protocol RemoteAPI {
    func pullMutations(cursor: String?) async throws -> SyncEnvelope<Data>
    func pushMutations(_ mutations: [SyncMutation<Data>]) async throws -> String?
}

/// Stub API in-memory per sviluppare il coordinatore senza backend.
public final class StubRemoteAPI: RemoteAPI {
    private struct Stored {
        let cursorIndex: Int
        let mutation: SyncMutation<Data>
    }

    private var storage: [Stored] = []
    private var cursorCounter: Int = 0

    public init() {}

    public func pullMutations(cursor: String?) async throws -> SyncEnvelope<Data> {
        let lastSeen = Self.cursorIndex(from: cursor)
        let mutations = storage.filter { $0.cursorIndex > lastSeen }.map(\.mutation)
        let nextCursor = "cursor-\(cursorCounter)"
        return SyncEnvelope(cursor: nextCursor, mutations: mutations)
    }

    public func pushMutations(_ mutations: [SyncMutation<Data>]) async throws -> String? {
        for mutation in mutations {
            storage.append(Stored(cursorIndex: cursorCounter + 1, mutation: mutation))
            cursorCounter += 1
        }
        return "cursor-\(cursorCounter)"
    }

    private static func cursorIndex(from cursor: String?) -> Int {
        guard let cursor, let value = Int(cursor.replacingOccurrences(of: "cursor-", with: "")) else { return 0 }
        return value
    }
}
