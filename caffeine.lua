-- Replace caffeine.
local caffeine = hs.menubar.new()
function setCaffeineDisplay(state)
    local result
    if state then
        result = caffeine:setIcon("images/caffeine-on.pdf")
    else
        result = caffeine:setIcon("images/caffeine-off.pdf")
    end
end

function caffeineClicked()
    local active = hs.caffeinate.toggle("displayIdle")
    hs.settings.set("caffeine", active)
    setCaffeineDisplay(active)
end

if caffeine then
    caffeine:setClickCallback(caffeineClicked)
    local active = hs.settings.get("caffeine")
    if active then
        hs.caffeinate.toggle("displayIdle")
        setCaffeineDisplay(true)
    else
        setCaffeineDisplay(false)
    end
end

-- Add hotkey to sleep.
hs.hotkey.bind(hyper, '-', function()
    hs.caffeinate.systemSleep()
end)
