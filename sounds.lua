function initializeSounds()
    -- Sound effect initialization
    shootSound = love.audio.newSource('sounds/laserShoot.wav', 'static');
    explosionSound = love.audio.newSource('sounds/explosion.wav', 'static');
    deathSound = love.audio.newSource('sounds/hitHurt.wav', 'static');
    selectSound = love.audio.newSource('sounds/blipSelect.wav', 'static');
    fireSound = love.audio.newSource('sounds/fire.wav', 'stream');
end