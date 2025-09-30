-- Consumables Configuration
-- Pure Lua config for better performance and maintainability

return {
  consumables = {
    {
      id = "moon_box",
      name = "月光寶盒",
      nameEng = "Moon Box",
      description = "神秘寶盒\n複製最近3張棄牌或打出的牌到手牌",
      descriptionEng = "Mystical box\nCopy last 3 discarded/played tiles to hand",
      price = 30,
      rarity = "common",
      category = "special",
      effectType = "copy_recent_tiles",
      effectValue = 3,
      icon = "🌙",
      color = {0.8, 0.8, 1.0}
    },
    {
      id = "east_wind",
      name = "孔明借東風",
      nameEng = "East Wind Blessing",
      description = "借東風之力\n東風牌打出時額外獲得番數",
      descriptionEng = "Borrow east wind power\nEast wind tiles give extra faan when played",
      price = 30,
      rarity = "common",
      category = "blessing",
      effectType = "east_wind_boost",
      effectValue = 1,
      icon = "🌪️",
      color = {0.2, 0.8, 0.2}
    },
    {
      id = "contact_lens",
      name = "隱形液晶體眼鏡",
      nameEng = "Contact Lens",
      description = "西德嘅最新科技\n可以窺探牌疊中的牌",
      descriptionEng = "West German latest tech\nPeek at upcoming tiles in deck",
      price = 20,
      rarity = "common",
      category = "utility",
      effectType = "enable_deck_peek",
      effectValue = 1,
      icon = "👁️",
      color = {0.5, 0.5, 1.0}
    },
    {
      id = "honesty",
      name = "誠實豆沙包",
      nameEng = "Honesty Bun",
      description = "誠實的力量\n移除所有戰鬥限制",
      descriptionEng = "Power of honesty\nRemove all battle restrictions",
      price = 50,
      rarity = "common",
      category = "special",
      effectType = "remove_restrictions",
      effectValue = 1,
      icon = "🥟",
      color = {1.0, 0.8, 0.6}
    },
    {
      id = "to_the_moon",
      name = "冧把降",
      nameEng = "Number Only",
      description = "只能打數字牌\n但基礎番數+5",
      descriptionEng = "Can only play number tiles\nBut base faan +5",
      price = 100,
      rarity = "rare",
      category = "restriction",
      effectType = "number_only_restriction",
      effectValue = 5,
      icon = "🔢",
      color = {0.8, 0.4, 0.8}
    },
    {
      id = "rice_rice_baby",
      name = "白飯",
      nameEng = "Rice",
      description = "改變手牌中的條子5為條子4",
      descriptionEng = "Change bamboo 5 to bamboo 4 in hand",
      price = 30,
      rarity = "common",
      category = "utility",
      effectType = "change_bamboo_5_to_4",
      effectValue = 1,
      icon = "🍚",
      color = {1.0, 1.0, 0.8}
    },
    {
      id = "solar_flash_light",
      name = "太陽能電筒",
      nameEng = "Solar Flashlight",
      description = "在黑暗中發光\n但沒有其他效果",
      descriptionEng = "Shines in the dark\nBut has no other effect",
      price = 1000,
      rarity = "legendary",
      category = "troll",
      effectType = "do_nothing",
      effectValue = 1,
      icon = "🔦",
      color = {1.0, 1.0, 0.0}
    }
  },

  rarityColors = {
    common = {0.8, 0.8, 0.8},
    uncommon = {0.3, 0.8, 0.3},
    rare = {0.3, 0.3, 0.9},
    legendary = {0.9, 0.6, 0.0}
  },

  categoryIcons = {
    drink = "🥤",
    food = "🍞",
    lucky = "🍀",
    skill = "🎯",
    special = "✨",
    divine = "👑"
  }
}
