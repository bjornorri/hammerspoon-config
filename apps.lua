-- Application constants.
local browser = "Safari"
local terminal = "iTerm"
local finder = "Finder"
local mail = "Mail"

local appkeys = {
	b = browser,
	t = terminal,
	f = finder,
	m = mail,
}

local function smartLaunchOrFocus(appName)
	local focusedApp = hs.application.frontmostApplication()
	local app = hs.application.find(appName)

	-- Launch or focus app if not already focused.
	if focusedApp ~= app then
		hs.application.launchOrFocus(appName)
		return
	end

	-- Cycle the app's windows with the built-in Cmd+` shortcut.
	hs.eventtap.keyStroke({ "cmd" }, "`", 10)
end

-- Bind hotkeys to apps.
local function bindHotkeys()
	for key, app in pairs(appkeys) do
		hs.hotkey.bind(Hyper, key, function()
			smartLaunchOrFocus(app)
		end)
	end
end
bindHotkeys()
