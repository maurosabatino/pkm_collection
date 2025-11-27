# PKMCollection

PKMCollection è un'app iOS sviluppata in SwiftUI che permette di sfogliare ed esplorare le espansioni e le carte della serie Pokémon. Il progetto utilizza [Tuist](https://tuist.io) per generare la workspace Xcode e gestire le dipendenze Swift Package, incluse Kingfisher per il caricamento delle immagini e Firebase Analytics per la telemetria.

## Caratteristiche principali
- Navigazione tra espansioni, carte e informazioni di dettaglio.
- Store e repository per la gestione dei dati dell'app.
- Integrazione con Firebase Analytics per tracciare gli eventi.
- Utilizzo di Kingfisher per la cache e il download delle immagini.
- Tracking locale della collezione con persistenza offline delle carte possedute.
- Assets e stringhe localizzate organizzati in cartelle dedicate.

## Requisiti
- macOS 13 o superiore
- Xcode 15 o superiore
- [Tuist](https://docs.tuist.io/tutorial/get-started) `>= 4.79`
- Swift 5.9+

## Configurazione rapida
1. **Installa Tuist**
   ```bash
   curl -Ls https://install.tuist.io | bash
   ```
2. **Allinea le dipendenze Swift Package**
   ```bash
   tuist install
   ```
3. **Genera la workspace**
   ```bash
   tuist generate
   ```
4. **Apri il progetto**
   ```bash
   open PKMCollection.xcworkspace
   ```

## Configurazione Firebase
1. Crea un progetto su [Firebase Console](https://console.firebase.google.com).
2. Registra un'app iOS con `com.maurosabatino.pkmcollection` (o aggiorna il bundle identifier in `Project.swift`).
3. Scarica il file `GoogleService-Info.plist` e posizionalo in `App/Resources/`.
4. Verifica che `FirebaseApp.configure()` sia chiamato in `PKMCollection/Sources/PKMCollectionApp.swift`.

> ⚠️ Se modifichi il bundle identifier, ricorda di aggiornare anche il file Firebase di configurazione o impostare un nuovo `bundleId` nel manifest Tuist.

## Struttura del progetto
```
PKMCollection/
├─ App/
│  ├─ Sources/         # Entry point, flow e root views
│  └─ Resources/       # Assets, stringhe, GoogleService-Info.plist, cards.db (no JSON)
├─ Modules/
│  ├─ CoreKit/         # Domain, data layer, stores, utilities
│  ├─ FeatureExpansion/# Feature SwiftUI per esplorare le espansioni
│  ├─ FeatureCollection# Wishlist/collections
│  ├─ FeatureDecks/    # Deck builder/import
│  ├─ FeatureSettings/ # Impostazioni (selezione lingua dati)
│  └─ UIComponents/    # Componenti riutilizzabili
├─ Tests/
│  ├─ Unit/            # Unit test (OwnedCards, Store, UseCase)
│  └─ UITests/         # UI test end-to-end
├─ Project.swift       # Manifest Tuist
└─ Tuist/              # Dipendenze Swift Package e configurazioni Tuist
```

### Dati carte multi-lingua
- Le sorgenti JSON delle carte/espansioni sono tenute fuori dal bundle in `Scripts/db_sources/<lang>`.
- Lo script `Scripts/build_card_archive.py` scarica i dump Malie multi-lingua, popola `Scripts/db_sources/<lang>` e genera `App/Resources/db/cards.db` con tutte le lingue.
- Esempio: `python Scripts/build_card_archive.py --languages it-IT en-US fr-FR --overwrite` (usa `--skip-download` per riutilizzare i JSON già presenti).
- In app è presente il tab **Impostazioni** per scegliere la lingua dei dati da usare nelle query.

## Esecuzione e test
- **Build**: `tuist build PKMCollection --platform iOS`
- **Unit test**: `tuist test PKMCollectionTests --platform iOS`
- **UI test**: `tuist test PKMCollectionUITests --platform iOS`
- **Aggiornare le dipendenze**: modifica `Tuist/Package.swift` e rilancia `tuist install`.

## Contribuire
Le linee guida sono disponibili in [`CONTRIBUTING.md`](CONTRIBUTING.md). In breve:
- apri un'issue prima di un cambiamento sostanziale;
- lavora su una branch separata;
- aggiungi test quando rilevante;
- assicurati che `tuist test` e lint (se presenti) passino.

Vedi anche il nostro [`Codice di condotta`](CODE_OF_CONDUCT.md).

## Licenza
Il progetto è distribuido con licenza [MIT](LICENSE).

## Roadmap
Le idee di sviluppo in corso sono raccolte in [`ROADMAP.md`](ROADMAP.md). Contribuzioni e feedback sono sempre ben accetti!
