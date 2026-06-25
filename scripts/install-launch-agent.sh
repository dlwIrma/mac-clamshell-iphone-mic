#!/usr/bin/env bash
set -euo pipefail

LABEL="${LABEL:-io.github.clamshell-iphone-mic}"
INTERVAL="${INTERVAL:-10}"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT_PATH="$PROJECT_DIR/scripts/clamshell-iphone-mic.sh"
CONFIG_PATH="${CLAMSHELL_IPHONE_MIC_CONFIG:-$HOME/.config/clamshell-iphone-mic/config.sh}"
PLIST_PATH="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG_DIR="$HOME/Library/Logs"

if [[ ! "$INTERVAL" =~ ^[0-9]+$ || "$INTERVAL" -lt 1 ]]; then
    echo "INTERVAL must be a positive integer." >&2
    exit 1
fi

if [[ ! -r "$CONFIG_PATH" ]]; then
    mkdir -p "$(dirname "$CONFIG_PATH")"
    cp "$PROJECT_DIR/config.example.sh" "$CONFIG_PATH"
    echo "Created $CONFIG_PATH."
    echo "Edit IPHONE_MIC_UID in that file, then run this installer again."
    exit 1
fi

chmod +x "$SCRIPT_PATH"
mkdir -p "$(dirname "$PLIST_PATH")" "$LOG_DIR"

cat > "$PLIST_PATH" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>

    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$SCRIPT_PATH</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>StartInterval</key>
    <integer>$INTERVAL</integer>

    <key>StandardOutPath</key>
    <string>$LOG_DIR/$LABEL.out.log</string>

    <key>StandardErrorPath</key>
    <string>$LOG_DIR/$LABEL.err.log</string>
</dict>
</plist>
PLIST

launchctl bootout "gui/$(id -u)" "$PLIST_PATH" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST_PATH"
launchctl enable "gui/$(id -u)/$LABEL"
launchctl kickstart -k "gui/$(id -u)/$LABEL"

echo "Installed $LABEL."
echo "LaunchAgent: $PLIST_PATH"
