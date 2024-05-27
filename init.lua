-- Get rid of error notifications.
hs.notify.withdrawAll()
hs.notify.new({ title = "Hammerspoon", subTitle = "Reloading..." }):autoWithdraw(true):send()

hs.loadSpoon("EmmyLua")

require("hyper_key")
require("reload_config")
require("force_paste")
require("windows")
require("app_focus")
require("magic_trackpad")
require("app_bundle_id_logger")

--- Notify that the config was loaded.
hs.notify.withdrawAll()
hs.notify.new({ title = "Hammerspoon", subTitle = "Config Loaded" }):autoWithdraw(true):send()
