

VuhDoHealComms = { };


-- BURST CACHE ---------------------------------------------------
local floor = floor;
local select = select;
local pairs = pairs;

local VUHDO_CONFIG;
local VUHDO_RAID_GUID_NAMES;

local VUHDO_updateHealthBarsFor;

local GetTime = GetTime;
local strsub = strsub;
local sIsCasted, sIsChannelled, sIsHots, sIsBombed;
local sIsOthers, sIsOwn;
local sCastedSecs, sChannelledSecs, sHotsSecs, sBombedSecs;
function VUHDO_healCommAdapterInitBurst()
	VUHDO_CONFIG = VUHDO_GLOBAL["VUHDO_CONFIG"];
	VUHDO_RAID_GUID_NAMES = VUHDO_GLOBAL["VUHDO_RAID_GUID_NAMES"];
	VUHDO_updateHealthBarsFor = VUHDO_GLOBAL["VUHDO_updateHealthBarsFor"];
	sIsCasted = VUHDO_CONFIG["SHOW_INC_CASTED"];
	sIsChannelled = VUHDO_CONFIG["SHOW_INC_CHANNELLED"];
	sIsHots = VUHDO_CONFIG["SHOW_INC_HOTS"];
	sIsBombed = VUHDO_CONFIG["SHOW_INC_BOMBED"];
	sIsOthers = VUHDO_CONFIG["SHOW_INCOMING"];
	sIsOwn = VUHDO_CONFIG["SHOW_OWN_INCOMING"];
  sCastedSecs = VUHDO_CONFIG["INC_CASTED_SECS"]
  sChannelledSecs = VUHDO_CONFIG["INC_CHANNELLED_SECS"];
  sHotsSecs = VUHDO_CONFIG["INC_HOTS_SECS"]
  sBombedSecs = VUHDO_CONFIG["INC_BOMBED_SECS"]
end


----------------------------------------------------


local VUHDO_INC_HEAL = { };
local VUHDO_INC_END = { };


--
local tInfo;
function VUHDO_getIncHealOnUnit(aName)
	return VUHDO_INC_HEAL[aName] or 0;
end



--
local function VUHDO_setIncHeal(aTargetName, anAmount, anEndTime)
	VUHDO_INC_HEAL[aTargetName] = anAmount;
	if (anEndTime ~= nil and (VUHDO_INC_END[aTargetName] == nil or VUHDO_INC_END[aTargetName] < anEndTime)) then
		VUHDO_INC_END[aTargetName] = anEndTime + 1;
	end
	VUHDO_updateHealthBarsFor(VUHDO_RAID_NAMES[aTargetName], 9); -- VUHDO_UPDATE_INC
end



--
local tName, tTime, tNow;
function VUHDO_clearObsoleteInc()
	tNow = GetTime();
	-- Clear obsolete ending times
	for tName, tTime in pairs(VUHDO_INC_END) do
		if (tTime < tNow) then
			VUHDO_setIncHeal(tName, 0, nil);
			VUHDO_INC_END[tName] = nil;
		end
	end
end



local sHealComm = LibStub("LibHealComm-4.0");
local VUHDO_DIRECT_HEALS = sHealComm.DIRECT_HEALS;
local VUHDO_CHANNEL_HEALS = sHealComm.CHANNEL_HEALS;
local VUHDO_HOT_HEALS = sHealComm.HOT_HEALS;
local VUHDO_BOMB_HEALS = sHealComm.BOMB_HEALS;

--
local tArgNum, tTargetGUID;
local tAmount;
local tCasterName;
local tTargetName;
local tAmount;
local tNow;
local tCnt;
function VuhDoHealComms:HealComm_HealStarted(_, aCasterGUID, _, aHealType, anEndTime, ...)
	tCasterName = VUHDO_RAID_GUID_NAMES[aCasterGUID];
	tNow = GetTime();

	if (tCasterName ~= nil and
				(sIsOthers and VUHDO_PLAYER_NAME ~= tCasterName)
		 or (sIsOwn and VUHDO_PLAYER_NAME == tCasterName)) then

		tArgNum = select("#", ...);

		for tCnt = 1, tArgNum do
			tTargetGUID = select(tCnt, ...);
			tTargetName = VUHDO_RAID_GUID_NAMES[tTargetGUID];
			if (tTargetName ~= nil) then
				tAmount = 0;

				if (sIsCasted) then
					tAmount = tAmount + (sHealComm:GetHealAmount(tTargetGUID, VUHDO_DIRECT_HEALS, tNow + sCastedSecs, nil) or 0);
				end

				if (sIsChannelled) then
					tAmount = tAmount + (sHealComm:GetHealAmount(tTargetGUID, VUHDO_CHANNEL_HEALS, tNow + sChannelledSecs, nil) or 0);
				end

				if (sIsHots) then
					tAmount = tAmount + (sHealComm:GetHealAmount(tTargetGUID, VUHDO_HOT_HEALS, tNow + sHotsSecs, nil) or 0);
				end

				if (sIsBombed) then
					tAmount = tAmount + (sHealComm:GetHealAmount(tTargetGUID, VUHDO_BOMB_HEALS, tNow + sBombedSecs, nil) or 0);
				end

				tAmount = floor(tAmount * sHealComm:GetHealModifier(tTargetGUID));
				VUHDO_setIncHeal(tTargetName, tAmount, anEndTime);
			end
		end
	end
end



--
function VuhDoHealComms:HealComm_HealStopped(_, aCasterGUID, _, aHealType, anIsInterrupted, ...)
	VuhDoHealComms:HealComm_HealStarted(nil, aCasterGUID, aSpellID, aHealType, nil, ...);
end
