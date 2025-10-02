import Foundation

public protocol OwnedCardsPersistence {
    func load() throws -> [OwnedCard]
    func save(_ cards: [OwnedCard]) throws
}

public final class FileOwnedCardsPersistence: OwnedCardsPersistence {
    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let fileManager: FileManager

    public init(fileManager: FileManager = .default, directoryName: String = "OwnedCards") {
        self.fileManager = fileManager
        let baseURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory
        let directoryURL = baseURL.appendingPathComponent(directoryName, isDirectory: true)

        if !fileManager.fileExists(atPath: directoryURL.path) {
            try? fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }

        self.fileURL = directoryURL.appendingPathComponent("owned_cards.json", isDirectory: false)
        self.encoder = JSONEncoder()
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder.dateEncodingStrategy = .iso8601
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    public func load() throws -> [OwnedCard] {
        guard fileManager.fileExists(atPath: fileURL.path) else { return [] }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode([OwnedCard].self, from: data)
    }

    public func save(_ cards: [OwnedCard]) throws {
        let data = try encoder.encode(cards)
        try data.write(to: fileURL, options: [.atomic])
    }
}
