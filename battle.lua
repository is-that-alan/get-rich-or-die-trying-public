local Battle = {}
local Card = require("card")
local Fortress = require("fortress")
local Music = require("music")

-- Battle state
local battleState = {
    playerFortress = nil,
    opponentFortress = nil,
    playerHand = {},
    opponentHand = {},
    playerTurn = true,
    selectedCard = nil,
    selectedCardIndex = nil,
    opponent = "",
    message = "",
    messageTimer = 0,

    -- Drag and drop state
    draggedCard = nil,
    draggedCardIndex = nil,
    dragStartX = 0,
    dragStartY = 0,
    dragOffsetX = 0,
    dragOffsetY = 0,
    isDragging = false,

    -- Drop zones
    dropZones = {
        fortress = {x = 100, y = 350, width = 200, height = 200, label = "建設基地"},
        attack = {x = 500, y = 50, width = 200, height = 200, label = "攻擊對手"},
        discard = {x = 650, y = 450, width = 100, height = 100, label = "棄牌"}
    },

    -- Visual effects
    hoveredZone = nil,
    cardScale = 1.0,
    handCardPositions = {}
}

function Battle.init(gameState, opponent)
    battleState.opponent = opponent or "茶餐廳阿姨"
    battleState.playerFortress = Fortress.new(200, 450, true)
    battleState.opponentFortress = Fortress.new(600, 150, false)
    battleState.playerTurn = true
    battleState.selectedCard = nil
    battleState.selectedCardIndex = nil
    battleState.message = ""
    battleState.messageTimer = 0

    -- Reset drag state
    battleState.isDragging = false
    battleState.draggedCard = nil
    battleState.draggedCardIndex = nil
    battleState.hoveredZone = nil
    battleState.cardScale = 1.0

    -- Initialize effect state
    battleState.nextCardReduction = 0
    battleState.costReduction = 0

    -- Initialize battle end state
    battleState.battleEnded = false
    battleState.battleResult = ""
    battleState.battleEndTimer = 0

    -- Deal cards
    Battle.dealCards(gameState.playerDeck)

    -- Initialize hand positions
    Battle.updateHandPositions()
end

function Battle.dealCards(deck)
    battleState.playerHand = {}
    battleState.opponentHand = {}

    -- Shuffle and deal 5 cards to each player
    local shuffled = {}
    for i, card in ipairs(deck) do
        shuffled[i] = card
    end

    -- Simple shuffle
    for i = #shuffled, 2, -1 do
        local j = math.random(i)
        shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
    end

    -- Deal 5 cards to player
    for i = 1, math.min(5, #shuffled) do
        table.insert(battleState.playerHand, shuffled[i])
    end

    -- Simple opponent hand (same cards for now)
    for i = 1, 5 do
        if shuffled[i] then
            table.insert(battleState.opponentHand, shuffled[i])
        end
    end
end

function Battle.update(dt)
    if battleState.messageTimer > 0 then
        battleState.messageTimer = battleState.messageTimer - dt
        if battleState.messageTimer <= 0 then
            battleState.message = ""
        end
    end

    -- Handle battle end timer
    if battleState.battleEnded and battleState.battleEndTimer > 0 then
        battleState.battleEndTimer = battleState.battleEndTimer - dt
        if battleState.battleEndTimer <= 0 then
            -- Return to progression after timer expires
            setGameScreen("progression")
        end
    end
end

function Battle.draw(gameState)
    -- Background
    love.graphics.setColor(0.1, 0.1, 0.18)
    love.graphics.rectangle("fill", 0, 0, 800, 600)

    -- Draw drop zones (when dragging)
    if battleState.isDragging then
        Battle.drawDropZones()
    end

    -- Title
    love.graphics.setColor(1, 0.42, 0.42)
    love.graphics.printf("對戰: " .. battleState.opponent, 0, 30, 800, "center")

    -- Turn indicator
    love.graphics.setColor(1, 0.9, 0.43)
    local turnText = battleState.playerTurn and "你嘅回合" or "對手回合"
    love.graphics.printf(turnText, 0, 60, 800, "center")

    -- Money display
    love.graphics.setColor(0, 1, 0)
    love.graphics.print("銀紙: $" .. gameState.playerMoney, 50, 30)

    -- Draw fortresses
    Fortress.draw(battleState.playerFortress)
    Fortress.draw(battleState.opponentFortress)

    -- Draw player hand
    Battle.drawHand()

    -- Draw dragged card on top
    if battleState.isDragging then
        Battle.drawDraggedCard()
    end

    -- End turn button
    love.graphics.setColor(0.2, 0.6, 0.86)
    love.graphics.rectangle("fill", 620, 485, 80, 30)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("結束回合", 620, 492, 80, "center")

    -- Battle end screen
    if battleState.battleEnded then
        -- Semi-transparent overlay
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, 800, 600)

        -- Result text
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(battleState.battleResult, 0, 250, 800, "center")

        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.printf("返回地圖中...", 0, 300, 800, "center")
    end

    -- Message
    if battleState.message ~= "" and not battleState.battleEnded then
        love.graphics.setColor(1, 0.9, 0.43)
        love.graphics.printf(battleState.message, 0, 400, 800, "center")
    end
end

function Battle.drawHand()
    -- Update hand positions if needed
    if #battleState.handCardPositions ~= #battleState.playerHand then
        Battle.updateHandPositions()
    end

    for i, card in ipairs(battleState.playerHand) do
        -- Skip drawing the dragged card in its original position
        if not (battleState.isDragging and i == battleState.draggedCardIndex) then
            local pos = battleState.handCardPositions[i]
            if pos then
                local isSelected = (i == battleState.selectedCardIndex)
                Card.drawCard(card, pos.x, pos.y, 0.8, isSelected)
            end
        end
    end
end

function Battle.drawDropZones()
    for zoneName, zone in pairs(battleState.dropZones) do
        -- Determine zone color based on card compatibility
        local color = Battle.getZoneColor(zoneName)
        local alpha = (battleState.hoveredZone == zoneName) and 0.6 or 0.3

        -- Draw zone background
        love.graphics.setColor(color[1], color[2], color[3], alpha)
        love.graphics.rectangle("fill", zone.x, zone.y, zone.width, zone.height)

        -- Draw zone border
        love.graphics.setColor(color[1], color[2], color[3], 0.8)
        love.graphics.setLineWidth(battleState.hoveredZone == zoneName and 3 or 1)
        love.graphics.rectangle("line", zone.x, zone.y, zone.width, zone.height)

        -- Draw zone label
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.printf(zone.label, zone.x, zone.y + zone.height/2 - 10, zone.width, "center")
    end
    love.graphics.setLineWidth(1)
end

function Battle.getZoneColor(zoneName)
    if not battleState.draggedCard then
        return {0.5, 0.5, 0.5} -- Gray default
    end

    local card = battleState.draggedCard

    if zoneName == "fortress" then
        if card.type == "build" then
            return {0.31, 0.8, 0.77} -- Teal for valid build
        else
            return {1, 0.3, 0.3} -- Red for invalid
        end
    elseif zoneName == "attack" then
        if card.type == "attack" or card.type == "defense" then
            return {1, 0.42, 0.42} -- Red for valid attack
        else
            return {1, 0.3, 0.3} -- Red for invalid
        end
    elseif zoneName == "discard" then
        return {0.6, 0.6, 0.6} -- Gray for discard (always valid)
    end

    return {0.5, 0.5, 0.5}
end

function Battle.drawDraggedCard()
    if not battleState.draggedCard then return end

    local mouseX, mouseY = love.mouse.getPosition()
    local cardX = mouseX - battleState.dragOffsetX
    local cardY = mouseY - battleState.dragOffsetY

    -- Draw with slight transparency and scaling
    love.graphics.push()
    love.graphics.translate(cardX + 60, cardY + 80) -- Center of card
    love.graphics.scale(battleState.cardScale)
    love.graphics.translate(-60, -80)

    -- Semi-transparent background
    love.graphics.setColor(1, 1, 1, 0.9)
    Card.drawCard(battleState.draggedCard, 0, 0, 0.8, true)

    love.graphics.pop()
end

function Battle.mousepressed(x, y, gameState)
    -- Don't allow interactions if battle has ended
    if battleState.battleEnded then
        return
    end

    -- Check end turn button
    if x >= 620 and x <= 700 and y >= 485 and y <= 515 then
        Music.playSFX("ui_click")
        Battle.endTurn()
        return
    end

    -- Start dragging cards
    if battleState.playerTurn and not battleState.isDragging then
        for i, card in ipairs(battleState.playerHand) do
            local cardPos = battleState.handCardPositions[i]
            if cardPos and Card.isPointInCard(x, y, cardPos.x, cardPos.y, 0.8) then
                battleState.isDragging = true
                battleState.draggedCard = card
                battleState.draggedCardIndex = i
                battleState.dragStartX = x
                battleState.dragStartY = y
                battleState.dragOffsetX = x - cardPos.x
                battleState.dragOffsetY = y - cardPos.y
                battleState.cardScale = 1.1 -- Slightly enlarge when dragging
                return
            end
        end
    end
end

function Battle.mousereleased(x, y, gameState)
    -- Don't allow interactions if battle has ended
    if battleState.battleEnded then
        return
    end

    if battleState.isDragging then
        -- Check if dropped in a valid zone
        local droppedZone = Battle.getDropZone(x, y)

        if droppedZone then
            Battle.handleCardDrop(droppedZone, gameState)
        end

        -- Reset drag state
        battleState.isDragging = false
        battleState.draggedCard = nil
        battleState.draggedCardIndex = nil
        battleState.cardScale = 1.0
        battleState.hoveredZone = nil
    end
end

function Battle.mousemoved(x, y, dx, dy)
    if battleState.isDragging then
        -- Update hovered drop zone
        battleState.hoveredZone = Battle.getDropZone(x, y)
    end
end

function Battle.playCard(card, handIndex, gameState)
    local success = false
    local message = ""

    if card.type == "build" then
        success = Fortress.build(battleState.playerFortress, card.effect)
        if success then
            Music.playSFX("card_play")
        end
        if not success then
            if not battleState.playerFortress.foundation and card.effect ~= "foundation" then
                message = "要先搭基礎！"
            elseif card.effect == "flag" and battleState.playerFortress.flags >= 3 then
                message = "旗夠了！"
            elseif card.effect == "shield" and battleState.playerFortress.flags < 3 then
                message = "要先插齊3支旗！"
            elseif card.effect == "shield" and battleState.playerFortress.shields >= 5 then
                message = "護盾夠了！"
            end
        end
    elseif card.type == "attack" then
        if battleState.playerFortress.isComplete then
            success = Fortress.takeDamage(battleState.opponentFortress, card.effect)
            if success then
                Music.playSFX("attack_hit")
            else
                message = "攻擊無效！"
            end
        else
            message = "要先完成基地！"
        end
    elseif card.type == "defense" then
        -- Defense cards can always be played (for now)
        success = true
        Music.playSFX("shield_block")
    end

    if success then
        -- Remove card from hand
        table.remove(battleState.playerHand, handIndex)

        -- Check win condition
        if Battle.checkWinCondition(gameState) then
            return
        end

        -- End turn after playing card
        Battle.endTurn()
    elseif message ~= "" then
        Battle.showMessage(message)
    end
end

function Battle.endTurn()
    battleState.playerTurn = not battleState.playerTurn

    if not battleState.playerTurn then
        -- Simple AI turn after delay
        love.timer.sleep(0.5)
        Battle.aiTurn()
    end
end

function Battle.aiTurn()
    -- Simple AI: play first valid card
    for i, card in ipairs(battleState.opponentHand) do
        local canPlay = false

        if card.type == "build" then
            canPlay = Fortress.canBuild(battleState.opponentFortress, card.effect)
            if canPlay then
                Fortress.build(battleState.opponentFortress, card.effect)
            end
        elseif card.type == "attack" then
            if battleState.opponentFortress.isComplete then
                canPlay = true
                Fortress.takeDamage(battleState.playerFortress, card.effect)
            end
        end

        if canPlay then
            table.remove(battleState.opponentHand, i)
            break
        end
    end

    Battle.endTurn()
end

function Battle.checkWinCondition(gameState)
    -- Only end battle if a fortress that was actually built gets destroyed
    if Fortress.wasDefeated(battleState.playerFortress) then
        print("Player fortress was defeated!")
        Battle.endBattle(false, gameState)
        return true
    elseif Fortress.wasDefeated(battleState.opponentFortress) then
        print("Opponent fortress was defeated!")
        Battle.endBattle(true, gameState)
        return true
    end

    -- Debug: Show fortress states
    print("Win check - Player foundation:", battleState.playerFortress.foundation, "flags:", battleState.playerFortress.flags, "shields:", battleState.playerFortress.shields)
    print("Win check - Opponent foundation:", battleState.opponentFortress.foundation, "flags:", battleState.opponentFortress.flags, "shields:", battleState.opponentFortress.shields)

    return false
end

function Battle.endBattle(playerWon, gameState)
    local result = playerWon and "你贏咗！" or "你輸咗！"
    local moneyChange = playerWon and 50 or -25

    gameState.playerMoney = gameState.playerMoney + moneyChange

    -- Set battle end state instead of immediately returning to map
    battleState.battleEnded = true
    battleState.battleResult = result .. " 金錢變化: " .. (moneyChange > 0 and "+" or "") .. moneyChange
    battleState.battleEndTimer = 3.0 -- Show result for 3 seconds

    Battle.showMessage(battleState.battleResult)
end

function Battle.getDropZone(x, y)
    for zoneName, zone in pairs(battleState.dropZones) do
        if x >= zone.x and x <= zone.x + zone.width and
           y >= zone.y and y <= zone.y + zone.height then
            return zoneName
        end
    end
    return nil
end

function Battle.handleCardDrop(zoneName, gameState)
    local card = battleState.draggedCard
    local cardIndex = battleState.draggedCardIndex

    if not card or not cardIndex then
        print("Error: No card or card index in handleCardDrop")
        return
    end

    local success = false
    local message = ""

    -- Add error checking
    pcall(function()
        if zoneName == "fortress" then
            success, message = Battle.handleBuildCard(card, gameState)
        elseif zoneName == "attack" then
            success, message = Battle.handleAttackCard(card, gameState)
        elseif zoneName == "discard" then
            success = true
            message = "棄掉 " .. (card.name or "unknown card")
        end

        if success then
            -- Show success message
            Battle.showMessage(message or "卡牌生效！")

            -- Process card effects safely
            pcall(function()
                Battle.processCardEffects(card, gameState)
            end)

            -- Remove card from hand
            if cardIndex <= #battleState.playerHand then
                table.remove(battleState.playerHand, cardIndex)
                Battle.updateHandPositions()
            end

            -- Check win condition
            if not Battle.checkWinCondition(gameState) then
                -- End turn after playing card (unless game ended)
                Battle.endTurn()
            end
        else
            Battle.showMessage(message or "Unknown error")
        end
    end)
end

function Battle.handleBuildCard(card, gameState)
    if card.type ~= "build" then
        return false, "只能用建設卡建造基地！"
    end

    print("Building with card:", card.name, "effect:", card.effect)
    print("Before build - Foundation:", battleState.playerFortress.foundation, "Flags:", battleState.playerFortress.flags, "Shields:", battleState.playerFortress.shields)

    local success = Fortress.build(battleState.playerFortress, card.effect)

    print("After build - Foundation:", battleState.playerFortress.foundation, "Flags:", battleState.playerFortress.flags, "Shields:", battleState.playerFortress.shields)
    print("Build success:", success)

    if not success then
        return false, Battle.getBuildErrorMessage(card)
    end

    return true, "建造 " .. card.name
end

function Battle.handleAttackCard(card, gameState)
    if card.type == "attack" then
        if not battleState.playerFortress.isComplete then
            return false, "要先完成基地！"
        end

        local success = Battle.processAttackCard(card)
        if not success then
            return false, "攻擊無效！"
        end

        return true, "攻擊成功！"

    elseif card.type == "defense" then
        return true, "使用防禦卡！"

    elseif card.type == "utility" then
        return true, "使用工具卡！"

    elseif card.type == "combo" then
        if not battleState.playerFortress.isComplete then
            return false, "要先完成基地！"
        end
        return true, "發動組合技！"

    else
        return false, "無法在此使用該卡！"
    end
end

function Battle.processAttackCard(card)
    local damage = card.damage or 1

    print("Attacking with card:", card.name, "effect:", card.effect, "damage:", damage)
    print("Before attack - Opponent Foundation:", battleState.opponentFortress.foundation, "Flags:", battleState.opponentFortress.flags, "Shields:", battleState.opponentFortress.shields)

    local success = false

    if card.effect == "destroy_shield" then
        for i = 1, damage do
            if battleState.opponentFortress.shields > 0 then
                battleState.opponentFortress.shields = battleState.opponentFortress.shields - 1
                success = true
            else
                break
            end
        end

    elseif card.effect == "destroy_flag" then
        if battleState.opponentFortress.flags > 0 then
            battleState.opponentFortress.flags = battleState.opponentFortress.flags - 1
            success = true
        end

    elseif card.effect == "destroy_all_shields" then
        if battleState.opponentFortress.shields > 0 then
            battleState.opponentFortress.shields = 0
            success = true
        end

    elseif card.effect == "destroy_any" then
        success = Fortress.takeDamage(battleState.opponentFortress, "destroy_any")

    elseif card.effect == "double_attack" then
        Battle.processAttackCard({effect = "destroy_any", damage = 1})
        Battle.processAttackCard({effect = "destroy_any", damage = 1})
        success = true

    elseif card.effect == "chain_attack" then
        local destroyed = 0
        while Fortress.takeDamage(battleState.opponentFortress, "destroy_any") do
            destroyed = destroyed + 1
            if destroyed >= 3 then break end -- Prevent infinite loops
        end
        success = destroyed > 0

    elseif card.effect == "ultimate_attack" then
        battleState.opponentFortress.foundation = false
        battleState.opponentFortress.flags = 0
        battleState.opponentFortress.shields = 0
        success = true
    end

    print("After attack - Opponent Foundation:", battleState.opponentFortress.foundation, "Flags:", battleState.opponentFortress.flags, "Shields:", battleState.opponentFortress.shields)
    print("Attack success:", success)

    return success
end

function Battle.processCardEffects(card, gameState)
    if not card then return end

    -- Process special effects safely
    if card.special == "draw_card" then
        Battle.drawCards(1)
        Battle.showMessage("抽了一張卡！")

    elseif card.special == "draw_cards" then
        local amount = card.specialValue or 2
        Battle.drawCards(amount)
        Battle.showMessage("抽了" .. amount .. "張卡！")

    elseif card.special == "gain_money" then
        local amount = card.specialValue or 10
        if gameState and gameState.playerMoney then
            gameState.playerMoney = gameState.playerMoney + amount
            Battle.showMessage("獲得 $" .. amount .. "！")
        end

    elseif card.special == "steal_money" then
        local amount = card.specialValue or 5
        if gameState and gameState.playerMoney then
            gameState.playerMoney = gameState.playerMoney + amount
            Battle.showMessage("偷了 $" .. amount .. "！")
        end

    elseif card.special == "counter_attack" then
        pcall(function()
            Battle.processAttackCard({effect = "destroy_any", damage = 1})
            Battle.showMessage("反擊成功！")
        end)

    elseif card.special == "reduce_cost" then
        battleState.nextCardReduction = (battleState.nextCardReduction or 0) + 1
        Battle.showMessage("下張卡減1費用！")

    elseif card.special == "reduce_all_costs" then
        battleState.costReduction = (battleState.costReduction or 0) + 1
        Battle.showMessage("本回合所有卡-1費用！")

    elseif card.special == "rebuild_fortress" then
        if battleState.playerFortress then
            battleState.playerFortress.foundation = true
            battleState.playerFortress.flags = 3
            battleState.playerFortress.shields = 5
            Fortress.checkComplete(battleState.playerFortress)
            Battle.showMessage("基地重建完成！")
        end
    end
end

function Battle.drawCards(amount)
    if not amount or amount <= 0 then return end

    -- Simple card drawing - add random cards to hand
    local availableCards = {}

    -- Safely build available cards list
    for cardId, cardData in pairs(Card.database) do
        if cardData and cardData.name then
            table.insert(availableCards, cardData)
        end
    end

    if #availableCards == 0 then
        print("Warning: No available cards to draw")
        return
    end

    for i = 1, amount do
        if #battleState.playerHand < 8 then -- Hand size limit
            local randomCard = availableCards[math.random(#availableCards)]
            if randomCard then
                table.insert(battleState.playerHand, randomCard)
            end
        end
    end

    Battle.updateHandPositions()
end

function Battle.getBuildErrorMessage(card)
    if not battleState.playerFortress.foundation and card.effect ~= "foundation" then
        return "要先搭基礎！"
    elseif card.effect == "flag" and battleState.playerFortress.flags >= 3 then
        return "旗夠了！"
    elseif card.effect == "shield" and battleState.playerFortress.flags < 3 then
        return "要先插齊3支旗！"
    elseif card.effect == "shield" and battleState.playerFortress.shields >= 5 then
        return "護盾夠了！"
    else
        return "無法建造！"
    end
end

function Battle.updateHandPositions()
    battleState.handCardPositions = {}
    local handSize = #battleState.playerHand
    local startX = 400 - (handSize * 65) -- Center the hand

    for i = 1, handSize do
        battleState.handCardPositions[i] = {
            x = startX + ((i-1) * 130),
            y = 450
        }
    end
end

-- Fallback function for old card playing system
function Battle.playCard(card, handIndex, gameState)
    print("Warning: Using deprecated playCard function")
    -- Simulate drag and drop
    battleState.draggedCard = card
    battleState.draggedCardIndex = handIndex

    -- Try to play as build card first, then attack
    if card.type == "build" then
        Battle.handleCardDrop("fortress", gameState)
    else
        Battle.handleCardDrop("attack", gameState)
    end
end

function Battle.showMessage(text)
    battleState.message = text or ""
    battleState.messageTimer = 2.0
end

return Battle