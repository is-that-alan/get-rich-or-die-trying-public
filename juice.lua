-- SIMPLE JUICE SYSTEM for Hackathon
-- Maximum impact, minimal code
local Juice = {}

-- Simple animation state
local effects = {}
local shakeX, shakeY = 0, 0
local flashAlpha = 0

function Juice.init()
    effects = {}
    shakeX, shakeY = 0, 0
    flashAlpha = 0
end

function Juice.update(dt)
    -- Update screen shake
    shakeX = shakeX * 0.9
    shakeY = shakeY * 0.9

    -- Update flash
    flashAlpha = math.max(0, flashAlpha - dt * 3)

    -- Update effects
    for i = #effects, 1, -1 do
        local effect = effects[i]
        effect.life = effect.life - dt

        if effect.type == "money" then
            effect.y = effect.y - 50 * dt
            effect.alpha = effect.life / effect.maxLife
        elseif effect.type == "particle" then
            effect.x = effect.x + effect.vx * dt
            effect.y = effect.y + effect.vy * dt
            effect.alpha = effect.life / effect.maxLife
        end

        if effect.life <= 0 then
            table.remove(effects, i)
        end
    end
end

-- SCREEN SHAKE (super simple but feels amazing)
function Juice.shake(intensity)
    intensity = intensity or 5
    shakeX = shakeX + (math.random() - 0.5) * intensity
    shakeY = shakeY + (math.random() - 0.5) * intensity
end

-- SCREEN FLASH (for big moments)
function Juice.flash(alpha)
    flashAlpha = alpha or 0.3
end

-- MONEY POPUP (feels so satisfying)
function Juice.showMoney(x, y, amount)
    table.insert(effects, {
        type = "money",
        x = x, y = y,
        amount = amount,
        life = 1.5,
        maxLife = 1.5,
        alpha = 1
    })
end

-- PARTICLES (for card plays, wins, etc)
function Juice.burst(x, y, color, count)
    color = color or {1, 0.8, 0}
    count = count or 10

    for i = 1, count do
        local angle = (i / count) * math.pi * 2
        local speed = 50 + math.random() * 100

        table.insert(effects, {
            type = "particle",
            x = x, y = y,
            vx = math.cos(angle) * speed,
            vy = math.sin(angle) * speed,
            life = 0.8 + math.random() * 0.4,
            maxLife = 1.2,
            alpha = 1,
            color = color,
            size = 2 + math.random() * 3
        })
    end
end

-- SIMPLE SOUND SYSTEM (using love2d's built-in sounds)
local sounds = {}

function Juice.initSounds()
    -- Generate simple sound effects programmatically
    sounds.click = Juice.generateTone(0.1, 800)
    sounds.win = Juice.generateTone(0.3, 600, 800)
    sounds.money = Juice.generateTone(0.2, 400, 600)
    sounds.card = Juice.generateTone(0.1, 300)
end

function Juice.generateTone(duration, startFreq, endFreq)
    local sampleRate = 44100
    local samples = math.floor(duration * sampleRate)
    local soundData = love.sound.newSoundData(samples, sampleRate)

    for i = 0, samples - 1 do
        local t = i / samples
        local freq = startFreq + (endFreq or startFreq - startFreq) * t
        local wave = math.sin(2 * math.pi * freq * t) * 0.3
        soundData:setSample(i, wave)
    end

    return love.audio.newSource(soundData, "static")
end

function Juice.playSound(soundName)
    if sounds[soundName] then
        sounds[soundName]:stop()
        sounds[soundName]:play()
    end
end

-- BUTTON HOVER EFFECT (makes UI feel responsive)
function Juice.drawButton(text, x, y, w, h, isHovered, isPressed)
    local scale = 1
    local alpha = 1

    if isPressed then
        scale = 0.95
        alpha = 0.8
    elseif isHovered then
        scale = 1.05
        alpha = 1.1
    end

    love.graphics.push()
    love.graphics.translate(x + w/2, y + h/2)
    love.graphics.scale(scale)
    love.graphics.translate(-w/2, -h/2)

    -- Button background
    love.graphics.setColor(0.31, 0.8, 0.77, alpha)
    love.graphics.rectangle("fill", 0, 0, w, h)

    -- Text
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(text, 0, h/2 - 10, w, "center")

    love.graphics.pop()
end

-- CARD HOVER EFFECT (makes cards feel alive)
function Juice.drawCard(card, x, y, scale, isSelected, isHovered)
    scale = scale or 1
    local finalScale = scale
    local offsetY = 0

    if isSelected then
        finalScale = scale * 1.1
        offsetY = -5
    elseif isHovered then
        finalScale = scale * 1.05
        offsetY = -3
    end

    love.graphics.push()
    love.graphics.translate(x, y + offsetY)
    love.graphics.scale(finalScale)

    -- Card background with glow if selected
    if isSelected then
        love.graphics.setColor(1, 1, 0, 0.3)
        love.graphics.rectangle("fill", -2, -2, 44, 64)
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, 40, 60)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", 0, 0, 40, 60)

    -- Card content
    love.graphics.printf(card.symbol or "?", 5, 5, 30, "center")
    love.graphics.printf(card.name or "Card", 2, 35, 36, "center")

    love.graphics.pop()
end

-- PROGRESSIVE TEXT REVEAL (for story moments)
function Juice.revealText(text, timeElapsed, speed)
    speed = speed or 30 -- characters per second
    local charsToShow = math.floor(timeElapsed * speed)
    return string.sub(text, 1, charsToShow)
end

-- SCREEN EFFECTS
function Juice.applyScreenEffects()
    love.graphics.push()
    love.graphics.translate(shakeX, shakeY)
end

function Juice.removeScreenEffects()
    love.graphics.pop()

    -- Draw screen flash
    if flashAlpha > 0 then
        love.graphics.setColor(1, 1, 1, flashAlpha)
        love.graphics.rectangle("fill", 0, 0, 800, 600)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

-- DRAW ALL EFFECTS
function Juice.draw()
    for _, effect in ipairs(effects) do
        if effect.type == "money" then
            love.graphics.setColor(1, 0.84, 0, effect.alpha)
            love.graphics.printf("$" .. effect.amount, effect.x - 25, effect.y, 50, "center")

        elseif effect.type == "particle" then
            love.graphics.setColor(effect.color[1], effect.color[2], effect.color[3], effect.alpha)
            love.graphics.circle("fill", effect.x, effect.y, effect.size)
        end
    end

    love.graphics.setColor(1, 1, 1, 1) -- Reset color
end

-- QUICK WIN CELEBRATION
function Juice.celebrate(x, y)
    Juice.shake(8)
    Juice.flash(0.4)
    Juice.burst(x, y, {1, 1, 0}, 15)
    Juice.playSound("win")
end

-- MONEY EARNED EFFECT
function Juice.earnMoney(x, y, amount)
    Juice.showMoney(x, y, amount)
    Juice.burst(x, y, {0, 1, 0}, 8)
    Juice.playSound("money")
end

-- CARD PLAYED EFFECT
function Juice.playCard(x, y)
    Juice.burst(x, y, {0.31, 0.8, 0.77}, 5)
    Juice.playSound("card")
end

return Juice