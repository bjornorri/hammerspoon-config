-- Application constants.
local browser = 'Google Chrome'
local terminal = 'iTerm'
local editor = 'Atom'
local xcode = 'Xcode'
local mail = 'Spark'
local simulator = 'Simulator'
local music = 'Spotify'
local finder = 'Finder'
local preview = 'Preview'
local slack = 'Slack'
local messenger = 'Messages'

local appkeys = {
    b = browser,
    t = terminal,
    n = editor,
    s = spotify,
    x = xcode,
    m = mail,
    s = simulator,
    u = music,
    f = finder,
    p = preview,
    c = slack,
    e = messenger
}


-- Bind hotkeys to apps.
for key, app in pairs(appkeys) do
    hs.hotkey.bind(hyper, key, function()
        smartLaunchOrFocus(app)
    end)
end

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
