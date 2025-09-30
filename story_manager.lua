-- Story Manager
-- Handles sequence of scenes, shops, and battles with optional shop visits

local StoryManager = {}
local Scene = require("scene")

-- Story sequence definition (shops are now optional points)
local storySequence = {
    {type = "scene", name = "intro"},
    {type = "choice_shop", next = "battle", opponent = "Level 1 Opponent"},
    {type = "scene", name = "level1_to_level2"},
    {type = "choice_shop", next = "battle", opponent = "Level 2 Opponent"},
    {type = "scene", name = "level2_mid"},
    {type = "scene", name = "level2_to_level3"},
    {type = "choice_shop", next = "battle", opponent = "Level 3 Opponent"},
    {type = "scene", name = "level3_mid"},
    {type = "scene", name = "level3_end"}
}

function StoryManager.init(gameState)
    gameState.storyProgress = 0
end

function StoryManager.advance(gameState)
    gameState.storyProgress = gameState.storyProgress + 1
    StoryManager.loadNext(gameState)
end

function StoryManager.loadNext(gameState)
    local step = storySequence[gameState.storyProgress + 1]  -- +1 because progress starts at 0
    if not step then
        gameState.screen = "menu"  -- End of story
        return
    end

    if step.type == "scene" then
        if Scene.loadScene(step.name) then
            Scene.onSceneComplete = function()
                StoryManager.advance(gameState)
            end
            Scene.onSceneExit = function()
                gameState.screen = "menu"
            end
            gameState.screen = "scene"
        else
            print("Failed to load scene: " .. step.name)
            gameState.screen = "menu"
        end
    elseif step.type == "choice_shop" then
        -- Show choice screen
        StoryManager.showShopChoice(gameState, step.next, step.opponent)
    elseif step.type == "shop" then
        gameState.screen = "shop"
        local Shop = require("shop")
        Shop.init(gameState.level or 1)
        -- Set shop exit to advance
        -- Assuming shop has an onExit callback, set it here
    elseif step.type == "battle" then
        gameState.screen = "mahjong_battle"
        local MahjongBattle = require("mahjong_battle")
        MahjongBattle.init(gameState, nil, "normal")  -- Assuming normal battle type
        -- Set battle exit to advance
    end
end

-- Simple choice screen for shop visit
function StoryManager.showShopChoice(gameState, nextType, nextParam)
    gameState.screen = "choice"
    gameState.choiceOptions = {
        {text = "Visit Shop", action = function()
            -- Go to shop, then to next
            gameState.screen = "shop"
            local Shop = require("shop")
            Shop.init(gameState.level or 1)
            -- Set shop onExit to load the next (battle)
            -- Assuming Shop has onExit, but you may need to implement it
            Shop.onExit = function()
                if nextType == "battle" then
                    gameState.screen = "mahjong_battle"
                    local MahjongBattle = require("mahjong_battle")
                    MahjongBattle.init(gameState, nil, "normal", nextParam)
                end
                StoryManager.advance(gameState)
            end
        end},
        {text = "Proceed to Battle", action = function()
            -- Directly to battle
            if nextType == "battle" then
                gameState.screen = "mahjong_battle"
                local MahjongBattle = require("mahjong_battle")
                MahjongBattle.init(gameState, nil, "normal", nextParam)
            end
            StoryManager.advance(gameState)
        end}
    }
end

-- You may need to implement the "choice" screen in main.lua or a separate choice.lua to display buttons for choices.

return StoryManager
