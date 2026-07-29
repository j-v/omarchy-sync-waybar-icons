#!/bin/bash
# Deploy scripts to ~/.local/bin/ and add watcher to Hyprland autostart.
set -euo pipefail

INSTALL_DIR="${HOME}/.local/bin"
mkdir -p "$INSTALL_DIR"

cp omarchy-sync-webapp-icons "$INSTALL_DIR/omarchy-sync-webapp-icons"
chmod +x "$INSTALL_DIR/omarchy-sync-webapp-icons"

cp omarchy-watch-webapp-icons "$INSTALL_DIR/omarchy-watch-webapp-icons"
chmod +x "$INSTALL_DIR/omarchy-watch-webapp-icons"

echo "Installed:"
echo "  $INSTALL_DIR/omarchy-sync-webapp-icons"
echo "  $INSTALL_DIR/omarchy-watch-webapp-icons"

AUTOSTART="$HOME/.config/hypr/autostart.conf"
if [ -f "$AUTOSTART" ] && grep -q "omarchy-watch-webapp-icons" "$AUTOSTART" 2>/dev/null; then
    echo "Watcher already in Hyprland autostart."
else
    echo "" >> "$AUTOSTART"
    echo "# Watch for new web app .desktop entries and sync Chrome-class icons" >> "$AUTOSTART"
    echo "exec-once = ${INSTALL_DIR}/omarchy-watch-webapp-icons" >> "$AUTOSTART"
    echo "Added watcher to Hyprland autostart ($AUTOSTART)"
fi

read -rp "Run sync now? [Y/n] " yn
case "$yn" in
    n|N|no|No) echo "Skipped." ;;
    *) "$INSTALL_DIR/omarchy-sync-webapp-icons" ;;
esac
