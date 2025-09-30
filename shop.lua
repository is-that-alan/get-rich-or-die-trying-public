-- Shop System
local Shop = {}

local Music = require("music")

local ConsumablesSystem = require("consumables_system")
local DeckSpells = require("deck_spells")
local Progression = require("progression")

local shopInventory = {}
local message = ""
local messageTimer = 0
local currentView = "shop" -- "shop" or "collection"

function Shop.init(playerLevel)
    shopInventory = Shop.generateInventory(playerLevel or 1)
end

function Shop.generateInventory(playerLevel)
    local inventory = {}
    playerLevel = playerLevel or 1







    -- Get spell cards and battle consumables

    local availableConsumablesSystem = ConsumablesSystem.generateShopItems(playerLevel)
    

    -- Combine all types with weighted selection
    local weightedInventory = {}

    -- Add consumables from ConsumablesSystem (new system)
    for _, consumable in ipairs(availableConsumablesSystem) do
        consumable.type = "consumable"
        table.insert(weightedInventory, consumable)
    end


    -- Add deck spells
    local availableDeckSpells = DeckSpells.getSpells()
    for _, spell in ipairs(availableDeckSpells) do
        local chance = 100
        if spell.rarity == "uncommon" then
            chance = 50
        elseif spell.rarity == "rare" then
            chance = 25
        elseif spell.rarity == "legendary" then
            chance = 10
        end
        if math.random(100) <= chance then
            table.insert(weightedInventory, { item = spell, type = "deck_spell", price = spell.price })
        end
    end







    -- Filter out items with nil data
    local validItems = {}
    for i, item in ipairs(weightedInventory) do
        if item and item.item and item.item.name then
            table.insert(validItems, item)
        else
            print("Warning: Skipping invalid shop item:",
                item and item.item and (item.item.id or item.item.name) or "unknown")
        end
    end

    -- Shuffle valid items
    local shuffled = {}
    for i, item in ipairs(validItems) do
        shuffled[i] = item
    end

    for i = #shuffled, 2, -1 do
        local j = math.random(i)
        shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
    end

    -- Select up to 8 items for shop (increased for more variety)
    local finalInventory = {}
    for i = 1, math.min(8, #shuffled) do
        table.insert(finalInventory, shuffled[i])
    end

    print("Generated shop inventory with", #finalInventory, "items")
    return finalInventory
end

function Shop.update(dt)
    if messageTimer > 0 then
        messageTimer = messageTimer - dt
        if messageTimer <= 0 then
            message = ""
        end
    end
end

function Shop.draw(gameState)
    -- Background
    love.graphics.setColor(0.1, 0.1, 0.18)
    love.graphics.rectangle("fill", 0, 0, 800, 600)

    -- Title

    love.graphics.setColor(0.31, 0.8, 0.77)
    love.graphics.printf("買卡強化你嘅實力！", 0, 60, 800, "center")

    -- Money display
    love.graphics.setColor(0, 1, 0)
    love.graphics.print("銀紙: $" .. gameState.playerMoney, 50, 30)

    -- Collection info
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("牌組: " .. #gameState.playerDeck .. " 張", 50, 60)
    love.graphics.print("角色: " .. #gameState.playerCharacters .. " 個", 50, 80)
    love.graphics.print("加強: " .. #gameState.playerModifiers .. " 張", 50, 100)

    -- Navigation tabs
    Shop.drawTabs(gameState)

    -- Draw content based on current view
    if currentView == "shop" then
        -- Draw shelf
        love.graphics.setColor(0.4, 0.2, 0.1) -- Brown color
        love.graphics.rectangle("fill", 80, 280, 640, 20)
        love.graphics.rectangle("fill", 80, 460, 640, 20)
        Shop.drawShopCards(gameState)
    elseif currentView == "collection" then
        Shop.drawCollection(gameState)
    end

    -- Back button
    love.graphics.setColor(0.58, 0.65, 0.65)
    love.graphics.rectangle("fill", 50, 520, 80, 30)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("返回", 50, 527, 80, "center")

    -- Refresh button (only in shop view)
    if currentView == "shop" then
        love.graphics.setColor(0.9, 0.49, 0.13)
        love.graphics.rectangle("fill", 650, 520, 100, 30)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("刷新 ($10)", 650, 527, 100, "center")
    end

    -- Message
    if message ~= "" then
        love.graphics.setColor(1, 0.9, 0.43)
        love.graphics.printf(message, 0, 100, 800, "center")
    end
end

function Shop.drawShopCards(gameState)
    if #shopInventory == 0 then
        Shop.init()
    end

    -- Display items in 2 rows of 4
    for i, item in ipairs(shopInventory) do
        -- Skip invalid items
        if not item or not item.item then
            print("Warning: Invalid shop item at index", i)
        else
            local col = ((i - 1) % 4)
            local row = math.floor((i - 1) / 4)

            local x = 100 + (col * 150)
            local y = 200 + (row * 180)

            -- Draw item based on type
            pcall(function()
                local mouseX, mouseY = love.mouse.getPosition()
                local isHovered = mouseX >= x and mouseX <= x + 80 and mouseY >= y and mouseY <= y + 120

                if item.type == "consumable" then
                    ConsumablesSystem.drawConsumable(item.item, x, y, 80, 80, isHovered, 1)
                elseif item.type == "deck_spell" then
                    -- Draw deck spell card
                    love.graphics.setColor(0.8, 0.3, 0.8, 0.8) -- Purple for spells
                    love.graphics.rectangle("fill", x, y, 80, 80, 10)
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.rectangle("line", x, y, 80, 80, 10)
                    love.graphics.printf(item.item.name, x + 2, y + 5, 76, "center")

                    if isHovered then
                        -- Draw hover details
                        local detailWidth = 200
                        local detailHeight = 100
                        love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
                        love.graphics.rectangle("fill", x + 90, y, detailWidth, detailHeight, 5)
                        love.graphics.setColor(1, 1, 1)
                        love.graphics.printf(item.item.name, x + 95, y + 5, detailWidth - 10, "center")
                        love.graphics.printf(item.item.description, x + 95, y + 25, detailWidth - 10, "left")
                    end
                end
            end)

            -- Price tag
            love.graphics.setColor(0.95, 0.61, 0.07) -- Orange
            love.graphics.rectangle("fill", x + 60, y + 100, 40, 20)
            love.graphics.setColor(0, 0, 0)
            love.graphics.printf("$" .. (item.price or 0), x + 60, y + 103, 40, "center")

            -- Type indicator
            love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
            love.graphics.rectangle("fill", x, y - 15, 80, 12)
            love.graphics.setColor(1, 1, 1)

            local typeText = "消耗品"
            if item.type == "deck_spell" then
                typeText = "法術"
            end
            love.graphics.printf(typeText, x, y - 13, 80, "center")

            -- Affordability indicator
            if gameState.playerMoney < (item.price or 0) then
                love.graphics.setColor(1, 0, 0, 0.5)
                love.graphics.rectangle("fill", x, y, 80, 120)
            end
        end
    end
end

function Shop.mousepressed(x, y, gameState)
    -- Back button
    if x >= 50 and x <= 130 and y >= 520 and y <= 550 then
        Music.playSFX("ui_click")
        -- Return to progression screen without advancing story
        gameState.screen = "progression"
        local ProgressionScreen = require("progression_screen")
        ProgressionScreen.init(gameState)
        return
    end

    -- Refresh button (only in shop view)
    if currentView == "shop" and x >= 650 and x <= 750 and y >= 520 and y <= 550 then
        Music.playSFX("ui_click")
        Shop.refreshShop(gameState)
        return
    end

    -- Tab navigation
    if y >= 130 and y <= 155 then
        if x >= 200 and x <= 300 then
            Music.playSFX("ui_click")
            currentView = "shop"
            return

        end
    end

    -- Check shop items (only in shop view)
    if currentView == "shop" then
        for i, item in ipairs(shopInventory) do
            local col = ((i - 1) % 4)
            local row = math.floor((i - 1) / 4)

            local itemX = 100 + (col * 150)
            local itemY = 200 + (row * 180)

            -- Check if click is within item bounds
            if x >= itemX and x <= itemX + 80 and y >= itemY and y <= itemY + 120 then
                Shop.buyCard(item, i, gameState)
                return
            end
        end
    end
end

function Shop.buyCard(item, index, gameState)
    if gameState.playerMoney >= item.price then
        -- Play purchase sound
        Music.playSFX("purchase")

        -- Deduct money
        gameState.playerMoney = gameState.playerMoney - item.price

        -- Add item to appropriate collection
        if item.type == "consumable" then
            ConsumablesSystem.addToInventory(gameState, item.item.id, 1)
            Shop.showMessage("買咗 " .. item.item.name .. "！")

        elseif item.type == "deck_spell" then
            local spell = item.item
            if spell.selection_count > 0 then
                gameState.screen = "deck_modifier"
                local DeckModifierScreen = require("deck_modifier_screen")
                DeckModifierScreen.init(spell, gameState)
            else
                local effect_func = require("deck_spell_effects")[spell.effect]
                if effect_func then
                    local new_deck, result_message = effect_func(gameState.playerDeck)
                    gameState.playerDeck = new_deck
                    Shop.showMessage(result_message)
                end
            end
        end

        -- Remove from shop
        table.remove(shopInventory, index)
    else
        -- Play error sound for insufficient funds
        Music.playSFX("ui_error")
        Shop.showMessage("錢唔夠！")
    end
end

function Shop.refreshShop(gameState)
    local refreshCost = 10

    if gameState.playerMoney >= refreshCost then
        gameState.playerMoney = gameState.playerMoney - refreshCost
        local playerLevel = gameState.runDepth or 1
        shopInventory = Shop.generateInventory(playerLevel)
        Shop.showMessage("商店已刷新！")
    else
        Shop.showMessage("錢唔夠刷新！")
    end
end

function Shop.drawTabs(gameState)
    -- Tab buttons
    local tabY = 130
    local tabHeight = 25

    -- Shop tab
    if currentView == "shop" then
        love.graphics.setColor(0.2, 0.6, 0.86)
    else
        love.graphics.setColor(0.4, 0.4, 0.4)
    end
    love.graphics.rectangle("fill", 200, tabY, 100, tabHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("商店", 200, tabY + 5, 100, "center")

    -- Collection tab
    -- if currentView == "collection" then
    --     love.graphics.setColor(0.2, 0.6, 0.86)
    -- else
    --     love.graphics.setColor(0.4, 0.4, 0.4)
    -- end
    -- love.graphics.rectangle("fill", 310, tabY, 100, tabHeight)
    -- love.graphics.setColor(1, 1, 1)
    -- love.graphics.printf("收藏", 310, tabY + 5, 100, "center")

    -- Deck builder tab
    -- if currentView == "deck" then
    --     love.graphics.setColor(0.2, 0.6, 0.86)
    -- else
    --     love.graphics.setColor(0.4, 0.4, 0.4)
    -- end
    -- love.graphics.rectangle("fill", 420, tabY, 100, tabHeight)
    -- love.graphics.setColor(1, 1, 1)
    -- love.graphics.printf("組牌", 420, tabY + 5, 100, "center")
end

function Shop.drawCollection(gameState)
    -- This function is now disabled as the collection view has been removed.
end

function Shop.showMessage(text)
    message = text
    messageTimer = 2.0
end

return Shop
