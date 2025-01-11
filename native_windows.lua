-- Manage windows with hotkeys.

local function runAppleScript(script)
	hs.osascript.applescript(script)
end

local function restore()
	runAppleScript([[
    tell application "System Events"
        tell process (name of first application process whose frontmost is true)
            click menu item "Return to Previous Size" of menu 1 of menu item "Move & Resize" of menu "Window" of menu bar 1
        end tell
    end tell
  ]])
end

local function fill()
	runAppleScript([[
    tell application "System Events"
        tell process (name of first application process whose frontmost is true)
            click menu item "Fill" of menu "Window" of menu bar 1
        end tell
    end tell
  ]])
end

local function left()
	runAppleScript([[
    tell application "System Events"
        tell process (name of first application process whose frontmost is true)
            click menu item "Left" of menu 1 of menu item "Move & Resize" of menu "Window" of menu bar 1
        end tell
    end tell
  ]])
end

local function right()
	runAppleScript([[
    tell application "System Events"
        tell process (name of first application process whose frontmost is true)
            click menu item "Right" of menu 1 of menu item "Move & Resize" of menu "Window" of menu bar 1
        end tell
    end tell
  ]])
end

local function halvesLeftRight()
	runAppleScript([[
    tell application "System Events"
        tell process (name of first application process whose frontmost is true)
            click menu item "Left & Right" of menu 1 of menu item "Move & Resize" of menu "Window" of menu bar 1
        end tell
    end tell
  ]])
end

local function halvesRightLeft()
	runAppleScript([[
    tell application "System Events"
        tell process (name of first application process whose frontmost is true)
            click menu item "Right & Left" of menu 1 of menu item "Move & Resize" of menu "Window" of menu bar 1
        end tell
    end tell
  ]])
end

-- Move instantly.
hs.window.animationDuration = 0

-- Restore size.
hs.hotkey.bind(Hyper, "`", function()
	restore()
end)
hs.hotkey.bind(Hyper, "r", function()
	restore()
end)

-- Maximize.
hs.hotkey.bind(Hyper, "up", function()
	fill()
end)

-- Left half.
hs.hotkey.bind(Hyper, "left", function()
	left()
end)

-- Right half.
hs.hotkey.bind(Hyper, "right", function()
	right()
end)

-- One window (maximized).
hs.hotkey.bind(Hyper, "1", function()
	fill()
end)

-- Two window halves.
hs.hotkey.bind(Hyper, "2", function()
	halvesLeftRight()
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

hs.hotkey.bind(Hyper, "space", function()
	local windows = getFrontmostWindows(2)
	if #windows == 0 or windows == nil then
		return
	end
	windows[#windows]:focus()
end)
