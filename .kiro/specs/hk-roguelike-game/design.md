# Design Document

## Overview

**Hong Kong Mahjong Get-Rich-Quick Schemes**
A roguelike deckbuilding game built on authentic **mahjong mechanics** with a Hong Kong cultural twist.
Players must build winning hands (食糊) within a limited number of rounds to reach target **fan** scores.
After each challenge, players earn coins to visit shops, acquire **meme cards** (active powers), **relics** (passives), and **tile-wall mods**.
Difficulty increases step by step, combining simple mechanics with deep strategy.

---

## Architecture

### Technology Stack

* **Framework:** LÖVE2D (Lua)
* **Platform:** Native desktop (Windows, macOS, Linux)
* **Deployment:** Standalone executable or `.love` archive
* **Storage:** File-based save system (JSON format)

### Core Systems

1. **Game State Manager** – Controls screen transitions (menu, battle, shop, event, results).
2. **Tile System** – Manages mahjong tiles, wall generation, shuffling, drawing.
3. **Hand & Meld System** – Stores hand, plays/discards tiles, checks melds (Chow, Pung, Kong, Pair, Seven Pairs).
4. **Scoring System** – Calculates fan, provides detailed breakdown.
5. **Battle System** – Enforces round limit, checks win/loss conditions.
6. **Economy System** – Tracks coins, purchases, upgrades, removals.
7. **Progression System** – Simple branching choice after battles (combat, shop, event, boss).
8. **UI Layer** – Displays tiles, buttons, animations, all in Traditional Chinese.

---

## Components and Interfaces

### Tile System

```lua
Tile = {
  id = "BAM_5",
  suit = "BAM",   -- BAM (萬), DOT (筒), CHR (條), HONOR (winds/dragons)
  rank = 5,       -- 1..9 or "E","S","W","N","R","G","W"
  type = "normal" -- "normal" or "meme"
}
```

Wall:

```lua
Wall = {
  tiles = {},
  draw = function() end,
  shuffle = function() end
}
```

---

### Hand & Meld System

```lua
Hand = {
  tiles = {},
  add = function(tile) end,
  remove = function(index) end,
  checkMelds = function() end -- Chow/Pung/Kong/Pair detection
}
```

---

### Scoring System

```lua
Score = {
  calcFan = function(hand)
    -- Example result:
    return {
      totalFan = 6,
      details = { "All Pungs +3", "Pure Suit +3" }
    }
  end
}
```

---

### Battle Flow

1. **Start**: Player begins with 14 tiles.
2. **Round sequence**:

   * Draw → Play/Discard → Optionally use meme cards → Check win.
3. **Scoring**: If hand is valid, calculate fan.
4. **Win condition**: Reach required fan before round limit ends.
5. **Lose condition**: Fail to meet target by the end of available rounds.

---

### Shop System

```lua
Shop = {
  memes = { {id="lucky_cat", price=25}, {id="octopus", price=60} },
  relics = { {id="pineapple_bun", price=120} },
  mods = { {id="extra_dragons", price=80} },
  rerollPrice = 10
}
```

Player actions:

* Buy meme cards (active abilities).
* Buy relics (permanent passives).
* Apply mods (e.g., add more dragons, ban a suit, increase hand size).
* Remove or upgrade meme cards.
* Reroll shop inventory.

---

### Progression System

Instead of a complex map, use **card choice progression**:

* After each challenge, the player chooses from 3 cards:

  * 🀄 Combat (next battle)
  * 🛍 Shop
  * 🎲 Event

---

## Data Models

### Game State

```lua
GameState = {
  screen = "battle",   -- "menu", "battle", "shop", "event"
  coins = 100,
  powerDeck = {},      -- meme cards
  relics = {},         -- passive effects
  mods = {},           -- tile-wall mutations
  runDepth = 1,
  currentRound = 1,
  hand = {},
  wall = {}
}
```

### Meme Card

```lua
MemeCard = {
  id = "lucky_cat",
  name = "Lucky Cat",
  desc = "Draw 2 extra tiles immediately.",
  rarity = "common",
  level = 1,
  use = function(ctx) ctx:drawExtra(2) end
}
```

### Relic

```lua
Relic = {
  id = "pineapple_bun",
  name = "Pineapple Bun",
  desc = "+1 round each level.",
  effect = function(run) run.rounds = run.rounds + 1 end
}
```

---

## Error Handling

* **Invalid play** → Show “Cannot play these tiles.”
* **Insufficient coins** → Block purchase, show message.
* **Insufficient fan** → Show “Not enough fan to win.”
* **Corrupted save** → Reset and return to main menu.

---

## Testing Strategy

* **Unit tests**: Tile shuffling, meld detection, fan calculation, meme card effects.
* **Integration tests**: Full run loop (battle → reward → shop/event → next battle).
* **User tests**: Validate cultural flavor with Hong Kong players.
* **Cross-platform tests**: Verify functionality on Windows, macOS, Linux.

---

## Hong Kong Cultural Elements

* **Locations**: Sham Shui Po, Kwun Tong, Cha Chaan Teng, Mong Kok market.
* **Meme Cards**: Octopus Card, Lucky Cat, Joss Paper, Typhoon Signal 8.
* **Relics**: Pineapple Bun, Red Taxi, Lion Rock.
* **Events**: MTR delays, typhoon shutdowns, Mid-Autumn bonuses.
* **Terminology**: Full Traditional Chinese UI, Cantonese phrasing (番數, 食糊, 銀紙).

