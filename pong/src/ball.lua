--[[
    Ball class
]]

Ball = Class{}

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    -- whenever a ball is initially, it is 
    -- given a random x and y velocity
    self.dx = math.random(2) == 1 and 100 or -100 
    self.dy = math.random(-50, 50)

end

function Ball:collides(paddle)
    -- check if this ball is to the right or
    -- to the left of the paddle
    if self.x > (paddle.x + paddle.width) or
        (self.x + self.width) < paddle.x then
        return false
    end

    -- check if this ball is above or 
    -- below of the paddle
    if self.y > (paddle.y + paddle.height) or
        (self.y + self.height) < paddle.y then
        return false
    end

    -- otherwise, ball and paddle collide
    return true
end

function Ball:changeDirection()
    -- add some padding to ensure that the
    -- ball is always outside of the paddle
    -- before re-checking for a collision
    -- (the width of the paddle, 5, is hard
    -- which, obviously, is not very good)
    if self.dx > 0 then
        -- the ball moves to the right
        self.x = self.x - 5
    else
        -- the ball moves to the left
        self.x = self.x + 5
    end

    -- then, slightly increase the x velocity
    -- the scaling factor 1.1 is hard coded
    self.dx = -self.dx * 1.1

    -- lastly, randomize the y velocity
    if self.dy < 0 then
        self.dy = -math.random(10, 150) -- ball moves back up
    else
        self.dy = math.random(10, 150) -- ball moves back down
    end
end

function Ball:update(dt, ceiling, floor)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    -- a ball is going to be reflected when
    -- it hits the ceiling or the floor
    -- (with some hard coded padding of 5px)
    if self.y <= ceiling then 
        self.y = self.y + 5
        self.dy = -self.dy
    elseif self.y >= floor then
        self.y = self.y - 5
        self.dy = -self.dy
    end
end

function Ball:render()
    love.graphics.rectangle("fill", self.x, self.y, 
        self.width, self.height)
end
