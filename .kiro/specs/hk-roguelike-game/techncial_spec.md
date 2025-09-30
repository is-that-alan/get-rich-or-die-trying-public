# Technical Specification

## 1. Overview

**Hong Kong Mahjong Roguelike Deckbuilder**

* **Core mechanic**: Player plays mahjong tiles under strict rules (play-time constraints).
* **End of round**: System re-arranges all played tiles into the best possible winning hand, then calculates **fan**.
* **Roguelike layer**: Coins, shop, meme cards, relics, mods.
* **Platform**: LÖVE2D (Lua).

---

## 2. Game Flow

1. **Start Run**

   * Generate wall (no 花 / 槓 for now).
   * Draw initial 14 tiles.

2. **Round Flow**

   * Player draws tile to refill hand (if <14).
   * Player chooses tile to play:

     * Must match play-time legality rules (see section 3).
   * Tile moves into “played area” sets.
   * Player may discard unwanted tiles into discard pile.
   * Player may use meme cards.
   * End round, decrement rounds left.

3. **End of Challenge**

   * Collect all played tiles.
   * Run **WinCheck** (standard 4 melds + 1 pair only for now).
   * If winning → calculate fan via `ScoringSystem`.
   * Compare against challenge requirements (target fan, round limit).
   * Grant or deduct coins.

---

## 3. Play-Time Legality (Constraint Rules)

* **Pair start**: If no sets yet, player may place 1 tile to begin a potential pair.
* **Pair complete**: If 1 tile already placed, another of the same tile may be played to form a Pair.
* **Pung**: If ≥2 of the same tile exist in played area, a third may complete a Pung.
* **Chow**: If consecutive sequence exists (e.g., 3萬 already played), a 2萬 or 4萬 can be placed to form/in-progress Chow.
* **Honor tiles (winds, dragons)**: Only Pung allowed, no Chow.
* **Illegal moves**: Prevented by greying out tiles or blocking input.

---

## 4. End-Phase Rearrangement

* At end of challenge, ignore player’s partial groupings.
* Run full **WinCheck.isWinning** with best arrangement search:

  * Tries all possible eyes.
  * Splits into Chows and Pungs using recursive decomposition + memoization.
* Placeholders for `SevenPairs` and `ThirteenOrphans` (return false for now).

---

## 5. Systems Breakdown

### 5.1 Tile System

```lua
Tile = {
  suit = "BAM"|"DOT"|"CHR"|"HON",
  rank = 1..9 | "E","S","W","N","R","G","W"
}
```

### 5.2 Hand System

```lua
Hand = {
  tiles = {},
  draw = function(self, wall) ... end,
  remove = function(self, index) ... end
}
```

### 5.3 Played Area System

```lua
Played = {
  sets = {}, -- { {type="pair_wait", tiles={}}, ... }
  canPlay = function(self, tile) ... end,
  play = function(self, tile) ... end
}
```

### 5.4 WinCheck System

* Implements **standard 4 melds + 1 pair** (no 花, no 槓).
* Placeholder stubs for Seven Pairs and Thirteen Orphans.

### 5.5 Scoring System

* Input: `melds`, `pair`, flags from WinCheck.
* Rules (basic):

  * All Pungs +3
  * All Chows +1
  * Pure Suit (清一色) +3
  * Mixed Suit (混一色) +2
  * Dragon Pung +2 each
  * Wind Pung (seat/prevailing) +1 each
  * Concealed hand +1
* Output: `fanTotal`, `breakdown`.

### 5.6 Economy System

* Tracks `coins`.
* Shops allow buying meme cards, relics, mods.
* Purchases update `powerDeck` and `relics`.

### 5.7 Progression System

* After each challenge, present 3 choices: Combat / Shop / Event.
* Boss levels enforce stricter rules (higher fan, restricted hands).

---

## 6. Data Models

### Game State

```lua
GameState = {
  screen = "battle",
  coins = 100,
  hand = {},
  wall = {},
  played = {},
  discard = {},
  powerDeck = {},
  relics = {},
  mods = {},
  roundsLeft = 7,
  targetFan = 3
}
```

### Meme Card

```lua
MemeCard = {
  id = "lucky_cat",
  desc = "Draw 2 extra tiles",
  use = function(ctx) ctx:drawExtra(2) end
}
```

### Relic

```lua
Relic = {
  id = "pineapple_bun",
  desc = "+1 round each challenge",
  effect = function(run) run.roundsLeft = run.roundsLeft + 1 end
}
```

---

## 7. Error Handling

* **Invalid play** → Reject with message “Not a valid set.”
* **Not enough coins** → Reject shop purchase.
* **Fan too low** → Show “Target fan not reached.”
* **Save file corrupt** → Reset progress.

---

## 8. Testing Strategy

* **Unit tests**:

  * WinCheck with known winning/non-winning hands.
  * canPlay logic with legal/illegal tiles.
  * Scoring breakdown for All Pungs, All Chows, etc.
* **Integration tests**:

  * Full loop: Battle → Reward → Shop → Next Battle.
* **User tests**:

  * Check if constraints feel intuitive.
  * Validate end-phase rearrangement makes sense.

---

## 9. Future Extensions

* Add **槓** handling.
* Add **花牌** handling.
* Implement **七對** + **十三么**.
* Multiplayer support (optional).
