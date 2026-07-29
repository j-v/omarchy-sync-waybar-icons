# omarchy-sync-waybar-icons

Sync `.desktop` entries so [Waybar](https://github.com/Alexays/Waybar)'s taskbar
shows correct app icons for web apps and TUI apps instead of generic fallbacks.

## Problem

Waybar's `workspace-taskbar` resolves a window's icon by matching its WM class
to a `.desktop` file. Two categories of apps fail this lookup:

**Web apps** launched via `omarchy-launch-webapp` get a Chrome-generated class
like `chrome-discord.com__channels_@me-Default` — no matching `.desktop` file
exists, so Waybar falls back to the browser icon.

**TUI apps** (terminal UI) run inside a terminal. The window class is always the
terminal's (`com.mitchellh.ghostty`, `Alacritty`, etc.), so Waybar shows the
terminal icon regardless of which TUI app is running.

## Solution

### Web Apps (two scripts)

**`omarchy-sync-webapp-icons`** — scans all omachy `.desktop` files,
computes the Chrome class name from the URL, and creates a shadow entry. Also
scans running `--app` windows for ad-hoc apps and creates entries with
downloaded favicons.

**`omarchy-watch-webapp-icons`** — watches for new `.desktop` files and runs
the sync automatically.

### TUI Apps (two scripts)

**`omarchy-sync-tui-icons`** — three phases:

1. **Patch** — rewrites installed TUI `.desktop` files that use shared window
   classes (`TUI.float` / `TUI.tile`) to use unique per-app IDs
   (`org.omarchy.tui.tile.Docker`), so each app gets its own icon.

2. **Override** — auto-discovers all system `.desktop` files with
   `Terminal=true` and creates local overrides that wrap the app with
   `omarchy-launch-tui`, giving it a unique window class
   (`org.omarchy.micro`, `org.omarchy.yazi`, etc.). Exclude apps by adding
   their desktop ID to `~/.config/omarchy/tui-icons-ignore.list`.

3. **Shadow** — creates `NoDisplay=true` shadow `.desktop` entries matching each
   TUI app's window class to its correct icon, so Waybar's taskbar can resolve
   it.

**`omarchy-watch-tui-icons`** — monitors `~/.local/share/applications/` with
`inotifywait -m` and runs the sync on any change.

## Usage

```bash
# Deploy all scripts and enable watchers on Hyprland start
chmod +x deploy.sh
./deploy.sh

# Run web app sync manually
~/.local/bin/omarchy-sync-webapp-icons

# Run TUI sync manually
~/.local/bin/omarchy-sync-tui-icons

# Start watchers immediately
hyprctl dispatch exec ~/.local/bin/omarchy-watch-webapp-icons
hyprctl dispatch exec ~/.local/bin/omarchy-watch-tui-icons
```

After deployment, both watchers start automatically with Hyprland. The TUI
watcher also adds a Hyprland window rule to float apps with class
`org.omarchy.tui.float.*`.

## Excluding TUI Apps

To prevent a system `Terminal=true` app from being wrapped (e.g., NordVPN which
is a URL handler rather than a TUI):

```bash
echo "nordvpn" >> ~/.config/omarchy/tui-icons-ignore.list
~/.local/bin/omarchy-sync-tui-icons
```

## How Web App Icons Work

Chrome encodes the URL in the window class:

| Window class                                     | Decoded URL                            |
|--------------------------------------------------|----------------------------------------|
| `chrome-discord.com__channels_@me-Default`       | `https://discord.com/channels/@me`     |
| `chrome-chatgpt.com__-Default`                   | `https://chatgpt.com/`                 |
| `chrome-reddit.com__r_hyprland-Default`          | `https://reddit.com/r/hyprland`        |

- Protocol (`https://`) stripped
- First `/` in path → `__` (double underscore)
- Subsequent `/` → `_` (single underscore)
- Prefixed with `chrome-` (or `brave-`, `msedge-`, etc.), suffixed with `-Default`

The sync script runs this encoding in reverse (URL → class) to create shadow
entries, and in forward (class → URL) for ad-hoc windows.

## How TUI App Icons Work

TUI apps installed via `omarchy-tui-install` get window classes
`TUI.float` / `TUI.tile` (shared by all apps). Phase 1 rewrites these to
`org.omarchy.tui.<style>.<Name>` for per-app icon resolution.

System TUI apps (installed via pacman) have `.desktop` files with
`Terminal=true`. When launched, the desktop environment opens the default
terminal, which sets its own window class — making per-app icon matching
impossible. Phase 2 creates local `.desktop` overrides that redirect the
launch through `omarchy-launch-tui`, which sets a unique window class
(`org.omarchy.<cmd>`). Phase 3 then creates shadow entries that map each class
to the correct icon.

## Files

| Script | Purpose |
|--------|---------|
| `omarchy-sync-webapp-icons` | Create shadow entries for Chrome-based web apps |
| `omarchy-watch-webapp-icons` | Watcher for new web app `.desktop` files |
| `omarchy-sync-tui-icons` | Patch, override, and create shadows for TUI apps |
| `omarchy-watch-tui-icons` | Watcher for TUI `.desktop` changes |
| `deploy.sh` | Install all scripts and configure Hyprland autostart |
