local class = require 'core.vendor.middleclass.middleclass'
local inspect = require 'core.vendor.inspectlua.inspect'
 
Display = class('Display')

Display.static.resolutionX = 1024
Display.static.resolutionY = 768

function Display:initialize() 
  MOAISim.openWindow ('Test', Display.resolutionX, Display.resolutionY)
end