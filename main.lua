require('player');
require('projectiles');

require('particles');
require('chunks');

require('sounds');

-- Game variables
mainMenu = true;
paused = false;
gameOver = false;
playerWon = 0;

-- Debug variables
showValues = false;

function love.load()
    local appIcon = love.image.newImageData('img/icon.jpg');

    love.window.setMode(1280, 720, {fullscreen = false});
    love.window.setTitle('Asteroids But Bad');
    love.window.setIcon(appIcon);

    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()

    font = love.graphics.newFont('font/joystix.otf');
    font:setFilter('nearest', 'nearest');
    love.graphics.setFont(font);

    if not enablePlayer2 then playerPos = {x = 0, y = 0} end

    initializeSounds();
end

function love.keypressed(key)
    if key == 'escape' then 
        paused = not paused 
    end
end

function love.update(dt)
    if love.keyboard.isDown('1') and not paused then
        enablePlayer2 = false;
        restartGame();
    elseif love.keyboard.isDown('2') and not paused then
        enablePlayer2 = true;
        restartGame();
    end

    if paused or mainMenu then
        return;
    end

    if gameOver then fireSound:stop() end;

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
    if mainMenu then
        love.graphics.printf('ASTEROIDS, BUT BAD', 0, screenHeight/2-(font:getHeight()*5), screenWidth/5, 'center', 0, 5, 5);
        love.graphics.printf('Press 1 for singleplayer and press 2 for multiplayer', 0, screenHeight/2, screenWidth/2, 'center', 0, 2, 2)

        return;
    end

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
                explosionSound:seek(0, 'seconds');
                explosionSound:play();

                table.insert(removeChunks, i);
                bullets[ii] = {
                    id = bullet.id,
                    pos = bullet.pos,
                    angle = bullet.angle,
                    lifetime = 100000
                }
            end
        end

        if checkPlayerCollision(collider) then
            if not gameOver then
                deathSound:play();
                if isDead then playerWon = 2 else playerWon = 1 end
                gameOver = true;
            end
        end
    end

    -- Bullet collision detection
    for i, bullet in ipairs(bullets) do
        if checkPlayerKill(bullet.pos) then
            deathSound:play();

            bullets[i] = {
                id = bullet.id,
                pos = bullet.pos,
                angle = bullet.angle,
                lifetime = 100000
            }

            if not gameOver then
                if isDead then playerWon = 2 else playerWon = 1 end
                gameOver = true;
            end
        end
    end

    for _, toRemove in ipairs(removeChunks) do
        local chunk = chunks[toRemove];

        if chunk then
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

            if chunk.size > 35 then smallChunkCount = 3
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
    end

    -- Particles
    drawParticles();

    -- Text and UI elements
    if gameOver then
        local textScale = 4;
        local message = 'GAME OVER';

        if enablePlayer2 then message = 'PLAYER '..playerWon..'\nWINS' end

        love.graphics.printf(message, 0, screenHeight/2-(font:getHeight()*textScale), screenWidth/textScale, 'center', 0, textScale, textScale);
    end
end

function restartGame()
    selectSound:play();

    local playerX = 0;
    if enablePlayer2 then playerX = -400; end

    playerPos = {x = playerX, y = 0};
    playerPos2 = {x = 400, y = 0};
    colliderPoints = {};
    colliderPoints2 = {};

    moveSpeed = 0;
    moveSpeed2 = 0;
    playerRotation = 0;
    playerRotation2 = 0;

    isDead = false;
    isDead2 = false;

    playerCorpseLines = {};
    playerCorpseColor = 255;
    playerCorpseLines2 = {};
    playerCorpseColor2 = 255;

    chunks = {};
    chunkColliders = {};

    particles = {};

    bullets = {};

    gameOver = false;
    mainMenu = false;
end