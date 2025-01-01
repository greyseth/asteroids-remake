particles = {};

particleSize = 2;
particleLifetime = 2;
particleSpeed = 35;
particleCountMin = 10;
particleCountMax = 16;

function createParticles(posX, posY) 
    for i=1, love.math.random(particleCountMin, particleCountMax) do
        local direction = love.math.random(-3, 3);
        table.insert(particles, {x = posX, y = posY, lifetime = 0, direction = direction});
    end
end

function moveParticles(dt)
    local particleRemove = {};
    for i, p in ipairs(particles) do
        if p.lifetime >= particleLifetime then table.insert(particleRemove, i); goto continue; end

        particles[i] = {
            x = p.x + math.sin(p.direction) * particleSpeed * dt,
            y = p.y - math.cos(p.direction) * particleSpeed * dt,
            lifetime = p.lifetime + dt,
            direction = p.direction,
        }

        ::continue::
    end

    for _, toRemove in ipairs(particleRemove) do
        table.remove(particles, toRemove);
    end
end

function drawParticles()
    for _, p in ipairs(particles) do
        love.graphics.setColor(128, 128, 128);

        love.graphics.circle('line', p.x, p.y, particleSize);

        love.graphics.setColor(255, 255, 255);
    end
end