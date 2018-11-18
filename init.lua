-- Define the hyper key.
hyper = {"shift", "cmd", "alt", "ctrl"}

-- Automatically reload config.
function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

-- Prevent the screen from going to sleep.
hs.caffeinate.set("displayIdle", true, true)

-- Defeat paste blocking.
hs.hotkey.bind({"cmd", "alt"}, "V", function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end)

-- Mute on screen wake.
function caffeinateCallback(event)
    if (event == hs.caffeinate.watcher.screensDidWake) then
        hs.audiodevice.defaultOutputDevice():setMuted(true)
    end
end
hs.caffeinate.watcher.new(caffeinateCallback):start()
local function keyCode(key)
  return function() hs.eventtap.keyStroke({}, key) end
end

-- React to USB events.
local kinesisKeyboard = "Kinesis Keyboard Hub"
function usbEventCallback(info)
    -- Change the keyboard layout when Kinesis Advantage is connected/disconnected.
    local event = info["eventType"]
    local device = info["productName"]
    if device == kinesisKeyboard then
        if event == "added" then
            hs.keycodes.setLayout("U.S.")
        else
            hs.keycodes.setLayout("Dvorak")
        end
        hs.reload()
    end
end
usbWatcher = hs.usb.watcher.new(usbEventCallback)
usbWatcher:start()

-- Window management.
require('windows')

-- App hotkeys.
require('apps')

-- Notify that the config was loaded.
hs.notify.new({title="Hammerspoon", informativeText="Config loaded"}):send()
