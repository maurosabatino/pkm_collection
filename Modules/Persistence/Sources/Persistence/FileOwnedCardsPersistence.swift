import Foundation
import CoreModels

public final class FileOwnedCardsPersistence: OwnedCardsPersistence {
    private let fileURL: URL

    public init(fileURL: URL? = nil) {
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory
            self.fileURL = directory.appendingPathComponent("owned_cards.json")
        }
    }

    public func load() throws -> [OwnedCard] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        return (try? JSONDecoder().decode([OwnedCard].self, from: data)) ?? []
    }

    public func save(_ cards: [OwnedCard]) throws {
        let data = try JSONEncoder().encode(cards)
        try data.write(to: fileURL)
    }
}
