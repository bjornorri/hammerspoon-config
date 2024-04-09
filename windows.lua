require("hyper_key")

-- Move instantly.
hs.window.animationDuration = 0

-- Maximize.
hs.hotkey.bind(Hyper, "up", function()
	local win = hs.window.focusedWindow()
	win:setFrame(win:screen():frame())
end)

-- Left half.
hs.hotkey.bind(Hyper, "left", function()
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	f.x = max.x
	f.y = max.y
	f.w = max.w / 2
	f.h = max.h
	win:setFrame(f)
end)

-- Right half.
hs.hotkey.bind(Hyper, "right", function()
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	f.x = max.x + (max.w / 2)
	f.y = max.y
	f.w = max.w / 2
	f.h = max.h
	win:setFrame(f)
end)

-- Move to next display.
hs.hotkey.bind(Hyper, "down", function()
	local screen = hs.window.focusedWindow():screen()

	local win = hs.window.focusedWindow()
	local screen = win:screen()
	local allScreens = hs.screen.allScreens()
	local index = hs.fnutils.indexOf(allScreens, screen)
	local newIndex = #allScreens - (index + 1) % #allScreens
	local newScreen = allScreens[newIndex]
	win:moveToScreen(newScreen)
end)
