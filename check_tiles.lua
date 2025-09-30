#!/usr/bin/env lua

-- Script to check which tiles are not displayable
-- This will identify missing tile images and broken links

print("🔍 Checking for non-displayable tiles...")

-- Function to check if file exists
local function fileExists(filename)
    local file = io.open(filename, "r")
    if file then
        file:close()
        return true
    end
    return false
end

-- All expected tile patterns the game might request
local expectedTiles = {
    -- Dot tiles (筒)
    "筒_1.png", "筒_2.png", "筒_3.png", "筒_4.png", "筒_5.png",
    "筒_6.png", "筒_7.png", "筒_8.png", "筒_9.png",

    -- Bamboo tiles (條)
    "條_1.png", "條_2.png", "條_3.png", "條_4.png", "條_5.png",
    "條_6.png", "條_7.png", "條_8.png", "條_9.png",

    -- Character tiles (萬)
    "萬_1.png", "萬_2.png", "萬_3.png", "萬_4.png", "萬_5.png",
    "萬_6.png", "萬_7.png", "萬_8.png", "萬_9.png",

    -- Character tiles (Chinese numbers)
    "一_1.png", "二_2.png", "三_3.png", "四_4.png", "五_5.png",
    "六_6.png", "七_7.png", "八_8.png", "九_9.png",

    -- Wind tiles
    "東_東.png", "南_南.png", "西_西.png", "北_北.png",

    -- Dragon tiles
    "白_白.png", "中_中.png", "發_發.png"
}

-- Available actual PNG files
local actualFiles = {
    "dot_1.png", "dot_2.png", "dot_3.png", "dot_4.png", "dot_5.png",
    "dot_6.png", "dot_7.png", "dot_8.png", "dot_9.png",
    "bam_1.png", "bam_2.png", "bam_3.png", "bam_4.png", "bam_5.png",
    "bam_6.png", "bam_7.png", "bam_8.png", "bam_9.png",
    "char_1.png", "char_2.png", "char_3.png", "char_4.png", "char_5.png",
    "char_6.png", "char_7.png", "char_8.png", "char_9.png",
    "wind_east.png", "wind_south.png", "wind_west.png", "wind_north.png",
    "dragon_white.png", "dragon_red.png", "dragon_green.png"
}

print("\n📋 Checking tiles directory...")

local missing = {}
local existing = {}

-- Check each expected tile
for _, tile in ipairs(expectedTiles) do
    local path = "tiles/" .. tile
    if fileExists(path) then
        table.insert(existing, tile)
        print("✅ " .. tile)
    else
        table.insert(missing, tile)
        print("❌ " .. tile .. " - NOT FOUND")
    end
end

print("\n📊 Summary:")
print("✅ Working tiles: " .. #existing)
print("❌ Missing tiles: " .. #missing)

if #missing > 0 then
    print("\n🔧 Missing tiles that need symbolic links:")
    for _, tile in ipairs(missing) do
        print("  " .. tile)
    end

    print("\n💡 To fix, run these commands:")
    print("cd tiles")

    -- Generate fix commands
    local linkCommands = {
        -- Bamboo tiles
        'ln -sf bam_1.png 條_1.png', 'ln -sf bam_2.png 條_2.png', 'ln -sf bam_3.png 條_3.png',
        'ln -sf bam_4.png 條_4.png', 'ln -sf bam_5.png 條_5.png', 'ln -sf bam_6.png 條_6.png',
        'ln -sf bam_7.png 條_7.png', 'ln -sf bam_8.png 條_8.png', 'ln -sf bam_9.png 條_9.png',

        -- Character tiles (Chinese numbers)
        'ln -sf char_1.png 一_1.png', 'ln -sf char_2.png 二_2.png', 'ln -sf char_3.png 三_3.png',
        'ln -sf char_4.png 四_4.png', 'ln -sf char_5.png 五_5.png',

        -- Dragon tiles
        'ln -sf dragon_white.png 白_白.png', 'ln -sf dragon_red.png 中_中.png', 'ln -sf dragon_green.png 發_發.png'
    }

    for _, cmd in ipairs(linkCommands) do
        print(cmd)
    end
end

print("\n🎮 To see missing tiles in real-time, watch the game console for:")
print("🔍 正在嘗試載入瓦片: tiles/FILENAME.png")
print("❌ 找不到瓦片文件: tiles/FILENAME.png")
print("🎨 回退到生成瓦片圖像: TILENAME")