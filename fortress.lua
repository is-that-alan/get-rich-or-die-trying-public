local Fortress = {}

function Fortress.new(x, y, isPlayer)
    local fortress = {
        x = x,
        y = y,
        isPlayer = isPlayer or true,

    
        foundation = false,
        flags = 0,          -- 0-3 flags
        shields = 0,        -- 0-5 shields
        isComplete = false,

        -- Track what has been built (for destruction logic)
        hadFoundation = false,
        maxFlags = 0,
        maxShields = 0
    }

    return fortress
end

function Fortress.canBuild(fortress, cardEffect)
    if cardEffect == "foundation" then
        return not fortress.foundation
    elseif cardEffect == "flag" then
        return fortress.foundation and fortress.flags < 3
    elseif cardEffect == "shield" then
        return fortress.foundation and fortress.flags == 3 and fortress.shields < 5
    end
    return false
end

function Fortress.build(fortress, cardEffect)
    if not Fortress.canBuild(fortress, cardEffect) then
        return false
    end

    if cardEffect == "foundation" then
        fortress.foundation = true
        fortress.hadFoundation = true
    elseif cardEffect == "flag" then
        fortress.flags = fortress.flags + 1
        fortress.maxFlags = math.max(fortress.maxFlags, fortress.flags)
    elseif cardEffect == "shield" then
        fortress.shields = fortress.shields + 1
        fortress.maxShields = math.max(fortress.maxShields, fortress.shields)
    end

    Fortress.checkComplete(fortress)
    return true
end

function Fortress.takeDamage(fortress, attackType)
    local damaged = false

    if attackType == "destroy_shield" then
        if fortress.shields > 0 then
            fortress.shields = fortress.shields - 1
            damaged = true
        end
    elseif attackType == "destroy_flag" then
        if fortress.flags > 0 then
            fortress.flags = fortress.flags - 1
            damaged = true
        end
    elseif attackType == "destroy_any" then
        if fortress.shields > 0 then
            fortress.shields = fortress.shields - 1
            damaged = true
        elseif fortress.flags > 0 then
            fortress.flags = fortress.flags - 1
            damaged = true
        elseif fortress.foundation then
            fortress.foundation = false
            damaged = true
        end
    end

    return damaged
end

function Fortress.checkComplete(fortress)
    fortress.isComplete = fortress.foundation and fortress.flags == 3 and fortress.shields == 5
end

function Fortress.isDestroyed(fortress)
    -- A fortress is destroyed only if:
    -- 1. It had a foundation at some point AND now has nothing, OR
    -- 2. It had flags/shields built AND now has nothing
    local hadSomething = fortress.hadFoundation or fortress.maxFlags > 0 or fortress.maxShields > 0
    local hasNothing = not fortress.foundation and fortress.flags == 0 and fortress.shields == 0

    return hadSomething and hasNothing
end

-- Alternative: Check if fortress was completed and then destroyed
function Fortress.wasDefeated(fortress)
    -- Only consider a fortress defeated if it was actually built up and then destroyed
    return fortress.hadFoundation and not fortress.foundation and fortress.flags == 0 and fortress.shields == 0
end

function Fortress.getStatusText(fortress)
    if Fortress.isDestroyed(fortress) then
        return "基地倒塌！"
    elseif fortress.isComplete then
        return "基地完成！可以攻擊"
    elseif not fortress.foundation then
        return "需要：基地基礎"
    elseif fortress.flags < 3 then
        return "需要：" .. (3 - fortress.flags) .. " 支旗"
    elseif fortress.shields < 5 then
        return "需要：" .. (5 - fortress.shields) .. " 個護盾"
    else
        return "準備中..."
    end
end

function Fortress.draw(fortress)
    local x, y = fortress.x, fortress.y

    -- Base fortress area with better visibility
    love.graphics.setColor(0.17, 0.24, 0.31, 0.8) -- More opaque
    love.graphics.rectangle("fill", x - 100, y - 75, 200, 150)
    love.graphics.setColor(0.2, 0.27, 0.34)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x - 100, y - 75, 200, 150)
    love.graphics.setLineWidth(1)

    -- Title with better contrast
    local titleColor = fortress.isPlayer and { 0.31, 0.8, 0.77 } or { 1, 0.42, 0.42 }
    love.graphics.setColor(titleColor[1], titleColor[2], titleColor[3])
    local title = fortress.isPlayer and "你嘅基地" or "對手基地"
    love.graphics.printf(title, x - 100, y - 100, 200, "center")

    local yOffset = -50

    if fortress.foundation then
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", x - 60, y + yOffset - 5, 120, 20)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("天下太平", x - 60, y + yOffset, 120, "center")
        yOffset = yOffset + 30
    else
        -- Show placeholder for foundation
        love.graphics.setColor(0.5, 0.5, 0.5, 0.3)
        love.graphics.rectangle("fill", x - 60, y + yOffset - 5, 120, 20)
        love.graphics.setColor(0.7, 0.7, 0.7)
        love.graphics.printf("需要基礎", x - 60, y + yOffset, 120, "center")
        yOffset = yOffset + 30
    end

    -- Flags with placeholders
    love.graphics.setColor(1, 1, 1)
    local flagEmojis = { "🚩", "🏴", "🏳️" }
    for i = 1, 3 do
        local flagX = x - 45 + ((i - 1) * 45)
        if i <= fortress.flags then
            -- Active flag
            local emoji = flagEmojis[i] or "🚩"
            love.graphics.printf(emoji, flagX - 15, y + yOffset, 30, "center")
        else
            -- Placeholder flag
            love.graphics.setColor(0.3, 0.3, 0.3, 0.5)
            love.graphics.circle("fill", flagX, y + yOffset + 10, 8)
            love.graphics.setColor(1, 1, 1)
        end
    end
    yOffset = yOffset + 35

    -- Shields with placeholders
    for i = 1, 5 do
        local shieldX = x - 60 + ((i - 1) * 30)
        if i <= fortress.shields then
            -- Active shield
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("🛡️", shieldX - 10, y + yOffset, 20, "center")
        else
            -- Placeholder shield
            love.graphics.setColor(0.3, 0.3, 0.3, 0.3)
            love.graphics.circle("line", shieldX, y + yOffset + 8, 6)
        end
    end

    -- Status text with background
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", x - 95, y + 55, 190, 20)
    love.graphics.setColor(1, 1, 1)
    local status = Fortress.getStatusText(fortress)
    love.graphics.printf(status, x - 95, y + 60, 190, "center")

    -- Progress indicator
    local progress = 0
    if fortress.foundation then progress = progress + 1 end
    progress = progress + fortress.flags + fortress.shields
    local maxProgress = 1 + 3 + 5 -- foundation + 3 flags + 5 shields

    -- Progress bar
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", x - 80, y + 80, 160, 8)
    love.graphics.setColor(titleColor[1], titleColor[2], titleColor[3])
    love.graphics.rectangle("fill", x - 80, y + 80, (160 * progress / maxProgress), 8)
end

return Fortress
