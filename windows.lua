-- Manage windows with hotkeys.

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

-- Top half.
hs.hotkey.bind(Hyper, "pageup", function()
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	f.x = max.x
	f.y = max.y
	f.w = max.w
	f.h = max.h / 2
	win:setFrame(f)
end)

-- Bottom half.
hs.hotkey.bind(Hyper, "pagedown", function()
	local win = hs.window.focusedWindow()
	local f = win:frame()
	local screen = win:screen()
	local max = screen:frame()

	f.x = max.x
	f.y = max.y + (max.h / 2)
	f.w = max.w
	f.h = max.h / 2
	win:setFrame(f)
end)

-- Move to next display.
hs.hotkey.bind(Hyper, "down", function()
	local win = hs.window.focusedWindow()
	local screen = win:screen()
	local allScreens = hs.screen.allScreens()
	local index = hs.fnutils.indexOf(allScreens, screen)
	local newIndex = #allScreens - (index + 1) % #allScreens
	local newScreen = allScreens[newIndex]
	win:moveToScreen(newScreen)
end)

-- Gets the n frontmost windows, ordered from front to back.
local function getFrontmostWindows(n)
	local allWindows = hs.window.orderedWindows()
	local filter = hs.window.filter.default
	local windows = hs.fnutils.ifilter(allWindows, function(w)
		return filter:isWindowAllowed(w)
	end)
	local frontmostWindows = {}
	for i, window in ipairs(windows) do
		table.insert(frontmostWindows, window)
		if i == n then
			break
		end
	end
	return frontmostWindows
end

local function getLayout(windows, frames)
	if #windows == 0 or windows == nil then
		return {}
	end
	local screen = windows[1]:screen()
	local layout = {}
	for i, window in ipairs(windows) do
		local entry = { nil, window, screen, frames[i], nil, nil }
		table.insert(layout, entry)
	end
	return layout
end

hs.hotkey.bind(Hyper, "1", function()
	local windows = getFrontmostWindows(1)
	local frames = {
		hs.layout.maximized,
	}
	local layout = getLayout(windows, frames)
	hs.layout.apply(layout)
end)

hs.hotkey.bind(Hyper, "2", function()
	local windows = getFrontmostWindows(2)
	local frames = {
		hs.layout.left50,
		hs.layout.right50,
	}
	local layout = getLayout(windows, frames)
	hs.layout.apply(layout)
end)
