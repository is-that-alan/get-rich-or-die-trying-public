-- Modern Consumables System
-- Lua-driven consumables with pluggable effects and hover details
local ConsumablesSystem = {}

local ConsumableEffects = require("consumable_effects")

-- Image cache for consumable icons
ConsumablesSystem.iconCache = {}

-- Load config from Lua module
ConsumablesSystem.config = nil

function ConsumablesSystem.loadConfig()
    if ConsumablesSystem.config then
        return ConsumablesSystem.config
    end

    local success, configData = pcall(function()
        return require("consumables_config")
    end)

    if success then
        ConsumablesSystem.config = configData
        print("✓ Consumables config loaded from consumables_config.lua")
    else
        print("⚠ Failed to load consumables_config.lua, using fallback")
        ConsumablesSystem.config = ConsumablesSystem.getFallbackConfig()
    end

    return ConsumablesSystem.config
end

-- Load consumable icon image
function ConsumablesSystem.loadIcon(consumableId)
    if ConsumablesSystem.iconCache[consumableId] then
        return ConsumablesSystem.iconCache[consumableId]
    end

    -- Try to load image from consumables directory
    local imagePath = "consumables/" .. consumableId .. ".png"
    local success, image = pcall(function()
        return love.graphics.newImage(imagePath)
    end)

    if success then
        ConsumablesSystem.iconCache[consumableId] = image
        print("✓ Loaded consumable icon: " .. imagePath)
        return image
    else
        -- Fallback: store nil to avoid repeated attempts
        ConsumablesSystem.iconCache[consumableId] = nil
        print("⚠ No icon found for: " .. consumableId .. " (" .. imagePath .. ")")
        return nil
    end
end

-- Fallback config if Lua module fails to load
function ConsumablesSystem.getFallbackConfig()
    return {
        consumables = {
            {
                id = "moon_box",
                name = "月光寶盒",
                description = "神秘寶盒\n複製最近3張棄牌或打出的牌到手牌",
                price = 30,
                rarity = "uncommon",
                category = "special",
                effectType = "copy_recent_tiles",
                effectValue = 3,
                icon = "🌙",
                color = {0.8, 0.8, 1.0}
            }
        },
        rarityColors = {
            common = {0.8, 0.8, 0.8},
            uncommon = {0.3, 0.8, 0.3},
            rare = {0.3, 0.3, 0.9},
            legendary = {0.9, 0.6, 0.0}
        }
    }
end

-- Get consumable by ID
function ConsumablesSystem.getConsumable(itemId)
    local config = ConsumablesSystem.loadConfig()
    for _, consumable in ipairs(config.consumables) do
        if consumable.id == itemId then
            return consumable
        end
    end
    return nil
end

-- Get all consumables
function ConsumablesSystem.getAllConsumables()
    local config = ConsumablesSystem.loadConfig()
    return config.consumables or {}
end

-- Get consumables by rarity
function ConsumablesSystem.getConsumablesByRarity(rarity)
    local config = ConsumablesSystem.loadConfig()
    local filtered = {}
    for _, consumable in ipairs(config.consumables) do
        if consumable.rarity == rarity then
            table.insert(filtered, consumable)
        end
    end
    return filtered
end

-- Add consumable to player inventory
function ConsumablesSystem.addToInventory(gameState, itemId, quantity)
    quantity = quantity or 1

    if not gameState.playerConsumables then
        gameState.playerConsumables = {}
    end

    for i = 1, quantity do
        table.insert(gameState.playerConsumables, itemId)
    end

    local consumable = ConsumablesSystem.getConsumable(itemId)
    local itemName = consumable and consumable.name or itemId
    print("🎒 獲得道具: " .. itemName .. " x" .. quantity)
end

-- Get player inventory with details
function ConsumablesSystem.getPlayerInventory(gameState)
    if not gameState.playerConsumables then
        return {}
    end

    local inventory = {}
    local counted = {}

    for _, itemId in ipairs(gameState.playerConsumables) do
        if not counted[itemId] then
            local consumable = ConsumablesSystem.getConsumable(itemId)
            if consumable then
                local count = 0
                for _, id in ipairs(gameState.playerConsumables) do
                    if id == itemId then
                        count = count + 1
                    end
                end

                inventory[itemId] = {
                    consumable = consumable,
                    count = count
                }
                counted[itemId] = true
            end
        end
    end

    return inventory
end

-- Use consumable
function ConsumablesSystem.useConsumable(itemId, gameState, battleState)
    local consumable = ConsumablesSystem.getConsumable(itemId)
    if not consumable then
        return false, "道具不存在"
    end

    -- Check if player has the item
    if not gameState.playerConsumables then
        gameState.playerConsumables = {}
    end

    local hasItem = false
    local itemIndex = nil
    for i, consumableId in ipairs(gameState.playerConsumables) do
        if consumableId == itemId then
            hasItem = true
            itemIndex = i
            break
        end
    end

    if not hasItem then
        return false, "你沒有這個道具"
    end

    -- Execute the effect
    local success, message = ConsumableEffects.executeEffect(
        consumable.effectType,
        gameState,
        battleState,
        consumable.effectValue
    )

    if success then
        -- Check if this is an infinite use item
        local infiniteUseItems = {"contact_lens", "rice_rice_baby"} -- List of infinite use items
        local isInfiniteUse = false
        for _, itemId in ipairs(infiniteUseItems) do
            if itemId == consumable.id then
                isInfiniteUse = true
                break
            end
        end
        
        if not isInfiniteUse then
            -- Remove item from inventory (consumables are single-use by default)
            table.remove(gameState.playerConsumables, itemIndex)
        end
        print("🍽️ 使用道具: " .. consumable.name .. " -> " .. message)
        return true, message
    else
        return false, message
    end
end

-- Generate shop items
function ConsumablesSystem.generateShopItems(shopLevel)
    shopLevel = shopLevel or 1
    local config = ConsumablesSystem.loadConfig()
    local items = {}

    -- Determine available rarities based on shop level
    local rarities = {"common"}
    if shopLevel >= 2 then table.insert(rarities, "uncommon") end
    if shopLevel >= 3 then table.insert(rarities, "rare") end
    if shopLevel >= 4 then table.insert(rarities, "legendary") end

    -- Generate 5-8 random items
    local itemCount = math.random(5, 8)
    for i = 1, itemCount do
        local rarity = rarities[math.random(#rarities)]
        local rarityItems = ConsumablesSystem.getConsumablesByRarity(rarity)

        if #rarityItems > 0 then
            local randomItem = rarityItems[math.random(#rarityItems)]
            table.insert(items, {
                item = randomItem,
                type = "consumable",
                price = randomItem.price
            })
        end
    end

    return items
end

-- Draw consumable with hover details
function ConsumablesSystem.drawConsumable(consumable, x, y, width, height, isHovered, count)
    local config = ConsumablesSystem.loadConfig()

    -- Get rarity color
    local rarityColor = config.rarityColors[consumable.rarity] or {0.8, 0.8, 0.8}
    local consumableColor = consumable.color or rarityColor

    -- Draw background
    if isHovered then
        love.graphics.setColor(consumableColor[1] * 1.2, consumableColor[2] * 1.2, consumableColor[3] * 1.2, 0.8)
    else
        love.graphics.setColor(consumableColor[1], consumableColor[2], consumableColor[3], 0.6)
    end
    love.graphics.rectangle("fill", x, y, width, height, 5)

    -- Draw border
    love.graphics.setColor(rarityColor[1], rarityColor[2], rarityColor[3], 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height, 5)

    -- Draw icon
    love.graphics.setColor(1, 1, 1, 1)

    -- Try to load and draw image icon first
    local iconImage = ConsumablesSystem.loadIcon(consumable.id)
    if iconImage then
        local iconSize = math.min(width - 10, height - 30) -- Leave space for text
        local iconX = x + (width - iconSize) / 2
        local iconY = y + 5

        -- Calculate scaling to fit icon in the space
        local scaleX = iconSize / iconImage:getWidth()
        local scaleY = iconSize / iconImage:getHeight()
        local scale = math.min(scaleX, scaleY)

        -- Center the scaled icon
        local scaledWidth = iconImage:getWidth() * scale
        local scaledHeight = iconImage:getHeight() * scale
        local centeredX = iconX + (iconSize - scaledWidth) / 2
        local centeredY = iconY + (iconSize - scaledHeight) / 2

        love.graphics.draw(iconImage, centeredX, centeredY, 0, scale, scale)
    else
        -- Fallback to emoji/text icon
        local icon = consumable.icon or "?"
        love.graphics.printf(icon, x + 5, y + 5, width - 10, "center")
    end

    -- Draw count if > 1
    if count and count > 1 then
        love.graphics.setColor(1, 1, 0, 1)
        love.graphics.printf("x" .. count, x + width - 20, y + height - 20, 20, "center")
    end

    -- Draw hover details
    if isHovered then
        ConsumablesSystem.drawHoverDetails(consumable, x + width + 10, y)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

-- Draw hover details
function ConsumablesSystem.drawHoverDetails(consumable, x, y)
    local detailWidth = 200
    local detailHeight = 100

    -- Background
    love.graphics.setColor(0.1, 0.1, 0.1, 0.9)
    love.graphics.rectangle("fill", x, y, detailWidth, detailHeight, 5)

    -- Border
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", x, y, detailWidth, detailHeight, 5)

    -- Title
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(consumable.name, x + 5, y + 5, detailWidth - 10, "center")

    -- Rarity
    local config = ConsumablesSystem.loadConfig()
    local rarityColor = config.rarityColors[consumable.rarity] or {0.8, 0.8, 0.8}
    love.graphics.setColor(rarityColor[1], rarityColor[2], rarityColor[3], 1)
    love.graphics.printf(consumable.rarity or "common", x + 5, y + 25, detailWidth - 10, "center")

    -- Description
    love.graphics.setColor(0.9, 0.9, 0.9, 1)
    love.graphics.printf(consumable.description or "無描述", x + 5, y + 45, detailWidth - 10, "left")

    -- Price
    love.graphics.setColor(1, 1, 0, 1)
    love.graphics.printf("$" .. (consumable.price or 0), x + 5, y + detailHeight - 20, detailWidth - 10, "center")
end

-- Draw consumables panel in battle screen
function ConsumablesSystem.drawBattlePanel(gameState, x, y, width)
    -- Extra safety checks to prevent segfaults
    if not gameState or not gameState.mainGameState then
        return 0
    end

    if not gameState.mainGameState.playerConsumables or #gameState.mainGameState.playerConsumables == 0 then
        return 0 -- Return height used
    end

    local success, inventory = pcall(ConsumablesSystem.getPlayerInventory, gameState.mainGameState)
    if not success or not inventory then
        print("❌ Failed to get player inventory")
        return 0
    end

    local itemList = {}
    for itemId, data in pairs(inventory) do
        if itemId and data then
            table.insert(itemList, {id = itemId, data = data})
        end
    end

    if #itemList == 0 then
        return 0
    end

    local panelHeight = 120
    local MahjongUI = require("mahjong_ui")
    MahjongUI.drawPanel(x, y, width, panelHeight, "道具")

    -- Draw consumables
    local itemWidth = 30
    local itemHeight = 30
    local itemSpacing = 5
    local startX = x + 10
    local startY = y + 30

    for i, item in ipairs(itemList) do
        local itemX = startX + (i - 1) * (itemWidth + itemSpacing)
        local itemY = startY

        -- Check if mouse is hovering
        local mouseX, mouseY = love.mouse.getPosition()
        local isHovered = mouseX >= itemX and mouseX <= itemX + itemWidth and
                         mouseY >= itemY and mouseY <= itemY + itemHeight

        ConsumablesSystem.drawConsumable(
            item.data.consumable,
            itemX, itemY,
            itemWidth, itemHeight,
            isHovered,
            item.data.count
        )

        -- Draw hotkey
        love.graphics.setColor(1, 1, 1, 0.8)
        love.graphics.printf(tostring(i), itemX, itemY + itemHeight + 2, itemWidth, "center")
    end

    -- Draw usage instructions
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.printf("按 1-5 使用道具", x + 10, y + panelHeight - 25, width - 20, "left")

    return panelHeight
end

return ConsumablesSystem