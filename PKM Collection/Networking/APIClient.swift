//
//  APIClient.swift
//  PKM Collection
//
//  Created by Mauro on 03/06/25.
//

import Foundation

final class APIClient {
    static let shared = APIClient()
    
    let basePath = "https://cdn.malie.io/file/malie-io/tcgl/export/"

    func fetchExpansionData() async throws -> Expansion {
        let url = URL(string: "\(basePath)index.json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(Expansion.self, from: data)
    }
    
    func fetchSetData(_ set: SetInfo) async throws -> [CardData] {
        let url = URL(string: "\(basePath)\(set.path)")!
        
        let (data, response) = try await URLSession.shared.data(from: url)

           // Controlla la risposta HTTP (opzionale ma utile)
           if let httpResponse = response as? HTTPURLResponse {
               print("HTTP Status Code: \(httpResponse.statusCode)")
               if httpResponse.statusCode != 200 {
                   print("Server returned an error status code.")
                   // Potresti lanciare un errore qui, es. throw URLError(.badServerResponse)
               }
           }

           // Prova a stampare i dati come stringa per vedere cosa c'è dentro
           if let jsonString = String(data: data, encoding: .utf8) {
               print("Received JSON String:")
               print(jsonString.prefix(500)) // Stampa i primi 500 caratteri
           } else {
               print("Could not convert received data to UTF-8 string.")
           }

           let decoder = JSONDecoder()
//           decoder.keyDecodingStrategy = .convertFromSnakeCase // Assicurati di usare questa se le chiavi JSON sono snake_case

           do {
               return try decoder.decode([CardData].self, from: data) // Assicurati che sia [CardData].self
           } catch {
               print("Failed to decode JSON: \(error)")
               // Stampa un errore più dettagliato per il debug
               if let decodingError = error as? DecodingError {
                   switch decodingError {
                   case .typeMismatch(let type, let context):
                       print("Type Mismatch: Expected \(type), but found different type.")
                       print("Context: \(context.debugDescription)")
                       print("Coding Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                   case .valueNotFound(let type, let context):
                       print("Value Not Found: Expected type \(type) was not found.")
                       print("Context: \(context.debugDescription)")
                       print("Coding Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                   case .keyNotFound(let key, let context):
                       print("Key Not Found: Key '\(key.stringValue)' missing.")
                       print("Context: \(context.debugDescription)")
                       print("Coding Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                   case .dataCorrupted(let context):
                       print("Data Corrupted: JSON data is malformed.")
                       print("Context: \(context.debugDescription)")
                       print("Coding Path: \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
                   @unknown default:
                       print("Unknown Decoding Error: \(decodingError.localizedDescription)")
                   }
               }
               throw error // Rilancia l'errore per gestirlo nel ViewModel
           }
    }
}

