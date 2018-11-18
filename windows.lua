-- Move instantly.
hs.window.animationDuration = 0

-- Maximize.
hs.hotkey.bind(hyper, "up", function()
    local win = hs.window.focusedWindow()
    win:setFrame(win:screen():frame())
end)

-- Left half.
hs.hotkey.bind(hyper, "left", function()
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
hs.hotkey.bind(hyper, "right", function()
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

-- Screen management.
hs.hotkey.bind(hyper, "down", function()
    local win = hs.window.focusedWindow()
    local screen = win:screen()
    local allScreens = hs.screen.allScreens()
    local index = hs.fnutils.indexOf(allScreens, screen)
    local newIndex = #allScreens - (index + 1) % #allScreens
    local newScreen = allScreens[newIndex]
    win:moveToScreen(newScreen)
end)
