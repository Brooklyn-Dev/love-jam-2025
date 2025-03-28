local Constants = require('constants')

--- @class Player
--- @field x number The x-coordinate of the player.
--- @field y number The y-coordinate of the player.
--- @field game Game The game instance this player is part of.
--- @field canMove boolean Whether the player can move or not.
--- @field lastMoveKey string The last movement key pressed by the player.
--- @field tickCallback function The callback function to call each tick.
--- @field sprites table List of player sprite images.
--- @field frame number Current animation frame of the player.

local Player = {}
Player.__index = Player

--- Creates a new Player instance.
--- @param x number The x-coordinate of the player.
--- @param y number The y-coordinate of the player.
--- @param game Game The game instance that this player belongs to.
--- @return Player
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

--- Sets the callback function to be called on each game tick.
--- @param callback function The function to call each tick.
function Player:setTickCallback(callback)
    self.tickCallback = callback
end

--- Advances the player animation to the next frame.
function Player:nextFrame()
    self.frame = self.frame + 1
    if self.frame > #self.sprites then
        self.frame = 1
    end
end

--- Moves the player.
--- Handles interactions with doors and walls.
--- @param dx number The change in x-coordinate.
--- @param dy number The change in y-coordinate.
function Player:move(dx, dy)
    local newX, newY = self.x + dx, self.y + dy

    local isDoor = false
    for i, door in ipairs(self.game.doors) do
        if door.x == newX and door.y == newY then
            isDoor = not self.game:unlockDoor(i)
            break
        end
    end

    if not isDoor and not self.game.level:isWall(newX, newY) then
        self.x, self.y = newX, newY
    end

    self.canMove = false
    self:nextFrame()

    if self.tickCallback then
        self.tickCallback()
    end
end

--- Draws the player at its current position.
function Player:draw()
    love.graphics.setColor(Constants.WHITE)
    love.graphics.draw(self.sprites[self.frame], (self.x - 1) * Constants.TILE_SIZE, (self.y - 1) * Constants.TILE_SIZE, 0, Constants.SPRITE_SCALE, Constants.SPRITE_SCALE)
end

--- Handles key presses.
--- @param key string The key that was pressed.
function Player:keypressed(key)
    if self.canMove then
        -- Move the player based on the key pressed.
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

--- Handles key releases.
--- @param key string The key that was released.
function Player:keyreleased(key)
    -- Re-enable movement if the last move key is released.
    if key == self.lastMoveKey then
        self.canMove = true
        self.lastMoveKey = nil
    end
end

return Player
