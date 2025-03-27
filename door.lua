local Constants = require('constants')

local Door = {}
Door.__index = Door

function Door.new(x, y)
    local self = setmetatable({}, Door)
    self.x = x
    self.y = y
    self.sprite = Constants.DOOR_SPRITE
    return self
end

function Door:draw()
    love.graphics.setColor(1.0, 1.0, 1.0)
    love.graphics.draw(self.sprite, (self.x - 1) * Constants.TILE_SIZE, (self.y - 1) * Constants.TILE_SIZE, 0, Constants.SPRITE_SCALE, Constants.SPRITE_SCALE)
end

return Door