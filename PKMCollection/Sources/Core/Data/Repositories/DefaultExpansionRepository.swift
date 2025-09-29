import Foundation


protocol ExpansionRepository {
    /// Fetches the main expansion data from the data source.
    /// - Returns: An Expansion entity.
    /// - Throws: A DomainError if the operation fails.
    func fetchExpansions() async throws -> [Expansion]
}


final class DefaultExpansionRepository: ExpansionRepository {
    private let fileName: String

    /// Inizializza la sorgente dati con il nome del file JSON nel bundle.
    /// - Parameter fileName: Il nome del file JSON (senza estensione), es. "expansions_db".
    init(fileName: String) {
        self.fileName = fileName
    }

    /// Implementazione per recuperare i dati delle espansioni dal file JSON locale.
    func fetchExpansions() async throws -> [Expansion] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            // Se il file non viene trovato, lancia un errore di dominio specifico.
            throw DomainError.dataNotFound(message: "File JSON '\(fileName).json' non trovato nel bundle.")
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd" 
                    
            dateFormatter.calendar = Calendar(identifier: .iso8601)
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            let expansions = try decoder.decode([Expansion].self, from: data)
            return expansions
        } catch let decodingError as DecodingError {
            // Mappa errori specifici di decodifica a un errore di dominio.
            throw DomainError.decodingError(decodingError)
        } catch {
            // Mappa qualsiasi altro errore a un errore di dominio generico.
            throw DomainError.unknownError
        }
    }
}
