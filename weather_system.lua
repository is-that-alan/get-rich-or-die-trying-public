-- Hong Kong Typhoon Weather System
-- Provides wind tile bonuses based on real HK typhoon warning signals

local WeatherSystem = {}

-- HK Typhoon Warning Signals with corresponding favored winds
WeatherSystem.TYPHOON_SIGNALS = {
    ["待候信號"] = {
        name = "待候信號 (Standby Signal)",
        signal = "待候",
        description = "等待中...",
        favoredWinds = {}, -- No bonus
        fanBonus = 0
    },
    ["一號戒備信號"] = {
        name = "一號戒備信號 (T1)",
        signal = "T1",
        description = "遠距離熱帶氣旋",
        favoredWinds = {"東"}, -- East wind bonus
        fanBonus = 1
    },
    ["三號強風信號"] = {
        name = "三號強風信號 (T3)",
        signal = "T3",
        description = "強風吹襲",
        favoredWinds = {"南"}, -- South wind bonus
        fanBonus = 1
    },
    ["八號東北烈風信號"] = {
        name = "八號東北烈風信號 (T8NE)",
        signal = "T8NE",
        description = "東北烈風",
        favoredWinds = {"東", "北"}, -- East & North wind bonus
        fanBonus = 1
    },
    ["八號東南烈風信號"] = {
        name = "八號東南烈風信號 (T8SE)",
        signal = "T8SE",
        description = "東南烈風",
        favoredWinds = {"東", "南"}, -- East & South wind bonus
        fanBonus = 1
    },
    ["八號西南烈風信號"] = {
        name = "八號西南烈風信號 (T8SW)",
        signal = "T8SW",
        description = "西南烈風",
        favoredWinds = {"西", "南"}, -- West & South wind bonus
        fanBonus = 1
    },
    ["八號西北烈風信號"] = {
        name = "八號西北烈風信號 (T8NW)",
        signal = "T8NW",
        description = "西北烈風",
        favoredWinds = {"西", "北"}, -- West & North wind bonus
        fanBonus = 1
    },
    ["九號烈風信號"] = {
        name = "九號烈風信號 (T9)",
        signal = "T9",
        description = "烈風增強",
        favoredWinds = {"東", "南", "西", "北"}, -- All winds bonus
        fanBonus = 2
    },
    ["十號颶風信號"] = {
        name = "十號颶風信號 (T10)",
        signal = "T10",
        description = "颶風來襲！",
        favoredWinds = {"東", "南", "西", "北"}, -- All winds bonus
        fanBonus = 3
    }
}

-- Current weather state
WeatherSystem.currentWeather = nil

-- Initialize weather system
function WeatherSystem.initialize()
    WeatherSystem.generateNewWeather()
end

-- Generate new random weather
function WeatherSystem.generateNewWeather()
    local signals = {}
    for signalName, _ in pairs(WeatherSystem.TYPHOON_SIGNALS) do
        table.insert(signals, signalName)
    end

    local randomIndex = love.math.random(1, #signals)
    local selectedSignal = signals[randomIndex]
    WeatherSystem.currentWeather = WeatherSystem.TYPHOON_SIGNALS[selectedSignal]

    print("🌪️ 天氣更新: " .. WeatherSystem.currentWeather.name)
    print("   " .. WeatherSystem.currentWeather.description)
    if #WeatherSystem.currentWeather.favoredWinds > 0 then
        print("   有利風向: " .. table.concat(WeatherSystem.currentWeather.favoredWinds, ", "))
        print("   額外番數: +" .. WeatherSystem.currentWeather.fanBonus)
    else
        print("   無風向加成")
    end
end

-- Check if a wind tile gets bonus fan
function WeatherSystem.getWindBonus(windValue)
    if not WeatherSystem.currentWeather then return 0 end

    for _, favoredWind in ipairs(WeatherSystem.currentWeather.favoredWinds) do
        if windValue == favoredWind then
            return WeatherSystem.currentWeather.fanBonus
        end
    end

    return 0
end

-- Get current weather info for display
function WeatherSystem.getCurrentWeatherInfo()
    if not WeatherSystem.currentWeather then
        return {
            signal = "未知",
            name = "無天氣資料",
            description = "",
            favoredWinds = {},
            fanBonus = 0
        }
    end

    return {
        signal = WeatherSystem.currentWeather.signal,
        name = WeatherSystem.currentWeather.name,
        description = WeatherSystem.currentWeather.description,
        favoredWinds = WeatherSystem.currentWeather.favoredWinds,
        fanBonus = WeatherSystem.currentWeather.fanBonus
    }
end

-- Check if any wind pungs in hand get weather bonus
function WeatherSystem.calculateWeatherBonus(playedTiles)
    if not WeatherSystem.currentWeather or #WeatherSystem.currentWeather.favoredWinds == 0 then
        return 0, {}
    end

    local bonusTotal = 0
    local bonusDetails = {}

    -- Count wind triplets that match current weather
    local tileCounts = {}
    for _, tile in ipairs(playedTiles) do
        if tile.suit == "winds" then
            local tileId = tile.suit .. "_" .. tile.value
            tileCounts[tileId] = (tileCounts[tileId] or 0) + 1
        end
    end

    for tileId, count in pairs(tileCounts) do
        if count >= 3 then -- Triplet or more
            local windValue = tileId:gsub("winds_", "")
            local windBonus = WeatherSystem.getWindBonus(windValue)
            if windBonus > 0 then
                bonusTotal = bonusTotal + windBonus
                table.insert(bonusDetails, {
                    wind = windValue,
                    bonus = windBonus,
                    reason = "颱風信號: " .. WeatherSystem.currentWeather.signal
                })
            end
        end
    end

    return bonusTotal, bonusDetails
end

return WeatherSystem