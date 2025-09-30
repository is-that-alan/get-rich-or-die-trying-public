-- Mahjong Deck Management Module
-- Handles deck creation, shuffling, dealing, and tile management

local MahjongTiles = require("mahjong_tiles")
local MahjongDeck = {}

-- Standard mahjong deck composition (using English names matching PNG files)
MahjongDeck.STANDARD_DECK = {
    -- Characters (萬子) 1-9, 4 of each
    {suit = "char", value = 1, type = "characters"},
    {suit = "char", value = 2, type = "characters"},
    {suit = "char", value = 3, type = "characters"},
    {suit = "char", value = 4, type = "characters"},
    {suit = "char", value = 5, type = "characters"},
    {suit = "char", value = 6, type = "characters"},
    {suit = "char", value = 7, type = "characters"},
    {suit = "char", value = 8, type = "characters"},
    {suit = "char", value = 9, type = "characters"},

    -- Circles (筒子) 1-9, 4 of each
    {suit = "dot", value = 1, type = "circles"},
    {suit = "dot", value = 2, type = "circles"},
    {suit = "dot", value = 3, type = "circles"},
    {suit = "dot", value = 4, type = "circles"},
    {suit = "dot", value = 5, type = "circles"},
    {suit = "dot", value = 6, type = "circles"},
    {suit = "dot", value = 7, type = "circles"},
    {suit = "dot", value = 8, type = "circles"},
    {suit = "dot", value = 9, type = "circles"},

    -- Bamboos (條子) 1-9, 4 of each
    {suit = "bam", value = 1, type = "bamboos"},
    {suit = "bam", value = 2, type = "bamboos"},
    {suit = "bam", value = 3, type = "bamboos"},
    {suit = "bam", value = 4, type = "bamboos"},
    {suit = "bam", value = 5, type = "bamboos"},
    {suit = "bam", value = 6, type = "bamboos"},
    {suit = "bam", value = 7, type = "bamboos"},
    {suit = "bam", value = 8, type = "bamboos"},
    {suit = "bam", value = 9, type = "bamboos"},

    -- Winds (風牌) 4 of each
    {suit = "wind", value = "east", type = "winds"},
    {suit = "wind", value = "south", type = "winds"},
    {suit = "wind", value = "west", type = "winds"},
    {suit = "wind", value = "north", type = "winds"},

    -- Dragons (箭牌) 4 of each
    {suit = "dragon", value = "red", type = "dragons"},
    {suit = "dragon", value = "green", type = "dragons"},
    {suit = "dragon", value = "white", type = "dragons"}
}

-- Create a new standard mahjong deck (144 tiles total)
function MahjongDeck.createStandardDeck()
    local deck = {}

    for _, template in ipairs(MahjongDeck.STANDARD_DECK) do
        -- Add 4 copies of each tile type
        for i = 1, 4 do
            local tile = {
                suit = template.suit,
                value = template.value,
                type = template.type,
                id = template.suit .. "_" .. template.value .. "_" .. i,
                display = template.suit
            }
            table.insert(deck, tile)
        end
    end

    return deck
end

-- Shuffle a deck using Fisher-Yates algorithm
function MahjongDeck.shuffleDeck(deck)
    local shuffled = {}
    for i, tile in ipairs(deck) do
        shuffled[i] = tile
    end

    for i = #shuffled, 2, -1 do
        local j = math.random(i)
        shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
    end

    return shuffled
end

-- Deal initial hands to players
function MahjongDeck.dealHands(deck, numPlayers, handSize)
    numPlayers = numPlayers or 4
    handSize = handSize or 13

    local hands = {}
    local deckIndex = 1

    -- Initialize empty hands
    for i = 1, numPlayers do
        hands[i] = {}
    end

    -- Deal cards round-robin style
    for round = 1, handSize do
        for player = 1, numPlayers do
            if deckIndex <= #deck then
                table.insert(hands[player], deck[deckIndex])
                deckIndex = deckIndex + 1
            end
        end
    end

    -- Return hands and remaining deck
    local remainingDeck = {}
    for i = deckIndex, #deck do
        table.insert(remainingDeck, deck[i])
    end

    return hands, remainingDeck
end

-- Draw tiles from deck
function MahjongDeck.drawTiles(deck, count)
    count = count or 1
    local drawn = {}

    for i = 1, math.min(count, #deck) do
        table.insert(drawn, table.remove(deck, 1))
    end

    return drawn, deck
end

-- Add tiles back to deck (for discards)
function MahjongDeck.addTilesToDeck(deck, tiles, position)
    position = position or "bottom" -- "top" or "bottom"

    if position == "top" then
        for i = #tiles, 1, -1 do
            table.insert(deck, 1, tiles[i])
        end
    else
        for _, tile in ipairs(tiles) do
            table.insert(deck, tile)
        end
    end

    return deck
end

-- Check if deck has enough tiles
function MahjongDeck.hasEnoughTiles(deck, count)
    return #deck >= count
end

-- Get deck statistics
function MahjongDeck.getDeckStats(deck)
    local stats = {
        total = #deck,
        suits = {},
        types = {}
    }

    for _, tile in ipairs(deck) do
        -- Count by suit
        stats.suits[tile.suit] = (stats.suits[tile.suit] or 0) + 1

        -- Count by type
        local category = MahjongTiles.getSuitCategory(tile)
        stats.types[category] = (stats.types[category] or 0) + 1
    end

    return stats
end

-- Create a deck from specific tiles (for testing or custom games)
function MahjongDeck.createCustomDeck(tileSpecs)
    local deck = {}

    for _, spec in ipairs(tileSpecs) do
        local count = spec.count or 1
        for i = 1, count do
            local tile = {
                suit = spec.suit,
                value = spec.value,
                type = spec.type or MahjongTiles.getSuitCategory({suit = spec.suit}),
                id = spec.suit .. "_" .. spec.value .. "_" .. i,
                display = spec.display or spec.suit
            }
            table.insert(deck, tile)
        end
    end

    return deck
end

-- Remove specific tiles from deck
function MahjongDeck.removeTilesFromDeck(deck, tilesToRemove)
    return MahjongTiles.removeTiles(deck, tilesToRemove)
end

-- Find tiles in deck by criteria
function MahjongDeck.findTilesInDeck(deck, criteria)
    local found = {}

    for _, tile in ipairs(deck) do
        local matches = true

        if criteria.suit and tile.suit ~= criteria.suit then matches = false end
        if criteria.value and tile.value ~= criteria.value then matches = false end
        if criteria.type and tile.type ~= criteria.type then matches = false end

        if matches then
            table.insert(found, tile)
        end
    end

    return found
end

-- Validate deck integrity (check for correct number of each tile)
function MahjongDeck.validateDeck(deck)
    local tileCounts = MahjongTiles.countTileTypes(deck)
    local errors = {}

    -- Check each tile type should have exactly 4 copies
    for _, template in ipairs(MahjongDeck.STANDARD_DECK) do
        local id = template.suit .. "_" .. template.value
        local count = tileCounts[id] or 0

        if count ~= 4 then
            table.insert(errors, string.format("Tile %s has %d copies (expected 4)", id, count))
        end
    end

    -- Check for unknown tiles
    local knownTiles = {}
    for _, template in ipairs(MahjongDeck.STANDARD_DECK) do
        knownTiles[template.suit .. "_" .. template.value] = true
    end

    for id, count in pairs(tileCounts) do
        if not knownTiles[id] then
            table.insert(errors, string.format("Unknown tile type: %s (%d copies)", id, count))
        end
    end

    return #errors == 0, errors
end

-- Create a deck for testing specific scenarios
function MahjongDeck.createTestDeck(scenario)
    if scenario == "winning_hand" then
        -- Create a deck where first 14 tiles form a winning hand
        return MahjongDeck.createCustomDeck({
            {suit = "一", value = 1, count = 3}, -- Triplet
            {suit = "二", value = 2, count = 3}, -- Triplet
            {suit = "三", value = 3, count = 3}, -- Triplet
            {suit = "四", value = 4, count = 3}, -- Triplet
            {suit = "五", value = 5, count = 2}, -- Pair
            -- Fill rest with random tiles
            {suit = "筒", value = 1, count = 20},
            {suit = "條", value = 1, count = 20},
        })
    elseif scenario == "thirteen_terminals" then
        return MahjongDeck.createCustomDeck({
            {suit = "一", value = 1, count = 2},
            {suit = "九", value = 9, count = 1},
            {suit = "筒", value = 1, count = 1},
            {suit = "筒", value = 9, count = 1},
            {suit = "條", value = 1, count = 1},
            {suit = "條", value = 9, count = 1},
            {suit = "東", value = "東", count = 1},
            {suit = "南", value = "南", count = 1},
            {suit = "西", value = "西", count = 1},
            {suit = "北", value = "北", count = 1},
            {suit = "中", value = "中", count = 1},
            {suit = "發", value = "發", count = 1},
            {suit = "白", value = "白", count = 1},
            -- Fill rest
            {suit = "二", value = 2, count = 20},
        })
    else
        return MahjongDeck.createStandardDeck()
    end
end

return MahjongDeck