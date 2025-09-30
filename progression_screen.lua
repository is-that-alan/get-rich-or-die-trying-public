-- Progression Screen - Card-based progression system
-- Replaces the map navigation with card choices

local ProgressionScreen = {}
local ProgressionCards = require("progression_cards")
local HKMemeCards = require("hk_meme_cards")
local HKRelics = require("hk_relics")
local Music = require("music")

-- Screen state
local currentChoices = {}
local selectedCard = nil
local cardAnimations = {}

-- Visual constants
local CARD_WIDTH = 200
local CARD_HEIGHT = 280
local CARD_MARGIN = 20

function ProgressionScreen.init(gameState)
    -- Check if we should trigger a level transition scene
    local sceneToTrigger = ProgressionCards.checkLevelTransition(gameState)
    if sceneToTrigger then
        ProgressionCards.triggerStoryScene(gameState, sceneToTrigger)
        return
    end

    -- Only generate new choices if they don't already exist in game state
    if not gameState.currentProgressionChoices then
        gameState.currentProgressionChoices = ProgressionCards.generateProgression(gameState)
        print("🎯 Generated new progression choices:", #gameState.currentProgressionChoices)
    else
        print("🎯 Using existing progression choices:", #gameState.currentProgressionChoices)
    end

    currentChoices = gameState.currentProgressionChoices
    selectedCard = nil
    cardAnimations = {}

    -- Initialize card animations
    for i = 1, #currentChoices do
        cardAnimations[i] = {
            scale = 1,
            targetScale = 1,
            glow = 0
        }
    end
end

function ProgressionScreen.update(dt)
    -- Update card animations
    for i, anim in ipairs(cardAnimations) do
        -- Smooth scaling
        local scaleDiff = anim.targetScale - anim.scale
        anim.scale = anim.scale + scaleDiff * 5 * dt

        -- Glow animation
        if selectedCard == i then
            anim.glow = math.min(1, anim.glow + 3 * dt)
        else
            anim.glow = math.max(0, anim.glow - 3 * dt)
        end
    end
end

function ProgressionScreen.draw(gameState)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    -- Background
    love.graphics.setColor(0.1, 0.15, 0.2, 1)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)


    -- Subtitle with run info
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    local runInfo = "第 " .. (gameState.runDepth or 1) .. " 層 | 銀紙: $" .. (gameState.playerMoney or 100)
    love.graphics.printf(runInfo, 0, 90, screenWidth, "center")

    -- Draw cards
    local totalWidth = #currentChoices * CARD_WIDTH + (#currentChoices - 1) * CARD_MARGIN
    local startX = (screenWidth - totalWidth) / 2
    local cardY = 150

    for i, choice in ipairs(currentChoices) do
        local cardX = startX + (i - 1) * (CARD_WIDTH + CARD_MARGIN)
        local anim = cardAnimations[i]

        -- Apply scaling and positioning
        love.graphics.push()
        love.graphics.translate(cardX + CARD_WIDTH/2, cardY + CARD_HEIGHT/2)
        love.graphics.scale(anim.scale, anim.scale)
        love.graphics.translate(-CARD_WIDTH/2, -CARD_HEIGHT/2)

        -- Draw card glow if selected
        if anim.glow > 0 then
            love.graphics.setColor(1, 0.8, 0.3, anim.glow * 0.5)
            love.graphics.rectangle("fill", -5, -5, CARD_WIDTH + 10, CARD_HEIGHT + 10, 10)
        end

        -- Draw card background
        local isHovered = selectedCard == i
        local isDisabled = choice.type == "combat" and gameState and gameState.currentSceneBattleCompleted

        if isDisabled then
            love.graphics.setColor(0.15, 0.15, 0.15, 0.5)
        elseif isHovered then
            love.graphics.setColor(0.3, 0.4, 0.5, 1)
        else
            love.graphics.setColor(0.2, 0.25, 0.3, 1)
        end
        love.graphics.rectangle("fill", 0, 0, CARD_WIDTH, CARD_HEIGHT, 10)

        -- Draw card border
        love.graphics.setColor(0.6, 0.7, 0.8, 1)
        love.graphics.rectangle("line", 0, 0, CARD_WIDTH, CARD_HEIGHT, 10)

        -- Card type indicator
        local typeColor = ProgressionScreen.getTypeColor(choice.type)
        love.graphics.setColor(typeColor[1], typeColor[2], typeColor[3], 1)
        love.graphics.rectangle("fill", 0, 0, CARD_WIDTH, 30, 10)

        -- Draw card content
        local isDisabled = choice.type == "combat" and gameState and gameState.currentSceneBattleCompleted
        local contentAlpha = isDisabled and 0.3 or 1.0

        love.graphics.setColor(1, 1, 1, contentAlpha)

        -- Title
        local title = choice.title or "未知"
        if isDisabled then
            title = title .. " (已完成)"
        end
        love.graphics.printf(title, 10, 40, CARD_WIDTH - 20, "center")

        -- Description
        love.graphics.setColor(0.9, 0.9, 0.9, contentAlpha)
        love.graphics.printf(choice.description or "", 10, 80, CARD_WIDTH - 20, "left")

        -- Subtitle
        if choice.subtitle then
            love.graphics.setColor(0.7, 0.8, 0.9, contentAlpha)
            love.graphics.printf(choice.subtitle, 10, CARD_HEIGHT - 60, CARD_WIDTH - 20, "center")
        end

        -- Reward info
        if choice.data and choice.data.reward then
            local reward = choice.data.reward
            love.graphics.setColor(0.3, 0.8, 0.3, contentAlpha)
            local rewardText = ""
            if reward.money then rewardText = rewardText .. "$" .. reward.money end
            if reward.xp then rewardText = rewardText .. " +" .. reward.xp .. "XP" end
            if reward.relic then rewardText = rewardText .. " 聖物" end
            if reward.memeCard then rewardText = rewardText .. " 天下太平卡" end

            love.graphics.printf(rewardText, 10, CARD_HEIGHT - 30, CARD_WIDTH - 20, "center")
        end

        love.graphics.pop()
    end

    -- Instructions
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.printf("點擊選擇你嘅下一步", 0, screenHeight - 50, screenWidth, "center")

end

function ProgressionScreen.getTypeColor(cardType)
    if cardType == "combat" then
        return {0.8, 0.3, 0.3}  -- Red
    elseif cardType == "shop" then
        return {0.3, 0.7, 0.3}  -- Green
    elseif cardType == "event" then
        return {0.7, 0.5, 0.2}  -- Orange
    elseif cardType == "advance" then
        return {0.3, 0.3, 0.8}  -- Blue
    else
        return {0.5, 0.5, 0.5}  -- Gray
    end
end


function ProgressionScreen.mousepressed(x, y, button, gameState)
    if button ~= 1 then return end

    local screenWidth = love.graphics.getWidth()
    local totalWidth = #currentChoices * CARD_WIDTH + (#currentChoices - 1) * CARD_MARGIN
    local startX = (screenWidth - totalWidth) / 2
    local cardY = 150

    -- Check card clicks
    for i, choice in ipairs(currentChoices) do
        local cardX = startX + (i - 1) * (CARD_WIDTH + CARD_MARGIN)

        if x >= cardX and x <= cardX + CARD_WIDTH and
           y >= cardY and y <= cardY + CARD_HEIGHT then

            -- Check if card is disabled (completed battle)
            local isDisabled = choice.type == "combat" and gameState.currentSceneBattleCompleted
            if isDisabled then
                print("戰鬥已完成，無法重複挑戰")
                return false
            end

            -- Play click sound
            Music.playSFX("ui_click")

            -- Execute choice
            local result = ProgressionCards.executeChoice(gameState, choice)
            print("選擇結果: " .. result)

            -- Only clear progression choices for combat and advance (not shop or events)
            if choice.type == ProgressionCards.CARD_TYPES.COMBAT or choice.type == "advance" then
                gameState.currentProgressionChoices = nil
                print("🎯 Cleared progression choices - new ones will be generated")
            end

            return true
        end
    end

    return false
end

function ProgressionScreen.mousemoved(x, y)
    local screenWidth = love.graphics.getWidth()
    local totalWidth = #currentChoices * CARD_WIDTH + (#currentChoices - 1) * CARD_MARGIN
    local startX = (screenWidth - totalWidth) / 2
    local cardY = 150

    selectedCard = nil

    -- Check card hover
    for i, choice in ipairs(currentChoices) do
        local cardX = startX + (i - 1) * (CARD_WIDTH + CARD_MARGIN)

        if x >= cardX and x <= cardX + CARD_WIDTH and
           y >= cardY and y <= cardY + CARD_HEIGHT then
            selectedCard = i
            cardAnimations[i].targetScale = 1.05
        else
            cardAnimations[i].targetScale = 1.0
        end
    end
end

return ProgressionScreen