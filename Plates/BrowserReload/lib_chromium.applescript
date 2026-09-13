tell application id "{{BROWSER_ID}}"
    activate
    repeat with w in windows
        repeat with t in tabs of w
            if (URL of t is not missing value) and ({{MATCH_CONDITION}}) then
                reload t
            end if
        end repeat
    end repeat
end tell
