-- Play/Pause Spotify.
hs.hotkey.bind(hyper, "space", function()
    if (hs.itunes.isPlaying()) then
        hs.itunes.playpause()
    elseif (hs.spotify.isPlaying()) then
        hs.spotify.playpause()
    elseif (hs.itunes.isRunning()) then
        hs.itunes.playpause()
    elseif (hs.spotify.isRunning()) then
        hs.spotify.playpause()
    else
        hs.itunes.playpause()
    end
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
local function keyCode(key)
  return function() hs.eventtap.keyStroke({}, key) end
end

-- Map map hyper-hjkl to arrow keys.
local function keyCode(key, modifiers)
  modifiers = modifiers or {}
  return function()
      hs.eventtap.event.newKeyEvent(modifiers, string.lower(key), true):post()
      hs.timer.usleep(0) -- Optional delay.
      hs.eventtap.event.newKeyEvent(modifiers, string.lower(key), false):post()
  end
end

hs.hotkey.bind(hyper, 'h', keyCode('left'), nil, keyCode('left'))
hs.hotkey.bind(hyper, 'j', keyCode('down'), nil, keyCode('down'))
hs.hotkey.bind(hyper, 'k', keyCode('up'), nil, keyCode('up'))
hs.hotkey.bind(hyper, 'l', keyCode('right'), nil, keyCode('right'))
