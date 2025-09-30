# Love2D Game Packaging

Simple script to package your Love2D game into a `.love` file.

## Quick Start

```bash
./quick_package.sh
```

This creates `dist/get-rich-or-die-trying.love` (128MB) that you can:
- Play with: `love dist/get-rich-or-die-trying.love`
- Share with others who have Love2D installed

## What Gets Included

- ✅ All `.lua` files (game code)
- ✅ `conf.lua` (Love2D configuration)
- ✅ Asset directories: `consumables/`, `tiles/`, `music/`, `scenes/`, `cutin_dialogues/`, `designs/`, `Noto_Sans_TC/`
- ✅ Additional assets: `.png`, `.jpg`, `.wav`, `.mp3`, `.ttf`, etc.

## What Gets Excluded

- ❌ `.git/`, `.vscode/`, `.kiro/` (development files)
- ❌ `*.orig`, `test_*.lua`, `*.sh`, `*.md` (utility files)
- ❌ `dist/` (output directory)
- ❌ `.DS_Store` (macOS files)

## Requirements

- **zip**: Required for creating `.love` files
- **Love2D**: Optional, for testing packages

## Package Size

Your game package is **128MB** and includes all game assets and code.
