# Scene Dialogue Format

This document describes the dialogue format for scene files.

## File Structure

For each scene panel, create a corresponding `.txt` file:
- `01.png` → `01.txt`
- `02.png` → `02.txt`
- etc.

## Dialogue Format

Each dialogue file uses a subtitle-style format with timing and formatting:

```
1
00:00:000 --> 00:03:000
[CHARACTER:阿明]
你好！我係住劏房嘅外賣仔。

2
00:03:000 --> 00:06:000
[COLOR:red]
而家搵錢真係好難啊...

3
00:06:000 --> 00:09:000
[CHARACTER:女朋友][COLOR:blue]
你成日都係咁講！
點解唔去搵份好工？

4
00:09:000 --> 00:12:000
[SFX:sigh]
唉...我會努力搵快錢！
```

## Format Tags

### Character Names
- `[CHARACTER:name]` - Display character name
- Example: `[CHARACTER:阿明]`, `[CHARACTER:女朋友]`

### Text Colors
- `[COLOR:colorname]` - Set text color
- Colors: `white`, `red`, `blue`, `green`, `yellow`, `orange`, `purple`, `gray`
- Example: `[COLOR:red]`, `[COLOR:blue]`

### Sound Effects
- `[SFX:soundname]` - Play sound effect when dialogue starts
- Example: `[SFX:sigh]`, `[SFX:gasp]`, `[SFX:laugh]`

### Background Music (Dialogue-Level)
- `[BGM:trackname]` - Change background music when dialogue starts
- `[BGM:stop]` - Stop current background music
- Example: `[BGM:story_dramatic]`, `[BGM:era_1990s]`, `[BGM:stop]`
- **Note**: This overrides scene-level BGM temporarily

### Special Formatting
- `[SPEED:fast]` - Fast typewriter speed
- `[SPEED:slow]` - Slow typewriter speed
- `[SPEED:normal]` - Normal speed (default)
- `[PAUSE:1000]` - Pause for milliseconds before continuing

## Timing Format

- `HH:MM:SSS` format (hours:minutes:seconds.milliseconds)
- `00:00:000` = start immediately
- `00:03:000` = 3 seconds duration
- Timing controls typewriter animation speed

## Example Complete Dialogue File

```
1
00:00:000 --> 00:04:000
[CHARACTER:外賣仔][COLOR:white]
我係一個住劏房嘅外賣仔...

2
00:04:000 --> 00:07:000
[COLOR:yellow][SFX:ding][BGM:story_dramatic]
想用各種方法搵快錢！

3
00:07:000 --> 00:10:000
[CHARACTER:旁白][COLOR:gray][SPEED:slow][BGM:stop]
但係搵快錢真係咁容易咩？
```

## Scene-Level vs Dialogue-Level BGM

### Scene-Level BGM (scene.txt)
- **Plays for entire scene** across all panels
- **Set once** when scene loads
- **Continues playing** until scene ends or dialogue overrides it
- **Use for**: Consistent atmosphere throughout the scene

### Dialogue-Level BGM (dialogue files)
- **Changes during specific dialogue**
- **Temporary override** of scene BGM
- **Returns to scene BGM** when dialogue ends (if no other changes)
- **Use for**: Dramatic moments, emotional shifts, special effects

### Example Workflow
1. Scene loads → `scene.txt` starts `[BGM:story_intro]`
2. Panel 3 dialogue → `[BGM:story_tense]` (temporary change)
3. Panel 4 dialogue → No BGM tag (continues story_tense)
4. Next scene loads → New scene BGM starts

## UTF-8 Support

- Full Chinese character support
- Traditional Chinese recommended for Hong Kong setting
- Emoji support: 😊💰🏠
- Mixed language support (Chinese + English)