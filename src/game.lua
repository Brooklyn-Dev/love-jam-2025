local Constants = require('constants')
local AStar = require("pathfinding")
local SoundManager = require("sound_manager")
local Animator = require("animator")

local Level = require('level')
local Player = require('player')
local Enemy = require('enemy')
local Spike = require('spike')
local Key = require('key')
local Door = require('door')

--- @class Game
--- @field seed number Random seed for rng.
--- @field levelIndex number Current level number.
--- @field levelReset boolean Whether the level is resetting.
--- @field levelComplete boolean Whether the level is completed.
--- @field keysCollected number Number of keys collected.
--- @field soundManager SoundManager Handles sound effects.
--- @field animator Animator Handles level transition animations.
--- @field level Level The current level instance.
--- @field player Player The player entity.
--- @field enemiesNormal Enemy[] List of normal enemy entities.
--- @field enemiesHard Enemy[] List of hard enemy entities.
--- @field spikes Spike[] List of spike entities.
--- @field keys Key[] List of keys in the level.
--- @field doors Door[] List of doors in the level.

local Game = {}
Game.__index = Game

--- Creates a new Game instance.
--- @return Game
function Game.new()
    local self = setmetatable({}, Game)

    -- Game state
    self.seed = os.time()
    self.state = 'playing'
    self.levelIndex = 1
    self.levelReset = false
    self.levelComplete = false
    self.keysCollected = 0

    self.soundManager = SoundManager.new()
    self.animator = Animator.new(0.3)

    self:loadLevel(self.levelIndex)

    return self
end

--- Loads a level by index.
--- @param levelIndex number The index of the level to load.
function Game:loadLevel(levelIndex)
    self.level = Level.new('levels/' .. levelIndex .. '.txt', self.seed)
    self.keysCollected = 0

    -- Reset all entities
    self.player = nil
    self.enemiesNormal = {}
    self.enemiesHard = {}
    self.spikes = {}
    self.keys = {}
    self.doors = {}

    -- Spawn entities from level data
    for _, entityData in ipairs(self.level.entityPositions) do
        self:spawnEntity(entityData)
    end
end

--- Spawns an entity based on level data.
--- @param entityData table Contains x, y, and type of the entity.
function Game:spawnEntity(entityData)
    local x, y, entityType = entityData.x, entityData.y, entityData.type
    local e = self.entities

    if entityType == 'player' then
        self.player = Player.new(x, y, self)
        self.player:setTickCallback(function() self:tick() end)

    elseif entityType == 'enemy_normal' then
        table.insert(self.enemiesNormal, Enemy.new(x, y, false))

    elseif entityType == 'enemy_hard' then
        table.insert(self.enemiesHard, Enemy.new(x, y, true))

    elseif entityType == 'spike' then
        table.insert(self.spikes, Spike.new(x, y))

    elseif entityType == 'key' then
        table.insert(self.keys, Key.new(x, y))

    elseif entityType == 'door' then
        table.insert(self.doors, Door.new(x, y))
    end
end

--- Resets the current level, triggering transition animation.
function Game:resetLevel()
    self.soundManager:play('player_death')
    self.levelReset = true
    self.animator:start()
end

--- Loads the next level, resetting the game state.
function Game:nextLevel()
    self.seed = os.time()
    self.levelIndex = self.levelIndex + 1
    self.soundManager:play('next_level')
    self.levelComplete = true
    self.animator:start()
end

--- Handles a game tick (step), updating all entities.
function Game:tick()
    self.soundManager:play('footstep')

    self:moveEnemies(self.enemiesNormal, false)
    self:moveEnemies(self.enemiesHard, true)
    self:resolveEnemyCollisions()

    self:checkSpikeCollisions()
    self:checkKeyCollection()
    self:checkExit()
end

--- Moves enemies based on pathfinding.
--- @param enemies table List of enemies to move.
--- @param isHard boolean Whether the enemies are 'hard' type.
function Game:moveEnemies(enemies, isHard)
    for _, enemy in ipairs(enemies) do
        local path = AStar:findPath(enemy.x, enemy.y, self.player.x, self.player.y, self.level.tiles, isHard)
        enemy:onTick(path, self.doors, enemies)

        -- Check if enemy reached the player
        if self:isPlayerAt(enemy.x, enemy.y) then
            self:resetLevel()
            return
        end
    end
end

--- Resolves collisions between normal and hard enemies.
function Game:resolveEnemyCollisions()
    local enemiesToDelete = {}

    for i, enemyNormal in ipairs(self.enemiesNormal) do
        for j, enemyHard in ipairs(self.enemiesHard) do
            if enemyNormal.x == enemyHard.x and enemyNormal.y == enemyHard.y then
                table.insert(enemiesToDelete, { normal = i, hard = j })
                self.soundManager:play('enemy_death')
            end
        end
    end

    for _, pair in ipairs(enemiesToDelete) do
        table.remove(self.enemiesNormal, pair.normal)
        table.remove(self.enemiesHard, pair.hard)
    end
end

--- Handles spike collisions for the player and enemies.
function Game:checkSpikeCollisions()
    for _, spike in ipairs(self.spikes) do
        spike:onTick()

        if not spike.active then goto continue end

        -- Check if player is on a spike
        if self:isPlayerAt(spike.x, spike.y) then
            self:resetLevel()
            return
        end

        -- Check if enemies are on a spike
        local enemiesToDelete = {}
        for i, enemy in ipairs(self.enemiesNormal) do
            if spike.x == enemy.x and spike.y == enemy.y then
                table.insert(enemiesToDelete, i)
            end
        end

        for _, index in ipairs(enemiesToDelete) do
            table.remove(self.enemiesNormal, index)
            self.soundManager:play('enemy_death')
        end

        enemiesToDelete = {}
        for i, enemy in ipairs(self.enemiesHard) do
            if spike.x == enemy.x and spike.y == enemy.y then
                table.insert(enemiesToDelete, i)
            end
        end

        for _, index in ipairs(enemiesToDelete) do
            table.remove(self.enemiesHard, index)
            self.soundManager:play('enemy_death')
        end

        ::continue::
    end
end

--- Handles key collection.
function Game:checkKeyCollection()
    local keyDeleteIndex = nil
    for i, key in ipairs(self.keys) do
        if self:isPlayerAt(key.x, key.y) then
            self.keysCollected = (self.keysCollected or 0) + 1
            keyDeleteIndex = i
            break
        end
    end

    if keyDeleteIndex ~= nil then
        table.remove(self.keys, keyDeleteIndex)
        self.soundManager:play('pickup_key')
    end
end

--- Checks if the player reached the exit.
function Game:checkExit()
    if self.level.exit and self:isPlayerAt(self.level.exit.x, self.level.exit.y) then
        self:nextLevel()
    end
end

--- Delete door if has keys and return true if successful.
--- @return boolean
function Game:unlockDoor(doorIndex)
    if self.keysCollected > 0 then
        table.remove(self.doors, doorIndex)
        self.keysCollected = self.keysCollected - 1
        self.soundManager:play('unlock_door')

        return true
    end

    return false
end

--- Utility function to check if the player is at a given position.
--- @param x number X coordinate.
--- @param y number Y coordinate.
--- @return boolean
function Game:isPlayerAt(x, y)
    return self.player and self.player.x == x and self.player.y == y
end

--- Updates the game state each frame.
--- @param dt number Delta time since the last update.
function Game:update(dt)
    self.animator:update(dt)

    if self.animator:getProgress() >= 0.5 then
        if self.levelReset then
            self:loadLevel(self.levelIndex)
            self.levelReset = false

        elseif self.levelComplete then
            self:loadLevel(self.levelIndex)
            self.levelComplete = false
        end
    end
end

--- Draws the game screen.
function Game:draw()
    -- Centre game screen
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local offsetX = (screenWidth - 8 * Constants.TILE_SIZE) / 2
    local offsetY = (screenHeight - 8 * Constants.TILE_SIZE) / 2
    love.graphics.translate(offsetX, offsetY)

    self.level:draw()
    self:drawEntities(self.enemiesNormal)
    self:drawEntities(self.enemiesHard)
    self:drawEntities(self.spikes)
    self:drawEntities(self.keys)
    self:drawEntities(self.doors)

    if not self.levelReset and not self.levelComplete then
        self.player:draw()
    end

    self:drawUI()
end

--- Draws all entities in a given list.
--- @param entities table List of entities.
function Game:drawEntities(entities)
    for _, entity in ipairs(entities) do
        entity:draw()
    end
end

--- Draws user interface elements
function Game:drawUI()
    local screenWidth, screenHeight = love.graphics.getDimensions()

    love.graphics.origin()

    love.graphics.setColor(Constants.TEXT_COLOUR)

    love.graphics.print("Level: " .. self.levelIndex, 0, 0)
    love.graphics.print("Keys: " .. self.keysCollected, 0, 32)

    if self.levelIndex == 11 and not self.levelComplete then
        local winText = "You Win."
        local winTextWidth = love.graphics.getFont():getWidth(winText)

        local thanksText = "Thanks for playing!"
        local thanksTextWidth = love.graphics.getFont():getWidth(thanksText)

        love.graphics.print(winText, (screenWidth - winTextWidth) / 2, screenHeight / 2 - 16)
        love.graphics.print(thanksText, (screenWidth - thanksTextWidth) / 2, screenHeight / 2 + 16)
    end

    love.graphics.setColor(Constants.BACKGROUND_COLOUR)

    local animationProgress = self.animator:getProgress()
    local barHeight = screenHeight * animationProgress

    love.graphics.rectangle("fill", 0, 0, screenWidth, barHeight)
    love.graphics.rectangle("fill", 0, screenHeight - barHeight, screenWidth, barHeight)
end

--- Handles key presses.
--- @param key string The key that was pressed.
function Game:keypressed(key)
    if not self.levelReset and not self.levelComplete then
        self.player:keypressed(key)
    end
end

--- Handles key releases.
--- @param key string The key that was released.
function Game:keyreleased(key)
    self.player:keyreleased(key)
end

return Game