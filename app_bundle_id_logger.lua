-- Logs the bundle ID of the active app to the Hammerspoon console.

local log = hs.logger.new("bundle_id_logger", "debug")
function applicationWatcher(appName, eventType, appObject)
	if eventType == hs.application.watcher.activated then
		log.d(string.format("\n%s: %s\n", appName, appObject:bundleID()))
	end
end

hs.application.watcher.new(applicationWatcher):start()
