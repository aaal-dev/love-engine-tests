local push = require'push'

local Ball = require'ball'
local Paddle = require'paddle'

local window_width = 1280
local window_height = 720

local virtual_width = 432
local virtual_height = 243

local paddle_speed = 200

local GameStates = {
    START = 0,
    PLAY = 1,
    PAUSE = 2,
    SERVE = 3,
    DONE = 4
}

local game = {
    state = GameStates.START,
    last_state = GameStates.START,
    win = 0,
    serve = 0,
}

local ball = Ball {
    x = virtual_width / 2 - 2,
    y = virtual_height / 2 - 2,
    dx = 0,
    dy = 0,
    width = 4,
    height = 4,
}

local player_1 = Paddle {
    x = 10,
    y = 30,
    width = 5,
    height = 20,
}

player_1.score = 0
player_1.is_win = false


local player_2 = Paddle {
    x = virtual_width - 10,
    y = virtual_height - 50,
    width = 5,
    height = 20,
}

player_2.score = 0
player_2.is_win = false


local fonts = {
    score = love.graphics.newFont('font.ttf', 32),
    small = love.graphics.newFont('font.ttf', 8),
    large = love.graphics.newFont('font.ttf', 16)
}

------------------------------------------------------------ local functions --

local function displayFPS() ------------------------------------- displayFPS --
    love.graphics.setFont(fonts.small)
    love.graphics.setColor(0.0, 1.0, 0.0, 1.0)
    love.graphics.print('FPS: '..tostring(love.timer.getFPS()), 10, 10)
end

local function displayScore() --------------------------------- displayScore --
    love.graphics.setFont(fonts.score)
    love.graphics.print(
        tostring(player_1.score),
        virtual_width / 2 - 50,
        virtual_height / 3
    )
    love.graphics.print(
        tostring(player_2.score),
        virtual_width / 2 + 30,
        virtual_height / 3
    )
end

-------------------------------------------------------------------------------

function love.load() --------------------------------------------- love.load --
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Pong')

    math.randomseed(os.time())

    push:setupScreen(
        virtual_width,
        virtual_height,
        window_width,
        window_height,
        {
            fullscreen = false,
            resizable = false,
            vsync = true,
        }
    )
end

function love.update(dt) --------------------------------------- love.update --
    if game.state == GameStates.SERVE then
        ball.dy = math.random(-50, 50)

        if game.serve == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    elseif game.state == GameStates.PLAY then
        if ball:collides(player_1) then
            ball.dx = (-ball.dx) * 1.1
            ball.x = player_1.x + 5

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        if ball:collides(player_2) then
            ball.dx = (-ball.dx) * 1.1
            ball.x = player_2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end
        end

        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
        end

        if ball.y >= virtual_height - 4 then
            ball.y = virtual_height - 4
            ball.dy = -ball.dy
        end

        if player_2.score == 10 then
            player_2.is_win = true
            game.win = 2
            game.state = GameStates.DONE
        else
            if ball.x < -4 then
                game.serve = 1
                player_2.score = player_2.score + 1
                ball:reset { dx = ball.dx }
                game.state = GameStates.SERVE
            end
        end

        if player_1.score == 10 then
            player_1.is_win = true
            game.win = 1
            game.state = GameStates.DONE
        else
            if (ball.x > virtual_width ) then
                game.serve = 2
                player_1.score = player_1.score + 1
                ball:reset { dx = ball.dx }
                game.state = GameStates.SERVE
            end
        end
    end

    if game.state ~= GameStates.DONE then
        if love.keyboard.isDown('w') then
            player_1.dy = (-paddle_speed)
        elseif love.keyboard.isDown('s') then
            player_1.dy = paddle_speed
        else
            player_1.dy = 0
        end

        if love.keyboard.isDown('up') then
            player_2.dy = (-paddle_speed)
        elseif love.keyboard.isDown('down') then
            player_2.dy = paddle_speed
        else
            player_2.dy = 0
        end
    end

    player_1:update(dt)
    player_2:update(dt)

    ball:update(dt)
end

function love.draw() --------------------------------------------- love.draw --
    push:apply'start'

    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

    displayScore()

    if GameStates.DONE then
        love.graphics.setFont(fonts.large)
    else
        love.graphics.setFont(fonts.small)
    end

    local text = game.state == GameStates.START
        and 'Welcome to Pong'
        or game.state == GameStates.PAUSE
        and 'Game Paused'
        or game.state == GameStates.SERVE
        and 'Player '..tostring(game.serve)..' is serve!'
        or game.state == GameStates.DONE
        and 'Player '..tostring(game.win)..' wins!'
        or ''

    love.graphics.printf(
        text,
        0,
        20,
        virtual_width,
        'center'
    )


    player_1:draw()

    player_2:draw()

    ball:draw()

    displayFPS()

    push:apply'end'
end

function love.mousepressed(x, y, button, is_touch)
end

function love.mouserelease(x, y, button, is_touch)
end

function love.keypressed(key) ------------------------------ love.keypressed --
    if key == 'escape' then
        love.event.quit()
    elseif key == 'space' then
        if game.state == GameStates.START
        or game.state == GameStates.SERVE
        then
            game.state = GameStates.PLAY
            ball:setState(Ball.States.MOVE)
        else
            game.state = GameStates.START
            ball:reset {}
        end
    end
end

function love.keyrelease(key)
end

function love.focus(is_focused) --------------------------------- love.focus --
    if is_focused then
        game.state = game.last_state
        ball:revertState()
    else
        game.last_state = game.state
        game.state = GameStates.PAUSE

        ball:setState(Ball.States.IDLE)
    end
end

function love.quit() --------------------------------------------- love.quit --
end

-------------------------------------------------------------------------------
