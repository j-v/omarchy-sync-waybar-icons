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

This script scans running browser-app windows via `hyprctl clients`, decodes
the URL from the window class, then:

1. **If an omarchy-managed `.desktop` exists** for that URL (e.g.
   `~/.local/share/applications/Discord.desktop`) → creates a **symlink**
   from the Chrome class name to the existing entry (preserving the bundled
   icon).
2. **If no entry exists** (a site you opened manually with `--app=`) →
   downloads the site's favicon and creates a new `.desktop` entry so it
   shows up properly in Waybar and app launchers.

## Usage

```bash
# Deploy (make executable first if needed)
chmod +x deploy.sh
./deploy.sh

# Or copy manually
cp omarchy-sync-webapp-icons ~/.config/omarchy/bin/
chmod +x ~/.config/omarchy/hooks/omarchy-sync-webapp-icons

# Run
~/.config/omarchy/hooks/omarchy-sync-webapp-icons
```

Run whenever you open new web apps (or after an `omarchy refresh`). The
script is idempotent — re-running is safe.

## Future

Once subscribed to Hyprland's `openwindow` event (`hyprctl events`), this
script will also trigger automatically by placing it at
`~/.config/omarchy/hooks/post-boot.d/` or wiring it into a window event
listener. The `hooks/` directory is the natural home for this.

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

The script reverses this encoding to recover the original URL.
