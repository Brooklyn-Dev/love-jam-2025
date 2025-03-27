local Animator = {}
Animator.__index = Animator

function Animator.new(duration)
    local self = setmetatable({}, Animator)
    self.time = 0
    self.duration = duration or 0.3
    self.progress = 0
    self.isAnimating = false
    self.callback = nil
    return self
end

function Animator:start(callback)
    self.time = 0
    self.isAnimating = true
    self.callback = callback
end

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

function Animator:getProgress()
    return self.progress
end

return Animator