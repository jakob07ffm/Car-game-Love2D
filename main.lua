local car = { x = 200, y = 500, width = 50, height = 100, speed = 200 }
local obstacles = {}
local powerups = {}
local obstacleSpeed = 100
local spawnInterval = 2
local powerupSpawnInterval = 10
local timeSinceLastSpawn = 0
local timeSinceLastPowerup = 0
local score = 0
local isGameOver = false
local isPaused = false
local highScore = 0
local difficultyIncreaseRate = 0.1
local timeSinceLastDifficultyIncrease = 0
local speedBoostDuration = 5
local speedBoostActive = false
local speedBoostEndTime = 0

function love.load()
    -- Placeholder for the car image
    car.width = 50
    car.height = 100
    
    -- Placeholders for obstacle and powerup images
    obstacleImage = nil
    powerupImage = nil
    
    -- Placeholder for background music and sounds
    backgroundMusic = nil
    scoreSound = nil
    crashSound = nil

    love.graphics.setFont(love.graphics.newFont(24))
end

function love.update(dt)
    if isPaused then return end

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

    -- Handle power-up duration
    if speedBoostActive and love.timer.getTime() > speedBoostEndTime then
        car.speed = 200
        speedBoostActive = false
    end

    timeSinceLastSpawn = timeSinceLastSpawn + dt
    if timeSinceLastSpawn > spawnInterval then
        timeSinceLastSpawn = 0
        local obstacle = { x = math.random(0, love.graphics.getWidth() - car.width), y = -car.height, speed = obstacleSpeed }
        table.insert(obstacles, obstacle)
        score = score + 1
    end

    timeSinceLastPowerup = timeSinceLastPowerup + dt
    if timeSinceLastPowerup > powerupSpawnInterval then
        timeSinceLastPowerup = 0
        local powerup = { x = math.random(0, love.graphics.getWidth() - car.width), y = -car.height }
        table.insert(powerups, powerup)
    end

    for i, obstacle in ipairs(obstacles) do
        obstacle.y = obstacle.y + obstacle.speed * dt
    end

    for i, powerup in ipairs(powerups) do
        powerup.y = powerup.y + obstacleSpeed * dt
    end

    for i = #obstacles, 1, -1 do
        local obstacle = obstacles[i]
        if obstacle.y > love.graphics.getHeight() then
            table.remove(obstacles, i)
        elseif CheckCollision(car.x, car.y, car.width, car.height, obstacle.x, obstacle.y, car.width, car.height) then
            isGameOver = true
            if score > highScore then
                highScore = score
            end
        end
    end

    for i = #powerups, 1, -1 do
        local powerup = powerups[i]
        if powerup.y > love.graphics.getHeight() then
            table.remove(powerups, i)
        elseif CheckCollision(car.x, car.y, car.width, car.height, powerup.x, powerup.y, car.width, car.height) then
            table.remove(powerups, i)
            activateSpeedBoost()
        end
    end

    timeSinceLastDifficultyIncrease = timeSinceLastDifficultyIncrease + dt
    if timeSinceLastDifficultyIncrease > 10 then
        timeSinceLastDifficultyIncrease = 0
        obstacleSpeed = obstacleSpeed + difficultyIncreaseRate * obstacleSpeed
    end
end

function love.draw()
    -- Draw the car as a rectangle
    love.graphics.rectangle("fill", car.x, car.y, car.width, car.height)
    
    -- Draw obstacles as rectangles
    for _, obstacle in ipairs(obstacles) do
        love.graphics.rectangle("fill", obstacle.x, obstacle.y, car.width, car.height)
    end
    
    -- Draw powerups as circles
    for _, powerup in ipairs(powerups) do
        love.graphics.circle("fill", powerup.x + car.width / 2, powerup.y + car.height / 2, car.width / 2)
    end
    
    love.graphics.print("Score: " .. score, 10, 10)
    love.graphics.print("High Score: " .. highScore, 10, 40)

    if isGameOver then
        love.graphics.printf("Game Over! Press Enter to restart", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
    end
    if isPaused then
        love.graphics.printf("Paused. Press 'P' to resume", 0, love.graphics.getHeight() / 2 + 50, love.graphics.getWidth(), "center")
    end
end

function CheckCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
           x2 < x1 + w1 and
           y1 < y2 + h2 and
           y2 < y1 + h1
end

-- Activate speed boost power-up
function activateSpeedBoost()
    car.speed = 400
    speedBoostActive = true
    speedBoostEndTime = love.timer.getTime() + speedBoostDuration
end

function resetGame()
    car.x = 200
    car.y = 500
    obstacles = {}
    powerups = {}
    obstacleSpeed = 100
    spawnInterval = 2
    powerupSpawnInterval = 10
    timeSinceLastSpawn = 0
    timeSinceLastPowerup = 0
    score = 0
    isGameOver = false
    isPaused = false
    timeSinceLastDifficultyIncrease = 0
    speedBoostActive = false
    car.speed = 200
end

function love.keypressed(key)
    if key == "p" then
        isPaused = not isPaused
    elseif key == "return" and isGameOver then
        resetGame()
    end
end
