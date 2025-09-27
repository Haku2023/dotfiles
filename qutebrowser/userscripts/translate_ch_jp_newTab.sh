#!/bin/bash
# Qutebrowser userscript to look up selected text using sdcv
# This version outputs the full definition to a new Qutebrowser buffer (:output)

WORD="${QUTE_SELECTED_TEXT:-$QUTE_WORD}"

if [ -n "$WORD" ]; then
    # Define the dictionaries you want to use
    CHINESE_DICT="朗道英汉字典5.0"
    JAPANESE_EN_JA_DICT="jmdict-en-ja"

    # Construct the sdcv command to use specific dictionaries
    SDCV_CMD="sdcv -u \"$CHINESE_DICT\" -u \"$JAPANESE_EN_JA_DICT\" \"$WORD\""

    # Run sdcv and capture output - no head -n limit here
    DEFINITION=$(eval "$SDCV_CMD")

    # Check if a definition was found
    if [ -z "$DEFINITION" ]; then
        MESSAGE="No definition found for '$WORD' in selected dictionaries."
        echo "message-warning '$MESSAGE'" > "$QUTE_FIFO"
    else
        # Prepend a header for clarity
        HEADER="--- Definition for '$WORD' (from sdcv) ---"
        # Combine header and definition
        FULL_OUTPUT="${HEADER}\n\n${DEFINITION}"

        # Send the full output to Qutebrowser's :output buffer
        # The 'spawn --userscript -s qute-fifo-command' is used to execute
        # a Qutebrowser command that itself contains arguments that might need escaping.
        # This is the most reliable way to pass multi-line or complex strings to :output.

        # We need to escape single quotes within the output string if any exist
        ESCAPED_OUTPUT=$(echo "$FULL_OUTPUT" | sed "s/'/'\\\''/g")

        # Command to open a new buffer with the definition
        QUTE_COMMAND="open -p -- \"qute://output/?text=$(echo -e "$ESCAPED_OUTPUT" | tr -d '\n' | sed 's/ /%20/g')\""
        # Alternative, simpler way if 'open -p' doesn't work well with newlines.
        # This requires manually writing to qute://output directly or using another method.
        # For simplicity and robust newlines, let's use a temporary file approach.

        # *** More Robust approach for full content: Write to a temporary file and open it ***
        TEMP_FILE=$(mktemp --suffix=.txt)
        echo -e "$FULL_OUTPUT" > "$TEMP_FILE"
        echo "open -t file://$TEMP_FILE" > "$QUTE_FIFO"
        # You might want to automatically delete the temp file after a delay,
        # or the user can just close the tab. For now, leave it.
        # (echo "delete-buffer"; rm "$TEMP_FILE") | at now + 5 minutes
        # The 'at' command might require installing 'at' package and starting 'atd' service.
        # For simple use, the user closes the tab, and the temp file remains until manual cleanup or reboot.
    fi
else
    echo "message-warning 'No word selected for sdcv lookup.'" > "$QUTE_FIFO"
fi
