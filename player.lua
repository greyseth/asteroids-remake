-- Player values
topSpeed = 250;
acceleration = 120;
deceleration = 170;
moveSpeed = 0;

playerPos = {x = -400, y = 0};
accPos = {x = 0, y = 0};

playerRotation = 0;
rotateSpeed = 5;

playerSize = {width = 20, height = 30};

isMoving = false;
moveDirection = 1; 

fireShowing = true;
fireShowInterval = 0.0005;
fireTimeCounter = 0;

isDead = false;

-- Misc player values
colliderPoints = {};
showColliderBox = false;
playerCorpseLines = {};
playerCorpseSpeed = 40;
playerCorpseColor = 255;
playerCorpseFadeSpeed = 100;

-- Player 2
enablePlayer2 = true;

isMoving2 = false;
moveSpeed2 = 0;
playerPos2 = {x = 400, y = 0};
accPos2 = {x = 0, y = 0};
playerRotation2 = 0;
isDead2 = false;
nextFireTime2 = 0.3;
playerCorpseLines2 = {};
playerCorpseColor2 = 255;
colliderPoints2 = {};

function playerUpdate(dt)
    accPos = {x = screenWidth / 2 + playerPos.x, y = screenHeight / 2 + playerPos.y};
    accPos2 = {x = screenWidth / 2 + playerPos2.x, y = screenHeight / 2 + playerPos2.y};

    local secondPlayer = 1;
    if enablePlayer2 then secondPlayer = 2 end
    for i=1, secondPlayer do
        local _isDead = false;
        local _isMoving = false;
        local _playerRotation = 0;
        local _moveSpeed = 0;
        local _playerPos = {};
        local _accPos = {};
        local _nextFireTime = 0;
        local _playerCorpseLines = {};
        local _playerCorpseColor = 255;

        local leftButton = '';
        local rightButton = '';
        local upButton = '';
        local shootButton = '';
        if i == 1 then
            _isDead = isDead;
            _isMoving = isMoving;
            _playerRotation = playerRotation;
            _moveSpeed = moveSpeed;
            _playerPos = playerPos;
            _accPos = accPos;
            _nextFireTime = nextFireTime;
            _playerCorpseLines = playerCorpseLines;
            _playerCorpseColor = playerCorpseColor;

            leftButton = 'a';
            rightButton = 'd';
            upButton = 'w';
            shootButton = 'space';
        else
            _isDead = isDead2;
            _isMoving = isMoving2;
            _playerRotation = playerRotation2;
            _moveSpeed = moveSpeed2;
            _playerPos = playerPos2;
            _accPos = accPos2;
            _nextFireTime = nextFireTime2;
            _playerCorpseLines = playerCorpseLines2;
            _playerCorpseColor = playerCorpseColor2;

            leftButton = 'left';
            rightButton = 'right';
            upButton = 'up';
            shootButton = 'kp0';
        end

        if not _isDead then
            -- #region Movement
        
            -- Rotation input & handling
            if love.keyboard.isDown(rightButton) then
                _playerRotation = _playerRotation + rotateSpeed * dt;
            elseif love.keyboard.isDown(leftButton) then
                _playerRotation = _playerRotation - rotateSpeed * dt;
            end

            -- Movement input
            if love.keyboard.isDown(upButton) then
                _isMoving = true;
                moveDirection = -1;

                fireShowing = true;
                fireTimeCounter = 0;
            else _isMoving = false;
            end

            -- Acceleration handling
            if _isMoving then
                if _moveSpeed < topSpeed then
                    _moveSpeed = _moveSpeed + acceleration * dt;
                end
            else
                if _moveSpeed > 0 then
                    _moveSpeed = _moveSpeed - deceleration * dt;
                end
            end

            -- Moves player
            local forwardX = math.sin(_playerRotation) * moveDirection;
            local forwardY = math.cos(_playerRotation) * moveDirection;
            _playerPos = {x = _playerPos.x - (forwardX * _moveSpeed * dt), y = _playerPos.y + (forwardY * _moveSpeed * dt)};

            -- #endregion

            -- #region Shooting

            -- Input handling
            if love.keyboard.isDown(shootButton) and love.timer.getTime() >= _nextFireTime then
                local topRaw = {x = _accPos.x, y = _accPos.y - (playerSize.height / 2)};
                local top = {x = math.cos(_playerRotation) * (topRaw.x - _accPos.x) - math.sin(_playerRotation) * (topRaw.y - _accPos.y) + _accPos.x, y = math.sin(_playerRotation) * (topRaw.x - _accPos.x) + math.cos(_playerRotation) * (topRaw.y - _accPos.y) + _accPos.y};

                table.insert(bullets, {id = table.getn(bullets)+1, pos = top, angle = _playerRotation, lifetime = 0});

                _nextFireTime = love.timer.getTime() + 1 / fireRate;
            end

            -- #endregion
        else 
            for i, line in ipairs(_playerCorpseLines) do
                _playerCorpseLines[i] = {
                    x1 = line.x1 + math.sin(line.direction) * playerCorpseSpeed * dt,
                    y1 = line.y1 - math.cos(line.direction) * playerCorpseSpeed * dt,
                    x2 = line.x2 + math.sin(line.direction) * playerCorpseSpeed * dt,
                    y2 = line.y2 - math.cos(line.direction) * playerCorpseSpeed * dt,
                    direction = line.direction
                }
            end
            
            _playerCorpseColor = _playerCorpseColor - playerCorpseFadeSpeed * dt;
        end

        if i == 1 then
            isDead = _isDead;
            isMoving = _isMoving;
            playerRotation = _playerRotation;
            moveSpeed = _moveSpeed;
            playerPos = _playerPos;
            nextFireTime = _nextFireTime;
            playerCorpseColor = _playerCorpseColor;
        else
            isDead2 = _isDead;
            isMoving2 = _isMoving;
            playerRotation2 = _playerRotation;
            moveSpeed2 = _moveSpeed;
            playerPos2 = _playerPos;
            nextFireTime2 = _nextFireTime;
            playerCorpseColor2 = _playerCorpseColor;
        end
    end
end

function playerDraw()
    local secondPlayer = 1;
    if enablePlayer2 then secondPlayer = 2 end
    for i=1, secondPlayer do
        local _accPos = {};
        local _playerRotation = 0;
        local _isMoving = false;
        local _isDead = false;
        local _playerCorpseLines = {};
        local _playerCorpseColor = 255;
        local _colliderPoints = {};

        local color = {};

        if i == 1 then 
            _accPos = accPos 
            _playerRotation = playerRotation;
            _isMoving = isMoving;
            _isDead = isDead;
            _playerCorpseLines = playerCorpseLines;
            _playerCorpseColor = playerCorpseColor;
            _colliderPoints = colliderPoints;

            color = {0, 0, 128};
        else 
            _accPos = accPos2;
            _playerRotation = playerRotation2;
            _isMoving = isMoving2;
            _isDead = isDead2;
            _playerCorpseLines = playerCorpseLines2;
            _playerCorpseColor = playerCorpseColor2;
            _colliderPoints = colliderPoints2;

            color = {128, 0, 0};
        end;

        -- Player vertices
        local bottomLeftRaw = {x = _accPos.x - (playerSize.width / 2), y = _accPos.y + (playerSize.height/2)};
        local bottomRightRaw = {x = _accPos.x + (playerSize.width / 2), y = _accPos.y + (playerSize.height/2)};
        local topRaw = {x = _accPos.x, y = _accPos.y - (playerSize.height / 2)};
        local bottomRaw = {x = _accPos.x, y = _accPos.y + playerSize.height};

        local fireBottomLeft = {x = _accPos.x - (playerSize.width / 4), y = _accPos.y + (playerSize.height / 2)};
        local fireBottomRight = {x = _accPos.x + (playerSize.width / 4), y = _accPos.y + (playerSize.height / 2)};

        bottomLeft = applyRotation(_playerRotation, _accPos, bottomLeftRaw);
        bottomRight = applyRotation(_playerRotation, _accPos, bottomRightRaw);
        top = applyRotation(_playerRotation, _accPos, topRaw);
        bottom = applyRotation(_playerRotation, _accPos, bottomRaw);
        
        if not _isDead then
            -- Player draw
            local player = love.physics.newPolygonShape(bottomLeft.x, bottomLeft.y, bottomRight.x, bottomRight.y, top.x, top.y);
            love.graphics.setColor(color);
            love.graphics.polygon('fill', player:getPoints());
            love.graphics.setColor(255, 255, 255);

            -- Draws fire
            if _isMoving and fireShowing then 
                love.graphics.polygon('line', 
                        applyRotation(_playerRotation, _accPos, fireBottomLeft).x, applyRotation(_playerRotation, _accPos, fireBottomLeft).y, 
                        applyRotation(_playerRotation, _accPos, fireBottomRight).x, applyRotation(_playerRotation, _accPos, fireBottomRight).y, 
                        bottom.x, bottom.y
                    );
            end

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

            _colliderPoints = {xMin = xMin, xMax = xMax, yMin = yMin, yMax = yMax};

            if i==1 then colliderPoints = _colliderPoints else colliderPoints2 = _colliderPoints end

            if showColliderBox then
                love.graphics.setColor(0, 1, 0);
                love.graphics.rectangle('line', _colliderPoints.xMin, _colliderPoints.yMin, (_colliderPoints.xMax-_colliderPoints.xMin), (_colliderPoints.yMax-_colliderPoints.yMin));
                love.graphics.setColor(255, 255, 255);
            end
        else
            -- Player corpse draw
            for _, line in ipairs(_playerCorpseLines) do
                love.graphics.setColor(_playerCorpseColor, _playerCorpseColor, _playerCorpseColor)
                love.graphics.line(line.x1, line.y1, line.x2, line.y2);
                love.graphics.setColor(255, 255, 255);
            end
        end
    end
end

function applyRotation(rotation, pos, raw)
    return {x = math.cos(rotation) * (raw.x - pos.x) - math.sin(rotation) * (raw.y - pos.y) + pos.x, y = math.sin(rotation) * (raw.x - pos.x) + math.cos(rotation) * (raw.y - pos.y) + pos.y}
end

function checkPlayerCollision(collider)
    local returnValue = false;

    local secondPlayer = 1;
    if enablePlayer2 then secondPlayer = 2 end
    for i=1, secondPlayer do
        local _isDead = false;
        if i == 1 then _isDead = isDead else _isDead = isDead2 end

        if not _isDead then
            local _accPos = {};
            local _playerRotation = 0;

            if i == 1 then 
                _accPos = accPos 
                _playerRotation = playerRotation;
            else 
                _accPos = accPos2;
                _playerRotation = playerRotation2;
            end;
        
            -- Player vertices
            local bottomLeftRaw = {x = _accPos.x - (playerSize.width / 2), y = _accPos.y + (playerSize.height/2)};
            local bottomRightRaw = {x = _accPos.x + (playerSize.width / 2), y = _accPos.y + (playerSize.height/2)};
            local topRaw = {x = _accPos.x, y = _accPos.y - (playerSize.height / 2)};
            local bottomRaw = {x = _accPos.x, y = _accPos.y + playerSize.height};

            local fireBottomLeft = {x = _accPos.x - (playerSize.width / 4), y = _accPos.y + (playerSize.height / 2)};
            local fireBottomRight = {x = _accPos.x + (playerSize.width / 4), y = _accPos.y + (playerSize.height / 2)};

            local bottomLeft = applyRotation(_playerRotation, _accPos, bottomLeftRaw);
            local bottomRight = applyRotation(_playerRotation, _accPos, bottomRightRaw);
            local top = applyRotation(_playerRotation, _accPos, topRaw);
            local bottom = applyRotation(_playerRotation, _accPos, bottomRaw);
            
            if
                (bottomLeft.x >= collider.xMin and bottomLeft.x <= collider.xMax
                and bottomLeft.y >= collider.yMin and bottomLeft.y <= collider.yMax)
                or
                (bottomRight.x >= collider.xMin and bottomRight.x <= collider.xMax
                and bottomRight.y >= collider.yMin and bottomRight.y <= collider.yMax)
                or
                (top.x >= collider.xMin and top.x <= collider.xMax
                and top.y >= collider.yMin and top.y <= collider.yMax)
            then
                local _playerCorpseLines = {};
                
                table.insert(_playerCorpseLines, {x1 = bottomLeft.x, y1 = bottomLeft.y, x2 = bottomRight.x, y2 = bottomRight.y, direction = love.math.random(-3, 3)});
                table.insert(_playerCorpseLines, {x1 = bottomLeft.x, y1 = bottomLeft.y, x2 = top.x, y2 = top.y, direction = love.math.random(-3, 3)});
                table.insert(_playerCorpseLines, {x1 = bottomRight.x, y1 = bottomRight.y, x2 = top.x, y2 = top.y, direction = love.math.random(-3, 3)});

                if i == 1 then 
                    playerCorpseLines = _playerCorpseLines;
                    isDead = true;
                else 
                    playerCorpseLines2 = _playerCorpseLines;
                    isDead2 = true;
                end

                createParticles(_accPos.x, _accPos.y);

                returnValue = true;
            end
        end
    end

    return returnValue;
end

function checkPlayerKill(bulletPos)
    local returnValue = false;

    local secondPlayer = 1;
    if enablePlayer2 then secondPlayer = 2 end
    for i=1, secondPlayer do
        local _isDead = false;
        local _accPos = {};
        local _playerRotation = 0;
        local _colliderPoints = {};
        if i == 1 then 
            _isDead = isDead;
            _accPos = accPos;
            _playerRotation = playerRotation;
            _colliderPoints = colliderPoints;
        else 
            _isDead = isDead2;
            _accPos = accPos2;
            _playerRotation = playerRotation2;
            _colliderPoints = colliderPoints2;
        end

        if not _isDead then
            -- Player vertices
            local bottomLeftRaw = {x = _accPos.x - (playerSize.width / 2), y = _accPos.y + (playerSize.height/2)};
            local bottomRightRaw = {x = _accPos.x + (playerSize.width / 2), y = _accPos.y + (playerSize.height/2)};
            local topRaw = {x = _accPos.x, y = _accPos.y - (playerSize.height / 2)};
            local bottomRaw = {x = _accPos.x, y = _accPos.y + playerSize.height};

            local fireBottomLeft = {x = _accPos.x - (playerSize.width / 4), y = _accPos.y + (playerSize.height / 2)};
            local fireBottomRight = {x = _accPos.x + (playerSize.width / 4), y = _accPos.y + (playerSize.height / 2)};

            local bottomLeft = applyRotation(_playerRotation, _accPos, bottomLeftRaw);
            local bottomRight = applyRotation(_playerRotation, _accPos, bottomRightRaw);
            local top = applyRotation(_playerRotation, _accPos, topRaw);
            local bottom = applyRotation(_playerRotation, _accPos, bottomRaw);

            print(_colliderPoints.xMin);
            if bulletPos.x >= _colliderPoints.xMin and bulletPos.x <= _colliderPoints.xMax
                and bulletPos.y >= _colliderPoints.yMin and bulletPos.y <= _colliderPoints.yMax
            then
                local _playerCorpseLines = {};
                
                table.insert(_playerCorpseLines, {x1 = bottomLeft.x, y1 = bottomLeft.y, x2 = bottomRight.x, y2 = bottomRight.y, direction = love.math.random(-3, 3)});
                table.insert(_playerCorpseLines, {x1 = bottomLeft.x, y1 = bottomLeft.y, x2 = top.x, y2 = top.y, direction = love.math.random(-3, 3)});
                table.insert(_playerCorpseLines, {x1 = bottomRight.x, y1 = bottomRight.y, x2 = top.x, y2 = top.y, direction = love.math.random(-3, 3)});

                if i == 1 then 
                    playerCorpseLines = _playerCorpseLines;
                    isDead = true;
                else 
                    playerCorpseLines2 = _playerCorpseLines;
                    isDead2 = true;
                end

                createParticles(_accPos.x, _accPos.y);

                returnValue = true;
            end
        end
    end

    return returnValue;
end