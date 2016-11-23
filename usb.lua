-- React to USB events.
local kinesisKeyboard = "Kinesis Keyboard Hub"
function usbEventCallback(info)
    -- Change the keyboard layout when Kinesis Advantage is connected/disconnected.
    local event = info["eventType"]
    local device = info["productName"]
    if device == kinesisKeyboard then
        if event == "added" then
            hs.keycodes.setLayout("U.S.")
        else
            hs.keycodes.setLayout("Dvorak")
        end
        hs.reload()
    end
end

usbWatcher = hs.usb.watcher.new(usbEventCallback)
usbWatcher:start()
