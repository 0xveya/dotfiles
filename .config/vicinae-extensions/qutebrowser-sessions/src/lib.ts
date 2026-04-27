import { homedir } from "node:os";
import path from "node:path";
import { readdir, readFile, rm } from "node:fs/promises";
import { execa } from "execa";
import YAML from "yaml";

export type SessionTab = {
  globalIndex: number;
  windowIndex: number;
  tabIndex: number;
  title: string;
  url: string;
};

export type BrowserSession = {
  name: string;
  path: string;
  tabCount: number;
  tabs: SessionTab[];
  isAutosave: boolean;
  isMalformed: boolean;
  error?: string;
  windowCount: number;
};

const HOME = homedir();
const DATA_HOME = process.env.XDG_DATA_HOME || path.join(HOME, ".local", "share");
export const SESSION_DIR = path.join(DATA_HOME, "qutebrowser", "sessions");

export function getSessionPath(name: string) {
  return path.join(SESSION_DIR, `${name}.yml`);
}

export function normalizeSessionName(raw: string) {
  const trimmed = raw.trim().replace(/\.yml$/i, "");
  if (!trimmed) {
    throw new Error("Session name cannot be empty.");
  }
  if (trimmed === "." || trimmed === "..") {
    throw new Error("Session name is invalid.");
  }
  if (trimmed.includes("/") || trimmed.includes("\\")) {
    throw new Error("Session names cannot contain path separators.");
  }
  return trimmed;
}

function asRecord(value: unknown): Record<string, unknown> {
  if (value && typeof value === "object" && !Array.isArray(value)) {
    return value as Record<string, unknown>;
  }
  return {};
}

function asArray(value: unknown): unknown[] {
  return Array.isArray(value) ? value : [];
}

function getCurrentHistoryEntry(tab: unknown) {
  const history = asArray(asRecord(tab).history);
  const activeEntry =
    history.find((entry) => Boolean(asRecord(entry).active)) ?? history.at(-1);
  return asRecord(activeEntry);
}

function parseTabs(data: unknown) {
  const tabs: SessionTab[] = [];
  const windows = asArray(asRecord(data).windows);

  for (const [windowOffset, windowValue] of windows.entries()) {
    const sessionWindow = asRecord(windowValue);
    const windowTabs = asArray(sessionWindow.tabs);
    for (const [tabOffset, tabValue] of windowTabs.entries()) {
      const entry = getCurrentHistoryEntry(tabValue);
      const title = String(entry.title ?? "(no title)");
      const url = String(entry.url ?? "");
      tabs.push({
        globalIndex: tabs.length + 1,
        windowIndex: windowOffset + 1,
        tabIndex: tabOffset + 1,
        title,
        url,
      });
    }
  }

  return {
    tabs,
    windowCount: windows.length,
  };
}

export async function getSessions() {
  let entries: string[] = [];
  try {
    entries = await readdir(SESSION_DIR);
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === "ENOENT") {
      return [];
    }
    throw error;
  }

  const sessions = await Promise.all(
    entries
      .filter((entry) => entry.endsWith(".yml"))
      .map(async (entry): Promise<BrowserSession> => {
        const sessionPath = path.join(SESSION_DIR, entry);
        const name = path.basename(entry, ".yml");
        try {
          const raw = await readFile(sessionPath, "utf8");
          const parsed = YAML.parse(raw) ?? {};
          const { tabs, windowCount } = parseTabs(parsed);
          return {
            name,
            path: sessionPath,
            tabCount: tabs.length,
            tabs,
            isAutosave: name === "_autosave",
            isMalformed: false,
            windowCount,
          };
        } catch (error) {
          return {
            name,
            path: sessionPath,
            tabCount: 0,
            tabs: [],
            isAutosave: name === "_autosave",
            isMalformed: true,
            error: error instanceof Error ? error.message : "Unknown parse error",
            windowCount: 0,
          };
        }
      }),
  );

  return sessions.sort((left, right) => {
    if (left.isAutosave !== right.isAutosave) {
      return left.isAutosave ? 1 : -1;
    }
    return left.name.localeCompare(right.name);
  });
}

export async function getSession(name: string) {
  const sessions = await getSessions();
  return sessions.find((session) => session.name === normalizeSessionName(name));
}

export async function getAutosaveSession() {
  return getSession("_autosave");
}

export async function runQutebrowserCommand(command: string) {
  await execa("qutebrowser", [`:${command}`]);
}

export async function focusActiveTab(tab: SessionTab) {
  const needle = tab.url || tab.title;
  const escapedNeedle = needle.replace(/"/g, '\\"');
  await runQutebrowserCommand(`tab-select "${escapedNeedle}"`);
}

export async function loadSession(name: string, clear = false) {
  const sessionName = normalizeSessionName(name);
  const flag = clear ? "--clear " : "";
  await runQutebrowserCommand(`session-load ${flag}${sessionName}`);
}

export async function saveSession(name: string, onlyActiveWindow = false) {
  const sessionName = normalizeSessionName(name);
  const flag = onlyActiveWindow ? "--only-active-window " : "";
  await runQutebrowserCommand(`session-save ${flag}${sessionName}`);
}

export async function deleteSession(name: string) {
  await rm(getSessionPath(normalizeSessionName(name)), { force: true });
}

export function sessionMarkdown(session: BrowserSession) {
  if (session.isMalformed) {
    return [
      `# ${escapeMarkdown(session.name)}`,
      "",
      "Malformed or unreadable session file.",
      "",
      "```",
      session.error ?? "Unknown parse error",
      "```",
    ].join("\n");
  }

  if (session.tabs.length === 0) {
    return [
      `# ${escapeMarkdown(session.name)}`,
      "",
      "_This session has no tabs._",
    ].join("\n");
  }

  const lines = [`# ${escapeMarkdown(session.name)}`, ""];
  for (const tab of session.tabs) {
    lines.push(
      `- \`w${tab.windowIndex}:t${tab.tabIndex}\` ${escapeMarkdown(tab.title)}`,
      `  ${tab.url || "_No URL_"}`,
    );
  }
  return lines.join("\n");
}

function escapeMarkdown(text: string) {
  return text.replace(/[\\`*_{}[\]()#+\-.!|>]/g, "\\$&");
}
