# Story Scene Background Music

This folder contains background music tracks for story scenes and dialogue.

## Available BGM Tracks for Dialogue

### General Story Music
- `story_intro` - Opening/introduction music
- `story_dramatic` - Dramatic/intense moments
- `story_ending` - Chapter ending music
- `story_sad` - Sad/melancholic moments
- `story_hopeful` - Hopeful/optimistic themes
- `story_tense` - Building tension/suspense

### Era-Specific Music
- `era_1990s` - 1990s Hong Kong atmosphere
- `era_2000s` - 2000s property boom era
- `era_2010s` - 2010s digital age

### Special Tracks
- `robot_wizard` - Robot wizard encounter music

## Usage in Dialogue Files

Use the `[BGM:trackname]` tag in dialogue files:

```
[BGM:story_intro]
歡迎嚟到香港！

[BGM:story_dramatic]
點解我啲投資全部都跌晒？！

[BGM:stop]
(停止背景音樂)
```

## Audio Format Guidelines

- **Format**: OGG or MP3 recommended for BGM
- **Length**: 2-5 minutes (will loop automatically)
- **Volume**: Normalized, not too loud (dialogue should be audible)
- **Quality**: 44.1kHz, 128kbps minimum

## BGM vs SFX Interaction

- **BGM and SFX are independent** - SFX won't interrupt or affect BGM
- **BGM changes smoothly** - New BGM replaces current track
- **SFX plays over BGM** - Short sound effects layer on top
- **Use `[BGM:stop]`** to silence music for dramatic effect

## Fallback Behavior

If BGM files are missing, the system will:
1. Print a warning to console
2. Try to play a fallback dummy track
3. Continue dialogue without breaking