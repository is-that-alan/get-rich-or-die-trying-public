-- Event Screen - Handles random events in the Hong Kong Roguelike
-- Provides choices and consequences for events like typhoon warnings

local EventScreen = {}
local Music = require("music")

-- Current event data
local currentEvent = nil
local selectedChoice = nil
local resultText = ""
local showResult = false
local resultTimer = 0

-- Visual constants
local CHOICE_HEIGHT = 80
local CHOICE_MARGIN = 15
local RESULT_DISPLAY_TIME = 3.0

function EventScreen.init(eventData)
    currentEvent = eventData
    selectedChoice = nil
    resultText = ""
    showResult = false
    resultTimer = 0

    print("🎭 Event initialized:", eventData and eventData.name or "Unknown Event")
end

function EventScreen.update(dt)
    if showResult then
        resultTimer = resultTimer + dt
        if resultTimer >= RESULT_DISPLAY_TIME then
            -- Auto-continue after showing result
            EventScreen.exitEvent()
        end
    end
end

function EventScreen.draw(gameState)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    if not currentEvent then
        -- Fallback if no event data
        love.graphics.setColor(0.8, 0.2, 0.2, 1)
        love.graphics.printf("錯誤：無事件資料", 0, screenHeight/2, screenWidth, "center")
        return
    end

    -- Background
    love.graphics.setColor(0.05, 0.1, 0.15, 1)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    -- Event illustration background
    love.graphics.setColor(0.1, 0.15, 0.2, 0.8)
    love.graphics.rectangle("fill", 50, 50, screenWidth - 100, 200, 20)

    if not showResult then
        -- Event title
        love.graphics.setColor(1, 0.9, 0.3, 1)
        love.graphics.printf(currentEvent.name or "未知事件", 60, 80, screenWidth - 120, "center")

        -- Event description
        love.graphics.setColor(0.9, 0.9, 0.9, 1)
        love.graphics.printf(currentEvent.description or "無描述", 60, 120, screenWidth - 120, "center")

        -- Choices
        if currentEvent.choices then
            local startY = 300
            local totalChoices = #currentEvent.choices

            for i, choice in ipairs(currentEvent.choices) do
                local choiceY = startY + (i - 1) * (CHOICE_HEIGHT + CHOICE_MARGIN)
                local isHovered = selectedChoice == i

                -- Choice background
                if isHovered then
                    love.graphics.setColor(0.3, 0.4, 0.5, 0.8)
                else
                    love.graphics.setColor(0.2, 0.25, 0.3, 0.8)
                end
                love.graphics.rectangle("fill", 100, choiceY, screenWidth - 200, CHOICE_HEIGHT, 10)

                -- Choice border
                love.graphics.setColor(0.5, 0.6, 0.7, 1)
                love.graphics.rectangle("line", 100, choiceY, screenWidth - 200, CHOICE_HEIGHT, 10)

                -- Choice text
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.printf(choice.text or "無選項", 120, choiceY + 25, screenWidth - 240, "left")
            end
        end

        -- Instructions
        love.graphics.setColor(0.7, 0.7, 0.7, 1)
        love.graphics.printf("用滑鼠點擊選項", 0, screenHeight - 60, screenWidth, "center")

    else
        -- Show result
        love.graphics.setColor(1, 0.9, 0.3, 1)
        love.graphics.printf("結果", 0, 300, screenWidth, "center")

        love.graphics.setColor(0.9, 0.9, 0.9, 1)
        love.graphics.printf(resultText, 100, 350, screenWidth - 200, "center")

        -- Auto-continue indicator
        local timeLeft = RESULT_DISPLAY_TIME - resultTimer
        love.graphics.setColor(0.7, 0.7, 0.7, 1)
        love.graphics.printf(string.format("%.1f秒後自動繼續...", timeLeft), 0, screenHeight - 60, screenWidth, "center")
    end
end

function EventScreen.mousepressed(x, y, button, gameState)
    if button ~= 1 or not currentEvent or showResult then return end

    if not currentEvent.choices then return end

    -- Check which choice was clicked
    local screenWidth = love.graphics.getWidth()
    local startY = 300

    for i, choice in ipairs(currentEvent.choices) do
        local choiceY = startY + (i - 1) * (CHOICE_HEIGHT + CHOICE_MARGIN)

        if x >= 100 and x <= screenWidth - 100 and
           y >= choiceY and y <= choiceY + CHOICE_HEIGHT then
            -- Choice clicked
            EventScreen.selectChoice(i, gameState)
            Music.playSFX("ui_click")
            return
        end
    end
end

function EventScreen.selectChoice(choiceIndex, gameState)
    if not currentEvent or not currentEvent.choices[choiceIndex] then return end

    local choice = currentEvent.choices[choiceIndex]
    selectedChoice = choiceIndex

    -- Execute choice effect
    if choice.effect then
        resultText = choice.effect(gameState)
    else
        resultText = "什麼都沒有發生"
    end

    showResult = true
    resultTimer = 0

    print("🎯 Choice selected:", choiceIndex, "->", resultText)
end

function EventScreen.exitEvent()
    -- Return to progression screen
    local mainModule = require("main")
    if mainModule and mainModule.setGameScreen then
        mainModule.setGameScreen("progression")
    else
        -- Fallback using global function
        setGameScreen("progression")
    end
end

function EventScreen.keypressed(key)
    if key == "escape" then
        EventScreen.exitEvent()
    elseif key == "space" and showResult then
        EventScreen.exitEvent()
    elseif key >= "1" and key <= "9" and not showResult then
        local choiceNum = tonumber(key)
        if currentEvent and currentEvent.choices and currentEvent.choices[choiceNum] then
            EventScreen.selectChoice(choiceNum, require("main").getGameState())
        end
    end
end

return EventScreen