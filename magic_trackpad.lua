-- Auto pairs and unpairs my magic trackpad to allow seamless switching between devices.

local isConnected = function()
	local result = hs.execute("/opt/homebrew/bin/blueutil --is-connected 8C:85:90:F3:49:47 | tr -d '\n'")
	return result == "1"
end

local connect = function()
	hs.execute(
		"/opt/homebrew/bin/blueutil --pair 8C:85:90:F3:49:47 && /opt/homebrew/bin/blueutil --connect 8C:85:90:F3:49:47"
	)
end

local disconnect = function()
	hs.execute("/opt/homebrew/bin/blueutil --unpair 8C:85:90:F3:49:47")
end

hs.caffeinate.watcher
	.new(function(event)
		if event == hs.caffeinate.watcher.systemWillSleep or event == hs.caffeinate.watcher.screensDidSleep then
			if isConnected() then
				disconnect()
			end
		end

		if event == hs.caffeinate.watcher.systemDidWake or event == hs.caffeinate.watcher.screensDidWake then
			if not isConnected() then
				hs.notify.new({ title = "Hammerspoon", subTitle = "Connecting..." }):autoWithdraw(true):send()
				connect()
				hs.notify.new({ title = "Hammerspoon", subTitle = "Trackpad connected" }):autoWithdraw(true):send()
			end
		end
	end)
	:start()

hs.hotkey.bind(Hyper, "f6", function()
	hs.notify.new({ title = "Hammerspoon", subTitle = "Connecting..." }):autoWithdraw(true):send()
	disconnect()
	connect()
	hs.notify.new({ title = "Hammerspoon", subTitle = "Trackpad connected" }):autoWithdraw(true):send()
end)
