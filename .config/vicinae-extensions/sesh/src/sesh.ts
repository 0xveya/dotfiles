import { exec } from "child_process";
import { getEnv } from "./env";
import { spawn } from "child_process";

const env = getEnv();

export interface Session {
  Src: string; // tmux or zoxide
  Name: string; // The display name
  Path: string; // The absolute directory path
  Score: number; // The score of the session (from Zoxide)
  Attached: number; // Whether the session is currently attached
  Windows: number; // The number of windows in the session
}

export function getSessions() {
  return new Promise<Session[]>((resolve, reject) => {
    exec(`sesh list --json`, { env }, (error, stdout, stderr) => {
      if (error || stderr) {
        console.error("stderr ", stderr);
        console.error("error ", error);
        return reject(`Please upgrade to the latest version of the sesh CLI`);
      }
      const sessions = JSON.parse(stdout);
      return resolve(sessions ?? []);
    });
  });
}

export function connectToSession(session: string): Promise<void> {
  return new Promise<void>((resolve, reject) => {
    try {
      const child = spawn(
        "kitty",
        ["--class", "sesh", "-e", "sesh", "connect", session],
        {
          env,
          detached: true,
          stdio: "ignore",
        }
      );
      child.unref();
      resolve();
    } catch (error) {
      reject(error);
    }
  });
}

export function isTmuxRunning(): Promise<boolean> {
  return new Promise<boolean>((resolve) => {
    exec(`tmux ls`, { env }, (error, _, stderr) => resolve(!(error || stderr)));
  });
}
