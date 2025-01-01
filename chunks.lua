chunks = {};
chunkColliders = {};

chunkSpeedMin = 35;
chunkSpeedMax = 150;
chunkRotateSpeedMin = 0.25;
chunkRotateSpeedMax = 2.2;
chunkSizeMin = 20;
chunkSizeMax = 45;
chunkVerticesMin = 5;
chunkVerticesMax = 8;
jaggedMax = 20;
chunkMaxLifetime = 20;

chunkSpawnRate = 1;
nextSpawnTime = 0.5;

showCollider = true;

function createChunk(posX, posY, direction, size)
    local chunkSize = 0;
    if not size then chunkSize = love.math.random(chunkSizeMin, chunkSizeMax); else chunkSize = size end
    local chunkVertices = love.math.random(chunkVerticesMin, chunkVerticesMax);
    local chunkSpeed = love.math.random(chunkSpeedMin, chunkSpeedMax);
    local chunkRotateSpeed = love.math.random(chunkRotateSpeedMin, chunkRotateSpeedMax);
    local rotationDirection = 0;
    if love.math.random(-1, 1) > 0 then rotationDirection = 1 else rotationDirection = -1 end;

    local vertices = {};
    local angleStep = (2 * math.pi) / chunkVertices;

    for i = 1, chunkVertices, 1 do
        local angle = i * angleStep;
        local jaggedness = love.math.random(-jaggedMax, jaggedMax);

        table.insert(vertices, {x=posX + (chunkSize + jaggedness) * math.cos(angle), y=posY + (chunkSize + jaggedness) * math.sin(angle)});
    end

    table.insert(chunks, {vertices = vertices, direction = direction, speed = chunkSpeed, rotation = 0, rotationDirection = rotationDirection, rotationSpeed = chunkRotateSpeed, size = chunkSize, lifetime = 0});
end

function moveChunks(dt)
    local removeChunks = {};
    for i, chunk in ipairs(chunks) do
        if chunk.lifetime >= chunkMaxLifetime then table.insert(removeChunks, i); goto continue; end
        
        local newVerticesPositions = {};

        -- Moves each vertex
        for _, chunkPoint in ipairs(chunk.vertices) do
            table.insert(newVerticesPositions, {
                x = chunkPoint.x + math.sin(chunk.direction)*chunk.speed*dt,
                y = chunkPoint.y - math.cos(chunk.direction)*chunk.speed*dt
            });
        end

        chunks[i] = {
            vertices = newVerticesPositions,
            direction = chunk.direction,
            speed = chunk.speed,
            size = chunk.size,
            rotationSpeed = chunk.rotationSpeed,
            rotationDirection = chunk.rotationDirection,
            rotation = chunk.rotation + (chunk.rotationSpeed * chunk.rotationDirection) * dt,
            lifetime = chunk.lifetime + dt
        }

        ::continue::
    end

    for _, toRemove in ipairs(removeChunks) do
        table.remove(chunks, toRemove);
    end
end

function spawnChunks(dt, playerPos)
    if love.timer.getTime() > nextSpawnTime then
        -- Spawns at the edge of the screen
        local edgePick = love.math.random(4); -- 1 left, 2 top, 3 right, 4 bottom
        local spawnPos = {x = 0, y = 0};
        local spawnDir = 0;

        if edgePick == 1 then
            spawnPos = {x = -chunkSizeMax, y = love.math.random(-chunkSizeMax, love.graphics.getHeight()+chunkSizeMax)};
            spawnDir = love.math.random(1.1, 1.4);
        elseif edgePick == 2 then
            spawnPos = {x = love.math.random(-chunkSizeMax, love.graphics.getWidth()+chunkSizeMax), y = -chunkSizeMax};
            spawnDir = love.math.random(2.8, 3.1);
        elseif edgePick == 3 then
            spawnPos = {x = love.graphics.getWidth()+chunkSizeMax, y = love.math.random(-chunkSizeMax, love.graphics.getHeight()+chunkSizeMax)}
            spawnDir = -love.math.random(1.1, 1.4);
        elseif edgePick == 4 then
            spawnPos = {x = love.math.random(-chunkSizeMax, love.graphics.getWidth()+chunkSizeMax), y = love.graphics.getHeight()+chunkSizeMax};
            spawnDir = love.math.random(-0.1, 0.1);
        end

        -- Initially to move towards where the player is
        -- local playerDirection = {x = playerPos.x - spawnPos.x, y = playerPos.y - spawnPos.y};
        -- createChunk(spawnPos.x, spawnPos.y, -math.deg(math.atan2(playerDirection.y, playerDirection.x)));

        createChunk(spawnPos.x, spawnPos.y, spawnDir);
        nextSpawnTime = love.timer.getTime() + 1 / chunkSpawnRate;
    end
end

function drawChunks()
    for i, chunk in ipairs(chunks) do
        local chunkPoints = {};
        local centerPoint = {x = 0, y = 0};

        -- Calculates center point
        local xSum = 0;
        local ySum = 0;
        for _, chunkPoint in ipairs(chunk.vertices) do
            xSum = xSum + chunkPoint.x;
            ySum = ySum + chunkPoint.y;
        end

        centerPoint = {x = xSum / #chunk.vertices, y = ySum / #chunk.vertices};

        -- Draws and rotates chunk
        for ii, chunkPoint in ipairs(chunk.vertices) do
            local xRotated = math.cos(chunk.rotation) * (chunkPoint.x - centerPoint.x) - math.sin(chunk.rotation) * (chunkPoint.y - centerPoint.y) + centerPoint.x;
            local yRotated =  math.sin(chunk.rotation) * (chunkPoint.x - centerPoint.x) + math.cos(chunk.rotation) * (chunkPoint.y - centerPoint.y) + centerPoint.y;

            table.insert(chunkPoints, xRotated);
            table.insert(chunkPoints, yRotated);
        end

        local xMin = 10000; local xMax = -10000;
        local yMin = 10000; local yMax = -10000;
        for i = 1, #chunkPoints do
            if i % 2 ~= 0 then
                if chunkPoints[i] < xMin then xMin = chunkPoints[i] end
                if chunkPoints[i] > xMax then xMax = chunkPoints[i] end 
            else
                if chunkPoints[i] < yMin then yMin = chunkPoints[i] end
                if chunkPoints[i] > yMax then yMax = chunkPoints[i] end
            end
        end

        chunkColliders[i] = {xMin = xMin, xMax = xMax, yMin = yMin, yMax = yMax};

        local chunkShape = love.physics.newPolygonShape(chunkPoints);
        love.graphics.polygon('line', chunkShape:getPoints());
    end

    if showCollider then
        for i, collider in ipairs(chunkColliders) do
            love.graphics.setColor(0, 1, 0);
            love.graphics.rectangle('line', collider.xMin, collider.yMin, (collider.xMax-collider.xMin), (collider.yMax-collider.yMin));
            love.graphics.setColor(255, 255, 255);
        end
    end
end