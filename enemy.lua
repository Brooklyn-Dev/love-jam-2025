local Constants = require('constants')

local Enemy = {}
Enemy.__index = Enemy

function Enemy.new(x, y, hard)
    local self = setmetatable({}, Enemy)
    self.x = x
    self.y = y
    self.hard = hard
    self.sprites = (hard and Constants.ENEMY_HARD_SPRITES) or Constants.ENEMY_NORMAL_SPRITES
    self.frame = 1
    return self
end

function Enemy:onTick(path, doors, sameEnemies)
    self:nextFrame()

    if path and #path > 1 then
        local nextTile = path[2]

        
        for _, door in ipairs(doors) do
            if door.x == nextTile.x and door.y == nextTile.y then
                return
            end
        end
        
        for _, enemy in ipairs(sameEnemies) do
            if enemy.x == nextTile.x and enemy.y == nextTile.y then
                return
            end
        end

        self.x, self.y = nextTile.x, nextTile.y
    end
end

function Enemy:nextFrame()
    self.frame = self.frame + 1
    if self.frame > #self.sprites then
        self.frame = 1
    end
end

function Enemy:draw()
    love.graphics.setColor(1.0, 1.0, 1.0)
    love.graphics.draw(self.sprites[self.frame], (self.x - 1) * Constants.TILE_SIZE, (self.y - 1) * Constants.TILE_SIZE, 0, Constants.SPRITE_SCALE, Constants.SPRITE_SCALE)
end

return Enemy