//
//  AppStrings.swift
//  PKM Collection
//
//  Created by SABATINO MAURO on 27/07/25.
//

enum AppStrings {
    // Titoli e etichette generali
    static let appTitle = "Pokémon Collection"
    static let expansionsTitle = "Pokémon Expansions"
    static let expansionsTabLabel = "Expansions"
    static let selectExpansionPlaceholder = "Select an expansion"
    static let pickSomethingFromList = "Pick something from the list."
    static let detailTitle = "Detail"
    static let loadingCards = "Caricamento carte..."
    static let noCardsFound = "Nessuna carta trovata"
    static let checkJsonOrLogic = "Controlla il file JSON o la logica di caricamento."
    static let expansionDetailsPrefix = "Dettagli Espansione: "
    static let errorLoadingCardsPrefix = "Errore nel caricamento delle carte: "

    // Etichette delle espansioni
    static let seriesPrefix = "Series: "
    static let releaseDatePrefix = "Release Date: "
    static let cardsPrefix = "Cards: "
    static let searchPlaceholder = "Search Expansions" // Nuova stringa per la barra di ricerca


    // Messaggi di errore di dominio (generalizzati per non ripetere)
    static let errorPrefix = "Error: "
    static let decodingErrorPrefix = "Decoding error: "
    static let unknownError = "Unknown error."
    static func jsonFileNotFound(fileName: String) -> String { return "JSON file '\(fileName).json' not found in bundle." }
    static func cardsJsonFileNotFound(fileName: String) -> String { return "JSON file '\(fileName).json' for cards not found in bundle." }
    static func errorLoadingExpansions(error: String) -> String { return "Error loading expansions: \(error)" }
    static func errorLoadingCards(expansionPath: String, error: String) -> String { return "Error loading cards for \(expansionPath): \(error)" }

    // Dati di esempio per le preview (non stringhe da localizzare in produzione)
    static let sampleExpansionName1 = "Spada e Scudo"
    static let sampleExpansionSeries1 = "Sword & Shield"
    static let sampleExpansionName2 = "Sole e Luna"
    static let sampleExpansionSeries2 = "Sole e Luna"
    static let sampleExpansionName3 = "XY"
    static let sampleExpansionSeries3 = "XY"
}
