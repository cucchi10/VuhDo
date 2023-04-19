if (GetLocale() ~= "ruRU") then
	return;
end
-- Class Names
-- @EXACT = false
VUHDO_I18N_WARRIORS="Войны"
VUHDO_I18N_ROGUES = "Разбойники";
VUHDO_I18N_HUNTERS = "Охотники";
VUHDO_I18N_PALADINS = "Паладины";
VUHDO_I18N_MAGES = "Маги";
VUHDO_I18N_WARLOCKS = "Чернокнижники";
VUHDO_I18N_SHAMANS = "Шаманы";
VUHDO_I18N_DRUIDS = "Друиды";
VUHDO_I18N_PRIESTS = "Жреци";
VUHDO_I18N_DEATH_KNIGHT = "Рыцари Смерти";


-- Group Model Names
-- @EXACT = false
VUHDO_I18N_GROUP = "Группа";
VUHDO_I18N_OWN_GROUP = "Ваша группа";


-- Special Model Names
-- @EXACT = false
VUHDO_I18N_PETS = "Питомцы";
VUHDO_I18N_MAINTANKS = "Глав. танки";
VUHDO_I18N_PRIVATE_TANKS = "Лич. танки";



-- General Labels
-- @EXACT = false
VUHDO_I18N_OKAY = "ОК";
VUHDO_I18N_CLASS = "Класс";
VUHDO_I18N_UNDEFINED = "<n/a>";
VUHDO_I18N_PLAYER = "Игрок";


-- VuhDoTooltip.lua
-- @EXACT = false
VUHDO_I18N_TT_POSITION = "|cffffb233Позиция:|r";
VUHDO_I18N_TT_GHOST = "<ПРИЗРАК>";
VUHDO_I18N_TT_DEAD = "<МЁРТВ>";
VUHDO_I18N_TT_AFK = "<AFK>";
VUHDO_I18N_TT_DND = "<DND>";
VUHDO_I18N_TT_LIFE = "|cffffb233Здоровье:|r ";
VUHDO_I18N_TT_MANA = "|cffffb233Мана:|r ";
VUHDO_I18N_TT_LEVEL = "Уровень ";


-- VuhDoPanel.lua
-- @EXACT = false
VUHDO_I18N_CHOOSE = "Выбрать";
VUHDO_I18N_DRAG = "Тащить";
VUHDO_I18N_REMOVE = "Удалить";
VUHDO_I18N_ME = "me!";
VUHDO_I18N_TYPE = "Тип";
VUHDO_I18N_VALUE = "Значение";
VUHDO_I18N_SPECIAL = "Особый";
VUHDO_I18N_BUFF_ALL = "все";
VUHDO_I18N_SHOW_BUFF_WATCH = "Наблюдение баффов";

-- @EXACT = true
--
VUHDO_I18N_RANK = "Уровень";


-- Chat messages
-- @EXACT = false
VUHDO_I18N_COMMAND_LIST = "\n|cffffe566 - [ Команды VuhDo ] -|r";
VUHDO_I18N_COMMAND_LIST = VUHDO_I18N_COMMAND_LIST .. "§|cffffe566opt|r[ions] - настройки VuhDo";
VUHDO_I18N_COMMAND_LIST = VUHDO_I18N_COMMAND_LIST .. "§|cffffe566res|r[et] - сбросить позицию панелей";
VUHDO_I18N_COMMAND_LIST = VUHDO_I18N_COMMAND_LIST .. "§|cffffe566lock|r - вкл/выкл закрепление панелей";
VUHDO_I18N_COMMAND_LIST = VUHDO_I18N_COMMAND_LIST .. "§|cffffe566mm, map, minimap|r - вкл/выкл иконку у миникарты";
VUHDO_I18N_COMMAND_LIST = VUHDO_I18N_COMMAND_LIST .. "§|cffffe566show, hide, toggle|r - включить/выключить панели";
VUHDO_I18N_COMMAND_LIST = VUHDO_I18N_COMMAND_LIST .. "§|cffffe566load|r - [Skin],[Arrangement],[Key Layout]";
VUHDO_I18N_COMMAND_LIST = VUHDO_I18N_COMMAND_LIST .. "§[broad]|cffffe566cast, mt|r[s] - передать список основных танков рейду";
VUHDO_I18N_COMMAND_LIST = VUHDO_I18N_COMMAND_LIST .. "§|cffffe566role|r - сбросить роли игроков";
VUHDO_I18N_COMMAND_LIST = VUHDO_I18N_COMMAND_LIST .. "§|cffffe566aegis x|r - Set Divine Aegis detection sensivity";
VUHDO_I18N_COMMAND_LIST = VUHDO_I18N_COMMAND_LIST .. "§|cffffe566help,?|r - список данных команд\n";

VUHDO_I18N_BAD_COMMAND = "Плохой аргумент! Введите '/vuhdo help' или '/vd ?' для получения списка команд.";
VUHDO_I18N_CHAT_SHOWN = "|cffffe566shown|r.";
VUHDO_I18N_CHAT_HIDDEN = "|cffffe566hidden|r.";
VUHDO_I18N_MM_ICON = "Иконка у миникарты: ";
VUHDO_I18N_MTS_BROADCASTED = "Основные танки переданы в рейд";
VUHDO_I18N_PANELS_SHOWN = "Панель исцеления: |cffffe566shown|r.";
VUHDO_I18N_PANELS_HIDDEN = "Панель исцеления: |cffffe566hidden|r.";
VUHDO_I18N_LOCK_PANELS_PRE = "Позиция панели: ";
VUHDO_I18N_LOCK_PANELS_LOCKED = "|cffffe566locked|r.";
VUHDO_I18N_LOCK_PANELS_UNLOCKED = "|cffffe566unlocked|r.";
VUHDO_I18N_PANELS_RESET = "Позиция панели сброшена.";


-- Config Pop-Up
-- @EXACT = false
VUHDO_I18N_ROLE = "Роль";
VUHDO_I18N_PRIVATE_TANK = "Личный танк";
VUHDO_I18N_SET_BUFF = "Назначте баф";


-- Minimap
-- @EXACT = false
VUHDO_I18N_VUHDO_OPTIONS = "Настройки VuhDo";
VUHDO_I18N_PANEL_SETUP = "Настройки";
VUHDO_I18N_MM_TOOLTIP = "ЛКМ: Настройки панели\nПКМ: Меню";
VUHDO_I18N_TOGGLES = "Toggles";
VUHDO_I18N_LOCK_PANELS = "Закрепить панель";
VUHDO_I18N_SHOW_PANELS = "Показать панели";
VUHDO_I18N_MM_BUTTON = "Кнопка у мини-карты";
VUHDO_I18N_CLOSE = "Закрыть";
VUHDO_I18N_BROADCAST_MTS = "Передать ГТ";


-- Buff categories
-- @EXACT = false
-- Priest
VUHDO_I18N_BUFFC_FORTITUDE = "01Стойкость";
VUHDO_I18N_BUFFC_SPIRIT = "02Дух";
VUHDO_I18N_BUFFC_SHADOW_PROTECTION = "03Защита от темной магии";

-- Shaman
VUHDO_I18N_BUFFC_FIRE_TOTEM = "01Тотем огня";
VUHDO_I18N_BUFFC_AIR_TOTEM = "02Тотем воздуха";
VUHDO_I18N_BUFFC_EARTH_TOTEM = "03Тотем земли";
VUHDO_I18N_BUFFC_WATER_TOTEM = "04Тотем воды";
VUHDO_I18N_BUFFC_WEAPON_ENCHANT = "08Зачарование оружия";
VUHDO_I18N_BUFFC_WEAPON_ENCHANT_2 = "13Зачарование оружия 2";
VUHDO_I18N_BUFFC_SHIELDS = "09Щиты";

-- Paladin
VUHDO_I18N_BUFFC_BLESSING = "01Благословение";
VUHDO_I18N_BUFFC_AURA = "02Аура";
VUHDO_I18N_BUFFC_SEAL = "03Печать";

-- Druids

-- Warlock
VUHDO_I18N_BUFFC_SKIN = "01Шкура";

-- Mage
VUHDO_I18N_BUFFC_ARMOR_MAGE = "03доспех";

-- Death Knight
VUHDO_SPELL_ID_BUFFC_PRESENCE    = "03Власть";

-- Warrior
VUHDO_I18N_BUFFC_SHOUT = "01крик";

-- Hunter
VUHDO_I18N_BUFFC_ASPECT = "02Дух";


-- Key Binding Headers/Names
-- @EXACT = false
BINDING_HEADER_VUHDO_TITLE = "VuhDo - рамки рейда";
BINDING_NAME_VUHDO_KEY_ASSIGN_1 = "Mouse over Spell 1";
BINDING_NAME_VUHDO_KEY_ASSIGN_2 = "Mouse over Spell 2";
BINDING_NAME_VUHDO_KEY_ASSIGN_3 = "Mouse over Spell 3";
BINDING_NAME_VUHDO_KEY_ASSIGN_4 = "Mouse over Spell 4";
BINDING_NAME_VUHDO_KEY_ASSIGN_5 = "Mouse over Spell 5";
BINDING_NAME_VUHDO_KEY_ASSIGN_6 = "Mouse over Spell 6";
BINDING_NAME_VUHDO_KEY_ASSIGN_7 = "Mouse over Spell 7";
BINDING_NAME_VUHDO_KEY_ASSIGN_8 = "Mouse over Spell 8";
BINDING_NAME_VUHDO_KEY_ASSIGN_9 = "Mouse over Spell 9";
BINDING_NAME_VUHDO_KEY_ASSIGN_10 = "Mouse over Spell 10";
BINDING_NAME_VUHDO_KEY_ASSIGN_11 = "Mouse over Spell 11";
BINDING_NAME_VUHDO_KEY_ASSIGN_12 = "Mouse over Spell 12";
BINDING_NAME_VUHDO_KEY_ASSIGN_13 = "Mouse over Spell 13";
BINDING_NAME_VUHDO_KEY_ASSIGN_14 = "Mouse over Spell 14";
BINDING_NAME_VUHDO_KEY_ASSIGN_15 = "Mouse over Spell 15";
BINDING_NAME_VUHDO_KEY_ASSIGN_16 = "Mouse over Spell 16";

BINDING_NAME_VUHDO_KEY_ASSIGN_SMART_BUFF = "Быстрый Бафф";

VUHDO_I18N_MOUSE_OVER_BINDING = "Keyboard spell";
VUHDO_I18N_UNASSIGNED = "(unassigned)";


-- #+V1.89
VUHDO_I18N_YES = "Да";
VUHDO_I18N_NO = "Нет";
VUHDO_I18N_UP = "вверх";
VUHDO_I18N_DOWN = "вниз";
VUHDO_I18N_VEHICLES = "Транспорт";


-- #+v1.94
VUHDO_I18N_DEFAULT_RES_ANNOUNCE = "Вернись к жизни, прошу тебя!";

-- #v+1.151
VUHDO_I18N_MAIN_ASSISTS = "Наводчик";

-- #v+1.169
VUHDO_I18N_O_REALLY = "Точно?";


-- #+v1.184
VUHDO_I18N_BW_CD = "CD";
VUHDO_I18N_BW_GO = "GO!";
VUHDO_I18N_BW_LOW = "LOW";
VUHDO_I18N_BW_N_A = "|cffff0000N/A|r";
VUHDO_I18N_BW_RNG_RED = "|cffff0000RNG|r";
VUHDO_I18N_BW_OK = "OK";
VUHDO_I18N_BW_RNG_YELLOW = "|cffffff00RNG|r";

VUHDO_I18N_PROMOTE_RAID_LEADER = "Назначить лидером рейда";
VUHDO_I18N_PROMOTE_ASSISTANT = "Назначить помощником";
VUHDO_I18N_DEMOTE_ASSISTANT = "Разжаловать из помощников";
VUHDO_I18N_PROMOTE_MASTER_LOOTER = "Назначить ответственным за добычу";
VUHDO_I18N_MT_NUMBER = "ГТ #";
VUHDO_I18N_ROLE_OVERRIDE = "Role override";
VUHDO_I18N_MELEE_TANK = "Ближний бой - Танк";
VUHDO_I18N_MELEE_DPS = "Ближний бой - DPS";
VUHDO_I18N_RANGED_DPS = "Дальний бой - DPS";
VUHDO_I18N_RANGED_HEALERS = "Дальний бой - Лекарь";
VUHDO_I18N_AUTO_DETECT = "<авто обнаруж.>";
VUHDO_I18N_PROMOTE_ASSIST_MSG_1 = "Произведён |cffffe566";
VUHDO_I18N_PROMOTE_ASSIST_MSG_2 = "|r в помощники.";
VUHDO_I18N_DEMOTE_ASSIST_MSG_1 = "Разжалует |cffffe566";
VUHDO_I18N_DEMOTE_ASSIST_MSG_2 = "|r из помощников.";
VUHDO_I18N_RESET_ROLES = "Сбросить роли";
VUHDO_I18N_LOAD_KEY_SETUP = "Загр.набор клавиш";
VUHDO_I18N_BUFF_ASSIGN_1 = "Бафф |cffffe566";
VUHDO_I18N_BUFF_ASSIGN_2 = "|r был назначен на |cffffe566";
VUHDO_I18N_BUFF_ASSIGN_3 = "|r";
VUHDO_I18N_RESS_ERR_1 = "Не может воскресить, ";
VUHDO_I18N_RESS_ERR_2 = " встал призраком.";
VUHDO_I18N_MACRO_KEY_ERR_1 = "ERROR: Keyboard mouse-over macro size exceeds limit for spell: ";
VUHDO_I18N_MACRO_KEY_ERR_2 = "/256 Characters). Try reducing auto fire options!!!";
VUHDO_I18N_MACRO_NUM_ERR = "Maximum number of macros per character exceeded! Can't create mouse over macro for: ";
VUHDO_I18N_SMARTBUFF_ERR_1 = "VuhDo: Unable to smart buff in combat!";
VUHDO_I18N_SMARTBUFF_ERR_2 = "VuhDo: No buff target available for ";
VUHDO_I18N_SMARTBUFF_ERR_3 = " players out of range for ";
VUHDO_I18N_SMARTBUFF_ERR_4 = "VuhDo: No buff to cast.";
VUHDO_I18N_SMARTBUFF_OKAY_1 = "VuhDo: Buffing |cffffffff";
VUHDO_I18N_SMARTBUFF_OKAY_2 = "|r on ";
VUHDO_I18N_SET_BUFF_TARGET_1 = "Setting buff target for ";
VUHDO_I18N_SET_BUFF_TARGET_2 = " to ";


-- #+v1.189
VUHDO_I18N_UNKNOWN = "неизвестно";
VUHDO_I18N_SELF = "Себя";
VUHDO_I18N_MELEES = "Ближний бой";
VUHDO_I18N_RANGED = "Дальний бой";

-- #+1.196
VUHDO_I18N_OPTIONS_NOT_LOADED = ">>> Модуль настроек VuhDo не загружен! <<<";
VUHDO_I18N_SPELL_LAYOUT_NOT_EXIST_1 = "Ошибка: Размещение заклинания \"";
VUHDO_I18N_SPELL_LAYOUT_NOT_EXIST_2 = "\" не существует.";
VUHDO_I18N_AUTO_ARRANG_1 = "Количество участников группы изменено на: ";
VUHDO_I18N_AUTO_ARRANG_2 = ". Auto-engaging arrangement: \"";

-- #+1.209
VUHDO_I18N_OWN_GROUP_LONG = "Свою группу";
VUHDO_I18N_TRACK_BUFFS_FOR = "Слежение баффа для ...";

VUHDO_I18N_NO_FOCUS = "[нет фокуса]";
VUHDO_I18N_NOT_AVAILABLE = "[ N/A ]";
VUHDO_I18N_SHIELD_ABSORPTION = "Статус щита";


-- #+1.237
VUHDO_I18N_TT_DISTANCE = "|cffffb233Расстояние:|r";
VUHDO_I18N_TT_OF = " - ";
VUHDO_I18N_YARDS = "метр(а/ов)";


-- #+1.252
VUHDO_I18N_PANEL = "Панель";

VUHDO_I18N_BOUQUET_AGGRO = "Пометка: Угроза";
VUHDO_I18N_BOUQUET_OUT_OF_RANGE = "Пометка: дальность, вне";
VUHDO_I18N_BOUQUET_IN_RANGE = "Пометка: дальность, в";
VUHDO_I18N_BOUQUET_IN_YARDS = "Пометка: Расстояние < метров";
VUHDO_I18N_BOUQUET_OTHER_HOTS = "Пометка: ХоТы других игроков";
VUHDO_I18N_BOUQUET_DEBUFF_DISPELLABLE = "Пометка: Дебаф, рассеиваемые";
VUHDO_I18N_BOUQUET_DEBUFF_MAGIC = "Пометка: Дебаф - магия";
VUHDO_I18N_BOUQUET_DEBUFF_DISEASE = "Пометка: Дебаф - болезнь";
VUHDO_I18N_BOUQUET_DEBUFF_POISON = "Пометка: Дебаф - яд";
VUHDO_I18N_BOUQUET_DEBUFF_CURSE = "Пометка: Дебаф - проклятие";
VUHDO_I18N_BOUQUET_CHARMED = "Пометка: очарованный";
VUHDO_I18N_BOUQUET_DEAD = "Пометка: Труп";
VUHDO_I18N_BOUQUET_DISCONNECTED = "Пометка: разъединён";
VUHDO_I18N_BOUQUET_AFK = "Пометка: AFK";
VUHDO_I18N_BOUQUET_PLAYER_TARGET = "Пометка: Цель игрока";
VUHDO_I18N_BOUQUET_MOUSEOVER_TARGET = "Пометка: Наведение мыши на 1 цель";
VUHDO_I18N_BOUQUET_MOUSEOVER_GROUP = "Пометка: Наведение мыши на группу";
VUHDO_I18N_BOUQUET_HEALTH_BELOW = "Пометка: Здоровье < %";
VUHDO_I18N_BOUQUET_MANA_BELOW = "Пометка: Мана < %";
VUHDO_I18N_BOUQUET_THREAT_ABOVE = "Пометка: Угроза > %";
VUHDO_I18N_BOUQUET_NUM_IN_CLUSTER = "Пометка: Cluster >= #players";
VUHDO_I18N_BOUQUET_CLASS_COLOR = "Пометка: Всегда окраска по классу";
VUHDO_I18N_BOUQUET_ALWAYS = "Пометка: Всегда цельный";
VUHDO_I18N_SWIFTMEND_POSSIBLE = "Пометка: Swiftmend possible";
VUHDO_I18N_BOUQUET_MOUSEOVER_CLUSTER = "Пометка: Cluster, Mouseover";
VUHDO_I18N_THREAT_LEVEL_MEDIUM = "Пометка: Угроза, высокая";
VUHDO_I18N_THREAT_LEVEL_HIGH = "Пометка: Угроза, Overnuke";
VUHDO_I18N_BOUQUET_STATUS_HEALTH = "Состояние: Здоровье %";
VUHDO_I18N_BOUQUET_STATUS_MANA = "Состояние: Мана %";
VUHDO_I18N_BOUQUET_STATUS_OTHER_POWERS = "Состояние: не-мана %";
VUHDO_I18N_BOUQUET_STATUS_INCOMING = "Состояние: Вхд. Исцеление %";
VUHDO_I18N_BOUQUET_STATUS_THREAT = "Состояние: Угроза %";
VUHDO_I18N_BOUQUET_NEW_ITEM_NAME = "-- введите сюда (де)баф --";


VUHDO_I18N_DEF_BOUQUET_TANK_COOLDOWNS = "Восстоновления танка";
VUHDO_I18N_DEF_BOUQUET_PW_S_WEAKENED_SOUL = "СС:Щ и Ослабленная душа";
VUHDO_I18N_DEF_BOUQUET_BORDER_MULTI_AGGRO = "Границы: нескалько + угроза";
VUHDO_I18N_DEF_BOUQUET_BORDER_MULTI = "Границы: нескалько";
VUHDO_I18N_DEF_BOUQUET_BORDER_SIMPLE = "Границы: один";
VUHDO_I18N_DEF_BOUQUET_SWIFTMENDABLE = "Swiftmendable";
VUHDO_I18N_DEF_BOUQUET_MOUSEOVER_SINGLE = "Наведение мыши: один";
VUHDO_I18N_DEF_BOUQUET_MOUSEOVER_MULTI = "Наведение мыши: нескалько";
VUHDO_I18N_DEF_BOUQUET_AGGRO_INDICATOR = "Индикатор угрозы";
VUHDO_I18N_DEF_BOUQUET_CLUSTER_MOUSE_HOVER = "Cluster: Mouse Hover";
VUHDO_I18N_DEF_BOUQUET_THREAT_MARKS = "Угроза: метки";
VUHDO_I18N_DEF_BOUQUET_BAR_MANA_ALL = "Мана полосы: Все виды энергии";
VUHDO_I18N_DEF_BOUQUET_BAR_MANA_ONLY = "Мана полосы: Только мана";
VUHDO_I18N_DEF_BOUQUET_BAR_THREAT = "Угроза: состояние";


VUHDO_I18N_CUSTOM_ICON_NONE = "- Нету / По умолчанию -";
VUHDO_I18N_CUSTOM_ICON_GLOSSY = "Блестящий";
VUHDO_I18N_CUSTOM_ICON_MOSAIC = "Мозаика";
VUHDO_I18N_CUSTOM_ICON_CLUSTER = "Cluster";
VUHDO_I18N_CUSTOM_ICON_FLAT = "Плоский";
VUHDO_I18N_CUSTOM_ICON_SPOT = "Крапинка";
VUHDO_I18N_CUSTOM_ICON_CIRCLE = "Круг";
VUHDO_I18N_CUSTOM_ICON_SKETCHED = "Набросок";
VUHDO_I18N_CUSTOM_ICON_RHOMB = "Ромб";


VUHDO_I18N_OUTER_BORDER = "Снаружи";
VUHDO_I18N_INNER_BORDER = "Внутри";
VUHDO_I18N_SWIFTMEND_INDICATOR = "Особый ДоТ";
VUHDO_I18N_MOUSEOVER_HIGHLIGHTER = "Наведение мыши";
VUHDO_I18N_THREAT_MARKS = "Метки угрозы";
VUHDO_I18N_THREAT_BAR = "Полоска угрозы";
VUHDO_I18N_AGGRO_LINE = "Линия агро";
VUHDO_I18N_MANA_BAR = "Полоска маны";
VUHDO_I18N_BORDER_WIDTH = "Ширина";

VUHDO_I18N_ERROR_NO_PROFILE = "Ошибка: Нету профиля с названием: ";
VUHDO_I18N_PROFILE_LOADED = "Профиль успешно загружен: ";
VUHDO_I18N_PROFILE_SAVED = "Профиль успешно сохранен: ";
VUHDO_I18N_PROFILE_OVERWRITE_1 = "Профиль";
VUHDO_I18N_PROFILE_OVERWRITE_2 = "is currently owned by\nanother toon";
VUHDO_I18N_PROFILE_OVERWRITE_3 = "\n- Перезаписать: Существующий профиль будет перезаписан.\n- Копировать: Создать и сохранить копию. Сохранив текущий профиль.";
VUHDO_I18N_COPY = "Копировать";
VUHDO_I18N_OVERWRITE = "Перезаписать";
VUHDO_I18N_DISCARD = "Отвергнуть";

-- 2.0, alpha #2
VUHDO_I18N_DEF_BAR_BACKGROUND_SOLID = "Фон: цельный";
VUHDO_I18N_DEF_BAR_BACKGROUND_CLASS_COLOR = "Фон: по цвету класса";

-- 2.0 alpha #9
VUHDO_I18N_BOUQUET_DEBUFF_BAR_COLOR = "Пометка: Дебаф, конфигурируемый";
VUHDO_I18N_BACKGROUND_BAR = "Фон полоски";

-- 2.0 alpha #11
VUHDO_I18N_HEALTH_BAR = "Полоска здоровья";
VUHDO_I18N_DEF_BOUQUET_BAR_HEALTH = "Полоска здоровья: (типичный)";
VUHDO_I18N_UPDATE_RAID_TARGET = "Пометка: Цвет цели рейда";
VUHDO_I18N_BOUQUET_OVERHEAL_HIGHLIGHT = "Цвет: подсветка избыточного лечения";
VUHDO_I18N_BOUQUET_EMERGENCY_COLOR = "Цвет: критическое положение";
VUHDO_I18N_BOUQUET_HEALTH_ABOVE = "Пометка: Здоровье > %";
VUHDO_I18N_BOUQUET_RESURRECTION = "Пометка: воскресение";
VUHDO_I18N_BOUQUET_STACKS_COLOR = "Цвет: #Stacks";

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
