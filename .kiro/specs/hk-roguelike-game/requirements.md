## Core Design Goals
1. **Simple to learn** – Pick tiles, make melds, score fan.
2. **Strategic depth** – Choose when to push for higher hands or survive with smaller wins.
3. **Roguelike fun** – Progression via shops, relics, and mods; increasing difficulty.
4. **Hong Kong identity** – All UI, names, and flavor rooted in local culture.
5. **Maintainable code** – Modular architecture for quick iteration.

---

## Requirements

### Requirement 1 – Core Mahjong Gameplay
**User Story:** As a player, I want authentic tile draws and winning hand checks, so the game feels like mahjong.

**Acceptance Criteria**
1. The system SHALL generate a full wall of tiles (Wan, Bamboo, Dots, Winds, Dragons; optional Flowers).
2. Each round, the player SHALL hold 14 tiles.
3. Players SHALL move tiles into play area or discard pile.
4. When the play area contains a complete structure (e.g., 4 melds + 1 pair or Seven Pairs), the system SHALL check for a win.
5. On win, the system SHALL calculate fan and award coins.

---

### Requirement 2 – Challenge Conditions
**User Story:** As a player, I want different difficulty modes, so each run feels fresh.

**Acceptance Criteria**
1. Challenges SHALL define a target fan and number of rounds allowed.
2. Restrictions SHALL be enforceable (e.g., “3 fan minimum”, “no Pung-based hands”).
3. Passing conditions within rounds SHALL reward coins and progression.
4. Failure SHALL deduct coins and allow retry or return to progression screen.

---

### Requirement 3 – Progression
**User Story:** As a player, I want clear progression between battles, so I feel like I’m advancing in a roguelike run.

**Acceptance Criteria**
1. After each challenge, the system SHALL present 2–3 choices: Combat, Shop, or Event.
2. Later stages SHALL scale difficulty (fewer rounds, higher target fan, special restrictions).
3. Boss stages SHALL enforce unique win conditions.
4. The run summary SHALL display total fan, coins earned, and depth reached.

---

### Requirement 4 – Shop and Deckbuilding
**User Story:** As a player, I want to shape my strategy with powers and passives, so each run is unique.

**Acceptance Criteria**
1. Shops SHALL offer meme cards, relics, and tile mods.
2. Purchases SHALL update the player’s deck or passive state immediately.
3. Meme cards SHALL be removable or upgradable in shops.
4. Prices SHALL scale with rarity and progression.

---

### Requirement 5 – Fan Calculation
**User Story:** As a mahjong fan, I want the scoring to feel fair and authentic.

**Acceptance Criteria**
1. The system SHALL recognize melds (Chow, Pung, Kong, Pair, Seven Pairs, Thirteen Orphans).
2. Each recognized fan SHALL add to total score (e.g., All Pungs +3, All Chows +1, Pure Suit +3, Seven Pairs +4).
3. Kongs SHALL add bonus fan.
4. The system SHALL show breakdown of fan sources.

---

### Requirement 6 – Controls and UI
**User Story:** As a player, I want intuitive controls and clean UI, so I can focus on strategy.

**Acceptance Criteria**
1. Tiles SHALL display in a clear row with hover highlights.
2. Clicking tiles SHALL select them; selected tiles SHALL glow.
3. Actions (Play, Discard, Reset) SHALL be visible as buttons.
4. Animations SHALL move tiles smoothly between areas.

---

### Requirement 7 – Hong Kong Theme
**User Story:** As a Hong Konger, I want local culture in the game, so it feels authentic.

**Acceptance Criteria**
1. Locations SHALL include Hong Kong landmarks (Sham Shui Po, Kwun Tong, Cha Chaan Teng).
2. Meme cards and relics SHALL use local items (Octopus Card, Pineapple Bun, Red Taxi, Lion Rock).
3. Events SHALL reference local culture (Typhoon Signal 8, MTR delay, Mid-Autumn bonus).
4. All text SHALL use Traditional Chinese with Cantonese terms.

---

### Requirement 8 – Developer Maintainability
**User Story:** As a developer, I want modular, clean code, so the project is easy to extend.

**Acceptance Criteria**
1. The system SHALL separate modules for wall, hand, rules, scoring, state, and UI.
2. The system SHALL fully support UTF-8 Traditional Chinese.
3. Fonts SHALL render Traditional Chinese correctly.
4. State management SHALL persist money, fan totals, and progression.