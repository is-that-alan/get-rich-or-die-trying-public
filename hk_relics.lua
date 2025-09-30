-- Hong Kong Relics System
-- Permanent passive effects representing Hong Kong culture and survival wisdom

local HKRelics = {}

-- Relics Database (sorted by power level)
HKRelics.DATABASE = {
    -- Basic Relics (生存智慧)
    {
        id = "cha_chaan_teng_loyalty_card",
        name = "茶餐廳儲印花卡",
        nameEng = "Cha Chaan Teng Loyalty Card",
        description = "每局開始時+10蚊，香港人嘅日常",
        effect = function(gameState)
            gameState.startingMoney = (gameState.startingMoney or 0) + 10
        end,
        passive = true,
        tier = "basic",
        price = 80
    },

    {
        id = "mtr_monthly_pass",
        name = "港鐵月票",
        nameEng = "MTR Monthly Pass",
        description = "移動效率+1，節省交通時間",
        effect = function(gameState)
            gameState.movementEfficiency = (gameState.movementEfficiency or 0) + 1
        end,
        passive = true,
        tier = "basic",
        price = 100
    },

    {
        id = "temple_amulet",
        name = "黃大仙靈符",
        nameEng = "Wong Tai Sin Amulet",
        description = "運氣永久+1，香港人必備",
        effect = function(gameState)
            gameState.luckModifier = (gameState.luckModifier or 0) + 1
        end,
        passive = true,
        tier = "basic",
        price = 120
    },

    {
        id = "old_nokia_3310",
        name = "舊款Nokia 3310",
        nameEng = "Old Nokia 3310",
        description = "堅韌不摧，電池持久，抗壓+2",
        effect = function(gameState)
            gameState.resilience = (gameState.resilience or 0) + 2
            gameState.batteryLife = true  -- Never runs out
        end,
        passive = true,
        tier = "basic",
        price = 60
    },

    -- Intermediate Relics (街頭智慧)
    {
        id = "wet_market_experience",
        name = "街市經驗",
        nameEng = "Wet Market Experience",
        description = "識講價，所有購買-10%價錢",
        effect = function(gameState)
            gameState.bargainingSkill = (gameState.bargainingSkill or 0) + 10
        end,
        passive = true,
        tier = "intermediate",
        price = 150
    },

    {
        id = "mahjong_table_wisdom",
        name = "麻雀檯智慧",
        nameEng = "Mahjong Table Wisdom",
        description = "睇人睇牌經驗，每局額外抽1張牌",
        effect = function(gameState)
            gameState.extraDrawPerRound = (gameState.extraDrawPerRound or 0) + 1
        end,
        passive = true,
        tier = "intermediate",
        price = 200
    },

    {
        id = "building_management_connections",
        name = "屋企管理處關係",
        nameEng = "Building Management Connections",
        description = "住屋穩定，抗租金加價，每月-5%開支",
        effect = function(gameState)
            gameState.rentProtection = true
            gameState.monthlyExpenseReduction = (gameState.monthlyExpenseReduction or 0) + 5
        end,
        passive = true,
        tier = "intermediate",
        price = 180
    },

    {
        id = "dai_pai_dong_network",
        name = "大牌檔人脈網",
        nameEng = "Dai Pai Dong Network",
        description = "街頭消息靈通，可以預知下個挑戰",
        effect = function(gameState)
            gameState.streetIntelligence = true
            gameState.challengePreview = true
        end,
        passive = true,
        tier = "intermediate",
        price = 220
    },

    -- Advanced Relics (生意頭腦)
    {
        id = "central_business_district_suit",
        name = "中環西裝",
        nameEng = "Central Business District Suit",
        description = "形象提升，所有談判成功率+20%",
        effect = function(gameState)
            gameState.negotiationBonus = (gameState.negotiationBonus or 0) + 20
            gameState.professionalImage = true
        end,
        passive = true,
        tier = "advanced",
        price = 350
    },

    {
        id = "causeway_bay_shopping_experience",
        name = "銅鑼灣購物經驗",
        nameEng = "Causeway Bay Shopping Experience",
        description = "識買嘢，所有商店額外選擇+1",
        effect = function(gameState)
            gameState.shoppingExpertise = true
            gameState.extraShopChoices = (gameState.extraShopChoices or 0) + 1
        end,
        passive = true,
        tier = "advanced",
        price = 280
    },

    {
        id = "tsim_sha_tsui_tourist_guide",
        name = "尖沙咀導遊證",
        nameEng = "Tsim Sha Tsui Tourist Guide License",
        description = "識搵外國人錢，每回合有機會獲得額外收入",
        effect = function(gameState)
            gameState.touristIncomeChance = 0.3  -- 30% chance per round
            gameState.touristIncomeAmount = 25
        end,
        passive = true,
        tier = "advanced",
        price = 400
    },

    -- Legendary Relics (傳說級香港精神)
    {
        id = "bruce_lee_nunchucks",
        name = "李小龍雙截棍",
        nameEng = "Bruce Lee Nunchucks",
        description = "功夫精神！面對困難時永不放棄",
        effect = function(gameState)
            gameState.bruceLeePower = true
            gameState.neverGiveUp = true  -- Can't lose from low fan
        end,
        passive = true,
        tier = "legendary",
        price = 800
    },

    {
        id = "golden_bauhinia_medal",
        name = "金紫荊獎章",
        nameEng = "Golden Bauhinia Medal",
        description = "香港之光！所有效果+50%",
        effect = function(gameState)
            gameState.hkPrideBonus = 1.5  -- 50% bonus to all effects
            gameState.goldenBauhinia = true
        end,
        passive = true,
        tier = "legendary",
        price = 1000
    },

    {
        id = "star_ferry_eternal_ticket",
        name = "天星小輪永久船票",
        nameEng = "Star Ferry Eternal Ticket",
        description = "維港精神永存，每次失敗後重新開始+100蚊",
        effect = function(gameState)
            gameState.starFerryTicket = true
            gameState.failureRecoveryBonus = 100
        end,
        passive = true,
        tier = "legendary",
        price = 600
    },

    -- Mythical Relics (神話級香港傳說)
    {
        id = "dragon_gate_blessing",
        name = "龍門祝福",
        nameEng = "Dragon Gate Blessing",
        description = "鯉躍龍門！每次食糊都有機會觸發奇蹟",
        effect = function(gameState)
            gameState.dragonGateBlessing = true
            gameState.miracleChance = 0.1  -- 10% chance for miracle on win
        end,
        passive = true,
        tier = "mythical",
        price = 1500
    },

    {
        id = "jade_emperor_fortune",
        name = "玉皇大帝財運",
        nameEng = "Jade Emperor Fortune",
        description = "天庭保佑！金錢永遠不會歸零",
        effect = function(gameState)
            gameState.jadeEmperorProtection = true
            gameState.minimumMoney = 50  -- Always keep at least 50
        end,
        passive = true,
        tier = "mythical",
        price = 2000
    }
}

-- Get relics by tier
function HKRelics.getRelicsByTier(tier)
    local relics = {}
    for _, relic in ipairs(HKRelics.DATABASE) do
        if relic.tier == tier then
            table.insert(relics, relic)
        end
    end
    return relics
end

-- Get relic by ID
function HKRelics.getRelic(id)
    for _, relic in ipairs(HKRelics.DATABASE) do
        if relic.id == id then
            return relic
        end
    end
    return nil
end

-- Apply relic effect (for permanent passive effects)
function HKRelics.applyRelic(gameState, relicId)
    local relic = HKRelics.getRelic(relicId)
    if relic and relic.effect then
        relic.effect(gameState)

        -- Add to player's relic collection
        gameState.playerRelics = gameState.playerRelics or {}
        if not gameState.playerRelics[relicId] then
            gameState.playerRelics[relicId] = relic
            return true, relic.name .. " 獲得！"
        end
    end
    return false, "搵唔到呢個聖物"
end

-- Check if player has specific relic
function HKRelics.hasRelic(gameState, relicId)
    return gameState.playerRelics and gameState.playerRelics[relicId] ~= nil
end

-- Apply passive effects at start of round
function HKRelics.applyPassiveEffects(gameState)
    if not gameState.playerRelics then return end

    for relicId, relic in pairs(gameState.playerRelics) do
        -- Tourist income from guide license
        if relicId == "tsim_sha_tsui_tourist_guide" then
            if math.random() < (gameState.touristIncomeChance or 0) then
                local income = gameState.touristIncomeAmount or 25
                gameState.playerMoney = gameState.playerMoney + income
                print("導遊搵到外國人！+" .. income .. "蚊")
            end
        end

        -- Cha chaan teng loyalty bonus
        if relicId == "cha_chaan_teng_loyalty_card" and gameState.roundNumber == 1 then
            gameState.playerMoney = gameState.playerMoney + (gameState.startingMoney or 10)
            print("茶餐廳免費早餐！")
        end

        -- Apply other passive effects as needed...
    end
end

-- Generate relic shop
function HKRelics.generateRelicShop(playerLevel)
    local shop = {}
    playerLevel = playerLevel or 1

    -- Basic relics (always available)
    local basicRelics = HKRelics.getRelicsByTier("basic")
    for i = 1, 2 do
        if #basicRelics > 0 then
            table.insert(shop, basicRelics[math.random(#basicRelics)])
        end
    end

    -- Intermediate relics (level 2+)
    if playerLevel >= 2 then
        local intermediateRelics = HKRelics.getRelicsByTier("intermediate")
        if #intermediateRelics > 0 then
            table.insert(shop, intermediateRelics[math.random(#intermediateRelics)])
        end
    end

    -- Advanced relics (level 4+)
    if playerLevel >= 4 then
        local advancedRelics = HKRelics.getRelicsByTier("advanced")
        if #advancedRelics > 0 and math.random() < 0.3 then
            table.insert(shop, advancedRelics[math.random(#advancedRelics)])
        end
    end

    -- Legendary relics (level 6+, very rare)
    if playerLevel >= 6 and math.random() < 0.1 then
        local legendaryRelics = HKRelics.getRelicsByTier("legendary")
        if #legendaryRelics > 0 then
            table.insert(shop, legendaryRelics[math.random(#legendaryRelics)])
        end
    end

    -- Mythical relics (level 10+, extremely rare)
    if playerLevel >= 10 and math.random() < 0.05 then
        local mythicalRelics = HKRelics.getRelicsByTier("mythical")
        if #mythicalRelics > 0 then
            table.insert(shop, mythicalRelics[math.random(#mythicalRelics)])
        end
    end

    return shop
end

return HKRelics