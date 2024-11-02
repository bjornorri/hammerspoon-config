-- Assign hotkeys to apps.
require("src/key_handler")
require("src/app_mapping")

local bindableKeys = "abcdefghijklmnopqrstuvwxyz"

hs.application.enableSpotlightForNameSearches(true)

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
	local app = hs.application.get(bundleID)

	-- Launch app if not already launched.
	if not app then
		hs.notify
			.new({
				title = hs.application.nameForBundleID(bundleID),
				subTitle = "Launching...",
				contentImage = hs.image.imageFromAppBundle(bundleID),
			})
			:autoWithdraw(true)
			:send()
		hs.application.open(bundleID)
	end

	local focusedApp = hs.application.frontmostApplication()

	-- Focus app if not already focused.
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

local appMapping = AppMapping:new("AppMapping")

local function createMapping(key, bundleID)
	appMapping:setMapping(key, bundleID)
	local appName = hs.application.nameForBundleID(bundleID)
	hs.notify.new({ title = "Hyper + " .. key, subTitle = "Now opens " .. appName }):autoWithdraw(true):send()
end

local function clearMapping(key)
	appMapping:clearMapping(key)
	hs.notify.new({ title = "Hyper + " .. key, subTitle = "Hotkey cleared" }):autoWithdraw(true):send()
end

-- Dynamically bind hotkeys to apps.
local function handleKeys()
	for i = 1, #bindableKeys do
		local key = bindableKeys:sub(i, i)

		KeyHandler:new(Hyper, key, function()
			-- Retrieve mapping and focus the app.
			if appMapping:hasMapping(key) then
				local app = appMapping:getMapping(key)
				smartLaunchOrFocus(app)
			end
		end, function()
			if appMapping:hasMapping(key) then
				clearMapping(key)
			else
				local bundleID = hs.application.frontmostApplication():bundleID()
				createMapping(key, bundleID)
			end
		end, 2)
	end
end
handleKeys()
