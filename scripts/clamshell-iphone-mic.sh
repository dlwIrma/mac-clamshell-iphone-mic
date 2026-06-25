#!/usr/bin/env bash
set -u

CONFIG_FILE="${CLAMSHELL_IPHONE_MIC_CONFIG:-$HOME/.config/clamshell-iphone-mic/config.sh}"

if [[ -r "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    . "$CONFIG_FILE"
fi

SWITCH_AUDIO_SOURCE="${SWITCH_AUDIO_SOURCE:-/opt/homebrew/bin/SwitchAudioSource}"
IPHONE_MIC_UID="${IPHONE_MIC_UID:-}"

is_lid_closed() {
    ioreg -r -k AppleClamshellState -d 4 | grep -q '"AppleClamshellState" = Yes'
}

if ! is_lid_closed; then
    exit 0
fi

if [[ -z "$IPHONE_MIC_UID" || "$IPHONE_MIC_UID" == "PASTE_YOUR_IPHONE_MIC_UID_HERE" ]]; then
    echo "IPHONE_MIC_UID is not configured. Edit $CONFIG_FILE." >&2
    exit 1
fi

if [[ ! -x "$SWITCH_AUDIO_SOURCE" ]]; then
    echo "SwitchAudioSource not found or not executable: $SWITCH_AUDIO_SOURCE" >&2
    exit 1
fi

"$SWITCH_AUDIO_SOURCE" -t input -u "$IPHONE_MIC_UID"
