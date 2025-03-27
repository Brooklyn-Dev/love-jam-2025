local Constants = require('constants')
local Utils = require('utils')

local Level = {}
Level.__index = Level

function Level.new(filename, seed)
    local self = setmetatable({}, Level)
    self.tiles = {}
    self.entityPositions = {}
    self.brightnessMap = {}
    self.exit = nil
    self.seed  = seed
    math.randomseed(self.seed)

    -- Load level file
    local lines = Utils.readFileLines(filename)

    -- Extract tiles and entities
    for y, line in ipairs(lines) do
        self.tiles[y] = {}
        self.brightnessMap[y] = {}

        for x = 1, #line do
            local tile = line:sub(x, x)

            -- Tiles
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

            -- Entities
            if tile == 'P' then
                table.insert(self.entityPositions, {type = 'player', x = x, y = y})
            elseif tile == 'N' then
                table.insert(self.entityPositions, {type = 'enemy_normal', x = x, y = y})
            elseif tile == 'H' then
                table.insert(self.entityPositions, {type = 'enemy_hard', x = x, y = y})
            elseif tile == 'S' then
                table.insert(self.entityPositions, {type = 'spike', x = x, y = y})
            elseif tile == 'K' then
                table.insert(self.entityPositions, {type = 'key', x = x, y = y})
            elseif tile == 'D' then
                table.insert(self.entityPositions, {type = 'door', x = x, y = y})
            end
        end
    end

    return self
end

function Level:isWall(x, y)
    return self.tiles[y] and self.tiles[y][x] == 'wall'
end

function Level:draw()
    for y = 1, #self.tiles do
        for x = 1, #self.tiles[y] do
            local tile = self.tiles[y][x]
            if tile == 'wall' then  -- Wall
                local brightness = self.brightnessMap[y][x]
                love.graphics.setColor(brightness, brightness, brightness)
                love.graphics.draw(Constants.WALL_SPRITE, (x - 1) * Constants.TILE_SIZE, (y - 1) * Constants.TILE_SIZE, 0, Constants.SPRITE_SCALE, Constants.SPRITE_SCALE)
            elseif tile == 'exit' then  --  Exit
                love.graphics.setColor(1.0, 1.0, 1.0)
                love.graphics.draw(Constants.EXIT_SPRITE, (self.exit.x - 1) * Constants.TILE_SIZE, (self.exit.y - 1) * Constants.TILE_SIZE, 0, Constants.SPRITE_SCALE, Constants.SPRITE_SCALE)
            end
        end
    end

end

return Level