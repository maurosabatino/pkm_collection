#!/usr/bin/env python3
"""
Suggest mapping between Malie expansions (set-<lang>.json) and Limitless set codes.

This script reads:
  - Scripts/db_sources/limitless_sets.json  (produced by limitless_scraper.py sets)
  - Scripts/db_sources/expansion_overrides.json (Malie expansions, names per lang)

And writes suggestions to:
  - Scripts/db_sources/limitless_set_map.json

The matching is heuristic (token Jaccard on English names). You should review and
edit the resulting JSON to confirm or fix codes.
"""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any

LIMITLESS_SETS = Path("Scripts/db_sources/limitless_sets.json")
OVERRIDES = Path("Scripts/db_sources/expansion_overrides.json")
OUTPUT = Path("Scripts/db_sources/limitless_set_map.json")


def normalize_tokens(text: str) -> set[str]:
    text = re.sub(r"[^\w\s-]", " ", text.lower())
    tokens = set(t for t in re.split(r"\s+", text) if t)
    return tokens


def jaccard(a: set[str], b: set[str]) -> float:
    if not a or not b:
        return 0.0
    inter = len(a & b)
    union = len(a | b)
    return inter / union if union else 0.0


def main() -> None:
    if not LIMITLESS_SETS.exists():
        raise SystemExit(f"missing {LIMITLESS_SETS}; run limitless_scraper.py sets first")
    if not OVERRIDES.exists():
        raise SystemExit(f"missing {OVERRIDES}; build expansion_overrides.json first")

    limitless = json.loads(LIMITLESS_SETS.read_text(encoding="utf-8"))
    overrides = json.loads(OVERRIDES.read_text(encoding="utf-8"))

    limitless_tokens = []
    for entry in limitless:
        tokens = normalize_tokens(entry.get("name", ""))
        limitless_tokens.append((entry, tokens))

    suggestions: dict[str, Any] = {}
    for exp_id, data in overrides.items():
        name_en = (data.get("names") or {}).get("en-US", "")
        exp_tokens = normalize_tokens(name_en)
        best = None
        best_score = 0.0
        for entry, tokens in limitless_tokens:
            score = jaccard(exp_tokens, tokens)
            if score > best_score:
                best_score = score
                best = entry
        suggestions[exp_id] = {
            "limitless_code": (best or {}).get("code"),
            "limitless_name": (best or {}).get("name"),
            "score": round(best_score, 3),
        }

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(json.dumps(suggestions, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"[done] wrote suggestions to {OUTPUT}")


if __name__ == "__main__":
    main()
