-- React to WiFi events.
local wifiWatcher = nil
local homeSSIDs = {"WG3C_1", "WG3C_3"}
local uniSSIDs = {"eth", "eth-5", "eduroam"}
local lastSSID = hs.wifi.currentNetwork()

function ssidChangedCallback()
    newSSID = hs.wifi.currentNetwork()

    if newSSID == "WG3C_3" then
        hs.notify.new({title="Hammerspoon", informativeText="Joined WG3C_3"}):send()
    end

    lastSSID = newSSID
end

wifiWatcher = hs.wifi.watcher.new(ssidChangedCallback)
wifiWatcher:start()
