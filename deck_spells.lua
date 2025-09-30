-- Deck-modifying spell cards

local DeckSpells = {}

DeckSpells.spells = {
    -- 你睇我唔到
    {
        id = "you_cant_see_me",
        name = "你睇我唔到",
        description = "Select up to three tiles and remove them from your deck.",
        price = 10,
        rarity = "common",
        image = "you_cant_see_me.png",
        effect = "remove_tiles",
        selection_count = 3
    },
    -- 嚦咕嚦咕
    {
        id = "one_and_nine",
        name = "嚦咕嚦咕",
        description = "Convert all tiles in your deck to a random 1 or 9 of the same suit.",
        price = 100,
        rarity = "rare",
        image = "one_and_nine.png",
        effect = "convert_to_one_and_nine",
        selection_count = 0
    },
    -- 一同歸西
    {
        id = "death",
        name = "一同歸西",
        description = "Convert all tiles in your deck to either a 1 dot or west wind.",
        price = 100,
        rarity = "rare",
        image = "death.png",
        effect = "convert_to_dot1_or_west",
        selection_count = 0
    },
    -- 人中出呂布
    {
        id = "red_middle",
        name = "人中出呂布",
        description = "Convert up to three selected tiles to Red Dragon.",
        price = 50,
        rarity = "uncommon",
        image = "red_middle.png",
        effect = "convert_to_red_dragon",
        selection_count = 3
    },
    -- 記憶麵包
    {
        id = "memo",
        name = "記憶麵包",
        description = "Create a copy of up to three selected tiles.",
        price = 10,
        rarity = "common",
        image = "memo.png",
        effect = "copy_tiles",
        selection_count = 3
    },
    -- 李氏力牆
    {
        id = "all_hail_lks",
        name = "李氏力牆",
        description = "Remove all wind tiles from your deck.",
        price = 100,
        rarity = "rare",
        image = "all_hail_lks.png",
        effect = "remove_all_winds",
        selection_count = 0
    },
    -- 轉身射個三分波
    {
        id = "three_point",
        name = "轉身射個三分波",
        description = "Make up to 3 selected tiles 3 dot.",
        price = 50,
        rarity = "uncommon",
        image = "three_point.png",
        effect = "convert_to_3_dot",
        selection_count = 3
    },
    -- 打雀英雄傳
    {
        id = "play_mj",
        name = "打雀英雄傳",
        description = "Make up to three selected tiles bamboo 1.",
        price = 50,
        rarity = "uncommon",
        image = "play_mj.png",
        effect = "convert_to_bamboo_1",
        selection_count = 3
    },
    -- 真係恭喜你呀
    {
        id = "voice_recording",
        name = "真係恭喜你呀",
        description = "Make up to 3 selected tiles Green Dragon.",
        price = 50,
        rarity = "uncommon",
        image = "voice_recording.png",
        effect = "convert_to_green_dragon",
        selection_count = 3
    },
    -- 粉筆字
    {
        id = "whiteboard_pen",
        name = "粉筆字",
        description = "Make up to 3 selected tiles White Dragon.",
        price = 50,
        rarity = "uncommon",
        image = "whiteboard_pen.png",
        effect = "convert_to_white_dragon",
        selection_count = 3
    },
    -- 頭文字D
    {
        id = "initial_d_meme",
        name = "頭文字D",
        description = "Make up to 3 selected tiles character 3.",
        price = 100,
        rarity = "rare",
        image = "initial_d_meme.png",
        effect = "convert_to_char_3",
        selection_count = 3
    },
    -- 阿婆走得快
    {
        id = "you_better_watch_out",
        name = "阿婆走得快",
        description = "Convert your entire deck to 10 copies of 8 random tiles.",
        price = 100,
        rarity = "rare",
        image = "you_better_watch_out.png",
        effect = "convert_to_8_random_tiles",
        selection_count = 0
    }
}

function DeckSpells.getSpells()
    return DeckSpells.spells
end

return DeckSpells
