#!/usr/bin/env bash
set -u

CONFIG_FILE="${CLAMSHELL_IPHONE_MIC_CONFIG:-$HOME/.config/clamshell-iphone-mic/config.sh}"

if [[ -r "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    . "$CONFIG_FILE"
fi

SWITCH_AUDIO_SOURCE="${SWITCH_AUDIO_SOURCE:-/opt/homebrew/bin/SwitchAudioSource}"
IPHONE_MIC_UID="${IPHONE_MIC_UID:-}"
RESTORE_MIC_UID="${RESTORE_MIC_UID:-}"
STATE_DIR="${CLAMSHELL_IPHONE_MIC_STATE_DIR:-$HOME/Library/Application Support/clamshell-iphone-mic}"
ACTIVE_MARKER="$STATE_DIR/active"
PREVIOUS_INPUT_UID_FILE="$STATE_DIR/previous-input-uid"

is_lid_closed() {
    ioreg -r -k AppleClamshellState -d 4 | grep -q '"AppleClamshellState" = Yes'
}

has_online_display() {
    system_profiler SPDisplaysDataType -json 2>/dev/null |
        grep -q '"spdisplays_online"[[:space:]]*:[[:space:]]*"spdisplays_yes"'
}

is_clamshell_desktop_mode() {
    is_lid_closed && has_online_display
}

current_input_uid() {
    "$SWITCH_AUDIO_SOURCE" -c -t input -f json 2>/dev/null |
        sed -n 's/.*"uid"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'
}

switch_input() {
    local uid="$1"

    if [[ -n "$uid" ]]; then
        "$SWITCH_AUDIO_SOURCE" -t input -u "$uid"
    fi
}

restore_previous_input_if_needed() {
    local restore_uid="$RESTORE_MIC_UID"

    if [[ ! -f "$ACTIVE_MARKER" ]]; then
        exit 0
    fi

    if [[ -z "$restore_uid" && -r "$PREVIOUS_INPUT_UID_FILE" ]]; then
        restore_uid="$(cat "$PREVIOUS_INPUT_UID_FILE")"
    fi

    if [[ -n "$restore_uid" && "$restore_uid" != "$IPHONE_MIC_UID" ]]; then
        switch_input "$restore_uid"
    fi

    rm -f "$ACTIVE_MARKER" "$PREVIOUS_INPUT_UID_FILE"
}

if [[ ! -x "$SWITCH_AUDIO_SOURCE" ]]; then
    echo "SwitchAudioSource not found or not executable: $SWITCH_AUDIO_SOURCE" >&2
    exit 1
fi

if ! is_clamshell_desktop_mode; then
    restore_previous_input_if_needed
    exit 0
fi

if [[ -z "$IPHONE_MIC_UID" || "$IPHONE_MIC_UID" == "PASTE_YOUR_IPHONE_MIC_UID_HERE" ]]; then
    echo "IPHONE_MIC_UID is not configured. Edit $CONFIG_FILE." >&2
    exit 1
fi

mkdir -p "$STATE_DIR"

if [[ ! -f "$ACTIVE_MARKER" ]]; then
    previous_uid="$(current_input_uid)"
    if [[ -n "$previous_uid" && "$previous_uid" != "$IPHONE_MIC_UID" ]]; then
        printf '%s\n' "$previous_uid" > "$PREVIOUS_INPUT_UID_FILE"
    fi
    date '+%Y-%m-%dT%H:%M:%S%z' > "$ACTIVE_MARKER"
fi

switch_input "$IPHONE_MIC_UID"
