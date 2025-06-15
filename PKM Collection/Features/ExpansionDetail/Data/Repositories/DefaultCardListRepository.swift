//
//  DefaultCardListRepository.swift
//  PKM Collection
//
//  Created by Mauro on 15/06/25.
//
import Foundation

final class DefaultCardListRepository: CardListRepository {
    
    
    func fetchCardList(path: String) async throws -> [CardData] {
        guard let url = Bundle.main.url(forResource: path, withExtension: "json") else {
            // Se il file non viene trovato, lancia un errore di dominio specifico.
            throw DomainError.dataNotFound(message: "File JSON '\(path).json' non trovato nel bundle.")
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let cardList = try decoder.decode([CardData].self, from: data)
            return cardList
        } catch let decodingError as DecodingError {
            // Mappa errori specifici di decodifica a un errore di dominio.
            throw DomainError.decodingError(decodingError)
        } catch {
            // Mappa qualsiasi altro errore a un errore di dominio generico.
            throw DomainError.unknownError
        }
    }
    
    
}
