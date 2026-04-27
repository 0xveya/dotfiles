#!/usr/bin/env python3

import json
import shutil
import sqlite3
import tempfile
from collections import OrderedDict
from datetime import datetime
from pathlib import Path
import re
import unicodedata

HELIUM = Path.home() / ".config" / "net.imput.helium" / "Default"
QUTE_CONFIG = Path.home() / ".config" / "qutebrowser"
QUTE_DATA = Path.home() / ".local" / "share" / "qutebrowser"

BOOKMARKS_JSON = HELIUM / "Bookmarks"
HELIUM_HISTORY = HELIUM / "History"
HELIUM_COOKIES = HELIUM / "Cookies"

QUTE_BOOKMARKS = QUTE_CONFIG / "bookmarks" / "urls"
QUTE_COOKIES = QUTE_DATA / "webengine" / "Cookies"
QUTE_SESSIONS = QUTE_DATA / "sessions"
QUTE_DEFAULT = QUTE_SESSIONS / "default.yml"
QUTE_HELIUM_MANIFEST = QUTE_SESSIONS / ".helium-imported-sessions.json"

URL_RE = re.compile(rb"https?://[^\x00-\x20\"'<>\\]+")
SAVED_GROUP_PREFIX = b"saved_tab_group-dt-"


def read_history_titles() -> dict[str, str]:
    with tempfile.NamedTemporaryFile(prefix="helium-history-", suffix=".sqlite", delete=False) as tmp:
        tmp_path = Path(tmp.name)
    try:
        shutil.copy2(HELIUM_HISTORY, tmp_path)
        db = sqlite3.connect(tmp_path)
        rows = db.execute("select url, title from urls where title is not null and title != ''")
        return {url: title for url, title in rows}
    finally:
        try:
            db.close()
        except Exception:
            pass
        tmp_path.unlink(missing_ok=True)


def iter_helium_bookmarks(node: dict, prefix: list[str]):
    for child in node.get("children", []):
        kind = child.get("type")
        name = (child.get("name") or "").strip()
        if kind == "folder":
            next_prefix = prefix + ([name] if name else [])
            yield from iter_helium_bookmarks(child, next_prefix)
        elif kind == "url":
            url = (child.get("url") or "").strip()
            if url.startswith(("http://", "https://")):
                title = " / ".join(["Helium"] + prefix + ([name] if name else []))
                yield url, title


def parse_existing_bookmarks() -> OrderedDict[str, str]:
    items: OrderedDict[str, str] = OrderedDict()
    if not QUTE_BOOKMARKS.exists():
        return items
    for line in QUTE_BOOKMARKS.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line:
            continue
        parts = line.split(" ", 1)
        if len(parts) == 1:
            url, title = parts[0], parts[0]
        else:
            url, title = parts
        if title.startswith("Helium /"):
            continue
        if title.startswith("Helium Tab /"):
            continue
        items[url] = title
    return items


def merge_bookmarks() -> tuple[int, int]:
    existing = parse_existing_bookmarks()
    before = len(existing)
    data = json.loads(BOOKMARKS_JSON.read_text(encoding="utf-8"))
    for root_name in ("bookmark_bar", "other", "synced"):
        root = data.get("roots", {}).get(root_name, {})
        for url, title in iter_helium_bookmarks(root, [root_name]):
            existing[url] = title

    QUTE_BOOKMARKS.parent.mkdir(parents=True, exist_ok=True)
    backup = QUTE_BOOKMARKS.with_suffix(".urls.bak")
    if QUTE_BOOKMARKS.exists():
        shutil.copy2(QUTE_BOOKMARKS, backup)
    with QUTE_BOOKMARKS.open("w", encoding="utf-8") as handle:
        for url, title in existing.items():
            handle.write(f"{url} {title}\n")
    return before, len(existing)


def extract_urls_from_tabs_file(path: Path) -> list[str]:
    urls: OrderedDict[str, None] = OrderedDict()
    data = path.read_bytes()
    for match in URL_RE.finditer(data):
        url = match.group().decode("utf-8", errors="ignore")
        if url.startswith(("chrome://", "chrome-extension://")):
            continue
        urls.setdefault(url, None)
    return list(urls.keys())


def extract_helium_urls() -> list[str]:
    urls: OrderedDict[str, None] = OrderedDict()
    for path in sorted((HELIUM / "Sessions").glob("Tabs_*")):
        for url in extract_urls_from_tabs_file(path):
            urls.setdefault(url, None)
    return list(urls.keys())


def read_varint(data: bytes, index: int) -> tuple[int, int]:
    shift = 0
    value = 0
    while True:
        byte = data[index]
        index += 1
        value |= (byte & 0x7F) << shift
        if not (byte & 0x80):
            return value, index
        shift += 7


def read_length_delimited(data: bytes, index: int) -> tuple[bytes, int]:
    length, index = read_varint(data, index)
    return data[index : index + length], index + length


def parse_proto_fields(buffer: bytes) -> list[tuple[int, int, int | bytes]]:
    fields: list[tuple[int, int, int | bytes]] = []
    index = 0
    while index < len(buffer):
        key, index = read_varint(buffer, index)
        field_number = key >> 3
        wire_type = key & 0x07
        if wire_type == 0:
            value, index = read_varint(buffer, index)
        elif wire_type == 2:
            value, index = read_length_delimited(buffer, index)
        elif wire_type == 1:
            value = int.from_bytes(buffer[index : index + 8], "little")
            index += 8
        elif wire_type == 5:
            value = int.from_bytes(buffer[index : index + 4], "little")
            index += 4
        else:
            raise ValueError(f"unsupported wire type: {wire_type}")
        fields.append((field_number, wire_type, value))
    return fields


def parse_saved_group_payload(payload: bytes) -> dict | None:
    try:
        wrapper_fields = parse_proto_fields(payload)
    except Exception:
        return None

    specifics_fields: list[tuple[int, int, int | bytes]] | None = None
    for field_number, wire_type, value in wrapper_fields:
        if field_number == 2 and wire_type == 2 and isinstance(value, bytes):
            specifics_fields = parse_proto_fields(value)
            break
    if specifics_fields is None:
        return None

    entry: dict[str, str | int] = {"guid": "", "update": 0, "kind": ""}
    for field_number, wire_type, value in specifics_fields:
        if field_number == 1 and wire_type == 2:
            entry["guid"] = value.decode("utf-8", errors="ignore")
        elif field_number == 3 and wire_type == 0:
            entry["update"] = value
        elif field_number == 4 and wire_type == 2:
            entry["kind"] = "group"
            for sub_field, sub_wire, sub_value in parse_proto_fields(value):
                if sub_field == 1 and sub_wire == 0:
                    entry["position"] = sub_value
                elif sub_field == 2 and sub_wire == 2:
                    entry["title"] = sub_value.decode("utf-8", errors="ignore")
                elif sub_field == 3 and sub_wire == 0:
                    entry["color"] = sub_value
        elif field_number == 5 and wire_type == 2:
            entry["kind"] = "tab"
            for sub_field, sub_wire, sub_value in parse_proto_fields(value):
                if sub_field == 1 and sub_wire == 2:
                    entry["group_guid"] = sub_value.decode("utf-8", errors="ignore")
                elif sub_field == 2 and sub_wire == 0:
                    entry["position"] = sub_value
                elif sub_field == 3 and sub_wire == 2:
                    entry["url"] = sub_value.decode("utf-8", errors="ignore")
                elif sub_field == 4 and sub_wire == 2:
                    entry["title"] = sub_value.decode("utf-8", errors="ignore")

    if not entry["guid"] or not entry["kind"]:
        return None
    return entry


def sanitize_session_name(name: str) -> str:
    cleaned = unicodedata.normalize("NFKC", name).strip()
    cleaned = cleaned.replace("/", "-").replace("\x00", "")
    cleaned = re.sub(r"\s+", " ", cleaned)
    return cleaned or "helium"


def extract_saved_group_sessions() -> list[tuple[str, list[str]]]:
    sync_db = HELIUM / "Sync Data" / "LevelDB"
    if not sync_db.exists():
        return []

    latest: dict[str, dict] = {}
    for path in sorted(sync_db.iterdir()):
        if path.suffix not in {".log", ".ldb"} or not path.is_file():
            continue
        data = path.read_bytes()
        index = 0
        while True:
            index = data.find(SAVED_GROUP_PREFIX, index)
            if index == -1:
                break
            key_end = index + len(SAVED_GROUP_PREFIX) + 36
            guid = data[index + len(SAVED_GROUP_PREFIX) : key_end]
            if not re.fullmatch(rb"[0-9a-f-]{36}", guid):
                index += len(SAVED_GROUP_PREFIX)
                continue
            try:
                payload_len, payload_start = read_varint(data, key_end)
                payload = data[payload_start : payload_start + payload_len]
                entry = parse_saved_group_payload(payload)
                if entry:
                    previous = latest.get(entry["guid"])
                    if previous is None or int(entry["update"]) >= int(previous["update"]):
                        latest[entry["guid"]] = entry
            except Exception:
                pass
            index = key_end

    groups = [entry for entry in latest.values() if entry["kind"] == "group"]
    tabs = [entry for entry in latest.values() if entry["kind"] == "tab"]
    sessions: list[tuple[str, list[str]]] = []
    for group in sorted(groups, key=lambda item: (str(item.get("title", "")), str(item["guid"]))):
        urls = [
            str(tab["url"])
            for tab in sorted(
                [item for item in tabs if item.get("group_guid") == group["guid"]],
                key=lambda item: int(item.get("position", 0)),
            )
            if str(tab.get("url", "")).startswith(("http://", "https://"))
        ]
        sessions.append((sanitize_session_name(str(group.get("title", ""))), urls))
    return sessions


def align4(length: int) -> int:
    return (length + 3) & ~3


class SessionPickleReader:
    def __init__(self, data: bytes):
        if len(data) < 4:
            self.buffer = b""
            return
        payload_size = int.from_bytes(data[:4], "little")
        self.buffer = data[4 : 4 + payload_size]
        self.offset = 0

    def read_bytes(self, length: int) -> bytes:
        if self.offset + length > len(self.buffer):
            raise EOFError("pickle underflow")
        data = self.buffer[self.offset : self.offset + length]
        self.offset += align4(length)
        return data

    def read_int(self) -> int:
        return int.from_bytes(self.read_bytes(4), "little", signed=True)

    def read_uint32(self) -> int:
        return int.from_bytes(self.read_bytes(4), "little", signed=False)

    def read_uint64(self) -> int:
        return int.from_bytes(self.read_bytes(8), "little", signed=False)

    def read_bool(self) -> bool:
        return self.read_bytes(1)[0] != 0

    def read_string(self) -> str:
        length = self.read_int()
        if length < 0:
            raise EOFError("negative string length")
        return self.read_bytes(length).decode("utf-8", errors="ignore")

    def read_string16(self) -> str:
        length = self.read_int()
        if length < 0:
            raise EOFError("negative string16 length")
        return self.read_bytes(length * 2).decode("utf-16-le", errors="ignore")


def iter_session_commands(path: Path):
    data = path.read_bytes()
    if len(data) < 8 or data[:4] != b"SNSS":
        return
    offset = 8
    while offset + 3 <= len(data):
        size = int.from_bytes(data[offset : offset + 2], "little")
        offset += 2
        if size < 1 or offset + size > len(data):
            break
        command_id = data[offset]
        contents = data[offset + 1 : offset + size]
        offset += size
        yield command_id, contents


def extract_group_sessions_from_session_file(path: Path) -> list[tuple[str, list[str]]]:
    groups: dict[tuple[int, int], dict[str, str | int | bool]] = {}
    tab_groups: dict[int, tuple[int, int] | None] = {}
    tab_indexes: dict[int, int] = {}
    tab_navigations: dict[int, dict[int, tuple[str, str]]] = {}
    selected_navigation_indexes: dict[int, int] = {}

    for command_id, contents in iter_session_commands(path):
        try:
            if command_id == 2 and len(contents) >= 8:
                tab_id = int.from_bytes(contents[:4], "little", signed=True)
                tab_indexes[tab_id] = int.from_bytes(contents[4:8], "little", signed=True)
            elif command_id == 7:
                reader = SessionPickleReader(contents)
                tab_id = reader.read_int()
                selected_navigation_indexes[tab_id] = reader.read_int()
            elif command_id == 25 and len(contents) >= 25:
                tab_id = int.from_bytes(contents[:4], "little", signed=True)
                token = (
                    int.from_bytes(contents[8:16], "little", signed=False),
                    int.from_bytes(contents[16:24], "little", signed=False),
                )
                tab_groups[tab_id] = token if contents[24] != 0 else None
            elif command_id == 27:
                reader = SessionPickleReader(contents)
                token = (reader.read_uint64(), reader.read_uint64())
                title = reader.read_string16()
                color = reader.read_uint32()
                is_collapsed = False
                is_saved = False
                try:
                    is_collapsed = reader.read_bool()
                    is_saved = reader.read_bool()
                except EOFError:
                    pass
                groups[token] = {
                    "title": title,
                    "color": color,
                    "collapsed": is_collapsed,
                    "saved": is_saved,
                }
            elif command_id == 6:
                reader = SessionPickleReader(contents)
                tab_id = reader.read_int()
                navigation_index = reader.read_int()
                url = reader.read_string()
                title = reader.read_string16()
                tab_navigations.setdefault(tab_id, {})[navigation_index] = (url, title)
        except EOFError:
            continue

    session_rows: list[tuple[str, list[str]]] = []
    for token, metadata in sorted(groups.items(), key=lambda item: str(item[1].get("title", "")).lower()):
        title = sanitize_session_name(str(metadata.get("title", "")))
        ordered_tabs: list[tuple[int, str]] = []
        for tab_id, group_token in tab_groups.items():
            if group_token != token:
                continue
            navigations = tab_navigations.get(tab_id)
            if not navigations:
                continue
            selected_index = selected_navigation_indexes.get(tab_id)
            if selected_index is not None and selected_index in navigations:
                url, _ = navigations[selected_index]
            else:
                _, (url, _) = max(navigations.items(), key=lambda item: item[0])
            if url.startswith(("http://", "https://")):
                ordered_tabs.append((tab_indexes.get(tab_id, 1_000_000), url))
        session_rows.append((title, [url for _, url in sorted(ordered_tabs, key=lambda item: item[0])]))
    return session_rows


def extract_live_group_sessions() -> list[tuple[str, list[str]]]:
    sessions_dir = HELIUM / "Sessions"
    if not sessions_dir.exists():
        return []

    best: list[tuple[str, list[str]]] = []
    best_score: tuple[int, int, int] = (0, 0, 0)
    for path in sorted(sessions_dir.glob("Session_*")):
        if path.stat().st_size < 8:
            continue
        session_rows = extract_group_sessions_from_session_file(path)
        non_empty_groups = sum(1 for _, urls in session_rows if urls)
        total_tabs = sum(len(urls) for _, urls in session_rows)
        score = (non_empty_groups, total_tabs, path.stat().st_mtime_ns)
        if score > best_score:
            best = session_rows
            best_score = score
    return best


def read_import_manifest() -> list[str]:
    if not QUTE_HELIUM_MANIFEST.exists():
        return []
    try:
        data = json.loads(QUTE_HELIUM_MANIFEST.read_text(encoding="utf-8"))
    except Exception:
        return []
    if not isinstance(data, list):
        return []
    return [str(item) for item in data]


def write_import_manifest(session_names: list[str]) -> None:
    QUTE_HELIUM_MANIFEST.write_text(
        json.dumps(sorted(session_names), indent=2) + "\n",
        encoding="utf-8",
    )


def cleanup_old_helium_sessions():
    for session_name in read_import_manifest():
        (QUTE_SESSIONS / f"{session_name}.yml").unlink(missing_ok=True)
    for path in QUTE_SESSIONS.glob("helium*.yml"):
        path.unlink(missing_ok=True)
    for path in QUTE_SESSIONS.glob("helium*.yml.bak"):
        path.unlink(missing_ok=True)


def write_session(session_path: Path, urls: list[str], history_titles: dict[str, str]) -> int:
    now = datetime.now().replace(microsecond=0).isoformat()
    geometry = default_geometry_block().rstrip("\n")

    lines = [
        "windows:",
        "- active: true",
        "  geometry: !!binary |",
        geometry,
        "  tabs:",
    ]

    if not urls:
        session_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
        return 0

    first = True
    for url in urls:
        title = history_titles.get(url) or url
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

    session_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return len(urls)


def write_helium_sessions(history_titles: dict[str, str]) -> list[tuple[str, int]]:
    QUTE_SESSIONS.mkdir(parents=True, exist_ok=True)
    cleanup_old_helium_sessions()
    live_group_sessions = extract_live_group_sessions()
    if live_group_sessions:
        written: list[tuple[str, int]] = []
        for session_name, urls in live_group_sessions:
            count = write_session(QUTE_SESSIONS / f"{session_name}.yml", urls, history_titles)
            written.append((session_name, count))
        write_import_manifest([session_name for session_name, _ in written])
        return written

    saved_group_sessions = extract_saved_group_sessions()
    if saved_group_sessions:
        written: list[tuple[str, int]] = []
        for session_name, urls in saved_group_sessions:
            count = write_session(QUTE_SESSIONS / f"{session_name}.yml", urls, history_titles)
            written.append((session_name, count))
        write_import_manifest([session_name for session_name, _ in written])
        return written

    urls = extract_helium_urls()
    if not urls:
        write_import_manifest([])
        return []
    count = write_session(QUTE_SESSIONS / "helium.yml", urls, history_titles)
    write_import_manifest(["helium"])
    return [("helium", count)]


def default_geometry_block() -> str:
    if not QUTE_DEFAULT.exists():
        return "    AAAA\n"
    lines = QUTE_DEFAULT.read_text(encoding="utf-8").splitlines()
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


def yaml_quote(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"


def merge_cookies() -> int:
    backup = QUTE_COOKIES.with_suffix(".bak")
    shutil.copy2(QUTE_COOKIES, backup)

    db = sqlite3.connect(QUTE_COOKIES)
    try:
        db.execute("ATTACH DATABASE ? AS helium", (str(HELIUM_COOKIES),))
        before = db.execute("select count(*) from cookies").fetchone()[0]
        db.execute(
            """
            INSERT OR REPLACE INTO cookies
            SELECT creation_utc, host_key, top_frame_site_key, name, value, encrypted_value,
                   path, expires_utc, is_secure, is_httponly, last_access_utc, has_expires,
                   is_persistent, priority, samesite, source_scheme, source_port,
                   last_update_utc, source_type, has_cross_site_ancestor
            FROM helium.cookies
            """
        )
        db.commit()
        after = db.execute("select count(*) from cookies").fetchone()[0]
        db.execute("DETACH DATABASE helium")
        return after - before
    finally:
        db.close()


def main() -> None:
    history_titles = read_history_titles()
    before_bookmarks, after_bookmarks = merge_bookmarks()
    written_sessions = write_helium_sessions(history_titles)
    cookies_added = merge_cookies()
    print(
        f"Bookmarks: {before_bookmarks} -> {after_bookmarks}\n"
        + "\n".join(
            f"Session: refreshed {session_name} with {count} tabs"
            for session_name, count in written_sessions
        )
        + "\n"
        f"Cookies: merged {cookies_added} rows from Helium into qutebrowser"
    )


if __name__ == "__main__":
    main()
