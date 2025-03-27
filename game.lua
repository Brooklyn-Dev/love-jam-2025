local Constants = require('constants')
local Level = require('level')
local Player = require('player')
local Enemy = require('enemy')
local Spike = require('spike')
local Key = require('key')
local Door = require('door')
local AStar = require("pathfinding")
local SoundManager = require("sound_manager")
local Animator = require("animator")

local Game = {}
Game.__index = Game

function Game.new()
    local self = setmetatable({}, Game)
    self.seed = os.time()
    self.state = 'playing'
    self.soundManager = SoundManager.new()

    self.levelIndex = 1
    self:loadLevel(self.levelIndex)

    self.levelReset = false
    self.levelComplete = false

    self.animator = Animator.new(0.3)

    return self
end

function Game:loadLevel(levelIndex)
    self.level = Level.new('levels/' .. levelIndex .. '.txt', self.seed)
    self.keysCollected = 0

    self.player = nil
    self.enemiesNormal = {}
    self.enemiesHard = {}
    self.spikes = {}
    self.keys = {}
    self.doors = {}

    for _, entityData in ipairs(self.level.entityPositions) do
        local entityType = entityData.type

        if entityType == 'player' then
            self.player = Player.new(entityData.x, entityData.y, self)
            self.player:setTickCallback(function() self:tick() end)

        elseif entityType == 'enemy_normal' then
            local enemy = Enemy.new(entityData.x, entityData.y, false)
            table.insert(self.enemiesNormal, enemy)

        elseif entityType == 'enemy_hard' then
            local enemy = Enemy.new(entityData.x, entityData.y, true)
            table.insert(self.enemiesHard, enemy)

        elseif entityType == 'spike' then
            local spike = Spike.new(entityData.x, entityData.y)
            table.insert(self.spikes, spike)

        elseif entityType == 'key' then
            local key = Key.new(entityData.x, entityData.y)
            table.insert(self.keys, key)

        elseif entityType == 'door' then
            local door = Door.new(entityData.x, entityData.y)
            table.insert(self.doors, door)
        end
    end
end

function Game:resetLevel()
    self.state = 'playing'
    self.soundManager:play('player_death')
    self.levelReset = true
    self.animator:start(function()
        self:loadLevel(self.levelIndex)
        self.levelReset = false
    end)
end

function Game:nextLevel()
    self.seed = os.time()
    self.levelIndex = self.levelIndex + 1
    self.state = 'playing'
    self.soundManager:play('next_level')
    self.levelComplete = true
    self.animator:start(function()
        self:loadLevel(self.levelIndex)
        self.levelComplete = false
    end)
end

function Game:tick()
    self.soundManager:play('footstep')

    -- Enemies
    for _, enemy in ipairs(self.enemiesNormal) do
        local path = AStar:findPath(enemy.x, enemy.y, self.player.x, self.player.y, self.level.tiles, false)
        enemy:onTick(path, self.doors, self.enemiesNormal)

        -- Kill player
        if self.player.x == enemy.x and self.player.y == enemy.y then
            self:resetLevel()
            return
        end
    end

    for _, enemy in ipairs(self.enemiesHard) do
        local path = AStar:findPath(enemy.x, enemy.y, self.player.x, self.player.y, self.level.tiles, true)
        enemy:onTick(path, self.doors, self.enemiesHard)

        -- Kill player
        if self.player.x == enemy.x and self.player.y == enemy.y then
            self:resetLevel()
            return
        end
    end

    -- Opposite enemies
    local enemiesNormalToDelete = {}
    local enemiesHardToDelete = {}
    for i, enemyNormal in ipairs(self.enemiesNormal) do
        for j, enemyHard in ipairs(self.enemiesHard) do
            -- Kill eachother
            if enemyNormal.x == enemyHard.x and enemyNormal.y == enemyHard.y then
                table.insert(enemiesNormalToDelete, i)
                table.insert(enemiesHardToDelete, j)
                self.soundManager:play('enemy_death')
            end
        end
    end

    for _, idx in ipairs(enemiesNormalToDelete) do
        table.remove(self.enemiesNormal, idx)
    end

    for _, idx in ipairs(enemiesHardToDelete) do
        table.remove(self.enemiesHard, idx)
    end

    -- Spikes
    for _, spike in ipairs(self.spikes) do
        spike:onTick()

        if not spike.active then goto continue end
        
        -- Kill player
        if self.player.x == spike.x and self.player.y == spike.y then
            self:resetLevel()
            return
        end

        -- Kill enemies
        local enemiesToDelete = {}
        for i, enemy in ipairs(self.enemiesNormal) do
            if spike.x == enemy.x and spike.y == enemy.y then
                table.insert(enemiesToDelete, i)
            end
        end

        for _, idx in ipairs(enemiesToDelete) do
            table.remove(self.enemiesNormal, idx)
            self.soundManager:play('enemy_death')
        end

        enemiesToDelete = {}
        for i, enemy in ipairs(self.enemiesHard) do
            if spike.x == enemy.x and spike.y == enemy.y then
                table.insert(enemiesToDelete, i)
            end
        end

        for _, idx in ipairs(enemiesToDelete) do
            table.remove(self.enemiesHard, idx)
            self.soundManager:play('enemy_death')
        end

        ::continue::
    end

    -- Keys
    local keyDeleteIdx = nil
    for i, key in ipairs(self.keys) do
        if self.player.x == key.x and self.player.y == key.y then
            self.keysCollected = (self.keysCollected or 0) + 1
            keyDeleteIdx = i
            break
        end
    end
    
    if keyDeleteIdx ~= nil then
        table.remove(self.keys, keyDeleteIdx)   
        self.soundManager:play('pickup_key')
    end

    -- Exit
    if self.level.exit ~= nil then
        if self.player.x == self.level.exit.x and self.player.y == self.level.exit.y then
            self:nextLevel()
            return
        end
    end
end

function Game:update(dt)
    self.animator:update(dt)

    if self.animator:getProgress() >= 0.5 then
        if self.levelComplete then
            self:loadLevel(self.levelIndex)
            self.levelComplete = false
        elseif self.levelReset then
            self:loadLevel(self.levelIndex)
            self.levelReset = false
        end
    end
end

function Game:draw()
    -- Centre game using offset
    local screenWidth, screenHeight = love.graphics.getDimensions()
    local offsetX = (screenWidth - 8 * Constants.TILE_SIZE) / 2
    local offsetY = (screenHeight - 8 * Constants.TILE_SIZE) / 2
    love.graphics.translate(offsetX, offsetY)

    self.level:draw()

    for _, enemy in ipairs(self.enemiesNormal) do
        enemy:draw()
    end

    for _, enemy in ipairs(self.enemiesHard) do
        enemy:draw()
    end

    for _, spike in ipairs(self.spikes) do
        spike:draw()
    end

    for _, key in ipairs(self.keys) do
        key:draw()
    end

    for _, door in ipairs(self.doors) do
        door:draw()
    end

    if not self.levelComplete and not self.levelReset then
        self.player:draw()
    end

    -- Reset offset for UI
    love.graphics.origin()

    love.graphics.setColor(Constants.TEXT_COLOUR)

    love.graphics.print("Level: " .. self.levelIndex, 0, 0)
    love.graphics.print("Keys: " .. self.keysCollected, 0, 32)

    if self.levelIndex == 11 then
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

function Game:keypressed(key)
    if self.state == 'playing' then
        self.player:keypressed(key)
    end
end

function Game:keyreleased(key)
    if self.state == 'playing' then
        self.player:keyreleased(key)
    end
end

return Game