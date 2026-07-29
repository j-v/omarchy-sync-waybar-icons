#!/bin/bash
# Deploy scripts to ~/.local/bin/ and add watchers to Hyprland autostart.
set -euo pipefail

REPO_DIR="$(dirname "$(readlink -f "$0")")"
INSTALL_DIR="${HOME}/.local/bin"
mkdir -p "$INSTALL_DIR"

echo "=== Web App Icons ==="
if [ -f "${REPO_DIR}/omarchy-sync-webapp-icons" ]; then
    cp "${REPO_DIR}/omarchy-sync-webapp-icons" "${INSTALL_DIR}/omarchy-sync-webapp-icons"
    chmod +x "${INSTALL_DIR}/omarchy-sync-webapp-icons"
    echo "  installed omarchy-sync-webapp-icons"
fi
if [ -f "${REPO_DIR}/omarchy-watch-webapp-icons" ]; then
    cp "${REPO_DIR}/omarchy-watch-webapp-icons" "${INSTALL_DIR}/omarchy-watch-webapp-icons"
    chmod +x "${INSTALL_DIR}/omarchy-watch-webapp-icons"
    echo "  installed omarchy-watch-webapp-icons"
fi

echo ""
echo "=== TUI App Icons ==="
cp "${REPO_DIR}/omarchy-sync-tui-icons" "${INSTALL_DIR}/omarchy-sync-tui-icons"
chmod +x "${INSTALL_DIR}/omarchy-sync-tui-icons"
echo "  installed omarchy-sync-tui-icons"

cp "${REPO_DIR}/omarchy-watch-tui-icons" "${INSTALL_DIR}/omarchy-watch-tui-icons"
chmod +x "${INSTALL_DIR}/omarchy-watch-tui-icons"
echo "  installed omarchy-watch-tui-icons"

echo ""
echo "=== Hyprland Autostart ==="
AUTOSTART="${HOME}/.config/hypr/autostart.conf"

add_autostart() {
    local desc="$1" cmd="$2"
    if [ -f "$AUTOSTART" ] && grep -qF "$cmd" "$AUTOSTART" 2>/dev/null; then
        echo "  already in autostart: $desc"
    else
        echo "" >> "$AUTOSTART"
        echo "# $desc" >> "$AUTOSTART"
        echo "exec-once = $cmd" >> "$AUTOSTART"
        echo "  added to autostart: $desc"
    fi
}

add_autostart "Watch for web app .desktop entries and sync Chrome-class icons" \
    "${INSTALL_DIR}/omarchy-watch-webapp-icons"

add_autostart "Watch for TUI app .desktop entries and sync window-class icons" \
    "${INSTALL_DIR}/omarchy-watch-tui-icons"

echo ""
echo "Installed:"
echo "  ${INSTALL_DIR}/omarchy-sync-webapp-icons"
echo "  ${INSTALL_DIR}/omarchy-watch-webapp-icons"
echo "  ${INSTALL_DIR}/omarchy-sync-tui-icons"
echo "  ${INSTALL_DIR}/omarchy-watch-tui-icons"
echo ""

read -rp "Run sync now? [Y/n] " yn
case "$yn" in
    n|N|no|No) echo "Skipped." ;;
    *)
        echo ""
        echo "--- Running TUI icon sync ---"
        "${INSTALL_DIR}/omarchy-sync-tui-icons"
        echo ""
        echo "--- Running webapp icon sync ---"
        "${INSTALL_DIR}/omarchy-sync-webapp-icons"
        ;;
esac
