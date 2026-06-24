-- Notify Karabiner-Elements when the user is typing.
--
-- Sets a Karabiner variable (default "typing") to 1 while typing and 0
-- otherwise, via karabiner_cli. Use the variable in karabiner.json with a
-- `variable_if` condition to enable/disable rules while typing.

local TypingDetector = require("src.typing_detector")

-- Name of the Karabiner variable to toggle.
local VARIABLE_NAME = "active_typing"

-- Seconds of inactivity before typing is considered to have stopped.
local TIMEOUT = 0.5

-- Path to the karabiner_cli binary (default install location).
local KARABINER_CLI = "/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli"

-- The most recently requested value, the value last sent to karabiner_cli, and
-- whether a karabiner_cli process is currently running. These serialize writes
-- so only one process runs at a time and we always converge to the latest
-- requested value, avoiding out-of-order completion leaving a stale state.
local desiredValue = 0
local sentValue = nil
local busy = false

-- Launch karabiner_cli for the latest desired value, if needed. Re-runs from
-- the task's completion callback so a value requested mid-flight still lands.
local function flush()
	if busy or desiredValue == sentValue then return end

	local value = desiredValue
	busy = true
	sentValue = value

	local args = { "--set-variables", string.format('{"%s":%d}', VARIABLE_NAME, value) }
	print(string.format("karabiner_typing_notifier: setting %s=%d", VARIABLE_NAME, value))
	hs.task.new(KARABINER_CLI, function(exitCode, _, stdErr)
		busy = false
		if exitCode ~= 0 then
			print(string.format("karabiner_typing_notifier: karabiner_cli exited %d: %s", exitCode, stdErr or ""))
		end
		flush()
	end, args):start()
end

-- Request that the Karabiner variable be set to the given value.
local function setVariable(value)
	desiredValue = value
	flush()
end

local detector = TypingDetector:new({ timeout = TIMEOUT })

detector:onStart(function()
	setVariable(1)
end)

detector:onStop(function()
	setVariable(0)
end)

detector:start()

-- Normalize the variable on (re)load so a reload mid-typing can't leave it
-- stuck at 1. The next keystroke re-sets it within the timeout window.
setVariable(0)

return detector
