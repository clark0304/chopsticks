hs.loadSpoon("SpoonInstall")

local Install = spoon.SpoonInstall
local keyHyper = { "ctrl", "alt", "cmd" }

local function funHyper(key)
    return { keyHyper, key }
end

Install.use_syncinstall = true

Install:andUse("EmmyLua")

Install:andUse("ReloadConfiguration", {
    start = true
})

Install:andUse("SpeedMenu", {
    start = true
})

Install:andUse("TextClipboardHistory", {
    config = {
        deduplicate = false,
    },
    hotkeys = {
        toggle_clipboard = funHyper("U")
    },
    start = true,
})

Install:andUse("MouseCircle", {
    hotkeys = {
        show = funHyper("M")
    },
})

Install:andUse("MouseFollowsFocus", {
    start = true
})

Install:andUse("WindowHalfsAndThirds", {
    hotkeys = {
        left_half    = funHyper("4"),
        right_half   = funHyper("6"),
        top_half     = funHyper("8"),
        bottom_half  = funHyper("2"),

        top_left     = funHyper("7"),
        top_right    = funHyper("9"),
        bottom_left  = funHyper("1"),
        bottom_right = funHyper("3"),

        undo         = funHyper("0"),
        center       = funHyper("5"),
        larger       = funHyper("Up"),
        smaller      = funHyper("Down"),

        third_left   = funHyper("A"),
        third_right  = funHyper("D"),
        third_up     = funHyper("W"),
        third_down   = funHyper("S"),

        max_toggle   = funHyper("Left"),
        max          = funHyper("Right"),
    }
})

Install:andUse("WindowScreenLeftAndRight", {
    hotkeys = {
        screen_left  = funHyper("["),
        screen_right = funHyper("]"),
    }
})

Install:andUse("KSheet", {
    hotkeys = {
        toggle = funHyper("P"),
    }
})

Install:andUse("HSKeybindings")

hs.hotkey.bind(keyHyper, "I", function()
    spoon.HSKeybindings:show()
end)
hs.hotkey.bind(keyHyper, "O", function()
    spoon.HSKeybindings:hide()
end)

Install:andUse("Seal", {
    hotkeys = {
        toggle = funHyper(";")
    },
    fn = function(mxd)
        mxd:loadPlugins({ "apps", "safari_bookmarks" })
    end,
    start = true,
})

Install:andUse("Commander")

hs.hotkey.bind(keyHyper, "'", function()
    spoon.Commander.show()
end)

Install:andUse("InputSourceSwitch", {
    start = true
})

Install:andUse("WifiNotifier", {
    start = true
})

Install:andUse("WiFiTransitions", {
    start = true
})

local browserReload = require("Chopsticks.BrowserReload.init")

hs.hotkey.bind(keyHyper, "L", function()
    browserReload.reload({
        sites = {
            ["chatglm.cn/main/alltoolsdetail"] = true,
            ["chat.deepseek.com"]              = true,
            ["claude.ai"]                      = false,
            ["gemini.google.com/app"]          = false,
            ["www.google.com/search"]          = true,
            ["grok.com"]                       = false,
            ["www.kimi.com"]                   = true,
            ["www.qianwen.com"]                = false,
            ["chat.z.ai"]                      = true,
        },
    })
end)
