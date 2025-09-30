-- Get Rich or Die Trying

-- Game state (Enhanced for Hong Kong Roguelike)
local gameState = {
    screen = "menu", -- "menu", "progression", "mahjong_battle", "shop", "event"
    playerMoney = 100,
    playerDeck = {},
    playerMemeCards = {}, -- Hong Kong meme cards (active abilities)
    playerRelics = {},    -- Hong Kong relics (passive effects)
    playerConsumables = {}, -- Hong Kong consumables (single-use items)
    playerCharacters = {},
    playerModifiers = {},
    playerPosition = { x = 1, y = 1 },
    selectedCard = nil,
    battleData = {},

    -- Roguelike progression
    runDepth = 1,
    level = 1,
    xp = 0,
    maxRounds = 10,

    -- Hong Kong cultural stats
    reputation = 0,
    friendCount = 3,
    streetCredibility = 0,
    socialMediaFollowers = 0,

    -- Status effects
    tiredness = 0,
    luckModifier = 0,
    passiveIncome = 0
}

-- Cache menu elements to prevent flashing
local menuCache = {
    motivation = nil,
    greeting = nil,
    weather = nil,
    lastUpdate = 0
}

-- Hover state tracking for sound effects
local hoverState = {
    startButton = false,
    continueButton = false
}

-- Konami code system
local konamiCode = { "up", "up", "down", "down", "left", "right", "d" }
local konamiWinCode = { "up", "up", "down", "down", "left", "right", "w" }
local konamiMoneyCode = { "up", "up", "down", "down", "left", "right", "m" }
local keySequence = {}
local maxSequenceLength = 7
local developerMenuActive = false
local previousScreen = "menu" -- Track the screen before opening developer menu

-- Cut-in dialogue test menu state
local cutinTestData = {
    allDialogues = {}, -- Flattened list of all dialogues
    searchTerm = "",
    filteredDialogues = {},
    selectedIndex = 1,
    isSearching = false
}

-- Load all game modules
local Card = require("card")
local Fortress = require("fortress")
-- Legacy battle system - deprecated, keeping for reference
-- local Battle = require("battle")
local MahjongBattle = require("mahjong_battle")
local Shop = require("shop")
local Music = require("music")
local Scene = require("scene")

-- Load Hong Kong roguelike systems
local HKMemeCards = require("hk_meme_cards")
local HKRelics = require("hk_relics")
local HKConsumables = require("hk_consumables")
local ProgressionCards = require("progression_cards")
local ProgressionScreen = require("progression_screen")
local EventScreen = require("event_screen")
local DeckModifierScreen = require("deck_modifier_screen")

-- Load enhancement systems
local HKFlavor = require("hk_flavor")
local Juice = require("juice")
local Progression = require("progression")
local CutinDialogue = require("cutin_dialogue")

-- Hot reload support for development
local lick = require("lick")
lick.reset = true -- Reset game state on reload

-- UTF-8 safe string length function
local function safeStringLength(str)
    if not str then return 0 end
    local success, len = pcall(function() return str:len() end)
    return success and len or 0
end

-- UTF-8 safe substring function
local function safeSubstring(str, start, finish)
    if not str then return "" end
    local success, result = pcall(function() return str:sub(start, finish) end)
    return success and result or ""
end

-- Screen dimensions
local SCREEN_WIDTH = 800
local SCREEN_HEIGHT = 600

-- Load UTF-8 helper
local utf8Helper = require("utf8")

-- Global font path for Chinese characters
_G.CHINESE_FONT_PATH = nil
_G.CHINESE_FONT_CACHE = {}

-- Helper function to create Chinese fonts at different sizes (with caching)
function createChineseFontSize(size)
    -- Check cache first
    if _G.CHINESE_FONT_CACHE[size] then
        return _G.CHINESE_FONT_CACHE[size]
    end

    local font
    if _G.CHINESE_FONT_PATH then
        local success, newFont = pcall(love.graphics.newFont, _G.CHINESE_FONT_PATH, size)
        if success then
            font = newFont
        end
    end

    -- Fallback to default font
    if not font then
        font = love.graphics.newFont(size)
    end

    -- Cache the font
    _G.CHINESE_FONT_CACHE[size] = font
    return font
end

function love.load()
    -- Set up proper UTF-8 handling
    love.filesystem.setRequirePath("?.lua;?/init.lua")

    -- Initialize enhancement systems
    Juice.init()
    Juice.initSounds()
    Progression.init()
    CutinDialogue.init()

    -- Create a font that supports Chinese characters
    local chineseFont = createChineseFont()
    love.graphics.setFont(chineseFont)

    -- Test Chinese character rendering
    local testChar = "測"
    local testWidth = chineseFont:getWidth(testChar)
    print("Test character '測' width: " .. testWidth)

    if testWidth > 0 then
        print("OK Chinese characters should render correctly!")
    else
        print("NO Chinese characters may not render - using fallback text")
    end

    -- Note: Tile graphics generation disabled for now
    -- Will use Chinese character rendering instead

    -- Initialize starter deck and characters
    gameState.playerDeck = Card.getStarterDeck()

    -- Load or generate tile images (ENABLED for compatibility)
    Card.loadImages()

    -- If no images were loaded, generate simple ones (ENABLED for fallback)
    if not Card.imagesLoaded or next(Card.images) == nil then
        print("No tile images found, generating simple graphics...")
        local tileGenerator = require("generate_tiles")
        tileGenerator.generateSimpleTiles()
        print("OK Generated authentic-style tile graphics")
    end

    print("Hong Kong 麻雀 Game Starting with JUICE & FLAVOR!")
end

function createChineseFont()
    local fontSize = 16

    -- Try to load Noto Sans TC fonts (Traditional Chinese - perfect for Hong Kong!)
    local notoFonts = {
        "Noto_Sans_TC/static/NotoSansTC-Regular.ttf",
        "Noto_Sans_TC/static/NotoSansTC-Medium.ttf",
        "Noto_Sans_TC/NotoSansTC-VariableFont_wght.ttf",
        "NotoSansCJK-Regular.ttc" -- Fallback to the old one
    }

    for _, fontPath in ipairs(notoFonts) do
        local success, font = pcall(love.graphics.newFont, fontPath, fontSize)
        if success then
            print("OK Successfully loaded Chinese font: " .. fontPath)
            _G.CHINESE_FONT_PATH = fontPath -- Store path globally
            return font
        else
            print("NO Failed to load: " .. fontPath)
        end
    end

    print("Trying system fonts...")

    -- Fallback to system fonts
    local systemFonts = {
        "/System/Library/Fonts/PingFang.ttc",
        "/System/Library/Fonts/Hiragino Sans GB.ttc",
        "/Library/Fonts/Arial Unicode MS.ttf"
    }

    for _, fontPath in ipairs(systemFonts) do
        local file = io.open(fontPath, "rb")
        if file then
            file:close()
            local success, font = pcall(love.graphics.newFont, fontPath, fontSize)
            if success then
                print("OK Loaded system font: " .. fontPath)
                _G.CHINESE_FONT_PATH = fontPath -- Store path globally
                return font
            end
        end
    end

    -- Last resort - default font
    print("WARNING Using default font as fallback")
    return love.graphics.newFont(fontSize)
end

function createFallbackFont(size)
    -- Create a simple bitmap font for Chinese characters
    -- This is a simplified approach - in a real game you'd want a proper font file

    -- For now, just use the default font and hope macOS handles it
    local font = love.graphics.newFont(size)

    -- Test if Chinese characters work
    local testWidth = font:getWidth("測")
    if testWidth > 0 then
        print("Default font supports Chinese characters")
        return font
    else
        print("Default font does not support Chinese - using ASCII fallback")
        return font -- Still return it, we'll handle display differently
    end
end

-- Helper function to safely print Chinese text
function printChinese(text, x, y, limit, align)
    local font = love.graphics.getFont()

    -- Test if the font can render Chinese characters
    local testChar = "測"
    local testWidth = font:getWidth(testChar)
    local defaultWidth = font:getWidth("?") -- Width of replacement character

    -- If Chinese character has different width than replacement, font supports it
    if testWidth > 0 and testWidth ~= defaultWidth then
        -- Font supports Chinese - render original text
        love.graphics.printf(text, x, y, limit or 800, align or "left")
        return true
    else
        -- Font doesn't support Chinese - show romanized version
        local romanized = romanizeChinese(text)
        love.graphics.printf(romanized, x, y, limit or 800, align or "left")
        return false
    end
end

-- Simple romanization fallback
function romanizeChinese(text)
    local translations = {
        ["外賣仔"] = "Delivery Boy",
        ["開始遊戲"] = "START GAME",
        ["繼續遊戲"] = "CONTINUE",
        ["你係一個住劏房嘅外賣仔"] = "You are a delivery boy in a tiny flat",
        ["想用各種方法搵快錢"] = "Trying to get rich through various methods",
        ["點擊開始你嘅遊戲之旅！"] = "Click to start your journey!",

        -- Descriptions
        ["開始你嘅計劃"] = "Start your plan",
    }

    return translations[text] or text
end

function love.update(dt)
    -- Hot reload support
    lick.update(dt)

    -- Update juice system
    Juice.update(dt)
    
    -- Update cut-in dialogue system
    CutinDialogue.update(dt)

    -- Apply passive relic effects each frame
    if gameState.playerRelics then
        HKRelics.applyPassiveEffects(gameState)
    end

    -- Legacy battle system removed
    -- if gameState.screen == "battle" then
    --     Battle.update(dt)
    -- els
    if gameState.screen == "mahjong_battle" then
        MahjongBattle.update(dt)
    elseif gameState.screen == "progression" then
        ProgressionScreen.update(dt)
    elseif gameState.screen == "event" then
        EventScreen.update(dt)
    elseif gameState.screen == "challenge" then
        local Challenge = require("challenge")
        Challenge.update(dt)
    elseif gameState.screen == "scene" then
        local Scene = require("scene")
        Scene.update(dt)
    elseif gameState.screen == "deck_modifier" then
        DeckModifierScreen.update(dt)
    end
end

function love.draw()
    -- Set background color (Hong Kong neon theme)
    love.graphics.setBackgroundColor(0.1, 0.1, 0.18) -- #1a1a2e

    -- Apply screen effects
    Juice.applyScreenEffects()

    if gameState.screen == "menu" then
        drawMenu()
    elseif gameState.screen == "developer_menu" then
        drawDeveloperMenu()
    elseif gameState.screen == "music_test_menu" then
        drawMusicTestMenu()
    elseif gameState.screen == "scene_test_menu" then
        drawSceneTestMenu()
    elseif gameState.screen == "cutin_test_menu" then
        drawCutinTestMenu()
    elseif gameState.screen == "progression" then
        ProgressionScreen.draw(gameState)
    -- Legacy battle system removed
    -- elseif gameState.screen == "battle" then
    --     Battle.draw(gameState)
    elseif gameState.screen == "mahjong_battle" then
        MahjongBattle.draw(gameState)
    elseif gameState.screen == "event" then
        EventScreen.draw(gameState)
    elseif gameState.screen == "challenge" then
        local Challenge = require("challenge")
        Challenge.draw(gameState)
    elseif gameState.screen == "shop" then
        Shop.draw(gameState)
    elseif gameState.screen == "scene" then
        local Scene = require("scene")
        Scene.draw()
    elseif gameState.screen == "deck_modifier" then
        DeckModifierScreen.draw(gameState)
    elseif gameState.screen == "snake" then
        drawSnake()
    elseif gameState.screen == "tetris" then
        drawTetris()
    end

    -- Draw juice effects
    Juice.draw()
    
    -- Draw cut-in dialogue (always on top)
    CutinDialogue.draw()

    -- Draw progression UI
    drawProgressionUI()

    -- Remove screen effects
    Juice.removeScreenEffects()
end

function drawMenu()
    local currentTime = love.timer.getTime()

    -- Update cached elements only every 5 seconds to prevent flashing
    if not menuCache.motivation or currentTime - menuCache.lastUpdate > 5 then
        menuCache.motivation = HKFlavor.getRandomMotivation()
        menuCache.greeting, menuCache.greetingEmoji = HKFlavor.getTimeGreeting()
        menuCache.weather, menuCache.weatherEmoji, menuCache.weatherColor = HKFlavor.getWeatherMood()
        menuCache.lastUpdate = currentTime
    end

    -- Animated title with neon glow
    love.graphics.push()
    love.graphics.translate(400, 100)
    local time = love.timer.getTime()
    local glow = 0.7 + 0.3 * math.sin(time * 3)
    love.graphics.scale(1 + 0.05 * math.sin(time * 2))

    -- Neon glow effect
    love.graphics.setColor(0, 1, 1, glow * 0.3)
    love.graphics.printf("可以冇錢但係唔可以窮", -200, -5, 400, "center")
    love.graphics.printf("可以冇錢但係唔可以窮", -200, 5, 400, "center")

    -- Main title
    love.graphics.setColor(1, 0.42, 0.42)
    love.graphics.printf("可以冇錢但係唔可以窮", -200, 0, 400, "center")
    love.graphics.pop()

    love.graphics.setColor(1, 0.9, 0.43)
    love.graphics.printf("住劏房外賣仔嘅發達記", 0, 180, SCREEN_WIDTH, "center")

    -- Dynamic greeting (cached)
    if menuCache.weatherColor then
        love.graphics.setColor(menuCache.weatherColor.r, menuCache.weatherColor.g, menuCache.weatherColor.b)
        love.graphics.printf((menuCache.greeting or "歡迎！"), 0, 210, SCREEN_WIDTH, "center")
        love.graphics.printf((menuCache.weather or "好天氣"), 0, 230, SCREEN_WIDTH, "center")
    end

    -- Enhanced description
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("你係一個住劏房嘅外賣仔", 0, 260, SCREEN_WIDTH, "center")
    love.graphics.printf("要用各種方法搞快錢翻身", 0, 280, SCREEN_WIDTH, "center")
    love.graphics.printf("善用麻雀技巧同街頭智慧生存！", 0, 300, SCREEN_WIDTH, "center")

    -- Money display
    love.graphics.setColor(0, 1, 0)
    love.graphics.printf("銀紙: " .. HKFlavor.formatMoney(gameState.playerMoney), 0, 330, SCREEN_WIDTH, "center")

    -- Interactive buttons with hover effects
    local mouseX, mouseY = love.mouse.getPosition()
    local startHovered = mouseX >= 300 and mouseX <= 500 and mouseY >= 380 and mouseY <= 430
    local continueHovered = mouseX >= 300 and mouseX <= 500 and mouseY >= 450 and mouseY <= 490

    -- Play hover sounds when entering buttons
    if startHovered and not hoverState.startButton then
        Music.playSFX("ui_hover")
        hoverState.startButton = true
    elseif not startHovered and hoverState.startButton then
        hoverState.startButton = false
    end

    if continueHovered and not hoverState.continueButton then
        Music.playSFX("ui_hover")
        hoverState.continueButton = true
    elseif not continueHovered and hoverState.continueButton then
        hoverState.continueButton = false
    end

    -- Start button with juice
    Juice.drawButton("》開始遊戲《", 300, 380, 200, 50, startHovered, false)

    -- Continue button with juice
    Juice.drawButton("》繼續遊戲《", 300, 450, 200, 40, continueHovered, false)

    -- Motivational quote (cached to prevent flashing)
    love.graphics.setColor(1, 0.84, 0)
    love.graphics.printf("\"" .. (menuCache.motivation or "做人冇夢想同條鹹魚有咩分別!") .. "\"", 50, 520, SCREEN_WIDTH - 100, "center")

    -- Credits
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.printf("用心喺香港製作", 0, 560, SCREEN_WIDTH, "center")
end

function drawDeveloperMenu()
    -- Semi-transparent background
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)

    -- Developer menu title
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.printf("DEVELOPER MENU", 0, 150, SCREEN_WIDTH, "center")

    -- Instructions
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Press ESC to close", 0, 180, SCREEN_WIDTH, "center")

    -- Interactive buttons
    local mouseX, mouseY = love.mouse.getPosition()
    local musicTestHovered = mouseX >= 300 and mouseX <= 500 and mouseY >= 250 and mouseY <= 300
    local sceneTestHovered = mouseX >= 300 and mouseX <= 500 and mouseY >= 320 and mouseY <= 370
    local cutinTestHovered = mouseX >= 300 and mouseX <= 500 and mouseY >= 390 and mouseY <= 440
    local closeHovered = mouseX >= 300 and mouseX <= 500 and mouseY >= 460 and mouseY <= 510

    -- Test Music button
    Juice.drawButton("Test Music System", 300, 250, 200, 50, musicTestHovered, false)

    -- Test Scene button
    Juice.drawButton("Test Scene System", 300, 320, 200, 50, sceneTestHovered, false)

    -- Test Cut-in Dialogue button
    Juice.drawButton("Test Cut-in Dialogues", 300, 390, 200, 50, cutinTestHovered, false)

    -- Close button
    Juice.drawButton("Close Menu", 300, 460, 200, 50, closeHovered, false)

    -- Konami code hint (subtle)
    love.graphics.setColor(0.4, 0.4, 0.4)
    love.graphics.printf("↑↑↓↓←→D to access", 0, 500, SCREEN_WIDTH, "center")
end

function handleDeveloperMenuClick(x, y)
    -- Music test button
    if x >= 300 and x <= 500 and y >= 250 and y <= 300 then
        Music.playSFX("ui_click")
        Juice.burst(400, 275, { 1, 0.8, 0.2 }, 6)
        testMusic()
    -- Scene test button
    elseif x >= 300 and x <= 500 and y >= 320 and y <= 370 then
        Music.playSFX("ui_click")
        Juice.burst(400, 345, { 0.8, 0.2, 1 }, 6)
        testScene()
    -- Cut-in test button
    elseif x >= 300 and x <= 500 and y >= 390 and y <= 440 then
        Music.playSFX("ui_click")
        Juice.burst(400, 415, { 0.2, 1, 0.8 }, 6)
        testCutinDialogues()
    -- Close button
    elseif x >= 300 and x <= 500 and y >= 460 and y <= 510 then
        Music.playSFX("ui_click")
        Juice.burst(400, 485, { 0.8, 0.8, 0.8 }, 6)
        developerMenuActive = false
        gameState.screen = previousScreen -- Return to previous screen
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then -- Left click
        print("Mouse pressed at:", x, y, "Screen:", gameState.screen)

        if gameState.screen == "menu" then
            -- Start button
            if x >= 300 and x <= 500 and y >= 380 and y <= 430 then
                Music.playSFX("ui_click")
                Juice.shake(3)
                Juice.burst(400, 405, { 0.15, 0.68, 0.38 }, 8)
                startNewGame()
                -- Load button
            elseif x >= 300 and x <= 500 and y >= 450 and y <= 490 then
                Music.playSFX("ui_click")
                Juice.burst(400, 470, { 0.2, 0.6, 0.86 }, 8)
                loadGame()
            end
        elseif gameState.screen == "developer_menu" then
            -- Developer menu button handling
            handleDeveloperMenuClick(x, y)
        elseif gameState.screen == "cutin_test_menu" then
            -- Cut-in test menu button handling
            handleCutinTestMenuClick(x, y)
        elseif gameState.screen == "progression" then
            pcall(function() ProgressionScreen.mousepressed(x, y, button, gameState) end)
        -- Legacy battle system removed
        -- elseif gameState.screen == "battle" then
        --     pcall(function() Battle.mousepressed(x, y, gameState) end)
        elseif gameState.screen == "mahjong_battle" then
            pcall(function() MahjongBattle.mousepressed(x, y, button) end)
        elseif gameState.screen == "event" then
            pcall(function() EventScreen.mousepressed(x, y, button, gameState) end)
        elseif gameState.screen == "challenge" then
            local Challenge = require("challenge")
            pcall(function() Challenge.mousepressed(x, y, gameState) end)
        elseif gameState.screen == "shop" then
            pcall(function() Shop.mousepressed(x, y, gameState) end)
        elseif gameState.screen == "scene" then
            local Scene = require("scene")
            pcall(function() Scene.mousepressed(x, y, button) end)
        elseif gameState.screen == "deck_modifier" then
            pcall(function() DeckModifierScreen.mousepressed(x, y) end)
        end
    end
end

function drawProgressionUI()
    -- Simple player stats in top corner
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.printf("銀紙: " .. HKFlavor.formatMoney(gameState.playerMoney), 20, 20, 200, "left")

    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function love.mousereleased(x, y, button)
    if button == 1 then -- Left click release
        print("Mouse released at:", x, y)
        -- Legacy battle system removed
        -- if gameState.screen == "battle" then
        --     pcall(function() Battle.mousereleased(x, y, gameState) end)
        -- els
        if gameState.screen == "mahjong_battle" then
            pcall(function() MahjongBattle.mousereleased(x, y, button) end)
        end
    end
end

function love.mousemoved(x, y, dx, dy)
    if gameState.screen == "menu" then
        -- Handle menu hover sounds (already handled in drawMenu function)
    -- Legacy battle system removed
    -- elseif gameState.screen == "battle" then
    --     pcall(function() Battle.mousemoved(x, y, dx, dy) end)
    elseif gameState.screen == "mahjong_battle" then
        pcall(function() MahjongBattle.mousemoved(x, y, dx, dy) end)
    elseif gameState.screen == "progression" then
        pcall(function() ProgressionScreen.mousemoved(x, y) end)
    elseif gameState.screen == "scene" then
        pcall(function() Scene.mousemoved(x, y) end)
    end
end

function startNewGame()
    gameState.playerMoney = 100
    gameState.playerDeck = Card.getStarterDeck()
    gameState.runDepth = 1
    gameState.level = 1
    gameState.xp = 0
    gameState.storyProgress = 0

    -- Initialize Hong Kong systems
    gameState.playerMemeCards = {}
    gameState.playerRelics = {}
    gameState.playerConsumables = {} -- Start with no consumables
    gameState.reputation = 0
    gameState.friendCount = 3
    gameState.streetCredibility = 0

    Progression.loadNextElement(gameState)

    print("開始新遊戲")
end

function loadGame()
    -- Try to load saved game, otherwise start new
    local saveData = loadGameData()
    if saveData then
        gameState.playerMoney = saveData.money or 100
        gameState.playerDeck = saveData.deck or Card.getStarterDeck()
        gameState.playerPosition = saveData.position or { x = 1, y = 1 }
        gameState.screen = "progression"
        -- Initialize progression screen
        ProgressionScreen.init(gameState)
    else
        startNewGame()
    end
end

-- Music testing system (global state)
local musicTestData = {
    availableTracks = {},
    filteredTracks = {},
    searchText = "",
    selectedIndex = 1,
    showMusicMenu = false
}

function testMusic()
    print("Opening music testing menu...")
    local Music = require("music")

    -- Initialize music system if not already done
    Music.init()

    -- Get available music tracks
    musicTestData.availableTracks = discoverAvailableMusicTracks()
    musicTestData.filteredTracks = musicTestData.availableTracks
    musicTestData.searchText = ""
    musicTestData.selectedIndex = 1
    musicTestData.showMusicMenu = true

    if #musicTestData.availableTracks == 0 then
        print("No music tracks found. Please add audio files to music/ directory.")
        return
    end

    print("Found " .. #musicTestData.availableTracks .. " music tracks to test")
    gameState.screen = "music_test_menu"
end

function discoverAvailableMusicTracks()
    local Music = require("music")
    local tracks = {}

    -- Get all available tracks from music system
    if Music.getAvailableTracks then
        local availableTracks = Music.getAvailableTracks()
        for trackName, trackInfo in pairs(availableTracks) do
            table.insert(tracks, {
                name = trackName,
                path = trackInfo.path or "unknown",
                available = trackInfo.available or false
            })
        end
    else
        -- Fallback: try to discover tracks manually with proper mapping
        local musicFolders = {
            { path = "music/bgm/menu/", prefix = "" },
            { path = "music/bgm/story/", prefix = "story_" },
            { path = "music/bgm/battle/", prefix = "battle_" },
            { path = "music/bgm/map/", prefix = "map_" },
            { path = "music/bgm/era/", prefix = "era_" },
            { path = "music/bgm/shop/", prefix = "shop_" },
            { path = "music/dummy/", prefix = "dummy_" }
        }

        -- File name to track name mapping
        local fileToTrackMapping = {
            ["menu"] = "menu",
            ["sad_moment"] = "story_sad",
            ["hopeful_theme"] = "story_hopeful",
            ["tension_building"] = "story_tense",
            ["dramatic_moment"] = "story_dramatic",
            ["chapter_ending"] = "story_ending",
            ["intense_battle"] = "battle",
            ["boss_battle"] = "battle_boss",
            ["hong_kong_streets"] = "map",
            ["sham_shui_po"] = "map_sham_shui_po",
            ["central_district"] = "map_central",
            ["manufacturing_boom"] = "era_1990s",
            ["property_frenzy"] = "era_2000s",
            ["digital_age"] = "era_2010s",
            ["robot_wizard_encounter"] = "robot_wizard",
            ["tea_restaurant"] = "shop",
            ["test_bgm"] = "dummy_bgm"
        }

        for _, folderInfo in ipairs(musicFolders) do
            local folder = folderInfo.path
            local prefix = folderInfo.prefix

            if love.filesystem.getInfo(folder, "directory") then
                local files = love.filesystem.getDirectoryItems(folder)
                for _, file in ipairs(files) do
                    local extension = file:match("%.([^%.]+)$")
                    if extension and (extension:lower() == "mp3" or extension:lower() == "ogg" or extension:lower() == "wav") then
                        local fileName = file:match("([^%.]+)")
                        local trackName = fileToTrackMapping[fileName] or (prefix .. fileName)

                        -- Check if the track actually exists in the music system
                        local available = false
                        if Music.playBGM then
                            -- Try to preload to check availability
                            local success = pcall(function() Music.playBGM(trackName) end)
                            if success then
                                available = true
                                Music.stopBGM() -- Stop immediately after testing
                            end
                        end

                        table.insert(tracks, {
                            name = trackName,
                            fileName = fileName,
                            path = folder .. file,
                            available = available
                        })
                    end
                end
            end
        end
    end

    -- Sort tracks by name
    table.sort(tracks, function(a, b) return a.name < b.name end)
    return tracks
end

function drawMusicTestMenu()
    -- Semi-transparent background
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)

    -- Music test menu title
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.printf("MUSIC TESTING MENU", 0, 50, SCREEN_WIDTH, "center")

    -- Instructions
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Type to search tracks, ENTER to play, ESC to close", 0, 80, SCREEN_WIDTH, "center")

    -- Search box
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 200, 110, 400, 30)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 200, 110, 400, 30)

    local searchDisplay = musicTestData.searchText
    if searchDisplay == "" then
        love.graphics.setColor(0.6, 0.6, 0.6)
        searchDisplay = "Search music tracks..."
    else
        love.graphics.setColor(1, 1, 1)
    end
    love.graphics.printf(searchDisplay, 210, 120, 380, "left")

    -- Music track list
    local startY = 160
    local itemHeight = 25
    local maxVisible = 12

    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", 150, startY, 500, maxVisible * itemHeight)
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.rectangle("line", 150, startY, 500, maxVisible * itemHeight)

    -- Display filtered tracks
    local displayStart = math.max(1, musicTestData.selectedIndex - maxVisible + 1)
    local displayEnd = math.min(#musicTestData.filteredTracks, displayStart + maxVisible - 1)

    for i = displayStart, displayEnd do
        local track = musicTestData.filteredTracks[i]
        local y = startY + (i - displayStart) * itemHeight

        if i == musicTestData.selectedIndex then
            -- Highlight selected item
            love.graphics.setColor(0.2, 0.5, 0.8, 0.7)
            love.graphics.rectangle("fill", 150, y, 500, itemHeight)
        end

        -- Track name
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(track.name, 160, y + 5, 300, "left")

        -- Availability indicator
        if track.available then
            love.graphics.setColor(0, 1, 0)
            love.graphics.printf("OK", 470, y + 5, 30, "center")
        else
            love.graphics.setColor(1, 0, 0)
            love.graphics.printf("NO", 470, y + 5, 30, "center")
        end
    end

    -- Scroll indicator
    if #musicTestData.filteredTracks > maxVisible then
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.printf("↑↓ Scroll", 150, startY + maxVisible * itemHeight + 5, 500, "center")
    end

    -- Track count
    love.graphics.setColor(0.7, 0.7, 0.7)
    local countText = string.format("Showing %d of %d tracks", #musicTestData.filteredTracks, #musicTestData.availableTracks)
    love.graphics.printf(countText, 0, startY + maxVisible * itemHeight + 30, SCREEN_WIDTH, "center")

    -- Controls
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.printf("↑↓ Navigate • ENTER Play • ESC Close • Type to search", 0, startY + maxVisible * itemHeight + 50, SCREEN_WIDTH, "center")
end

function handleMusicTestMenuKey(key)
    if key == "escape" then
        musicTestData.showMusicMenu = false
        gameState.screen = "developer_menu"
    elseif key == "return" or key == "kpenter" then
        -- Play selected track
        if #musicTestData.filteredTracks > 0 and musicTestData.selectedIndex >= 1 and musicTestData.selectedIndex <= #musicTestData.filteredTracks then
            local selectedTrack = musicTestData.filteredTracks[musicTestData.selectedIndex]
            playSelectedMusicTrack(selectedTrack)
        end
    elseif key == "up" then
        musicTestData.selectedIndex = math.max(1, musicTestData.selectedIndex - 1)
    elseif key == "down" then
        musicTestData.selectedIndex = math.min(#musicTestData.filteredTracks, musicTestData.selectedIndex + 1)
    elseif key == "backspace" then
        -- Handle backspace for search
        musicTestData.searchText = musicTestData.searchText:sub(1, -2)
        filterMusicTracks()
    elseif key:len() == 1 then
        -- Add character to search
        musicTestData.searchText = musicTestData.searchText .. key:lower()
        filterMusicTracks()
    end
end

function filterMusicTracks()
    if musicTestData.searchText == "" then
        musicTestData.filteredTracks = musicTestData.availableTracks
    else
        musicTestData.filteredTracks = {}
        for _, track in ipairs(musicTestData.availableTracks) do
            if string.find(track.name:lower(), musicTestData.searchText, 1, true) then
                table.insert(musicTestData.filteredTracks, track)
            end
        end
    end

    -- Reset selection if it's out of bounds
    musicTestData.selectedIndex = math.min(musicTestData.selectedIndex, #musicTestData.filteredTracks)
    if musicTestData.selectedIndex < 1 and #musicTestData.filteredTracks > 0 then
        musicTestData.selectedIndex = 1
    end
end

function playSelectedMusicTrack(track)
    print("Playing music track: " .. track.name)
    local Music = require("music")

    -- Stop any currently playing music
    Music.stopBGM()

    -- Try to play the selected track
    if track.available then
        Music.playBGM(track.name)
        print("OK Started playing: " .. track.name)
    else
        print("NO Track not available: " .. track.name .. " (" .. track.path .. ")")
    end
end

-- Scene testing system (global state)
local sceneTestData = {
    availableScenes = {},
    filteredScenes = {},
    searchText = "",
    selectedIndex = 1,
    showSceneMenu = false
}

function testScene()
    print("Opening scene testing menu...")

    -- Discover all available scenes
    sceneTestData.availableScenes = discoverAvailableScenes()
    sceneTestData.filteredScenes = sceneTestData.availableScenes
    sceneTestData.searchText = ""
    sceneTestData.selectedIndex = 1
    sceneTestData.showSceneMenu = true

    if #sceneTestData.availableScenes == 0 then
        print("No test scenes found. Please add scene images to scenes/ folder.")
        print("Expected folders: scenes/intro/, scenes/level1_to_level2/, etc.")
        print("Add .png or .jpg files to these folders to test the scene system.")
        return
    end

    print("Found " .. #sceneTestData.availableScenes .. " scenes to test")
    gameState.screen = "scene_test_menu"
end

function drawSceneTestMenu()
    -- Semi-transparent background
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)

    -- Scene test menu title
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.printf("SCENE TESTING MENU", 0, 50, SCREEN_WIDTH, "center")

    -- Instructions
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Type to search scenes, ENTER to play, ESC to close", 0, 80, SCREEN_WIDTH, "center")

    -- Search box
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 200, 110, 400, 30)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 200, 110, 400, 30)

    local searchDisplay = sceneTestData.searchText
    if searchDisplay == "" then
        love.graphics.setColor(0.6, 0.6, 0.6)
        searchDisplay = "Search scenes..."
    else
        love.graphics.setColor(1, 1, 1)
    end
    love.graphics.printf(searchDisplay, 210, 120, 380, "left")

    -- Scene list
    local startY = 160
    local itemHeight = 25
    local maxVisible = 12

    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", 150, startY, 500, maxVisible * itemHeight)
    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.rectangle("line", 150, startY, 500, maxVisible * itemHeight)

    -- Display filtered scenes
    local displayStart = math.max(1, sceneTestData.selectedIndex - maxVisible + 1)
    local displayEnd = math.min(#sceneTestData.filteredScenes, displayStart + maxVisible - 1)

    for i = displayStart, displayEnd do
        local sceneName = sceneTestData.filteredScenes[i]
        local y = startY + (i - displayStart) * itemHeight

        if i == sceneTestData.selectedIndex then
            -- Highlight selected item
            love.graphics.setColor(0.2, 0.5, 0.8, 0.7)
            love.graphics.rectangle("fill", 150, y, 500, itemHeight)
        end

        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(sceneName, 160, y + 5, 480, "left")
    end

    -- Scroll indicator
    if #sceneTestData.filteredScenes > maxVisible then
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.printf("↑↓ Scroll", 150, startY + maxVisible * itemHeight + 5, 500, "center")
    end

    -- Scene count
    love.graphics.setColor(0.7, 0.7, 0.7)
    local countText = string.format("Showing %d of %d scenes", #sceneTestData.filteredScenes, #sceneTestData.availableScenes)
    love.graphics.printf(countText, 0, startY + maxVisible * itemHeight + 30, SCREEN_WIDTH, "center")

    -- Controls
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.printf("↑↓ Navigate • ENTER Play • ESC Close • Type to search", 0, startY + maxVisible * itemHeight + 50, SCREEN_WIDTH, "center")
end

function handleSceneTestMenuKey(key)
    if key == "escape" then
        sceneTestData.showSceneMenu = false
        gameState.screen = "developer_menu"
    elseif key == "return" or key == "kpenter" then
        -- Play selected scene
        if #sceneTestData.filteredScenes > 0 and sceneTestData.selectedIndex >= 1 and sceneTestData.selectedIndex <= #sceneTestData.filteredScenes then
            local selectedScene = sceneTestData.filteredScenes[sceneTestData.selectedIndex]
            playSelectedScene(selectedScene)
        end
    elseif key == "up" then
        sceneTestData.selectedIndex = math.max(1, sceneTestData.selectedIndex - 1)
    elseif key == "down" then
        sceneTestData.selectedIndex = math.min(#sceneTestData.filteredScenes, sceneTestData.selectedIndex + 1)
    elseif key == "backspace" then
        -- Handle backspace for search
        sceneTestData.searchText = sceneTestData.searchText:sub(1, -2)
        filterScenes()
    elseif key:len() == 1 then
        -- Add character to search
        sceneTestData.searchText = sceneTestData.searchText .. key:lower()
        filterScenes()
    end
end

function filterScenes()
    if sceneTestData.searchText == "" then
        sceneTestData.filteredScenes = sceneTestData.availableScenes
    else
        sceneTestData.filteredScenes = {}
        for _, sceneName in ipairs(sceneTestData.availableScenes) do
            if string.find(sceneName:lower(), sceneTestData.searchText, 1, true) then
                table.insert(sceneTestData.filteredScenes, sceneName)
            end
        end
    end

    -- Reset selection if it's out of bounds
    sceneTestData.selectedIndex = math.min(sceneTestData.selectedIndex, #sceneTestData.filteredScenes)
    if sceneTestData.selectedIndex < 1 and #sceneTestData.filteredScenes > 0 then
        sceneTestData.selectedIndex = 1
    end
end

function playSelectedScene(sceneName)
    print("Playing scene: " .. sceneName)
    local Scene = require("scene")

    -- Set up scene callbacks for single scene mode
    Scene.onSceneComplete = function(completedSceneName)
        print("Scene completed: " .. completedSceneName)
        gameState.screen = "scene_test_menu" -- Return to scene menu
    end

    Scene.onSceneExit = function()
        print("Scene exited (ESC pressed)")
        gameState.screen = "scene_test_menu" -- Return to scene menu
    end

    -- Load the selected scene
    if Scene.loadScene(sceneName) then
        print("Starting scene: " .. sceneName)
        gameState.screen = "scene"
    else
        print("Failed to load scene: " .. sceneName)
        gameState.screen = "scene_test_menu"
    end
end

function discoverAvailableScenes()
    local availableScenes = {}

    -- Get all folders in scenes directory
    local scenesFolders = love.filesystem.getDirectoryItems("scenes")

    -- Priority order (newest/most important first)
    -- Only include scenes that actually exist in the scenes/ directory
    local priorityScenes = {
        "intro",            -- Game start
        "level1_to_level2", -- Level 1 to Level 2 transition
        "level2_mid",       -- Level 2 middle scene
        "level2_to_level3", -- Level 2 to Level 3 transition
        "level3_mid",       -- Level 3 middle scene
        "level3_end",       -- Level 3 ending scene
        "level1_lose",      -- Level 1 lose scene
        "level2_lose1",     -- Level 2 lose scene 1
        "level2_lose2",     -- Level 2 lose scene 2
        "level3_lose"       -- Level 3 lose scene
    }

    -- Add priority scenes first (if they exist and have images)
    for _, sceneName in ipairs(priorityScenes) do
        if love.filesystem.getInfo("scenes/" .. sceneName, "directory") then
            if sceneHasImages(sceneName) then
                table.insert(availableScenes, sceneName)
                print("OK Found priority scene: " .. sceneName)
            end
        end
    end

    -- Add any other scenes not in priority list
    for _, folder in ipairs(scenesFolders) do
        local isDirectory = love.filesystem.getInfo("scenes/" .. folder, "directory")
        if isDirectory and folder ~= ".DS_Store" then
            -- Check if this scene is not already in our list
            local alreadyAdded = false
            for _, existingScene in ipairs(availableScenes) do
                if existingScene == folder then
                    alreadyAdded = true
                    break
                end
            end

            -- Add if not already added and has images
            if not alreadyAdded and sceneHasImages(folder) then
                table.insert(availableScenes, folder)
                print("OK Found additional scene: " .. folder)
            end
        end
    end

    return availableScenes
end

function sceneHasImages(sceneName)
    local sceneFolder = "scenes/" .. sceneName
    local files = love.filesystem.getDirectoryItems(sceneFolder)

    -- Check if folder contains any image files
    for _, file in ipairs(files) do
        local extension = file:match("%.([^%.]+)$")
        if extension and (extension:lower() == "png" or extension:lower() == "jpg" or extension:lower() == "jpeg") then
            return true
        end
    end

    return false
end

function saveGameData()
    local saveData = {
        money = gameState.playerMoney,
        deck = gameState.playerDeck,
        position = gameState.playerPosition
    }

    local success = love.filesystem.write("save.lua", "return " .. serialize(saveData))
    if success then
        print("Game saved successfully")
    else
        print("Failed to save game")
    end
end

function loadGameData()
    if love.filesystem.getInfo("save.lua") then
        local chunk = love.filesystem.load("save.lua")
        if chunk then
            return chunk()
        end
    end
    return nil
end

function serialize(t)
    local result = "{"
    for k, v in pairs(t) do
        if type(k) == "string" then
            result = result .. k .. "="
        else
            result = result .. "[" .. k .. "]="
        end

        if type(v) == "table" then
            result = result .. serialize(v)
        elseif type(v) == "string" then
            result = result .. '"' .. v .. '"'
        else
            result = result .. tostring(v)
        end
        result = result .. ","
    end
    result = result .. "}"
    return result
end

-- Global functions for other modules
function getGameState()
    return gameState
end

function setGameScreen(screen)
    print("電幕由", gameState.screen, "更改為", screen)
    gameState.screen = screen
    print("電幕現在是:", gameState.screen)
end

function checkKonamiCode(key)
    -- Map keys to Konami code format
    local keyMap = {
        ["up"] = "up",
        ["down"] = "down",
        ["left"] = "left",
        ["right"] = "right",
        ["d"] = "d",
        ["w"] = "w",
        ["m"] = "m"
    }

    local mappedKey = keyMap[key]
    if not mappedKey then
        -- Reset sequence if invalid key pressed
        keySequence = {}
        return
    end

    -- Add key to sequence
    table.insert(keySequence, mappedKey)

    -- Keep sequence within max length
    if #keySequence > maxSequenceLength then
        table.remove(keySequence, 1)
    end

    -- Check if sequence matches developer menu Konami code
    if #keySequence == #konamiCode then
        local matches = true
        for i = 1, #konamiCode do
            if keySequence[i] ~= konamiCode[i] then
                matches = false
                break
            end
        end

        if matches then
            print("KONAMI CODE ACTIVATED! (Developer Menu)")
            Music.playSFX("ui_click")
            Juice.shake(5)
            Juice.burst(400, 300, { 1, 0.2, 0.2 }, 12)
            developerMenuActive = true
            previousScreen = gameState.screen -- Store current screen before switching
            gameState.screen = "developer_menu"
            keySequence = {} -- Reset sequence
            return
        end
    end

    -- Check if sequence matches win game Konami code
    if #keySequence == #konamiWinCode then
        local matches = true
        for i = 1, #konamiWinCode do
            if keySequence[i] ~= konamiWinCode[i] then
                matches = false
                break
            end
        end

        if matches then
            print("KONAMI WIN CODE ACTIVATED!")
            Music.playSFX("ui_click")
            Juice.shake(8)
            Juice.burst(400, 300, { 0, 1, 0 }, 15)

            -- Win the current game based on screen
            if gameState.screen == "mahjong_battle" then
                -- Force win the mahjong battle
                if MahjongBattle.forceWin then
                    MahjongBattle.forceWin()
                    print("FORCE WIN ACTIVATED!")
                else
                    print("Mahjong battle win not implemented yet")
                end
            else
                print("Win code only works during battle!")
            end

            keySequence = {} -- Reset sequence
        end
    end

    -- Check if sequence matches money Konami code
    if #keySequence == #konamiMoneyCode then
        local matches = true
        for i = 1, #konamiMoneyCode do
            if keySequence[i] ~= konamiMoneyCode[i] then
                matches = false
                break
            end
        end

        if matches then
            print("KONAMI MONEY CODE ACTIVATED! (+$1000)")
            Music.playSFX("ui_click")
            Juice.shake(6)
            Juice.burst(400, 300, { 1, 1, 0 }, 10)

            -- Add $1000 to player money
            gameState.playerMoney = (gameState.playerMoney or 0) + 1000
            print("💰 Money added! Total: $" .. gameState.playerMoney)

            keySequence = {} -- Reset sequence
        end
    end
end

function love.keypressed(key)
    -- Hot reload support
    lick.keypressed(key)

    -- Handle ESC key for developer menu
    if key == "escape" then
        if gameState.screen == "developer_menu" then
            developerMenuActive = false
            gameState.screen = previousScreen -- Return to previous screen
            return
        end
    end

    -- Konami code detection (available during gameplay)
    checkKonamiCode(key)

    -- Game-specific key handling
    if gameState.screen == "mahjong_battle" then
        pcall(function() MahjongBattle.keypressed(key) end)
    elseif gameState.screen == "event" then
        pcall(function() EventScreen.keypressed(key) end)
    elseif gameState.screen == "scene" then
        local Scene = require("scene")
        pcall(function() Scene.keypressed(key) end)
    elseif gameState.screen == "music_test_menu" then
        handleMusicTestMenuKey(key)
    elseif gameState.screen == "scene_test_menu" then
        handleSceneTestMenuKey(key)
    elseif gameState.screen == "cutin_test_menu" then
        handleCutinTestMenuKey(key)
    end

    -- Global ESC to quit (only if not handled by specific screens)
    if key == "escape" then
        -- Don't quit if we're in screens that have their own ESC handling
        if gameState.screen == "mahjong_battle" or
           gameState.screen == "event" or
           gameState.screen == "scene" or
           gameState.screen == "developer_menu" or
           gameState.screen == "music_test_menu" or
           gameState.screen == "scene_test_menu" or
           gameState.screen == "cutin_test_menu" then
            -- These screens handle ESC themselves, don't quit
            return
        end

        -- For other screens (menu, progression, shop), ESC quits the game
        love.event.quit()
    end
end

-- Global accessor functions
function getGameState()
    return gameState
end

function setGameScreen(newScreen)
    gameState.screen = newScreen
end

function setEventData(eventData)
    EventScreen.init(eventData)
end

-- Cut-in dialogue test functions
function testCutinDialogues()
    print("Opening Cut-in Dialogue Test Menu...")
    gameState.screen = "cutin_test_menu"
    
    -- Initialize cut-in test data
    cutinTestData.searchTerm = ""
    cutinTestData.filteredDialogues = {}
    cutinTestData.selectedIndex = 1
    cutinTestData.isSearching = false
    
    -- Load all cut-in dialogues and flatten them
    local allCutins = CutinDialogue.getAllCutins()
    cutinTestData.allDialogues = {}
    
    if allCutins then
        for cutinId, cutinData in pairs(allCutins) do
            if cutinData.dialogues then
                for dialogueKey, dialogue in pairs(cutinData.dialogues) do
                    table.insert(cutinTestData.allDialogues, {
                        cutinId = cutinId,
                        dialogueKey = dialogueKey,
                        dialogue = dialogue,
                        cutinName = cutinData.name or cutinId
                    })
                end
            end
        end
    end
    
    -- Sort by cutin name, then dialogue key
    table.sort(cutinTestData.allDialogues, function(a, b)
        if a.cutinName == b.cutinName then
            return a.dialogueKey < b.dialogueKey
        end
        return a.cutinName < b.cutinName
    end)
    
    -- Initialize filtered list
    cutinTestData.filteredDialogues = cutinTestData.allDialogues
end

function drawCutinTestMenu()
    -- Background
    love.graphics.setColor(0.1, 0.1, 0.2, 0.95)
    love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
    
    -- Title
    love.graphics.setColor(0.31, 0.8, 0.77)
    love.graphics.printf("Cut-in Dialogue Tester", 0, 40, SCREEN_WIDTH, "center")
    
    -- Subtitle
    love.graphics.setColor(0.8, 0.8, 0.9)
    love.graphics.printf("Search and preview all cut-in dialogues", 0, 70, SCREEN_WIDTH, "center")
    
    -- Search box
    local searchX = 50
    local searchY = 100
    local searchW = 600
    local searchH = 40
    
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle("fill", searchX, searchY, searchW, searchH)
    love.graphics.setColor(0.31, 0.8, 0.77)
    love.graphics.rectangle("line", searchX, searchY, searchW, searchH)
    
    local searchText = cutinTestData.searchTerm == "" and "Search dialogues..." or cutinTestData.searchTerm
    love.graphics.setColor(cutinTestData.searchTerm == "" and 0.5 or 1, 1, 1)
    love.graphics.printf(searchText, searchX + 10, searchY + 10, searchW - 20, "left")
    
    -- Dialogue list
    local listX = 50
    local listY = 160
    local listW = 600
    local listH = 280 -- Reduced height to fit screen
    
    love.graphics.setColor(0.15, 0.15, 0.25)
    love.graphics.rectangle("fill", listX, listY, listW, listH)
    love.graphics.setColor(0.31, 0.8, 0.77)
    love.graphics.rectangle("line", listX, listY, listW, listH)
    
    -- Display filtered dialogues
    local itemHeight = 25
    local maxVisible = 10 -- Reduced to fit better
    local displayStart = math.max(1, cutinTestData.selectedIndex - maxVisible + 1)
    local displayEnd = math.min(#cutinTestData.filteredDialogues, displayStart + maxVisible - 1)
    
    for i = displayStart, displayEnd do
        local dialogue = cutinTestData.filteredDialogues[i]
        local y = listY + 10 + (i - displayStart) * itemHeight
        local isSelected = i == cutinTestData.selectedIndex
        
        if isSelected then
            love.graphics.setColor(0.31, 0.8, 0.77, 0.3)
            love.graphics.rectangle("fill", listX + 5, y - 2, listW - 10, itemHeight)
        end
        
        -- Dialogue info
        love.graphics.setColor(isSelected and 1 or 0.9, 1, isSelected and 1 or 0.9)
        
        -- Cut-in name
        love.graphics.printf(dialogue.cutinName, listX + 10, y, 120, "left")
        
        -- Dialogue key
        love.graphics.setColor(0.7, 0.7, 0.8)
        love.graphics.printf(dialogue.dialogueKey, listX + 140, y, 120, "left")
        
        -- Character name
        if dialogue.dialogue.character then
            love.graphics.setColor(0.6, 0.8, 1)
            love.graphics.printf(dialogue.dialogue.character, listX + 270, y, 100, "left")
        end
        
        -- Dialogue text preview
        local text = dialogue.dialogue.text or ""
        local preview = text
        if safeStringLength(text) > 30 then
            preview = safeSubstring(text, 1, 30) .. "..."
        end
        love.graphics.setColor(0.8, 0.8, 0.9)
        love.graphics.printf(preview, listX + 380, y, 220, "left")
    end
    
    -- Selected dialogue details
    if cutinTestData.selectedIndex > 0 and cutinTestData.selectedIndex <= #cutinTestData.filteredDialogues then
        local selectedDialogue = cutinTestData.filteredDialogues[cutinTestData.selectedIndex]
        local detailsX = 50
        local detailsY = 450 -- Moved up to fit screen
        local detailsW = 600
        local detailsH = 50 -- Reduced height
        
        love.graphics.setColor(0.2, 0.2, 0.3)
        love.graphics.rectangle("fill", detailsX, detailsY, detailsW, detailsH)
        love.graphics.setColor(0.31, 0.8, 0.77)
        love.graphics.rectangle("line", detailsX, detailsY, detailsW, detailsH)
        
        -- Full dialogue text (truncated if too long)
        love.graphics.setColor(1, 1, 1)
        local fullText = selectedDialogue.dialogue.text or "No text"
        if safeStringLength(fullText) > 80 then
            fullText = safeSubstring(fullText, 1, 80) .. "..."
        end
        love.graphics.printf("Text: " .. fullText, detailsX + 10, detailsY + 5, detailsW - 20, "left")
        
        -- Character info
        if selectedDialogue.dialogue.character then
            love.graphics.setColor(0.6, 0.8, 1)
            love.graphics.printf("Character: " .. selectedDialogue.dialogue.character, detailsX + 10, detailsY + 25, detailsW - 20, "left")
        end
    end
    
    -- Action buttons
    local mouseX, mouseY = love.mouse.getPosition()
    local buttonY = 510 -- Moved up to fit screen
    local buttonSpacing = 60
    
    -- Preview button
    local previewHovered = mouseX >= 50 and mouseX <= 250 and mouseY >= buttonY and mouseY <= buttonY + 50
    local canPreview = cutinTestData.selectedIndex > 0 and cutinTestData.selectedIndex <= #cutinTestData.filteredDialogues
    Juice.drawButton(canPreview and "Preview Dialogue" or "Select dialogue first", 50, buttonY, 200, 50, previewHovered and canPreview, false)
    
    -- Back button
    local backHovered = mouseX >= 270 and mouseX <= 470 and mouseY >= buttonY and mouseY <= buttonY + 50
    Juice.drawButton("Back to Dev Menu", 270, buttonY, 200, 50, backHovered, false)
    
    -- Instructions
    love.graphics.setColor(0.6, 0.6, 0.7)
    love.graphics.printf("Use arrow keys to navigate • Space to search • Enter to preview", 0, 570, SCREEN_WIDTH, "center")
end

function handleCutinTestMenuClick(x, y)
    -- Search box
    if x >= 50 and x <= 650 and y >= 100 and y <= 140 then
        cutinTestData.isSearching = true
        return
    end
    
    -- Dialogue list
    if x >= 50 and x <= 650 and y >= 160 and y <= 440 then
        local listIndex = math.floor((y - 170) / 25) + 1
        local displayStart = math.max(1, cutinTestData.selectedIndex - 10 + 1)
        local actualIndex = displayStart + listIndex - 1
        
        if actualIndex <= #cutinTestData.filteredDialogues then
            cutinTestData.selectedIndex = actualIndex
            Music.playSFX("ui_click")
        end
        return
    end
    
    -- Preview button
    if x >= 50 and x <= 250 and y >= 510 and y <= 560 then
        if cutinTestData.selectedIndex > 0 and cutinTestData.selectedIndex <= #cutinTestData.filteredDialogues then
            local selectedDialogue = cutinTestData.filteredDialogues[cutinTestData.selectedIndex]
            Music.playSFX("ui_click")
            Juice.burst(150, 535, { 0.31, 0.8, 0.77 }, 6)
            CutinDialogue.show(selectedDialogue.cutinId, selectedDialogue.dialogueKey)
        end
        return
    end
    
    -- Back button
    if x >= 270 and x <= 470 and y >= 510 and y <= 560 then
        Music.playSFX("ui_click")
        Juice.burst(370, 535, { 0.8, 0.8, 0.8 }, 6)
        gameState.screen = "developer_menu"
        return
    end
end

function handleCutinTestMenuKey(key)
    if key == "escape" then
        gameState.screen = "developer_menu"
        return
    end
    
    -- Search handling
    if cutinTestData.isSearching then
        if key == "return" or key == "escape" then
            cutinTestData.isSearching = false
            -- Perform search
            if cutinTestData.searchTerm ~= "" then
                cutinTestData.filteredDialogues = {}
                local searchTerm = cutinTestData.searchTerm:lower()
                for _, dialogue in ipairs(cutinTestData.allDialogues) do
                    local matches = false
                    -- Search in cut-in name
                    if dialogue.cutinName:lower():find(searchTerm) then
                        matches = true
                    end
                    -- Search in dialogue key
                    if dialogue.dialogueKey:lower():find(searchTerm) then
                        matches = true
                    end
                    -- Search in character name
                    if dialogue.dialogue.character and dialogue.dialogue.character:lower():find(searchTerm) then
                        matches = true
                    end
                    -- Search in dialogue text
                    if dialogue.dialogue.text and dialogue.dialogue.text:lower():find(searchTerm) then
                        matches = true
                    end
                    if matches then
                        table.insert(cutinTestData.filteredDialogues, dialogue)
                    end
                end
            else
                -- Reset to show all
                cutinTestData.filteredDialogues = cutinTestData.allDialogues
            end
            cutinTestData.selectedIndex = 1
        elseif key == "backspace" then
            cutinTestData.searchTerm = cutinTestData.searchTerm:sub(1, -2)
        elseif key:len() == 1 then
            cutinTestData.searchTerm = cutinTestData.searchTerm .. key
        end
        return
    end
    
    -- Navigation
    if key == "up" then
        if cutinTestData.selectedIndex > 1 then
            cutinTestData.selectedIndex = cutinTestData.selectedIndex - 1
            Music.playSFX("ui_hover")
        end
    elseif key == "down" then
        if cutinTestData.selectedIndex < #cutinTestData.filteredDialogues then
            cutinTestData.selectedIndex = cutinTestData.selectedIndex + 1
            Music.playSFX("ui_hover")
        end
    elseif key == "return" then
        -- Preview selected dialogue
        if cutinTestData.selectedIndex > 0 and cutinTestData.selectedIndex <= #cutinTestData.filteredDialogues then
            local selectedDialogue = cutinTestData.filteredDialogues[cutinTestData.selectedIndex]
            Music.playSFX("ui_click")
            CutinDialogue.show(selectedDialogue.cutinId, selectedDialogue.dialogueKey)
        end
    elseif key == "space" then
        -- Toggle search mode
        cutinTestData.isSearching = not cutinTestData.isSearching
        if not cutinTestData.isSearching then
            cutinTestData.searchTerm = ""
        end
    end
end

-- Return module table for require() calls
return {
    getGameState = getGameState,
    setGameScreen = setGameScreen,
    setEventData = setEventData
}


