-- Unminimize windows for the currently focused app using cmd+shift+m
-- Windows are unminimized in LIFO order (last minimized first)

-- Table to track minimized windows per application bundle ID
-- Structure: minimizedStacks[bundleID] = {window1, window2, ...}
local minimizedStacks = {}

-- Create a window filter to watch for minimize/unminimize events
local windowFilter = hs.window.filter.new()

-- Track when a window is minimized
windowFilter:subscribe(hs.window.filter.windowMinimized, function(window, appName, event)
    local app = window:application()
    if not app then return end

    local bundleID = app:bundleID()
    if not bundleID then return end

    -- Initialize stack for this app if it doesn't exist
    if not minimizedStacks[bundleID] then
        minimizedStacks[bundleID] = {}
    end

    -- Add window to the end of the stack (LIFO - we'll pop from the end)
    table.insert(minimizedStacks[bundleID], window)
end)

-- Track when a window is unminimized (by user or other means)
-- Remove it from our tracking so we don't try to unminimize it again
windowFilter:subscribe(hs.window.filter.windowUnminimized, function(window, appName, event)
    local app = window:application()
    if not app then return end

    local bundleID = app:bundleID()
    if not bundleID or not minimizedStacks[bundleID] then return end

    -- Remove this window from the stack
    local stack = minimizedStacks[bundleID]
    for i = #stack, 1, -1 do
        if stack[i] == window then
            table.remove(stack, i)
            break
        end
    end

    -- Clean up empty stacks
    if #stack == 0 then
        minimizedStacks[bundleID] = nil
    end
end)

-- Function to unminimize the most recently minimized window of the frontmost app
local function unminimizeMostRecent()
    local app = hs.application.frontmostApplication()
    if not app then return end

    local bundleID = app:bundleID()
    if not bundleID or not minimizedStacks[bundleID] then return end

    local stack = minimizedStacks[bundleID]

    -- Pop from the end (LIFO - most recently minimized)
    while #stack > 0 do
        local window = table.remove(stack)

        -- Check if window still exists and is still minimized
        if window and window:isMinimized() then
            window:unminimize()
            break
        end
    end

    -- Clean up empty stacks
    if #stack == 0 then
        minimizedStacks[bundleID] = nil
    end
end

-- Function to unminimize the most recently minimized window for a specific app
-- Returns true if a window was unminimized, false otherwise
local function unminimizeForApp(bundleID)
    if not bundleID or not minimizedStacks[bundleID] then return false end

    local stack = minimizedStacks[bundleID]

    -- Pop from the end (LIFO - most recently minimized)
    while #stack > 0 do
        local window = table.remove(stack)

        -- Check if window still exists and is still minimized
        if window and window:isMinimized() then
            window:unminimize()
            -- Clean up empty stacks
            if #stack == 0 then
                minimizedStacks[bundleID] = nil
            end
            return true
        end
    end

    -- Clean up empty stacks
    if #stack == 0 then
        minimizedStacks[bundleID] = nil
    end

    return false
end

-- Bind cmd+shift+m to unminimize the most recently minimized window
hs.hotkey.bind({ "cmd", "shift" }, "m", unminimizeMostRecent)

-- Export function for use by other modules
return {
    unminimizeForApp = unminimizeForApp
}
