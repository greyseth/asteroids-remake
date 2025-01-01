-- Player values
topSpeed = 250;
acceleration = 120;
deceleration = 170;
moveSpeed = 0;

playerPos = {x = 0, y = 0};
accPos = {x = 0, y = 0};

playerRotation = 0;
rotateSpeed = 5;

playerSize = {width = 20, height = 30};

isMoving = false;
moveDirection = 1; 

fireShowing = true;
fireShowInterval = 0.0005;
fireTimeCounter = 0;

-- Player 2
moveSpeed2 = 0;
playerPos2 = {x = 0, y = 0};
accPos2 = {x = 0, y = 0};
playerRotation2 = 0;

-- Misc player values
playerCorpseLines = {};
playerCorpseSpeed = 40;
playerCorpseColor = 255;
playerCorpseFadeSpeed = 100;

colliderPoints = {};
showColliderBox = false;

function playerUpdate(dt)
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
end

function playerDraw()
    -- Player vertices
    local bottomLeftRaw = {x = accPos.x - (playerSize.width / 2), y = accPos.y + (playerSize.height/2)};
    local bottomRightRaw = {x = accPos.x + (playerSize.width / 2), y = accPos.y + (playerSize.height/2)};
    local topRaw = {x = accPos.x, y = accPos.y - (playerSize.height / 2)};
    local bottomRaw = {x = accPos.x, y = accPos.y + playerSize.height};

    local fireBottomLeft = {x = accPos.x - (playerSize.width / 4), y = accPos.y + (playerSize.height / 2)};
    local fireBottomRight = {x = accPos.x + (playerSize.width / 4), y = accPos.y + (playerSize.height / 2)};

    bottomLeft = applyRotation(bottomLeftRaw);
    bottomRight = applyRotation(bottomRightRaw);
    top = applyRotation(topRaw);
    bottom = applyRotation(bottomRaw);
    
    if not isDead then
        -- Player draw
        local player = love.physics.newPolygonShape(bottomLeft.x, bottomLeft.y, bottomRight.x, bottomRight.y, top.x, top.y);
        love.graphics.setColor(0, 0, 255);
        love.graphics.polygon('fill', player:getPoints());
        love.graphics.setColor(255, 255, 255);

        -- Draws fire
        if isMoving and fireShowing then 
            love.graphics.polygon('line', 
                    applyRotation(fireBottomLeft).x, applyRotation(fireBottomLeft).y, 
                    applyRotation(fireBottomRight).x, applyRotation(fireBottomRight).y, 
                    bottom.x, bottom.y
                );
        end

        if showColliderBox then
            -- Collider visualization (im not proud of this method...)
            local playerPoints = {};
            playerPoints[1] = bottomLeft.x; playerPoints[2] = bottomLeft.y;
            playerPoints[3] = bottomRight.x; playerPoints[4] = bottomRight.y;
            playerPoints[5] = top.x; playerPoints[6] = top.y;

            local xMin = 10000; local xMax = -10000;
            local yMin = 10000; local yMax = -10000;
            for i = 1, #playerPoints do
                if i % 2 ~= 0 then
                    if playerPoints[i] < xMin then xMin = playerPoints[i] end
                    if playerPoints[i] > xMax then xMax = playerPoints[i] end 
                else
                    if playerPoints[i] < yMin then yMin = playerPoints[i] end
                    if playerPoints[i] > yMax then yMax = playerPoints[i] end
                end
            end

            colliderPoints = {xMin = xMin, xMax = xMax, yMin = yMin, yMax = yMax};

            love.graphics.setColor(0, 1, 0);
            love.graphics.rectangle('line', colliderPoints.xMin, colliderPoints.yMin, (colliderPoints.xMax-colliderPoints.xMin), (colliderPoints.yMax-colliderPoints.yMin));
            love.graphics.setColor(255, 255, 255);
        end
    else
        -- Player corpse draw
        for _, line in ipairs(playerCorpseLines) do
            love.graphics.setColor(playerCorpseColor, playerCorpseColor, playerCorpseColor)
            love.graphics.line(line.x1, line.y1, line.x2, line.y2);
            love.graphics.setColor(255, 255, 255);
        end
    end
end

function applyRotation(raw)
    return {x = math.cos(playerRotation) * (raw.x - accPos.x) - math.sin(playerRotation) * (raw.y - accPos.y) + accPos.x, y = math.sin(playerRotation) * (raw.x - accPos.x) + math.cos(playerRotation) * (raw.y - accPos.y) + accPos.y}
end

function checkPlayerCollision(collider)
    return 
        (bottomLeft.x >= collider.xMin and bottomLeft.x <= collider.xMax
        and bottomLeft.y >= collider.yMin and bottomLeft.y <= collider.yMax)
        or
        (bottomRight.x >= collider.xMin and bottomRight.x <= collider.xMax
        and bottomRight.y >= collider.yMin and bottomRight.y <= collider.yMax)
        or
        (top.x >= collider.xMin and top.x <= collider.xMax
        and top.y >= collider.yMin and top.y <= collider.yMax);
end

function playerDie()
    table.insert(playerCorpseLines, {x1 = bottomLeft.x, y1 = bottomLeft.y, x2 = bottomRight.x, y2 = bottomRight.y, direction = love.math.random(-3, 3)});
    table.insert(playerCorpseLines, {x1 = bottomLeft.x, y1 = bottomLeft.y, x2 = top.x, y2 = top.y, direction = love.math.random(-3, 3)});
    table.insert(playerCorpseLines, {x1 = bottomRight.x, y1 = bottomRight.y, x2 = top.x, y2 = top.y, direction = love.math.random(-3, 3)});

    isDead = true;
end