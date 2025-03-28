local Constants = require('constants')

--- @class Spike
--- @field x number The x-coordinate of the spike.
--- @field y number The y-coordinate of the spike.
--- @field active boolean Whether the spike is currently active.
--- @field sprites table List of spike sprite images.
--- @field frame number Current animation frame of the spike.

local Spike = {}
Spike.__index = Spike

--- Creates a new Spike instance.
--- @param x number The x-coordinate of the spike.
--- @param y number The y-coordinate of the spike.
--- @return Spike
function Spike.new(x, y)
    local self = setmetatable({}, Spike)

    self.x = x
    self.y = y
    self.active = true
    self.sprites = Constants.SPIKE_SPRITES
    self.frame = 1

    return self
end

--- Updates the spike state on each tick.
--- Toggles between active and inactive states and updates its animation frame.
function Spike:onTick()
    self.active = not self.active
    self:nextFrame()
end

--- Advances the spike animation to the next frame.
function Spike:nextFrame()
    self.frame = self.frame + 1
    if self.frame > #self.sprites then
        self.frame = 1  -- Loop back to the first frame when animation ends.
    end
end

--- Draws the spike at its current position.
function Spike:draw()
    love.graphics.setColor(Constants.WHITE)
    love.graphics.draw(self.sprites[self.frame], (self.x - 1) * Constants.TILE_SIZE, (self.y - 1) * Constants.TILE_SIZE, 0, Constants.SPRITE_SCALE, Constants.SPRITE_SCALE)
end

return Spike