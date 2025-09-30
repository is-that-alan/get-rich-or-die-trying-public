-- Settings Menu
-- Simple settings menu for display and other options

local SettingsMenu = {}

local MahjongUI = require("mahjong_ui")
local Music = require("music")

-- Simple approach: Always use the global DisplaySettings from main.lua
local function getWorkingDisplaySettings()
    return _G.DisplaySettings
end

-- Check if DisplaySettings is available at module load time
local DisplaySettings = getWorkingDisplaySettings()
if DisplaySettings then
    print("DEBUG: SettingsMenu found DisplaySettings with",
          (DisplaySettings.getSettings and "getSettings" or "NO getSettings"))
else
    print("ERROR: SettingsMenu could not find DisplaySettings")
end

-- Menu state
local currentOption = 1
local maxOptions = 6
local isResolutionSubMenu = false
local currentResolutionOption = 1
local availableResolutions = {}

-- Initialize settings menu
function SettingsMenu.init(mainGameState)
    SettingsMenu.mainGameState = mainGameState
    currentOption = 1
    isResolutionSubMenu = false

    local workingDisplaySettings = getWorkingDisplaySettings()
    if workingDisplaySettings and workingDisplaySettings.getAvailableResolutions then
        availableResolutions = workingDisplaySettings.getAvailableResolutions()

        -- Find current resolution index
        local currentSettings = workingDisplaySettings.getSettings()
        if currentSettings and currentSettings.resolution then
            for i, res in ipairs(availableResolutions) do
                if res.width == currentSettings.resolution.width and res.height == currentSettings.resolution.height then
                    currentResolutionOption = i
                    break
                end
            end
        end
    else
        print("DisplaySettings not available in settings menu")
        availableResolutions = {{width = 1280, height = 720, name = "720p Default"}}
        currentResolutionOption = 1
    end
end

-- Update
function SettingsMenu.update(dt)
    -- Nothing to update for now
end


-- Draw settings menu
function SettingsMenu.draw()
    if not SettingsMenu.mainGameState then return end

    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    -- Background
    love.graphics.setColor(0.1, 0.1, 0.2, 1)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    -- Title
    love.graphics.setColor(0.9, 0.9, 1, 1)
    love.graphics.setFont(MahjongUI.fonts and MahjongUI.fonts.title or love.graphics.newFont(24))
    love.graphics.printf("Settings / 設定", 0, 50, screenWidth, "center")

    -- Get current settings - try local first, then global
    local settings = nil
    local workingDisplaySettings = getWorkingDisplaySettings()

    if workingDisplaySettings and workingDisplaySettings.getSettings then
        settings = workingDisplaySettings.getSettings()
    else
        print("DisplaySettings not available in draw function")
        if not workingDisplaySettings then
            print("DEBUG: No DisplaySettings found (local or global)")
        else
            print("DEBUG: DisplaySettings found but getSettings is missing")
        end
        return
    end

    if not isResolutionSubMenu then
        -- Main menu options
        SettingsMenu.drawMainMenu(screenWidth, screenHeight, settings, workingDisplaySettings)
    else
        -- Resolution submenu
        SettingsMenu.drawResolutionMenu(screenWidth, screenHeight, settings)
    end

    -- Instructions
    love.graphics.setColor(0.7, 0.7, 0.8, 1)
    love.graphics.setFont(MahjongUI.fonts and MahjongUI.fonts.small or love.graphics.newFont(12))
    local instructions = isResolutionSubMenu and
        "↑↓ Navigate • Enter Select • Backspace Back • Esc Exit" or
        "↑↓ Navigate • Enter Select/Toggle • Esc Back"
    love.graphics.printf(instructions, 0, screenHeight - 30, screenWidth, "center")
end

-- Draw main menu
function SettingsMenu.drawMainMenu(screenWidth, screenHeight, settings, workingDisplaySettings)
    local startY = 150
    local lineHeight = 50
    local font = MahjongUI.fonts and MahjongUI.fonts.normal or love.graphics.newFont(16)
    love.graphics.setFont(font)

    local options = {
        "Fullscreen: " .. (settings.fullscreen and "ON" or "OFF"),
        "Resolution: " .. settings.resolution.width .. "x" .. settings.resolution.height,
        "Aspect Ratio: " .. (workingDisplaySettings and workingDisplaySettings.getAspectRatioDisplayName and workingDisplaySettings.getAspectRatioDisplayName(settings.aspectRatio) or settings.aspectRatio),
        "VSync: " .. (settings.vsync and "ON" or "OFF"),
        "Shortcuts: F11 or Alt+Enter for Fullscreen",
        "Back to Game"
    }

    maxOptions = #options

    for i, option in ipairs(options) do
        local y = startY + (i - 1) * lineHeight
        local isSelected = (i == currentOption)

        -- Highlight selected option
        if isSelected then
            love.graphics.setColor(0.3, 0.5, 0.8, 0.3)
            love.graphics.rectangle("fill", screenWidth * 0.2, y - 10, screenWidth * 0.6, lineHeight - 10, 5)
        end

        -- Option text
        love.graphics.setColor(isSelected and {1, 1, 1, 1} or {0.8, 0.8, 0.9, 1})
        love.graphics.printf(option, screenWidth * 0.2, y, screenWidth * 0.6, "center")

        -- Arrows for selected option
        if isSelected and i <= 4 then -- Only show arrows for adjustable options
            love.graphics.setColor(0.9, 0.7, 0.3, 1)
            love.graphics.printf("< >", screenWidth * 0.1, y, screenWidth * 0.8, "center")
        end
    end
end

-- Draw resolution menu
function SettingsMenu.drawResolutionMenu(screenWidth, screenHeight, settings)
    local startY = 120
    local lineHeight = 40
    local font = MahjongUI.fonts and MahjongUI.fonts.normal or love.graphics.newFont(16)
    love.graphics.setFont(font)

    -- Title
    love.graphics.setColor(0.8, 0.9, 1, 1)
    love.graphics.printf("Select Resolution", 0, 80, screenWidth, "center")

    -- Resolution options
    for i, res in ipairs(availableResolutions) do
        local y = startY + (i - 1) * lineHeight
        local isSelected = (i == currentResolutionOption)
        local isCurrent = (res.width == settings.resolution.width and res.height == settings.resolution.height)

        -- Highlight selected option
        if isSelected then
            love.graphics.setColor(0.3, 0.5, 0.8, 0.3)
            love.graphics.rectangle("fill", screenWidth * 0.25, y - 5, screenWidth * 0.5, lineHeight - 10, 5)
        end

        -- Option text
        local color = {0.8, 0.8, 0.9, 1}
        if isSelected then
            color = {1, 1, 1, 1}
        elseif isCurrent then
            color = {0.3, 0.8, 0.3, 1}
        end
        love.graphics.setColor(color)

        local resText = res.width .. "x" .. res.height .. " (" .. res.name .. ")"
        if isCurrent then
            resText = resText .. " ✓"
        end
        love.graphics.printf(resText, screenWidth * 0.25, y, screenWidth * 0.5, "center")
    end
end

-- Handle key presses
function SettingsMenu.keypressed(key)
    if key == "escape" then
        if isResolutionSubMenu then
            isResolutionSubMenu = false
            return
        else
            SettingsMenu.mainGameState.screen = "menu"
            Music.playSFX("ui_back")
            return
        end
    end

    if not isResolutionSubMenu then
        SettingsMenu.handleMainMenuKey(key)
    else
        SettingsMenu.handleResolutionMenuKey(key)
    end
end

-- Handle main menu keys
function SettingsMenu.handleMainMenuKey(key)
    if key == "up" then
        currentOption = currentOption - 1
        if currentOption < 1 then currentOption = maxOptions end
        Music.playSFX("ui_move")
    elseif key == "down" then
        currentOption = currentOption + 1
        if currentOption > maxOptions then currentOption = 1 end
        Music.playSFX("ui_move")
    elseif key == "return" or key == "space" then
        Music.playSFX("ui_click")

        if currentOption == 1 then -- Fullscreen
            local workingDisplaySettings = getWorkingDisplaySettings()
            if workingDisplaySettings and workingDisplaySettings.toggleFullscreen then
                workingDisplaySettings.toggleFullscreen()
            end
        elseif currentOption == 2 then -- Resolution
            isResolutionSubMenu = true
        elseif currentOption == 3 then -- Aspect Ratio
            SettingsMenu.cycleAspectRatio()
        elseif currentOption == 4 then -- VSync
            SettingsMenu.toggleVSync()
        elseif currentOption == 6 then -- Back to Game
            SettingsMenu.mainGameState.screen = "menu"
            Music.playSFX("ui_back")
        end
    end
end

-- Handle resolution menu keys
function SettingsMenu.handleResolutionMenuKey(key)
    if key == "up" then
        currentResolutionOption = currentResolutionOption - 1
        if currentResolutionOption < 1 then currentResolutionOption = #availableResolutions end
        Music.playSFX("ui_move")
    elseif key == "down" then
        currentResolutionOption = currentResolutionOption + 1
        if currentResolutionOption > #availableResolutions then currentResolutionOption = 1 end
        Music.playSFX("ui_move")
    elseif key == "return" or key == "space" then
        local selectedRes = availableResolutions[currentResolutionOption]
        local workingDisplaySettings = getWorkingDisplaySettings()
        if workingDisplaySettings and workingDisplaySettings.setResolution then
            workingDisplaySettings.setResolution(selectedRes.width, selectedRes.height)
        end
        isResolutionSubMenu = false
        Music.playSFX("ui_confirm")
    elseif key == "backspace" then
        isResolutionSubMenu = false
        Music.playSFX("ui_back")
    end
end

-- Cycle through aspect ratios (with error protection)
function SettingsMenu.cycleAspectRatio()
    local workingDisplaySettings = getWorkingDisplaySettings()
    if not workingDisplaySettings then
        print("DisplaySettings not available for aspect ratio cycling")
        return
    end

    local success = pcall(function()
        local ratios = workingDisplaySettings.getAvailableAspectRatios()
        if not ratios or #ratios == 0 then
            print("No aspect ratios available")
            return
        end

        local currentRatio = workingDisplaySettings.getSettings().aspectRatio

        local currentIndex = 1
        for i, ratio in ipairs(ratios) do
            if ratio == currentRatio then
                currentIndex = i
                break
            end
        end

        local nextIndex = currentIndex + 1
        if nextIndex > #ratios then nextIndex = 1 end

        local nextRatio = ratios[nextIndex]
        if nextRatio then
            workingDisplaySettings.setAspectRatio(nextRatio)
            availableResolutions = workingDisplaySettings.getAvailableResolutions()
            currentResolutionOption = 1
        end
    end)

    if not success then
        print("Failed to cycle aspect ratio, keeping current setting")
    end
end

-- Toggle VSync
function SettingsMenu.toggleVSync()
    local workingDisplaySettings = getWorkingDisplaySettings()
    if not workingDisplaySettings then
        print("DisplaySettings not available for VSync toggle")
        return
    end

    local settings = workingDisplaySettings.getSettings()
    settings.vsync = not settings.vsync
    workingDisplaySettings.applySettings()
    workingDisplaySettings.saveSettings()
    print("VSync: " .. (settings.vsync and "ON" or "OFF"))
end

return SettingsMenu