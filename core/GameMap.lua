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
    tile_count_x = 
      (tilesetData.imagewidth - tilesetData.margin)  / (tilesetData.tilewidth + tilesetData.spacing),
    tile_count_y = 
      (tilesetData.imageheight - tilesetData.margin) / (tilesetData.tileheight + tilesetData.spacing)
  }
end

function GameMap:initialize() 
  local mapData = require 'assets.experimental_large_map'
  
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
  
  local tileset_width = 
    (self.tileset.tile_count_x * (self.tileWidth + self.tileset.spacing)) + self.tileset.margin
  local tileset_height = 
    (self.tileset.tile_count_y * (self.tileHeight + self.tileset.spacing)) + self.tileset.margin
    
  tileset:setSize(
    -- size x, y
    self.tileset.tile_count_x,
    self.tileset.tile_count_y,
    -- cell width, height
    (self.tileWidth + self.tileset.spacing) / tileset_width,
    (self.tileHeight + self.tileset.spacing) / tileset_height,
    -- offset y, x
    self.tileset.spacing / tileset_width, 
    self.tileset.spacing / tileset_height,
    self.tileWidth / tileset_width,
    self.tileHeight / tileset_height
  )
  
  print(self.tileHeight / 
      ((self.tileset.tile_count_y * (self.tileHeight + self.tileset.spacing)) + self.tileset.margin))
  return tileset
end

local _getMOAIGrid = function(self)
  grid = MOAIGrid.new()
  grid:initRectGrid(
    self.mapWidth,
    self.mapHeight,
    self.tileWidth,
    self.tileHeight
  )
  
  return grid
end

local _parseLayer = function(self, _viewport, _data_layer)
  layer = MOAILayer2D.new()
  layer:setViewport(_viewport)
  MOAISim.pushRenderPass(layer)
  
  grid = _getMOAIGrid(self)
  for i = 1, self.mapHeight do
    for j = 1, self.mapWidth do
      local tileData = _data_layer[(self.mapHeight-i) * self.mapWidth+j]
      --print(tileData)
      grid:setTile(j, i, tileData)
    end
  end
  
  prop = MOAIProp2D.new()
  prop:setDeck(_getMOAIDeck(self))
  prop:setGrid(grid)
  -- Why oh why I wonder
  prop:setLoc(-Display.resolutionX/4, -Display.resolutionY/4)
  layer:insertProp(prop)
end

function GameMap:renderMap(_viewport) 
  for key, layer in ipairs(self.dataLayers) do
    _parseLayer(self, _viewport, layer.data) 
  end
end