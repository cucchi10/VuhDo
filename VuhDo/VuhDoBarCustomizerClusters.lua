local VUHDO_HIGLIGHT_CLUSTER = { };
local VUHDO_HIGLIGHT_NUM = 0;
local VUHDO_ICON_CLUSTER = { };
local VUHDO_NUM_IN_UNIT_CLUSTER = { };
local VUHDO_ACTIVE_HOTS = { };
local sClusterConfig;

local VUHDO_CLUSTER_UNIT = nil;

--
local twipe = table.wipe;
local pairs = pairs;

local VUHDO_GLOBAL = getfenv();

local VUHDO_RAID = { };

local VUHDO_getUnitsInRadialClusterWith;
local VUHDO_getUnitsInChainClusterWith;
local VUHDO_getUnitButtons;
local VUHDO_getHealthBar;
local VUHDO_getClusterBorderFrame;
local VUHDO_updateBouquetsForEvent;
local VUHDO_getBarIcon;
local VUHDO_getBarIconTimer;

local sHealthLimit
local sIsRaid;
local sThreshFair;
local sThreshGood;
local sColorFair;
local sColorGood;
local sIsShowNumber;
local sIsSourcePlayer;
local sRange;
local sNumMaxJumps;
local sIsRadial;
local sHotSlots;
function VUHDO_customClustersInitBurst()
  VUHDO_RAID = VUHDO_GLOBAL["VUHDO_RAID"];
	VUHDO_ACTIVE_HOTS = VUHDO_GLOBAL["VUHDO_ACTIVE_HOTS"];

  VUHDO_getUnitsInRadialClusterWith = VUHDO_GLOBAL["VUHDO_getUnitsInRadialClusterWith"];
  VUHDO_getUnitsInChainClusterWith = VUHDO_GLOBAL["VUHDO_getUnitsInChainClusterWith"];
  VUHDO_getUnitButtons = VUHDO_GLOBAL["VUHDO_getUnitButtons"];
  VUHDO_getHealthBar = VUHDO_GLOBAL["VUHDO_getHealthBar"];
  VUHDO_getClusterBorderFrame = VUHDO_GLOBAL["VUHDO_getClusterBorderFrame"];
	VUHDO_updateBouquetsForEvent = VUHDO_GLOBAL["VUHDO_updateBouquetsForEvent"];
	VUHDO_getBarIcon = VUHDO_GLOBAL["VUHDO_getBarIcon"];
	VUHDO_getBarIconTimer = VUHDO_GLOBAL["VUHDO_getBarIconTimer"];

  sClusterConfig = VUHDO_CONFIG["CLUSTER"];
  sHealthLimit = sClusterConfig["BELOW_HEALTH_PERC"] * 0.01;
  sIsRaid = sClusterConfig["DISPLAY_DESTINATION"] == 2;
  sThreshFair = sClusterConfig["THRESH_FAIR"];
  sThreshGood = sClusterConfig["THRESH_GOOD"];
  sColorFair = VUHDO_PANEL_SETUP["BAR_COLORS"]["CLUSTER_FAIR"];
  sColorGood = VUHDO_PANEL_SETUP["BAR_COLORS"]["CLUSTER_GOOD"];
  sIsShowNumber = sClusterConfig["IS_NUMBER"];
  sIsSourcePlayer = sClusterConfig["DISPLAY_SOURCE"] == 1;
  sRange = sClusterConfig["RANGE"];
  sNumMaxJumps = sClusterConfig["CHAIN_MAX_JUMP"];
  sIsRadial = sClusterConfig["MODE"] == 1;

  sHotSlots = VUHDO_PANEL_SETUP["HOTS"]["SLOTS"];
end



--
local tHotName;
local tIndex;
local tIcon;
local tColor;
local function VUHDO_customizeClusterIcons(aButton, aNumLow, anInfo)
	for tIndex, tHotName in pairs(sHotSlots) do
		if ("CLUSTER" == tHotName) then

		  if (aNumLow < sThreshFair or not anInfo["range"]) then
		    VUHDO_getBarIcon(aButton, tIndex):Hide();
			  VUHDO_getBarIconTimer(aButton, tIndex):SetText("");
		  else
  		  if (aNumLow < sThreshGood) then
  		    tColor = sColorFair;
  		  else
  		    tColor = sColorGood;
  		  end

				tIcon = VUHDO_getBarIcon(aButton, tIndex);
		    tIcon:SetVertexColor(tColor["R"], tColor["G"], tColor["B"], tColor["O"]);
		    tIcon:Show();
		    if (sIsShowNumber) then
  		    VUHDO_getBarIconTimer(aButton, tIndex):SetText(aNumLow);
		    end
		  end
		end
	end
end



--
local tDestCluster = { };
local tInfo, tSrcInfo, tNumArray;
local tSrcGroup;
local function VUHDO_getDestCluster(aUnit, anArray)
  twipe(anArray);
  tNumArray = 0;
  if (sIsSourcePlayer and aUnit ~= "player") then
    return 0;
  end

	tSrcInfo = VUHDO_RAID[aUnit];
	if (tSrcInfo == nil or tSrcInfo["isPet"] or "focus" == aUnit or "target" == aUnit) then
    return 0;
	end

  if (sIsRadial) then
  	VUHDO_getUnitsInRadialClusterWith(aUnit, sRange, tDestCluster);
  else
  	VUHDO_getUnitsInChainClusterWith(aUnit, sRange, tDestCluster, sNumMaxJumps);
  end

	tSrcGroup = tSrcInfo["group"];
  for _, tUnit in pairs(tDestCluster) do
    tInfo = VUHDO_RAID[tUnit];
    if (tInfo ~= nil and not tInfo["dead"] and tInfo["health"] / tInfo["healthmax"] <= sHealthLimit) then
			if (sIsRaid or tInfo["group"] == tSrcGroup) then -- all raid members or in same group
      	anArray[tUnit] = tUnit;
      	tNumArray = tNumArray + 1;
      end
    end
  end

  return tNumArray;
end



--
local tInfo, tNumLow;
local tAllButtons, tButton, tInfo;
function VUHDO_updateAllClusterIcons(aUnit)
	tInfo = VUHDO_RAID[aUnit];
	if (tInfo == nil) then
		return;
	end

  tNumLow = VUHDO_getDestCluster(aUnit, VUHDO_ICON_CLUSTER);
  if (VUHDO_NUM_IN_UNIT_CLUSTER[aUnit] ~= tNumLow) then
  	VUHDO_NUM_IN_UNIT_CLUSTER[aUnit] = tNumLow;
		VUHDO_updateBouquetsForEvent(aUnit, 16); -- VUHDO_UPDATE_NUM_CLUSTER
  end

	tAllButtons = VUHDO_getUnitButtons(aUnit);
	if (tAllButtons ~= nil and VUHDO_ACTIVE_HOTS["CLUSTER"]) then
		for _, tButton in pairs(tAllButtons) do
	    VUHDO_customizeClusterIcons(tButton, tNumLow, tInfo);
		end
	end
end



--
local tUnit;
local tAllButtons, tButton;
function VUHDO_removeAllClusterHighlights()
  for _, tUnit in pairs(VUHDO_HIGLIGHT_CLUSTER) do
		VUHDO_updateBouquetsForEvent(tUnit, 18); -- VUHDO_UPDATE_MOUSEOVER_CLUSTER
  end

  twipe(VUHDO_HIGLIGHT_CLUSTER);
end
local VUHDO_removeAllClusterHighlights = VUHDO_removeAllClusterHighlights;



--
local tUnit, tAllButtons, tButton;
local tClusterBorder;
function VUHDO_highlightClusterFor(aUnit)
	VUHDO_CLUSTER_UNIT = aUnit;
  if (VUHDO_HIGLIGHT_NUM ~= 0) then
    VUHDO_removeAllClusterHighlights();
  end

  VUHDO_HIGLIGHT_NUM = VUHDO_getDestCluster(aUnit, VUHDO_HIGLIGHT_CLUSTER);

  for _, tUnit in pairs(VUHDO_HIGLIGHT_CLUSTER) do
    VUHDO_updateBouquetsForEvent(tUnit, 18); -- VUHDO_UPDATE_MOUSEOVER_CLUSTER
  end
end



--
function VUHDO_updateClusterHighlights()
	if (VUHDO_CLUSTER_UNIT ~= nil) then
		VUHDO_highlightClusterFor(VUHDO_CLUSTER_UNIT);
	end
end



--
function VUHDO_resetClusterUnit()
  VUHDO_CLUSTER_UNIT = nil;
end



--
function VUHDO_getNumInUnitCluster(aUnit)
	return VUHDO_NUM_IN_UNIT_CLUSTER[aUnit] or 0;
end



--
function VUHDO_getIsInHiglightCluster(aUnit)
	if(VUHDO_HIGLIGHT_NUM < sThreshFair) then
		return false;
	end

	return VUHDO_HIGLIGHT_CLUSTER[aUnit] ~= nil;
end



--
local tAllButtons, tButton, tBorder;
function VUHDO_clusterBorderBouquetCallback(aUnit, anIsActive, anIcon, aTimer, aCounter, aDuration, aColor, aBuffName, aBouquetName)
	tAllButtons =  VUHDO_getUnitButtons(aUnit);
	if (tAllButtons ~= nil) then
		for _, tButton in pairs(tAllButtons) do
			tBorder = VUHDO_getClusterBorderFrame(tButton);
			if (aColor ~= nil) then
				tBorder:SetBackdropBorderColor(aColor["R"], aColor["G"], aColor["B"], aColor["O"]);
				tBorder:Show();
			else
				tBorder:Hide();
			end
		end
	end
end
