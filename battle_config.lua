-- Battle Configuration Manager
-- Pure Lua configuration system for battle difficulty levels and time loop scaling

local BattleConfig = {}

-- Cache for loaded configurations
BattleConfig.configs = nil
BattleConfig.isLoaded = false

-- Load battle configurations from Lua file
function BattleConfig.loadConfigs()
    if BattleConfig.isLoaded then
        return BattleConfig.configs
    end

    local success, configData = pcall(function()
        return require("battle_configs")
    end)

    if success then
        BattleConfig.configs = configData
        BattleConfig.isLoaded = true
        print("✓ Battle configurations loaded from battle_configs.lua")
        return BattleConfig.configs
    else
        print("⚠ Failed to load battle_configs.lua, using fallback defaults")
        BattleConfig.configs = BattleConfig.getDefaultConfigs()
        BattleConfig.isLoaded = true
        return BattleConfig.configs
    end
end

-- Get default configurations (fallback)
function BattleConfig.getDefaultConfigs()
    return {
        battle_types = {
            normal = {
                name = "標準戰鬥",
                description = "標準難度的麻將戰鬥",
                difficulty = "normal",
                config = {
                    targetFan = 3,
                    maxHands = 20,
                    maxHandSize = 14,
                    targetPlayedTiles = 14,
                    deckMultiplier = 1.0,
                    allowUndo = false,
                    weatherEffects = true
                },
                rewards = { money = 100, xp = 50 },
                penalties = { money = 25 }
            }
        }
    }
end

-- Get a specific battle configuration
function BattleConfig.getBattleConfig(battleType)
    local configs = BattleConfig.loadConfigs()

    if not configs or not configs.battle_types then
        print("⚠ No battle configurations available")
        return BattleConfig.getDefaultConfigs().battle_types.normal
    end

    local config = configs.battle_types[battleType]
    if not config then
        print("⚠ Battle type '" .. tostring(battleType) .. "' not found, using normal")
        return configs.battle_types.normal or BattleConfig.getDefaultConfigs().battle_types.normal
    end

    print("✓ Loaded battle config: " .. config.name)
    return config
end

-- Apply configuration to game state
function BattleConfig.applyConfig(gameState, battleType)
    local config = BattleConfig.getBattleConfig(battleType)

    if not config or not config.config then
        print("⚠ Invalid config for battle type: " .. tostring(battleType))
        return false
    end

    local battleConfig = config.config

    -- Apply time loop difficulty scaling
    local timeLoopLevel = gameState.timeLoopLevel or 0
    local timeLoopMultiplier = BattleConfig.getTimeLoopMultiplier(timeLoopLevel)

    -- Apply core game settings with time loop scaling
    gameState.targetFan = math.floor((battleConfig.targetFan or 3) * timeLoopMultiplier.targetFan)
    gameState.maxHands = math.max(1, math.floor((battleConfig.maxHands or 10) * timeLoopMultiplier.maxHands))
    gameState.maxHandSize = math.max(7, math.floor((battleConfig.maxHandSize or 14) * timeLoopMultiplier.maxHandSize))
    gameState.targetPlayedTiles = battleConfig.targetPlayedTiles or 14

    -- Apply UI/UX settings
    if gameState.settings then
        gameState.settings.allowUndo = battleConfig.allowUndo or false
        gameState.settings.weatherEffects = battleConfig.weatherEffects ~= false
    end

    -- Store configuration info for rewards/penalties
    gameState.battleConfig = {
        type = battleType,
        rewards = config.rewards or {},
        penalties = config.penalties or {},
        specialRules = battleConfig.specialRules or {},
        difficulty = config.difficulty or "normal"
    }

    -- Apply deck modifications
    if battleConfig.deckMultiplier and battleConfig.deckMultiplier ~= 1.0 then
        gameState.deckMultiplier = battleConfig.deckMultiplier
    end

    -- Apply starting tile bonus/penalty
    if battleConfig.startingTileBonus then
        gameState.startingTileBonus = battleConfig.startingTileBonus
    end

    -- Apply suit restrictions
    if battleConfig.limitedSuits then
        gameState.limitedSuits = battleConfig.limitedSuits
    end

    -- Apply special rules
    if battleConfig.honorTilesOnly then
        gameState.honorTilesOnly = true
    end

    print("✓ Applied battle configuration: " .. config.name)
    print("  Target Fan: " .. gameState.targetFan)
    print("  Max Hands: " .. gameState.maxHands)
    print("  Difficulty: " .. config.difficulty)

    if timeLoopLevel > 0 then
        print("  🌀 Time Loop Level: " .. timeLoopLevel)
        print("  🌀 Difficulty Scaling: " .. string.format("%.1fx", timeLoopMultiplier.targetFan))
    end

    return true
end

-- Get available battle types for a level
function BattleConfig.getBattleTypesForLevel(level)
    local configs = BattleConfig.loadConfigs()

    if not configs or not configs.difficulty_progression then
        return {"normal"} -- Default fallback
    end

    local levelKey = "level_" .. tostring(level)
    local availableTypes = configs.difficulty_progression[levelKey]

    if not availableTypes or #availableTypes == 0 then
        -- Fall back to all available types if level not defined
        local allTypes = {}
        for battleType, _ in pairs(configs.battle_types) do
            table.insert(allTypes, battleType)
        end
        return allTypes
    end

    return availableTypes
end

-- Get random battle type for level
function BattleConfig.getRandomBattleTypeForLevel(level)
    local availableTypes = BattleConfig.getBattleTypesForLevel(level)
    if #availableTypes == 0 then
        return "normal"
    end

    return availableTypes[math.random(#availableTypes)]
end

-- Calculate rewards based on configuration
function BattleConfig.calculateRewards(gameState, won)
    if not gameState.battleConfig then
        -- Default rewards
        return won and {money = 100, xp = 50} or {money = -25}
    end

    local config = gameState.battleConfig

    if won then
        local rewards = {}
        for key, value in pairs(config.rewards) do
            rewards[key] = value
        end

        -- Apply difficulty multiplier
        local difficultyMultiplier = BattleConfig.getDifficultyMultiplier(config.difficulty)

        -- Apply time loop multiplier
        local timeLoopLevel = gameState.timeLoopLevel or 0
        local timeLoopMultiplier = BattleConfig.getTimeLoopMultiplier(timeLoopLevel).rewardMultiplier

        local totalMultiplier = difficultyMultiplier * timeLoopMultiplier

        if rewards.money then
            rewards.money = math.floor(rewards.money * totalMultiplier)
        end
        if rewards.xp then
            rewards.xp = math.floor(rewards.xp * totalMultiplier)
        end

        return rewards
    else
        local penalties = {}
        for key, value in pairs(config.penalties) do
            penalties[key] = -value -- Make penalties negative
        end
        return penalties
    end
end

-- Get difficulty multiplier for rewards
function BattleConfig.getDifficultyMultiplier(difficulty)
    local multipliers = {
        tutorial = 0.5,
        easy = 0.8,
        normal = 1.0,
        hard = 1.3,
        expert = 1.6,
        boss_easy = 2.0,
        boss_hard = 3.0,
        challenge = 1.5
    }

    return multipliers[difficulty] or 1.0
end

-- Get time loop difficulty multipliers
function BattleConfig.getTimeLoopMultiplier(timeLoopLevel)
    if timeLoopLevel == 0 then
        return {
            targetFan = 1.0,
            maxHands = 1.0,
            maxHandSize = 1.0,
            rewardMultiplier = 1.0
        }
    end

    -- Exponential scaling for time loops
    local baseMultiplier = 1.0 + (timeLoopLevel * 0.3)  -- 30% increase per loop

    return {
        targetFan = baseMultiplier,  -- Higher fan requirement
        maxHands = math.max(0.3, 1.0 - (timeLoopLevel * 0.1)),  -- Fewer hands allowed
        maxHandSize = math.max(0.6, 1.0 - (timeLoopLevel * 0.05)),  -- Smaller hand size
        rewardMultiplier = 1.0 + (timeLoopLevel * 0.5)  -- Higher rewards for higher difficulty
    }
end

-- JSON parsing removed - using pure Lua configs instead

-- Get list of all available battle types
function BattleConfig.getAllBattleTypes()
    local configs = BattleConfig.loadConfigs()

    if not configs or not configs.battle_types then
        return {"normal"}
    end

    local types = {}
    for battleType, config in pairs(configs.battle_types) do
        table.insert(types, {
            id = battleType,
            name = config.name,
            description = config.description,
            difficulty = config.difficulty
        })
    end

    -- Sort by difficulty
    local difficultyOrder = {tutorial=1, easy=2, normal=3, hard=4, expert=5, boss_easy=6, boss_hard=7, challenge=8}
    table.sort(types, function(a, b)
        local aOrder = difficultyOrder[a.difficulty] or 999
        local bOrder = difficultyOrder[b.difficulty] or 999
        return aOrder < bOrder
    end)

    return types
end

return BattleConfig