# omarchy-sync-webapp-icons

Sync `.desktop` entries for Chrome-based browser-app windows so
[Waybar](https://github.com/Alexays/Waybar)'s taskbar shows correct app icons
instead of the default browser icon.

## Problem

When Omarchy launches a web app (Discord, ChatGPT, etc.) via
`omarchy-launch-webapp`, Chrome opens it with `--app=<url>`. The resulting
window gets a class like `chrome-discord.com__channels_@me-Default` (encoding
the URL), but **no matching `.desktop` file exists** for that class name.
Waybar's taskbar can't find a matching icon and falls back to the generic
browser icon.

Chromium-installed PWAs work correctly because Chromium creates a
`.desktop` entry with a matching class name at install time.

## Solution

Two scripts:

**`omarchy-sync-webapp-icons`** — scans all omarchy `.desktop` files,
computes the Chrome class name from the URL, and creates a symlink. Also
scans running `--app` windows for any ad-hoc apps (non-omarchy) and creates
desktop entries with downloaded favicons.

**`omarchy-watch-webapp-icons`** — uses `inotifywait` to detect new
`.desktop` files and runs the sync script automatically.

## Usage

```bash
# Deploy sync and watcher scripts, enable run on Hyprland start
chmod +x deploy.sh
./deploy.sh

# Run once
~/.local/bin/omarchy-sync-webapp-icons

# Start watcher immediatedly
hyprctl dispatch exec ~/.local/bin/omarchy-watch-webapp-icons
```

After deployment, the watcher starts automatically with Hyprland. 

## How It Works

Chrome encodes the URL in the window class following this pattern:

| Window class                                     | Decoded URL                            |
|--------------------------------------------------|----------------------------------------|
| `chrome-discord.com__channels_@me-Default`       | `https://discord.com/channels/@me`     |
| `chrome-chatgpt.com__-Default`                   | `https://chatgpt.com/`                 |
| `chrome-reddit.com__r_hyprland-Default`          | `https://reddit.com/r/hyprland`        |

- Protocol (`https://`) is stripped
- First `/` in the path → `__` (double underscore)
- Subsequent `/` → `_` (single underscore)
- Prefixed with `chrome-` (or `brave-`, `msedge-`, etc.), suffixed with
  `-Default`

The sync script runs this encoding in reverse (URL → class) to create
symlinks, and in forward (class → URL) for ad-hoc windows.
