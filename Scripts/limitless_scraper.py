#!/usr/bin/env python3
"""
Helpers to scrape expansion metadata and card prices from LimitlessTCG.

Usage:
  - Fetch expansions list (code, name, release date, logo URL):
      python Scripts/limitless_scraper.py sets --output Scripts/db_sources/limitless_sets.json
  - Fetch price history for a specific card (by Limitless set code and card number):
      python Scripts/limitless_scraper.py prices --set PFL --number 118 --output /tmp/prices.json

Notes:
  - Set codes on Limitless (e.g., PFL) differ from Malie ids (e.g., me2), so a mapping is still required.
  - Logo URLs are taken from the list page (typically https://s3.limitlesstcg.com/sets/en/<CODE>_SM.png).
  - Price API endpoint: /api/cards/{cardId}/prices (cardId is read from the card page).
"""

from __future__ import annotations

import argparse
import html
import json
import re
from datetime import datetime
from pathlib import Path
from typing import Any
from urllib.error import HTTPError, URLError
from urllib.request import urlopen, Request

SETS_URL = "https://limitlesstcg.com/cards"
CARD_PAGE_URL = "https://limitlesstcg.com/cards/{code}/{number}"
PRICE_API_URL = "https://limitlesstcg.com/api/cards/{card_id}/prices"

MONTHS = {
    "Jan": 1,
    "Feb": 2,
    "Mar": 3,
    "Apr": 4,
    "May": 5,
    "Jun": 6,
    "Jul": 7,
    "Aug": 8,
    "Sep": 9,
    "Oct": 10,
    "Nov": 11,
    "Dec": 12,
}


def fetch(url: str) -> str:
    try:
        req = Request(url, headers={"User-Agent": "pkm-collection-scraper"})
        with urlopen(req) as resp:
            return resp.read().decode("utf-8")
    except HTTPError as exc:
        raise RuntimeError(f"HTTP error fetching {url}: {exc.code}") from exc
    except URLError as exc:
        raise RuntimeError(f"Network error fetching {url}: {exc.reason}") from exc


def parse_release_date(value: str) -> str | None:
    value = value.strip()
    if not value:
        return None
    # Format observed: "14 Nov 25"
    parts = value.split()
    if len(parts) != 3:
        return None
    day, mon, year = parts
    if mon not in MONTHS:
        return None
    try:
        day_num = int(day)
        year_num = int(year)
        year_num = 2000 + year_num if year_num < 100 else year_num
        dt = datetime(year_num, MONTHS[mon], day_num)
        return dt.strftime("%Y-%m-%d")
    except ValueError:
        return None


def scrape_sets() -> list[dict[str, Any]]:
    html_text = fetch(SETS_URL)
    pattern = re.compile(
        r'<td><a href="/cards/(?P<code>[A-Z0-9-]+)"><img[^>]+src="(?P<logo>[^"]+)"[^>]*>\s*(?P<name>.*?)\s*<span class="code annotation">(?P=code)</span></a></td>\s*<td><a href="/cards/(?P=code)">(.*?)</a></td>',
        re.S,
    )
    results: list[dict[str, Any]] = []
    for match in pattern.finditer(html_text):
        code = match.group("code")
        logo = match.group("logo")
        name = html.unescape(match.group("name")).strip()
        release_raw = match.group(4).strip()
        release = parse_release_date(release_raw)
        results.append(
            {
                "code": code,
                "name": name,
                "releaseDate": release,
                "logoUrl": logo,
                "symbolUrl": "",  # Not exposed on Limitless list page; keep empty for now.
            }
        )
    return results


def scrape_card_prices(set_code: str, number: str) -> dict[str, Any]:
    page = fetch(CARD_PAGE_URL.format(code=set_code, number=number))
    m = re.search(r"var\s+cardId\s*=\s*(\d+)", page)
    if not m:
        raise RuntimeError("cardId not found on card page")
    card_id = m.group(1)
    prices = fetch(PRICE_API_URL.format(card_id=card_id))
    try:
        return json.loads(prices)
    except json.JSONDecodeError as exc:
        raise RuntimeError("Failed to decode price JSON") from exc


def cmd_sets(args: argparse.Namespace) -> None:
    sets = scrape_sets()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(sets, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"[done] wrote {len(sets)} sets to {args.output}")


def cmd_prices(args: argparse.Namespace) -> None:
    data = scrape_card_prices(args.set, args.number)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"[done] wrote prices for {args.set}/{args.number} to {args.output}")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Scrape LimitlessTCG sets and card prices.")
    sub = parser.add_subparsers(dest="command", required=True)

    p_sets = sub.add_parser("sets", help="Fetch expansions list from Limitless.")
    p_sets.add_argument(
        "--output",
        type=Path,
        default=Path("Scripts/db_sources/limitless_sets.json"),
        help="Destination JSON file.",
    )
    p_sets.set_defaults(func=cmd_sets)

    p_prices = sub.add_parser("prices", help="Fetch price history for a card.")
    p_prices.add_argument("--set", required=True, help="Limitless set code (e.g., PFL).")
    p_prices.add_argument("--number", required=True, help="Card number within the set (e.g., 118).")
    p_prices.add_argument(
        "--output",
        type=Path,
        default=Path("Scripts/db_sources/limitless_prices.json"),
        help="Destination JSON file for the price payload.",
    )
    p_prices.set_defaults(func=cmd_prices)

    return parser.parse_args()


def main() -> None:
    args = parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
