local Constants = require('constants')

--- @class SoundManager
--- @field volume number The current volume level for all sounds.
--- @field sounds table A table that stores sound sources by their name.

local SoundManager = {}
SoundManager.__index = SoundManager

--- Creates a new instance of the SoundManager and loads sound files.
--- @return SoundManager
function SoundManager.new()
    local self = setmetatable({}, SoundManager)

    self.volume = 1.0
    self.sounds = {}

    -- Load all sound effects
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

--- Loads a sound from a file and stores it in the sounds table.
--- @param name string The name of the sound.
--- @param file string The file path to the sound.
function SoundManager:load(name, file)
    local sound = love.audio.newSource(file, "static")
    sound:setVolume(self.volume)
    self.sounds[name] = sound
end

--- Plays a sound by name.
--- @param name string The name of the sound to play.
function SoundManager:play(name)
    local sound = self.sounds[name]

    if sound then
        local instance = sound:clone()
        instance:play()
    else
        print("Sound not found:", name)
    end
end

--- Adjusts the volume for all sounds.
--- @param volume number The volume level to set (0 to 1).
function SoundManager:setVolume(volume)
    self.volume = volume

    for _, sound in ipairs(self.sounds) do
        sound:setVolume(volume)
    end
end

return SoundManager