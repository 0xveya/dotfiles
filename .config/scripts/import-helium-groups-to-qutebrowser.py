#!/usr/bin/env python3

import json
import re
import shutil
import sqlite3
import tempfile
from collections import OrderedDict
from datetime import datetime
from pathlib import Path

HELIUM = Path.home() / ".config/net.imput.helium" / "Default"
QUTE_SESSIONS = Path.home() / ".local" / "share" / "qutebrowser" / "sessions"
QUTE_DEFAULT = QUTE_SESSIONS / "default.yml"

URL_RE = re.compile(rb"https?://[^\x00-\x20\"'<>\\]+")
GROUP_RE = re.compile(rb'group(?:=|":"?)([A-Za-z0-9._-]+)')


def yaml_quote(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"


def detect_groups() -> list[str]:
    groups: list[str] = []
    seen: set[str] = set()
    for path in sorted((HELIUM / "Sessions").glob("*")):
        data = path.read_bytes()
        for match in GROUP_RE.finditer(data):
            group = match.group(1).decode("utf-8", errors="ignore").strip()
            if not group or group in seen:
                continue
            seen.add(group)
            groups.append(group)
    return groups


def load_titles() -> dict[str, str]:
    history = HELIUM / "History"
    fd, tmp_name = tempfile.mkstemp(prefix="helium-history-", suffix=".sqlite")
    Path(tmp_name).unlink(missing_ok=True)
    tmp = Path(tmp_name)
    try:
        shutil.copy2(history, tmp)
        db = sqlite3.connect(tmp)
        rows = db.execute("select url, title from urls where title is not null and title != ''")
        return {url: title for url, title in rows}
    finally:
        try:
            db.close()
        except Exception:
            pass
        tmp.unlink(missing_ok=True)


def extract_urls() -> list[str]:
    urls: "OrderedDict[str, None]" = OrderedDict()
    for path in sorted((HELIUM / "Sessions").glob("Tabs_*")):
        for match in URL_RE.finditer(path.read_bytes()):
            url = match.group().decode("utf-8", errors="ignore")
            if url.startswith(("chrome://", "chrome-extension://")):
                continue
            urls.setdefault(url, None)
    return list(urls.keys())


def choose_session_name(group: str) -> str:
    candidate = group
    if (QUTE_SESSIONS / f"{candidate}.yml").exists():
        candidate = f"helium-{group}"
    index = 2
    while (QUTE_SESSIONS / f"{candidate}.yml").exists():
        candidate = f"helium-{group}-{index}"
        index += 1
    return candidate


def default_geometry_block() -> str:
    if not QUTE_DEFAULT.exists():
        return "    AAAA\n"
    lines = QUTE_DEFAULT.read_text().splitlines()
    start = None
    for i, line in enumerate(lines):
        if line.strip() == "geometry: !!binary |":
            start = i + 1
            break
    if start is None:
        return "    AAAA\n"
    block: list[str] = []
    for line in lines[start:]:
        if line.startswith("  tabs:"):
            break
        block.append(line)
    return "\n".join(block).rstrip() + "\n"


def write_session(session_name: str, urls: list[str], titles: dict[str, str]) -> Path:
    now = datetime.now().replace(microsecond=0).isoformat()
    geometry = default_geometry_block()
    out = QUTE_SESSIONS / f"{session_name}.yml"
    QUTE_SESSIONS.mkdir(parents=True, exist_ok=True)

    lines = [
        "windows:",
        "- active: true",
        "  geometry: !!binary |",
        geometry.rstrip("\n"),
        "  tabs:",
    ]

    first = True
    for url in urls:
        title = titles.get(url) or url
        lines.extend(
            [
                f"  - active: {'true' if first else 'false'}",
                "    history:",
                "    - active: true",
                f"      last_visited: {yaml_quote(now)}",
                "      pinned: false",
                "      scroll-pos:",
                "        x: 0",
                "        y: 0",
                f"      title: {yaml_quote(title)}",
                f"      url: {yaml_quote(url)}",
                "      zoom: 1.0",
            ]
        )
        first = False

    out.write_text("\n".join(lines) + "\n")
    return out


def main() -> None:
    groups = detect_groups()
    if not groups:
        raise SystemExit("No Helium tab groups detected.")
    if len(groups) > 1:
        raise SystemExit(f"Detected multiple groups {groups}, but mapping tabs per group is not available yet.")

    group = groups[0]
    urls = extract_urls()
    if not urls:
        raise SystemExit("No importable Helium tab URLs found.")

    titles = load_titles()
    session_name = choose_session_name(group)
    path = write_session(session_name, urls, titles)
    print(f"Imported Helium group '{group}' to qutebrowser session '{session_name}' at {path}")


if __name__ == "__main__":
    main()
