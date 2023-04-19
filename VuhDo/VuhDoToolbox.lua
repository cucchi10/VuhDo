local strlen = strlen;
local strsub = strsub;
local InCombatLockdown = InCombatLockdown;
local twipe = table.wipe;
local tinsert = tinsert;
local strfind = strfind;
local strsplit = strsplit;
local strbyte = strbyte;
local floor = floor;
local tonumber = tonumber;
local UnitInRaid = UnitInRaid;
local UnitExists = UnitExists;
local UnitInRange = UnitInRange;
local GetRaidRosterInfo = GetRaidRosterInfo;
local IsInInstance = IsInInstance;
local IsSpellInRange = IsSpellInRange;
local GetTime = GetTime;
local GetRealZoneText = GetRealZoneText;
local GetMapInfo = GetMapInfo;
local GetSpellInfo = GetSpellInfo;
local pairs = pairs;
local _ = _;



-- returns an array of numbers sequentially found in a string
local tCnt;
local tNumbers = { };
local tIndex;
local tStrlen;
local tDigit;
local tIsInNumber;
function VUHDO_getNumbersFromString(aName, aMaxAnz)
	twipe(tNumbers);
	tIndex = 0;
	tStrlen = strlen(aName);
	tIsInNumber = false;

	for tCnt = 1, tStrlen do
		tDigit = strbyte(aName, tCnt) - 48;
		if (tDigit >= 0 and tDigit <= 9) then
			if (tIsInNumber) then
				tNumbers[tIndex] = tNumbers[tIndex] * 10 + tDigit;
			else
				tIsInNumber = true;
				tIndex = tIndex + 1;
				tNumbers[tIndex] = tDigit;
			end
		else
			if (tIndex >= aMaxAnz) then
				return tNumbers;
			end

			tIsInNumber = false;
		end
	end

	return tNumbers;
end



--
local tValue;
function VUHDO_tableUniqueAdd(aTable, aValue)
	for _, tValue in pairs(aTable) do
		if (tValue == aValue) then
			return false;
		end
	end

	tinsert(aTable, aValue);
	return true;
end



----------------------------------------------------
local VUHDO_RAID_NAMES;
local VUHDO_RAID;
local VUHDO_UNIT_BUTTONS;
local VUHDO_CONFIG;
local VUHDO_GROUPS_BUFFS;
local sRangeSpell;
local sIsGuessRange = true;
local sScanRange;


--
local VUHDO_updateBouquetsForEvent;
function VUHDO_toolboxInitBurst()
	VUHDO_RAID_NAMES = VUHDO_GLOBAL["VUHDO_RAID_NAMES"];
	VUHDO_RAID = VUHDO_GLOBAL["VUHDO_RAID"];
	VUHDO_UNIT_BUTTONS = VUHDO_GLOBAL["VUHDO_UNIT_BUTTONS"];
	VUHDO_CONFIG = VUHDO_GLOBAL["VUHDO_CONFIG"];
	VUHDO_GROUPS_BUFFS = VUHDO_GLOBAL["VUHDO_GROUPS_BUFFS"];
	VUHDO_updateBouquetsForEvent = VUHDO_GLOBAL["VUHDO_updateBouquetsForEvent"];
	sScanRange = tonumber(VUHDO_CONFIG["SCAN_RANGE"]);
	sRangeSpell = VUHDO_CONFIG["RANGE_SPELL"];
	sIsGuessRange = VUHDO_CONFIG["RANGE_PESSIMISTIC"] or GetSpellInfo(VUHDO_CONFIG["RANGE_SPELL"]) == nil;
end



local VUHDO_PROFILE_TIMER = 0; -- Profilers starting time stamp

-- Init by setting start time stamp
function VUHDO_initProfiler()
	VUHDO_Msg("Init Profiler");
	VUHDO_PROFILE_TIMER = GetTime() * 1000;
end



-- Dump the duration in ms since profiler has been initialized
function VUHDO_seeProfiler()
	local tTimeDelta = floor(GetTime() * 1000 - VUHDO_PROFILE_TIMER);
	VUHDO_Msg("Duration: " .. tTimeDelta);
end



--
--local tInfo;
--function VUHDO_dumpRaid()
--	for _, tInfo in pairs(VUHDO_RAID) do
--		VUHDO_Msg(tInfo.name .. ": " .. tInfo.unit);
--	end
--end



-- Print chat frame line with no "{Vuhdo} prefix
function VUHDO_MsgC(aMessage, aRed, aGreen, aBlue)
	aRed = aRed or 1;
	aGreen = aGreen or 0.7;
	aBlue = aBlue or 0.2;

	DEFAULT_CHAT_FRAME:AddMessage(aMessage, aRed, aGreen, aBlue);
end



--
local tMessage;
local function VUHDO_argumentToText(anArgument)

	if (anArgument == nil) then
		tMessage = "<nil>";
	elseif ("function" == type(anArgument)) then
		tMessage = "<function>";
	elseif ("table" == type(anArgument)) then
		tMessage = "<table>";
	elseif ("boolean" == type(anArgument)) then
		if (anArgument) then
			tMessage = "<true>";
		else
			tMessage = "<false>";
		end
	elseif (anArgument == "") then
		tMessage = " ";
	else
		tMessage = anArgument;
	end

	return tMessage;
end



-- Print a standard chat frame
function VUHDO_Msg(aMessage, aRed, aGreen, aBlue)
	aMessage = VUHDO_argumentToText(aMessage);
	VUHDO_MsgC("|cffffe566{VuhDo}|r " .. aMessage, aRed, aGreen, aBlue)
end



--
local tText;
local tCnt;
local tFrag;
function VUHDO_xMsg(...)
	tText = "";
	for tCnt = 1, select('#', ...) do
		tFrag = select(tCnt, ...);
		tText = tText .. tCnt .. "=[" .. VUHDO_argumentToText(tFrag) .. "] ";
	end
	VUHDO_MsgC(tText);
end



-- Returns the type of a given model id
function VUHDO_getModelType(aModelId)
	if ((aModelId >= 1 and aModelId <= 8) or aModelId == 10) then -- VUHDO_ID_GROUP_1 -- VUHDO_ID_GROUP_8 -- VUHDO_ID_GROUP_OWN
		return 2; -- VUHDO_ID_TYPE_GROUP
	elseif (aModelId >= 20 and aModelId <= 29) then -- VUHDO_ID_WARRIORS -- VUHDO_ID_DEATH_KNIGHT
		return 1; -- VUHDO_ID_TYPE_CLASS
	elseif (aModelId == 0) then -- VUHDO_ID_UNDEFINED
	  return 0; -- VUHDO_ID_TYPE_UNDEFINED
	else
		return 3; -- VUHDO_ID_TYPE_SPECIAL
	end
end



-- returns unit-prefix, pet-prefix and maximum number of players in a party
function VUHDO_getUnitIds()
	if (UnitInRaid("player")) then
		return "raid", "raidpet";
	elseif (UnitExists("party1")) then
		return "party", "partypet";
	else
		return "player", "pet";
	end
end
local VUHDO_getUnitIds = VUHDO_getUnitIds;



-- Extracts unit number from a Unit's name
local tUnitNo;
function VUHDO_getUnitNo(aUnit)
	if ("player" == aUnit) then
		aUnit = VUHDO_PLAYER_RAID_ID or "player";
	end
	tUnitNo = tonumber(strsub(aUnit, -2, -1)) or tonumber(strsub(aUnit, -1));
	if (tUnitNo ~= nil) then
		return tUnitNo;
	elseif ("focus" == aUnit or "target" == aUnit) then
		return 0;
	else
		return 1;
	end
end
local VUHDO_getUnitNo = VUHDO_getUnitNo;



-- returns the units subgroup number, or 0 for pets/focus
local tGroupNo;
function VUHDO_getUnitGroup(aUnit, anIsPet)
	if (anIsPet or aUnit == nil or aUnit == "focus" or aUnit == "target") then
		return 0;
	elseif (UnitInRaid("player")) then
		_, _, tGroupNo, _, _, _, _, _ = GetRaidRosterInfo(VUHDO_getUnitNo(aUnit));
		return tGroupNo or 1;
	else
		return 1;
	end
end



-- returns wether or not a unit is in range
function VUHDO_isInRange(aUnit)
	if ("focus" == aUnit or "target" == aUnit) then
		return CheckInteractDistance(aUnit, 1);
	elseif (sIsGuessRange) then
		return UnitInRange(aUnit);
	else
		--return UnitInRange(aUnit) or (1 == IsSpellInRange(sRangeSpell, aUnit));
		return 1 == IsSpellInRange(sRangeSpell, aUnit);
	end
end



-- Parses a aString line into an array of arguments
function VUHDO_textParse(aString)
   local tTextLen = 1;
   local tOutStrings = {};
   local tTextNum = 1;
   local tStartIdx = 1;
   local tStopIdx = 1;
   local tTextIdxStart = 1;
   local tTextIdxStop = 1;
   local tTextLeft = 1;
   local tNextSpaceIdx = 1;
   local tTextChunk = "";
   local tAnzIterations = 1;
   local tIsErroneous = false;

   if ((aString ~= nil) and (aString ~= "")) then
      while (string.find(aString, "  ") ~= nil) do
     	  aString = string.gsub(aString, "  ", " ");
      end

      if (string.len(aString) <= 1) then
         tIsErroneous = true;
      end

      if tIsErroneous ~= true then
        tTextIdxStart = 1;
        tTextIdxStop = string.len(aString);

        if (string.sub(aString, tTextIdxStart, tTextIdxStart) == " ") then
           tTextIdxStart = tTextIdxStart+1;
        end

        if (string.sub(aString, tTextIdxStop, tTextIdxStop) == " ") then
           tTextIdxStop = tTextIdxStop-1;
        end

        aString = string.sub(aString, tTextIdxStart, tTextIdxStop);
      end

      tTextNum = 1;
      tTextLeft = string.len(aString);

      while (tStartIdx <= tTextLeft) and (tIsErroneous ~= true) do

         tNextSpaceIdx = string.find(aString, " ",tStartIdx);
         if (tNextSpaceIdx ~= nil) then
            tStopIdx = (tNextSpaceIdx - 1);
         else
            tStopIdx = string.len(aString);
            LetsEnd = true;
         end

         tTextChunk = string.sub(aString, tStartIdx, tStopIdx);
         tOutStrings[tTextNum] = tTextChunk;
         tTextNum = tTextNum + 1;

         tStartIdx = tStopIdx + 2;

      end
   else
      tOutStrings[1] = "Error: Bad value passed to TextParse!";
   end

   if (tIsErroneous ~= true) then
      return tOutStrings;
   else
      return {"Error: Bad value passed to TextParse!"};
   end
end



-- Returns a "deep" copy of a table,
-- which means containing tables will be copies value-wise, not by reference
function VUHDO_deepCopyTable(aTable)
	local tDestTable = { };
	local tKey, tValue;

	for tKey, tValue in pairs(aTable) do
		if ("table" == type(tValue)) then
			tDestTable[tKey] = VUHDO_deepCopyTable(tValue);
		else
			tDestTable[tKey] = tValue;
		end
	end

	return tDestTable;
end



-- Tokenizes a String into an array of strings, which were delimited by "aChar"
function VUHDO_splitString(aText, aChar)
	return { strsplit(aChar, aText) };
end



-- returns true if player currently is in a battleground
local tType;
function VUHDO_isInBattleground()
	_, tType = IsInInstance();
	return "pvp" == tType or "arena" == tType;
end
local VUHDO_isInBattleground = VUHDO_isInBattleground;



-- returns the appropriate addon message channel for player
function VUHDO_getAddOnDistribution()
	if (VUHDO_isInBattleground()) then
		return "BATTLEGROUND";
	elseif(UnitInRaid("player")) then
		return "RAID";
	else
		return "PARTY";
	end
end



-- returns the players rank in a raid which is 0 = raid member, 1 = assist, 2 = leader
-- returns leader if not in raid, and member if solo, as no main tank are needed
local tUnitNo;
local tRank, tIsMl;
function VUHDO_getPlayerRank()
	for tUnit, _ in pairs(VUHDO_RAID) do
		if (tUnit == "player") then
			if (UnitInRaid("player")) then
				tUnitNo = VUHDO_getUnitNo(tUnit);
				_, tRank, _, _, _, _, _, _, _, _, tIsMl = GetRaidRosterInfo(tUnitNo);
				return tRank, tIsMl;
			elseif (GetNumPartyMembers() > 0) then
				return 2, true;
			else
				return 2, true;
			end
		end
	end

	return 2, true;
end



-- returns the units rank in a raid which is 0 = raid member, 1 = assist, 2 = leader
-- returns 2 if not in raid
local tRank, tIsMl;
function VUHDO_getUnitRank(aUnit)
	if (UnitInRaid("player")) then
		_, tRank, _, _, _, _, _, _, _, _, tIsMl = GetRaidRosterInfo(VUHDO_getUnitNo(aUnit));
		return tRank, tIsMl;
	end

	return 2, true;
end



-- returns the raid unit of player eg. "raid13" or "party4"
local tCnt, tRaidUnit;
function VUHDO_getPlayerRaidUnit()
	if (UnitInRaid("player")) then
		for tCnt = 1, 40 do
			tRaidUnit = "raid" .. tCnt;
			if (UnitIsUnit("player", tRaidUnit)) then
				return tRaidUnit;
			end
		end
	end
	return "player";
end
local VUHDO_getPlayerRaidUnit = VUHDO_getPlayerRaidUnit;



--
local tEmpty = { };
function VUHDO_getNumGroupMembers(aGroupId)
	return #(VUHDO_GROUPS[aGroupId] or tEmpty);
end



--
local tZone, tIndex, tMap;
local tEmpty = { };
function VUHDO_getUnitZoneName(aUnit)
	tInfo = VUHDO_RAID[aUnit];
	if (tInfo == nil) then
		return;
	end

	if ("player" == aUnit or tInfo["visible"]) then
		tZone = GetRealZoneText();
	elseif (UnitInRaid("player")) then
		tIndex = (VUHDO_RAID[aUnit] or tEmpty)["number"] or 1;
		_, _, _, _, _, _, tZone, _, _ = GetRaidRosterInfo(tIndex);
	else
    if (not VuhDoScanTooltip:IsOwned(VuhDo)) then
    	VuhDoScanTooltip:SetOwner(VuhDo, "ANCHOR_NONE");
	    VuhDoScanTooltip:ClearLines();
    end
    VuhDoScanTooltip:SetUnit(aUnit)
    tZone = VuhDoScanTooltipTextLeft3:GetText();
    if (tZone == "PvP") then
    	tZone = VuhDoScanTooltipTextLeft4:GetText();
    end
	end

	if (tZone == nil or strfind(tZone, "Level", 1, true)) then
		tZone = VUHDO_I18N_UNKNOWN;
	end
	tMap, _, _ = GetMapInfo();
	return tZone, tMap;
end



--
local tZoneOkay;
local tUnitZone, tPlayerZone;
local tIdx;
local tEmptyZone = { };
function VUHDO_isInSameZone(aUnit)
	return (VUHDO_RAID[aUnit] or tEmptyZone)["map"] == (VUHDO_RAID["player"] or tEmptyZone)["map"];
end
local VUHDO_isInSameZone = VUHDO_isInSameZone;



-- Returns health of unit info in Percent
local tHealthMax;
function VUHDO_getUnitHealthPercent(anInfo)
	tHealthMax = anInfo["healthmax"];
	if (tHealthMax == 0) then
		return 0;
	end

	if (anInfo["health"] < tHealthMax) then
		return (anInfo["health"] / tHealthMax) * 100;
	else
		return 100;
	end
end



--
function VUHDO_isSpellKnown(aSpellName)
	return GetSpellInfo(aSpellName) ~= nil;
end



--
local tDeltaSecs;
function VUHDO_getDurationTextSince(aStartTime)
	if (aStartTime == nil) then
		return "";
	end

	tDeltaSecs = GetTime() - aStartTime;

	if (tDeltaSecs >= 3600) then
		return "(|cffffffff" .. floor(tDeltaSecs / 360) * 0.1 .. " hours|r)";
	elseif(tDeltaSecs >= 60) then
		return "(|cffffffff" .. floor(tDeltaSecs / 60) .. " mins|r)";
	else
		return "(|cffffffff" .. floor(tDeltaSecs) .. " secs|r)";
	end
end



--
local tDistance;
function VUHDO_getDistanceText(aUnit)
	tDistance = VUHDO_getDistanceBetween("player", aUnit);
	if (tDistance ~= nil) then
		return floor(tDistance * 10) / 10 .. " " .. VUHDO_I18N_YARDS;
	elseif ("player" == aUnit) then
		return "0.0 " .. VUHDO_I18N_YARDS;
	else
		return VUHDO_I18N_UNKNOWN;
	end

end



--
local tPet;
function VUHDO_getPetUnit(anOwnerUnit)
	_, tPet, _ = VUHDO_getUnitIds();

	if ("player" == anOwnerUnit) then
		return "pet";
	elseif ("focus" == anOwnerUnit or "target" == anOwnerUnit) then
		return nil;
	elseif ("raidpet" == tPet or "partypet" == tPet) then
		return tPet .. VUHDO_getUnitNo(anOwnerUnit);
	else
		return "pet";
	end
end



--
function VUHDO_getTargetUnit(aSourceUnit)
	if ("player" == aSourceUnit) then
		return "target";
	else
		return aSourceUnit .. "target";
	end
end



--
function VUHDO_getResurrectionSpells()
	if (VUHDO_RESURRECTION_SPELLS[VUHDO_PLAYER_CLASS] == nil) then
		return nil, nil;
	elseif (#VUHDO_RESURRECTION_SPELLS[VUHDO_PLAYER_CLASS] == 1) then
		return VUHDO_RESURRECTION_SPELLS[VUHDO_PLAYER_CLASS][1], nil;
	else
		if (InCombatLockdown()) then
			return VUHDO_RESURRECTION_SPELLS[VUHDO_PLAYER_CLASS][2], VUHDO_RESURRECTION_SPELLS[VUHDO_PLAYER_CLASS][1];
		else
			return VUHDO_RESURRECTION_SPELLS[VUHDO_PLAYER_CLASS][1], VUHDO_RESURRECTION_SPELLS[VUHDO_PLAYER_CLASS][2];
		end
	end
end



--
local tBtnUnit;
local tBtnName;
function VUHDO_resolveButtonUnit(aButton)
	return aButton:GetAttribute("unit");
end



--
local tInfo;
local tEmptyInfo = { };
function VUHDO_resolveVehicleUnit(aUnit)
	tInfo = VUHDO_RAID[aUnit] or tEmptyInfo;
	if (tInfo["isPet"] and (VUHDO_RAID[tInfo["ownerUnit"]] or tEmptyInfo)["isVehicle"]) then
		return tInfo["ownerUnit"];
	else
		return aUnit;
	end
end



--
local tBtnInfo;
local tButtons;
function VUHDO_getUnitButtons(aUnit)
	return VUHDO_UNIT_BUTTONS[aUnit];
end



--
function VUHDO_getBuffVariantMaxTarget(someVariants)
	return someVariants[2] or someVariants[1];
end



--
function VUHDO_getBuffVariantSingleTarget(someVariants)
	return someVariants[1];
end



--
local tEmpty = { };
local tInfo;
function VUHDO_shouldScanUnit(aUnit)
  tInfo = VUHDO_RAID[aUnit] or tEmpty;
  if (not tInfo["connected"] or tInfo["dead"]) then
    return true;
	elseif (sScanRange == 1) then
		return VUHDO_isInSameZone(aUnit);
	elseif (sScanRange == 2) then
		return tInfo["visible"];
	elseif (sScanRange == 3) then
		return tInfo["baseRange"];
	else
		return true;
	end
end



--
local tNumBytes, tNumChars;
local tNumCut;
local tByte;
function VUHDO_utf8Cut(aString, aNumChars)
	tNumBytes = strlen(aString);
	tNumCut = 1;
	tNumChars = 0;
	while (tNumCut < tNumBytes and tNumChars < aNumChars) do
		tByte = strbyte(aString, tNumCut);
		if (tByte < 128) then
			tNumCut = tNumCut + 1;
		elseif (tByte >= 194 and tByte <= 223) then
			tNumCut = tNumCut + 2;
		elseif (tByte >= 224 and tByte <= 239) then
			tNumCut = tNumCut + 3;
		elseif (tByte >= 240 and tByte <= 244) then
			tNumCut = tNumCut + 4;
		else
			tNumCut = tNumCut + 1; -- invalid
		end
		tNumChars = tNumChars + 1;
	end

	return strsub(aString, 1, tNumCut - 1);
end
