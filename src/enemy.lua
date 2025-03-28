local Constants = require('constants')

--- @class Enemy
--- @field x number The x-coordinate of the enemy.
--- @field y number The y-coordinate of the enemy.
--- @field hard boolean A flag indicating whether the enemy is a "hard" enemy.
--- @field sprites table List of enemy sprite images.
--- @field frame number Current animation frame of the enemy.

local Enemy = {}
Enemy.__index = Enemy

--- Creates a new Enemy instance.
--- @param x number The x-coordinate of the enemy.
--- @param y number The y-coordinate of the enemy.
--- @param hard boolean Whether the enemy is a "hard" enemy.
--- @return Enemy
function Enemy.new(x, y, hard)
    local self = setmetatable({}, Enemy)

    self.x = x
    self.y = y
    self.hard = hard
    self.sprites = (hard and Constants.ENEMY_HARD_SPRITES) or Constants.ENEMY_NORMAL_SPRITES
    self.frame = 1

    return self
end

--- Updates the enemy's position each tick.
--- @param path table The calculated path to move along.
--- @param doors table List of doors to avoid.
--- @param sameEnemies table List of same type enemies to avoid.
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

--- Advances the enemy animation to the next frame.
function Enemy:nextFrame()
    self.frame = self.frame + 1
    if self.frame > #self.sprites then
        self.frame = 1  -- Loop back to the first frame when animation ends.
    end
end

--- Draws the enemy at its current position.
function Enemy:draw()
    love.graphics.setColor(Constants.WHITE)
    love.graphics.draw(self.sprites[self.frame], (self.x - 1) * Constants.TILE_SIZE, (self.y - 1) * Constants.TILE_SIZE, 0, Constants.SPRITE_SCALE, Constants.SPRITE_SCALE)
end

return Enemy