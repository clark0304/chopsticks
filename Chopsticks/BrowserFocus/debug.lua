local M = {}

local PLATES_DIR = hs.configdir .. "/Plates/BrowserFocus"

local CHROMIUM_BROWSERS = {
    ["com.brave.Browser"]          = false,
    ["com.google.Chrome"]          = true,
    ["com.microsoft.edgemac"]      = true,
    ["com.vivaldi.Vivaldi"]        = false,
    ["company.thebrowser.Browser"] = false,
}

local JS_TPL = {
    ["chatglm.cn/main/alltoolsdetail"] = "console.log('chatglm.cn/main/alltoolsdetail');",
    ["chatgpt.com"]                    = "console.log('chatgpt.com');",
    ["chat.deepseek.com"]              = "console.log('chat.deepseek.com');",
    ["claude.ai"]                      = "console.log('claude.ai');",
    ["gemini.google.com/app"]          = "console.log('gemini.google.com/app');",
    ["www.google.com/search"]          = "console.log('www.google.com/search');",
    ["grok.com"]                       =
    "(function(){let el=document.querySelector('[contenteditable=true],[role=textbox]');if(el){el.focus()};})();",
    ["www.qianwen.com"]                = "console.log('www.qianwen.com');",
    ["chat.z.ai"]                      = "console.log('chat.z.ai');",
}

local function checkOneSite(sites)
    local count = 0
    for _, enabled in pairs(sites) do
        if enabled then
            count = count + 1
        end
    end
    return count == 1
end

local function getTag(sites)
    for site, enabled in pairs(sites) do
        if enabled then
            return site
        end
    end
    return ""
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
        hs.printf("[BrowserFocusGrok] 找不到模板: %s", path)
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

function M.openFocus(config)
    config = config or {}
    local sites = config.sites or {}

    if not checkOneSite(sites) then
        hs.alert.show("未指定一个唯一的站点 site")
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
    local tag = getTag(sites)

    if CHROMIUM_BROWSERS[browserID] then
        templateName = "lib_chromium.applescript"
        vars = {
            BROWSER_ID      = browserID,
            MATCH_CONDITION = condition,
            JS_CODE         = JS_TPL[tag],
        }
    elseif browserID == "com.apple.Safari" then
        templateName = "lib_safari.applescript"
        vars = {
            BROWSER_ID      = browserID,
            MATCH_CONDITION = condition,
            JS_CODE         = JS_TPL[tag],
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
        local resultDebug = tostring(result)
        local rawDebug = tostring(hs.inspect(raw))

        hs.printf("[BrowserFocus] AppleScript result: %s", resultDebug)
        hs.printf("[BrowserFocus] AppleScript raw: %s", rawDebug)
        if rawDebug:lower():find("javascript") then
            hs.alert.show("请先在浏览器开启: 允许 Apple 事件中的 JavaScript")
        else
            hs.alert.show("聚焦失败, 请查看 Console")
        end
        return
    end

    if result ~= "FLAG_FOUND" then
        hs.alert.show("未找到标签页:\n" .. tag)
        return
    end

    hs.alert.show("AI 标签页已聚焦")
end

return M
