import Foundation


protocol GenericAPIClientProtocol {
    func performRequest<T: Decodable>(endpoint: String) async throws -> T
}

final class APIClient: GenericAPIClientProtocol {
    
    static let shared = APIClient()
    private let basePath = "https://cdn.malie.io/file/malie-io/tcgl/export/"
    private let decoder: JSONDecoder
    
    /// Dipendenza iniettata: APIClient usa un'istanza che conforma a LoggerProtocol.
    private let logger: LoggerProtocol
    
    /// L'inizializzatore ora accetta un logger, con un valore di default per comodità.
    private init(logger: LoggerProtocol = Log.network) {
        self.decoder = JSONDecoder()
        self.logger = logger
        // self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    // MARK: - Public API Methods

    func fetchExpansionData() async throws -> Expansion {
        try await performRequest(endpoint: "index.json")
    }
    
    func fetchSetData(_ expansion: Expansion) async throws -> [CardData] {
        try await performRequest(endpoint: expansion.path)
    }
    
    // MARK: - Private Generic Request Handler

    internal func performRequest<T: Decodable>(endpoint: String) async throws -> T {
        guard let url = URL(string: basePath + endpoint) else {
            throw URLError(.badURL)
        }
        
        let request = URLRequest(url: url)
        
        logger.info("➡️ Inviando richiesta a \(endpoint)")
        logger.debug(formatRequestLog(request))
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            logger.info("⬅️ Ricevuta risposta da \(endpoint)")
            logger.debug(formatResponseLog(response: response, data: data))
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let error = URLError(.badServerResponse, userInfo: ["statusCode": statusCode])
                logger.error(error.localizedDescription)
                throw error
            }
            
            return try decoder.decode(T.self, from: data)
            
        } catch let decodingError as DecodingError {
            logger.error(formatDecodingError(decodingError, for: endpoint, dataType: T.self))
            throw decodingError
        } catch {
            logger.error(error.localizedDescription)
            throw error
        }
    }
    
    // MARK: - Log Formatting Helpers
    
    private func formatRequestLog(_ request: URLRequest) -> String {
        """
        [RICHIESTA]
          - URL: \(request.url?.absoluteString ?? "N/A")
          - Metodo: \(request.httpMethod ?? "N/A")
          - Header:
        \(request.allHTTPHeaderFields?.prettyPrinted ?? "    -")
          - Body:
        \(request.httpBody.toPrettyPrintedString)
        """
    }
    
    private func formatResponseLog(response: URLResponse?, data: Data?) -> String {
        guard let httpResponse = response as? HTTPURLResponse else {
            return "[RISPOSTA NON-HTTP]"
        }
        return """
        [RISPOSTA]
          - Status Code: \(httpResponse.statusCode)
          - URL: \(httpResponse.url?.absoluteString ?? "N/A")
          - Header:
        \(httpResponse.allHeaderFields.prettyPrinted)
          - Body:
        \(data.toPrettyPrintedString)
        """
    }

    private func formatDecodingError<T>(_ error: DecodingError, for endpoint: String, dataType: T.Type) -> String {
        let logMessage = """
        [ERRORE DI DECODIFICA]
          - Endpoint: \(endpoint)
          - Tipo Atteso: \(String(describing: dataType))
          - Errore: \(error.localizedDescription)
        
        """
        // Aggiungi dettagli specifici dell'errore...
        return logMessage
    }
}


// =================================================================
//  5. Helper Extensions.swift
// =================================================================
// Le stesse estensioni di prima, ora usate dai metodi di formattazione del log.

private extension Optional where Wrapped == Data {
    var toPrettyPrintedString: String {
        guard let data = self, !data.isEmpty else { return "    -" }
        guard let obj = try? JSONSerialization.jsonObject(with: data, options: []),
              let prettyData = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return String(data: data, encoding: .utf8) ?? "Dati non decodificabili"
        }
        return prettyString.split(separator: "\n").map { "    \($0)" }.joined(separator: "\n")
    }
}

private extension Dictionary where Key == AnyHashable, Value == Any {
    var prettyPrinted: String {
        guard !self.isEmpty else { return "    -" }
        return self.map { "    \($0.key): \($0.value)" }.joined(separator: "\n")
    }
}

// NEW EXTENSION for [String: String] to handle HTTP headers specifically
private extension Dictionary where Key == String, Value == String {
    var prettyPrinted: String {
        guard !self.isEmpty else { return "    -" }
        return self.map { "    \($0.key): \($0.value)" }.joined(separator: "\n")
    }
}
