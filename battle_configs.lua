-- Battle Configuration Data
-- Returns table with all battle configurations

return {
  battle_types = {
    tutorial = {
      name = "新手教學",
      description = "簡單的入門戰鬥",
      difficulty = "tutorial",
      config = {
        targetFan = 1,
        maxHands = 25,
        maxHandSize = 14,
        targetPlayedTiles = 14,
        deckMultiplier = 1.0,
        startingTileBonus = 2,
        allowUndo = true,
        weatherEffects = false
      },
      rewards = {
        money = 50,
        xp = 25
      },
      penalties = {
        money = 10
      }
    },

    easy = {
      name = "初級戰鬥",
      description = "適合新手的輕鬆戰鬥",
      difficulty = "easy",
      config = {
        targetFan = 2,
        maxHands = 22,
        maxHandSize = 14,
        targetPlayedTiles = 14,
        deckMultiplier = 1.0,
        startingTileBonus = 1,
        allowUndo = true,
        weatherEffects = true
      },
      rewards = {
        money = 75,
        xp = 35
      },
      penalties = {
        money = 15
      }
    },

    normal = {
      name = "標準戰鬥",
      description = "標準難度的麻將戰鬥",
      difficulty = "normal",
      config = {
        targetFan = 3,
        maxHands = 20,
        maxHandSize = 14,
        targetPlayedTiles = 14,
        deckMultiplier = 1.0,
        startingTileBonus = 0,
        allowUndo = false,
        weatherEffects = true
      },
      rewards = {
        money = 100,
        xp = 50
      },
      penalties = {
        money = 25
      }
    },

    hard = {
      name = "困難戰鬥",
      description = "挑戰性的高難度戰鬥",
      difficulty = "hard",
      config = {
        targetFan = 4,
        maxHands = 18,
        maxHandSize = 13,
        targetPlayedTiles = 14,
        deckMultiplier = 0.8,
        startingTileBonus = 0,
        allowUndo = false,
        weatherEffects = true,
        honorTilesOnly = false
      },
      rewards = {
        money = 150,
        xp = 75
      },
      penalties = {
        money = 40
      }
    },

    expert = {
      name = "專家戰鬥",
      description = "極具挑戰性的專家級戰鬥",
      difficulty = "expert",
      config = {
        targetFan = 5,
        maxHands = 16,
        maxHandSize = 12,
        targetPlayedTiles = 14,
        deckMultiplier = 0.7,
        startingTileBonus = -1,
        allowUndo = false,
        weatherEffects = true,
        limitedSuits = {"characters", "circles"}
      },
      rewards = {
        money = 200,
        xp = 100
      },
      penalties = {
        money = 50
      }
    },

    boss_easy = {
      name = "小Boss戰",
      description = "區域小Boss戰鬥",
      difficulty = "boss_easy",
      config = {
        targetFan = 6,
        maxHands = 5,
        maxHandSize = 14,
        targetPlayedTiles = 14,
        deckMultiplier = 1.2,
        startingTileBonus = 1,
        allowUndo = false,
        weatherEffects = true,
        specialRules = {"double_honors", "weather_boost"}
      },
      rewards = {
        money = 300,
        xp = 150,
        specialItems = {"rare_relic"}
      },
      penalties = {
        money = 75
      }
    },

    boss_hard = {
      name = "大Boss戰",
      description = "終極Boss戰鬥",
      difficulty = "boss_hard",
      config = {
        targetFan = 8,
        maxHands = 4,
        maxHandSize = 14,
        targetPlayedTiles = 14,
        deckMultiplier = 0.6,
        startingTileBonus = 0,
        allowUndo = false,
        weatherEffects = true,
        honorTilesOnly = true,
        specialRules = {"terminal_honors_only", "minimum_pattern_restrictions"}
      },
      rewards = {
        money = 500,
        xp = 250,
        specialItems = {"legendary_relic", "rare_consumable"}
      },
      penalties = {
        money = 100
      }
    },

    challenge_speed = {
      name = "速戰速決",
      description = "時間限制的快速戰鬥",
      difficulty = "challenge",
      config = {
        targetFan = 3,
        maxHands = 3,
        maxHandSize = 14,
        targetPlayedTiles = 14,
        deckMultiplier = 1.5,
        startingTileBonus = 2,
        allowUndo = false,
        weatherEffects = false,
        specialRules = {"speed_bonus"}
      },
      rewards = {
        money = 125,
        xp = 60,
        specialItems = {"time_bonus"}
      },
      penalties = {
        money = 20
      }
    },

    challenge_limited = {
      name = "限制挑戰",
      description = "只能使用特定花色的限制戰鬥",
      difficulty = "challenge",
      config = {
        targetFan = 4,
        maxHands = 18,
        maxHandSize = 14,
        targetPlayedTiles = 14,
        deckMultiplier = 0.5,
        startingTileBonus = 0,
        allowUndo = false,
        weatherEffects = true,
        limitedSuits = {"bamboos"},
        specialRules = {"single_suit_only"}
      },
      rewards = {
        money = 175,
        xp = 85,
        specialItems = {"suit_mastery"}
      },
      penalties = {
        money = 35
      }
    }
  },

  special_rules = {
    double_honors = {
      description = "字牌番數加倍",
      effect = "honor_tiles_double_fan"
    },
    weather_boost = {
      description = "天氣效果增強",
      effect = "weather_effects_amplified"
    },
    terminal_honors_only = {
      description = "只能使用么九牌",
      effect = "restrict_to_terminals_and_honors"
    },
    speed_bonus = {
      description = "快速完成有額外獎勵",
      effect = "time_based_bonus"
    },
    single_suit_only = {
      description = "只能使用單一花色",
      effect = "restrict_suits"
    },
    minimum_pattern_restrictions = {
      description = "需要特定組合才能獲勝",
      effect = "require_specific_patterns"
    }
  },

  difficulty_progression = {
    level_1 = {"tutorial", "easy"},
    level_2 = {"easy", "normal"},
    level_3 = {"normal", "hard"},
    level_4 = {"hard", "expert", "boss_easy"},
    level_5 = {"expert", "boss_hard", "challenge_speed", "challenge_limited"}
  }
}