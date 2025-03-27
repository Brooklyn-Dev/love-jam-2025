local Constants = require('constants')

local Spike = {}
Spike.__index = Spike

function Spike.new(x, y)
    local self = setmetatable({}, Spike)
    self.x = x
    self.y = y
    self.active = true
    self.sprites = Constants.SPIKE_SPRITES
    self.frame = 1
    return self
end

function Spike:onTick()
    self.active = not self.active
    self:nextFrame()
end

function Spike:nextFrame()
    self.frame = self.frame + 1
    if self.frame > #self.sprites then
        self.frame = 1
    end
end

function Spike:draw()
    love.graphics.setColor(1.0, 1.0, 1.0)
    love.graphics.draw(self.sprites[self.frame], (self.x - 1) * Constants.TILE_SIZE, (self.y - 1) * Constants.TILE_SIZE, 0, Constants.SPRITE_SCALE, Constants.SPRITE_SCALE)
end

return Spike