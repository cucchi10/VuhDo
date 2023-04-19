local VUHDO_IS_RESURRECTING = false;



--
local string = string;
local pairs = pairs;
local strlen = strlen;
local smatch = string.match;

local UnitIsGhost = UnitIsGhost;
local InCombatLockdown = InCombatLockdown;

local VUHDO_sendCtraMessage;
local VUHDO_updateAllHoTs;
local VUHDO_updateAllCyclicBouquets;
local VUHDO_getResurrectionSpells;
local VUHDO_initGcd;

local VUHDO_ACTIVE_HOTS;
local VUHDO_RAID_NAMES;
local VUHDO_CONFIG = { };

function VUHDO_spellEventHandlerInitBurst()
	VUHDO_sendCtraMessage = VUHDO_GLOBAL["VUHDO_sendCtraMessage"];
	VUHDO_updateAllHoTs = VUHDO_GLOBAL["VUHDO_updateAllHoTs"];
	VUHDO_updateAllCyclicBouquets = VUHDO_GLOBAL["VUHDO_updateAllCyclicBouquets"];
	VUHDO_getResurrectionSpells	= VUHDO_GLOBAL["VUHDO_getResurrectionSpells"];
	VUHDO_initGcd = VUHDO_GLOBAL["VUHDO_initGcd"];

	VUHDO_ACTIVE_HOTS = VUHDO_GLOBAL["VUHDO_ACTIVE_HOTS"];
	VUHDO_RAID_NAMES = VUHDO_GLOBAL["VUHDO_RAID_NAMES"];
	VUHDO_CONFIG = VUHDO_GLOBAL["VUHDO_CONFIG"];
end



--
function VUHDO_spellcastStop(aUnit)
	if (VUHDO_IS_RESURRECTING and "player" == aUnit) then
		VUHDO_sendCtraMessage("RESNO");
		VUHDO_IS_RESURRECTING = false;
	end
end
local VUHDO_spellcastStop = VUHDO_spellcastStop;



--
function VUHDO_spellcastFailed(aUnit, aSpellName)
	VUHDO_spellcastStop(aUnit, aSpellName);
end



--
local function VUHDO_activateSpellForSpec(aSpecId)
	local tName = VUHDO_SPEC_LAYOUTS[aSpecId];
	if (tName ~= nil and strlen(tName) > 0) then
		if (VUHDO_SPELL_LAYOUTS[tName] ~= nil) then
			VUHDO_activateLayout(tName);
		else
			VUHDO_Msg("Spell layout \"" .. tName .. "\" doesn't exist.", 1, 0.4, 0.4);
		end
	end
end



-- local
function VUHDO_activateSpecc(aSpeccNum)
	VUHDO_activateSpellForSpec("" .. aSpeccNum);

	if (1 == aSpeccNum and VUHDO_CONFIG["AUTO_PROFILES"]["SPEC_1"] ~= nil) then
		VUHDO_loadProfile(VUHDO_CONFIG["AUTO_PROFILES"]["SPEC_1"]);
	elseif (2 == aSpeccNum and VUHDO_CONFIG["AUTO_PROFILES"]["SPEC_2"] ~= nil) then
		VUHDO_loadProfile(VUHDO_CONFIG["AUTO_PROFILES"]["SPEC_2"]);
	end
end




local VUHDO_TALENT_CHANGE_SPELLS = {
	[VUHDO_SPELL_ID_ACTIVATE_FIRST_TALENT] = true,
	[VUHDO_SPELL_ID_ACTIVATE_SECOND_TALENT] = true,
	[VUHDO_SPELL_ID_BUFF_FROST_PRESENCE] = true,
	[VUHDO_SPELL_ID_BUFF_BLOOD_PRESENCE] = true,
	[VUHDO_SPELL_ID_BUFF_UNHOLY_PRESENCE] = true,
}



--
function VUHDO_spellcastSucceeded(aUnit, aSpellName)
	if (VUHDO_TALENT_CHANGE_SPELLS[aSpellName]) then
		VUHDO_resetTalentScan(aUnit);
		VUHDO_timeReloadUI(1);
	end

	if ("player" ~= aUnit and VUHDO_PLAYER_RAID_ID ~= aUnit) then
		return;
	end

	if (VUHDO_ACTIVE_HOTS[aSpellName]) then
		VUHDO_updateAllHoTs();
		VUHDO_updateAllCyclicBouquets("player");
	end

	if (VUHDO_SPELL_ID_ACTIVATE_FIRST_TALENT == aSpellName) then
		VUHDO_activateSpecc(1);
	elseif (VUHDO_SPELL_ID_ACTIVATE_SECOND_TALENT == aSpellName) then
		VUHDO_activateSpecc(2);
	end
end



--
local tTargetUnit;
local tFirstRes, tSecondRes;
local tUniqueSpells = nil;
local tUniqueCategs;
local tSpellName;
local tCateg;
local tText;
function VUHDO_spellcastSent(aUnit, aSpellName, aSpellRank, aTargetName)
	if ("player" ~= aUnit or aTargetName == nil) then
		return;
	end

	if (VUHDO_CONFIG["IS_SHOW_GCD"]) then
		VUHDO_initGcd();
	end

	aTargetName = smatch(aTargetName, "^[^-]*");
	tTargetUnit = VUHDO_RAID_NAMES[aTargetName];

	-- Resurrection?
	tFirstRes, tSecondRes = VUHDO_getResurrectionSpells();
	if ((aSpellName == tFirstRes or aSpellName == tSecondRes)
		and aTargetName ~= nil and tTargetUnit ~= nil and not UnitIsGhost(tTargetUnit)) then

		VUHDO_sendCtraMessage("RES " .. aTargetName);
		VUHDO_IS_RESURRECTING = true;

		if (VUHDO_CONFIG["RES_IS_SHOW_TEXT"]) then
			tText = gsub(VUHDO_CONFIG["RES_ANNOUNCE_TEXT"], "vuhdo", aTargetName);

			if (GetNumRaidMembers() > 0) then
				SendChatMessage(tText, "RAID", nil, nil);
			elseif (GetNumPartyMembers() > 0) then
				SendChatMessage(tText, "PARTY", nil, nil);
			else
				SendChatMessage(tText, "WHISPER", nil, aTargetName);
			end
		end
		return;
	end

	-- Auto track single target unique spells?
	if (tUniqueSpells == nil) then
		tUniqueSpells = { };

		local tUnique, tUniqueCategs = VUHDO_getAllUniqueSpells();
		for _, tSpellName in pairs(tUnique) do
			tUniqueSpells[tSpellName] = tUniqueCategs[tSpellName];
		end
	end

	tCateg = tUniqueSpells[aSpellName];
	if (tCateg ~= nil and tTargetUnit ~= nil and not InCombatLockdown()) then
		if (VUHDO_BUFF_SETTINGS ~= nil and VUHDO_BUFF_SETTINGS[tCateg] ~= nil and aTargetName ~= VUHDO_BUFF_SETTINGS[tCateg].name) then
			VUHDO_BUFF_SETTINGS[tCateg].name = aTargetName;
			VUHDO_reloadBuffPanel();
		end
	end
end



