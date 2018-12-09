--[[
    A simple NES-like Pong game
]]

-- imports/dependencies
push = require "lib/push"
Class = require "lib/class"
require "src/paddle"
require "src/ball"

-- constants
WINDOW_WIDTH = 1024
WINDOW_HEIGHT = 640

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200
PADDLE_WIDTH = 5
PADDLE_HEIGHT = 30
PADDLE_1_START_X = 10
PADDLE_2_START_X = VIRTUAL_WIDTH - PADDLE_WIDTH - PADDLE_1_START_X
PADDLE_1_START_Y = 30
PADDLE_2_START_Y = VIRTUAL_HEIGHT - 50

BALL_WIDTH = 6
BALL_HEIGHT = 6

UPPER_BOUND = 5
LOWER_BOUND = VIRTUAL_HEIGHT - PADDLE_HEIGHT - 5

-- local variables
local gFont
local gameState

function love.load()
    math.randomseed(os.time())
    love.window.setTitle("Pong")
    love.graphics.setDefaultFilter("nearest", "nearest")

    -- import and set a non-default font
    gFont = love.graphics.newFont("fonts/PressStart2P.ttf", 8)
    love.graphics.setFont(gFont)

    -- set up virtual resolution window
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, 
        WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    -- initialize the game state to start
    -- and initialize a new ball and paddles
    gameState = "start"
    ball = Ball(VIRTUAL_WIDTH/2 - 3, VIRTUAL_HEIGHT/2 - 3,
        BALL_WIDTH, BALL_HEIGHT)
    paddle1 = Paddle(PADDLE_1_START_X, PADDLE_1_START_Y,
        PADDLE_WIDTH, PADDLE_HEIGHT)
    paddle2 = Paddle(PADDLE_2_START_X, PADDLE_2_START_Y,
        PADDLE_WIDTH, PADDLE_HEIGHT)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "space" or key == "return" then
        if gameState == "start" then
            gameState = "play"
        else
            gameState = "start"

            -- reset ball to its starting positioned
            -- the ball is position exactly in the
            -- middle of the screen
            ball = Ball((VIRTUAL_WIDTH/2) - (BALL_WIDTH/2), 
                (VIRTUAL_HEIGHT/2) - (BALL_HEIGHT/2), 
                BALL_WIDTH, BALL_HEIGHT)
        end
    end
end

function love.update(dt)
    -- bounds checking could have been done
    -- using math.max() and math.min() instead
    -- of (ab)using ugly nested if-constructs
    -- also, updating should actually be done in
    -- the Paddle:update() function, including
    -- the keyboard input detection

    -- player 1 movement
    if love.keyboard.isDown('w') then
        paddle1:update(dt, "up", PADDLE_SPEED, 
            UPPER_BOUND, LOWER_BOUND)
    elseif love.keyboard.isDown('s') then
        paddle1:update(dt, "down", PADDLE_SPEED, 
            UPPER_BOUND, LOWER_BOUND)
    end

    -- player 2 movement
    if love.keyboard.isDown("up") then
        paddle2:update(dt, "up", PADDLE_SPEED, 
            UPPER_BOUND, LOWER_BOUND)
    elseif love.keyboard.isDown("down") then
        paddle2:update(dt, "down", PADDLE_SPEED, 
            UPPER_BOUND, LOWER_BOUND)
    end

    if gameState == "play" then
        ball:update(dt, 0, VIRTUAL_HEIGHT)
        if ball:collides(paddle1) or
            ball:collides(paddle2) then
            ball:changeDirection()
        end

        -- if the ball goes past one of the paddles,
        -- the respective player gets a point
        -- relies on p1 being on the left and p2 
        -- being on the right side of the screen
        -- (again with some hard coded padding)
        if paddle1.x > (ball.x+5) then
            paddle2.score = paddle2.score + 1
            gameState = "start"
            ball = Ball((VIRTUAL_WIDTH/2) - (BALL_WIDTH/2), 
                (VIRTUAL_HEIGHT/2) - (BALL_HEIGHT/2), 
                BALL_WIDTH, BALL_HEIGHT)
        elseif paddle2.x < (ball.x-5) then
            paddle1.score = paddle1.score + 1
            gameState = "start"
            ball = Ball((VIRTUAL_WIDTH/2) - (BALL_WIDTH/2), 
                (VIRTUAL_HEIGHT/2) - (BALL_HEIGHT/2), 
                BALL_WIDTH, BALL_HEIGHT)
        end
    end
end

function love.draw()
    -- start rendering at virtual resolution
    push:apply("start")

    love.graphics.clear(0, 0.5, 0, 0.5)
    love.graphics.setColor(1, 1, 1, 1)

    -- display FPS in lower left corner
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()),
        10, VIRTUAL_HEIGHT - 10)

    -- display scores and heading
    love.graphics.printf("Retro Pong", VIRTUAL_WIDTH/2-150, 5, 
        150, "center", 0, 2, 2)
    love.graphics.printf(string.format("%d", paddle1.score), 
        20-150, 5, 150, "center", 0, 2, 2)
    love.graphics.printf(string.format("%d", paddle2.score), 
        VIRTUAL_WIDTH-150-20, 5, 150, "center", 0, 2, 2)


    -- render paddles and ball
    paddle1:render()
    paddle2:render()
    ball:render()

    -- stop rendering at virtual resolution
    push:apply("end")
end
