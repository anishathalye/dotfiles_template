#!/bin/bash
if [[ $1 =~ ^[[:digit:]]+$ ]]; then
  MAX_TITLE_WIDTH=$1
else
  MAX_TITLE_WIDTH=$(($(tmux display -p '#{window_width}') - 80))
fi

if cmus-remote -Q > /dev/null 2> /dev/null; then
  CMUS_STATUS=$(cmus-remote -Q)
  STATUS=$(echo "$CMUS_STATUS" | grep status | head -n 1 | cut -d' ' -f2-)
  ARTIST=$(echo "$CMUS_STATUS" | grep 'tag artist' | head -n 1 | cut -d' ' -f3-)
  TITLE=$(echo "$CMUS_STATUS" | grep 'tag title' | cut -d' ' -f3-)
  if [ -n "$TITLE" ]; then
    OUTPUT="$ARTIST - $TITLE"

    # Only show the song title if we are over $MAX_TITLE_WIDTH characters
    if [ "${#OUTPUT}" -ge $MAX_TITLE_WIDTH ]; then
      OUTPUT="${TITLE:0:$MAX_TITLE_WIDTH-3}..."
    fi

    if [ "$STATUS" = "playing" ]; then
      OUTPUT="[▶ $OUTPUT]"
    else
      OUTPUT="[❚❚$OUTPUT]"
    fi
  else
    OUTPUT=''
  fi
fi
echo $OUTPUT
