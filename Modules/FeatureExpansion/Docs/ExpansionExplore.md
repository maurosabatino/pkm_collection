# Expansion Explore – Technical Notes

## Structure
- Screens
  - `Sources/ExpansionExplore/Screens/ExpansionsList/ExpansionListView.swift`: series/expansion list entry point.
  - `Sources/ExpansionExplore/Screens/ExpansionDetail/ExpansionDetailView.swift`: per-expansion card grid with filters and modal card detail.
- Components – List
  - `Sources/ExpansionExplore/Screens/ExpansionDetail/Components/ExpansionRowView.swift`: row with logo + progress summary.
  - `Sources/ExpansionExplore/Screens/ExpansionDetail/Components/ExpansionProgressView.swift`: progress bar + dup/wishlist counters.
  - `Sources/ExpansionExplore/Screens/ExpansionDetail/Components/CardCatalogGrid.swift`: grid for cards with optional header slot.
  - `Sources/ExpansionExplore/Screens/ExpansionDetail/Components/CardCatalogGrid.swift` contains the `CollapsibleSearchBar`.
- Components – Detail
  - `Sources/ExpansionExplore/Screens/CardDetail/FullCardModalView.swift`: modal with full card details and collection actions.
  - `Sources/ExpansionExplore/Screens/CardDetail/CardFoilImageView.swift`: layered rendering for foil/etch assets.
  - `Sources/ExpansionExplore/Screens/CardDetail/CardDetailComponents.swift`: simple rows for metadata and moves.

## Data Flow
- Stores
  - `ExpansionStore`: loads expansions, exposes grouping and search text.
  - `CardListStore`: per-expansion list used by `ExpansionDetailView` and `ExpansionProgressView`.
  - `OwnedCardsStore`: collection state (owned, qty, wishlist) injected via `@EnvironmentObject`.
- Filters & search
  - Ricerca e filtri agiscono sui dati di `CardListStore` per la singola espansione.
  - Display mode (Regular/Master) è persistito insieme a `showOwnedOnly`.
  - Expansion detail filters sono per espansione (ownership + rarity) con display mode nello stesso sheet.

## Navigation & Composition
- Home list (`ExpansionListView`) -> tap a row -> `ExpansionDetailView`.
- Grid selections in `ExpansionDetailView` present `FullCardModalView` for details/actions.
- Progress summaries:
  - List rows use `ExpansionProgressView` (loads snapshot via `CardListStore`).
  - Detail header reuses the snapshot from `CardListStore.progressSnapshot(using:)`.

## Notes for Future Work
- If catalog data grows further, consider paging or incremental loading per expansion path.
- `CardCatalogStore` recompute is cancelable; keep future heavy work (e.g., sorting by localized name) off the main thread.
- UI assets/strings should stay within the owning module to avoid leaking dependencies per repository guidelines.
