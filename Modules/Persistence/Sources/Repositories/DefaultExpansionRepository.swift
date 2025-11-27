import Foundation
import CoreModels

public struct DefaultExpansionRepository: ExpansionRepository {
    public init() {}

    public func fetchExpansions(language: String) async throws -> [Expansion] {
        let fileName = "set-\(language)"
        let subdir = "db/\(language)"
        guard let url = ResourceLocator.url(forResource: fileName, withExtension: "json", subdirectory: subdir) else {
            throw NSError(domain: "expansion-json-missing", code: -1, userInfo: ["fileName": fileName, "lang": language])
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)
            if let date = Self.dateFormatter.date(from: raw) {
                return date
            }
            if let iso = ISO8601DateFormatter().date(from: raw) {
                return iso
            }
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date format: \(raw)"
            )
        }
        return try decoder.decode([Expansion].self, from: data)
    }
}

private extension DefaultExpansionRepository {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
