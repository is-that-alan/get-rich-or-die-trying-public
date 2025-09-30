-- Scene System for Story Comics
-- Handles loading and displaying story scenes as comic panels

local Scene = {}
local Music = require("music")
local Dialogue = require("dialogue")

-- Scene state
local currentScene = nil
local currentPanel = 1
local scenePanels = {}
local sceneImages = {}
local blurredBackgrounds = {} -- Cache for blurred backgrounds
local sceneConfig = {}        -- Scene configuration from scene.txt
local sceneBGMStarted = false -- Track if scene BGM has been started
local panelZoom = {}          -- Per-panel zoom settings

-- Hover state tracking for sound effects
local hoverState = {
    backButton = false,
    nextButton = false
}

function Scene.loadScene(sceneName)
    currentScene = sceneName
    currentPanel = 1
    scenePanels = {}
    sceneImages = {}
    blurredBackgrounds = {} -- Clear blur cache
    sceneConfig = {}        -- Clear scene config
    sceneBGMStarted = false -- Reset BGM state
    panelZoom = {}          -- Clear panel zoom settings

    -- Load all images from the scene folder
    local sceneFolder = "scenes/" .. sceneName

    -- Get list of files in the scene folder
    local files = love.filesystem.getDirectoryItems(sceneFolder)

    -- Filter and sort image files
    local imageFiles = {}
    for _, file in ipairs(files) do
        local extension = file:match("%.([^%.]+)$")
        if extension and (extension:lower() == "png" or extension:lower() == "jpg" or extension:lower() == "jpeg") then
            table.insert(imageFiles, file)
        end
    end

    -- Sort files alphabetically/numerically
    table.sort(imageFiles)

    -- Load images
    for i, file in ipairs(imageFiles) do
        local imagePath = sceneFolder .. "/" .. file
        local success, image = pcall(love.graphics.newImage, imagePath)
        if success then
            table.insert(scenePanels, file)
            table.insert(sceneImages, image)
            print("✓ Loaded scene panel: " .. file)
        else
            print("✗ Failed to load: " .. file)
        end
    end

    print("Loaded " .. #scenePanels .. " panels for scene: " .. sceneName)

    -- Load scene configuration
    Scene.loadSceneConfig(sceneName)

    -- Start scene BGM if specified and not already started
    if sceneConfig.bgm and not sceneBGMStarted then
        Music.playBGM(sceneConfig.bgm)
        sceneBGMStarted = true
        print("🎵 Started scene BGM: " .. sceneConfig.bgm)
    end

    -- Load dialogue for first panel
    if #scenePanels > 0 then
        Dialogue.loadDialogue(sceneName, scenePanels[currentPanel])
    end

    -- Clear any global zoom from previous scenes
    _G.currentPanelZoom = nil

    return #scenePanels > 0
end

function Scene.update(dt)
    -- Update dialogue system
    if Dialogue.hasDialogue() then
        Dialogue.update(dt)
    end
end

function Scene.draw()
    if not currentScene or #sceneImages == 0 then
        -- No scene loaded, show placeholder
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("No scene loaded", 0, love.graphics.getHeight() / 2 - 20, love.graphics.getWidth(), "center")
        return
    end

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    -- Draw current panel
    local image = sceneImages[currentPanel]
    if image then
        local uiSpace = Dialogue.hasDialogue() and 140 or 100 -- More space if dialogue present
        local imageHeight = screenHeight - uiSpace
        local imageWidth = image:getWidth()
        local imgHeight = image:getHeight()

        -- Calculate scaling to fit screen while maintaining aspect ratio
        local scaleX = screenWidth / imageWidth
        local scaleY = imageHeight / imgHeight
        local baseScale = math.min(scaleX, scaleY)

        -- Apply zoom multiplier (default to 1.0 if not specified)
        -- Priority: dialogue zoom > panel zoom > scene zoom > default
        local zoomMultiplier = (_G.currentPanelZoom) or panelZoom[currentPanel] or sceneConfig.zoom or 1.0
        local scale = baseScale * zoomMultiplier

        -- Check if image doesn't fill the entire screen (has letterboxing/pillarboxing)
        local fillScaleX = screenWidth / imageWidth
        local fillScaleY = imageHeight / imgHeight
        local fillScale = math.max(fillScaleX, fillScaleY)

        local needsBackground = scale < fillScale

        if needsBackground then
            Scene.drawBlurredBackground(image, screenWidth, imageHeight, fillScale)
        end

        -- Draw the main image centered and properly scaled
        local drawWidth = imageWidth * scale
        local drawHeight = imgHeight * scale
        local x = (screenWidth - drawWidth) / 2
        local y = (imageHeight - drawHeight) / 2 + 50 -- Offset for UI

        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(image, x, y, 0, scale, scale)
    end

    -- Draw dialogue if present
    if Dialogue.hasDialogue() then
        Dialogue.draw(screenWidth, screenHeight)
    end

    -- Draw UI
    Scene.drawUI()
end

function Scene.drawBlurredBackground(image, screenWidth, screenHeight, fillScale)
    -- Check if we have a cached blurred background for this panel
    if not blurredBackgrounds[currentPanel] then
        -- Create blurred background canvas
        local canvas = love.graphics.newCanvas(screenWidth, screenHeight - 100)
        love.graphics.setCanvas(canvas)
        love.graphics.clear(0, 0, 0, 0)

        local imageWidth = image:getWidth()
        local imageHeight = image:getHeight()
        local bgX = (screenWidth - imageWidth * fillScale) / 2
        local bgY = (screenHeight - 100 - imageHeight * fillScale) / 2

        -- Create blur effect with multiple passes
        love.graphics.setBlendMode("alpha")

        -- First pass: draw multiple offset copies with low opacity
        love.graphics.setColor(1, 1, 1, 0.08)
        local blurRadius = 4
        local samples = 0
        for dx = -blurRadius, blurRadius, 1 do
            for dy = -blurRadius, blurRadius, 1 do
                local distance = math.sqrt(dx * dx + dy * dy)
                if distance <= blurRadius then
                    love.graphics.draw(image, bgX + dx, bgY + dy, 0, fillScale, fillScale)
                    samples = samples + 1
                end
            end
        end

        -- Second pass: add a slightly more opaque center layer
        love.graphics.setColor(1, 1, 1, 0.2)
        love.graphics.draw(image, bgX, bgY, 0, fillScale, fillScale)

        love.graphics.setCanvas()
        love.graphics.setBlendMode("alpha")

        -- Cache the result
        blurredBackgrounds[currentPanel] = canvas
    end

    -- Draw the cached blurred background
    love.graphics.setColor(1, 1, 1, 0.7) -- Adjust opacity as needed
    love.graphics.draw(blurredBackgrounds[currentPanel], 0, 50)
end

function Scene.drawUI()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    -- Top bar only (removed bottom UI bar)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, screenWidth, 50)

    -- Scene name and panel counter
    love.graphics.setColor(1, 1, 1)
    if currentScene then
        local sceneTitle = sceneConfig.title or currentScene
        if Scene.playlistInfo then
            sceneTitle = sceneTitle .. " (" .. Scene.playlistInfo.current .. "/" .. Scene.playlistInfo.total .. ")"
        end
        love.graphics.printf("Scene: " .. sceneTitle, 0, 5, screenWidth, "center")
        love.graphics.printf("Panel " .. currentPanel .. " of " .. #scenePanels, 0, 25, screenWidth, "center")
    else
        love.graphics.printf("Panel " .. currentPanel .. " of " .. #scenePanels, 0, 15, screenWidth, "center")
    end
end

function Scene.keypressed(key)
    if key == "right" then
        Music.playSFX("ui_click")
        Scene.nextPanel()
    elseif key == "left" then
        Music.playSFX("ui_click")
        Scene.previousPanel()
    elseif key == "escape" then
        Music.playSFX("ui_click")
        Scene.exitScene()
    end
end

function Scene.mousemoved(x, y)
    -- No hover effects needed since we removed the buttons
end

function Scene.mousepressed(x, y, button)
    if button ~= 1 then return end -- Only left click

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    -- Check if clicking on dialogue box
    if Dialogue.hasDialogue() and not Dialogue.isComplete() then
        local boxHeight = 120
        local boxY = screenHeight - boxHeight - 20  -- Match dialogue.lua position
        local boxX = 20
        local boxWidth = screenWidth - 40

        if x >= boxX and x <= boxX + boxWidth and y >= boxY and y <= boxY + boxHeight then
            Music.playSFX("ui_click")
            Scene.nextPanel()
            return
        end
    else
        -- No dialogue or dialogue complete - clicking anywhere on the image advances
        -- Exclude the top UI bar (y < 50) and very bottom edge
        if y > 50 and y < screenHeight - 10 then
            Music.playSFX("ui_click")
            Scene.nextPanel()
            return
        end
    end
end

function Scene.nextPanel()
    -- If dialogue is present and not complete, advance dialogue first
    if Dialogue.hasDialogue() and not Dialogue.isComplete() then
        local advanced = Dialogue.advance()
        if advanced then
            return -- Stay on current panel, dialogue advanced
        end
    end

    -- Dialogue complete or no dialogue, advance to next panel
    if currentPanel < #scenePanels then
        currentPanel = currentPanel + 1
        print("Advanced to panel " .. currentPanel)

        -- Load dialogue for new panel
        if currentScene and scenePanels[currentPanel] then
            Dialogue.loadDialogue(currentScene, scenePanels[currentPanel])
        end

        -- Clear any global zoom from previous panel
        _G.currentPanelZoom = nil

        -- Debug audio state when changing panels
        Music.debugAudioState()
    else
        -- No more panels - finish the scene
        print("No more panels - finishing scene")
        Scene.finishScene()
    end
end

function Scene.previousPanel()
    if currentPanel > 1 then
        currentPanel = currentPanel - 1
        print("Went back to panel " .. currentPanel)

        -- Load dialogue for previous panel
        if currentScene and scenePanels[currentPanel] then
            Dialogue.loadDialogue(currentScene, scenePanels[currentPanel])
        end

        -- Clear any global zoom from previous panel
        _G.currentPanelZoom = nil
    end
end

function Scene.finishScene()
    print("Scene finished: " .. (currentScene or "unknown"))

    -- Handle BGM end behavior
    Scene.handleSceneBGMEnd()

    -- This will be called when story is complete
    -- The main game should handle transitioning to next level
    if Scene.onSceneComplete then
        Scene.onSceneComplete(currentScene)
    end
end

function Scene.exitScene()
    print("Exiting scene: " .. (currentScene or "unknown"))

    -- Handle BGM end behavior
    Scene.handleSceneBGMEnd()

    if Scene.onSceneExit then
        Scene.onSceneExit()
    end
end

function Scene.handleSceneBGMEnd()
    if sceneConfig.bgmEnd then
        if sceneConfig.bgmEnd == "stop" then
            Music.stopBGM()
            print("🎵 Stopped BGM after scene end")
        else
            Music.playBGM(sceneConfig.bgmEnd)
            print("🎵 Changed BGM after scene end to: " .. sceneConfig.bgmEnd)
        end
    else
        -- Default behavior: continue current BGM (no change)
        print("🎵 BGM continues after scene (no BGM_END specified)")
    end
end

-- Callback functions (to be set by main game)
Scene.onSceneComplete = nil
Scene.onSceneExit = nil

-- Getters
function Scene.getCurrentScene()
    return currentScene
end

function Scene.getCurrentPanel()
    return currentPanel
end

function Scene.getTotalPanels()
    return #scenePanels
end

function Scene.isSceneLoaded()
    return currentScene ~= nil and #sceneImages > 0
end

-- Playlist info (can be set by main.lua for testing)
Scene.playlistInfo = nil

function Scene.setPlaylistInfo(current, total)
    Scene.playlistInfo = { current = current, total = total }
end

function Scene.loadSceneConfig(sceneName)
    local configFile = "scenes/" .. sceneName .. "/scene.txt"

    -- Reset config
    sceneConfig = {}

    -- Check if config file exists
    if not love.filesystem.getInfo(configFile) then
        print("No scene config found: " .. configFile .. " (using defaults)")
        return false
    end

    -- Load and parse config file
    local content = love.filesystem.read(configFile)
    if not content then
        print("Failed to read scene config: " .. configFile)
        return false
    end

    print("✓ Loading scene config: " .. configFile)

    -- Parse config tags
    for line in content:gmatch("[^\r\n]+") do
        line = line:match("^%s*(.-)%s*$") -- trim whitespace

        -- Parse BGM tag
        local bgm = line:match("%[BGM:([^%]]+)%]")
        if bgm then
            sceneConfig.bgm = bgm
            print("  BGM: " .. bgm)
        end

        -- Parse TITLE tag
        local title = line:match("%[TITLE:([^%]]+)%]")
        if title then
            sceneConfig.title = title
            print("  Title: " .. title)
        end

        -- Parse DESCRIPTION tag
        local description = line:match("%[DESCRIPTION:([^%]]+)%]")
        if description then
            sceneConfig.description = description
            print("  Description: " .. description)
        end

        -- Parse BGM_END tag
        local bgmEnd = line:match("%[BGM_END:([^%]]+)%]")
        if bgmEnd then
            sceneConfig.bgmEnd = bgmEnd
            print("  BGM End: " .. bgmEnd)
        end

        -- Parse ZOOM tag
        local zoom = line:match("%[ZOOM:([^%]]+)%]")
        if zoom then
            local zoomValue = tonumber(zoom)
            if zoomValue then
                sceneConfig.zoom = zoomValue
                print("  Zoom: " .. zoomValue)
            else
                print("  Invalid zoom value: " .. zoom)
            end
        end
    end

    return true
end

-- Getters for scene config
function Scene.getSceneTitle()
    return sceneConfig.title
end

function Scene.getSceneDescription()
    return sceneConfig.description
end

return Scene
