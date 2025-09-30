-- Handles background music switching and sound effects

local Music = {}

-- Music state
local currentBGM = nil
local currentBGMName = ""
local musicVolume = 0.7
local sfxVolume = 0.8
local isMusicEnabled = true
local isSFXEnabled = true

-- Music tracks registry
local musicTracks = {
    -- Menu music
    menu = "music/bgm/menu/menu.mp3",

    -- Battle music
    battle = "music/bgm/battle/intense_battle.ogg",
    battle_boss = "music/bgm/battle/boss_battle.ogg",

    -- Map/exploration music
    map = "music/bgm/map/hong_kong_streets.ogg",
    map_sham_shui_po = "music/bgm/map/sham_shui_po.ogg",
    map_central = "music/bgm/map/central_district.ogg",

    -- Shop music
    shop = "music/bgm/shop/tea_restaurant.ogg",

    -- Story scene music
    story_intro = "music/bgm/menu/menu.mp3",
    story_dramatic = "music/bgm/story/dramatic_moment.ogg",
    story_ending = "music/bgm/story/chapter_ending.ogg",
    story_sad = "music/bgm/story/sad_moment.mp3",
    story_hopeful = "music/bgm/story/hopeful_theme.ogg",
    story_tense = "music/bgm/story/tension_building.ogg",

    -- Era-specific music
    era_1990s = "music/bgm/era/1990s/manufacturing_boom.ogg",
    era_2000s = "music/bgm/era/2000s/property_frenzy.ogg",
    era_2010s = "music/bgm/era/2010s/digital_age.ogg",

    -- Special music
    robot_wizard = "music/bgm/story/robot_wizard_encounter.ogg",

    -- Dummy/test files
    dummy_bgm = "music/dummy/test_bgm.ogg"
}

-- Sound effects registry
local soundEffects = {
    -- UI sounds
    ui_click = "music/sfx/ui/click.wav",
    ui_hover = "music/sfx/ui/hover.mp3",
    ui_error = "music/sfx/ui/error_sound.mp3",
    ui_success = "music/sfx/ui/success.wav",

    -- Card sounds
    card_play = "music/sfx/cards/card_play.ogg",
    card_draw = "music/sfx/cards/card_draw.ogg",
    card_shuffle = "music/sfx/cards/deck_shuffle.ogg",

    -- Battle sounds
    attack_hit = "music/sfx/battle/attack_impact.ogg",
    shield_block = "music/sfx/battle/shield_block.ogg",
    fortress_build = "music/sfx/battle/fortress_build.ogg",
    fortress_destroy = "music/sfx/battle/fortress_collapse.ogg",

    -- Ambient sounds
    hong_kong_street = "music/sfx/ambient/street_ambience.ogg",
    tea_restaurant = "music/sfx/ambient/tea_restaurant.ogg",

    -- Money/economy sounds
    money_gain = "music/sfx/ui/money_gain.ogg",
    money_loss = "music/sfx/ui/money_loss.ogg",
    purchase = "music/sfx/ui/purchase_sound.ogg",

    -- Dialogue sounds
    ui_type = "music/sfx/dialogue/typewriter.wav",
    sigh = "music/sfx/dialogue/sigh.ogg",
    gasp = "music/sfx/dialogue/gasp.ogg",
    laugh = "music/sfx/dialogue/laugh.ogg",
    ding = "music/sfx/dialogue/notification.wav"
}

-- Loaded audio sources cache
local loadedMusic = {}
local loadedSFX = {}

-- Initialize music system
function Music.init()
    print("Initializing Music System...")

    -- Create dummy test file if it doesn't exist
    Music.createDummyFiles()

    -- Try to load a test track
    Music.preloadTrack("dummy_bgm")

    print("Music System initialized")
end

-- Create dummy audio files for testing
function Music.createDummyFiles()
    -- Create dummy folder structure
    love.filesystem.createDirectory("music")
    love.filesystem.createDirectory("music/dummy")

    -- Note: We can't actually create audio files programmatically in LÖVE2D
    -- This is just to set up the folder structure
    -- You'll need to add actual audio files manually

    print("Created music folder structure")
    print("Please add audio files to the music/ directory")
end

-- Preload a music track
function Music.preloadTrack(trackName)
    if not musicTracks[trackName] then
        print("Warning: Unknown music track: " .. trackName)
        return false
    end

    local filePath = musicTracks[trackName]

    -- Check if file exists
    if not love.filesystem.getInfo(filePath) then
        print("Warning: Music file not found: " .. filePath)
        return false
    end

    -- Load the audio source
    local success, source = pcall(love.audio.newSource, filePath, "stream")
    if success then
        loadedMusic[trackName] = source
        print("✓ Preloaded music track: " .. trackName)
        return true
    else
        print("✗ Failed to load music track: " .. trackName)
        return false
    end
end

-- Preload a sound effect
function Music.preloadSFX(sfxName)
    if not soundEffects[sfxName] then
        print("Warning: Unknown sound effect: " .. sfxName)
        return false
    end

    local filePath = soundEffects[sfxName]

    -- Check if file exists
    if not love.filesystem.getInfo(filePath) then
        print("Warning: SFX file not found: " .. filePath)
        return false
    end

    -- Load the audio source
    local success, source = pcall(love.audio.newSource, filePath, "static")
    if success then
        loadedSFX[sfxName] = source
        print("✓ Preloaded sound effect: " .. sfxName)
        return true
    else
        print("✗ Failed to load sound effect: " .. sfxName)
        return false
    end
end

-- Play background music
function Music.playBGM(trackName, fadeIn)
    if not isMusicEnabled then
        print("♪ Music disabled, skipping: " .. trackName)
        return
    end

    -- Don't restart the same track
    if currentBGMName == trackName and currentBGM and currentBGM:isPlaying() then
        print("♪ Already playing: " .. trackName .. " (skipping duplicate)")
        return
    end

    -- Debug: Log BGM change attempts
    if currentBGMName ~= "" and currentBGMName ~= trackName then
        print("♪ BGM Change: " .. currentBGMName .. " → " .. trackName)
    end

    -- Stop current music
    Music.stopBGM()

    -- Try to load track if not already loaded
    if not loadedMusic[trackName] then
        if not Music.preloadTrack(trackName) then
            print("♪ Failed to play BGM: " .. trackName .. " (file not found)")
            -- Try fallback to dummy track
            if trackName ~= "dummy_bgm" then
                print("♪ Trying fallback dummy track...")
                Music.playBGM("dummy_bgm")
            end
            return
        end
    end

    currentBGM = loadedMusic[trackName]
    currentBGMName = trackName

    if currentBGM then
        -- Ensure the source is stopped before playing (prevents layering)
        love.audio.stop(currentBGM)

        currentBGM:setLooping(true)
        currentBGM:setVolume(musicVolume)
        love.audio.play(currentBGM)
        print("♪ Playing BGM: " .. trackName .. " (volume: " .. musicVolume .. ")")
    end
end

-- Stop background music
function Music.stopBGM(fadeOut)
    if currentBGM then
        -- Stop the current BGM source
        love.audio.stop(currentBGM)
        print("♪ Stopped BGM: " .. currentBGMName)

        -- Also stop the source in the loaded cache to prevent reuse issues
        if loadedMusic[currentBGMName] then
            love.audio.stop(loadedMusic[currentBGMName])
        end
    end

    currentBGM = nil
    currentBGMName = ""
end

-- Play sound effect
function Music.playSFX(sfxName)
    if not isSFXEnabled then
        print("🔊 SFX disabled, skipping: " .. sfxName)
        return
    end

    -- Try to load SFX if not already loaded
    if not loadedSFX[sfxName] then
        if not Music.preloadSFX(sfxName) then
            print("🔊 Failed to play SFX: " .. sfxName .. " (file not found)")
            return
        end
    end

    local sfx = loadedSFX[sfxName]
    if sfx then
        -- Clone the source so we can play multiple instances
        local instance = sfx:clone()
        instance:setVolume(sfxVolume)
        love.audio.play(instance)
        print("🔊 Playing SFX: " .. sfxName)
    end
end

-- Context-aware music switching
function Music.switchToScreen(screenName, gameState)
    local trackName = Music.getTrackForScreen(screenName, gameState)
    if trackName then
        Music.playBGM(trackName)
    end
end

-- Debug function to check audio state
function Music.debugAudioState()
    print("🎵 DEBUG: Current BGM = " .. (currentBGMName or "none"))
    if currentBGM then
        print("🎵 DEBUG: BGM isPlaying = " .. tostring(currentBGM:isPlaying()))
        print("🎵 DEBUG: BGM volume = " .. currentBGM:getVolume())
    end

    -- Count loaded sources
    local bgmCount = 0
    local sfxCount = 0
    for name, source in pairs(loadedMusic) do
        bgmCount = bgmCount + 1
        if source:isPlaying() then
            print("🎵 DEBUG: BGM source '" .. name .. "' is playing")
        end
    end
    for name, source in pairs(loadedSFX) do
        sfxCount = sfxCount + 1
    end

    print("🎵 DEBUG: Loaded " .. bgmCount .. " BGM sources, " .. sfxCount .. " SFX sources")
end

-- Get appropriate track for screen context
function Music.getTrackForScreen(screenName, gameState)
    if screenName == "menu" then
        return "menu"
    elseif screenName == "battle" then
        -- Check if it's a boss battle
        if gameState and gameState.battleData and gameState.battleData.isBoss then
            return "battle_boss"
        else
            return "battle"
        end
    elseif screenName == "progression" then
        -- Era-specific progression music
        if gameState and gameState.currentLevel then
            if gameState.currentLevel <= 3 then
                return "era_1990s"
            elseif gameState.currentLevel <= 6 then
                return "era_2000s"
            else
                return "era_2010s"
            end
        end
        return "progression"
    elseif screenName == "shop" then
        return "shop"
    elseif screenName == "scene" then
        -- Context-aware story music
        if gameState and gameState.currentStoryScene then
            if gameState.currentStoryScene:find("intro") then
                return "story_intro"
            elseif gameState.currentStoryScene:find("ending") then
                return "story_ending"
            else
                return "story_dramatic"
            end
        end
        return "story_intro"
    end

    return nil
end

-- Volume controls
function Music.setMusicVolume(volume)
    musicVolume = math.max(0, math.min(1, volume))
    if currentBGM then
        currentBGM:setVolume(musicVolume)
    end
end

function Music.setSFXVolume(volume)
    sfxVolume = math.max(0, math.min(1, volume))
end

function Music.getMusicVolume()
    return musicVolume
end

function Music.getSFXVolume()
    return sfxVolume
end

-- Enable/disable controls
function Music.setMusicEnabled(enabled)
    isMusicEnabled = enabled
    if not enabled then
        Music.stopBGM()
    end
end

function Music.setSFXEnabled(enabled)
    isSFXEnabled = enabled
end

function Music.isMusicEnabled()
    return isMusicEnabled
end

function Music.isSFXEnabled()
    return isSFXEnabled
end

-- Get current playing track
function Music.getCurrentTrack()
    return currentBGMName
end

function Music.isPlaying()
    return currentBGM and currentBGM:isPlaying()
end

-- Cleanup
function Music.cleanup()
    Music.stopBGM()

    -- Clear loaded audio sources
    for _, source in pairs(loadedMusic) do
        source:release()
    end

    for _, source in pairs(loadedSFX) do
        source:release()
    end

    loadedMusic = {}
    loadedSFX = {}

    print("Music system cleaned up")
end

-- Test function to verify music system
function Music.test()
    print("=== Music System Test ===")
    print("Music enabled: " .. tostring(isMusicEnabled))
    print("SFX enabled: " .. tostring(isSFXEnabled))
    print("Music volume: " .. musicVolume)
    print("SFX volume: " .. sfxVolume)

    -- Test dummy track
    print("Testing dummy BGM...")
    Music.playBGM("dummy_bgm")

    -- List available tracks
    print("Available music tracks:")
    for trackName, filePath in pairs(musicTracks) do
        local exists = love.filesystem.getInfo(filePath) ~= nil
        print("  " .. trackName .. ": " .. filePath .. (exists and " ✓" or " ✗"))
    end

    print("Available sound effects:")
    for sfxName, filePath in pairs(soundEffects) do
        local exists = love.filesystem.getInfo(filePath) ~= nil
        print("  " .. sfxName .. ": " .. filePath .. (exists and " ✓" or " ✗"))
    end

    print("=== End Test ===")
end

return Music
