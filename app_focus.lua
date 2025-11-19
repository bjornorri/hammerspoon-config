-- app_focus.lua
-- Same behavior as before; only change is how pruning is called (now safe with or without keys)

local AppMapping = require("src/app_mapping")
if type(AppMapping) ~= "table" then AppMapping = _G.AppMapping end

-- Expect `Hyper` to be defined in your init.lua
local bindableKeys = "abcdefghijklmnopqrstuvwxyz`1234567890-=[]\\,./"

hs.application.enableSpotlightForNameSearches(true)

local function getReadableHotkeyString(key) return "Hyper + " .. string.upper(key) end

local function hasNoWindows(app)
  if not app then return true end
  if app:title() == "Finder" then return #app:visibleWindows() <= 1 end
  return #app:visibleWindows() == 0
end

local function keyStroke(mods, key) hs.eventtap.keyStroke(mods, key, 10) end

local function createNewWindow(app)
  if not app then return end
  if app:bundleID() == "com.apple.mail" then keyStroke({ "cmd", "alt" }, "n") else keyStroke({ "cmd" }, "n") end
end

local function focusNextWindow() keyStroke({ "cmd" }, "`") end

local function smartLaunchOrFocus(bundleID)
  local app = hs.application.get(bundleID)
  if not app then
    hs.notify.new({
      title = hs.application.nameForBundleID(bundleID) or bundleID,
      subTitle = "Launching...",
      contentImage = hs.image.imageFromAppBundle(bundleID),
    }):autoWithdraw(true):send()
    hs.application.open(bundleID)
  end
  local focusedApp = hs.application.frontmostApplication()
  if focusedApp == nil or focusedApp:bundleID() ~= bundleID then
    hs.application.open(bundleID); return
  end
  local liveApp = hs.application.get(bundleID)
  if hasNoWindows(liveApp) then createNewWindow(liveApp); return end
  focusNextWindow()
end

local appMapping = AppMapping:new("AppMapping")

local function nameFor(bid) return hs.application.nameForBundleID(bid) or bid end
local function notifyPruned(removedByKey)
  local lines = {}
  for key, bids in pairs(removedByKey) do
    local names = {}
    for _, bid in ipairs(bids) do table.insert(names, nameFor(bid)) end
    table.insert(lines, string.format("%s → %s", string.upper(key), table.concat(names, " · ")))
  end
  if #lines > 0 then
    hs.notify.new({
      title = "Hotkey cleanup",
      subTitle = "Removed uninstalled apps",
      informativeText = table.concat(lines, "\n"),
    }):autoWithdraw(true):send()
  end
end

-- Prune whatever exists in storage; then again after 1.5s (LS cache lag)
notifyPruned(appMapping:pruneAll())           -- no arg: prune everything we know about
hs.timer.doAfter(1.5, function() notifyPruned(appMapping:pruneAll()) end)

-- ===== MRU-cycle session state =====
local cycleState = {}  -- per key: { order = {bids...}, idx = number }

local function runningSet(list)
  local s = {}
  for _, bid in ipairs(list) do if hs.application.get(bid) ~= nil then s[bid] = true end end
  return s
end

local function orderFromMRUThenList(key, list)
  local seen, out = {}, {}
  for _, bid in ipairs(appMapping:getMRU(key)) do
    for _, x in ipairs(list) do if x == bid and not seen[x] then table.insert(out, x); seen[x] = true; break end end
  end
  for _, x in ipairs(list) do if not seen[x] then table.insert(out, x); seen[x] = true end end
  return out
end

local function indexOf(t, v) for i, x in ipairs(t) do if x == v then return i end end end

local function stateValidForList(state, list)
  if not state or not state.order then return false end
  if #state.order ~= #list then return false end
  local want, got = {}, {}
  for _, bid in ipairs(list) do want[bid] = (want[bid] or 0) + 1 end
  for _, bid in ipairs(state.order) do got[bid] = (got[bid] or 0) + 1 end
  for bid, n in pairs(want) do if (got[bid] or 0) ~= n then return false end end
  return true
end

-- ===== group press behavior =====
local function smartLaunchOrFocusGroup(key, list)
  if not list or #list == 0 then return end
  local frontApp = hs.application.frontmostApplication()
  local frontBID = frontApp and frontApp:bundleID() or nil
  local inGroup = false; for _, bid in ipairs(list) do if bid == frontBID then inGroup = true; break end end
  local rset = runningSet(list)
  local runningN = 0; for _ in pairs(rset) do runningN = runningN + 1 end

  if runningN == 0 then
    local order = orderFromMRUThenList(key, list)
    local launchBID = order[1] or list[1]; if not launchBID then return end
    smartLaunchOrFocus(launchBID)
    appMapping:touchMRU(key, launchBID)
    cycleState[key] = { order = order, idx = indexOf(order, launchBID) or 1 }
    return
  end

  if not inGroup or not stateValidForList(cycleState[key], list) then
    local order = orderFromMRUThenList(key, list)
    cycleState[key] = { order = order, idx = 0 }
    local targetIdx = nil
    for i = 1, #order do local bid = order[i]; if rset[bid] then targetIdx = i; break end end
    if not targetIdx then return end
    cycleState[key].idx = targetIdx
    smartLaunchOrFocus(order[targetIdx])
    appMapping:touchMRU(key, order[targetIdx])
    return
  end

  local order = cycleState[key].order
  local idx   = cycleState[key].idx or 0

  if runningN == 1 then
    local onlyBID = nil
    for _, bid in ipairs(order) do if rset[bid] then onlyBID = bid; break end end
    if not onlyBID then return end
    if frontBID == onlyBID then
      if hasNoWindows(frontApp) then createNewWindow(frontApp) else focusNextWindow() end
    else
      smartLaunchOrFocus(onlyBID)
      appMapping:touchMRU(key, onlyBID)
      cycleState[key].idx = indexOf(order, onlyBID) or 1
    end
    return
  end

  local n = #order
  for step = 1, n do
    local i   = ((idx + step - 1) % n) + 1
    local bid = order[i]
    if rset[bid] and bid ~= frontBID then
      cycleState[key].idx = i
      smartLaunchOrFocus(bid)
      appMapping:touchMRU(key, bid)
      return
    end
  end
end

-- ===== membership management (hold) =====
local function notifyGroup(key, list, msg)
  local names = {}
  for _, bid in ipairs(list) do table.insert(names, hs.application.nameForBundleID(bid) or bid) end
  hs.notify.new({
    title = getReadableHotkeyString(key),
    subTitle = msg or ((#list > 0) and ("Bound to: " .. table.concat(names, " · ")) or "Hotkey cleared"),
    contentImage = (#list > 0) and hs.image.imageFromAppBundle(list[1]) or nil,
  }):autoWithdraw(true):send()
end

local function toggleSpecificAppOnKey(key, bundleID)
  if not bundleID or not hs.application.pathForBundleID(bundleID) then
    hs.notify.new({ title = getReadableHotkeyString(key), subTitle = "Can't bind this app (no stable bundle ID)" }):autoWithdraw(true):send()
    return
  end
  if appMapping:hasInList(key, bundleID) then appMapping:removeFromList(key, bundleID) else appMapping:addToList(key, bundleID) end
  cycleState[key] = nil
  notifyGroup(key, appMapping:getList(key))
end

-- ===== snappy press + return-to-original-on-hold binder =====
local function bindImmediatePressWithReturnOnHold(mods, keyParam, onPress, onHoldForApp, holdSeconds)
  local key = keyParam
  local timerRef, capturedBID = nil, nil
  hs.hotkey.bind(mods, key,
    function()
      local front = hs.application.frontmostApplication()
      capturedBID = front and front:bundleID() or nil
      if onPress then onPress() end
      timerRef = hs.timer.doAfter(holdSeconds or 0.4, function()
        timerRef = nil; if not onHoldForApp then return end
        local now = hs.application.frontmostApplication()
        local nowBID = now and now:bundleID() or nil
        if capturedBID and nowBID ~= capturedBID then
          hs.application.open(capturedBID)
          hs.timer.doAfter(0.05, function() onHoldForApp(key, capturedBID) end)
        else
          onHoldForApp(key, capturedBID)
        end
      end)
    end,
    function()
      if timerRef then timerRef:stop(); timerRef = nil end
      capturedBID = nil
    end
  )
end

-- ===== hotkey wiring =====
local HOLD_SECONDS = 0.4
local function handleKeys()
  for i = 1, #bindableKeys do
    local char = bindableKeys:sub(i, i)
    do
      local key = char
      bindImmediatePressWithReturnOnHold(
        Hyper,
        key,
        function()
          if appMapping:hasAny(key) then smartLaunchOrFocusGroup(key, appMapping:getList(key)) end
        end,
        function(k, capturedBID) toggleSpecificAppOnKey(k, capturedBID) end,
        HOLD_SECONDS
      )
    end
  end
end

handleKeys()
