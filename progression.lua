-- SIMPLE PROGRESSION SYSTEM
-- Perfect for hackathon demos
local Progression = {}
local HKFlavor = require("hk_flavor")
local Juice = require("juice")

-- Player progression state
local progress = {
    level = 1,
    experience = 0,
    achievements = {},
    unlockedLocations = {"深水埗"}, -- Start with Sham Shui Po
    totalWins = 0,
    totalLosses = 0,
    totalMoneyEarned = 0,
    streak = 0,
    bestStreak = 0
}

-- Achievement definitions (quick to achieve for demo)
local achievements = {
    {
        id = "first_win",
        name = "初嘗勝利",
        description = "贏咗第一場！",
        condition = function() return progress.totalWins >= 1 end,
        reward = {money = 50, experience = 10},
        emoji = "🎉"
    },
    {
        id = "money_maker",
        name = "搵錢能手",
        description = "賺到 $500",
        condition = function() return progress.totalMoneyEarned >= 500 end,
        reward = {money = 100, experience = 20},
        emoji = "💰"
    },
    {
        id = "streak_master",
        name = "連勝王者",
        description = "連勝 3 場",
        condition = function() return progress.streak >= 3 end,
        reward = {money = 200, experience = 30},
        emoji = "🔥"
    },
    {
        id = "explorer",
        name = "香港遊俠",
        description = "解鎖 3 個地區",
        condition = function() return #progress.unlockedLocations >= 3 end,
        reward = {money = 300, experience = 50},
        emoji = "🗺️"
    },
    {
        id = "millionaire",
        name = "百萬富翁",
        description = "擁有 $1000",
        condition = function() return true end, -- Will check money in game
        reward = {money = 0, experience = 100},
        emoji = "🤑"
    }
}

-- Level requirements (fast progression for demo)
local levelRequirements = {50, 120, 200, 300, 500, 750, 1000, 1500, 2000, 3000}

function Progression.init()
    progress = {
        level = 1,
        experience = 0,
        achievements = {},
        unlockedLocations = {"深水埗"},
        totalWins = 0,
        totalLosses = 0,
        totalMoneyEarned = 0,
        streak = 0,
bestStreak = 0,
    storyProgress = 0
    }
end

function Progression.addExperience(amount, gameState)
    local oldLevel = progress.level
    progress.experience = progress.experience + amount

    -- Check for level up
    while progress.level <= #levelRequirements and
          progress.experience >= levelRequirements[progress.level] do
        progress.level = progress.level + 1

        -- Level up rewards
        local reward = 100 * progress.level
        gameState.playerMoney = gameState.playerMoney + reward

        -- Show celebration
        Juice.celebrate(400, 300)
        Juice.earnMoney(400, 200, reward)

        -- Unlock new location every 2 levels
        if progress.level % 2 == 0 and progress.level <= 6 then
            Progression.unlockNewLocation()
        end
    end

    return progress.level > oldLevel
end

function Progression.unlockNewLocation()
    local availableLocations = {"觀塘", "旺角", "中環", "銅鑼灣", "尖沙咀"}

    for _, location in ipairs(availableLocations) do
        local alreadyUnlocked = false
        for _, unlocked in ipairs(progress.unlockedLocations) do
            if unlocked == location then
                alreadyUnlocked = true
                break
            end
        end

        if not alreadyUnlocked then
            table.insert(progress.unlockedLocations, location)
            Juice.shake(5)
            break
        end
    end
end

function Progression.recordWin(gameState, moneyEarned)
    progress.totalWins = progress.totalWins + 1
    progress.totalMoneyEarned = progress.totalMoneyEarned + moneyEarned
    progress.streak = progress.streak + 1
    progress.bestStreak = math.max(progress.bestStreak, progress.streak)

    -- Add experience
    local experience = 25 + math.floor(moneyEarned / 10)
    Progression.addExperience(experience, gameState)

    -- Check achievements
    Progression.checkAchievements(gameState)
end

function Progression.recordLoss(gameState)
    progress.totalLosses = progress.totalLosses + 1
    progress.streak = 0

    -- Small consolation experience
    Progression.addExperience(5, gameState)
end

function Progression.checkAchievements(gameState)
    for _, achievement in ipairs(achievements) do
        local alreadyUnlocked = false
        for _, unlocked in ipairs(progress.achievements) do
            if unlocked == achievement.id then
                alreadyUnlocked = true
                break
            end
        end

        if not alreadyUnlocked then
            local conditionMet = false

            if achievement.id == "millionaire" then
                conditionMet = gameState.playerMoney >= 1000
            else
                conditionMet = achievement.condition()
            end

            if conditionMet then
                table.insert(progress.achievements, achievement.id)

                -- Give reward
                gameState.playerMoney = gameState.playerMoney + achievement.reward.money
                Progression.addExperience(achievement.reward.experience, gameState)

                -- Show achievement popup
                Progression.showAchievement(achievement)
            end
        end
    end
end

function Progression.showAchievement(achievement)
    -- Create a simple achievement notification
    Juice.celebrate(400, 300)
    Juice.earnMoney(400, 150, achievement.reward.money)

    -- Could add a popup system here for hackathon demo
end

function Progression.getPlayerStats()
    return {
        level = progress.level,
        experience = progress.experience,
        nextLevelExp = levelRequirements[progress.level] or 9999,
        wins = progress.totalWins,
        losses = progress.totalLosses,
        winRate = progress.totalWins > 0 and
                  math.floor(progress.totalWins / (progress.totalWins + progress.totalLosses) * 100) or 0,
        streak = progress.streak,
        bestStreak = progress.bestStreak,
        achievements = #progress.achievements,
        locations = #progress.unlockedLocations
    }
end

function Progression.getUnlockedLocations()
    return progress.unlockedLocations
end

function Progression.getRecentAchievements()
    local recent = {}
    local count = math.min(3, #progress.achievements)

    for i = #progress.achievements - count + 1, #progress.achievements do
        if progress.achievements[i] then
            for _, achievement in ipairs(achievements) do
                if achievement.id == progress.achievements[i] then
                    table.insert(recent, achievement)
                    break
                end
            end
        end
    end

    return recent
end

-- Draw progress UI (simple overlay)
function Progression.drawProgressUI(x, y)
    local stats = Progression.getPlayerStats()

    -- Level and experience bar
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", x, y, 200, 80)

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Level " .. stats.level, x, y + 5, 200, "center")

    -- Experience bar
    local expProgress = stats.experience / stats.nextLevelExp
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", x + 10, y + 25, 180, 15)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", x + 10, y + 25, 180 * expProgress, 15)

    -- Stats
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(stats.wins .. "W/" .. stats.losses .. "L", x, y + 45, 100, "left")
    love.graphics.printf("🔥" .. stats.streak, x + 100, y + 45, 100, "left")
    love.graphics.printf("📍" .. stats.locations, x, y + 60, 100, "left")
    love.graphics.printf("🏆" .. stats.achievements, x + 100, y + 60, 100, "left")
end

function Progression.save()
    return progress
end

function Progression.load(data)
    if data then
        progress = data
    end
end

-- Story progression functions
function Progression.advanceStory(gameState)
    progress.storyProgress = progress.storyProgress + 1
    Progression.loadNextElement(gameState)
end

function Progression.loadNextElement(gameState)
    local story = progress.storyProgress
    local sceneName
    local opponent

    if story == 0 then
        sceneName = "intro"
    elseif story == 3 then
        sceneName = "level1_to_level2"
    elseif story == 6 then
        sceneName = "level2_mid"
    elseif story == 7 then
        sceneName = "level2_to_level3"
    elseif story == 10 then
        sceneName = "level3_mid"
    elseif story == 11 then
        sceneName = "level3_end"
    end

    if sceneName then
        Progression.loadStoryScene(gameState, sceneName)
        return
    end

    if story == 1 or story == 2 or story == 4 or story == 5 or story == 8 or story == 9 then
        -- Use progression screen for all battle choices
        gameState.screen = "progression"
        local ProgressionScreen = require("progression_screen")
        ProgressionScreen.init(gameState)
        return
    end

    -- Removed direct battle loading - now handled by progression screen

    -- TIME TRAVEL ENDLESS MODE: Loop back to beginning with increased difficulty
    print("🌀 時光倒流！回到過去但更加困難...")

    -- Increase difficulty level for endless mode
    gameState.timeLoopLevel = (gameState.timeLoopLevel or 0) + 1
    gameState.storyProgress = 0  -- Reset story to beginning

    -- Apply time loop bonuses/penalties
    if gameState.timeLoopLevel > 0 then
        -- Give player some time loop consumables
        if not gameState.playerConsumables then gameState.playerConsumables = {} end
        table.insert(gameState.playerConsumables, "time_machine")

        -- Boost player money for higher difficulty
        local timeLoopBonus = gameState.timeLoopLevel * 100
        gameState.playerMoney = gameState.playerMoney + timeLoopBonus
        print("🎁 時空旅行獎勵: $" .. timeLoopBonus)
    end

    -- Start the loop again
    Progression.loadNextElement(gameState)
end

function Progression.loadStoryScene(gameState, sceneName)
    local Scene = require("scene")
    if Scene.loadScene(sceneName) then
        Scene.onSceneComplete = function()
            Progression.advanceStory(gameState)
        end
        Scene.onSceneExit = function()
            gameState.screen = "menu"
        end
        gameState.screen = "scene"
    else
        print("Failed to load scene: " .. sceneName)
        gameState.screen = "menu"
    end
end

return Progression