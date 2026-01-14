-- ShortcutRemap: A class for remapping keyboard shortcuts globally or per-app
ShortcutRemap = {}
ShortcutRemap.__index = ShortcutRemap

-- Constructor for ShortcutRemap
function ShortcutRemap:new()
	local self = setmetatable({}, ShortcutRemap)

	-- Store global and per-app mappings
	self.globalMappings = {}
	self.appMappings = {}

	-- Track currently bound app-specific hotkeys
	self.currentAppBundleID = nil
	self.boundAppHotkeys = {}

	-- Create an application watcher to handle app switching
	self.appWatcher = hs.application.watcher.new(function(appName, eventType, app)
		self:_handleAppChange(appName, eventType, app)
	end)
	self.appWatcher:start()

	-- Bind hotkeys for the currently focused app on init
	local frontApp = hs.application.frontmostApplication()
	if frontApp then
		self:_updateAppBindings(frontApp:bundleID())
	end

	return self
end

-- Add a global mapping (always active)
function ShortcutRemap:addGlobalMapping(sourceMods, sourceKey, targetMods, targetKey)
	local mapping = {
		sourceMods = sourceMods,
		sourceKey = sourceKey,
		targetMods = targetMods,
		targetKey = targetKey,
		hotkeyRef = nil
	}

	table.insert(self.globalMappings, mapping)
	self:_createGlobalBinding(mapping)
end

-- Add a per-app mapping (only active when specified app is focused)
function ShortcutRemap:addAppMapping(bundleID, sourceMods, sourceKey, targetMods, targetKey)
	-- Initialize app mappings table for this bundle ID if needed
	if not self.appMappings[bundleID] then
		self.appMappings[bundleID] = {}
	end

	local mapping = {
		sourceMods = sourceMods,
		sourceKey = sourceKey,
		targetMods = targetMods,
		targetKey = targetKey,
		hotkeyRef = nil
	}

	table.insert(self.appMappings[bundleID], mapping)

	-- If this app is currently focused, bind the hotkey immediately
	if self.currentAppBundleID == bundleID then
		self:_bindAppMapping(mapping)
	end
end

-- Private: Create and bind a global hotkey
function ShortcutRemap:_createGlobalBinding(mapping)
	mapping.hotkeyRef = hs.hotkey.bind(
		mapping.sourceMods,
		mapping.sourceKey,
		function()  -- pressedfn - send target key DOWN to enter held state
			hs.eventtap.event.newKeyEvent(mapping.targetMods, mapping.targetKey, true):post()
		end,
		function()  -- releasedfn - send target key UP to release
			hs.eventtap.event.newKeyEvent(mapping.targetMods, mapping.targetKey, false):post()
		end,
		function()  -- repeatfn - send UP then DOWN to simulate repeat while maintaining held state
			hs.eventtap.event.newKeyEvent(mapping.targetMods, mapping.targetKey, false):post()
			hs.eventtap.event.newKeyEvent(mapping.targetMods, mapping.targetKey, true):post()
		end
	)
end

-- Private: Bind a single app-specific mapping
function ShortcutRemap:_bindAppMapping(mapping)
	mapping.hotkeyRef = hs.hotkey.bind(
		mapping.sourceMods,
		mapping.sourceKey,
		function()  -- pressedfn - send target key DOWN to enter held state
			hs.eventtap.event.newKeyEvent(mapping.targetMods, mapping.targetKey, true):post()
		end,
		function()  -- releasedfn - send target key UP to release
			hs.eventtap.event.newKeyEvent(mapping.targetMods, mapping.targetKey, false):post()
		end,
		function()  -- repeatfn - send UP then DOWN to simulate repeat while maintaining held state
			hs.eventtap.event.newKeyEvent(mapping.targetMods, mapping.targetKey, false):post()
			hs.eventtap.event.newKeyEvent(mapping.targetMods, mapping.targetKey, true):post()
		end
	)

	table.insert(self.boundAppHotkeys, mapping.hotkeyRef)
end

-- Private: Enable/disable app-specific hotkeys based on focused app
function ShortcutRemap:_updateAppBindings(bundleID)
	-- Unbind all currently bound app-specific hotkeys
	for _, hotkey in ipairs(self.boundAppHotkeys) do
		hotkey:delete()
	end
	self.boundAppHotkeys = {}

	-- Update current app tracking
	self.currentAppBundleID = bundleID

	-- Bind hotkeys for the new app if we have mappings for it
	if bundleID and self.appMappings[bundleID] then
		for _, mapping in ipairs(self.appMappings[bundleID]) do
			self:_bindAppMapping(mapping)
		end
	end
end

-- Private: App watcher callback
function ShortcutRemap:_handleAppChange(appName, eventType, app)
	if eventType == hs.application.watcher.activated then
		local bundleID = app and app:bundleID() or nil
		self:_updateAppBindings(bundleID)
	end
end

-- Cleanup method to stop the watcher and unbind all hotkeys
function ShortcutRemap:delete()
	-- Stop the app watcher
	if self.appWatcher then
		self.appWatcher:stop()
	end

	-- Unbind all global hotkeys
	for _, mapping in ipairs(self.globalMappings) do
		if mapping.hotkeyRef then
			mapping.hotkeyRef:delete()
		end
	end

	-- Unbind all app-specific hotkeys
	for _, hotkey in ipairs(self.boundAppHotkeys) do
		hotkey:delete()
	end
end

return ShortcutRemap
