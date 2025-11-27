#!/usr/bin/env python3
"""
Post-build health checks for cards.db.

Checks:
- counts for tables
- unmatched Pokemon
- missing Limitless ids for mapped sets
- missing Cardmarket URLs for mapped sets
"""

from __future__ import annotations

import os
import sqlite3

DB_PATH = "App/Resources/db/cards.db"


def main() -> None:
    if not os.path.exists(DB_PATH):
        raise SystemExit("cards.db missing")
    conn = sqlite3.connect(DB_PATH)
    cur = conn.cursor()
    def q(sql: str) -> int:
        cur.execute(sql)
        return cur.fetchone()[0]
    print("size_mb", round(os.path.getsize(DB_PATH)/1024/1024, 2))
    print("expansions", q("select count(*) from expansions"))
    print("prints", q("select count(*) from card_prints"))
    print("variants", q("select count(*) from card_variants"))
    print("localizations", q("select count(*) from card_localizations"))
    print("prints_without_pokemon", q("select count(*) from card_prints where pokemon_id is null"))
    print("prints_without_limitless_id", q("select count(*) from card_prints where limitless_set_code is not null and (limitless_card_id is null or limitless_card_id=0)"))
    print("prints_without_cardmarket_url", q("select count(*) from card_prints where cardmarket_url is null and limitless_set_code is not null"))
    conn.close()


if __name__ == "__main__":
    main()
