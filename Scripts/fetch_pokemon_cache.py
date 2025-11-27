#!/usr/bin/env python3
"""
Download the full Pokemon catalog from PokeAPI and store it as a JSON cache.

This script is meant to be run offline ahead of the card archive build so that
the main build does not need network access. The resulting file is used by
Scripts/build_card_archive.py via the --pokemon-source flag.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.request import urlopen

DEFAULT_DEST = Path("Scripts/db_sources/pokeapi/pokemon.json")
DEFAULT_API_BASE = "https://pokeapi.co/api/v2/pokemon-species"


def fetch_json(url: str) -> Any:
    with urlopen(url) as response:
        return json.loads(response.read().decode("utf-8"))


def download_pokemon(api_base: str, limit: int) -> list[dict[str, Any]]:
    index_url = f"{api_base}?limit={limit}"
    print(f"[pokemon] fetching index {index_url}")
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
            if len(pokemon) % 100 == 0:
                print(f"[pokemon] fetched {len(pokemon)}…")
        except HTTPError as exc:
            print(f"[warn] HTTP error for {name}: {exc.code}")
        except URLError as exc:
            print(f"[warn] network error for {name}: {exc.reason}")
    print(f"[pokemon] fetched {len(pokemon)} total")
    return pokemon


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Download Pokemon data from PokeAPI into a local cache.")
    parser.add_argument(
        "--dest",
        type=Path,
        default=DEFAULT_DEST,
        help="Destination JSON file for cached Pokemon data.",
    )
    parser.add_argument(
        "--api-base",
        type=str,
        default=DEFAULT_API_BASE,
        help="Base URL for the PokeAPI pokemon endpoint.",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=100000,
        help="Maximum number of Pokemon to fetch from the API index.",
    )
    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Overwrite the existing cache file if it exists.",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if args.dest.exists() and not args.overwrite:
        print(f"[skip] cache already exists at {args.dest}, use --overwrite to refresh")
        return

    args.dest.parent.mkdir(parents=True, exist_ok=True)
    pokemon = download_pokemon(args.api_base.rstrip("/"), args.limit)
    args.dest.write_text(json.dumps(pokemon, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"[done] wrote {len(pokemon)} entries to {args.dest}")


if __name__ == "__main__":
    main()
