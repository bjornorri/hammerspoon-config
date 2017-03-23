require('reload')
require('utils')
require('caffeine')
require('position')
require('focus')
require('jumpcut')
require('wifi')
require('usb')

-- Play/Pause Spotify.
hs.hotkey.bind(hyper, "space", function()
    hs.spotify.playpause()
end)

-- Defeat paste blocking.
hs.hotkey.bind({"cmd", "alt"}, "V", function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end)

-- Mute on screen wake.
function caffeinateCallback(event)
    if (event == hs.caffeinate.watcher.screensDidWake) then
        hs.audiodevice.defaultOutputDevice():setMuted(true)
    end
end
hs.caffeinate.watcher.new(caffeinateCallback):start()

-- Notify that the config was loaded.
hs.notify.new({title="Hammerspoon", informativeText="Config loaded"}):send()
