#!/bin/bash

# Script to check which tiles are not displayable

echo "🔍 Checking for non-displayable tiles..."

# Expected tile patterns
expected_tiles=(
    "筒_1.png" "筒_2.png" "筒_3.png" "筒_4.png" "筒_5.png"
    "筒_6.png" "筒_7.png" "筒_8.png" "筒_9.png"
    "條_1.png" "條_2.png" "條_3.png" "條_4.png" "條_5.png"
    "條_6.png" "條_7.png" "條_8.png" "條_9.png"
    "萬_1.png" "萬_2.png" "萬_3.png" "萬_4.png" "萬_5.png"
    "萬_6.png" "萬_7.png" "萬_8.png" "萬_9.png"
    "一_1.png" "二_2.png" "三_3.png" "四_4.png" "五_5.png"
    "六_6.png" "七_7.png" "八_8.png" "九_9.png"
    "東_東.png" "南_南.png" "西_西.png" "北_北.png"
    "白_白.png" "中_中.png" "發_發.png"
)

echo ""
echo "📋 Checking tiles directory..."

missing=()
existing=()

for tile in "${expected_tiles[@]}"; do
    if [ -e "tiles/$tile" ]; then
        existing+=("$tile")
        echo "✅ $tile"
    else
        missing+=("$tile")
        echo "❌ $tile - NOT FOUND"
    fi
done

echo ""
echo "📊 Summary:"
echo "✅ Working tiles: ${#existing[@]}"
echo "❌ Missing tiles: ${#missing[@]}"

if [ ${#missing[@]} -gt 0 ]; then
    echo ""
    echo "🔧 Missing tiles that need symbolic links:"
    for tile in "${missing[@]}"; do
        echo "  $tile"
    done

    echo ""
    echo "💡 To fix, run these commands:"
    echo "cd tiles"

    # Create missing links
    for tile in "${missing[@]}"; do
        case $tile in
            "條_"*)
                num=${tile#條_}
                num=${num%.png}
                echo "ln -sf bam_${num}.png $tile"
                ;;
            "一_1.png") echo "ln -sf char_1.png $tile" ;;
            "二_2.png") echo "ln -sf char_2.png $tile" ;;
            "三_3.png") echo "ln -sf char_3.png $tile" ;;
            "四_4.png") echo "ln -sf char_4.png $tile" ;;
            "五_5.png") echo "ln -sf char_5.png $tile" ;;
            "白_白.png") echo "ln -sf dragon_white.png $tile" ;;
            "中_中.png") echo "ln -sf dragon_red.png $tile" ;;
            "發_發.png") echo "ln -sf dragon_green.png $tile" ;;
        esac
    done
fi

echo ""
echo "🎮 To see missing tiles in real-time, watch the game console for:"
echo "🔍 正在嘗試載入瓦片: tiles/FILENAME.png"
echo "❌ 找不到瓦片文件: tiles/FILENAME.png"
echo "🎨 回退到生成瓦片圖像: TILENAME"