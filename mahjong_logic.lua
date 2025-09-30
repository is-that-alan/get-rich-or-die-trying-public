-- Mahjong Logic Module
-- Handles game logic, validation, scoring, and win detection

local MahjongTiles = require("mahjong_tiles")
local MahjongLogic = {}

-- Simplified HK Mahjong scoring patterns (no flowers, no kongs, solo draw)
MahjongLogic.WIN_PATTERNS = {
    -- 13番 (Limit hands, not stackable)
    ["大四喜"] = {name = "大四喜 (Great Four Winds)", fan = 13, check = "checkBigFourWinds"},

    -- 10番 (Limit hands, not stackable)
    ["字一色"] = {name = "字一色 (All Honors)", fan = 10, check = "checkAllHonors"},
    ["清么九"] = {name = "清么九 (All Terminals)", fan = 10, check = "checkAllTerminals"},

    -- 8番
    ["大三元"] = {name = "大三元 (Big Three Dragons)", fan = 8, check = "checkBigThreeDragons"},

    -- 7番
    ["清一色"] = {name = "清一色 (Full Flush)", fan = 7, check = "checkPureSuit"},

    -- 6番
    ["小四喜"] = {name = "小四喜 (Small Four Winds)", fan = 6, check = "checkSmallFourWinds"},

    -- 5番
    ["小三元"] = {name = "小三元 (Small Three Dragons)", fan = 5, check = "checkSmallThreeDragons"},

    -- 4番
    ["花么九"] = {name = "花么九 (Mixed Terminals & Honors)", fan = 4, check = "checkMixedTerminalsAndHonors"},

    -- 3番
    ["對對糊"] = {name = "對對糊 (All Pungs)", fan = 3, check = "checkAllTriplets"},
    ["混一色"] = {name = "混一色 (Half Flush)", fan = 3, check = "checkMixedSuit"},

    -- 1番 (stackable with other bonuses)
    ["平糊"] = {name = "平糊 (All Sequences)", fan = 1, check = "checkAllSequences"},

    -- 1番 (basic hand - every winning hand should get at least 1 fan)
    ["雞糊"] = {name = "雞糊 (Chicken Hand)", fan = 1, check = "checkChickenHand"}
}

-- Check if tiles form a valid winning hand (14 tiles total)
function MahjongLogic.checkWinningHand(tiles)
    if not tiles or #tiles ~= 14 then
        return false, "Need exactly 14 tiles", 0
    end

    -- Sort tiles for easier analysis
    local sortedTiles = MahjongTiles.sortTiles(tiles)

    -- Check each winning pattern (highest fan first)
    local patterns = {}
    for patternName, patternData in pairs(MahjongLogic.WIN_PATTERNS) do
        table.insert(patterns, {name = patternName, data = patternData})
    end

    -- Sort by fan value (highest first)
    table.sort(patterns, function(a, b) return a.data.fan > b.data.fan end)

    for _, pattern in ipairs(patterns) do
        local checkFunction = MahjongLogic[pattern.data.check]
        if checkFunction and checkFunction(sortedTiles) then
            return true, pattern.data.name, pattern.data.fan
        end
    end

    return false, "No valid winning pattern", 0
end

-- Check for Thirteen Terminals (十三么)
function MahjongLogic.checkThirteenTerminals(tiles)
    local required = {
        "characters_1", "characters_9", "circles_1", "circles_9",
        "bamboos_1", "bamboos_9", "東", "南", "西", "北", "中", "發", "白"
    }

    local tileCounts = MahjongTiles.countTileTypes(tiles)
    local foundTerminals = {}
    local pairFound = false

    for _, tile in ipairs(tiles) do
        local id = MahjongTiles.getTileId(tile)
        local isRequired = false

        -- Check if this tile is a required terminal/honor
        for _, req in ipairs(required) do
            if id == req or tile.suit == req then
                isRequired = true
                foundTerminals[id or tile.suit] = (foundTerminals[id or tile.suit] or 0) + 1
                break
            end
        end

        if not isRequired then
            return false
        end
    end

    -- Must have exactly 13 different terminals/honors, one as a pair
    local uniqueCount = 0
    for id, count in pairs(foundTerminals) do
        uniqueCount = uniqueCount + 1
        if count == 2 then
            if pairFound then return false end
            pairFound = true
        elseif count ~= 1 then
            return false
        end
    end

    return uniqueCount == 13 and pairFound
end

-- Check for Nine Gates (九蓮寶燈)
function MahjongLogic.checkNineGates(tiles)
    -- Must be pure suit
    if not MahjongLogic.checkPureSuit(tiles) then return false end

    local suit = tiles[1].suit
    local values = {}

    for _, tile in ipairs(tiles) do
        if tile.suit ~= suit then return false end
        local val = tonumber(tile.value)
        if not val or val < 1 or val > 9 then return false end
        values[val] = (values[val] or 0) + 1
    end

    -- Must have pattern: 1112345678999 + one extra
    local required = {3, 1, 1, 1, 1, 1, 1, 1, 3}
    local extraFound = false

    for i = 1, 9 do
        local count = values[i] or 0
        if count == required[i] + 1 and not extraFound then
            extraFound = true
        elseif count ~= required[i] then
            return false
        end
    end

    return extraFound
end

-- Check for Four Kongs (四槓子)
function MahjongLogic.checkFourKongs(tiles)
    local tileCounts = MahjongTiles.countTileTypes(tiles)
    local kongCount = 0

    for _, count in pairs(tileCounts) do
        if count == 4 then
            kongCount = kongCount + 1
        elseif count ~= 2 then
            return false
        end
    end

    return kongCount == 4
end

-- Check for Seven Consecutive Pairs (連七對)
function MahjongLogic.checkSevenConsecutivePairs(tiles)
    local tileCounts = MahjongTiles.countTileTypes(tiles)

    -- Must have exactly 7 pairs
    local pairCount = 0
    for _, count in pairs(tileCounts) do
        if count == 2 then
            pairCount = pairCount + 1
        else
            return false
        end
    end

    if pairCount ~= 7 then return false end

    -- Must be consecutive values in same suit
    local suit = tiles[1].suit
    for _, tile in ipairs(tiles) do
        if tile.suit ~= suit then return false end
    end

    local values = {}
    for id, count in pairs(tileCounts) do
        local tile = tiles[1]
        for _, t in ipairs(tiles) do
            if MahjongTiles.getTileId(t) == id then
                tile = t
                break
            end
        end
        local val = tonumber(tile.value)
        if not val then return false end
        table.insert(values, val)
    end

    table.sort(values)
    for i = 2, #values do
        if values[i] ~= values[i-1] + 1 then
            return false
        end
    end

    return true
end

-- Check for Big Three Dragons (大三元)
function MahjongLogic.checkBigThreeDragons(tiles)
    local dragons = {"中", "發", "白"}
    local dragonTriplets = 0
    local tileCounts = MahjongTiles.countTileTypes(tiles)

    for _, tile in ipairs(tiles) do
        for _, dragon in ipairs(dragons) do
            if tile.suit == dragon then
                local id = MahjongTiles.getTileId(tile)
                if tileCounts[id] >= 3 then
                    dragonTriplets = dragonTriplets + 1
                    break
                end
            end
        end
    end

    return dragonTriplets == 3
end

-- Check for Small Three Dragons (小三元)
function MahjongLogic.checkSmallThreeDragons(tiles)
    local dragons = {"中", "發", "白"}
    local dragonTriplets = 0
    local dragonPairs = 0
    local tileCounts = MahjongTiles.countTileTypes(tiles)

    for _, tile in ipairs(tiles) do
        for _, dragon in ipairs(dragons) do
            if tile.suit == dragon then
                local id = MahjongTiles.getTileId(tile)
                local count = tileCounts[id] or 0
                if count >= 3 then
                    dragonTriplets = dragonTriplets + 1
                elseif count == 2 then
                    dragonPairs = dragonPairs + 1
                end
                break
            end
        end
    end

    return dragonTriplets == 2 and dragonPairs == 1
end

-- Check for Big Four Winds (大四喜)
function MahjongLogic.checkBigFourWinds(tiles)
    local winds = {"東", "南", "西", "北"}
    local windTriplets = 0
    local tileCounts = MahjongTiles.countTileTypes(tiles)

    for _, tile in ipairs(tiles) do
        for _, wind in ipairs(winds) do
            if tile.suit == wind then
                local id = MahjongTiles.getTileId(tile)
                if tileCounts[id] >= 3 then
                    windTriplets = windTriplets + 1
                    break
                end
            end
        end
    end

    return windTriplets == 4
end

-- Check for Small Four Winds (小四喜)
function MahjongLogic.checkSmallFourWinds(tiles)
    local winds = {"東", "南", "西", "北"}
    local windTriplets = 0
    local windPairs = 0
    local tileCounts = MahjongTiles.countTileTypes(tiles)

    for _, tile in ipairs(tiles) do
        for _, wind in ipairs(winds) do
            if tile.suit == wind then
                local id = MahjongTiles.getTileId(tile)
                local count = tileCounts[id] or 0
                if count >= 3 then
                    windTriplets = windTriplets + 1
                elseif count == 2 then
                    windPairs = windPairs + 1
                end
                break
            end
        end
    end

    return windTriplets == 3 and windPairs == 1
end

-- Check for All Honors (字一色)
function MahjongLogic.checkAllHonors(tiles)
    for _, tile in ipairs(tiles) do
        if not MahjongTiles.isHonor(tile) then
            return false
        end
    end
    return true
end

-- Check for Pure Suit (清一色)
function MahjongLogic.checkPureSuit(tiles)
    if #tiles == 0 then return false end

    local suit = tiles[1].suit
    local category = MahjongTiles.getSuitCategory(tiles[1])

    -- Must be numbered tiles (not honors)
    if category == "winds" or category == "dragons" then
        return false
    end

    for _, tile in ipairs(tiles) do
        if tile.suit ~= suit then
            return false
        end
    end
    return true
end

-- Check for Mixed Suit (混一色)
function MahjongLogic.checkMixedSuit(tiles)
    local suits = {}
    local hasNumbers = false
    local hasHonors = false

    for _, tile in ipairs(tiles) do
        suits[tile.suit] = true
        if MahjongTiles.isHonor(tile) then
            hasHonors = true
        else
            hasNumbers = true
        end
    end

    -- Must have both honors and one numbered suit
    return hasNumbers and hasHonors and MahjongLogic.countTableKeys(suits) <= 4
end

-- Check for All Triplets (碰碰糊)
function MahjongLogic.checkAllTriplets(tiles)
    local tileCounts = MahjongTiles.countTileTypes(tiles)
    local pairCount = 0
    local triplets = 0

    for _, count in pairs(tileCounts) do
        if count == 2 then
            pairCount = pairCount + 1
        elseif count == 3 or count == 4 then
            triplets = triplets + 1
        else
            return false
        end
    end

    return pairCount == 1 and triplets >= 4
end

-- Check for Mixed Terminals and Honors (花么九)
function MahjongLogic.checkMixedTerminalsAndHonors(tiles)
    for _, tile in ipairs(tiles) do
        if not MahjongTiles.isTerminalOrHonor(tile) then
            return false
        end
    end
    return true
end

-- Check for All Terminals (清么九)
function MahjongLogic.checkAllTerminals(tiles)
    for _, tile in ipairs(tiles) do
        if not MahjongTiles.isTerminal(tile) then
            return false
        end
    end
    return true
end

-- Check for All Sequences (平糊)
function MahjongLogic.checkAllSequences(tiles)
    local tileCounts = MahjongTiles.countTileTypes(tiles)
    local pairCount = 0
    local triplets = 0
    local remainingTiles = {}

    -- Count pairs and triplets
    for id, count in pairs(tileCounts) do
        if count == 2 then
            pairCount = pairCount + 1
        elseif count == 3 or count == 4 then
            triplets = triplets + 1
        elseif count == 1 then
            -- Collect single tiles for sequence checking
            for _, tile in ipairs(tiles) do
                if MahjongTiles.getTileId(tile) == id then
                    table.insert(remainingTiles, tile)
                    break
                end
            end
        else
            return false
        end
    end

    -- Need exactly one pair
    if pairCount ~= 1 then return false end

    -- Remaining tiles should form sequences
    local sequenceCount = 0
    local sortedRemaining = MahjongTiles.sortTiles(remainingTiles)

    -- Try to form sequences with remaining tiles
    while #sortedRemaining >= 3 do
        local found = false

        -- Try to find a sequence starting from first tile
        for i = 2, #sortedRemaining - 1 do
            for j = i + 1, #sortedRemaining do
                local candidate = {sortedRemaining[1], sortedRemaining[i], sortedRemaining[j]}
                if MahjongTiles.isSequence(candidate) then
                    sequenceCount = sequenceCount + 1
                    -- Remove used tiles
                    table.remove(sortedRemaining, j)
                    table.remove(sortedRemaining, i)
                    table.remove(sortedRemaining, 1)
                    found = true
                    break
                end
            end
            if found then break end
        end

        if not found then break end
    end

    -- Must be ALL sequences (no triplets) with exactly 1 pair
    -- 平糊 means "all sequences" - specifically no triplets/pungs allowed
    if triplets > 0 then return false end

    local totalGroups = pairCount + sequenceCount
    return #sortedRemaining == 0 and totalGroups == 5 and sequenceCount == 4
end

-- Utility function to count table keys
function MahjongLogic.countTableKeys(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

-- Check for Chicken Hand (雞糊) - basic winning hand with no special patterns
function MahjongLogic.checkChickenHand(tiles)
    -- 雞糊 is a standard mahjong winning hand (4 groups + 1 pair) with no special features
    -- Must have exactly:
    -- - 1 pair (眼)
    -- - 4 groups (triplets or sequences)
    -- - No special patterns (dragons, winds, honors)
    -- - Mixed suits allowed

    local tileCounts = MahjongTiles.countTileTypes(tiles)
    local pairCount = 0
    local triplets = 0
    local hasHonors = false
    local remainingTiles = {}

    -- Count pairs, triplets, and check for honor tiles
    for id, count in pairs(tileCounts) do
        -- Check if this is an honor tile (winds or dragons)
        local tile = nil
        for _, t in ipairs(tiles) do
            if MahjongTiles.getTileId(t) == id then
                tile = t
                break
            end
        end

        if tile then
            -- Check if it's a wind or dragon (honor tile)
            if tile.suit == "winds" or tile.suit == "dragons" then
                hasHonors = true
            end
        end

        if count == 2 then
            pairCount = pairCount + 1
        elseif count == 3 or count == 4 then
            triplets = triplets + 1
        elseif count == 1 then
            -- Collect single tiles for sequence checking
            for _, t in ipairs(tiles) do
                if MahjongTiles.getTileId(t) == id then
                    table.insert(remainingTiles, t)
                    break
                end
            end
        else
            return false -- Invalid count
        end
    end

    -- 雞糊 requirements:
    -- 1. Must be a basic winning hand (1 pair + 4 groups)
    -- 2. Can contain honor tiles (but that's still considered 雞糊)
    -- 3. No special scoring patterns

    -- Need exactly one pair
    if pairCount ~= 1 then return false end

    -- Remaining tiles should form sequences
    local sequenceCount = 0
    local sortedRemaining = MahjongTiles.sortTiles(remainingTiles)

    -- Try to form sequences with remaining tiles
    while #sortedRemaining >= 3 do
        local found = false

        -- Try to find a sequence starting from first tile
        for i = 2, #sortedRemaining - 1 do
            for j = i + 1, #sortedRemaining do
                local candidate = {sortedRemaining[1], sortedRemaining[i], sortedRemaining[j]}
                if MahjongTiles.isSequence(candidate) then
                    sequenceCount = sequenceCount + 1
                    -- Remove used tiles
                    table.remove(sortedRemaining, j)
                    table.remove(sortedRemaining, i)
                    table.remove(sortedRemaining, 1)
                    found = true
                    break
                end
            end
            if found then break end
        end

        if not found then break end
    end

    -- All tiles should be used in sequences or triplets, forming exactly 5 groups total
    local totalGroups = pairCount + triplets + sequenceCount
    local isValidWin = (#sortedRemaining == 0 and totalGroups == 5)

    -- For 雞糊, it's just a basic win - any valid 14-tile winning hand qualifies
    return isValidWin
end

-- Calculate total score based on winning pattern and game context
function MahjongLogic.calculateScore(winPattern, fanValue, gameContext, playedTiles)
    gameContext = gameContext or {}

    local baseFan = fanValue
    local bonusFan = 0

    -- Add number only restriction base faan bonus
    if gameContext.numberOnlyBaseFaan and gameContext.numberOnlyBaseFaan > 0 then
        baseFan = baseFan + gameContext.numberOnlyBaseFaan
        print("🔢 冧把降: 基礎番數 +" .. gameContext.numberOnlyBaseFaan)
    end

    -- Add bonus fan for special conditions
    if gameContext.selfDrawn then bonusFan = bonusFan + 1 end
    if gameContext.lastTile then bonusFan = bonusFan + 1 end
    if gameContext.robKong then bonusFan = bonusFan + 1 end
    if gameContext.afterKong then bonusFan = bonusFan + 1 end

    -- Add weather bonus from typhoon system
    if playedTiles then
        local success, weatherBonus, weatherDetails = pcall(function()
            local WeatherSystem = require("weather_system")
            return WeatherSystem.calculateWeatherBonus(playedTiles)
        end)

        if success then

            bonusFan = bonusFan + (weatherBonus or 0)

            if weatherBonus and weatherBonus > 0 then
                print("🌪️ 颱風加成: +" .. weatherBonus .. "番")
                if weatherDetails then
                    for _, detail in ipairs(weatherDetails) do
                        print("   " .. detail.wind .. "風: +" .. detail.bonus .. "番 (" .. detail.reason .. ")")
                    end
                end
            else
                print("🌪️ 天氣系統: 無額外加成")
            end
        else
            print("⚠ 天氣系統錯誤: " .. tostring(result))
        end

        -- Add east wind boost from consumables
        if gameContext.eastWindBoost and gameContext.eastWindBoost > 0 then
            local eastWindCount = 0
            for _, tile in ipairs(playedTiles) do
                if tile.suit == "wind" and tile.value == "east" then
                    eastWindCount = eastWindCount + 1
                end
            end
            
            if eastWindCount > 0 then
                local eastWindBonus = eastWindCount * gameContext.eastWindBoost
                bonusFan = bonusFan + eastWindBonus
                print("🌪️ 孔明借東風: +" .. eastWindBonus .. "番 (" .. eastWindCount .. "張東風牌)")
            end
        end
    end

    local totalFan = baseFan + bonusFan

    -- Convert fan to points (Hong Kong scoring)
    local basePoints = 8
    if totalFan >= 13 then
        return 8192 -- Maximum
    elseif totalFan >= 10 then
        return 1024
    elseif totalFan >= 8 then
        return 512
    elseif totalFan >= 6 then
        return 256
    elseif totalFan >= 4 then
        return 128
    elseif totalFan >= 3 then
        return 64
    elseif totalFan >= 2 then
        return 32
    else
        return basePoints * (2 ^ totalFan)
    end
end

return MahjongLogic