-- Mahjong State Management Module
-- Handles game state, turn management, and state transitions

local MahjongDeck = require("mahjong_deck")
local MahjongTiles = require("mahjong_tiles")
local MahjongLogic = require("mahjong_logic")
local WeatherSystem = require("weather_system")
local MahjongUI = require("mahjong_ui")
local MahjongState = {}

-- Game state constants
MahjongState.PHASES = {
    SETUP = "setup",
    PLAYING = "playing",
    WIN_CHECK = "win_check",
    GAME_OVER = "game_over",
    PAUSED = "paused"
}

MahjongState.ACTIONS = {
    DRAW = "draw",
    PLAY = "play",
    DISCARD = "discard",
    WIN = "win",
    CONTINUE = "continue"
}

-- Create initial game state
function MahjongState.createInitialState()
    local state = {
        -- Core game state
        phase = MahjongState.PHASES.SETUP,
        currentAction = nil,

        -- Game configuration
        maxHands = 5,
        handsPlayed = 0,
        maxHandSize = 14,
        targetPlayedTiles = 14,

        -- Deck and tiles
        deck = {},
        hand = {},
        playedTiles = {},
        discardPile = {},
        selectedTiles = {},

        -- Scoring and progression
        score = 0,
        totalFan = 0,
        wins = 0,
        invalidPlayAttempts = 0,
        maxInvalidAttempts = 3, -- Allow 3 invalid attempts before battle loss

        -- Game history
        gameHistory = {},

        -- UI state
        showWinDialog = false,
        winData = nil,

        -- Input and Dragging State
        isDragging = false,
        draggedTile = nil,
        draggedTileIndex = nil,
        draggedTileOffsetX = 0,
        draggedTileOffsetY = 0,
        potentialDrag = false,
        dragStartX = 0,
        dragStartY = 0,
        draggedTileVisualX = 0,
        draggedTileVisualY = 0,

        -- Game settings
        settings = {
            showDebug = false,
            allowUndo = false
        },
        
        -- Restart tracking
        restartCount = 0
    }

    return state
end

-- Initialize a new game
function MahjongState.initializeGame(state)
    -- Initialize weather system
    WeatherSystem.initialize()

    -- Create and shuffle deck
    state.deck = MahjongDeck.shuffleDeck(MahjongDeck.createStandardDeck())

    -- Deal initial hand
    local hands, remainingDeck = MahjongDeck.dealHands(state.deck, 1, state.maxHandSize)
    state.hand = hands[1] or {}
    state.deck = remainingDeck

    -- Always sort hand after game init
    print("DEBUG: Sorting hand after game init")
    state.hand = MahjongTiles.sortTiles(state.hand)

    -- Reset game state
    state.playedTiles = {}
    state.selectedTiles = {}
    state.phase = MahjongState.PHASES.PLAYING
    state.handsPlayed = 0
    state.invalidPlayAttempts = 0
    state.showWinDialog = false
    state.winData = nil

    -- Add to history
    MahjongState.addToHistory(state, "game_started", {
        handSize = #state.hand,
        deckSize = #state.deck,
        weather = WeatherSystem.getCurrentWeatherInfo().name
    })

    return state
end

-- Handle tile selection/deselection
function MahjongState.toggleTileSelection(state, tileIndex, collection)
    collection = collection or "hand"

    local tiles = collection == "hand" and state.hand or state.playedTiles
    if not tiles[tileIndex] then return false end

    -- Toggle selection
    if state.selectedTiles[tileIndex] then
        state.selectedTiles[tileIndex] = nil
    else
        -- Limit selection to 3 tiles max
        local selectedCount = 0
        for _ in pairs(state.selectedTiles) do
            selectedCount = selectedCount + 1
        end

        if selectedCount < 3 then
            state.selectedTiles[tileIndex] = true
        end
    end

    return true
end

-- Get currently selected tiles
function MahjongState.getSelectedTiles(state, collection)
    collection = collection or "hand"
    local tiles = collection == "hand" and state.hand or state.playedTiles
    local selected = {}
    local indices = {}

    print("🔍 getSelectedTiles 調試:")
    print("   集合類型: " .. collection)
    print("   瓦片數量: " .. #tiles)
    print("   選擇狀態:")
    for index, isSelected in pairs(state.selectedTiles) do
        print("     索引 " .. index .. ": " .. tostring(isSelected))
        if isSelected then
            if tiles[index] then
                local tile = tiles[index]
                table.insert(selected, tile)
                table.insert(indices, index)
                print("     ✅ 索引 " .. index .. " 有效: " .. (tile.suit or "?") .. "_" .. (tile.value or "?"))
            else
                print("     ❌ 索引 " .. index .. " 無效 (超出範圍或nil)")
            end
        end
    end
    print("   最終選中: " .. #selected .. " 張瓦片")

    return selected, indices
end

-- Clear all selections
function MahjongState.clearSelection(state)
    state.selectedTiles = {}
end

-- Play selected tiles from hand to played area
function MahjongState.playSelectedTiles(state)
    local selectedTiles, selectedIndices = MahjongState.getSelectedTiles(state, "hand")

    print("🎮 嘗試出牌:")
    print("   選擇的瓦片數量: " .. #selectedTiles)
    for i, tile in ipairs(selectedTiles) do
        print("   " .. i .. ". " .. (tile.suit or "?") .. "_" .. (tile.value or "?"))
    end

    if #selectedTiles == 0 then
        print("❌ 沒有選擇瓦片")
        MahjongUI.showError("請先選擇瓦片！", 5)
        return false, "No tiles selected"
    end

    if #selectedTiles > 3 then
        print("❌ 選擇太多瓦片 (" .. #selectedTiles .. " > 3)")
        MahjongUI.showError("一次最多只能出3張瓦片！", 8)
        return false, "Cannot play more than 3 tiles at once"
    end

    -- Validate that selected tiles form a valid mahjong combination
    local isValidCombination = false
    local combinationType = ""

    if #selectedTiles == 2 then
        if MahjongTiles.isPair(selectedTiles) then
            isValidCombination = true
            combinationType = "對子 (pair)"
        end
    elseif #selectedTiles == 3 then
        if MahjongTiles.isTriplet(selectedTiles) then
            isValidCombination = true
            combinationType = "碰 (triplet)"
        elseif MahjongTiles.isSequence(selectedTiles) then
            isValidCombination = true
            combinationType = "上 (sequence)"
        end
    end

    if not isValidCombination then
        print("❌ 選擇的瓦片不構成有效組合")

        -- Increment invalid attempts counter
        state.invalidPlayAttempts = (state.invalidPlayAttempts or 0) + 1
        print("   無效出牌次數: " .. state.invalidPlayAttempts .. "/" .. (state.maxInvalidAttempts or 3))

        local errorMsg = ""
        if #selectedTiles == 2 then
            print("   兩張瓦片必須相同 (對子)")
            errorMsg = "兩張瓦片必須相同才能組成對子！ (失敗次數: " .. state.invalidPlayAttempts .. "/" .. (state.maxInvalidAttempts or 3) .. ")"
        elseif #selectedTiles == 3 then
            print("   三張瓦片必須相同 (碰) 或連續 (上)")
            errorMsg = "三張瓦片必須相同(碰)或連續(上)！ (失敗次數: " .. state.invalidPlayAttempts .. "/" .. (state.maxInvalidAttempts or 3) .. ")"
        else
            print("   必須選擇2張 (對子) 或3張 (碰/上)")
            errorMsg = "必須選擇2張(對子)或3張(碰/上)！ (失敗次數: " .. state.invalidPlayAttempts .. "/" .. (state.maxInvalidAttempts or 3) .. ")"
        end

        -- Add to history
        MahjongState.addToHistory(state, "invalid_play_attempt", {
            attemptNumber = state.invalidPlayAttempts,
            selectedTilesCount = #selectedTiles,
            maxAttemptsAllowed = state.maxInvalidAttempts or 3
        })

        MahjongUI.showError(errorMsg, 10)
        return false, "Selected tiles do not form a valid mahjong combination"
    end

    print("✅ 有效組合: " .. combinationType)

    -- Check number only restriction
    if state.numberOnlyRestriction then
        for _, tile in ipairs(selectedTiles) do
            if tile.suit == "wind" or tile.suit == "dragon" then
                print("❌ 冧把降限制：不能打出風牌或箭牌")
                state.invalidPlayAttempts = (state.invalidPlayAttempts or 0) + 1
                local errorMsg = "冧把降限制：只能打數字牌！ (失敗次數: " .. state.invalidPlayAttempts .. "/" .. (state.maxInvalidAttempts or 3) .. ")"
                MahjongUI.showError(errorMsg, 10)
                return false, "Number only restriction: cannot play wind or dragon tiles"
            end
        end
    end

    -- Check if playing these tiles would exceed target
    local newPlayedCount = #state.playedTiles + #selectedTiles
    if newPlayedCount > state.targetPlayedTiles then
        print("❌ 無法出牌：會超過目標瓦片數 (" .. newPlayedCount .. " > " .. state.targetPlayedTiles .. ")")
        MahjongUI.showError("會超過目標瓦片數！剩餘位置：" .. (state.targetPlayedTiles - #state.playedTiles), 8)
        return false, "Cannot exceed target played tiles count of " .. state.targetPlayedTiles
    end

    -- Move tiles from hand to played area
    print("   移動瓦片到出牌區域...")
    for _, tile in ipairs(selectedTiles) do
        table.insert(state.playedTiles, tile)
        print("   已移動: " .. (tile.suit or "?") .. "_" .. (tile.value or "?"))
    end
    print("   出牌區域現有瓦片數: " .. #state.playedTiles)

    -- Remove tiles from hand (in reverse order to maintain indices)
    print("   從手牌移除選中瓦片...")
    print("   移除前手牌數: " .. #state.hand)
    print("   原始選中索引: " .. table.concat(selectedIndices, ", "))
    table.sort(selectedIndices, function(a, b) return a > b end)
    print("   排序後索引: " .. table.concat(selectedIndices, ", "))

    for _, index in ipairs(selectedIndices) do
        if index <= #state.hand then
            local removedTile = state.hand[index]
            table.remove(state.hand, index)
            print("   已移除位置 " .. index .. ": " .. (removedTile and (removedTile.suit or "?") .. "_" .. (removedTile.value or "?") or "nil"))
        else
            print("   ⚠️ 跳過無效索引 " .. index .. " (超出手牌範圍 " .. #state.hand .. ")")
        end
    end
    print("   移除後手牌數: " .. #state.hand)

    -- Clear selection
    state.selectedTiles = {}
    print("   已清除選擇")

    -- Draw replacement tiles
    local drawn, newDeck = MahjongDeck.drawTiles(state.deck, #selectedTiles)
    state.deck = newDeck

    -- Track newly drawn tiles for animation
    if not state.newlyDrawnTiles then
        state.newlyDrawnTiles = {}
    end

    for _, tile in ipairs(drawn) do
        table.insert(state.hand, tile)
        -- Mark this tile as newly drawn for animation
        table.insert(state.newlyDrawnTiles, {
            tile = tile,
            handIndex = #state.hand,  -- Position in hand
            animationTime = 0,
            maxAnimTime = 1.5,  -- 1.5 seconds animation
            startTime = love.timer.getTime()
        })
        print("🎴 Drew new tile: " .. (tile.display or tile.suit .. tile.value))
    end

    -- Always sort hand after adding new tiles
    print("DEBUG: Sorting hand after playing tiles")
    state.hand = MahjongTiles.sortTiles(state.hand)

    -- Update animation data after sorting - find new positions of animated tiles
    if state.newlyDrawnTiles then
        for _, anim in ipairs(state.newlyDrawnTiles) do
            for i, handTile in ipairs(state.hand) do
                if handTile == anim.tile then
                    anim.handIndex = i
                    break
                end
            end
        end
    end

    -- Add to history
    MahjongState.addToHistory(state, "tiles_played", {
        tilesPlayed = #selectedTiles,
        playedAreaSize = #state.playedTiles,
        handSize = #state.hand
    })

    -- Increment round counter for the action
    if state.isChallenge then
        state.currentRound = (state.currentRound or 1) + 1
    end

    -- Check for win condition
    MahjongState.checkWinCondition(state)

    return true, "Tiles played successfully"
end

-- Discard selected tiles from hand
function MahjongState.discardSelectedTiles(state)
    local selectedTiles, selectedIndices = MahjongState.getSelectedTiles(state, "hand")

    print("🗑️ 嘗試丟棄瓦片:")
    print("   選擇的瓦片數量: " .. #selectedTiles)
    for i, tile in ipairs(selectedTiles) do
        print("   " .. i .. ". " .. (tile.suit or "?") .. "_" .. (tile.value or "?"))
    end

    if #selectedTiles == 0 then
        print("❌ 沒有選擇瓦片")
        return false, "No tiles selected"
    end

    if #selectedTiles > 3 then
        print("❌ 選擇太多瓦片 (" .. #selectedTiles .. " > 3)")
        return false, "Cannot discard more than 3 tiles at once"
    end

    -- Add discarded tiles to discard pile
    print("   移動瓦片到棄牌堆...")
    for _, tile in ipairs(selectedTiles) do
        table.insert(state.discardPile, tile)
        print("   已丟棄: " .. (tile.suit or "?") .. "_" .. (tile.value or "?"))
    end
    print("   棄牌堆現有瓦片數: " .. #state.discardPile)

    -- Remove tiles from hand (in reverse order to maintain indices)
    print("   從手牌移除選中瓦片...")
    print("   移除前手牌數: " .. #state.hand)
    table.sort(selectedIndices, function(a, b) return a > b end)
    for _, index in ipairs(selectedIndices) do
        local removedTile = state.hand[index]
        table.remove(state.hand, index)
        print("   已移除位置 " .. index .. ": " .. (removedTile and (removedTile.suit or "?") .. "_" .. (removedTile.value or "?") or "nil"))
    end
    print("   移除後手牌數: " .. #state.hand)

    -- Clear selection
    state.selectedTiles = {}
    print("   已清除選擇")

    -- Draw replacement tiles
    local drawn, newDeck = MahjongDeck.drawTiles(state.deck, #selectedTiles)
    state.deck = newDeck

    -- Track newly drawn tiles for animation
    if not state.newlyDrawnTiles then
        state.newlyDrawnTiles = {}
    end

    print("   補充新瓦片...")
    for _, tile in ipairs(drawn) do
        table.insert(state.hand, tile)
        -- Mark this tile as newly drawn for animation
        table.insert(state.newlyDrawnTiles, {
            tile = tile,
            handIndex = #state.hand,  -- Position in hand
            animationTime = 0,
            maxAnimTime = 1.5,  -- 1.5 seconds animation
            startTime = love.timer.getTime()
        })
        print("🎴 Drew new tile: " .. (tile.suit or "?") .. "_" .. (tile.value or "?"))
    end

    -- Always sort hand after adding new tiles
    print("DEBUG: Sorting hand after discarding tiles")
    state.hand = MahjongTiles.sortTiles(state.hand)

    -- Update animation data after sorting - find new positions of animated tiles
    if state.newlyDrawnTiles then
        for _, anim in ipairs(state.newlyDrawnTiles) do
            for i, handTile in ipairs(state.hand) do
                if handTile == anim.tile then
                    anim.handIndex = i
                    break
                end
            end
        end
    end

    -- Add to history
    MahjongState.addToHistory(state, "tiles_discarded", {
        tilesDiscarded = #selectedTiles,
        discardPileSize = #state.discardPile,
        handSize = #state.hand
    })

    -- Increment round counter for the action
    if state.isChallenge then
        state.currentRound = (state.currentRound or 1) + 1
    end

    print("✅ 丟棄完成！")
    return true, "Tiles discarded successfully"
end

-- Retrieve tiles from discard pile (for special abilities)
function MahjongState.retrieveFromDiscardPile(state, count)
    count = count or 1
    local retrieved = {}

    print("♻️ 從棄牌堆回收瓦片:")
    print("   嘗試回收數量: " .. count)
    print("   棄牌堆可用瓦片: " .. #state.discardPile)

    for i = 1, math.min(count, #state.discardPile) do
        local tile = table.remove(state.discardPile) -- Remove from end (LIFO)
        table.insert(retrieved, tile)
        print("   已回收: " .. (tile.suit or "?") .. "_" .. (tile.value or "?"))
    end

    print("   回收完成，棄牌堆剩餘: " .. #state.discardPile)
    return retrieved
end

-- Get discard pile info
function MahjongState.getDiscardPileInfo(state)
    return {
        count = #state.discardPile,
        tiles = state.discardPile,
        lastDiscarded = state.discardPile[#state.discardPile] -- Most recent
    }
end

-- Check if current played tiles form a winning hand
function MahjongState.checkWinCondition(state)
    if #state.playedTiles ~= state.targetPlayedTiles then
        return false
    end

    local isWin, patternName, fanValue = MahjongLogic.checkWinningHand(state.playedTiles)

    if isWin then
        -- Calculate score including weather bonus
        local gameContext = {
            selfDrawn = true,
            handsPlayed = state.handsPlayed,
            eastWindBoost = state.eastWindBoost, -- Pass east wind boost from consumables
            numberOnlyBaseFaan = state.numberOnlyBaseFaan -- Pass number only base faan bonus
        }
        local score = MahjongLogic.calculateScore(patternName, fanValue, gameContext, state.playedTiles)

        -- Hong Kong Mahjong requires minimum 3 fan to win
        local WeatherSystem = require("weather_system")
        local weatherBonus, _ = WeatherSystem.calculateWeatherBonus(state.playedTiles)
        local eastWindBonus = 0
        if state.eastWindBoost and state.eastWindBoost > 0 then
            local eastWindCount = 0
            for _, tile in ipairs(state.playedTiles) do
                if tile.suit == "wind" and tile.value == "east" then
                    eastWindCount = eastWindCount + 1
                end
            end
            eastWindBonus = eastWindCount * state.eastWindBoost
        end
        local numberOnlyBonus = state.numberOnlyBaseFaan or 0
        local totalFan = fanValue + weatherBonus + eastWindBonus + numberOnlyBonus

        if totalFan < 3 then
            print("❌ 未達最低番數要求!")
            print("   目前番數: " .. totalFan .. " (需要最少3番)")
            print("   基本番數: " .. fanValue)
            print("   天氣加成: " .. weatherBonus)
            return false
        end

        -- Update game state
        state.phase = MahjongState.PHASES.WIN_CHECK
        state.showWinDialog = true
        state.winData = {
            pattern = patternName,
            fan = fanValue,
            totalFan = totalFan,
            weatherBonus = weatherBonus,
            eastWindBonus = eastWindBonus,
            numberOnlyBonus = numberOnlyBonus,
            score = score,
            tiles = state.playedTiles
        }

        -- Trigger win animations
        MahjongUI.resetWinAnimation()

        -- Update player stats
        state.score = state.score + score
        state.totalFan = state.totalFan + fanValue
        state.wins = state.wins + 1

        -- Challenge mode tracking
        if state.isChallenge then
            -- Add fan to challenge total
            state.totalFan = state.totalFan + fanValue
            print("贏咗一局！番數: " .. fanValue .. " (總計: " .. state.totalFan .. "/" .. state.targetFan .. ")")
        end

        -- Add to history
        MahjongState.addToHistory(state, "game_won", {
            pattern = patternName,
            fan = fanValue,
            score = score
        })

        return true
    end

    return false
end

-- Continue to next round after win
function MahjongState.continueToNextRound(state)
    state.handsPlayed = state.handsPlayed + 1

    if state.handsPlayed >= state.maxHands then
        state.phase = MahjongState.PHASES.GAME_OVER
        return false
    end

    -- Generate new weather for next round
    WeatherSystem.generateNewWeather()

    -- Reset for next round
    state.playedTiles = {}
    state.selectedTiles = {}
    state.showWinDialog = false
    state.winData = nil
    state.phase = MahjongState.PHASES.PLAYING

    -- Deal new hand if needed
    if #state.hand < state.maxHandSize then
        local needed = state.maxHandSize - #state.hand
        local drawn, newDeck = MahjongDeck.drawTiles(state.deck, needed)
        state.deck = newDeck

        for _, tile in ipairs(drawn) do
            table.insert(state.hand, tile)
        end

        -- Always sort hand after adding new tiles
        state.hand = MahjongTiles.sortTiles(state.hand)
    end

    return true
end

-- Add event to game history
function MahjongState.addToHistory(state, eventType, eventData)
    local historyEntry = {
        timestamp = os.time(),
        type = eventType,
        data = eventData or {}
    }

    table.insert(state.gameHistory, historyEntry)

    -- Limit history size
    if #state.gameHistory > 100 then
        table.remove(state.gameHistory, 1)
    end
end

-- Get game statistics
function MahjongState.getGameStats(state)
    return {
        score = state.score,
        wins = state.wins,
        totalFan = state.totalFan,
        handsPlayed = state.handsPlayed,
        maxHands = state.maxHands,
        handSize = #state.hand,
        playedTilesCount = #state.playedTiles,
        deckRemaining = #state.deck,
        invalidPlayAttempts = state.invalidPlayAttempts or 0,
        maxInvalidAttempts = state.maxInvalidAttempts or 3,
        averageFan = state.wins > 0 and (state.totalFan / state.wins) or 0
    }
end

-- Save game state (simplified for now)
function MahjongState.saveGame(state, filename)
    filename = filename or "savegame.json"

    local saveData = {
        score = state.score,
        wins = state.wins,
        totalFan = state.totalFan,
        settings = state.settings,
        timestamp = os.time()
    }

    -- In a real implementation, this would write to a file
    -- For now, just return the save data
    return saveData
end

-- Load game state (simplified for now)
function MahjongState.loadGame(filename)
    filename = filename or "savegame.json"

    -- In a real implementation, this would read from a file
    -- For now, just return a new state
    return MahjongState.createInitialState()
end

-- Reset game to initial state
function MahjongState.resetGame(state)
    local newState = MahjongState.createInitialState()

    -- Preserve settings
    newState.settings = state.settings

    -- Preserve battle-specific data that should persist across resets
    if state.mainGameState then
        newState.mainGameState = state.mainGameState
    end

    if state.isChallenge ~= nil then
        newState.isChallenge = state.isChallenge
    end

    if state.challengeData then
        newState.challengeData = state.challengeData
    end

    if state.battleConfig then
        newState.battleConfig = state.battleConfig
    end

    -- Preserve battle parameters
    if state.targetFan then
        newState.targetFan = state.targetFan
    end

    if state.maxRounds then
        newState.maxRounds = state.maxRounds
    end

    if state.targetPlayedTiles then
        newState.targetPlayedTiles = state.targetPlayedTiles
    end

    if state.maxInvalidAttempts then
        newState.maxInvalidAttempts = state.maxInvalidAttempts
    end

    -- Reset current round/attempts but preserve configuration
    newState.currentRound = 1
    newState.invalidPlayAttempts = 0
    
    -- Increment restart count and preserve it
    newState.restartCount = (state.restartCount or 0) + 1

    -- Initialize the new game
    newState = MahjongState.initializeGame(newState)

    -- Restore Chinese font for battle screen (same logic as MahjongBattle.initialize)
    if createChineseFontSize then
        local chineseFont = createChineseFontSize(16)
        love.graphics.setFont(chineseFont)
        print("✓ Reset: Chinese font restored successfully")
    elseif _G.CHINESE_FONT_PATH then
        local chineseFont = love.graphics.newFont(_G.CHINESE_FONT_PATH, 16)
        love.graphics.setFont(chineseFont)
        print("✓ Reset: Chinese font restored from path")
    else
        print("⚠ Reset: No Chinese font available")
    end

    return newState
end

-- Update game state (called each frame)
function MahjongState.update(state, dt)
    -- Handle automatic state transitions
    if state.phase == MahjongState.PHASES.SETUP then
        -- Auto-transition to playing phase
        state.phase = MahjongState.PHASES.PLAYING
    end

    -- Update newly drawn tile animations
    if state.newlyDrawnTiles then
        local currentTime = love.timer.getTime()
        for i = #state.newlyDrawnTiles, 1, -1 do
            local anim = state.newlyDrawnTiles[i]
            anim.animationTime = currentTime - anim.startTime

            -- Remove completed animations
            if anim.animationTime >= anim.maxAnimTime then
                table.remove(state.newlyDrawnTiles, i)
            end
        end
    end

    return state
end

-- Validate game state integrity
function MahjongState.validateState(state)
    local errors = {}

    -- Check hand size
    if #state.hand > state.maxHandSize then
        table.insert(errors, "Hand size exceeds maximum")
    end

    -- Check played tiles
    if #state.playedTiles > state.targetPlayedTiles then
        table.insert(errors, "Too many tiles in played area")
    end

    -- Check deck integrity
    local isValid, deckErrors = MahjongDeck.validateDeck(state.deck)
    if not isValid then
        for _, error in ipairs(deckErrors) do
            table.insert(errors, "Deck: " .. error)
        end
    end

    -- Check selections
    for index, isSelected in pairs(state.selectedTiles) do
        if isSelected and not state.hand[index] then
            table.insert(errors, "Invalid tile selection: " .. index)
        end
    end

    return #errors == 0, errors
end

return MahjongState