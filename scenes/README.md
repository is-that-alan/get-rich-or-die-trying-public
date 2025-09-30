# Story Scenes

This folder contains story scenes for the Hong Kong mahjong game. Each scene is a folder containing comic-style images that tell part of the story.

## Folder Structure

```
scenes/
├── intro/              # Opening story
├── level1/             # Story for level 1
├── level1_to_level2/   # Level transition scene (level 1 ending + level 2 intro)
├── level2/             # Story for level 2
└── ...
```

## How to Add Story Scenes

1. **Create a scene folder** (e.g., `scenes/intro/`)
2. **Add images** in PNG or JPG format
3. **Add dialogue files** (optional) in TXT format
4. **Add scene config** (optional) for scene-wide settings
5. **Name files to match exactly**:
   - `01.png` ↔ `01.txt` (zero-padded numbers)
   - `1.png` ↔ `1.txt` (simple numbers)
   - `a.png` ↔ `a.txt` (alphabetical)
   - `panel1.png` ↔ `panel1.txt` (descriptive names)

   **Rule**: Dialogue file must have same base name as image file

## Image Guidelines

- **Format**: PNG or JPG
- **Resolution**: Any size (will be scaled to fit screen)
- **Aspect Ratio**: 16:9 recommended for best fit
- **Naming**: Use consistent naming that sorts correctly

## Example Scene Structure

```
scenes/intro/
├── scene.txt                 # Scene configuration (optional)
├── 1.png
├── 1.txt                     # Dialogue for 1.png
├── 2.png
├── 2.txt                     # Dialogue for 2.png
├── 3.png
├── 3.txt                     # Dialogue for 3.png
├── 4.png
└── 4.txt                     # Dialogue for 4.png

scenes/level1_to_level2/
├── scene.txt                 # Scene configuration (optional)
├── 01.png
├── 01.txt                    # Dialogue for 01.png
├── 02.png
├── 02.txt                    # Dialogue for 02.png
├── 03.png
└── 04.png                    # No dialogue = image only
```

## How It Works

1. Player triggers a story scene (from map, battle completion, etc.)
2. Scene system loads all images and dialogue files from the specified folder
3. **With Dialogue**: Typewriter animation displays text with SFX
4. **Navigation**:
   - **→ Arrow Key** or **Click**: Advance dialogue or go to next panel
   - **← Arrow Key**: Go to previous panel
   - **SPACE Key**: Skip current scene (testing mode)
   - **ESC Key**: Exit scene (return to menu)
5. At the final panel, "Finish Story" button advances to next level

## Scene Configuration (scene.txt)

Optional `scene.txt` file for scene-wide settings:

```
[BGM:story_dramatic]
[BGM_END:stop]
[TITLE:Level 1 Ending]
[DESCRIPTION:The dot-com crash of 2000]
```

**BGM Control Examples:**
- `[BGM_END:stop]` - Silence after scene
- `[BGM_END:menu]` - Return to menu music
- `[BGM_END:story_hopeful]` - Transition to hopeful music
- No `BGM_END` tag - Music continues to next scene

**Available Scene Tags:**
- `[BGM:trackname]` - Background music for entire scene
- `[BGM_END:stop]` - Stop music when scene ends
- `[BGM_END:trackname]` - Change to specific track when scene ends
- `[TITLE:text]` - Scene title (displayed in UI)
- `[DESCRIPTION:text]` - Scene description

## Dialogue Features

- **Typewriter Animation**: Text appears character-by-character
- **Chinese Character Support**: Full UTF-8 support for Traditional Chinese
- **Color Text**: Use `[COLOR:red]` tags for colored dialogue
- **Character Names**: Use `[CHARACTER:name]` to show speaker
- **Sound Effects**: Use `[SFX:sound]` to play audio cues
- **Speed Control**: Use `[SPEED:fast/slow/normal]` for typing speed
- **Background Music**: Use `[BGM:track]` for dialogue-specific music changes

## Integration

To trigger a scene from your game code:
```lua
triggerStoryScene("intro")            -- Loads scenes/intro/
triggerStoryScene("level1")          -- Loads scenes/level1/
triggerStoryScene("level1_to_level2") -- Loads scenes/level1_to_level2/
```

The scene system automatically handles:
- Image loading and scaling
- Navigation controls
- UI display
- Level progression when story completes