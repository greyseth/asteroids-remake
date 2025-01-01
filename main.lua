require('player');
require('projectiles');

require('particles');
require('chunks');

-- Game variables
paused = false;
isDead = false;
gameOver = false;

-- Debug variables
showValues = true;

function love.load()
    local appIcon = love.image.newImageData('assets/icon.jpg');

    love.window.setMode(1280, 720, {fullscreen = false});
    love.window.setTitle('Asteroids But Bad');
    love.window.setIcon(appIcon);

    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()
end

function love.keypressed(key)
    if key == 'escape' then paused = not paused end
end

function love.update(dt)
    if paused then
        return;
    end

    playerUpdate(dt);

    bulletUpdate(dt);

    -- #region Misc updates

    -- Chunk management
    moveChunks(dt);
    spawnChunks(dt, accPos);

    -- Particle management
    moveParticles(dt);

    -- #endregion
end

function love.draw() 
    if gameOver then return end

    if showValues then
        -- Debug variables
        love.graphics.print("Current Speed: "..moveSpeed, 0, 0);
        love.graphics.print("Angle: "..playerRotation, 0, 15);
        love.graphics.print("X: "..accPos.x.." | Y: "..accPos.y, 0, 30);
        love.graphics.print("Chunk count: "..#chunks, 0, 45);
    end

    drawChunks();
    playerDraw();
    bulletDraw();
    
    -- Chunk collision detection
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

        if not isDead then
            if checkPlayerCollision(collider) then 
                playerDie(); 
                createParticles(accPos.x, accPos.y); 
            end
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