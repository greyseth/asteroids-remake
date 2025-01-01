require('chunks');

-- Player values
topSpeed = 250;
acceleration = 120;
deceleration = 170;
moveSpeed = 0;

playerPos = {x = 0, y = 0};
accPos = {x = 0, y = 0};

playerRotation = 0;
rotateSpeed = 5;

isMoving = false;
moveDirection = 1;

fireShowing = true;
fireShowInterval = 0.0005;
fireTimeCounter = 0;

-- Projectiles
bullets = {};
bulletSpeed = 450;
bulletSize = 2.5;
bulletMaxLifetime = 3;
fireRate = 3;
nextFireTime = 0.3;

-- Game variables
paused = false;

function love.load()
    -- love.window.setMode(800, 600, {fullscreen = false})

    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()

    -- love.window.setMode(screenWidth, screenHeight, {fullscreen=false})

    playerSize = {width = 20, height = 30};
end

function love.update(dt)
    -- #region Misc

    if love.keyboard.isDown('escape') then
        paused = not paused;
    end

    -- #endregion

    if paused then
        return;
    end

    accPos = {x = screenWidth / 2 + playerPos.x, y = screenHeight / 2 + playerPos.y};

    -- #region Movement
    
    -- Rotation input & handling
    if love.keyboard.isDown('d') then
        playerRotation = playerRotation + rotateSpeed * dt;
    elseif love.keyboard.isDown('a') then
        playerRotation = playerRotation - rotateSpeed * dt;
    end

    -- Movement input
    if love.keyboard.isDown('w') then
        isMoving = true;
        moveDirection = -1;

        fireShowing = true;
        fireTimeCounter = 0;
    else isMoving = false;
    end

    -- Acceleration handling
    if isMoving then
        if moveSpeed < topSpeed then
            moveSpeed = moveSpeed + acceleration * dt;
        end
    else
        if moveSpeed > 0 then
            moveSpeed = moveSpeed - deceleration * dt;
        end
    end

    -- Moves player
    local forwardX = math.sin(playerRotation) * moveDirection;
    local forwardY = math.cos(playerRotation) * moveDirection;
    playerPos = {x = playerPos.x - (forwardX * moveSpeed * dt), y = playerPos.y + (forwardY * moveSpeed * dt)};

    -- #endregion

    -- #region Shooting

    -- Input handling
    if love.keyboard.isDown("space") and love.timer.getTime() >= nextFireTime then
        local accPos = {x = screenWidth / 2 + playerPos.x, y = screenHeight / 2 + playerPos.y};

        local topRaw = {x = accPos.x, y = accPos.y - (playerSize.height / 2)};
        local top = {x = math.cos(playerRotation) * (topRaw.x - accPos.x) - math.sin(playerRotation) * (topRaw.y - accPos.y) + accPos.x, y = math.sin(playerRotation) * (topRaw.x - accPos.x) + math.cos(playerRotation) * (topRaw.y - accPos.y) + accPos.y};

        table.insert(bullets, {id = table.getn(bullets)+1, pos = top, angle = playerRotation, lifetime = 0});

        nextFireTime = love.timer.getTime() + 1 / fireRate;
    end

    local removeBullets = {};
    for i, bullet in ipairs(bullets) do
        if bullet.lifetime >= bulletMaxLifetime then table.insert(removeBullets, i); goto continue; end

        local bulletForwardX = math.sin(bullet.angle);
        local bulletForwardY = math.cos(bullet.angle);
        bullets[i] = {
            id = bullet.id, 
            pos = {x = bullet.pos.x + (bulletForwardX * bulletSpeed * dt), y = bullet.pos.y - (bulletForwardY * bulletSpeed * dt)}, 
            angle = bullet.angle,
            lifetime = bullet.lifetime + dt
        };

        ::continue::
    end

    for _, toRemove in ipairs(removeBullets) do
        table.remove(bullets, toRemove);
    end

    -- #endregion

    -- #region Misc updates

    moveChunks(dt);
    spawnChunks(dt, accPos);

    if isMoving then
        if fireTimeCounter < fireShowInterval then
            fireTimeCounter = fireTimeCounter + dt;
        else fireShowing = not fireShowing; fireTimeCounter = 0;
        end
    end

    -- #endregion
end

-- function love.keypressed(key, scancode, isrepeat)
--     if key == 'f' then
--         local accPos = {x = screenWidth / 2 + playerPos.x, y = screenHeight / 2 + playerPos.y};
--         createChunk(accPos.x, accPos.y, playerRotation);
--     end
-- end

function love.draw() 
    if paused then
        return;
    end

    -- Debug variables
    love.graphics.print("Current Speed: "..moveSpeed, 0, 0);
    love.graphics.print("Angle: "..playerRotation, 0, 15);
    love.graphics.print("X: "..accPos.x.." | Y: "..accPos.y, 0, 30);
    love.graphics.print("Time: "..love.timer.getTime().." | Next Fire Time: "..nextFireTime, 0, 45);

    -- vertices
    local bottomLeftRaw = {x = accPos.x - (playerSize.width / 2), y = accPos.y + (playerSize.height/2)};
    local bottomRightRaw = {x = accPos.x + (playerSize.width / 2), y = accPos.y + (playerSize.height/2)};
    local topRaw = {x = accPos.x, y = accPos.y - (playerSize.height / 2)};
    local bottomRaw = {x = accPos.x, y = accPos.y + playerSize.height};

    local fireBottomLeft = {x = accPos.x - (playerSize.width / 4), y = accPos.y + (playerSize.height / 2)};
    local fireBottomRight = {x = accPos.x + (playerSize.width / 4), y = accPos.y + (playerSize.height / 2)};

    local bottomLeft = applyRotation(bottomLeftRaw);
    local bottomRight = applyRotation(bottomRightRaw);
    local top = applyRotation(topRaw);
    local bottom = applyRotation(bottomRaw);

    -- player draw
    local player = love.physics.newPolygonShape(bottomLeft.x, bottomLeft.y, bottomRight.x, bottomRight.y, top.x, top.y);
    love.graphics.polygon('fill', player:getPoints());
    if isMoving and fireShowing then 
        love.graphics.polygon('line', 
                applyRotation(fireBottomLeft).x, applyRotation(fireBottomLeft).y, 
                applyRotation(fireBottomRight).x, applyRotation(fireBottomRight).y, 
                bottom.x, bottom.y
            );
    end

    -- bullets draw
    for i, bullet in ipairs(bullets) do
        love.graphics.circle("fill", bullet.pos.x, bullet.pos.y, bulletSize)
    end

    -- chunks
    drawChunks();
end

function applyRotation(raw)
    return {x = math.cos(playerRotation) * (raw.x - accPos.x) - math.sin(playerRotation) * (raw.y - accPos.y) + accPos.x, y = math.sin(playerRotation) * (raw.x - accPos.x) + math.cos(playerRotation) * (raw.y - accPos.y) + accPos.y}
end