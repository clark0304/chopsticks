local M = {}

function M.checkOneSite(sites)
    local count = 0
    for _, enabled in pairs(sites) do
        if enabled then
            count = count + 1
        end
    end
    return count == 1
end

-- 把字符串安全嵌入 AppleScript 的双引号字符串字面量中
-- 先反斜杠转义
-- 后双引号转义
function M.escapeForAppleScript(s)
    s = tostring(s or "")
    s = s:gsub("\\", "\\\\")
    s = s:gsub('"', '\\"')
    return s
end

function M.getTag(sites)
    for site, enabled in pairs(sites) do
        if enabled then
            return site
        end
    end
    return ""
end

-- 统一处理 osascript 报错
-- 识别 "JS 权限"
function M.handleAppleScriptError(moduleTag, result, raw)
    hs.printf("[%s] AppleScript result: %s", moduleTag, tostring(result))
    hs.printf("[%s] AppleScript raw: %s", moduleTag, hs.inspect(raw))

    local errNum  = raw and raw.OSAScriptErrorNumberKey
    local errText = raw and (raw.OSAScriptErrorMessageKey or raw.NSLocalizedDescription or "")
    errText       = tostring(errText):lower()

    if errNum == 12 or errText:find("javascript") or errText:find("apple event") then
        hs.alert.show("请先在浏览器开启: 允许 Apple 事件中的 JavaScript")
    else
        hs.alert.show("操作失败, 请查看 Console")
    end
end

function M.matchCondition(sites)
    local conds = {}
    for site, enabled in pairs(sites) do
        if enabled then
            table.insert(conds, ('URL of t contains "%s"'):format(site))
        end
    end
    return table.concat(conds, " or ")
end

function M.readPlate(moduleTag, fileName)
    local f = io.open(fileName, "r")
    if not f then
        hs.printf("[%s] 未找到对应模板: %s", moduleTag, fileName)
        return nil
    end
    local content = f:read("*a")
    f:close()
    return content
end

function M.readSaucer(moduleTag, fileName)
    local f = io.open(fileName, "r")
    if not f then
        hs.printf("[%s] 未找到对应脚本: %s", moduleTag, fileName)
        return nil
    end
    local content = f:read("*a")
    f:close()
    return content
end

function M.siteToFilename(site)
    return (site:gsub("/", "_"):gsub("%.", "_")) .. ".js"
end

function M.render(template, vars)
    return (template:gsub("{{(.-)}}", function(key)
        return vars[key] or ""
    end))
end

return M
