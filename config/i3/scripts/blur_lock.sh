#!/bin/bash
set -e
xset s off dpms 0 200 0  # It sets DPMS so the locker does not stay on forever (avoiding battery drain when just locked).

rm -f /tmp/screen_locked.png

scrot /tmp/screen_locked.png

convert /tmp/screen_locked.png -blur 0x6 /tmp/screen_locked.png

# Define the path to the Python unlock logging script (same directory as this script)
SCRIPT_DIR="$(dirname "$0")"
PYTHON_SCRIPT="$SCRIPT_DIR/log_unlock_time.py"

# Log the lock time
python3 "$PYTHON_SCRIPT" lock
#
# Define a cleanup function to prompt the user and log unlock time if "work" is selected
unlock_cleanup() {
    # Prompt the user with a Zenity dialog for work or leisure
    zenity --question --text="Is this a work session?" --ok-label="Work" --cancel-label="Leisure" --timeout=10
    response=$?

    # If OK was pressed (0), or if Enter was pressed (timeout code 5), consider it "Work"
    if [[ $response -eq 0 || $response -eq 5 ]]; then
        python3 "$PYTHON_SCRIPT" unlock
    else
        echo "Session marked as leisure; unlock time not logged."
    fi
}

# Set up a trap to call the unlock_cleanup function after i3lock exits (i.e., on unlock)
trap unlock_cleanup EXIT

# Run i3lock with your custom lock screen image
i3lock -i /tmp/screen_locked.png --show-failed-attempts --ignore-empty-password --nofork

# Restore DPMS settings after unlocking
xset s off -dpms

