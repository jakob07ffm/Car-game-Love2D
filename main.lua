local car = { x = 200, y = 500, width = 50, height = 100, speed = 200 }
local obstacles = {}
local obstacleSpeed = 100
local spawnInterval = 2
local timeSinceLastSpawn = 0

function love.load()
    car.image = love.graphics.newImage("car.png")
    car.width = car.image:getWidth()
    car.height = car.image:getHeight()
    obstacleImage = love.graphics.newImage("obstacle.png")
end

function love.update(dt)
    -- Move car left and right
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
    end

    for i, obstacle in ipairs(obstacles) do
        obstacle.y = obstacle.y + obstacleSpeed * dt
    end

    for i = #obstacles, 1, -1 do
        local obstacle = obstacles[i]
        if obstacle.y > love.graphics.getHeight() then
            table.remove(obstacles, i)
        elseif CheckCollision(car.x, car.y, car.width, car.height, obstacle.x, obstacle.y, car.width, car.height) then
            love.event.quit("restart")
        end
    end
end

function love.draw()
    love.graphics.draw(car.image, car.x, car.y)
    for _, obstacle in ipairs(obstacles) do
        love.graphics.draw(obstacleImage, obstacle.x, obstacle.y)
    end
end

function CheckCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2+w2 and
           x2 < x1+w1 and
           y1 < y2+h2 and
           y2 < y1+h1
end
