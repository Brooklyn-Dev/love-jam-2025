--- @class Animator
--- @field time number The elapsed time since the animation started.
--- @field duration number The total duration of the animation.
--- @field progress number The current animation progress (0 to 1).
--- @field isAnimating boolean Whether the animation is active.
--- @field callback function | nil A function to call when the animation completes.

local Animator = {}
Animator.__index = Animator

--- Creates a new Animator instance.
--- @param duration number | nil The duration of the animation (default: 0.3 seconds).
--- @return Animator
function Animator.new(duration)
    local self = setmetatable({}, Animator)

    self.time = 0
    self.duration = duration or 0.3
    self.progress = 0
    self.isAnimating = false
    self.callback = nil

    return self
end

--- Starts the animation.
--- @param callback function | nil A function to execute when the animation finishes.
function Animator:start(callback)
    self.time = 0
    self.isAnimating = true
    self.callback = callback
end

--- Updates the animation progress.
--- @param dt number Delta time since the last update.
function Animator:update(dt)
    if not self.isAnimating then return end

    self.time = self.time + dt

    if self.time <= self.duration then
        self.progress = self.time / self.duration

    elseif self.time <= self.duration * 2 then
        self.progress = 1 - (self.time - self.duration) / self.duration

    else
        self.progress = 0
        self.isAnimating = false
        if self.callback then self.callback() end
    end
end

--- Returns the current animation progress (0 to 1).
--- @return number
function Animator:getProgress()
    return self.progress
end

return Animator