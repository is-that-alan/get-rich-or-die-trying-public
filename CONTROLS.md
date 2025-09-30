# Game Controls & Features

## 🀄️ Mahjong Battle Controls

### Multi-Select Tile System
- **Drag Selection**: Click and drag across tiles to select multiple tiles
- **Individual Click**: Click on tiles to toggle selection
- **Selection Visual**: Selected tiles glow yellow with numbered indicators
- **Clear Selection**: Press `Escape` to clear all selections

### Keyboard Shortcuts
- **Ctrl+A**: Select all tiles in hand
- **Escape**: Clear current selection
- **Space**: Quick draw tile (if hand < 14)
- **Enter**: Quick win declaration (if hand is winning)
- **Delete/Backspace**: Quick discard first selected tile

### Mouse Controls
- **Left Click**: Select/deselect individual tiles
- **Drag**: Multi-select tiles by dragging across them
- **Button Clicks**: Use UI buttons for actions

### Game Actions
- **摸牌 (Draw)**: Add a tile to your hand (up to 14 tiles)
- **棄牌 (Discard)**: Remove selected tile from hand (when hand = 14)
- **和牌 (Win)**: Declare victory with a complete mahjong hand
- **講meme**: Activate meme phrases with collected characters

## 🔥 Hot Reload (Development)

### LICK Integration
- **Ctrl+R**: Manual reload
- **Auto-reload**: Automatically reloads when files change
- **File Watching**: Monitors `main.lua` for changes

### Development Features
- Real-time code updates without restarting
- Preserves game state during reload
- Console output for reload status

## 🎮 General Controls

### Navigation
- **Mouse**: Click to interact with UI elements
- **Escape**: Quit game
- **Map Navigation**: Click adjacent locations to move

### Scene & Dialogue System
- **Click Dialogue Box**: Click on dialogue box to advance dialogue
- **Click Image**: Click anywhere on the image to advance to next panel (when no dialogue or dialogue complete)
- **Arrow Keys**: Use ← → arrows to navigate between scene panels
- **Auto-Finish**: When reaching the last panel, clicking will automatically finish the scene
- **Escape**: Exit current scene

### Mahjong Hand Analysis
- **Real-time Evaluation**: Shows current hand type and score
- **Tenpai Detection**: Alerts when ready to win
- **Waiting Tiles**: Shows which tiles you need to win
- **Fan Calculation**: Traditional mahjong scoring

## 🎮 Konami Codes (Cheat Codes)

### Available Codes
- **↑↑↓↓←→D**: Open Developer Menu
- **↑↑↓↓←→W**: Force Win (during battle)
- **↑↑↓↓←→M**: Add $1000 Money 💰

### How to Use
1. Press the key sequence in order
2. Visual and audio feedback will confirm activation
3. Codes work from any screen
4. Sequence resets if wrong key is pressed

## 📱 User Experience Features

### Visual Feedback
- **Selection Glow**: Yellow highlight for selected tiles
- **Selection Numbers**: Shows selection order for multiple tiles
- **Drag Rectangle**: Blue selection area during drag
- **Hand Counter**: Shows current hand size (X/14)
- **Selection Counter**: Shows number of selected tiles

### Authentic Mahjong Feel
- **13-tile Starting Hand**: Standard mahjong hand size
- **Draw-Discard Cycle**: Authentic mahjong gameplay flow
- **Pattern Recognition**: Real mahjong winning patterns
- **Traditional Scoring**: Fan-based scoring system

### Hong Kong Cultural Elements
- **Meme Phrases**: Collect characters to form Cantonese memes
- **Cultural Locations**: Navigate Hong Kong districts
- **Traditional Chinese**: Authentic language throughout
- **Local Humor**: Hong Kong internet culture integration

## 🎯 Pro Tips

### Efficient Selection
1. **Drag Selection**: Fastest way to select multiple adjacent tiles
2. **Ctrl+A**: Quick way to see all tiles at once
3. **Escape**: Quick deselection when you change your mind
4. **Number Indicators**: Track selection order for complex hands

### Mahjong Strategy
1. **Watch Hand Analysis**: Real-time feedback on your progress
2. **Tenpai Alerts**: Pay attention to "ready to win" notifications
3. **Pattern Building**: Focus on sequences and triplets
4. **Discard Strategy**: Remove tiles that don't fit your patterns

### Meme System
1. **Character Collection**: Buy characters in shops
2. **Phrase Formation**: Combine 3+ characters for effects
3. **Strategic Timing**: Use memes for maximum impact
4. **Cultural Learning**: Discover authentic Cantonese expressions

## 🛠️ Development Mode

When developing or modifying the game:
1. **LICK Hot Reload**: Edit files and see changes instantly
2. **Console Output**: Monitor loading and error messages
3. **Debug Keys**: Use keyboard shortcuts for testing
4. **State Preservation**: Game state maintained during reloads