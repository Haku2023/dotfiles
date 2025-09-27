#!/bin/bash
# Qutebrowser userscript to look up selected text using sdcv

WORD="${QUTE_SELECTED_TEXT:-$QUTE_WORD}"
#for macos it may not find the sdcv and sed
export PATH="$PATH:/usr/local/bin:/usr/bin"

if [ -n "$WORD" ]; then
    # Define the dictionaries you want to use
    # Use the exact names as listed by 'sdcv -l'
    CHINESE_DICT="朗道英汉字典5.0"
    JAPANESE_EN_JA_DICT="jmdict-en-ja"

    # Construct the sdcv command to use specific dictionaries
    # We'll use both the Chinese and the Japanese (EN-JA) dictionary
    # Important: Quote dictionary names to handle spaces or special characters
    SDCV_CMD="sdcv -u \"$CHINESE_DICT\" -u \"$JAPANESE_EN_JA_DICT\" \"$WORD\""

    # Run sdcv and capture output
    DEFINITION=$(eval "$SDCV_CMD" )

    # haku_chek="$(command -v sdcv )"

    # Check if a definition was found
    if [ -z "$DEFINITION" ]; then
        MESSAGE="No definition found for '$WORD' in selected dictionaries."
        echo "message-warning '$MESSAGE'" > "$QUTE_FIFO"
        # echo "message-warning '$haku_chek'" > "$QUTE_FIFO"
    else
        # Send the definition to Qutebrowser's message bar
        # Sanitize for display in the message bar:
        # Replace newlines with a space, limit to first 300 characters for readability
        # Method 1 : use tr
        # SANITIZED_DEFINITION=$(echo "$DEFINITION" | tr '\n' '<br/>' )
        # haku check
        # echo "message-info  \"$WORD: $SANITIZED_DEFINITION (end)\"" > "$QUTE_FIFO"

        # Method 2 : use sed / awk, we choose awk
        SANITIZED_DEFINITION=$(printf "%s" "$DEFINITION" | awk '{printf $0 "<br />"}')
        # wrap with html tags
        echo "message-info -r \"<html> <div style='line-height : 80%'><b>$WORD:</b> $SANITIZED_DEFINITION <br/>(end)</div></html>\"" > "$QUTE_FIFO"
        # haku check
        # echo "message-info -r \"<html> abc <br/> def <br/> (end) </html>\"" > "$QUTE_FIFO"
        # echo "message-info abc"

        # Alternative: If you want to open a terminal for full output
        # You'll need to comment out the message.info line above and uncomment this:
        # xfce4-terminal -e "bash -c 'eval \"$SDCV_CMD\"; echo; read -p \"Press Enter to close\"'" &
    fi
else
    echo "message-warning 'No word selected for sdcv lookup.'" > "$QUTE_FIFO"
fi
