-- for saving once learnt yards in saved variables
local VUHDO_STORED_ZONES = { };
local VUHDO_CLUSTER_BLACKLIST = { };

local sqrt = sqrt;
local GetPlayerMapPosition = GetPlayerMapPosition;
local CheckInteractDistance = CheckInteractDistance;
local GetMapInfo = GetMapInfo;
local GetCurrentMapDungeonLevel = GetCurrentMapDungeonLevel;
local SetMapToCurrentZone = SetMapToCurrentZone;
local table = table;
local tinsert = tinsert;
local WorldMapFrame = WorldMapFrame;
local GetMouseFocus = GetMouseFocus;
local pairs = pairs;
local twipe = table.wipe;


local VUHDO_COORD_DELTAS = { };
local VUHDO_MAP_WIDTH = 0;
local VUHDO_LAST_ZONE = nil;

local VUHDO_MIN_TICK_UNIT = 0.000000000001;
local VUHDO_MAX_TICK_UNIT = 1;
local VUHDO_MAP_LIMIT_YARDS = 1000000;
local VUHDO_MAX_SAMPLES = 50;
local VUHDO_MAX_ITERATIONS = 120; -- For a 40 man raid there is a total of +800 iterations

local sCdSpell;

--
local VUHDO_CLUSTER_BASE_RAID = { };
function VUHDO_clusterBuilderInitBurst()
	VUHDO_CLUSTER_BASE_RAID = VUHDO_GLOBAL["VUHDO_CLUSTER_BASE_RAID"];
	sCdSpell = VUHDO_CONFIG["CLUSTER"]["COOLDOWN_SPELL"];
	if (sCdSpell == nil or sCdSpell == "" or not VUHDO_isSpellKnown(sCdSpell)) then
		sCdSpell = nil;
	end
end



--
local tLastTime = 0;
local function VUHDO_setMapToCurrentZone()
	if (tLastTime + 2 < GetTime()) then
		SetMapToCurrentZone();
		tLastTime = GetTime();
	end
end



--
local VUHDO_MAP_FIX_WIDTH = {

  ["VaultofArchavon"] = {
    [1] = 1398.255004883,
  },

  ["TheObsidianSanctum"] = {
    [0] = 1162.4967,
  },

  ["IcecrownCitadel"] = {
  	[1] = 1355.47009278,
  	[2] = 1067,
  	[3] = 195.46997071,
  	[4] = 773.71008301,
  	[5] = 1148.73999024,
  	[6] = 373.70996094,
  	[7] = 293.26000977,
  	[8] = 247.92993165,
  },

  ["TheArgentColiseum"] = {
  	[1] = 369.9861869814,
  	[2] = 739.996017456,
  },

  ["TheEyeofEternity"] = {
    [1] = 430.07006836,
  },

  ["CoTStratholme"] = {
  	[1] = 1824.997,
  	[2] = 1125.299987791,
  },

  ["PitofSaron"] = {
    [0] = 1533.333,
  },

  ["Ulduar"] = {
  	[1] = 3287.49987793,
  	[2] = 669.45098877,
  	[3] = 1328.460998535,
  	[4] = 910.5,
  	[5] = 1569.45996094,
  	[6] = 619.46899414,
  },

  ["Ahnkahet"] = {
    [1] = 972.417968747,
  },

  ["Gundrak"] = {
    [1] = 905.033050542,
  },

  ["UtgardeKeep"] = {
  	[1] = 734.580993652,
  	[2] = 481.081008911,
  	[3] = 736.581008911,
  },

  ["Naxxramas"] = {
  	[1] = 1093.83007813,
  	[2] = 1093.83007813,
  	[3] = 1200,
  	[4] = 1200.33007813,
  	[5] = 2069.80981445,
  	[6] = 655.9399414,
  },

  ["HallsofLightning"] = {
  	[1] = 566.235015869,
  	[2] = 708.23701477,
  },

  ["DrakTharonKeep"] = {
  	[1] = 619.93917093835,
  	[2] = 619.93877606243,
  },

  ["Ulduar77"] = {
    [1] = 920.19794213868,
  },

  ["TheForgeofSouls"] = {
    [1] = 1448.09985351,
  },

  ["HallsofReflection"] = {
    [1] = 879.02001954,
  },

  ["TheNexus"] = {
    [1] = 1101.280975342,
  },

  ["AzjolNerub"] = {
  	[1] = 752.973999023,
  	[2] = 292.973999023,
  	[3] = 367.5,
  },

  ["UtgardePinnacle"] = {
  	[1] = 548.936019897,
  	[2] = 756.17994308428,
  },

  ["VioletHold"] = {
    [1] = 256.229003907,
  },

  ["Nexus80"] = {
  	[1] = 514.706970217,
  	[2] = 664.706970217,
  	[3] = 514.706970217,
  	[4] = 294.700988772,
  },
};



-- Inspect, Trade, Duel, UnitInRange(, UnitIsVisible? => doesn't seem to be reliable)
local VUHDO_INTERACT_MAX_DISTANCES = { VUHDO_MIN_TICK_UNIT, VUHDO_MIN_TICK_UNIT, VUHDO_MIN_TICK_UNIT, VUHDO_MIN_TICK_UNIT };
local VUHDO_INTERACT_FAIL_MIN_DISTANCES = { VUHDO_MAX_TICK_UNIT, VUHDO_MAX_TICK_UNIT, VUHDO_MAX_TICK_UNIT, VUHDO_MAX_TICK_UNIT };
local VUHDO_INTERACT_YARDS = { 28, 11.11, 9.9, 40 };



--
local function VUHDO_clusterBuilderStoreZone(aZone)
	if (aZone ~= nil)  then
		VUHDO_STORED_ZONES[aZone] = { };
		VUHDO_STORED_ZONES[aZone]["good"] = VUHDO_deepCopyTable(VUHDO_INTERACT_MAX_DISTANCES);
		VUHDO_STORED_ZONES[aZone]["fail"] = VUHDO_deepCopyTable(VUHDO_INTERACT_FAIL_MIN_DISTANCES);
	end
end



--
local tIsValid;
local function VUHDO_isValidClusterUnit(anInfo)
	tIsValid = not anInfo["dead"]
				    and anInfo["connected"]
				    and anInfo["visible"]; -- Marks the max. line of 100 yards

	VUHDO_CLUSTER_BLACKLIST[anInfo["unit"]] = not tIsValid;
	return tIsValid;
end



--
local tCnt, tDistance;
local tEmptyUnit = { };
local function VUHDO_calibrateMapScale(aUnit, aDeltaX, aDeltaY)
  -- Pythagoras, y range is alwyay x range / 1.5 in all current maps. (mul is faster than div in lua)
  tDistance = sqrt((aDeltaX * aDeltaX)  + ((aDeltaY * 0.6666666666666) ^ 2));

	for tCnt = 1, 3 do
		-- Check only if new distance is within bandwidth (= better result than before)
		if (tDistance > VUHDO_INTERACT_MAX_DISTANCES[tCnt] and tDistance < VUHDO_INTERACT_FAIL_MIN_DISTANCES[tCnt]) then
			if (CheckInteractDistance(aUnit, tCnt)) then
				VUHDO_INTERACT_MAX_DISTANCES[tCnt] = tDistance;
			else
				VUHDO_INTERACT_FAIL_MIN_DISTANCES[tCnt] = tDistance;
			end
			VUHDO_clusterBuilderStoreZone(VUHDO_LAST_ZONE);
		end
	end

	if (tDistance > VUHDO_INTERACT_MAX_DISTANCES[4] and tDistance < VUHDO_INTERACT_FAIL_MIN_DISTANCES[4]) then
		if ((VUHDO_RAID[aUnit] or tEmptyUnit)["baseRange"]) then
			VUHDO_INTERACT_MAX_DISTANCES[4] = tDistance;
		else
			VUHDO_INTERACT_FAIL_MIN_DISTANCES[4] = tDistance;
		end
		VUHDO_clusterBuilderStoreZone(VUHDO_LAST_ZONE);
	end
end



--
local tIndex, tNormFactor;
local tCurrWorldSize, tMinWorldSize, tUpperBoundary;
local function VUHDO_getHeuristicMapWidth()
	tMinWorldSize = VUHDO_MAP_LIMIT_YARDS;
	tUpperBoundary = nil;
	for tIndex, tNormFactor in pairs(VUHDO_INTERACT_YARDS) do
		tCurrWorldSize = tNormFactor / VUHDO_INTERACT_MAX_DISTANCES[tIndex]; -- yards per full tick = world size in yards

		if (tCurrWorldSize < tMinWorldSize) then -- Better test results are always smaller = closer to the limit of interact distance
			tMinWorldSize = tCurrWorldSize;
			if (VUHDO_INTERACT_FAIL_MIN_DISTANCES[tIndex] < VUHDO_MAX_TICK_UNIT) then
			  tUpperBoundary = tNormFactor / VUHDO_INTERACT_FAIL_MIN_DISTANCES[tIndex];
			end
		end
	end

	if (tUpperBoundary ~= nil) then
		return (tMinWorldSize + tUpperBoundary) * 0.5;
	else
		return tMinWorldSize;
	end
end



--
local tX1, tY1, tX2, tY2;
local tIsValid;
local function VUHDO_determineDistanceBetween(aUnit, anotherUnit)
	tIsValid = true;

	tX1, tY1 = GetPlayerMapPosition(aUnit);
	if (tX1 + tY1 <= 0) then
	  VUHDO_CLUSTER_BLACKLIST[aUnit] = true;
		tIsValid = false;
	end

	tX2, tY2 = GetPlayerMapPosition(anotherUnit);
	if (tX2 + tY2 <= 0) then
	  VUHDO_CLUSTER_BLACKLIST[anotherUnit] = true;
		tIsValid = false;
	end

	if (not tIsValid) then
		return nil, nil;
	end

	return tX1 - tX2, tY1 - tY2;
end



--
local function VUHDO_clusterBuilderNewZone(anOldZone, aNewZone)
	VUHDO_clusterBuilderStoreZone(anOldZone);

	if (VUHDO_STORED_ZONES[aNewZone] ~= nil) then
		VUHDO_INTERACT_MAX_DISTANCES = VUHDO_deepCopyTable(VUHDO_STORED_ZONES[aNewZone]["good"]);
		VUHDO_INTERACT_FAIL_MIN_DISTANCES = VUHDO_deepCopyTable(VUHDO_STORED_ZONES[aNewZone]["fail"]);
	else
		VUHDO_INTERACT_MAX_DISTANCES[1] = VUHDO_MIN_TICK_UNIT;
		VUHDO_INTERACT_MAX_DISTANCES[2] = VUHDO_MIN_TICK_UNIT;
		VUHDO_INTERACT_MAX_DISTANCES[3] = VUHDO_MIN_TICK_UNIT;
		VUHDO_INTERACT_MAX_DISTANCES[4] = VUHDO_MIN_TICK_UNIT;
		VUHDO_INTERACT_FAIL_MIN_DISTANCES[1] = VUHDO_MAX_TICK_UNIT;
		VUHDO_INTERACT_FAIL_MIN_DISTANCES[2] = VUHDO_MAX_TICK_UNIT;
		VUHDO_INTERACT_FAIL_MIN_DISTANCES[3] = VUHDO_MAX_TICK_UNIT;
		VUHDO_INTERACT_FAIL_MIN_DISTANCES[4] = VUHDO_MAX_TICK_UNIT;
	end
end



--
local tUnit, tInfo, tCnt;
local tAnotherUnit, tAnotherInfo;
local tX, tY, tDeltaX, tDeltaY, tDeltas;
local tMaxX, tMaxY;
local tMapFileName, tDungeonLevels, tCurrLevel;
local tCurrentZone;
local tNumRaid;
local tIndex = 0;
local tNumSamples, tNumIterations;
function VUHDO_updateAllClusters() 																													-- Carbonite workaround
	if ((WorldMapFrame ~= nil and WorldMapFrame:IsShown())
	  or (GetMouseFocus() ~= nil and GetMouseFocus():GetName() == nil)) then
	  return;
	end
	tX, tX = GetPlayerMapPosition("player");
	if ((tX or 0) + (tY or 0) <= 0) then
		VUHDO_setMapToCurrentZone();
	end

	tMapFileName = (GetMapInfo()) or "*";
	tCurrLevel = GetCurrentMapDungeonLevel() or 0;
	tCurrentZone = tMapFileName .. tCurrLevel;

	if (VUHDO_LAST_ZONE ~= tCurrentZone) then
		VUHDO_clusterBuilderNewZone(VUHDO_LAST_ZONE, tCurrentZone);
		VUHDO_LAST_ZONE = tCurrentZone;
	end

  tNumSamples = 0;
  tNumIterations = 0;
	tNumRaid = #VUHDO_CLUSTER_BASE_RAID;
	-- Check all the units in raid against all other units
	while (true) do
		tIndex = tIndex + 1;
		if (tIndex > tNumRaid) then
		  tIndex = 0;
		  break;
		end

	  tInfo = VUHDO_CLUSTER_BASE_RAID[tIndex];
	  if (tInfo == nil) then
	    break;
	  end

		tUnit = tInfo["unit"];

		if (VUHDO_COORD_DELTAS[tUnit] == nil) then
			VUHDO_COORD_DELTAS[tUnit] = { };
		end

		if (VUHDO_isValidClusterUnit(tInfo)) then
			for tCnt = tIndex + 1, tNumRaid do
				tAnotherInfo = VUHDO_CLUSTER_BASE_RAID[tCnt];
    	  if (tAnotherInfo == nil) then
    	    break;
    	  end
				tAnotherUnit = tAnotherInfo["unit"];

				if (VUHDO_isValidClusterUnit(tAnotherInfo)) then
					tDeltaX, tDeltaY = VUHDO_determineDistanceBetween(tUnit, tAnotherUnit);

					if (tDeltaX ~= nil) then
						if (VUHDO_COORD_DELTAS[tUnit][tAnotherUnit] == nil) then
							VUHDO_COORD_DELTAS[tUnit][tAnotherUnit] = { };
						end

						VUHDO_COORD_DELTAS[tUnit][tAnotherUnit][1] = tDeltaX;
						VUHDO_COORD_DELTAS[tUnit][tAnotherUnit][2] = tDeltaY;

						-- and the other way round to reduce iterations
						if (VUHDO_COORD_DELTAS[tAnotherUnit] == nil) then
							VUHDO_COORD_DELTAS[tAnotherUnit] = { };
						end
						if (VUHDO_COORD_DELTAS[tAnotherUnit][tUnit] == nil) then
							VUHDO_COORD_DELTAS[tAnotherUnit][tUnit] = { };
						end
						VUHDO_COORD_DELTAS[tAnotherUnit][tUnit][1] = tDeltaX;
						VUHDO_COORD_DELTAS[tAnotherUnit][tUnit][2] = tDeltaY;

      			tNumSamples = tNumSamples + 1;
      			if (tNumSamples > 50) then -- VUHDO_MAX_SAMPLES
      			  break;
      			end
					end
				end
				tNumIterations = tNumIterations + 1;
				if (tNumIterations > 120) then -- VUHDO_MAX_ITERATIONS
					break;
				end
			end -- for
		else -- Blacklist updaten
			for tCnt = tIndex + 1, tNumRaid do
				tAnotherInfo = VUHDO_CLUSTER_BASE_RAID[tCnt];
    	  if (tAnotherInfo == nil) then
    	    break;
    	  end
				VUHDO_isValidClusterUnit(tAnotherInfo);
			end
		end

		if (tNumSamples > 50 or tNumIterations > 120) then -- VUHDO_MAX_SAMPLES -- VUHDO_MAX_ITERATIONS
		  break;
		end
	end

	tMaxX = nil;

	-- Try to determine well known dungeons
	tDungeonLevels = VUHDO_MAP_FIX_WIDTH[tMapFileName];
	if (tDungeonLevels ~= nil and tCurrLevel ~= nil) then
		tMaxX = tDungeonLevels[tCurrLevel];
		--VUHDO_Msg("Found predefined map width of: " .. tMaxX);
	end

	-- Otherwise get from heuristic database
	if ((tMaxX or 0) == 0) then
    if (VUHDO_COORD_DELTAS["player"] ~= nil) then
      for tUnit, tDeltas in pairs(VUHDO_COORD_DELTAS["player"]) do
      	VUHDO_calibrateMapScale(tUnit, tDeltas[1], tDeltas[2]);
      end
    end

		tMaxX = VUHDO_getHeuristicMapWidth();

		-- Unreasonable?
		if (tMaxX < 20 or tMaxX >= VUHDO_MAP_LIMIT_YARDS) then
			VUHDO_MAP_WIDTH = 0;
			return;
		end
	end

--	if (VUHDO_MAP_WIDTH ~= tMaxX) then
--		VUHDO_Msg("Map approx yards changed from " .. floor(VUHDO_MAP_WIDTH * 10) / 10 .. " to " .. floor(tMaxX * 10) / 10);
--	end

	VUHDO_MAP_WIDTH = tMaxX;
end



--
function VUHDO_resetClusterCoordDeltas()
	twipe(VUHDO_COORD_DELTAS);
end



--
local tDeltas, tDistance, tNumber, tOtherUnit, tInfo;
local tStart, tDuration;
function VUHDO_getUnitsInRadialClusterWith(aUnit, aYards, anArray)
  twipe(anArray);

  if (sCdSpell ~= nil) then
		tStart, tDuration, _ = GetSpellCooldown(sCdSpell);
		tDuration = tDuration or 0;

		if (tDuration > 1.5) then
		  tStart = tStart or 0;
		  if (tStart + tDuration > GetTime()) then
		  	return anArray;
		  end
		end
  end

  tInfo = VUHDO_RAID[aUnit];
  if (tInfo ~= nil and not VUHDO_CLUSTER_BLACKLIST[aUnit]) then
  	tinsert(anArray, aUnit); -- Source is always part of the cluster
  end
	if (VUHDO_MAP_WIDTH == 0 or VUHDO_COORD_DELTAS[aUnit] == nil) then
		return anArray;
	end

	for tOtherUnit, tDeltas in pairs(VUHDO_COORD_DELTAS[aUnit]) do
		tDistance = sqrt((((tDeltas[1] or 0) * VUHDO_MAP_WIDTH) ^ 2)  + (((tDeltas[2] or 0) * VUHDO_MAP_WIDTH / 1.5) ^ 2));
		if (tDistance <= aYards and not VUHDO_CLUSTER_BLACKLIST[tOtherUnit]) then
			tinsert(anArray, tOtherUnit);
		end
	end
	return anArray;
end



--
local tUnit, tWinnerUnit, tInfo, tWinnerInfo;
local function VUHDO_getMostDeficitUnitOutOf(anIncludeList, anExcludeList)
	tWinnerUnit = nil;

	for _, tUnit in pairs(anIncludeList) do
		if (not anExcludeList[tUnit]) then
			tInfo = VUHDO_RAID[tUnit];

			if (tWinnerUnit == nil
				or (tInfo ~= nil
						and tInfo["healthmax"] - tInfo["health"] > tWinnerInfo["healthmax"] - tWinnerInfo["health"])) then
				tWinnerUnit = tUnit;
				tWinnerInfo = tInfo;
			end
		end
	end
	return tWinnerUnit;
end



--
local tNextJumps = { };
local tExcludeList = { };
local tNumJumps = 0;
local tCnt;
function VUHDO_getUnitsInChainClusterWith(aUnit, aYards, anArray, aMaxJumps)
  twipe(anArray);
  twipe(tExcludeList)
  for tCnt = 0, aMaxJumps do
  	tinsert(anArray, aUnit);
  	tExcludeList[aUnit] = true;
		VUHDO_getUnitsInRadialClusterWith(aUnit, aYards, tNextJumps);
  	aUnit = VUHDO_getMostDeficitUnitOutOf(tNextJumps, tExcludeList);
  	if (aUnit == nil) then
  		break;
  	end
 	end
 	return anArray;
end



--
local tDeltas, tDistance;
function VUHDO_getDistanceBetween(aUnit, anotherUnit)
	if (VUHDO_CLUSTER_BLACKLIST[aUnit] or VUHDO_CLUSTER_BLACKLIST[anotherUnit]) then
		return nil;
	end

	if (VUHDO_COORD_DELTAS[aUnit] ~= nil and VUHDO_COORD_DELTAS[aUnit][anotherUnit] ~= nil) then
		tDeltas = VUHDO_COORD_DELTAS[aUnit][anotherUnit];
		return sqrt((((tDeltas[1] or 0) * VUHDO_MAP_WIDTH) ^ 2)  + (((tDeltas[2] or 0) * VUHDO_MAP_WIDTH / 1.5) ^ 2));
	end

	return nil;
end




