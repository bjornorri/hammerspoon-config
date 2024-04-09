-- Defeat paste blocking by "typing" clipboard contents.

hs.hotkey.bind({ "shift", "cmd" }, "v", function()
	hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end)
