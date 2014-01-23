require 'core.GameMap'
require 'core.Display'
require 'core.Camera'
require "io"

local Dsp = Display:new()
local Cam = Camera:new()
local Map = GameMap:new()

Map:renderMap(Cam:getViewport())