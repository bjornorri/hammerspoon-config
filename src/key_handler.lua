-- Define a KeyHandler class
KeyHandler = {}
KeyHandler.__index = KeyHandler

-- Constructor for KeyHandler
function KeyHandler:new(modifiers, key, pressCallback, holdCallback, holdDuration)
	local self = setmetatable({}, KeyHandler)

	-- Store the callbacks and the hold duration (in seconds)
	self.pressCallback = pressCallback
	self.holdCallback = holdCallback
	self.modifiers = modifiers
	self.key = key
	self.isHeld = false
	self.holdDuration = holdDuration or 5 -- Default to 5 seconds if not provided

	-- Define a timer to check if the key is held
	self.holdTimer = hs.timer.delayed.new(self.holdDuration, function()
		if self.isHeld and self.holdCallback then
			self.holdCallback()
		end
	end)

	-- Bind the key combination
	self.hotkey = hs.hotkey.bind(modifiers, key, function()
		self:onKeyPress()
	end, function()
		self:onKeyRelease()
	end)

	return self
end

-- Function called when key is pressed
function KeyHandler:onKeyPress()
	self.isHeld = true

	-- Start the hold timer
	self.holdTimer:start()

	-- Trigger the press callback
	if self.pressCallback then
		self.pressCallback()
	end
end

-- Function called when key is released
function KeyHandler:onKeyRelease()
	self.isHeld = false

	-- Stop the hold timer
	self.holdTimer:stop()
end

-- Destructor to clean up the hotkey binding
function KeyHandler:delete()
	self.hotkey:delete()
end

-- Example usage:
local keyHandler = KeyHandler:new(
	{ "cmd", "alt" },
	"h",
	function()
		-- This will be triggered when the key combination is pressed
		hs.alert.show("Key Pressed!")
	end,
	function()
		-- This will be triggered when the key combination is held for the specified duration
		hs.alert.show("Key Held!")
	end,
	3 -- Hold duration in seconds
)
