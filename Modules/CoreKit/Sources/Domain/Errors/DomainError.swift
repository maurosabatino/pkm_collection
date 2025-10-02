//
//  DomainError.swift
//  PKM Collection
//
//  Created by Mauro on 15/06/25.
//

import Foundation

enum DomainError: Error {
    /// Errore generico di rete, spesso mappato da un `URLError`.
    case networkError(Error)
    
    /// Errore durante la decodifica dei dati (es. JSON malformato, tipo non corrispondente).
    case decodingError(Error)
    
    /// Errore ricevuto da un server (es. codice di stato HTTP 4xx, 5xx).
    case serverError(statusCode: Int, message: String?)
    
    /// Errore causato da un URL non valido o impossibile da costruire.
    case badURL
    
    /// Errore generico o inatteso non coperto da altri casi.
    case unknownError
    
    /// Errore dovuto a input non validi forniti a un caso d'uso o a un servizio.
    case invalidInput
    
    /// Errore quando i dati richiesti non vengono trovati nella sorgente (locale o remota).
    /// Utile per indicare che una risorsa specifica non esiste.
    case dataNotFound(message: String)
    
    /// Errore relativo a operazioni di persistenza (es. Core Data, Realm, FileManager).
    case persistenceError(Error)
}
