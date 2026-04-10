# Sesh

## Description

This is an extension for Raycast/Vicinae to manage terminal sessions.

## Features

- Switch to tmux sessions
- Create new tmux sessions from zoxide results
- Open your terminal emulator on Linux with a configurable command

## How to use

1. Install [Raycast](https://raycast.com/) or Vicinae
2. Install [Sesh](https://github.com/joshmedeski/sesh)
3. Install [Extension](https://www.raycast.com/raycast)
4. Open Raycast and type "Connect to Session `sesh`" to connect to a session
5. Set "Terminal Command" to the terminal command you want to use. The default is `kitty --class sesh -e sesh connect {session}`.

**Note:** due to limitations with Raycast, tmux has to be running before you can use this extension.
