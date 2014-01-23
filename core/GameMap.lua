local class = require 'core.vendor.middleclass.middleclass'
local inspect = require 'core.vendor.inspectlua.inspect'
local display = require 'core.Display'
local Strict = require 'core.vendor.strict_table.strict_table'

Strict.Tileset {
  name = '';
  tile_width = 1;
  tile_height = 1;
  spacing = 0;
  margin = 0;
  image = '';
  tile_count_x = 1;
  tile_count_y = 1;
}

GameMap = class('GameMap')

-- We only use one for the proto
local _parseTileset = function(self, tilesetData)
  return Tileset {
    name = tilesetData.name,
    -- Maybe support multiple tile sizes? Maybe not?
    tile_width = tilesetData.tilewidth,
    tile_height = tilesetData.tileheight,
    spacing = tilesetData.spacing,
    margin = tilesetData.margin,
    image = tilesetData.image,
    -- assuming no margin or spacing for proto
    tile_count_x = tilesetData.imagewidth / tilesetData.tilewidth,
    tile_count_y = tilesetData.imageheight / tilesetData.tileheight
  }
end

function GameMap:initialize() 
  local mapData = require 'assets.map'
  
  self.mapWidth = mapData.width
  self.mapHeight = mapData.height
  self.tileWidth = mapData.tilewidth
  self.tileHeight = mapData.tileheight
  self.dataLayers = mapData.layers
  
  self.tileset = _parseTileset(self, mapData.tilesets[1])
end

local _getMOAIDeck = function(self) 
  tileset = MOAITileDeck2D.new()
  tileset:setTexture(self.tileset.image)
  tileset:setSize(
    self.tileset.tile_count_x,
    self.tileset.tile_count_y
  )
  
  return tileset
end

local _getMOAIGrid = function(self)
  grid = MOAIGrid.new()
  grid:initDiamondGrid(
    self.mapWidth,
    self.mapHeight,
    self.tileWidth,
    self.tileHeight
  )
  
  return grid
end

local _parseLayer = function(self, _viewport)
  layer = MOAILayer2D.new()
  layer:setViewport(_viewport)
  MOAISim.pushRenderPass(layer)
  
  grid = _getMOAIGrid(self)
  for i = 1, self.mapHeight do
    for j = 1, self.mapWidth do
      local tileData = self.dataLayers[1].data[(self.mapHeight-i) * self.mapWidth+j]
      inspect(tileData)
      --local tileData = 15
      grid:setTile(j, i, tileData)
    end
  end
  
  prop = MOAIProp2D.new()
  prop:setDeck(_getMOAIDeck(self))
  prop:setGrid(grid)
  prop:setLoc(-Display.resolutionX/2, -Display.resolutionY/2)
  layer:insertProp(prop)
end

function GameMap:renderMap(_viewport) 
  _parseLayer(self, _viewport) -- We'll parse more layers here in the future
end