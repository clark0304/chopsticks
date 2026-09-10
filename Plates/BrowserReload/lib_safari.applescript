tell application "Safari"
    repeat with w in windows
        repeat with t in tabs of w
            if (URL of t is not missing value) and ({{MATCH_CONDITION}}) then
                set URL of t to URL of t
            end if
        end repeat
    end repeat
end tell
