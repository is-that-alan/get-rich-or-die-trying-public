-- Hong Kong Meme Cards System

local HKMemeCards = {}

-- Meme Card Database (sorted by rarity and authenticity)
HKMemeCards.DATABASE = {
    -- {
    --     id = "octopus_card",
    --     name = "八達通",
    --     nameEng = "Octopus Card",
    --     description = "增加1張牌，搭車都慳時間",
    --     effect = function(gameState)
    --         gameState.hand = gameState.hand or {}
    --         local MahjongDeck = require("mahjong_deck")
    --         table.insert(gameState.hand, MahjongDeck.drawTile(gameState.deck))
    --     end,
    --     rarity = "common",
    --     price = 25,
    --     category = "transport"
    -- }
}

-- Get meme cards by rarity
function HKMemeCards.getCardsByRarity(rarity)
    local cards = {}
    for _, card in ipairs(HKMemeCards.DATABASE) do
        if card.rarity == rarity then
            table.insert(cards, card)
        end
    end
    return cards
end

-- Get random meme card
function HKMemeCards.getRandomCard()
    return HKMemeCards.DATABASE[math.random(#HKMemeCards.DATABASE)]
end

-- Get meme card by ID
function HKMemeCards.getCard(id)
    for _, card in ipairs(HKMemeCards.DATABASE) do
        if card.id == id then
            return card
        end
    end
    return nil
end

-- Use meme card effect
function HKMemeCards.useCard(gameState, cardId)
    local card = HKMemeCards.getCard(cardId)
    if card and card.effect then
        card.effect(gameState)
        return true, card.name .. " 發動！"
    end
    return false, "搵唔到呢張卡"
end

-- Generate shop inventory with Hong Kong flavor
function HKMemeCards.generateShopInventory(playerLevel)
    local inventory = {}
    playerLevel = playerLevel or 1

    -- Common cards (60% chance)
    for i = 1, 3 do
        if math.random() < 0.6 then
            local commonCards = HKMemeCards.getCardsByRarity("common")
            if #commonCards > 0 then
                table.insert(inventory, commonCards[math.random(#commonCards)])
            end
        end
    end

    -- Uncommon cards (30% chance)
    for i = 1, 2 do
        if math.random() < 0.3 then
            local uncommonCards = HKMemeCards.getCardsByRarity("uncommon")
            if #uncommonCards > 0 then
                table.insert(inventory, uncommonCards[math.random(#uncommonCards)])
            end
        end
    end

    -- Rare cards (8% chance, level-gated)
    if playerLevel >= 3 and math.random() < 0.08 then
        local rareCards = HKMemeCards.getCardsByRarity("rare")
        if #rareCards > 0 then
            table.insert(inventory, rareCards[math.random(#rareCards)])
        end
    end

    -- Epic cards (2% chance, high level only)
    if playerLevel >= 5 and math.random() < 0.02 then
        local epicCards = HKMemeCards.getCardsByRarity("epic")
        if #epicCards > 0 then
            table.insert(inventory, epicCards[math.random(#epicCards)])
        end
    end

    return inventory
end

return HKMemeCards