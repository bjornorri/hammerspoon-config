-- Replace jumpcut.
local jumpcut = hs.menubar.new()
jumpcut:setTitle("✂")

-- Constants.
local interval = 0.8
local storeCount = 20
local labelLength = 40
local trim = false 
local trim_display = true

-- Variables.
local clipboard = hs.settings.get("jumpcut") or {}
local lastCount = hs.pasteboard.changeCount()

function populateMenu(key)
    menuData = {}
    if #clipboard == 0 then
        table.insert(menuData, {title="None", disabled=true})
    else
        for key, val in pairs(clipboard) do
            local title = val
            if trim_display then title = (title:gsub("^%s*(.-)%s*$", "%1")) end
            if string.len(title) > labelLength then
                title = string.sub(title, 0, labelLength).."..."
            end
            table.insert(menuData, 1, {title=title, fn=function()
                table.remove(clipboard, key)
                hs.pasteboard.setContents(val)
            end})
        end
        table.insert(menuData, {title="-"})
        table.insert(menuData, {title="Clear All", fn=clear})
    end
    return menuData
end

function clear()
    hs.pasteboard.clearContents()
    clipboard = {}
    hs.settings.set("jumpcut", clipboard)
    lastCount = hs.pasteboard.changeCount()
end

function update()
    local count = hs.pasteboard.changeCount()
    if count ~= lastCount then
        lastCount = count
        local content = hs.pasteboard.getContents()
        if trim then content = (content:gsub("^%s*(.-)%s*$", "%1")) end
        if content ~= clipboard[#clipboard] and content ~= "" then
            while #clipboard >= storeCount do
                table.remove(clipboard, 1)
            end
            table.insert(clipboard, content)
            hs.settings.set("jumpcut", clipboard)
        end
    end
end

hs.hotkey.bind(hyper, 'v', function()
    local f = jumpcut:frame()
    jumpcut:popupMenu(hs.geometry.point(f.x, f.y + f.h))
end)

timer = hs.timer.new(interval, update)
timer:start()
jumpcut:setMenu(populateMenu)
