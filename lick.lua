-- LICK - Live Coding Kit for LÖVE2D
-- Source: https://github.com/usysrc/LICK
-- Enables hot reload during development

local lick = {}

lick.file = "main.lua"
lick.debug = true -- Enable debug for development
lick.reset = true -- Enable auto-reload for development
lick.clearFlag = false

-- Watch multiple files for changes (restored for full development)
lick.watchFiles = {
    "main.lua",
    "card.lua",
    "mahjong_battle.lua",
    "mahjong_tiles.lua",
    "mahjong_logic.lua",
    "mahjong_deck.lua",
    "mahjong_state.lua",
    "mahjong_ui.lua",
    "juice.lua",
    "hk_flavor.lua",
    "progression.lua",
    "shop.lua"
}

-- Smart reloading configuration
lick.debounceTime = 0.5 -- Wait 0.5 seconds before reloading after last file change
lick.reloadCooldown = 1.0 -- Minimum time between reloads
lick.lastReloadTime = 0
lick.pendingReload = false
lick.pendingReloadTime = 0

-- File-specific reload behavior
lick.fileReloadBehavior = {
    -- Files that require full game reload
    ["main.lua"] = "full_reload",
    ["card.lua"] = "full_reload",
    ["mahjong_battle.lua"] = "full_reload",
    ["progression.lua"] = "full_reload",
    ["shop.lua"] = "full_reload",

    -- Files that can be reloaded without calling love.load
    ["juice.lua"] = "module_only",
    ["hk_flavor.lua"] = "module_only",
    ["mahjong_tiles.lua"] = "module_only",
    ["mahjong_logic.lua"] = "module_only",
    ["mahjong_deck.lua"] = "module_only",
    ["mahjong_state.lua"] = "module_only",
    ["mahjong_ui.lua"] = "module_only"
}

-- Track which file triggered the last reload
lick.lastChangedFile = nil

-- Reload statistics
lick.stats = {
    totalReloads = 0,
    moduleOnlyReloads = 0,
    fullReloads = 0,
    lastReloadFile = nil
}

-- Configuration functions
function lick.setDebounceTime(time)
    lick.debounceTime = time
    if lick.debug then
        print("🔄 LICK: Debounce time set to " .. time .. "s")
    end
end

function lick.setReloadCooldown(time)
    lick.reloadCooldown = time
    if lick.debug then
        print("🔄 LICK: Reload cooldown set to " .. time .. "s")
    end
end

function lick.setFileBehavior(filename, behavior)
    lick.fileReloadBehavior[filename] = behavior
    if lick.debug then
        print("🔄 LICK: File " .. filename .. " set to " .. behavior .. " reload")
    end
end

function lick.getStats()
    return lick.stats
end

function lick.resetStats()
    lick.stats = {
        totalReloads = 0,
        moduleOnlyReloads = 0,
        fullReloads = 0,
        lastReloadFile = nil
    }
    if lick.debug then
        print("🔄 LICK: Statistics reset")
    end
end

local last_modified = {}

function lick.update(dt)
    local currentTime = love.timer.getTime()

    -- Check if we have a pending reload and enough time has passed
    if lick.pendingReload and (currentTime - lick.pendingReloadTime) >= lick.debounceTime then
        lick.pendingReload = false
        lick.performReload()
        return
    end

    -- Check for file changes
    for _, filename in ipairs(lick.watchFiles) do
        local info = love.filesystem.getInfo(filename)
        if info then
            local modified = info.modtime
            local last = last_modified[filename] or 0
            if modified > last then
                last_modified[filename] = modified
                lick.lastChangedFile = filename

                -- Check cooldown to prevent rapid successive reloads
                if (currentTime - lick.lastReloadTime) >= lick.reloadCooldown then
                    local behavior = lick.fileReloadBehavior[filename] or "full_reload"
                    if lick.debug then
                        print("🔄 LICK: File changed: " .. filename .. " (" .. behavior .. ") - scheduling reload in " .. lick.debounceTime .. "s")
                    end
                    lick.pendingReload = true
                    lick.pendingReloadTime = currentTime
                else
                    if lick.debug then
                        print("🔄 LICK: File changed: " .. filename .. " - reload on cooldown, ignoring")
                    end
                end
                break -- Only handle one file change per frame
            end
        end
    end
end

-- Internal function that actually performs the reload
function lick.performReload()
    lick.lastReloadTime = love.timer.getTime()

    local behavior = lick.fileReloadBehavior[lick.lastChangedFile] or "full_reload"

    -- Update statistics
    lick.stats.totalReloads = lick.stats.totalReloads + 1
    lick.stats.lastReloadFile = lick.lastChangedFile

    if lick.debug then
        print("🔄 LICK: Performing " .. behavior .. " for " .. (lick.lastChangedFile or "unknown file"))
    end

    if behavior == "module_only" then
        -- Module-only reload: just clear and reload the specific module
        local moduleName = lick.lastChangedFile:gsub("%.lua$", "")
        package.loaded[moduleName] = nil

        local ok, result = pcall(require, moduleName)
        if not ok then
            print("❌ LICK: Error reloading module " .. moduleName .. ": " .. tostring(result))
            return false
        end

        lick.stats.moduleOnlyReloads = lick.stats.moduleOnlyReloads + 1

        if lick.debug then
            print("✅ LICK: Successfully reloaded module: " .. moduleName)
        end
        return true
    else
        -- Full reload: clear all modules and reload main
        local protected = {
            lick = true,
            love = true,
            ["love.filesystem"] = true,
            ["love.graphics"] = true,
            ["love.audio"] = true,
            ["love.timer"] = true
        }

        for k, v in pairs(package.loaded) do
            if not protected[k] then
                package.loaded[k] = nil
            end
        end

        -- Try to reload main
        local ok, chunk = pcall(love.filesystem.load, lick.file)
        if not ok then
            print("❌ LICK: Syntax error in " .. lick.file .. ": " .. tostring(chunk))
            return false
        end

        local ok, result = pcall(chunk)
        if not ok then
            print("❌ LICK: Runtime error: " .. tostring(result))
            return false
        end

        -- Reinitialize if love.load exists
        if love.load then
            local ok, err = pcall(love.load, love.arg and love.arg.parseGameArguments(arg) or {}, arg or {})
            if not ok then
                print("❌ LICK: Error in love.load: " .. tostring(err))
                return false
            end
        end

        lick.stats.fullReloads = lick.stats.fullReloads + 1

        if lick.debug then
            print("✅ LICK: Successfully performed full reload!")
        end
        return true
    end
end

-- Public function for manual reloading (Ctrl+R)
function lick.reload()
    lick.pendingReload = false -- Cancel any pending reload
    return lick.performReload()
end

function lick.keypressed(key)
    if key == "r" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        lick.reload()
    elseif key == "s" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        -- Show statistics
        local stats = lick.getStats()
        print("📊 LICK Statistics:")
        print("  Total reloads: " .. stats.totalReloads)
        print("  Module-only reloads: " .. stats.moduleOnlyReloads)
        print("  Full reloads: " .. stats.fullReloads)
        print("  Last reloaded file: " .. (stats.lastReloadFile or "none"))
    elseif key == "d" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        -- Toggle debug mode
        lick.debug = not lick.debug
        print("🔄 LICK: Debug mode " .. (lick.debug and "enabled" or "disabled"))
    elseif key == "c" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        -- Reset statistics
        lick.resetStats()
    end
end

return lick