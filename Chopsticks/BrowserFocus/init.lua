local M                 = {}
local U                 = require("Chopsticks.BrowserUtil.init")

local M_TAG             = "BrowserFocus"
local PLATES_DIR        = hs.configdir .. "/Plates/" .. M_TAG
local SAUCERS_DIR       = hs.configdir .. "/Saucers/" .. M_TAG

local CHROMIUM_BROWSERS = {
    ["com.brave.Browser"]          = false,
    ["com.google.Chrome"]          = true,
    ["com.microsoft.edgemac"]      = true,
    ["com.vivaldi.Vivaldi"]        = false,
    ["company.thebrowser.Browser"] = false,
}

local SUPPORTED_SITES   = {
    ["chatglm.cn/main/alltoolsdetail"] = false,
    ["chatgpt.com"]                    = false,
    ["chat.deepseek.com"]              = false,
    ["claude.ai"]                      = false,
    ["gemini.google.com/app"]          = false,
    ["www.google.com/search"]          = false,
    ["grok.com"]                       = true,
    ["www.kimi.com"]                   = false,
    ["www.qianwen.com"]                = false,
    ["chat.z.ai"]                      = false,
}

local function loadJsForSite(tag)
    local fileName = U.siteToFilename(tag)
    local saucerName = SAUCERS_DIR .. "/" .. fileName
    local js = U.readSaucer(M_TAG, saucerName)
    if js then
        return js
    end
    saucerName = SAUCERS_DIR .. "/" .. "default.js"
    hs.printf("已回退到 default.js", M_TAG, tag)
    return U.readSaucer(M_TAG, saucerName)
end

function M.openFocus(config)
    config = config or {}
    local sites = config.sites or {}

    if not U.checkOneSite(sites) then
        hs.alert.show("未指定一个唯一的站点 site")
        return
    end

    local browserID = hs.urlevent.getDefaultHandler("http")
    if not browserID then
        hs.alert.show("无法获取默认浏览器")
        return
    end

    if not hs.application.get(browserID) then
        hs.alert.show("浏览器未运行:\n" .. browserID)
        return
    end

    local tag = U.getTag(sites)
    if not SUPPORTED_SITES[tag] then
        hs.alert.show("未支持该站点:\n" .. tag)
        return
    end

    local jsCode = loadJsForSite(tag)
    if not jsCode then
        hs.alert.show("加载 JS 脚本失败:\n" .. tag)
        return
    end

    local fileName
    if CHROMIUM_BROWSERS[browserID] then
        fileName = "lib_chromium.applescript"
    elseif browserID == "com.apple.Safari" then
        fileName = "lib_safari.applescript"
    else
        hs.alert.show("暂不支持此浏览器:\n" .. browserID)
        return
    end

    local plateName = PLATES_DIR .. "/" .. fileName
    local template = U.readPlate(M_TAG, plateName)
    if not template then
        hs.alert.show("加载 AppleScript 模板失败")
        return
    end

    local vars = {
        BROWSER_ID      = browserID,
        MATCH_CONDITION = U.matchCondition(sites),
        JS_CODE         = U.escapeForAppleScript(jsCode),
    }

    local script = U.render(template, vars)
    local ok, result, raw = hs.osascript.applescript(script)

    if not ok then
        U.handleAppleScriptError(M_TAG, result, raw)
        return
    end

    if result ~= "FLAG_FOUND" then
        hs.alert.show("未找到标签页:\n" .. tag)
        return
    end

    hs.alert.show("标签页已聚焦")
end

return M
