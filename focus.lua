-- Application constants.
local browser = 'Google Chrome'
local terminal = 'iTerm'
local editor = 'Visual Studio Code'
local xcode = 'Xcode'
local mail = 'Polymail'
local simulator = 'Simulator'
local music = 'Spotify'
local finder = 'Finder'
local preview = 'Preview'
local slack = 'Slack'
local messenger = 'Messages'
local videoPlayer = "VLC"

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
    e = messenger,
    w = videoPlayer
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

-- Add hotkey menu item.
local hotkeys = hs.menubar.new()
hotkeys:setTitle("H")
local settings = hs.settings.get("hotkeys") or {}
-- Remove unwanted entries.
for key, val in pairs(settings) do
    if not contains(appkeys, key) then
        settings[key] = nil
    end
end
-- Add new entries.
for key, val in pairs(appkeys) do
    if settings[val] == nil then
        settings[val] = true
    end
end

-- Bind hotkeys to apps.
function bindHotkeys()
    for key, app in pairs(appkeys) do
        if settings[app] == true then
            hs.hotkey.bind(hyper, key, function()
                smartLaunchOrFocus(app)
            end)
        else
            hs.hotkey.deleteAll(hyper, key)
        end
    end
end

function populateMenu(key)
    menuData = {}
    for key, val in pairs(settings) do
        local title = key
        local checked = val
        table.insert(menuData, 1, {title=title, checked=checked, fn=function()
            -- Toggle hotkey.
            settings[key] = not checked
            hs.settings.set("hotkeys", settings)
            bindHotkeys()
        end})
    end
    -- Sort in alphabetical order.
    local comp = function(a, b) return string.lower(a.title) < string.lower(b.title) end
    table.sort(menuData, comp)
    return menuData
end
bindHotkeys()
hotkeys:setMenu(populateMenu)

