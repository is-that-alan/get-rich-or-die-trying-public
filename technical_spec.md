# Technical Specification: Get Rich or Die Trying

**Version**: 1.0
**Last Updated**: 2025-09-30
**Engine**: LÖVE2D 11.4
**Language**: Lua 5.1

---

## Table of Contents

1. [System Architecture](#1-system-architecture)
2. [Module Specifications](#2-module-specifications)
3. [Data Structures](#3-data-structures)
4. [Algorithms](#4-algorithms)
5. [API Reference](#5-api-reference)
6. [Performance Optimization](#6-performance-optimization)
7. [Asset Management](#7-asset-management)
8. [Build & Deployment](#8-build--deployment)

---

## 1. System Architecture

### 1.1 High-Level Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     LÖVE2D Engine                       │
│  (love.load, love.update, love.draw, love.handlers)    │
└───────────────────────┬─────────────────────────────────┘
                        │
┌───────────────────────▼─────────────────────────────────┐
│                     main.lua                            │
│  • Game State Machine                                   │
│  • Input Handling (mouse, keyboard, Konami codes)      │
│  • Screen Routing                                       │
│  • Developer Tools                                      │
└───┬──────────┬──────────┬─────────┬──────────┬─────────┘
    │          │          │         │          │
┌───▼────┐ ┌──▼─────┐ ┌──▼───┐ ┌──▼─────┐ ┌─▼──────┐
│ Battle │ │Progress│ │ Shop │ │ Event  │ │ Scene  │
│ System │ │ System │ │ System│ │ System │ │ System │
└───┬────┘ └──┬─────┘ └──┬───┘ └──┬─────┘ └─┬──────┘
    │          │          │         │          │
┌───▼──────────▼──────────▼─────────▼──────────▼──────┐
│               Support Systems                        │
│  • Items (Consumables, Relics, Deck Spells)         │
│  • Audio (Music, SFX)                                │
│  • Visual Effects (Juice, Particles, Shake)          │
│  • Atmosphere (Flavor, Weather, Dialogue)            │
│  • Utilities (UTF-8, Card helpers)                   │
└──────────────────────────────────────────────────────┘
```

### 1.2 State Machine

```lua
GameState = {
    "MENU",           -- Main menu
    "STORY_SCENE",    -- Story comic panels
    "PROGRESSION",    -- Card-based path selection
    "BATTLE",         -- Mahjong battle
    "SHOP",           -- Shop UI
    "EVENT",          -- Random event
    "DECK_MODIFIER",  -- Deck spell application
    "VICTORY",        -- Run completed
    "DEFEAT"          -- Run failed
}
```

**Transitions**:
- `MENU` → `STORY_SCENE` → `PROGRESSION`
- `PROGRESSION` → `BATTLE` | `SHOP` | `EVENT` | `STORY_SCENE`
- `BATTLE` → `PROGRESSION` (victory) | `PROGRESSION` (defeat)
- `SHOP` → `PROGRESSION`
- `EVENT` → `PROGRESSION`
- `PROGRESSION` → `VICTORY` (final level) | `DEFEAT` (failed run)

### 1.3 Module Dependency Graph

```
main.lua
├── mahjong_battle.lua
│   ├── mahjong_state.lua
│   ├── mahjong_logic.lua
│   ├── mahjong_ui.lua
│   ├── mahjong_tiles.lua
│   ├── mahjong_deck.lua
│   └── consumables_system.lua
├── progression_screen.lua
│   ├── progression_cards.lua
│   └── progression.lua
├── shop.lua
│   ├── hk_consumables.lua
│   ├── hk_relics.lua
│   └── deck_spells.lua
├── event_screen.lua
├── deck_modifier_screen.lua
├── scene.lua
│   └── dialogue.lua
├── cutin_dialogue.lua
├── music.lua
├── juice.lua
├── hk_flavor.lua
├── weather_system.lua
└── card.lua (legacy utilities)
```

---

## 2. Module Specifications

### 2.1 Core Module: main.lua

**Purpose**: Game loop orchestration, state management, input routing

**Key Functions**:

```lua
function love.load()
    -- Initialize game state
    -- Load assets (font, music, images)
    -- Set up initial screen
end

function love.update(dt)
    -- Update current game state
    -- Route to appropriate update function
    -- Handle Konami code detection
end

function love.draw()
    -- Route to appropriate draw function
    -- Render current screen
end

function love.mousepressed(x, y, button)
    -- Route to appropriate mouse handler
end

function love.keypressed(key)
    -- Handle global keys (ESC, Konami codes)
    -- Route to state-specific handlers
end
```

**State Variables**:

```lua
{
    currentState = "MENU",        -- Current game state
    gameData = { ... },           -- Persistent run data
    playerMoney = 100,            -- Currency
    playerLevel = 1,              -- Run depth
    runDepth = 1,                 -- Same as playerLevel
    relics = {},                  -- Owned relics
    consumables = {},             -- Owned consumables
    deck = {},                    -- Mahjong tile deck
    currentProgressionChoices = {},  -- Active cards
    currentSceneBattleCompleted = false  -- Flag for battles
}
```

### 2.2 Battle System: mahjong_battle.lua

**Purpose**: Battle orchestration, UI rendering, user interactions

**Architecture**:

```lua
MahjongBattle = {
    initialize = function(challengeData, battleType),
    update = function(dt),
    draw = function(mainGameState),
    mousepressed = function(x, y, button, gameState),
    mousemoved = function(x, y, dx, dy),
    mousereleased = function(x, y, button),
    getGameState = function(),
    isBattleOver = function()
}
```

**Battle Flow**:

1. `initialize()`: Setup game state, apply battle config
2. `update(dt)`: Animate tiles, update drag state
3. `draw()`: Render UI (sidebar, main area, help button)
4. `mousepressed()`: Start tile drag
5. `mousemoved()`: Track drag position, update help button hover
6. `mousereleased()`: Drop tile or toggle selection
7. Check win/loss conditions
8. Return to progression on battle end

**Layout System**:

```lua
function calculateLayout(screenWidth, screenHeight)
    return {
        sidebarZone = {
            x = 0,
            y = 0,
            w = screenWidth * 0.3,
            h = screenHeight
        },
        mainZone = {
            x = screenWidth * 0.3,
            y = 0,
            w = screenWidth * 0.7,
            h = screenHeight
        }
    }
end
```

### 2.3 Mahjong Logic: mahjong_logic.lua

**Purpose**: Win pattern detection, fan calculation

**Key Functions**:

```lua
function MahjongLogic.checkWin(hand)
    -- Returns: { isWin, patternName, fan, breakdown }
end

function MahjongLogic.identifyPattern(hand)
    -- Identify specific winning pattern
    -- Return pattern name and fan value
end

function MahjongLogic.hasPair(tiles)
    -- Check for pair (2 identical tiles)
end

function MahjongLogic.hasTriplet(tiles)
    -- Check for triplet/kong (3-4 identical tiles)
end

function MahjongLogic.hasSequence(tiles)
    -- Check for sequence (consecutive numbered tiles)
end
```

**Win Patterns Supported**:

| Pattern | Fan | Logic |
|---------|-----|-------|
| 平糊 | 1 | Any valid 14-tile hand |
| 對對糊 | 3 | All triplets + pair |
| 清一色 | 6 | All same suit |
| 混一色 | 3 | One suit + honors |
| 小三元 | 4 | 2 dragon triplets + dragon pair |
| 大三元 | 8 | All 3 dragon triplets |
| 字一色 | 10 | All honor tiles |
| 清老頭 | 13 | All terminals (1s and 9s) |

**Algorithm**:

```
1. Count tiles (must be 14)
2. Group by suit and rank
3. Check for standard pattern (4 sets + 1 pair)
4. Check for special patterns (all honors, all terminals, etc.)
5. Calculate fan based on pattern
6. Return result
```

### 2.4 Mahjong State: mahjong_state.lua

**Purpose**: Battle state management, tile operations

**State Structure**:

```lua
gameState = {
    -- Core game data
    deck = {},                -- Tile deck
    hand = {},                -- Player's hand
    playArea = {},            -- Submitted sets
    discardPile = {},         -- Discarded tiles

    -- Battle config
    targetFan = 5,            -- Win condition
    maxRounds = 5,            -- Round limit
    currentRound = 1,         -- Current round
    totalFan = 0,             -- Accumulated fan
    score = 0,                -- Score

    -- UI state
    selectedTiles = {},       -- Selected for play
    isDragging = false,       -- Drag state
    draggedTile = nil,        -- Dragged tile
    draggedTileIndex = nil,   -- Index in hand

    -- Battle state
    battleWon = false,
    battleLost = false,
    challengePassed = false,
    challengeFailed = false,
    invalidPlayAttempts = 0,
    maxInvalidAttempts = 3
}
```

**Key Functions**:

```lua
function MahjongState.createInitialState()
    -- Create empty game state
end

function MahjongState.initializeGame(gameState)
    -- Setup deck, shuffle, draw initial hand
end

function MahjongState.drawTiles(gameState, count)
    -- Draw tiles from deck to hand
end

function MahjongState.submitHand(gameState)
    -- Validate hand, calculate fan, update state
end

function MahjongState.advanceRound(gameState)
    -- Move to next round, check win/loss
end
```

### 2.5 Progression System: progression_screen.lua

**Purpose**: Card-based path selection UI

**Card Structure**:

```lua
{
    type = "combat" | "shop" | "event" | "elite" | "boss",
    title = "深水埗街市挑戰",
    description = "與街市麻雀高手對決",
    subtitle = "基礎難度",
    data = {
        difficulty = "easy",
        location = "深水埗",
        reward = {
            money = 50,
            xp = 10,
            relic = false
        }
    }
}
```

**Key Functions**:

```lua
function ProgressionScreen.init(gameState)
    -- Generate or load progression choices
end

function ProgressionScreen.draw(gameState)
    -- Render card choices
end

function ProgressionScreen.mousepressed(x, y, button, gameState)
    -- Handle card selection
    -- Execute choice
    -- Transition to encounter
end
```

### 2.6 Item Systems

#### 2.6.1 Consumables: hk_consumables.lua

**Structure**:

```lua
{
    id = "milk_tea",
    name = "港式奶茶",
    displayName = "港式奶茶 (HK Milk Tea)",
    description = "香滑可口嘅奶茶，俾你回復精神",
    price = 30,
    rarity = "common",
    category = "cha_chaan_teng",
    icon = "images/consumables/milk_tea.png",
    effect = function(gameState)
        -- Draw 2 extra tiles
        MahjongState.drawTiles(gameState, 2)
    end
}
```

#### 2.6.2 Relics: hk_relics.lua

**Structure**:

```lua
{
    id = "loyalty_card",
    name = "茶餐廳儲印花卡",
    description = "每場戰鬥後獲得額外 $10",
    rarity = "basic",
    minLevel = 1,
    effect = {
        type = "post_battle",
        value = 10
    },
    apply = function(gameState)
        -- Called after battle
        gameState.playerMoney = gameState.playerMoney + 10
    end
}
```

### 2.7 Scene System: scene.lua

**Scene Structure**:

```lua
{
    id = "intro",
    panels = {
        {
            image = "images/scenes/intro/panel1.jpg",
            text = "1997年，回歸之後...",
            music = "intro_theme.mp3"
        },
        ...
    },
    onComplete = function(gameState)
        -- Trigger next action
    end
}
```

**Key Functions**:

```lua
function Scene.load(sceneId)
    -- Load scene data
end

function Scene.start(sceneId, gameState)
    -- Begin scene playback
end

function Scene.update(dt)
    -- Animate panels, handle transitions
end

function Scene.draw()
    -- Render current panel
end

function Scene.advance()
    -- Move to next panel or complete
end
```

### 2.8 Cut-in Dialogue: cutin_dialogue.lua

**Dialogue Structure**:

```lua
{
    id = "battle_big_win",
    character = "player",
    text = "贏咗！",
    image = "images/characters/player_happy.png",
    duration = 2.0,
    sfx = "victory_cheer.wav",
    bgm_change = "victory_fanfare.mp3"
}
```

**Animation States**:
1. **FADE_IN** (0.3s): Character slides in from bottom-left, fades in
2. **DISPLAY** (duration): Hold on screen
3. **FADE_OUT** (0.3s): Fade out and slide down

**Trigger System**:

```lua
CutinDialogue.trigger("battle_big_win")
```

---

## 3. Data Structures

### 3.1 Tile Representation

```lua
Tile = {
    suit = "dots" | "bamboo" | "characters" | "winds" | "dragons",
    rank = 1-9 (numbered) | "east" | "south" | "west" | "north" (winds) |
           "red" | "green" | "white" (dragons),
    id = "dots_5",      -- Unique identifier
    display = "5筒",    -- Display string
    unicode = "🀙",     -- Unicode representation (optional)
    image = Drawable    -- LÖVE2D image (if using graphics)
}
```

### 3.2 Game State (Main)

```lua
mainGameState = {
    currentState = "MENU",
    playerMoney = 100,
    playerLevel = 1,
    runDepth = 1,
    maxDepth = 20,

    -- Inventory
    relics = {},          -- Array of relic IDs
    consumables = {},     -- Array of { id, count }
    deck = {},            -- Array of tiles

    -- Progression
    currentProgressionChoices = {},
    currentSceneBattleCompleted = false,

    -- Story
    storyProgress = {
        loop = 1,
        chapter = 1,
        karma = 50
    },

    -- Settings
    settings = {
        volume = 0.5,
        showDebug = false
    }
}
```

### 3.3 Battle State

See [2.4 Mahjong State](#24-mahjong-state-mahjong_statelua)

---

## 4. Algorithms

### 4.1 Mahjong Win Detection

**Problem**: Determine if 14 tiles form a valid winning hand

**Standard Pattern**: 4 sets + 1 pair
- **Set**: Triplet (3 identical) or Sequence (3 consecutive same-suit)
- **Pair**: 2 identical tiles

**Algorithm** (Recursive Backtracking):

```lua
function checkStandardWin(tiles)
    -- Base case: 0 tiles remaining
    if #tiles == 0 then return true end

    -- Try to form a pair (if no pair found yet)
    if not pairFound then
        for each unique tile do
            if count >= 2 then
                remove pair
                if checkStandardWin(remaining) then
                    return true
                end
                restore pair
            end
        end
    end

    -- Try to form a triplet
    for each unique tile do
        if count >= 3 then
            remove triplet
            if checkStandardWin(remaining) then
                return true
            end
            restore triplet
        end
    end

    -- Try to form a sequence
    if tile is numbered then
        if tiles contain [n, n+1, n+2] of same suit then
            remove sequence
            if checkStandardWin(remaining) then
                return true
            end
            restore sequence
        end
    end

    return false
end
```

**Optimization**: Memoization for repeated tile configurations

**Special Patterns**: Checked separately (all honors, all terminals, etc.)

### 4.2 Fan Calculation

**Algorithm**:

```
1. Identify winning pattern
2. Check for pure flush (清一色): All same suit → +6 fan
3. Check for all triplets (對對糊): No sequences → +3 fan
4. Check for dragons:
   - All 3 dragon triplets (大三元) → +8 fan
   - 2 dragon triplets + 1 pair (小三元) → +4 fan
5. Check for honors:
   - All honors (字一色) → +10 fan
6. Check for terminals:
   - All 1s and 9s (清老頭) → +13 fan
7. Return total fan
```

### 4.3 Card Generation (Progression)

**Algorithm**:

```lua
function generateProgression(gameState)
    local level = gameState.runDepth
    local choices = {}

    -- Determine card types based on level
    local pool = {}
    if level < 5 then
        pool = { "combat" (50%), "shop" (25%), "event" (25%) }
    elseif level < 15 then
        pool = { "combat" (40%), "shop" (20%), "event" (20%), "elite" (15%), "boss" (5%) }
    else
        pool = { "combat" (30%), "shop" (15%), "event" (15%), "elite" (25%), "boss" (15%) }
    end

    -- Generate 3-4 unique cards
    for i = 1, math.random(3, 4) do
        local cardType = selectWeighted(pool)
        local card = createCard(cardType, level)
        table.insert(choices, card)
    end

    return choices
end
```

### 4.4 Deck Shuffling

**Fisher-Yates Shuffle**:

```lua
function shuffle(deck)
    for i = #deck, 2, -1 do
        local j = math.random(1, i)
        deck[i], deck[j] = deck[j], deck[i]
    end
end
```

---

## 5. API Reference

### 5.1 MahjongBattle API

```lua
MahjongBattle.initialize(challengeData, battleType)
-- challengeData: { targetFan, hands, name, battleType }
-- battleType: "normal" | "challenge" | "boss"

MahjongBattle.update(dt)
-- dt: delta time in seconds

MahjongBattle.draw(mainGameState)
-- mainGameState: main game state table

MahjongBattle.getGameState()
-- Returns: current battle state

MahjongBattle.isBattleOver()
-- Returns: boolean (true if won or lost)
```

### 5.2 MahjongLogic API

```lua
MahjongLogic.checkWin(hand)
-- hand: array of 14 tiles
-- Returns: { isWin, patternName, fan, breakdown }

MahjongLogic.validateHand(hand)
-- Returns: boolean (true if 14 tiles and valid types)
```

### 5.3 ProgressionCards API

```lua
ProgressionCards.generateProgression(gameState)
-- Returns: array of card objects

ProgressionCards.executeChoice(gameState, choice)
-- choice: selected card
-- Returns: string (result message)

ProgressionCards.checkLevelTransition(gameState)
-- Returns: sceneId | nil
```

### 5.4 ConsumablesSystem API

```lua
ConsumablesSystem.useConsumable(consumableId, gameState)
-- Executes consumable effect
-- Returns: boolean (success)

ConsumablesSystem.addConsumable(gameState, consumableId, count)
-- Adds to inventory

ConsumablesSystem.getAvailableConsumables(gameState)
-- Returns: array of consumable objects
```

### 5.5 Scene API

```lua
Scene.start(sceneId, gameState)
-- Begin scene playback

Scene.advance()
-- Move to next panel

Scene.skip()
-- Skip to end of scene

Scene.isComplete()
-- Returns: boolean
```

### 5.6 CutinDialogue API

```lua
CutinDialogue.trigger(dialogueId)
-- Show cut-in dialogue

CutinDialogue.update(dt)
-- Update animation state

CutinDialogue.draw()
-- Render dialogue

CutinDialogue.isActive()
-- Returns: boolean
```

---

## 6. Performance Optimization

### 6.1 Rendering Optimizations

**Technique**: Minimize love.graphics state changes

```lua
-- Bad: State change per draw call
for i, tile in ipairs(tiles) do
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(tile.image, tile.x, tile.y)
end

-- Good: Batch state changes
love.graphics.setColor(1, 1, 1)
for i, tile in ipairs(tiles) do
    love.graphics.draw(tile.image, tile.x, tile.y)
end
```

**Technique**: Use sprite batches for many tiles

```lua
tileBatch = love.graphics.newSpriteBatch(tileImage, 1000)
tileBatch:clear()
for i, tile in ipairs(tiles) do
    tileBatch:add(quad, tile.x, tile.y)
end
love.graphics.draw(tileBatch)
```

### 6.2 Memory Management

**Technique**: Release assets when not needed

```lua
function love.quit()
    -- Release large assets
    for k, v in pairs(images) do
        if v.release then v:release() end
    end
end
```

**Technique**: Avoid table creation in loops

```lua
-- Bad
for i = 1, 1000 do
    local temp = { x = i, y = i }
    process(temp)
end

-- Good
local temp = {}
for i = 1, 1000 do
    temp.x = i
    temp.y = i
    process(temp)
end
```

### 6.3 Algorithm Optimizations

**Technique**: Memoize expensive calculations

```lua
local winCache = {}

function checkWinCached(hand)
    local key = serializeHand(hand)
    if winCache[key] then
        return winCache[key]
    end

    local result = checkWin(hand)
    winCache[key] = result
    return result
end
```

**Technique**: Early exit conditions

```lua
function checkWin(hand)
    -- Fast fail
    if #hand ~= 14 then return false end
    if not hasValidTiles(hand) then return false end

    -- Expensive check
    return checkStandardPattern(hand)
end
```

---

## 7. Asset Management

### 7.1 File Organization

```
get-rich-or-die-trying/
├── images/
│   ├── consumables/
│   │   ├── milk_tea.png
│   │   ├── pineapple_bun.png
│   │   └── ...
│   ├── characters/
│   │   ├── player_happy.png
│   │   └── ...
│   ├── scenes/
│   │   ├── intro/
│   │   │   ├── panel1.jpg
│   │   │   └── ...
│   │   └── ...
│   └── tiles/
│       ├── dots_1.png
│       └── ...
├── sounds/
│   ├── music/
│   │   ├── battle_theme.mp3
│   │   └── ...
│   └── sfx/
│       ├── tile_click.wav
│       └── ...
└── NotoSansCJK-Regular.ttc
```

### 7.2 Asset Loading

**Lazy Loading**:

```lua
local images = {}

function getImage(path)
    if not images[path] then
        images[path] = love.graphics.newImage(path)
    end
    return images[path]
end
```

**Font Loading**:

```lua
function love.load()
    _G.CHINESE_FONT_PATH = "NotoSansCJK-Regular.ttc"
    chineseFont = love.graphics.newFont(_G.CHINESE_FONT_PATH, 16)
    love.graphics.setFont(chineseFont)
end
```

### 7.3 Audio Management

```lua
Music = {
    bgm = nil,
    sfx = {},

    playBGM = function(filename)
        if Music.bgm then Music.bgm:stop() end
        Music.bgm = love.audio.newSource("sounds/music/" .. filename, "stream")
        Music.bgm:setLooping(true)
        Music.bgm:play()
    end,

    playSFX = function(name)
        if not Music.sfx[name] then
            Music.sfx[name] = love.audio.newSource("sounds/sfx/" .. name .. ".wav", "static")
        end
        Music.sfx[name]:play()
    end
}
```

---

## 8. Build & Deployment

### 8.1 Development Build

```bash
# Run directly
love .

# With hot reload (lick.lua)
love .  # Auto-reloads on file changes
```

### 8.2 Production Build

**macOS**:

```bash
# Create .app bundle
cp -r /Applications/love.app "Get Rich or Die Trying.app"
zip -r game.zip *.lua *.md images/ sounds/ NotoSansCJK-Regular.ttc
cp game.zip "Get Rich or Die Trying.app/Contents/Resources/game.love"
rm game.zip
```

**Windows**:

```bash
# Create .exe
zip -r game.love *.lua *.md images/ sounds/ NotoSansCJK-Regular.ttc
copy /b love.exe+game.love "Get Rich or Die Trying.exe"
```

**Linux**:

```bash
# Create .AppImage or tar.gz
zip -r game.love *.lua *.md images/ sounds/ NotoSansCJK-Regular.ttc
cat love game.love > "get-rich-or-die-trying"
chmod +x "get-rich-or-die-trying"
```

### 8.3 Release Checklist

- [ ] Disable debug features (Konami codes optional)
- [ ] Disable hot reload (lick.lua)
- [ ] Test on all target platforms
- [ ] Verify all assets included
- [ ] Check font file included
- [ ] Test cold start performance
- [ ] Verify no console output (except intentional)
- [ ] Package with README.md
- [ ] Create installer/DMG (optional)

### 8.4 Version Management

**Semantic Versioning**: MAJOR.MINOR.PATCH

- **MAJOR**: Breaking changes (gameplay overhaul)
- **MINOR**: New features (new items, story chapters)
- **PATCH**: Bug fixes, balance tweaks

**Version Location**: `conf.lua`

```lua
function love.conf(t)
    t.version = "11.4"
    t.window.title = "Get Rich or Die Trying v1.0.0"
    t.identity = "get-rich-or-die-trying"
end
```

---

## 9. Testing Strategy

### 9.1 Unit Tests

**Manual Testing** (no test framework):

```lua
-- Test mahjong logic
function testCheckWin()
    local hand = {
        -- Define test hand
    }
    local result = MahjongLogic.checkWin(hand)
    assert(result.isWin == true, "Should detect win")
    assert(result.fan == 3, "Should calculate 3 fan")
end
```

### 9.2 Integration Tests

**Scenarios**:
- Complete battle start to finish
- Purchase item in shop and use in battle
- Trigger event and verify outcome
- Play through progression screen to battle

### 9.3 Playtesting

**Focus Areas**:
- Difficulty curve (is progression fair?)
- Cultural authenticity (do phrases feel natural?)
- Performance (any FPS drops?)
- Balance (are relics/consumables useful?)

---

## 10. Known Issues & Limitations

### 10.1 Current Limitations

1. **No Save System**: Runs cannot be saved mid-session
2. **No Undo**: Cannot undo battle actions (except with consumable)
3. **No Multiplayer**: Single-player only
4. **Limited Localization**: Chinese only (no English)
5. **Desktop Only**: No mobile support

### 10.2 Legacy Code

**Deprecated Modules** (kept for compatibility):
- `battle.lua`: Old fortress battle system
- `fortress.lua`: Old base building
- `challenge.lua`: Old challenge mode

**Status**: Not used in main game loop, safe to ignore

### 10.3 Technical Debt

- **Mahjong Logic**: Could be optimized with better memoization
- **State Management**: Some global state could be encapsulated
- **Error Handling**: Limited error messages for invalid states
- **Asset Loading**: No progress bar for initial load

---

**Technical Specification Complete**

This document provides implementation details for all major systems in **Get Rich or Die Trying**. For high-level design, see `design.md`. For requirements, see `requirements.md`.