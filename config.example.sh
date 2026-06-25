# Copy this file to:
#   ~/.config/clamshell-iphone-mic/config.sh
#
# Find input device UIDs with:
#   /opt/homebrew/bin/SwitchAudioSource -a -t input -f json

IPHONE_MIC_UID="PASTE_YOUR_IPHONE_MIC_UID_HERE"

# Optional.
# Leave this empty to restore whatever input device was active before the
# script switched to the iPhone Continuity Microphone.
#
# Set this to a known microphone UID if you always want to restore to a
# specific device when leaving clamshell desktop mode.
RESTORE_MIC_UID=""

# Apple Silicon Homebrew default:
SWITCH_AUDIO_SOURCE="/opt/homebrew/bin/SwitchAudioSource"

# Intel Homebrew users may need:
# SWITCH_AUDIO_SOURCE="/usr/local/bin/SwitchAudioSource"
