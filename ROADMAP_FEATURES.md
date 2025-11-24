# PKM Collection – Roadmap Feature

## Feature backlog
- Wishlist multiple
  - Tab dedicata con liste separate, conteggio carte mancanti/possesse per ogni wishlist.
  - Azioni: crea/duplica/elimina wishlist; assegna/rimuovi carte; esporta/importa.

- Gestione mazzi (deck import)
  - Import da lista/CSV/testo (es. elenco ID/nomi carte), mapping a card ID locale.
  - Tracking carte mancanti per mazzo; stato possesso per ogni deck; esportazione.

- Filtri ampliati
  - Nuovi criteri: illustratore, costo energia, intervallo HP, data rilascio set, lingua, tipo carta (trainer/energia/pokemon), rarità avanzate.
  - UX: filtri avanzati con salvataggio preset.

- Ricerca globale carte
  - Schermata dedicata per query full-text su tutto il database carte (oltre alle viste per espansione).
  - Risultati con link a dettaglio carta e a espansione di appartenenza.

- Storage su DB locale + sync remoto
  - Migrazione da JSON a DB locale (SQLite/Core Data) per card data, wishlist, mazzi e ownership.
  - Layer di sync verso backend remoto (da definire) con conflitto risoluzione.

## Note tecniche iniziali
- Wishlist/mazzi: definire nuovi model persistiti e UI separata (nuova tab + viste lista/dettaglio).
- Filtri: estendere store e UI filtri; valutare performance delle query su dataset più ricchi (indice locale o query DB).
- Ricerca globale: richiede indice locale (DB) o API; UI con search bar persistente e risultato cross-expansione.
- Storage DB: scegliere stack (SQLite/Core Data) e piano di migrazione dei JSON attuali; definire eventuale layer di sync (API/Cloud).

## Prossimi passi
1) Definire stack DB e modello dati condiviso (card catalog, ownership, wishlist, deck).
2) Progettare la nuova tab Wishlist con supporto multi-lista.
3) Disegnare flow di import deck e mapping carte.
4) Estendere filtri e ricerca globale dopo la migrazione a DB per ottimizzare query.
5) Pianificare il sync remoto (API/architettura) una volta stabilizzato il modello locale.
