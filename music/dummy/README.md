# Dummy Audio Files

This folder contains placeholder audio files for testing the music system.

## Test Files Needed

To test the music system, please add these dummy audio files:

1. `test_bgm.ogg` - A simple background music loop (any .ogg file will work)
2. `test_sfx.ogg` - A simple sound effect (any short .ogg file will work)

## Quick Setup for Testing

You can use any .ogg audio files you have available:

1. Rename any background music file to `test_bgm.ogg`
2. Rename any short sound effect to `test_sfx.ogg`
3. Place them in this folder

The music system will automatically detect and use these files for testing.

## Converting Audio Files

If you have .mp3 or .wav files, you can convert them to .ogg using:
- Online converters
- FFmpeg: `ffmpeg -i input.mp3 output.ogg`
- Audacity (free audio editor)

## File Requirements

- Format: .ogg (preferred) or .mp3/.wav
- Background music: Should loop seamlessly
- Sound effects: Short duration (< 2 seconds recommended)
- File size: Keep reasonable for game distribution