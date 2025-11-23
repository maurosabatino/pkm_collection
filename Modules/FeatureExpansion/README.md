# FeatureExpansion Module – Navigation Cheat Sheet

## Entry Points
- `ExpansionListView` (`Sources/ExpansionExplore/Screens/ExpansionsList`): elenco espansioni per serie, cerca per nome/serie, apre `ExpansionDetailView` via `NavigationLink`.
- `ExpansionDetailView` (`Sources/ExpansionExplore/Screens/ExpansionDetail`): grid carte di una singola espansione, con:
  - Ricerca a scomparsa e header progressi.
  - Filtri possesso/rarità + display mode in `ExpansionFiltersView`.
  - Selezione card -> `FullCardModalView`.

## Componenti chiave
- ExpansionsList: `ExpansionRowView`, `ExpansionProgressView`.
- Detail grid: `CardCatalogGrid`, `CollapsibleSearchBar`.
- Filtri: `ExpansionFiltersView` (sheet interno a `ExpansionDetailView`).
- Card detail: `FullCardModalView`, `CardFoilImageView`, `CardDetailComponents` (righe e mosse).
- Store support: `ExpansionStore`, `CardCatalogStore` (filtro/sort off-main-thread + debounce), `CardListStore`, `OwnedCardsStore`.

## Navigazione (schematica)
```
ExpansionListView
  └─ tap row → ExpansionDetailView
        └─ tap card → FullCardModalView
```
