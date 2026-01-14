-- Keyboard Shortcut Remapping Module
--
-- This module allows you to remap keyboard shortcuts globally or per-app.
-- - Global mappings are always active
-- - Per-app mappings are only active when the specified app is focused
-- - Key repeat is automatically supported for all mappings
--
-- API:
--   remapper:addGlobalMapping(sourceMods, sourceKey, targetMods, targetKey)
--   remapper:addAppMapping(bundleID, sourceMods, sourceKey, targetMods, targetKey)
--
-- Finding Bundle IDs:
-- osascript -e 'id of app "AppName"'

require("hyper_key")

local ShortcutRemap = require("src.shortcut_remap")
local remapper = ShortcutRemap:new()

-- Example: Global Mappings
-- These shortcuts are always active, regardless of which app is focused
--
-- Vim navigation with hyper key
remapper:addGlobalMapping(
  Hyper, "h",
  {}, "left"
)
remapper:addGlobalMapping(
  Hyper, "j",
  {}, "down"
)
remapper:addGlobalMapping(
  Hyper, "k",
  {}, "up"
)
remapper:addGlobalMapping(
  Hyper, "l",
  {}, "right"
)

-- Claude Desktop - New conversation
remapper:addAppMapping(
  "com.anthropic.claudefordesktop",
  {"cmd"}, "n",
  {"cmd",  "shift"}, "o"
)
