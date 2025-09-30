-- Dialogue System for Scene Comics
-- Handles subtitle-style dialogue with typewriter animation and SFX

local Dialogue = {}
local Music = require("music")

-- Dialogue state
local currentDialogue = nil
local dialogueEntries = {}
local currentEntry = 1
local typewriterText = ""
local typewriterIndex = 1
local typewriterTimer = 0
local isTypewriterComplete = false
local dialogueComplete = false

-- Animation settings
local TYPEWRITER_SPEED = {
    slow = 0.08,    -- 80ms per character
    normal = 0.05,  -- 50ms per character
    fast = 0.03     -- 30ms per character
}

local currentSpeed = TYPEWRITER_SPEED.normal

-- Color definitions
local COLORS = {
    white = {1, 1, 1},
    red = {1, 0.3, 0.3},
    blue = {0.3, 0.7, 1},
    green = {0.3, 1, 0.3},
    yellow = {1, 1, 0.3},
    orange = {1, 0.7, 0.3},
    purple = {0.8, 0.3, 1},
    gray = {0.7, 0.7, 0.7}
}

-- Current dialogue state
local currentCharacter = ""
local currentColor = COLORS.white
local currentSFX = nil
local currentBGM = nil

function Dialogue.loadDialogue(sceneName, imageFilename)
    -- Extract base filename without extension
    local baseName = imageFilename:match("(.+)%.[^%.]+$") or imageFilename
    dialogueFile = "scenes/" .. sceneName .. "/" .. baseName .. ".txt"

    -- Reset state
    dialogueEntries = {}
    currentEntry = 1
    typewriterText = ""
    typewriterIndex = 1
    typewriterTimer = 0
    isTypewriterComplete = false
    dialogueComplete = false
    currentCharacter = ""
    currentColor = COLORS.white
    currentSpeed = TYPEWRITER_SPEED.normal
    currentBGM = nil

    -- Check if dialogue file exists
    if not love.filesystem.getInfo(dialogueFile) then
        print("No dialogue file found: " .. dialogueFile .. " (for image: " .. imageFilename .. ")")
        dialogueComplete = true
        return false
    end

    print("✓ Found dialogue file: " .. dialogueFile)

    -- Load and parse dialogue file
    local content = love.filesystem.read(dialogueFile)
    if not content then
        print("Failed to read dialogue file: " .. dialogueFile)
        dialogueComplete = true
        return false
    end

    -- Parse subtitle format
    dialogueEntries = Dialogue.parseSubtitleFormat(content)

    if #dialogueEntries == 0 then
        print("No dialogue entries found in: " .. dialogueFile)
        dialogueComplete = true
        return false
    end

    print("✓ Loaded " .. #dialogueEntries .. " dialogue entries from: " .. dialogueFile)

    -- Start first dialogue entry
    Dialogue.startEntry(1)

    return true
end

function Dialogue.parseSubtitleFormat(content)
    local entries = {}
    local lines = {}

    -- Split content into lines
    for line in content:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end

    local i = 1
    while i <= #lines do
        local line = lines[i]:match("^%s*(.-)%s*$") -- trim whitespace

        -- Skip empty lines
        if line == "" then
            i = i + 1
        -- Check for entry number
        elseif line:match("^%d+$") then
            local entryNum = tonumber(line)
            i = i + 1

            -- Parse timing line
            if i <= #lines then
                local timingLine = lines[i]:match("^%s*(.-)%s*$")
                local startTime, endTime = timingLine:match("(%d%d:%d%d:%d%d%d)%s*%-%->%s*(%d%d:%d%d:%d%d%d)")

                if startTime and endTime then
                    i = i + 1

                    -- Parse dialogue text (can be multiple lines)
                    local dialogueText = ""
                    local character = ""
                    local color = "white"
                    local sfx = nil
                    local speed = "normal"
                    local zoom = nil

                    while i <= #lines do
                        local textLine = lines[i]:match("^%s*(.-)%s*$")

                        -- Stop if we hit next entry number or empty line
                        if textLine == "" or textLine:match("^%d+$") then
                            break
                        end

                        -- Parse tags and text
                        local processedLine, lineChar, lineColor, lineSFX, lineSpeed, lineBGM, lineZoom = Dialogue.parseDialogueLine(textLine)

                        if lineChar then character = lineChar end
                        if lineColor then color = lineColor end
                        if lineSFX then sfx = lineSFX end
                        if lineSpeed then speed = lineSpeed end
                        if lineBGM then bgm = lineBGM end
                        if lineZoom then zoom = lineZoom end

                        if dialogueText ~= "" then
                            dialogueText = dialogueText .. "\n"
                        end
                        dialogueText = dialogueText .. processedLine

                        i = i + 1
                    end

                    -- Create dialogue entry
                    if dialogueText ~= "" then
                        table.insert(entries, {
                            number = entryNum,
                            startTime = Dialogue.parseTime(startTime),
                            endTime = Dialogue.parseTime(endTime),
                            text = dialogueText,
                            character = character,
                            color = color,
                            sfx = sfx,
                            speed = speed,
                            bgm = bgm,
                            zoom = zoom
                        })
                    end
                else
                    i = i + 1
                end
            else
                break
            end
        else
            i = i + 1
        end
    end

    return entries
end

function Dialogue.parseDialogueLine(line)
    local character = nil
    local color = nil
    local sfx = nil
    local speed = nil
    local bgm = nil
    local zoom = nil
    local text = line

    -- Parse CHARACTER tag
    text = text:gsub("%[CHARACTER:([^%]]+)%]", function(name)
        character = name
        return ""
    end)

    -- Parse COLOR tag
    text = text:gsub("%[COLOR:([^%]]+)%]", function(colorName)
        color = colorName
        return ""
    end)

-- Parse SFX tag
    text = text:gsub("%[SFX:([^%]]+)%]", function(soundName)
        sfx = soundName
        return ""
    end)

    -- Parse BGM tag
    text = text:gsub("%[BGM:([^%]]+)%]", function(trackName)
        bgm = trackName
        return ""
    end)

    -- Parse SPEED tag
    text = text:gsub("%[SPEED:([^%]]+)%]", function(speedName)
        speed = speedName
        return ""
    end)

    -- Parse ZOOM tag
    text = text:gsub("%[ZOOM:([^%]]+)%]", function(zoomValue)
        zoom = tonumber(zoomValue)
        return ""
    end)

    -- Clean up extra whitespace
    text = text:match("^%s*(.-)%s*$")

    return text, character, color, sfx, speed, bgm, zoom
end

function Dialogue.parseTime(timeStr)
    local hours, minutes, seconds = timeStr:match("(%d%d):(%d%d):(%d%d%d)")
    if hours and minutes and seconds then
        return tonumber(hours) * 3600 + tonumber(minutes) * 60 + tonumber(seconds) / 1000
    end
    return 0
end

function Dialogue.startEntry(entryIndex)
    if entryIndex > #dialogueEntries then
        dialogueComplete = true
        return
    end

    currentEntry = entryIndex
    local entry = dialogueEntries[currentEntry]

    -- Set dialogue properties
    currentCharacter = entry.character or ""
    currentColor = COLORS[entry.color] or COLORS.white
    currentSpeed = TYPEWRITER_SPEED[entry.speed] or TYPEWRITER_SPEED.normal

    -- Play SFX if specified
    if entry.sfx then
        Music.playSFX(entry.sfx)
    end

    -- Change BGM if specified
    if entry.bgm then
        if entry.bgm == "stop" then
            Music.stopBGM()
            print("🎵 Stopped BGM via dialogue")
        else
            Music.playBGM(entry.bgm)
            print("🎵 Changed BGM to: " .. entry.bgm)
        end
    end

    -- Apply zoom if specified
    if entry.zoom then
        -- We need to communicate this back to the Scene system
        -- For now, we'll store it in a global that Scene can access
        _G.currentPanelZoom = entry.zoom
        print("🔍 Set panel zoom to: " .. entry.zoom)
    end

    -- Start typewriter animation
    typewriterText = ""
    typewriterIndex = 1
    typewriterTimer = 0
    isTypewriterComplete = false

    print("Starting dialogue entry " .. entryIndex .. ": " .. (entry.character or ""))
end

function Dialogue.update(dt)
    if dialogueComplete or currentEntry > #dialogueEntries then
        return
    end

    local entry = dialogueEntries[currentEntry]
    if not entry then
        return
    end

    -- Update typewriter animation
    if not isTypewriterComplete then
        typewriterTimer = typewriterTimer + dt

        if typewriterTimer >= currentSpeed then
            typewriterTimer = 0

            -- Get next character (handle UTF-8)
            local fullText = entry.text
            local nextChar = Dialogue.getUTF8Character(fullText, typewriterIndex)

            if nextChar then
                typewriterText = typewriterText .. nextChar
                typewriterIndex = typewriterIndex + #nextChar

                -- Play typing sound effect
                if math.random() < 0.3 then -- 30% chance per character
                    Music.playSFX("ui_type")
                end
            else
                -- Typewriter complete
                isTypewriterComplete = true
                typewriterText = fullText
            end
        end
    end
end

function Dialogue.getUTF8Character(str, byteIndex)
    if byteIndex > #str then
        return nil
    end

    local byte = str:byte(byteIndex)
    local charLen = 1

    -- Determine UTF-8 character length
    if byte >= 240 then
        charLen = 4
    elseif byte >= 224 then
        charLen = 3
    elseif byte >= 192 then
        charLen = 2
    end

    -- Extract character
    if byteIndex + charLen - 1 <= #str then
        return str:sub(byteIndex, byteIndex + charLen - 1)
    else
        return str:sub(byteIndex)
    end
end

function Dialogue.draw(screenWidth, screenHeight)
    if dialogueComplete or currentEntry > #dialogueEntries then
        return
    end

    local entry = dialogueEntries[currentEntry]
    if not entry then
        return
    end

    -- Dialogue box dimensions
    local boxHeight = 120
    local boxY = screenHeight - boxHeight - 20  -- More space from bottom edge
    local boxX = 20
    local boxWidth = screenWidth - 40

    -- Draw dialogue box background
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", boxX, boxY, boxWidth, boxHeight, 10)

    -- Draw dialogue box border
    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.rectangle("line", boxX, boxY, boxWidth, boxHeight, 10)

    -- Draw character name if present
    if currentCharacter ~= "" then
        love.graphics.setColor(1, 1, 0.8)
        love.graphics.printf(currentCharacter, boxX + 15, boxY + 10, boxWidth - 30, "left")
    end

    -- Draw dialogue text
    love.graphics.setColor(currentColor[1], currentColor[2], currentColor[3])
    local textY = boxY + (currentCharacter ~= "" and 35 or 15)
    love.graphics.printf(typewriterText, boxX + 15, textY, boxWidth - 30, "left")

    -- Draw continuation indicator
    if isTypewriterComplete then
        local indicatorX = boxX + boxWidth - 30
        local indicatorY = boxY + boxHeight - 25
        love.graphics.setColor(1, 1, 1, 0.5 + 0.5 * math.sin(love.timer.getTime() * 4))
        love.graphics.printf("▼", indicatorX, indicatorY, 20, "center")
    end
end

function Dialogue.advance()
    if dialogueComplete then
        return false
    end

    -- If typewriter is still running, complete it immediately
    if not isTypewriterComplete then
        local entry = dialogueEntries[currentEntry]
        if entry then
            typewriterText = entry.text
            isTypewriterComplete = true
        end
        return true
    end

    -- Move to next dialogue entry
    currentEntry = currentEntry + 1

    if currentEntry > #dialogueEntries then
        dialogueComplete = true
        return false
    else
        Dialogue.startEntry(currentEntry)
        return true
    end
end

function Dialogue.isComplete()
    return dialogueComplete
end

function Dialogue.skip()
    dialogueComplete = true
end

-- Getters
function Dialogue.getCurrentEntry()
    return currentEntry
end

function Dialogue.getTotalEntries()
    return #dialogueEntries
end

function Dialogue.hasDialogue()
    return #dialogueEntries > 0
end

return Dialogue