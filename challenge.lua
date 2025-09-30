-- Challenge System (Legacy/Deprecated - replaced by mahjong_battle.lua)
local Challenge = {}
local Card = require("card")
local Fortress = require("fortress")

-- Challenge state
local challengeState = {
    fortress = nil,
    hand = {},
    deck = {},
    discardPile = {},

    -- Challenge parameters
    targetMoney = 100,
    currentMoney = 0,
    handsRemaining = 5,
    maxHands = 5,

    -- Game state
    selectedCards = {},
    challengeComplete = false,
    challengeFailed = false,

    -- Visual effects
    moneyAnimation = 0,
    lastEarned = 0,

    -- Challenge info
    challengeName = "基本挑戰",
    challengeDescription = "賺到 $100 完成挑戰"
}

function Challenge.init(gameState, challengeData)
    challengeData = challengeData or {}

    -- Set challenge parameters
    challengeState.targetMoney = challengeData.target or 100
    challengeState.maxHands = challengeData.hands or 5
    challengeState.handsRemaining = challengeState.maxHands
    challengeState.challengeName = challengeData.name or "基本挑戰"
    challengeState.challengeDescription = challengeData.description or ("賺到 $" .. challengeState.targetMoney .. " 完成挑戰")

    -- Reset state
    challengeState.currentMoney = 0
    challengeState.challengeComplete = false
    challengeState.challengeFailed = false
    challengeState.selectedCards = {}
    challengeState.moneyAnimation = 0
    challengeState.lastEarned = 0

    -- Initialize fortress
    challengeState.fortress = Fortress.new(400, 200, true)

    -- Set up deck
    challengeState.deck = {}
    for i, card in ipairs(gameState.playerDeck) do
        table.insert(challengeState.deck, card)
    end
    challengeState.discardPile = {}

    -- Deal initial hand
    Challenge.dealHand()
end

function Challenge.dealHand()
    challengeState.hand = {}

    -- Draw 8 cards
    for i = 1, 8 do
        if #challengeState.deck > 0 then
            local card = table.remove(challengeState.deck, math.random(#challengeState.deck))
            table.insert(challengeState.hand, card)
        elseif #challengeState.discardPile > 0 then
            -- Reshuffle discard pile
            for j, discardCard in ipairs(challengeState.discardPile) do
                table.insert(challengeState.deck, discardCard)
            end
            challengeState.discardPile = {}

            -- Draw from reshuffled deck
            if #challengeState.deck > 0 then
                local card = table.remove(challengeState.deck, math.random(#challengeState.deck))
                table.insert(challengeState.hand, card)
            end
        end
    end
end

function Challenge.update(dt)
    -- Update money animation
    if challengeState.moneyAnimation > 0 then
        challengeState.moneyAnimation = challengeState.moneyAnimation - dt
    end

    -- Check win/lose conditions
    if challengeState.currentMoney >= challengeState.targetMoney and not challengeState.challengeComplete then
        challengeState.challengeComplete = true
    elseif challengeState.handsRemaining <= 0 and challengeState.currentMoney < challengeState.targetMoney and not challengeState.challengeFailed then
        challengeState.challengeFailed = true
    end
end

function Challenge.draw(gameState)
    -- Background
    love.graphics.setColor(0.1, 0.1, 0.18)
    love.graphics.rectangle("fill", 0, 0, 800, 600)

    -- Challenge info
    Challenge.drawChallengeInfo()

    -- Draw fortress
    Fortress.draw(challengeState.fortress)

    -- Draw hand
    Challenge.drawHand()

    -- Draw play area
    Challenge.drawPlayArea()

    -- Draw completion screen
    if challengeState.challengeComplete or challengeState.challengeFailed then
        Challenge.drawCompletionScreen(gameState)
    end
end

function Challenge.drawChallengeInfo()
    -- Challenge name
    love.graphics.setColor(1, 0.42, 0.42)
    love.graphics.printf(challengeState.challengeName, 0, 20, 800, "center")

    -- Progress bar background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 100, 50, 600, 20)

    -- Progress bar fill
    local progress = math.min(challengeState.currentMoney / challengeState.targetMoney, 1)
    love.graphics.setColor(0.31, 0.8, 0.77)
    love.graphics.rectangle("fill", 100, 50, 600 * progress, 20)

    -- Money display
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("$" .. challengeState.currentMoney .. " / $" .. challengeState.targetMoney, 100, 52, 600, "center")

    -- Hands remaining
    love.graphics.setColor(1, 0.9, 0.43)
    love.graphics.printf("剩餘回合: " .. challengeState.handsRemaining, 50, 80, 200, "left")

    -- Money animation
    if challengeState.moneyAnimation > 0 and challengeState.lastEarned > 0 then
        love.graphics.setColor(0, 1, 0, challengeState.moneyAnimation)
        love.graphics.printf("+$" .. challengeState.lastEarned, 0, 100, 800, "center")
    end
end

function Challenge.drawHand()
    local startX = 50
    local startY = 450
    local cardSpacing = 90

    for i, card in ipairs(challengeState.hand) do
        local x = startX + ((i-1) * cardSpacing)
        local y = startY

        -- Highlight selected cards
        local isSelected = false
        for j, selectedIndex in ipairs(challengeState.selectedCards) do
            if selectedIndex == i then
                isSelected = true
                y = y - 20 -- Lift selected cards
                break
            end
        end

        Card.drawCard(card, x, y, 0.7, isSelected)
    end
end

function Challenge.drawPlayArea()
    -- Play button
    local playEnabled = #challengeState.selectedCards > 0 and challengeState.handsRemaining > 0
    local buttonColor = playEnabled and {0.27, 0.8, 0.36} or {0.5, 0.5, 0.5}

    love.graphics.setColor(buttonColor[1], buttonColor[2], buttonColor[3])
    love.graphics.rectangle("fill", 350, 350, 100, 40)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("出牌", 350, 360, 100, "center")

    -- Discard button
    love.graphics.setColor(0.8, 0.3, 0.3)
    love.graphics.rectangle("fill", 470, 350, 100, 40)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("棄牌", 470, 360, 100, "center")

    -- Selected cards info
    if #challengeState.selectedCards > 0 then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("已選: " .. #challengeState.selectedCards .. " 張牌", 300, 320, 200, "center")

        -- Show potential earnings
        local earnings = Challenge.calculateEarnings(challengeState.selectedCards)
        love.graphics.setColor(0, 1, 0)
        love.graphics.printf("預計收入: $" .. earnings, 300, 300, 200, "center")
    end
end

function Challenge.drawCompletionScreen(gameState)
    -- Overlay
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, 800, 600)

    -- Result text
    local resultText = challengeState.challengeComplete and "挑戰成功！" or "挑戰失敗！"
    local resultColor = challengeState.challengeComplete and {0, 1, 0} or {1, 0, 0}

    love.graphics.setColor(resultColor[1], resultColor[2], resultColor[3])
    love.graphics.printf(resultText, 0, 250, 800, "center")

    -- Money earned
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("總收入: $" .. challengeState.currentMoney, 0, 300, 800, "center")

    -- Continue button
    love.graphics.setColor(0.2, 0.6, 0.86)
    love.graphics.rectangle("fill", 350, 400, 100, 40)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("繼續", 350, 410, 100, "center")
end

function Challenge.mousepressed(x, y, gameState)
    if challengeState.challengeComplete or challengeState.challengeFailed then
        -- Continue button
        if x >= 350 and x <= 450 and y >= 400 and y <= 440 then
            Challenge.endChallenge(gameState)
        end
        return
    end

    -- Hand card selection
    local startX = 50
    local startY = 450
    local cardSpacing = 90

    for i, card in ipairs(challengeState.hand) do
        local cardX = startX + ((i-1) * cardSpacing)
        local cardY = startY

        if Card.isPointInCard(x, y, cardX, cardY, 0.7) then
            Challenge.toggleCardSelection(i)
            return
        end
    end

    -- Play button
    if x >= 350 and x <= 450 and y >= 350 and y <= 390 then
        Challenge.playSelectedCards()
        return
    end

    -- Discard button
    if x >= 470 and x <= 570 and y >= 350 and y <= 390 then
        Challenge.discardSelectedCards()
        return
    end
end

function Challenge.toggleCardSelection(cardIndex)
    -- Check if card is already selected
    for i, selectedIndex in ipairs(challengeState.selectedCards) do
        if selectedIndex == cardIndex then
            table.remove(challengeState.selectedCards, i)
            return
        end
    end

    -- Add to selection (max 5 cards)
    if #challengeState.selectedCards < 5 then
        table.insert(challengeState.selectedCards, cardIndex)
    end
end

function Challenge.playSelectedCards()
    if #challengeState.selectedCards == 0 or challengeState.handsRemaining <= 0 then
        return
    end

    -- Calculate earnings
    local earnings = Challenge.calculateEarnings(challengeState.selectedCards)
    challengeState.currentMoney = challengeState.currentMoney + earnings
    challengeState.lastEarned = earnings
    challengeState.moneyAnimation = 2.0

    -- Process card effects
    Challenge.processSelectedCards()

    -- Remove played cards and discard
    local playedCards = {}
    for i, selectedIndex in ipairs(challengeState.selectedCards) do
        table.insert(playedCards, challengeState.hand[selectedIndex])
    end

    -- Remove from hand (in reverse order to maintain indices)
    table.sort(challengeState.selectedCards, function(a, b) return a > b end)
    for i, selectedIndex in ipairs(challengeState.selectedCards) do
        local card = table.remove(challengeState.hand, selectedIndex)
        table.insert(challengeState.discardPile, card)
    end

    challengeState.selectedCards = {}
    challengeState.handsRemaining = challengeState.handsRemaining - 1

    -- Refill hand
    Challenge.refillHand()
end

function Challenge.discardSelectedCards()
    if #challengeState.selectedCards == 0 then
        return
    end

    -- Remove selected cards (in reverse order)
    table.sort(challengeState.selectedCards, function(a, b) return a > b end)
    for i, selectedIndex in ipairs(challengeState.selectedCards) do
        local card = table.remove(challengeState.hand, selectedIndex)
        table.insert(challengeState.discardPile, card)
    end

    challengeState.selectedCards = {}

    -- Refill hand
    Challenge.refillHand()
end

function Challenge.refillHand()
    -- Draw cards to fill hand back to 8
    while #challengeState.hand < 8 do
        if #challengeState.deck > 0 then
            local card = table.remove(challengeState.deck, math.random(#challengeState.deck))
            table.insert(challengeState.hand, card)
        else
            break
        end
    end
end

function Challenge.calculateEarnings(selectedIndices)
    local earnings = 0
    local buildCards = 0
    local moneyCards = 0
    local multiplierCards = 0

    -- Analyze selected cards
    for i, cardIndex in ipairs(selectedIndices) do
        local card = challengeState.hand[cardIndex]
        if card then
            if card.type == "build" then
                buildCards = buildCards + 1
                earnings = earnings + (card.cost or 1) * 5 -- Base earnings
            elseif card.type == "utility" and card.effect == "gain_money" then
                moneyCards = moneyCards + 1
                earnings = earnings + (card.specialValue or 10)
            elseif card.special == "gain_money" then
                earnings = earnings + (card.specialValue or 5)
            end
        end
    end

    -- Combo bonuses
    if buildCards >= 3 then
        earnings = earnings * 1.5 -- 50% bonus for 3+ build cards
    end

    if #selectedIndices == 5 then
        earnings = earnings * 1.2 -- 20% bonus for full hand
    end

    -- Fortress completion bonus
    if challengeState.fortress.isComplete then
        earnings = earnings * 2 -- Double money when fortress is complete
    end

    return math.floor(earnings)
end

function Challenge.processSelectedCards()
    -- Apply card effects to fortress
    for i, cardIndex in ipairs(challengeState.selectedCards) do
        local card = challengeState.hand[cardIndex]
        if card and card.type == "build" then
            Fortress.build(challengeState.fortress, card.effect)
        end
    end
end

function Challenge.endChallenge(gameState)
    -- Award money to player
    if challengeState.challengeComplete then
        gameState.playerMoney = gameState.playerMoney + challengeState.currentMoney
    end

    -- Return to progression
    setGameScreen("progression")
end

return Challenge