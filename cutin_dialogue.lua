-- Cut-in Dialogue System

-- Handles animated cut-in dialogues that appear during special events
-- Features: character images, names, dialogue, SFX, and smooth animations

local CutinDialogue = {}
local Music = require("music")
local Juice = require("juice")

-- Cut-in dialogue state
local currentCutin = nil
local cutinData = {}
local isActive = false
local animationTimer = 0
local appearDuration = 3.0 -- Default 3 seconds
local fadeInDuration = 0.5
local fadeOutDuration = 0.5

-- Animation states
local ANIMATION_STATE = {
    FADE_IN = "fade_in",
    DISPLAY = "display", 
    FADE_OUT = "fade_out",
    COMPLETE = "complete"
}

local currentState = ANIMATION_STATE.COMPLETE

-- Character image cache
local characterImages = {}

-- Cut-in dialogue data structure
local cutinDialogues = {}

-- Animation settings
local ANIMATION_SETTINGS = {
    SLIDE_DISTANCE = 150, -- How far the cut-in slides in from
    GLOW_INTENSITY = 0.3 -- Glow effect intensity
}

-- Load all cut-in dialogue data
function CutinDialogue.loadCutinData()
    cutinDialogues = {}
    
    -- Load from cutin_dialogues folder
    local cutinFiles = love.filesystem.getDirectoryItems("cutin_dialogues")
    
    for _, file in ipairs(cutinFiles) do
        if file:match("%.lua$") then
            local cutinName = file:gsub("%.lua$", "")
            local success, data = pcall(require, "cutin_dialogues." .. cutinName)
            
            if success and data then
                cutinDialogues[cutinName] = data
                print("✓ Loaded cut-in dialogue: " .. cutinName)
            else
                print("✗ Failed to load cut-in dialogue: " .. cutinName)
            end
        end
    end
    
    print("Loaded " .. #cutinDialogues .. " cut-in dialogue sets")
end

-- Load character image
function CutinDialogue.loadCharacterImage(characterPath)
    if characterImages[characterPath] then
        return characterImages[characterPath]
    end
    
    local success, image = pcall(love.graphics.newImage, characterPath)
    if success then
        characterImages[characterPath] = image
        print("✓ Loaded character image: " .. characterPath)
        return image
    else
        print("✗ Failed to load character image: " .. characterPath)
        return nil
    end
end

-- Show a cut-in dialogue
function CutinDialogue.show(cutinId, dialogueKey)
    if not cutinDialogues[cutinId] then
        print("✗ Cut-in dialogue not found: " .. cutinId)
        return false
    end
    
    local cutinSet = cutinDialogues[cutinId]
    if not cutinSet.dialogues or not cutinSet.dialogues[dialogueKey] then
        print("✗ Dialogue key not found: " .. dialogueKey .. " in " .. cutinId)
        return false
    end
    
    local dialogue = cutinSet.dialogues[dialogueKey]
    
    -- Set up cut-in data
    currentCutin = {
        id = cutinId,
        dialogueKey = dialogueKey,
        character = dialogue.character or "",
        characterImage = dialogue.characterImage and CutinDialogue.loadCharacterImage(dialogue.characterImage) or nil,
        text = dialogue.text or "",
        sfx = dialogue.sfx,
        appearSeconds = dialogue.appearSeconds or 3.0,
        color = dialogue.color or {1, 1, 1},
        bgm = dialogue.bgm
    }
    
    -- Reset animation state
    isActive = true
    animationTimer = 0
    currentState = ANIMATION_STATE.FADE_IN
    appearDuration = currentCutin.appearSeconds
    
    -- Play SFX if specified
    if currentCutin.sfx then
        Music.playSFX(currentCutin.sfx)
    end
    
    -- Change BGM if specified
    if currentCutin.bgm then
        if currentCutin.bgm == "stop" then
            Music.stopBGM()
        else
            Music.playBGM(currentCutin.bgm)
        end
    end
    
    print("🎭 Showing cut-in dialogue: " .. cutinId .. " -> " .. dialogueKey)
    return true
end

-- Update cut-in dialogue animation
function CutinDialogue.update(dt)
    if not isActive or not currentCutin then
        return
    end
    
    animationTimer = animationTimer + dt
    
    if currentState == ANIMATION_STATE.FADE_IN then
        if animationTimer >= fadeInDuration then
            currentState = ANIMATION_STATE.DISPLAY
            animationTimer = 0
        end
    elseif currentState == ANIMATION_STATE.DISPLAY then
        if animationTimer >= appearDuration then
            currentState = ANIMATION_STATE.FADE_OUT
            animationTimer = 0
        end
    elseif currentState == ANIMATION_STATE.FADE_OUT then
        if animationTimer >= fadeOutDuration then
            currentState = ANIMATION_STATE.COMPLETE
            isActive = false
            currentCutin = nil
        end
    end
end

-- Draw cut-in dialogue
function CutinDialogue.draw()
    if not isActive or not currentCutin then
        return
    end
    
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    -- Calculate animation progress
    local progress = 0
    local alpha = 1
    local offsetX = 0
    
    if currentState == ANIMATION_STATE.FADE_IN then
        progress = animationTimer / fadeInDuration
        alpha = progress
        offsetX = (1 - progress) * ANIMATION_SETTINGS.SLIDE_DISTANCE
    elseif currentState == ANIMATION_STATE.DISPLAY then
        progress = animationTimer / appearDuration
        alpha = 1
        offsetX = 0 -- Static during display
    elseif currentState == ANIMATION_STATE.FADE_OUT then
        progress = animationTimer / fadeOutDuration
        alpha = 1 - progress
        offsetX = progress * ANIMATION_SETTINGS.SLIDE_DISTANCE
    end
    
    -- Apply screen effects
    love.graphics.push()
    
    -- Apply transformations (no scaling, just translation)
    love.graphics.translate(screenWidth / 2, screenHeight / 2)
    love.graphics.translate(offsetX, 0) -- Only horizontal slide
    
    -- No dark modal background - less intrusive
    
    -- Bottom left corner layout - up to 33% of screen dimensions
    local maxCharacterWidth = screenWidth * 0.33 -- 33% of screen width
    local maxCharacterHeight = screenHeight * 0.33 -- 33% of screen height
    
    -- Position in bottom left corner with more bottom padding
    local characterX = -screenWidth/2 + 20
    local characterY = screenHeight/2 - maxCharacterHeight - 40 -- More bottom padding
    
    -- Character image (bottom left, maintain aspect ratio with max 33% constraint)
    if currentCutin.characterImage then
        -- Calculate scale to maintain aspect ratio while respecting max 33% dimensions
        local imgScaleX = maxCharacterWidth / currentCutin.characterImage:getWidth()
        local imgScaleY = maxCharacterHeight / currentCutin.characterImage:getHeight()
        local imgScale = math.max(imgScaleX, imgScaleY) -- Use the smaller scale to fit within bounds
        
        local imgWidth = currentCutin.characterImage:getWidth() * imgScale
        local imgHeight = currentCutin.characterImage:getHeight() * imgScale
        
        -- Position image in bottom left corner
        local imgX = characterX
        local imgY = characterY + (maxCharacterHeight - imgHeight) -- Align to bottom
        
        -- Draw solid character image (no layered effects)
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.draw(currentCutin.characterImage, imgX, imgY, 0, imgScale, imgScale)
    end
    
    -- Calculate text dimensions for dynamic sizing
    local text = currentCutin.text or ""
    local characterName = currentCutin.character or ""
    
    -- Use the existing Chinese font (already set up in main.lua)
    local originalFont = love.graphics.getFont()
    -- Don't change font - use the same Chinese font that's already working
    
    -- Calculate text box size based on content
    local textBoxPadding = 20
    local textBoxMargin = 5 -- Reduced gap between image and dialogue box
    local textBoxX = characterX + maxCharacterWidth + textBoxMargin
    local textBoxMaxWidth = screenWidth * 0.6 -- 60% of screen width for text
    
    -- Measure text height using current font
    local textHeight = 0
    if characterName ~= "" then
        textHeight = textHeight + originalFont:getHeight() + 10
    end
    textHeight = textHeight + originalFont:getHeight() + 10
    
    -- Calculate text box height
    local textBoxHeight = textHeight + textBoxPadding * 2
    local textBoxWidth = textBoxMaxWidth
    
    -- Align text box to bottom of character area
    local characterBottomY = characterY + maxCharacterHeight
    local textBoxY = characterBottomY - textBoxHeight
    
    -- Create feathered background with multiple layers for smooth gradient
    local featherLayers = 4
    for i = 1, featherLayers do
        local layerAlpha = alpha * (0.6 - (i-1) * 0.12)
        local layerWidth = textBoxWidth + i * 8
        local layerHeight = textBoxHeight + i * 6
        local layerX = textBoxX - i * 4
        local layerY = textBoxY - i * 3
        
        love.graphics.setColor(0.1, 0.1, 0.2, layerAlpha)
        love.graphics.rectangle("fill", layerX, layerY, layerWidth, layerHeight, 8 + i)
    end
    
    -- Main text background
    love.graphics.setColor(0.15, 0.15, 0.25, alpha * 0.85)
    love.graphics.rectangle("fill", textBoxX, textBoxY, textBoxWidth, textBoxHeight, 8)
    
    -- Subtle border
    love.graphics.setColor(0.6, 0.6, 0.8, alpha * 0.5)
    love.graphics.setLineWidth(1.5)
    love.graphics.rectangle("line", textBoxX, textBoxY, textBoxWidth, textBoxHeight, 8)
    
    -- Draw character name (if present)
    if characterName ~= "" then
        love.graphics.setColor(1, 1, 0.9, alpha)
        
        local success, err = pcall(function()
            love.graphics.printf(characterName, textBoxX + textBoxPadding, textBoxY + textBoxPadding, textBoxWidth - textBoxPadding * 2, "left")
        end)
        
        if not success then
            -- Silently fallback to English text
            love.graphics.printf("Character", textBoxX + textBoxPadding, textBoxY + textBoxPadding, textBoxWidth - textBoxPadding * 2, "left")
        end
    end
    
    -- Draw dialogue text
    love.graphics.setColor(currentCutin.color[1], currentCutin.color[2], currentCutin.color[3], alpha)
    local textY = characterName ~= "" and textBoxY + textBoxPadding + originalFont:getHeight() + 10 or textBoxY + textBoxPadding
    
    -- Safe text display with error handling
    local success, err = pcall(function()
        love.graphics.printf(text, textBoxX + textBoxPadding, textY, textBoxWidth - textBoxPadding * 2, "left")
    end)
    
    if not success then
        -- Silently fallback to English text
        love.graphics.printf("Dialogue text", textBoxX + textBoxPadding, textY, textBoxWidth - textBoxPadding * 2, "left")
    end
    
    -- Font restoration not needed since we didn't change the font
    
    -- Progress indicator removed for more natural feel
    
    love.graphics.pop()
end

-- Check if cut-in is currently active
function CutinDialogue.isActive()
    return isActive
end

-- Get current cut-in info
function CutinDialogue.getCurrentCutin()
    return currentCutin
end

-- Force close current cut-in
function CutinDialogue.close()
    if isActive then
        currentState = ANIMATION_STATE.FADE_OUT
        animationTimer = 0
    end
end

-- Get all available cut-in dialogues
function CutinDialogue.getAllCutins()
    return cutinDialogues
end

-- Search cut-in dialogues
function CutinDialogue.searchCutins(searchTerm)
    local results = {}
    searchTerm = searchTerm:lower()
    
    for cutinId, cutinData in pairs(cutinDialogues) do
        -- Search in cutin ID
        if cutinId:lower():find(searchTerm) then
            table.insert(results, {id = cutinId, data = cutinData, matchType = "id"})
        end
        
        -- Search in dialogue text
        if cutinData.dialogues then
            for dialogueKey, dialogue in pairs(cutinData.dialogues) do
                if dialogue.text and dialogue.text:lower():find(searchTerm) then
                    table.insert(results, {id = cutinId, dialogueKey = dialogueKey, data = cutinData, matchType = "text"})
                end
                if dialogue.character and dialogue.character:lower():find(searchTerm) then
                    table.insert(results, {id = cutinId, dialogueKey = dialogueKey, data = cutinData, matchType = "character"})
                end
            end
        end
    end
    
    return results
end

-- Initialize cut-in dialogue system
function CutinDialogue.init()
    print("Initializing Cut-in Dialogue System...")
    CutinDialogue.loadCutinData()
    print("Cut-in Dialogue System initialized")
end

-- Cleanup
function CutinDialogue.cleanup()
    characterImages = {}
    cutinDialogues = {}
    isActive = false
    currentCutin = nil
    print("Cut-in Dialogue System cleaned up")
end

return CutinDialogue
