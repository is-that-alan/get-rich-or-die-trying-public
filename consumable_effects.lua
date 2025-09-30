-- Consumable Effects System
-- Pluggable effect functions for consumables
local ConsumableEffects = {}

-- Effect function registry
ConsumableEffects.EFFECTS = {}

-- East wind boost - gives extra faan when east wind tiles are played
ConsumableEffects.EFFECTS.east_wind_boost = function(gameState, battleState, value)
    if not battleState then
        return false, "無法激活東風加成"
    end

    -- Set a flag that will be checked during scoring
    battleState.eastWindBoost = (battleState.eastWindBoost or 0) + (value or 1)
    return true, "東風之力激活！東風牌將額外獲得 " .. (value or 1) .. " 番！"
end

-- Enable deck peek - allows seeing upcoming tiles in deck
ConsumableEffects.EFFECTS.enable_deck_peek = function(gameState, battleState, value)
    if not battleState then
        return false, "無法激活窺探功能"
    end

    -- Set a flag to enable deck peeking (infinite use)
    battleState.deckPeekEnabled = true
    return true, "隱形液晶體眼鏡激活！可以窺探牌疊中的牌！"
end

-- Remove battle restrictions
ConsumableEffects.EFFECTS.remove_restrictions = function(gameState, battleState, value)
    if not battleState then
        return false, "無法移除限制"
    end

    -- Remove common battle restrictions
    battleState.restrictionsRemoved = true
    battleState.maxInvalidAttempts = math.huge -- Allow infinite invalid attempts
    battleState.targetFan = 1 -- Lower fan requirement to minimum
    battleState.maxRounds = math.huge -- Allow infinite rounds
    
    return true, "誠實豆沙包生效！所有戰鬥限制已移除！"
end

-- Number only restriction - can only play number tiles but get +5 base faan
ConsumableEffects.EFFECTS.number_only_restriction = function(gameState, battleState, value)
    if not battleState then
        return false, "無法設置限制"
    end

    -- Set restriction to only allow number tiles (no wind/dragon tiles)
    battleState.numberOnlyRestriction = true
    battleState.numberOnlyBaseFaan = value or 5
    
    return true, "冧把降生效！只能打數字牌，但基礎番數+" .. (value or 5) .. "！"
end

-- Change bamboo 5 to bamboo 4 in hand
ConsumableEffects.EFFECTS.change_bamboo_5_to_4 = function(gameState, battleState, value)
    if not battleState or not battleState.hand then
        return false, "無法改變牌：遊戲狀態異常"
    end

    local changedCount = 0
    for _, tile in ipairs(battleState.hand) do
        if tile.suit == "bam" and tile.value == 5 then
            tile.value = 4
            changedCount = changedCount + 1
        end
    end

    -- Always sort hand after modifying tiles
    local MahjongTiles = require("mahjong_tiles")
    battleState.hand = MahjongTiles.sortTiles(battleState.hand)

    if changedCount > 0 then
        return true, "白飯生效！改變了 " .. changedCount .. " 張條子5為條子4！"
    else
        return true, "白飯使用成功，但手牌中沒有條子5"
    end
end

-- Do nothing - troll item
ConsumableEffects.EFFECTS.do_nothing = function(gameState, battleState, value)
    -- This item literally does nothing
    return true, "太陽能電筒發光了... 但沒有其他效果。你被騙了！"
end

-- Copy recent tiles from discard pile or played tiles
ConsumableEffects.EFFECTS.copy_recent_tiles = function(gameState, battleState, value)
    if not battleState or not battleState.hand then
        return false, "無法複製牌：遊戲狀態異常"
    end

    local copyCount = value or 3
    local copiedTiles = {}
    
    -- First try to get tiles from discard pile
    if battleState.discardPile and #battleState.discardPile > 0 then
        local startIndex = math.max(1, #battleState.discardPile - copyCount + 1)
        for i = startIndex, #battleState.discardPile do
            if #copiedTiles < copyCount then
                local tile = battleState.discardPile[i]
                if tile then
                    -- Create a copy of the tile
                    local tileCopy = {
                        suit = tile.suit,
                        value = tile.value,
                        name = tile.name,
                        points = tile.points,
                        image = tile.image
                    }
                    table.insert(copiedTiles, tileCopy)
                    table.insert(battleState.hand, tileCopy)
                end
            end
        end
    end
    
    -- If we need more tiles, try to get from played tiles
    if #copiedTiles < copyCount and battleState.playedTiles and #battleState.playedTiles > 0 then
        local remainingCount = copyCount - #copiedTiles
        local startIndex = math.max(1, #battleState.playedTiles - remainingCount + 1)
        for i = startIndex, #battleState.playedTiles do
            if #copiedTiles < copyCount then
                local tile = battleState.playedTiles[i]
                if tile then
                    -- Create a copy of the tile
                    local tileCopy = {
                        suit = tile.suit,
                        value = tile.value,
                        name = tile.name,
                        points = tile.points,
                        image = tile.image
                    }
                    table.insert(copiedTiles, tileCopy)
                    table.insert(battleState.hand, tileCopy)
                end
            end
        end
    end

    -- Always sort hand after modifying tiles
    local MahjongTiles = require("mahjong_tiles")
    battleState.hand = MahjongTiles.sortTiles(battleState.hand)

    if #copiedTiles > 0 then
        return true, "複製了 " .. #copiedTiles .. " 張牌到手牌！月光寶盒發光！"
    else
        return false, "沒有可複製的牌"
    end
end

-- Execute effect by type
function ConsumableEffects.executeEffect(effectType, gameState, battleState, effectValue)
    local effectFunc = ConsumableEffects.EFFECTS[effectType]
    if effectFunc then
        return effectFunc(gameState, battleState, effectValue)
    else
        return false, "未知的效果類型: " .. tostring(effectType)
    end
end

return ConsumableEffects