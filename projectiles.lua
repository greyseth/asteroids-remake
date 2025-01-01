-- Projectile variables
bullets = {};
bulletSpeed = 450;
bulletSize = 2.5;
bulletMaxLifetime = 3;
fireRate = 3;
nextFireTime = 0.3;

function bulletUpdate(dt)
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

    for _, toRemove in ipairs(removeBullets) do
        table.remove(bullets, toRemove);
    end

    if isMoving then
        if fireTimeCounter < fireShowInterval then
            fireTimeCounter = fireTimeCounter + dt;
        else fireShowing = not fireShowing; fireTimeCounter = 0;
        end
    end
end

function bulletDraw()
    -- bullets draw
    for i, bullet in ipairs(bullets) do
        love.graphics.circle("fill", bullet.pos.x, bullet.pos.y, bulletSize)
    end
end