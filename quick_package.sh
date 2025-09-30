#!/bin/bash

# Love2D Game Packaging Script
# Packages game into dist/ directory and optionally builds web version

# =============================================================================
# CONFIGURATION
# =============================================================================

# Game settings
GAME_NAME="game"
GAME_TITLE="Get Rich or Die Trying"

# Build settings
BUILD_WEB=true
MEMORY_SIZE=256000000
WEB_OUTPUT_DIR="web"

# Paths
DIST_DIR="dist"
LOVE_FILE="${DIST_DIR}/${GAME_NAME}.love"

# =============================================================================
# FUNCTIONS
# =============================================================================

print_header() {
    echo "🎮 Love2D Game Packaging Script"
    echo "================================"
    echo ""
}

print_config() {
    echo "📋 Build Configuration:"
    echo "  Game Name: ${GAME_NAME}"
    echo "  Game Title: ${GAME_TITLE}"
    echo "  Build Web: ${BUILD_WEB}"
    echo "  Memory Size: ${MEMORY_SIZE} bytes"
    echo "  Web Output: ${DIST_DIR}/${WEB_OUTPUT_DIR}/"
    echo ""
}

build_love_file() {
    echo "📦 Building .love file..."
    
    # Create dist directory
    mkdir -p "${DIST_DIR}"
    
    # Create .love file by zipping all necessary files
    zip -r "${LOVE_FILE}" . \
        -x "*.DS_Store" \
        -x ".git/*" \
        -x ".vscode/*" \
        -x ".kiro/*" \
        -x "*.orig" \
        -x "test_*.lua" \
        -x "check_tiles.*" \
        -x "*.sh" \
        -x "*.md" \
        -x "dist/*" \
        -x "*.love" \
        -x "web/*" \
        -x "*.log" \
        -x "*.tmp" \
        -x "*.temp" \
        -x "*.bak" \
        -x "*.backup" \
        -x "*.old" \
        -x "*.swp" \
        -x "*.swo" \
        -x "*~" \
        -x "Thumbs.db" \
        -x "desktop.ini" \
        -x ".luacheckrc" \
        -x ".gitignore" \
        -x "HOT_RELOAD_STATUS.md" \
        -x "ENHANCED_FEATURES.md" \
        -x "FINAL_SUMMARY.md" \
        -x "GAME_STRUCTURE.md" \
        -x "MUSIC_SYSTEM_SUMMARY.md" \
        -x "ZOOM_FEATURE.md" \
        -x "CUTIN_DIALOGUE_SYSTEM.md*" \
        -x "CONTROLS.md" \
        -x "PACKAGING.md"
    
    if [ $? -eq 0 ]; then
        echo "✅ Created: ${LOVE_FILE}"
        echo "📊 Size: $(du -h "${LOVE_FILE}" | cut -f1)"
    else
        echo "❌ Failed to create .love file"
        exit 1
    fi
    echo ""
}

build_web_version() {
    if [ "$BUILD_WEB" = true ]; then
        echo "🌐 Building web version..."
        
        # Check if love.js is available
        if ! command -v love.js &> /dev/null; then
            echo "❌ love.js not found. Please install it first:"
            echo "   npm install -g love.js"
            echo ""
            echo "Skipping web build..."
            return 1
        fi
        
        # Change to dist directory and run love.js
        cd "${DIST_DIR}"
        
        love.js "${GAME_NAME}.love" \
            -m "${MEMORY_SIZE}" \
            -t "${GAME_TITLE}" \
            "${WEB_OUTPUT_DIR}" \
            -c
        
        if [ $? -eq 0 ]; then
            echo "✅ Web build completed: ${DIST_DIR}/${WEB_OUTPUT_DIR}/"
            echo "📊 Web build size: $(du -sh "${WEB_OUTPUT_DIR}" | cut -f1)"
        else
            echo "❌ Web build failed"
            cd ..
            return 1
        fi
        
        # Return to original directory
        cd ..
        echo ""
    fi
}

print_usage_instructions() {
    echo "🎯 Usage Instructions:"
    echo "  Desktop: love ${LOVE_FILE}"
    if [ "$BUILD_WEB" = true ]; then
        echo "  Web:     Open ${DIST_DIR}/${WEB_OUTPUT_DIR}/index.html in browser"
        echo "  Web Dev: cd ${DIST_DIR}/${WEB_OUTPUT_DIR} && python3 -m http.server"
    fi
    echo ""
}

# =============================================================================
# MAIN SCRIPT
# =============================================================================

print_header
print_config

# Build .love file
build_love_file

# Build web version if enabled
build_web_version

# Print usage instructions
print_usage_instructions

echo "🎉 Build process completed!"
