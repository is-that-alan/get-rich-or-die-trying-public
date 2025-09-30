-- Deck Modifier Screen

local DeckModifierScreen = {}

local MahjongUI = require("mahjong_ui")
local MahjongTiles = require("mahjong_tiles")
local DeckSpellEffects = require("deck_spell_effects")
local Music = require("music")

local current_spell = nil
local selected_tiles_indices = {}
local message = ""
local tile_transformations = {} -- Track before/after transformations
local animation_timer = 0
local animation_duration = 3.0
local cached_sorted_deck = nil -- Cache the sorted deck to prevent re-sorting every frame
local animation_phase = "none" -- "none", "transforming", "result"

function DeckModifierScreen.init(spell, mainGameState)
    current_spell = spell
    selected_tiles_indices = {}
    message = "Select up to " .. (spell.selection_count or 0) .. " tiles to apply the spell."
    -- We need the mainGameState to access the player's deck
    DeckModifierScreen.mainGameState = mainGameState
    tile_transformations = {}
    animation_timer = 0
    animation_phase = "none"

    -- Sort deck once at initialization and cache it
    if mainGameState and mainGameState.playerDeck then
        cached_sorted_deck = MahjongTiles.sortTiles(mainGameState.playerDeck)
        mainGameState.playerDeck = cached_sorted_deck
    end
end

function DeckModifierScreen.update(dt)
    -- Update tile transformation animation
    if animation_timer > 0 then
        animation_timer = animation_timer - dt

        -- Update animation phase based on progress
        local progress = 1 - (animation_timer / animation_duration)
        if progress < 0.5 then
            animation_phase = "transforming"
        else
            animation_phase = "result"
        end

        if animation_timer <= 0 then
            tile_transformations = {}
            animation_phase = "none"
        end
    end
end

function DeckModifierScreen.draw()
    if not DeckModifierScreen.mainGameState then return end

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    -- Draw background
    love.graphics.setColor(0.1, 0.1, 0.18)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    -- Draw title
    love.graphics.setColor(0.2, 0.6, 0.86)
    love.graphics.printf(current_spell.name, 0, 30, screenWidth, "center")

    -- Draw message
    love.graphics.setColor(0.31, 0.8, 0.77)
    love.graphics.printf(message, 0, 60, screenWidth, "center")

    -- Draw the player's deck (using cached sorted deck)
    if cached_sorted_deck and #cached_sorted_deck > 0 then
        local tilesPerRow = math.floor((screenWidth - 40) / (MahjongUI.DIMENSIONS.TILE_WIDTH * 0.8 + MahjongUI.DIMENSIONS.TILE_MARGIN))

        -- Draw tiles with transformation animation
        DeckModifierScreen.drawTileCollectionWithTransformation(cached_sorted_deck, 20, 100, tilesPerRow, selected_tiles_indices, 0.8)
    end

    -- Draw transformation summary if animating
    if animation_timer > 0 and #tile_transformations > 0 then
        DeckModifierScreen.drawTransformationSummary(screenWidth, screenHeight)
    end

    -- Draw buttons
    local buttonWidth = 120
    local buttonHeight = 40
    local confirmButtonX = screenWidth / 2 - buttonWidth - 20
    local cancelButtonX = screenWidth / 2 + 20
    local buttonY = screenHeight - buttonHeight - 20

    MahjongUI.drawButton("Confirm", confirmButtonX, buttonY, buttonWidth, buttonHeight)
    MahjongUI.drawButton("Cancel", cancelButtonX, buttonY, buttonWidth, buttonHeight)

    -- Reset graphics state to prevent ghosting
    love.graphics.setColor(1, 1, 1, 1)
end

function DeckModifierScreen.mousepressed(x, y)
    if not DeckModifierScreen.mainGameState then return end

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    local deck = DeckModifierScreen.mainGameState.playerDeck

    -- Handle tile selection (using cached sorted deck)
    if cached_sorted_deck and #cached_sorted_deck > 0 then
        local tilesPerRow = math.floor((screenWidth - 40) / (MahjongUI.DIMENSIONS.TILE_WIDTH * 0.8 + MahjongUI.DIMENSIONS.TILE_MARGIN))
        local tileIndex, _, _, _ = MahjongUI.getTileAtPosition(x, y, cached_sorted_deck, 20, 100, tilesPerRow, 0.8, selected_tiles_indices)
        if tileIndex then
            if selected_tiles_indices[tileIndex] then
                selected_tiles_indices[tileIndex] = nil
            else
                if #DeckModifierScreen.getSelectedTiles() < current_spell.selection_count then
                    selected_tiles_indices[tileIndex] = true
                end
            end
            Music.playSFX("ui_click")
        end
    end

    -- Handle button clicks
    local buttonWidth = 120
    local buttonHeight = 40
    local confirmButtonX = screenWidth / 2 - buttonWidth - 20
    local cancelButtonX = screenWidth / 2 + 20
    local buttonY = screenHeight - buttonHeight - 20

    if MahjongUI.isPointInButton(x, y, confirmButtonX, buttonY, buttonWidth, buttonHeight) then
        DeckModifierScreen.confirm()
    elseif MahjongUI.isPointInButton(x, y, cancelButtonX, buttonY, buttonWidth, buttonHeight) then
        DeckModifierScreen.cancel()
    end
end

function DeckModifierScreen.getSelectedTiles()
    local selected = {}
    if cached_sorted_deck then
        for i, _ in pairs(selected_tiles_indices) do
            if cached_sorted_deck[i] then
                table.insert(selected, cached_sorted_deck[i])
            end
        end
    end
    return selected
end

function DeckModifierScreen.confirm()
    local selected_tiles = DeckModifierScreen.getSelectedTiles()
    local effect_func = DeckSpellEffects[current_spell.effect]
    if effect_func then
        local original_deck = {}
        -- Make a copy of original deck for comparison
        for i, tile in ipairs(cached_sorted_deck) do
            original_deck[i] = tile
        end

        local new_deck, result_message = effect_func(cached_sorted_deck, selected_tiles)

        -- Sort the new deck and update cache
        new_deck = MahjongTiles.sortTiles(new_deck)
        cached_sorted_deck = new_deck
        DeckModifierScreen.mainGameState.playerDeck = new_deck

        -- Clear selections after applying effect
        selected_tiles_indices = {}

        -- Track tile transformations for animation
        DeckModifierScreen.trackTileTransformations(original_deck, new_deck)

        -- Start animation
        animation_timer = animation_duration
        animation_phase = "transforming"

        print(result_message)

        -- Don't return to shop immediately, let user see the changes
        message = result_message .. " Press any key to continue."
    end
end

function DeckModifierScreen.cancel()
    -- Return to the shop
    DeckModifierScreen.mainGameState.screen = "shop"
    Music.playSFX("ui_error")
end

-- Draw tile collection with transformation animation
function DeckModifierScreen.drawTileCollectionWithTransformation(tiles, startX, startY, tilesPerRow, selectedIndices, scale)
    if not tiles or #tiles == 0 then return end

    local tileWidth = MahjongUI.DIMENSIONS.TILE_WIDTH * scale
    local tileHeight = MahjongUI.DIMENSIONS.TILE_HEIGHT * scale
    local tileMargin = MahjongUI.DIMENSIONS.TILE_MARGIN

    for i, tile in ipairs(tiles) do
        local row = math.floor((i - 1) / tilesPerRow)
        local col = (i - 1) % tilesPerRow
        local x = startX + col * (tileWidth + tileMargin)
        local y = startY + row * (tileHeight + tileMargin)

        -- Check if this tile has a transformation
        local transformation = nil
        for _, trans in ipairs(tile_transformations) do
            if trans.newIndex == i then
                transformation = trans
                break
            end
        end

        -- Apply transformation animation if exists
        if transformation and animation_timer > 0 then
            DeckModifierScreen.drawTransformingTile(transformation, x, y, tileWidth, tileHeight, selectedIndices and selectedIndices[i], scale)
        else
            MahjongUI.drawTile(tile, x, y, selectedIndices and selectedIndices[i], scale)
        end
    end

    -- Reset graphics state after drawing tiles
    love.graphics.setColor(1, 1, 1, 1)
end

-- Track tile transformations for better animation
function DeckModifierScreen.trackTileTransformations(originalDeck, newDeck)
    tile_transformations = {}

    -- Find tiles that were transformed
    for i = 1, math.max(#originalDeck, #newDeck) do
        local originalTile = originalDeck[i]
        local newTile = newDeck[i]

        if originalTile and newTile and not MahjongTiles.tilesMatch(originalTile, newTile) then
            table.insert(tile_transformations, {
                oldTile = originalTile,
                newTile = newTile,
                newIndex = i,
                startTime = love.timer.getTime()
            })
        end
    end
end

-- Draw a tile that's currently transforming
function DeckModifierScreen.drawTransformingTile(transformation, x, y, tileWidth, tileHeight, isSelected, scale)
    local progress = 1 - (animation_timer / animation_duration)

    love.graphics.push()
    love.graphics.translate(x + tileWidth/2, y + tileHeight/2)

    if animation_phase == "transforming" then
        -- Phase 1: Show transformation in progress
        local pulseIntensity = math.sin(progress * 8) * 0.5 + 0.5
        love.graphics.scale(1 + pulseIntensity * 0.2, 1 + pulseIntensity * 0.2)

        -- Draw transformation effect background
        love.graphics.setColor(1, 0.5, 0, 0.4 + pulseIntensity * 0.4)
        love.graphics.rectangle("fill", -tileWidth/2 - 3, -tileHeight/2 - 3, tileWidth + 6, tileHeight + 6, 5)

        -- Draw old tile fading out
        local oldAlpha = 1 - progress * 2
        if oldAlpha > 0 then
            love.graphics.setColor(1, 1, 1, oldAlpha)
            MahjongUI.drawTile(transformation.oldTile, -tileWidth/2, -tileHeight/2, isSelected, scale)
        end

        -- Draw new tile fading in
        local newAlpha = (progress - 0.3) * 2
        if newAlpha > 0 then
            love.graphics.setColor(1, 1, 1, math.min(1, newAlpha))
            MahjongUI.drawTile(transformation.newTile, -tileWidth/2, -tileHeight/2, isSelected, scale)
        end

    elseif animation_phase == "result" then
        -- Phase 2: Show result with celebratory effect
        local glowIntensity = math.sin((1-progress) * 10) * 0.5 + 0.5
        love.graphics.scale(1 + glowIntensity * 0.1, 1 + glowIntensity * 0.1)

        -- Draw success glow
        love.graphics.setColor(0, 1, 0, 0.3 + glowIntensity * 0.3)
        love.graphics.rectangle("fill", -tileWidth/2 - 2, -tileHeight/2 - 2, tileWidth + 4, tileHeight + 4, 5)

        -- Draw the new tile
        love.graphics.setColor(1, 1, 1, 1)
        MahjongUI.drawTile(transformation.newTile, -tileWidth/2, -tileHeight/2, isSelected, scale)
    end

    love.graphics.pop()

    -- Draw transformation arrow if in transforming phase
    if animation_phase == "transforming" and progress > 0.2 and progress < 0.8 then
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.setFont(MahjongUI.fonts and MahjongUI.fonts.small or love.graphics.getFont())
        love.graphics.printf("→", x - 10, y + tileHeight + 5, tileWidth + 20, "center")
    end
end

-- Draw transformation summary overlay
function DeckModifierScreen.drawTransformationSummary(screenWidth, screenHeight)
    if #tile_transformations == 0 then return end

    -- Summary panel
    local panelWidth = 350
    local panelHeight = math.min(200, 50 + #tile_transformations * 25)
    local panelX = screenWidth - panelWidth - 20
    local panelY = 20

    -- Semi-transparent background
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", panelX, panelY, panelWidth, panelHeight, 8)

    -- Border
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", panelX, panelY, panelWidth, panelHeight, 8)

    -- Title
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(MahjongUI.fonts and MahjongUI.fonts.normal or love.graphics.getFont())
    love.graphics.printf("Tile Transformations:", panelX + 10, panelY + 10, panelWidth - 20, "center")

    -- List transformations
    local y = panelY + 35
    local maxDisplay = math.min(6, #tile_transformations)

    for i = 1, maxDisplay do
        local trans = tile_transformations[i]
        local oldName = DeckModifierScreen.getTileName(trans.oldTile)
        local newName = DeckModifierScreen.getTileName(trans.newTile)

        love.graphics.setColor(0.8, 0.8, 0.8, 1)
        love.graphics.printf(oldName .. " → " .. newName, panelX + 10, y, panelWidth - 20, "left")
        y = y + 22
    end

    if #tile_transformations > maxDisplay then
        love.graphics.setColor(0.6, 0.6, 0.6, 1)
        love.graphics.printf("... and " .. (#tile_transformations - maxDisplay) .. " more", panelX + 10, y, panelWidth - 20, "left")
    end

    -- Phase indicator
    local phaseText = animation_phase == "transforming" and "Transforming..." or "Transformation Complete!"
    local phaseColor = animation_phase == "transforming" and {1, 0.5, 0, 1} or {0, 1, 0, 1}

    love.graphics.setColor(phaseColor)
    love.graphics.printf(phaseText, panelX + 10, panelY + panelHeight - 25, panelWidth - 20, "center")
end

-- Get a readable name for a tile
function DeckModifierScreen.getTileName(tile)
    if not tile then return "Unknown" end

    if tile.suit == "dots" or tile.suit == "circles" then
        return tile.value .. " Dots"
    elseif tile.suit == "bamboos" then
        return tile.value .. " Bamboo"
    elseif tile.suit == "characters" then
        return tile.value .. " Char"
    elseif tile.suit == "winds" then
        local windNames = {[1] = "East", [2] = "South", [3] = "West", [4] = "North", east = "East", south = "South", west = "West", north = "North"}
        return windNames[tile.value] or (tile.value .. " Wind")
    elseif tile.suit == "dragons" then
        local dragonNames = {[1] = "Red Dragon", [2] = "Green Dragon", [3] = "White Dragon", red = "Red Dragon", green = "Green Dragon", white = "White Dragon"}
        return dragonNames[tile.value] or (tile.value .. " Dragon")
    end

    return (tile.suit or "?") .. " " .. (tile.value or "?")
end

-- Handle keypressed to continue after spell effect
function DeckModifierScreen.keypressed(key)
    if animation_timer > 0 then
        -- Any key press during animation returns to shop
        DeckModifierScreen.mainGameState.screen = "shop"
        Music.playSFX("purchase")
    end
end

return DeckModifierScreen
