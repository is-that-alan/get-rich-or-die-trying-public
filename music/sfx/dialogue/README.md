# Dialogue Sound Effects

This folder contains sound effects for the dialogue system.

## Required SFX Files

### Typewriter Effect
- `typewriter.wav` - Short typing sound for typewriter animation

### Character Emotions
- `sigh.ogg` - Character sighing sound
- `gasp.ogg` - Character gasping in surprise
- `laugh.ogg` - Character laughing sound

### UI Sounds
- `notification.wav` - Ding sound for important dialogue moments

## Audio Format Guidelines

- **Format**: WAV or OGG recommended
- **Length**: 0.1-2.0 seconds for most effects
- **Volume**: Normalized to prevent clipping
- **Quality**: 44.1kHz, 16-bit minimum

## Usage in Dialogue Files

Use the `[SFX:soundname]` tag in dialogue files:

```
[SFX:sigh]
唉...我又冇錢喇...

[SFX:gasp]
咩話？！

[SFX:ding]
我有個好主意！
```

## Fallback Behavior

If SFX files are missing, the dialogue system will:
1. Print a warning to console
2. Continue without playing the sound
3. Not break the dialogue flow