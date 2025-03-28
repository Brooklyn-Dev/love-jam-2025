local Constants = require('constants')
local Utils = require('utils')

--- @class Level
--- @field tiles table The grid of tiles representing the level layout.
--- @field entityPositions table The list of entities in the level (player, enemies, etc.).
--- @field brightnessMap table The brightness values for wall tiles.
--- @field exit table The position of the exit in the level.
--- @field seed number Random seed for rng.

local Level = {}
Level.__index = Level

--- Creates a new Level instance from a file.
--- @param filename string The path to the level file.
--- @param seed number The random seed to use for the level.
--- @return Level
function Level.new(filename, seed)
    local self = setmetatable({}, Level)

    self.tiles = {}
    self.entityPositions = {}
    self.brightnessMap = {}
    self.exit = nil
    self.seed  = seed

    math.randomseed(self.seed)

    -- Load the level file into lines
    local lines = Utils.readFileLines(filename)

    -- Parse the level file and extract tiles and entities
    for y, line in ipairs(lines) do
        self.tiles[y] = {}
        self.brightnessMap[y] = {}

        for x = 1, #line do
            local tile = line:sub(x, x)

            -- Determine the type of tile at the current position.
            if tile == '1' then  -- Wall
                self.tiles[y][x] = 'wall'

                if math.random() < 0.4 then
                    local randBrightness = Constants.WALL_BRIGHTNESSES[math.random(#Constants.WALL_BRIGHTNESSES)]
                    self.brightnessMap[y][x] = randBrightness
                else
                    self.brightnessMap[y][x] = 1.0
                end

            elseif tile == 'E' then  -- Exit
                self.tiles[y][x] = 'exit'
                self.exit = { x = x, y = y }

            else  -- Empty space
                self.tiles[y][x] = 'empty'
            end

            -- Add entities to the entity list based on their type.
            if tile == 'P' then
                table.insert(self.entityPositions, { type = 'player', x = x, y = y })
            elseif tile == 'N' then
                table.insert(self.entityPositions, { type = 'enemy_normal', x = x, y = y })
            elseif tile == 'H' then
                table.insert(self.entityPositions, { type = 'enemy_hard', x = x, y = y })
            elseif tile == 'S' then
                table.insert(self.entityPositions, { type = 'spike', x = x, y = y })
            elseif tile == 'K' then
                table.insert(self.entityPositions, { type = 'key', x = x, y = y })
            elseif tile == 'D' then
                table.insert(self.entityPositions, { type = 'door', x = x, y = y })
            end
        end
    end

    return self
end

--- Checks if the given coordinates represent a wall tile.
--- @param x number The x-coordinate.
--- @param y number The y-coordinate.
--- @return boolean True if the tile is a wall, false otherwise.
function Level:isWall(x, y)
    return self.tiles[y] and self.tiles[y][x] == 'wall'
end

--- Draws the level to the screen, including walls, exit, and other entities.
function Level:draw()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[y] do
            local tile = self.tiles[y][x]

            -- Draw wall tiles with brightness.
            if tile == 'wall' then
                local brightness = self.brightnessMap[y][x]
                love.graphics.setColor(brightness, brightness, brightness)
                love.graphics.draw(Constants.WALL_SPRITE, (x - 1) * Constants.TILE_SIZE, (y - 1) * Constants.TILE_SIZE, 0, Constants.SPRITE_SCALE, Constants.SPRITE_SCALE)

            -- Draw the exit sprite if the tile is an exit.
            elseif tile == 'exit' then
                love.graphics.setColor(Constants.WHITE)
                love.graphics.draw(Constants.EXIT_SPRITE, (self.exit.x - 1) * Constants.TILE_SIZE, (self.exit.y - 1) * Constants.TILE_SIZE, 0, Constants.SPRITE_SCALE, Constants.SPRITE_SCALE)
            end
        end
    end

end

return Level