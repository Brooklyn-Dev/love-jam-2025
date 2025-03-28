local Constants = require('constants')

--- @class Door
--- @field x number The x-coordinate of the door.
--- @field y number The y-coordinate of the door.
--- @field sprite table The door sprite image.

local Door = {}
Door.__index = Door

--- Creates a new Door instance.
--- @param x number The x-coordinate of the door.
--- @param y number The y-coordinate of the door.
--- @return Door
function Door.new(x, y)
    local self = setmetatable({}, Door)

    self.x = x
    self.y = y
    self.sprite = Constants.DOOR_SPRITE

    return self
end

--- Draws the door at its current position.
function Door:draw()
    love.graphics.setColor(Constants.WHITE)
    love.graphics.draw(self.sprite, (self.x - 1) * Constants.TILE_SIZE, (self.y - 1) * Constants.TILE_SIZE, 0, Constants.SPRITE_SCALE, Constants.SPRITE_SCALE)
end

return Door