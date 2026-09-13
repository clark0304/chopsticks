tell application id "{{BROWSER_ID}}"
    activate
    repeat with w in windows
        set i to 0
        repeat with t in tabs of w
            set i to i + 1
            if ({{MATCH_CONDITION}}) then
                set active tab index of w to i
                set index of w to 1
                delay 1
                try
                    do JavaScript "{{JS_CODE}}" in t
                end try
                return "FLAG_FOUND"
            end if
        end repeat
    end repeat
    return "FLAG_ERR"
end tell
