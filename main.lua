-- Configure graphics settings for pixel art
love.graphics.setDefaultFilter('nearest', 'nearest')

-- Load modules
local Constants = require('constants')
local Game = require('game')

-- Set background colour
love.graphics.setBackgroundColor(Constants.BACKGROUND_COLOUR)

-- Load and set default font
local font = love.graphics.newFont("assets/fonts/m6x11.ttf", 24)
love.graphics.setFont(font)

local game
local backgroundMusic

--- Called once at the start of the game.
function love.load()
    game = Game.new()

    backgroundMusic = love.audio.newSource(Constants.MUSIC, "stream")
    backgroundMusic:setLooping(true)
    backgroundMusic:setVolume(0.65)
    backgroundMusic:play()
end

--- Called every frame to update game logic.
--- @param dt number: Delta time since last frame.
function love.update(dt)
    game:update(dt)
end

--- Called every frame to render game graphics.
function love.draw()
    game:draw()
end

--- Called when a key is pressed.
--- @param key string: The key that was pressed.
function love.keypressed(key)
    game:keypressed(key)
end

--- Called when a key is released.
--- @param key string: The key that was released.
function love.keyreleased(key)
    game:keyreleased(key)
end