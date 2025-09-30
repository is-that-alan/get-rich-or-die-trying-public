-- Hong Kong Roguelike Progression Card System
-- Card-based progression instead of map navigation

local ProgressionCards = {}
local HKMemeCards = require("hk_meme_cards")
local HKRelics = require("hk_relics")

-- Card Types for Progression
ProgressionCards.CARD_TYPES = {
    COMBAT = "combat",
    SHOP = "shop",
    EVENT = "event",
    ELITE = "elite",
    BOSS = "boss"
}

ProgressionCards.COMBAT_ENCOUNTERS = {
    -- Basic encounters
    {
        id = "sham_shui_po_market",
        name = "深水埗街市挑戰",
        nameEng = "Sham Shui Po Market Scheme",
        description = "同街市阿嬸學做小生意",
        targetFan = 3,
        rounds = 5,
        reward = {money = 80, xp = 10},
        difficulty = "easy",
        area = "sham_shui_po"
    },

    {
        id = "kwun_tong_factory",
        name = "觀塘工廠快錢計劃",
        nameEng = "Kwun Tong Factory Quick Money",
        description = "工業區兼職挑戰",
        targetFan = 4,
        rounds = 6,
        reward = {money = 120, xp = 15},
        difficulty = "medium",
        area = "kwun_tong"
    },

    {
        id = "mong_kok_electronics",
        name = "旺角電器舖生意",
        nameEng = "Mong Kok Electronics Business",
        description = "電器舖挑戰，科技致富",
        targetFan = 5,
        rounds = 4,
        reward = {money = 150, xp = 18},
        difficulty = "medium",
        area = "mong_kok"
    },

    {
        id = "tsim_sha_tsui_tourists",
        name = "尖沙咀搵遊客錢",
        nameEng = "Tsim Sha Tsui Tourist Money",
        description = "向外國遊客推銷香港特產",
        targetFan = 6,
        rounds = 5,
        reward = {money = 200, xp = 25},
        difficulty = "hard",
        area = "tsim_sha_tsui"
    }
}

-- Elite Encounters (進階挑戰)
ProgressionCards.ELITE_ENCOUNTERS = {
    {
        id = "central_investment_scam",
        name = "中環投資騙局",
        nameEng = "Central Investment Scam",
        description = "挑戰金融區大佬",
        targetFan = 7,
        rounds = 4,
        reward = {money = 300, relic = true},
        difficulty = "elite",
        area = "central"
    },

    {
        id = "causeway_bay_luxury_flip",
        name = "銅鑼灣奢侈品炒賣",
        nameEng = "Causeway Bay Luxury Flipping",
        description = "炒賣名牌手袋挑戰",
        targetFan = 8,
        rounds = 3,
        reward = {money = 250, memeCard = true},
        difficulty = "elite",
        area = "causeway_bay"
    }
}

-- Boss Encounters (終極挑戰)
ProgressionCards.BOSS_ENCOUNTERS = {
    {
        id = "crypto_king_challenge",
        name = "加密貨幣之王",
        nameEng = "Crypto King Challenge",
        description = "數碼科技大亨的終極挑戰",
        targetFan = 12,
        rounds = 5,
        specialRule = "每回合必須打至少2張牌",
        reward = {money = 800, legendaryRelic = true},
        difficulty = "boss",
        area = "cyberport"
    }
}

-- Event Cards (隨機事件)
ProgressionCards.EVENT_CARDS = {
    {
        id = "typhoon_warning",
        name = "颱風警告",
        nameEng = "Typhoon Warning",
        description = "八號風球，全港停工",
        choices = {
            {
                text = "躲喺屋企休息",
                effect = function(gameState)
                    gameState.playerMoney = gameState.playerMoney + 50
                    return "安全渡過，獲得50蚊"
                end
            },
            {
                text = "趁機搞外賣生意",
                effect = function(gameState)
                    if math.random() < 0.7 then
                        gameState.playerMoney = gameState.playerMoney + 150
                        return "生意大好！+150蚊"
                    else
                        gameState.playerMoney = math.max(0, gameState.playerMoney - 50)
                        return "俾人投訴，損失50蚊"
                    end
                end
            }
        }
    },

    {
        id = "mtr_delay",
        name = "港鐵故障",
        nameEng = "MTR Delay",
        description = "信號故障，全線延誤",
        choices = {
            {
                text = "搭的士（更快但貴）",
                effect = function(gameState)
                    if gameState.playerMoney >= 30 then
                        gameState.playerMoney = gameState.playerMoney - 30
                        gameState.extraTime = true
                        return "準時到達，下回合+1"
                    else
                        return "錢不夠，要等巴士"
                    end
                end
            },
            {
                text = "行路（慳錢但累）",
                effect = function(gameState)
                    gameState.tiredness = (gameState.tiredness or 0) + 1
                    gameState.playerMoney = gameState.playerMoney + 10
                    return "行路有益身心，+10蚊零用"
                end
            }
        }
    },

    {
        id = "cha_chaan_teng_meeting",
        name = "茶餐廳聚會",
        nameEng = "Cha Chaan Teng Meeting",
        description = "朋友請食茶餐廳，有內幕消息",
        choices = {
            {
                text = "聽消息（可能得到好資訊）",
                effect = function(gameState)
                    if math.random() < 0.6 then
                        gameState.nextChallengePreview = true
                        return "得到有用情報！"
                    else
                        return "得啖笑，無料到"
                    end
                end
            },
            {
                text = "專心食嘢（回復體力）",
                effect = function(gameState)
                    gameState.tiredness = math.max(0, (gameState.tiredness or 0) - 1)
                    return "凍奶茶好正！體力回復"
                end
            }
        }
    }
}

-- Generate progression choices
function ProgressionCards.generateProgression(gameState)
    local choices = {}
    local runDepth = gameState.runDepth or 1
    local playerLevel = gameState.level or 1

    -- Initialize battle completion tracking if not exists
    if not gameState.currentSceneBattleCompleted then
        gameState.currentSceneBattleCompleted = false
    end

    -- Always include combat option (if not completed)
    local combatEncounters = ProgressionCards.COMBAT_ENCOUNTERS
    if runDepth >= 5 then
        -- Add elite encounters at higher depth
        for _, encounter in ipairs(ProgressionCards.ELITE_ENCOUNTERS) do
            table.insert(combatEncounters, encounter)
        end
    end

    if runDepth >= 8 then
        -- Add boss encounters at high depth
        for _, encounter in ipairs(ProgressionCards.BOSS_ENCOUNTERS) do
            table.insert(combatEncounters, encounter)
        end
    end

    -- Combat card (only if not completed)
    if not gameState.currentSceneBattleCompleted then
        local combat = combatEncounters[math.random(#combatEncounters)]
        table.insert(choices, {
            type = ProgressionCards.CARD_TYPES.COMBAT,
            data = combat,
            title = "【戰鬥】" .. combat.name,
            description = combat.description,
            subtitle = "目標: " .. combat.targetFan .. "番 / " .. combat.rounds .. "回合"
        })
    end

    -- Always include shop option
    table.insert(choices, {
        type = ProgressionCards.CARD_TYPES.SHOP,
        title = "【商店】超市",
        description = "係咪you會員?",
        subtitle = "提升實力準備下次挑戰"
    })

    -- Random event card (50% chance)
    if math.random() < 0.5 then
        local event = ProgressionCards.EVENT_CARDS[math.random(#ProgressionCards.EVENT_CARDS)]
        table.insert(choices, {
            type = ProgressionCards.CARD_TYPES.EVENT,
            data = event,
            title = "【事件】" .. event.name,
            description = event.description,
            subtitle = "隨機遭遇，有風險有機遇"
        })
    end

    -- Add advance option if battle is completed
    if gameState.currentSceneBattleCompleted then
        print("🎯 DEBUG: Adding advance card (battle completed)")
        table.insert(choices, {
            type = "advance",
            title = "【前進】進入下一關",
            description = "繼續你嘅搵錢之路",
            subtitle = "前往新的挑戰"
        })
    else
        print("🎯 DEBUG: No advance card (battle not completed)")
    end

    return choices
end

-- Execute progression choice
function ProgressionCards.executeChoice(gameState, choice)
    print("🎮 DEBUG: Executing choice type: " .. tostring(choice.type))
    print("   Choice title: " .. tostring(choice.title))

    if choice.type == ProgressionCards.CARD_TYPES.COMBAT then
        -- Start combat with the selected encounter
        local encounter = choice.data
        gameState.currentEncounter = encounter

        -- Initialize the mahjong battle with the encounter data
        local MahjongBattle = require("mahjong_battle")
        MahjongBattle.init(gameState, encounter)

        gameState.screen = "mahjong_battle"
        return "進入戰鬥: " .. encounter.name

    elseif choice.type == ProgressionCards.CARD_TYPES.SHOP then
        -- Open shop (doesn't affect progression state)
        gameState.screen = "shop"
        return "進入商店"

    elseif choice.type == ProgressionCards.CARD_TYPES.EVENT then
        -- Trigger event
        local event = choice.data
        gameState.currentEvent = event

        -- Initialize event screen with the event data
        local mainModule = require("main")
        if mainModule and mainModule.setEventData then
            mainModule.setEventData(event)
        end

        gameState.screen = "event"
        return "遭遇事件: " .. event.name

    elseif choice.type == "advance" then
        -- Advance to next scene
        gameState.runDepth = (gameState.runDepth or 1) + 1
        gameState.currentSceneBattleCompleted = false  -- Reset for new scene

        -- Clear progression choices to force regeneration with new randomization
        gameState.currentProgressionChoices = nil

        -- Check if we should trigger a story scene before showing progression
        print("🎭 DEBUG: Checking for story scenes...")
        print("   Level: " .. (gameState.level or 1))
        print("   Run Depth: " .. gameState.runDepth)
        print("   Level1ToLevel2Seen: " .. tostring(gameState.level1ToLevel2Seen))

        local sceneToTrigger = ProgressionCards.checkLevelTransition(gameState)
        print("   Scene to trigger: " .. tostring(sceneToTrigger))

        if sceneToTrigger then
            ProgressionCards.triggerStoryScene(gameState, sceneToTrigger)
            return "觸發劇情場景: " .. sceneToTrigger
        else
            -- No story scene, go directly to progression screen
            gameState.screen = "progression"
            local ProgressionScreen = require("progression_screen")
            ProgressionScreen.init(gameState)
            return "前進到第 " .. gameState.runDepth .. " 層"
        end
    end

    return "未知選擇"
end

-- Check if level transition scene should be triggered
function ProgressionCards.checkLevelTransition(gameState)
    local level = gameState.level or 1
    local runDepth = gameState.runDepth or 1

    -- Level 1 to Level 2 transition - trigger after completing level 1
    if level == 1 and runDepth >= 2 and not gameState.level1ToLevel2Seen then
        return "level1_to_level2"
    end

    -- Level 2 mid-story scene
    if level == 2 and runDepth >= 2 and not gameState.level2MidSeen then
        return "level2_mid"
    end

    -- Level 2 to Level 3 transition
    if level == 2 and runDepth >= 4 and not gameState.level2ToLevel3Seen then
        return "level2_to_level3"
    end

    -- Level 3 mid-story scene
    if level == 3 and runDepth >= 2 and not gameState.level3MidSeen then
        return "level3_mid"
    end

    -- Level 3 ending scene
    if level == 3 and runDepth >= 4 and not gameState.level3EndSeen then
        return "level3_end"
    end

    return nil
end

-- Trigger a story scene
function ProgressionCards.triggerStoryScene(gameState, sceneName)
    local Scene = require("scene")

    -- Set up scene callbacks
    Scene.onSceneComplete = function(completedScene)
        print("Scene completed: " .. completedScene)

        -- Mark scene as seen and handle level progression
        if completedScene == "level1_to_level2" then
            gameState.level1ToLevel2Seen = true
            gameState.level = 2  -- Advance to level 2
            gameState.runDepth = 1  -- Reset run depth for new level
        elseif completedScene == "level2_mid" then
            gameState.level2MidSeen = true
        elseif completedScene == "level2_to_level3" then
            gameState.level2ToLevel3Seen = true
            gameState.level = 3  -- Advance to level 3
            gameState.runDepth = 1  -- Reset run depth for new level
        elseif completedScene == "level3_mid" then
            gameState.level3MidSeen = true
        elseif completedScene == "level3_end" then
            gameState.level3EndSeen = true
            -- Could trigger game completion here
        end

        -- Return to progression screen
        gameState.screen = "progression"
        local ProgressionScreen = require("progression_screen")
        ProgressionScreen.init(gameState)
    end

    Scene.onSceneExit = function()
        print("Scene exited")
        gameState.screen = "progression"
        local ProgressionScreen = require("progression_screen")
        ProgressionScreen.init(gameState)
    end

    -- Load and display the scene
    if Scene.loadScene(sceneName) then
        gameState.screen = "scene"
        return true
    else
        print("Failed to load scene: " .. sceneName)
        return false
    end
end

-- Handle event choice
function ProgressionCards.handleEventChoice(gameState, choiceIndex)
    local event = gameState.currentEvent
    if event and event.choices and event.choices[choiceIndex] then
        local choice = event.choices[choiceIndex]
        local result = choice.effect(gameState)

        -- Clear current event
        gameState.currentEvent = nil

        -- Events don't advance the run, just return to progression
        gameState.screen = "progression"
        local ProgressionScreen = require("progression_screen")
        ProgressionScreen.init(gameState)

        return result
    end

    return "無效選擇"
end

-- Mark battle as completed
function ProgressionCards.markBattleCompleted(gameState)
    gameState.currentSceneBattleCompleted = true
    print("🎯 Battle completed for current scene")
end

return ProgressionCards