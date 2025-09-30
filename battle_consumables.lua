-- Enhanced Battle Consumables System
-- Powerful consumables specifically designed for battle use

local BattleConsumables = {}

-- Enhanced battle consumable definitions
BattleConsumables.BATTLE_ITEMS = {
    -- === 戰術系列 (Tactical Series) ===
    {
        id = "tactical_tea",
        name = "戰術奶茶",
        nameEng = "Tactical Tea",
        description = "預覽牌庫接下來3張牌，然後抽2張牌",
        descriptionEng = "Preview next 3 tiles in deck, then draw 2 tiles",
        price = 60,
        rarity = "uncommon",
        category = "intelligence",
        type = "battle_consumable",
        battleEffect = function(gameState, battleState)
            local message = ""

            -- Peek at next few tiles in deck
            if battleState.deck and #battleState.deck >= 3 then
                message = message .. "窺探了牌庫接下來3張牌！"
                -- Set flag to show next 3 tiles briefly
                battleState.showNextTiles = 3
                battleState.showNextTilesTimer = 5 -- Show for 5 seconds
            end

            -- Draw 2 tiles
            if battleState.deck and #battleState.deck >= 2 then
                for i = 1, 2 do
                    if #battleState.deck > 0 then
                        table.insert(battleState.hand, table.remove(battleState.deck, 1))
                    end
                end
                message = message .. " 額外抽了2張牌！"
            end

            return message ~= "" and message or "戰術奶茶生效！"
        end
    },

    {
        id = "phoenix_roll",
        name = "鳳凰卷",
        nameEng = "Phoenix Roll",
        description = "從棄牌堆選擇一隻牌回到手牌",
        descriptionEng = "Choose one tile from discard pile to return to hand",
        price = 80,
        rarity = "rare",
        category = "recovery",
        type = "battle_consumable",
        battleEffect = function(gameState, battleState)
            if battleState.discardPile and #battleState.discardPile > 0 then
                -- Get a random valuable tile from discard pile
                local bestTile = nil
                local bestValue = 0

                for _, tile in ipairs(battleState.discardPile) do
                    local value = tile.points or tile.value or 1
                    if value > bestValue then
                        bestValue = value
                        bestTile = tile
                    end
                end

                if bestTile then
                    -- Remove from discard pile and add to hand
                    for i, tile in ipairs(battleState.discardPile) do
                        if tile == bestTile then
                            table.remove(battleState.discardPile, i)
                            table.insert(battleState.hand, bestTile)
                            return "從棄牌堆取回了 " .. (bestTile.name or "牌") .. "！"
                        end
                    end
                end
            end

            return "棄牌堆沒有可用的牌"
        end
    },

    {
        id = "time_freeze_bun",
        name = "時停包子",
        nameEng = "Time Freeze Bun",
        description = "本回合可以多打一組牌",
        descriptionEng = "Can play one extra tile combination this turn",
        price = 100,
        rarity = "rare",
        category = "action",
        type = "battle_consumable",
        battleEffect = function(gameState, battleState)
            battleState.extraPlaysThisTurn = (battleState.extraPlaysThisTurn or 0) + 1
            return "獲得額外打牌機會！時間暫停"
        end
    },

    -- === 增強系列 (Enhancement Series) ===
    {
        id = "golden_dim_sum",
        name = "黃金點心",
        nameEng = "Golden Dim Sum",
        description = "下一組打出的牌獲得雙倍番數",
        descriptionEng = "Next combination played gains double fan value",
        price = 120,
        rarity = "rare",
        category = "multiplier",
        type = "battle_consumable",
        battleEffect = function(gameState, battleState)
            battleState.nextCombinationDoubleFan = true
            return "下次組合將獲得雙倍番數！黃金點心威力"
        end
    },

    {
        id = "luck_incense",
        name = "幸運香",
        nameEng = "Luck Incense",
        description = "接下來3次抽牌都從3張中選1張",
        descriptionEng = "Next 3 draws let you choose from 3 tiles",
        price = 90,
        rarity = "uncommon",
        category = "choice",
        type = "battle_consumable",
        battleEffect = function(gameState, battleState)
            battleState.luckyDrawsRemaining = 3
            return "獲得3次幸運抽牌！香火保佑"
        end
    },

    {
        id = "mahjong_master_wisdom",
        name = "麻將宗師智慧",
        nameEng = "Mahjong Master Wisdom",
        description = "顯示手牌最佳組合建議",
        descriptionEng = "Shows optimal combination suggestions for current hand",
        price = 75,
        rarity = "uncommon",
        category = "guidance",
        type = "battle_consumable",
        battleEffect = function(gameState, battleState)
            battleState.showOptimalCombinations = true
            return "宗師智慧開啟！最佳組合提示激活"
        end
    },

    -- === 混亂系列 (Chaos Series) ===
    {
        id = "typhoon_shelter_crab",
        name = "避風塘炒蟹",
        nameEng = "Typhoon Shelter Crab",
        description = "隨機改變5隻手牌的花色",
        descriptionEng = "Randomly change suits of 5 tiles in hand",
        price = 70,
        rarity = "uncommon",
        category = "chaos",
        type = "battle_consumable",
        battleEffect = function(gameState, battleState)
            if not battleState.hand or #battleState.hand == 0 then
                return "手牌為空"
            end

            local suits = {"characters", "circles", "bamboos"}
            local changed = 0

            for i = 1, math.min(5, #battleState.hand) do
                local randomIndex = math.random(#battleState.hand)
                local tile = battleState.hand[randomIndex]

                if tile.suit == "characters" or tile.suit == "circles" or tile.suit == "bamboos" then
                    local newSuit = suits[math.random(#suits)]
                    tile.suit = newSuit
                    changed = changed + 1
                end
            end

            return "改變了 " .. changed .. " 隻牌的花色！避風塘威力"
        end
    },

    {
        id = "randomizer_ramen",
        name = "隨機拉麵",
        nameEng = "Randomizer Ramen",
        description = "重新分配手牌數字，保持花色不變",
        descriptionEng = "Redistribute hand tile numbers, keeping suits",
        price = 85,
        rarity = "uncommon",
        category = "chaos",
        type = "battle_consumable",
        battleEffect = function(gameState, battleState)
            if not battleState.hand or #battleState.hand == 0 then
                return "手牌為空"
            end

            -- Collect all values and redistribute them
            local values = {}
            local eligibleTiles = {}

            for _, tile in ipairs(battleState.hand) do
                if tile.value and type(tile.value) == "number" then
                    table.insert(values, tile.value)
                    table.insert(eligibleTiles, tile)
                end
            end

            -- Shuffle values
            for i = #values, 2, -1 do
                local j = math.random(i)
                values[i], values[j] = values[j], values[i]
            end

            -- Reassign values
            for i, tile in ipairs(eligibleTiles) do
                if values[i] then
                    tile.value = values[i]
                end
            end

            return "重新分配了 " .. #values .. " 隻牌的數字！拉麵大變身"
        end
    },

    -- === 傳奇系列 (Legendary Series) ===
    {
        id = "dragon_emperor_feast",
        name = "龍皇盛宴",
        nameEng = "Dragon Emperor Feast",
        description = "立即完成一個字牌組合並獲得3番",
        descriptionEng = "Instantly complete a honor tile combination and gain 3 fan",
        price = 250,
        rarity = "legendary",
        category = "instant_win",
        type = "battle_consumable",
        battleEffect = function(gameState, battleState)
            -- Add honor tile combination to played tiles
            local honorCombo = {
                {suit = "dragons", value = "中", name = "紅中"},
                {suit = "dragons", value = "發", name = "發財"},
                {suit = "dragons", value = "白", name = "白板"}
            }

            if battleState.playedTiles then
                for _, tile in ipairs(honorCombo) do
                    table.insert(battleState.playedTiles, tile)
                end
            end

            -- Add 3 fan to total
            battleState.totalFan = (battleState.totalFan or 0) + 3

            return "龍皇盛宴！自動完成三元組合，獲得3番"
        end
    },

    {
        id = "mahjong_god_dice",
        name = "麻將神骰子",
        nameEng = "Mahjong God Dice",
        description = "選擇一個完美組合直接加入打牌區",
        descriptionEng = "Choose a perfect combination to add directly to play area",
        price = 300,
        rarity = "legendary",
        category = "instant_win",
        type = "battle_consumable",
        battleEffect = function(gameState, battleState)
            -- Add a perfect sequence
            local perfectSequence = {
                {suit = "characters", value = 1, name = "一萬"},
                {suit = "characters", value = 2, name = "二萬"},
                {suit = "characters", value = 3, name = "三萬"}
            }

            if battleState.playedTiles then
                for _, tile in ipairs(perfectSequence) do
                    table.insert(battleState.playedTiles, tile)
                end
            end

            -- Add 2 fan for perfect sequence
            battleState.totalFan = (battleState.totalFan or 0) + 2

            return "麻將神骰子！完美順子降臨，獲得2番"
        end
    },

    -- === 策略系列 (Strategy Series) ===
    {
        id = "hand_optimizer",
        name = "手牌優化器",
        nameEng = "Hand Optimizer",
        description = "重新排列手牌，創造更好的組合機會",
        descriptionEng = "Rearrange hand tiles to create better combination opportunities",
        price = 70,
        rarity = "uncommon",
        category = "optimization",
        type = "battle_consumable",
        battleEffect = function(gameState, battleState)
            if not battleState.hand or #battleState.hand == 0 then
                return "手牌為空"
            end

            -- Optimize hand by grouping similar tiles together
            local suits = {}
            local honors = {}

            for _, tile in ipairs(battleState.hand) do
                if tile.suit == "winds" or tile.suit == "dragons" then
                    table.insert(honors, tile)
                else
                    suits[tile.suit] = suits[tile.suit] or {}
                    table.insert(suits[tile.suit], tile)
                end
            end

            -- Sort each suit group by value
            for suit, tiles in pairs(suits) do
                table.sort(tiles, function(a, b)
                    return (a.value or 1) < (b.value or 1)
                end)
            end

            -- Rebuild hand with optimized order
            battleState.hand = {}
            for _, suitTiles in pairs(suits) do
                for _, tile in ipairs(suitTiles) do
                    table.insert(battleState.hand, tile)
                end
            end
            for _, tile in ipairs(honors) do
                table.insert(battleState.hand, tile)
            end

            return "手牌已優化排列！組合機會增加"
        end
    },

    {
        id = "deck_scanner",
        name = "牌庫掃描器",
        nameEng = "Deck Scanner",
        description = "顯示牌庫中剩餘的特定牌型數量",
        descriptionEng = "Show count of specific tile types remaining in deck",
        price = 55,
        rarity = "common",
        category = "information",
        type = "battle_consumable",
        battleEffect = function(gameState, battleState)
            if not battleState.deck or #battleState.deck == 0 then
                return "牌庫為空"
            end

            -- Count remaining tiles by type
            local counts = {}
            for _, tile in ipairs(battleState.deck) do
                local key = tile.suit .. "_" .. (tile.value or "special")
                counts[key] = (counts[key] or 0) + 1
            end

            -- Show scan results for 10 seconds
            battleState.deckScanResults = counts
            battleState.deckScanTimer = 10

            return "牌庫掃描完成！顯示剩餘牌型統計"
        end
    },

    {
        id = "tile_transmuter",
        name = "瓦片變換器",
        nameEng = "Tile Transmuter",
        description = "將手牌中一隻牌變換成最需要的牌",
        descriptionEng = "Transform one tile in hand to the most needed tile",
        price = 90,
        rarity = "rare",
        category = "transformation",
        type = "battle_consumable",
        battleEffect = function(gameState, battleState)
            if not battleState.hand or #battleState.hand == 0 then
                return "手牌為空"
            end

            -- Find least useful tile (lowest value or duplicate)
            local leastUseful = nil
            local leastValue = math.huge

            for _, tile in ipairs(battleState.hand) do
                local value = tile.points or tile.value or 1
                if value < leastValue then
                    leastValue = value
                    leastUseful = tile
                end
            end

            if leastUseful then
                -- Transform to a useful honor tile
                leastUseful.suit = "dragons"
                leastUseful.value = "中"
                leastUseful.name = "紅中"
                leastUseful.points = 15

                return "變換了1隻牌成紅中！價值提升"
            end

            return "無法找到可變換的牌"
        end
    },

    -- === 救命系列 (Emergency Series) ===
    {
        id = "emergency_wonton",
        name = "救命雲吞",
        nameEng = "Emergency Wonton",
        description = "重置本局遊戲，保留已獲得的番數",
        descriptionEng = "Reset current game, keeping earned fan",
        price = 150,
        rarity = "epic",
        category = "reset",
        type = "battle_consumable",
        battleEffect = function(gameState, battleState)
            local savedFan = battleState.totalFan or 0

            -- Reset game state but keep fan
            if battleState.hand then
                battleState.hand = {}
            end
            if battleState.playedTiles then
                battleState.playedTiles = {}
            end

            -- Redeal starting hand
            local MahjongDeck = require("mahjong_deck")
            if battleState.deck then
                local hands, remainingDeck = MahjongDeck.dealHands(battleState.deck, 1, 14)
                battleState.hand = hands[1] or {}
                battleState.deck = remainingDeck
            end

            -- Restore fan count
            battleState.totalFan = savedFan

            return "救命雲吞生效！重新開始但保留 " .. savedFan .. " 番"
        end
    },

    {
        id = "miracle_milk_tea",
        name = "奇蹟奶茶",
        nameEng = "Miracle Milk Tea",
        description = "如果即將失敗，自動獲得勝利所需番數",
        descriptionEng = "If about to lose, automatically gain required fan for victory",
        price = 200,
        rarity = "epic",
        category = "miracle",
        type = "battle_consumable",
        battleEffect = function(gameState, battleState)
            local currentFan = battleState.totalFan or 0
            local requiredFan = battleState.targetFan or 3

            if currentFan < requiredFan then
                local neededFan = requiredFan - currentFan
                battleState.totalFan = requiredFan
                return "奇蹟奶茶！獲得 " .. neededFan .. " 番，達到勝利條件"
            else
                -- Still provide some benefit
                battleState.totalFan = currentFan + 1
                return "奇蹟奶茶！額外獲得1番"
            end
        end
    }
}

-- Get battle consumables by rarity
function BattleConsumables.getBattleConsumablesByRarity(rarity)
    local items = {}
    for _, item in ipairs(BattleConsumables.BATTLE_ITEMS) do
        if item.rarity == rarity then
            table.insert(items, item)
        end
    end
    return items
end

-- Generate battle consumables for shop
function BattleConsumables.generateShopBattleConsumables(playerLevel)
    local availableItems = {}

    -- Rarity chances based on player level
    local rarityChances = {
        common = 40,
        uncommon = 30,
        rare = 20,
        epic = 8,
        legendary = 2
    }

    -- Adjust based on player level
    if playerLevel >= 3 then
        rarityChances.rare = 30
        rarityChances.epic = 12
    end
    if playerLevel >= 5 then
        rarityChances.epic = 20
        rarityChances.legendary = 5
    end

    for _, item in ipairs(BattleConsumables.BATTLE_ITEMS) do
        local chance = rarityChances[item.rarity] or 0
        if math.random(100) <= chance then
            table.insert(availableItems, item)
        end
    end

    return availableItems
end

-- Use battle consumable
function BattleConsumables.useBattleConsumable(consumable, gameState, battleState)
    if not consumable or not consumable.battleEffect then
        return false, "無效的戰鬥道具"
    end

    local success, result = pcall(consumable.battleEffect, gameState, battleState)

    if success then
        return true, result or "戰鬥道具生效！"
    else
        return false, "道具使用失敗: " .. tostring(result)
    end
end

-- Get battle consumable by ID
function BattleConsumables.getBattleConsumableById(id)
    for _, item in ipairs(BattleConsumables.BATTLE_ITEMS) do
        if item.id == id then
            return item
        end
    end
    return nil
end

-- Get all battle consumables
function BattleConsumables.getAllBattleConsumables()
    return BattleConsumables.BATTLE_ITEMS
end

return BattleConsumables