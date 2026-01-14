-- Get rid of error notifications.
hs.notify.withdrawAll()

hs.loadSpoon("EmmyLua")

require("hyper_key")
require("reload_config")
require("force_paste")
require("windows")
require("shortcut_remap")  -- Uncomment to enable shortcut remapping

--- Notify that the config was loaded.
hs.notify.new({ title = "Hammerspoon", subTitle = "Config Loaded" }):autoWithdraw(true):send()
