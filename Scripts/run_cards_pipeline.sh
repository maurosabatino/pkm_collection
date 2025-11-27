#!/usr/bin/env bash
set -euo pipefail

# Pipeline helper:
# 1) Download Pokemon cache (PokeAPI) if missing
# 2) Build the cards.db with Pokemon linkage
# 3) Run basic validation queries
# 
# Usage:
#   ./Scripts/run_cards_pipeline.sh [--fetch] [--overwrite] [--skip-download] [--fetch-limitless-ids]
# 
# Flags:
#   --fetch          Force fetch Pokemon cache from PokeAPI
#   --overwrite      Overwrite existing caches and db
#   --skip-download  Reuse existing Malie JSON sources
#   --fetch-limitless-ids  Resolve missing Limitless card IDs (can be slow)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FETCH_POKEMON=0
OVERWRITE=0
SKIP_DOWNLOAD=0
FETCH_LIMITLESS_IDS=0

for arg in "$@"; do
  case "$arg" in
    --fetch) FETCH_POKEMON=1 ;;
    --fetch-limitless-ids) FETCH_LIMITLESS_IDS=1 ;;
    --overwrite) OVERWRITE=1 ;;
    --skip-download) SKIP_DOWNLOAD=1 ;;
    *) echo "Unknown arg: $arg" >&2; exit 1 ;;
  esac
done

PARGS=()
if [[ $OVERWRITE -eq 1 ]]; then PARGS+=("--overwrite"); fi
if [[ $FETCH_POKEMON -eq 1 ]]; then PARGS+=("--overwrite"); fi

if [[ $FETCH_POKEMON -eq 1 || ! -f "$ROOT_DIR/Scripts/db_sources/pokeapi/pokemon.json" ]]; then
  echo "[step] fetching pokemon cache"
  python "$ROOT_DIR/Scripts/fetch_pokemon_cache.py" "${PARGS[@]}"
else
  echo "[step] pokemon cache present, skipping fetch"
fi

echo "[step] building cards.db"
# Backup existing db before overwrite
if [[ $OVERWRITE -eq 1 && -f "$ROOT_DIR/App/Resources/db/cards.db" ]]; then
  mkdir -p "$ROOT_DIR/Backups"
  stamp=$(date +"%Y%m%d%H%M%S")
  cp "$ROOT_DIR/App/Resources/db/cards.db" "$ROOT_DIR/Backups/cards.db.$stamp"
  echo "[backup] cards.db -> Backups/cards.db.$stamp"
fi
BD_ARGS=()
if [[ $OVERWRITE -eq 1 ]]; then BD_ARGS+=("--overwrite"); fi
if [[ $SKIP_DOWNLOAD -eq 1 ]]; then BD_ARGS+=("--skip-download"); fi
if [[ $FETCH_POKEMON -eq 1 ]]; then BD_ARGS+=("--fetch-pokemon"); fi
if [[ $FETCH_LIMITLESS_IDS -eq 1 ]]; then BD_ARGS+=("--fetch-limitless-ids"); fi
python "$ROOT_DIR/Scripts/build_card_archive.py" "${BD_ARGS[@]}"

echo "[step] validating cards.db"
python - <<'PY'
import sqlite3, os, json
path = "App/Resources/db/cards.db"
if not os.path.exists(path):
    raise SystemExit("cards.db missing")
conn = sqlite3.connect(path)
cur = conn.cursor()
def q(sql):
    cur.execute(sql)
    return cur.fetchone()[0]
print("size_mb", round(os.path.getsize(path)/1024/1024, 2))
print("expansions", q("select count(*) from expansions"))
print("prints", q("select count(*) from card_prints"))
print("variants", q("select count(*) from card_variants"))
print("localizations", q("select count(*) from card_localizations"))
unmatched = q("select count(*) from card_prints where pokemon_id is null")
print("prints_without_pokemon", unmatched)
missing_limitless = q("select count(*) from card_prints where limitless_set_code is not null and (limitless_card_id is null or limitless_card_id=0)")
print("prints_without_limitless_id", missing_limitless)
missing_cardmarket = q("select count(*) from card_prints where cardmarket_url is null and limitless_set_code is not null")
print("prints_without_cardmarket_url", missing_cardmarket)
conn.close()
PY
echo "[done] pipeline complete"
