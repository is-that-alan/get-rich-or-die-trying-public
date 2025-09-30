-- Mahjong Tiles Module
-- Handles all tile-related operations, matching, grouping, and identification

local MahjongTiles = {}

-- Tile constants
MahjongTiles.SUITS = {
    -- Chinese characters
    ["萬"] = "characters", ["筒"] = "circles", ["條"] = "bamboos",
    ["東"] = "winds", ["南"] = "winds", ["西"] = "winds", ["北"] = "winds",
    ["中"] = "dragons", ["發"] = "dragons", ["白"] = "dragons",
    -- English suit names (from deck creation)
    ["char"] = "characters", ["dot"] = "circles", ["bam"] = "bamboos",
    ["wind"] = "winds", ["dragon"] = "dragons"
}

MahjongTiles.SUIT_ORDER = {"characters", "circles", "bamboos", "winds", "dragons"}

-- Get standardized tile identifier
function MahjongTiles.getTileId(tile)
    if not tile then return nil end
    return tile.suit .. "_" .. tile.value
end

-- Check if two tiles are identical
function MahjongTiles.tilesMatch(tile1, tile2)
    if not tile1 or not tile2 then return false end
    return tile1.suit == tile2.suit and tile1.value == tile2.value
end

-- Get tile suit category
function MahjongTiles.getSuitCategory(tile)
    if not tile then return nil end

    -- First try to get category from suit mapping
    if tile.suit and MahjongTiles.SUITS[tile.suit] then
        return MahjongTiles.SUITS[tile.suit]
    end

    -- Fall back to type field if available
    if tile.type then
        return tile.type
    end

    -- Last resort: return suit as-is
    return tile.suit
end

-- Check if tile is a terminal (1 or 9 in suited tiles)
function MahjongTiles.isTerminal(tile)
    if not tile then return false end
    local category = MahjongTiles.getSuitCategory(tile)
    if category == "characters" or category == "circles" or category == "bamboos" then
        return tile.value == 1 or tile.value == 9
    end
    return false
end

-- Check if tile is an honor (winds or dragons)
function MahjongTiles.isHonor(tile)
    if not tile then return false end
    local category = MahjongTiles.getSuitCategory(tile)
    return category == "winds" or category == "dragons"
end

-- Check if tile is terminal or honor
function MahjongTiles.isTerminalOrHonor(tile)
    return MahjongTiles.isTerminal(tile) or MahjongTiles.isHonor(tile)
end

-- Group tiles by suit and value
function MahjongTiles.groupTiles(tiles)
    local groups = {}
    for _, tile in ipairs(tiles) do
        local id = MahjongTiles.getTileId(tile)
        if id then
            groups[id] = groups[id] or {}
            table.insert(groups[id], tile)
        end
    end
    return groups
end

-- Count occurrences of each tile type
function MahjongTiles.countTileTypes(tiles)
    local counts = {}
    for _, tile in ipairs(tiles) do
        local id = MahjongTiles.getTileId(tile)
        if id then
            counts[id] = (counts[id] or 0) + 1
        end
    end
    return counts
end

-- Sort tiles by suit and value (Corrected Implementation)
function MahjongTiles.sortTiles(tiles)
    if not tiles or #tiles == 0 then return {} end

    local sorted = {}
    for _, tile in ipairs(tiles) do
        table.insert(sorted, tile)
    end

    local SUIT_WEIGHTS = {
        characters = 1,
        circles = 2,
        bamboos = 3,
        winds = 4,
        dragons = 5,
        flowers = 6 -- Added for completeness
    }

    local HONOR_WEIGHTS = {
        -- Winds (Chinese names)
        ["東"] = 1, ["南"] = 2, ["西"] = 3, ["北"] = 4,
        -- Dragons (Chinese names)
        ["中"] = 5, ["發"] = 6, ["白"] = 7,
        -- Winds (English names from deck)
        ["east"] = 1, ["south"] = 2, ["west"] = 3, ["north"] = 4,
        -- Dragons (English names from deck)
        ["red"] = 5, ["green"] = 6, ["white"] = 7
    }

    table.sort(sorted, function(a, b)
        -- Handle nil tiles gracefully
        if not a or not a.suit then return false end
        if not b or not b.suit then return true end

        local categoryA = MahjongTiles.getSuitCategory(a)
        local categoryB = MahjongTiles.getSuitCategory(b)

        local weightA = SUIT_WEIGHTS[categoryA] or 99
        local weightB = SUIT_WEIGHTS[categoryB] or 99

        if weightA ~= weightB then
            return weightA < weightB
        end

        -- If suits are the same category, sort by value
        if categoryA == "winds" or categoryA == "dragons" then
            -- For honor tiles, check both suit and value fields for mapping
            local valueA = HONOR_WEIGHTS[a.suit] or HONOR_WEIGHTS[a.value] or 99
            local valueB = HONOR_WEIGHTS[b.suit] or HONOR_WEIGHTS[b.value] or 99
            return valueA < valueB
        else
            -- Numbered tiles
            local valueA = tonumber(a.value) or 0
            local valueB = tonumber(b.value) or 0
            return valueA < valueB
        end
    end)

    return sorted
end

-- Check if tiles form a sequence (consecutive values in same suit)
function MahjongTiles.isSequence(tiles)
    if #tiles ~= 3 then return false end

    local sorted = MahjongTiles.sortTiles(tiles)
    local suit = sorted[1].suit

    -- All tiles must be same suit
    for _, tile in ipairs(sorted) do
        if tile.suit ~= suit then return false end
    end

    -- Must be numbered tiles (not honors)
    if MahjongTiles.isHonor(sorted[1]) then return false end

    -- Check consecutive values
    local values = {}
    for _, tile in ipairs(sorted) do
        local val = tonumber(tile.value)
        if not val then return false end
        table.insert(values, val)
    end

    table.sort(values)
    return values[2] == values[1] + 1 and values[3] == values[2] + 1
end

-- Check if tiles form a triplet (same tile three times)
function MahjongTiles.isTriplet(tiles)
    if #tiles ~= 3 then return false end

    local first = tiles[1]
    for i = 2, #tiles do
        if not MahjongTiles.tilesMatch(first, tiles[i]) then
            return false
        end
    end
    return true
end

-- Check if tiles form a pair (same tile twice)
function MahjongTiles.isPair(tiles)
    if #tiles ~= 2 then return false end
    return MahjongTiles.tilesMatch(tiles[1], tiles[2])
end

-- Find all valid groups (pairs, triplets, sequences) from tiles
function MahjongTiles.findValidGroups(tiles)
    local groups = {
        pairs = {},
        triplets = {},
        sequences = {}
    }

    local tileCounts = MahjongTiles.countTileTypes(tiles)

    -- Find pairs and triplets
    for tileId, count in pairs(tileCounts) do
        if count >= 2 then
            -- Create sample tiles for this type
            local sampleTiles = {}
            for _, tile in ipairs(tiles) do
                if MahjongTiles.getTileId(tile) == tileId then
                    table.insert(sampleTiles, tile)
                    if #sampleTiles >= count then break end
                end
            end

            if count >= 2 then
                table.insert(groups.pairs, {sampleTiles[1], sampleTiles[2]})
            end
            if count >= 3 then
                table.insert(groups.triplets, {sampleTiles[1], sampleTiles[2], sampleTiles[3]})
            end
        end
    end

    -- Find sequences (more complex - need to check consecutive values)
    local suitGroups = {}
    for _, tile in ipairs(tiles) do
        local category = MahjongTiles.getSuitCategory(tile)
        if category == "characters" or category == "circles" or category == "bamboos" then
            suitGroups[tile.suit] = suitGroups[tile.suit] or {}
            table.insert(suitGroups[tile.suit], tile)
        end
    end

    for suit, suitTiles in pairs(suitGroups) do
        local sorted = MahjongTiles.sortTiles(suitTiles)

        -- Try all possible 3-tile combinations for sequences
        for i = 1, #sorted - 2 do
            for j = i + 1, #sorted - 1 do
                for k = j + 1, #sorted do
                    local candidate = {sorted[i], sorted[j], sorted[k]}
                    if MahjongTiles.isSequence(candidate) then
                        table.insert(groups.sequences, candidate)
                    end
                end
            end
        end
    end

    return groups
end

-- Remove tiles from a collection
function MahjongTiles.removeTiles(fromTiles, tilesToRemove)
    local result = {}
    local toRemove = {}

    -- Mark tiles to remove
    for _, removeThis in ipairs(tilesToRemove) do
        for i, tile in ipairs(fromTiles) do
            if not toRemove[i] and MahjongTiles.tilesMatch(tile, removeThis) then
                toRemove[i] = true
                break
            end
        end
    end

    -- Copy non-removed tiles
    for i, tile in ipairs(fromTiles) do
        if not toRemove[i] then
            table.insert(result, tile)
        end
    end

    return result
end

-- Get display character for tile
function MahjongTiles.getDisplayChar(tile)
    if not tile then return "?" end

    -- Use suit as display (works with Chinese characters)
    if type(tile.suit) == "string" then
        return tile.suit
    end

    -- For special cases
    local display = tile.display or tile.suit or "?"
    -- Don't try to substring Chinese characters - use the whole string
    return tostring(display)
end

return MahjongTiles