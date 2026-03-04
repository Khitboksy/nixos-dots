#!/usr/bin/env fish

set sticker (rmpc sticker get "$FILE" "playCount" | jq -r '.value')

if test -z "$sticker"
    rmpc sticker set "$FILE" "playCount" "1"
else
    set new_count (math "$sticker + 1")
    rmpc sticker set "$FILE" "playCount" "$new_count"
end
