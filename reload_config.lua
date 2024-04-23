-- Automatically reload config.

local function reloadConfig(files)
	local doReload = false
	for _, file in pairs(files) do
		if file:sub(-4) == ".lua" then
			doReload = true
		end
	end
	if doReload then
		hs.reload()
	end
end

-- Auto reload.
hs.pathwatcher.new(hs.configdir, reloadConfig):start()

-- Add reload hotkey.
hs.hotkey.bind(Hyper, "f5", hs.reload)
