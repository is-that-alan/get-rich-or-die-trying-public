# Music Assets

## Folder Structure

```
music/
├── bgm/                    # Background Music
│   ├── menu/              # Menu screen music
│   ├── battle/            # Battle music
│   ├── map/               # Map/exploration music
│   ├── shop/              # Shop ambient music
│   ├── story/             # Story scene music
│   └── era/               # Era-specific music
│       ├── 1990s/         # 1990s Hong Kong music
│       ├── 2000s/         # 2000s Hong Kong music
│       └── 2010s/         # 2010s Hong Kong music
├── sfx/                   # Sound Effects
│   ├── ui/                # UI interaction sounds
│   ├── cards/             # Card play sounds
│   ├── battle/            # Battle action sounds
│   └── ambient/           # Ambient Hong Kong sounds
└── dummy/                 # Placeholder/test files
```

## Music Themes by Context

### Menu Music
- Hong Kong nostalgic themes
- Cantonese pop influences
- Welcoming but slightly melancholic

### Battle Music
- Intense, fast-paced
- Traditional Chinese instruments mixed with modern beats

### Map/Exploration Music
- Ambient Hong Kong street sounds
- Subtle background melodies
- Different variations for different districts

### Shop Music
- Calm, commercial atmosphere
- Light Cantonese instrumental
- Tea restaurant vibes

### Era-Specific Music
- **1990s**: Manufacturing boom, optimistic synth-pop
- **2000s**: Property market frenzy, electronic beats
- **2010s**: Digital age, AI/tech sounds, modern pop

## File Formats
- Primary: `.ogg` (recommended for LÖVE2D)
- Fallback: `.mp3`, `.wav`
- All files should be optimized for game use (reasonable file sizes)

## Volume Guidelines
- Background music: -20dB to -15dB
- Sound effects: -10dB to -5dB
- Ensure no clipping or distortion