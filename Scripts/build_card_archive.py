#!/usr/bin/env python3
"""
Fetch Malie exports for multiple languages and build a read-only card archive SQLite database.

Default workflow:
- Download index.json from https://cdn.malie.io/file/malie-io/tcgl/export/index.json
- For each language, download set files into Scripts/db_sources/<lang>/
- Generate set-<lang>.json (expansion metadata) per language
- Build App/Resources/db/cards.db with all languages
"""

from __future__ import annotations

import argparse
import json
import re
import unicodedata
import sqlite3
import time
from datetime import datetime
from pathlib import Path
from typing import Any, Iterable, Mapping
from urllib.error import HTTPError, URLError
from urllib.request import urlopen

EXPORT_BASE_URL = "https://cdn.malie.io/file/malie-io/tcgl/export/"
DEFAULT_INDEX_URL = f"{EXPORT_BASE_URL}index.json"
SUPPORTED_LANGS = ["en-US", "fr-FR", "it-IT", "de-DE", "es-ES", "pt-BR", "es-419"]
POKEMON_API_BASE = "https://pokeapi.co/api/v2/pokemon-species"
POKEMON_SPECIES_API = POKEMON_API_BASE
BUILTIN_ALIASES: dict[str, str] = {
    "paldean-tauros": "tauros-paldea-combat",
    "paldea-tauros": "tauros-paldea-combat",
    "tauros-paldean": "tauros-paldea-combat",
    "hisuian-growlithe": "growlithe-hisui",
    "hisuian-arcanine": "arcanine-hisui",
    "hisuian-braviary": "braviary-hisui",
    "hisuian-avalugg": "avalugg-hisui",
    "hisuian-voltorb": "voltorb-hisui",
    "hisuian-electrode": "electrode-hisui",
    "hisuian-typhlosion": "typhlosion-hisui",
    "hisuian-zoroark": "zoroark-hisui",
    "hisuian-zorua": "zorua-hisui",
    "hisuian-decidueye": "decidueye-hisui",
    "hisuian-samurott": "samurott-hisui",
    "hisuian-lilligant": "lilligant-hisui",
    "hisuian-goodra": "goodra-hisui",
    "hisuian-sliggoo": "sliggoo-hisui",
    "hisuian-sneasel": "sneasel-hisui",
    "hisuian-qwilfish": "qwilfish-hisui",
    "hisuian-basculin": "basculin-white-striped",
    "hisuian-basculegion": "basculegion-female",
    "alolan-raichu": "raichu-alola",
    "alolan-grimer": "grimer-alola",
    "alolan-muk": "muk-alola",
    "alolan-exeggutor": "exeggutor-alola",
    "alolan-ninetales": "ninetales-alola",
    "alolan-vulpix": "vulpix-alola",
    "alolan-meowth": "meowth-alola",
    "alolan-persian": "persian-alola",
    "alolan-sandshrew": "sandshrew-alola",
    "alolan-sandslash": "sandslash-alola",
    "alolan-marowak": "marowak-alola",
    "alolan-geodude": "geodude-alola",
    "alolan-graveler": "graveler-alola",
    "alolan-golem": "golem-alola",
    "galarian-articuno": "articuno-galar",
    "galarian-zapdos": "zapdos-galar",
    "galarian-moltres": "moltres-galar",
    "galarian-slowpoke": "slowpoke-galar",
    "galarian-slowbro": "slowbro-galar",
    "galarian-slowking": "slowking-galar",
    "galarian-zigzagoon": "zigzagoon-galar",
    "galarian-linoone": "linoone-galar",
    "galarian-obstagoon": "obstagoon",
    "galarian-ponyta": "ponyta-galar",
    "galarian-rapidash": "rapidash-galar",
    "galarian-farfetchd": "farfetchd-galar",
    "galarian-sirfetchd": "sirfetchd",
    "galarian-mr-mime": "mr-mime-galar",
    "galarian-mr-rime": "mr-rime",
    "galarian-darumaka": "darumaka-galar",
    "galarian-darmanitan": "darmanitan-galar-standard",
    "galarian-yamask": "yamask-galar",
    "galarian-corsola": "corsola-galar",
    "galarian-stunfisk": "stunfisk-galar",
    "galarian-weezing": "weezing-galar",
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Fetch Malie exports, stage JSON per language, and build the bundled cards.db. "
            "Supports overrides, Limitless mapping/card IDs, Pokemon species linking, and Cardmarket links."
        )
    )
    parser.add_argument(
        "--index-url",
        type=str,
        default=DEFAULT_INDEX_URL,
        help="URL to Malie export index JSON.",
    )
    parser.add_argument(
        "--languages",
        type=str,
        nargs="*",
        default=SUPPORTED_LANGS,
        help="Languages to sync (defaults to known languages).",
    )
    parser.add_argument(
        "--sources-root",
        type=Path,
        default=Path("Scripts/db_sources"),
        help="Root folder where JSON sources are stored per language.",
    )
    parser.add_argument(
        "--base-url",
        type=str,
        default=EXPORT_BASE_URL,
        help="Base URL for Malie export files (index paths are resolved relative to this).",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("App/Resources/db/cards.db"),
        help="Destination SQLite database path.",
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Replace output or staged JSON files if they already exist.",
    )
    parser.add_argument(
        "--skip-download",
        action="store_true",
        help="Reuse existing JSON files instead of downloading from the index.",
    )
    parser.add_argument(
        "--pokemon-source",
        type=Path,
        default=Path("Scripts/db_sources/pokeapi/pokemon.json"),
        help="Local cache file containing Pokemon data (list of pokemon objects).",
    )
    parser.add_argument(
        "--pokemon-aliases",
        type=Path,
        default=Path("Scripts/db_sources/pokeapi/aliases.json"),
        help="Optional aliases file to map card names to PokeAPI slugs.",
    )
    parser.add_argument(
        "--fetch-pokemon",
        action="store_true",
        help="Download Pokemon data from PokeAPI if the local cache is missing or overwrite is set.",
    )
    parser.add_argument(
        "--pokemon-api-base",
        type=str,
        default=POKEMON_API_BASE,
        help="Base URL for PokeAPI pokemon endpoint.",
    )
    parser.add_argument(
        "--unmatched-output",
        type=Path,
        default=Path("Scripts/db_sources/pokeapi/unmatched_pokemon.json"),
        help="Where to write a JSON report of card prints without a matched pokemon_id.",
    )
    parser.add_argument(
        "--expansion-overrides",
        type=Path,
        default=Path("Scripts/db_sources/expansion_overrides.json"),
        help="Optional overrides for expansions (series, releaseDate, logoUrl, symbolUrl, names, seriesNames).",
    )
    parser.add_argument(
        "--limitless-sets",
        type=Path,
        default=Path("Scripts/db_sources/limitless_sets.json"),
        help="Limitless sets JSON (from limitless_scraper.py sets) to enrich overrides.",
    )
    parser.add_argument(
        "--limitless-map",
        type=Path,
        default=Path("Scripts/db_sources/limitless_set_map.json"),
        help="Mapping between Malie expansion ids and Limitless set codes.",
    )
    parser.add_argument(
        "--limitless-id-cache",
        type=Path,
        default=Path("Scripts/db_sources/limitless_card_ids.json"),
        help="Cache of resolved Limitless card IDs keyed by set_code and collector_number.",
    )
    parser.add_argument(
        "--fetch-limitless-ids",
        action="store_true",
        help="Fetch missing Limitless card IDs from the website when not in cache.",
    )
    return parser.parse_args()


def load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def ensure_output_path(path: Path, overwrite: bool) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists() and overwrite:
        path.unlink()
    return path


def fetch_json(url: str) -> Any:
    try:
        with urlopen(url) as response:
            return json.loads(response.read().decode("utf-8"))
    except HTTPError as exc:
        raise RuntimeError(f"HTTP error fetching {url}: {exc.code}") from exc
    except URLError as exc:
        raise RuntimeError(f"Network error fetching {url}: {exc.reason}") from exc


def fetch_text(url: str) -> str:
    try:
        with urlopen(url) as response:
            return response.read().decode("utf-8")
    except HTTPError as exc:
        raise RuntimeError(f"HTTP error fetching {url}: {exc.code}") from exc
    except URLError as exc:
        raise RuntimeError(f"Network error fetching {url}: {exc.reason}") from exc


def download_if_needed(url: str, dest: Path, overwrite: bool) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    if dest.exists() and not overwrite:
        return
    try:
        with urlopen(url) as response:
            dest.write_bytes(response.read())
    except HTTPError as exc:
        raise RuntimeError(f"HTTP error downloading {url}: {exc.code}") from exc
    except URLError as exc:
        raise RuntimeError(f"Network error downloading {url}: {exc.reason}") from exc


def canonical_expansion_metadata(sources_root: Path) -> dict[str, dict[str, Any]]:
    seed_path = sources_root / "it-IT" / "set-it-IT.json"
    if not seed_path.exists():
        return {}
    try:
        data = load_json(seed_path)
    except Exception:
        return {}
    mapping: dict[str, dict[str, Any]] = {}
    for entry in data:
        key = entry.get("path") or entry.get("key") or entry.get("id")
        if key:
            mapping[key] = entry
    return mapping


def load_pokemon_cache(path: Path) -> list[dict[str, Any]]:
    if not path.exists():
        raise FileNotFoundError(f"Pokemon cache not found: {path}")
    return load_json(path)


def fetch_all_pokemon(api_base: str, dest: Path, overwrite: bool) -> list[dict[str, Any]]:
    if dest.exists() and not overwrite:
        return load_pokemon_cache(dest)
    dest.parent.mkdir(parents=True, exist_ok=True)
    print(f"[pokemon] fetching list from {api_base}?limit=2000")
    index_url = f"{api_base}?limit=2000"
    index = fetch_json(index_url)
    results = index.get("results") or []
    pokemon: list[dict[str, Any]] = []
    for entry in results:
        url = entry.get("url")
        name = entry.get("name")
        if not url:
            continue
        try:
            data = fetch_json(url)
            pokemon.append(data)
        except RuntimeError as exc:
            print(f"[warn] failed pokemon {name}: {exc}")
    dest.write_text(json.dumps(pokemon, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"[pokemon] wrote {len(pokemon)} pokemon to {dest}")
    return pokemon


def load_pokemon_data(path: Path, fetch: bool, api_base: str, overwrite: bool) -> list[dict[str, Any]]:
    if path.exists() and not fetch:
        return load_pokemon_cache(path)
    if fetch:
        return fetch_all_pokemon(api_base, path, overwrite)
    raise FileNotFoundError(f"Pokemon cache missing at {path}. Run with --fetch-pokemon to download.")


def load_aliases(path: Path) -> dict[str, str]:
    file_aliases: dict[str, str] = {}
    if path.exists():
        try:
            file_aliases = load_json(path)
        except Exception:
            file_aliases = {}
    merged = {**BUILTIN_ALIASES, **file_aliases}
    return merged


def load_expansion_overrides(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {}
    try:
        return load_json(path)
    except Exception:
        return {}


def load_limitless_sets(path: Path) -> dict[str, dict[str, Any]]:
    if not path.exists():
        return {}
    try:
        items = load_json(path)
        return {entry.get("code"): entry for entry in items if entry.get("code")}
    except Exception:
        return {}


def load_limitless_map(path: Path) -> dict[str, str]:
    if not path.exists():
        return {}
    try:
        data = load_json(path)
        return {k: (v or {}).get("limitless_code") for k, v in data.items() if (v or {}).get("limitless_code")}
    except Exception:
        return {}


def load_limitless_id_cache(path: Path) -> dict[str, dict[str, int]]:
    if not path.exists():
        return {}
    try:
        return load_json(path)
    except Exception:
        return {}


def normalize_name(value: str) -> str:
    # Strip accents/diacritics and normalize to ASCII-friendly form
    normalized = unicodedata.normalize("NFKD", value)
    without_accents = "".join(ch for ch in normalized if not unicodedata.combining(ch))
    cleaned = without_accents.lower()
    cleaned = cleaned.replace("’", "'")
    cleaned = re.sub(r"[^a-z0-9\s'-]", " ", cleaned)
    cleaned = cleaned.replace("‑", "-")
    cleaned = re.sub(r"\s+", " ", cleaned).strip()
    return cleaned


def strip_html_tags(value: str | None) -> str:
    if not value:
        return ""
    return re.sub(r"<[^>]+>", "", value).strip()


def normalize_pokemon_slug(name: str, aliases: Mapping[str, str]) -> str | None:
    base = normalize_name(name)
    base = re.sub(r"\b(radiant|prism star|prism|break|ex terastal|ex)\b", "", base)
    base = re.sub(r"\b(vstar|vmax|gx|ex|lv\.? x|mega|gigantamax|tera)\b", "", base)
    base = re.sub(r"\b(del|de|il|la|lo|le|gli)\b", "", base)
    # Strip leading possessives or trainer prefixes (e.g., "n's", "cynthia's", "team rocket's")
    base = re.sub(r"^[a-z]+['’]s\s+", "", base)
    base = re.sub(r"^team\s+rockets\s+", "", base)
    base = base.strip()
    alias_key = base.replace(" ", "-")
    if alias_key in aliases:
        return aliases[alias_key]
    # Regional forms
    parts = base.split(" ", 1)
    if len(parts) == 2:
        prefix, rest = parts
        if prefix in {"alolan", "alola"}:
            return f"{rest.replace(' ', '-')}-alola"
        if prefix in {"galarian", "galar"}:
            return f"{rest.replace(' ', '-')}-galar"
        if prefix in {"hisuian", "hisui"}:
            return f"{rest.replace(' ', '-')}-hisui"
        if prefix in {"paldean", "paldea"}:
            return f"{rest.replace(' ', '-')}-paldea"
    return alias_key or None


def build_pokemon_index(pokemon: list[dict[str, Any]], aliases: Mapping[str, str]) -> dict[str, int]:
    index: dict[str, int] = {}
    for entry in pokemon:
        slug = normalize_pokemon_slug(entry.get("name", ""), aliases)
        if not slug:
            continue
        index[slug] = int(entry.get("id", 0))
    return index


def stage_language_sources(
    index: Mapping[str, Any],
    languages: list[str],
    sources_root: Path,
    base_url: str,
    overwrite: bool,
) -> None:
    canonical_meta = canonical_expansion_metadata(sources_root)
    for lang in languages:
        if lang not in index:
            print(f"[warn] language {lang} missing in index, skipping")
            continue
        print(f"[download] {lang}: {len(index[lang])} set files")
        lang_dir = sources_root / lang
        lang_dir.mkdir(parents=True, exist_ok=True)
        expansions_meta: list[dict[str, Any]] = []
        for set_id, meta in index[lang].items():
            relative_path = meta.get("path")
            if not relative_path:
                print(f"[warn] missing path for {lang}:{set_id}, skipping")
                continue
            filename = Path(relative_path).name
            dest = lang_dir / filename
            url = base_url.rstrip("/") + "/" + relative_path
            download_if_needed(url, dest, overwrite)
            print(f"  - {relative_path} -> {dest}")
            fallback_meta = canonical_meta.get(set_id, {})
            expansions_meta.append(
                {
                    "key": set_id,
                    "path": set_id,
                    "id": set_id,
                    "name": meta.get("name") or fallback_meta.get("name") or set_id,
                    "series": fallback_meta.get("series", ""),
                    "abbr": meta.get("abbr") or fallback_meta.get("abbr") or "",
                    "num": meta.get("num") or fallback_meta.get("num") or 0,
                    "hash": meta.get("hash") or fallback_meta.get("hash") or "",
                    "releaseDate": fallback_meta.get("releaseDate") or "1970-01-01",
                    "logoUrl": fallback_meta.get("logoUrl") or "",
                    "symbolUrl": fallback_meta.get("symbolUrl") or "",
                    "lang": lang,
                }
            )
        expansions_path = lang_dir / f"set-{lang}.json"
        expansions_path.write_text(json.dumps(expansions_meta, ensure_ascii=False, indent=2), encoding="utf-8")


def create_schema(conn: sqlite3.Connection) -> None:
    conn.executescript(
        """
        PRAGMA journal_mode=WAL;
        PRAGMA synchronous=OFF;
        DROP TABLE IF EXISTS expansions;
        DROP TABLE IF EXISTS cards;
        DROP TABLE IF EXISTS expansions_localized;
        DROP TABLE IF EXISTS card_prints;
        DROP TABLE IF EXISTS card_variants;
        DROP TABLE IF EXISTS card_localizations;
        DROP TABLE IF EXISTS pokemon;
        DROP TABLE IF EXISTS series;
        DROP TABLE IF EXISTS series_localizations;

        CREATE TABLE expansions (
            id TEXT PRIMARY KEY,
            limitless_code TEXT,
            series_id TEXT,
            series TEXT,
            abbr TEXT,
            release_date REAL,
            logo_url TEXT,
            symbol_url TEXT,
            num_master INTEGER,
            num_regular INTEGER,
            hash TEXT,
            updated_at REAL,
            json_data BLOB
        );

        CREATE TABLE expansion_localizations (
            expansion_id TEXT NOT NULL,
            lang TEXT NOT NULL,
            name TEXT NOT NULL,
            UNIQUE(expansion_id, lang),
            FOREIGN KEY(expansion_id) REFERENCES expansions(id)
        );

        CREATE TABLE series (
            id TEXT PRIMARY KEY,
            updated_at REAL
        );

        CREATE TABLE series_localizations (
            series_id TEXT NOT NULL,
            lang TEXT NOT NULL,
            name TEXT NOT NULL,
            UNIQUE(series_id, lang),
            FOREIGN KEY(series_id) REFERENCES series(id)
        );

        CREATE TABLE card_prints (
            id TEXT PRIMARY KEY,
            expansion_id TEXT NOT NULL,
            limitless_set_code TEXT,
            collector_number TEXT,
            collector_raw TEXT,
            rarity TEXT,
            types TEXT,
            stage TEXT,
            hp INTEGER,
            regulation_mark TEXT,
            pokemon_id INTEGER,
            tcgl_card_id TEXT,
            limitless_card_id INTEGER,
            cardmarket_url TEXT,
            updated_at REAL,
            json_data BLOB,
            FOREIGN KEY(expansion_id) REFERENCES expansions(id),
            FOREIGN KEY(pokemon_id) REFERENCES pokemon(id)
        );

        CREATE TABLE card_variants (
            id TEXT PRIMARY KEY,
            print_id TEXT NOT NULL,
            variant TEXT NOT NULL,
            image_front TEXT,
            image_foil TEXT,
            image_etch TEXT,
            tcgl_long_form_id TEXT,
            updated_at REAL,
            FOREIGN KEY(print_id) REFERENCES card_prints(id)
        );

        CREATE TABLE card_localizations (
            variant_id TEXT NOT NULL,
            lang TEXT NOT NULL,
            name TEXT NOT NULL,
            text_json BLOB,
            image_front TEXT,
            image_foil TEXT,
            image_etch TEXT,
            UNIQUE(variant_id, lang),
            FOREIGN KEY(variant_id) REFERENCES card_variants(id)
        );

        CREATE TABLE pokemon (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            slug TEXT,
            national_dex INTEGER,
            types TEXT,
            json_data BLOB,
            updated_at REAL
        );

        CREATE INDEX idx_expansions_series ON expansions(series);
        CREATE INDEX idx_card_prints_expansion ON card_prints(expansion_id);
        CREATE INDEX idx_card_prints_pokemon ON card_prints(pokemon_id);
        CREATE INDEX idx_card_variants_print ON card_variants(print_id);
        CREATE INDEX idx_card_localizations_variant ON card_localizations(variant_id);
        """
    )


def to_timestamp(date_str: str | None) -> float:
    if not date_str:
        return 0.0
    try:
        return datetime.fromisoformat(date_str.replace("Z", "+00:00")).timestamp()
    except ValueError:
        try:
            return datetime.strptime(date_str, "%Y-%m-%d").timestamp()
        except ValueError:
            return 0.0


def iter_expansions(expansions: Iterable[dict[str, Any]], now_ts: float) -> Iterable[tuple[Any, ...]]:
    for exp in expansions:
        num_raw = exp.get("num")
        if isinstance(num_raw, dict):
            num_master = num_raw.get("master")
            num_regular = num_raw.get("regular")
        elif isinstance(num_raw, int):
            num_master = num_regular = num_raw
        else:
            num_master = num_regular = None
        lang = exp.get("lang") or "it-IT"
        yield (
            exp.get("path") or exp.get("key"),
            lang,
            exp.get("name", ""),
            exp.get("series"),
            exp.get("abbr"),
            to_timestamp(exp.get("releaseDate")),
            exp.get("logoUrl"),
            exp.get("symbolUrl"),
            num_master,
            num_regular,
            exp.get("hash"),
            now_ts,
            json.dumps(exp, ensure_ascii=False).encode("utf-8"),
        )


def safe_int(value: Any) -> int | None:
    if value is None:
        return None
    try:
        return int(value)
    except (TypeError, ValueError):
        return None


def first_image(card: dict[str, Any], key: str) -> str | None:
    images = (card.get("images") or {}).get("tcgl") or {}
    for fmt in ("tex", "png", "jpg"):
        src = images.get(fmt) or {}
        val = src.get(key)
        if val:
            return val
    return None


def build_card_id(card: dict[str, Any], expansion_id: str) -> str:
    collector = card.get("collector_number") or {}
    numeric = collector.get("numeric")
    numerator = collector.get("numerator")
    suffix = None
    if numeric is not None:
        suffix = str(numeric)
    elif numerator:
        suffix = str(numerator)
    else:
        suffix = collector.get("full") or card.get("name", "unknown")
    return f"{expansion_id}_{suffix}"


def fetch_limitless_card_id(set_code: str, number: str | int) -> int | None:
    url = f"https://limitlesstcg.com/cards/{set_code}/{number}"
    text = fetch_text(url)
    match = re.search(r"var\s+cardId\s*=\s*(\d+)", text)
    if match:
        return int(match.group(1))
    return None


def detect_variant(card: dict[str, Any]) -> str:
    long_form = ((card.get("ext") or {}).get("tcgl") or {}).get("longFormID")
    if long_form:
        tail = long_form.split("_")[-1]
        normalized = tail.lower()
        mapping = {
            "nonfoil": "nonfoil",
            "none": "nonfoil",
            "reverse": "reverse",
            "holo": "holo",
            "etched": "etched",
            "stamped": "stamped",
            "castandcure": "castandcure",
        }
        if normalized in mapping:
            return mapping[normalized]
    images = (card.get("images") or {}).get("tcgl") or {}
    tex = images.get("tex") or {}
    if "etch" in tex:
        return "etched"
    if "foil" in tex:
        return "foil"
    return "nonfoil"


def variant_id(print_id: str, variant: str) -> str:
    return f"{print_id}#{variant}"


def pokemon_id_for_card(card_name_en: str | None, pokemon_index: Mapping[str, int], aliases: Mapping[str, str]) -> int | None:
    if not card_name_en:
        return None
    slug = normalize_pokemon_slug(card_name_en, aliases)
    if not slug:
        return None
    return pokemon_index.get(slug)


def iter_pokemon_rows(pokemon: list[dict[str, Any]], now_ts: float) -> Iterable[tuple[Any, ...]]:
    for entry in pokemon:
        slug = normalize_pokemon_slug(entry.get("name", ""), {})
        if not slug:
            continue
        yield (
            int(entry.get("id", 0)),
            entry.get("name") or "",
            slug,
            safe_int(entry.get("id")),
            "",
            json.dumps(entry, ensure_ascii=False).encode("utf-8"),
            now_ts,
        )


def iter_card_print(
    card: dict[str, Any],
    print_id_value: str,
    expansion_id: str,
    limitless_set_code: str | None,
    limitless_card_id: int | None,
    pokemon_id_value: int | None,
    now_ts: float,
) -> tuple[Any, ...]:
    collector = card.get("collector_number") or {}
    rarity = card.get("rarity") or {}
    tcgl = (card.get("ext") or {}).get("tcgl") or {}
    collector_full = collector.get("full")
    cardmarket_url = None
    if limitless_set_code:
        number_int = collector.get("numeric") or collector.get("numerator")
        if number_int is None and collector_full:
            try:
                number_int = int(str(collector_full).split("/")[0])
            except Exception:
                number_int = None
        if isinstance(number_int, str):
            try:
                number_int = int(number_int)
            except Exception:
                number_int = None
        if isinstance(number_int, int):
            cardmarket_url = (
                "https://www.cardmarket.com/en/Pokemon/Products/Search?searchString="
                f"{limitless_set_code.lower()}{number_int:03d}"
            )
    return (
        print_id_value,
        expansion_id,
        limitless_set_code,
        collector.get("numeric") or collector_full or collector.get("numerator"),
        collector_full,
        rarity.get("designation"),
        ",".join(card.get("types") or []),
        card.get("stage"),
        safe_int(card.get("hp")),
        card.get("regulation_mark"),
        pokemon_id_value,
        tcgl.get("cardID"),
        limitless_card_id,
        cardmarket_url,
        now_ts,
        json.dumps(card, ensure_ascii=False).encode("utf-8"),
    )


def iter_card_variant(card: dict[str, Any], print_id_value: str, variant: str, now_ts: float) -> tuple[Any, ...]:
    long_form = ((card.get("ext") or {}).get("tcgl") or {}).get("longFormID")
    return (
        variant_id(print_id_value, variant),
        print_id_value,
        variant,
        first_image(card, "front"),
        first_image(card, "foil"),
        first_image(card, "etch"),
        long_form,
        now_ts,
    )


def iter_card_localization(card: dict[str, Any], variant_id_value: str, lang: str) -> tuple[Any, ...]:
    return (
        variant_id_value,
        lang,
        card.get("name", ""),
        json.dumps(card.get("text") or [], ensure_ascii=False).encode("utf-8"),
        first_image(card, "front"),
        first_image(card, "foil"),
        first_image(card, "etch"),
    )


def build_database_for_languages(
    sources_root: Path,
    languages: list[str],
    output: Path,
    overwrite: bool,
    pokemon_data: list[dict[str, Any]],
    aliases: Mapping[str, str],
    unmatched_output: Path | None,
    expansion_overrides: Mapping[str, Any],
    limitless_sets: Mapping[str, Any],
    limitless_map: Mapping[str, str],
    limitless_id_cache: dict[str, dict[str, int]],
    fetch_limitless_ids: bool,
    limitless_id_cache_path: Path,
) -> None:
    output_path = ensure_output_path(output, overwrite)
    now_ts = time.time()
    total_expansions = 0
    total_prints = 0
    total_variants = 0
    total_localizations = 0
    english_names: dict[str, str] = {}
    pokemon_index = build_pokemon_index(pokemon_data, aliases)
    languages_sorted = sorted(languages, key=lambda lang: 0 if lang == "en-US" else 1)
    unmatched: dict[str, dict[str, Any]] = {}
    overrides = expansion_overrides or {}
    limitless_sets = limitless_sets or {}
    limitless_map = limitless_map or {}
    limitless_cache = limitless_id_cache or {}
    limitless_cache_dirty = False

    def pick_lang_value(value: Any) -> Any:
        if isinstance(value, dict):
            for lang in languages_sorted:
                if lang in value:
                    return value[lang]
            # fallback to first value
            return next(iter(value.values()), None)
        return value

    with sqlite3.connect(output_path) as conn:
        create_schema(conn)
        conn.execute("BEGIN")

        # Insert Pokemon catalog
        pokemon_rows = list(iter_pokemon_rows(pokemon_data, now_ts))
        if pokemon_rows:
            conn.executemany(
                """
                INSERT OR REPLACE INTO pokemon
                (id, name, slug, national_dex, types, json_data, updated_at)
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """,
                pokemon_rows,
            )

        # Build expansions and localizations
        expansions_by_lang: dict[str, list[dict[str, Any]]] = {}
        canonical_expansions: dict[str, dict[str, Any]] = {}
        series_seen: set[str] = set()
        series_loc_rows: list[tuple[Any, ...]] = []

        for lang in languages_sorted:
            expansions_path = sources_root / lang / f"set-{lang}.json"
            if not expansions_path.exists():
                print(f"[warn] expansions list missing for {lang}: {expansions_path}")
                continue
            expansions_data = load_json(expansions_path)
            expansions_by_lang[lang] = expansions_data
            for exp in expansions_data:
                key = exp.get("path") or exp.get("key")
                if not key:
                    continue
                if key not in canonical_expansions:
                    canonical_expansions[key] = exp

        exp_rows = []
        for exp_id, exp in canonical_expansions.items():
            ov = overrides.get(exp_id, {})
            release_src = ov.get("releaseDate") or exp.get("releaseDate")
            logo_src = pick_lang_value(ov.get("logoUrl")) or exp.get("logoUrl")
            symbol_src = pick_lang_value(ov.get("symbolUrl")) or exp.get("symbolUrl")
            series_id = ov.get("seriesId") or exp.get("series")
            limitless_code = limitless_map.get(exp_id)
            if limitless_code and limitless_code in limitless_sets:
                lset = limitless_sets[limitless_code]
                release_src = release_src or lset.get("releaseDate")
                logo_src = logo_src or lset.get("logoUrl")
            num_raw = exp.get("num")
            if isinstance(num_raw, dict):
                num_master = num_raw.get("master")
                num_regular = num_raw.get("regular")
            elif isinstance(num_raw, int):
                num_master = num_regular = num_raw
            else:
                num_master = num_regular = None
            exp_rows.append(
                (
                    exp_id,
                    limitless_code,
                    series_id,
                    exp.get("series"),
                    exp.get("abbr"),
                    to_timestamp(release_src),
                    logo_src,
                    symbol_src,
                    num_master,
                    num_regular,
                    exp.get("hash"),
                    now_ts,
                    json.dumps(exp, ensure_ascii=False).encode("utf-8"),
                )
            )
        if exp_rows:
            conn.executemany(
                """
                INSERT OR REPLACE INTO expansions
                (id, limitless_code, series_id, series, abbr, release_date, logo_url, symbol_url, num_master, num_regular, hash, updated_at, json_data)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                exp_rows,
            )
            total_expansions = len(exp_rows)

        # Series localization rows (from overrides)
        for exp_id, ov in overrides.items():
            sid = ov.get("seriesId")
            if not sid:
                continue
            if sid not in series_seen:
                series_seen.add(sid)
            series_names = ov.get("seriesNames") or {}
            for lang, name in series_names.items():
                series_loc_rows.append((sid, lang, name))
        if series_seen:
            conn.executemany(
                "INSERT OR REPLACE INTO series (id, updated_at) VALUES (?, ?)",
                [(sid, now_ts) for sid in series_seen],
            )
        if series_loc_rows:
            conn.executemany(
                """
                INSERT OR REPLACE INTO series_localizations (series_id, lang, name)
                VALUES (?, ?, ?)
                """,
                series_loc_rows,
            )

        loc_rows = []
        for lang, expansions in expansions_by_lang.items():
            for exp in expansions:
                exp_id = exp.get("path") or exp.get("key")
                if not exp_id:
                    continue
                ov = overrides.get(exp_id, {})
                names_override = ov.get("names") or {}
                name_value = names_override.get(lang) or strip_html_tags(exp.get("name", ""))
                loc_rows.append((exp_id, lang, name_value))
        if loc_rows:
            conn.executemany(
                """
                INSERT OR REPLACE INTO expansion_localizations
                (expansion_id, lang, name) VALUES (?, ?, ?)
                """,
                loc_rows,
            )

        seen_prints: set[str] = set()
        seen_variants: set[str] = set()

        for lang in languages_sorted:
            print(f"[build] ingesting {lang}")
            expansions_data = expansions_by_lang.get(lang, [])
            for exp in expansions_data:
                expansion_id = exp.get("path") or exp.get("key")
                if not expansion_id:
                    continue
                exp_limitless_code = limitless_map.get(expansion_id)
                card_file = sources_root / lang / f"{expansion_id}.{lang}.json"
                if not card_file.exists() and "path" in exp:
                    card_file = sources_root / lang / Path(str(exp["path"])).name
                if not card_file.exists():
                    print(f"[warn] missing cards file for {lang}:{expansion_id}: {card_file}")
                    continue
                cards_data = load_json(card_file)
                print_rows = []
                variant_rows = []
                loc_rows = []
                for card in cards_data:
                    if card.get("card_type") == "TRAINER" or card.get("card_type") == "ENERGY":
                        pokemon_id_value = None
                    else:
                        name_en = card.get("name") if lang == "en-US" else english_names.get(build_card_id(card, expansion_id))
                        pokemon_id_value = pokemon_id_for_card(name_en, pokemon_index, aliases)
                        if pokemon_id_value is None and name_en:
                            pid = build_card_id(card, expansion_id)
                            if pid not in unmatched:
                                unmatched[pid] = {
                                    "print_id": pid,
                                    "expansion_id": expansion_id,
                                    "collector": (card.get("collector_number") or {}).get("full"),
                                    "name_en": name_en,
                                    "lang_seen": lang,
                                }
                    print_id_value = build_card_id(card, expansion_id)
                    variant = detect_variant(card)
                    variant_id_value = variant_id(print_id_value, variant)
                    collector = card.get("collector_number") or {}
                    limitless_card_id = None
                    if exp_limitless_code:
                        number = collector.get("numeric") or collector.get("numerator")
                        if number is None and collector.get("full"):
                            try:
                                number = int(str(collector["full"]).split("/")[0])
                            except Exception:
                                number = None
                        if number is not None:
                            cache_key = str(number)
                            set_cache = limitless_cache.setdefault(exp_limitless_code, {})
                            if cache_key in set_cache:
                                limitless_card_id = set_cache[cache_key]
                            elif fetch_limitless_ids:
                                try:
                                    limitless_card_id = fetch_limitless_card_id(exp_limitless_code, cache_key)
                                    if limitless_card_id:
                                        set_cache[cache_key] = limitless_card_id
                                        limitless_cache_dirty = True
                                    print(f"[limitless] {exp_limitless_code} {cache_key} -> {limitless_card_id}")
                                except Exception as exc:
                                    print(f"[warn] failed to resolve limitless id for {exp_limitless_code} {cache_key}: {exc}")
                    if lang == "en-US":
                        english_names[print_id_value] = card.get("name", "")
                    if print_id_value not in seen_prints:
                        print_rows.append(
                            iter_card_print(
                                card,
                                print_id_value,
                                expansion_id,
                                exp_limitless_code,
                                limitless_card_id,
                                pokemon_id_value,
                                now_ts,
                            )
                        )
                        seen_prints.add(print_id_value)
                    if variant_id_value not in seen_variants:
                        variant_rows.append(iter_card_variant(card, print_id_value, variant, now_ts))
                        seen_variants.add(variant_id_value)
                    loc_rows.append(iter_card_localization(card, variant_id_value, lang))
                if print_rows:
                    conn.executemany(
                        """
                        INSERT OR REPLACE INTO card_prints
                        (id, expansion_id, limitless_set_code, collector_number, collector_raw, rarity, types, stage, hp, regulation_mark, pokemon_id, tcgl_card_id, limitless_card_id, cardmarket_url, updated_at, json_data)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                        """,
                        print_rows,
                    )
                    total_prints += len(print_rows)
                if variant_rows:
                    conn.executemany(
                        """
                        INSERT OR REPLACE INTO card_variants
                        (id, print_id, variant, image_front, image_foil, image_etch, tcgl_long_form_id, updated_at)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                        """,
                        variant_rows,
                    )
                    total_variants += len(variant_rows)
                if loc_rows:
                    conn.executemany(
                        """
                        INSERT OR REPLACE INTO card_localizations
                        (variant_id, lang, name, text_json, image_front, image_foil, image_etch)
                        VALUES (?, ?, ?, ?, ?, ?, ?)
                        """,
                        loc_rows,
                    )
                    total_localizations += len(loc_rows)

        conn.commit()

    print(
        f"Wrote {total_expansions} expansions, {total_prints} card prints, {total_variants} variants, "
        f"{total_localizations} localizations to {output_path}"
    )
    if limitless_cache_dirty and limitless_id_cache_path:
        limitless_id_cache_path.parent.mkdir(parents=True, exist_ok=True)
        limitless_id_cache_path.write_text(json.dumps(limitless_cache, ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"[cache] updated Limitless card id cache: {limitless_id_cache_path}")
    if unmatched_output:
        unmatched_output.parent.mkdir(parents=True, exist_ok=True)
        unmatched_output.write_text(json.dumps(list(unmatched.values()), ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"[report] wrote {len(unmatched)} unmatched Pokemon prints to {unmatched_output}")


def main() -> None:
    args = parse_args()
    index = fetch_json(args.index_url)
    languages = [lang for lang in args.languages if lang in index]
    if not languages:
        raise SystemExit("No requested languages are available in the index; aborting.")
    print(f"[info] languages: {', '.join(languages)}")
    if not args.skip_download:
        stage_language_sources(index, languages, args.sources_root, args.base_url, args.overwrite)
    else:
        print("[info] skip-download enabled, reusing existing JSON files")
    pokemon_data = load_pokemon_data(args.pokemon_source, args.fetch_pokemon, args.pokemon_api_base, args.overwrite)
    aliases = load_aliases(args.pokemon_aliases)
    expansion_overrides = load_expansion_overrides(args.expansion_overrides)
    limitless_sets = load_limitless_sets(args.limitless_sets)
    limitless_map = load_limitless_map(args.limitless_map)
    limitless_id_cache = load_limitless_id_cache(args.limitless_id_cache)
    build_database_for_languages(
        args.sources_root,
        languages,
        args.output,
        args.overwrite,
        pokemon_data,
        aliases,
        args.unmatched_output,
        expansion_overrides,
        limitless_sets,
        limitless_map,
        limitless_id_cache,
        args.fetch_limitless_ids,
        args.limitless_id_cache,
    )


if __name__ == "__main__":
    main()
