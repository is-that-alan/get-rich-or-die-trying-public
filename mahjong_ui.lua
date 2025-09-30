-- Mahjong UI Module
-- Handles all rendering, drawing, and UI layout functions

local MahjongUI = MahjongUI or {}

-- =============================
-- Defaults / State
-- =============================

MahjongUI.tileImageCache = MahjongUI.tileImageCache or {}

MahjongUI.DIMENSIONS = MahjongUI.DIMENSIONS or {
    TILE_WIDTH    = 48,  -- Reduced from 64 to 48 (25% smaller)
    TILE_HEIGHT   = 66,  -- Reduced from 88 to 66 (25% smaller)
    TILE_MARGIN   = 6,   -- Reduced from 8 to 6
    HEADER_HEIGHT = 64,
}

-- All colors are 0..1
MahjongUI.COLORS = MahjongUI.COLORS or {
    BACKGROUND      = {0.1, 0.15, 0.25, 1.0},    -- Deeper navy blue
    TILE_SELECTED   = {1.0, 0.9, 0.3, 1.0},     -- Bright gold for selection
    TILE_BACKGROUND = {0.95, 0.95, 0.95, 1.0},
    TILE_BORDER     = {0.20, 0.20, 0.20, 1.0},
    TEXT_MAIN       = {1.0, 1.0, 1.0, 1.0},     -- White text
    TEXT_SECONDARY  = {0.8, 0.8, 0.8, 1.0},     -- Light gray
    PLAYED_AREA     = {0.1, 0.5, 0.3, 0.15},      -- Kept for contrast
    WIN_HIGHLIGHT   = {0.2, 0.8, 0.3, 0.3},

    -- Unified UI panels (Warm Gold/Brown theme)
    PANEL_BG        = {0.3, 0.25, 0.15, 0.9},   -- Rich, warm brown
    PANEL_BORDER    = {0.9, 0.7, 0.2, 1.0},      -- Bright, warm gold border

    -- Highlights
    SCORE_POSITIVE  = {0.3, 0.6, 0.9, 1.0},      -- Blue for positive scores/info
    SCORE_NEGATIVE  = {0.9, 0.3, 0.3, 1.0},      -- Red for negative/warnings
    MONEY_COLOR     = {0.9, 0.8, 0.2, 1.0},      -- Gold for money

    BUTTON          = {0.4, 0.35, 0.25, 1.0},    -- Darker brown for buttons
    BUTTON_HOVER    = {0.5, 0.45, 0.35, 1.0},
    BUTTON_PRESSED  = {0.3, 0.25, 0.15, 1.0},
}

-- Cache fonts once. Use Chinese-compatible fonts if available.
local function createChineseFontSafe(size)
    if createChineseFontSize then
        return createChineseFontSize(size)
    elseif _G.CHINESE_FONT_PATH then
        local success, font = pcall(love.graphics.newFont, _G.CHINESE_FONT_PATH, size)
        if success then
            return font
        end
    end
    return love.graphics.newFont(size)
end

MahjongUI.fonts = MahjongUI.fonts or {
    tiny   = createChineseFontSafe(10),
    small  = createChineseFontSafe(12),
    normal = createChineseFontSafe(16),
    mid    = createChineseFontSafe(18),
    large  = createChineseFontSafe(20),
    title  = createChineseFontSafe(24),
}

-- =============================
-- Helpers
-- =============================

-- Convert a tile (string or table) into a file key like "dot_5", "wind_east", etc.
local function toTileKey(tile)
    if type(tile) == "string" then
        -- Handle direct string keys like "筒9", "條3", etc.
        local chineseToEnglish = {
            ["筒"] = "dot_",
            ["條"] = "bam_",
            ["萬"] = "char_",
            ["東"] = "wind_east",
            ["南"] = "wind_south",
            ["西"] = "wind_west",
            ["北"] = "wind_north",
            ["紅"] = "dragon_red",
            ["發"] = "dragon_green",
            ["白"] = "dragon_white"
        }

        -- Check for direct wind/dragon mappings
        if chineseToEnglish[tile] then
            return chineseToEnglish[tile]
        end

        -- Check for suit+number combinations like "筒9", "條3", "筒_4", "條_2", etc.
        for chinese, english in pairs(chineseToEnglish) do
            if english:find("_$") then
                -- Handle formats like "筒_4" or "筒4"
                local pattern1 = "^" .. chinese .. "_(%d+)$"
                local pattern2 = "^" .. chinese .. "(%d+)$"

                local number = tile:match(pattern1) or tile:match(pattern2)
                if number then
                    return english .. number
                end
            end
        end

        -- Handle special wind/dragon cases like "東_東", "白_白", etc.
        local specialMappings = {
            ["東_東"] = "wind_east",
            ["南_南"] = "wind_south",
            ["西_西"] = "wind_west",
            ["北_北"] = "wind_north",
            ["紅_紅"] = "dragon_red",
            ["發_發"] = "dragon_green",
            ["白_白"] = "dragon_white",
            ["中_中"] = "dragon_red" -- Alternative for red dragon
        }

        if specialMappings[tile] then
            return specialMappings[tile]
        end

        -- Handle Chinese number characters like "一_1", "二_2", etc.
        local numberMappings = {
            ["一_1"] = "char_1", ["二_2"] = "char_2", ["三_3"] = "char_3",
            ["四_4"] = "char_4", ["五_5"] = "char_5", ["六_6"] = "char_6",
            ["七_7"] = "char_7", ["八_8"] = "char_8", ["九_9"] = "char_9"
        }

        if numberMappings[tile] then
            return numberMappings[tile]
        end

        return tile -- Return as-is if no mapping found
    end

    if type(tile) == "table" then
        -- Prefer a canonical key if your tile system provides it
        if MahjongTiles and MahjongTiles.getKey then
            return MahjongTiles.getKey(tile)
        end

        -- Handle tile tables with suit and value
        if tile.suit and tile.value then
            local suitMapping = {
                ["筒"] = "dot_",
                ["dots"] = "dot_",
                ["circles"] = "dot_",
                ["dot"] = "dot_",  -- Direct English mapping
                ["條"] = "bam_",
                ["bamboos"] = "bam_",
                ["bamboo"] = "bam_",
                ["bam"] = "bam_",  -- Direct English mapping
                ["萬"] = "char_",
                ["characters"] = "char_",
                ["char"] = "char_",  -- Direct English mapping
                ["萬子"] = "char_",
                ["筒子"] = "dot_",
                ["條子"] = "bam_"
            }

            local englishSuit = suitMapping[tile.suit]
            if englishSuit and tile.value then
                return englishSuit .. tostring(tile.value)
            end

            -- Handle wind tiles
            if tile.suit == "wind" or tile.suit == "winds" then
                local windMapping = {
                    ["east"] = "wind_east",
                    ["south"] = "wind_south",
                    ["west"] = "wind_west",
                    ["north"] = "wind_north",
                    ["東"] = "wind_east",
                    ["南"] = "wind_south",
                    ["西"] = "wind_west",
                    ["北"] = "wind_north",
                    -- Handle numeric values from card system
                    [1] = "wind_east",
                    [2] = "wind_south",
                    [3] = "wind_west",
                    [4] = "wind_north"
                }
                return windMapping[tile.value] or ("wind_" .. tostring(tile.value))
            end

            -- Handle dragon tiles
            if tile.suit == "dragon" or tile.suit == "dragons" then
                local dragonMapping = {
                    ["red"] = "dragon_red",
                    ["green"] = "dragon_green",
                    ["white"] = "dragon_white",
                    ["紅"] = "dragon_red",
                    ["發"] = "dragon_green",
                    ["白"] = "dragon_white",
                    -- Handle numeric values from card system
                    [1] = "dragon_red",
                    [2] = "dragon_green",
                    [3] = "dragon_white"
                }
                return dragonMapping[tile.value] or ("dragon_" .. tostring(tile.value))
            end
        end

        -- Handle wind tiles directly by type
        if tile.wind then
            local windMapping = {
                ["east"] = "wind_east",
                ["south"] = "wind_south",
                ["west"] = "wind_west",
                ["north"] = "wind_north",
                ["東"] = "wind_east",
                ["南"] = "wind_south",
                ["西"] = "wind_west",
                ["北"] = "wind_north"
            }
            return windMapping[tile.wind] or ("wind_" .. tostring(tile.wind))
        end

        -- Handle dragon tiles directly by type
        if tile.dragon then
            local dragonMapping = {
                ["red"] = "dragon_red",
                ["green"] = "dragon_green",
                ["white"] = "dragon_white",
                ["紅"] = "dragon_red",
                ["發"] = "dragon_green",
                ["白"] = "dragon_white"
            }
            return dragonMapping[tile.dragon] or ("dragon_" .. tostring(tile.dragon))
        end

        -- Fallback to key field
        if tile.key then return tile.key end
    end

    return nil
end

-- =============================
-- Image loading / caching
-- =============================

function MahjongUI.getTileImage(tile)
    local tileKey = toTileKey(tile)
    if not tileKey then return nil end

    local cache = MahjongUI.tileImageCache
    local cached = cache[tileKey]
    if cached then return cached end

    local filename = ("tiles/%s.png"):format(tileKey)
    local info = love.filesystem.getInfo(filename, "file")
    if not info then
        print("✗ Tile file not found: " .. filename)
        return nil
    end

    print("✓ Tile file exists: " .. filename)
    local ok, img = pcall(love.graphics.newImage, filename)
    if ok and img then
        cache[tileKey] = img
        print("✓ Loaded tile image: " .. tileKey)
        return img
    else
        print("✗ Failed to load image: " .. filename)
        return nil
    end
end

-- =============================
-- Drawing: Tiles
-- =============================

-- Draw a single mahjong tile
function MahjongUI.drawTile(tile, x, y, selected, scale, animationData)
    selected = selected or false
    scale = scale or 1
    animationData = animationData or nil

    -- Animation effects for newly drawn tiles
    local animScale = scale
    local glowAlpha = 0
    local bounceOffset = 0

    if animationData then
        local progress = math.min(animationData.animationTime / animationData.maxAnimTime, 1)
        local easeOut = 1 - math.pow(1 - progress, 3)  -- Ease-out cubic

        -- Scaling animation: start big, shrink to normal
        animScale = scale * (1.0 + (1 - easeOut) * 0.3)

        -- Glow effect: bright at start, fade out
        glowAlpha = (1 - progress) * 0.8

        -- Bounce effect: settle into position
        bounceOffset = -math.sin(progress * math.pi) * 15 * (1 - progress)
    end

    -- Selected tiles get subtle visual effects
    local yOffset = selected and -6 or 0       -- Lift up slightly when selected
    yOffset = yOffset + bounceOffset

    local width  = MahjongUI.DIMENSIONS.TILE_WIDTH * animScale
    local height = MahjongUI.DIMENSIONS.TILE_HEIGHT * animScale

    -- Center the animated tile
    local drawX = x - (width - MahjongUI.DIMENSIONS.TILE_WIDTH * scale) / 2
    local drawY = y + yOffset - (height - MahjongUI.DIMENSIONS.TILE_HEIGHT * scale) / 2

    -- Glow effect for newly drawn tiles
    if glowAlpha > 0 then
        love.graphics.setColor(0.3, 0.9, 0.3, glowAlpha) -- Green glow for new tiles
        love.graphics.setLineWidth(6)
        love.graphics.rectangle("line", drawX - 4, drawY - 4, width + 8, height + 8, 8)
        love.graphics.setLineWidth(1)
    end

    -- Selection outline for selected tiles
    if selected then
        love.graphics.setColor(MahjongUI.COLORS.TILE_SELECTED)
        love.graphics.setLineWidth(4) -- Create a thick, glowing line
        love.graphics.rectangle("line", drawX - 2, drawY - 2, width + 4, height + 4, 8) -- Draw slightly outside the tile
        love.graphics.setLineWidth(1) -- Reset line width
    end

    local tileImage = MahjongUI.getTileImage(tile)

    if tileImage then
        -- Draw white background for tile
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", drawX, drawY, width, height, 5)

        -- Draw the tile image scaled to fit
        love.graphics.setColor(1, 1, 1, 1)
        local iw, ih = tileImage:getWidth(), tileImage:getHeight()
        local sx, sy = width / iw, height / ih
        love.graphics.draw(tileImage, drawX, drawY, 0, sx, sy)
    else
        -- Fallback: draw a styled rectangle with a character label
        -- Draw tile background
        love.graphics.setColor(MahjongUI.COLORS.TILE_BACKGROUND)
        love.graphics.rectangle("fill", drawX, drawY, width, height, 5)

        love.graphics.setColor(MahjongUI.COLORS.TILE_BORDER)
        love.graphics.rectangle("line", drawX, drawY, width, height, 5)

        love.graphics.setColor(MahjongUI.COLORS.TEXT_MAIN)
        local prevFont = love.graphics.getFont()
        love.graphics.setFont(MahjongUI.fonts.normal)

        local displayChar = MahjongTiles and MahjongTiles.getDisplayChar and MahjongTiles.getDisplayChar(tile) or "?"

        -- Safe width calculation
        local textWidth = 20
        local ok, w = pcall(love.graphics.getFont().getWidth, love.graphics.getFont(), displayChar)
        if ok then textWidth = w end
        local textHeight = love.graphics.getFont():getHeight()

        local centerX = drawX + width  / 2 - textWidth  / 2
        local centerY = drawY + height / 2 - textHeight / 2
        love.graphics.print(displayChar, centerX, centerY)

        -- Small value indicator for numbered tiles
        if tile and tile.value and tonumber(tile.value) then
            love.graphics.setColor(MahjongUI.COLORS.TEXT_SECONDARY)
            love.graphics.setFont(MahjongUI.fonts.small)
            love.graphics.print(tostring(tile.value), drawX + 2, drawY + 2)
        end

        -- restore font
        love.graphics.setFont(prevFont)
    end
end

-- Draw a collection of tiles (hand, played area, etc.)
function MahjongUI.drawTileCollection(tiles, startX, startY, maxPerRow, selectedIndices, scale, draggedTileIndex, animationData)
    maxPerRow = maxPerRow or 10
    selectedIndices = selectedIndices or {}
    scale = scale or 1
    animationData = animationData or {}

    local tileWidth  = MahjongUI.DIMENSIONS.TILE_WIDTH * scale
    local tileHeight = MahjongUI.DIMENSIONS.TILE_HEIGHT * scale
    local margin     = MahjongUI.DIMENSIONS.TILE_MARGIN

    local x, y = startX, startY
    local tilesInRow = 0

    local prevFont = love.graphics.getFont()

    for i, tile in ipairs(tiles) do
        if i == draggedTileIndex then
            -- Draw a placeholder for the dragged tile
            love.graphics.setColor(0, 0, 0, 0.2)
            love.graphics.rectangle("fill", x, y, tileWidth, tileHeight, 5)
        else
            local isSelected = selectedIndices[i] or false
            local tileAnimData = animationData[i] or nil
            MahjongUI.drawTile(tile, x, y, isSelected, scale, tileAnimData)
        end

        -- Debug index overlay while holding LShift
        if love.keyboard.isDown("lshift") then
            love.graphics.setColor(MahjongUI.COLORS.TEXT_SECONDARY)
            love.graphics.setFont(MahjongUI.fonts.tiny)
            love.graphics.print(tostring(i), x + tileWidth - 15, y + tileHeight - 15)
        end

        x = x + tileWidth + margin
        tilesInRow = tilesInRow + 1

        if tilesInRow >= maxPerRow then
            x = startX
            y = y + tileHeight + margin
            tilesInRow = 0
        end
    end

    love.graphics.setFont(prevFont)

    return y + tileHeight + margin -- next available Y
end

-- Draw a labeled section (like "Hand:", "Played Area:")
function MahjongUI.drawSection(label, tiles, x, y, maxPerRow, selectedIndices, scale, draggedTileIndex, animationData)
    scale = scale or 1
    animationData = animationData or {}

    love.graphics.setColor(MahjongUI.COLORS.TEXT_MAIN)
    local prevFont = love.graphics.getFont()
    love.graphics.setFont(MahjongUI.fonts.normal)
    love.graphics.print(label, x, y)

    local tileY = y + MahjongUI.fonts.normal:getHeight() + 10
    local nextY = MahjongUI.drawTileCollection(tiles, x, tileY, maxPerRow, selectedIndices, scale, draggedTileIndex, animationData)

    love.graphics.setFont(prevFont)
    return nextY
end

-- =============================
-- Drawing: UI Panels
-- =============================

function MahjongUI.drawPanel(x, y, width, height, title, cornerRadius)
    cornerRadius = cornerRadius or 10

    -- Panel background with rounded corners
    love.graphics.setColor(MahjongUI.COLORS.PANEL_BG)
    love.graphics.rectangle("fill", x, y, width, height, cornerRadius)

    -- Panel border
    love.graphics.setColor(MahjongUI.COLORS.PANEL_BORDER)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height, cornerRadius)

    -- Title bar if provided
    if title then
        -- Title background
        love.graphics.setColor(MahjongUI.COLORS.PANEL_BORDER[1], MahjongUI.COLORS.PANEL_BORDER[2], MahjongUI.COLORS.PANEL_BORDER[3], 0.8)
        love.graphics.rectangle("fill", x, y, width, 30, cornerRadius, cornerRadius, 0, 0)

        -- Title text
        love.graphics.setColor(MahjongUI.COLORS.TEXT_MAIN)
        love.graphics.setFont(MahjongUI.fonts.normal)
        love.graphics.printf(title, x + 10, y + 7, width - 20, "center")
    end

    love.graphics.setLineWidth(1)
end

function MahjongUI.drawScoreDisplay(x, y, width, height, label, value, isPositive)
    local bgColor = isPositive and MahjongUI.COLORS.SCORE_POSITIVE or MahjongUI.COLORS.SCORE_NEGATIVE
    local textColor = MahjongUI.COLORS.TEXT_MAIN

    -- Background
    love.graphics.setColor(bgColor)
    love.graphics.rectangle("fill", x, y, width, height, 5)

    -- Border
    love.graphics.setColor(MahjongUI.COLORS.PANEL_BORDER)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height, 5)

    -- Label
    love.graphics.setColor(textColor)
    love.graphics.setFont(MahjongUI.fonts.small)
    love.graphics.printf(label, x + 5, y + 5, width - 10, "center")

    -- Value
    love.graphics.setFont(MahjongUI.fonts.large)
    local valueHeight = MahjongUI.fonts.large:getHeight()
    love.graphics.printf(tostring(value), x + 5, y + (height - valueHeight) / 2, width - 10, "center")

    love.graphics.setLineWidth(1)
end

function MahjongUI.drawProgressBar(x, y, width, height, progress, label, color)
    progress = math.max(0, math.min(1, progress or 0))
    color = color or {0.3, 0.6, 0.9}

    -- Draw background
    love.graphics.setColor(0.1, 0.1, 0.1, 0.8)
    love.graphics.rectangle("fill", x, y, width, height, 4)

    -- Draw progress fill
    love.graphics.setColor(color[1], color[2], color[3], 1.0)
    love.graphics.rectangle("fill", x, y, width * progress, height, 4)

    -- Draw border
    love.graphics.setColor(MahjongUI.COLORS.PANEL_BORDER)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, width, height, 4)
    love.graphics.setLineWidth(1)

    -- Draw label text centered on the bar
    love.graphics.setColor(MahjongUI.COLORS.TEXT_MAIN)
    love.graphics.setFont(MahjongUI.fonts.small)
    love.graphics.printf(label, x, y + (height - MahjongUI.fonts.small:getHeight()) / 2, width, "center")
end

-- Hand evaluation panel
function MahjongUI.drawHandEvaluation(x, y, width, height, hand, gameState)
    if not hand or #hand == 0 then return end

    -- Main panel
    MahjongUI.drawPanel(x, y, width, height, "手牌分析")

    local contentY = y + 35
    local contentHeight = height - 35
    local sectionWidth = width / 4 - 10

    -- Section 1: Suit distribution
    love.graphics.setColor(MahjongUI.COLORS.TEXT_MAIN)
    love.graphics.setFont(MahjongUI.fonts.small)
    love.graphics.print("花色分布", x + 10, contentY)

    local suits = {characters = 0, circles = 0, bamboos = 0, winds = 0, dragons = 0}
    for _, tile in ipairs(hand) do
        if tile and tile.category then
            suits[tile.category] = (suits[tile.category] or 0) + 1
        end
    end

    local suitY = contentY + 15
    love.graphics.setFont(MahjongUI.fonts.tiny)
    for suit, count in pairs(suits) do
        if count > 0 then
            local suitName = suit == "characters" and "萬" or
                           suit == "circles" and "筒" or
                           suit == "bamboos" and "條" or
                           suit == "winds" and "風" or
                           suit == "dragons" and "龍" or suit
            love.graphics.print(suitName .. ": " .. count, x + 15, suitY)
            suitY = suitY + 12
        end
    end

    -- Section 2: Possible combinations
    love.graphics.setColor(MahjongUI.COLORS.TEXT_MAIN)
    love.graphics.setFont(MahjongUI.fonts.small)
    love.graphics.print("可能組合", x + sectionWidth + 10, contentY)

    local combos = MahjongUI.findPossibleCombinations(hand)
    local comboY = contentY + 15
    love.graphics.setFont(MahjongUI.fonts.tiny)
    for _, combo in ipairs(combos) do
        love.graphics.print(combo, x + sectionWidth + 15, comboY)
        comboY = comboY + 12
        if comboY > contentY + contentHeight - 15 then break end
    end

    -- Section 3: Potential score
    love.graphics.setColor(MahjongUI.COLORS.TEXT_MAIN)
    love.graphics.setFont(MahjongUI.fonts.small)
    love.graphics.print("潛在分數", x + sectionWidth * 2 + 10, contentY)

    local potentialFan = MahjongUI.calculatePotentialFan(hand, gameState)
    love.graphics.setFont(MahjongUI.fonts.normal)
    love.graphics.setColor(potentialFan >= 3 and MahjongUI.COLORS.SCORE_POSITIVE or MahjongUI.COLORS.SCORE_NEGATIVE)
    love.graphics.print(potentialFan .. " 番", x + sectionWidth * 2 + 15, contentY + 15)

    -- Section 4: Recommendations
    love.graphics.setColor(MahjongUI.COLORS.TEXT_MAIN)
    love.graphics.setFont(MahjongUI.fonts.small)
    love.graphics.print("建議", x + sectionWidth * 3 + 10, contentY)

    local recommendation = MahjongUI.getHandRecommendation(hand)
    love.graphics.setFont(MahjongUI.fonts.tiny)
    love.graphics.printf(recommendation, x + sectionWidth * 3 + 15, contentY + 15, sectionWidth - 5, "left")
end

-- Helper functions for hand evaluation
function MahjongUI.findPossibleCombinations(hand)
    local combos = {}
    if #hand >= 2 then
        table.insert(combos, "對子: " .. math.floor(#hand / 2))
    end
    if #hand >= 3 then
        table.insert(combos, "順子: " .. math.floor(#hand / 3))
        table.insert(combos, "刻子: " .. math.floor(#hand / 3))
    end
    return combos
end

function MahjongUI.calculatePotentialFan(hand, gameState)
    local fan = 1  -- Base fan
    local suits = {}
    for _, tile in ipairs(hand) do
        if tile and tile.category then
            suits[tile.category] = true
        end
    end
    local suitCount = 0
    for _ in pairs(suits) do suitCount = suitCount + 1 end

    if suitCount == 1 then fan = fan + 2 end  -- Single suit bonus
    if gameState and gameState.weatherBonus then fan = fan + 1 end

    return fan
end

function MahjongUI.getHandRecommendation(hand)
    if #hand < 3 then
        return "抽更多牌"
    elseif #hand > 14 then
        return "丟棄多餘牌"
    else
        return "組合牌組"
    end
end

-- =============================
-- Drawing: Buttons
-- =============================

function MahjongUI.drawButton(text, x, y, width, height, pressed, hovered)
    pressed  = pressed  or false
    hovered  = hovered  or false

    local color = MahjongUI.COLORS.BUTTON
    if pressed then
        color = MahjongUI.COLORS.BUTTON_PRESSED
    elseif hovered then
        color = MahjongUI.COLORS.BUTTON_HOVER
    end

    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x, y, width, height, 5)

    love.graphics.setColor(MahjongUI.COLORS.TILE_BORDER)
    love.graphics.rectangle("line", x, y, width, height, 5)

    love.graphics.setColor(MahjongUI.COLORS.TEXT_MAIN)
    local prevFont = love.graphics.getFont()
    love.graphics.setFont(MahjongUI.fonts.normal)

    local textWidth  = love.graphics.getFont():getWidth(text)
    local textHeight = love.graphics.getFont():getHeight()
    local centerX = x + width  / 2 - textWidth  / 2
    local centerY = y + height / 2 - textHeight / 2
    love.graphics.print(text, centerX, centerY)

    love.graphics.setFont(prevFont)
end

function MahjongUI.isPointInButton(px, py, buttonX, buttonY, buttonWidth, buttonHeight)
    return px >= buttonX and px <= buttonX + buttonWidth and
           py >= buttonY and py <= buttonY + buttonHeight
end

-- =============================
-- Drawing: Game chrome
-- =============================

function MahjongUI.drawGameHeader(gameState, x, y, width)
    local height = 50 -- Use the new standard height from our layout math

    -- Draw a proper panel background that matches the sidebar style
    MahjongUI.drawPanel(x, y, width, height, nil) -- No title for the main header

    love.graphics.setColor(MahjongUI.COLORS.TEXT_MAIN)
    local padding = 20
    local prevFont = love.graphics.getFont()
    love.graphics.setFont(MahjongUI.fonts.normal)

    -- Calculate vertical center for all text
    local textY = y + (height - MahjongUI.fonts.normal:getHeight()) / 2

    -- Left-aligned info (Score)
    local scoreText = "分數: " .. tostring(gameState.score or 0)
    love.graphics.print(scoreText, x + padding, textY)

    -- Center-aligned info (Rounds)
    if gameState.isChallenge and gameState.currentRound and gameState.maxRounds then
        local roundText = "回合: " .. tostring(gameState.currentRound) .. "/" .. tostring(gameState.maxRounds)
        local roundTextWidth = MahjongUI.fonts.normal:getWidth(roundText)
        love.graphics.print(roundText, x + (width - roundTextWidth) / 2, textY)
    end

    -- Right-aligned info (Deck Count)
    if gameState.deck and type(gameState.deck) == "table" then
        local deckText = "牌疊: " .. tostring(#gameState.deck) .. " 隻"
        local deckTextWidth = MahjongUI.fonts.normal:getWidth(deckText)
        love.graphics.print(deckText, x + width - deckTextWidth - padding, textY)
    end

    love.graphics.setFont(prevFont)
    return y + height
end

function MahjongUI.drawPlayedArea(playedTiles, x, y, width, height, winningHand)
    winningHand = winningHand or false

    local bg = winningHand and MahjongUI.COLORS.WIN_HIGHLIGHT or MahjongUI.COLORS.PLAYED_AREA
    love.graphics.setColor(bg)
    love.graphics.rectangle("fill", x, y, width, height, 5)

    love.graphics.setColor(MahjongUI.COLORS.TILE_BORDER)
    love.graphics.rectangle("line", x, y, width, height, 5)

    love.graphics.setColor(MahjongUI.COLORS.TEXT_MAIN)
    local labelText = winningHand and "【食糊！】" or ("打出區域 (" .. tostring(#playedTiles) .. "/14)")
    local prevFont = love.graphics.getFont()
    love.graphics.setFont(MahjongUI.fonts.normal)
    love.graphics.print(labelText, x + 10, y + 5)

    if #playedTiles > 0 then
        local tileStartX = x + 10
        local tileStartY = y + 30
        local maxTilesPerRow = math.floor((width - 20) / (MahjongUI.DIMENSIONS.TILE_WIDTH + MahjongUI.DIMENSIONS.TILE_MARGIN))
        MahjongUI.drawTileCollection(playedTiles, tileStartX, tileStartY, maxTilesPerRow, {}, 0.8)
    end

    love.graphics.setFont(prevFont)
    return y + height
end

function MahjongUI.drawDiscardPile(discardPile, x, y, width, height)
    -- Draw background
    love.graphics.setColor(0.3, 0.2, 0.2, 1.0)  -- Dark brown for discard pile
    love.graphics.rectangle("fill", x, y, width, height, 5)

    love.graphics.setColor(MahjongUI.COLORS.TILE_BORDER)
    love.graphics.rectangle("line", x, y, width, height, 5)

    -- Draw label
    love.graphics.setColor(MahjongUI.COLORS.TEXT_MAIN)
    local labelText = "棄牌堆 (" .. tostring(#discardPile) .. ")"
    local prevFont = love.graphics.getFont()
    love.graphics.setFont(MahjongUI.fonts.normal)
    love.graphics.print(labelText, x + 10, y + 5)

    -- Show last few discarded tiles
    if #discardPile > 0 then
        local tileStartX = x + 10
        local tileStartY = y + 30
        local maxTilesPerRow = math.floor((width - 20) / (MahjongUI.DIMENSIONS.TILE_WIDTH + MahjongUI.DIMENSIONS.TILE_MARGIN))

        -- Show last 9 discarded tiles (most recent first) - increased from 6
        local showCount = math.min(9, #discardPile)
        local recentTiles = {}
        for i = #discardPile - showCount + 1, #discardPile do
            table.insert(recentTiles, discardPile[i])
        end

        MahjongUI.drawTileCollection(recentTiles, tileStartX, tileStartY, maxTilesPerRow, {}, 0.7)  -- Increased scale from 0.6 to 0.7

        -- Show total count if there are more tiles
        if #discardPile > 9 then
            love.graphics.setColor(MahjongUI.COLORS.TEXT_SECONDARY)
            love.graphics.setFont(MahjongUI.fonts.small)
            love.graphics.print("(最近 " .. showCount .. " 張，共 " .. #discardPile .. " 張)", x + 10, y + height - 20)
        end
    else
        love.graphics.setColor(MahjongUI.COLORS.TEXT_SECONDARY)
        love.graphics.setFont(MahjongUI.fonts.small)
        love.graphics.print("空", x + 10, y + 30)
    end

    love.graphics.setFont(prevFont)
    return y + height
end

-- Win animation state
MahjongUI.winAnimationTime = MahjongUI.winAnimationTime or 0

function MahjongUI.drawWinNotification(winData, screenWidth, screenHeight, deltaTime)
    if not winData then return end

    -- Update animation timer
    MahjongUI.winAnimationTime = MahjongUI.winAnimationTime + (deltaTime or love.timer.getDelta())

    -- Celebration screen flash effect
    local flashIntensity = math.max(0, 0.3 * math.sin(MahjongUI.winAnimationTime * 8))
    love.graphics.setColor(1, 0.9, 0.3, flashIntensity)  -- Golden flash
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    -- Animated overlay
    local pulseAlpha = 0.7 + 0.1 * math.sin(MahjongUI.winAnimationTime * 3)
    love.graphics.setColor(0, 0, 0, pulseAlpha)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    -- Animated dialog with bounce effect
    local bounceScale = 1 + 0.1 * math.sin(MahjongUI.winAnimationTime * 4)
    local boxWidth, boxHeight = 400 * bounceScale, 200 * bounceScale
    local boxX = screenWidth / 2 - boxWidth / 2
    local boxY = screenHeight / 2 - boxHeight / 2

    -- Enhanced win colors with pulsing
    local winGlow = 0.5 + 0.3 * math.sin(MahjongUI.winAnimationTime * 5)
    love.graphics.setColor(0.2 + winGlow * 0.5, 0.8 + winGlow * 0.2, 0.3 + winGlow * 0.2, 0.9)
    love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight, 10)

    -- Glowing border effect
    love.graphics.setColor(1, 0.9, 0.3, 0.8 + 0.2 * math.sin(MahjongUI.winAnimationTime * 6))
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", boxX, boxY, boxWidth, boxHeight, 10)
    love.graphics.setLineWidth(1)

    -- Draw celebration particles
    MahjongUI.drawWinParticles(screenWidth, screenHeight)

    -- Animated text
    local prevFont = love.graphics.getFont()

    -- Bouncing title with color animation
    local titleBounce = 1 + 0.15 * math.sin(MahjongUI.winAnimationTime * 6)
    local titleHue = (MahjongUI.winAnimationTime * 2) % 1
    local r, g, b = MahjongUI.hsvToRgb(titleHue, 0.7, 1)
    love.graphics.setColor(r, g, b, 1)
    love.graphics.setFont(MahjongUI.fonts.title)

    love.graphics.push()
    love.graphics.translate(screenWidth/2, boxY + 50)
    love.graphics.scale(titleBounce, titleBounce)
    love.graphics.printf("【🎉 食糊！🎉】", -boxWidth/2, -10, boxWidth, "center")
    love.graphics.pop()

    -- Pattern text with slight glow
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(MahjongUI.fonts.mid)
    love.graphics.printf(winData.pattern or "Unknown Pattern", boxX, boxY + 90, boxWidth, "center")

    -- Animated score counter
    local animatedScore = math.floor((winData.score or 0) * math.min(1, MahjongUI.winAnimationTime / 2))
    local scoreText = string.format("%d 番 - %d 分", winData.totalFan or winData.fan or 0, animatedScore)
    love.graphics.setFont(MahjongUI.fonts.normal)
    love.graphics.printf(scoreText, boxX, boxY + 100, boxWidth, "center")

    love.graphics.setColor(MahjongUI.COLORS.TEXT_SECONDARY)
    love.graphics.setFont(MahjongUI.fonts.small)
    love.graphics.printf("按空白鍵繼續", boxX, boxY + 140, boxWidth, "center")

    love.graphics.setFont(prevFont)
end

-- =============================
-- Hit testing
-- =============================

function MahjongUI.getTileAtPosition(mouseX, mouseY, tiles, startX, startY, maxPerRow, scale, selectedIndices)
    scale = scale or 1
    maxPerRow = maxPerRow or 10
    selectedIndices = selectedIndices or {}

    local tileWidth  = MahjongUI.DIMENSIONS.TILE_WIDTH * scale
    local tileHeight = MahjongUI.DIMENSIONS.TILE_HEIGHT * scale
    local margin     = MahjongUI.DIMENSIONS.TILE_MARGIN

    local x, y = startX, startY
    local tilesInRow = 0

    for i, tile in ipairs(tiles) do
        local isSelected = selectedIndices and selectedIndices[i]
        local yOffset = isSelected and -6 or 0
        local drawX = x
        local drawY = y + yOffset

        if mouseX >= drawX and mouseX <= drawX + tileWidth and
           mouseY >= drawY and mouseY <= drawY + tileHeight then
            return i, tile, drawX, drawY
        end

        x = x + tileWidth + margin
        tilesInRow = tilesInRow + 1

        if tilesInRow >= maxPerRow then
            x = startX
            y = y + tileHeight + margin
            tilesInRow = 0
        end
    end

    return nil, nil, nil, nil
end

function MahjongUI.getDropIndexAtPosition(mouseX, mouseY, tiles, startX, startY, maxPerRow, scale)
    scale = scale or 1
    maxPerRow = maxPerRow or 10

    local tileWidth  = MahjongUI.DIMENSIONS.TILE_WIDTH * scale
    local margin     = MahjongUI.DIMENSIONS.TILE_MARGIN
    local slotWidth = tileWidth + margin

    -- Check if mouse is in the hand area vertically
    if mouseY < startY or mouseY > startY + MahjongUI.DIMENSIONS.TILE_HEIGHT * scale then
        return nil
    end

    local relativeX = mouseX - startX + (slotWidth / 2)
    if relativeX < 0 then return 1 end

    local index = math.floor(relativeX / slotWidth) + 1
    return math.min(index, #tiles + 1)
end

-- =============================
-- Debug overlay
-- =============================

function MahjongUI.drawDebugInfo(gameState, x, y)
    if not love.keyboard.isDown("lshift") then return y end

    love.graphics.setColor(MahjongUI.COLORS.TEXT_SECONDARY)
    local prevFont = love.graphics.getFont()
    love.graphics.setFont(MahjongUI.fonts.small)

    local lineHeight = love.graphics.getFont():getHeight() + 2
    local currentY = y

    love.graphics.print("=== 調試資料 ===", x, currentY)
    currentY = currentY + lineHeight

    if gameState.hand then
        love.graphics.print("手牌數量: " .. tostring(#gameState.hand), x, currentY)
        currentY = currentY + lineHeight
    end

    if gameState.playedTiles then
        love.graphics.print("已打牌數: " .. tostring(#gameState.playedTiles), x, currentY)
        currentY = currentY + lineHeight
    end

    if gameState.selectedTiles then
        love.graphics.print("已選牌數: " .. tostring(#gameState.selectedTiles), x, currentY)
        currentY = currentY + lineHeight
    end

    if gameState.deck then
        love.graphics.print("牌疊剩餘: " .. tostring(#gameState.deck), x, currentY)
        currentY = currentY + lineHeight
    end

    love.graphics.setFont(prevFont)
    return currentY + 10
end

-- =============================
-- Utilities
-- =============================

function MahjongUI.setDefaultFont(size)
    size = size or 16
    local font = love.graphics.newFont(size)
    love.graphics.setFont(font)
    -- Optionally keep this as the normal font for the UI
    MahjongUI.fonts.normal = font
    return font
end

function MahjongUI.resetGraphics()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(1)
end

-- HSV to RGB color conversion for animated effects
function MahjongUI.hsvToRgb(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)

    local imod = i % 6
    if imod == 0 then
        r, g, b = v, t, p
    elseif imod == 1 then
        r, g, b = q, v, p
    elseif imod == 2 then
        r, g, b = p, v, t
    elseif imod == 3 then
        r, g, b = p, q, v
    elseif imod == 4 then
        r, g, b = t, p, v
    elseif imod == 5 then
        r, g, b = v, p, q
    end

    return r, g, b
end

-- Win celebration particles
MahjongUI.winParticles = MahjongUI.winParticles or {}

function MahjongUI.drawWinParticles(screenWidth, screenHeight)
    local time = MahjongUI.winAnimationTime

    -- Generate new particles periodically
    if #MahjongUI.winParticles < 50 and math.random() < 0.8 then
        table.insert(MahjongUI.winParticles, {
            x = math.random(0, screenWidth),
            y = screenHeight + 10,
            vx = math.random(-100, 100),
            vy = math.random(-300, -150),
            life = math.random(2, 4),
            maxLife = math.random(2, 4),
            size = math.random(3, 8),
            hue = math.random()
        })
    end

    -- Update and draw particles
    local dt = love.timer.getDelta()
    for i = #MahjongUI.winParticles, 1, -1 do
        local p = MahjongUI.winParticles[i]

        -- Update particle
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.life = p.life - dt

        if p.life <= 0 then
            table.remove(MahjongUI.winParticles, i)
        else
            -- Draw particle
            local alpha = p.life / p.maxLife
            local r, g, b = MahjongUI.hsvToRgb(p.hue, 0.8, 1)
            love.graphics.setColor(r, g, b, alpha)
            love.graphics.circle("fill", p.x, p.y, p.size * alpha)
        end
    end
end

-- Reset win animation when dialog is shown
function MahjongUI.resetWinAnimation()
    MahjongUI.winAnimationTime = 0
    MahjongUI.winParticles = {}
end

-- Draw clickable deck preview
function MahjongUI.drawDeckPreview(deck, x, y, width, height, showExpanded, deckPeekEnabled)
    -- Draw background
    love.graphics.setColor(0.2, 0.3, 0.4, 1.0)  -- Blue-gray for deck
    love.graphics.rectangle("fill", x, y, width, height, 5)

    love.graphics.setColor(MahjongUI.COLORS.TILE_BORDER)
    love.graphics.rectangle("line", x, y, width, height, 5)

    -- Draw label
    love.graphics.setColor(MahjongUI.COLORS.TEXT_MAIN)
    local labelText = "牌疊 (" .. tostring(#deck) .. ")"
    if deckPeekEnabled then
        labelText = labelText .. " 👁️"
    else
        labelText = labelText .. " 點擊查看"
    end
    local prevFont = love.graphics.getFont()
    love.graphics.setFont(MahjongUI.fonts.small)
    love.graphics.print(labelText, x + 5, y + 5)

    -- If deck peek is enabled, always show upcoming tiles
    local shouldShowTiles = showExpanded or deckPeekEnabled
    
    if shouldShowTiles and #deck > 0 then
        -- Show first 12 tiles from deck as preview
        local previewCount = math.min(12, #deck)
        local previewTiles = {}
        for i = 1, previewCount do
            table.insert(previewTiles, deck[i])
        end

        local tileStartX = x + 5
        local tileStartY = y + 25
        local maxTilesPerRow = math.floor((width - 10) / (MahjongUI.DIMENSIONS.TILE_WIDTH * 0.5 + MahjongUI.DIMENSIONS.TILE_MARGIN))
        MahjongUI.drawTileCollection(previewTiles, tileStartX, tileStartY, maxTilesPerRow, {}, 0.5)

        if #deck > 12 then
            love.graphics.setColor(MahjongUI.COLORS.TEXT_SECONDARY)
            love.graphics.print("(顯示前 " .. previewCount .. " 張)", x + 5, y + height - 15)
        end
        
        if deckPeekEnabled then
            love.graphics.setColor(0.0, 1.0, 0.0, 0.8) -- Green glow for contact lens effect
            love.graphics.print("👁️ 隱形液晶體眼鏡", x + 5, y + height - 30)
        end
    else
        -- Show just a stack of tiles icon
        love.graphics.setColor(0.8, 0.8, 0.8, 0.8)
        for i = 0, 2 do
            love.graphics.rectangle("fill", x + 20 + i*2, y + 25 + i*2, 30, 40, 3)
            love.graphics.setColor(MahjongUI.COLORS.TILE_BORDER)
            love.graphics.rectangle("line", x + 20 + i*2, y + 25 + i*2, 30, 40, 3)
            love.graphics.setColor(0.8, 0.8, 0.8, 0.8)
        end
    end

    love.graphics.setFont(prevFont)
    return y + height
end

-- Deck popup state
MahjongUI.deckPopupState = MahjongUI.deckPopupState or {
    isVisible = false,
    animationTimer = 0,
    maxAnimationTime = 0.3
}

-- Discard pile popup state
MahjongUI.discardPopupState = MahjongUI.discardPopupState or {
    isVisible = false,
    animationTimer = 0,
    maxAnimationTime = 0.3
}

-- Show the deck popup
function MahjongUI.showDeckPopup()
    MahjongUI.deckPopupState.isVisible = true
    MahjongUI.deckPopupState.animationTimer = 0
end

-- Hide the deck popup
function MahjongUI.hideDeckPopup()
    MahjongUI.deckPopupState.isVisible = false
end

-- Show the discard popup
function MahjongUI.showDiscardPopup()
    MahjongUI.discardPopupState.isVisible = true
    MahjongUI.discardPopupState.animationTimer = 0
end

-- Hide the discard popup
function MahjongUI.hideDiscardPopup()
    MahjongUI.discardPopupState.isVisible = false
end

-- Update deck popup animation
function MahjongUI.updateDeckPopup(deltaTime)
    if MahjongUI.deckPopupState.isVisible then
        MahjongUI.deckPopupState.animationTimer = math.min(
            MahjongUI.deckPopupState.animationTimer + deltaTime,
            MahjongUI.deckPopupState.maxAnimationTime
        )
    end
    if MahjongUI.discardPopupState.isVisible then
        MahjongUI.discardPopupState.animationTimer = math.min(
            MahjongUI.discardPopupState.animationTimer + deltaTime,
            MahjongUI.discardPopupState.maxAnimationTime
        )
    end
end

-- Calculate tile statistics for the deck
function MahjongUI.calculateDeckStats(deck)
    local stats = {
        total = #deck,
        bySuit = {
            characters = 0,
            circles = 0,
            bamboos = 0,
            winds = 0,
            dragons = 0
        },
        byValue = {},
        remaining = {}
    }

    -- Count tiles by suit and track individual tiles
    for _, tile in ipairs(deck) do
        local category = tile.type or "unknown"
        if stats.bySuit[category] then
            stats.bySuit[category] = stats.bySuit[category] + 1
        end

        -- Count by specific tile
        local tileKey = tile.suit .. "_" .. tostring(tile.value)
        stats.remaining[tileKey] = (stats.remaining[tileKey] or 0) + 1
    end

    return stats
end

-- Draw deck summary popup
function MahjongUI.drawDeckSummaryPopup(deck, screenWidth, screenHeight, deckPeekEnabled)
    if not MahjongUI.deckPopupState.isVisible then return end

    -- Animation progress (0 to 1)
    local progress = MahjongUI.deckPopupState.animationTimer / MahjongUI.deckPopupState.maxAnimationTime
    local easeProgress = 1 - (1 - progress) * (1 - progress) -- Ease out

    -- Semi-transparent overlay
    love.graphics.setColor(0, 0, 0, 0.7 * easeProgress)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    -- Popup dimensions
    local popupWidth = math.min(600, screenWidth * 0.8)
    local popupHeight = math.min(500, screenHeight * 0.8)
    local popupX = (screenWidth - popupWidth) / 2
    local popupY = (screenHeight - popupHeight) / 2

    -- Animate popup scale
    local scale = 0.8 + 0.2 * easeProgress
    local actualWidth = popupWidth * scale
    local actualHeight = popupHeight * scale
    local actualX = popupX + (popupWidth - actualWidth) / 2
    local actualY = popupY + (popupHeight - actualHeight) / 2

    -- Draw popup background with gradient
    love.graphics.setColor(0.15, 0.2, 0.25, 0.95 * easeProgress)
    love.graphics.rectangle("fill", actualX, actualY, actualWidth, actualHeight, 15)

    -- Glowing border effect
    love.graphics.setColor(0.3, 0.5, 0.7, 0.8 * easeProgress)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", actualX, actualY, actualWidth, actualHeight, 15)
    love.graphics.setLineWidth(1)

    -- Only draw content if animation is mostly complete
    if progress > 0.5 then
        local contentAlpha = (progress - 0.5) * 2 -- Fade in content

        -- Title
        love.graphics.setColor(1, 1, 1, contentAlpha)
        local prevFont = love.graphics.getFont()
        love.graphics.setFont(MahjongUI.fonts.title)
        local titleText = "牌疊詳情"
        if deckPeekEnabled then
            titleText = titleText .. " 👁️"
        end
        local titleWidth = love.graphics.getFont():getWidth(titleText)
        love.graphics.print(titleText, actualX + (actualWidth - titleWidth) / 2, actualY + 20)

        -- Calculate statistics
        local stats = MahjongUI.calculateDeckStats(deck)

        -- Draw stats sections
        love.graphics.setFont(MahjongUI.fonts.normal)
        local contentY = actualY + 80
        local leftColumnX = actualX + 30
        local rightColumnX = actualX + actualWidth / 2 + 20
        local lineHeight = love.graphics.getFont():getHeight() + 8

        -- Left column: Suit totals
        love.graphics.setColor(0.8, 0.9, 1, contentAlpha)
        love.graphics.print("按花色統計:", leftColumnX, contentY)
        contentY = contentY + lineHeight + 5

        local suitNames = {
            characters = "萬子",
            circles = "筒子",
            bamboos = "條子",
            winds = "風牌",
            dragons = "箭牌"
        }

        for suit, count in pairs(stats.bySuit) do
            if count > 0 then
                love.graphics.setColor(1, 1, 1, contentAlpha)
                love.graphics.print(suitNames[suit] .. ": " .. count .. " 張", leftColumnX + 10, contentY)
                contentY = contentY + lineHeight
            end
        end

        -- Right column: Individual tile counts (top 10 most common)
        contentY = actualY + 80
        love.graphics.setColor(0.8, 0.9, 1, contentAlpha)
        love.graphics.print("個別牌張統計:", rightColumnX, contentY)
        contentY = contentY + lineHeight + 5

        -- Sort tiles by count and show top 10
        local sortedTiles = {}
        for tileKey, count in pairs(stats.remaining) do
            table.insert(sortedTiles, {key = tileKey, count = count})
        end
        table.sort(sortedTiles, function(a, b) return a.count > b.count end)

        local maxDisplay = math.min(10, #sortedTiles)
        for i = 1, maxDisplay do
            local entry = sortedTiles[i]
            love.graphics.setColor(1, 1, 1, contentAlpha)
            love.graphics.print(entry.key .. ": " .. entry.count .. " 張", rightColumnX + 10, contentY)
            contentY = contentY + lineHeight
        end

        if #sortedTiles > 10 then
            love.graphics.setColor(0.7, 0.7, 0.7, contentAlpha)
            love.graphics.print("... 還有 " .. (#sortedTiles - 10) .. " 種牌", rightColumnX + 10, contentY)
        end

        -- If deck peek is enabled, show actual tiles
        if deckPeekEnabled and #deck > 0 then
            local tilesY = actualY + 300
            love.graphics.setColor(0.0, 1.0, 0.0, contentAlpha) -- Green for contact lens effect
            love.graphics.setFont(MahjongUI.fonts.normal)
            love.graphics.print("👁️ 隱形液晶體眼鏡 - 顯示前 " .. math.min(20, #deck) .. " 張牌:", actualX + 30, tilesY)
            
            -- Show first 20 tiles
            local previewCount = math.min(20, #deck)
            local previewTiles = {}
            for i = 1, previewCount do
                table.insert(previewTiles, deck[i])
            end
            
            local tileStartX = actualX + 30
            local tileStartY = tilesY + 30
            local maxTilesPerRow = math.floor((actualWidth - 60) / (MahjongUI.DIMENSIONS.TILE_WIDTH * 0.4 + 5))
            MahjongUI.drawTileCollection(previewTiles, tileStartX, tileStartY, maxTilesPerRow, {}, 0.4)
        end

        -- Bottom section: Total count
        love.graphics.setColor(1, 0.9, 0.3, contentAlpha)
        love.graphics.setFont(MahjongUI.fonts.mid)
        local totalText = "總共: " .. stats.total .. " 張牌"
        local totalWidth = love.graphics.getFont():getWidth(totalText)
        love.graphics.print(totalText, actualX + (actualWidth - totalWidth) / 2, actualY + actualHeight - 60)

        -- Close instruction
        love.graphics.setColor(0.7, 0.7, 0.7, contentAlpha)
        love.graphics.setFont(MahjongUI.fonts.small)
        local closeText = "點擊任何地方關閉"
        local closeWidth = love.graphics.getFont():getWidth(closeText)
        love.graphics.print(closeText, actualX + (actualWidth - closeWidth) / 2, actualY + actualHeight - 30)

        love.graphics.setFont(prevFont)
    end
end

-- Draw discard summary popup
function MahjongUI.drawDiscardSummaryPopup(discardPile, screenWidth, screenHeight)
    if not MahjongUI.discardPopupState.isVisible then return end

    -- (This function would be a near-duplicate of drawDeckSummaryPopup, but using discardPile and discardPopupState)
    -- For brevity, we will implement a generic popup drawer
    MahjongUI.drawGenericPopup("棄牌詳情", discardPile, MahjongUI.discardPopupState, screenWidth, screenHeight)
end

-- Generic popup drawing function to handle both Deck and Discard
function MahjongUI.drawGenericPopup(title, tiles, state, screenWidth, screenHeight)
    if not state.isVisible then return end

    local progress = (state.animationTimer or 0) / (state.maxAnimationTime or 0.3)
    local easeProgress = 1 - (1 - progress) * (1 - progress)

    love.graphics.setColor(0, 0, 0, 0.7 * easeProgress)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    local popupWidth = math.min(600, screenWidth * 0.8)
    local popupHeight = math.min(500, screenHeight * 0.8)
    local popupX = (screenWidth - popupWidth) / 2
    local popupY = (screenHeight - popupHeight) / 2

    love.graphics.setColor(0.15, 0.2, 0.25, 0.95 * easeProgress)
    love.graphics.rectangle("fill", popupX, popupY, popupWidth, popupHeight, 15)

    if progress > 0.5 then
        local contentAlpha = (progress - 0.5) * 2

        -- Title
        love.graphics.setColor(1, 1, 1, contentAlpha)
        love.graphics.setFont(MahjongUI.fonts.title)
        love.graphics.printf(title, popupX, popupY + 20, popupWidth, "center")

        -- Tile visuals
        if #tiles > 0 then
            local sortedTiles = MahjongTiles.sortTiles(tiles)
            local maxPerRow = math.floor((popupWidth - 40) / (MahjongUI.DIMENSIONS.TILE_WIDTH * 0.8 + MahjongUI.DIMENSIONS.TILE_MARGIN))
            MahjongUI.drawTileCollection(sortedTiles, popupX + 20, popupY + 80, maxPerRow, {}, 0.8)
        else
            love.graphics.setFont(MahjongUI.fonts.normal)
            love.graphics.printf("空", popupX, popupY + popupHeight/2, popupWidth, "center")
        end

        -- Close instruction
        love.graphics.setColor(0.7, 0.7, 0.7, contentAlpha)
        love.graphics.setFont(MahjongUI.fonts.small)
        local closeText = "點擊任何地方關閉"
        local closeWidth = love.graphics.getFont():getWidth(closeText)
        love.graphics.print(closeText, popupX + (popupWidth - closeWidth) / 2, popupY + popupHeight - 30)
    end
end

-- =============================
-- Error Feedback System
-- =============================

-- Error state variables
MahjongUI.errorState = MahjongUI.errorState or {
    isShowing = false,
    message = "",
    timer = 0,
    duration = 3.0,
    shakeIntensity = 0,
    shakeTimer = 0,
    shakeDecay = 0.85
}

-- Show error message with visual feedback
function MahjongUI.showError(message, shakeIntensity)
    MahjongUI.errorState.isShowing = true
    MahjongUI.errorState.message = message or "錯誤！"
    MahjongUI.errorState.timer = 0
    MahjongUI.errorState.shakeIntensity = shakeIntensity or 8
    MahjongUI.errorState.shakeTimer = 0.5  -- Shake for 0.5 seconds

    print("🚨 顯示錯誤: " .. MahjongUI.errorState.message)
end

-- Update error state (called from main update loop)
function MahjongUI.updateErrorState(deltaTime)
    if not MahjongUI.errorState.isShowing then return end

    -- Update error display timer
    MahjongUI.errorState.timer = MahjongUI.errorState.timer + deltaTime

    -- Update shake effect
    if MahjongUI.errorState.shakeTimer > 0 then
        MahjongUI.errorState.shakeTimer = MahjongUI.errorState.shakeTimer - deltaTime
        MahjongUI.errorState.shakeIntensity = MahjongUI.errorState.shakeIntensity * MahjongUI.errorState.shakeDecay
    else
        MahjongUI.errorState.shakeIntensity = 0
    end

    -- Hide error after duration
    if MahjongUI.errorState.timer >= MahjongUI.errorState.duration then
        MahjongUI.errorState.isShowing = false
        MahjongUI.errorState.shakeIntensity = 0
    end
end

-- Get current screen shake offset
function MahjongUI.getScreenShake()
    if MahjongUI.errorState.shakeIntensity <= 0 then
        return 0, 0
    end

    local shake = MahjongUI.errorState.shakeIntensity
    local offsetX = (love.math.random() - 0.5) * shake * 2
    local offsetY = (love.math.random() - 0.5) * shake * 2

    return offsetX, offsetY
end

-- Draw error notification
function MahjongUI.drawErrorNotification(screenWidth, screenHeight)
    if not MahjongUI.errorState.isShowing then return end

    local errorBg = {0.8, 0.2, 0.2, 0.9}  -- Red background
    local errorText = {1.0, 1.0, 1.0, 1.0}  -- White text

    -- Calculate fade-out in last 0.5 seconds
    local fadeStart = MahjongUI.errorState.duration - 0.5
    local alpha = 1.0
    if MahjongUI.errorState.timer > fadeStart then
        alpha = 1.0 - ((MahjongUI.errorState.timer - fadeStart) / 0.5)
    end

    -- Error background with pulsing effect
    local pulse = 1 + 0.1 * math.sin(MahjongUI.errorState.timer * 8)
    love.graphics.setColor(errorBg[1], errorBg[2], errorBg[3], errorBg[4] * alpha)

    local errorWidth = 400 * pulse
    local errorHeight = 80 * pulse
    local errorX = (screenWidth - errorWidth) / 2
    local errorY = 100

    love.graphics.rectangle("fill", errorX, errorY, errorWidth, errorHeight, 10)

    -- Error border
    love.graphics.setColor(0.6, 0.1, 0.1, alpha)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", errorX, errorY, errorWidth, errorHeight, 10)
    love.graphics.setLineWidth(1)

    -- Error text
    love.graphics.setColor(errorText[1], errorText[2], errorText[3], errorText[4] * alpha)
    love.graphics.setFont(MahjongUI.fonts.mid)

    local textWidth = love.graphics.getFont():getWidth(MahjongUI.errorState.message)
    local textHeight = love.graphics.getFont():getHeight()
    local textX = errorX + (errorWidth - textWidth) / 2
    local textY = errorY + (errorHeight - textHeight) / 2

    love.graphics.print(MahjongUI.errorState.message, textX, textY)

    -- Error icon (X mark)
    love.graphics.setColor(1.0, 0.8, 0.8, alpha)
    love.graphics.setLineWidth(4)
    local iconSize = 16
    local iconX = errorX + 20
    local iconY = errorY + (errorHeight - iconSize) / 2

    love.graphics.line(iconX, iconY, iconX + iconSize, iconY + iconSize)
    love.graphics.line(iconX, iconY + iconSize, iconX + iconSize, iconY)
    love.graphics.setLineWidth(1)
end

return MahjongUI