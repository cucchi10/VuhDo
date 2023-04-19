local pairs = pairs;



--
local tHotCfg, tHotSlots, tCnt2, tHasFixed;
function VUHDO_fixHotSettings()
	tHasFixed = false;
	tHotSlots = VUHDO_PANEL_SETUP["HOTS"]["SLOTS"];
	tHotCfg = VUHDO_PANEL_SETUP["HOTS"]["SLOTCFG"];

	for tCnt2 = 1, 9 do
		if (not tHotCfg["" .. tCnt2]["mine"]  and not tHotCfg["" .. tCnt2]["others"]) then
			if (tHotSlots[tCnt2] ~= nil) then
				tHotCfg["" .. tCnt2]["mine"] = true;
				tHotCfg["" .. tCnt2]["others"] = VUHDO_EXCLUSIVE_HOTS[tHotSlots[tCnt2]] ~= nil;
				tHasFixed = true;
			end
		end
	end

	return tHasFixed;
end



--
local function VUHDO_getVarDescription(aVar)
	local tMessage = "";
	if (aVar == nil) then
		tMessage = "<nil>";
	elseif ("boolean" == type(aVar)) then
		if (aVar) then
			tMessage = "<true>";
		else
			tMessage = "<false>";
		end
	elseif("number" == type(aVar) or "string" == type(aVar)) then
		tMessage = aVar .. " (" .. type(aVar) .. ")";
	else
		tMessage = "(" .. type(aVar) .. ")";
	end

	return tMessage;
end



--
local tCreated, tRepaired;
local function _VUHDO_ensureSanity(aName, aValue, aSaneValue)
	if (aSaneValue ~= nil) then
		if (type(aSaneValue) == "table") then
			if (aValue ~= nil and type(aValue) == "table") then
				local tIndex;
				for tIndex, _ in pairs(aSaneValue) do
					aValue[tIndex] = _VUHDO_ensureSanity(aName, aValue[tIndex], aSaneValue[tIndex]);
				end
			else

				if (aValue ~= nil) then
					VUHDO_Msg("AUTO MODEL SANITY: " .. aName .. " repaired table (was flat value): " .. VUHDO_getVarDescription(aValue));
					tRepaired = tRepaired + 1;
				else
					tCreated = tCreated + 1;
				end

				return VUHDO_deepCopyTable(aSaneValue);
			end
		else
			if (aValue == nil or type(aValue) ~= type(aSaneValue)) then
				if ((type(aSaneValue) ~= "boolean" or (aValue ~= 1 and aValue ~= 0 and aValue ~= nil))
				and (type(aSaneValue) ~= "number" or (aSaneValue ~= 1 and aSaneValue ~= 0))) then

					if (aValue ~= nil) then
						tRepaired = tRepaired + 1;
						VUHDO_Msg("AUTO MODEL SANITY: " .. aName
								.. " repaired a flat value: " .. VUHDO_getVarDescription(aValue)
								.. " to " .. VUHDO_getVarDescription(aSaneValue));
					else
						tCreated = tCreated + 1;
					end

					return aSaneValue;
				end
			end
		end
	end

	return aValue
end



--
local tRepairedArray;
function VUHDO_ensureSanity(aName, aValue, aSaneValue)
	tCreated = 0;
	tRepaired = 0;
	tRepairedArray = _VUHDO_ensureSanity(aName, aValue, aSaneValue);

	if (tCreated + tRepaired > 0) then
		VUHDO_Msg("auto model sanity: " .. aName .. ": created " .. tCreated .. ", repaired " .. tRepaired .. " values.");
	end

	return tRepairedArray;
end



local VUHDO_DEFAULT_MODELS = {
	{ VUHDO_ID_GROUP_1, VUHDO_ID_GROUP_2, VUHDO_ID_GROUP_3, VUHDO_ID_GROUP_4, VUHDO_ID_GROUP_5, VUHDO_ID_GROUP_6, VUHDO_ID_GROUP_7, VUHDO_ID_GROUP_8 },
	{ VUHDO_ID_MAINTANKS },
	{ VUHDO_ID_PETS },
	{ VUHDO_ID_PRIVATE_TANKS },
};



local VUHDO_DEFAULT_RANGE_SPELLS = {
	["WARRIOR"] = nil,
	["ROGUE"] = nil,
	["HUNTER"] = nil,
	["PALADIN"] = VUHDO_SPELL_ID_HOLY_LIGHT,
	["MAGE"] = nil,
	["WARLOCK"] = nil,
	["SHAMAN"] = VUHDO_SPELL_ID_HEALING_WAVE,
	["DRUID"] = VUHDO_SPELL_ID_HEALING_TOUCH,
	["PRIEST"] = VUHDO_SPELL_ID_LESSER_HEAL,
	["DEATHKNIGHT"] = nil,
}



local VUHDO_DEFAULT_SPELL_ASSIGNMENT = {
		["1"] = {"", "1", "target"},
		["2"] = {"", "2", "assist"},
		["3"] = {"", "3", "focus"},
		["4"] = {"", "4", "menu"},
		["5"] = {"", "5", "menu"},
		["6"] = {"", "6", ""},
		["7"] = {"", "7", ""},
		["8"] = {"", "8", ""},
		["9"] = {"", "9", ""},
		["10"] = {"", "10", ""},
		["11"] = {"", "11", ""},
		["12"] = {"", "12", ""},
		["13"] = {"", "13", ""},
		["14"] = {"", "14", ""},
		["15"] = {"", "15", ""},
		["16"] = {"", "16", ""},

		["alt1"] = {"alt-", "1", ""},
		["alt2"] = {"alt-", "2", ""},
		["alt3"] = {"alt-", "3", ""},
		["alt4"] = {"alt-", "4", ""},
		["alt5"] = {"alt-", "5", ""},
		["alt6"] = {"alt-", "6", ""},
		["alt7"] = {"alt-", "7", ""},
		["alt8"] = {"alt-", "8", ""},
		["alt9"] = {"alt-", "9", ""},
		["alt10"] = {"alt-", "10", ""},
		["alt11"] = {"alt-", "11", ""},
		["alt12"] = {"alt-", "12", ""},
		["alt13"] = {"alt-", "13", ""},
		["alt14"] = {"alt-", "14", ""},
		["alt15"] = {"alt-", "15", ""},
		["alt16"] = {"alt-", "16", ""},

		["ctrl1"] = {"ctrl-", "1", ""},
		["ctrl2"] = {"ctrl-", "2", ""},
		["ctrl3"] = {"ctrl-", "3", ""},
		["ctrl4"] = {"ctrl-", "4", ""},
		["ctrl5"] = {"ctrl-", "5", ""},
		["ctrl6"] = {"ctrl-", "6", ""},
		["ctrl7"] = {"ctrl-", "7", ""},
		["ctrl8"] = {"ctrl-", "8", ""},
		["ctrl9"] = {"ctrl-", "9", ""},
		["ctrl10"] = {"ctrl-", "10", ""},
		["ctrl11"] = {"ctrl-", "11", ""},
		["ctrl12"] = {"ctrl-", "12", ""},
		["ctrl13"] = {"ctrl-", "13", ""},
		["ctrl14"] = {"ctrl-", "14", ""},
		["ctrl15"] = {"ctrl-", "15", ""},
		["ctrl16"] = {"ctrl-", "16", ""},

		["shift1"] = {"shift-", "1", ""},
		["shift2"] = {"shift-", "2", ""},
		["shift3"] = {"shift-", "3", ""},
		["shift4"] = {"shift-", "4", ""},
		["shift5"] = {"shift-", "5", ""},
		["shift6"] = {"shift-", "6", ""},
		["shift7"] = {"shift-", "7", ""},
		["shift8"] = {"shift-", "8", ""},
		["shift9"] = {"shift-", "9", ""},
		["shift10"] = {"shift-", "10", ""},
		["shift11"] = {"shift-", "11", ""},
		["shift12"] = {"shift-", "12", ""},
		["shift13"] = {"shift-", "13", ""},
		["shift14"] = {"shift-", "14", ""},
		["shift15"] = {"shift-", "15", ""},
		["shift16"] = {"shift-", "16", ""},

		["altctrl1"] = {"alt-ctrl-", "1", ""},
		["altctrl2"] = {"alt-ctrl-", "2", ""},
		["altctrl3"] = {"alt-ctrl-", "3", ""},
		["altctrl4"] = {"alt-ctrl-", "4", ""},
		["altctrl5"] = {"alt-ctrl-", "5", ""},
		["altctrl6"] = {"alt-ctrl-", "6", ""},
		["altctrl7"] = {"alt-ctrl-", "7", ""},
		["altctrl8"] = {"alt-ctrl-", "8", ""},
		["altctrl9"] = {"alt-ctrl-", "9", ""},
		["altctrl10"] = {"alt-ctrl-", "10", ""},
		["altctrl11"] = {"alt-ctrl-", "11", ""},
		["altctrl12"] = {"alt-ctrl-", "12", ""},
		["altctrl13"] = {"alt-ctrl-", "13", ""},
		["altctrl14"] = {"alt-ctrl-", "14", ""},
		["altctrl15"] = {"alt-ctrl-", "15", ""},
		["altctrl16"] = {"alt-ctrl-", "16", ""},

		["altshift1"] = {"alt-shift-", "1", ""},
		["altshift2"] = {"alt-shift-", "2", ""},
		["altshift3"] = {"alt-shift-", "3", ""},
		["altshift4"] = {"alt-shift-", "4", ""},
		["altshift5"] = {"alt-shift-", "5", ""},
		["altshift6"] = {"alt-shift-", "6", ""},
		["altshift7"] = {"alt-shift-", "7", ""},
		["altshift8"] = {"alt-shift-", "8", ""},
		["altshift9"] = {"alt-shift-", "9", ""},
		["altshift10"] = {"alt-shift-", "10", ""},
		["altshift11"] = {"alt-shift-", "11", ""},
		["altshift12"] = {"alt-shift-", "12", ""},
		["altshift13"] = {"alt-shift-", "13", ""},
		["altshift14"] = {"alt-shift-", "14", ""},
		["altshift15"] = {"alt-shift-", "15", ""},
		["altshift16"] = {"alt-shift-", "16", ""},

		["ctrlshift1"] = {"ctrl-shift-", "1", ""},
		["ctrlshift2"] = {"ctrl-shift-", "2", ""},
		["ctrlshift3"] = {"ctrl-shift-", "3", ""},
		["ctrlshift4"] = {"ctrl-shift-", "4", ""},
		["ctrlshift5"] = {"ctrl-shift-", "5", ""},
		["ctrlshift6"] = {"ctrl-shift-", "6", ""},
		["ctrlshift7"] = {"ctrl-shift-", "7", ""},
		["ctrlshift8"] = {"ctrl-shift-", "8", ""},
		["ctrlshift9"] = {"ctrl-shift-", "9", ""},
		["ctrlshift10"] = {"ctrl-shift-", "10", ""},
		["ctrlshift11"] = {"ctrl-shift-", "11", ""},
		["ctrlshift12"] = {"ctrl-shift-", "12", ""},
		["ctrlshift13"] = {"ctrl-shift-", "13", ""},
		["ctrlshift14"] = {"ctrl-shift-", "14", ""},
		["ctrlshift15"] = {"ctrl-shift-", "15", ""},
		["ctrlshift16"] = {"ctrl-shift-", "16", ""},

		["altctrlshift1"] = {"alt-ctrl-shift-", "1", ""},
		["altctrlshift2"] = {"alt-ctrl-shift-", "2", ""},
		["altctrlshift3"] = {"alt-ctrl-shift-", "3", ""},
		["altctrlshift4"] = {"alt-ctrl-shift-", "4", ""},
		["altctrlshift5"] = {"alt-ctrl-shift-", "5", ""},
		["altctrlshift6"] = {"alt-ctrl-shift-", "6", ""},
		["altctrlshift7"] = {"alt-ctrl-shift-", "7", ""},
		["altctrlshift8"] = {"alt-ctrl-shift-", "8", ""},
		["altctrlshift9"] = {"alt-ctrl-shift-", "9", ""},
		["altctrlshift10"] = {"alt-ctrl-shift-", "10", ""},
		["altctrlshift11"] = {"alt-ctrl-shift-", "11", ""},
		["altctrlshift12"] = {"alt-ctrl-shift-", "12", ""},
		["altctrlshift13"] = {"alt-ctrl-shift-", "13", ""},
		["altctrlshift14"] = {"alt-ctrl-shift-", "14", ""},
		["altctrlshift15"] = {"alt-ctrl-shift-", "15", ""},
		["altctrlshift16"] = {"alt-ctrl-shift-", "16", ""},
};



local VUHDO_CLASS_DEFAULT_SPELL_ASSIGNMENT = {
	["PALADIN"] = {
		["1"] = {"", "1", VUHDO_SPELL_ID_FLASH_OF_LIGHT},
		["2"] = {"", "2", VUHDO_SPELL_ID_PALA_CLEANSE},
		["3"] = {"", "3", "menu"},
		["4"] = {"", "4", VUHDO_SPELL_ID_DIVINE_FAVOR},
		["5"] = {"", "5", VUHDO_SPELL_ID_DIVINE_ILLUMINATION},

		["alt1"] = {"alt-", "1", "target"},
		["alt4"] = {"alt-", "4", VUHDO_SPELL_ID_DIVINE_INTERVENTION},
		["alt5"] = {"alt-", "5", VUHDO_SPELL_ID_DIVINE_INTERVENTION},

		["ctrl1"] = {"ctrl-", "1", VUHDO_SPELL_ID_HOLY_LIGHT},
		["ctrl2"] = {"ctrl-", "2", VUHDO_SPELL_ID_HOLY_LIGHT},
		["ctrl4"] = {"ctrl-", "4", VUHDO_SPELL_ID_DIVINE_INTERVENTION},
		["ctrl5"] = {"ctrl-", "5", VUHDO_SPELL_ID_DIVINE_INTERVENTION},

		["shift1"] = {"shift-", "1", VUHDO_SPELL_ID_HOLY_SHOCK},
		["shift2"] = {"shift-", "2", VUHDO_SPELL_ID_LAY_ON_HANDS},
		["shift4"] = {"shift-", "4", VUHDO_SPELL_ID_DIVINE_INTERVENTION},
		["shift5"] = {"shift-", "5", VUHDO_SPELL_ID_DIVINE_INTERVENTION},
	},

	["SHAMAN"] = {
		["1"] = {"", "1", VUHDO_SPELL_ID_LESSER_HEALING_WAVE},
		["2"] = {"", "2", VUHDO_SPELL_ID_CHAIN_HEAL},
		["3"] = {"", "3", "menu"},

		["alt1"] = {"alt-", "1", VUHDO_SPELL_ID_BUFF_EARTH_SHIELD},
		["alt2"] = {"alt-", "2", VUHDO_SPELL_ID_GIFT_OF_THE_NAARU},
		["alt3"] = {"alt-", "3", "menu"},

		["ctrl1"] = {"ctrl-", "1", "target"},
		["ctrl2"] = {"ctrl-", "2", "target"},
		["ctrl3"] = {"ctrl-", "3", "menu"},

		["ctrlshift1"] = {"ctrl-shift-", "1", VUHDO_SPELL_ID_CURE_TOXINS},
		["ctrlshift2"] = {"ctrl-shift-", "2", VUHDO_SPELL_ID_CURE_TOXINS},

		["shift1"] = {"shift-", "1", VUHDO_SPELL_ID_HEALING_WAVE},
		["shift2"] = {"shift-", "2", VUHDO_SPELL_ID_CHAIN_HEAL},
		["shift3"] = {"shift-", "3", "menu" },

		["altctrl1"] = {"alt-ctrl-", "1", VUHDO_SPELL_ID_PURGE},
		["altctrl2"] = {"alt-ctrl-", "2", VUHDO_SPELL_ID_PURGE},
	},

	["PRIEST"] = {
		["1"] = {"", "1", VUHDO_SPELL_ID_FLASH_HEAL},
		["2"] = {"", "2", VUHDO_SPELL_ID_GREATER_HEAL},
		["3"] = {"", "3", VUHDO_SPELL_ID_DESPERATE_PRAYER},
		["4"] = {"", "4", VUHDO_SPELL_ID_RENEW},
		["5"] = {"", "5", VUHDO_SPELL_ID_BINDING_HEAL},

		["alt1"] = {"alt-", "1", "target"},
		["alt2"] = {"alt-", "2", "focus"},
		["alt3"] = {"alt-", "3", VUHDO_SPELL_ID_POWERWORD_SHIELD},
		["alt4"] = {"alt-", "4", VUHDO_SPELL_ID_POWERWORD_SHIELD},
		["alt5"] = {"alt-", "5", VUHDO_SPELL_ID_POWERWORD_SHIELD},

		["ctrl1"] = {"ctrl-", "1", VUHDO_SPELL_ID_PRAYER_OF_HEALING},
		["ctrl2"] = {"ctrl-", "2", VUHDO_SPELL_ID_CIRCLE_OF_HEALING},
		["ctrl3"] = {"ctrl-", "3", "menu"},
		["ctrl4"] = {"ctrl-", "4", VUHDO_SPELL_ID_PRAYER_OF_MENDING},
		["ctrl5"] = {"ctrl-", "5", VUHDO_SPELL_ID_PRAYER_OF_MENDING},

		["shift1"] = {"shift-", "1", VUHDO_SPELL_ID_ABOLISH_DISEASE},
		["shift2"] = {"shift-", "2", VUHDO_SPELL_ID_DISPEL_MAGIC},
		["shift3"] = {"shift-", "3", "menu"},
		["shift4"] = {"shift-", "4", ""},
		["shift5"] = {"shift-", "5", ""},
	},

	["DRUID"] = {
		["1"] = {"", "1", VUHDO_SPELL_ID_HEALING_TOUCH},
		["2"] = {"", "2", VUHDO_SPELL_ID_REJUVENATION},
		["3"] = {"", "3", "menu"},
		["4"] = {"", "4", VUHDO_SPELL_ID_INNERVATE},
		["5"] = {"", "5", VUHDO_SPELL_ID_INNERVATE},

		["alt1"] = {"alt-", "1", "target"},
		["alt2"] = {"alt-", "2", "focus"},
		["alt3"] = {"alt-", "3", "menu"},
		["alt4"] = {"alt-", "4", ""},
		["alt5"] = {"alt-", "5", ""},

		["ctrl1"] = {"ctrl-", "1", VUHDO_SPELL_ID_REGROWTH},
		["ctrl2"] = {"ctrl-", "2", VUHDO_SPELL_ID_LIFEBLOOM},
		["ctrl3"] = {"ctrl-", "3", ""},
		["ctrl4"] = {"ctrl-", "4", VUHDO_SPELL_ID_TRANQUILITY},
		["ctrl5"] = {"ctrl-", "5", VUHDO_SPELL_ID_TRANQUILITY},

		["shift1"] = {"shift-", "1", VUHDO_SPELL_ID_ABOLISH_POISON},
		["shift2"] = {"shift-", "2", VUHDO_SPELL_ID_REMOVE_CURSE},
		["shift3"] = {"shift-", "3", ""},
		["shift4"] = {"shift-", "4", ""},
		["shift5"] = {"shift-", "5", ""},
	}
};



local VUHDO_DEFAULT_SPELLS_KEYBOARD = {
	["SPELL1"] = "",
	["SPELL2"] = "",
	["SPELL3"] = "",
	["SPELL4"] = "",
	["SPELL5"] = "",
	["SPELL6"] = "",
	["SPELL7"] = "",
	["SPELL8"] = "",
	["SPELL9"] = "",
	["SPELL10"] = "",
	["SPELL11"] = "",
	["SPELL12"] = "",
	["SPELL13"] = "",
	["SPELL14"] = "",
	["SPELL15"] = "",
	["SPELL16"] = "",

	["WHEEL"] = {
		["1"] = {"", "-w1", ""},
		["2"] = {"", "-w2", ""},

		["alt1"] = {"ALT-", "-w3", ""},
		["alt2"] = {"ALT-", "-w4", ""},

		["ctrl1"] = {"CTRL-", "-w5", ""},
		["ctrl2"] = {"CTRL-", "-w6", ""},

		["shift1"] = {"SHIFT-", "-w7", ""},
		["shift2"] = {"SHIFT-", "-w8", ""},

		["altctrl1"] = {"ALT-CTRL-", "-w9", ""},
		["altctrl2"] = {"ALT-CTRL-", "-w10", ""},

		["altshift1"] = {"ALT-SHIFT-", "-w11", ""},
		["altshift2"] = {"ALT-SHIFT-", "-w12", ""},

		["ctrlshift1"] = {"CTRL-SHIFT-", "-w13", ""},
		["ctrlshift2"] = {"CTRL-SHIFT-", "-w14", ""},

		["altctrlshift1"] = {"ALT-CTRL-SHIFT-", "-w15", ""},
		["altctrlshift2"] = {"ALT-CTRL-SHIFT-", "-w16", ""},
	},

	["HOSTILE_WHEEL"] = {
		["1"] = {"", "-w1", ""},
		["2"] = {"", "-w2", ""},

		["alt1"] = {"ALT-", "-w3", ""},
		["alt2"] = {"ALT-", "-w4", ""},

		["ctrl1"] = {"CTRL-", "-w5", ""},
		["ctrl2"] = {"CTRL-", "-w6", ""},

		["shift1"] = {"SHIFT-", "-w7", ""},
		["shift2"] = {"SHIFT-", "-w8", ""},

		["altctrl1"] = {"ALT-CTRL-", "-w9", ""},
		["altctrl2"] = {"ALT-CTRL-", "-w10", ""},

		["altshift1"] = {"ALT-SHIFT-", "-w11", ""},
		["altshift2"] = {"ALT-SHIFT-", "-w12", ""},

		["ctrlshift1"] = {"CTRL-SHIFT-", "-w13", ""},
		["ctrlshift2"] = {"CTRL-SHIFT-", "-w14", ""},

		["altctrlshift1"] = {"ALT-CTRL-SHIFT-", "w15", ""},
		["altctrlshift2"] = {"ALT-CTRL-SHIFT-", "w16", ""},
	},
}



local VUHDO_DEFAULT_SPELL_CONFIG = {
	["IS_AUTO_FIRE"] = true,
	["IS_FIRE_HOT"] = false,
	["IS_FIRE_OUT_FIGHT"] = false,
	["IS_KEEP_STANCE"] = false,
	["IS_AUTO_TARGET"] = false,
	["IS_CANCEL_CURRENT"] = false,
	["IS_FIRE_TRINKET_1"] = false,
	["IS_FIRE_TRINKET_2"] = false,
	["IS_FIRE_CUSTOM_1"] = false,
	["FIRE_CUSTOM_1_SPELL"] = "",
	["IS_FIRE_CUSTOM_2"] = false,
	["FIRE_CUSTOM_2_SPELL"] = "",
	["IS_TOOLTIP_INFO"] = false,
	["IS_LOAD_HOTS"] = false,
	["smartCastModi"] = "all",
	["autoBattleRez"] = true,
}



--
function VUHDO_loadSpellArray()
	if (VUHDO_SPELL_ASSIGNMENTS == nil) then
		VUHDO_assignDefaultSpells();
	end
	VUHDO_SPELL_ASSIGNMENTS = VUHDO_ensureSanity("VUHDO_SPELL_ASSIGNMENTS", VUHDO_SPELL_ASSIGNMENTS, VUHDO_DEFAULT_SPELL_ASSIGNMENT);

	if (VUHDO_HOSTILE_SPELL_ASSIGNMENTS == nil) then
		VUHDO_HOSTILE_SPELL_ASSIGNMENTS = VUHDO_deepCopyTable(VUHDO_DEFAULT_SPELL_ASSIGNMENT);
	end
	VUHDO_HOSTILE_SPELL_ASSIGNMENTS = VUHDO_ensureSanity("VUHDO_HOSTILE_SPELL_ASSIGNMENTS", VUHDO_HOSTILE_SPELL_ASSIGNMENTS, VUHDO_DEFAULT_SPELL_ASSIGNMENT);

	if (VUHDO_SPELLS_KEYBOARD == nil) then
		VUHDO_SPELLS_KEYBOARD = VUHDO_deepCopyTable(VUHDO_DEFAULT_SPELLS_KEYBOARD);
	end
	VUHDO_SPELLS_KEYBOARD = VUHDO_ensureSanity("VUHDO_SPELLS_KEYBOARD", VUHDO_SPELLS_KEYBOARD, VUHDO_DEFAULT_SPELLS_KEYBOARD);

	if (VUHDO_SPELL_CONFIG == nil) then
		VUHDO_SPELL_CONFIG = VUHDO_deepCopyTable(VUHDO_DEFAULT_SPELL_CONFIG);
	end
	VUHDO_SPELL_CONFIG = VUHDO_ensureSanity("VUHDO_SPELL_CONFIG", VUHDO_SPELL_CONFIG, VUHDO_DEFAULT_SPELL_CONFIG);

	if (VUHDO_SPELL_LAYOUTS == nil) then
		VUHDO_SPELL_LAYOUTS = { };
	end

	if (VUHDO_SPEC_LAYOUTS == nil) then
		VUHDO_SPEC_LAYOUTS = {
			["selected"] = "",
			["1"] = "";
			["2"] = "";
		}
	end

end



--
function VUHDO_assignDefaultSpells()
	local tClass;

	_, tClass = UnitClass("player");

	VUHDO_SPELL_ASSIGNMENTS = VUHDO_deepCopyTable(VUHDO_DEFAULT_SPELL_ASSIGNMENT);

	if (VUHDO_CLASS_DEFAULT_SPELL_ASSIGNMENT[tClass] ~= nil) then
		VUHDO_SPELL_ASSIGNMENTS = VUHDO_deepCopyTable(VUHDO_CLASS_DEFAULT_SPELL_ASSIGNMENT[tClass]);
		local tKey, tValue;

		for tKey, tValue in pairs(VUHDO_DEFAULT_SPELL_ASSIGNMENT) do
			if (VUHDO_SPELL_ASSIGNMENTS[tKey] == nil) then
				VUHDO_SPELL_ASSIGNMENTS[tKey] = tValue;
			end
		end
	end
end



--
local tIsToggle;
local function VUHDO_customDebuffsAddDefaultSettings(aBuffName)
	if (VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"] == nil) then
		VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"] = { };
	end

	tIsToggle =
		aBuffName ~= VUHDO_SPELL_ID_DEBUFF_WEAKENED_SOUL and VUHDO_CONFIG["CUSTOM_DEBUFF"].toggleName;

	if (VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][aBuffName] == nil) then
		VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][aBuffName]	= {
			["isIcon"] = VUHDO_CONFIG["CUSTOM_DEBUFF"].isIcon,
			["isColor"] = false,
			["animate"] = VUHDO_CONFIG["CUSTOM_DEBUFF"].animate,
			["timer"] = VUHDO_CONFIG["CUSTOM_DEBUFF"].timer,
			["isStacks"] = VUHDO_CONFIG["CUSTOM_DEBUFF"].isStacks,
		}
	end

	if (not VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][aBuffName].isColor) then
		VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][aBuffName].color = nil;
	elseif (VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][aBuffName].color == nil) then
		VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][aBuffName].color = {
			["R"] = 0.6,
			["G"] = 0.3,
			["B"] = 0,
			["O"] = 1,
			["TR"] = 0.8,
			["TG"] = 0.5,
			["TB"] = 0,
			["TO"] = 1,
			["useText"] = true,
			["useBackground"] = true,
		  ["useOpacity"] = true,
		};
	end
end


--
local tArgNum, tArg;
local tCnt;
local tBuffName;
local function VUHDO_addCustomSpellIds(...)
	tArgNum = select("#", ...);

	for tCnt = 1, tArgNum do
		tArg = select(tCnt, ...);
		tBuffName = select(1, GetSpellInfo(tArg));
		VUHDO_tableUniqueAdd(VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED"], tBuffName);
	end
end



--
local VUHDO_DEFAULT_CONFIG = {
	["SHOW_PANELS"] = true,
	["HIDE_PANELS_SOLO"] = false,
	["HIDE_PANELS_PARTY"] = false,
	["LOCK_PANELS"] = false,
	["LOCK_CLICKS_THROUGH"] = false,
	["SHOW_MINIMAP"] = true,

	["MODE"] = VUHDO_MODE_NEUTRAL,
	["EMERGENCY_TRIGGER"] = 100,
	["MAX_EMERGENCIES"] = 5,
	["SHOW_INCOMING"] = true,
	["SHOW_OVERHEAL"] = true,
	["SHOW_OWN_INCOMING"] = true,
	["SHOW_TEXT_OVERHEAL"] = true,

	["RANGE_CHECK_DELAY"] = 260,

	["SOUND_DEBUFF"] = nil,
	["DETECT_DEBUFFS_REMOVABLE_ONLY"] = true,
	["DETECT_DEBUFFS_IGNORE_BY_CLASS"] = true,
	["DETECT_DEBUFFS_IGNORE_NO_HARM"] = true,
	["DETECT_DEBUFFS_IGNORE_MOVEMENT"] = true,
	["DETECT_DEBUFFS_IGNORE_DURATION"] = true,

	["SMARTCAST_RESURRECT"] = true,
	["SMARTCAST_CLEANSE"] = true,
	["SMARTCAST_BUFF"] = false,

	["SHOW_PLAYER_TAGS"] = true,
	["OMIT_MAIN_TANKS"] = false,
	["OMIT_MAIN_ASSIST"] = false,
	["OMIT_PLAYER_TARGETS"] = false,
	["OMIT_OWN_GROUP"] = false,
	["OMIT_FOCUS"] = false,
	["OMIT_TARGET"] = false,
	["OMIT_SELF"] = false,
	["OMIT_DFT_MTS"] = false,
	["BLIZZ_UI_HIDE_PLAYER"] = false,
	["BLIZZ_UI_HIDE_PARTY"] = false,
	["BLIZZ_UI_HIDE_TARGET"] = false,
	["BLIZZ_UI_HIDE_PET"] = false,
	["BLIZZ_UI_HIDE_FOCUS"] = false,

	["CURRENT_PROFILE"] = "",
	["IS_ALWAYS_OVERWRITE_PROFILE"] = false,
	["HIDE_EMPTY_PANELS"] = false,
	["ON_MOUSE_UP"] = false,
	["STANDARD_TOOLTIP"] = false,

	["AUTO_PROFILES"] = {
		["1"] = nil,
		["5"] = nil,
		["10"] = nil,
		["15"] = nil,
		["25"] = nil,
		["40"] = nil,
		["SPEC_1"] = nil,
		["SPEC_2"] = nil,
	},

	["RES_ANNOUNCE_TEXT"] = VUHDO_I18N_DEFAULT_RES_ANNOUNCE,
	["RES_IS_SHOW_TEXT"] = false,

	["CUSTOM_DEBUFF"] = {
		["scale"] = 0.8,
		["animate"] = true,
		["timer"] = true,
		["max_num"] = 3,
		["isIcon"] = true,
		["isColor"] = false,
		["isStacks"] = false,
		["isName"] = false,
		["selected"] = "",
		["point"] = "TOPRIGHT",
		["xAdjust"] = -2,
		["yAdjust"] = -34,
		["STORED"] = { VUHDO_SPELL_ID_DEBUFF_FROST_BLAST },
	},

	["THREAT"] = {
		["AGGRO_REFRESH_MS"] = 300,
		["AGGRO_TEXT_LEFT"] = ">>",
		["AGGRO_TEXT_RIGHT"] = "<<",
		["AGGRO_USE_TEXT"] = false,
		["IS_TANK_MODE"] = false,
	},

	["CLUSTER"] = {
		["REFRESH"] = 180,
		["RANGE"] = 15,
		["BELOW_HEALTH_PERC"] = 85,
		["THRESH_FAIR"] = 3,
		["THRESH_GOOD"] = 5,
		["DISPLAY_SOURCE"] = 2, -- 1=Mine, 2=all
		["DISPLAY_DESTINATION"] = 2, -- 1=Party, 2=Raid
		["MODE"] = 1, -- 1=radial, 2=chained
		["IS_NUMBER"] = false,
		["CHAIN_MAX_JUMP"] = 3,
		["COOLDOWN_SPELL"] = "",
	},

	["INC_CASTED_SECS"] = 3,
	["SHOW_INC_CASTED"] = true,
	["INC_CHANNELLED_SECS"] = 3,
	["SHOW_INC_CHANNELLED"] = true,
	["INC_HOTS_SECS"] = 3,
	["SHOW_INC_HOTS"] = true,
	["INC_BOMBED_SECS"] = 3,
	["SHOW_INC_BOMBED"] = true,

	["UPDATE_HOTS_MS"] = 250,
	["SCAN_RANGE"] = "2", -- 0=all, 2=100 yards, 3=40 yards

	["RANGE_SPELL"] = "",
	["RANGE_PESSIMISTIC"] = true,

	["IS_SHOW_GCD"] = false,
	["IS_SCAN_TALENTS"] = true,
	["IS_CLIQUE_COMPAT_MODE"] = false,
	["IS_PALLY_POWER_COMMS"] = true,
	["DIRECTION"] = {
		["enable"] = true,
		["isDistanceText"] = false,
		["isDeadOnly"] = false,
		["scale"] = 75,
	},
	["IS_DC_SHIELD_DISABLED"] = false;
};



local VUHDO_DEFAULT_CU_DE_STORED_SETTINGS = {
	["isIcon"] = true,
	["isColor"] = false,
--	["SOUND"] = "",
	["animate"] = true,
	["timer"] = true,
	["isStacks"] = true,

--	["color"] = {
--		["R"] = 0.6,
--		["G"] = 0.3,
--		["B"] = 0,
--		["O"] = 1,
--		["TR"] = 0.8,
--		["TG"] = 0.5,
--		["TB"] = 0,
--		["TO"] = 1,
--		["useText"] = true,
--		["useBackground"] = true,
--		["useOpacity"] = true,
--	},
};



VUHDO_DEFAULT_POWER_TYPE_COLORS = {
	[VUHDO_UNIT_POWER_MANA] = { ["R"] = 0, ["G"] = 0, ["B"] = 1, ["O"] = 1, ["TR"] = 0, ["TG"] = 0, ["TB"] = 1, ["TO"] = 1, ["useBackground"] = true, ["useOpacity"] = true, ["useText"] = true },
	[VUHDO_UNIT_POWER_RAGE] = { ["R"] = 1, ["G"] = 0, ["B"] = 0, ["O"] = 1, ["TR"] = 1, ["TG"] = 0, ["TB"] = 0, ["TO"] = 1, ["useBackground"] = true, ["useOpacity"] = true, ["useText"] = true  },
	[VUHDO_UNIT_POWER_FOCUS] = { ["R"] = 1, ["G"] = 0.5, ["B"] = 0.25, ["O"] = 1, ["TR"] = 1, ["TG"] = 0.5, ["TB"] = 0.25, ["TO"] = 1, ["useBackground"] = true, ["useOpacity"] = true, ["useText"] = true  },
	[VUHDO_UNIT_POWER_ENERGY] = { ["R"] = 1, ["G"] = 1, ["B"] = 0, ["O"] = 1,["TR"] = 1, ["TG"] = 1, ["TB"] = 0, ["TO"] = 1,  ["useBackground"] = true, ["useOpacity"] = true, ["useText"] = true  },
	[VUHDO_UNIT_POWER_HAPPINESS] = { ["R"] = 0, ["G"] = 1, ["B"] = 1, ["O"] = 1, ["TR"] = 0, ["TG"] = 1, ["TB"] = 1, ["TO"] = 1, ["useBackground"] = true, ["useOpacity"] = true, ["useText"] = true  },
	[VUHDO_UNIT_POWER_RUNES] = { ["R"] = 0.5, ["G"] = 0.5, ["B"] = 0.5, ["O"] = 1, ["TR"] = 0.5, ["TG"] = 0.5, ["TB"] = 0.5, ["TO"] = 1, ["useBackground"] = true, ["useOpacity"] = true, ["useText"] = true  },
};


--
function VUHDO_loadDefaultConfig()
	local tClass;
	 _, tClass = UnitClass("player");

	if (VUHDO_CONFIG == nil) then
		VUHDO_CONFIG = VUHDO_deepCopyTable(VUHDO_DEFAULT_CONFIG);

		if (VUHDO_DEFAULT_RANGE_SPELLS[tClass] ~= nil) then
			VUHDO_CONFIG["RANGE_SPELL"] = VUHDO_DEFAULT_RANGE_SPELLS[tClass];
			VUHDO_CONFIG["RANGE_PESSIMISTIC"] = false;
		end
	end

	VUHDO_CONFIG = VUHDO_ensureSanity("VUHDO_CONFIG", VUHDO_CONFIG, VUHDO_DEFAULT_CONFIG);

	if (VUHDO_CONFIG["CUSTOM_DEBUFF"].version == nil or VUHDO_CONFIG["CUSTOM_DEBUFF"].version < 2) then
		VUHDO_CONFIG["CUSTOM_DEBUFF"].version = 2;
		VUHDO_addCustomSpellIds(
			-- WotLK
			48920,  -- Drak'Tharon Keep - Grievous Bite
			23965,  -- Utgarde Keep - Frost Tomb
			48261,  -- Utgarde Pinnacle - Impale
			-- Naxx
			28622,  -- Maexxna - Web Wrap
			55550,  -- Razuvious - Jagged Knife
			27808,  -- Kel'Thuzad - Frost Blast
			-- Ulduar
			63477, -- Ignis - Slag Pot
			64234, -- XT-002 - Gravity Bomb
			63018, -- XT-002 - Searing Light
			64292, -- Kologarn - Stone Grip
			64669, -- Auriaya - Feral Pounce
			63666  -- Mimiron - Napalm Shell
		);
	end

	if (VUHDO_CONFIG["CUSTOM_DEBUFF"].version < 6) then
		VUHDO_CONFIG["CUSTOM_DEBUFF"].version = 6;

		VUHDO_addCustomSpellIds(
			-- ToC
			67478, -- Impale
			66406, -- Snobolled!
			66869, -- Burning Bile
			67618, -- Paralytic Toxin
			67049, -- Incinerate Flesh
			67297, -- Touch of Light
			66001, -- Touch of Darkness
			66013, -- Penetrating Cold
			67861 -- Acid-Drenched Mandibles
		);
	end

	if (VUHDO_CONFIG["CUSTOM_DEBUFF"].version < 7) then
		VUHDO_CONFIG["CUSTOM_DEBUFF"].version = 7;

		VUHDO_addCustomSpellIds(
			-- Ulduar
			62283, -- Iron Roots
			63134, -- Sara's Blessing
			-- ToC
			67475, -- Fire Bomb
			68123, -- Legion Flame
			67078, -- Mistress' Kiss
			66283, -- Spinning Pain Spike
			67847, -- Expose Weakness
			-- ICC
			69065, -- Impaled
			70659, -- Necrotic Strike
			72293, -- Mark of the Fallen Champion
			72385, -- Boiling Blood
			72409  -- Rune Blood
		);
	end

	if (VUHDO_CONFIG["CUSTOM_DEBUFF"].version < 9) then
		VUHDO_CONFIG["CUSTOM_DEBUFF"].version = 9;

		VUHDO_addCustomSpellIds(
			-- ICC
			72273, -- Vile Gas
			72219, -- Gastric Bloat
			69278, -- Gas Spore
			--72103, -- Inoculated
			71224, -- Mutated Infection
			72455, -- Gaseous Bloat
			70447, -- Volatile Ooze Adhesive
			72745  -- Mutated Plague
		);
	end

	if (VUHDO_CONFIG["CUSTOM_DEBUFF"].version < 10) then
		VUHDO_CONFIG["CUSTOM_DEBUFF"].version = 10;

		VUHDO_addCustomSpellIds(
			-- ICC
			72999, -- Shadow Prison
			72796, -- Glittering Sparks
			71624, -- Delirious Slash
			72638, -- Swarming Shadows
			70986, -- Shroud of Sorrow
			71340  -- Pact of the Darkfallen
		);
	end

	if (VUHDO_CONFIG["CUSTOM_DEBUFF"].version < 11) then
		VUHDO_CONFIG["CUSTOM_DEBUFF"].version = 11;

		VUHDO_addCustomSpellIds(
			-- ICC
			70867 -- Essence of the Blood Queen
		);
	end

	if (VUHDO_CONFIG["CUSTOM_DEBUFF"].version < 12) then
		VUHDO_CONFIG["CUSTOM_DEBUFF"].version = 12;

		VUHDO_addCustomSpellIds(
			-- ICC
			70751, -- Corrosion
			70633, -- Gut Spray
			70157, -- Ice Tomb
			70106, -- Chilled to the Bone
			69766, -- Instability
			69649, -- Frost Breath
			70126, -- Frost Beacon
			70541, -- Infest
			72754, -- Defile
			68980  -- Harvest Soul
		);
	end

	if (VUHDO_CONFIG["CUSTOM_DEBUFF"].version < 13) then
		VUHDO_CONFIG["CUSTOM_DEBUFF"].version = 13;

		VUHDO_addCustomSpellIds(
			-- ICC
			73912 -- Necrotic plague, Lich King
		);
	end

	local tName;
	for _, tName in pairs(VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED"]) do
		VUHDO_customDebuffsAddDefaultSettings(tName);
		VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tName] = VUHDO_ensureSanity(
			"CUSTOM_DEBUFF.STORED_SETTINGS",
			VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tName],
			VUHDO_DEFAULT_CU_DE_STORED_SETTINGS
		);
	end

	if (VUHDO_POWER_TYPE_COLORS == nil) then
		VUHDO_POWER_TYPE_COLORS = VUHDO_deepCopyTable(VUHDO_DEFAULT_POWER_TYPE_COLORS);
	end
	VUHDO_POWER_TYPE_COLORS = VUHDO_ensureSanity("VUHDO_POWER_TYPE_COLORS", VUHDO_POWER_TYPE_COLORS, VUHDO_DEFAULT_POWER_TYPE_COLORS);
end



local VUHDO_DEFAULT_PANEL_SETUP = {
	["RAID_ICON_FILTER"] = {
		[1] = true,
		[2] = true,
		[3] = true,
		[4] = true,
		[5] = true,
		[6] = true,
		[7] = true,
		[8] = true
	},

	["HOTS"] = {
		["radioValue"] = 20,
		["iconRadioValue"] = 2,
		["stacksRadioValue"] = 3,
		["font"] = "Interface\\AddOns\\VuhDo\\Fonts\\ariblk.ttf",

		["SLOTS"] = {
			["firstFlood"] = true,
		},

		["SLOTCFG"] = {
			["firstFlood"] = true,
			["1"] = { ["mine"] = true, ["others"] = false },
			["2"] = { ["mine"] = true, ["others"] = false },
			["3"] = { ["mine"] = true, ["others"] = false },
			["4"] = { ["mine"] = true, ["others"] = false },
			["5"] = { ["mine"] = true, ["others"] = false },
			["6"] = { ["mine"] = true, ["others"] = false },
			["7"] = { ["mine"] = true, ["others"] = false },
			["8"] = { ["mine"] = true, ["others"] = false },
			["9"] = { ["mine"] = true, ["others"] = false },
		},

		["BARS"] = {
			["radioValue"] = 1,
			["width"] = 25,
		},
	},

	["PANEL_COLOR"] = {
		["TEXT"] = {
			["TR"] = 1, ["TG"] = 0.82, ["TB"] = 0, ["TO"] = 1,
			["useText"] = true,
		},
		["BARS"] = {
			["R"] = 0.7, ["G"] = 0.7, ["B"] = 0.7, ["O"] = 1,
			["useBackground"] = true, ["useOpacity"] = true,
		},
		["classColorsName"] = false,
	},

	["BAR_COLORS"] = {

		["IRRELEVANT"] =  {
			["R"] = 0, ["G"] = 0, ["B"] = 0.4, ["O"] = 0.5,
			["TR"] = 1, ["TG"] = 0.82, ["TB"] = 0, ["TO"] = 1,
			["useText"] = false, ["useBackground"] = false, ["useOpacity"] = true,
		},

		["INCOMING"] = {
			["R"] = 0, ["G"] = 0, ["B"] = 0, ["O"] = 0.33,
			["TR"] = 1, ["TG"] = 0.82, ["TB"] = 0, ["TO"] = 1,
			["useText"] = false, ["useBackground"] = false,	["useOpacity"] = true,
		},

		["EMERGENCY"] = {
			["R"] = 1, ["G"] = 0, ["B"] = 0, ["O"] = 1,
			["TR"] = 1, ["TG"] = 0.82, ["TB"] = 0, ["TO"] = 1,
			["useText"] = true, ["useBackground"] = true, ["useOpacity"] = true,
		},

		["NO_EMERGENCY"] = {
			["R"] = 0, ["G"] = 0, ["B"] = 0.4, ["O"] = 1,
			["TR"] = 1, ["TG"] = 0.82, ["TB"] = 0, ["TO"] = 1,
			["useText"] = true, ["useBackground"] = true, ["useOpacity"] = true,
		},

		["OFFLINE"] = {
			["R"] = 0.298, ["G"] = 0.298, ["B"] = 0.298, ["O"] = 0.21,
			["TR"] = 0.576, ["TG"] = 0.576, ["TB"] = 0.576,
			["TO"] = 0.58, ["useText"] = true, ["useBackground"] = true, ["useOpacity"] = true,
		},

		["DEAD"] = {
			["R"] = 0.3, ["G"] = 0.3, ["B"] = 0.3, ["O"] = 0.5,
			["TR"] = 0.5, ["TG"] = 0.5, ["TB"] = 0.5, ["TO"] = 1,
			["useText"] = true, ["useBackground"] = true, ["useOpacity"] = true,
		},

		["OUTRANGED"] = {
			["R"] = 0, ["G"] = 0, ["B"] = 0, ["O"] = 0.25,
			["TR"] = 0, ["TG"] = 0, ["TB"] = 0, ["TO"] = 0.5,
			["useText"] = false, ["useBackground"] = false, ["useOpacity"] = true,
		},

		["DEBUFF" .. VUHDO_DEBUFF_TYPE_NONE] =  {
			["useText"] = false, ["useBackground"] = false, ["useOpacity"] = false,
		},

		["DEBUFF" .. VUHDO_DEBUFF_TYPE_POISON] = {
			["R"] = 0, ["G"] = 0.592, ["B"] = 0.8, ["O"] = 1,
			["TR"] = 0, ["TG"] = 1, ["TB"] = 0.686, ["TO"] = 1,
			["useText"] = true, ["useBackground"] = true, ["useOpacity"] = true,
		},

		["DEBUFF" .. VUHDO_DEBUFF_TYPE_DISEASE] = {
			["R"] = 0.8, ["G"] = 0.4, ["B"] = 0.4, ["O"] = 1,
			["TR"] = 1, ["TG"] = 0, ["TB"] = 0, ["TO"] = 1,
			["useText"] = true, ["useBackground"] = true, ["useOpacity"] = true,
		},

		["DEBUFF" .. VUHDO_DEBUFF_TYPE_CURSE] = {
			["R"] = 0.7, ["G"] = 0, ["B"] = 0.7, ["O"] = 1,
			["TR"] = 1, ["TG"] = 0, ["TB"] = 1, ["TO"] = 1,
			["useText"] = true, ["useBackground"] = true, ["useOpacity"] = true,
		},

		["DEBUFF" .. VUHDO_DEBUFF_TYPE_MAGIC] = {
			["R"] = 0.4, ["G"] = 0.4, ["B"] = 0.8, ["O"] = 1,
			["TR"] = 0.329, ["TG"] = 0.957, ["TB"] = 1, ["TO"] = 1,
			["useText"] = true, ["useBackground"] = true, ["useOpacity"] = true,
		},

		["DEBUFF" .. VUHDO_DEBUFF_TYPE_CUSTOM] = {
			["R"] = 0.6, ["G"] = 0.3, ["B"] = 0, ["O"] = 1,
			["TR"] = 0.8, ["TG"] = 0.5, ["TB"] = 0, ["TO"] = 1,
			["useText"] = true, ["useBackground"] = true, ["useOpacity"] = true,
		},

		["CHARMED"] = {
			["R"] = 0.51, ["G"] = 0.082, ["B"] = 0.263, ["O"] = 1,
			["TR"] = 1, ["TG"] = 0.31, ["TB"] = 0.31, ["TO"] = 1,
			["useText"] = true, ["useBackground"] = true, ["useOpacity"] = true,
		},

		["BAR_FRAMES"] = {
			["R"] = 0, ["G"] = 0, ["B"] = 0, ["O"] = 0.7,
			["useBackground"] = true, ["useOpacity"] = true,
		},

		["OVERHEAL_TEXT"] = {
			["TR"] = 0.8, ["TG"] = 1, ["TB"] = 0.8, ["TO"] = 1,
			["useText"] = true, ["useOpacity"] = true,
		},

		["HOTS"] = {
			["useColorText"] = true,
			["useColorBack"] = true,
			["isFadeOut"] = false,
			["showShieldAbsorb"] = false,

			["TEXT"] = {
				["shadow"] = false,
				["outline"] = true,
			},

			["WARNING"] = {
				["R"] = 0.5,
				["G"] = 0.2,
				["B"] = 0.2,
				["O"] = 1,
				["TR"] = 1,
				["TG"] = 0.6,
				["TB"] = 0.6,
				["TO"] = 1,
				["useText"] = true,
				["useBackground"] = true,
				["lowSecs"] = 3,
				["enabled"] = false,
			},
		},

		["HOT1"] = {
			["R"] = 1, ["G"] = 0.3, ["B"] = 0.3, ["O"] = 1,
			["TR"] = 1, ["TG"] = 0.6, ["TB"] = 0.6, ["TO"] = 1,
			["useBackground"] = true, ["useText"] = true,
			["isFullDuration"] = false, ["countdownMode"] = 1,
		},

		["HOT2"] = {
			["R"] = 1, ["G"] = 1, ["B"] = 0.3, ["O"] = 1,
			["TR"] = 1, ["TG"] = 1, ["TB"] = 0.6, ["TO"] = 1,
			["useBackground"] = true, ["useText"] = true,
			["isFullDuration"] = false,	["countdownMode"] = 1,
		},

		["HOT3"] = {
			["R"] = 1, ["G"] = 1, ["B"] = 1, ["O"] = 1,
			["TR"] = 1, ["TG"] = 1, ["TB"] = 1, ["TO"] = 1,
			["useBackground"] = true, ["useText"] = true,
			["isFullDuration"] = false, ["countdownMode"] = 1,
		},

		["HOT4"] = {
			["R"] = 0.3, ["G"] = 0.3, ["B"] = 1, ["O"] = 1,
			["TR"] = 0.6, ["TG"] = 0.6, ["TB"] = 1, ["TO"] = 1,
			["useBackground"] = true, ["useText"] = true,
			["isFullDuration"] = false, ["countdownMode"] = 1,
		},

		["HOT5"] = {
			["R"] = 1, ["G"] = 0.3, ["B"] = 1, ["O"] = 1,
			["TR"] = 1, ["TG"] = 0.6, ["TB"] = 1, ["TO"] = 1,
			["useBackground"] = true, ["useText"] = true,
			["isFullDuration"] = false, ["countdownMode"] = 1,
		},

		["HOT6"] = {
			["R"] = 1, ["G"] = 1, ["B"] = 1, ["O"] = 0.75,
			["useBackground"] = true,
		},

		["HOT7"] = {
			["R"] = 1, ["G"] = 1, ["B"] = 1, ["O"] = 0.75,
			["useBackground"] = true,
		},

		["HOT8"] = {
			["R"] = 1, ["G"] = 1, ["B"] = 1, ["O"] = 0.75,
			["useBackground"] = true,
		},

		["HOT9"] = {
			["R"] = 0.3, ["G"] = 1, ["B"] = 1, ["O"] = 1,
			["TR"] = 0.6, ["TG"] = 1, ["TB"] = 1, ["TO"] = 1,
			["useBackground"] = true,	["useText"] = true,
			["isFullDuration"] = false,	["countdownMode"] = 1,
		},


		["HOT_CHARGE_2"] = {
			["R"] = 1, ["G"] = 1, ["B"] = 0.3, ["O"] = 1,
			["TR"] = 1, ["TG"] = 1, ["TB"] = 0.6, ["TO"] = 1,
			["useBackground"] = true, ["useText"] = true,
		},

		["HOT_CHARGE_3"] = {
			["R"] = 0.3, ["G"] = 1, ["B"] = 0.3, ["O"] = 1,
			["TR"] = 0.6, ["TG"] = 1, ["TB"] = 0.6, ["TO"] = 1,
			["useBackground"] = true, ["useText"] = true,
		},

		["HOT_CHARGE_4"] = {
			["R"] = 0.8, ["G"] = 0.8, ["B"] = 0.8, ["O"] = 1,
			["TR"] = 1, ["TG"] = 1, ["TB"] = 1, ["TO"] = 1,
			["useBackground"] = true, ["useText"] = true,
		},

		["useDebuffIcon"] = false,

		["RAID_ICONS"] = {
			["enable"] = false,
			["filterOnly"] = false,

			["3"] = {
				["TG"] = 0.674,
				["R"] = 0.788,
				["TB"] = 0.921,
				["G"] = 0.290,
				["TR"] = 1,
				["TO"] = 1,
				["B"] = 0.8,
				["useBackground"] = true,
				["O"] = 1,
				["useText"] = true,
			},
			["2"] = {
				["TG"] = 0.827,
				["R"] = 1,
				["TB"] = 0.419,
				["G"] = 0.513,
				["TR"] = 1,
				["TO"] = 1,
				["B"] = 0.039,
				["useBackground"] = true,
				["O"] = 1,
				["useText"] = true,
			},
			["5"] = {
				["TG"] = 0.870,
				["R"] = 0.466,
				["TB"] = 1,
				["G"] = 0.717,
				["TR"] = 0.725,
				["TO"] = 1,
				["B"] = 0.8,
				["useBackground"] = true,
				["O"] = 1,
				["useText"] = true,
			},
			["4"] = {
				["TG"] = 1,
				["R"] = 0,
				["TB"] = 0.698,
				["G"] = 0.8,
				["TR"] = 0.698,
				["TO"] = 1,
				["B"] = 0.015,
				["useBackground"] = true,
				["O"] = 1,
				["useText"] = true,
			},
			["7"] = {
				["TG"] = 0.627,
				["R"] = 0.8,
				["TB"] = 0.619,
				["G"] = 0.184,
				["TR"] = 1,
				["TO"] = 1,
				["B"] = 0.129,
				["useBackground"] = true,
				["O"] = 1,
				["useText"] = true,
			},
			["6"] = {
				["TG"] = 0.831,
				["R"] = 0.121,
				["TB"] = 1,
				["G"] = 0.690,
				["TR"] = 0.662,
				["TO"] = 1,
				["B"] = 0.972,
				["useBackground"] = true,
				["O"] = 1,
				["useText"] = true,
			},
			["8"] = {
				["TG"] = 0.231,
				["R"] = 0.847,
				["TB"] = 0.231,
				["G"] = 0.866,
				["TR"] = 0.231,
				["TO"] = 1,
				["B"] = 0.890,
				["useBackground"] = true,
				["O"] = 1,
				["useText"] = true,
			},
			["1"] = {
				["TG"] = 1,
				["R"] = 1,
				["TB"] = 0.607,
				["G"] = 0.976,
				["TR"] = 0.980,
				["TO"] = 1,
				["useBackground"] = true,
				["useText"] = true,
				["O"] = 1,
				["B"] = 0.305,
			},
		},

		["CLUSTER_FAIR"] = {
			["R"] = 0.8, ["G"] = 0.8, ["B"] = 0, ["O"] = 1,
			["TR"] = 1, ["TG"] = 1, ["TB"] = 0, ["TO"] = 1,
			["useBackground"] = true, ["useText"] = true,
		},

		["CLUSTER_GOOD"] = {
			["R"] = 0, ["G"] = 0.8, ["B"] = 0, ["O"] = 1,
			["TR"] = 0, ["TG"] = 1, ["TB"] = 0, ["TO"] = 1,
			["useBackground"] = true, ["useText"] = true,
		},

		["GCD_BAR"] = {
			["R"] = 0.4, ["G"] = 0.4, ["B"] = 0.4, ["O"] = 0.5,
			["useBackground"] = true,
		},

		["LIFE_LEFT"] = {
			["LOW"] = {
				["R"] = 1, ["G"] = 0, ["B"] = 0, ["O"] = 1,
				["useBackground"] = true,
			},
			["FAIR"] = {
				["R"] = 1, ["G"] = 1, ["B"] = 0, ["O"] = 1,
				["useBackground"] = true,
			},
			["GOOD"] = {
				["R"] = 0, ["G"] = 1, ["B"] = 0, ["O"] = 1,
				["useBackground"] = true,
			},
		},

		["THREAT"] = {
			["HIGH"] = {
				["R"] = 1, ["G"] = 0, ["B"] = 1, ["O"] = 1,
				["useBackground"] = true,
			},
			["LOW"] = {
				["R"] = 0, ["G"] = 1, ["B"] = 1, ["O"] = 1,
				["useBackground"] = true,
			},
		},
	}, -- BAR_COLORS
};



local VUHDO_DEFAULT_PER_PANEL_SETUP = {
	["HOTS"] = {
		["size"] = 76,
		["textSize"] = 100,
	},
	["MODEL"] = {
		["ordering"] = VUHDO_ORDERING_STRICT,
		["sort"] = VUHDO_SORT_RAID_UNITID,
		["isReverse"] = false,
	},

	["POSITION"] = {
		["x"] = 100,
		["y"] = 668,
		["relativePoint"] = "BOTTOMLEFT",
		["orientation"] = "TOPLEFT",
		["growth"] = "TOPLEFT",
		["width"] = 200,
		["height"] = 200,
		["scale"] = 1,
	};

	["SCALING"] = {
		["columnSpacing"] = 5,
		["rowSpacing"] = 2,

		["borderGapX"] = 5,
		["borderGapY"] = 5,

		["barWidth"] = 75,
		["barHeight"] = 25,

		["showHeaders"] = true,
		["headerHeight"] = 20,
		["headerWidth"] = 33,
		["headerSpacing"] = 5,

		["manaBarHeight"] = 3,

		["maxColumnsWhenStructured"] = 8,
		["maxRowsWhenLoose"] = 6,
		["ommitEmptyWhenStructured"] = false,
		["isPlayerOnTop"] = true,

		["showTarget"] = false,
		["targetSpacing"] = 3,
		["targetWidth"] = 30,

		["showTot"] = false,
		["totSpacing"] = 3,
		["totWidth"] = 30,
		["targetOrientation"] = 1;

		["arrangeHorizontal"] = false,
		["alignBottom"] = false,

		["scale"] = 1,

		["isDamFlash"] = true,
		["damFlashFactor"] = 0.75,
	},

	["LIFE_TEXT"] = {
		["show"] = true,
		["mode"] = VUHDO_LT_MODE_PERCENT,
		["position"] = VUHDO_LT_POS_ABOVE,
		["verbose"] = false,
		["hideIrrelevant"] = false,
	},

	["ID_TEXT"] = {
		["showName"] = true,
		["showClass"] = false,
		["showTags"] = true,
		["showPetOwners"] = true,
		["position"] = "BOTTOMRIGHT+BOTTOMRIGHT",
	},

	["PANEL_COLOR"] = {
		["barTexture"] = "VuhDo - Polished Wood",

		["BACK"] = {
			["R"] = 0, ["G"] = 0, ["B"] = 0, ["O"] = 0.4,
			["useBackground"] = true, ["useOpacity"] = true,
		},

		["BORDER"] = {
			["R"] = 0, ["G"] = 0, ["B"] = 0, ["O"] = 0.46,
			["useBackground"] = true, ["useOpacity"] = true,
			["file"] = "Interface\\Tooltips\\UI-Tooltip-Border",
			["edgeSize"] = 8,
			["insets"] = 1,
		},

		["TEXT"] = {
			["useText"] = true, ["useOpacity"] = true,
			["textSize"] = 10,
			["textSizeLife"] = 8,
			["maxChars"] = 0,
			["outline"] = false,
		},

		["HEADER"] = {
			["R"] = 0.6, ["G"] = 0.6, ["B"] = 0.6, ["O"] = 0.6,
			["TR"] = 1, ["TG"] = 0.859, ["TB"] = 0.38, ["TO"] = 1,
			["useText"] = true, ["useBackground"] = true,
			["barTexture"] = "VuhDo - Concave, dark",
			["textSize"] = 10,
		},

		["classColorsHeader"] = false,
		["classColorsBackHeader"] = false,

		["TARGET"] = {
			["TR"] = 1,	["TG"] = 1,	["TB"] = 1,	["TO"] = 1,
			["useText"] = true,
		},

		["TOT"] = {
			["TR"] = 1,	["TG"] = 1,	["TB"] = 1,	["TO"] = 1,
			["useText"] = true,
		},
	},

	["TOOLTIP"] = {
		["show"] = true,
		["position"] = 2, -- Standard-Pos
		["inFight"] = false,
		["showBuffs"] = false,
		["x"] = 100,
		["y"] = -100,
		["point"] = "TOPLEFT",
		["relativePoint"] = "TOPLEFT",
		["SCALE"] = 1,

		["BACKGROUND"] = {
			["R"] = 0, ["G"] = 0, ["B"] = 0, ["O"] = 1,
			["useBackground"] = true, ["useOpacity"] = true,
		},

		["BORDER"] = {
			["R"] = 0, ["G"] = 0, ["B"] = 0, ["O"] = 1,
			["useBackground"] = true, ["useOpacity"] = true,
		},
	},

	["RAID_ICON"] = {
		["show"] = true,
		["scale"] = 1,
		["point"] = "TOP",
		["xAdjust"] = 0,
		["yAdjust"] = -20,
	},

	["OVERHEAL_TEXT"] = {
		["show"] = true,
		["scale"] = 1,
		["point"] = "LEFT",
		["xAdjust"] = 0,
		["yAdjust"] = 0,
	},
}



--
function VUHDO_loadDefaultPanelSetup()
	local tPanelNum;
	local tAktPanel;

	if (VUHDO_PANEL_SETUP == nil) then
		VUHDO_PANEL_SETUP = VUHDO_deepCopyTable(VUHDO_DEFAULT_PANEL_SETUP);
	end

	for tPanelNum = 1, VUHDO_MAX_PANELS do
		if (VUHDO_PANEL_SETUP[tPanelNum] == nil) then
			VUHDO_PANEL_SETUP[tPanelNum] = VUHDO_deepCopyTable(VUHDO_DEFAULT_PER_PANEL_SETUP);

			tAktPanel = VUHDO_PANEL_SETUP[tPanelNum];
			tAktPanel["MODEL"]["groups"] = VUHDO_DEFAULT_MODELS[tPanelNum];

			if (VUHDO_DEFAULT_MODELS[tPanelNum] ~= nil and VUHDO_ID_MAINTANKS == VUHDO_DEFAULT_MODELS[tPanelNum][1]) then
				tAktPanel["SCALING"].barWidth = 100;
				tAktPanel["SCALING"].barHeight = 26;
				tAktPanel["SCALING"].showTarget = true;
			else
				if (VUHDO_DEFAULT_MODELS[tPanelNum] ~= nil and VUHDO_ID_PETS == VUHDO_DEFAULT_MODELS[tPanelNum][1]) then
					tAktPanel["MODEL"].ordering = VUHDO_ORDERING_LOOSE;
				elseif (VUHDO_DEFAULT_MODELS[tPanelNum] ~= nil and VUHDO_ID_PRIVATE_TANKS == VUHDO_DEFAULT_MODELS[tPanelNum][1]) then
					tAktPanel["SCALING"].showTarget = true;
				else
					tAktPanel["SCALING"].ommitEmptyWhenStructured = true;
				end
			end

			if (GetLocale() == "zhCN" or GetLocale() == "zhTW" or GetLocale() == "koKR") then
				tAktPanel["PANEL_COLOR"]["TEXT"].font = "";
				tAktPanel["PANEL_COLOR"]["HEADER"].font = "";
			else
				tAktPanel["PANEL_COLOR"]["TEXT"].font = VUHDO_LibSharedMedia:Fetch('font', "Emblem");
				tAktPanel["PANEL_COLOR"]["HEADER"].font = VUHDO_LibSharedMedia:Fetch('font', "Emblem");
			end

			if (VUHDO_DEFAULT_MODELS[tPanelNum] ~= nil and VUHDO_ID_MAINTANKS == VUHDO_DEFAULT_MODELS[tPanelNum][1]) then
				tAktPanel["PANEL_COLOR"]["TEXT"].textSize = 12;
			end
		end
	end

	for tPanelNum = 1, VUHDO_MAX_PANELS do
		if (VUHDO_PANEL_SETUP[tPanelNum]["POSITION"] == nil) then
			VUHDO_PANEL_SETUP[tPanelNum]["POSITION"] = {
				["x"] = 100 + 30 * tPanelNum,
				["y"] = 668 - 30 * tPanelNum,
				["relativePoint"] = "BOTTOMLEFT",
				["orientation"] = "TOPLEFT",
				["growth"] = "TOPLEFT",
				["width"] = 200,
				["height"] = 200,
				["scale"] = 1,
			};
		end

		VUHDO_PANEL_SETUP[tPanelNum] = VUHDO_ensureSanity("VUHDO_PANEL_SETUP[" .. tPanelNum .. "]", VUHDO_PANEL_SETUP[tPanelNum], VUHDO_DEFAULT_PER_PANEL_SETUP);
	end

	VUHDO_PANEL_SETUP = VUHDO_ensureSanity("VUHDO_PANEL_SETUP", VUHDO_PANEL_SETUP, VUHDO_DEFAULT_PANEL_SETUP);
	VUHDO_fixHotSettings();
end



local VUHDO_DEFAULT_BUFF_CONFIG = {
	["SHOW"] = true,
	["COMPACT"] = true,
	["SHOW_LABEL"] = false,
	["SHOW_EMPTY"] = false,
	["BAR_COLORS_TEXT"] = true,
	["BAR_COLORS_BACKGROUND"] = true,
	["BAR_COLORS_IN_FIGHT"] = false,
	["HIDE_CHARGES"] = false,
	["REFRESH_SECS"] = 1,
	["POSITION"] = {
		["x"] = 100,
		["y"] = -100,
		["point"] = "TOPLEFT",
		["relativePoint"] = "TOPLEFT",
	},
	["SCALE"] = 1,
	["SWATCH_MAX_ROWS"] = 2,
	["PANEL_MAX_BUFFS"] = 5,
	["AT_LEAST_MISSING"] = 2,
	["PANEL_BG_COLOR"] = {
		["R"] = 0, ["G"] = 0,	["B"] = 0, ["O"] = 0.5,
		["useText"] = false, ["useBackground"] = true, ["useOpacity"] = false,
	},
	["PANEL_BORDER_COLOR"] = {
		["R"] = 0, ["G"] = 0,	["B"] = 0, ["O"] = 0.5,
		["useText"] = false, ["useBackground"] = true, ["useOpacity"] = false,
	},
	["SWATCH_BG_COLOR"] = {
		["R"] = 0, ["G"] = 0,	["B"] = 0, ["O"] = 1,
		["useText"] = false, ["useBackground"] = true, ["useOpacity"] = false,
	},
	["SWATCH_BORDER_COLOR"] = {
		["R"] = 0.8, ["G"] = 0.8,	["B"] = 0.8, ["O"] = 0,
		["useText"] = false, ["useBackground"] = true, ["useOpacity"] = false,
	},
	["GROUP_SPELL_VERSION"] = "smart",
	["REBUFF_AT_PERCENT"] = 25,
	["REBUFF_MIN_MINUTES"] = 3,
	["HIGHLIGHT_COOLDOWN"] = true,
	["WHEEL_SMART_BUFF"] = false,

	["SWATCH_COLOR_BUFF_OKAY"] = {
		["R"] = 0, ["G"] = 0,	["B"] = 0,
		["TR"] = 0, ["TG"] = 0.8,	["TB"] = 0,
		["O"] = 1, ["TO"] = 1,
		["useText"] = true, ["useBackground"] = true, ["useOpacity"] = true,
	},
	["SWATCH_COLOR_BUFF_LOW"] = {
		["R"] = 0, ["G"] = 0,	["B"] = 0,
		["TR"] = 1.0, ["TG"] = 0.7,	["TB"] = 0,
		["O"] = 1, ["TO"] = 1,
		["useText"] = true, ["useBackground"] = true, ["useOpacity"] = true,
	},
	["SWATCH_COLOR_BUFF_OUT"] = {
		["R"] = 0, ["G"] = 0,	["B"] = 0,
		["TR"] = 0.8, ["TG"] = 0,	["TB"] = 0,
		["O"] = 1, ["TO"] = 1,
		["useText"] = true, ["useBackground"] = true, ["useOpacity"] = true,
	},
	["SWATCH_COLOR_BUFF_COOLDOWN"] = {
		["R"] = 0.3, ["G"] = 0.3,	["B"] = 0.3,
		["TR"] = 0.6, ["TG"] = 0.6,	["TB"] = 0.6,
		["O"] = 1, ["TO"] = 1,
		["useText"] = true, ["useBackground"] = true, ["useOpacity"] = true,
	},
	["SWATCH_COLOR_OUT_RANGE"] = {
		["R"] = 0, ["G"] = 0,	["B"] = 0,
		["TR"] = 0, ["TG"] = 0,	["TB"] = 0,
		["O"] = 0.5, ["TO"] = 0.5,
		["useText"] = true, ["useBackground"] = true, ["useOpacity"] = true,
	},
	["SWATCH_EMPTY_GROUP"] = {
		["R"] = 0, ["G"] = 0,	["B"] = 0,
		["TR"] = 0.8, ["TG"] = 0.8,	["TB"] = 0.8,
		["O"] = 0.5, ["TO"] = 0.6,
		["useText"] = true, ["useBackground"] = true, ["useOpacity"] = true,
	},
}



VUHDO_DEFAULT_USER_CLASS_COLORS = {
	[VUHDO_ID_DRUIDS] =       { ["R"]  = 1,    ["G"]  = 0.49, ["B"]  = 0.04, ["O"] = 1, ["useBackground"] = true, ["useOpacity"] = true,
															["TR"] = 1,    ["TG"] = 0.6,  ["TB"] = 0.04, ["TO"] = 1, ["useText"] = true },

	[VUHDO_ID_HUNTERS] =      { ["R"]  = 0.67, ["G"]  = 0.83, ["B"]  = 0.45, ["O"] = 1, ["useBackground"] = true, ["useOpacity"] = true,
															["TR"] = 0.77, ["TG"] = 0.93, ["TB"] = 0.55, ["TO"] = 1, ["useText"] = true 	},

	[VUHDO_ID_MAGES] =        { ["R"]  = 0.41, ["G"]  = 0.8,  ["B"]  = 0.94, ["O"] = 1, ["useBackground"] = true, ["useOpacity"] = true,
															["TR"] = 0.51, ["TG"] = 0.9,  ["TB"] = 1,    ["TO"] = 1, ["useText"] = true  },

	[VUHDO_ID_PALADINS] =     { ["R"]  = 0.96, ["G"]  = 0.55, ["B"]  = 0.73, ["O"] = 1, ["useBackground"] = true, ["useOpacity"] = true,
															["TR"] = 1   , ["TG"] = 0.65, ["TB"] = 0.83, ["TO"] = 1, ["useText"] = true  },

	[VUHDO_ID_PRIESTS] =      { ["R"]  = 0.9,  ["G"]  = 0.9,  ["B"]  = 0.9,  ["O"] = 1, ["useBackground"] = true, ["useOpacity"] = true,
															["TR"] = 1,    ["TG"] = 1,    ["TB"] = 1,    ["TO"] = 1, ["useText"] = true  },

	[VUHDO_ID_ROGUES] =       { ["R"]  = 1,    ["G"]  = 0.96, ["B"]  = 0.41, ["O"] = 1, ["useBackground"] = true, ["useOpacity"] = true,
															["TR"] = 1,    ["TG"] = 1,    ["TB"] = 0.51, ["TO"] = 1, ["useText"] = true  },

	[VUHDO_ID_SHAMANS] =      { ["R"]  = 0.14, ["G"]  = 0.35, ["B"]  = 1,    ["O"] = 1, ["useBackground"] = true, ["useOpacity"] = true,
															["TR"] = 0.24, ["TG"] = 0.45, ["TB"] = 1,    ["TO"] = 1, ["useText"] = true  },

	[VUHDO_ID_WARLOCKS] =     { ["R"]  = 0.58, ["G"]  = 0.51, ["B"]  = 0.79, ["O"] = 1, ["useBackground"] = true, ["useOpacity"] = true,
															["TR"] = 0.68, ["TG"] = 0.61, ["TB"] = 0.89, ["TO"] = 1, ["useText"] = true  },

	[VUHDO_ID_WARRIORS] =     { ["R"]  = 0.78, ["G"]  = 0.61, ["B"]  = 0.43, ["O"] = 1, ["useBackground"] = true, ["useOpacity"] = true,
															["TR"] = 0.88, ["TG"] = 0.71, ["TB"] = 0.53, ["TO"] = 1, ["useText"] = true  },

	[VUHDO_ID_DEATH_KNIGHT] = { ["R"]  = 0.77, ["G"]  = 0.12, ["B"]  = 0.23, ["O"] = 1, ["useBackground"] = true, ["useOpacity"] = true,
															["TR"] = 0.87, ["TG"] = 0.22, ["TB"] = 0.33, ["TO"] = 1, ["useText"] = true  },

	[VUHDO_ID_PETS] =         { ["R"]  = 0.4,  ["G"]  = 0.6,  ["B"]  = 0.4,    ["O"] = 1, ["useBackground"] = true, ["useOpacity"] = true,
															["TR"] = 0.5,    ["TG"] = 0.9,    ["TB"] = 0.5,    ["TO"] = 1, ["useText"] = true  },

	["petClassColor"] = false,
}



--
function VUHDO_initClassColors()
	if (VUHDO_USER_CLASS_COLORS == nil) then
		VUHDO_USER_CLASS_COLORS = VUHDO_deepCopyTable(VUHDO_DEFAULT_USER_CLASS_COLORS);
	end
	VUHDO_USER_CLASS_COLORS = VUHDO_ensureSanity("VUHDO_USER_CLASS_COLORS", VUHDO_USER_CLASS_COLORS, VUHDO_DEFAULT_USER_CLASS_COLORS);
end



--
function VUHDO_initBuffSettings()

	if (VUHDO_BUFF_SETTINGS["CONFIG"] == nil) then
		VUHDO_BUFF_SETTINGS["CONFIG"] = VUHDO_deepCopyTable(VUHDO_DEFAULT_BUFF_CONFIG);
	end
	VUHDO_BUFF_SETTINGS["CONFIG"] = VUHDO_ensureSanity("VUHDO_BUFF_SETTINGS.CONFIG", VUHDO_BUFF_SETTINGS["CONFIG"], VUHDO_DEFAULT_BUFF_CONFIG);

	local _, tPlayerClass = UnitClass("player");
	local tAllClassBuffs = VUHDO_CLASS_BUFFS[tPlayerClass];
	local tCategSepc, tCategName;
	if (tAllClassBuffs ~= nil) then
		for tCategSpec, _ in pairs(tAllClassBuffs) do

			tCategName = strsub(tCategSpec, 3);

			if (VUHDO_BUFF_SETTINGS[tCategName] == nil) then
				VUHDO_BUFF_SETTINGS[tCategName] = {
					["enabled"] = false,
					["missingColor"] = {
						["show"] = false,
						["R"] = 1, ["G"] = 1, ["B"] = 1, ["O"] = 1,
						["TR"] = 1, ["TG"] = 1, ["TB"] = 1, ["TO"] = 1,
						["useText"] = true, ["useBackground"] = true, ["useOpacity"] = true,
					}
				};
			end

			if (VUHDO_BUFF_SETTINGS[tCategName]["filter"] == nil) then
				VUHDO_BUFF_SETTINGS[tCategName]["filter"] = { [VUHDO_ID_ALL] = true };
			end
		end
	end

	local tAllBuffs = VUHDO_CLASS_BUFFS[VUHDO_PLAYER_CLASS];
	if (tAllBuffs ~= nil) then
		local tCategoryName, tAllCategoryBuffs;
		for tCategoryName, tAllCategoryBuffs in pairs(tAllBuffs) do
			if (VUHDO_BUFF_ORDER[tCategoryName] == nil) then
				local tNumber = tonumber(strsub(tCategoryName, 1, 2));
				VUHDO_BUFF_ORDER[tCategoryName] = tNumber;
			end
		end
	end

	VUHDO_REFRESH_BUFFS_TIMER = VUHDO_BUFF_SETTINGS["CONFIG"]["REFRESH_SECS"];
end
