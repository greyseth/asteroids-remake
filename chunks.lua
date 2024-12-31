chunks = {};

chunkSpeedMin = 35;
chunkSpeedMax = 150;
chunkRotateSpeedMin = 0.25;
chunkRotateSpeedMax = 2.2;
chunkSizeMin = 20;
chunkSizeMax = 85;
chunkVerticesMin = 5;
chunkVerticesMax = 8;
jaggedMax = 20;

chunkSpawnRate = 1.2;
nextSpawnTime = 0.5;

function createChunk(posX, posY, direction)
    local chunkSize = love.math.random(chunkSizeMin, chunkSizeMax);
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

    table.insert(chunks, {vertices = vertices, direction = direction, speed = chunkSpeed, rotation = 0, rotationDirection = rotationDirection, rotationSpeed = chunkRotateSpeed});
end

function moveChunks(dt)
    for i, chunk in ipairs(chunks) do
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
            rotationSpeed = chunk.rotationSpeed,
            rotationDirection = chunk.rotationDirection,
            rotation = chunk.rotation + (chunk.rotationSpeed * chunk.rotationDirection) * dt,
        }
    end
end

function spawnChunks(dt, playerPos)
    if love.timer.getTime() > nextSpawnTime then
        -- createChunk(love.graphics.getWidth()/2, love.graphics.getHeight()/2, math.sqrt(playerPos.x*playerPos.x + playerPos.y*playerPos.y));
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
        for i, chunkPoint in ipairs(chunk.vertices) do
            local xRotated = math.cos(chunk.rotation) * (chunkPoint.x - centerPoint.x) - math.sin(chunk.rotation) * (chunkPoint.y - centerPoint.y) + centerPoint.x;
            local yRotated =  math.sin(chunk.rotation) * (chunkPoint.x - centerPoint.x) + math.cos(chunk.rotation) * (chunkPoint.y - centerPoint.y) + centerPoint.y;

            table.insert(chunkPoints, xRotated);
            table.insert(chunkPoints, yRotated);
        end

        local chunkShape = love.physics.newPolygonShape(chunkPoints);
        love.graphics.polygon('line', chunkShape:getPoints());
    end
end