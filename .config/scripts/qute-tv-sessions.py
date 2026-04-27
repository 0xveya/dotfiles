#!/usr/bin/env -S uv run --script
# /// script
# dependencies = ["pyyaml"]
# ///

import os
import sys
import yaml
from pathlib import Path

DATA_HOME = Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local/share"))
SESSION_DIR = DATA_HOME / "qutebrowser" / "sessions"


def session_file(name: str) -> Path:
    candidates = [
        SESSION_DIR / f"{name}.yml",
        SESSION_DIR / name,
    ]

    for path in candidates:
        if path.exists():
            return path

    raise SystemExit(f"session not found: {name}")


def load_session(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as f:
        return yaml.safe_load(f) or {}


def iter_tabs(data: dict):
    for w_i, win in enumerate(data.get("windows", []), start=1):
        for t_i, tab in enumerate(win.get("tabs", []), start=1):
            history = tab.get("history", [])
            active = next((h for h in history if h.get("active")), None)

            if active is None and history:
                active = history[-1]

            if not active:
                continue

            title = active.get("title") or "(no title)"
            url = active.get("url") or ""

            yield w_i, t_i, title, url


def list_sessions():
    SESSION_DIR.mkdir(parents=True, exist_ok=True)

    for path in sorted(SESSION_DIR.glob("*.yml")):
        data = load_session(path)
        tabs = list(iter_tabs(data))
        print(f"{path.stem}\t{len(tabs)} tabs\t{path}")


def preview_session(name: str):
    path = session_file(name)
    data = load_session(path)

    print(f"Session: {name}")
    print(f"File: {path}")
    print()

    for w_i, t_i, title, url in iter_tabs(data):
        print(f"[w{w_i}:t{t_i}] {title}")
        print(f"  {url}")
        print()


def list_tabs(name: str):
    path = session_file(name)
    data = load_session(path)

    for w_i, t_i, title, url in iter_tabs(data):
        print(f"{t_i}\t[w{w_i}:t{t_i}] {title}\t{url}")


def preview_tab(name: str, index: str):
    path = session_file(name)
    data = load_session(path)

    for _w_i, t_i, title, url in iter_tabs(data):
        if str(t_i) == str(index):
            print(title)
            print()
            print(url)
            return


cmd = sys.argv[1] if len(sys.argv) > 1 else ""

if cmd == "list-sessions":
    list_sessions()
elif cmd == "preview-session":
    preview_session(sys.argv[2])
elif cmd == "list-tabs":
    list_tabs(sys.argv[2])
elif cmd == "preview-tab":
    preview_tab(sys.argv[2], sys.argv[3])
else:
    raise SystemExit(
        "usage: qute-tv-sessiosn "
        "list-sessions|preview-session|list-tabs|preview-tab"
    )
