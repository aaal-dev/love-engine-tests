local Paddle = require'class' {}

function Paddle:init (opts)
    self.x = opts.x
    self.y = opts.y
    self.width = opts.width
    self.height = opts.height
    self.dx = 0
    self.dy = 0
end

function Paddle:draw ()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

function Paddle:update (dt)
    self.y = self.dy < 0 and math.max(0, self.y + self.dy * dt)
        or math.min(243 - self.height, self.y + self.dy * dt)
end

return Paddle
