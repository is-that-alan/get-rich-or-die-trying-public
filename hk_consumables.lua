-- Hong Kong Consumables System
-- Items that can be used during mahjong battles and purchased in shops

local HKConsumables = {}

-- Consumable item definitions
HKConsumables.ITEMS = {
    -- === 茶餐廳系列 (Cha Chaan Teng Series) ===
    {
        id = "milk_tea",
        name = "港式奶茶",
        nameEng = "HK Milk Tea",
        description = "提神醒腦，增加專注力",
        descriptionEng = "Boosts focus and concentration",
        price = 25,
        rarity = "common",
        category = "drink",
        effect = function(gameState, battleState)
            -- Draw 2 extra tiles this turn
            if battleState and battleState.deck and #battleState.deck >= 2 then
                local drawnTiles = {}
                for i = 1, 2 do
                    if #battleState.deck > 0 then
                        table.insert(drawnTiles, table.remove(battleState.deck, 1))
                        table.insert(battleState.hand, drawnTiles[#drawnTiles])
                    end
                end
                return "抽了 " .. #drawnTiles .. " 張牌！奶茶好正！"
            end
            return "抽牌失敗"
        end
    },

    {
        id = "pineapple_bun",
        name = "菠蘿包",
        nameEng = "Pineapple Bun",
        description = "香港人的comfort food，回復體力",
        descriptionEng = "Hong Kong comfort food, restores energy",
        price = 20,
        rarity = "common",
        category = "food",
        effect = function(gameState, battleState)
            -- Allows you to undo last tile play this battle
            if battleState then
                battleState.canUndo = true
                return "可以悔棋一次！菠蘿包給你第二次機會"
            end
            return "效果激活"
        end
    },

    {
        id = "instant_noodles",
        name = "即食麵",
        nameEng = "Instant Noodles",
        description = "窮學生恩物，便宜實用",
        descriptionEng = "Poor student's best friend, cheap and practical",
        price = 15,
        rarity = "common",
        category = "food",
        effect = function(gameState, battleState)
            -- Shuffle hand and redraw same number of tiles
            if battleState and battleState.hand and battleState.deck then
                local handSize = #battleState.hand
                -- Put hand back into deck
                for _, tile in ipairs(battleState.hand) do
                    table.insert(battleState.deck, tile)
                end
                battleState.hand = {}

                -- Shuffle deck
                local MahjongDeck = require("mahjong_deck")
                battleState.deck = MahjongDeck.shuffleDeck(battleState.deck)

                -- Draw new hand
                for i = 1, math.min(handSize, #battleState.deck) do
                    table.insert(battleState.hand, table.remove(battleState.deck, 1))
                end

                return "重新洗牌！即食麵拯救爛手牌"
            end
            return "洗牌失敗"
        end
    },

    -- === 街頭小食系列 (Street Food Series) ===
    {
        id = "fish_balls",
        name = "魚蛋",
        nameEng = "Fish Balls",
        description = "街頭小食之王，增強運氣",
        descriptionEng = "King of street food, boosts luck",
        price = 30,
        rarity = "common",
        category = "snack",
        effect = function(gameState, battleState)
            -- Next tile draw shows you 3 options to choose from
            if battleState then
                battleState.nextDrawShowsOptions = 3
                return "下次抽牌可以選擇！魚蛋帶來好運"
            end
            return "幸運加成激活"
        end
    },

    {
        id = "curry_fish_balls",
        name = "咖喱魚蛋",
        nameEng = "Curry Fish Balls",
        description = "辣味十足，刺激思維",
        descriptionEng = "Spicy kick stimulates thinking",
        price = 35,
        rarity = "uncommon",
        category = "snack",
        effect = function(gameState, battleState)
            -- Allows you to see opponent's next 3 tiles (if applicable)
            -- For single player, reveals next 3 tiles in deck
            if battleState and battleState.deck then
                local preview = {}
                for i = 1, math.min(3, #battleState.deck) do
                    table.insert(preview, battleState.deck[i])
                end
                battleState.deckPreview = preview
                return "偷看牌疊頭 " .. #preview .. " 張牌！辣味開眼界"
            end
            return "偷看失敗"
        end
    },

    -- === 茶樓點心系列 (Dim Sum Series) ===
    {
        id = "har_gow",
        name = "蝦餃",
        nameEng = "Har Gow",
        description = "茶樓經典，提升手牌質量",
        descriptionEng = "Dim sum classic, improves hand quality",
        price = 50,
        rarity = "uncommon",
        category = "dimsum",
        effect = function(gameState, battleState)
            -- Discard up to 2 tiles and draw 2 new ones
            if battleState then
                battleState.canDiscardAndDraw = 2
                return "可以換 2 張牌！蝦餃點石成金"
            end
            return "換牌功能激活"
        end
    },

    {
        id = "siu_mai",
        name = "燒賣",
        nameEng = "Siu Mai",
        description = "茶樓必點，增強組合能力",
        descriptionEng = "Dim sum essential, enhances combinations",
        price = 45,
        rarity = "uncommon",
        category = "dimsum",
        effect = function(gameState, battleState)
            -- Allows one invalid combination to be played this battle
            if battleState then
                battleState.canPlayInvalidOnce = true
                return "可以打出一次無效組合！燒賣開綠燈"
            end
            return "特殊規則激活"
        end
    },

    -- === 高級食品系列 (Premium Food Series) ===
    {
        id = "abalone",
        name = "鮑魚",
        nameEng = "Abalone",
        description = "名貴海鮮，大幅提升能力",
        descriptionEng = "Premium seafood, greatly enhances abilities",
        price = 150,
        rarity = "rare",
        category = "premium",
        effect = function(gameState, battleState)
            -- Gain +2 fan for this battle
            if battleState then
                battleState.bonusFan = (battleState.bonusFan or 0) + 2
                return "本局番數 +2！鮑魚帶來豪華加成"
            end
            return "番數加成激活"
        end
    },

    {
        id = "bird_nest",
        name = "燕窩",
        nameEng = "Bird's Nest",
        description = "滋補聖品，回復所有狀態",
        descriptionEng = "Nourishing delicacy, restores all status",
        price = 200,
        rarity = "rare",
        category = "premium",
        effect = function(gameState, battleState)
            -- Remove all negative effects and gain multiple bonuses
            if battleState then
                battleState.negativeEffects = {}
                battleState.canUndo = true
                battleState.bonusFan = (battleState.bonusFan or 0) + 1
                battleState.nextDrawShowsOptions = 2
                return "所有負面效果清除！燕窩全面恢復"
            end
            return "全面回復"
        end
    },

    -- === 飲料系列 (Beverage Series) ===
    {
        id = "lemon_tea",
        name = "檸檬茶",
        nameEng = "Lemon Tea",
        description = "清香怡人，清除負面狀態",
        descriptionEng = "Refreshing, removes negative effects",
        price = 30,
        rarity = "common",
        category = "drink",
        effect = function(gameState, battleState)
            -- Remove one random negative effect
            if battleState and battleState.negativeEffects and #battleState.negativeEffects > 0 then
                table.remove(battleState.negativeEffects, math.random(#battleState.negativeEffects))
                return "清除一個負面狀態！檸檬茶好清新"
            end
            return "無負面狀態可清除"
        end
    },

    {
        id = "herbal_tea",
        name = "涼茶",
        nameEng = "Herbal Tea",
        description = "去火良藥，穩定心情",
        descriptionEng = "Cooling medicine, stabilizes mood",
        price = 25,
        rarity = "common",
        category = "drink",
        effect = function(gameState, battleState)
            -- Prevents next negative effect
            if battleState then
                battleState.immuneToNextNegative = true
                return "免疫下一個負面效果！涼茶護體"
            end
            return "負面免疫激活"
        end
    },

    -- === 特殊道具系列 (Special Items Series) ===
    {
        id = "octopus_card",
        name = "八達通卡",
        nameEng = "Octopus Card",
        description = "香港必備，快速行動",
        descriptionEng = "HK essential, enables quick actions",
        price = 40,
        rarity = "uncommon",
        category = "utility",
        effect = function(gameState, battleState)
            -- Take an extra turn this round
            if battleState then
                battleState.extraTurn = true
                return "額外一個回合！八達通嘟一聲"
            end
            return "額外回合激活"
        end
    },

    {
        id = "lucky_bamboo",
        name = "開運竹",
        nameEng = "Lucky Bamboo",
        description = "風水好物，帶來好運",
        descriptionEng = "Feng shui item, brings good luck",
        price = 60,
        rarity = "uncommon",
        category = "feng_shui",
        effect = function(gameState, battleState)
            -- Increase chance of drawing needed tiles
            if battleState then
                battleState.luckyDraws = (battleState.luckyDraws or 0) + 3
                return "接下來3次抽牌運氣增強！開運竹生效"
            end
            return "幸運加成激活"
        end
    }
}

-- Get consumable by ID
function HKConsumables.getItem(itemId)
    for _, item in ipairs(HKConsumables.ITEMS) do
        if item.id == itemId then
            return item
        end
    end
    return nil
end

-- Get items by rarity
function HKConsumables.getItemsByRarity(rarity)
    local items = {}
    for _, item in ipairs(HKConsumables.ITEMS) do
        if item.rarity == rarity then
            table.insert(items, item)
        end
    end
    return items
end

-- Get items by category
function HKConsumables.getItemsByCategory(category)
    local items = {}
    for _, item in ipairs(HKConsumables.ITEMS) do
        if item.category == category then
            table.insert(items, item)
        end
    end
    return items
end

-- Use consumable during battle
function HKConsumables.useItem(itemId, gameState, battleState)
    local item = HKConsumables.getItem(itemId)
    if not item then
        return false, "道具不存在"
    end

    -- Check if player has the item
    if not gameState.playerConsumables then
        gameState.playerConsumables = {}
    end

    local hasItem = false
    local itemIndex = nil
    for i, consumableId in ipairs(gameState.playerConsumables) do
        if consumableId == itemId then
            hasItem = true
            itemIndex = i
            break
        end
    end

    if not hasItem then
        return false, "你沒有這個道具"
    end

    -- Use the item effect
    local result = "無效果"
    if item.effect then
        result = item.effect(gameState, battleState)
    end

    -- Remove item from inventory (consumables are single-use)
    table.remove(gameState.playerConsumables, itemIndex)

    print("🍽️ 使用道具:", item.name, "->", result)
    return true, result
end

-- Add consumable to player inventory
function HKConsumables.addItem(gameState, itemId, quantity)
    quantity = quantity or 1

    if not gameState.playerConsumables then
        gameState.playerConsumables = {}
    end

    for i = 1, quantity do
        table.insert(gameState.playerConsumables, itemId)
    end

    local item = HKConsumables.getItem(itemId)
    local itemName = item and item.name or itemId
    print("🎒 獲得道具:", itemName, "x" .. quantity)
end

-- Generate random shop items
function HKConsumables.generateShopItems(shopLevel)
    shopLevel = shopLevel or 1
    local items = {}

    -- Determine rarity distribution based on shop level
    local rarityChances = {
        common = math.max(0.1, 0.7 - shopLevel * 0.1),
        uncommon = math.min(0.6, 0.25 + shopLevel * 0.05),
        rare = math.min(0.3, shopLevel * 0.05)
    }

    -- Generate 4-6 random items
    local itemCount = math.random(4, 6)
    local availableItems = {}

    -- Build available items list based on rarity
    for _, item in ipairs(HKConsumables.ITEMS) do
        local chance = rarityChances[item.rarity] or 0.1
        if math.random() < chance then
            table.insert(availableItems, item)
        end
    end

    -- Ensure we have at least some common items
    if #availableItems < itemCount then
        local commonItems = HKConsumables.getItemsByRarity("common")
        for _, item in ipairs(commonItems) do
            if #availableItems < itemCount then
                table.insert(availableItems, item)
            end
        end
    end

    -- Select random items
    for i = 1, math.min(itemCount, #availableItems) do
        local randomIndex = math.random(#availableItems)
        table.insert(items, availableItems[randomIndex])
        table.remove(availableItems, randomIndex)
    end

    return items
end

-- Get player's consumable count
function HKConsumables.getPlayerItemCount(gameState, itemId)
    if not gameState.playerConsumables then
        return 0
    end

    local count = 0
    for _, consumableId in ipairs(gameState.playerConsumables) do
        if consumableId == itemId then
            count = count + 1
        end
    end
    return count
end

-- Get all unique items in player inventory with counts
function HKConsumables.getPlayerInventory(gameState)
    if not gameState.playerConsumables then
        return {}
    end

    local inventory = {}
    local counted = {}

    for _, itemId in ipairs(gameState.playerConsumables) do
        if not counted[itemId] then
            local item = HKConsumables.getItem(itemId)
            if item then
                inventory[itemId] = {
                    item = item,
                    count = HKConsumables.getPlayerItemCount(gameState, itemId)
                }
                counted[itemId] = true
            end
        end
    end

    return inventory
end

-- Rarity colors for UI
HKConsumables.RARITY_COLORS = {
    common = {0.8, 0.8, 0.8, 1.0},    -- Light gray
    uncommon = {0.3, 0.8, 0.3, 1.0},  -- Green
    rare = {0.3, 0.5, 0.9, 1.0},      -- Blue
    legendary = {0.9, 0.6, 0.2, 1.0}  -- Orange
}

return HKConsumables