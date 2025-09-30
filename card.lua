-- Mahjong Tile System with Image Support
local Card = {}

-- Image cache for tile graphics
Card.images = {}
Card.imagesLoaded = false

-- Load tile images
function Card.loadImages()
    if Card.imagesLoaded then return end

    -- Try to load tile images from tiles/ directory
    local tileFiles = {
        -- Dots
        dot1 = "tiles/dot_1.png", dot2 = "tiles/dot_2.png", dot3 = "tiles/dot_3.png",
        dot4 = "tiles/dot_4.png", dot5 = "tiles/dot_5.png", dot6 = "tiles/dot_6.png",
        dot7 = "tiles/dot_7.png", dot8 = "tiles/dot_8.png", dot9 = "tiles/dot_9.png",

        -- Bamboo
        bam1 = "tiles/bam_1.png", bam2 = "tiles/bam_2.png", bam3 = "tiles/bam_3.png",
        bam4 = "tiles/bam_4.png", bam5 = "tiles/bam_5.png", bam6 = "tiles/bam_6.png",
        bam7 = "tiles/bam_7.png", bam8 = "tiles/bam_8.png", bam9 = "tiles/bam_9.png",

        -- Characters
        char1 = "tiles/char_1.png", char2 = "tiles/char_2.png", char3 = "tiles/char_3.png",
        char4 = "tiles/char_4.png", char5 = "tiles/char_5.png", char6 = "tiles/char_6.png",
        char7 = "tiles/char_7.png", char8 = "tiles/char_8.png", char9 = "tiles/char_9.png",

        -- Winds
        east = "tiles/wind_east.png", south = "tiles/wind_south.png",
        west = "tiles/wind_west.png", north = "tiles/wind_north.png",

        -- Dragons
        red = "tiles/dragon_red.png", green = "tiles/dragon_green.png", white = "tiles/dragon_white.png"
    }

    -- Load images if they exist, otherwise use fallback
    for tileId, filename in pairs(tileFiles) do
        if love.filesystem.getInfo(filename) then
            Card.images[tileId] = love.graphics.newImage(filename)
            print("✓ Loaded tile image: " .. filename)
        else
            print("⚠ Tile image not found: " .. filename .. " (using fallback)")
        end
    end

    Card.imagesLoaded = true
end

-- Mahjong tile database
Card.database = {
    -- Dots (筒子) - 1-9
    dot1 = {id = "dot1", suit = "dots", value = 1, symbol = "🀙", name = "一筒", points = 1},
    dot2 = {id = "dot2", suit = "dots", value = 2, symbol = "🀚", name = "二筒", points = 2},
    dot3 = {id = "dot3", suit = "dots", value = 3, symbol = "🀛", name = "三筒", points = 3},
    dot4 = {id = "dot4", suit = "dots", value = 4, symbol = "🀜", name = "四筒", points = 4},
    dot5 = {id = "dot5", suit = "dots", value = 5, symbol = "🀝", name = "五筒", points = 5},
    dot6 = {id = "dot6", suit = "dots", value = 6, symbol = "🀞", name = "六筒", points = 6},
    dot7 = {id = "dot7", suit = "dots", value = 7, symbol = "🀟", name = "七筒", points = 7},
    dot8 = {id = "dot8", suit = "dots", value = 8, symbol = "🀠", name = "八筒", points = 8},
    dot9 = {id = "dot9", suit = "dots", value = 9, symbol = "🀡", name = "九筒", points = 9},

    -- Bamboo (索子) - 1-9
    bam1 = {id = "bam1", suit = "bamboo", value = 1, symbol = "🀐", name = "一索", points = 1},
    bam2 = {id = "bam2", suit = "bamboo", value = 2, symbol = "🀑", name = "二索", points = 2},
    bam3 = {id = "bam3", suit = "bamboo", value = 3, symbol = "🀒", name = "三索", points = 3},
    bam4 = {id = "bam4", suit = "bamboo", value = 4, symbol = "🀓", name = "四索", points = 4},
    bam5 = {id = "bam5", suit = "bamboo", value = 5, symbol = "🀔", name = "五索", points = 5},
    bam6 = {id = "bam6", suit = "bamboo", value = 6, symbol = "🀕", name = "六索", points = 6},
    bam7 = {id = "bam7", suit = "bamboo", value = 7, symbol = "🀖", name = "七索", points = 7},
    bam8 = {id = "bam8", suit = "bamboo", value = 8, symbol = "🀗", name = "八索", points = 8},
    bam9 = {id = "bam9", suit = "bamboo", value = 9, symbol = "🀘", name = "九索", points = 9},

    -- Characters (萬子) - 1-9
    char1 = {id = "char1", suit = "characters", value = 1, symbol = "🀇", name = "一萬", points = 1},
    char2 = {id = "char2", suit = "characters", value = 2, symbol = "🀈", name = "二萬", points = 2},
    char3 = {id = "char3", suit = "characters", value = 3, symbol = "🀉", name = "三萬", points = 3},
    char4 = {id = "char4", suit = "characters", value = 4, symbol = "🀊", name = "四萬", points = 4},
    char5 = {id = "char5", suit = "characters", value = 5, symbol = "🀋", name = "五萬", points = 5},
    char6 = {id = "char6", suit = "characters", value = 6, symbol = "🀌", name = "六萬", points = 6},
    char7 = {id = "char7", suit = "characters", value = 7, symbol = "🀍", name = "七萬", points = 7},
    char8 = {id = "char8", suit = "characters", value = 8, symbol = "🀎", name = "八萬", points = 8},
    char9 = {id = "char9", suit = "characters", value = 9, symbol = "🀏", name = "九萬", points = 9},

    -- Honor tiles (字牌)
    east = {id = "east", suit = "winds", value = 1, symbol = "🀀", name = "東", points = 10},
    south = {id = "south", suit = "winds", value = 2, symbol = "🀁", name = "南", points = 10},
    west = {id = "west", suit = "winds", value = 3, symbol = "🀂", name = "西", points = 10},
    north = {id = "north", suit = "winds", value = 4, symbol = "🀃", name = "北", points = 10},

    -- Dragons (三元牌)
    red = {id = "red", suit = "dragons", value = 1, symbol = "🀄", name = "紅中", points = 15},
    green = {id = "green", suit = "dragons", value = 2, symbol = "🀅", name = "發財", points = 15},
    white = {id = "white", suit = "dragons", value = 3, symbol = "🀆", name = "白板", points = 15}
}

function Card.getStarterDeck()
    local deck = {}

    -- Add basic tiles (like a simplified mahjong set)
    for i = 1, 9 do
        table.insert(deck, Card.database["dot" .. i])
        table.insert(deck, Card.database["bam" .. i])
        table.insert(deck, Card.database["char" .. i])
    end

    -- Add some honor tiles
    table.insert(deck, Card.database.east)
    table.insert(deck, Card.database.south)
    table.insert(deck, Card.database.red)
    table.insert(deck, Card.database.green)

    return deck
end

function Card.getCardColor(suit)
    if suit == "dots" then
        return {0.31, 0.8, 0.77} -- Teal for dots
    elseif suit == "bamboo" then
        return {0.18, 0.8, 0.44} -- Green for bamboo
    elseif suit == "characters" then
        return {1, 0.42, 0.42} -- Red for characters
    elseif suit == "winds" then
        return {1, 0.9, 0.43} -- Yellow for winds
    elseif suit == "dragons" then
        return {0.64, 0.21, 0.93} -- Purple for dragons
    else
        return {0.58, 0.65, 0.65} -- Gray default
    end
end

function Card.getSuitText(suit)
    if suit == "dots" then
        return "筒子"
    elseif suit == "bamboo" then
        return "索子"
    elseif suit == "characters" then
        return "萬子"
    elseif suit == "winds" then
        return "風牌"
    elseif suit == "dragons" then
        return "三元"
    else
        return suit or "未知"
    end
end

function Card.drawCard(tile, x, y, scale, isSelected)
    if not tile then
        -- Draw placeholder for missing tile
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("fill", x, y, 80 * (scale or 1), 120 * (scale or 1))
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("?", x, y + 50, 80 * (scale or 1), "center")
        return
    end

    -- Ensure images are loaded
    Card.loadImages()

    scale = scale or 1
    local width = 80 * scale
    local height = 120 * scale

    -- Tile shadow
    love.graphics.setColor(0, 0, 0, 0.4)
    love.graphics.rectangle("fill", x + 3, y + 3, width, height, 8)

    -- Check if we have an image for this tile
    local tileImage = Card.images[tile.id]

    if tileImage then
        -- Draw image-based tile
        Card.drawImageTile(tile, tileImage, x, y, width, height, isSelected)
    else
        -- Draw fallback tile with symbols
        Card.drawSymbolTile(tile, x, y, width, height, isSelected)
    end
end

function Card.drawImageTile(tile, image, x, y, width, height, isSelected)
    -- Tile background (white/ivory for authentic look)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", x, y, width, height, 8)

    -- Draw the tile image
    love.graphics.setColor(1, 1, 1)
    local imageWidth = image:getWidth()
    local imageHeight = image:getHeight()

    -- Scale image to fit tile while maintaining aspect ratio
    local scaleX = (width - 8) / imageWidth
    local scaleY = (height - 8) / imageHeight
    local imageScale = math.min(scaleX, scaleY)

    local drawWidth = imageWidth * imageScale
    local drawHeight = imageHeight * imageScale
    local drawX = x + (width - drawWidth) / 2
    local drawY = y + (height - drawHeight) / 2

    love.graphics.draw(image, drawX, drawY, 0, imageScale, imageScale)

    -- Tile border
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height, 8)

    -- Selection highlight
    if isSelected then
        love.graphics.setColor(1, 1, 0)
        love.graphics.setLineWidth(4)
        love.graphics.rectangle("line", x - 2, y - 2, width + 4, height + 4, 8)
    end
    love.graphics.setLineWidth(1)
end

function Card.drawSymbolTile(tile, x, y, width, height, isSelected)
    -- Tile background (traditional mahjong ivory color)
    love.graphics.setColor(0.95, 0.93, 0.88)
    love.graphics.rectangle("fill", x, y, width, height, 8)

    -- Suit color border
    local color = Card.getCardColor(tile.suit)
    love.graphics.setColor(color[1], color[2], color[3], 0.8)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height, 8)

    -- Selection highlight
    if isSelected then
        love.graphics.setColor(1, 1, 0)
        love.graphics.setLineWidth(4)
        love.graphics.rectangle("line", x - 2, y - 2, width + 4, height + 4, 8)
    end
    love.graphics.setLineWidth(1)

    -- Large mahjong symbol in center - use fallback if symbol not available
    love.graphics.setColor(0.1, 0.1, 0.1)
    local displaySymbol = tile.symbol

    -- Fallback text-based symbols if Unicode mahjong symbols don't render
    if not displaySymbol or displaySymbol == "" then
        if tile.suit == "dots" then
            displaySymbol = tile.value .. "筒"
        elseif tile.suit == "bamboo" then
            displaySymbol = tile.value .. "索"
        elseif tile.suit == "characters" then
            displaySymbol = tile.value .. "萬"
        elseif tile.suit == "honors" then
            displaySymbol = tile.name or "?"
        else
            displaySymbol = tile.name or "?"
        end
    end

    love.graphics.printf(displaySymbol, x, y + height/2 - 16, width, "center")

    -- Tile name at bottom
    love.graphics.setColor(color[1], color[2], color[3])
    love.graphics.printf(tile.name or "Unknown", x + 2, y + height - 20, width - 4, "center")

    -- Points indicator in top right
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.circle("fill", x + width - 12, y + 12, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(tostring(tile.points), x + width - 18, y + 6, 12, "center")

    -- Suit indicator at top
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", x + 2, y + 2, width - 4, 16)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(Card.getSuitText(tile.suit), x + 2, y + 4, width - 4, "center")
end

-- Draw character collection (replaces jokers)
function Card.drawCharacter(character, x, y, scale, isSelected)
    if not character then return end

    scale = scale or 1
    local size = 60 * scale

    -- Character background
    local rarity = character.rarity or "common"
    local color = Card.getRarityColor(rarity)

    love.graphics.setColor(color[1], color[2], color[3], 0.8)
    love.graphics.circle("fill", x + size/2, y + size/2, size/2)

    -- Selection highlight
    if isSelected then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setLineWidth(3)
        love.graphics.circle("line", x + size/2, y + size/2, size/2 + 2)
        love.graphics.setLineWidth(1)
    end

    -- Character symbol
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf(character.char, x, y + size/2 - 15, size, "center")

    -- Power indicator if special
    if character.power then
        love.graphics.setColor(1, 1, 0)
        love.graphics.circle("fill", x + size - 8, y + 8, 6)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf("★", x + size - 12, y + 2, 8, "center")
    end
end

function Card.isPointInCard(px, py, x, y, scale)
    scale = scale or 1
    local width = 120 * scale
    local height = 160 * scale
    return px >= x and px <= x + width and py >= y and py <= y + height
end

-- Authentic Mahjong hand evaluation
function Card.evaluateHand(tiles)
    if not tiles or #tiles == 0 or #tiles > 14 then
        return {name = "無牌", score = 0, multiplier = 1, isWinning = false}
    end

    -- Check for authentic mahjong winning patterns
    local handType = Card.getMahjongPattern(tiles)
    return handType
end

function Card.getMahjongPattern(tiles)
    local tileCount = #tiles

    -- Check for authentic mahjong winning patterns
    if tileCount == 14 then
        -- Full mahjong hand - check for winning patterns
        return Card.checkWinningHand(tiles)
    elseif tileCount >= 11 and tileCount <= 13 then
        -- Near-complete hand - check for tenpai (ready to win)
        return Card.checkTenpai(tiles)
    elseif tileCount >= 8 and tileCount <= 10 then
        -- Mid-game hand - check for good shapes
        return Card.checkGoodShape(tiles)
    elseif tileCount >= 5 and tileCount <= 7 then
        -- Early game - check for basic patterns
        return Card.checkBasicPatterns(tiles)
    else
        -- Too few tiles
        return Card.checkSmallPatterns(tiles)
    end
end

-- Check for winning mahjong hands (14 tiles)
function Card.checkWinningHand(tiles)
    -- Standard winning pattern: 4 sets + 1 pair (4×3 + 2 = 14)
    if Card.isStandardWin(tiles) then
        local fan = Card.calculateFan(tiles)
        return {
            name = "和牌 (" .. fan .. "番)",
            score = 1000 + (fan * 500),
            multiplier = fan,
            isWinning = true,
            fan = fan
        }
    end

    -- Special hands
    local specialHand = Card.checkSpecialHands(tiles)
    if specialHand then
        return specialHand
    end

    -- Not a winning hand
    return {name = "未和牌", score = 50, multiplier = 1, isWinning = false}
end

-- Check if hand follows standard winning pattern
function Card.isStandardWin(tiles)
    -- Try to form 4 sets (triplets/sequences) + 1 pair
    local tileCounts = Card.countTiles(tiles)

    -- Find pairs first
    local possiblePairs = {}
    for tileKey, count in pairs(tileCounts) do
        if count >= 2 then
            table.insert(possiblePairs, tileKey)
        end
    end

    -- Try each possible pair
    for _, pairTile in ipairs(possiblePairs) do
        local remainingTiles = Card.copyTileCounts(tileCounts)
        remainingTiles[pairTile] = remainingTiles[pairTile] - 2

        if Card.canFormSets(remainingTiles, 4) then
            return true
        end
    end

    return false
end

-- Check for tenpai (ready to win) - 13 tiles
function Card.checkTenpai(tiles)
    local tileCount = #tiles
    local waitingTiles = Card.findWaitingTiles(tiles)

    if #waitingTiles > 0 then
        return {
            name = "聽牌 (等" .. #waitingTiles .. "種)",
            score = 200 + (#waitingTiles * 50),
            multiplier = 2,
            isWinning = false,
            waiting = waitingTiles
        }
    end

    return {name = "未聽牌", score = 100, multiplier = 1, isWinning = false}
end

-- Check for good shapes (8-10 tiles)
function Card.checkGoodShape(tiles)
    local sets = Card.countCompleteSets(tiles)
    local pairCount = Card.countPairs(tiles)
    local sequences = Card.countSequences(tiles)

    if sets >= 2 then
        return {name = "兩面子", score = 150, multiplier = 1.5, isWinning = false}
    elseif sets == 1 and pairCount >= 1 then
        return {name = "一面子一對", score = 120, multiplier = 1.3, isWinning = false}
    elseif sequences >= 2 then
        return {name = "兩順子", score = 100, multiplier = 1.2, isWinning = false}
    else
        return {name = "散牌", score = 50, multiplier = 1, isWinning = false}
    end
end

-- Check for basic patterns (5-7 tiles)
function Card.checkBasicPatterns(tiles)
    local pairCount = Card.countPairs(tiles)
    local sequences = Card.countSequences(tiles)
    local triplets = Card.countTriplets(tiles)

    if triplets >= 1 then
        return {name = "刻子", score = 80, multiplier = 1.2, isWinning = false}
    elseif sequences >= 1 then
        return {name = "順子", score = 60, multiplier = 1.1, isWinning = false}
    elseif pairCount >= 2 then
        return {name = "兩對", score = 40, multiplier = 1.1, isWinning = false}
    elseif pairCount == 1 then
        return {name = "一對", score = 30, multiplier = 1, isWinning = false}
    else
        return {name = "散牌", score = 20, multiplier = 1, isWinning = false}
    end
end

-- Check small patterns (1-4 tiles)
function Card.checkSmallPatterns(tiles)
    if #tiles == 0 then
        return {name = "無牌", score = 0, multiplier = 1, isWinning = false}
    end

    local pairCount = Card.countPairs(tiles)
    if pairCount >= 1 then
        return {name = "對子", score = 20, multiplier = 1, isWinning = false}
    end

    -- Check for potential sequences
    if Card.hasSequencePotential(tiles) then
        return {name = "搭子", score = 15, multiplier = 1, isWinning = false}
    end

    return {name = "散牌", score = 10, multiplier = 1, isWinning = false}
end

-- Helper functions for mahjong pattern recognition

function Card.countTiles(tiles)
    local counts = {}
    for _, tile in ipairs(tiles) do
        if tile and tile.suit and tile.value then
            local key = tile.suit .. "_" .. tostring(tile.value)
            counts[key] = (counts[key] or 0) + 1
        end
    end
    return counts
end

function Card.copyTileCounts(tileCounts)
    local copy = {}
    for key, count in pairs(tileCounts) do
        copy[key] = count
    end
    return copy
end

function Card.canFormSets(tileCounts, setsNeeded)
    if setsNeeded == 0 then
        -- Check if all tiles are used
        for _, count in pairs(tileCounts) do
            if count > 0 then
                return false
            end
        end
        return true
    end

    -- Try to form a triplet
    for tileKey, count in pairs(tileCounts) do
        if count >= 3 then
            tileCounts[tileKey] = tileCounts[tileKey] - 3
            if Card.canFormSets(tileCounts, setsNeeded - 1) then
                tileCounts[tileKey] = tileCounts[tileKey] + 3
                return true
            end
            tileCounts[tileKey] = tileCounts[tileKey] + 3
        end
    end

    -- Try to form a sequence (only for numbered suits)
    for suit, suitName in pairs({dots = "dots", bamboo = "bamboo", characters = "characters"}) do
        for value = 1, 7 do -- 1-2-3 to 7-8-9
            local key1 = suitName .. "_" .. value
            local key2 = suitName .. "_" .. (value + 1)
            local key3 = suitName .. "_" .. (value + 2)

            if (tileCounts[key1] or 0) >= 1 and
               (tileCounts[key2] or 0) >= 1 and
               (tileCounts[key3] or 0) >= 1 then

                tileCounts[key1] = (tileCounts[key1] or 0) - 1
                tileCounts[key2] = (tileCounts[key2] or 0) - 1
                tileCounts[key3] = (tileCounts[key3] or 0) - 1

                if Card.canFormSets(tileCounts, setsNeeded - 1) then
                    tileCounts[key1] = tileCounts[key1] + 1
                    tileCounts[key2] = tileCounts[key2] + 1
                    tileCounts[key3] = tileCounts[key3] + 1
                    return true
                end

                tileCounts[key1] = tileCounts[key1] + 1
                tileCounts[key2] = tileCounts[key2] + 1
                tileCounts[key3] = tileCounts[key3] + 1
            end
        end
    end

    return false
end

function Card.findWaitingTiles(tiles)
    local waiting = {}

    -- Try adding each possible tile to see if it creates a winning hand
    for _, possibleTile in pairs(Card.database) do
        local testHand = {}
        for _, tile in ipairs(tiles) do
            table.insert(testHand, tile)
        end
        table.insert(testHand, possibleTile)

        if #testHand == 14 and Card.isStandardWin(testHand) then
            table.insert(waiting, possibleTile)
        end
    end

    return waiting
end

function Card.countCompleteSets(tiles)
    local tileCounts = Card.countTiles(tiles)
    local sets = 0

    -- Count triplets
    for _, count in pairs(tileCounts) do
        sets = sets + math.floor(count / 3)
    end

    return sets
end

function Card.countPairs(tiles)
    local tileCounts = Card.countTiles(tiles)
    local pairCount = 0

    for _, count in pairs(tileCounts) do
        pairCount = pairCount + math.floor(count / 2)
    end

    return pairCount
end

function Card.countSequences(tiles)
    local sequences = 0
    local bySuit = {}

    -- Group by suit
    for _, tile in ipairs(tiles) do
        if tile.suit == "dots" or tile.suit == "bamboo" or tile.suit == "characters" then
            bySuit[tile.suit] = bySuit[tile.suit] or {}
            bySuit[tile.suit][tile.value] = (bySuit[tile.suit][tile.value] or 0) + 1
        end
    end

    -- Count sequences in each suit
    for suit, values in pairs(bySuit) do
        for value = 1, 7 do
            local count1 = values[value] or 0
            local count2 = values[value + 1] or 0
            local count3 = values[value + 2] or 0

            local seqCount = math.min(count1, count2, count3)
            sequences = sequences + seqCount
        end
    end

    return sequences
end

function Card.countTriplets(tiles)
    local tileCounts = Card.countTiles(tiles)
    local triplets = 0

    for _, count in pairs(tileCounts) do
        if count >= 3 then
            triplets = triplets + 1
        end
    end

    return triplets
end

function Card.hasSequencePotential(tiles)
    -- Check for potential sequences (like 1-2 waiting for 3, or 2-4 waiting for 3)
    local bySuit = {}

    for _, tile in ipairs(tiles) do
        if tile.suit == "dots" or tile.suit == "bamboo" or tile.suit == "characters" then
            bySuit[tile.suit] = bySuit[tile.suit] or {}
            table.insert(bySuit[tile.suit], tile.value)
        end
    end

    for suit, values in pairs(bySuit) do
        table.sort(values)
        for i = 1, #values - 1 do
            local diff = values[i + 1] - values[i]
            if diff == 1 or diff == 2 then -- Adjacent or one gap
                return true
            end
        end
    end

    return false
end

function Card.calculateFan(tiles)
    local fan = 1 -- Base fan

    -- Add fan for special patterns
    if Card.isAllSameSuit(tiles) then
        fan = fan + 2 -- 清一色
    end

    if Card.hasAllHonors(tiles) then
        fan = fan + 3 -- 字一色
    end

    if Card.isAllTriplets(tiles) then
        fan = fan + 2 -- 對對和
    end

    return fan
end

function Card.checkSpecialHands(tiles)
    -- Check for special winning hands
    if Card.isThirteenOrphans(tiles) then
        return {name = "十三么", score = 5000, multiplier = 10, isWinning = true, fan = 10}
    end

    if Card.isSevenPairs(tiles) then
        return {name = "七對子", score = 2000, multiplier = 4, isWinning = true, fan = 4}
    end

    return nil
end

function Card.isAllSameSuit(tiles)
    local firstSuit = nil
    for _, tile in ipairs(tiles) do
        if tile.suit ~= "winds" and tile.suit ~= "dragons" then
            if firstSuit == nil then
                firstSuit = tile.suit
            elseif tile.suit ~= firstSuit then
                return false
            end
        end
    end
    return firstSuit ~= nil
end

function Card.hasAllHonors(tiles)
    for _, tile in ipairs(tiles) do
        if tile.suit ~= "winds" and tile.suit ~= "dragons" then
            return false
        end
    end
    return true
end

function Card.isAllTriplets(tiles)
    local tileCounts = Card.countTiles(tiles)
    for _, count in pairs(tileCounts) do
        if count ~= 2 and count ~= 3 then
            return false
        end
    end
    return true
end

function Card.isThirteenOrphans(tiles)
    -- Check for 13 different terminal and honor tiles + 1 pair
    -- This is a very rare special hand
    return false -- Simplified for now
end

function Card.isSevenPairs(tiles)
    -- Check for exactly 7 different pairs
    local tileCounts = Card.countTiles(tiles)
    local pairCount = 0

    for _, count in pairs(tileCounts) do
        if count == 2 then
            pairCount = pairCount + 1
        elseif count ~= 0 then
            return false
        end
    end

    return pairCount == 7
end

-- Meme phrase system
function Card.checkMemePhrase(characters)
    for phrase, meme in pairs(Card.memeDatabase) do
        if Card.hasAllCharacters(characters, meme.characters) then
            return meme
        end
    end
    return nil
end

function Card.hasAllCharacters(playerChars, requiredChars)
    local available = {}
    for _, char in ipairs(playerChars) do
        available[char.char] = (available[char.char] or 0) + 1
    end

    for _, required in ipairs(requiredChars) do
        if not available[required] or available[required] <= 0 then
            return false
        end
        available[required] = available[required] - 1
    end

    return true
end

function Card.getCardRarity(tile)
    if not tile then
        return "common"
    end

    if tile.suit == "dragons" then
        return "epic"
    elseif tile.suit == "winds" then
        return "rare"
    elseif tile.value == 1 or tile.value == 9 then
        return "uncommon" -- Terminal tiles
    else
        return "common"
    end
end

function Card.getRarityColor(rarity)
    if rarity == "legendary" then
        return {1, 0.84, 0} -- Gold
    elseif rarity == "epic" then
        return {0.64, 0.21, 0.93} -- Purple
    elseif rarity == "rare" then
        return {0.25, 0.41, 1} -- Blue
    elseif rarity == "uncommon" then
        return {0.12, 0.7, 0.17} -- Green
    else
        return {0.6, 0.6, 0.6} -- Gray
    end
end

return Card