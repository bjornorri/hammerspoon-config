-- Automatically connects to an iPad via Sidecar.

-- This uses the SidecarLauncher project:
-- https://github.com/Ocasio-J/SidecarLauncher

local function connectSidecar()
    local path = hs.configdir .. "/src/sidecarlauncher.swift"
    local command = "swift " .. path .. " devices | head -n 1 | xargs -I{} " .. "swift " .. path .. " connect '{}'"
    hs.execute(command, true)
end

local function usbDeviceCallback(data)
    if data["eventType"] == "added" and string.match(data["productName"]:lower(), "ipad") then
        connectSidecar()
    end
end

local usbWatcher = hs.usb.watcher.new(usbDeviceCallback)
usbWatcher:start()
