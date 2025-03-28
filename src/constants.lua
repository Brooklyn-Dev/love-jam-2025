local Constants = {}

-- Dimensions and Scaling
Constants.SPRITE_SIZE = 16  -- Sprite size in pixels
Constants.TILE_SIZE = 64  -- Tile size in pixels
Constants.SPRITE_SCALE = Constants.TILE_SIZE / Constants.SPRITE_SIZE -- Sprite scale factor

-- Colours
Constants.WHITE = { 1.0, 1.0, 1.0}
Constants.BACKGROUND_COLOUR = { love.math.colorFromBytes(62, 58, 66) }
Constants.TEXT_COLOUR = { love.math.colorFromBytes(233, 245, 218) }

-- Asset Paths
local SPRITE_DIR = 'assets/sprites/'
local SFX_DIR = 'assets/audio/sfx/'
Constants.MUSIC = 'assets/audio/music.wav'

-- Environment Sprites
Constants.WALL_SPRITE = love.graphics.newImage(SPRITE_DIR .. 'wall.png')
Constants.WALL_BRIGHTNESSES = { 0.8, 0.85, 0.9, 0.95 }
Constants.EXIT_SPRITE = love.graphics.newImage(SPRITE_DIR .. 'exit.png')
Constants.KEY_SPRITE = love.graphics.newImage(SPRITE_DIR .. 'key.png')
Constants.DOOR_SPRITE = love.graphics.newImage(SPRITE_DIR .. 'door.png')

-- Entity Sprites
Constants.PLAYER_SPRITES = {
    love.graphics.newImage(SPRITE_DIR .. 'player/1.png'),
    love.graphics.newImage(SPRITE_DIR .. 'player/2.png')
}
Constants.ENEMY_NORMAL_SPRITES = {
    love.graphics.newImage(SPRITE_DIR .. 'enemy_normal/1.png'),
    love.graphics.newImage(SPRITE_DIR .. 'enemy_normal/2.png')
}
Constants.ENEMY_HARD_SPRITES = {
    love.graphics.newImage(SPRITE_DIR .. 'enemy_hard/1.png'),
    love.graphics.newImage(SPRITE_DIR .. 'enemy_hard/2.png')
}
Constants.SPIKE_SPRITES = {
    love.graphics.newImage(SPRITE_DIR .. 'spike/1.png'),
    love.graphics.newImage(SPRITE_DIR .. 'spike/2.png')
}

-- Sound Effects
Constants.SOUND_EFFECTS = {
    SFX_DIR .. 'enemy_death.mp3',
    SFX_DIR .. 'footstep.mp3',
    SFX_DIR .. 'next_level.mp3',
    SFX_DIR .. 'pickup_key.mp3',
    SFX_DIR .. 'player_death.mp3',
    SFX_DIR .. 'unlock_door.mp3',
}

return Constants