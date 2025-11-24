# PKM Collection – Local DB & Sync (Draft)

## Goals
- Migrare da JSON a SQLite (GRDB) con schema esplicito.
- Supportare wishlist multiple, deck import/tracking, ownership.
- Preparare un flusso di sync verso backend (stub ora, API reale in seguito).

## Proposta schema (GRDB/SQLite)
- `expansions` (read-only master)
  - `id` (TEXT PK), `name`, `series`, `abbr`, `release_date`, `logo_url`, `symbol_url`, `num_master`, `num_regular`, `hash`, `updated_at`
- `cards` (read-only master)
  - `id` (TEXT PK), `expansion_id` (FK), `name`, `collector_number`, `rarity`, `types`, `stage`, `hp`, `lang`, `image_url`, `foil_url`, `etch_url`, `data_hash`, `updated_at`
- `ownership` (user)
  - `card_id` (FK), `quantity` (INT), `wishlist` (BOOL), `updated_at`, `dirty` (BOOL), `deleted` (BOOL default 0), PK (`card_id`)
- `wishlists` (user)
  - `id` (UUID PK), `name`, `notes`, `updated_at`, `dirty`, `deleted`
- `wishlist_items` (user)
  - `wishlist_id` (FK), `card_id` (FK), `quantity` (INT), `updated_at`, `dirty`, `deleted`, PK (`wishlist_id`,`card_id`)
- `decks` (user)
  - `id` (UUID PK), `name`, `format`, `notes`, `updated_at`, `dirty`, `deleted`
- `deck_cards` (user)
  - `deck_id` (FK), `card_id` (FK), `quantity` (INT), `role` (main/side), `updated_at`, `dirty`, `deleted`, PK (`deck_id`,`card_id`,`role`)
- `sync_state`
  - `resource` (TEXT PK), `last_cursor` (TEXT), `last_pulled_at` (DATETIME)

Note: campi `dirty`/`deleted` servono per sync offline-first; `updated_at` per LWW.

## Flussi di sync (stub → backend reale)
- **Master data (expansions/cards)**: pull-only. Opzioni:
  1) Full refresh con hash/versione set (se hash cambia, replace).
  2) Delta `since`/`cursor` (preferito) con insert/update/delete.
- **User data (ownership, wishlists, wishlist_items, decks, deck_cards)**:
  - Pull delta: GET `/sync?since=<cursor>` → array mutazioni (upsert/tombstone) con `updated_at`.
  - Push delta: POST `/sync` con mutazioni `dirty` (insert/update/delete) e timestamp client.
  - Conflitti: LWW su `updated_at`; per `quantity` si accetta valore server vincente. (Da raffinare se serve merge quantità).
- **SyncState**: salva ultimo `cursor` per ciascuna risorsa.

## Architettura suggerita (offline-first)
- Layer dati:
  - `LocalDatabase` (GRDB) con DAO per tabelle (ownership, wishlist, deck, master data).
  - `RemoteAPI` (stub ora) con modelli di mutazione (`Mutation { table, op, record, updatedAt }`).
  - `SyncCoordinator` che:
    1) Pusha `dirty` locali.
    2) Pulla delta con `cursor`.
    3) Applica mutazioni LWW, marca `dirty = false`.
- UI/ViewModel: legge dal DB (query GRDB) invece dei JSON; OwnedCardsStore/wishlist/deck store vanno adattati al nuovo strato.

## Migrazione iniziale
1) Seed master data: importa expansions/cards dai JSON attuali → tabelle read-only.
2) Seed ownership: mappa OwnedCardsStore attuale in `ownership`.
3) Wishlist/deck: inizialmente vuoti; migrazione non necessaria se assenti.

## Passi operativi
- Scegliere GRDB via SPM (aggiungere a Tuist/Package.swift) e creare modulo persistence in FeatureCore.
- Definire DAO e migrazioni (v1) per tabelle sopra.
- Creare RemoteAPI stub (in-memory) per sviluppare SyncCoordinator senza backend.
- Adattare gli store UI (OwnedCardsStore, future Wishlist/Deck store) a leggere/scrivere sul DB.
- Integrare sync manuale (pull/push) e task di background opzionale.
