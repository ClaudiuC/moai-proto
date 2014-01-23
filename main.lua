require 'core.GameMap'
require 'core.Display'
require 'core.Camera'

local Dsp = Display:new()
local Cam = Camera:new()
local Map = GameMap:new()

Map:renderMap(Cam:getViewport())