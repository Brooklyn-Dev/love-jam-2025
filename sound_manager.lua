local Constants = require('constants')

local SoundManager = {}
SoundManager.__index = SoundManager

function SoundManager.new()
    local self = setmetatable({}, SoundManager)
    self.volume = 1.0
    self.sounds = {}

    for _, filename in ipairs(Constants.SOUND_EFFECTS) do
        print("Loading sound:", filename)
        
        local name = filename:match("([^/\\]+)%.%w+$")
        if name then
            self:load(name, filename)
        else
            print("Error: Unable to extract sound name from filename:", filename)
        end
    end
    
    return self
end

function SoundManager:load(name, file)
    local sound = love.audio.newSource(file, "static")
    sound:setVolume(self.volume)
    self.sounds[name] = sound 
end

function SoundManager:play(name)
    local sound = self.sounds[name]
    if sound then
        local instance = sound:clone()
        instance:play()
    else
        print("Sound not found:", name)
    end
end

function SoundManager:setVolume(volume)
    self.volume = volume
    for _, sound in ipairs(self.sounds) do
        sound:setVolume(volume)
    end
end

return SoundManager