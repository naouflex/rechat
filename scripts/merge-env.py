#!/usr/bin/env python3
"""Merge two .env files, preserving selected keys from the existing file.

Used on deploy so WEBUI_SECRET_KEY on the VM is never overwritten by a
developer laptop .env synced to GitHub.

Usage:
  merge-env.py EXISTING_ENV NEW_ENV > MERGED_ENV
"""

from __future__ import annotations

import sys

PRESERVE_KEYS = ("WEBUI_SECRET_KEY",)


def _parse(path: str) -> tuple[dict[str, str], list[str]]:
    values: dict[str, str] = {}
    lines: list[str] = []
    try:
        with open(path, encoding="utf-8") as fh:
            lines = fh.readlines()
    except FileNotFoundError:
        return values, lines

    for line in lines:
        stripped = line.strip()
        if not stripped or stripped.startswith("#") or "=" not in line:
            continue
        key, _, _value = line.partition("=")
        key = key.strip()
        if _.strip().strip('"').strip("'"):
            values[key] = line if line.endswith("\n") else line + "\n"
    return values, lines


def merge(existing_path: str, new_path: str) -> str:
    existing, _ = _parse(existing_path)
    with open(new_path, encoding="utf-8") as fh:
        new_lines = fh.readlines()

    out: list[str] = []
    seen: set[str] = set()
    for line in new_lines:
        stripped = line.strip()
        if stripped and not stripped.startswith("#") and "=" in line:
            key = line.split("=", 1)[0].strip()
            seen.add(key)
            if key in PRESERVE_KEYS and key in existing:
                out.append(existing[key])
                continue
        out.append(line)

    if out and not out[-1].endswith("\n"):
        out[-1] += "\n"

    for key in PRESERVE_KEYS:
        if key in existing and key not in seen:
            out.append(existing[key])

    text = "".join(out)
    if text and not text.endswith("\n"):
        text += "\n"
    return text


def main() -> None:
    if len(sys.argv) != 3:
        print(__doc__.strip(), file=sys.stderr)
        sys.exit(2)
    sys.stdout.write(merge(sys.argv[1], sys.argv[2]))


if __name__ == "__main__":
    main()
