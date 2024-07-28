local car = { x = 200, y = 500, width = 50, height = 100, speed = 200 }
local obstacles = {}
local obstacleSpeed = 100
local spawnInterval = 2
local timeSinceLastSpawn = 0
local score = 0
local isGameOver = false
local difficultyIncreaseRate = 0.1
local timeSinceLastDifficultyIncrease = 0

function love.load()
    car.image = love.graphics.newImage("car.png")
    car.width = car.image:getWidth()
    car.height = car.image:getHeight()
    obstacleImage = love.graphics.newImage("obstacle.png")
    scoreSound = love.audio.newSource("score.wav", "static")
    crashSound = love.audio.newSource("crash.wav", "static")
    love.graphics.setFont(love.graphics.newFont(24))
end

function love.update(dt)
    if isGameOver then
        if love.keyboard.isDown("return") then
            -- Restart the game
            resetGame()
        end
        return
    end

    if love.keyboard.isDown("left") then
        car.x = car.x - car.speed * dt
    elseif love.keyboard.isDown("right") then
        car.x = car.x + car.speed * dt
    end

    if car.x < 0 then car.x = 0 end
    if car.x > love.graphics.getWidth() - car.width then car.x = love.graphics.getWidth() - car.width end


    timeSinceLastSpawn = timeSinceLastSpawn + dt
    if timeSinceLastSpawn > spawnInterval then
        timeSinceLastSpawn = 0
        table.insert(obstacles, { x = math.random(0, love.graphics.getWidth() - car.width), y = -car.height })
        score = score + 1
        love.audio.play(scoreSound)
    end

    for i, obstacle in ipairs(obstacles) do
        obstacle.y = obstacle.y + obstacleSpeed * dt
    end


    for i = #obstacles, 1, -1 do
        local obstacle = obstacles[i]
        if obstacle.y > love.graphics.getHeight() then
            table.remove(obstacles, i)
        elseif CheckCollision(car.x, car.y, car.width, car.height, obstacle.x, obstacle.y, car.width, car.height) then
            love.audio.play(crashSound)
            isGameOver = true
        end
    end

 
    timeSinceLastDifficultyIncrease = timeSinceLastDifficultyIncrease + dt
    if timeSinceLastDifficultyIncrease > 10 then
        timeSinceLastDifficultyIncrease = 0
        obstacleSpeed = obstacleSpeed + difficultyIncreaseRate * obstacleSpeed
    end
end


function love.draw()
    love.graphics.draw(car.image, car.x, car.y)
    for _, obstacle in ipairs(obstacles) do
        love.graphics.draw(obstacleImage, obstacle.x, obstacle.y)
    end
    love.graphics.print("Score: " .. score, 10, 10)

    if isGameOver then
        love.graphics.printf("Game Over! Press Enter to restart", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
    end
end


function CheckCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
           x2 < x1 + w1 and
           y1 < y2 + h2 and
           y2 < y1 + h1
end


function resetGame()
    car.x = 200
    car.y = 500
    obstacles = {}
    obstacleSpeed = 100
    spawnInterval = 2
    timeSinceLastSpawn = 0
    score = 0
    isGameOver = false
    timeSinceLastDifficultyIncrease = 0
end
