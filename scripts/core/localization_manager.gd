extends Node

## Central localization manager for Zen Mahjong.
## Provides localized strings, language selection, persistence, and signal dispatch.

signal language_changed(new_language: String)

const SUPPORTED_LANGUAGES: Array[Dictionary] = [
	{"code": "en", "name": "English", "native": "English"},
	{"code": "zh", "name": "Simplified Chinese", "native": "简体中文"},
	{"code": "ja", "name": "Japanese", "native": "日本語"},
	{"code": "es", "name": "Spanish", "native": "Español"},
	{"code": "fr", "name": "French", "native": "Français"},
	{"code": "de", "name": "German", "native": "Deutsch"},
	{"code": "hi", "name": "Hindi", "native": "हिन्दी"}
]

var current_language: String = "en"

const STRINGS: Dictionary = {
	"en": {
		# Main Menu
		"APP_TITLE": "ZEN MAHJONG",
		"APP_SUBTITLE": "A TRANQUIL SOLITAIRE EXPERIENCE",
		"BTN_PLAY": "▶  Play",
		"BTN_CONTINUE": "▶  Continue (Level %d)",
		"BTN_LEVEL_SELECT": "🏯  Level Selection",
		"BTN_DAILY": "📅  Daily Challenge",
		"BTN_TUTORIAL": "📖  How to Play",
		"BTN_SETTINGS": "⚙  Settings & Audio",
		"DAILY_STREAK": "🌿 Tranquil Garden • Daily Streak: %d Days",
		"DAILY_STREAK_ZERO": "🌿 Tranquil Garden",
		"VERSION": "Zen Mahjong v1.0.0",

		# Settings
		"SETTINGS_TITLE": "Settings & Accessibility",
		"LANGUAGE_LABEL": "Language",
		"MUSIC_VOLUME": "Music Volume",
		"SFX_VOLUME": "Sound Effects Volume",
		"DIM_BLOCKED": "Dim blocked tiles (visual assistance)",
		"HAPTIC_FEEDBACK": "Enable haptic feedback on touch",
		"REDUCED_MOTION": "Reduced motion (softer transitions)",
		"BTN_BACK_MENU": "◀ Return to Main Menu",

		# Level Selection
		"LEVEL_SELECT_TITLE": "Select Garden Level",
		"LEVEL_LABEL": "Level %d",

		# Gameplay HUD
		"HUD_PAUSE": "⏸ Menu",
		"HUD_PAIRS_LEFT": "%d Pairs Left",
		"HUD_MOVES": "Moves: %d",
		"HUD_UNDO": "↶ Undo",
		"HUD_HINT": "💡 Hint",
		"HUD_SHUFFLE": "🔀 Shuffle",
		"HUD_RESTART": "🔄 Restart",

		# Modals
		"PAUSE_TITLE": "Game Paused",
		"BTN_RESUME": "▶ Resume",
		"BTN_RESTART_LEVEL": "🔄 Restart Level",
		"BTN_HOW_TO_PLAY": "📖 Tile Guide & Rules",
		"BTN_RETURN_MENU": "🏠 Return to Menu",

		"VICTORY_TITLE": "🌸 Garden Cleared! 🌸",
		"VICTORY_TIME": "Time",
		"VICTORY_MOVES": "Moves",
		"BTN_NEXT_LEVEL": "Next Level ▶",

		"NO_MOVES_TITLE": "No Moves Remaining",
		"NO_MOVES_DESC": "No open matching pairs remain on the board. Undo your recent moves or restart the level to find the winning path!",
		"BTN_SHUFFLE_BOARD": "🔀 Shuffle Board",
		"BTN_UNDO_MOVE": "↶ Undo Move",
		"BTN_CLOSE": "Close",

		# How to Play & Tile Guide
		"GUIDE_TITLE": "How to Play & Tile Guide",
		"TAB_RULES": "📜 Game Rules",
		"TAB_CHARACTERS": "一 Characters (Wan)",
		"TAB_BAMBOO": "竹 Bamboo (Tiao)",
		"TAB_DOTS": "● Dots (Tong)",
		"TAB_WINDS": "🀀 Winds (Feng)",
		"TAB_DRAGONS": "🀄 Dragons (Jian)",
		"TAB_FLOWERS_SEASONS": "🌸 Flowers & Seasons",

		# Rules Descriptions
		"RULES_FREE_TITLE": "1. Free Tiles (Selectable)",
		"RULES_FREE_DESC": "A tile is FREE and can be matched only when:\n• No tile is resting directly ON TOP of it, AND\n• At least its LEFT or RIGHT side is completely unobstructed.\nTiles that are trapped on both sides or covered cannot be picked up.",

		"RULES_MATCH_TITLE": "2. Matching Rules",
		"RULES_MATCH_DESC": "Tap two free matching tiles to remove them from the board:\n• [color=#75c080]Regular Suits & Honors[/color] (Characters, Bamboo, Dots, Winds, Dragons) must match an [b]EXACT IDENTICAL[/b] tile.\n• [color=#e8b070]Flowers[/color] (Plum, Orchid, Bamboo, Chrysanthemum) match with [b]ANY Flower[/b]!\n• [color=#e8b070]Seasons[/color] (Spring, Summer, Autumn, Winter) match with [b]ANY Season[/b]!",
		"RULES_SUITS_HEADER": "🎯 Regular Suits & Honors (Must match EXACT SAME tile):",
		"RULES_SUITS_EXAMPLE": "Example: [ 8 of Characters ] = [ 8 of Characters ]  ✓ Exact Identical Match",
		"RULES_FLOWERS_HEADER": "🌸 Flowers (Any Flower matches ANY other Flower!):",
		"RULES_FLOWERS_EXAMPLE": "Example: [ Plum Blossom (梅) ] = [ Orchid (蘭) ]  ✓ Any 2 Flowers Match!",
		"RULES_SEASONS_HEADER": "🍂 Seasons (Any Season matches ANY other Season!):",
		"RULES_SEASONS_EXAMPLE": "Example: [ Spring (春) ] = [ Summer (夏) ]  ✓ Any 2 Seasons Match!",

		"RULES_TOOLS_TITLE": "3. Assistance Tools",
		"RULES_TOOLS_DESC": "• [b]Undo[/b]: Reverses your most recent tile match.\n• [b]Hint[/b]: Highlights an active free matching pair in emerald.\n• [b]Restart[/b]: Restarts the board from the beginning so you can try a different solution path.",

		"RULES_GOAL_TITLE": "4. Objective",
		"RULES_GOAL_DESC": "Clear all 144 tiles from the garden board to achieve victory and earn up to 3 stars!",

		# Suit Explanations
		"SUIT_CHARACTERS_DESC": "[b]Characters Suit (萬 / Wàn):[/b]\nTraditional Chinese numerals from 1 to 9 with the red character '萬' (Wan = ten thousand). Match identical characters.",
		"SUIT_BAMBOO_DESC": "[b]Bamboo Suit (竹 / Tiáo):[/b]\nBamboo stalks from 1 to 9. [color=#e8b070][b]Notice:[/b] 1 Bamboo is uniquely depicted as the Sacred Sparrow / Bird (鳥)![/color] Match identical bamboo tiles.",
		"SUIT_DOTS_DESC": "[b]Dots Suit (筒 / Tǒng):[/b]\nConcentric circular copper coins / discs from 1 to 9 with ruby accents. Match identical dot tiles.",
		"HONOR_WINDS_DESC": "[b]Wind Honors (風牌 / Fēng):[/b]\nRepresenting the 4 cardinal compass directions: East (東), South (南), West (西), North (北). Wind tiles only match their [b]EXACT SAME[/b] direction!",
		"HONOR_DRAGONS_DESC": "[b]Dragon Honors (三元牌 / Sānyuán):[/b]\nRepresenting the 3 cardinal virtues: Red Dragon (中 / Center), Green Dragon (發 / Prosperity), White Dragon (白 / Purity). Dragon tiles only match their [b]EXACT SAME[/b] dragon!",
		"SPECIAL_FLOWERS_SEASONS_DESC": "[b]Flowers & Seasons (Special Wildcard Match):[/b]\nUnlike regular tiles, these tiles do [b]NOT[/b] need an identical twin!\n• [color=#e8b070]Any Flower matches ANY other Flower[/color] (Plum, Orchid, Bamboo, Chrysanthemum).\n• [color=#75c080]Any Season matches ANY other Season[/color] (Spring, Summer, Autumn, Winter).",

		# Tile Names
		"TILE_1C": "1 of Characters", "TILE_2C": "2 of Characters", "TILE_3C": "3 of Characters",
		"TILE_4C": "4 of Characters", "TILE_5C": "5 of Characters", "TILE_6C": "6 of Characters",
		"TILE_7C": "7 of Characters", "TILE_8C": "8 of Characters", "TILE_9C": "9 of Characters",

		"TILE_1B": "1 of Bamboo (Sparrow)", "TILE_2B": "2 of Bamboo", "TILE_3B": "3 of Bamboo",
		"TILE_4B": "4 of Bamboo", "TILE_5B": "5 of Bamboo", "TILE_6B": "6 of Bamboo",
		"TILE_7B": "7 of Bamboo", "TILE_8B": "8 of Bamboo", "TILE_9B": "9 of Bamboo",

		"TILE_1D": "1 of Dots", "TILE_2D": "2 of Dots", "TILE_3D": "3 of Dots",
		"TILE_4D": "4 of Dots", "TILE_5D": "5 of Dots", "TILE_6D": "6 of Dots",
		"TILE_7D": "7 of Dots", "TILE_8D": "8 of Dots", "TILE_9D": "9 of Dots",

		"TILE_EAST": "East Wind (東)", "TILE_SOUTH": "South Wind (南)",
		"TILE_WEST": "West Wind (西)", "TILE_NORTH": "North Wind (北)",

		"TILE_RED": "Red Dragon (中)", "TILE_GREEN": "Green Dragon (發)", "TILE_WHITE": "White Dragon (白)",

		"TILE_PLUM": "Plum Blossom (梅)", "TILE_ORCHID": "Orchid (蘭)",
		"TILE_BAMBOO_FLOWER": "Bamboo Blossom (竹)", "TILE_CHRYSANTHEMUM": "Chrysanthemum (菊)",

		"TILE_AUTUMN": "Autumn (秋)", "TILE_WINTER": "Winter (冬)",

		# Profile & Streak & Percentile
		"PROFILE_TITLE": "Player Profile",
		"PROFILE_AVATAR": "Avatar",
		"PROFILE_FRAME": "Frame",
		"PROFILE_NAME_LABEL": "Player Name",
		"BTN_SAVE_PROFILE": "Save Profile",
		"STREAK_TITLE": "Day Streak",
		"STREAK_SUBTITLE": "Tranquil focus, great job!",
		"STREAK_CLAIM_BTN": "Claim Reward",
		"STREAK_CLAIMED_BTN": "Claimed Today ✓",
		"STREAK_CHEST_REWARD": "Day 7 Grand Reward: +5 Hints & Golden Chest!",
		"STREAK_DAILY_REWARD": "Daily Reward: +2 Bonus Hints!",
		"VIC_TOPPED_PLAYERS": "You topped %s of players!",
		"VIC_CHEST_UNLOCK": "Milestone Chest: Level %d (%d/%d)",
		"VIC_CHEST_READY": "Milestone Chest Unlocked! +3 Hints",
		"SETTINGS_EDIT_PROFILE": "Edit Profile",
		"SETTINGS_AUDIO_HAPTICS": "Audio & Haptics"
	},

	"zh": {
		# Main Menu
		"APP_TITLE": "禅宗麻将",
		"APP_SUBTITLE": "静心怡神的古典麻将消消乐",
		"BTN_PLAY": "▶  开始游戏",
		"BTN_CONTINUE": "▶  继续游戏 (第 %d 关)",
		"BTN_LEVEL_SELECT": "🏯  关卡选择",
		"BTN_DAILY": "📅  每日挑战",
		"BTN_TUTORIAL": "📖  玩法与牌型",
		"BTN_SETTINGS": "⚙  设置与音效",
		"DAILY_STREAK": "🌿 幽雅禅园 • 连续打卡: %d 天",
		"DAILY_STREAK_ZERO": "🌿 幽雅禅园",
		"VERSION": "Zen Mahjong v1.0.0",

		# Settings
		"SETTINGS_TITLE": "设置与辅助功能",
		"LANGUAGE_LABEL": "语言 (Language)",
		"MUSIC_VOLUME": "背景音乐音量",
		"SFX_VOLUME": "按键与碰撞音效",
		"DIM_BLOCKED": "暗化被阻挡的牌 (视觉辅助)",
		"HAPTIC_FEEDBACK": "开启轻触振动反馈",
		"REDUCED_MOTION": "减少动画过渡 (柔和模式)",
		"BTN_BACK_MENU": "◀ 返回主菜单",

		# Level Selection
		"LEVEL_SELECT_TITLE": "选择禅意庭院关卡",
		"LEVEL_LABEL": "第 %d 关",

		# Gameplay HUD
		"HUD_PAUSE": "⏸ 菜单",
		"HUD_PAIRS_LEFT": "剩余 %d 对",
		"HUD_MOVES": "步数: %d",
		"HUD_UNDO": "↶ 撤销",
		"HUD_HINT": "💡 提示",
		"HUD_SHUFFLE": "🔀 洗牌",
		"HUD_RESTART": "🔄 重开",

		# Modals
		"PAUSE_TITLE": "游戏已暂停",
		"BTN_RESUME": "▶ 继续游戏",
		"BTN_RESTART_LEVEL": "🔄 重新开始本关",
		"BTN_HOW_TO_PLAY": "📖 牌型指南与规则",
		"BTN_RETURN_MENU": "🏠 返回主菜单",

		"VICTORY_TITLE": "🌸 庭院圆满清除! 🌸",
		"VICTORY_TIME": "用时",
		"VICTORY_MOVES": "步数",
		"BTN_NEXT_LEVEL": "下一关卡 ▶",

		"NO_MOVES_TITLE": "暂无可消配对",
		"NO_MOVES_DESC": "当前牌面上无可用配对。您可以撤销最近的移动，或重新开始本关以尝试胜利路径！",
		"BTN_SHUFFLE_BOARD": "🔀 重新洗牌",
		"BTN_UNDO_MOVE": "↶ 撤回上步",
		"BTN_CLOSE": "关闭",

		# How to Play & Tile Guide
		"GUIDE_TITLE": "游戏玩法与牌型图解",
		"TAB_RULES": "📜 基本规则",
		"TAB_CHARACTERS": "一 万字牌 (萬)",
		"TAB_BAMBOO": "竹 条子牌 (竹/鳥)",
		"TAB_DOTS": "● 筒子牌 (筒)",
		"TAB_WINDS": "🀀 四风牌 (風)",
		"TAB_DRAGONS": "🀄 三元牌 (箭)",
		"TAB_FLOWERS_SEASONS": "🌸 花牌与四季牌",

		# Rules Descriptions
		"RULES_FREE_TITLE": "1. 自由牌 (可被点击拾取)",
		"RULES_FREE_DESC": "麻将牌只有在满足以下两项条件时才是【自由】的：\n• 其上方没有任何牌压着，并且\n• 牌的【左侧】或【右侧】至少有一边完全开阔无遮挡。\n两侧都被阻挡或被压住的牌不可被选中。",

		"RULES_MATCH_TITLE": "2. 配对消除规则",
		"RULES_MATCH_DESC": "点击两张相同的自由牌即可将它们从盘面移除：\n• [color=#75c080]普通数牌与字牌[/color] (万、条、筒、风、箭) 必须完全【相同】才能配对。\n• [color=#e8b070]花牌[/color] (梅、兰、竹、菊) 拥有特殊规则：【任意花牌与任意花牌】均可配对！\n• [color=#e8b070]四季牌[/color] (春、夏、秋、冬) 拥有特殊规则：【任意四季牌与任意四季牌】均可配对！",
		"RULES_SUITS_HEADER": "🎯 普通数牌与字牌（必须完全相同方可配对消除）：",
		"RULES_SUITS_EXAMPLE": "配对范例：[ 八萬 ] = [ 八萬 ]  ✓ 必须完全相同方可消除",
		"RULES_FLOWERS_HEADER": "🌸 花牌（任意两张花牌均可直接配对消除！）：",
		"RULES_FLOWERS_EXAMPLE": "配对范例：[ 梅花 (梅) ] = [ 兰花 (蘭) ]  ✓ 任意花牌互为配对！",
		"RULES_SEASONS_HEADER": "🍂 四季牌（任意两张四季牌均可直接配对消除！）：",
		"RULES_SEASONS_EXAMPLE": "配对范例：[ 春季 (春) ] = [ 夏季 (夏) ]  ✓ 任意四季牌互为配对！",

		"RULES_TOOLS_TITLE": "3. 禅意辅助道具",
		"RULES_TOOLS_DESC": "• [b]撤销[/b]: 倒退一步，恢复刚刚消除的配对。\n• [b]提示[/b]: 以翠玉翡翠光效高亮一组可消除的有效牌。\n• [b]重新开始[/b]: 从头重新开始本关，以便尝试不同的解题路径。",

		"RULES_GOAL_TITLE": "4. 游戏目标",
		"RULES_GOAL_DESC": "清除庭院棋盘上所有的 144 张麻将牌即可赢得胜利，并解锁三星荣耀！",

		# Suit Explanations
		"SUIT_CHARACTERS_DESC": "[b]万字牌 (萬 / Wàn):[/b]\n从一到九的中文数字，下方带有红色的“萬”字。只能与完全相同的数字牌配对 (例如五万只能与五万配对)。",
		"SUIT_BAMBOO_DESC": "[b]条子牌 (竹 / Tiáo):[/b]\n象征青翠竹节，编号 1 至 9。[color=#e8b070][b]特别提醒：[/b]1条 (幺鸡) 传统上绘为神鸟/麻雀 (鳥)！[/color] 只能与相同的条子牌配对。",
		"SUIT_DOTS_DESC": "[b]筒子牌 (筒 / Tǒng):[/b]\n象征古钱铜币与圆月，编号 1 至 9。只能与完全相同的筒子牌配对。",
		"HONOR_WINDS_DESC": "[b]四风牌 (風牌):[/b]\n代表东南西北四个方位：东 (東)、南 (南)、西 (西)、北 (北)。风牌只能与【完全相同方位】的风牌配对！",
		"HONOR_DRAGONS_DESC": "[b]三元牌 (箭牌):[/b]\n代表传统三元：红中 (中)、发财 (發)、白板 (白)。三元牌只能与【完全相同的龙牌】配对！",
		"SPECIAL_FLOWERS_SEASONS_DESC": "[b]花牌与四季牌 (特殊百搭消除):[/b]\n与普通牌不同，这类牌[b]不需要相同[/b]即可消除！\n• [color=#e8b070]任意花牌均可相互配对消除[/color] (梅、兰、竹、菊)。\n• [color=#75c080]任意四季牌均可相互配对消除[/color] (春、夏、秋、冬)。",

		# Tile Names
		"TILE_1C": "一万", "TILE_2C": "二万", "TILE_3C": "三万",
		"TILE_4C": "四万", "TILE_5C": "五万", "TILE_6C": "六万",
		"TILE_7C": "七万", "TILE_8C": "八万", "TILE_9C": "九万",

		"TILE_1B": "一条 (幺鸡/雀)", "TILE_2B": "二条", "TILE_3B": "三条",
		"TILE_4B": "四条", "TILE_5B": "五条", "TILE_6B": "六条",
		"TILE_7B": "七条", "TILE_8B": "八条", "TILE_9B": "九条",

		"TILE_1D": "一筒", "TILE_2D": "二筒", "TILE_3D": "三筒",
		"TILE_4D": "四筒", "TILE_5D": "五筒", "TILE_6D": "六筒",
		"TILE_7D": "七筒", "TILE_8D": "八筒", "TILE_9D": "九筒",

		"TILE_EAST": "东风 (東)", "TILE_SOUTH": "南风 (南)",
		"TILE_WEST": "西风 (西)", "TILE_NORTH": "北风 (北)",

		"TILE_RED": "红中 (中)", "TILE_GREEN": "发财 (發)", "TILE_WHITE": "白板 (白)",

		"TILE_PLUM": "梅花 (梅)", "TILE_ORCHID": "兰花 (蘭)",
		"TILE_BAMBOO_FLOWER": "竹子 (竹)", "TILE_CHRYSANTHEMUM": "菊花 (菊)",

		"TILE_AUTUMN": "秋季 (秋)", "TILE_WINTER": "冬季 (冬)",

		# Profile & Streak & Percentile
		"PROFILE_TITLE": "玩家档案",
		"PROFILE_AVATAR": "头像",
		"PROFILE_FRAME": "相框",
		"PROFILE_NAME_LABEL": "玩家昵称",
		"BTN_SAVE_PROFILE": "保存档案",
		"STREAK_TITLE": "每日连胜",
		"STREAK_SUBTITLE": "心如止水，精彩发挥！",
		"STREAK_CLAIM_BTN": "领取奖励",
		"STREAK_CLAIMED_BTN": "今日已领 ✓",
		"STREAK_CHEST_REWARD": "第7天终极大奖：+5 提示与黄金宝箱！",
		"STREAK_DAILY_REWARD": "每日奖励：+2 提示！",
		"VIC_TOPPED_PLAYERS": "你的表现超越了 %s 的玩家！",
		"VIC_CHEST_UNLOCK": "里程碑宝箱：第 %d 关 (%d/%d)",
		"VIC_CHEST_READY": "里程碑宝箱已解锁！+3 提示",
		"SETTINGS_EDIT_PROFILE": "编辑档案",
		"SETTINGS_AUDIO_HAPTICS": "音频与触觉反馈"
	},

	"ja": {
		# Main Menu
		"APP_TITLE": "禅麻雀",
		"APP_SUBTITLE": "静寂と癒やしの麻雀ソリティア",
		"BTN_PLAY": "▶  プレイ",
		"BTN_CONTINUE": "▶  続きから (レベル %d)",
		"BTN_LEVEL_SELECT": "🏯  レベル選択",
		"BTN_DAILY": "📅  デイリー挑戦",
		"BTN_TUTORIAL": "📖  遊び方と牌図鑑",
		"BTN_SETTINGS": "⚙  設定とサウンド",
		"DAILY_STREAK": "🌿 禅の庭園 • 連続記録: %d 日",
		"DAILY_STREAK_ZERO": "🌿 禅の庭園",
		"VERSION": "Zen Mahjong v1.0.0",

		# Settings
		"SETTINGS_TITLE": "設定とアクセシビリティ",
		"LANGUAGE_LABEL": "言語 (Language)",
		"MUSIC_VOLUME": "BGM 音量",
		"SFX_VOLUME": "効果音 音量",
		"DIM_BLOCKED": "ブロックされた牌を暗く表示",
		"HAPTIC_FEEDBACK": "タップ時の振動フィードバック",
		"REDUCED_MOTION": "アニメーション軽減 (ソフトモード)",
		"BTN_BACK_MENU": "◀ メインメニューに戻る",

		# Level Selection
		"LEVEL_SELECT_TITLE": "庭園レベル選択",
		"LEVEL_LABEL": "レベル %d",

		# Gameplay HUD
		"HUD_PAUSE": "⏸ メニュー",
		"HUD_PAIRS_LEFT": "残り %d 組",
		"HUD_MOVES": "手数: %d",
		"HUD_UNDO": "↶ 元に戻す",
		"HUD_HINT": "💡 ヒント",
		"HUD_SHUFFLE": "🔀 シャッフル",
		"HUD_RESTART": "🔄 やり直し",

		# Modals
		"PAUSE_TITLE": "一時停止",
		"BTN_RESUME": "▶ 再開する",
		"BTN_RESTART_LEVEL": "🔄 レベルをやり直す",
		"BTN_HOW_TO_PLAY": "📖 牌の図鑑とルール",
		"BTN_RETURN_MENU": "🏠 メニューに戻る",

		"VICTORY_TITLE": "🌸 見事に盤面をクリア! 🌸",
		"VICTORY_TIME": "クリア時間",
		"VICTORY_MOVES": "手数",
		"BTN_NEXT_LEVEL": "次のレベルへ ▶",

		"NO_MOVES_TITLE": "取れる手がありません",
		"NO_MOVES_DESC": "現在ペアにできる自由な牌がありません。直前の手を戻すか、レベルをやり直してクリアを目指しましょう！",
		"BTN_SHUFFLE_BOARD": "🔀 シャッフルする",
		"BTN_UNDO_MOVE": "↶ 手を戻す",
		"BTN_CLOSE": "閉じる",

		# How to Play & Tile Guide
		"GUIDE_TITLE": "遊び方と牌の図鑑",
		"TAB_RULES": "📜 基本ルール",
		"TAB_CHARACTERS": "一 萬子 (マンズ)",
		"TAB_BAMBOO": "竹 索子 (ソーズ)",
		"TAB_DOTS": "● 筒子 (ピンズ)",
		"TAB_WINDS": "🀀 風牌 (かぜはい)",
		"TAB_DRAGONS": "🀄 三元牌 (さんげん)",
		"TAB_FLOWERS_SEASONS": "🌸 花牌・季節牌",

		# Rules Descriptions
		"RULES_FREE_TITLE": "1. 自由に取れる牌 (オープンな牌)",
		"RULES_FREE_DESC": "牌は次の2つの条件を満たすときだけタップして選択できます：\n• その牌の【真上】に他の牌が乗っていないこと、かつ\n• 【左側】または【右側】のどちらかが完全に空いていること。\n両側を挟まれている牌や重なっている牌は取れません。",

		"RULES_MATCH_TITLE": "2. ペア消去ルール",
		"RULES_MATCH_DESC": "自由に取れる同じ牌を2枚タップして取り除きます：\n• [color=#75c080]通常の数牌・字牌[/color] (萬子、索子、筒子、風牌、三元牌) は【全く同じ牌】同士のみ消せます。\n• [color=#e8b070]花牌[/color] (梅、蘭、竹、菊) は特別ルール：【どの花牌同士でもペア】になります！\n• [color=#e8b070]季節牌[/color] (春、夏、秋、冬) は特別ルール：【どの季節牌同士でもペア】になります！",
		"RULES_SUITS_HEADER": "🎯 数牌と字牌（全く同じ牌同士のみマッチ）：",
		"RULES_SUITS_EXAMPLE": "一致の例：[ 八萬 ] = [ 八萬 ]  ✓ 全く同じ牌でマッチ！",
		"RULES_FLOWERS_HEADER": "🌸 花牌（どの花牌同士でも自由にマッチ！）：",
		"RULES_FLOWERS_EXAMPLE": "一致の例：[ 梅 ] = [ 蘭 ]  ✓ 異なる花牌同士でもペア成立！",
		"RULES_SEASONS_HEADER": "🍂 季節牌（どの季節牌同士でも自由にマッチ！）：",
		"RULES_SEASONS_EXAMPLE": "一致の例：[ 春 ] = [ 夏 ]  ✓ 異なる季節牌同士でもペア成立！",

		"RULES_TOOLS_TITLE": "3. サポート機能",
		"RULES_TOOLS_DESC": "• [b]元に戻す[/b]: 直前の消去を取り消して戻します。\n• [b]ヒント[/b]: 現在取れるペアをエメラルド色で光らせます。\n• [b]やり直し[/b]: 最初から配置をやり直して別の解き方を試せます。",

		"RULES_GOAL_TITLE": "4. 勝利の条件",
		"RULES_GOAL_DESC": "盤面上のすべての牌 (144枚) を消去すれば見事クリアとなり、星が贈られます！",

		# Suit Explanations
		"SUIT_CHARACTERS_DESC": "[b]萬子 (マンズ / Characters):[/b]\n一から九までの漢数字と赤文字の「萬」が描かれています。同じ数字同士のみペアにできます。",
		"SUIT_BAMBOO_DESC": "[b]索子 (ソーズ / Bamboo):[/b]\n竹の節を表す1から9までの牌。[color=#e8b070][b]重要：[/b]一索 (イーソー) は伝統的に美しい鳥 (孔雀/雀) として描かれています！[/color] 同じ索子同士のみペアにできます。",
		"SUIT_DOTS_DESC": "[b]筒子 (ピンズ / Dots):[/b]\n銅銭や丸を模した1から9までの牌。同じ筒子同士のみペアにできます。",
		"HONOR_WINDS_DESC": "[b]風牌 (かぜはい / Winds):[/b]\n東 (東)、南 (南)、西 (西)、北 (北) の四方位を表します。同じ方角の牌同士のみペアにできます！",
		"HONOR_DRAGONS_DESC": "[b]三元牌 (さんげんぱい / Dragons):[/b]\n白 (白板)、發 (緑の文字)、中 (赤い文字) の三種です。同じ三元牌同士のみペアにできます！",
		"SPECIAL_FLOWERS_SEASONS_DESC": "[b]花牌・季節牌 (ワイルドカードペア):[/b]\n通常の牌と異なり、絵柄が完全一致していなくても消せます！\n• [color=#e8b070]花牌はどの花牌同士でも消去可能[/color] (梅・蘭・竹・菊)。\n• [color=#75c080]季節牌はどの季節牌同士でも消去可能[/color] (春・夏・秋・冬)。",

		# Tile Names
		"TILE_1C": "一萬 (イーマン)", "TILE_2C": "二萬 (リャンマン)", "TILE_3C": "三萬 (サンマン)",
		"TILE_4C": "四萬 (スーマン)", "TILE_5C": "五萬 (ウーマン)", "TILE_6C": "六萬 (ローマン)",
		"TILE_7C": "七萬 (チーマン)", "TILE_8C": "八萬 (パーマン)", "TILE_9C": "九萬 (チュウマン)",

		"TILE_1B": "一索 (鳥/イーソー)", "TILE_2B": "二索", "TILE_3B": "三索",
		"TILE_4B": "四索", "TILE_5B": "五索", "TILE_6B": "六索",
		"TILE_7B": "七索", "TILE_8B": "八索", "TILE_9B": "九索",

		"TILE_1D": "一筒 (イーピン)", "TILE_2D": "二筒", "TILE_3D": "三筒",
		"TILE_4D": "四筒", "TILE_5D": "五筒", "TILE_6D": "六筒",
		"TILE_7D": "七筒", "TILE_8D": "八筒", "TILE_9D": "九筒",

		"TILE_EAST": "東 (トン)", "TILE_SOUTH": "南 (ナン)",
		"TILE_WEST": "西 (シャー)", "TILE_NORTH": "北 (ペー)",

		"TILE_RED": "中 (チュン)", "TILE_GREEN": "發 (ハツ)", "TILE_WHITE": "白 (ハク)",

		"TILE_PLUM": "梅 (ウメ)", "TILE_ORCHID": "蘭 (ラン)",
		"TILE_BAMBOO_FLOWER": "竹 (タケ)", "TILE_CHRYSANTHEMUM": "菊 (キク)",

		"TILE_AUTUMN": "秋 (アキ)", "TILE_WINTER": "冬 (フユ)",

		# Profile & Streak & Percentile
		"PROFILE_TITLE": "プレイヤープロフィール",
		"PROFILE_AVATAR": "アバター",
		"PROFILE_FRAME": "フレーム",
		"PROFILE_NAME_LABEL": "プレイヤー名",
		"BTN_SAVE_PROFILE": "プロフィールを保存",
		"STREAK_TITLE": "デイリーストリーク",
		"STREAK_SUBTITLE": "素晴らしい集中力です！",
		"STREAK_CLAIM_BTN": "報酬を受け取る",
		"STREAK_CLAIMED_BTN": "本日受取済み ✓",
		"STREAK_CHEST_REWARD": "7日目特別報酬：ヒント+5＆黄金の宝箱！",
		"STREAK_DAILY_REWARD": "デイリー報酬：ヒント+2！",
		"VIC_TOPPED_PLAYERS": "プレイヤーの %s より優れたスコアです！",
		"VIC_CHEST_UNLOCK": "マイルストーン宝箱：レベル %d (%d/%d)",
		"VIC_CHEST_READY": "マイルストーン宝箱解除！ヒント+3",
		"SETTINGS_EDIT_PROFILE": "プロフィール編集",
		"SETTINGS_AUDIO_HAPTICS": "オーディオ＆触覚"
	},

	"es": {
		# Main Menu
		"APP_TITLE": "ZEN MAHJONG",
		"APP_SUBTITLE": "UNA EXPERIENCIA TRANQUILA DE SOLITARIO",
		"BTN_PLAY": "▶  Jugar",
		"BTN_CONTINUE": "▶  Continuar (Nivel %d)",
		"BTN_LEVEL_SELECT": "🏯  Selección de Nivel",
		"BTN_DAILY": "📅  Desafío Diario",
		"BTN_TUTORIAL": "📖  Cómo Jugar",
		"BTN_SETTINGS": "⚙  Ajustes y Audio",
		"DAILY_STREAK": "🌿 Jardín Tranquilo • Racha Diaria: %d Días",
		"DAILY_STREAK_ZERO": "🌿 Jardín Tranquilo",
		"VERSION": "Zen Mahjong v1.0.0",

		# Settings
		"SETTINGS_TITLE": "Ajustes y Accesibilidad",
		"LANGUAGE_LABEL": "Idioma (Language)",
		"MUSIC_VOLUME": "Volumen de Música",
		"SFX_VOLUME": "Volumen de Efectos",
		"DIM_BLOCKED": "Atenuar fichas bloqueadas (asistencia visual)",
		"HAPTIC_FEEDBACK": "Vibración háptica al pulsar",
		"REDUCED_MOTION": "Movimiento reducido (transiciones suaves)",
		"BTN_BACK_MENU": "◀ Volver al Menú Principal",

		# Level Selection
		"LEVEL_SELECT_TITLE": "Selecciona un Nivel del Jardín",
		"LEVEL_LABEL": "Nivel %d",

		# Gameplay HUD
		"HUD_PAUSE": "⏸ Menú",
		"HUD_PAIRS_LEFT": "%d Parejas Restantes",
		"HUD_MOVES": "Movimientos: %d",
		"HUD_UNDO": "↶ Deshacer",
		"HUD_HINT": "💡 Pista",
		"HUD_SHUFFLE": "🔀 Barajar",
		"HUD_RESTART": "🔄 Reiniciar",

		# Modals
		"PAUSE_TITLE": "Juego Pausado",
		"BTN_RESUME": "▶ Reanudar",
		"BTN_RESTART_LEVEL": "🔄 Reiniciar Nivel",
		"BTN_HOW_TO_PLAY": "📖 Guía de Fichas y Reglas",
		"BTN_RETURN_MENU": "🏠 Volver al Menú",

		"VICTORY_TITLE": "🌸 ¡Jardín Completado! 🌸",
		"VICTORY_TIME": "Tiempo",
		"VICTORY_MOVES": "Movimientos",
		"BTN_NEXT_LEVEL": "Siguiente Nivel ▶",

		"NO_MOVES_TITLE": "Sin Movimientos Disponibles",
		"NO_MOVES_DESC": "No quedan parejas disponibles en el tablero. ¡Deshaz tus últimos movimientos o reinicia el nivel para encontrar el camino ganador!",
		"BTN_SHUFFLE_BOARD": "🔀 Barajar Tablero",
		"BTN_UNDO_MOVE": "↶ Deshacer Jugada",
		"BTN_CLOSE": "Cerrar",

		# How to Play & Tile Guide
		"GUIDE_TITLE": "Cómo Jugar y Guía de Fichas",
		"TAB_RULES": "📜 Reglas del Juego",
		"TAB_CHARACTERS": "一 Caracteres (Wan)",
		"TAB_BAMBOO": "竹 Bambú (Tiao)",
		"TAB_DOTS": "● Círculos (Tong)",
		"TAB_WINDS": "🀀 Vientos (Feng)",
		"TAB_DRAGONS": "🀄 Dragones (Jian)",
		"TAB_FLOWERS_SEASONS": "🌸 Flores y Estaciones",

		# Rules Descriptions
		"RULES_FREE_TITLE": "1. Fichas Libres (Seleccionables)",
		"RULES_FREE_DESC": "Una ficha es LIBRE y puede emparejarse solo cuando:\n• No hay ninguna ficha encima de ella, Y\n• Su lado IZQUIERDO o DERECHO está completamente despejado.\nLas fichas bloqueadas por ambos lados o cubiertas no se pueden elegir.",

		"RULES_MATCH_TITLE": "2. Reglas de Emparejamiento",
		"RULES_MATCH_DESC": "Toca dos fichas libres iguales para retirarlas:\n• [color=#75c080]Palos y Honores[/color] (Caracteres, Bambú, Círculos, Vientos, Dragones) deben coincidir de forma [b]EXACTA E IDÉNTICA[/b].\n• [color=#e8b070]Flores[/color] (Ciruelo, Orquídea, Bambú, Crisantemo) ¡coinciden con [b]CUALQUIER otra Flor[/b]!\n• [color=#e8b070]Estaciones[/color] (Primavera, Verano, Otoño, Invierno) ¡coinciden con [b]CUALQUIER otra Estación[/b]!",
		"RULES_SUITS_HEADER": "🎯 Palos Regulares y Honores (Deben coincidir exactamente):",
		"RULES_SUITS_EXAMPLE": "Ejemplo: [ 8 de Caracteres ] = [ 8 de Caracteres ]  ✓ Coincidencia exacta",
		"RULES_FLOWERS_HEADER": "🌸 Flores (¡Cualquier flor coincide con cualquier otra flor!):",
		"RULES_FLOWERS_EXAMPLE": "Ejemplo: [ Flor de Ciruelo ] = [ Orquídea ]  ✓ ¡Cualquier 2 flores coinciden!",
		"RULES_SEASONS_HEADER": "🍂 Estaciones (¡Cualquier estación coincide con cualquier otra estación!):",
		"RULES_SEASONS_EXAMPLE": "Ejemplo: [ Primavera ] = [ Verano ]  ✓ ¡Cualquier 2 estaciones coinciden!",

		"RULES_TOOLS_TITLE": "3. Herramientas de Asistencia",
		"RULES_TOOLS_DESC": "• [b]Deshacer[/b]: Revierte tu último movimiento emparejado.\n• [b]Pista[/b]: Resalta en verde esmeralda una pareja disponible.\n• [b]Reiniciar[/b]: Reinicia el tablero desde el principio para probar otra solución.",

		"RULES_GOAL_TITLE": "4. Objetivo",
		"RULES_GOAL_DESC": "¡Limpia las 144 fichas del jardín para conseguir la victoria y hasta 3 estrellas!",

		# Suit Explanations
		"SUIT_CHARACTERS_DESC": "[b]Palo de Caracteres (萬 / Wan):[/b]\nNúmeros tradicionales chinos del 1 al 9 con el carácter rojo '萬' (diez mil). Deben coincidir exactamente con el mismo número.",
		"SUIT_BAMBOO_DESC": "[b]Palo de Bambú (竹 / Tiao):[/b]\nTallos del 1 al 9. [color=#e8b070][b]Atención:[/b] ¡El 1 de Bambú está representado como un Gorrión / Ave Sagrada (鳥)![/color] Coinciden con fichas idénticas.",
		"SUIT_DOTS_DESC": "[b]Palo de Círculos / Puntos (筒 / Tong):[/b]\nDiscos y monedas tradicionales del 1 al 9. Coinciden con fichas de puntos idénticas.",
		"HONOR_WINDS_DESC": "[b]Honores de Viento (風牌 / Feng):[/b]\nRepresentan los 4 puntos cardinales: Este (東), Sur (南), Oeste (西), Norte (北). ¡Solo coinciden con su [b]MISMA DIRECCIÓN[/b]!",
		"HONOR_DRAGONS_DESC": "[b]Honores de Dragón (三元牌 / Jian):[/b]\nDragón Rojo (中), Dragón Verde (發), Dragón Blanco (白). ¡Solo coinciden con el [b]MISMO DRAGÓN[/b]!",
		"SPECIAL_FLOWERS_SEASONS_DESC": "[b]Flores y Estaciones (Emparejamiento Especial):[/b]\nA diferencia de las demás, estas fichas [b]NO[/b] necesitan ser idénticas:\n• [color=#e8b070]Cualquier Flor coincide con CUALQUIER otra Flor[/color].\n• [color=#75c080]Cualquier Estación coincide con CUALQUIER otra Estación[/color].",

		# Tile Names
		"TILE_1C": "1 de Caracteres", "TILE_2C": "2 de Caracteres", "TILE_3C": "3 de Caracteres",
		"TILE_4C": "4 de Caracteres", "TILE_5C": "5 de Caracteres", "TILE_6C": "6 de Caracteres",
		"TILE_7C": "7 de Caracteres", "TILE_8C": "8 de Caracteres", "TILE_9C": "9 de Caracteres",

		"TILE_1B": "1 de Bambú (Gorrión)", "TILE_2B": "2 de Bambú", "TILE_3B": "3 de Bambú",
		"TILE_4B": "4 de Bambú", "TILE_5B": "5 de Bambú", "TILE_6B": "6 de Bambú",
		"TILE_7B": "7 de Bambú", "TILE_8B": "8 de Bambú", "TILE_9B": "9 de Bambú",

		"TILE_1D": "1 de Círculos", "TILE_2D": "2 de Círculos", "TILE_3D": "3 de Círculos",
		"TILE_4D": "4 de Círculos", "TILE_5D": "5 de Círculos", "TILE_6D": "6 de Círculos",
		"TILE_7D": "7 de Círculos", "TILE_8D": "8 de Círculos", "TILE_9D": "9 de Círculos",

		"TILE_EAST": "Viento Este (東)", "TILE_SOUTH": "Viento Sur (南)",
		"TILE_WEST": "Viento Oeste (西)", "TILE_NORTH": "Viento Norte (北)",

		"TILE_RED": "Dragón Rojo (中)", "TILE_GREEN": "Dragón Verde (發)", "TILE_WHITE": "Dragón Blanco (白)",

		"TILE_PLUM": "Flor de Ciruelo (梅)", "TILE_ORCHID": "Orquídea (蘭)",
		"TILE_BAMBOO_FLOWER": "Bambú en Flor (竹)", "TILE_CHRYSANTHEMUM": "Crisantemo (菊)",

		"TILE_AUTUMN": "Otoño (秋)", "TILE_WINTER": "Invierno (冬)",

		# Profile & Streak & Percentile
		"PROFILE_TITLE": "Perfil del Jugador",
		"PROFILE_AVATAR": "Avatar",
		"PROFILE_FRAME": "Marco",
		"PROFILE_NAME_LABEL": "Nombre del Jugador",
		"BTN_SAVE_PROFILE": "Guardar Perfil",
		"STREAK_TITLE": "Racha Diaria",
		"STREAK_SUBTITLE": "¡Gran enfoque y excelente juego!",
		"STREAK_CLAIM_BTN": "Reclamar Recompensa",
		"STREAK_CLAIMED_BTN": "Reclamado Hoy ✓",
		"STREAK_CHEST_REWARD": "Gran Recompensa Día 7: ¡+5 Pistas y Cofre Dorado!",
		"STREAK_DAILY_REWARD": "Recompensa Diaria: ¡+2 Pistas Adicionales!",
		"VIC_TOPPED_PLAYERS": "¡Superaste al %s de los jugadores!",
		"VIC_CHEST_UNLOCK": "Cofre de Meta: Nivel %d (%d/%d)",
		"VIC_CHEST_READY": "¡Cofre Desbloqueado! +3 Pistas",
		"SETTINGS_EDIT_PROFILE": "Editar Perfil",
		"SETTINGS_AUDIO_HAPTICS": "Audio y Vibración"
	},

	"fr": {
		# Main Menu
		"APP_TITLE": "ZEN MAHJONG",
		"APP_SUBTITLE": "UNE EXPÉRIENCE DE SOLITAIRE APAISANTE",
		"BTN_PLAY": "▶  Jouer",
		"BTN_CONTINUE": "▶  Continuer (Niveau %d)",
		"BTN_LEVEL_SELECT": "🏯  Choix du Niveau",
		"BTN_DAILY": "📅  Défi Quotidien",
		"BTN_TUTORIAL": "📖  Comment Jouer",
		"BTN_SETTINGS": "⚙  Options et Audio",
		"DAILY_STREAK": "🌿 Jardin Paisible • Série Quotidienne: %d Jours",
		"DAILY_STREAK_ZERO": "🌿 Jardin Paisible",
		"VERSION": "Zen Mahjong v1.0.0",

		# Settings
		"SETTINGS_TITLE": "Options & Accessibilité",
		"LANGUAGE_LABEL": "Langue (Language)",
		"MUSIC_VOLUME": "Volume de la Musique",
		"SFX_VOLUME": "Volume des Effets",
		"DIM_BLOCKED": "Assombrir les tuiles bloquées (aide visuelle)",
		"HAPTIC_FEEDBACK": "Retour haptique tactile",
		"REDUCED_MOTION": "Mouvements réduits (transitions douces)",
		"BTN_BACK_MENU": "◀ Retour au Menu Principal",

		# Level Selection
		"LEVEL_SELECT_TITLE": "Sélectionnez un Jardin",
		"LEVEL_LABEL": "Niveau %d",

		# Gameplay HUD
		"HUD_PAUSE": "⏸ Menu",
		"HUD_PAIRS_LEFT": "%d Paires Restantes",
		"HUD_MOVES": "Coups: %d",
		"HUD_UNDO": "↶ Annuler",
		"HUD_HINT": "💡 Indice",
		"HUD_SHUFFLE": "🔀 Mélanger",
		"HUD_RESTART": "🔄 Recommencer",

		# Modals
		"PAUSE_TITLE": "Partie en Pause",
		"BTN_RESUME": "▶ Reprendre",
		"BTN_RESTART_LEVEL": "🔄 Recommencer le Niveau",
		"BTN_HOW_TO_PLAY": "📖 Guide des Tuiles & Règles",
		"BTN_RETURN_MENU": "🏠 Retour au Menu",

		"VICTORY_TITLE": "🌸 Jardin Parfaitement Résolu! 🌸",
		"VICTORY_TIME": "Temps",
		"VICTORY_MOVES": "Coups",
		"BTN_NEXT_LEVEL": "Niveau Suivant ▶",

		"NO_MOVES_TITLE": "Aucun Coup Restant",
		"NO_MOVES_DESC": "Aucune paire libre n'est disponible sur le plateau. Annulez vos derniers coups ou recommencez le niveau pour trouver le chemin gagnant !",
		"BTN_SHUFFLE_BOARD": "🔀 Mélanger le Plateau",
		"BTN_UNDO_MOVE": "↶ Annuler le Coup",
		"BTN_CLOSE": "Fermer",

		# How to Play & Tile Guide
		"GUIDE_TITLE": "Comment Jouer & Guide des Tuiles",
		"TAB_RULES": "📜 Règles du Jeu",
		"TAB_CHARACTERS": "一 Caractères (Wan)",
		"TAB_BAMBOO": "竹 Bambous (Tiao)",
		"TAB_DOTS": "● Cercles (Tong)",
		"TAB_WINDS": "🀀 Vents (Feng)",
		"TAB_DRAGONS": "🀄 Dragons (Jian)",
		"TAB_FLOWERS_SEASONS": "🌸 Fleurs & Saisons",

		# Rules Descriptions
		"RULES_FREE_TITLE": "1. Tuiles Libres (Jouables)",
		"RULES_FREE_DESC": "Une tuile est LIBRE et peut être combinée seulement si :\n• Aucune tuile ne repose DIRECTEMENT dessus, ET\n• Son côté GAUCHE ou DROIT est totalement dégagé.\nLes tuiles coincées des deux côtés ou couvertes ne peuvent pas être choisies.",

		"RULES_MATCH_TITLE": "2. Règle des Paires",
		"RULES_MATCH_DESC": "Touchez deux tuiles libres identiques pour les retirer :\n• [color=#75c080]Familles & Honneurs[/color] (Caractères, Bambous, Cercles, Vents, Dragons) doivent être [b]EXACTEMENT IDENTIQUES[/b].\n• [color=#e8b070]Fleurs[/color] (Prunier, Orchidée, Bambou, Chrysanthème) s'associent avec [b]N'IMPORTE QUELLE autre Fleur[/b] !\n• [color=#e8b070]Saisons[/color] (Printemps, Été, Automne, Hiver) s'associent avec [b]N'IMPORTE QUELLE autre Saison[/b] !",
		"RULES_SUITS_HEADER": "🎯 Familles régulières & Honneurs (Doivent être identiques) :",
		"RULES_SUITS_EXAMPLE": "Exemple : [ 8 de Caractères ] = [ 8 de Caractères ]  ✓ Correspondance exacte",
		"RULES_FLOWERS_HEADER": "🌸 Fleurs (Toute fleur correspond à n'importe quelle autre fleur !) :",
		"RULES_FLOWERS_EXAMPLE": "Exemple : [ Prunier ] = [ Orchidée ]  ✓ N'importe quelles 2 fleurs s'associent !",
		"RULES_SEASONS_HEADER": "🍂 Saisons (Toute saison correspond à n'importe quelle autre saison !) :",
		"RULES_SEASONS_EXAMPLE": "Exemple : [ Printemps ] = [ Été ]  ✓ N'importe quelles 2 saisons s'associent !",

		"RULES_TOOLS_TITLE": "3. Outils d'Aide",
		"RULES_TOOLS_DESC": "• [b]Annuler[/b] : Déjoue votre dernier coup.\n• [b]Indice[/b] : Fait briller une paire libre en vert émeraude.\n• [b]Recommencer[/b] : Recommence le niveau dès le début pour tenter une autre approche.",

		"RULES_GOAL_TITLE": "4. Objectif",
		"RULES_GOAL_DESC": "Éliminez les 144 tuiles du jardin zen pour remporter la victoire et jusqu'à 3 étoiles !",

		# Suit Explanations
		"SUIT_CHARACTERS_DESC": "[b]Famille des Caractères (萬 / Wan) :[/b]\nNuméros traditionnels chinois de 1 à 9 avec le caractère rouge '萬' (Wan = dix mille). S'associent uniquement avec le numéro identique.",
		"SUIT_BAMBOO_DESC": "[b]Famille des Bambous (竹 / Tiao) :[/b]\nTiges de bambou de 1 à 9. [color=#e8b070][b]Remarque :[/b] Le 1 de Bambou est représenté par le Moineau sacré / Oiseau (鳥) ![/color] S'associent avec des bambous identiques.",
		"SUIT_DOTS_DESC": "[b]Famille des Cercles (筒 / Tong) :[/b]\nPièces de monnaie rondes de 1 à 9. S'associent uniquement avec les cercles identiques.",
		"HONOR_WINDS_DESC": "[b]Honneurs des Vents (風牌 / Feng) :[/b]\nLes 4 points cardinaux : Est (東), Sud (南), Ouest (西), Nord (北). S'associent uniquement avec la [b]MÊME DIRECTION[/b] !",
		"HONOR_DRAGONS_DESC": "[b]Honneurs des Dragons (三元牌 / Jian) :[/b]\nDragon Rouge (中), Dragon Vert (發), Dragon Blanc (白). S'associent uniquement avec le [b]MÊME DRAGON[/b] !",
		"SPECIAL_FLOWERS_SEASONS_DESC": "[b]Fleurs & Saisons (Combinaisons Libres) :[/b]\nContrairement aux autres tuiles, elles n'[b]ONT PAS BESOIN[/b] d'être identiques !\n• [color=#e8b070]Toute Fleur s'associe avec TOUTE autre Fleur[/color].\n• [color=#75c080]Toute Saison s'associe avec TOUTE autre Saison[/color].",

		# Tile Names
		"TILE_1C": "1 de Caractères", "TILE_2C": "2 de Caractères", "TILE_3C": "3 de Caractères",
		"TILE_4C": "4 de Caractères", "TILE_5C": "5 de Caractères", "TILE_6C": "6 de Caractères",
		"TILE_7C": "7 de Caractères", "TILE_8C": "8 de Caractères", "TILE_9C": "9 de Caractères",

		"TILE_1B": "1 de Bambou (Oiseau)", "TILE_2B": "2 de Bambou", "TILE_3B": "3 de Bambou",
		"TILE_4B": "4 de Bambou", "TILE_5B": "5 de Bambou", "TILE_6B": "6 de Bambou",
		"TILE_7B": "7 de Bambou", "TILE_8B": "8 de Bambou", "TILE_9B": "9 de Bambou",

		"TILE_1D": "1 de Cercles", "TILE_2D": "2 de Cercles", "TILE_3D": "3 de Cercles",
		"TILE_4D": "4 de Cercles", "TILE_5D": "5 de Cercles", "TILE_6D": "6 de Cercles",
		"TILE_7D": "7 de Cercles", "TILE_8D": "8 de Cercles", "TILE_9D": "9 de Cercles",

		"TILE_EAST": "Vent d'Est (東)", "TILE_SOUTH": "Vent du Sud (南)",
		"TILE_WEST": "Vent d'Ouest (西)", "TILE_NORTH": "Vent du Nord (北)",

		"TILE_RED": "Dragon Rouge (中)", "TILE_GREEN": "Dragon Vert (發)", "TILE_WHITE": "Dragon Blanc (白)",

		"TILE_PLUM": "Fleur de Prunier (梅)", "TILE_ORCHID": "Orchidée (蘭)",
		"TILE_BAMBOO_FLOWER": "Fleur de Bambou (竹)", "TILE_CHRYSANTHEMUM": "Chrysanthème (菊)",

		"TILE_AUTUMN": "Automne (秋)", "TILE_WINTER": "Hiver (冬)",

		# Profile & Streak & Percentile
		"PROFILE_TITLE": "Profil du Joueur",
		"PROFILE_AVATAR": "Avatar",
		"PROFILE_FRAME": "Cadre",
		"PROFILE_NAME_LABEL": "Nom du Joueur",
		"BTN_SAVE_PROFILE": "Sauvegarder le Profil",
		"STREAK_TITLE": "Série de Jours",
		"STREAK_SUBTITLE": "Concentration zen, excellent jeu !",
		"STREAK_CLAIM_BTN": "Récupérer la Récompense",
		"STREAK_CLAIMED_BTN": "Récupéré Aujourd'hui ✓",
		"STREAK_CHEST_REWARD": "Grande Récompense Jour 7 : +5 Indices et Coffre Doré !",
		"STREAK_DAILY_REWARD": "Récompense Quotidienne : +2 Indices Bonus !",
		"VIC_TOPPED_PLAYERS": "Vous avez surpassé %s des joueurs !",
		"VIC_CHEST_UNLOCK": "Coffre d'Étape : Niveau %d (%d/%d)",
		"VIC_CHEST_READY": "Coffre Débloqué ! +3 Indices",
		"SETTINGS_EDIT_PROFILE": "Modifier le Profil",
		"SETTINGS_AUDIO_HAPTICS": "Audio et Vibrations"
	},

	"de": {
		# Main Menu
		"APP_TITLE": "ZEN MAHJONG",
		"APP_SUBTITLE": "EIN RUHIGES SOLITÄRE-ERLEBNIS",
		"BTN_PLAY": "▶  Spielen",
		"BTN_CONTINUE": "▶  Fortsetzen (Level %d)",
		"BTN_LEVEL_SELECT": "🏯  Levelauswahl",
		"BTN_DAILY": "📅  Tägliche Herausforderung",
		"BTN_TUTORIAL": "📖  Spielanleitung",
		"BTN_SETTINGS": "⚙  Einstellungen & Ton",
		"DAILY_STREAK": "🌿 Ruhiger Garten • Tagesserie: %d Tage",
		"DAILY_STREAK_ZERO": "🌿 Ruhiger Garten",
		"VERSION": "Zen Mahjong v1.0.0",

		# Settings
		"SETTINGS_TITLE": "Einstellungen & Barrierefreiheit",
		"LANGUAGE_LABEL": "Sprache (Language)",
		"MUSIC_VOLUME": "Musiklautstärke",
		"SFX_VOLUME": "Soundeffekte-Lautstärke",
		"DIM_BLOCKED": "Blockierte Steine abdunkeln (Sehhilfe)",
		"HAPTIC_FEEDBACK": "Haptisches Feedback bei Berührung",
		"REDUCED_MOTION": "Reduzierte Bewegung (sanfte Übergänge)",
		"BTN_BACK_MENU": "◀ Zurück zum Hauptmenü",

		# Level Selection
		"LEVEL_SELECT_TITLE": "Garten-Level auswählen",
		"LEVEL_LABEL": "Level %d",

		# Gameplay HUD
		"HUD_PAUSE": "⏸ Menü",
		"HUD_PAIRS_LEFT": "%d Paare übrig",
		"HUD_MOVES": "Züge: %d",
		"HUD_UNDO": "↶ Zurück",
		"HUD_HINT": "💡 Hinweis",
		"HUD_SHUFFLE": "🔀 Mischen",
		"HUD_RESTART": "🔄 Neustart",

		# Modals
		"PAUSE_TITLE": "Spiel Pausiert",
		"BTN_RESUME": "▶ Weiter",
		"BTN_RESTART_LEVEL": "🔄 Level Neustarten",
		"BTN_HOW_TO_PLAY": "📖 Stein-Übersicht & Regeln",
		"BTN_RETURN_MENU": "🏠 Zum Hauptmenü",

		"VICTORY_TITLE": "🌸 Garten Vollständig Gelöst! 🌸",
		"VICTORY_TIME": "Zeit",
		"VICTORY_MOVES": "Züge",
		"BTN_NEXT_LEVEL": "Nächstes Level ▶",

		"NO_MOVES_TITLE": "Keine Züge Mehr",
		"NO_MOVES_DESC": "Keine offenen Paare mehr auf dem Spielfeld. Machen Sie Ihre letzten Züge rückgängig oder starten Sie das Level neu, um den Gewinnweg zu finden!",
		"BTN_SHUFFLE_BOARD": "🔀 Steine Mischen",
		"BTN_UNDO_MOVE": "↶ Zug Rückgängig",
		"BTN_CLOSE": "Schließen",

		# How to Play & Tile Guide
		"GUIDE_TITLE": "Spielanleitung & Stein-Übersicht",
		"TAB_RULES": "📜 Spielregeln",
		"TAB_CHARACTERS": "一 Schriftzeichen (Wan)",
		"TAB_BAMBOO": "竹 Bambus (Tiao)",
		"TAB_DOTS": "● Kreise (Tong)",
		"TAB_WINDS": "🀀 Winde (Feng)",
		"TAB_DRAGONS": "🀄 Drachen (Jian)",
		"TAB_FLOWERS_SEASONS": "🌸 Blumen & Jahreszeiten",

		# Rules Descriptions
		"RULES_FREE_TITLE": "1. Freie Steine (Auswählbar)",
		"RULES_FREE_DESC": "Ein Stein ist FREI und kann kombiniert werden, wenn:\n• Kein Stein DIREKT AUF ihm liegt, UND\n• Seine LINKE oder RECHTE Seite komplett frei liegt.\nSteine, die beidseitig blockiert oder verdeckt sind, können nicht gewählt werden.",

		"RULES_MATCH_TITLE": "2. Paarbildungsregeln",
		"RULES_MATCH_DESC": "Tippe auf zwei freie identische Steine, um sie abzuräumen:\n• [color=#75c080]Zahlen & Ehren[/color] (Schriftzeichen, Bambus, Kreise, Winde, Drachen) müssen [b]EXAKT IDENTISCH[/b] sein.\n• [color=#e8b070]Blumen[/color] (Pflaume, Orchidee, Bambus, Chrysantheme) passen zu [b]JEDER anderen Blume[/b]!\n• [color=#e8b070]Jahreszeiten[/color] (Frühling, Sommer, Herbst, Winter) passen zu [b]JEDER anderen Jahreszeit[/b]!",
		"RULES_SUITS_HEADER": "🎯 Reguläre Farben & Ziegel (Müssen exakt übereinstimmen):",
		"RULES_SUITS_EXAMPLE": "Beispiel: [ 8 der Zeichen ] = [ 8 der Zeichen ]  ✓ Exakte Übereinstimmung",
		"RULES_FLOWERS_HEADER": "🌸 Blumen (Jede Blume passt zu jeder anderen Blume!):",
		"RULES_FLOWERS_EXAMPLE": "Beispiel: [ Pflaume ] = [ Orchidee ]  ✓ Beliebige 2 Blumen passen zusammen!",
		"RULES_SEASONS_HEADER": "🍂 Jahreszeiten (Jede Jahreszeit passt zu jeder anderen Jahreszeit!):",
		"RULES_SEASONS_EXAMPLE": "Beispiel: [ Frühling ] = [ Sommer ]  ✓ Beliebige 2 Jahreszeiten passen zusammen!",

		"RULES_TOOLS_TITLE": "3. Hilfsmittel",
		"RULES_TOOLS_DESC": "• [b]Rückgängig[/b]: Macht den letzten Spielzug rückgängig.\n• [b]Hinweis[/b]: Lässt ein freies Paar smaragdgrün leuchten.\n• [b]Neustart[/b]: Startet das Level von vorne, um einen anderen Lösungsweg zu versuchen.",

		"RULES_GOAL_TITLE": "4. Spielziel",
		"RULES_GOAL_DESC": "Räume alle 144 Steine vom Brett, um den Sieg zu erringen und bis zu 3 Sterne zu erhalten!",

		# Suit Explanations
		"SUIT_CHARACTERS_DESC": "[b]Schriftzeichen-Familie (萬 / Wan):[/b]\nChinesische Zahlen von 1 bis 9 mit dem roten Symbol '萬' (Zehntausend). Nur gleiche Zahlen passen zueinander.",
		"SUIT_BAMBOO_DESC": "[b]Bambus-Familie (竹 / Tiao):[/b]\nBambushalme von 1 bis 9. [color=#e8b070][b]Hinweis:[/b] 1 Bambus wird traditionell als heiliger Spatz / Vogel (鳥) dargestellt![/color] Nur gleiche Bambussteine passen zueinander.",
		"SUIT_DOTS_DESC": "[b]Kreise-Familie (筒 / Tong):[/b]\nTraditionelle runde Kupfermünzen von 1 bis 9. Nur gleiche Kreissteine passen zueinander.",
		"HONOR_WINDS_DESC": "[b]Wind-Ehren (風牌 / Feng):[/b]\nDie 4 Himmelsrichtungen: Ost (東), Süd (南), West (西), Nord (北). Nur Steine der [b]GLEICHEN RICHTUNG[/b] passen zueinander!",
		"HONOR_DRAGONS_DESC": "[b]Drachen-Ehren (三元牌 / Jian):[/b]\nRoter Drache (中), Grüner Drache (發), Weißer Drache (白). Nur [b]DERSELBE DRACHE[/b] passt zusammen!",
		"SPECIAL_FLOWERS_SEASONS_DESC": "[b]Blumen & Jahreszeiten (Sonderregeln):[/b]\nIm Gegensatz zu normalen Steinen müssen diese [b]NICHT[/b] identisch sein!\n• [color=#e8b070]Jede Blume passt zu JEDER anderen Blume[/color].\n• [color=#75c080]Jede Jahreszeit passt zu JEDER anderen Jahreszeit[/color].",

		# Tile Names
		"TILE_1C": "1 der Schriftzeichen", "TILE_2C": "2 der Schriftzeichen", "TILE_3C": "3 der Schriftzeichen",
		"TILE_4C": "4 der Schriftzeichen", "TILE_5C": "5 der Schriftzeichen", "TILE_6C": "6 der Schriftzeichen",
		"TILE_7C": "7 der Schriftzeichen", "TILE_8C": "8 der Schriftzeichen", "TILE_9C": "9 der Schriftzeichen",

		"TILE_1B": "1 des Bambus (Vogel)", "TILE_2B": "2 des Bambus", "TILE_3B": "3 des Bambus",
		"TILE_4B": "4 des Bambus", "TILE_5B": "5 des Bambus", "TILE_6B": "6 des Bambus",
		"TILE_7B": "7 des Bambus", "TILE_8B": "8 des Bambus", "TILE_9B": "9 des Bambus",

		"TILE_1D": "1 der Kreise", "TILE_2D": "2 der Kreise", "TILE_3D": "3 der Kreise",
		"TILE_4D": "4 der Kreise", "TILE_5D": "5 der Kreise", "TILE_6D": "6 der Kreise",
		"TILE_7D": "7 der Kreise", "TILE_8D": "8 der Kreise", "TILE_9D": "9 der Kreise",

		"TILE_EAST": "Ostwind (東)", "TILE_SOUTH": "Südwind (南)",
		"TILE_WEST": "Westwind (西)", "TILE_NORTH": "Nordwind (北)",

		"TILE_RED": "Roter Drache (中)", "TILE_GREEN": "Grüner Drache (發)", "TILE_WHITE": "Weißer Drache (白)",

		"TILE_PLUM": "Pflaumenblüte (梅)", "TILE_ORCHID": "Orchidee (蘭)",
		"TILE_BAMBOO_FLOWER": "Bambusblüte (竹)", "TILE_CHRYSANTHEMUM": "Chrysantheme (菊)",

		"TILE_AUTUMN": "Herbst (秋)", "TILE_WINTER": "Winter (冬)",

		# Profile & Streak & Percentile
		"PROFILE_TITLE": "Spielerprofil",
		"PROFILE_AVATAR": "Avatar",
		"PROFILE_FRAME": "Rahmen",
		"PROFILE_NAME_LABEL": "Spielername",
		"BTN_SAVE_PROFILE": "Profil Speichern",
		"STREAK_TITLE": "Tages-Serie",
		"STREAK_SUBTITLE": "Tolle Konzentration, großartig gespielt!",
		"STREAK_CLAIM_BTN": "Belohnung Abholen",
		"STREAK_CLAIMED_BTN": "Heute Abgeholt ✓",
		"STREAK_CHEST_REWARD": "Tag 7 Hauptbelohnung: +5 Hinweise & Goldene Truhe!",
		"STREAK_DAILY_REWARD": "Tägliche Belohnung: +2 Bonus-Hinweise!",
		"VIC_TOPPED_PLAYERS": "Besser als %s aller Spieler!",
		"VIC_CHEST_UNLOCK": "Meilenstein-Truhe: Level %d (%d/%d)",
		"VIC_CHEST_READY": "Meilenstein-Truhe Freigeschaltet! +3 Hinweise",
		"SETTINGS_EDIT_PROFILE": "Profil Bearbeiten",
		"SETTINGS_AUDIO_HAPTICS": "Audio & Haptik"
	},

	"hi": {
		# Main Menu
		"APP_TITLE": "ज़ेन माहजोंग",
		"APP_SUBTITLE": "एक शांत और ध्यानमग्न सॉलिटेयर अनुभव",
		"BTN_PLAY": "▶  खेलें",
		"BTN_CONTINUE": "▶  जारी रखें (स्तर %d)",
		"BTN_LEVEL_SELECT": "🏯  स्तर चयन",
		"BTN_DAILY": "📅  दैनिक चुनौती",
		"BTN_TUTORIAL": "📖  कैसे खेलें",
		"BTN_SETTINGS": "⚙  सेटिंग्स और ध्वनि",
		"DAILY_STREAK": "🌿 शांत उद्यान • दैनिक स्ट्रीक: %d दिन",
		"DAILY_STREAK_ZERO": "🌿 शांत उद्यान",
		"VERSION": "Zen Mahjong v1.0.0",

		# Settings
		"SETTINGS_TITLE": "सेटिंग्स और सुगमता",
		"LANGUAGE_LABEL": "भाषा (Language)",
		"MUSIC_VOLUME": "संगीत वॉल्यूम",
		"SFX_VOLUME": "ध्वनि प्रभाव वॉल्यूम",
		"DIM_BLOCKED": "अवरुद्ध टाइलों को मंद करें (दृश्य सहायता)",
		"HAPTIC_FEEDBACK": "स्पर्श पर कंपन (हैप्टिक)",
		"REDUCED_MOTION": "धीमी गति (कोमल बदलाव)",
		"BTN_BACK_MENU": "◀ मुख्य मेनू पर लौटें",

		# Level Selection
		"LEVEL_SELECT_TITLE": "उद्यान स्तर चुनें",
		"LEVEL_LABEL": "स्तर %d",

		# Gameplay HUD
		"HUD_PAUSE": "⏸ मेनू",
		"HUD_PAIRS_LEFT": "%d जोड़े शेष",
		"HUD_MOVES": "चालें: %d",
		"HUD_UNDO": "↶ पूर्ववत",
		"HUD_HINT": "💡 संकेत",
		"HUD_SHUFFLE": "🔀 फेरबदल",
		"HUD_RESTART": "🔄 पुनः आरंभ",

		# Modals
		"PAUSE_TITLE": "खेल रुका हुआ",
		"BTN_RESUME": "▶ फिर शुरू करें",
		"BTN_RESTART_LEVEL": "🔄 स्तर पुनः आरंभ करें",
		"BTN_HOW_TO_PLAY": "📖 टाइल गाइड और नियम",
		"BTN_RETURN_MENU": "🏠 मेनू पर लौटें",

		"VICTORY_TITLE": "🌸 उद्यान सफलतापूर्वक साफ हुआ! 🌸",
		"VICTORY_TIME": "समय",
		"VICTORY_MOVES": "चालें",
		"BTN_NEXT_LEVEL": "अगला स्तर ▶",

		"NO_MOVES_TITLE": "कोई चाल शेष नहीं",
		"NO_MOVES_DESC": "बोर्ड पर कोई खुली जोड़ी नहीं बची है। जीतने का रास्ता खोजने के लिए अपनी हालिया चालों को पूर्ववत करें या स्तर को पुनः आरंभ करें!",
		"BTN_SHUFFLE_BOARD": "🔀 बोर्ड फेरबदल",
		"BTN_UNDO_MOVE": "↶ चाल पूर्ववत करें",
		"BTN_CLOSE": "बंद करें",

		# How to Play & Tile Guide
		"GUIDE_TITLE": "खेलने का तरीका और टाइल गाइड",
		"TAB_RULES": "📜 खेल के नियम",
		"TAB_CHARACTERS": "一 अक्षर (Wan)",
		"TAB_BAMBOO": "竹 बांस (Tiao)",
		"TAB_DOTS": "● बिंदु (Tong)",
		"TAB_WINDS": "🀀 दिशाएं (Feng)",
		"TAB_DRAGONS": "🀄 ड्रैगन (Jian)",
		"TAB_FLOWERS_SEASONS": "🌸 फूल और ऋतुएं",

		# Rules Descriptions
		"RULES_FREE_TITLE": "1. खुली टाइलें (चयन योग्य)",
		"RULES_FREE_DESC": "एक टाइल केवल तब मुक्त होती है जब:\n• इसके ऊपर सीधे कोई अन्य टाइल न रखी हो, और\n• इसका बायां या दायां सिरा पूरी तरह से खुला हो।\nदोनों तरफ से घिरी या दबी हुई टाइलों को नहीं चुना जा सकता।",

		"RULES_MATCH_TITLE": "2. जोड़ी मिलान के नियम",
		"RULES_MATCH_DESC": "बोर्ड से हटाने के लिए दो समान खुली टाइलों पर टैप करें:\n• [color=#75c080]नियमित सूट और सम्मान[/color] (अक्षर, बांस, बिंदु, दिशाएं, ड्रैगन) केवल [b]बिल्कुल समान टाइल[/b] से मेल खाती हैं।\n• [color=#e8b070]फूल[/color] (बेर, आर्किड, बांस, गुलदाउदी) [b]किसी भी अन्य फूल[/b] से मेल खाते हैं!\n• [color=#e8b070]ऋतुएं[/color] (वसंत, ग्रीष्म, पतझड़, सर्दी) [b]किसी भी अन्य ऋतु[/b] से मेल खाती हैं!",
		"RULES_SUITS_HEADER": "🎯 नियमित सूट और सम्मान (सटीक समान टाइल से मिलना चाहिए):",
		"RULES_SUITS_EXAMPLE": "उदाहरण: [ 8 कैरेक्टर ] = [ 8 कैरेक्टर ]  ✓ सटीक समान मिलान",
		"RULES_FLOWERS_HEADER": "🌸 फूल (कोई भी फूल किसी भी अन्य फूल से मेल खाता है!):",
		"RULES_FLOWERS_EXAMPLE": "उदाहरण: [ बेर का फूल ] = [ ऑर्किड ]  ✓ कोई भी 2 फूल आपस में मिलते हैं!",
		"RULES_SEASONS_HEADER": "🍂 मौसम (कोई भी मौसम किसी भी अन्य मौसम से मेल खाता है!):",
		"RULES_SEASONS_EXAMPLE": "उदाहरण: [ वसंत ] = [ ग्रीष्म ]  ✓ कोई भी 2 मौसम आपस में मिलते हैं!",

		"RULES_TOOLS_TITLE": "3. सहायता उपकरण",
		"RULES_TOOLS_DESC": "• [b]पूर्ववत[/b]: अपनी पिछली चाल को उलटें।\n• [b]संकेत[/b]: पन्ना हरे रंग में उपलब्ध जोड़ी को दिखाता है।\n• [b]पुनः आरंभ[/b]: बोर्ड को शुरू से फिर से शुरू करें ताकि आप दूसरा रास्ता खोज सकें।",

		"RULES_GOAL_TITLE": "4. खेल का लक्ष्य",
		"RULES_GOAL_DESC": "जीत हासिल करने और 3 सितारे प्राप्त करने के लिए सभी 144 टाइलों को साफ करें!",

		# Suit Explanations
		"SUIT_CHARACTERS_DESC": "[b]अक्षर सूट (萬 / Wan):[/b]\nपारंपरिक चीनी 1 से 9 अंक जिनके नीचे लाल '萬' प्रतीक होता है। ये केवल समान अंक से मेल खाते हैं।",
		"SUIT_BAMBOO_DESC": "[b]बांस सूट (竹 / Tiao):[/b]\n1 से 9 बांस की तीलियां। [color=#e8b070][b]ध्यान दें:[/b] 1 बांस को पारंपरिक रूप से पवित्र पक्षी/गौरैया (鳥) के रूप में दर्शाया जाता है![/color] केवल समान बांस से मेल खाते हैं।",
		"SUIT_DOTS_DESC": "[b]बिंदु सूट (筒 / Tong):[/b]\n1 से 9 गोल सिक्के/डिस्क। ये केवल समान बिंदु वाली टाइल से मेल खाते हैं।",
		"HONOR_WINDS_DESC": "[b]दिशाएं / हवाएं (風牌 / Feng):[/b]\nपूर्व (東), दक्षिण (南), पश्चिम (西), उत्तर (北)। ये केवल अपनी [b]समान दिशा[/b] से मेल खाती हैं!",
		"HONOR_DRAGONS_DESC": "[b]शाही ड्रैगन (三元牌 / Jian):[/b]\nलाल ड्रैगन (中), हरा ड्रैगन (發), सफेद ड्रैगन (白)। ये केवल [b]समान ड्रैगन[/b] से मेल खाते हैं!",
		"SPECIAL_FLOWERS_SEASONS_DESC": "[b]फूल और ऋतुएं (विशेष वाइल्डकार्ड मिलान):[/b]\nअन्य टाइलों के विपरीत, इनके समान होने की [b]आवश्यकता नहीं[/b] है!\n• [color=#e8b070]कोई भी फूल किसी भी अन्य फूल से मेल खाता है[/color]।\n• [color=#75c080]कोई भी ऋतु किसी भी अन्य ऋतु से मेल खाती है[/color]।",

		# Tile Names
		"TILE_1C": "1 अक्षर", "TILE_2C": "2 अक्षर", "TILE_3C": "3 अक्षर",
		"TILE_4C": "4 अक्षर", "TILE_5C": "5 अक्षर", "TILE_6C": "6 अक्षर",
		"TILE_7C": "7 अक्षर", "TILE_8C": "8 अक्षर", "TILE_9C": "9 अक्षर",

		"TILE_1B": "1 बांस (पक्षी)", "TILE_2B": "2 बांस", "TILE_3B": "3 बांस",
		"TILE_4B": "4 बांस", "TILE_5B": "5 बांस", "TILE_6B": "6 बांस",
		"TILE_7B": "7 बांस", "TILE_8B": "8 बांस", "TILE_9B": "9 बांस",

		"TILE_1D": "1 बिंदु", "TILE_2D": "2 बिंदु", "TILE_3D": "3 बिंदु",
		"TILE_4D": "4 बिंदु", "TILE_5D": "5 बिंदु", "TILE_6D": "6 बिंदु",
		"TILE_7D": "7 बिंदु", "TILE_8D": "8 बिंदु", "TILE_9D": "9 बिंदु",

		"TILE_EAST": "पूर्वी हवा (東)", "TILE_SOUTH": "दक्षिणी हवा (南)",
		"TILE_WEST": "पश्चिमी हवा (西)", "TILE_NORTH": "उत्तरी हवा (北)",

		"TILE_RED": "लाल ड्रैगन (中)", "TILE_GREEN": "हरा ड्रैगन (發)", "TILE_WHITE": "सफेद ड्रैगन (白)",

		"TILE_PLUM": "बेर का फूल (梅)", "TILE_ORCHID": "आर्किड (蘭)",
		"TILE_BAMBOO_FLOWER": "बांस का फूल (竹)", "TILE_CHRYSANTHEMUM": "गुलदाउदी (菊)",

		"TILE_AUTUMN": "पतझड़ (秋)", "TILE_WINTER": "सर्दी (冬)",

		# Profile & Streak & Percentile
		"PROFILE_TITLE": "खिलाड़ी प्रोफ़ाइल",
		"PROFILE_AVATAR": "अवतार",
		"PROFILE_FRAME": "फ़्रेम",
		"PROFILE_NAME_LABEL": "खिलाड़ी का नाम",
		"BTN_SAVE_PROFILE": "प्रोफ़ाइल सहेजें",
		"STREAK_TITLE": "दैनिक स्ट्रीक",
		"STREAK_SUBTITLE": "शांत एकाग्रता, बहुत बढ़िया खेल!",
		"STREAK_CLAIM_BTN": "पुरस्कार प्राप्त करें",
		"STREAK_CLAIMED_BTN": "आज प्राप्त किया ✓",
		"STREAK_CHEST_REWARD": "दिन 7 भव्य पुरस्कार: +5 संकेत और स्वर्ण संदूक!",
		"STREAK_DAILY_REWARD": "दैनिक पुरस्कार: +2 बोनस संकेत!",
		"VIC_TOPPED_PLAYERS": "आपने %s खिलाड़ियों को पीछे छोड़ दिया!",
		"VIC_CHEST_UNLOCK": "मील का पत्थर संदूक: स्तर %d (%d/%d)",
		"VIC_CHEST_READY": "मील का पत्थर संदूक खुला! +3 संकेत",
		"SETTINGS_EDIT_PROFILE": "प्रोफ़ाइल संपादित करें",
		"SETTINGS_AUDIO_HAPTICS": "ऑडियो और कंपन"
	}
}

func _init() -> void:
	_init_language()

func _ready() -> void:
	_init_language()

func _init_language() -> void:
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root and tree.root.has_node("SaveManager"):
		var sm = tree.root.get_node("SaveManager")
		var saved_lang = sm.get_setting("language", "")
		if saved_lang != "" and is_language_supported(saved_lang):
			current_language = saved_lang
		else:
			# Auto detect system locale if available
			var sys_locale = OS.get_locale_language()
			if is_language_supported(sys_locale):
				current_language = sys_locale
			else:
				current_language = "en"
	TranslationServer.set_locale(current_language)

func is_language_supported(lang_code: String) -> bool:
	for lang in SUPPORTED_LANGUAGES:
		if lang["code"] == lang_code:
			return true
	return false

func get_available_languages() -> Array[Dictionary]:
	return SUPPORTED_LANGUAGES

func get_current_language() -> String:
	return current_language

func set_language(lang_code: String) -> void:
	if not is_language_supported(lang_code):
		push_warning("Language %s not supported, defaulting to en" % lang_code)
		lang_code = "en"
	
	if current_language == lang_code:
		return
		
	current_language = lang_code
	TranslationServer.set_locale(lang_code)
	
	var tree = Engine.get_main_loop() as SceneTree
	if tree and tree.root and tree.root.has_node("SaveManager"):
		var sm = tree.root.get_node("SaveManager")
		sm.set_setting("language", lang_code)
		
	language_changed.emit(current_language)

func get_text(key: String, default_text: String = "") -> String:
	var lang_dict = STRINGS.get(current_language, STRINGS["en"])
	if lang_dict.has(key):
		return lang_dict[key]
	# Fallback to English
	if STRINGS["en"].has(key):
		return STRINGS["en"][key]
	return default_text if default_text != "" else key

func format_text(key: String, args: Array) -> String:
	var pattern = get_text(key)
	match args.size():
		1: return pattern % args[0]
		2: return pattern % [args[0], args[1]]
		3: return pattern % [args[0], args[1], args[2]]
		_: return pattern
