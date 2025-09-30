-- Spell Card System for Deck Modifications
-- Hong Kong themed spell cards that permanently modify the player's deck

local SpellCards = {}

-- Spell card definitions
SpellCards.SPELL_CARDS = {
    -- === 基礎改造系列 (Basic Modification Series) ===
    {
        id = "suit_converter",
        name = "花色轉換咒",
        nameEng = "Suit Converter Spell",
        description = "將3隻同數字不同花色牌轉換成同花色",
        descriptionEng = "Convert 3 tiles of same number but different suits to same suit",
        price = 150,
        rarity = "uncommon",
        category = "conversion",
        type = "spell_card",
        effect = function(playerDeck)
            -- Find tiles with same number but different suits and convert them
            local conversions = 0
            local numbers = {}

            -- Count tiles by number
            for _, tile in ipairs(playerDeck) do
                if tile.value then
                    numbers[tile.value] = numbers[tile.value] or {}
                    table.insert(numbers[tile.value], tile)
                end
            end

            -- Convert sets of 3+ same numbers to same suit
            for num, tiles in pairs(numbers) do
                if #tiles >= 3 then
                    local targetSuit = tiles[1].suit
                    for i = 2, 3 do
                        tiles[i].suit = targetSuit
                        conversions = conversions + 1
                    end
                end
            end

            return conversions > 0 and "轉換了 " .. conversions .. " 隻牌的花色！" or "沒有可轉換的牌"
        end
    },

    {
        id = "honor_blessing",
        name = "字牌祝福",
        nameEng = "Honor Tile Blessing",
        description = "隨機3隻牌轉換成字牌(風/龍)",
        descriptionEng = "Convert 3 random tiles to honor tiles (winds/dragons)",
        price = 200,
        rarity = "rare",
        category = "enhancement",
        type = "spell_card",
        effect = function(playerDeck)
            local honors = {"東", "南", "西", "北", "中", "發", "白"}
            local converted = 0

            -- Find non-honor tiles to convert
            local nonHonors = {}
            for i, tile in ipairs(playerDeck) do
                if tile.suit ~= "winds" and tile.suit ~= "dragons" then
                    table.insert(nonHonors, {tile = tile, index = i})
                end
            end

            -- Convert up to 3 tiles
            for i = 1, math.min(3, #nonHonors) do
                local randomIndex = math.random(#nonHonors)
                local chosen = nonHonors[randomIndex]
                local honorSuit = honors[math.random(#honors)]

                -- Convert to honor tile
                if honorSuit == "東" or honorSuit == "南" or honorSuit == "西" or honorSuit == "北" then
                    chosen.tile.suit = "winds"
                    chosen.tile.value = honorSuit
                else
                    chosen.tile.suit = "dragons"
                    chosen.tile.value = honorSuit
                end

                converted = converted + 1
                table.remove(nonHonors, randomIndex)
            end

            return "轉換了 " .. converted .. " 隻牌成字牌！"
        end
    },

    {
        id = "deck_purify",
        name = "牌組淨化",
        nameEng = "Deck Purification",
        description = "移除5隻最低價值的牌",
        descriptionEng = "Remove 5 lowest value tiles from deck",
        price = 120,
        rarity = "uncommon",
        category = "removal",
        type = "spell_card",
        effect = function(playerDeck)
            -- Sort tiles by value (lowest first)
            local sortedTiles = {}
            for i, tile in ipairs(playerDeck) do
                table.insert(sortedTiles, {tile = tile, index = i, value = tile.points or tile.value or 1})
            end

            table.sort(sortedTiles, function(a, b) return a.value < b.value end)

            -- Remove up to 5 lowest value tiles
            local removed = 0
            for i = 1, math.min(5, #sortedTiles) do
                for j = #playerDeck, 1, -1 do
                    if playerDeck[j] == sortedTiles[i].tile then
                        table.remove(playerDeck, j)
                        removed = removed + 1
                        break
                    end
                end
            end

            return "移除了 " .. removed .. " 隻低價值牌！"
        end
    },

    -- === 進階改造系列 (Advanced Modification Series) ===
    {
        id = "dragon_ascension",
        name = "飛龍昇天",
        nameEng = "Dragon Ascension",
        description = "將所有9隻牌轉換成龍牌",
        descriptionEng = "Convert all 9-tiles to dragon tiles",
        price = 300,
        rarity = "epic",
        category = "transformation",
        type = "spell_card",
        effect = function(playerDeck)
            local dragons = {"中", "發", "白"}
            local converted = 0

            for _, tile in ipairs(playerDeck) do
                if tile.value == 9 then
                    tile.suit = "dragons"
                    tile.value = dragons[math.random(#dragons)]
                    converted = converted + 1
                end
            end

            return "轉換了 " .. converted .. " 隻九隻牌成龍牌！"
        end
    },

    {
        id = "feng_shui_master",
        name = "風水大師",
        nameEng = "Feng Shui Master",
        description = "重新安排牌組，優化組合搭配",
        descriptionEng = "Rearrange deck for optimal combinations",
        price = 250,
        rarity = "rare",
        category = "optimization",
        type = "spell_card",
        effect = function(playerDeck)
            -- Create more sequential and matching tiles
            local suits = {"characters", "circles", "bamboos"}
            local optimized = 0

            -- Group tiles by suit
            local suitGroups = {}
            for _, tile in ipairs(playerDeck) do
                if tile.suit == "characters" or tile.suit == "circles" or tile.suit == "bamboos" then
                    suitGroups[tile.suit] = suitGroups[tile.suit] or {}
                    table.insert(suitGroups[tile.suit], tile)
                end
            end

            -- Optimize each suit group to create better sequences
            for suit, tiles in pairs(suitGroups) do
                if #tiles >= 3 then
                    -- Sort by value
                    table.sort(tiles, function(a, b) return (a.value or 1) < (b.value or 1) end)

                    -- Create sequences where possible
                    for i = 1, #tiles - 2 do
                        if tiles[i].value and tiles[i+1].value and tiles[i+2].value then
                            if tiles[i+2].value - tiles[i].value > 2 then
                                -- Adjust middle tile to create sequence
                                tiles[i+1].value = tiles[i].value + 1
                                optimized = optimized + 1
                            end
                        end
                    end
                end
            end

            return "優化了 " .. optimized .. " 個組合！風水改運"
        end
    },

    -- === 傳奇改造系列 (Legendary Modification Series) ===
    {
        id = "mahjong_god_blessing",
        name = "麻將神祝福",
        nameEng = "Mahjong God's Blessing",
        description = "添加3隻萬能牌到牌組",
        descriptionEng = "Add 3 universal tiles to deck",
        price = 500,
        rarity = "legendary",
        category = "addition",
        type = "spell_card",
        effect = function(playerDeck)
            -- Add 3 special universal tiles
            local universalTile = {
                id = "universal",
                suit = "special",
                value = "universal",
                symbol = "🃏",
                name = "萬能牌",
                points = 50,
                isUniversal = true
            }

            for i = 1, 3 do
                table.insert(playerDeck, universalTile)
            end

            return "獲得3隻萬能牌！麻將神保佑"
        end
    },

    {
        id = "deck_duplicate",
        name = "牌組複製術",
        nameEng = "Deck Duplication Spell",
        description = "複製牌組中最好的5隻牌",
        descriptionEng = "Duplicate the 5 best tiles in your deck",
        price = 400,
        rarity = "epic",
        category = "duplication",
        type = "spell_card",
        effect = function(playerDeck)
            -- Sort tiles by value (highest first)
            local sortedTiles = {}
            for _, tile in ipairs(playerDeck) do
                table.insert(sortedTiles, tile)
            end

            table.sort(sortedTiles, function(a, b)
                return (a.points or a.value or 1) > (b.points or b.value or 1)
            end)

            -- Duplicate top 5 tiles
            local duplicated = 0
            for i = 1, math.min(5, #sortedTiles) do
                local copy = {}
                for k, v in pairs(sortedTiles[i]) do
                    copy[k] = v
                end
                table.insert(playerDeck, copy)
                duplicated = duplicated + 1
            end

            return "複製了 " .. duplicated .. " 隻最好的牌！"
        end
    },

    -- === 特殊系列 (Special Series) ===
    {
        id = "hk_culture_infusion",
        name = "港式文化注入",
        nameEng = "HK Culture Infusion",
        description = "隨機牌獲得香港特色效果",
        descriptionEng = "Random tiles gain Hong Kong special effects",
        price = 180,
        rarity = "rare",
        category = "special",
        type = "spell_card",
        effect = function(playerDeck)
            local hkEffects = {
                "cha_chaan_teng_boost", "dim_sum_power", "yum_cha_luck",
                "tram_connection", "harbor_blessing", "skyline_view"
            }

            local enhanced = 0
            for i = 1, math.min(6, #playerDeck) do
                local randomIndex = math.random(#playerDeck)
                local tile = playerDeck[randomIndex]

                if not tile.hkEffect then
                    tile.hkEffect = hkEffects[math.random(#hkEffects)]
                    enhanced = enhanced + 1
                end
            end

            return "為 " .. enhanced .. " 隻牌注入香港文化！"
        end
    }
}

-- Get spell cards by rarity
function SpellCards.getSpellCardsByRarity(rarity)
    local cards = {}
    for _, card in ipairs(SpellCards.SPELL_CARDS) do
        if card.rarity == rarity then
            table.insert(cards, card)
        end
    end
    return cards
end

-- Get random spell cards for shop
function SpellCards.generateShopSpellCards(playerLevel)
    local availableCards = {}

    -- Determine available rarities based on player level
    local rarityChances = {
        common = 50,
        uncommon = 30,
        rare = 15,
        epic = 4,
        legendary = 1
    }

    -- Adjust chances based on player level
    if playerLevel >= 3 then
        rarityChances.rare = 25
        rarityChances.epic = 8
    end
    if playerLevel >= 5 then
        rarityChances.epic = 15
        rarityChances.legendary = 3
    end

    for _, card in ipairs(SpellCards.SPELL_CARDS) do
        local chance = rarityChances[card.rarity] or 0
        if math.random(100) <= chance then
            table.insert(availableCards, card)
        end
    end

    return availableCards
end

-- Apply spell card effect to player deck
function SpellCards.useSpellCard(spellCard, playerDeck)
    if not spellCard or not spellCard.effect or not playerDeck then
        return false, "無效的咒文卡"
    end

    local success, result = pcall(spellCard.effect, playerDeck)

    if success then
        return true, result or "咒文生效！"
    else
        return false, "咒文施放失敗: " .. tostring(result)
    end
end

-- Get spell card by ID
function SpellCards.getSpellCardById(id)
    for _, card in ipairs(SpellCards.SPELL_CARDS) do
        if card.id == id then
            return card
        end
    end
    return nil
end

-- Get all spell cards
function SpellCards.getAllSpellCards()
    return SpellCards.SPELL_CARDS
end

return SpellCards