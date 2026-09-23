#!/usr/bin/env python3
"""Normalize legacy Claude skill documents into Codex SKILL.md packages."""

from __future__ import annotations

import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
SKILLS = ROOT / "Skills"


def quoted(value: str) -> str:
    return json.dumps(" ".join(value.split()), ensure_ascii=False)


def shorten_description(value: str, limit: int = 900) -> str:
    value = " ".join(value.split())
    if len(value) <= limit:
        return value
    candidate = value[:limit]
    sentence_end = candidate.rfind(". ")
    if sentence_end >= limit // 2:
        return candidate[: sentence_end + 1]
    return candidate.rsplit(" ", 1)[0].rstrip(" ,;:") + "."


def convert_legacy(path: Path, text: str) -> str:
    folder_match = re.search(r"^- \*\*Folder\*\*:\s*(.+?)\s*$", text, re.MULTILINE)
    description_match = re.search(
        r"^## Description\s*\n(.*?)(?=\n## Trigger Phrases)", text, re.MULTILINE | re.DOTALL
    )
    methodology_match = re.search(
        r"^## Full Methodology\s*\n(.*)\Z", text, re.MULTILINE | re.DOTALL
    )

    name = folder_match.group(1).strip() if folder_match else path.parent.name
    if description_match:
        description = description_match.group(1).strip()
    else:
        description = f"Specialized offensive-security methodology for {name.replace('-', ' ')}."

    if methodology_match:
        body = methodology_match.group(1).lstrip()
    else:
        body = text

    body = body.replace("Instructions for Claude", "Instructions for Codex")
    body = body.replace("Claude", "Codex").replace("claude", "codex")
    description = shorten_description(description)
    return f"---\nname: {name}\ndescription: {quoted(description)}\n---\n\n{body.rstrip()}\n"


def normalize_existing(text: str) -> str:
    text = text.replace("Claude", "Codex").replace("claude", "codex")
    match = re.search(r'^description:\s*("(?:[^"\\]|\\.)*")\s*$', text, re.MULTILINE)
    if not match:
        return text
    description = shorten_description(json.loads(match.group(1)))
    return text[: match.start(1)] + quoted(description) + text[match.end(1) :]


def main() -> int:
    converted = 0
    normalized = 0
    for path in sorted(SKILLS.rglob("SKILL.md")):
        text = path.read_text(encoding="utf-8")
        if text.startswith("---\n"):
            updated = normalize_existing(text)
            normalized += 1
        else:
            updated = convert_legacy(path, text)
            converted += 1
        path.write_text(updated, encoding="utf-8", newline="\n")

    print(f"Converted {converted} legacy skills; normalized {normalized} existing skills.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
