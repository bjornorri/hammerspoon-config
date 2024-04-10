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

local function hasNoWindows(app)
	if app:title() == "Finder" then
		return #app:allWindows() == 1
	end
	return #app:allWindows() == 0
end

local function keyStroke(mods, key)
	hs.eventtap.keyStroke(mods, key, 10)
end

local function createNewWindow(app)
	if app:bundleID() == "com.apple.mail" then
		keyStroke({ "cmd", "alt" }, "n")
	else
		keyStroke({ "cmd" }, "n")
	end
end

local function focusNextWindow()
	keyStroke({ "cmd" }, "`")
end

local function smartLaunchOrFocus(app)
	-- Launch or focus app if not already focused.
	if not app:isFrontmost() then
		hs.application.launchOrFocus(app:path())
		return
	end

	-- Create a new window if the app has no windows.
	if hasNoWindows(app) then
		createNewWindow(app)
		return
	end

	-- Cycle the app's windows if one is already focused.
	focusNextWindow()
end

-- Bind hotkeys to apps.
local function bindHotkeys()
	for key, appName in pairs(appkeys) do
		local app = hs.application.get(appName) or hs.application.find(appName)
		if app ~= nil then
			hs.hotkey.bind(Hyper, key, function()
				smartLaunchOrFocus(app)
			end)
		end
	end
end
bindHotkeys()
