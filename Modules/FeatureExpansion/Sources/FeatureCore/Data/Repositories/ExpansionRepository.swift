import Foundation
import CoreKit

protocol ExpansionRepository {
    func fetchExpansions() async throws -> [Expansion]
}

struct DefaultExpansionRepository: ExpansionRepository {
    private let fileName: String

    init(fileName: String) {
        self.fileName = fileName
    }

    func fetchExpansions() async throws -> [Expansion] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw DomainError.dataNotFound(message: FeatureExpansionStrings.jsonFileNotFound(fileName))
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            decoder.dateDecodingStrategy = .formatted(formatter)
            return try decoder.decode([Expansion].self, from: data)
        } catch let decodingError as DecodingError {
            throw DomainError.decodingError(decodingError)
        } catch {
            throw DomainError.unknownError
        }
    }
}
