-- Application constants.
local browser = 'Safari'
local terminal = 'iTerm'
local xcode = 'Xcode'
local messenger = 'Rambox'
local music = 'iTunes'
local finder = 'Finder'
local preview = 'Preview'

local appkeys = {
    b = browser,
    t = terminal,
    x = xcode,
    m = messenger,
    u = music,
    f = finder,
    p = preview
}

-- Launches or focuses the app.
-- Cycles through windows if already focused.
function smartLaunchOrFocus(appName)
    local app = hs.application.find(appName)
    local focusedWindow = hs.window.focusedWindow()
    if app ~= nil and app:isFrontmost() and focusedWindow ~= nil then
        -- Sort the windows by id to have consistent looping.
        local windows = hs.fnutils.filter(app:allWindows(), function(window)
            return window:isStandard() or window:isFullScreen() or window:isMinimized()
        end)
        table.sort(windows, function(a, b) return a:id() < b:id() end)

        local currentIndex = hs.fnutils.indexOf(windows, focusedWindow)
        local newIndex = (currentIndex == #windows) and 1 or currentIndex + 1
        windows[newIndex]:focus()
    else
        hs.application.launchOrFocus(appName)
    end
end

-- Bind hotkeys to apps.
function bindHotkeys()
    for key, app in pairs(appkeys) do
        hs.hotkey.bind(hyper, key, function()
            smartLaunchOrFocus(app)
        end)
    end
end
bindHotkeys()

