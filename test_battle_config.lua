-- Simple test script for battle configuration system
local BattleConfig = require("battle_config")

print("=== Battle Configuration Test ===")

-- Test loading configurations
print("\n1. Testing configuration loading...")
local configs = BattleConfig.loadConfigs()
if configs then
    print("✓ Configurations loaded successfully")
    print("  Available battle types: " .. tostring(#BattleConfig.getAllBattleTypes()))
else
    print("✗ Failed to load configurations")
end

-- Test getting specific battle config
print("\n2. Testing specific battle configurations...")
local testTypes = {"tutorial", "normal", "hard", "boss_easy", "invalid_type"}

for _, battleType in ipairs(testTypes) do
    local config = BattleConfig.getBattleConfig(battleType)
    if config then
        print("✓ " .. battleType .. ": " .. config.name .. " (Fan: " .. config.config.targetFan .. ")")
    else
        print("✗ " .. battleType .. ": Failed to load")
    end
end

-- Test applying configuration to mock game state
print("\n3. Testing configuration application...")
local mockGameState = {
    settings = {},
    mainGameState = {}
}

local success = BattleConfig.applyConfig(mockGameState, "hard")
if success then
    print("✓ Configuration applied successfully")
    print("  Target Fan: " .. mockGameState.targetFan)
    print("  Max Hands: " .. mockGameState.maxHands)
    print("  Battle Type: " .. mockGameState.battleConfig.type)
else
    print("✗ Failed to apply configuration")
end

-- Test reward calculation
print("\n4. Testing reward calculation...")
mockGameState.battleConfig = {
    type = "hard",
    difficulty = "hard",
    rewards = {money = 150, xp = 75},
    penalties = {money = 40}
}

local winRewards = BattleConfig.calculateRewards(mockGameState, true)
local loseRewards = BattleConfig.calculateRewards(mockGameState, false)

print("✓ Win rewards: Money = " .. (winRewards.money or 0) .. ", XP = " .. (winRewards.xp or 0))
print("✓ Loss penalties: Money = " .. (loseRewards.money or 0))

-- Test level-based battle types
print("\n5. Testing level-based battle types...")
for level = 1, 5 do
    local availableTypes = BattleConfig.getBattleTypesForLevel(level)
    local randomType = BattleConfig.getRandomBattleTypeForLevel(level)
    print("✓ Level " .. level .. ": " .. #availableTypes .. " types available, random: " .. randomType)
end

print("\n=== Test Completed ===")