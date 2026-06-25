# Copy this file to:
#   ~/.config/clamshell-iphone-mic/config.sh
#
# Find input device UIDs with:
#   /opt/homebrew/bin/SwitchAudioSource -a -t input -f json

IPHONE_MIC_UID="PASTE_YOUR_IPHONE_MIC_UID_HERE"

# Apple Silicon Homebrew default:
SWITCH_AUDIO_SOURCE="/opt/homebrew/bin/SwitchAudioSource"

# Intel Homebrew users may need:
# SWITCH_AUDIO_SOURCE="/usr/local/bin/SwitchAudioSource"
