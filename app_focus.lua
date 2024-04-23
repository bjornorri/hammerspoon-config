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
-- Getting an app by its bundle ID seems to be the fastest and most reliable way to retrieve it.
-- The app_bundle_id_logger module logs the bundle ID of the active app to the console for convenience.
local finder = getEnv("HS_FILE_BROWSER") or "com.apple.finder"
local browser = getEnv("HS_BROWSER") or "com.apple.Safari"
local terminal = getEnv("HS_TERMINAL") or "com.googlecode.iterm2"
local mail = getEnv("HS_EMAIL") or "com.apple.mail"
local editor = getEnv("HS_EDITOR") or "com.microsoft.VSCode"
local chat = getEnv("HS_CHAT") or "com.facebook.archon" -- Messenger
local calendar = getEnv("HS_CALENDAR") or "com.apple.iCal"
local whatsapp = getEnv("HS_WHATSAPP") or "net.whatsapp.WhatsApp"
local xcode = getEnv("HS_XCODE") or "com.apple.dt.Xcode"

local appkeys = {
	f = finder,
	b = browser,
	t = terminal,
	m = mail,
	e = editor,
	c = chat,
	a = calendar,
	w = whatsapp,
	x = xcode,
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

local function smartLaunchOrFocus(bundleID)
	local focusedApp = hs.application.frontmostApplication()
	local app = hs.application.get(bundleID)

	-- Launch or focus app if not already focused.
	if focusedApp ~= app then
		hs.application.open(bundleID)
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
		hs.hotkey.bind(Hyper, key, function()
			smartLaunchOrFocus(appName)
		end)
	end
end
bindHotkeys()
