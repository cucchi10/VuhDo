VUHDO_MAX_HOTS = 0;
VUHDO_ACTIVE_HOTS = { };
VUHDO_ACTIVE_HOTS_OTHERS = { };
VUHDO_PLAYER_HOTS = { };

local VUHDO_SPELL_TARGET_SELF = 1;            -- Heal target is player
local VUHDO_SPELL_TARGET_TARGET = 2;					-- Heal target is selected target
local VUHDO_SPELL_TARGET_GROUP_OWN = 3;       -- Heal target is players group
local VUHDO_SPELL_TARGET_GROUP_TARGET = 4;    -- Heal target is selected target's group
local VUHDO_SPELL_TARGET_SELF_TARGET = 5;     -- Heal target is player and selected target
local VUHDO_SPELL_TARGET_PET = 6;             -- Heal target is player's pet


VUHDO_SPELL_TYPE_HOT = 1;  -- Spell type heal over time
VUHDO_SPELL_TYPE_CAST = 2; -- Spell type is regular cast
VUHDO_SPELL_TYPE_CAST_HOT = 3; -- Spell type is regular cast + HoT



VUHDO_GCD_SPELLS = {
	["WARRIOR"] = GetSpellInfo(78), -- Heroic Strike
	["ROGUE"] = GetSpellInfo(1752), -- Sinister Strike
	["HUNTER"] = GetSpellInfo(1494), -- Track beasts
	["PALADIN"] = GetSpellInfo(635), -- Holy Light
	["MAGE"] = GetSpellInfo(133), -- Fire Ball
	["WARLOCK"] = GetSpellInfo(686), -- Shadow Bolt
	["SHAMAN"] = GetSpellInfo(331), --  Healing Wave
	["DRUID"] = GetSpellInfo(5185), -- Healing Touch
	["PRIEST"] = GetSpellInfo(2050), -- Lesser Heal
	["DEATHKNIGHT"] = GetSpellInfo(48266), -- Blood Presence
}



local twipe = table.wipe;
local GetSpellName = GetSpellName;
local GetSpellInfo = GetSpellInfo;
local pairs = pairs;


-- target
-- type
-- casttime (auto)
-- regulartime
-- lasts
-- nobonus
-- icon (auto)
-- present (auto)
-- <rangx>.average (auto)
-- <rangx>.level { }
-- <rangx>.present (auto)
-- <rangx>.bonus


-- All healing spells and their ranks we will take notice of
VUHDO_SPELLS = {
	-- Paladin
  [VUHDO_SPELL_ID_FLASH_OF_LIGHT] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_CAST_HOT,
  },
  [VUHDO_SPELL_ID_HOLY_LIGHT] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_CAST,
  },
	[VUHDO_SPELL_ID_BUFF_BEACON_OF_LIGHT] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_HOT,
	},
	[VUHDO_SPELL_ID_SACRED_SHIELD] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_HOT,
	},

  -- Priest
  [VUHDO_SPELL_ID_FLASH_HEAL] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_CAST,
  },
  [VUHDO_SPELL_ID_RENEW] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_HOT,
  },
  [VUHDO_SPELL_ID_LESSER_HEAL] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_CAST,
  },
  [VUHDO_SPELL_ID_HEAL] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_CAST,
  },
  [VUHDO_SPELL_ID_GREATER_HEAL] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_CAST,
  },
  [VUHDO_SPELL_ID_BINDING_HEAL] = {
  	["target"] = VUHDO_SPELL_TARGET_SELF_TARGET,
		["type"] = VUHDO_SPELL_TYPE_CAST,
  },
  [VUHDO_SPELL_ID_PRAYER_OF_HEALING] = {
  	["target"] = VUHDO_SPELL_TARGET_GROUP_OWN,
		["type"] = VUHDO_SPELL_TYPE_CAST,
  },
  [VUHDO_SPELL_ID_CIRCLE_OF_HEALING] = {
  	["target"] = VUHDO_SPELL_TARGET_GROUP_TARGET,
		["type"] = VUHDO_SPELL_TYPE_CAST,
  },
  [VUHDO_SPELL_ID_POWERWORD_SHIELD] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_HOT,
		["nostance"] = true,
  },
  [VUHDO_SPELL_ID_PRAYER_OF_MENDING] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_HOT,
  },
  [VUHDO_SPELL_ID_DIVINE_AEGIS] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_HOT,
		["nodefault"] = true,
  },
  [VUHDO_SPELL_ID_PAIN_SUPPRESSION] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_HOT,
		["nodefault"] = true,
		["nostance"] = true,
  },
  [VUHDO_SPELL_ID_GRACE] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_HOT,
 		["nodefault"] = true,
  },
  [VUHDO_SPELL_ID_GUARDIAN_SPIRIT] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_HOT,
		["nohelp"] = true,
		["noselftarget"] = true,
  },
  [VUHDO_SPELL_ID_ABOLISH_DISEASE] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_HOT,
		["nohelp"] = true,
		["noselftarget"] = true,
  },
  [VUHDO_SPELL_ID_RENEWED_HOPE] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_HOT,
		["nodefault"] = true,
  },
  [VUHDO_SPELL_ID_INSPIRATION] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_HOT,
		["nodefault"] = true,
  },
  [VUHDO_SPELL_ID_BLESSED_HEALING] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_HOT,
		["nodefault"] = true,
  },

  -- Shaman
  [VUHDO_SPELL_ID_HEALING_WAVE] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_CAST,
  },
  [VUHDO_SPELL_ID_LESSER_HEALING_WAVE] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_CAST,
  },
  [VUHDO_SPELL_ID_CHAIN_HEAL] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_CAST,
  },
  [VUHDO_SPELL_ID_RIPTIDE] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_HOT,
  },
  [VUHDO_SPELL_ID_BUFF_EARTHLIVING_WEAPON] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_HOT,
  },
  [VUHDO_SPELL_ID_GIFT_OF_THE_NAARU] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_HOT,
	},
  [VUHDO_SPELL_ID_BUFF_EARTH_SHIELD] = {
  	["target"] = VUHDO_BUFF_TARGET_UNIQUE,
		["type"] = VUHDO_SPELL_TYPE_HOT,
	},
  [VUHDO_SPELL_ID_ANCESTRAL_HEALING] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_HOT,
	},
  [VUHDO_SPELL_ID_BUFF_WATER_SHIELD] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_HOT,
	},

  -- Druid
  [VUHDO_SPELL_ID_REJUVENATION] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_HOT,
  },
  [VUHDO_SPELL_ID_HEALING_TOUCH] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_CAST,
  },
  [VUHDO_SPELL_ID_NOURISH] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_CAST,
  },
  [VUHDO_SPELL_ID_REGROWTH] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_HOT,
  },
  [VUHDO_SPELL_ID_LIFEBLOOM] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_HOT,
  },
  [VUHDO_SPELL_ID_WILD_GROWTH] = {
  	["target"] = VUHDO_SPELL_TARGET_GROUP_OWN,
		["type"] = VUHDO_SPELL_TYPE_HOT,
	},
  [VUHDO_SPELL_ID_ABOLISH_POISON] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_HOT,
  },
  [VUHDO_SPELL_ID_SWIFTMEND] = {
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
		["type"] = VUHDO_SPELL_TYPE_CAST,
  },

  -- Hunter
  [VUHDO_SPELL_ID_MEND_PET] = {
  	["target"] = VUHDO_SPELL_TARGET_PET,
		["type"] = VUHDO_SPELL_TYPE_HOT,
  },

  -- custom
  [VUHDO_SPELL_ID_POAK] = { -- Weapon proc
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
 		["type"] = VUHDO_SPELL_TYPE_HOT,
 		["nodefault"] = true,
  },
  [VUHDO_SPELL_ID_FOUNTAIN_OF_LIGHT] = { -- Weapon proc
  	["target"] = VUHDO_SPELL_TARGET_TARGET,
 		["type"] = VUHDO_SPELL_TYPE_HOT,
 		["nodefault"] = true,
  }
};
local VUHDO_SPELLS = VUHDO_SPELLS;



-- Spells from talents only, not in spellbook
local function VUHDO_addTalentSpells()
	if (VUHDO_PLAYER_CLASS == "SHAMAN") then
		VUHDO_SPELLS[VUHDO_SPELL_ID_ANCESTRAL_HEALING]["present"] = true;
		VUHDO_SPELLS[VUHDO_SPELL_ID_ANCESTRAL_HEALING]["icon"] = "Interface\\Icons\\Spell_Nature_UndyingStrength";
	end

	if (VUHDO_PLAYER_CLASS == "PRIEST") then
		VUHDO_SPELLS[VUHDO_SPELL_ID_GRACE]["present"] = true;
		VUHDO_SPELLS[VUHDO_SPELL_ID_GRACE]["icon"] = "Interface\\Icons\\Spell_Holy_Hopeandgrace";

		VUHDO_SPELLS[VUHDO_SPELL_ID_DIVINE_AEGIS]["present"] = true;
		VUHDO_SPELLS[VUHDO_SPELL_ID_DIVINE_AEGIS]["icon"] = "Interface\\Icons\\Spell_Holy_DevineAegis";

		VUHDO_SPELLS[VUHDO_SPELL_ID_RENEWED_HOPE]["present"] = true;
		_, _, VUHDO_SPELLS[VUHDO_SPELL_ID_RENEWED_HOPE]["icon"] = GetSpellInfo(57470);

		VUHDO_SPELLS[VUHDO_SPELL_ID_INSPIRATION].present = true;
		_, _, VUHDO_SPELLS[VUHDO_SPELL_ID_INSPIRATION]["icon"] = GetSpellInfo(14893);

		VUHDO_SPELLS[VUHDO_SPELL_ID_BLESSED_HEALING]["present"] = true;
		_, _, VUHDO_SPELLS[VUHDO_SPELL_ID_BLESSED_HEALING]["icon"] = GetSpellInfo(70772);
	end

  -- Val'anyr, Hammer of Ancient Kings
  VUHDO_SPELLS[VUHDO_SPELL_ID_POAK]["present"] = true;
  VUHDO_SPELLS[VUHDO_SPELL_ID_POAK]["icon"] = "Interface\\Icons\\Spell_Holy_ImpHolyConcentration";

	-- Rotface hammer
  VUHDO_SPELLS[VUHDO_SPELL_ID_FOUNTAIN_OF_LIGHT]["present"] = true;
  _, _, VUHDO_SPELLS[VUHDO_SPELL_ID_FOUNTAIN_OF_LIGHT]["icon"] = GetSpellInfo(71864);
end



-- initializes some dynamic information into VUHDO_SPELLS
local tHotSlots, tHotCfg, tHotName;
local tCnt2;
local tIndex;
local tSpellName;
local tInfo;
local tSlotsUsed;
local tHasFoundSpells;
function VUHDO_initFromSpellbook()
	tIndex = 1;
	while (true) do
		tSpellName, tSpellRank = GetSpellName(tIndex, BOOKTYPE_SPELL);
		if (tSpellName == nil) then
			break;
		end

		if (VUHDO_SPELLS[tSpellName] ~= nil) then
			VUHDO_SPELLS[tSpellName]["present"] = true;
			_, _, VUHDO_SPELLS[tSpellName]["icon"], _, _, _, _, _, _ = GetSpellInfo(tSpellName);
			VUHDO_SPELLS[tSpellName]["id"] = tIndex;
		end

		tIndex = tIndex + 1;
	end

	tHasFoundSpells = tIndex > 1;
	VUHDO_addTalentSpells();

	VUHDO_MAX_HOTS = 0;
	twipe(VUHDO_PLAYER_HOTS);
	for tSpellName, tInfo in pairs(VUHDO_SPELLS) do
		if (tInfo["present"] and (VUHDO_SPELL_TYPE_HOT == tInfo["type"] or VUHDO_SPELL_TYPE_CAST_HOT == tInfo["type"])) then
			VUHDO_MAX_HOTS = VUHDO_MAX_HOTS + 1;
			tinsert(VUHDO_PLAYER_HOTS, tSpellName);
		end
	end

	tSlotsUsed = 0;
	twipe(VUHDO_ACTIVE_HOTS);
	twipe(VUHDO_ACTIVE_HOTS_OTHERS);

	tHotSlots = VUHDO_PANEL_SETUP["HOTS"]["SLOTS"];

	if (tHasFoundSpells) then
		if (tHotSlots["firstFlood"]) then
			for tCnt2 = 1, VUHDO_MAX_HOTS do
				if (not VUHDO_SPELLS[VUHDO_PLAYER_HOTS[tCnt2]]["nodefault"]) then
					tinsert(tHotSlots, VUHDO_PLAYER_HOTS[tCnt2]);
					tSlotsUsed = tSlotsUsed + 1;
					if (tSlotsUsed == 9) then
						break;
					end
				end
			end
			tHotSlots["firstFlood"] = nil;
		end

		tHotCfg = VUHDO_PANEL_SETUP["HOTS"]["SLOTCFG"];
		if (tHotCfg["firstFlood"]) then
			for tCnt2 = 1, 9 do
				if (tHotSlots[tCnt2] ~= nil) then
					tHotCfg["" .. tCnt2]["others"] = VUHDO_EXCLUSIVE_HOTS[tHotSlots[tCnt2]] ~= nil;
				end
			end
			tHotCfg["firstFlood"] = nil;
		end

		for tCnt2, tHotName in pairs(tHotSlots) do
			if (tHotName ~= nil and strlen(tHotName) > 0) then
				VUHDO_ACTIVE_HOTS[tHotName] = true;

				if (tHotCfg["" .. tCnt2]["others"]) then
					VUHDO_ACTIVE_HOTS_OTHERS[tHotName] = true;
				end
			end
		end
		VUHDO_setKnowsSwiftmend(VUHDO_isSpellKnown(VUHDO_SPELL_ID_SWIFTMEND));
	end
end
