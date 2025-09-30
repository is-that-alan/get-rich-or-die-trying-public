# 可以冇錢但係唔可以窮 (Get Rich or Die Trying)

> A Hong Kong-themed mahjong roguelike where you play as a delivery boy (外賣仔) fighting through economic hardship with authentic mahjong battles, time-loop storytelling, and real Cantonese culture.

[![LÖVE2D](https://img.shields.io/badge/LÖVE2D-11.4-pink)](https://love2d.org/)
[![Language](https://img.shields.io/badge/Language-Traditional%20Chinese-blue)](https://en.wikipedia.org/wiki/Traditional_Chinese_characters)
[![Culture](https://img.shields.io/badge/Culture-Hong%20Kong-red)](https://en.wikipedia.org/wiki/Hong_Kong)

## 🎮 Game Overview

**Get Rich or Die Trying** is a **mahjong roguelike**, combining authentic Hong Kong mahjong mechanics with card-based progression and a multi-generational time-loop narrative spanning Hong Kong's economic history from the 1990s to 2020s.

![Scene screenshot 1](https://raw.githubusercontent.com/is-that-alan/get-rich-or-die-trying-public/main/public/images/pitch-image-scene-1.png)

![Game screenshot 2](https://raw.githubusercontent.com/is-that-alan/get-rich-or-die-trying-public/main/public/images/pitch-image-game-2.png)


### What Makes This Special

- **🀄 Real Mahjong**: Authentic Hong Kong mahjong rules with 14-tile winning hands and traditional fan scoring
- **🎴 Roguelike Progression**: Card-based advancement through Hong Kong districts
- **🇭🇰 Hong Kong Culture**: Cantonese language, cha chaan teng items, typhoon warnings, and real locations
- **⏰ Time-Loop Story**: Multi-generational narrative from manufacturing boom to cryptocurrency era
- **🍜 Cultural Items**: Milk tea, pineapple buns, fish balls as strategic consumables
- **💎 Professional Polish**: Screen shake, particles, cut-in dialogues, comic-style scenes

---

## 🚀 Quick Start

### Installation

#### macOS/Linux
```bash
# Install LÖVE2D
brew install love  # macOS
# or download from https://love2d.org/

# Run the game
cd get-rich-or-die-trying
love .
```

#### Windows
1. Download LÖVE2D from [love2d.org](https://love2d.org/)
2. Drag the game folder onto `love.exe`

### System Requirements
- **OS**: Windows 7+, macOS 10.9+, or Linux
- **LÖVE2D**: Version 11.4 or higher
- **RAM**: 512MB minimum
- **Display**: 800x600 or higher

---

## 🎯 How to Play

### Game Loop

1. **Progression Screen** → Choose your path (Combat/Shop/Event/Boss)
2. **Mahjong Battle** → Form valid hands to earn fan points
3. **Rewards** → Collect money and items
4. **Shop** → Buy items to strengthen your strategy
5. **Repeat** → Progress through Hong Kong's economic eras

### Controls

#### Mouse
- **Click**: Select cards/tiles
- **Drag & Drop**: Rearrange hand tiles during battle
- **Hover**: View tooltips and help information

#### Keyboard
- **ESC**: Pause menu / Back
- **Space**: Confirm / Continue
- **Arrow Keys**: Navigate menus
- **?** Button: In-game help (hover to see)

#### Developer Tools (Konami Codes)
- **↑↑↓↓←→W**: Instant win current battle
- **↑↑↓↓←→M**: +$1000 money
- **↑↑↓↓←→D**: Cut-in dialogue test menu

---

## 🀄 Mahjong Battle System

### Objective
Form valid 14-tile winning hands to achieve **target fan (番)** within limited rounds.

### Tile Types
- **筒子 (Dots)**: 1-9 circles
- **索子 (Bamboo)**: 1-9 sticks
- **萬字 (Characters)**: 1-9 Chinese numerals
- **風牌 (Winds)**: 東南西北 (East/South/West/North)
- **三元牌 (Dragons)**: 中發白 (Red/Green/White)

### Winning Patterns (Fan Values)

#### Basic Patterns (1-3 Fan)
- **平糊 (Common Hand)**: 1 fan - Any valid 14-tile hand
- **對對糊 (All Pungs)**: 3 fan - All triplets + pair
- **清一色 (Pure Flush)**: 6 fan - All same suit

#### Advanced Patterns (4-8 Fan)
- **小三元 (Small Three Dragons)**: 4 fan - 2 dragon triplets + 1 dragon pair
- **混一色 (Mixed Flush)**: 3 fan - One suit + honors
- **全求人 (All Melded)**: 2 fan - No concealed tiles

#### Rare Patterns (9-13 Fan)
- **大三元 (Big Three Dragons)**: 8 fan - All 3 dragon triplets
- **字一色 (All Honors)**: 10 fan - Only winds/dragons

### How to Win
1. **Draw tiles** from your deck
2. **Drag tiles** to form sets (pairs/triplets/sequences)
3. **Submit hand** when you have 14 tiles in valid pattern
4. **Accumulate fan** across multiple rounds
5. **Meet target** fan before running out of rounds

---

## 🎴 Progression System

### Card Types

#### 🔴 Combat (戰鬥)
Battle opponents in iconic Hong Kong locations:
- **深水埗街市** (Sham Shui Po Market)
- **觀塘工廠** (Kwun Tong Factory)
- **旺角電器舖** (Mong Kok Electronics)
- **銅鑼灣** (Causeway Bay)

**Rewards**: Money, XP, items

#### 🟢 Shop (商店)
Buy items to strengthen your strategy

#### 🟠 Event (事件)
Random Hong Kong encounters with choices:
- **颱風警告** (Typhoon Warning): Risk delivery or stay safe
- **港鐵故障** (MTR Delay): Take taxi or wait
- **街頭擺賣** (Street Vending): Risk profit or legal trouble

**Outcomes**: Money gain/loss, status effects

#### 🟣 Boss (終極)
Major story battles with unique mechanics

---

## 🎯 Current Feature Status

### ✅ Fully Implemented
- [x] Complete Hong Kong mahjong battle system
- [x] Fan-based scoring (1-13 fan patterns)
- [x] Card-based progression (Combat/Shop/Event/Boss)
- [x] 20+ consumable items with HK themes
- [x] 15+ passive relics with cultural references
- [x] Shop system with rarity-based items
- [x] Random event encounters
- [x] Story scene system
- [x] Cut-in dialogue animations
- [x] Visual effects (shake/particles/transitions)
- [x] Weather/typhoon system
- [x] Developer debug tools (Konami codes)
- [x] Hot reload for development
- [x] Chinese font support

### 🚧 Partially Implemented
- [ ] Meme card system (infrastructure exists, database empty)
- [ ] Full time-loop story (scenes exist, not all connected)
- [ ] Karma system (designed, not fully integrated)
- [ ] Weather gameplay effects (coded, needs battle integration)
- [ ] Deck spell variety (basic spells work, needs more)

### ❌ Not Implemented
- [ ] Multiplayer mode
- [ ] Achievements system
- [ ] Statistics tracking
- [ ] Mobile touch controls
- [ ] Social media integration

---

## 🎮 Ready to Play?

```bash
love .
```

**Remember**: 可以冇錢但係唔可以窮！(Get Rich or Die Trying!)