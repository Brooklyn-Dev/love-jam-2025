local Constants = require('constants')

--- @class Key
--- @field x number The x-coordinate of the key.
--- @field y number The y-coordinate of the key.
--- @field sprite table The key sprite image.

local Key = {}
Key.__index = Key

--- Creates a new Key instance.
--- @param x number The x-coordinate of the key.
--- @param y number The y-coordinate of the key.
--- @return Key
function Key.new(x, y)
    local self = setmetatable({}, Key)

    self.x = x
    self.y = y
    self.sprite = Constants.KEY_SPRITE
    
    return self
end

--- Draws the key at its current position.
function Key:draw()
    love.graphics.setColor(Constants.WHITE)
    love.graphics.draw(self.sprite, (self.x - 1) * Constants.TILE_SIZE, (self.y - 1) * Constants.TILE_SIZE, 0, Constants.SPRITE_SCALE, Constants.SPRITE_SCALE)
end

return Key