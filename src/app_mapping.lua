-- src/app_mapping.lua
-- AppMapping with:
-- - ordered lists per key
-- - MRU tracking per key
-- - robust pruning (verifies bundle path exists)
-- - removes empty keys from settings
-- - legacy single-value methods kept for compatibility

local AppMapping = {}
AppMapping.__index = AppMapping

function AppMapping:new(settingsKey)
  local self = setmetatable({}, AppMapping)
  self.settingsKey = settingsKey
  self.mapping = hs.settings.get(self.settingsKey) or {}

  -- Migrate legacy formats to { list = {...}, lastIndex = nil|number, mru = {...} }
  for k, v in pairs(self.mapping) do
    if type(v) == "string" then
      self.mapping[k] = { list = { v }, lastIndex = nil, mru = {} }
    elseif type(v) == "table" then
      if v.list == nil and v[1] ~= nil then
        self.mapping[k] = { list = v, lastIndex = nil, mru = {} }
      else
        self.mapping[k].list = self.mapping[k].list or {}
        self.mapping[k].mru  = self.mapping[k].mru  or {}
      end
    else
      self.mapping[k] = { list = {}, lastIndex = nil, mru = {} }
    end
  end

  self:saveMappings()
  return self
end

-- ========= utils =========
local function tableCopy(t)
  local out = {}
  for i, v in ipairs(t or {}) do out[i] = v end
  return out
end

local function isValidBundleID(bid)
  if not bid then return false end
  local path = hs.application.pathForBundleID(bid)
  if not path then return false end
  return hs.fs.attributes(path) ~= nil
end

local function dedupeKeepOrder(list)
  local seen, out = {}, {}
  for _, bid in ipairs(list or {}) do
    if bid and not seen[bid] then seen[bid] = true; table.insert(out, bid) end
  end
  return out
end

-- Returns (filteredList, removedList)
local function pruneList(list)
  local out, removed, seen = {}, {}, {}
  for _, bid in ipairs(list or {}) do
    if bid and not seen[bid] then
      seen[bid] = true
      if isValidBundleID(bid) then table.insert(out, bid) else table.insert(removed, bid) end
    end
  end
  return out, removed
end

local function ensureEntry(self, character)
  self.mapping[character] = self.mapping[character] or { list = {}, lastIndex = nil, mru = {} }
  if not self.mapping[character].list then self.mapping[character].list = {} end
  if not self.mapping[character].mru  then self.mapping[character].mru  = {} end
  return self.mapping[character]
end

local function cleanupEmpty(self, character)
  local e = self.mapping[character]
  if not e then return end
  local listEmpty = not e.list or #e.list == 0
  local mruEmpty  = not e.mru  or #e.mru  == 0
  if listEmpty and mruEmpty and (e.lastIndex == nil) then
    self.mapping[character] = nil
  end
end

local function filterMRU(entry)
  local allow = {}
  for _, bid in ipairs(entry.list or {}) do allow[bid] = true end
  local out = {}
  for _, bid in ipairs(entry.mru or {}) do
    if allow[bid] and isValidBundleID(bid) then table.insert(out, bid) end
  end
  entry.mru = out
end

function AppMapping:saveMappings()
  hs.settings.set(self.settingsKey, self.mapping)
end

-- ========= list API =========
function AppMapping:getList(character)
  local entry = ensureEntry(self, character)
  local cleaned, removed = pruneList(entry.list)
  if #removed > 0 then
    entry.list = cleaned
    if entry.lastIndex and (entry.lastIndex < 1 or entry.lastIndex > #entry.list) then entry.lastIndex = nil end
    filterMRU(entry)
    cleanupEmpty(self, character)
    self:saveMappings()
  else
    filterMRU(entry)
  end
  return tableCopy(entry.list or {})
end

function AppMapping:setList(character, list)
  local entry = ensureEntry(self, character)
  entry.list = dedupeKeepOrder(list or {})
  if entry.lastIndex and (entry.lastIndex < 1 or entry.lastIndex > #entry.list) then entry.lastIndex = nil end
  filterMRU(entry)
  cleanupEmpty(self, character)
  self:saveMappings()
end

function AppMapping:addToList(character, bundleIdentifier)
  local entry = ensureEntry(self, character)
  table.insert(entry.list, bundleIdentifier)
  entry.list = dedupeKeepOrder(entry.list)
  filterMRU(entry)
  self:saveMappings()
end

function AppMapping:removeFromList(character, bundleIdentifier)
  local entry = ensureEntry(self, character)
  local out = {}
  for _, bid in ipairs(entry.list) do if bid ~= bundleIdentifier then table.insert(out, bid) end end
  entry.list = out
  if entry.lastIndex and (entry.lastIndex < 1 or entry.lastIndex > #entry.list) then entry.lastIndex = nil end
  filterMRU(entry)
  cleanupEmpty(self, character)
  self:saveMappings()
end

function AppMapping:clearList(character)
  local entry = ensureEntry(self, character)
  entry.list = {}
  entry.lastIndex = nil
  filterMRU(entry)
  cleanupEmpty(self, character)
  self:saveMappings()
end

function AppMapping:hasInList(character, bundleIdentifier)
  for _, bid in ipairs(self:getList(character)) do if bid == bundleIdentifier then return true end end
  return false
end

function AppMapping:hasAny(character)
  return #self:getList(character) > 0
end

function AppMapping:getLastIndex(character)
  local entry = ensureEntry(self, character)
  return entry.lastIndex
end

function AppMapping:setLastIndex(character, idx)
  local entry = ensureEntry(self, character)
  entry.lastIndex = idx
  self:saveMappings()
end

-- ========= pruning =========
function AppMapping:pruneKey(character)
  local entry = ensureEntry(self, character)
  local cleaned, removed = pruneList(entry.list)
  if #removed > 0 then
    entry.list = cleaned
    if entry.lastIndex and (entry.lastIndex < 1 or entry.lastIndex > #entry.list) then entry.lastIndex = nil end
    filterMRU(entry)
    cleanupEmpty(self, character)
    self:saveMappings()
  else
    filterMRU(entry)
    cleanupEmpty(self, character)
  end
  return removed
end

-- If `keys` is provided (string of characters), prune just those.
-- If omitted, prune ALL keys present in storage (safer).
function AppMapping:pruneAll(keys)
  local removedByKey = {}
  if keys and #keys > 0 then
    for i = 1, #keys do
      local key = keys:sub(i, i)
      local removed = self:pruneKey(key)
      if #removed > 0 then removedByKey[key] = removed end
    end
  else
    for key, _ in pairs(self.mapping) do
      local removed = self:pruneKey(key)
      if #removed > 0 then removedByKey[key] = removed end
    end
  end
  self:saveMappings()
  return removedByKey
end

-- ========= MRU API =========
function AppMapping:getMRU(character)
  local entry = ensureEntry(self, character)
  filterMRU(entry)
  return tableCopy(entry.mru or {})
end

function AppMapping:setMRU(character, list)
  local entry = ensureEntry(self, character)
  entry.mru = list or {}
  filterMRU(entry)
  cleanupEmpty(self, character)
  self:saveMappings()
end

function AppMapping:touchMRU(character, bundleID)
  if not bundleID then return end
  local entry = ensureEntry(self, character)
  local out = {}
  for _, bid in ipairs(entry.mru or {}) do if bid ~= bundleID then table.insert(out, bid) end end
  table.insert(out, 1, bundleID)
  entry.mru = out
  filterMRU(entry)
  self:saveMappings()
end

-- ========= legacy single-value API =========
function AppMapping:getMapping(character)
  local list = self:getList(character)
  return list[1]
end
function AppMapping:setMapping(character, bundleIdentifier)
  self:setList(character, { bundleIdentifier })
end
function AppMapping:clearMapping(character)
  self:clearList(character)
end
function AppMapping:hasMapping(character)
  return self:hasAny(character)
end

return AppMapping
