-- Display Settings Module
-- Handles fullscreen, aspect ratio, and resolution management

local DisplaySettings = {}

-- Default settings
DisplaySettings.settings = {
    fullscreen = false,
    resolution = {width = 1280, height = 720},
    aspectRatio = "16_9",
    vsync = true
}

-- Common aspect ratios and resolutions (using _ instead of : to avoid Lua syntax issues)
DisplaySettings.aspectRatios = {
    ["16_9"] = {
        {width = 1920, height = 1080, name = "1080p"},
        {width = 1680, height = 945, name = "1680x945"},
        {width = 1600, height = 900, name = "1600x900"},
        {width = 1366, height = 768, name = "1366x768"},
        {width = 1280, height = 720, name = "720p"},
        {width = 1024, height = 576, name = "1024x576"}
    },
    ["16_10"] = {
        {width = 1920, height = 1200, name = "1920x1200"},
        {width = 1680, height = 1050, name = "1680x1050"},
        {width = 1440, height = 900, name = "1440x900"},
        {width = 1280, height = 800, name = "1280x800"}
    },
    ["4_3"] = {
        {width = 1600, height = 1200, name = "1600x1200"},
        {width = 1400, height = 1050, name = "1400x1050"},
        {width = 1280, height = 960, name = "1280x960"},
        {width = 1024, height = 768, name = "1024x768"},
        {width = 800, height = 600, name = "800x600"}
    }
}

-- Display names for aspect ratios (for UI display)
DisplaySettings.aspectRatioNames = {
    ["16_9"] = "16:9 (Widescreen)",
    ["16_10"] = "16:10 (Wide)",
    ["4_3"] = "4:3 (Traditional)"
}

-- Initialize display settings
function DisplaySettings.init()
    -- Load settings from save file if it exists (with error protection)
    local loadSuccess = pcall(DisplaySettings.loadSettings)
    if not loadSuccess then
        print("Warning: Failed to load saved display settings, using defaults")
    end

    -- Apply initial settings (but preserve Chinese font rendering) (with error protection)
    local applySuccess = pcall(DisplaySettings.applySettings)
    if not applySuccess then
        print("Warning: Failed to apply display settings, using system defaults")
    end
end

-- Toggle fullscreen mode
function DisplaySettings.toggleFullscreen()
    DisplaySettings.settings.fullscreen = not DisplaySettings.settings.fullscreen
    DisplaySettings.applySettings()
    DisplaySettings.saveSettings()

    print("Fullscreen: " .. (DisplaySettings.settings.fullscreen and "ON" or "OFF"))
end

-- Set resolution (preserves Chinese font rendering)
function DisplaySettings.setResolution(width, height)
    DisplaySettings.settings.resolution.width = width
    DisplaySettings.settings.resolution.height = height
    DisplaySettings.applySettings()
    DisplaySettings.saveSettings()

    print("Resolution set to: " .. width .. "x" .. height)
end

-- Set aspect ratio (with error protection)
function DisplaySettings.setAspectRatio(aspectRatio)
    if not aspectRatio or not DisplaySettings.aspectRatios[aspectRatio] then
        print("Invalid aspect ratio: " .. tostring(aspectRatio) .. ", using default")
        aspectRatio = "16_9"
    end

    local success = pcall(function()
        DisplaySettings.settings.aspectRatio = aspectRatio
        -- Set to the highest resolution for this aspect ratio
        local resolutions = DisplaySettings.aspectRatios[aspectRatio]
        if resolutions and #resolutions > 0 then
            local bestRes = resolutions[1] -- First one is usually highest
            DisplaySettings.setResolution(bestRes.width, bestRes.height)
        else
            print("No resolutions available for aspect ratio: " .. aspectRatio)
            -- Fall back to default resolution
            DisplaySettings.setResolution(1280, 720)
        end
    end)

    if not success then
        print("Failed to set aspect ratio, reverting to defaults")
        DisplaySettings.settings.aspectRatio = "16_9"
        DisplaySettings.setResolution(1280, 720)
    end
end

-- Apply current settings to the window (carefully preserving font rendering)
function DisplaySettings.applySettings()
    local success = love.window.setMode(
        DisplaySettings.settings.resolution.width,
        DisplaySettings.settings.resolution.height,
        {
            fullscreen = DisplaySettings.settings.fullscreen,
            fullscreentype = "desktop",
            vsync = DisplaySettings.settings.vsync,
            resizable = not DisplaySettings.settings.fullscreen,
            minwidth = 800,
            minheight = 600,
            -- Preserve font rendering quality
            msaa = 0,
            stencil = true,
            depth = 0
        }
    )

    if not success then
        print("Failed to set display mode, reverting to defaults")
        DisplaySettings.settings.fullscreen = false
        DisplaySettings.settings.resolution = {width = 1280, height = 720}
        love.window.setMode(1280, 720, {
            fullscreen = false,
            fullscreentype = "desktop",
            vsync = true,
            resizable = true,
            minwidth = 800,
            minheight = 600,
            msaa = 0,
            stencil = true,
            depth = 0
        })
    end

    -- Important: Reset font filter to preserve Chinese character rendering
    if love.graphics.getFont then
        local currentFont = love.graphics.getFont()
        if currentFont then
            currentFont:setFilter("nearest", "nearest", 0)
        end
    end
end

-- Save settings to file
function DisplaySettings.saveSettings()
    local saveData = {
        fullscreen = DisplaySettings.settings.fullscreen,
        resolution = DisplaySettings.settings.resolution,
        aspectRatio = DisplaySettings.settings.aspectRatio,
        vsync = DisplaySettings.settings.vsync
    }

    local serialized = DisplaySettings.serialize(saveData)
    love.filesystem.write("display_settings.lua", serialized)
end

-- Load settings from file with error recovery
function DisplaySettings.loadSettings()
    if love.filesystem.getInfo("display_settings.lua") then
        local success, loadedSettings = pcall(function()
            local chunk = love.filesystem.load("display_settings.lua")
            return chunk()
        end)

        if success and loadedSettings and type(loadedSettings) == "table" then
            -- Merge loaded settings with defaults (with validation)
            for key, value in pairs(loadedSettings) do
                if DisplaySettings.settings[key] ~= nil then
                    -- Validate the value type matches expected
                    if type(value) == type(DisplaySettings.settings[key]) then
                        DisplaySettings.settings[key] = value
                    else
                        print("Invalid setting type for " .. key .. ", using default")
                    end
                end
            end
            print("Display settings loaded successfully")
        else
            print("Failed to load display settings (corrupted file), deleting and using defaults")
            -- Delete corrupted settings file
            love.filesystem.remove("display_settings.lua")
        end
    end
end

-- Robust serialization for settings (handles strings properly)
function DisplaySettings.serialize(t)
    local function serializeValue(val)
        if type(val) == "string" then
            return "\"" .. val .. "\""
        elseif type(val) == "boolean" then
            return tostring(val)
        elseif type(val) == "number" then
            return tostring(val)
        else
            return "nil"
        end
    end

    local result = "return {\n"
    for k, v in pairs(t) do
        if type(v) == "table" then
            result = result .. "    " .. k .. " = {\n"
            for k2, v2 in pairs(v) do
                result = result .. "        " .. k2 .. " = " .. serializeValue(v2) .. ",\n"
            end
            result = result .. "    },\n"
        else
            result = result .. "    " .. k .. " = " .. serializeValue(v) .. ",\n"
        end
    end
    result = result .. "}"
    return result
end

-- Get current settings
function DisplaySettings.getSettings()
    return DisplaySettings.settings
end

-- Get available resolutions for current aspect ratio
function DisplaySettings.getAvailableResolutions()
    return DisplaySettings.aspectRatios[DisplaySettings.settings.aspectRatio] or DisplaySettings.aspectRatios["16_9"]
end

-- Get all available aspect ratios (with display names)
function DisplaySettings.getAvailableAspectRatios()
    local ratios = {}
    for ratio, _ in pairs(DisplaySettings.aspectRatios) do
        table.insert(ratios, ratio)
    end
    table.sort(ratios)
    return ratios
end

-- Get display name for aspect ratio
function DisplaySettings.getAspectRatioDisplayName(ratio)
    return DisplaySettings.aspectRatioNames[ratio] or ratio
end

-- Handle keyboard shortcuts
function DisplaySettings.handleKeyPress(key)
    if key == "f11" then
        DisplaySettings.toggleFullscreen()
        return true
    elseif key == "return" and (love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt")) then
        DisplaySettings.toggleFullscreen()
        return true
    end
    return false
end

return DisplaySettings