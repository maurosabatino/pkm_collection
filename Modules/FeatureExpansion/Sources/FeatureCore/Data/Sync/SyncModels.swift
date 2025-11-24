import Foundation

public enum SyncOperation: String, Codable {
    case insert, update, delete
}

public struct SyncMutation<Record: Codable>: Codable {
    public let table: String
    public let operation: SyncOperation
    public let record: Record
    public let updatedAt: Date
}

public struct SyncEnvelope<Record: Codable>: Codable {
    public let cursor: String?
    public let mutations: [SyncMutation<Record>]
}

public struct SyncState {
    public var resource: String
    public var lastCursor: String?
    public var lastPulledAt: Date?
    public init(resource: String, lastCursor: String? = nil, lastPulledAt: Date? = nil) {
        self.resource = resource
        self.lastCursor = lastCursor
        self.lastPulledAt = lastPulledAt
    }
}
