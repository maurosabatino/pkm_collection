# Database and scripts snapshot

- Schema ora normalizzato con serie, espansioni (multilingua), card_prints/variants/localizations, Pokémon, integrazione Limitless (limitless_code su expansions, limitless_set_code/cardmarket_url/limitless_card_id su card_prints).
- `build_card_archive.py`: supporta overrides espansioni, mapping Limitless, cache Pokémon (species), report unmatched Pokémon, opzione `--fetch-limitless-ids`, cardmarket URL corretto (`{setcode}{num_3cifre}`), backup via pipeline.
- Script aggiuntivi: `limitless_scraper.py` (sets/prices), `generate_limitless_mapping.py` (suggerimenti Malie→Limitless), `populate_limitless_ids.py` (parallel fetch cardId, cache), `check_build_health.py` (post-build stats).
- Cache/sorgenti: `Scripts/db_sources/limitless_sets.json`, `limitless_set_map.json`, `limitless_card_ids.json`, `expansion_overrides.json`, `pokeapi/pokemon.json`, unmatched in `pokeapi/unmatched_pokemon.json`.
- Pipeline `run_cards_pipeline.sh`: backup automatico di cards.db, flag `--fetch-limitless-ids`, validazione estesa (missing Pokémon/Limitless/cardmarket).
