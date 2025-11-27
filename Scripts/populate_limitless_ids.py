#!/usr/bin/env python3
"""
Populate/refresh Limitless card ID cache in chunks.

Reads:
  - Scripts/db_sources/limitless_set_map.json (Malie -> Limitless set codes)
  - Scripts/db_sources/limitless_card_ids.json (cache, updated in-place)
  - Scripts/db_sources/<lang>/set-<lang>.json to iterate expansions/cards (default en-US)

Usage examples:
  python Scripts/populate_limitless_ids.py --sets PFL BLK
  python Scripts/populate_limitless_ids.py --all
  python Scripts/populate_limitless_ids.py --lang en-US --limit 200   # first 200 cards across selected sets

Results are written to Scripts/db_sources/limitless_card_ids.json.
"""

from __future__ import annotations

import argparse
import concurrent.futures
import json
import re
from pathlib import Path
from typing import Any, Iterable
import time
from urllib.error import HTTPError, URLError
from urllib.request import urlopen

LIMITLESS_MAP = Path("Scripts/db_sources/limitless_set_map.json")
LIMITLESS_CACHE = Path("Scripts/db_sources/limitless_card_ids.json")
DEFAULT_LANG = "en-US"


def fetch_text(url: str) -> str:
    try:
        with urlopen(url) as resp:
            return resp.read().decode("utf-8")
    except HTTPError as exc:
        raise RuntimeError(f"HTTP error {exc.code} for {url}") from exc
    except URLError as exc:
        raise RuntimeError(f"Network error {exc.reason} for {url}") from exc


def fetch_limitless_card_id(set_code: str, number: str | int) -> int | None:
    text = fetch_text(f"https://limitlesstcg.com/cards/{set_code}/{number}")
    m = re.search(r"var\s+cardId\s*=\s*(\d+)", text)
    if m:
        return int(m.group(1))
    return None


def load_json(path: Path) -> Any:
    return json.loads(path.read_text(encoding="utf-8"))


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Populate Limitless card IDs into cache.")
    parser.add_argument("--lang", default=DEFAULT_LANG, help="Language to read card lists from (default en-US).")
    parser.add_argument("--sets", nargs="*", help="Limitless set codes to process. Defaults to all mapped sets.")
    parser.add_argument("--all", action="store_true", help="Process all mapped sets.")
    parser.add_argument("--limit", type=int, default=0, help="Max number of cards to process (0 = no limit).")
    parser.add_argument("--workers", type=int, default=8, help="Concurrent workers for fetching card pages.")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if not LIMITLESS_MAP.exists():
        raise SystemExit("missing limitless_set_map.json; run generate_limitless_mapping.py first")

    set_map = load_json(LIMITLESS_MAP)
    mapped_sets = {malie: v.get("limitless_code") for malie, v in set_map.items() if v.get("limitless_code")}

    # choose sets to process
    target_sets: set[str] = set(args.sets or [])
    if args.all or not target_sets:
        target_sets = set(mapped_sets.values())

    cache: dict[str, dict[str, int]] = {}
    if LIMITLESS_CACHE.exists():
        cache = load_json(LIMITLESS_CACHE)

    tasks: list[tuple[str, str]] = []
    for malie_id, l_code in mapped_sets.items():
        if l_code not in target_sets:
            continue
        cards_path = Path(f"Scripts/db_sources/{args.lang}/{malie_id}.{args.lang}.json")
        if not cards_path.exists():
            print(f"[skip] missing cards file {cards_path}")
            continue
        cards = load_json(cards_path)
        set_cache = cache.setdefault(l_code, {})
        for card in cards:
            collector = card.get("collector_number") or {}
            number = collector.get("numeric") or collector.get("numerator")
            if number is None and collector.get("full"):
                try:
                    number = int(str(collector["full"]).split("/")[0])
                except Exception:
                    number = None
            if number is None:
                continue
            key = str(number)
            if key in set_cache:
                continue
            tasks.append((l_code, key))
            if args.limit and len(tasks) >= args.limit:
                break
        if args.limit and len(tasks) >= args.limit:
            break

    if not tasks:
        print("[info] nothing to do; cache already covers requested sets")
        return

    results: list[tuple[str, str, int | None]] = []
    workers = max(1, args.workers)
    with concurrent.futures.ThreadPoolExecutor(max_workers=workers) as executor:
        future_to_task = {
            executor.submit(fetch_limitless_card_id, set_code, num): (set_code, num)
            for set_code, num in tasks
        }
        for future in concurrent.futures.as_completed(future_to_task):
            set_code, num = future_to_task[future]
            cid = None
            try:
                cid = future.result()
            except Exception as exc:
                print(f"[warn] {set_code} {num} failed: {exc}")
            results.append((set_code, num, cid))
            print(f"[limitless] {set_code} {num} -> {cid}")
            # simple throttle to avoid hammering
            time.sleep(0.02)

    for set_code, num, cid in results:
        cache.setdefault(set_code, {})[num] = cid or 0

    LIMITLESS_CACHE.parent.mkdir(parents=True, exist_ok=True)
    LIMITLESS_CACHE.write_text(json.dumps(cache, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"[done] processed {len(results)} cards, cache saved to {LIMITLESS_CACHE}")


if __name__ == "__main__":
    main()
