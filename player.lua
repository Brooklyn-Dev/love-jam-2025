local Constants = require('constants')

local Player = {}
Player.__index = Player

function Player.new(x, y, game)
    local self = setmetatable({}, Player)
    self.x = x
    self.y = y
    self.game = game
    self.canMove = true
    self.lastMoveKey = nil
    self.tickCallback = nil
    self.sprites = Constants.PLAYER_SPRITES
    self.frame = 1
    return self
end

function Player:setTickCallback(callback)
    self.tickCallback = callback
end

function Player:nextFrame()
    self.frame = self.frame + 1
    if self.frame > #self.sprites then
        self.frame = 1
    end
end

function Player:move(dx, dy)
    local newX, newY = self.x + dx, self.y + dy

    local is_door = false
    for i, door in ipairs(self.game.doors) do
        if door.x == newX and door.y == newY then
            is_door = true
            if self.game.keysCollected <= 0 then
                break
            end

            table.remove(self.game.doors, i)
            self.game.keysCollected = self.game.keysCollected - 1
            is_door = false
            self.game.soundManager:play('unlock_door')
            break
        end
    end

    if not is_door and not self.game.level:isWall(newX, newY) then
        self.x, self.y = newX, newY
    end

    self.canMove = false
    self:nextFrame()

    if self.tickCallback then
        self.tickCallback()
    end
end

function Player:draw()
    love.graphics.setColor(1.0, 1.0, 1.0)
    love.graphics.draw(self.sprites[self.frame], (self.x - 1) * Constants.TILE_SIZE, (self.y - 1) * Constants.TILE_SIZE, 0, Constants.SPRITE_SCALE, Constants.SPRITE_SCALE)
end

function Player:keypressed(key)
    if self.canMove then
        if key == 'up' then
            self:move(0, -1)
            self.lastMoveKey = key
        elseif key == 'down' then
            self:move(0, 1) 
            self.lastMoveKey = key
        elseif key == 'left' then
            self:move(-1, 0)
            self.lastMoveKey = key
        elseif key == 'right' then
            self:move(1, 0)
            self.lastMoveKey = key
        end
    end
end

function Player:keyreleased(key)
    if key == self.lastMoveKey then
        self.canMove = true
        self.lastMoveKey = nil
    end
end

return Player
