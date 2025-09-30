# Game Design Document: Get Rich or Die Trying

**Version**: 2.0
**Last Updated**: 2025-09-30
**Status**: Active Development

---

## Executive Summary

**Get Rich or Die Trying** (可以冇錢但係唔可以窮) is a Hong Kong-themed mahjong roguelike that combines authentic Hong Kong mahjong mechanics with fan-based scoring and Slay the Spire-style card-based progression. Players experience a time-loop narrative spanning Hong Kong's economic eras from the 1990s to 2020s, playing as a delivery boy trying to escape poverty through mahjong battles.

---

## Core Pillars

### 1. Authentic Hong Kong Mahjong
- **Real Rules**: Traditional 14-tile winning hands
- **Fan Scoring**: 1-13 fan patterns (清一色, 對對糊, 大三元, etc.)
- **Strategic Depth**: Hand optimization and tile management

### 2. Roguelike Progression
- **Card-Based Paths**: Choose Combat/Shop/Event/Boss cards
- **Permanent Upgrades**: Relics provide passive bonuses
- **Run-Based Structure**: Each playthrough is unique
- **Risk/Reward**: Balance progression with resource management

### 3. Hong Kong Cultural Authenticity
- **Cantonese Language**: Traditional Chinese with authentic phrases
- **Real Locations**: 深水埗, 觀塘, 旺角, 中環, 銅鑼灣, 尖沙咀
- **Cultural Items**: 奶茶, 菠蘿包, 魚蛋 as gameplay mechanics
- **Social Commentary**: Economic inequality, housing crisis, gig economy

### 4. Time-Loop Narrative
- **Multi-Generational**: Experience 3-4 economic eras
- **Class Progression**: 外賣仔 → 文員仔 → 小老闆 → 誠哥
- **Karma System**: Choices affect endings
- **Historical Events**: Dot-com bubble, SARS, 2008 crisis, COVID-19

---

## Game Flow

### Session Structure

```
Main Menu
    ↓
Story Scene (Optional)
    ↓
Progression Screen ←─┐
    ↓                │
Choose Card          │
    ↓                │
┌───┴────┬──────┬────┴────┐
│Combat  │Shop  │Event    │Boss
↓        ↓      ↓         ↓
Battle   Buy    Choose    Story Battle
         Items  Option
↓        ↓      ↓         ↓
Rewards  Return Return    Rewards
↓        ↓      ↓         ↓
└────────┴──────┴─────────┘
         ↓
     Next Level / Scene / Victory
```

### Progression Loop

1. **Start Run**: Begin as 外賣仔 with basic deck
2. **Choose Path**: Select card from 3-4 options
3. **Resolve Encounter**: Battle, shop, or event
4. **Gain Resources**: Money, relics, consumables
5. **Advance**: Progress through levels (1-20+)
6. **Story Beats**: Scenes at level milestones (5, 10, 15, 20)
7. **Boss Fights**: Major battles at chapters end
8. **Victory/Defeat**: Complete time loop or restart

---

## Core Systems

### 1. Mahjong Battle System

#### Battle Structure
```
Start of Battle
    ↓
Draw Initial Hand (13-14 tiles)
    ↓
┌─→ Player Turn
│       ↓
│   Draw Tile
│       ↓
│   Use Consumable (Optional)
│       ↓
│   Rearrange Hand (Drag & Drop)
│       ↓
│   Submit Hand or Discard
│       └──→ Invalid → Penalty
│            Valid → Score Fan
│                ↓
│           Check Win Condition
│                ↓
│       ┌───────┴────────┐
│       │Met Target      │Reached Max Rounds
│       ↓                ↓
│   Victory          Defeat
│       │                │
└───────┘                └─→ End Battle
```

#### Win Conditions
- **Challenge Mode**: Reach target fan within max rounds
- **Normal Mode**: Complete valid hands with minimum fan
- **Boss Mode**: Special victory conditions per boss

#### Scoring System

| Fan Value | Pattern Examples | Difficulty |
|-----------|-----------------|------------|
| 1 fan | 平糊 (Basic win) | Common |
| 2-3 fan | 對對糊, 混一色 | Uncommon |
| 4-6 fan | 小三元, 清一色 | Rare |
| 7-10 fan | 大三元, 字一色 | Very Rare |
| 11-13 fan | 清老頭, 十三么 | Legendary |

#### Failure States
1. **Round Limit**: Exceed maximum rounds without reaching target
2. **Invalid Attempts**: Too many invalid hand submissions (3x)
3. **Empty Deck**: Cannot draw required tiles

### 2. Progression System

#### Card Types & Frequencies

**Early Game (Levels 1-5)**
- Combat: 50%
- Shop: 25%
- Event: 25%
- Elite: 0%
- Boss: 0%

**Mid Game (Levels 6-15)**
- Combat: 40%
- Shop: 20%
- Event: 20%
- Elite: 15%
- Boss: 5%

**Late Game (Levels 16-20)**
- Combat: 30%
- Shop: 15%
- Event: 15%
- Elite: 25%
- Boss: 15%

#### Encounter Design

##### Combat Encounters
**Difficulty Tiers**:
- **Easy** (深水埗): 3 fan target, 5 rounds
- **Medium** (旺角): 5 fan target, 4 rounds
- **Hard** (中環): 8 fan target, 3 rounds
- **Elite** (銅鑼灣): 10 fan target, 3 rounds
- **Boss** (尖沙咀): Special mechanics, 12+ fan

**Location Themes**:
- 深水埗: Grassroots hustles
- 觀塘: Factory grinds
- 旺角: Street smart battles
- 中環: High-stakes finance
- 銅鑼灣: Luxury challenges
- 尖沙咀: Tourist trap bosses

##### Shop Encounters
**Inventory Structure**:
- Consumables: 3-5 items (common to rare)
- Deck Spells: 1-2 spells (uncommon to legendary)
- Relics: 0-1 relic (rare to legendary, level-gated)
- Refresh Option: Costs $50

**Pricing**:
- Common: $20-50
- Uncommon: $50-100
- Rare: $100-200
- Legendary: $200-500

##### Event Encounters
**Structure**:
1. Narrative setup (2-3 sentences)
2. 2-3 choice options
3. Outcomes (money, items, status effects)

**Example Events**:
- 颱風警告: Risk/safety choice
- 港鐵故障: Time vs money
- 街頭擺賣: Legal risk vs profit
- 劏房問題: Housing investment
- Crypto機會: Scam or fortune

### 3. Item Systems

#### Consumables (戰鬥用品)

**Design Philosophy**: Hong Kong food/culture as mechanics

**Categories**:
1. **Cha Chaan Teng** (茶餐廳) - Basic utility
2. **Street Food** (街頭小食) - Advanced effects
3. **Dim Sum** (點心) - Premium effects

**Usage Rules**:
- Use during battle before submitting hand
- One-time effect per consumable
- Stackable (can use multiple per turn)
- Purchased or found as rewards

**Balance Considerations**:
- Price reflects power
- Rarity affects availability
- Synergies with relics encouraged

#### Relics (聖物)

**Design Philosophy**: Passive bonuses representing HK culture

**Categories**:
1. **Economic** - Money/resource generation
2. **Strategic** - Gameplay advantages
3. **Cultural** - Unique Hong Kong mechanics

**Acquisition**:
- Level-gated (basic → legendary)
- Shop purchases (expensive)
- Elite battle rewards
- Boss victory rewards

**Balance**:
- No duplicate relics
- Maximum 10-15 relics per run
- Synergies create build diversity

#### Deck Spells (牌組法術)

**Purpose**: Permanent deck modification

**Operations**:
- Transform: Change tile types
- Add: Insert new tiles
- Remove: Delete tiles
- Duplicate: Add copies

**Strategic Depth**:
- Build suit-focused decks (清一色 strategy)
- Balance tile distribution
- Enable specific patterns
- Counter difficulty spikes

### 4. Story System

#### Time-Loop Structure

**Loop 1: 1990s-2000s Manufacturing Era**
- **Theme**: Innocence and harsh lessons
- **Class**: 外賣仔 (Delivery Boy)
- **Key Events**: Dot-com bubble, low wages, first loss
- **Lesson**: Money is hard to make

**Loop 2: 2000s-2010s Property Boom**
- **Theme**: Knowledge and greed
- **Class**: 文員仔 (Office Worker)
- **Key Events**: SARS opportunity, property speculation, 2008 crash
- **Lesson**: Risk management matters

**Loop 3: 2010s-2020s Digital Age**
- **Theme**: Wisdom and consequence
- **Class**: 小老闆 (Small Boss)
- **Key Events**: AI disruption, COVID-19, cryptocurrency
- **Lesson**: Ethics vs profit

**Loop 4: Breaking the Cycle**
- **Theme**: Choice and fate
- **Class**: 誠哥 (Tycoon)
- **Confrontation**: Robot Wizard final battle
- **Endings**: Based on karma accumulated

#### Karma System

**Karma Sources**:
- Event choices (help vs exploit)
- Business practices (fair vs ruthless)
- Story decisions (compassion vs greed)

**Karma Ranges**:
- **High Karma** (80-100): Benevolent capitalist ending
- **Neutral Karma** (40-79): Balanced ending
- **Low Karma** (0-39): Rich but empty ending

**Endings**:
1. **Good**: Break loop, help others, find meaning
2. **Neutral**: Continue cycle with awareness
3. **Bad**: Trapped forever, wealthy but soulless
4. **Secret**: Become the next Robot Wizard

#### Scene Integration

**Scene Types**:
- **Intro**: Game opening
- **Level Transitions**: Major story beats
- **Mid-Level**: Character development
- **Boss Preludes**: Setup major battles
- **Endings**: Victory/defeat outcomes

**Scene Mechanics**:
- Comic panel layout
- Dialogue overlays
- Background music
- Zoom/blur effects
- Player choices (branching)

---

## Visual Design

### Art Style
- **Comic-Inspired**: Panel-based storytelling
- **Hong Kong Aesthetics**: Neon signs, crowded streets, local color
- **Mahjong Tiles**: Traditional designs with modern clarity
- **UI**: Clean, functional, culturally appropriate

### Color Palette
- **Background**: Dark blues/grays (0.1, 0.15, 0.2)
- **Primary**: Red/gold for important elements
- **Combat Cards**: Red (0.8, 0.3, 0.3)
- **Shop Cards**: Green (0.3, 0.7, 0.3)
- **Event Cards**: Orange (0.7, 0.5, 0.2)
- **Boss Cards**: Purple/Blue (0.3, 0.3, 0.8)

### Animation Principles
- **Juice**: Screen shake, particles, impacts
- **Smoothness**: Lerped movements, easing functions
- **Feedback**: Visual/audio confirmation of actions
- **Clarity**: Never obscure critical information

---

## Audio Design

### Music
- **Main Menu**: Upbeat Hong Kong pop-inspired
- **Battles**: Tension-building, mahjong hall ambiance
- **Shop**: Relaxed, market atmosphere
- **Events**: Situational (typhoon winds, MTR sounds)
- **Bosses**: Epic, dramatic scores
- **Victory**: Triumphant fanfare
- **Defeat**: Melancholic but hopeful

### Sound Effects
- **Tile Sounds**: Click, shuffle, place
- **UI**: Button hovers, clicks, confirmations
- **Battle**: Invalid play warning, victory chime
- **Items**: Consumption sounds (drinking tea, eating food)
- **Ambient**: Hong Kong street noise, weather

---

## Difficulty & Balance

### Difficulty Curve

**Levels 1-5: Tutorial Arc**
- Low fan targets (3-5)
- Generous rounds (5-6)
- Simple patterns expected
- Abundant consumables

**Levels 6-10: Competence Test**
- Medium fan targets (5-8)
- Standard rounds (4-5)
- Mixed patterns required
- Balanced resources

**Levels 11-15: Mastery Required**
- High fan targets (8-10)
- Limited rounds (3-4)
- Advanced patterns needed
- Scarce resources

**Levels 16-20: Legendary Skill**
- Extreme fan targets (10-13)
- Minimal rounds (2-3)
- Perfect play expected
- Strategic item use critical

**Boss Battles**: Special mechanics + high requirements

### Balancing Levers

1. **Fan Targets**: Adjust difficulty directly
2. **Round Limits**: Time pressure control
3. **Deck Composition**: Tile availability
4. **Consumable Drops**: Resource abundance
5. **Shop Prices**: Economic pressure
6. **Relic Power**: Scaling potential
7. **Event Outcomes**: Risk/reward ratios

### Player Power Curve

**Early Game**: Weak, learning, struggling
**Mid Game**: Competent, building strategy, thriving
**Late Game**: Powerful, executing builds, dominating
**Boss**: Test limits, narrow victory, satisfying challenge

---

## Technical Specifications

### Engine: LÖVE2D 11.4
- **Resolution**: 800x600 (resizable)
- **Target FPS**: 60
- **Platform**: Windows, macOS, Linux

### Performance Targets
- **Load Time**: <3 seconds
- **Scene Transitions**: <1 second
- **Battle Start**: <2 seconds
- **Memory**: <512MB
- **CPU**: Minimal (2D only)

### Module Architecture

**Core** (`main.lua`)
- Game state machine
- Input handling
- Konami code system
- Dev tools integration

**Battle** (`mahjong_battle.lua`)
- Battle orchestration
- UI rendering
- Tile drag & drop

**Logic** (`mahjong_logic.lua`)
- Win pattern checking
- Fan calculation
- Hand validation

**State** (`mahjong_state.lua`)
- Battle state management
- Tile deck operations
- Score tracking

**Progression** (`progression_*.lua`)
- Card generation
- Encounter resolution
- Level advancement

**Items** (`hk_*.lua`, `consumables_*.lua`)
- Item definitions
- Effect implementations
- Shop integration

**Atmosphere** (`scene.lua`, `cutin_dialogue.lua`, etc.)
- Story delivery
- Visual polish
- Audio integration

---

## Future Considerations

### Post-Launch Features
- [ ] **Achievements**: Hong Kong culture-themed
- [ ] **Daily Runs**: Seeded challenges
- [ ] **Leaderboards**: High score tracking
- [ ] **More Characters**: Different starting classes
- [ ] **Custom Runs**: Modifier options
- [ ] **Endless Mode**: Survival challenge

### Community Features
- [ ] **Mod Support**: Custom items/events
- [ ] **Multiplayer**: Async or real-time battles
- [ ] **Localization**: English translation
- [ ] **Mobile Port**: Touch controls

### Content Expansion
- [ ] **More Relics**: 30+ total
- [ ] **More Consumables**: 40+ total
- [ ] **Meme Cards**: Full database (50+)
- [ ] **More Events**: 30+ encounters
- [ ] **More Bosses**: Unique mechanics each
- [ ] **Alternative Endings**: 5+ endings

---

## Design Philosophy

### Core Values

1. **Cultural Authenticity**: Real Hong Kong, real struggles, real language
2. **Strategic Depth**: Decisions matter, builds matter, skill matters
3. **Replayability**: Every run feels different
4. **Narrative Integration**: Mechanics support story, story supports mechanics
5. **Respect**: Handle culture and social issues with nuance

### Design Mantras

- **"可以冇錢但係唔可以窮"**: Game about struggle, not hopelessness
- **"獅子山精神"**: Perseverance is rewarded
- **"Hong Kong First"**: Authenticity over accessibility
- **"Mahjong Second"**: Real rules, no compromises
- **"Roguelike Third"**: Replayability through variety

---

## Conclusion

**Get Rich or Die Trying** is designed to be a culturally authentic, strategically deep, narratively rich mahjong roguelike that honors Hong Kong culture while delivering engaging gameplay. Every system—from mahjong mechanics to consumable items to time-loop storytelling—reinforces the core theme: the struggle to rise above economic hardship in modern Hong Kong.

The game respects both mahjong tradition and roguelike innovation, creating a unique hybrid that serves both genres while remaining true to its Hong Kong roots.

---

**End of Design Document**