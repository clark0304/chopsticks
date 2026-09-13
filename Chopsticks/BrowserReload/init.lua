local M = {}

local PLATES_DIR = hs.configdir .. "/Plates/BrowserReload"

local CHROMIUM_BROWSERS = {
    ["com.brave.Browser"]          = false,
    ["com.google.Chrome"]          = true,
    ["com.microsoft.edgemac"]      = true,
    ["com.vivaldi.Vivaldi"]        = false,
    ["company.thebrowser.Browser"] = false,
}

local function hasEnabledSite(sites)
    for _, enabled in pairs(sites) do
        if enabled then
            return true
        end
    end
    return false
end

local function matchCondition(sites)
    local conds = {}
    for site, enabled in pairs(sites) do
        if enabled then
            table.insert(conds, ('URL of t contains "%s"'):format(site))
        end
    end
    return table.concat(conds, " or ")
end

local function readPlate(name)
    local path = PLATES_DIR .. "/" .. name
    local f = io.open(path, "r")
    if not f then
        hs.printf("[BrowserReload] 找不到模板: %s", path)
        return nil
    end
    local content = f:read("*a")
    f:close()
    return content
end

local function render(template, vars)
    return (template:gsub("{{(.-)}}", function(key)
        return vars[key] or ""
    end))
end

function M.openReload(config)
    config      = config or {}
    local sites = config.sites or {}

    if not hasEnabledSite(sites) then
        hs.alert.show("未启用任何站点 sites")
        return
    end

    local browserID = hs.urlevent.getDefaultHandler("http")
    if not browserID then
        hs.alert.show("无法获取默认浏览器")
        return
    end

    local app = hs.application.get(browserID)
    if not app then
        hs.alert.show("浏览器未运行:\n" .. browserID)
        return
    end

    local templateName, vars
    local condition = matchCondition(sites)

    if CHROMIUM_BROWSERS[browserID] then
        templateName = "lib_chromium.applescript"
        vars = {
            BROWSER_ID      = browserID,
            MATCH_CONDITION = condition,
        }
    elseif browserID == "com.apple.Safari" then
        templateName = "lib_safari.applescript"
        vars = {
            BROWSER_ID      = "Safari",
            MATCH_CONDITION = condition,
        }
    else
        hs.alert.show("暂不支持此浏览器:\n" .. browserID)
        return
    end

    local template = readPlate(templateName)
    if not template then
        hs.alert.show("加载 AppleScript 模板失败")
        return
    end

    local script = render(template, vars)
    local ok, result, raw = hs.osascript.applescript(script)

    if not ok then
        hs.printf("[BrowserReload] AppleScript result: %s", tostring(result))
        hs.printf("[BrowserReload] AppleScript raw: %s", hs.inspect(raw))
        hs.alert.show("刷新失败, 请查看 Console")
        return
    end

    hs.alert.show("标签页已刷新")
end

return M
