-- Assign hotkeys to apps.

hs.application.enableSpotlightForNameSearches(true)

-- Read environment variables.
local function getEnv(variable)
	local result = hs.execute(string.format("printenv | grep %s | tr -d '\n'", variable), true)
	if result ~= nil then
		return string.match(result, "=(.*)")
	end
end

-- Application constants.
local finder = getEnv("HS_FILE_BROWSER") or "Finder"
local browser = getEnv("HS_BROWSER") or "Safari"
local terminal = getEnv("HS_TERMINAL") or "iTerm"
local mail = getEnv("HS_EMAIL") or "Mail"
local editor = getEnv("HS_EDITOR") or "Code"
local chat = getEnv("HS_CHAT") or "Messenger"
local calendar = getEnv("HS_CALENDAR") or nil

local appkeys = {
	f = finder,
	b = browser,
	t = terminal,
	m = mail,
	e = editor,
	c = chat,
	a = calendar,
}

local function smartLaunchOrFocus(appName)
	local focusedApp = hs.application.frontmostApplication()
	-- local app = hs.application.get(appName) or hs.application.find(appName)
	local app = hs.application.find(appName)

	-- Launch or focus app if not already focused.
	if focusedApp ~= app then
		hs.application.launchOrFocus(app:path())
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
