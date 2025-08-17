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
    static let searchPlaceholder = "Search Expansions"
    static let searchCardsPlaceholder = "Search Cards" // Nuova stringa per la barra di ricerca delle carte

    // Dettagli delle carte
    static let cardNamePlaceholder = "Card Name" // Placeholder per il nome della carta
    static let noFoil = "No Foil" // Stringa per indicare l'assenza di foil
    static let displayModeLabel = "Display Mode" // Nuova stringa per il picker
    static let regularSetMode = "Regular Set" // Stringa per la modalità Regular Set
    static let masterSetMode = "Master Set" // Stringa per la modalità Master Set

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
    static let sampleExpansionName4 = "Evoluzioni a Paldea"
    static let sampleExpansionSeries4 = "Scarlatto e Violetto"
    static let sampleExpansionName5 = "Destino di Paldea"
    static let sampleExpansionSeries5 = "Scarlatto e Violetto"
    static let sampleExpansionName6 = "Zenit Regale"
    static let sampleExpansionSeries6 = "Spada e Scudo"
    static let sampleCardName1 = "Pikachu"
    static let sampleCardName2 = "Charizard"
    static let sampleCardName3 = "Mewtwo"
}
