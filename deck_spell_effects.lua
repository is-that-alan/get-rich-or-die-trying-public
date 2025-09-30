-- Deck Spell Effects

local DeckSpellEffects = {}
local MahjongTiles = require("mahjong_tiles")

-- Helper function to create a new tile
local function createTile(suit, value)
    return { suit = suit, value = value, name = suit .. " " .. value } -- Add a name for easier debugging
end

-- Helper function to generate a random numbered tile
local function createRandomNumberedTile()
    local suits = {"characters", "circles", "bamboos"}
    local suit = suits[math.random(#suits)]
    local value = math.random(1, 9)
    return createTile(suit, value)
end

-- Effect: Remove selected tiles from the deck
function DeckSpellEffects.remove_tiles(deck, selected_tiles)
    local new_deck = {}
    local removed_count = 0
    for _, tile in ipairs(deck) do
        local should_remove = false
        for _, selected in ipairs(selected_tiles) do
            if MahjongTiles.tilesMatch(tile, selected) then
                should_remove = true
                break
            end
        end
        if not should_remove then
            table.insert(new_deck, tile)
        else
            removed_count = removed_count + 1
        end
    end
    return new_deck, "Removed " .. removed_count .. " tiles."
end

-- Effect: Convert all tiles to 1s or 9s of a random suit
function DeckSpellEffects.convert_to_one_and_nine(deck, selected_tiles)
    local new_deck = {}
    local suits = {"characters", "circles", "bamboos"}
    local suit = suits[math.random(#suits)]
    for i = 1, #deck do
        local value = math.random(2) == 1 and 1 or 9
        table.insert(new_deck, createTile(suit, value))
    end
    return new_deck, "Converted all tiles to 1s and 9s of " .. suit .. "."
end

-- Effect: Convert all tiles to 1 dot or west wind
function DeckSpellEffects.convert_to_dot1_or_west(deck, selected_tiles)
    local new_deck = {}
    for i = 1, #deck do
        if math.random(2) == 1 then
            table.insert(new_deck, createTile("dots", 1))
        else
            table.insert(new_deck, createTile("winds", "west"))
        end
    end
    -- Ensure at least one of each
    if #new_deck > 1 then
        new_deck[1] = createTile("dots", 1)
        new_deck[2] = createTile("winds", "west")
    end
    return new_deck, "Converted all tiles to 1 dot or west wind."
end

-- Effect: Convert selected tiles to Red Dragon
function DeckSpellEffects.convert_to_red_dragon(deck, selected_tiles)
    for _, selected in ipairs(selected_tiles) do
        for i, tile in ipairs(deck) do
            if MahjongTiles.tilesMatch(tile, selected) then
                deck[i] = createTile("dragons", "red")
                break
            end
        end
    end
    return deck, "Converted " .. #selected_tiles .. " tiles to Red Dragon."
end

-- Effect: Create copies of selected tiles
function DeckSpellEffects.copy_tiles(deck, selected_tiles)
    for _, selected in ipairs(selected_tiles) do
        table.insert(deck, selected)
    end
    return deck, "Copied " .. #selected_tiles .. " tiles."
end

-- Effect: Remove all wind tiles from the deck
function DeckSpellEffects.remove_all_winds(deck, selected_tiles)
    local new_deck = {}
    local removed_count = 0
    for _, tile in ipairs(deck) do
        if tile.suit ~= "winds" then
            table.insert(new_deck, tile)
        else
            removed_count = removed_count + 1
        end
    end
    return new_deck, "Removed " .. removed_count .. " wind tiles."
end

-- Effect: Convert selected tiles to 3 dot
function DeckSpellEffects.convert_to_3_dot(deck, selected_tiles)
    for _, selected in ipairs(selected_tiles) do
        for i, tile in ipairs(deck) do
            if MahjongTiles.tilesMatch(tile, selected) then
                deck[i] = createTile("dots", 3)
                break
            end
        end
    end
    return deck, "Converted " .. #selected_tiles .. " tiles to 3 dot."
end

-- Effect: Convert selected tiles to bamboo 1
function DeckSpellEffects.convert_to_bamboo_1(deck, selected_tiles)
    for _, selected in ipairs(selected_tiles) do
        for i, tile in ipairs(deck) do
            if MahjongTiles.tilesMatch(tile, selected) then
                deck[i] = createTile("bamboos", 1)
                break
            end
        end
    end
    return deck, "Converted " .. #selected_tiles .. " tiles to bamboo 1."
end

-- Effect: Convert selected tiles to Green Dragon
function DeckSpellEffects.convert_to_green_dragon(deck, selected_tiles)
    for _, selected in ipairs(selected_tiles) do
        for i, tile in ipairs(deck) do
            if MahjongTiles.tilesMatch(tile, selected) then
                deck[i] = createTile("dragons", "green")
                break
            end
        end
    end
    return deck, "Converted " .. #selected_tiles .. " tiles to Green Dragon."
end

-- Effect: Convert selected tiles to White Dragon
function DeckSpellEffects.convert_to_white_dragon(deck, selected_tiles)
    for _, selected in ipairs(selected_tiles) do
        for i, tile in ipairs(deck) do
            if MahjongTiles.tilesMatch(tile, selected) then
                deck[i] = createTile("dragons", "white")
                break
            end
        end
    end
    return deck, "Converted " .. #selected_tiles .. " tiles to White Dragon."
end

-- Effect: Convert selected tiles to character 3
function DeckSpellEffects.convert_to_char_3(deck, selected_tiles)
    for _, selected in ipairs(selected_tiles) do
        for i, tile in ipairs(deck) do
            if MahjongTiles.tilesMatch(tile, selected) then
                deck[i] = createTile("characters", 3)
                break
            end
        end
    end
    return deck, "Converted " .. #selected_tiles .. " tiles to character 3."
end

-- Effect: Convert deck to 10 copies of 8 random tiles
function DeckSpellEffects.convert_to_8_random_tiles(deck, selected_tiles)
    local new_deck = {}
    local random_tiles = {}
    for i = 1, 8 do
        table.insert(random_tiles, createRandomNumberedTile())
    end
    for i = 1, 8 do
        for j = 1, 10 do
            table.insert(new_deck, random_tiles[i])
        end
    end
    return new_deck, "Converted deck to 10 copies of 8 random tiles."
end

return DeckSpellEffects
