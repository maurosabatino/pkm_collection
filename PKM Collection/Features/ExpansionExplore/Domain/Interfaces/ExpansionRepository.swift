

import Foundation

protocol ExpansionRepository {
    /// Fetches the main expansion data from the data source.
    /// - Returns: An Expansion entity.
    /// - Throws: A DomainError if the operation fails.
    func fetchExpansions() async throws -> [Expansion]
}
