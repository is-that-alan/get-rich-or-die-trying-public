-- AUTHENTIC HONG KONG FLAVOR SYSTEM
-- Makes the game feel genuinely Hong Kong
local HKFlavor = {}

-- Time-based greetings and atmosphere
function HKFlavor.getTimeGreeting()
    local hour = tonumber(os.date("%H"))

    if hour >= 6 and hour < 11 then
        return "早晨！去茶餐廳食早餐未？", "🌅"
    elseif hour >= 11 and hour < 14 then
        return "午安！搵錢緊要過食飯！", "🍜"
    elseif hour >= 14 and hour < 18 then
        return "下午好！依家係搵錢時間！", "💼"
    elseif hour >= 18 and hour < 22 then
        return "夜晚好！夜市開始喇！", "🌃"
    else
        return "夜深喇！仲搵緊錢？", "🌙"
    end
end

-- Hong Kong location-based schemes
HKFlavor.locations = {
    {
        name = "深水埗",
        english = "Sham Shui Po",
        scheme = "電腦配件轉賣",
        description = "係黃金商場買平嘢，轉手賣貴啲",
        vibe = "草根創業",
        difficulty = 1,
        moneyMultiplier = 1.2
    },
    {
        name = "觀塘",
        english = "Kwun Tong",
        scheme = "工業大廈劏房",
        description = "將工廈分租畀創業青年",
        vibe = "地產投機",
        difficulty = 2,
        moneyMultiplier = 1.5
    },
    {
        name = "旺角",
        english = "Mong Kok",
        scheme = "街頭小食檔",
        description = "賣魚蛋燒賣同奶茶",
        vibe = "傳統生意",
        difficulty = 1,
        moneyMultiplier = 1.3
    },
    {
        name = "中環",
        english = "Central",
        scheme = "金融投資顧問",
        description = "教人炒股票炒樓",
        vibe = "專業騙徒",
        difficulty = 4,
        moneyMultiplier = 3.0
    },
    {
        name = "銅鑼灣",
        english = "Causeway Bay",
        scheme = "代購名牌手袋",
        description = "幫內地客買LV同Chanel",
        vibe = "時尚生意",
        difficulty = 3,
        moneyMultiplier = 2.0
    },
    {
        name = "尖沙咀",
        english = "Tsim Sha Tsui",
        scheme = "遊客紀念品",
        description = "賣\"香港製造\"嘅假貨",
        vibe = "旅遊陷阱",
        difficulty = 2,
        moneyMultiplier = 1.8
    }
}

-- Authentic Hong Kong reactions and expressions
HKFlavor.reactions = {
    win = {
        "發達喇！", "搵到錢喇！", "好爽！", "抵讚！",
        "收工收工！", "今晚食好啲！", "終於翻身！"
    },
    lose = {
        "輸硬！", "死梗！", "破產喇！", "慘！"
    },
    money = {
        "有錢使！", "袋袋平安！", "錢銀滾滾來！", "發大財！",
        "數錢數到手軟！", "富貴逼人來！"
    },
    struggle = {
        "一蚊都冇！", "食風飲露！",
        "頸都扭埋！", "做到癲咗！"
    }
}

-- Hong Kong-style motivational phrases
HKFlavor.motivation = {
    "香港人就係要打不死！",
    "獅子山精神永不死！",
    "搏盡無悔，盡力而為！",
    "今日唔搏，聽日後悔！",
    "錢唔係萬能，但冇錢萬萬不能！"
}

-- Local schemes that Hong Kongers recognize
HKFlavor.schemes = {
    {
        name = "樓市投資班",
        description = "教你點樣30萬上車",
        realness = "每個港人都聽過",
        warning = "小心成為接火棒俠"
    },
    {
        name = "港股研習社",
        description = "炒股票發達班",
        realness = "Facebook廣告常見",
        warning = "股災時導師會消失"
    },
    {
        name = "網上代購",
        description = "幫人買日韓化妝品",
        realness = "IG Story成日見",
        warning = "小心收唔到錢"
    },
    {
        name = "crypto挖礦",
        description = "虛擬貨幣投資",
        realness = "2021年全民瘋狂",
        warning = "熊市時欲哭無淚"
    }
}

-- Dynamic flavor text based on player state
function HKFlavor.getPlayerStateText(money, wins, losses)
    if money >= 10000 then
        return "你已經係有錢人喇！", "😎"
    elseif money >= 1000 then
        return "開始有啲積蓄喇", "🤑"
    elseif money >= 100 then
        return "仲有啲錢用", "😊"
    elseif money >= 10 then
        return "就嚟破產喇", "😰"
    else
        return "一蚊都冇，苦過弟弟", "😭"
    end
end

-- Weather-based mood (Hong Kong specific)
function HKFlavor.getWeatherMood()
    local weather = math.random(1, 6)

    if weather == 1 then
        return "今日好熱，最啱開冷氣打邊爐", "☀️", {r=1, g=0.8, b=0.2}
    elseif weather == 2 then
        return "寒冷天氣警告現正生效警告，新界再低一兩度", "🌪️", {r=0.3, g=0.5, b=0.8}
    elseif weather == 3 then
        return "勁大風，出街小心比風吹到企唔穩", "💨", {r=0.6, g=0.6, b=0.6}
    elseif weather == 4 then
        return "八號熱帶氣旋警告信號生效", "🌀", {r=0.5, g=0.3, b=0.1}
    elseif weather == 5 then
        return "空氣污染指數爆燈，出街戴口罩啦", "😷", {r=0.7, g=0.6, b=0.5}
    else
        return "好靚天，出去搵錢啦", "🌤️", {r=0.8, g=0.9, b=1}
    end
end

-- Street food rewards (very Hong Kong)
HKFlavor.streetFood = {
}

-- Character archetypes Hong Kongers know
HKFlavor.characters = {
}

-- Get random flavor based on context
function HKFlavor.getRandomReaction(context)
    local reactions = HKFlavor.reactions[context] or HKFlavor.reactions.win
    return reactions[math.random(#reactions)]
end

function HKFlavor.getRandomMotivation()
    return HKFlavor.motivation[math.random(#HKFlavor.motivation)]
end

-- Format money Hong Kong style
function HKFlavor.formatMoney(amount)
    if amount >= 10000 then
        return string.format("$%.1f萬", amount / 10000)
    else
        return "$" .. amount
    end
end

-- Get district-specific challenge
function HKFlavor.getDistrictChallenge(locationName)
    for _, location in ipairs(HKFlavor.locations) do
        if location.name == locationName then
            return {
                title = location.scheme .. " @ " .. location.name,
                description = location.description,
                vibe = location.vibe,
                multiplier = location.moneyMultiplier,
                flavor = "係" .. location.name .. "搞" .. location.scheme .. "，" .. location.description
            }
        end
    end

    return {
        title = "街頭搵錢",
        description = "隨便搵個地方搞搞震",
        vibe = "求其",
        multiplier = 1.0,
        flavor = "求其搵個地方搞搞震"
    }
end

return HKFlavor