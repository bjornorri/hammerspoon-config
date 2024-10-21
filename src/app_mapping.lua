-- Define the AppMapping class
AppMapping = {}
AppMapping.__index = AppMapping

-- Constructor for AppMapping
function AppMapping:new(settingsKey)
	local self = setmetatable({}, AppMapping)

	-- Store the settings key for this instance
	self.settingsKey = settingsKey

	-- Load existing mappings from hs.settings or initialize an empty table
	self.mapping = hs.settings.get(self.settingsKey) or {}

	return self
end

-- Method to retrieve the bundle identifier associated with a character
function AppMapping:getMapping(character)
	return self.mapping[character]
end

-- Method to set the bundle identifier for a given character and persist it
function AppMapping:setMapping(character, bundleIdentifier)
	self.mapping[character] = bundleIdentifier
	self:saveMappings() -- Persist the mappings
end

-- Method to clear the mapping for a given character and persist it
function AppMapping:clearMapping(character)
	self.mapping[character] = nil
	self:saveMappings() -- Persist the mappings
end

-- Method to check if a mapping exists for a given character
function AppMapping:hasMapping(character)
	return self.mapping[character] ~= nil
end

-- Internal method to save the current mappings to persistent storage
function AppMapping:saveMappings()
	hs.settings.set(self.settingsKey, self.mapping)
end
