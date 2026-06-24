-- src/typing_detector.lua
-- Detect when the user starts and stops typing.
--
-- A "start" event fires on the first keypress after a period of inactivity.
-- A "stop" event fires once no keys have been pressed for `timeout` seconds.
--
-- This is a reusable library. Create an instance and register hooks:
--   local TypingDetector = require("src.typing_detector")
--   local detector = TypingDetector:new({ timeout = 1.0 })
--   detector:onStart(function() ... end)
--   detector:onStop(function() ... end)
--   detector:start()

local TypingDetector = {}
TypingDetector.__index = TypingDetector

-- Create a new detector. Options:
--   timeout: seconds of inactivity before typing is considered to have stopped.
function TypingDetector:new(options)
	options = options or {}

	local self = setmetatable({}, TypingDetector)
	self.timeout = options.timeout or 1.0
	self.isTyping = false
	self.stopTimer = nil
	self.startHooks = {}
	self.stopHooks = {}

	-- Watch for key presses anywhere in the system.
	self.keyTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function()
		self:_onKey()
		-- Returning false passes the event through unmodified.
		return false
	end)

	return self
end

-- Call every hook in the given list, isolating failures so one bad hook
-- doesn't prevent the others from running.
local function fireHooks(hooks)
	for _, hook in ipairs(hooks) do
		local ok, err = pcall(hook)
		if not ok then
			print("typing_detector: hook error: " .. tostring(err))
		end
	end
end

-- Handle a keypress: fire the start event if needed and (re)arm the stop timer.
function TypingDetector:_onKey()
	if not self.isTyping then
		self.isTyping = true
		fireHooks(self.startHooks)
	end

	if self.stopTimer then
		self.stopTimer:stop()
	end
	self.stopTimer = hs.timer.doAfter(self.timeout, function()
		self:_fireStop()
	end)
end

-- Mark typing as stopped and notify listeners.
function TypingDetector:_fireStop()
	if not self.isTyping then return end
	self.isTyping = false
	fireHooks(self.stopHooks)
end

-- Register a function to be called when the user starts typing.
function TypingDetector:onStart(fn)
	table.insert(self.startHooks, fn)
	return self
end

-- Register a function to be called when the user stops typing.
function TypingDetector:onStop(fn)
	table.insert(self.stopHooks, fn)
	return self
end

-- Set how many seconds of inactivity count as having stopped typing.
function TypingDetector:setTimeout(seconds)
	self.timeout = seconds
	return self
end

-- Begin watching for key presses.
function TypingDetector:start()
	self.keyTap:start()
	return self
end

-- Stop watching for key presses and clear any pending stop timer.
function TypingDetector:stop()
	self.keyTap:stop()
	if self.stopTimer then
		self.stopTimer:stop()
		self.stopTimer = nil
	end
	self.isTyping = false
	return self
end

return TypingDetector
