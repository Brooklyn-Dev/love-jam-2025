local Constants = {}

Constants.SPRITE_SIZE = 16
Constants.TILE_SIZE = 64
Constants.SPRITE_SCALE = Constants.TILE_SIZE / Constants.SPRITE_SIZE

Constants.BACKGROUND_COLOUR = { love.math.colorFromBytes(62, 58, 66) }
Constants.TEXT_COLOUR = { love.math.colorFromBytes(233, 245, 218) }

local SPRITE_DIR = 'assets/sprites/'

Constants.WALL_SPRITE = love.graphics.newImage(SPRITE_DIR .. 'wall.png')
Constants.WALL_BRIGHTNESSES = { 0.8, 0.85, 0.9, 0.95 }

Constants.EXIT_SPRITE = love.graphics.newImage(SPRITE_DIR .. 'exit.png')

Constants.KEY_SPRITE = love.graphics.newImage(SPRITE_DIR .. 'key.png')
Constants.DOOR_SPRITE = love.graphics.newImage(SPRITE_DIR .. 'door.png')

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

local SOUND_EFFECTS_DIR = 'assets/audio/sfx/'
Constants.SOUND_EFFECTS = {
    SOUND_EFFECTS_DIR .. 'enemy_death.mp3',
    SOUND_EFFECTS_DIR .. 'footstep.mp3',
    SOUND_EFFECTS_DIR .. 'next_level.mp3',
    SOUND_EFFECTS_DIR .. 'pickup_key.mp3',
    SOUND_EFFECTS_DIR .. 'player_death.mp3',
    SOUND_EFFECTS_DIR .. 'unlock_door.mp3',
}

Constants.MUSIC = 'assets/audio/music.wav'

return Constants