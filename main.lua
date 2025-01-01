require('particles');
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

-- Misc player values
playerCorpseLines = {};
playerCorpseSpeed = 40;
playerCorpseColor = 255;
playerCorpseFadeSpeed = 100;

-- Projectiles
bullets = {};
bulletSpeed = 450;
bulletSize = 2.5;
bulletMaxLifetime = 3;
fireRate = 3;
nextFireTime = 0.3;

-- Game variables
paused = false;
isDead = false;
gameOver = false;

function love.load()
    love.window.setMode(1280, 720, {fullscreen = false})

    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()

    -- love.window.setMode(screenWidth, screenHeight, {fullscreen=false})

    playerSize = {width = 20, height = 30};
end

function love.keypressed(key)
    if key == 'escape' then paused = not paused end
end

function love.update(dt)
    if paused then
        return;
    end

    accPos = {x = screenWidth / 2 + playerPos.x, y = screenHeight / 2 + playerPos.y};

    if not isDead then
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

        -- #endregion
    else 
        for i, line in ipairs(playerCorpseLines) do
            playerCorpseLines[i] = {
                x1 = line.x1 + math.sin(line.direction) * playerCorpseSpeed * dt,
                y1 = line.y1 - math.cos(line.direction) * playerCorpseSpeed * dt,
                x2 = line.x2 + math.sin(line.direction) * playerCorpseSpeed * dt,
                y2 = line.y2 - math.cos(line.direction) * playerCorpseSpeed * dt,
                direction = line.direction
            }
        end
        
        playerCorpseColor = playerCorpseColor - playerCorpseFadeSpeed * dt;
    end

    -- Bullet movement
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

    -- #region Misc updates

    -- Chunk management
    moveChunks(dt);
    spawnChunks(dt, accPos);

    -- Particle management
    moveParticles(dt);

    for _, toRemove in ipairs(removeBullets) do
        table.remove(bullets, toRemove);
    end

    if isMoving then
        if fireTimeCounter < fireShowInterval then
            fireTimeCounter = fireTimeCounter + dt;
        else fireShowing = not fireShowing; fireTimeCounter = 0;
        end
    end

    -- #endregion
end

function love.draw() 
    if gameOver then return end

    -- Debug variables
    love.graphics.print("Current Speed: "..moveSpeed, 0, 0);
    love.graphics.print("Angle: "..playerRotation, 0, 15);
    love.graphics.print("X: "..accPos.x.." | Y: "..accPos.y, 0, 30);
    love.graphics.print(playerCorpseColor, 0, 45);

    -- Player vertices
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
    
    if not isDead then
        -- Player draw
        local player = love.physics.newPolygonShape(bottomLeft.x, bottomLeft.y, bottomRight.x, bottomRight.y, top.x, top.y);
        love.graphics.polygon('fill', player:getPoints());
        if isMoving and fireShowing then 
            love.graphics.polygon('line', 
                    applyRotation(fireBottomLeft).x, applyRotation(fireBottomLeft).y, 
                    applyRotation(fireBottomRight).x, applyRotation(fireBottomRight).y, 
                    bottom.x, bottom.y
                );
        end
    else
        -- Player corpse draw
        for _, line in ipairs(playerCorpseLines) do
            love.graphics.setColor(playerCorpseColor, playerCorpseColor, playerCorpseColor)
            love.graphics.line(line.x1, line.y1, line.x2, line.y2);
            love.graphics.setColor(255, 255, 255);
        end
    end

    -- bullets draw
    for i, bullet in ipairs(bullets) do
        love.graphics.circle("fill", bullet.pos.x, bullet.pos.y, bulletSize)
    end

    -- chunks
    drawChunks();
    
    local removeChunks = {};
    for i, collider in ipairs(chunkColliders) do
        for ii, bullet in ipairs(bullets) do
            if bullet.pos.x >= collider.xMin and bullet.pos.x <= collider.xMax
                and bullet.pos.y >= collider.yMin and bullet.pos.y <= collider.yMax
            then
                table.insert(removeChunks, i);
                bullets[ii] = {
                    id = bullet.id,
                    pos = bullet.pos,
                    angle = bullet.angle,
                    lifetime = 100000
                }
            end
        end

        if checkPlayerCollision(bottomLeft, collider) or
            checkPlayerCollision(bottomRight, collider) or
            checkPlayerCollision(top, collider) then
            table.insert(playerCorpseLines, {x1 = bottomLeft.x, y1 = bottomLeft.y, x2 = bottomRight.x, y2 = bottomRight.y, direction = love.math.random(-3, 3)});
            table.insert(playerCorpseLines, {x1 = bottomLeft.x, y1 = bottomLeft.y, x2 = top.x, y2 = top.y, direction = love.math.random(-3, 3)});
            table.insert(playerCorpseLines, {x1 = bottomRight.x, y1 = bottomRight.y, x2 = top.x, y2 = top.y, direction = love.math.random(-3, 3)});

            isDead = true;
        end
    end

    for _, toRemove in ipairs(removeChunks) do
        local chunk = chunks[toRemove];

        -- Calculates center point
        local centerPoint = {x = 0, y = 0};

        local xSum = 0;
        local ySum = 0;
        for _, chunkPoint in ipairs(chunk.vertices) do
            xSum = xSum + chunkPoint.x;
            ySum = ySum + chunkPoint.y;
        end

        centerPoint = {x = xSum / #chunk.vertices, y = ySum / #chunk.vertices};

        -- Creates smaller chunks and particles
        local smallChunkCount = 0;
        local smallChunkSize = 15;

        if chunk.size > 30 then smallChunkCount = 3
        elseif chunk.size > 20 then smallChunkCount = 2
        end

        for i=1, smallChunkCount do
            createChunk(centerPoint.x, centerPoint.y, love.math.random(-3, 3), smallChunkSize);
        end

        createParticles(centerPoint.x, centerPoint.y);

        -- Removes chunk
        table.remove(chunks, toRemove);
        table.remove(chunkColliders, toRemove);
    end

    -- Particles
    drawParticles();
end

function applyRotation(raw)
    return {x = math.cos(playerRotation) * (raw.x - accPos.x) - math.sin(playerRotation) * (raw.y - accPos.y) + accPos.x, y = math.sin(playerRotation) * (raw.x - accPos.x) + math.cos(playerRotation) * (raw.y - accPos.y) + accPos.y}
end

function checkPlayerCollision(playerPoint, collider)
    return playerPoint.x >= collider.xMin and playerPoint.x <= collider.xMax
        and playerPoint.y >= collider.yMin and playerPoint.y <= collider.yMax;
end