love.graphics.setDefaultFilter('nearest', 'nearest')

local Constants = require('constants')
local Game = require('game')

love.graphics.setBackgroundColor(Constants.BACKGROUND_COLOUR)

local font = love.graphics.newFont("assets/fonts/m6x11.ttf", 24)
love.graphics.setFont(font)

local game
local backgroundMusic

function love.load()
    game = Game.new()

    backgroundMusic = love.audio.newSource(Constants.MUSIC, "stream")
    backgroundMusic:setLooping(true)
    backgroundMusic:setVolume(0.65)
    backgroundMusic:play()
end

function love.update(dt)
    game:update(dt)
end

function love.draw()
    game:draw()
end

function love.keypressed(key)
    game:keypressed(key)
end

function love.keyreleased(key)
    game:keyreleased(key)
end