local VUHDO_RAID = { };
local VUHDO_RAID_GUIDS = { };
local VUHDO_INTERNAL_TOGGLES = { };

local strsplit = strsplit;
local UnitIsUnit = UnitIsUnit;
local pairs = pairs;

local VUHDO_updateHealth;
local sCurrentTarget = nil;
local sCurrentFocus = nil;



--
function VUHDO_combatLogInitBurst()
	VUHDO_RAID = VUHDO_GLOBAL["VUHDO_RAID"];
	VUHDO_RAID_GUIDS = VUHDO_GLOBAL["VUHDO_RAID_GUIDS"];
	VUHDO_INTERNAL_TOGGLES = VUHDO_GLOBAL["VUHDO_INTERNAL_TOGGLES"];
	VUHDO_updateHealth = VUHDO_GLOBAL["VUHDO_updateHealth"];
end



--
local tInfo;
local tNewHealth;
local tDeadInfo = { ["dead"] = true };
local function VUHDO_addUnitHealth(aUnit, aDelta)
	tInfo = VUHDO_RAID[aUnit] or tDeadInfo;

	if (not tInfo["dead"]) then
		tNewHealth = tInfo["health"] + aDelta;

		if (tNewHealth < 0) then
			tNewHealth = 0;
		elseif (tNewHealth > tInfo["healthmax"]) then
			tNewHealth = tInfo["healthmax"];
		end

		tInfo["health"] = tNewHealth;
		VUHDO_updateHealth(aUnit, 2); -- VUHDO_UPDATE_HEALTH
	end
end



--
local tPrefix, tSuffix, tSpecial;
local function VUHDO_getTargetHealthImpact(aMessage, aMessage1, aMessage2, aMessage4)
	tPrefix, tSuffix, tSpecial = strsplit("_", aMessage);

	if ("SPELL" == tPrefix) then
		if (("HEAL" == tSuffix or "HEAL" == tSpecial) and "MISSED" ~= tSpecial) then
			return aMessage4;
		elseif ("DAMAGE" == tSuffix or "DAMAGE" == tSpecial) then
			return -aMessage4;
		end
	elseif ("DAMAGE" == tSuffix) then
		if ("SWING" == tPrefix) then
			return -aMessage1;
		elseif ("RANGE" == tPrefix) then
			return -aMessage4;
		elseif ("ENVIRONMENTAL" == tPrefix) then
			return -aMessage2
		end
	elseif ("DAMAGE" == tPrefix and "MISSED" ~= tSpecial and "RESISTED" ~= tSpecial) then
		return -aMessage4;
	end

	return 0;
end



--
function VUHDO_clParserSetCurrentTarget(aUnit)
	if (VUHDO_INTERNAL_TOGGLES[27]) then -- VUHDO_UPDATE_PLAYER_TARGET
		sCurrentTarget = aUnit;
	else
		sCurrentTarget = "*"; -- foo
	end
end



--
local tUnit, tInfo;
local tEmptyInfo = { };
function VUHDO_clParserSetCurrentFocus()
	sCurrentFocus = nil;

	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if (UnitIsUnit("focus", tUnit) and tUnit ~= "focus" and tUnit ~= "target") then
			if (tInfo["isPet"] and (VUHDO_RAID[tInfo["ownerUnit"]] or tEmptyInfo)["isVehicle"]) then
				sCurrentFocus = tInfo["ownerUnit"];
			else
				sCurrentFocus = tUnit;
			end
			break;
		end
	end

end



--
local tUnit;
local tImpact;
function VUHDO_parseCombatLogEvent(aMessage, aDstGUID, aMessage1, aMessage2, aMessage4)
	tUnit = VUHDO_RAID_GUIDS[aDstGUID];
	if (tUnit == nil) then
		return;
	end

	tImpact = VUHDO_getTargetHealthImpact(aMessage, aMessage1, aMessage2, aMessage4);

	if (tImpact ~= 0) then
		VUHDO_addUnitHealth(tUnit, tImpact);
		if (tUnit == sCurrentTarget) then
			VUHDO_addUnitHealth("target", tImpact);
		end
		if (tUnit == sCurrentFocus) then
			VUHDO_addUnitHealth("focus", tImpact);
		end
	end
end
