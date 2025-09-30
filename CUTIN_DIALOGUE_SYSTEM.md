# Cut-in Dialogue System


A comprehensive system for displaying animated cut-in dialogues.


## Overview

The cut-in dialogue system provides animated, full-screen dialogue overlays that appear during special events. Each cut-in dialogue includes character images, names, dialogue text, sound effects, and smooth animations.

## Features

- **Animated Appearance**: Smooth fade-in, display, and fade-out animations
- **Character Support**: Character images and names
- **Sound Effects**: Optional SFX and BGM changes
- **Customizable Timing**: Configurable display duration (default 3 seconds)
- **Search & Preview**: Developer menu for testing and previewing all cut-ins
- **Easy Integration**: Simple API for triggering cut-ins from game events

## File Structure

```
cutin_dialogues/
├── characters/           # Character images for cut-ins
│   ├── andylau-cool.png
│   ├── seanlau-angry.png
│   ├── wongtinlam-shocked.png
│   ├── ugly-chef.png
│   └── tong-ngau.png
├── battle_events.lua     # Battle-related cut-ins
├── story_moments.lua     # Story progression cut-ins
├── shop_events.lua       # Shop interaction cut-ins
└── level_transitions.lua # Level/era transition cut-ins
```

## Usage

### Basic Usage

```lua
local CutinDialogue = require("cutin_dialogue")

-- Show a cut-in dialogue using string keys
CutinDialogue.show("battle_events", "victory_andy")  -- Show victory dialogue from battle_events

-- Check if cut-in is active
if CutinDialogue.isActive() then
    -- Handle cut-in display
end

-- Force close current cut-in
CutinDialogue.close()
```

### Developer Menu

Access the cut-in test menu through the developer menu (Konami code: ↑↑↓↓←→D):

1. Open developer menu
2. Click "Test Cut-in Dialogues"
3. Browse and search cut-ins
4. Click "Preview Selected" to test animations
5. Use arrow keys for navigation
6. Press Space to toggle search mode

## Cut-in Data Format

Each cut-in dialogue file should export a table with the following structure:

```lua
return {
    name = "Cut-in Set Name",
    description = "Description of when these cut-ins are used",
    
    dialogues = {
        -- Use string keys for dialogue identification
        victory_andy = {
            character = "Character Name",
            characterImage = "cutin_dialogues/characters/character_name.png", -- Optional
            text = "Dialogue text to display",
            sfx = "sound_effect_name", -- Optional
            appearSeconds = 3.0, -- Display duration (default 3)
            color = {1, 1, 1}, -- RGB color for text (default white)
            bgm = "background_music_track" -- Optional BGM change
        },
        defeat_sean = {
            character = "Another Character",
            characterImage = "cutin_dialogues/characters/another_character.png",
            text = "Another dialogue text",
            appearSeconds = 2.0,
            color = {1, 0.8, 0.2} -- Gold color
        },
        -- ... more dialogues with string keys
    }
}
```

## Animation Details

### Animation States
- **FADE_IN**: Slides in from the side (0.5s)
- **DISPLAY**: Shows dialogue in bottom-left corner
- **FADE_OUT**: Slides out horizontally (0.5s)

### Visual Effects
- **Slide Animation**: 150px horizontal slide distance
- **Bottom-Left Layout**: Character image and dialogue box positioned in bottom-left corner
- **Character Sizing**: Maximum 33% of screen dimensions for character images
- **Feathered Background**: Multi-layered background with smooth gradient effect
- **No Modal Overlay**: Less intrusive design without dark background

## Integration Examples

### Battle Events
```lua
-- In mahjong_battle.lua
if battleWon then
    CutinDialogue.show("battle_events", "victory_andy") -- Victory dialogue
elseif battleLost then
    CutinDialogue.show("battle_events", "defeat_sean") -- Defeat dialogue
end
```

### Story Progression
```lua
-- In progression.lua
if levelUp then
    CutinDialogue.show("story_moments", "level_up") -- Level up dialogue
end
```

### Shop Events
```lua
-- In shop.lua
if expensivePurchase then
    CutinDialogue.show("shop_events", "expensive_item") -- Expensive item dialogue
end
```

## API Reference

### Core Functions

#### `CutinDialogue.init()`
Initialize the cut-in dialogue system. Called automatically in `love.load()`.

#### `CutinDialogue.show(cutinId, dialogueKey)`
Display a cut-in dialogue.
- `cutinId`: ID of the cut-in set (e.g., "battle_events")
- `dialogueKey`: String key of dialogue within the set (e.g., "victory_andy")
- Returns: `true` if successful, `false` if cut-in not found

#### `CutinDialogue.update(dt)`
Update cut-in animations. Called automatically in `love.update()`.

#### `CutinDialogue.draw()`
Draw current cut-in dialogue. Called automatically in `love.draw()`.

#### `CutinDialogue.isActive()`
Check if a cut-in dialogue is currently being displayed.
- Returns: `true` if active, `false` otherwise

#### `CutinDialogue.close()`
Force close the current cut-in dialogue.

### Utility Functions

#### `CutinDialogue.getAllCutins()`
Get all loaded cut-in dialogue sets.
- Returns: Table of cut-in sets indexed by ID

#### `CutinDialogue.searchCutins(searchTerm)`
Search cut-in dialogues by text, character, or ID.
- `searchTerm`: Search query string
- Returns: Array of matching cut-ins

## Customization

### Adding New Cut-ins

1. Create a new `.lua` file in `cutin_dialogues/`
2. Follow the data format structure
3. Add character images to `cutin_dialogues/characters/`
4. Reference the cut-in in your game code

### Modifying Animations

Edit `ANIMATION_SETTINGS` in `cutin_dialogue.lua`:
```lua
local ANIMATION_SETTINGS = {
    SLIDE_DISTANCE = 150,      -- Horizontal slide distance
    GLOW_INTENSITY = 0.3       -- Glow effect intensity
}
```

### Custom Colors

Use RGB values (0-1 range) for text colors:
```lua
color = {1, 0.8, 0.2}    -- Gold
color = {0.3, 0.7, 1}    -- Blue
color = {1, 0.3, 0.3}    -- Red
color = {0.7, 0.7, 0.7}  -- Gray
```

## Sound Integration

The system integrates with the existing music system:

- **SFX**: Uses `Music.playSFX(sfxName)` for sound effects
- **BGM**: Uses `Music.playBGM(trackName)` for background music changes
- **Stop BGM**: Use `bgm = "stop"` to stop current background music

## Performance Notes

- Character images are cached after first load
- Cut-in data is loaded once at initialization
- Animations are lightweight and don't impact game performance
- System automatically cleans up when cut-ins complete

## Troubleshooting

### Common Issues

1. **Cut-in not showing**: Check that cut-in ID and dialogue index exist
2. **Character image missing**: Verify image path and file exists
3. **Sound not playing**: Check SFX/BGM names match music system registry
4. **Animation glitches**: Ensure `CutinDialogue.update(dt)` is called in main update loop

### Debug Information

The system prints debug information to console:
- Cut-in loading status
- Animation state changes
- Error messages for missing files

## Future Enhancements

Potential improvements for the system:
- Multiple cut-ins queuing
- Custom animation curves
- Voice acting support
- Particle effects integration
- Cut-in templates for easy creation
