VUHDO_DID_DC_RESTORE = false;

VUHDO_IN_COMBAT_RELOG = false;


VUHDO_RAID = { };
local VUHDO_RAID;

VUHDO_RAID_NAMES = { };
local VUHDO_RAID_NAMES = VUHDO_RAID_NAMES;

VUHDO_GROUPS = { };
local VUHDO_GROUPS = VUHDO_GROUPS;

VUHDO_RAID_GUIDS = { };
local VUHDO_RAID_GUIDS = VUHDO_RAID_GUIDS;

VUHDO_RAID_GUID_NAMES = { };
local VUHDO_RAID_GUID_NAMES = VUHDO_RAID_GUID_NAMES;

VUHDO_EMERGENCIES = { };
local VUHDO_EMERGENCIES = VUHDO_EMERGENCIES;

VUHDO_CLUSTER_BASE_RAID = { };
local VUHDO_CLUSTER_BASE_RAID = VUHDO_CLUSTER_BASE_RAID;

VUHDO_PLAYER_TARGETS = { };

VUHDO_BUFF_GROUPS = {
	["WARRIOR"] = {};
	["ROGUE"] = {};
	["HUNTER"] = {};
	["PALADIN"] = {};
	["MAGE"] = {};
	["WARLOCK"] = {};
	["SHAMAN"] = {};
	["DRUID"] = {};
	["PRIEST"] = {};
	["DEATHKNIGHT"] = {};
};
local VUHDO_BUFF_GROUPS = VUHDO_BUFF_GROUPS;

local VUHDO_IS_SUSPICIOUS_ROSTER = false;

local VUHDO_RAID_SORTED = { };
local VUHDO_MAINTANKS = { };
local VUHDO_INTERNAL_TOGGLES = { };


VUHDO_PLAYER_CLASS = nil;
VUHDO_PLAYER_NAME = nil;
VUHDO_PLAYER_RAID_ID = nil;
VUHDO_PLAYER_GROUP = nil;

VUHDO_GLOBAL = getfenv();

-- BURST CACHE ---------------------------------------------------
local VUHDO_PET_2_OWNER;
local VUHDO_OWNER_2_PET;
local VUHDO_CurrentMode;
local VUHDO_getUnitIds;
local VUHDO_getUnitNo;
local VUHDO_isInRange;
local VUHDO_determineDebuff;
local VUHDO_getUnitGroup;
local VUHDO_getPetUnit;
local VUHDO_tableUniqueAdd;
local VUHDO_getTargetUnit;
local VUHDO_updateHealthBarsFor;
local VUHDO_trimInspected;
local VUHDO_CONFIG;
local VUHDO_getPlayerRaidUnit;
local VUHDO_getModelType;
local VUHDO_isConfigDemoUsers;
local VUHDO_updateBouquetsForEvent;
local VUHDO_resetClusterCoordDeltas;
local VUHDO_getUnitZoneName;
local GetRaidTargetIndex = GetRaidTargetIndex;
local UnitIsDeadOrGhost = UnitIsDeadOrGhost;
local UnitIsFeignDeath = UnitIsFeignDeath;
local UnitExists = UnitExists;
local UnitHealth = UnitHealth;
local UnitHealthMax = UnitHealthMax;
local string = string;
local UnitIsAFK = UnitIsAFK;
local UnitIsConnected = UnitIsConnected;
local UnitIsCharmed = UnitIsCharmed;
local UnitCanAttack = UnitCanAttack;
local GetNumRaidMembers = GetNumRaidMembers;
local GetNumPartyMembers = GetNumPartyMembers;
local UnitName = UnitName;
local UnitMana = UnitMana;
local UnitManaMax = UnitManaMax;
local UnitThreatSituation = UnitThreatSituation;
local UnitClass = UnitClass;
local UnitPowerType = UnitPowerType;
local UnitHasVehicleUI = UnitHasVehicleUI;
local UnitGroupRolesAssigned = UnitGroupRolesAssigned;
local GetRaidRosterInfo = GetRaidRosterInfo;
local InCombatLockdown = InCombatLockdown;
local table = table;
local UnitGUID = UnitGUID;
local tinsert = tinsert;
local tremove = tremove;
local strfind = strfind;
local gsub = gsub;
--local VUHDO_PANEL_MODELS;
local VUHDO_determineRole;
local VUHDO_getUnitHealthPercent;
local GetTime = GetTime;
local pairs = pairs;
local ipairs = ipairs;
local twipe = table.wipe;
local tsort = table.sort;
local _ = _;

function VUHDO_vuhdoInitBurst()
	VUHDO_CONFIG = VUHDO_GLOBAL["VUHDO_CONFIG"];
	VUHDO_RAID = VUHDO_GLOBAL["VUHDO_RAID"];
  VUHDO_PET_2_OWNER = VUHDO_GLOBAL["VUHDO_PET_2_OWNER"];
	VUHDO_OWNER_2_PET = VUHDO_GLOBAL["VUHDO_OWNER_2_PET"];
	VUHDO_getUnitIds = VUHDO_GLOBAL["VUHDO_getUnitIds"];
	VUHDO_getUnitNo = VUHDO_GLOBAL["VUHDO_getUnitNo"];
	VUHDO_isInRange = VUHDO_GLOBAL["VUHDO_isInRange"];
	VUHDO_determineDebuff = VUHDO_GLOBAL["VUHDO_determineDebuff"];
	VUHDO_getUnitGroup = VUHDO_GLOBAL["VUHDO_getUnitGroup"];
	VUHDO_getPetUnit = VUHDO_GLOBAL["VUHDO_getPetUnit"];
	VUHDO_updateHealthBarsFor = VUHDO_GLOBAL["VUHDO_updateHealthBarsFor"];
	VUHDO_tableUniqueAdd = VUHDO_GLOBAL["VUHDO_tableUniqueAdd"];
	VUHDO_trimInspected = VUHDO_GLOBAL["VUHDO_trimInspected"];
	VUHDO_getTargetUnit = VUHDO_GLOBAL["VUHDO_getTargetUnit"];
	VUHDO_getModelType = VUHDO_GLOBAL["VUHDO_getModelType"];

	VUHDO_getPlayerRaidUnit = VUHDO_GLOBAL["VUHDO_getPlayerRaidUnit"];
	--VUHDO_PANEL_MODELS = VUHDO_GLOBAL["VUHDO_PANEL_MODELS"];
	VUHDO_determineRole = VUHDO_GLOBAL["VUHDO_determineRole"];
	VUHDO_getUnitHealthPercent = VUHDO_GLOBAL["VUHDO_getUnitHealthPercent"];
	VUHDO_isConfigDemoUsers = VUHDO_GLOBAL["VUHDO_isConfigDemoUsers"];
	VUHDO_updateBouquetsForEvent = VUHDO_GLOBAL["VUHDO_updateBouquetsForEvent"];
	VUHDO_resetClusterCoordDeltas = VUHDO_GLOBAL["VUHDO_resetClusterCoordDeltas"];
	VUHDO_getUnitZoneName = VUHDO_GLOBAL["VUHDO_getUnitZoneName"];
  VUHDO_CurrentMode = VUHDO_CONFIG["MODE"]

	VUHDO_INTERNAL_TOGGLES = VUHDO_GLOBAL["VUHDO_INTERNAL_TOGGLES"];
end

----------------------------------------------------

local VUHDO_UNIT_AFK_DC = { };


--
local tUnit, tInfo, tName;
local function VUHDO_updateAllRaidNames()
	twipe(VUHDO_RAID_NAMES);

	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if (tUnit ~= "focus" and tUnit ~= "target") then
			-- ensure not to overwrite a player name with a pet's identical name
			tName = tInfo["name"];
			if (VUHDO_RAID_NAMES[tName] == nil or not tInfo["isPet"]) then
				VUHDO_RAID_NAMES[tName] = tUnit;
			end
		end
	end
end



--
local function VUHDO_isValidEmergency(anInfo)
	return
		not anInfo["isPet"]
		and anInfo["range"]
		and not anInfo["dead"]
		and anInfo["connected"]
		and not anInfo["charmed"];
end



--
local tUnit;
local tIndex;
local function VUHDO_setTopEmergencies(aMaxAnz)
	twipe(VUHDO_EMERGENCIES);
	for tIndex, tUnit in ipairs(VUHDO_RAID_SORTED) do
		VUHDO_EMERGENCIES[tUnit] = tIndex;
		if (tIndex == aMaxAnz) then
			break;
		end
	end
end



--
local tInfoA, tInfoB;
local VUHDO_EMERGENCY_SORTERS = {
	[VUHDO_MODE_EMERGENCY_MOST_MISSING]
		= function(aUnit, anotherUnit)
				tInfoA = VUHDO_RAID[aUnit];
				tInfoB = VUHDO_RAID[anotherUnit];

				return (tInfoA["healthmax"] - tInfoA["health"]
							> tInfoB["healthmax"] - tInfoB["health"]);
			end,

	[VUHDO_MODE_EMERGENCY_PERC]
		= function(aUnit, anotherUnit)
				tInfoA = VUHDO_RAID[aUnit];
				tInfoB = VUHDO_RAID[anotherUnit];

					return (tInfoA["health"] / tInfoA["healthmax"]
								< tInfoB["health"] / tInfoB["healthmax"]);
			end,

	[VUHDO_MODE_EMERGENCY_LEAST_LEFT]
		= function(aUnit, anotherUnit)
				return VUHDO_RAID[aUnit]["health"] < VUHDO_RAID[anotherUnit]["health"];
			end,
}



--
local tUnit, tInfo;
local tTrigger;
local function VUHDO_sortEmergencies()
	twipe(VUHDO_RAID_SORTED);
	tTrigger = VUHDO_CONFIG["EMERGENCY_TRIGGER"];

	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if (VUHDO_getUnitHealthPercent(tInfo) < tTrigger and VUHDO_isValidEmergency(tInfo)) then
			tinsert(VUHDO_RAID_SORTED, tUnit);
		end
	end

	tsort(VUHDO_RAID_SORTED, VUHDO_EMERGENCY_SORTERS[VUHDO_CurrentMode]);
	VUHDO_setTopEmergencies(VUHDO_CONFIG["MAX_EMERGENCIES"]);
end



-- Avoid reordering sorting by max-health if someone dies or gets offline
local tEmptyInfo = {};
local function VUHDO_getUnitSortMaxHp(aUnit)
	if ((VUHDO_RAID[aUnit] or tEmptyInfo)["sortMaxHp"] ~= nil and InCombatLockdown()) then
		return VUHDO_RAID[aUnit]["sortMaxHp"];
	else
		return VUHDO_RAID[aUnit]["healthmax"];
	end
end



--
local tIsAfk;
local tIsConnected;
local function VUHDO_updateAfkDc(aUnit)
	tIsAfk = UnitIsAFK(aUnit);
	tIsConnected = UnitIsConnected(aUnit);
	if (tIsAfk or not tIsConnected) then
		if (VUHDO_UNIT_AFK_DC[aUnit] == nil) then
			VUHDO_UNIT_AFK_DC[aUnit] = GetTime();
		end
	else
		VUHDO_UNIT_AFK_DC[aUnit] = nil;
	end

	return tIsAfk, tIsConnected, VUHDO_RAID[aUnit] ~= nil and tIsConnected ~= VUHDO_RAID[aUnit]["connected"];
end



--
function VUHDO_getAfkDcTime(aUnit)
	return VUHDO_UNIT_AFK_DC[aUnit];
end



--
function VUHDO_getOwner(aUnit, anIsPet)
	if ("pet" == aUnit) then
		return "player";
	elseif (anIsPet) then
		return gsub(aUnit, "pet", "");
	else
		return nil;
	end
end
local VUHDO_getOwner = VUHDO_getOwner;



-- Sets a Member info into raid array
local tUnitId;
local tIsPet;
local tClassName;
local tPowerType;
local tIsAfk, tIsConnected;
local tLocalClass;
local tIsDead;
local tClassId;
local tInfo;
local tNewHealth;
local tName, tRealm;
local tIsDcChange;
function VUHDO_setHealth(aUnit, aMode)

	tInfo = VUHDO_RAID[aUnit];

	if (4 == aMode) then -- VUHDO_UPDATE_DEBUFF
		if (tInfo ~= nil) then
			tInfo["debuff"], tInfo["debuffName"] = VUHDO_determineDebuff(aUnit);
		end
		return;
	end

	tUnitId, _ = VUHDO_getUnitIds();
	tOwner = VUHDO_PET_2_OWNER[aUnit];
	tIsPet = tOwner ~= nil;

	if (strfind(aUnit, tUnitId, 1, true) ~= nil
			or tIsPet
			or aUnit == "player"
			or aUnit == "focus"
			or aUnit == "target") then

		tIsDead = UnitIsDeadOrGhost(aUnit) and not UnitIsFeignDeath(aUnit);
		if (tIsDead) then
			VUHDO_removeAllDebuffIcons(aUnit);
			VUHDO_removeHots(aUnit);
		end

		if (1 == aMode) then -- VUHDO_UPDATE_ALL
			tLocalClass, tClassName = UnitClass(aUnit);
			tPowerType = UnitPowerType(aUnit);
			tIsAfk, tIsConnected, _ = VUHDO_updateAfkDc(aUnit);

			if (VUHDO_RAID[aUnit] == nil) then
				VUHDO_RAID[aUnit] = { };
			end
			tInfo = VUHDO_RAID[aUnit];
			tInfo["ownerUnit"] = tOwner;

			if (tIsPet and tClassId ~= nil) then
				if (VUHDO_USER_CLASS_COLORS["petClassColor"] and VUHDO_RAID[tInfo["ownerUnit"]] ~= nil) then
					tClassId = VUHDO_RAID[tInfo["ownerUnit"]]["classId"] or VUHDO_ID_PETS;
				else
					tClassId = VUHDO_ID_PETS;
				end
			else
				tClassId = VUHDO_CLASS_IDS[tClassName];
			end

			tName, tRealm = UnitName(aUnit);
			tInfo["healthmax"] = UnitHealthMax(aUnit);
			tInfo["health"] = UnitHealth(aUnit);
			tInfo["name"] = tName;
			tInfo["number"] = VUHDO_getUnitNo(aUnit);
			tInfo["unit"] = aUnit;
			tInfo["class"] = tClassName;
			tInfo["range"] = VUHDO_isInRange(aUnit);
			tInfo["debuff"], tInfo["debuffName"] = VUHDO_determineDebuff(aUnit);
			tInfo["isPet"] = tIsPet;
			tInfo["powertype"] = tonumber(tPowerType);
			tInfo["power"] = UnitMana(aUnit);
			tInfo["powermax"] = UnitManaMax(aUnit);
			tInfo["charmed"] = UnitIsCharmed(aUnit) and UnitCanAttack("player", aUnit);
			tInfo["aggro"] = false;
			tInfo["group"] = VUHDO_getUnitGroup(aUnit, tIsPet);
			tInfo["dead"] = tIsDead;
			tInfo["afk"] = tIsAfk;
			tInfo["connected"] = tIsConnected;
			tInfo["threat"] = UnitThreatSituation(aUnit);
			tInfo["threatPerc"] = 0;
			tInfo["isVehicle"] = UnitHasVehicleUI(aUnit);
			tInfo["className"] = tLocalClass or "";
			tInfo["petUnit"] = VUHDO_OWNER_2_PET[aUnit];
			tInfo["targetUnit"] = VUHDO_getTargetUnit(aUnit);
			tInfo["classId"] = tClassId;
			tInfo["sortMaxHp"] = VUHDO_getUnitSortMaxHp(aUnit);
			tInfo["role"] = VUHDO_determineRole(aUnit);
      tInfo["fullName"] = (tRealm or "") ~= "" and (tName .. "-" .. tRealm) or tName;
			tInfo["raidIcon"] = GetRaidTargetIndex(aUnit);
			tInfo["visible"] = UnitIsVisible(aUnit); -- Reihenfolge beachten
			tInfo["zone"], tInfo["map"] = VUHDO_getUnitZoneName(aUnit); -- ^^
			tInfo["baseRange"] = UnitInRange(aUnit);
			--tInfo["missbuff"] = nil;
			--tInfo["mibucateg"] = nil;
			--tInfo["mibuvariants"] = nil;

			if (aUnit ~= "focus" and aUnit ~= "target") then
				if (not tIsPet and tInfo["fullName"] == tName and VUHDO_RAID_NAMES[tName] ~= nil) then
					VUHDO_IS_SUSPICIOUS_ROSTER = true;
				end

				-- ensure not to overwrite a player name with a pet's identical name
				if (VUHDO_RAID_NAMES[tName] == nil or not tIsPet) then
					VUHDO_RAID_NAMES[tName] = aUnit;
				end
			end

		elseif (tInfo ~= nil) then
			tIsAfk, tInfo["connected"], tIsDcChange = VUHDO_updateAfkDc(aUnit);

			if (tIsDcChange) then
				VUHDO_updateBouquetsForEvent(aUnit, 19); -- VUHDO_UPDATE_DC
			end

			if(2 == aMode) then -- VUHDO_UPDATE_HEALTH
				tNewHealth = UnitHealth(aUnit);
				if (not tIsDead) then
					tInfo["lifeLossPerc"] = tNewHealth / tInfo["health"];
				end

				tInfo["health"] = tNewHealth;

				if (tInfo["dead"] ~= tIsDead) then
					if (tInfo["dead"] and not tIsDead) then
						tInfo["healthmax"] = UnitHealthMax(aUnit);
					end
					tInfo["dead"] = tIsDead;
					VUHDO_updateHealthBarsFor(aUnit, 10); -- VUHDO_UPDATE_ALIVE
					VUHDO_updateBouquetsForEvent(aUnit, 10); -- VUHDO_UPDATE_ALIVE
				end

			elseif(3 == aMode) then -- VUHDO_UPDATE_HEALTH_MAX
				tInfo["dead"] = tIsDead;
				tInfo["healthmax"] = UnitHealthMax(aUnit);
				tInfo["sortMaxHp"] = VUHDO_getUnitSortMaxHp(aUnit);

			elseif(6 == aMode) then -- VUHDO_UPDATE_AFK
				tInfo["afk"] = tIsAfk;
			end
		end
	end
end
local VUHDO_setHealth = VUHDO_setHealth;



--
local function VUHDO_setHealthSafe(aUnit, aMode)
	if (UnitExists(aUnit)) then
		VUHDO_setHealth(aUnit, aMode);
	end
end



-- Callback for UNIT_HEALTH / UNIT_MAXHEALTH events
local tUnit;
local tOwner;
local tIsPet;
function VUHDO_updateHealth(aUnit, aMode)
	tIsPet = VUHDO_RAID[aUnit]["isPet"];

	if (not tIsPet or VUHDO_INTERNAL_TOGGLES[26]) then -- VUHDO_UPDATE_PETS  -- Enth�lt nur Pets als eigene Balken, vehicles werden �ber owner dargestellt s.unten
		VUHDO_setHealthSafe(aUnit, aMode);
		VUHDO_updateHealthBarsFor(aUnit, aMode);
	end

	if (tIsPet) then -- Vehikel?
		tOwner = VUHDO_RAID[aUnit]["ownerUnit"];
		if (tOwner ~= nil and VUHDO_RAID[tOwner]["isVehicle"]) then
			VUHDO_setHealthSafe(tOwner, aMode);
			VUHDO_updateHealthBarsFor(tOwner, aMode);
		end
	end

	if (1 ~= VUHDO_CurrentMode -- VUHDO_MODE_NEUTRAL
		and (2 == aMode or 3 == aMode)) then -- VUHDO_UPDATE_HEALTH -- VUHDO_UPDATE_HEALTH_MAX
		-- Remove old emergencies
		VUHDO_FORCE_RESET = true;
		for tUnit, _ in pairs(VUHDO_EMERGENCIES) do
			VUHDO_updateHealthBarsFor(tUnit, 11); -- VUHDO_UPDATE_EMERGENCY
		end
		VUHDO_sortEmergencies();
		-- Set new Emergencies
		VUHDO_FORCE_RESET = false;
		for tUnit, _ in pairs(VUHDO_EMERGENCIES) do
			VUHDO_updateHealthBarsFor(tUnit, 11); -- VUHDO_UPDATE_EMERGENCY
		end
	end
end



--
local tUnit, tInfo, tIcon;
function VUHDO_updateAllRaidTargetIndices()
	for tUnit, tInfo in pairs(VUHDO_RAID) do
		tIcon = GetRaidTargetIndex(tUnit);
		if (tInfo["raidIcon"] ~= tIcon) then
			tInfo["raidIcon"] = tIcon;
			VUHDO_updateBouquetsForEvent(tUnit, 24); -- VUHDO_UPDATE_RAID_TARGET
		end
	end
end



-- Add to groups 1-8
local function VUHDO_addUnitToGroup(aUnit, aGroupNum)
	if ("player" == aUnit and VUHDO_CONFIG["OMIT_SELF"]) then
		return;
	end

	if (not VUHDO_CONFIG["OMIT_OWN_GROUP"] or aGroupNum ~= VUHDO_PLAYER_GROUP) then
		if (VUHDO_GROUPS[aGroupNum] == nil) then
			VUHDO_GROUPS[aGroupNum] = { };
		end
		tinsert(VUHDO_GROUPS[aGroupNum], aUnit);
	end

	if (VUHDO_PLAYER_GROUP == aGroupNum) then
		tinsert(VUHDO_GROUPS[VUHDO_ID_GROUP_OWN], aUnit);
	end
end



--
local function VUHDO_addUnitToClass(aUnit, aClassId)
	if (("player" == aUnit and VUHDO_CONFIG["OMIT_SELF"]) or aClassId == nil) then
		return;
	end

	tinsert(VUHDO_GROUPS[aClassId], aUnit);
	tinsert(VUHDO_BUFF_GROUPS[VUHDO_ID_CLASSES[aClassId] or "WARRIOR"], aUnit);
end



--
local tCnt, tModel;
function VUHDO_isModelConfigured(aModelId)
	for tCnt = 1, 10 do -- VUHDO_MAX_PANELS
		if (VUHDO_PANEL_MODELS[tCnt] ~= nil) then
			for _, tModel in pairs(VUHDO_PANEL_MODELS[tCnt]) do
				if (aModelId == tModel) then
					return true;
				end
			end
		end
	end

  return false;
end
local VUHDO_isModelConfigured = VUHDO_isModelConfigured;



--
local tModelId, tAllUnits, tIndex, tUnit;
local function VUHDO_removeUnitFromAllModelsBut(aUnit, aModelId)
	if (not VUHDO_isModelConfigured(aModelId)) then -- nur doppelte Balken entfernen
		return;
	end

	for tModelId, tAllUnits in pairs(VUHDO_GROUPS) do
		if (tModelId ~= 41 -- VUHDO_ID_MAINTANKS
			and tModelId ~= 42 -- VUHDO_ID_PRIVATE_TANKS
			and tModelId ~= 43) then -- VUHDO_ID_MAIN_ASSISTS
			for tIndex, tUnit in pairs(tAllUnits) do
				if (tUnit == aUnit) then
					tremove(tAllUnits, tIndex);
				end
			end
		end
	end
end



--
local function VUHDO_removeFromAllMainGroups()
	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if (VUHDO_CONFIG["OMIT_MAIN_TANKS"] and VUHDO_isUnitInModel(tUnit, 41)) then -- VUHDO_ID_MAINTANKS
			VUHDO_removeUnitFromAllModelsBut(tUnit, 41); -- VUHDO_ID_MAINTANKS
		elseif (VUHDO_CONFIG["OMIT_PLAYER_TARGETS"] and VUHDO_isUnitInModel(tUnit, 42)) then -- VUHDO_ID_PRIVATE_TANKS
			VUHDO_removeUnitFromAllModelsBut(tUnit, 42); -- VUHDO_ID_PRIVATE_TANKS
		elseif (VUHDO_CONFIG["OMIT_MAIN_ASSIST"] and VUHDO_isUnitInModel(tUnit, 43)) then -- VUHDO_ID_MAIN_ASSISTS
			VUHDO_removeUnitFromAllModelsBut(tUnit, 43); -- VUHDO_ID_MAIN_ASSISTS
		end
	end
end



--
local tRole, tIsTank;
local function VUHDO_addUnitToSpecial(aUnit)
	tIsTank, _, _ = UnitGroupRolesAssigned(aUnit);
	if (tIsTank and VUHDO_CONFIG["OMIT_DFT_MTS"]) then
		tinsert(VUHDO_GROUPS[41], aUnit); -- VUHDO_ID_MAINTANKS
	end

	if (GetNumRaidMembers() == 0) then
		return;
	end
	_, _, _, _, _, _, _, _, _, tRole, _ = GetRaidRosterInfo(VUHDO_RAID[aUnit]["number"]);

	-- MTs
	if ("MAINTANK" == tRole and not tIsTank) then
		tinsert(VUHDO_GROUPS[41], aUnit); -- VUHDO_ID_MAINTANKS
	-- Main Assist
	elseif ("MAINASSIST" == tRole) then
		tinsert(VUHDO_GROUPS[43], aUnit); -- VUHDO_ID_MAIN_ASSISTS
	end
end



--
local tCnt;
local tUnit;
local function VUHDO_addUnitToCtraMainTanks()
	for tCnt = 1, VUHDO_MAX_MTS do
		tUnit = VUHDO_MAINTANKS[tCnt];
		if (tUnit ~= nil) then
			VUHDO_tableUniqueAdd(VUHDO_GROUPS[41], tUnit); -- VUHDO_ID_MAINTANKS
		end
	end
end



--
local tUnit, tName;
local function VUHDO_addUnitToPrivateTanks()
	if (VUHDO_INTERNAL_TOGGLES[27]) then -- VUHDO_UPDATE_PLAYER_TARGET
		tinsert(VUHDO_GROUPS[42], "target"); -- VUHDO_ID_PRIVATE_TANKS
	end

	if (not VUHDO_CONFIG["OMIT_FOCUS"]) then
		tinsert(VUHDO_GROUPS[42], "focus"); -- VUHDO_ID_PRIVATE_TANKS
	end

	for tName, _ in pairs(VUHDO_PLAYER_TARGETS) do
		tUnit = VUHDO_RAID_NAMES[tName];
		if (tUnit ~= nil) then
			VUHDO_tableUniqueAdd(VUHDO_GROUPS[42], tUnit); -- VUHDO_ID_PRIVATE_TANKS
		else
			VUHDO_PLAYER_TARGETS[tName] = nil;
		end
	end
end



--
local tOwner;
local function VUHDO_addUnitToPets(aPetUnit)
	tOwner = VUHDO_RAID[aPetUnit]["ownerUnit"];

	if (VUHDO_RAID[tOwner] == nil or VUHDO_RAID[tOwner]["isVehicle"]) then
		return;
	end

	tinsert(VUHDO_GROUPS[40], aPetUnit); -- VUHDO_ID_PETS
end



--
local tRole;
local function VUHDO_addUnitToRole(aUnit)
	if ("player" == aUnit and VUHDO_CONFIG["OMIT_SELF"]) then
		return;
	end

	tRole = VUHDO_RAID[aUnit]["role"] or 62; -- -- VUHDO_ID_RANGED_DAMAGE

	tinsert(VUHDO_GROUPS[tRole], aUnit);

	if(tRole == 63 or tRole == 62) then -- VUHDO_ID_RANGED_HEAL -- VUHDO_ID_RANGED_DAMAGE
		tinsert(VUHDO_GROUPS[51], aUnit); -- VUHDO_ID_RANGED
	elseif(tRole == 61 or tRole == 60) then -- VUHDO_ID_MELEE_DAMAGE -- VUHDO_ID_MELEE_TANK
		tinsert(VUHDO_GROUPS[50], aUnit); -- VUHDO_ID_MELEE
	end
end



--
local tPetUnit;
local function VUHDO_addUnitToVehicles(aUnit)
	tPetUnit = VUHDO_RAID[aUnit]["petUnit"];
	if (tPetUnit ~= nil) then
		tinsert(VUHDO_GROUPS[70], tPetUnit); -- VUHDO_ID_VEHICLES
	end
end



-- Get an empty array for each group
local tType, tTypeMembers, tMember, tBuffClassGroup;
local function VUHDO_initGroupArrays()
	twipe(VUHDO_GROUPS);

	for tType, tTypeMembers in pairs(VUHDO_ID_TYPE_MEMBERS) do
		for _, tMember in pairs(tTypeMembers) do
			VUHDO_GROUPS[tMember] = { };
		end
	end

	for _, tBuffClassGroup in pairs(VUHDO_BUFF_GROUPS) do
		twipe(tBuffClassGroup);
	end
end



--
local tUnit, tInfo;
local function VUHDO_updateGroupArrays(anWasMacroRestore)
	VUHDO_initGroupArrays();

	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if (not tInfo["isPet"]) then
			if ("focus" ~= tUnit and "target" ~= tUnit) then
				VUHDO_addUnitToGroup(tUnit, tInfo["group"]);
				VUHDO_addUnitToClass(tUnit, tInfo["classId"]);
				VUHDO_addUnitToVehicles(tUnit);
				VUHDO_addUnitToSpecial(tUnit);
			end
		else
			VUHDO_addUnitToPets(tUnit);
		end
	end
	tinsert(VUHDO_GROUPS[80], "player"); -- VUHDO_ID_SELF

	VUHDO_addUnitToCtraMainTanks();
	VUHDO_addUnitToPrivateTanks();

	-- Need MTs for role estimation
	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if ("focus" ~= tUnit and "target" ~= tUnit and not tInfo["isPet"]) then
			VUHDO_addUnitToRole(tUnit);
		end
	end
	if (not anWasMacroRestore) then
		VUHDO_removeFromAllMainGroups();
	end
	VUHDO_initDynamicPanelModels();
end



--
local tGroup;
local tUnit;
local tEmptyGroup = {};
local function VUHDO_isInSpecialGroup(aUnit, aModelId)
	tGroup = VUHDO_GROUPS[aModelId] or tEmptyGroup;
	for _, tUnit in pairs(tGroup) do
		if (aUnit == tUnit) then
			return true;
		end
	end

	return false;
end



--
local tModelType, tModelId, tSpecialModels;
function VUHDO_isUnitInModel(aUnit, aModelId)

	tModelType = VUHDO_getModelType(aModelId);

	if (2 == tModelType) then -- VUHDO_ID_TYPE_GROUP
		return aModelId == VUHDO_RAID[aUnit]["group"];
	elseif(1 == tModelType) then -- VUHDO_ID_TYPE_CLASS
		return aModelId == VUHDO_RAID[aUnit]["classId"];
	else -- VUHDO_ID_TYPE_SPECIAL
		tSpecialModels = VUHDO_ID_TYPE_MEMBERS[3]; -- VUHDO_ID_TYPE_SPECIAL
		for _, tModelId in pairs(tSpecialModels) do
			if (tModelId == aModelId and VUHDO_isInSpecialGroup(aUnit, aModelId)) then
				return true;
			end
		end

		return false;
	end
end
local VUHDO_isUnitInModel = VUHDO_isUnitInModel;



--
local tModelId;
local tModelType;
local function VUHDO_isUnitInPanel(aPanelNum, aUnit)
	for _, tModelId in pairs(VUHDO_PANEL_MODELS[aPanelNum]) do
		tModelType = VUHDO_getModelType(tModelId);
		if (2 == tModelType or 1 == tModelType) then -- VUHDO_ID_TYPE_GROUP -- VUHDO_ID_TYPE_CLASS
			if (VUHDO_CONFIG["OMIT_MAIN_TANKS"] and VUHDO_isUnitInModel(aUnit, 41)) then -- VUHDO_ID_MAINTANKS
			elseif (VUHDO_CONFIG["OMIT_PLAYER_TARGETS"] and VUHDO_isUnitInModel(aUnit, 42)) then -- VUHDO_ID_PRIVATE_TANKS
			elseif (VUHDO_CONFIG["OMIT_MAIN_ASSIST"] and VUHDO_isUnitInModel(aUnit, 43)) then -- VUHDO_ID_MAIN_ASSISTS
			else
				if (VUHDO_isUnitInModel(aUnit, tModelId)) then
					return true;
				end
			end
		else
			if (VUHDO_isUnitInModel(aUnit, tModelId)) then
				return true;
			end
		end
	end

	return false;
end



--
local tIndex, tModelId;
function VUHDO_getPanelUnitFirstModel(aPanelNum, aUnit)
	for tIndex, tModelId in ipairs(VUHDO_PANEL_MODELS[aPanelNum]) do
		if (VUHDO_isUnitInModel(aUnit, tModelId)) then
			return tIndex;
		end
	end

	return 9999;
end



--
local tPanelModels;
local tModel;
local function VUHDO_isModelInPanel(aPanelNum, aModelId)
	tPanelModels = VUHDO_PANEL_MODELS[aPanelNum];
	for _, tModel in pairs(tPanelModels) do
		if (aModelId == tModel) then
			return true;
		end
	end

	return false;
end



-- Uniquely buffer all units defined in a panel
local tPanelUnits = { };
local tPanelNum;
local tHasVehicles;
local tVehicleUnit;
local tUnit;
local function VUHDO_updateAllPanelUnits()

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		twipe(VUHDO_PANEL_UNITS[tPanelNum]);

		if (VUHDO_PANEL_MODELS[tPanelNum] ~= nil) then
			tHasVehicles = VUHDO_isModelInPanel(tPanelNum, 70); -- VUHDO_ID_VEHICLES
			twipe(tPanelUnits);
			for tUnit, _ in pairs(VUHDO_RAID) do
				if (VUHDO_isUnitInPanel(tPanelNum, tUnit)) then
					tPanelUnits[tUnit] = tUnit;
				end

				if (tHasVehicles and not VUHDO_RAID[tUnit]["isPet"]) then
					tVehicleUnit =	VUHDO_RAID[tUnit]["petUnit"];
					if (tVehicleUnit ~= nil) then -- e.g. "focus", "target"
						tPanelUnits[tVehicleUnit] = tVehicleUnit;
					end
				end
			end

			for _, tUnit in pairs(tPanelUnits) do
				tinsert(VUHDO_PANEL_UNITS[tPanelNum], tUnit);
			end
		end
	end
end



--
local tGuid, tUnit, tInfo;
local function VUHDO_updateAllGuids()
	twipe(VUHDO_RAID_GUIDS);
	twipe(VUHDO_RAID_GUID_NAMES);
	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if (tUnit ~= "focus" and tUnit ~= "target") then
			tGuid = UnitGUID(tUnit) or 0;
			VUHDO_RAID_GUIDS[tGuid] = tUnit;
			VUHDO_RAID_GUID_NAMES[tGuid] = tInfo["name"];
		end
	end
end



--
local tCnt, tName;
local function VUHDO_convertMainTanks()
	-- Discard deprecated
	for tCnt = 1, 8 do -- VUHDO_MAX_MTS
		tName = VUHDO_MAINTANK_NAMES[tCnt];
		if (tName ~= nil and VUHDO_RAID_NAMES[tName] == nil) then
			VUHDO_MAINTANK_NAMES[tCnt] = nil;
		end
	end

	-- Convert to units instead of names
	twipe(VUHDO_MAINTANKS);
	for tCnt, tName in pairs(VUHDO_MAINTANK_NAMES) do
		VUHDO_MAINTANKS[tCnt] = VUHDO_RAID_NAMES[tName];
	end
end



--
local tUnit, tInfo;
local function VUHDO_createIndexedUnits()
	twipe(VUHDO_CLUSTER_BASE_RAID);
	VUHDO_resetClusterCoordDeltas();

	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if (not tInfo["isPet"] -- won't work for pets
				and "focus" ~= tUnit and "target" ~= tUnit) then

			tinsert(VUHDO_CLUSTER_BASE_RAID, tInfo);
		end
	end
end



--
-- Reload all raid members into the raid array e.g. in case of raid roster change
function VUHDO_reloadRaidMembers()
	local i;
	local tPlayer, tPet;
	local tMaxMembers;
	local tUnit, tPetUnit;
	local tWasRestored = false;

	VUHDO_IS_SUSPICIOUS_ROSTER = false;

	if (GetNumRaidMembers() == 0 and not UnitExists("party1") and not VUHDO_DID_DC_RESTORE) then
		VUHDO_IN_COMBAT_RELOG = true;
		tWasRestored = VUHDO_buildRaidFromMacro();
		VUHDO_updateAllRaidNames();
		if (tWasRestored) then
			VUHDO_normalRaidReload(true);
		end
		VUHDO_DID_DC_RESTORE = true;
	elseif (VUHDO_isConfigDemoUsers()) then
		VUHDO_demoSetupResetUsers();
		VUHDO_reloadRaidDemoUsers();
		VUHDO_updateAllRaidNames();
	else
		VUHDO_PLAYER_RAID_ID = VUHDO_getPlayerRaidUnit();
		VUHDO_IN_COMBAT_RELOG = false;
		VUHDO_DID_DC_RESTORE = true;
		tUnit, tPetUnit = VUHDO_getUnitIds();

    tMaxMembers = ("raid" == tUnit) and GetNumRaidMembers() or ("party" == tUnit) and GetNumPartyMembers() or 0;

		twipe(VUHDO_RAID);
		twipe(VUHDO_RAID_NAMES);

		if (tMaxMembers > 0) then
			for i = 1, tMaxMembers do
				tPlayer = tUnit .. i;
				if (UnitExists(tPlayer) and tPlayer ~= VUHDO_PLAYER_RAID_ID) then
					VUHDO_setHealthSafe(tPlayer, 1); -- VUHDO_UPDATE_ALL

					tPet = tPetUnit .. i;
					VUHDO_setHealthSafe(tPet, 1); -- VUHDO_UPDATE_ALL
				end
			end

		end
		VUHDO_setHealthSafe("player", 1); -- VUHDO_UPDATE_ALL
		VUHDO_setHealthSafe("pet", 1); -- VUHDO_UPDATE_ALL
		VUHDO_setHealthSafe("focus", 1); -- VUHDO_UPDATE_ALL

		if (VUHDO_INTERNAL_TOGGLES[27]) then -- VUHDO_UPDATE_PLAYER_TARGET
			VUHDO_setHealthSafe("target", 1); -- VUHDO_UPDATE_ALL
		end

		VUHDO_TIMERS["MIRROR_TO_MACRO"] = 8;
	end

	VUHDO_PLAYER_GROUP = VUHDO_getUnitGroup(VUHDO_PLAYER_RAID_ID, false);

	VUHDO_trimInspected();
	VUHDO_convertMainTanks();
	VUHDO_updateGroupArrays(tWasRestored);
	VUHDO_updateAllPanelUnits();
	VUHDO_updateAllGuids();
	VUHDO_updateBuffRaidGroup();
	VUHDO_updateBuffPanel();
	if (VUHDO_CurrentMode ~= 1) then -- VUHDO_MODE_NEUTRAL
		VUHDO_sortEmergencies();
	end
	VUHDO_createIndexedUnits();

	if (VUHDO_IS_SUSPICIOUS_ROSTER) then
		VUHDO_normalRaidReload();
	end
end



--
local i;
local tPlayer, tPet;
local tPlayerVRG;
local tMaxMembers;
local tUnit, tPetUnit;
local tInfo;
local tIsDcChange;
local tName, tRealm;
local tNameVRG, tNamePlayer;
local tRaidId;
function VUHDO_refreshRaidMembers()
	VUHDO_IS_SUSPICIOUS_ROSTER = false;

	if (VUHDO_isConfigDemoUsers()) then
		VUHDO_reloadRaidDemoUsers();
		VUHDO_updateAllRaidNames();
	else
		VUHDO_PLAYER_RAID_ID = VUHDO_getPlayerRaidUnit();
		VUHDO_IN_COMBAT_RELOG = false;
		tUnit, tPetUnit = VUHDO_getUnitIds();

    tMaxMembers = ("raid" == tUnit) and 40 or ("party" == tUnit) and 5 or 0;

		twipe(VUHDO_RAID_NAMES);

    tNamePlayer, _ = UnitName(VUHDO_PLAYER_RAID_ID);

		for i = 1, tMaxMembers do
			tPlayer = tUnit .. i;
      tInfo = VUHDO_RAID[tPlayer];
      if (UnitExists(tPlayer)) then
        tName, tRealm = UnitName(tPlayer);
        if(tName and tName == tNamePlayer) then
          VUHDO_RAID[tPlayer] = nil;
        elseif (tName and tName ~= tNamePlayer) then
          tPlayerVRG = VUHDO_RAID_GUIDS[UnitGUID(tPlayer)]
          if(tPlayerVRG ~= nil) then
            tNameVRG, _= UnitName(tPlayer);
            if (tInfo == nil or tPlayerVRG ~= nil and tNameVRG ~= tNamePlayer) then
              VUHDO_setHealthSafe(tPlayer, 1);--VUHDO_UPDATE_ALL
            end
          elseif (tInfo == nil ) then
             VUHDO_setHealthSafe(tPlayer, 1);--VUHDO_UPDATE_ALL
          else
            tInfo["group"] = VUHDO_getUnitGroup(tPlayer, false);
            tInfo["isVehicle"] = UnitHasVehicleUI(tPlayer);

            if ( tInfo["isVehicle"] ) then
              tRaidId = UnitInRaid(tPlayer);
              
              if ( tRaidId and not UnitTargetsVehicleInRaidUI(tPlayer) ) then
                tInfo["isVehicle"] = false;
              end

            end
            tInfo["role"] = VUHDO_determineRole(tPlayer); -- weil talent-scanner nach und nach arbeitet
            tInfo["afk"], tInfo["connected"], tIsDcChange = VUHDO_updateAfkDc(tPlayer);
            tInfo["range"] = VUHDO_isInRange(tPlayer);

            tInfo["name"] = tName;

            if (strlen(tRealm or "") > 0) then
              tInfo["fullName"] = tName .. "-" .. tRealm;
            else
              tInfo["fullName"] = tName;

              if (VUHDO_RAID_NAMES[tName] ~= nil) then
                VUHDO_IS_SUSPICIOUS_ROSTER = true;
              end

            end
            VUHDO_RAID_NAMES[tName] = tPlayer;

            if (tIsDcChange) then
              VUHDO_updateBouquetsForEvent(tPlayer, 19); -- VUHDO_UPDATE_DC
            end
          
            tPet = tPetUnit .. i;
            VUHDO_setHealthSafe(tPet, 1); -- VUHDO_UPDATE_ALL
          end
        end
      end
		end

		VUHDO_setHealthSafe("player", 1); -- VUHDO_UPDATE_ALL
		VUHDO_setHealthSafe("pet", 1); -- VUHDO_UPDATE_ALL
		VUHDO_setHealthSafe("focus", 1); -- VUHDO_UPDATE_ALL
		if (VUHDO_INTERNAL_TOGGLES[27]) then -- VUHDO_UPDATE_PLAYER_TARGET
			VUHDO_setHealthSafe("target", 1); -- VUHDO_UPDATE_ALL
    end
    VUHDO_TIMERS["MIRROR_TO_MACRO"] = 8;
	end

	VUHDO_PLAYER_GROUP = VUHDO_getUnitGroup(VUHDO_PLAYER_RAID_ID, false);

	VUHDO_updateAllRaidNames();
	VUHDO_trimInspected();
	VUHDO_convertMainTanks();
	VUHDO_updateGroupArrays(false);
	VUHDO_updateAllPanelUnits();
	VUHDO_updateAllGuids();
	VUHDO_updateBuffRaidGroup();
	if (VUHDO_CurrentMode ~= 1) then -- VUHDO_MODE_NEUTRAL
		VUHDO_sortEmergencies();
	end
	VUHDO_createIndexedUnits();

	if (VUHDO_IS_SUSPICIOUS_ROSTER) then
		VUHDO_lateRaidReload();
	end
end