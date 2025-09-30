# Development Tasks: Get Rich or Die Trying

**Last Updated**: 2025-09-30
**Project Status**: ~85% Complete (Core gameplay done, polish & content expansion ongoing)

---

## Task Categories

- **P0**: Critical (must complete for v1.0)
- **P1**: High Priority (important for v1.5)
- **P2**: Medium Priority (nice-to-have features)
- **P3**: Low Priority (future enhancements)

**Status Legend**:
- ✅ Completed
- 🚧 In Progress
- ⏳ Not Started
- ❌ Blocked

---

## Completed Features ✅

### Core Gameplay
- [x] Mahjong battle system with Hong Kong rules
- [x] Fan-based scoring (1-13 fan patterns)
- [x] 14-tile hand validation
- [x] Drag-and-drop tile interface
- [x] Challenge mode (target fan + round limits)
- [x] Victory/defeat conditions
- [x] Invalid play tracking and penalties

### Progression System
- [x] Card-based progression UI
- [x] Combat/Shop/Event/Elite/Boss cards
- [x] Level-based card frequency adjustment
- [x] Combat encounter completion tracking
- [x] Level milestones trigger story scenes
- [x] Smooth card hover animations

### Item Systems
- [x] 20+ consumable items (HK-themed food)
- [x] Consumable effects (draw tiles, undo, peek, etc.)
- [x] 15+ passive relics
- [x] Relic effects (money generation, bonuses, discounts)
- [x] Deck spell system infrastructure
- [x] Shop purchasing and inventory

### Shop System
- [x] Shop UI with item display
- [x] Rarity-based pricing
- [x] Refresh inventory option
- [x] Purchase validation (money check)
- [x] Collection view

### Event System
- [x] 10+ random Hong Kong events
- [x] Choice-based outcomes
- [x] Money/item rewards
- [x] Auto-progression after results
- [x] Thematic flavor text

### Story & Atmosphere
- [x] 10+ story scenes (comic-style)
- [x] Scene panel system
- [x] Dialogue overlay system
- [x] Cut-in dialogue animations
- [x] Developer test menus (scenes, dialogues, music)
- [x] Background music system
- [x] Sound effects integration

### Visual Polish
- [x] Screen shake effects
- [x] Particle system
- [x] Button hover animations
- [x] Smooth transitions
- [x] Help button in battle (with tooltip)
- [x] Card glow effects

### Hong Kong Culture
- [x] Traditional Chinese throughout
- [x] Cantonese phrases and romanization
- [x] Time-based greetings
- [x] 6 Hong Kong district locations
- [x] Typhoon warning signal system
- [x] Authentic cultural references

### Developer Tools
- [x] Konami code system
- [x] Instant win code (↑↑↓↓←→W)
- [x] Money cheat (↑↑↓↓←→M)
- [x] Test menus (D=dialogue, S=scenes, 1=music)
- [x] Hot reload (lick.lua integration)

### Documentation
- [x] Comprehensive README.md
- [x] Complete story.md
- [x] CUTIN_DIALOGUE_SYSTEM.md
- [x] PACKAGING.md
- [x] CONTROLS.md
- [x] design.md
- [x] requirements.md
- [x] technical_spec.md
- [x] tasks.md (this file)

---

## Priority 0 (Critical) - Remaining for v1.0

### None! 🎉

All P0 tasks are complete. The game is fully playable from start to finish with core gameplay loop functional.

---

## Priority 1 (High) - For v1.5

### Story Integration 🚧

#### Task: Connect Time-Loop Narrative
**Status**: 🚧 Partially Complete
**Effort**: Large (20-30 hours)
**Dependencies**: Scene system (complete)

**Subtasks**:
- [x] Write story outline (story.md complete)
- [x] Create scene infrastructure
- [ ] Implement Loop 1 scenes (1990s-2000s)
  - [ ] Opening: Delivery boy introduction
  - [ ] Mid-loop: Dot-com bubble experience
  - [ ] End: First major loss
- [ ] Implement Loop 2 scenes (2000s-2010s)
  - [ ] Opening: Reawakening with knowledge
  - [ ] Mid-loop: SARS crisis opportunity
  - [ ] Property speculation
  - [ ] 2008 financial crisis
- [ ] Implement Loop 3 scenes (2010s-2020s)
  - [ ] Opening: Third loop wisdom
  - [ ] AI revolution
  - [ ] COVID-19 pandemic
  - [ ] Cryptocurrency schemes
- [ ] Implement Loop 4 (Breaking the Cycle)
  - [ ] Robot Wizard confrontation
  - [ ] Multiple endings based on karma

**Files to Modify**:
- `progression.lua` - Trigger scenes at level milestones
- `progression_cards.lua` - Add story card types
- `scene.lua` - Add new scene definitions
- `images/scenes/` - Create artwork (external)

**Acceptance Criteria**:
- Player experiences all 4 loops
- Story feels cohesive and compelling
- Choices meaningfully affect narrative
- Karma system tracks player morality

---

#### Task: Implement Karma System
**Status**: ⏳ Not Started
**Effort**: Medium (8-12 hours)
**Dependencies**: Event system (complete), Story integration (in progress)

**Subtasks**:
- [ ] Define karma calculation rules
- [ ] Track karma in game state
  - [ ] Add `karma` field to gameState
  - [ ] Initialize at 50 (neutral)
- [ ] Assign karma values to event choices
  - [ ] Update `event_screen.lua` to modify karma
- [ ] Display karma in UI (subtle indicator)
- [ ] Implement karma thresholds
  - [ ] High karma (80-100): Good ending
  - [ ] Neutral karma (40-79): Normal ending
  - [ ] Low karma (0-39): Bad ending
- [ ] Create ending variations
  - [ ] Good: Break loop, help others
  - [ ] Neutral: Continue with awareness
  - [ ] Bad: Trapped, wealthy but empty
  - [ ] Secret: Become Robot Wizard

**Files to Modify**:
- `main.lua` - Add karma to game state
- `event_screen.lua` - Modify karma on choices
- `progression.lua` - Check karma for endings
- `scene.lua` - Add ending scenes

**Acceptance Criteria**:
- Karma tracked throughout run
- Choices visibly affect karma
- Endings reflect karma level
- UI shows karma subtly (no explicit number)

---

### Weather Integration 🚧

#### Task: Integrate Weather Effects into Battles
**Status**: ⏳ Not Started
**Effort**: Medium (6-8 hours)
**Dependencies**: Weather system (complete), Battle system (complete)

**Subtasks**:
- [ ] Display current weather in battle UI
  - [ ] Show typhoon signal (T1, T3, T8, etc.)
  - [ ] Weather icon in sidebar
- [ ] Apply wind tile bonuses
  - [ ] T8 NE: East wind tiles +1 fan
  - [ ] T8 SE: South wind tiles +1 fan
  - [ ] T8 SW: West wind tiles +1 fan
  - [ ] T8 NW: North wind tiles +1 fan
- [ ] Add weather-triggered events
  - [ ] T8+: Shelter in place choice
  - [ ] T1-T3: Delivery opportunities
- [ ] Visual effects for weather
  - [ ] Rain particles during typhoon
  - [ ] Wind animation
  - [ ] Screen darkening

**Files to Modify**:
- `mahjong_battle.lua` - Display weather, apply bonuses
- `mahjong_logic.lua` - Calculate weather bonuses in fan
- `weather_system.lua` - Expose current weather state
- `juice.lua` - Add weather particle effects

**Acceptance Criteria**:
- Weather displayed in battle
- Wind tiles provide bonuses
- Bonuses correctly calculated
- Visual effects enhance atmosphere

---

### Content Expansion

#### Task: Expand Deck Spells
**Status**: 🚧 Partially Complete
**Effort**: Small (4-6 hours)
**Dependencies**: Deck spell system (complete)

**Subtasks**:
- [x] Basic spells functional
- [ ] Add 10+ new spells
  - [ ] "All In" - Convert all tiles to one suit
  - [ ] "Lucky Draw" - Add 3 random honor tiles
  - [ ] "Balanced Deck" - Equal distribution
  - [ ] "Terminal Focus" - More 1s and 9s
  - [ ] "Middle Ground" - More 4-6 tiles
  - [ ] "Wind Master" - More wind tiles
  - [ ] "Dragon Power" - More dragon tiles
  - [ ] "Pure Suit" - Remove two suits
  - [ ] "Honor Heavy" - Double honor tiles
  - [ ] "Sequence Specialist" - Optimize for sequences
- [ ] Balance spell costs
- [ ] Test spell synergies

**Files to Modify**:
- `deck_spells.lua` - Add new spell definitions
- `deck_modifier_screen.lua` - Display new spells
- `shop.lua` - Add to shop inventory

**Acceptance Criteria**:
- 15+ total spells available
- Each spell feels unique and useful
- Prices balanced vs power
- Spells enable diverse strategies

---

#### Task: Fill Meme Card Database
**Status**: ⏳ Not Started
**Effort**: Medium (8-10 hours)
**Dependencies**: Meme card system (infrastructure complete)

**Subtasks**:
- [ ] Research authentic Hong Kong meme phrases
  - [ ] 50+ phrases identified
  - [ ] Meanings and contexts documented
- [ ] Design effects per meme
  - [ ] "講呢啲" (gong2 ne1 di1) - Draw 2 tiles
  - [ ] "搞乜嘢" (gaau2 mat1 je5) - Confuse opponent
  - [ ] "咁樣囉" (gam2 joeng6 lo1) - +3 points to all tiles
  - [ ] "唔知喎" (m4 zi1 wo3) - Peek at deck
  - [ ] "梗係啦" (gang2 hai6 laa1) - Double fan next round
  - [ ] ... (45+ more)
- [ ] Implement effects
- [ ] Balance power levels
- [ ] Add to shop generation
- [ ] Create icons (optional)

**Files to Modify**:
- `hk_meme_cards.lua` - Fill database
- `shop.lua` - Verify meme card generation
- `mahjong_battle.lua` - Trigger meme effects

**Acceptance Criteria**:
- 50+ meme cards defined
- Effects feel thematic
- Native speakers approve phrases
- Cards add strategic depth

---

#### Task: Add More Events
**Status**: ⏳ Not Started
**Effort**: Medium (6-8 hours)
**Dependencies**: Event system (complete)

**Subtasks**:
- [ ] Design 20+ new events
  - [ ] 中秋節 (Mid-Autumn Festival) - Mooncake opportunities
  - [ ] 農曆新年 (Lunar New Year) - Red envelope gamble
  - [ ] 七月鬼節 (Hungry Ghost Festival) - Risky night deliveries
  - [ ] 賽馬日 (Horse Racing Day) - Betting temptation
  - [ ] 麻雀館老闆 (Mahjong Parlor Boss) - Challenge or befriend
  - [ ] 劏房加租 (Rent Increase) - Pay or move
  - [ ] 茶餐廳打工 (Cha Chaan Teng Job) - Stable income vs freedom
  - [ ] 地產經紀 (Real Estate Agent) - Property investment
  - [ ] 炒股票 (Stock Trading) - Market speculation
  - [ ] 買六合彩 (Mark Six Lottery) - Gambling chance
  - [ ] ... (10+ more)
- [ ] Write flavor text (2-3 sentences each)
- [ ] Define outcomes (money, items, karma)
- [ ] Balance risk/reward
- [ ] Test variety (no repetition feel)

**Files to Modify**:
- `event_screen.lua` - Add new event definitions

**Acceptance Criteria**:
- 30+ total events available
- Events feel thematic and Hong Kong-specific
- Variety in outcomes (not all money-focused)
- Balanced risk/reward

---

## Priority 2 (Medium) - Nice-to-Have

### Gameplay Enhancements

#### Task: Add Achievements System
**Status**: ⏳ Not Started
**Effort**: Medium (10-12 hours)

**Subtasks**:
- [ ] Design achievement categories
  - [ ] Battle achievements (win with 13 fan, win without consumables, etc.)
  - [ ] Collection achievements (own all relics, buy 100 consumables, etc.)
  - [ ] Story achievements (complete loops, reach endings, etc.)
  - [ ] Cultural achievements (experience all locations, trigger all events, etc.)
- [ ] Implement tracking system
- [ ] Create achievement UI screen
- [ ] Add visual notifications on unlock
- [ ] Persist achievements across runs

**Files to Create**:
- `achievements.lua` - Achievement definitions and tracking
- `achievements_screen.lua` - Display UI

**Files to Modify**:
- `main.lua` - Track achievement progress
- `mahjong_battle.lua` - Trigger battle achievements

**Acceptance Criteria**:
- 30+ achievements defined
- Achievements unlock correctly
- UI shows progress and unlocks
- Persist across game sessions

---

#### Task: Add Statistics Tracking
**Status**: ⏳ Not Started
**Effort**: Small (4-6 hours)

**Subtasks**:
- [ ] Track gameplay statistics
  - [ ] Total runs
  - [ ] Wins/losses
  - [ ] Average fan per run
  - [ ] Highest fan in single hand
  - [ ] Money earned/spent
  - [ ] Most used consumables
  - [ ] Favorite relics
  - [ ] Locations visited
- [ ] Create stats UI screen
- [ ] Persist stats across runs

**Files to Create**:
- `statistics.lua` - Stats tracking
- `statistics_screen.lua` - Display UI

**Files to Modify**:
- `main.lua` - Track stats during gameplay

**Acceptance Criteria**:
- Key stats tracked accurately
- UI displays stats clearly
- Stats persist across sessions

---

#### Task: Add Tutorial Mode
**Status**: ⏳ Not Started
**Effort**: Large (12-16 hours)

**Subtasks**:
- [ ] Design tutorial flow
  - [ ] Introduce mahjong basics
  - [ ] Explain tile types
  - [ ] Teach hand formation
  - [ ] Show fan scoring
  - [ ] Explain progression cards
  - [ ] Introduce items
- [ ] Implement interactive tutorial battles
  - [ ] Scripted hands
  - [ ] Tooltips and hints
  - [ ] Guided actions
- [ ] Add tutorial skip option
- [ ] Track tutorial completion

**Files to Create**:
- `tutorial.lua` - Tutorial system
- `tutorial_battle.lua` - Scripted battles

**Files to Modify**:
- `main.lua` - Launch tutorial on first run

**Acceptance Criteria**:
- New players understand mechanics
- Tutorial is non-intrusive
- Skippable for experienced players
- Clear and concise explanations

---

### Audio Enhancements

#### Task: Add Authentic Hong Kong Sound Design
**Status**: ⏳ Not Started
**Effort**: Medium (8-10 hours)
**Dependencies**: Music system (complete), External audio assets

**Subtasks**:
- [ ] Source/create Hong Kong ambient sounds
  - [ ] Street noise (traffic, crowds)
  - [ ] MTR station announcements
  - [ ] Cha chaan teng sounds (cooking, chatter)
  - [ ] Mahjong tile clicks and shuffles
  - [ ] Typhoon wind and rain
  - [ ] Market haggling
- [ ] Source/create mahjong tile SFX
  - [ ] Tile draw sound
  - [ ] Tile place sound
  - [ ] Tile shuffle sound
  - [ ] Victory chime
  - [ ] Defeat sound
- [ ] Source/create UI sounds
  - [ ] Button hover
  - [ ] Button click
  - [ ] Card select
  - [ ] Money sound
  - [ ] Item purchase
- [ ] Integrate into game
- [ ] Balance volume levels

**Files to Modify**:
- `music.lua` - Add new SFX
- `mahjong_battle.lua` - Trigger tile sounds
- `shop.lua` - Trigger purchase sounds
- `progression_screen.lua` - Trigger card sounds

**Acceptance Criteria**:
- Sounds feel authentically Hong Kong
- Tile sounds satisfying
- UI feedback clear
- Volume balanced (not overwhelming)

---

### Visual Enhancements

#### Task: Improve Tile Graphics
**Status**: ⏳ Not Started
**Effort**: Small (4-6 hours)
**Dependencies**: External artwork

**Subtasks**:
- [ ] Source or create high-quality tile images
  - [ ] Traditional mahjong tile designs
  - [ ] Clear, readable characters
  - [ ] Consistent style
  - [ ] Multiple sizes (for scaling)
- [ ] Implement tile image loading
- [ ] Add tile shadows and depth
- [ ] Smooth tile animations

**Files to Modify**:
- `mahjong_ui.lua` - Render tile images
- `mahjong_tiles.lua` - Load tile graphics
- `generate_tiles.lua` - Update procedural generation

**Acceptance Criteria**:
- Tiles visually appealing
- Characters readable at all sizes
- Consistent art style
- Performance not impacted

---

## Priority 3 (Low) - Future Enhancements

### Mobile Support

#### Task: Add Touch Controls
**Status**: ⏳ Not Started
**Effort**: Large (20-30 hours)

**Subtasks**:
- [ ] Implement touch input handling
- [ ] Redesign UI for mobile
  - [ ] Larger buttons
  - [ ] Touch-friendly layout
  - [ ] Swipe gestures
- [ ] Test on mobile devices
- [ ] Optimize performance for mobile

**Acceptance Criteria**:
- Game playable on iOS/Android
- Touch controls intuitive
- UI readable on small screens
- Performance acceptable (30+ FPS)

---

### Multiplayer

#### Task: Add Asynchronous Multiplayer
**Status**: ⏳ Not Started
**Effort**: Very Large (40-60 hours)

**Subtasks**:
- [ ] Design multiplayer architecture
  - [ ] Server/client model
  - [ ] Matchmaking
  - [ ] Turn-based async gameplay
- [ ] Implement networking (socket.lua or similar)
- [ ] Create multiplayer UI
- [ ] Handle disconnections and timeouts
- [ ] Leaderboards

**Acceptance Criteria**:
- Players can challenge each other
- Matches are fair and synchronized
- Leaderboards functional
- Stable and secure

---

### Localization

#### Task: Add English Translation
**Status**: ⏳ Not Started
**Effort**: Large (16-24 hours)

**Subtasks**:
- [ ] Extract all text strings
- [ ] Translate to English
  - [ ] Preserve cultural context
  - [ ] Explain Hong Kong references
- [ ] Implement language switching
- [ ] Add English font support
- [ ] Test English UI layout

**Files to Create**:
- `localization.lua` - Language system
- `en.lua` - English strings
- `zh.lua` - Chinese strings

**Acceptance Criteria**:
- All text translatable
- English feels natural
- Cultural context preserved
- UI adapts to language

---

## Bug Fixes & Polish

### Known Issues

#### Issue: Help Button Overlap in Battle
**Status**: ✅ Fixed
**Priority**: P0
**Fixed**: Help button moved to top-right, tooltip adjusted

---

#### Issue: Deck Spell Balance
**Status**: ⏳ Open
**Priority**: P1
**Description**: Some deck spells too powerful/weak
**Action**: Playtest and adjust costs/effects

---

#### Issue: Event Repetition
**Status**: ⏳ Open
**Priority**: P2
**Description**: Same events appear too frequently
**Action**: Improve event generation algorithm

---

## Testing Tasks

### Playtesting Priorities

#### Task: Balance Testing
**Status**: 🚧 Ongoing
**Effort**: Ongoing

**Focus Areas**:
- [ ] Fan targets per level (too easy/hard?)
- [ ] Consumable prices (worth the cost?)
- [ ] Relic power levels (balanced?)
- [ ] Event risk/reward ratios
- [ ] Shop prices (fair?)
- [ ] Deck spell effectiveness

**Method**:
- Play complete runs (10+ runs)
- Track difficulty spikes
- Adjust numbers iteratively

---

#### Task: Cultural Authenticity Review
**Status**: ⏳ Not Started
**Effort**: Small (2-4 hours)

**Focus Areas**:
- [ ] Native Cantonese speaker review
- [ ] Verify phrases sound natural
- [ ] Check cultural references accuracy
- [ ] Confirm respectful representation

**Method**:
- Invite Hong Kong native speakers to play
- Collect feedback
- Adjust language and references

---

#### Task: Performance Testing
**Status**: ✅ Passing
**Effort**: Small (2-3 hours)

**Focus Areas**:
- [x] 60 FPS sustained
- [x] <3s load time
- [x] No memory leaks
- [x] Smooth transitions

**Method**:
- Extended play sessions (1-2 hours)
- Monitor FPS and memory
- Profile hotspots

---

## Release Milestones

### Version 1.0 (Current) ✅
**Status**: Complete
**Release Date**: 2025-09-30

**Features**:
- Core gameplay loop functional
- All P0 requirements met
- Playable start to finish
- Comprehensive documentation

---

### Version 1.5 (Next)
**Target**: 2025 Q4
**Status**: Planning

**Goals**:
- Complete time-loop story integration
- Implement karma system
- Weather integration in battles
- Expand deck spells (15+ total)
- Fill meme card database (50+ cards)
- Add more events (30+ total)

---

### Version 2.0 (Future)
**Target**: 2026 Q1
**Status**: Concept

**Goals**:
- Achievements system
- Statistics tracking
- Tutorial mode
- Sound design overhaul
- Visual improvements

---

### Version 3.0 (Aspirational)
**Target**: TBD
**Status**: Concept

**Goals**:
- Mobile support
- Multiplayer (async)
- English localization
- Additional game modes
- Mod support

---

## Task Assignment

**Solo Developer** (current):
- All tasks managed by primary developer
- Prioritize based on P0 → P1 → P2 → P3
- Focus on high-impact, low-effort tasks first

**Future Contributors**:
- **Content Writers**: Story integration, event writing, meme card phrases
- **Artists**: Tile graphics, scene artwork, UI improvements
- **Audio Designers**: Sound effects, music composition
- **Translators**: English localization
- **Playtesters**: Balance feedback, bug reports

---

## Progress Tracking

**Overall Completion**: ~85%

**By Priority**:
- P0 (Critical): 100% ✅
- P1 (High): ~40% 🚧
- P2 (Medium): ~10% ⏳
- P3 (Low): 0% ⏳

**By Category**:
- Core Gameplay: 100% ✅
- Story & Narrative: 60% 🚧
- Items & Content: 70% 🚧
- Polish & Effects: 90% ✅
- Documentation: 100% ✅

---

**Tasks Document Complete**

This living document tracks all development tasks for **Get Rich or Die Trying**. Update regularly as tasks are completed or new priorities emerge.