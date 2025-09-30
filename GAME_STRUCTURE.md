# 🎮 Hong Kong Mahjong Game - Clean Structure

## 📁 **Core Game Files**

### **Main Game Loop**
- `main.lua` - Entry point, game state management, main loop
- `conf.lua` - LÖVE configuration

### **Game Systems**
- `card.lua` - Mahjong tile system, hand evaluation, drawing
- `mahjong_battle.lua` - Core gameplay, battle mechanics
- `map.lua` - World navigation, location selection
- `shop.lua` - Card purchasing system

### **Enhancement Systems**
- `juice.lua` - Visual effects, screen shake, particles, sounds
- `hk_flavor.lua` - Hong Kong cultural elements, greetings, reactions
- `progression.lua` - Experience, levels, achievements

### **Legacy Systems (Simplified)**
- `battle.lua` - Original card battle system (kept for compatibility)
- `fortress.lua` - Original fortress building (simplified)
- `challenge.lua` - Challenge system framework

### **Utilities**
- `generate_tiles.lua` - Procedural tile graphics generation
- `lick.lua` - Hot reload support for development
- `utf8.lua` - Chinese character support

## 📋 **File Purpose Summary**

| File | Purpose | Status |
|------|---------|--------|
| `main.lua` | Game entry point & state management | ✅ Active |
| `mahjong_battle.lua` | Core mahjong gameplay | ✅ Active |
| `card.lua` | Tile system & hand evaluation | ✅ Active |
| `juice.lua` | Visual effects & feedback | ✅ Active |
| `hk_flavor.lua` | Hong Kong cultural elements | ✅ Active |
| `progression.lua` | Player progression system | ✅ Active |
| `map.lua` | World navigation | ✅ Active |
| `shop.lua` | Card purchasing | ✅ Active |
| `generate_tiles.lua` | Tile graphics generation | ✅ Utility |
| `battle.lua` | Legacy card battle | 📦 Legacy |
| `fortress.lua` | Legacy fortress building | 📦 Legacy |
| `challenge.lua` | Challenge framework | 📦 Legacy |

## 🗑️ **Removed Files**
- `progression_system.lua` - Redundant (merged into `progression.lua`)
- `sound_manager.lua` - Replaced by simplified sounds in `juice.lua`
- `hong_kong_atmosphere.lua` - Features integrated into other modules
- `convert_riichi_tiles.lua` - Development tool no longer needed
- `setup_tiles.sh` - Development script
- `SETUP_RIICHI_TILES.md` - Development documentation
- `TILE_IMAGES.md` - Development documentation
- `test_game.lua` - Temporary test file

## 🎯 **Clean Architecture Benefits**
- **Focused modules**: Each file has a clear, single purpose
- **No redundancy**: Removed duplicate functionality
- **Easy maintenance**: Clear separation of concerns
- **Hackathon ready**: Streamlined codebase for presentations
- **Performance**: Fewer file loads, cleaner memory usage

The game now has a **clean, professional structure** perfect for a hackathon demo! 🚀