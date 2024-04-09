-- Uncomment this to generate Hammerspoon lua annotations.
-- hs.loadSpoon("EmmyLua")

require("hyper_key")
require("reload_config")
require("force_paste")
require("windows")
require("apps")

-- Notify that the config was loaded.
hs.notify.show("Hammerspoon", "Config Loaded", "")
