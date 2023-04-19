
if (GetLocale() ~= "zhCN") then
	return;
end
-- @EXACT = true: Translation has to be the exact(!) match in the clients language,
--                beacause it carries technical semantics
-- @EXACT = false: Translation can be done freely, because text is only descriptive


-- Class Names
-- @EXACT = false
VUHDO_I18N_WARRIORS="战士"
VUHDO_I18N_ROGUES = "盗贼";
VUHDO_I18N_HUNTERS = "猎人";
VUHDO_I18N_PALADINS = "圣骑士";
VUHDO_I18N_MAGES = "法师";
VUHDO_I18N_WARLOCKS = "术士";
VUHDO_I18N_SHAMANS = "萨满";
VUHDO_I18N_DRUIDS = "德鲁伊";
VUHDO_I18N_PRIESTS = "牧师";
VUHDO_I18N_DEATH_KNIGHT = "死亡骑士";


-- Group Model Names
-- @EXACT = false
VUHDO_I18N_GROUP = "队伍";
VUHDO_I18N_OWN_GROUP = "我的队伍";


-- Special Model Names
-- @EXACT = false
VUHDO_I18N_PETS = "宠物";
VUHDO_I18N_MAINTANKS = "主坦克";
VUHDO_I18N_PRIVATE_TANKS = "辅助坦克";



-- General Labels
-- @EXACT = false
VUHDO_I18N_OKAY = "确定";
VUHDO_I18N_CLASS = "职业";
VUHDO_I18N_UNDEFINED = "未定义";
VUHDO_I18N_PLAYER = "玩家";


-- VuhDoTooltip.lua
-- @EXACT = false
VUHDO_I18N_TT_POSITION = "|cffffb233位置:|r";
VUHDO_I18N_TT_GHOST = "<鬼魂>";
VUHDO_I18N_TT_DEAD = "<死亡>";
VUHDO_I18N_TT_AFK = "<暂离>";
VUHDO_I18N_TT_DND = "<勿扰>";
VUHDO_I18N_TT_LIFE = "|cffffb233生命值:|r ";
VUHDO_I18N_TT_MANA = "|cffffb233法力值:|r ";
VUHDO_I18N_TT_LEVEL = "等级";


-- VuhDoPanel.lua
-- @EXACT = false
VUHDO_I18N_CHOOSE = "选择";
VUHDO_I18N_DRAG = "拖动";
VUHDO_I18N_REMOVE = "移除";
VUHDO_I18N_ME = "自己";
VUHDO_I18N_TYPE = "类型";
VUHDO_I18N_VALUE = "数值";
VUHDO_I18N_SPECIAL = "附加";
VUHDO_I18N_BUFF_ALL = "全部";
VUHDO_I18N_SHOW_BUFF_WATCH = "显示增益监视";


-- @EXACT = true
--
VUHDO_I18N_RANK = "等级";


-- Chat messages
-- @EXACT = false
VUHDO_I18N_COMMAND_LIST = "\n|cffffe566 - [ VuhDo commands ] -|r";
VUHDO_I18N_COMMAND_LIST = VUHDO_I18N_COMMAND_LIST .. "§|cffffe566opt|r[ions] - VuhDo 选项";
VUHDO_I18N_COMMAND_LIST = VUHDO_I18N_COMMAND_LIST .. "§|cffffe566res|r[et] - 重置面板位置";
VUHDO_I18N_COMMAND_LIST = VUHDO_I18N_COMMAND_LIST .. "§|cffffe566lock|r - 切换面板锁定";
VUHDO_I18N_COMMAND_LIST = VUHDO_I18N_COMMAND_LIST .. "§|cffffe566mm, map, minimap|r - 小地图按钮切换";
VUHDO_I18N_COMMAND_LIST = VUHDO_I18N_COMMAND_LIST .. "§|cffffe566show, hide, toggle|r - 框体显示开/关";
VUHDO_I18N_COMMAND_LIST = VUHDO_I18N_COMMAND_LIST .. "§|cffffe566load|r - [皮肤],[布局],[配置]";
VUHDO_I18N_COMMAND_LIST = VUHDO_I18N_COMMAND_LIST .. "§[broad]|cffffe566cast, mt|r[s] - 主坦克同步";
VUHDO_I18N_COMMAND_LIST = VUHDO_I18N_COMMAND_LIST .. "§|cffffe566role|r - 重置玩家职责";
VUHDO_I18N_COMMAND_LIST = VUHDO_I18N_COMMAND_LIST .. "§|cffffe566aegis x|r - Set Divine Aegis detection sensivity";
VUHDO_I18N_COMMAND_LIST = VUHDO_I18N_COMMAND_LIST .. "§|cffffe566help,?|r - 显示该命令列表\n";

VUHDO_I18N_BAD_COMMAND = "输入'/vuhdo help' 或 '/vd ?' 查看命令列表.";
VUHDO_I18N_CHAT_SHOWN = "|cffffe566显示|r.";
VUHDO_I18N_CHAT_HIDDEN = "|cffffe566隐藏|r.";
VUHDO_I18N_MM_ICON = "小地图按钮 ";
VUHDO_I18N_MTS_BROADCASTED = "主坦克设置已发送";
VUHDO_I18N_PANELS_SHOWN = "治疗面板已 |cffffe566开启|r.";
VUHDO_I18N_PANELS_HIDDEN = "治疗面板已 |cffffe566隐藏|r.";
VUHDO_I18N_LOCK_PANELS_PRE = "面板位置已经 ";
VUHDO_I18N_LOCK_PANELS_LOCKED = "|cffffe566锁定|r.";
VUHDO_I18N_LOCK_PANELS_UNLOCKED = "|cffffe566解锁|r.";
VUHDO_I18N_PANELS_RESET = "面板位置已重置.";


-- Config Pop-Up
-- @EXACT = false
VUHDO_I18N_ROLE = "职责";
VUHDO_I18N_PRIVATE_TANK = "辅助坦克";
VUHDO_I18N_SET_BUFF = "设置增益";


-- Minimap
-- @EXACT = false
VUHDO_I18N_VUHDO_OPTIONS = "VuhDo 选项";
VUHDO_I18N_PANEL_SETUP = "选项";
VUHDO_I18N_MM_TOOLTIP = "左: 面板设置\n右: 菜单";
VUHDO_I18N_TOGGLES = "切换";
VUHDO_I18N_LOCK_PANELS = "锁定面板";
VUHDO_I18N_SHOW_PANELS = "显示面板";
VUHDO_I18N_MM_BUTTON = "小地图按钮";
VUHDO_I18N_CLOSE = "关闭";
VUHDO_I18N_BROADCAST_MTS = "主坦克同步";



-- Buff categories
-- @EXACT = false
-- Priest
VUHDO_I18N_BUFFC_FORTITUDE = "01真言术：韧";
VUHDO_I18N_BUFFC_SPIRIT = "02精神";
VUHDO_I18N_BUFFC_SHADOW_PROTECTION = "03暗影防护";

-- Shaman
VUHDO_I18N_BUFFC_FIRE_TOTEM = "01火焰图腾";
VUHDO_I18N_BUFFC_AIR_TOTEM = "02风之图腾";
VUHDO_I18N_BUFFC_EARTH_TOTEM = "03大地图腾";
VUHDO_I18N_BUFFC_WATER_TOTEM = "04水之图腾";
VUHDO_I18N_BUFFC_WEAPON_ENCHANT = "08武器附魔";
VUHDO_I18N_BUFFC_WEAPON_ENCHANT_2 = "13武器附魔 2";
VUHDO_I18N_BUFFC_SHIELDS = "09盾";

-- Paladin
VUHDO_I18N_BUFFC_BLESSING = "01祝福";
VUHDO_I18N_BUFFC_AURA = "02光环";
VUHDO_I18N_BUFFC_SEAL = "03圣印";

-- Druids

-- Warlock
VUHDO_I18N_BUFFC_SKIN = "01皮肤";

-- Mage
VUHDO_I18N_BUFFC_ARMOR_MAGE = "03护甲";

-- Death Knight
VUHDO_SPELL_ID_BUFFC_PRESENCE    = "03Presence";

-- Warrior
VUHDO_I18N_BUFFC_SHOUT = "01怒吼";

-- Hunter
VUHDO_I18N_BUFFC_ASPECT = "02Aspect";

-- Key Binding Headers/Names
-- @EXACT = false
BINDING_HEADER_VUHDO_TITLE = "VuhDo - 团队框体";
BINDING_NAME_VUHDO_KEY_ASSIGN_1 = "鼠标滑过技能 1";
BINDING_NAME_VUHDO_KEY_ASSIGN_2 = "鼠标滑过技能 2";
BINDING_NAME_VUHDO_KEY_ASSIGN_3 = "鼠标滑过技能 3";
BINDING_NAME_VUHDO_KEY_ASSIGN_4 = "鼠标滑过技能 4";
BINDING_NAME_VUHDO_KEY_ASSIGN_5 = "鼠标滑过技能 5";
BINDING_NAME_VUHDO_KEY_ASSIGN_6 = "鼠标滑过技能 6";
BINDING_NAME_VUHDO_KEY_ASSIGN_7 = "鼠标滑过技能 7";
BINDING_NAME_VUHDO_KEY_ASSIGN_8 = "鼠标滑过技能 8";
BINDING_NAME_VUHDO_KEY_ASSIGN_9 = "鼠标滑过技能 9";
BINDING_NAME_VUHDO_KEY_ASSIGN_10 = "鼠标滑过技能 10";
BINDING_NAME_VUHDO_KEY_ASSIGN_11 = "鼠标滑过技能 11";
BINDING_NAME_VUHDO_KEY_ASSIGN_12 = "鼠标滑过技能 12";
BINDING_NAME_VUHDO_KEY_ASSIGN_13 = "鼠标滑过技能 13";
BINDING_NAME_VUHDO_KEY_ASSIGN_14 = "鼠标滑过技能 14";
BINDING_NAME_VUHDO_KEY_ASSIGN_15 = "鼠标滑过技能 15";
BINDING_NAME_VUHDO_KEY_ASSIGN_16 = "鼠标滑过技能 16";

BINDING_NAME_VUHDO_KEY_ASSIGN_SMART_BUFF = "智能 Buff";

VUHDO_I18N_MOUSE_OVER_BINDING = "按键施法";
VUHDO_I18N_UNASSIGNED = "(未指定)";


-- #+V1.89
VUHDO_I18N_YES = "Yes";
VUHDO_I18N_NO = "No";
VUHDO_I18N_UP = "上";
VUHDO_I18N_DOWN = "下";
VUHDO_I18N_VEHICLES = "载具";


-- #+v1.94
VUHDO_I18N_DEFAULT_RES_ANNOUNCE = "复活吧, 我的勇士!";

-- #v+1.151
VUHDO_I18N_MAIN_ASSISTS = "协助坦克";

--VUHDO_OPTIONS_FONT_NAME = "Interface\\AddOns\\VuhDo\\Fonts\\ariblk.ttf";
VUHDO_OPTIONS_FONT_NAME = GameFontNormal:GetFont();

-- #v+1.169

VUHDO_I18N_O_REALLY = "O'确定嘛?";


-- #+v1.184
VUHDO_I18N_BW_CD = "冷却";
VUHDO_I18N_BW_GO = "GO!";
VUHDO_I18N_BW_LOW = "LOW";
VUHDO_I18N_BW_N_A = "|cffff0000N/A|r";
VUHDO_I18N_BW_RNG_RED = "|cffff0000RNG|r";
VUHDO_I18N_BW_OK = "OK";
VUHDO_I18N_BW_RNG_YELLOW = "|cffffff00RNG|r";

VUHDO_I18N_PROMOTE_RAID_LEADER = "提升为团队领袖";
VUHDO_I18N_PROMOTE_ASSISTANT = "提升为团队助理";
VUHDO_I18N_DEMOTE_ASSISTANT = "取消团队助理职务";
VUHDO_I18N_PROMOTE_MASTER_LOOTER = "提升为团队拾取";
VUHDO_I18N_MT_NUMBER = "主坦克 #";
VUHDO_I18N_ROLE_OVERRIDE = "Role override";
VUHDO_I18N_MELEE_TANK = "近战 - 坦克";
VUHDO_I18N_MELEE_DPS = "近战 - 伤害输出";
VUHDO_I18N_RANGED_DPS = "远程 - 伤害输出";
VUHDO_I18N_RANGED_HEALERS = "远程 - 治疗";
VUHDO_I18N_AUTO_DETECT = "<自动侦测>";
VUHDO_I18N_PROMOTE_ASSIST_MSG_1 = "提升 |cffffe566";
VUHDO_I18N_PROMOTE_ASSIST_MSG_2 = "|r 为助理.";
VUHDO_I18N_DEMOTE_ASSIST_MSG_1 = "解除 |cffffe566";
VUHDO_I18N_DEMOTE_ASSIST_MSG_2 = "|r 助理职务.";
VUHDO_I18N_RESET_ROLES = "重置职责";
VUHDO_I18N_LOAD_KEY_SETUP = "读取按键设置";
VUHDO_I18N_BUFF_ASSIGN_1 = "增益 |cffffe566";
VUHDO_I18N_BUFF_ASSIGN_2 = "|r 被指定为 |cffffe566";
VUHDO_I18N_BUFF_ASSIGN_3 = "|r";
VUHDO_I18N_RESS_ERR_1 = "无法复活, ";
VUHDO_I18N_RESS_ERR_2 = " 已释放灵魂.";
VUHDO_I18N_MACRO_KEY_ERR_1 = "错误: 键盘鼠标滑过宏字符过多: ";
VUHDO_I18N_MACRO_KEY_ERR_2 = "/256 字符). 尝试减少自动施放选项!!!";
VUHDO_I18N_MACRO_NUM_ERR = "角色最大宏数量溢出! 无法创建鼠标滑过宏: ";
VUHDO_I18N_SMARTBUFF_ERR_1 = "VuhDo: 智能BUFF功能无法在战斗中使用!";
VUHDO_I18N_SMARTBUFF_ERR_2 = "VuhDo: 无有效BUFF目标 ";
VUHDO_I18N_SMARTBUFF_ERR_3 = " 超出距离 ";
VUHDO_I18N_SMARTBUFF_ERR_4 = "VuhDo: 无BUFF可施放.";
VUHDO_I18N_SMARTBUFF_OKAY_1 = "VuhDo: 正在施放增益 |cffffffff";
VUHDO_I18N_SMARTBUFF_OKAY_2 = "|r 开启 ";
VUHDO_I18N_SET_BUFF_TARGET_1 = "指定增益目标 ";
VUHDO_I18N_SET_BUFF_TARGET_2 = " 为 ";


-- #+v1.189
VUHDO_I18N_UNKNOWN = "未知";
VUHDO_I18N_SELF = "自己";
VUHDO_I18N_MELEES = "近战";
VUHDO_I18N_RANGED = "远程";
VUHDO_I18N_OPTIONS_NOT_LOADED = ">>> VuhDo 选项插件未开启! <<<";
VUHDO_I18N_SPELL_LAYOUT_NOT_EXIST_1 = "错误: 法术布局 \"";
VUHDO_I18N_SPELL_LAYOUT_NOT_EXIST_2 = "\" 不存在.";
VUHDO_I18N_AUTO_ARRANG_1 = "队伍成员人数变更为：";
VUHDO_I18N_AUTO_ARRANG_2 = ". 自动启用布局: \"";

-- #+1.209
VUHDO_I18N_OWN_GROUP_LONG = "Own Group";
VUHDO_I18N_TRACK_BUFFS_FOR = "Track buff for ...";
VUHDO_I18N_NO_FOCUS = "[no focus]";
VUHDO_I18N_NOT_AVAILABLE = "[ N/A ]";
VUHDO_I18N_SHIELD_ABSORPTION = "Shield Status";


-- #+1.237
VUHDO_I18N_TT_DISTANCE = "|cffffb233Distance:|r";
VUHDO_I18N_TT_OF = " of ";
VUHDO_I18N_YARDS = "yards";


-- #+1.252
VUHDO_I18N_PANEL = "Panel";

VUHDO_I18N_BOUQUET_AGGRO = "Flag: Aggro";
VUHDO_I18N_BOUQUET_OUT_OF_RANGE = "Flag: Range, out of";
VUHDO_I18N_BOUQUET_IN_RANGE = "Flag: Range, in";
VUHDO_I18N_BOUQUET_IN_YARDS = "Flag: Distance < yards";
VUHDO_I18N_BOUQUET_OTHER_HOTS = "Flag: Other Player's HoTs";
VUHDO_I18N_BOUQUET_DEBUFF_DISPELLABLE = "Flag: Debuff, Dispellable";
VUHDO_I18N_BOUQUET_DEBUFF_MAGIC = "Flag: Debuff Magic";
VUHDO_I18N_BOUQUET_DEBUFF_DISEASE = "Flag: Debuff Disease";
VUHDO_I18N_BOUQUET_DEBUFF_POISON = "Flag: Debuff Poison";
VUHDO_I18N_BOUQUET_DEBUFF_CURSE = "Flag: Debuff Curse";
VUHDO_I18N_BOUQUET_CHARMED = "Flag: Charmed";
VUHDO_I18N_BOUQUET_DEAD = "Flag: Dead";
VUHDO_I18N_BOUQUET_DISCONNECTED = "Flag: Disconnected";
VUHDO_I18N_BOUQUET_AFK = "Flag: AFK";
VUHDO_I18N_BOUQUET_PLAYER_TARGET = "Flag: Player Target";
VUHDO_I18N_BOUQUET_MOUSEOVER_TARGET = "Flag: Mouseover Single";
VUHDO_I18N_BOUQUET_MOUSEOVER_GROUP = "Flag: Mouseover Group";
VUHDO_I18N_BOUQUET_HEALTH_BELOW = "Flag: Health < %";
VUHDO_I18N_BOUQUET_MANA_BELOW = "Flag: Mana < %";
VUHDO_I18N_BOUQUET_THREAT_ABOVE = "Flag: Threat > %";
VUHDO_I18N_BOUQUET_NUM_IN_CLUSTER = "Flag: Cluster >= #players";
VUHDO_I18N_BOUQUET_CLASS_COLOR = "Flag: Always Class Color";
VUHDO_I18N_BOUQUET_ALWAYS = "Flag: Always Solid";
VUHDO_I18N_SWIFTMEND_POSSIBLE = "Flag: Swiftmend possible";
VUHDO_I18N_BOUQUET_MOUSEOVER_CLUSTER = "Flag: Cluster, Mouseover";
VUHDO_I18N_THREAT_LEVEL_MEDIUM = "Flag: Threat, High";
VUHDO_I18N_THREAT_LEVEL_HIGH = "Flag: Threat, Overnuke";
VUHDO_I18N_BOUQUET_STATUS_HEALTH = "Statusbar: Health %";
VUHDO_I18N_BOUQUET_STATUS_MANA = "Statusbar: Mana %";
VUHDO_I18N_BOUQUET_STATUS_OTHER_POWERS = "Statusbar: non-Mana %";
VUHDO_I18N_BOUQUET_STATUS_INCOMING = "Statusbar: Inc. Heals %";
VUHDO_I18N_BOUQUET_STATUS_THREAT = "Statusbar: Threat %";
VUHDO_I18N_BOUQUET_NEW_ITEM_NAME = "-- enter (de)buff here --";


VUHDO_I18N_DEF_BOUQUET_TANK_COOLDOWNS = "Tank Cooldowns";
VUHDO_I18N_DEF_BOUQUET_PW_S_WEAKENED_SOUL = "PW:S & Weakened Soul";
VUHDO_I18N_DEF_BOUQUET_BORDER_MULTI_AGGRO = "Border: Multi + Aggro";
VUHDO_I18N_DEF_BOUQUET_BORDER_MULTI = "Border: Multi";
VUHDO_I18N_DEF_BOUQUET_BORDER_SIMPLE = "Border: Simple";
VUHDO_I18N_DEF_BOUQUET_SWIFTMENDABLE = "Swiftmendable";
VUHDO_I18N_DEF_BOUQUET_MOUSEOVER_SINGLE = "Mouseover: Single";
VUHDO_I18N_DEF_BOUQUET_MOUSEOVER_MULTI = "Mouseover: Multi";
VUHDO_I18N_DEF_BOUQUET_AGGRO_INDICATOR = "Aggro Indicator";
VUHDO_I18N_DEF_BOUQUET_CLUSTER_MOUSE_HOVER = "Cluster: Mouse Hover";
VUHDO_I18N_DEF_BOUQUET_THREAT_MARKS = "Threat: Marks";
VUHDO_I18N_DEF_BOUQUET_BAR_MANA_ALL = "Manabars: All Powers";
VUHDO_I18N_DEF_BOUQUET_BAR_MANA_ONLY = "Manabars: Mana only";
VUHDO_I18N_DEF_BOUQUET_BAR_THREAT = "Threat: Status Bar";


VUHDO_I18N_CUSTOM_ICON_NONE = "- None / Default -";
VUHDO_I18N_CUSTOM_ICON_GLOSSY = "Glossy";
VUHDO_I18N_CUSTOM_ICON_MOSAIC = "Mosaic";
VUHDO_I18N_CUSTOM_ICON_CLUSTER = "Cluster";
VUHDO_I18N_CUSTOM_ICON_FLAT = "Flat";
VUHDO_I18N_CUSTOM_ICON_SPOT = "Spot";
VUHDO_I18N_CUSTOM_ICON_CIRCLE = "Circle";
VUHDO_I18N_CUSTOM_ICON_SKETCHED = "Sketched";
VUHDO_I18N_CUSTOM_ICON_RHOMB = "Rhomb";


VUHDO_I18N_OUTER_BORDER = "Outer";
VUHDO_I18N_INNER_BORDER = "Inner";
VUHDO_I18N_SWIFTMEND_INDICATOR = "Special Dot";
VUHDO_I18N_MOUSEOVER_HIGHLIGHTER = "Mouseover";
VUHDO_I18N_THREAT_MARKS = "Threat Marks";
VUHDO_I18N_THREAT_BAR = "Threat Bar";
VUHDO_I18N_AGGRO_LINE = "Aggro Line";
VUHDO_I18N_MANA_BAR = "Mana Bar";
VUHDO_I18N_BORDER_WIDTH = "Width";

VUHDO_I18N_ERROR_NO_PROFILE = "Error: No profile named: ";
VUHDO_I18N_PROFILE_LOADED = "Profile successfully loaded: ";
VUHDO_I18N_PROFILE_SAVED = "Successfully saved profile: ";
VUHDO_I18N_PROFILE_OVERWRITE_1 = "Profile";
VUHDO_I18N_PROFILE_OVERWRITE_2 = "is currently owned by\nanother toon";
VUHDO_I18N_PROFILE_OVERWRITE_3 = "\n- Overwrite: Existing profile will be overwritten.\n- Copy: Create and save a copy. Keep existing profile.";
VUHDO_I18N_COPY = "Copy";
VUHDO_I18N_OVERWRITE = "Overwrite";
VUHDO_I18N_DISCARD = "Discard";

-- 2.0, alpha #2
VUHDO_I18N_DEF_BAR_BACKGROUND_SOLID = "Background: Solid";
VUHDO_I18N_DEF_BAR_BACKGROUND_CLASS_COLOR = "Background: Class Color";

-- 2.0 alpha #9
VUHDO_I18N_BOUQUET_DEBUFF_BAR_COLOR = "Flag: Debuff, configured";
VUHDO_I18N_BACKGROUND_BAR = "Bar Background";

-- 2.0 alpha #11
VUHDO_I18N_HEALTH_BAR = "Health Bar";
VUHDO_I18N_DEF_BOUQUET_BAR_HEALTH = "Health Bar: (auto)";
VUHDO_I18N_UPDATE_RAID_TARGET = "Flag: Raid target color";
VUHDO_I18N_BOUQUET_OVERHEAL_HIGHLIGHT = "Color: Overheal Highlighter";
VUHDO_I18N_BOUQUET_EMERGENCY_COLOR = "Color: Emergency";
VUHDO_I18N_BOUQUET_HEALTH_ABOVE = "Flag: Health > %";
VUHDO_I18N_BOUQUET_RESURRECTION = "Flag: Resurrection";
VUHDO_I18N_BOUQUET_STACKS_COLOR = "Color: #Stacks";

-- 2.1
VUHDO_I18N_DEF_BOUQUET_BAR_HEALTH_SOLID = "Health: (generic, solid)";
VUHDO_I18N_DEF_BOUQUET_BAR_HEALTH_CLASS_COLOR = "Health: (generic, class col)";

-- 2.9
VUHDO_I18N_NO_TARGET = "[no target]";
VUHDO_I18N_TT_LEFT = " Left: ";
VUHDO_I18N_TT_RIGHT = " Right: ";
VUHDO_I18N_TT_MIDDLE = " Middle: ";
VUHDO_I18N_TT_BTN_4 = " Button 4: ";
VUHDO_I18N_TT_BTN_5 = " Button 5: ";
VUHDO_I18N_TT_WHEEL_UP = " Wheel up: ";
VUHDO_I18N_TT_WHEEL_DOWN = " Wheel down: ";


-- 2.13
VUHDO_I18N_BOUQUET_CLASS_ICON = "Icon: Class";
VUHDO_I18N_BOUQUET_RAID_ICON = "Icon: Raid target";
VUHDO_I18N_BOUQUET_ROLE_ICON = "Icon: Role";

-- 2.18
VUHDO_I18N_LOAD_PROFILE = "Load Profile";

-- 2.20
VUHDO_I18N_DC_SHIELD_NO_MACROS = "No free macro slots for this toon... d/c shield temporarily disabled.";
VUHDO_I18N_BROKER_TOOLTIP_1 = "|cffffff00Left Click|r to show options menu";
VUHDO_I18N_BROKER_TOOLTIP_2 = "|cffffff00Right Click|r to show popup menu";
