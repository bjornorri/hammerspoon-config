require('utils')
require('reload')
require('caffeine')
require('position')
require('focus')
require('jumpcut')
require('wifi')
require('usb')
require('misc')

-- Notify that the config was loaded.
hs.notify.new({title="Hammerspoon", informativeText="Config loaded"}):send()
