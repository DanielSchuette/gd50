--[[
    Paddle class
]]

Paddle = Class{}

function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.score = 0
end

function Paddle:update(dt, direction, speed, ub, lb)
    if direction == "up" then
        if not (self.y < ub) then
            self.y = self.y - speed * dt
        end
    elseif direction == "down" then
        if not (self.y > lb) then
            self.y = self.y + speed * dt
        end
    end
end

function Paddle:render()
    love.graphics.rectangle("fill", self.x, self.y, 
        self.width, self.height)
end
