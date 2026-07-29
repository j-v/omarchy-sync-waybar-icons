#!/bin/bash
# Deploy omarchy-sync-webapp-icons to the user config directory.
set -euo pipefail

INSTALL_DIR="${HOME}/.config/omarchy/hooks"
mkdir -p "$INSTALL_DIR"

cp omarchy-sync-webapp-icons "$INSTALL_DIR/omarchy-sync-webapp-icons"
chmod +x "$INSTALL_DIR/omarchy-sync-webapp-icons"

echo "Installed to $INSTALL_DIR/omarchy-sync-webapp-icons"

read -rp "Run now to sync current app windows? [Y/n] " yn
case "$yn" in
    n|N|no|No) echo "Skipped." ;;
    *) "$INSTALL_DIR/omarchy-sync-webapp-icons" ;;
esac
