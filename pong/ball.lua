local Ball = require'class' {}

Ball.States = {
    IDLE = 0,
    MOVE = 1,
    RESET = 2,
}

Ball.state = Ball.States.IDLE
Ball.last_state = Ball.States.IDLE

Ball.reset_opts = {}

function Ball:init (opts)
    local defaults = {}
    self.x = opts.x
    self.y = opts.y
    self.width = opts.width
    self.height = opts.height

    self.dx = math.random(2) == 1 and -100 or 100
    self.dy = math.random(-50, 50)
end

function Ball:reset (opts)
    self.reset_opts = opts
    self.state = Ball.States.RESET
end

function Ball:draw ()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

function Ball:update (dt)
    if self.state == Ball.States.MOVE then
        self.x = self.x + self.dx * dt
        self.y = self.y + self.dy * dt
    elseif self.state == Ball.States.RESET then
        self.x = self.reset_opts.x or 432 / 2 - 2
        self.y = self.reset_opts.y or 243 / 2 - 2
        self.dx = self.reset_opts.dx or math.random(2) == 1 and -100 or 100
        self.dy = self.reset_opts.dy or math.random(-50, 50)
        self.state = Ball.States.IDLE
    end
end

function Ball:collides(rect)
    if self.x > rect.x + rect.width or rect.x > self.x + self.width then
        return false
    end

    if self.y > rect.y + rect.height or rect.y > self.y + self.height then
        return false
    end

    return true
end

-- @param state integer
function Ball:setState(state)
    self.last_state = self.state
    self.state = state
end

function Ball:revertState()
    local state = self.state
    self.state = self.last_state
    self.last_state = state
end

return Ball
