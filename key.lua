local Constants = require('constants')

local Key = {}
Key.__index = Key

function Key.new(x, y)
    local self = setmetatable({}, Key)
    self.x = x
    self.y = y
    self.sprite = Constants.KEY_SPRITE
    return self
end

function Key:draw()
    love.graphics.setColor(1.0, 1.0, 1.0)
    love.graphics.draw(self.sprite, (self.x - 1) * Constants.TILE_SIZE, (self.y - 1) * Constants.TILE_SIZE, 0, Constants.SPRITE_SCALE, Constants.SPRITE_SCALE)
end

return Key