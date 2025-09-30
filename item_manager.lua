-- Item Manager - Handles usage of spell cards and battle consumables
local ItemManager = {}

local SpellCards = require("spell_cards")
local BattleConsumables = require("battle_consumables")

-- Use spell card on player deck (outside of battle)
function ItemManager.useSpellCard(gameState, spellCardId)
    if not gameState.playerSpellCards then
        return false, "沒有咒文卡收藏"
    end

    -- Find the spell card
    local spellCard = nil
    local cardIndex = nil

    for i, card in ipairs(gameState.playerSpellCards) do
        if card.id == spellCardId then
            spellCard = card
            cardIndex = i
            break
        end
    end

    if not spellCard then
        return false, "找不到指定的咒文卡"
    end

    -- Apply spell card effect to player deck
    local success, message = SpellCards.useSpellCard(spellCard, gameState.playerDeck or {})

    if success then
        -- Remove spell card from collection (one-time use)
        table.remove(gameState.playerSpellCards, cardIndex)
        return true, "咒文卡生效: " .. message
    else
        return false, "咒文卡施放失敗: " .. message
    end
end

-- Use battle consumable during battle
function ItemManager.useBattleConsumable(gameState, battleState, consumableId)
    if not gameState.playerBattleConsumables then
        return false, "沒有戰鬥道具收藏"
    end

    -- Find the battle consumable
    local consumable = nil
    local itemIndex = nil

    for i, item in ipairs(gameState.playerBattleConsumables) do
        if item.id == consumableId then
            consumable = item
            itemIndex = i
            break
        end
    end

    if not consumable then
        return false, "找不到指定的戰鬥道具"
    end

    -- Apply battle consumable effect
    local success, message = BattleConsumables.useBattleConsumable(consumable, gameState, battleState)

    if success then
        -- Remove consumable from collection (one-time use)
        table.remove(gameState.playerBattleConsumables, itemIndex)
        return true, "戰鬥道具生效: " .. message
    else
        return false, "戰鬥道具使用失敗: " .. message
    end
end

-- Get available spell cards for UI display
function ItemManager.getAvailableSpellCards(gameState)
    if not gameState.playerSpellCards then
        return {}
    end

    local availableCards = {}
    for _, card in ipairs(gameState.playerSpellCards) do
        table.insert(availableCards, {
            id = card.id,
            name = card.name,
            description = card.description,
            rarity = card.rarity,
            category = card.category
        })
    end

    return availableCards
end

-- Get available battle consumables for UI display
function ItemManager.getAvailableBattleConsumables(gameState)
    if not gameState.playerBattleConsumables then
        return {}
    end

    local availableItems = {}
    for _, item in ipairs(gameState.playerBattleConsumables) do
        table.insert(availableItems, {
            id = item.id,
            name = item.name,
            description = item.description,
            rarity = item.rarity,
            category = item.category
        })
    end

    return availableItems
end

-- Quick use battle consumable by hotkey (1-5 keys)
function ItemManager.quickUseBattleConsumable(gameState, battleState, slotNumber)
    local availableConsumables = gameState.playerBattleConsumables or {}

    if slotNumber < 1 or slotNumber > #availableConsumables then
        return false, "沒有道具在插槽 " .. slotNumber
    end

    local consumable = availableConsumables[slotNumber]
    return ItemManager.useBattleConsumable(gameState, battleState, consumable.id)
end

-- Initialize player inventories if they don't exist
function ItemManager.initializeInventories(gameState)
    gameState.playerSpellCards = gameState.playerSpellCards or {}
    gameState.playerBattleConsumables = gameState.playerBattleConsumables or {}
    gameState.playerDeck = gameState.playerDeck or {}
    gameState.playerCharacters = gameState.playerCharacters or {}
    gameState.playerModifiers = gameState.playerModifiers or {}
end

-- Get inventory counts for UI
function ItemManager.getInventoryCounts(gameState)
    return {
        spellCards = #(gameState.playerSpellCards or {}),
        battleConsumables = #(gameState.playerBattleConsumables or {}),
        tiles = #(gameState.playerDeck or {}),
        characters = #(gameState.playerCharacters or {}),
        modifiers = #(gameState.playerModifiers or {})
    }
end

-- Check if player can afford spell card or battle consumable
function ItemManager.canAffordItem(gameState, price)
    return (gameState.playerMoney or 0) >= price
end

-- Add starter spell cards and battle consumables for new players
function ItemManager.giveStarterItems(gameState)
    ItemManager.initializeInventories(gameState)

    -- Give 1 basic spell card
    local basicSpellCard = SpellCards.getSpellCardById("deck_purify")
    if basicSpellCard then
        table.insert(gameState.playerSpellCards, basicSpellCard)
    end

    -- Give 2 basic battle consumables
    local basicBattleConsumable1 = BattleConsumables.getBattleConsumableById("luck_incense")
    local basicBattleConsumable2 = BattleConsumables.getBattleConsumableById("tactical_tea")

    if basicBattleConsumable1 then
        table.insert(gameState.playerBattleConsumables, basicBattleConsumable1)
    end
    if basicBattleConsumable2 then
        table.insert(gameState.playerBattleConsumables, basicBattleConsumable2)
    end

    return "獲得初始道具: 咒文卡和戰鬥道具各2件！"
end

-- Preview spell card effects without using them
function ItemManager.previewSpellCardEffect(gameState, spellCardId)
    local spellCard = SpellCards.getSpellCardById(spellCardId)
    if not spellCard then
        return "未知咒文卡"
    end

    -- Estimate what the spell card would do
    local deckSize = #(gameState.playerDeck or {})
    local preview = spellCard.description

    if spellCard.category == "removal" then
        preview = preview .. "\n(預計移除 " .. math.min(5, deckSize) .. " 隻牌)"
    elseif spellCard.category == "conversion" then
        preview = preview .. "\n(預計轉換 3-6 隻牌)"
    elseif spellCard.category == "addition" then
        preview = preview .. "\n(預計添加 1-3 隻特殊牌)"
    end

    return preview
end

-- Sort items by rarity for display
function ItemManager.sortItemsByRarity(items)
    local rarityOrder = {
        common = 1,
        uncommon = 2,
        rare = 3,
        epic = 4,
        legendary = 5
    }

    table.sort(items, function(a, b)
        local aRarity = rarityOrder[a.rarity] or 0
        local bRarity = rarityOrder[b.rarity] or 0
        return aRarity < bRarity
    end)

    return items
end

return ItemManager