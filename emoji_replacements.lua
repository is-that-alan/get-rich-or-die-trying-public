-- Emoji to Chinese Text Replacement System
-- Replaces emojis with Traditional Chinese text for Hong Kong players

local EmojiReplacements = {}

-- Emoji to Traditional Chinese mapping
EmojiReplacements.REPLACEMENTS = {
    -- Gaming and UI
    ["🎮"] = "遊戲",
    ["🀄"] = "麻雀",
    ["🎉"] = "慶祝",
    ["🏆"] = "獎盃",
    ["💰"] = "銀紙",
    ["💎"] = "寶石",
    ["⭐"] = "星",
    ["🌟"] = "閃星",
    ["🔥"] = "火",
    ["🚀"] = "火箭",
    ["✅"] = "正確",
    ["❌"] = "錯誤",
    ["🎯"] = "目標",
    ["🔄"] = "重新載入",
    ["📱"] = "手機",
    ["💻"] = "電腦",
    ["🖱️"] = "滑鼠",

    -- Hong Kong specific
    ["🏙️"] = "城市",
    ["🍽️"] = "餐廳",
    ["🛍️"] = "購物",
    ["🎲"] = "骰仔",
    ["🌤️"] = "好天氣",
    ["☀️"] = "太陽",
    ["🌧️"] = "落雨",
    ["🌪️"] = "颱風",
    ["❤️"] = "愛心",

    -- Actions and states
    ["🔮"] = "占卜",
    ["🎪"] = "表演",
    ["🎭"] = "戲劇",
    ["🎨"] = "藝術",
    ["🎬"] = "電影",
    ["🎵"] = "音樂",
    ["🎶"] = "歌曲",
    ["🎸"] = "結他",
    ["🎺"] = "小號",
    ["🎻"] = "小提琴",
    ["🥁"] = "鼓",

    -- Map and locations
    ["🗺️"] = "地圖",
    ["🏗️"] = "建築",
    ["🚩"] = "旗",
    ["🏴"] = "黑旗",
    ["🏳️"] = "白旗",
    ["🛡️"] = "盾牌",

    -- Combat and effects
    ["💪"] = "強壯",
    ["🌈"] = "彩虹",
    ["🎄"] = "聖誕樹",
    ["🎊"] = "彩帶",
    ["🎈"] = "氣球",

    -- Development and system
    ["🛠️"] = "工具",
    ["⚠️"] = "警告",
    ["💾"] = "儲存",
    ["💿"] = "光碟",
    ["💽"] = "磁碟",
    ["🖥️"] = "螢幕",
    ["⌨️"] = "鍵盤",
    ["🖨️"] = "打印機",
    ["📷"] = "相機",
    ["📹"] = "攝錄機",
    ["📺"] = "電視",
    ["📻"] = "收音機",
    ["☎️"] = "電話",
    ["📞"] = "聽筒",
    ["⌚"] = "手錶",
    ["💡"] = "燈膽",
    ["🔌"] = "插頭",

    -- Mahjong specific (keeping traditional characters)
    ["🀄"] = "中",  -- Red dragon simplified
    ["🃏"] = "牌",
    ["🧩"] = "拼圖",
    ["🎰"] = "老虎機",
}

-- Function to replace emojis in text with Chinese equivalents
function EmojiReplacements.replaceEmojis(text)
    if not text or type(text) ~= "string" then
        return text
    end

    local result = text

    -- Replace each emoji with Chinese text
    for emoji, chinese in pairs(EmojiReplacements.REPLACEMENTS) do
        result = result:gsub(emoji, chinese)
    end

    return result
end

-- Function to replace emojis in printf calls
function EmojiReplacements.printf(text, x, y, width, align)
    local cleanText = EmojiReplacements.replaceEmojis(text)
    love.graphics.printf(cleanText, x, y, width, align or "left")
end

-- Function to replace emojis in print calls
function EmojiReplacements.print(text, x, y)
    local cleanText = EmojiReplacements.replaceEmojis(text)
    if x and y then
        love.graphics.print(cleanText, x, y)
    else
        print(cleanText)
    end
end

return EmojiReplacements