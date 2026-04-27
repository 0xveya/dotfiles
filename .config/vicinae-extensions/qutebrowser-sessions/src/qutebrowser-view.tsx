import {
  Action,
  ActionPanel,
  Alert,
  closeMainWindow,
  confirmAlert,
  Icon,
  Keyboard,
  List,
  PopToRootType,
  Toast,
  showToast,
} from "@vicinae/api";
import { useEffect, useState } from "react";
import type { BrowserSession, SessionTab } from "./lib";
import {
  deleteSession,
  focusActiveTab,
  getAutosaveSession,
  getSessions,
  sessionMarkdown,
} from "./lib";

const SESSION_LIST_LINK =
  "vicinae://extensions/veya/qutebrowser-sessions/qutebrowser-sessions";
const ALL_TABS_LINK =
  "vicinae://extensions/veya/qutebrowser-sessions/search-session-tabs";
const ACTIVE_TABS_LINK =
  "vicinae://extensions/veya/qutebrowser-sessions/active-session-tabs";

type SessionTabEntry = SessionTab & {
  session: BrowserSession;
};

function sessionAccessories(session: BrowserSession): List.Item.Accessory[] {
  const accessories: List.Item.Accessory[] = [
    {
      icon: Icon.AppWindow,
      text: `${session.windowCount}`,
      tooltip: session.windowCount === 1 ? "Window" : "Windows",
    },
    {
      icon: Icon.CheckList,
      text: `${session.tabCount}`,
      tooltip: session.tabCount === 1 ? "Tab" : "Tabs",
    },
  ];

  if (session.isAutosave) {
    accessories.push({
      tag: { value: "autosave" },
      tooltip: "Autosave session",
    });
  }

  if (session.isMalformed) {
    accessories.push({
      tag: { value: "broken" },
      tooltip: "Malformed session file",
    });
  }

  return accessories;
}

function minimalTabDetail(entry: SessionTabEntry) {
  return (
    <List.Item.Detail
      markdown={[
        `# ${entry.title}`,
        "",
        entry.url || "_No URL_",
        "",
        `Session: \`${entry.session.name}\``,
      ].join("\n")}
      metadata={
        <List.Item.Detail.Metadata>
          <List.Item.Detail.Metadata.Label
            title="Session"
            text={entry.session.name}
            icon={Icon.Bookmark}
          />
          <List.Item.Detail.Metadata.Label
            title="Location"
            text={`w${entry.windowIndex}:t${entry.tabIndex}`}
            icon={Icon.AppWindow}
          />
          <List.Item.Detail.Metadata.Link
            title="URL"
            text={entry.url || "(empty)"}
            target={entry.url || "about:blank"}
          />
        </List.Item.Detail.Metadata>
      }
    />
  );
}

function sessionDetail(session: BrowserSession) {
  return (
    <List.Item.Detail
      markdown={sessionMarkdown(session)}
      metadata={
        <List.Item.Detail.Metadata>
          <List.Item.Detail.Metadata.Label title="File" text={session.path} icon={Icon.BlankDocument} />
          <List.Item.Detail.Metadata.Label
            title="Tabs"
            text={String(session.tabCount)}
            icon={Icon.CheckList}
          />
          <List.Item.Detail.Metadata.Label
            title="Windows"
            text={String(session.windowCount)}
            icon={Icon.AppWindow}
          />
        </List.Item.Detail.Metadata>
      }
    />
  );
}

async function deleteSessionWithConfirm(session: BrowserSession, refresh: () => Promise<void>) {
  const confirmed = await confirmAlert({
    title: `Delete "${session.name}"?`,
    message: "The session YAML file will be removed from disk.",
    primaryAction: {
      title: "Delete",
      style: Alert.ActionStyle.Destructive,
    },
  });

  if (!confirmed) {
    return;
  }

  try {
    await deleteSession(session.name);
    await refresh();
  } catch (error) {
    await showToast({
      style: Toast.Style.Failure,
      title: "Couldn't delete session",
      message: error instanceof Error ? error.message : "Unknown error",
    });
  }
}

export function QutebrowserSessionsView() {
  const [sessions, setSessions] = useState<BrowserSession[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  async function refresh() {
    try {
      setSessions(await getSessions());
    } catch (error) {
      await showToast({
        style: Toast.Style.Failure,
        title: "Couldn't read qutebrowser sessions",
        message: error instanceof Error ? error.message : "Unknown error",
      });
    } finally {
      setIsLoading(false);
    }
  }

  useEffect(() => {
    void refresh();
  }, []);

  return (
    <List isLoading={isLoading} isShowingDetail searchBarPlaceholder="Search sessions...">
      {sessions.length === 0 ? (
        <List.EmptyView
          title="No saved sessions"
          description="Create a session with :session-save and it will appear here."
          icon={Icon.Bookmark}
        />
      ) : null}
      {sessions.map((session) => (
        <List.Item
          key={session.path}
          id={session.name}
          title={session.name}
          subtitle={session.isAutosave ? "autosave" : undefined}
          keywords={[session.path, ...session.tabs.flatMap((tab) => [tab.title, tab.url])]}
          icon={session.isMalformed ? Icon.Exclamationmark : session.isAutosave ? Icon.Clock : Icon.Bookmark}
          accessories={sessionAccessories(session)}
          detail={sessionDetail(session)}
          actions={
            <ActionPanel>
              <Action
                title="Load Session"
                icon={Icon.ArrowRight}
                onAction={async () => {
                  try {
                    await closeMainWindow({ popToRootType: PopToRootType.Immediate });
                    await import("./lib").then(({ loadSession }) => loadSession(session.name, false));
                  } catch (error) {
                    await showToast({
                      style: Toast.Style.Failure,
                      title: "Couldn't load session",
                      message: error instanceof Error ? error.message : "Unknown error",
                    });
                  }
                }}
              />
              <Action
                title="Delete Session"
                icon={Icon.Trash}
                style={Action.Style.Destructive}
                shortcut={{ modifiers: ["ctrl"], key: "b" }}
                onAction={() => void deleteSessionWithConfirm(session, refresh)}
              />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}

function dedupeTabs(entries: SessionTabEntry[]) {
  const winners = new Map<string, SessionTabEntry>();
  for (const entry of entries) {
    const key = `${entry.title}\u0000${entry.url}`;
    const current = winners.get(key);
    if (!current) {
      winners.set(key, entry);
      continue;
    }
    if (current.session.isAutosave && !entry.session.isAutosave) {
      winners.set(key, entry);
      continue;
    }
    if (current.session.name > entry.session.name) {
      winners.set(key, entry);
    }
  }
  return [...winners.values()];
}

export function SessionTabsView() {
  const [tabs, setTabs] = useState<SessionTabEntry[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  async function refresh() {
    try {
      const sessions = await getSessions();
      const flattened = sessions.flatMap((session) =>
        session.tabs.map((tab) => ({
          ...tab,
          session,
        })),
      );
      setTabs(dedupeTabs(flattened));
    } catch (error) {
      await showToast({
        style: Toast.Style.Failure,
        title: "Couldn't read session tabs",
        message: error instanceof Error ? error.message : "Unknown error",
      });
    } finally {
      setIsLoading(false);
    }
  }

  useEffect(() => {
    void refresh();
  }, []);

  return (
    <List isLoading={isLoading} isShowingDetail searchBarPlaceholder="Search tabs across sessions...">
      {tabs.length === 0 ? (
        <List.EmptyView
          title="No saved tabs"
          description="Sessions with tabs will appear here once qutebrowser sessions exist."
          icon={Icon.CheckList}
        />
      ) : null}
      {tabs.map((entry) => (
        <List.Item
          key={`${entry.session.path}:${entry.globalIndex}`}
          title={entry.title}
          subtitle={entry.session.name}
          keywords={[entry.url, entry.session.name]}
          icon={Icon.AppWindow}
          accessories={[{ text: `w${entry.windowIndex}:t${entry.tabIndex}` }]}
          detail={minimalTabDetail(entry)}
          actions={
            <ActionPanel>
              <Action
                title="Load Session"
                icon={Icon.ArrowRight}
                onAction={async () => {
                  try {
                    await closeMainWindow({ popToRootType: PopToRootType.Immediate });
                    await import("./lib").then(({ loadSession }) => loadSession(entry.session.name, false));
                  } catch (error) {
                    await showToast({
                      style: Toast.Style.Failure,
                      title: "Couldn't load session",
                      message: error instanceof Error ? error.message : "Unknown error",
                    });
                  }
                }}
              />
              <Action.Open title="Active Session Tabs" icon={Icon.Clock} target={ACTIVE_TABS_LINK} />
              <Action.Open title="Session Switcher" icon={Icon.Bookmark} target={SESSION_LIST_LINK} />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}

export function ActiveSessionTabsView() {
  const [session, setSession] = useState<BrowserSession | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  async function refresh() {
    try {
      setSession((await getAutosaveSession()) ?? null);
    } catch (error) {
      await showToast({
        style: Toast.Style.Failure,
        title: "Couldn't read active session tabs",
        message: error instanceof Error ? error.message : "Unknown error",
      });
    } finally {
      setIsLoading(false);
    }
  }

  useEffect(() => {
    void refresh();
  }, []);

  return (
    <List isLoading={isLoading} isShowingDetail searchBarPlaceholder="Search tabs in active session...">
      {!session || session.tabs.length === 0 ? (
        <List.EmptyView
          title="No active session tabs"
          description="This reads qutebrowser's autosaved session."
          icon={Icon.Clock}
        />
      ) : null}
      {session?.tabs.map((tab) => {
        const entry: SessionTabEntry = { ...tab, session };
        return (
          <List.Item
            key={`${session.path}:${tab.globalIndex}`}
            title={tab.title}
            subtitle={tab.url || undefined}
            keywords={[session.name, tab.url]}
            icon={Icon.AppWindow}
            accessories={[{ text: `w${tab.windowIndex}:t${tab.tabIndex}` }]}
            detail={minimalTabDetail(entry)}
            actions={
              <ActionPanel>
                <Action
                  title="Focus Tab"
                  icon={Icon.ArrowRight}
                  onAction={async () => {
                    try {
                      await focusActiveTab(tab);
                      await closeMainWindow({ popToRootType: PopToRootType.Immediate });
                    } catch (error) {
                      await showToast({
                        style: Toast.Style.Failure,
                        title: "Couldn't focus tab",
                        message: error instanceof Error ? error.message : "Unknown error",
                      });
                    }
                  }}
                />
                <Action.Open title="All Session Tabs" icon={Icon.CheckList} target={ALL_TABS_LINK} />
                <Action.Open title="Session Switcher" icon={Icon.Bookmark} target={SESSION_LIST_LINK} />
              </ActionPanel>
            }
          />
        );
      })}
    </List>
  );
}
