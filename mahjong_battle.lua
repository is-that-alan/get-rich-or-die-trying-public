-- Mahjong Battle System (Fixed Working Version)
local MahjongBattle = {}

-- Try to import modules with error handling
local MahjongTiles, MahjongLogic, MahjongDeck, MahjongState, MahjongUI, ConsumablesSystem
local modulesLoaded = false

local function loadModules()
    local success, err = pcall(function()
        MahjongTiles = require("mahjong_tiles")
        MahjongLogic = require("mahjong_logic")
        MahjongDeck = require("mahjong_deck")
        MahjongState = require("mahjong_state")
        MahjongUI = require("mahjong_ui")
        ConsumablesSystem = require("consumables_system")
        modulesLoaded = true
    end)

    if not success then
        modulesLoaded = false
        print("Module loading failed: " .. tostring(err))
    end
end

-- Try to load modules on startup
loadModules()

-- Legacy imports (still needed for some features)
local Card = require("card")
local Juice = require("juice")
local Progression = require("progression")
local HKFlavor = require("hk_flavor")
local Music = require("music")
local BattleConfig = require("battle_config")
local Progression = require("progression")
local CutinDialogue = require("cutin_dialogue")

-- Game state (using new modular system)
local gameState = nil
local deckExpanded = false  -- Track if deck preview is expanded
local showHelpTooltip = false  -- Track help button hover state

-- Dynamic layout calculation function (Two-Column Responsive)
local function calculateLayout(screenWidth, screenHeight)
    local layout = {}

    -- Defines the two primary vertical columns
    layout.sidebarZone = { x = 0, y = 0, w = screenWidth * 0.3, h = screenHeight }
    layout.mainZone = { x = layout.sidebarZone.w, y = 0, w = screenWidth * 0.7, h = screenHeight }

    return layout
end

-- Initialize the battle system
function MahjongBattle.initialize(challengeData, battleType)
    -- Create initial game state using new system
    gameState = MahjongState.createInitialState()

    -- Determine battle type
    local actualBattleType = battleType or "normal"
    if challengeData and challengeData.battleType then
        actualBattleType = challengeData.battleType
    end

    -- Apply battle configuration
    BattleConfig.applyConfig(gameState, actualBattleType)

    -- Handle challenge data if provided
    if challengeData then
        gameState.isChallenge = true
        gameState.challengeData = challengeData

        -- Override with challenge-specific settings if provided
        gameState.targetFan = challengeData.targetFan or gameState.targetFan
        gameState.maxRounds = challengeData.hands or gameState.maxHands
        gameState.currentRound = 1
        gameState.totalFan = 0
        gameState.challengePassed = false
        gameState.challengeFailed = false

        print("挑戰開始: " .. (challengeData.name or "未知挑戰"))
        print("目標番數: " .. gameState.targetFan .. " / 最大回合: " .. gameState.maxRounds)
    else
        -- Regular battle mode
        gameState.isChallenge = false
        gameState.currentRound = 1
        gameState.totalFan = 0
        print("戰鬥開始 (" .. actualBattleType .. "): " .. (gameState.battleConfig.type or "未知模式"))
    end

    -- Initialize the game
    gameState = MahjongState.initializeGame(gameState)

    -- Reset help tooltip state
    showHelpTooltip = false

    -- Set proper Chinese font for battle screen (same as main menu)
    if createChineseFontSize then
        local chineseFont = createChineseFontSize(16)
        love.graphics.setFont(chineseFont)
        print("✓ Battle screen: Chinese font loaded successfully")
    elseif _G.CHINESE_FONT_PATH then
        local chineseFont = love.graphics.newFont(_G.CHINESE_FONT_PATH, 16)
        love.graphics.setFont(chineseFont)
        print("✓ Battle screen: Chinese font loaded from path")
    else
        print("⚠ Battle screen: No Chinese font available")
    end

    -- Force refresh MahjongUI fonts to ensure Chinese support
    if MahjongUI then
        local function createChineseFontSafe(size)
            if createChineseFontSize then
                return createChineseFontSize(size)
            elseif _G.CHINESE_FONT_PATH then
                local success, font = pcall(love.graphics.newFont, _G.CHINESE_FONT_PATH, size)
                if success then
                    return font
                end
            end
            return love.graphics.newFont(size)
        end

        MahjongUI.fonts = {
            tiny   = createChineseFontSafe(10),
            small  = createChineseFontSafe(12),
            normal = createChineseFontSafe(16),
            mid    = createChineseFontSafe(18),
            large  = createChineseFontSafe(20),
            title  = createChineseFontSafe(24),
        }
        print("✓ Battle screen: MahjongUI fonts refreshed with Chinese support")
    end

    -- Add test consumables to test the icon system (temporary)
    if ConsumablesSystem and gameState.mainGameState then
        print("🧪 Adding test consumables to verify icon loading...")
        ConsumablesSystem.addToInventory(gameState.mainGameState, "milk_tea", 1)
        ConsumablesSystem.addToInventory(gameState.mainGameState, "pineapple_bun", 1)
        ConsumablesSystem.addToInventory(gameState.mainGameState, "golden_dragon", 1)
        print("🧪 Test consumables added")
    end

    return true
end

-- Legacy function name compatibility
function MahjongBattle.init(mainGameState, challengeData, battleType)
    if not modulesLoaded then
        loadModules()
    end

    if modulesLoaded then
        local result = MahjongBattle.initialize(challengeData, battleType)
        -- Store reference to main game state after initialization
        if mainGameState and gameState then
            gameState.mainGameState = mainGameState
            if not gameState.isChallenge then
                gameState.maxRounds = mainGameState.maxRounds or gameState.maxHands or 7
            end
        end
        return result
    else
        -- Create basic fallback state
        gameState = {
            hand = {},
            playedTiles = {},
            selectedTiles = {},
            deck = {},
            score = 0,
            phase = "playing"
        }
        return true
    end
end

-- Update function (called each frame)
function MahjongBattle.update(dt)
    if not gameState then return end

    -- Smoothly update dragged tile position
    if gameState.isDragging then
        local mouseX, mouseY = love.mouse.getPosition()
        local targetX = mouseX - gameState.draggedTileOffsetX
        local targetY = mouseY - gameState.draggedTileOffsetY

        -- Interpolate for smooth movement
        local lerpFactor = 0.2
        gameState.draggedTileVisualX = gameState.draggedTileVisualX + (targetX - gameState.draggedTileVisualX) * lerpFactor
        gameState.draggedTileVisualY = gameState.draggedTileVisualY + (targetY - gameState.draggedTileVisualY) * lerpFactor
    end

    -- Update game state
    gameState = MahjongState.update(gameState, dt)

    -- Update error feedback system
    MahjongUI.updateErrorState(dt)

    -- Update deck popup animation
    MahjongUI.updateDeckPopup(dt)

    -- Check challenge conditions
    if gameState.isChallenge and not gameState.challengePassed and not gameState.challengeFailed then
        MahjongBattle.checkChallengeConditions()
    end

    -- Check regular battle conditions (for non-challenge mode)
    if not gameState.isChallenge and not gameState.battleWon and not gameState.battleLost then
        MahjongBattle.checkBattleConditions()
    end

    -- Auto-return after battle/challenge ends (DISABLED - user controls progression)
    -- if gameState.battleEndTime and love.timer.getTime() >= gameState.battleEndTime then
    --     if gameState.mainGameState then
    --         if gameState.battleWon or gameState.challengePassed then
    --             Progression.advanceStory(gameState.mainGameState)
    --         else
    --             gameState.mainGameState.screen = "menu"  -- Handle loss by returning to menu
    --         end
    --         print("返回進度畫面")
    --     end
    --     gameState.battleEndTime = nil
    -- end

    -- Update juice effects
    if Juice then
        Juice.update(dt)
    end
end

-- Check challenge win/loss conditions
function MahjongBattle.checkChallengeConditions()
    if not gameState.isChallenge then return end

    -- Check if rounds exceeded
    if gameState.currentRound > gameState.maxRounds then
        if gameState.totalFan >= gameState.targetFan then
            MahjongBattle.completeChallenge(true)
        else
            MahjongBattle.completeChallenge(false)
        end
    end

    -- Check for immediate win (if target fan reached)
    if gameState.totalFan >= gameState.targetFan then
        MahjongBattle.completeChallenge(true)
    end
end

-- Complete challenge with win/loss
function MahjongBattle.completeChallenge(success)
    if success then
        gameState.challengePassed = true
        print("挑戰成功！番數: " .. gameState.totalFan .. "/" .. gameState.targetFan)
        -- Award money based on challenge reward
        if gameState.challengeData and gameState.challengeData.reward then
            local reward = gameState.challengeData.reward
            if reward.money and gameState.mainGameState then
                gameState.mainGameState.playerMoney = gameState.mainGameState.playerMoney + reward.money
                print("獲得賞金: $" .. reward.money)
            end
            if reward.xp and gameState.mainGameState then
                gameState.mainGameState.xp = (gameState.mainGameState.xp or 0) + reward.xp
                print("獲得經驗: +" .. reward.xp .. "XP")
            end
        end
    else
        gameState.challengeFailed = true
        print("挑戰失敗！番數不足: " .. gameState.totalFan .. "/" .. gameState.targetFan)

        -- Deduct money for failure
        if gameState.mainGameState then
            local penalty = math.min(50, gameState.mainGameState.playerMoney)
            gameState.mainGameState.playerMoney = gameState.mainGameState.playerMoney - penalty
            print("失敗懲罰: -$" .. penalty)
        end
    end

    -- Timer removed - user controls progression with ESC key
end

-- Force win function for Konami code
function MahjongBattle.forceWin()
    if not gameState then return end

    print("FORCE WIN ACTIVATED!")
    gameState.battleWon = true
    gameState.showWinDialog = true

    -- Create fake win data for display
    gameState.winData = {
        handType = "Konami Win",
        fan = 999,
        description = "作弊勝利！"
    }

    -- Trigger proper story advancement for Konami win
    if gameState.mainGameState then
        local Progression = require("progression")
        Progression.advanceStory(gameState.mainGameState)
        
        -- Also record the win for progression (with minimal rewards for cheat)
        Progression.recordWin(gameState.mainGameState, 10) -- Small reward for cheat win
    end

    print("戰鬥勝利！(Konami Code)")
    
    -- Show special Konami code cut-in dialogue
    local CutinDialogue = require("cutin_dialogue")
end

-- Check regular battle win/loss conditions
function MahjongBattle.checkBattleConditions()
    if not gameState then return end

    -- Win condition: Complete a valid mahjong hand
    if gameState.showWinDialog and gameState.winData then
        gameState.battleWon = true
        print("戰鬥勝利！完成麻將手牌")

        -- Award money and XP for regular battles using configuration
        if gameState.mainGameState then
            local rewards = BattleConfig.calculateRewards(gameState, true)

            if rewards.money then
                gameState.mainGameState.playerMoney = gameState.mainGameState.playerMoney + rewards.money
                print("獲得賞金: $" .. rewards.money)
            end

            if rewards.xp then
                gameState.mainGameState.xp = (gameState.mainGameState.xp or 0) + rewards.xp
                print("獲得經驗: +" .. rewards.xp .. "XP")
            end

            -- Handle special items if any
            if rewards.specialItems then
                for _, item in ipairs(rewards.specialItems) do
                    print("獲得特殊物品: " .. item)
                    -- TODO: Add special items to inventory
                end
            end

            -- Record the win in progression system to advance levels
            local Progression = require("progression")
            Progression.recordWin(gameState.mainGameState, rewards.money or 0)
            print("已記錄戰鬥勝利，等級進度已更新")
        end

        -- Timer removed - user controls progression with ESC key
        return
    end

    -- Loss condition 1: Played area is full (14 tiles) but insufficient fan
    if #gameState.playedTiles >= (gameState.targetPlayedTiles or 14) then
        local requiredFan = gameState.targetFan or 3
        local currentFan = gameState.totalFan or 0

        if currentFan < requiredFan then
            gameState.battleLost = true
            print("戰鬥失敗！打牌區域已滿但番數不足: " .. currentFan .. "/" .. requiredFan)

            -- Penalty for regular battle loss using configuration
            if gameState.mainGameState then
                local penalties = BattleConfig.calculateRewards(gameState, false)
                if penalties.money then
                    local actualPenalty = math.min(math.abs(penalties.money), gameState.mainGameState.playerMoney)
                    gameState.mainGameState.playerMoney = gameState.mainGameState.playerMoney - actualPenalty
                    print("失敗懲罰: -$" .. actualPenalty)
                end
            end

            -- Timer removed - user controls progression with ESC key
            return
        end
    end

    -- Loss condition 2: Maximum hands played without winning
    if gameState.handsPlayed and gameState.maxHands then
        if gameState.handsPlayed >= gameState.maxHands then
            local requiredFan = gameState.targetFan or 3
            local currentFan = gameState.totalFan or 0

            if currentFan < requiredFan then
                gameState.battleLost = true
                print("戰鬥失敗！已達最大手牌數但番數不足: " .. currentFan .. "/" .. requiredFan)

                -- Penalty for regular battle loss using configuration
                if gameState.mainGameState then
                    local penalties = BattleConfig.calculateRewards(gameState, false)
                    if penalties.money then
                        local actualPenalty = math.min(math.abs(penalties.money), gameState.mainGameState.playerMoney)
                        gameState.mainGameState.playerMoney = gameState.mainGameState.playerMoney - actualPenalty
                        print("失敗懲罰: -$" .. actualPenalty)
                    end
                end

                -- Set auto-return timer for battle loss
                gameState.battleEndTime = love.timer.getTime() + 5
                return
            end
        end
    end

    -- Loss condition 3: Too many invalid play attempts
    if gameState.invalidPlayAttempts and gameState.maxInvalidAttempts then
        if gameState.invalidPlayAttempts >= gameState.maxInvalidAttempts then
            gameState.battleLost = true
            print("戰鬥失敗！無效出牌次數過多: " .. gameState.invalidPlayAttempts .. "/" .. gameState.maxInvalidAttempts)

            -- Penalty for regular battle loss using configuration
            if gameState.mainGameState then
                local penalties = BattleConfig.calculateRewards(gameState, false)
                if penalties.money then
                    local actualPenalty = math.min(math.abs(penalties.money), gameState.mainGameState.playerMoney)
                    gameState.mainGameState.playerMoney = gameState.mainGameState.playerMoney - actualPenalty
                    print("失敗懲罰: -$" .. actualPenalty)
                end
            end

            -- Timer removed - user controls progression with ESC key
            return
        end
    end

    -- Loss condition 4: Run out of moves (deck empty and can't make valid combinations)
    if #gameState.deck == 0 and #gameState.hand > 0 then
        -- Check if player can make any valid combinations with current hand
        local canPlay = MahjongBattle.canMakeValidCombination(gameState.hand)
        if not canPlay then
            gameState.battleLost = true
            print("戰鬥失敗！無法組成有效組合")

            -- Penalty for regular battle loss using configuration
            if gameState.mainGameState then
                local penalties = BattleConfig.calculateRewards(gameState, false)
                if penalties.money then
                    local actualPenalty = math.min(math.abs(penalties.money), gameState.mainGameState.playerMoney)
                    gameState.mainGameState.playerMoney = gameState.mainGameState.playerMoney - actualPenalty
                    print("失敗懲罰: -$" .. actualPenalty)
                end
            end

            -- Timer removed - user controls progression with ESC key
        end
    end
end

-- Helper function to check if player can make valid combinations
function MahjongBattle.canMakeValidCombination(hand)
    if #hand < 2 then return false end

    -- Check if any 2-tile pairs can be formed
    for i = 1, #hand - 1 do
        for j = i + 1, #hand do
            if MahjongTiles.isPair({hand[i], hand[j]}) then
                return true
            end
        end
    end

    -- Check if any 3-tile combinations can be formed
    if #hand >= 3 then
        for i = 1, #hand - 2 do
            for j = i + 1, #hand - 1 do
                for k = j + 1, #hand do
                    local combo = {hand[i], hand[j], hand[k]}
                    if MahjongTiles.isTriplet(combo) or MahjongTiles.isSequence(combo) then
                        return true
                    end
                end
            end
        end
    end

    return false
end

-- Use consumable item during battle
function MahjongBattle.useConsumable(consumableIndex)
    if not gameState or not gameState.mainGameState then return end

    local mainGameState = gameState.mainGameState
    local inventory = ConsumablesSystem.getPlayerInventory(mainGameState)

    -- Get the nth item from inventory (1-indexed)
    local itemIds = {}
    for itemId, _ in pairs(inventory) do
        table.insert(itemIds, itemId)
    end

    if consumableIndex > #itemIds or consumableIndex < 1 then
        print("🚫 無效的道具編號: " .. consumableIndex)
        return
    end

    local itemId = itemIds[consumableIndex]
    local success, message = ConsumablesSystem.useConsumable(itemId, mainGameState, gameState)

    if success then
        print("✨ " .. message)
        -- Trigger visual feedback
        if gameState.settings then
            gameState.settings.showConsumableEffect = {
                message = message,
                timer = 2.0
            }
        end
    else
        print("❌ " .. message)
    end
end

-- Handle key presses
function MahjongBattle.keypressed(key)
    if not gameState then return end

    if key == "return" or key == "kpenter" then -- Enter key
        -- Only allow Enter exit when battle has ended
        local battleEnded = gameState.battleWon or gameState.battleLost or gameState.challengePassed or gameState.challengeFailed
        if battleEnded then
            MahjongBattle.exitBattle()
            return "progression"
        else
            -- During active battle, Enter does nothing
            print("按Enter無效：戰鬥進行中，請完成戰鬥後再退出")
            return nil
        end

    -- elseif key == "p" then
    --     -- Play selected tiles
    --     local success, message = MahjongState.playSelectedTiles(gameState)
    --     if not success then
    --         print("Play failed: " .. message)
    --     end
    -- elseif key == "d" then
    --     -- Discard selected tiles
    --     local success, message = MahjongState.discardSelectedTiles(gameState)
    --     if not success then
    --         print("Discard failed: " .. message)
    --     end
    elseif key >= "1" and key <= "5" then
        -- Use consumables (1-5)
        local consumableIndex = tonumber(key)
        MahjongBattle.useConsumable(consumableIndex)
    elseif key == "r" then
        -- Reset game
        gameState = MahjongState.resetGame(gameState)
        
        -- Check for angry_sean dialogue trigger (after 2+ restarts)
        if gameState.restartCount > 2 then
            CutinDialogue.show("dialogue", "angry_sean")
        end

    elseif key == "s" then
        -- Sort hand immediately
        gameState.hand = MahjongTiles.sortTiles(gameState.hand)
    elseif key == "f3" then
        -- Toggle debug view
        gameState.settings.showDebug = not gameState.settings.showDebug

    end
end

-- Draw the battle interface using the new two-column layout
function MahjongBattle.draw(mainGameState)
    if not gameState then return end

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local layout = calculateLayout(screenWidth, screenHeight)

    -- Apply screen shake if error is showing
    local shakeX, shakeY = MahjongUI.getScreenShake()
    if shakeX ~= 0 or shakeY ~= 0 then
        love.graphics.push()
        love.graphics.translate(shakeX, shakeY)
    end

    -- Set background color
    love.graphics.setColor(MahjongUI.COLORS.BACKGROUND)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    -- Draw the two main zones
    MahjongBattle.drawSidebar(layout.sidebarZone, gameState)
    MahjongBattle.drawMainContent(layout.mainZone, gameState)

    -- Draw dragged tile on top with smooth animation
    if gameState.isDragging and gameState.draggedTile then
        MahjongUI.drawTile(gameState.draggedTile, gameState.draggedTileVisualX, gameState.draggedTileVisualY, true, 0.8)
    end

    -- Restore graphics transform if screen shake was applied
    if shakeX ~= 0 or shakeY ~= 0 then
        love.graphics.pop()
    end

    -- Draw overlays (which are screen-wide)
    MahjongUI.drawErrorNotification(screenWidth, screenHeight)
    if gameState.showWinDialog and gameState.winData then
        MahjongUI.drawWinNotification(gameState.winData, screenWidth, screenHeight)
    end

    -- Draw battle end results
    if gameState.battleWon then
        MahjongBattle.drawBattleResult(screenWidth, screenHeight, true, "戰鬥勝利！", "恭喜完成麻將手牌")
    elseif gameState.battleLost then
        local lossReason = "未能達到目標要求"
        if gameState.invalidPlayAttempts and gameState.invalidPlayAttempts >= (gameState.maxInvalidAttempts or 3) then
            lossReason = "無效出牌次數過多 (" .. gameState.invalidPlayAttempts .. "/" .. (gameState.maxInvalidAttempts or 3) .. ")"
        end
        MahjongBattle.drawBattleResult(screenWidth, screenHeight, false, "戰鬥失敗！", lossReason)
    elseif gameState.challengePassed then
        MahjongBattle.drawBattleResult(screenWidth, screenHeight, true, "挑戰成功！", "番數: " .. (gameState.totalFan or 0) .. "/" .. (gameState.targetFan or 3))
    elseif gameState.challengeFailed then
        MahjongBattle.drawBattleResult(screenWidth, screenHeight, false, "挑戰失敗！", "番數不足: " .. (gameState.totalFan or 0) .. "/" .. (gameState.targetFan or 3))
    end

    MahjongUI.drawDeckSummaryPopup(gameState.deck or {}, screenWidth, screenHeight, gameState.deckPeekEnabled)
    MahjongUI.drawDiscardSummaryPopup(gameState.discardPile or {}, screenWidth, screenHeight)

    -- Draw debug info if enabled
    if gameState.settings.showDebug then
        MahjongUI.drawDebugInfo(gameState, layout.mainZone.x + 20, 20)
    end

    -- Draw help button (top-right corner of main zone)
    local HELP_BUTTON_SIZE = 40
    local HELP_BUTTON_PADDING = 20
    local helpButtonX = layout.mainZone.x + layout.mainZone.w - HELP_BUTTON_SIZE - HELP_BUTTON_PADDING
    local helpButtonY = HELP_BUTTON_PADDING

    -- Draw help button
    if showHelpTooltip then
        love.graphics.setColor(0.4, 0.5, 0.6, 1)
    else
        love.graphics.setColor(0.3, 0.4, 0.5, 0.8)
    end
    love.graphics.circle("fill", helpButtonX + HELP_BUTTON_SIZE/2, helpButtonY + HELP_BUTTON_SIZE/2, HELP_BUTTON_SIZE/2)

    -- Draw question mark
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("?", helpButtonX, helpButtonY + 8, HELP_BUTTON_SIZE, "center")

    -- Draw help tooltip if hovering
    if showHelpTooltip then
        local tooltipWidth = 320
        local tooltipHeight = 240
        local tooltipX = helpButtonX - tooltipWidth - 10
        local tooltipY = helpButtonY

        -- Tooltip background
        love.graphics.setColor(0.15, 0.15, 0.15, 0.95)
        love.graphics.rectangle("fill", tooltipX, tooltipY, tooltipWidth, tooltipHeight, 5)

        -- Tooltip border
        love.graphics.setColor(0.6, 0.7, 0.8, 1)
        love.graphics.rectangle("line", tooltipX, tooltipY, tooltipWidth, tooltipHeight, 5)

        -- Tooltip text
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("點樣玩麻雀戰鬥？", tooltipX + 10, tooltipY + 10, tooltipWidth - 20, "left")

        love.graphics.setColor(0.9, 0.9, 0.9, 1)
        local helpText = [[
• 從手牌拖曳麻雀牌到出牌區
• 組合成有效的麻雀牌型
• 牌型包括：對子、刻子、順子等
• 完成牌型可以獲得番數
• 達到目標番數就贏得戰鬥
• 留意天氣效果會影響戰鬥
• 使用消耗品獲得特殊效果
• 查看棄牌區同牌疊剩餘數量]]

        love.graphics.printf(helpText, tooltipX + 10, tooltipY + 40, tooltipWidth - 20, "left")
    end

    MahjongUI.resetGraphics()
end

-- New function to draw all sidebar content within its zone
function MahjongBattle.drawSidebar(zone, gameState)
    local x = zone.x + 10 -- 10px padding from the edge of the zone
    local y = zone.y + 10
    local width = zone.w - 20 -- 10px padding on each side
    local panelSpacing = 15

    -- 1. Scoreboard Panel (formerly the header)
    local scoreboardHeight = 60
    MahjongUI.drawPanel(x, y, width, scoreboardHeight, nil)
    love.graphics.setColor(MahjongUI.COLORS.TEXT_MAIN)
    love.graphics.setFont(MahjongUI.fonts.normal)
    local textY = y + (scoreboardHeight - MahjongUI.fonts.normal:getHeight()) / 2
    local scoreText = "分數: " .. (gameState.score or 0)
    local roundText = "回合: " .. (gameState.currentRound or 1) .. "/" .. (gameState.maxRounds or 10)
    local deckText = "牌疊: " .. #gameState.deck
    love.graphics.print(scoreText, x + 15, textY)
    love.graphics.printf(roundText, x + 15, textY, width - 30, "center")
    local deckWidth = MahjongUI.fonts.normal:getWidth(deckText)
    love.graphics.print(deckText, x + width - deckWidth - 15, textY)
    y = y + scoreboardHeight + panelSpacing

    -- 2. Challenge Panel
    if gameState.isChallenge then
        local challengePanelHeight = 100
        MahjongUI.drawPanel(x, y, width, challengePanelHeight, "挑戰模式")
        local fanProgress = (gameState.totalFan or 0) / (gameState.targetFan or 1)
        MahjongUI.drawProgressBar(x + 10, y + 40, width - 20, 20, fanProgress, "番數: " .. gameState.totalFan .. "/" .. gameState.targetFan, {0.3, 0.6, 0.9})
        local roundProgress = (gameState.currentRound or 1) / (gameState.maxRounds or 1)
        MahjongUI.drawProgressBar(x + 10, y + 70, width - 20, 20, roundProgress, "回合: " .. gameState.currentRound .. "/" .. gameState.maxRounds, {0.9, 0.3, 0.3})
        y = y + challengePanelHeight + panelSpacing
    end

    -- 3. Weather Panel
    local weatherPanelHeight = 100
    local WeatherSystem = require("weather_system")
    local currentWeather = WeatherSystem.getCurrentWeatherInfo()

    if currentWeather then
        MahjongUI.drawPanel(x, y, width, weatherPanelHeight, "天氣")

        -- Weather icon and name
        love.graphics.setColor(MahjongUI.COLORS.TEXT_MAIN)
        love.graphics.setFont(MahjongUI.fonts.normal)
        love.graphics.printf(currentWeather.name, x + 10, y + 30, width - 20, "center")

        -- Favored winds display
        if #currentWeather.favoredWinds > 0 then
            local windText = "有利風向: " .. table.concat(currentWeather.favoredWinds, ", ")
            love.graphics.setColor(0.3, 0.8, 0.3, 1) -- Green for bonus
            love.graphics.printf(windText, x + 10, y + 50, width - 20, "center")

            if currentWeather.fanBonus > 0 then
                local bonusText = "額外番數: +" .. currentWeather.fanBonus
                love.graphics.printf(bonusText, x + 10, y + 70, width - 20, "center")
            end
        else
            love.graphics.setColor(0.6, 0.6, 0.6, 1) -- Gray for no bonus
            love.graphics.printf("無風向加成", x + 10, y + 50, width - 20, "center")
        end

        y = y + weatherPanelHeight + panelSpacing
    end

    -- 4. Consumables Panel
    local consumablesPanelHeight = ConsumablesSystem.drawBattlePanel(gameState, x, y, width)
    if consumablesPanelHeight > 0 then
        y = y + consumablesPanelHeight + panelSpacing
    end

    -- 5. Deck Overview Panel (composition only, no previews)
    local deckOverviewHeight = 140
    local deckTitle = "牌疊概況: " .. #gameState.deck .. " 張"
    if gameState.deckPeekEnabled then
        deckTitle = deckTitle .. " 👁️"
    end
    MahjongUI.drawPanel(x, y, width, deckOverviewHeight, deckTitle)
    -- Draw deck composition overview (no specific tile previews)
    MahjongBattle.drawDeckOverview(gameState.deck, x + 10, y + 30, width - 20, 100)
    y = y + deckOverviewHeight + panelSpacing
end

-- New function to draw all main content within its zone
function MahjongBattle.drawMainContent(zone, gameState)
    -- All content here is drawn relative to the zone's x and y
    local x = zone.x
    local y = zone.y
    local w = zone.w
    local h = zone.h

    -- Played Area (now takes up more of the main zone)
    local topAreaHeight = h * 0.5
    MahjongUI.drawPlayedArea(gameState.playedTiles, x + 20, y + 20, w - 40, topAreaHeight, false)

    -- Hand and Buttons (Bottom half of main zone)
    local handY = h - 120 -- Adjusted for new tile size
    local buttonY = handY - 60

    -- Calculate button sizes to fit all 5 buttons within available width
    local availableWidth = w - 40  -- Account for 20px margin on each side
    local numButtons = 5
    local minSpacing = 10
    local buttonWidth = math.floor((availableWidth - (numButtons - 1) * minSpacing) / numButtons)
    buttonWidth = math.min(buttonWidth, 100)  -- Cap at 100px for readability
    local buttonHeight = 40

    -- Draw Hand (with smaller tiles to ensure they fit)
    local handMaxWidth = w - 40
    local newTileScale = 0.6
    local tilesPerRow = math.max(14, math.floor(handMaxWidth / (MahjongUI.DIMENSIONS.TILE_WIDTH * newTileScale + MahjongUI.DIMENSIONS.TILE_MARGIN)))

    -- Prepare animation data for newly drawn tiles
    local handAnimationData = {}
    if gameState.newlyDrawnTiles then
        for _, anim in ipairs(gameState.newlyDrawnTiles) do
            -- Find the current position of this tile in the sorted hand
            for i, handTile in ipairs(gameState.hand) do
                if handTile == anim.tile then
                    handAnimationData[i] = anim
                    break
                end
            end
        end
    end

    -- In drawMainContent, pass the dragging state and animation data to drawSection
    MahjongUI.drawSection("你嘅手牌 (" .. #gameState.hand .. " 隻):", gameState.hand, x + 20, handY, tilesPerRow, gameState.selectedTiles, newTileScale, gameState.isDragging and gameState.draggedTileIndex, handAnimationData)


    -- Draw Buttons
    local mouseX, mouseY = love.mouse.getPosition()
    local buttonSpacing = buttonWidth + minSpacing
    local playButtonX = x + 20
    local playHovered = MahjongUI.isPointInButton(mouseX, mouseY, playButtonX, buttonY, buttonWidth, buttonHeight)
    MahjongUI.drawButton("打牌", playButtonX, buttonY, buttonWidth, buttonHeight, false, playHovered)

    local discardButtonX = playButtonX + buttonSpacing
    local discardHovered = MahjongUI.isPointInButton(mouseX, mouseY, discardButtonX, buttonY, buttonWidth, buttonHeight)
    MahjongUI.drawButton("棄牌", discardButtonX, buttonY, buttonWidth, buttonHeight, false, discardHovered)

    local resetButtonX = discardButtonX + buttonSpacing
    local resetHovered = MahjongUI.isPointInButton(mouseX, mouseY, resetButtonX, buttonY, buttonWidth, buttonHeight)
    MahjongUI.drawButton("重開", resetButtonX, buttonY, buttonWidth, buttonHeight, false, resetHovered)

    local sortButtonX = resetButtonX + buttonSpacing
    local sortHovered = MahjongUI.isPointInButton(mouseX, mouseY, sortButtonX, buttonY, buttonWidth, buttonHeight)
    MahjongUI.drawButton("排序", sortButtonX, buttonY, buttonWidth, buttonHeight, false, sortHovered)

    -- Exit button - only show when battle has ended
    local battleEnded = gameState.battleWon or gameState.battleLost or gameState.challengePassed or gameState.challengeFailed
    if battleEnded then
        local exitButtonX = sortButtonX + buttonSpacing
        local exitHovered = MahjongUI.isPointInButton(mouseX, mouseY, exitButtonX, buttonY, buttonWidth, buttonHeight)
        MahjongUI.drawButton("返回地圖", exitButtonX, buttonY, buttonWidth, buttonHeight, false, exitHovered)
    end
end

-- Mouse press handler for starting drag or selecting tiles
function MahjongBattle.mousepressed(x, y, button)
    if not gameState or button ~= 1 then return end

    -- Handle clicks on result screen exit button
    local battleEnded = gameState.battleWon or gameState.battleLost or gameState.challengePassed or gameState.challengeFailed
    if battleEnded then
        local panelWidth = 400
        local panelHeight = 200
        local screenWidth = love.graphics.getWidth()
        local screenHeight = love.graphics.getHeight()
        local panelX = (screenWidth - panelWidth) / 2
        local panelY = (screenHeight - panelHeight) / 2

        local buttonWidth = 120
        local buttonHeight = 40
        local buttonX = panelX + (panelWidth - buttonWidth) / 2
        local buttonY = panelY + 140

        if MahjongUI.isPointInButton(x, y, buttonX, buttonY, buttonWidth, buttonHeight) then
            MahjongBattle.exitBattle()
            return true
        end
    end

    local layout = calculateLayout(love.graphics.getWidth(), love.graphics.getHeight())
    local mainZone = layout.mainZone
    local sidebarZone = layout.sidebarZone

    -- Close popups first
    if MahjongUI.deckPopupState.isVisible or MahjongUI.discardPopupState.isVisible then
        MahjongUI.hideDeckPopup()
        MahjongUI.hideDiscardPopup()
        return
    end

    -- Check sidebar buttons
    if MahjongBattle.checkSidebarButtons(x, y, sidebarZone) then
        return
    end

    -- Check main action buttons
    if MahjongBattle.checkActionButtons(x, y, mainZone) then
        return
    end

    -- Check for tile click in hand (for potential dragging)
    local handY = mainZone.h - 120
    local handStartX = mainZone.x + 20
    local newTileScale = 0.6
    local handMaxWidth = mainZone.w - 40
    local tilesPerRow = math.max(14, math.floor(handMaxWidth / (MahjongUI.DIMENSIONS.TILE_WIDTH * newTileScale + MahjongUI.DIMENSIONS.TILE_MARGIN)))
    local handTilesY = handY + MahjongUI.fonts.normal:getHeight() + 10

    local tileIndex, tile, tileX, tileY = MahjongUI.getTileAtPosition(x, y, gameState.hand, handStartX, handTilesY, tilesPerRow, newTileScale)

    if tileIndex then
        gameState.potentialDrag = true
        gameState.draggedTile = tile
        gameState.draggedTileIndex = tileIndex
        gameState.dragStartX = x
        gameState.dragStartY = y
        gameState.draggedTileOffsetX = x - tileX
        gameState.draggedTileOffsetY = y - tileY
        gameState.draggedTileVisualX = tileX
        gameState.draggedTileVisualY = tileY
    end
end

function MahjongBattle.mousemoved(x, y, dx, dy)
    if not gameState then return end

    -- Check help button hover
    local layout = calculateLayout(love.graphics.getWidth(), love.graphics.getHeight())
    local HELP_BUTTON_SIZE = 40
    local HELP_BUTTON_PADDING = 20
    local helpButtonX = layout.mainZone.x + layout.mainZone.w - HELP_BUTTON_SIZE - HELP_BUTTON_PADDING
    local helpButtonY = HELP_BUTTON_PADDING
    local dx_help = x - (helpButtonX + HELP_BUTTON_SIZE/2)
    local dy_help = y - (helpButtonY + HELP_BUTTON_SIZE/2)
    local distance = math.sqrt(dx_help*dx_help + dy_help*dy_help)

    showHelpTooltip = distance <= HELP_BUTTON_SIZE/2

    -- Original drag logic
    if not gameState.potentialDrag then return end

    local dragThreshold = 5
    if not gameState.isDragging then
        local dist = math.sqrt((x - gameState.dragStartX)^2 + (y - gameState.dragStartY)^2)
        if dist > dragThreshold then
            gameState.isDragging = true
            -- Clear selection when starting a drag
            MahjongState.clearSelection(gameState)
            Music.playSFX("ui_click")
        end
    end
end

function MahjongBattle.mousereleased(x, y, button)
    if not gameState or button ~= 1 then return end

    if gameState.isDragging then
        -- Drop the tile
        local layout = calculateLayout(love.graphics.getWidth(), love.graphics.getHeight())
        local mainZone = layout.mainZone
        local handY = mainZone.h - 120
        local handStartX = mainZone.x + 20
        local newTileScale = 0.6
        local handMaxWidth = mainZone.w - 40
        local tilesPerRow = math.max(14, math.floor(handMaxWidth / (MahjongUI.DIMENSIONS.TILE_WIDTH * newTileScale + MahjongUI.DIMENSIONS.TILE_MARGIN)))
        local handTilesY = handY + MahjongUI.fonts.normal:getHeight() + 10

        local targetIndex = MahjongUI.getDropIndexAtPosition(x, y, gameState.hand, handStartX, handTilesY, tilesPerRow, newTileScale)

        if targetIndex and gameState.draggedTileIndex then
            local tileToMove = table.remove(gameState.hand, gameState.draggedTileIndex)
            if tileToMove then
                table.insert(gameState.hand, targetIndex, tileToMove)
            end
        end

    elseif gameState.potentialDrag then
        -- This was a click, not a drag. Toggle selection.
        MahjongState.toggleTileSelection(gameState, gameState.draggedTileIndex, "hand")
        Music.playSFX("ui_click")
    end

    -- Reset all drag-related states
    gameState.potentialDrag = false
    gameState.isDragging = false
    gameState.draggedTile = nil
    gameState.draggedTileIndex = nil
end


-- Helper function for sidebar button clicks
function MahjongBattle.checkSidebarButtons(x, y, sidebarZone)
    local sidebarX = sidebarZone.x + 10
    local panelWidth = sidebarZone.w - 20
    local currentY = sidebarZone.y + 10
    local panelSpacing = 15

    -- Calculate Y position dynamically based on NEW sidebar layout
    currentY = currentY + 60 + panelSpacing -- Scoreboard
    if gameState.isChallenge then
        currentY = currentY + 100 + panelSpacing -- Challenge Panel
    end
    currentY = currentY + 100 + panelSpacing -- Weather Panel

    -- Check if consumables panel will be shown
    local hasConsumables = gameState.mainGameState and gameState.mainGameState.playerConsumables
                          and #gameState.mainGameState.playerConsumables > 0
    if hasConsumables then
        currentY = currentY + 120 + panelSpacing -- Consumables Panel
    end

    -- Deck Overview Panel (single clickable panel)
    local deckOverviewY = currentY
    local deckOverviewHeight = 140  -- Match the height from drawSidebar
    if MahjongUI.isPointInButton(x, y, sidebarX, deckOverviewY, panelWidth, deckOverviewHeight) then
        MahjongUI.showDeckPopup()
        return true
    end
    return false
end

-- Helper function for main action button clicks
function MahjongBattle.checkActionButtons(x, y, mainZone)
    local buttonY = mainZone.h - 120 - 60

    -- Use same button sizing calculation as in drawMainContent
    local availableWidth = mainZone.w - 40
    local numButtons = 5
    local minSpacing = 10
    local buttonWidth = math.floor((availableWidth - (numButtons - 1) * minSpacing) / numButtons)
    buttonWidth = math.min(buttonWidth, 100)
    local buttonHeight = 40
    local buttonSpacing = buttonWidth + minSpacing
    local playButtonX = mainZone.x + 20

    if MahjongUI.isPointInButton(x, y, playButtonX, buttonY, buttonWidth, buttonHeight) then
        MahjongState.playSelectedTiles(gameState)
        return true
    end

    local discardButtonX = playButtonX + buttonSpacing
    if MahjongUI.isPointInButton(x, y, discardButtonX, buttonY, buttonWidth, buttonHeight) then
        MahjongState.discardSelectedTiles(gameState)
        return true
    end

    local resetButtonX = discardButtonX + buttonSpacing
    if MahjongUI.isPointInButton(x, y, resetButtonX, buttonY, buttonWidth, buttonHeight) then
        gameState = MahjongState.resetGame(gameState)
        
        -- Check for angry_sean dialogue trigger (after 2+ restarts)
        if gameState.restartCount > 2 then
            CutinDialogue.show("dialogue", "angry_sean")
        end
        
        return true
    end

    local sortButtonX = resetButtonX + buttonSpacing
    if MahjongUI.isPointInButton(x, y, sortButtonX, buttonY, buttonWidth, buttonHeight) then
        gameState.hand = MahjongTiles.sortTiles(gameState.hand)
        return true
    end

    -- Exit button click handler - only when battle has ended
    local battleEnded = gameState.battleWon or gameState.battleLost or gameState.challengePassed or gameState.challengeFailed
    if battleEnded then
        local exitButtonX = sortButtonX + buttonSpacing  -- Same positioning as in draw function
        if MahjongUI.isPointInButton(x, y, exitButtonX, buttonY, buttonWidth, buttonHeight) then
            -- Call the same logic as ESC key press
            MahjongBattle.exitBattle()
            return true
        end
    end

    return false
end

-- Exit battle function (shared by ESC key and exit button)
function MahjongBattle.exitBattle()
    -- Safely handle screen transition with proper cleanup
    local success, err = pcall(function()
        print("🔙 Returning to progression")

        -- Clean up any resources before transition
        if gameState and gameState.cleanupCallback then
            gameState.cleanupCallback()
        end

        -- If battle has ended, go to progression screen and advance story
        if gameState and (gameState.battleWon or gameState.battleLost or gameState.challengePassed or gameState.challengeFailed) then
            -- Return to progression for all battles
            if gameState.mainGameState then
                if gameState.battleWon or gameState.challengePassed then
                    -- Mark battle as completed and return to progression
                    local ProgressionCards = require("progression_cards")
                    ProgressionCards.markBattleCompleted(gameState.mainGameState)

                    gameState.mainGameState.screen = "progression"
                    local ProgressionScreen = require("progression_screen")
                    ProgressionScreen.init(gameState.mainGameState)
                else
                    -- On loss, just go to progression screen
                    gameState.mainGameState.screen = "progression"
                    local ProgressionScreen = require("progression_screen")
                    ProgressionScreen.init(gameState.mainGameState)
                end
            else
                local success2, err2 = pcall(function()
                    -- Use global setGameScreen function directly
                    setGameScreen("progression")
                end)
                if not success2 then
                    print("❌ Failed to set screen:", err2)
                end
            end
            return
        end

        -- Otherwise normal exit behavior - return to progression
        local success3, err3 = pcall(function()
            -- Use global setGameScreen function directly
            setGameScreen("progression")
        end)

        if not success3 then
            print("❌ Failed to set screen (fallback):", err3)
            -- Last resort - quit gracefully instead of crashing
            love.event.quit()
        end
    end)

    if not success then
        print("❌ Critical error during screen transition:", err)
        -- Prevent crash by graceful quit
        love.event.quit()
    end
end

-- Get current game state (for compatibility)
function MahjongBattle.getGameState()
    return gameState
end

-- Legacy function compatibility
function MahjongBattle.getBattleState()
    return gameState
end

-- Check if battle is active
function MahjongBattle.isActive()
    return gameState ~= nil
end

-- Get battle results
function MahjongBattle.getResults()
    if not gameState then
        return {
            score = 0,
            wins = 0,
            fan = 0
        }
    end

    local stats = MahjongState.getGameStats(gameState)
    return {
        score = stats.score,
        wins = stats.wins,
        fan = stats.totalFan
    }
end

-- Start a specific battle type (convenience function for other modules)
function MahjongBattle.startBattle(mainGameState, battleType, customConfig)
    battleType = battleType or "normal"

    -- Create challenge data if custom config provided
    local challengeData = nil
    if customConfig then
        challengeData = {
            name = customConfig.name or ("Custom " .. battleType),
            battleType = battleType,
            targetFan = customConfig.targetFan,
            hands = customConfig.maxHands
        }
    end

    -- Initialize with the specified battle type
    MahjongBattle.init(mainGameState, challengeData, battleType)

    print("🎲 Started " .. battleType .. " battle")
    if gameState and gameState.battleConfig then
        print("   " .. gameState.battleConfig.type .. ": " .. BattleConfig.getBattleConfig(battleType).name)
    end
end

-- Get available battle types for progression screen
function MahjongBattle.getAvailableBattleTypes(playerLevel)
    return BattleConfig.getBattleTypesForLevel(playerLevel or 1)
end

-- Get battle information for UI display
function MahjongBattle.getBattleInfo(battleType)
    local config = BattleConfig.getBattleConfig(battleType)
    if not config then return nil end

    return {
        name = config.name,
        description = config.description,
        difficulty = config.difficulty,
        targetFan = config.config.targetFan,
        maxHands = config.config.maxHands,
        rewards = config.rewards,
        penalties = config.penalties
    }
end

-- Draw deck composition overview (counts, not specific tiles)
function MahjongBattle.drawDeckOverview(tiles, x, y, maxWidth, maxHeight)
    if not tiles or #tiles == 0 then
        love.graphics.setColor(MahjongUI.COLORS.TEXT_SECONDARY)
        love.graphics.setFont(MahjongUI.fonts.small)
        love.graphics.printf("空", x, y + maxHeight/2 - 10, maxWidth, "center")
        return
    end

    -- Count tiles by type
    local counts = {
        dots = 0,     -- 筒子
        bamboos = 0,  -- 條子
        chars = 0,    -- 萬子
        winds = 0,    -- 風牌
        dragons = 0   -- 三元牌
    }

    for _, tile in ipairs(tiles) do
        if tile.suit == "dots" then
            counts.dots = counts.dots + 1
        elseif tile.suit == "bamboos" then
            counts.bamboos = counts.bamboos + 1
        elseif tile.suit == "chars" then
            counts.chars = counts.chars + 1
        elseif tile.suit == "winds" or tile.suit == "東" or tile.suit == "南" or tile.suit == "西" or tile.suit == "北" then
            counts.winds = counts.winds + 1
        elseif tile.suit == "dragons" or tile.suit == "紅中" or tile.suit == "青發" or tile.suit == "白板" then
            counts.dragons = counts.dragons + 1
        end
    end

    -- Draw the overview with visual icons
    love.graphics.setFont(MahjongUI.fonts.small)
    local lineHeight = MahjongUI.fonts.small:getHeight() + 2
    local currentY = y + 5

    -- Dots (筒子)
    if counts.dots > 0 then
        love.graphics.setColor(0.3, 0.6, 0.9, 1) -- Blue for dots
        love.graphics.printf("⚫ 筒: " .. counts.dots, x + 5, currentY, maxWidth - 10, "left")
        currentY = currentY + lineHeight
    end

    -- Bamboos (條子)
    if counts.bamboos > 0 then
        love.graphics.setColor(0.3, 0.8, 0.3, 1) -- Green for bamboos
        love.graphics.printf("🎋 條: " .. counts.bamboos, x + 5, currentY, maxWidth - 10, "left")
        currentY = currentY + lineHeight
    end

    -- Characters (萬子)
    if counts.chars > 0 then
        love.graphics.setColor(0.9, 0.3, 0.3, 1) -- Red for characters
        love.graphics.printf("萬 萬: " .. counts.chars, x + 5, currentY, maxWidth - 10, "left")
        currentY = currentY + lineHeight
    end

    -- Winds (風牌)
    if counts.winds > 0 then
        love.graphics.setColor(0.8, 0.8, 0.3, 1) -- Yellow for winds
        love.graphics.printf("🌪 風: " .. counts.winds, x + 5, currentY, maxWidth - 10, "left")
        currentY = currentY + lineHeight
    end

    -- Dragons (三元牌)
    if counts.dragons > 0 then
        love.graphics.setColor(0.8, 0.3, 0.8, 1) -- Purple for dragons
        love.graphics.printf("🐲 元: " .. counts.dragons, x + 5, currentY, maxWidth - 10, "left")
        currentY = currentY + lineHeight
    end
end

-- [DISABLED] Draw a visual preview of tiles from a deck/pile (for special abilities)
function MahjongBattle.drawDeckPreview_DISABLED(tiles, x, y, maxWidth, maxHeight)
    if not tiles or #tiles == 0 then
        -- Draw empty state
        love.graphics.setColor(MahjongUI.COLORS.TEXT_SECONDARY)
        love.graphics.setFont(MahjongUI.fonts.small)
        love.graphics.printf("空", x, y + maxHeight/2 - 10, maxWidth, "center")
        return
    end

    -- Calculate how many tiles we can fit
    local tileScale = 0.4  -- Small tiles for preview
    local tileWidth = MahjongUI.DIMENSIONS.TILE_WIDTH * tileScale
    local tileHeight = MahjongUI.DIMENSIONS.TILE_HEIGHT * tileScale
    local tileMargin = 3
    local maxTilesPerRow = math.floor(maxWidth / (tileWidth + tileMargin))
    local maxRows = math.floor(maxHeight / (tileHeight + tileMargin))
    local maxTilesToShow = math.min(maxTilesPerRow * maxRows, #tiles, 12) -- Show max 12 tiles

    -- Show a sample of tiles from different parts of the deck
    local tilesToShow = {}
    if #tiles <= maxTilesToShow then
        -- Show all tiles if few enough
        for i = 1, #tiles do
            table.insert(tilesToShow, tiles[i])
        end
    else
        -- Show a representative sample: some from start, middle, and end
        local step = math.floor(#tiles / maxTilesToShow)
        for i = 1, maxTilesToShow do
            local index = ((i - 1) * step) + 1
            if index <= #tiles then
                table.insert(tilesToShow, tiles[index])
            end
        end
    end

    -- Draw the tiles
    local currentX = x
    local currentY = y
    local tilesInRow = 0

    for i, tile in ipairs(tilesToShow) do
        -- Check if we need to move to next row
        if tilesInRow >= maxTilesPerRow then
            currentX = x
            currentY = currentY + tileHeight + tileMargin
            tilesInRow = 0

            -- Stop if we've exceeded max height
            if currentY + tileHeight > y + maxHeight then
                break
            end
        end

        -- Draw the tile
        MahjongUI.drawTile(tile, currentX, currentY, false, tileScale)

        currentX = currentX + tileWidth + tileMargin
        tilesInRow = tilesInRow + 1
    end

    -- Draw "..." indicator if there are more tiles
    if #tiles > maxTilesToShow then
        love.graphics.setColor(MahjongUI.COLORS.TEXT_SECONDARY)
        love.graphics.setFont(MahjongUI.fonts.small)
        love.graphics.print("...", currentX + 5, currentY + tileHeight/2)
    end
end

-- Draw battle result overlay
function MahjongBattle.drawBattleResult(screenWidth, screenHeight, isWin, title, subtitle)
    -- Semi-transparent overlay
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    -- Result panel
    local panelWidth = 400
    local panelHeight = 200
    local panelX = (screenWidth - panelWidth) / 2
    local panelY = (screenHeight - panelHeight) / 2

    -- Panel background
    if isWin then
        love.graphics.setColor(0.2, 0.6, 0.3, 0.9) -- Green for wins
    else
        love.graphics.setColor(0.6, 0.2, 0.2, 0.9) -- Red for losses
    end
    love.graphics.rectangle("fill", panelX, panelY, panelWidth, panelHeight, 10)

    -- Panel border
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", panelX, panelY, panelWidth, panelHeight, 10)

    -- Title
    local titleFont = MahjongUI.fonts.title or love.graphics.newFont(24)
    love.graphics.setFont(titleFont)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(title, panelX, panelY + 40, panelWidth, "center")

    -- Subtitle
    local normalFont = MahjongUI.fonts.normal or love.graphics.newFont(16)
    love.graphics.setFont(normalFont)
    love.graphics.setColor(0.9, 0.9, 0.9, 1)
    love.graphics.printf(subtitle, panelX, panelY + 80, panelWidth, "center")

    -- Rewards/Penalties text
    if gameState and gameState.mainGameState then
        local rewards = BattleConfig.calculateRewards(gameState, isWin)
        local rewardText = ""

        if isWin then
            if rewards.money and rewards.money > 0 then
                rewardText = rewardText .. "獲得金錢: +$" .. rewards.money .. "\n"
            end
            if rewards.xp and rewards.xp > 0 then
                rewardText = rewardText .. "獲得經驗: +" .. rewards.xp .. "XP\n"
            end
            if rewards.specialItems and #rewards.specialItems > 0 then
                rewardText = rewardText .. "特殊獎勵: " .. table.concat(rewards.specialItems, ", ")
            end
        else
            if rewards.money and rewards.money < 0 then
                rewardText = "失去金錢: $" .. math.abs(rewards.money)
            end
        end

        if rewardText ~= "" then
            love.graphics.setColor(1, 1, 0.8, 1)
            love.graphics.printf(rewardText, panelX, panelY + 110, panelWidth, "center")
        end
    end

    -- Exit button on result screen
    local buttonWidth = 120
    local buttonHeight = 40
    local buttonX = panelX + (panelWidth - buttonWidth) / 2
    local buttonY = panelY + 140

    local mouseX, mouseY = love.mouse.getPosition()
    local exitHovered = MahjongUI.isPointInButton(mouseX, mouseY, buttonX, buttonY, buttonWidth, buttonHeight)
    MahjongUI.drawButton("返回地圖", buttonX, buttonY, buttonWidth, buttonHeight, false, exitHovered)

    -- Continue instruction
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.printf("點擊按鈕或按 Enter 鍵返回地圖", panelX, panelY + 190, panelWidth, "center")

    -- Reset graphics state
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1, 1)
end

-- Cleanup function
function MahjongBattle.cleanup()
    gameState = nil
end

return MahjongBattle
