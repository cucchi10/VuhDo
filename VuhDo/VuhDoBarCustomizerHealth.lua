
local VUHDO_NAME_TEXTS = { };


-- BURST CACHE ---------------------------------------------------

local VUHDO_getHealthBar;
local VUHDO_getBarText;
local VUHDO_getIncHealOnUnit;
local VUHDO_getDiffColor;
local VUHDO_isPanelVisible;
local VUHDO_updateManaBars;
local VUHDO_updateAllHoTs;
local VUHDO_removeAllHots;
local VUHDO_getUnitHealthPercent;
local VUHDO_getPanelButtons;
local VUHDO_updateBouquetsForEvent;
local VUHDO_utf8Cut;
local VUHDO_resolveVehicleUnit;
local VUHDO_getOverhealPanel;
local VUHDO_getOverhealText;
local VUHDO_getUnitButtons;
local VUHDO_getBarRoleIcon;
local VUHDO_getBarIconFrame;
local VUHDO_updateClusterHighlights;

local VUHDO_PANEL_SETUP;
local VUHDO_BUTTON_CACHE;
local VUHDO_RAID;
local VUHDO_CONFIG;
local VUHDO_INDICATOR_CONFIG;
local VUHDO_BAR_COLOR;
local VUHDO_THREAT_CFG;
local VUHDO_IN_RAID_TARGET_BUTTONS;
local VUHDO_INTERNAL_TOGGLES;

local abs = abs;
local floor = floor;
local strlen = strlen;
local strfind = strfind;
local strbyte = strbyte;
local GetRaidTargetIndex = GetRaidTargetIndex;
local UnitIsUnit = UnitIsUnit;
local pairs = pairs;
local twipe = table.wipe;
local _ = _;
local sIsOverhealText;
local sIsAggroText;



function VUHDO_customHealthInitBurst()
  -- variables
	VUHDO_PANEL_SETUP = VUHDO_GLOBAL["VUHDO_PANEL_SETUP"];
	VUHDO_BUTTON_CACHE = VUHDO_GLOBAL["VUHDO_BUTTON_CACHE"];
	VUHDO_RAID = VUHDO_GLOBAL["VUHDO_RAID"];
	VUHDO_CONFIG = VUHDO_GLOBAL["VUHDO_CONFIG"];
	VUHDO_INDICATOR_CONFIG = VUHDO_GLOBAL["VUHDO_INDICATOR_CONFIG"];
	VUHDO_getUnitButtons = VUHDO_GLOBAL["VUHDO_getUnitButtons"];
 	VUHDO_BAR_COLOR = VUHDO_PANEL_SETUP["BAR_COLORS"];
 	VUHDO_THREAT_CFG = VUHDO_CONFIG["THREAT"];
 	VUHDO_IN_RAID_TARGET_BUTTONS = VUHDO_GLOBAL["VUHDO_IN_RAID_TARGET_BUTTONS"];
	VUHDO_INTERNAL_TOGGLES = VUHDO_GLOBAL["VUHDO_INTERNAL_TOGGLES"];
 	
 	-- functions
	VUHDO_getHealthBar = VUHDO_GLOBAL["VUHDO_getHealthBar"];
	VUHDO_getBarText = VUHDO_GLOBAL["VUHDO_getBarText"];
	VUHDO_getIncHealOnUnit = VUHDO_GLOBAL["VUHDO_getIncHealOnUnit"];
	VUHDO_getDiffColor = VUHDO_GLOBAL["VUHDO_getDiffColor"];
	VUHDO_isPanelVisible = VUHDO_GLOBAL["VUHDO_isPanelVisible"];
	VUHDO_updateManaBars = VUHDO_GLOBAL["VUHDO_updateManaBars"];
	VUHDO_removeAllHots = VUHDO_GLOBAL["VUHDO_removeAllHots"];
	VUHDO_updateAllHoTs = VUHDO_GLOBAL["VUHDO_updateAllHoTs"];
	VUHDO_getUnitHealthPercent = VUHDO_GLOBAL["VUHDO_getUnitHealthPercent"];
	VUHDO_getPanelButtons = VUHDO_GLOBAL["VUHDO_getPanelButtons"];
	VUHDO_updateBouquetsForEvent = VUHDO_GLOBAL["VUHDO_updateBouquetsForEvent"];
	VUHDO_utf8Cut = VUHDO_GLOBAL["VUHDO_utf8Cut"];
	VUHDO_resolveVehicleUnit = VUHDO_GLOBAL["VUHDO_resolveVehicleUnit"];
	VUHDO_getOverhealPanel = VUHDO_GLOBAL["VUHDO_getOverhealPanel"];
	VUHDO_getOverhealText = VUHDO_GLOBAL["VUHDO_getOverhealText"];
	VUHDO_getBarRoleIcon = VUHDO_GLOBAL["VUHDO_getBarRoleIcon"];
	VUHDO_getBarIconFrame = VUHDO_GLOBAL["VUHDO_getBarIconFrame"];
  VUHDO_updateClusterHighlights = VUHDO_GLOBAL["VUHDO_updateClusterHighlights"];
	
	-- statics
	sIsOverhealText = VUHDO_CONFIG["SHOW_TEXT_OVERHEAL"]
	sIsAggroText = VUHDO_CONFIG["THREAT"]["AGGRO_USE_TEXT"];

	-- custom
	twipe(VUHDO_NAME_TEXTS);
end

----------------------------------------------------


function VUHDO_resetNameTextCache()
	twipe(VUHDO_NAME_TEXTS);
end


local tIncColor = { ["useBackground"] = true };


--
local function VUHDO_getUnitHealthModiPercent(anInfo, aModifier)
	if (anInfo["healthmax"] == 0) then
		return 0;
	else
		return 100 * (anInfo["health"] + aModifier) / anInfo["healthmax"];
	end
end



--
local tOpacity;
local function VUHDO_setStatusBarColor(aBar, aColor)
	if (aColor["useOpacity"]) then
		tOpacity = aColor["O"];
	else
		tOpacity = nil;
	end

	if (aColor["useBackground"]) then
		aBar:SetStatusBarColor(aColor["R"], aColor["G"], aColor["B"], tOpacity);
	elseif (tOpacity ~= nil) then
		aBar:SetAlpha(tOpacity);
	end
end



--
local function VUHDO_getKiloText(aNumber, aSetup)
	if (abs(aNumber) < 100 or aSetup["LIFE_TEXT"]["verbose"]) then
		return aNumber;
	end

  return floor(aNumber * 0.01) * 0.1 .. "k";
end



--
local tOverheal;
local tRatio;
local tIsOverhealText;
local tScale;
local tAllButtons;
local tHealthPlusInc;
local tIncBar;
local tButton;
local tAmountInc;
local tInfo;
local tOverhealSetup;
local tValue;
local tSetup;
local function _VUHDO_updateIncHeal(aUnit)
	tInfo = VUHDO_RAID[aUnit];
	tAllButtons = VUHDO_getUnitButtons(VUHDO_resolveVehicleUnit(aUnit));

	if (tInfo == nil or tAllButtons == nil) then
		return;
	end

	tAmountInc = VUHDO_getIncHealOnUnit(tInfo["name"]);
	tOverheal = tAmountInc - tInfo["healthmax"] + tInfo["health"];
	tRatio = tOverheal / tInfo["healthmax"];
	if (tAmountInc > 0 and tInfo["connected"] and not tInfo["dead"]) then
		tHealthPlusInc = VUHDO_getUnitHealthModiPercent(tInfo, tAmountInc);
		if (tHealthPlusInc > 100) then
			tHealthPlusInc = 100;
		end
	else
		tHealthPlusInc = 0;
	end

	if (tAmountInc > 0) then
		tIncColor["R"] = -1;

  	for _, tButton in pairs(tAllButtons) do
    	tIncBar = VUHDO_getHealthBar(tButton, 6);

			tSetup = VUHDO_PANEL_SETUP[VUHDO_BUTTON_CACHE[tButton]];
			if (VUHDO_INDICATOR_CONFIG["CUSTOM"]["HEALTH_BAR"]["invertGrowth"] and tInfo["healthmax"] > 0) then
				tIncBar:SetValueRange(100 * tInfo["health"] / tInfo["healthmax"], tHealthPlusInc);
			else
  			tIncBar:SetValue(tHealthPlusInc);
  		end

   		if (tIncColor["R"] == -1) then
   			tIncColor["R"], tIncColor["G"], tIncColor["B"] = VUHDO_getHealthBar(tButton, 1):GetStatusBarColor();
   			tIncColor = VUHDO_getDiffColor(tIncColor, VUHDO_PANEL_SETUP["BAR_COLORS"]["INCOMING"]);
   		end

    	VUHDO_setStatusBarColor(tIncBar, tIncColor);
    	tOverhealSetup = tSetup["OVERHEAL_TEXT"];
			tIsOverhealText = tOverhealSetup["show"];

    	if (tIsOverhealText) then
				tScale = tOverhealSetup["scale"];
  	  	if (tOverheal > 0) then
    			if (tRatio < 1) then
    				VUHDO_getOverhealPanel(VUHDO_getHealthBar(tButton, 1)):SetScale((0.5 + tRatio) * tScale);
    			else
	    			VUHDO_getOverhealPanel(VUHDO_getHealthBar(tButton, 1)):SetScale(1.5 * tScale);
  	  		end

					VUHDO_getOverhealText(VUHDO_getHealthBar(tButton, 1)):SetText("+" .. floor(tOverheal * 0.01) * 0.1 .. "k");
				else
					VUHDO_getOverhealText(VUHDO_getHealthBar(tButton, 1)):SetText("");
				end
  		end

  	end

	else
		for _, tButton in pairs(tAllButtons) do
			if (VUHDO_INDICATOR_CONFIG["CUSTOM"]["HEALTH_BAR"]["invertGrowth"]) then
				VUHDO_getHealthBar(tButton, 6):SetValueRange(0, 0);
			else
  			VUHDO_getHealthBar(tButton, 6):SetValue(0);
  		end
			if (tIsOverhealText) then
				VUHDO_getOverhealText(VUHDO_getHealthBar(tButton, 1)):SetText("");
			end
		end
	end
end


--
local function VUHDO_updateIncHeal(aUnit)
	_VUHDO_updateIncHeal(aUnit)

	if (UnitIsUnit(aUnit, "target")) then
		_VUHDO_updateIncHeal("target");
	end

	if (UnitIsUnit(aUnit, "focus")) then
		_VUHDO_updateIncHeal("focus");
	end
end


--
VUHDO_CUSTOM_INFO = {
	["number"] = 1,
	["range"] = true,
	["debuff"] = 0,
	["isPet"] = false,
	["charmed"] = false,
	["aggro"] = false,
	["group"] = 0,
	["afk"] = false,
	["threat"] = 0,
	["threatPerc"] = 0,
	["isVehicle"] = false,
	["ownerUnit"] = nil,
	["petUnit"] = nil,
	["missbuff"] = nil,
	["mibucateg"] = nil,
	["mibuvariants"] = nil,
	["raidIcon"] = nil,
	["visible"] = true,
	["baseRange"] = true,
};
local VUHDO_CUSTOM_INFO = VUHDO_CUSTOM_INFO;



--
local tUnit;
local function VUHDO_getDisplayUnit(aButton)
	tUnit = aButton:GetAttribute("unit");

	if (strfind(tUnit, "target", 1, true) and tUnit ~= "target") then
		if (VUHDO_CUSTOM_INFO["fixResolveId"] == nil) then
			return tUnit, VUHDO_CUSTOM_INFO;
		else
			return VUHDO_CUSTOM_INFO["fixResolveId"], VUHDO_RAID[VUHDO_CUSTOM_INFO["fixResolveId"]];
		end
	else
		if (VUHDO_RAID[tUnit] ~= nil and VUHDO_RAID[tUnit]["isVehicle"]) then
			tUnit = VUHDO_RAID[tUnit]["petUnit"];
		end
		return tUnit, VUHDO_RAID[tUnit];
	end
end



--
local tMissLife;
local tIsName, tIsLife, tIsLifeInName;
local tTextString;
local tHealthBar;
local tSetup;
local tLifeConfig;
local tAmountInc;
local tOwnerInfo;
local tMaxChars;
local tLifeString;
local tUnit, tInfo;
local tIsShowLife;
local tLifeAmount;
local tIsHideIrrel;
local tIndex;
function VUHDO_customizeText(aButton, aMode, anIsTarget)
	tUnit, tInfo = VUHDO_getDisplayUnit(aButton);
 	tHealthBar = VUHDO_getHealthBar(aButton, 1);

	if (tInfo == nil) then
		if ("focus" == tUnit) then
			VUHDO_getBarText(tHealthBar):SetText(VUHDO_I18N_NO_FOCUS);
		elseif ("target" == tUnit) then
			VUHDO_getBarText(tHealthBar):SetText(VUHDO_I18N_NO_TARGET);
		else
			VUHDO_getBarText(tHealthBar):SetText(VUHDO_I18N_NOT_AVAILABLE);
		end
		VUHDO_getLifeText(tHealthBar):SetText("");
		return;
	end

  tSetup = VUHDO_PANEL_SETUP[VUHDO_BUTTON_CACHE[aButton]];
  tLifeConfig = tSetup["LIFE_TEXT"];

	tIsHideIrrel = tLifeConfig["hideIrrelevant"] and VUHDO_getUnitHealthPercent(tInfo) >= VUHDO_CONFIG["EMERGENCY_TRIGGER"];
	tIsShowLife = tLifeConfig["show"] and not tIsHideIrrel;

	tIsLifeInName = tLifeConfig["show"] and
		(1 == tLifeConfig["position"] -- VUHDO_LT_POS_RIGHT
		or 2 == tLifeConfig["position"]); -- VUHDO_LT_POS_LEFT

	tIsName = aMode ~= 2 or tIsLifeInName; -- VUHDO_UPDATE_HEALTH
	tIsLife = aMode ~= 7 or tIsLifeInName; -- VUHDO_UPDATE_AGGRO

	tTextString = "";
	-- Basic name text
	if (tIsName) then

	  tOwnerInfo = VUHDO_RAID[tInfo["ownerUnit"]];
	  tIndex = tInfo["name"] .. (tInfo["ownerUnit"] or "");
		if (VUHDO_NAME_TEXTS[tIndex] == nil) then
	  	if (tSetup["ID_TEXT"]["showName"]) then
	  		if (tSetup["ID_TEXT"]["showClass"] and not tInfo["isPet"]) then
	  			tTextString = tInfo["className"] .. ": ";
	  		else
	  			tTextString = "";
	  		end

	  		if (tOwnerInfo == nil or not tSetup["ID_TEXT"]["showPetOwners"]) then
	  			tTextString = tTextString .. tInfo["name"];
	  		else
	  			tTextString = tTextString .. tOwnerInfo["name"] .. ": " .. tInfo["name"];
	  		end
	  	else
	  		if (tSetup["ID_TEXT"]["showClass"] and not tInfo["isPet"]) then
	  			tTextString = tInfo["className"];
	  		else
	  			tTextString = "";
	  		end

	  		if (tOwnerInfo ~= nil and tSetup["ID_TEXT"]["showPetOwners"]) then
	  			tTextString = tTextString .. tOwnerInfo["name"];
	  		end
	  	end
	  	tMaxChars = tSetup["PANEL_COLOR"]["TEXT"]["maxChars"];
	  	if (tMaxChars > 0 and strlen(tTextString) > tMaxChars) then
	  		tTextString = VUHDO_utf8Cut(tTextString, tMaxChars);
	  	end
	  	VUHDO_NAME_TEXTS[tIndex] = tTextString;
	  else
	  	tTextString = VUHDO_NAME_TEXTS[tIndex];
	  end

  	-- Add player flags
  	if (tSetup["ID_TEXT"]["showTags"]) then
    	if (not tInfo["connected"]) then
    		tTextString = "d/c-" .. tTextString;
    	elseif (tInfo["dead"]) then
    		if (UnitIsGhost(tUnit)) then
    			tTextString = "|cffff0000ghost|r-" .. tTextString;
    		else
    			tTextString = "rip-" .. tTextString;
    		end
    	else
    		if ("focus" == tUnit) then
   				tTextString = "|cffff0000foc|r-" .. tTextString;
    		elseif ("target" == tUnit) then
   				tTextString = "|cffff0000tar|r-" .. tTextString;
   			elseif (tInfo["afk"]) then
   				tTextString = "afk-" .. tTextString;
   			elseif(tOwnerInfo ~= nil and tOwnerInfo["isVehicle"]) then
   				tTextString = "|cffff0000pet|r-" .. tTextString;
   			end
    	end
  	end
  	if (tMaxChars > 0 and strlen(tTextString) > tMaxChars and strbyte(tTextString, 1) ~= 124) then --|
  		tTextString = VUHDO_utf8Cut(tTextString, tMaxChars);
  	end
	end

	-- Life Text
	if (tIsLife and tIsShowLife) then
		tAmountInc = VUHDO_getIncHealOnUnit(tInfo["name"]);

		if (sIsOverhealText) then
			tLifeAmount = tInfo["health"] + tAmountInc;
		else
			tLifeAmount = tInfo["health"];
		end

		if (1 == tLifeConfig["mode"] or anIsTarget) then -- VUHDO_LT_MODE_PERCENT
			tLifeString = floor(VUHDO_getUnitHealthModiPercent(tInfo, tLifeAmount - tInfo["health"])) .. "%";
		elseif (3 == tLifeConfig["mode"]) then -- VUHDO_LT_MODE_MISSING
			tMissLife = tLifeAmount - tInfo["healthmax"];
			if (tMissLife < -10) then
				tLifeString =  VUHDO_getKiloText(tMissLife, tSetup);
			else
				tLifeString = "";
			end
		else -- VUHDO_LT_MODE_LEFT
			tLifeString = VUHDO_getKiloText(tLifeAmount, tSetup) .. " / " .. VUHDO_getKiloText(tInfo["healthmax"], tSetup);
		end

		if (not tIsLifeInName) then
			VUHDO_getLifeText(tHealthBar):SetText(tLifeString);
		elseif (not tIsHideIrrel) then
			if (2 == tLifeConfig["position"]) then -- VUHDO_LT_POS_LEFT
				tTextString = tLifeString .. " " .. tTextString;
			else
				tTextString = tTextString .. " " .. tLifeString;
			end
		end
	elseif (tIsLife and tIsHideIrrel) then
		VUHDO_getLifeText(tHealthBar):SetText("");
	end

  -- Aggro Text
  if (tIsName) then
	  if (tInfo["aggro"] and sIsAggroText) then
			tTextString =
			   "|cffff2020" .. VUHDO_THREAT_CFG["AGGRO_TEXT_LEFT"] .. "|r"
				.. tTextString
				.. "|cffff2020" .. VUHDO_THREAT_CFG["AGGRO_TEXT_RIGHT"] .. "|r";
		end

		VUHDO_getBarText(tHealthBar):SetText(tTextString);
	end
end

local VUHDO_customizeText = VUHDO_customizeText;



--
local tInfo;
function VUHDO_customizeBarSize(aButton)
	_, tInfo = VUHDO_getDisplayUnit(aButton);

	if (tInfo == nil) then
 		VUHDO_getHealthBar(aButton, 1):SetValue(100);
 		VUHDO_getHealthBar(aButton, 3):SetValue(100);
		VUHDO_getHealthBar(aButton, 8):SetValue(100);
		VUHDO_getHealthBar(aButton, 2):SetValue(0);
	elseif (not tInfo["connected"] or tInfo["dead"]) then
 		VUHDO_getHealthBar(aButton, 1):SetValue(100);
 		VUHDO_getHealthBar(aButton, 3):SetValue(100);
		VUHDO_getHealthBar(aButton, 8):SetValue(100);
		VUHDO_getHealthBar(aButton, 6):SetValue(0);
		VUHDO_getHealthBar(aButton, 2):SetValue(0);
	else
 		VUHDO_getHealthBar(aButton, 1):SetValue(VUHDO_getUnitHealthPercent(tInfo));
 	end
end



--
local tFlashBar;
local tScaling;
local function VUHDO_customizeDamageFlash(aButton, aLossPercent)
	if (aLossPercent ~= nil) then
		tScaling = VUHDO_PANEL_SETUP[VUHDO_BUTTON_CACHE[aButton]]["SCALING"];
		if (tScaling["isDamFlash"] and tScaling["damFlashFactor"] >= aLossPercent) then
			tFlashBar = VUHDO_GLOBAL[aButton:GetName() .. "BgBarIcBarHlBarFlBar"];
			UIFrameFlash(tFlashBar, 0.05, 0.3, 0.45, false, 0.1, 0);
		end
	end
end



--
local tAllButtons, tButton, tHealthBar, tQuota, tTargetQuota;
function VUHDO_healthBarBouquetCallback(aUnit, anIsActive, anIcon, aCurrValue, aCounter, aMaxValue, aColor, aBuffName, aBouquetName, aLevel, aCurrValue2)
	aMaxValue = aMaxValue or 0;
	aCurrValue = aCurrValue or 0;

	if (aCurrValue == 0 and aMaxValue == 0) then
		if (anIsActive) then
			tQuota = 100;
		else
			tQuota = 0;
		end
	elseif (aMaxValue > 1) then
		tQuota = 100 * aCurrValue / aMaxValue;
	else
		tQuota = 0;
	end

	tAllButtons = VUHDO_getUnitButtons(aUnit);
	if (tAllButtons ~= nil) then
		for _, tButton in pairs(tAllButtons) do
			if (VUHDO_INDICATOR_CONFIG["BOUQUETS"]["HEALTH_BAR_PANEL"][VUHDO_BUTTON_CACHE[tButton]] == "") then
				tHealthBar = VUHDO_getHealthBar(tButton, 1);

				if (tQuota > 0) then
					if (aColor ~= nil) then
						tHealthBar:SetStatusBarColor(aColor["R"], aColor["G"], aColor["B"], aColor["O"]);
						if (aColor["useText"]) then
							VUHDO_getBarText(tHealthBar):SetTextColor(aColor["TR"], aColor["TG"], aColor["TB"], aColor["TO"]);
							VUHDO_getLifeText(tHealthBar):SetTextColor(aColor["TR"], aColor["TG"], aColor["TB"], aColor["TO"]);
						end
					end
				  tHealthBar:SetValue(tQuota);
				else
					tHealthBar:SetValue(0);
				end
			end
		end
	end

	if (VUHDO_RAID[aUnit] == nil) then
		return;
	end

	tTargetQuota = nil;

	-- Targets und targets-of-target, die im Raid sind
  tAllButtons = VUHDO_IN_RAID_TARGET_BUTTONS[VUHDO_RAID[aUnit]["name"]];
	if (tAllButtons == nil) then
		return;
	end
	for _, tButton in pairs(tAllButtons) do
		if (tTargetQuota == nil and aCurrValue2 ~= nil and aCurrValue2 ~= aCurrValue) then
			if (aCurrValue2 == 0 and aMaxValue == 0) then
				if (anIsActive) then
					tQuota = 100;
				else
					tQuota = 0;
				end
			elseif (aMaxValue > 1) then
				tQuota = 100 * aCurrValue2 / aMaxValue;
			else
				tQuota = 0;
			end
		end
		tTargetQuota = tQuota;
		tHealthBar = VUHDO_getHealthBar(tButton, 1);
		if (tQuota > 0) then
			tHealthBar:SetValue(tQuota);
		else
			tHealthBar:SetValue(0);
		end
	end

end



--
function VUHDO_healthBarBouquetCallbackCustom(aUnit, anIsActive, anIcon, aCurrValue, aCounter, aMaxValue, aColor, aBuffName, aBouquetName)
	aMaxValue = aMaxValue or 0;
	aCurrValue = aCurrValue or 0;

	if (aCurrValue == 0 and aMaxValue == 0) then
		if (anIsActive) then
			tQuota = 100;
		else
			tQuota = 0;
		end
	elseif (aMaxValue > 1) then
		tQuota = 100 * aCurrValue / aMaxValue;
	else
		tQuota = 0;
	end

	tAllButtons = VUHDO_getUnitButtons(aUnit);
	if (tAllButtons ~= nil) then
		for _, tButton in pairs(tAllButtons) do
			if (VUHDO_INDICATOR_CONFIG["BOUQUETS"]["HEALTH_BAR_PANEL"][VUHDO_BUTTON_CACHE[tButton]] == aBouquetName) then
				tHealthBar = VUHDO_getHealthBar(tButton, 1);

				if (tQuota > 0) then
					if (aColor ~= nil) then
						tHealthBar:SetStatusBarColor(aColor["R"], aColor["G"], aColor["B"], aColor["O"]);
						if (aColor["useText"]) then
							VUHDO_getBarText(tHealthBar):SetTextColor(aColor["TR"], aColor["TG"], aColor["TB"], aColor["TO"]);
							VUHDO_getLifeText(tHealthBar):SetTextColor(aColor["TR"], aColor["TG"], aColor["TB"], aColor["TO"]);
						end
					end
				  tHealthBar:SetValue(tQuota);
				else
					tHealthBar:SetValue(0);
				end
			end
		end
	end
end



--
local tAllButtons, tButton, tAggroBar;
function VUHDO_aggroBarBouquetCallback(aUnit, anIsActive, anIcon, aTimer, aCounter, aDuration, aColor, aBuffName, aBouquetName)
	tAllButtons = VUHDO_getUnitButtons(aUnit);
	if (tAllButtons ~= nil) then
		for _, tButton in pairs(tAllButtons) do
			if (anIsActive) then
				tAggroBar = VUHDO_getHealthBar(tButton, 4);
				tAggroBar:SetStatusBarColor(aColor["R"], aColor["G"], aColor["B"], aColor["O"]);
				tAggroBar:SetValue(100);
			else
				VUHDO_getHealthBar(tButton, 4):SetValue(0);
			end
		end
	end
end



--
local tAllButtons, tButton, tBar, tQuota;
function VUHDO_backgroundBarBouquetCallback(aUnit, anIsActive, anIcon, aCurrValue, aCounter, aMaxValue, aColor, aBuffName, aBouquetName)
	aMaxValue = aMaxValue or 0;
	aCurrValue = aCurrValue or 0;

	if (aCurrValue == 0 and aMaxValue == 0) then
		if (anIsActive) then
			tQuota = 100;
		else
			tQuota = 0;
		end
	elseif (aMaxValue > 1 and anIsActive) then
		tQuota = 100;
	else
		tQuota = 0;
	end

	tAllButtons =  VUHDO_getUnitButtons(aUnit);
	if (tAllButtons ~= nil) then
		for _, tButton in pairs(tAllButtons) do
			tBar = VUHDO_getHealthBar(tButton, 3);
			if (aColor ~= nil) then
				tBar:SetStatusBarColor(aColor["R"], aColor["G"], aColor["B"], aColor["O"]);
			end
			tBar:SetValue(tQuota);
		end
	end
end



--
local tTexture;
local tIcon;
local tUnit;
function VUHDO_customizeHealButton(aButton)
	VUHDO_customizeText(aButton, 1, false); -- VUHDO_UPDATE_ALL

	tUnit, _ = VUHDO_getDisplayUnit(aButton);
	-- Raid icon
	if (VUHDO_PANEL_SETUP[VUHDO_BUTTON_CACHE[aButton]]["RAID_ICON"]["show"] and tUnit ~= nil) then
  	tIcon = GetRaidTargetIndex(tUnit);
  	if (tIcon ~= nil and VUHDO_PANEL_SETUP["RAID_ICON_FILTER"][tIcon]) then
	  	tTexture = VUHDO_getBarRoleIcon(aButton, 50);
  		VUHDO_setRaidTargetIconTexture(tTexture, tIcon);
  		tTexture:Show();
  	else
  		VUHDO_getBarRoleIcon(aButton, 50):Hide();
  	end
	end
end
local VUHDO_customizeHealButton = VUHDO_customizeHealButton;



--
local tInfo, tCnt, tAlpha;
local function VUHDO_customizeDebuffIconsRange(aButton)
	_, tInfo = VUHDO_getDisplayUnit(aButton);

  if (tInfo ~= nil) then
    if (tInfo["range"]) then
      tAlpha = 1;
    else
      tAlpha = VUHDO_BAR_COLOR["OUTRANGED"]["O"];
    end

  	for tCnt = 40, 44 do
  		VUHDO_getBarIconFrame(aButton, tCnt):SetAlpha(tAlpha);
  	end
  end
end



--
local tInfo;
local tAllButtons;
local tButton;
function VUHDO_updateHealthBarsFor(aUnit, anUpdateMode)
	VUHDO_updateBouquetsForEvent(aUnit, anUpdateMode);

	if (4 == anUpdateMode) then -- VUHDO_UPDATE_DEBUFF
		return;
	end

  tAllButtons = VUHDO_getUnitButtons(aUnit);
	tInfo = VUHDO_RAID[aUnit];
	if (tInfo == nil or tAllButtons == nil) then
		return;
	end

	if (2 == anUpdateMode) then -- VUHDO_UPDATE_HEALTH
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 2, false); -- VUHDO_UPDATE_HEALTH
			VUHDO_customizeDamageFlash(tButton, tInfo["lifeLossPerc"]);
		end
		tInfo["lifeLossPerc"] = nil;
		VUHDO_updateIncHeal(aUnit);

	elseif (9 == anUpdateMode) then -- VUHDO_UPDATE_INC
		if (sIsOverhealText) then
			for _, tButton in pairs(tAllButtons) do
				VUHDO_customizeText(tButton, 2, false); -- VUHDO_UPDATE_HEALTH
			end
		end
		VUHDO_updateIncHeal(aUnit);

	elseif (7 == anUpdateMode) then -- VUHDO_UPDATE_AGGRO
		if (sIsAggroText) then
			for _, tButton in pairs(tAllButtons) do
				VUHDO_customizeText(tButton, 7, false); -- VUHDO_UPDATE_AGGRO
			end
		end

	elseif (5 == anUpdateMode) then -- VUHDO_UPDATE_RANGE
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 7, false); -- f�r d/c tag -- VUHDO_UPDATE_AGGRO
			VUHDO_customizeDebuffIconsRange(tButton);
		end

	elseif (3 == anUpdateMode) then -- VUHDO_UPDATE_HEALTH_MAX
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 2, false); -- VUHDO_UPDATE_HEALTH
		end
		VUHDO_updateIncHeal(aUnit);

	elseif (6 == anUpdateMode) then -- VUHDO_UPDATE_AFK
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 7, false); -- VUHDO_UPDATE_AGGRO
		end
	elseif (10 == anUpdateMode) then -- VUHDO_UPDATE_ALIVE
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 1, false); -- VUHDO_UPDATE_ALL
		end
		VUHDO_updateIncHeal(aUnit);

	elseif (25 == anUpdateMode) then -- VUHDO_UPDATE_RESURRECTION
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 1, false); -- VUHDO_UPDATE_ALL
		end

	elseif (1 == anUpdateMode) then -- VUHDO_UPDATE_ALL
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeHealButton(tButton);
		end

		VUHDO_updateIncHeal(aUnit);
	end

	------------------
	-- In-Raid Targets
	------------------

  tAllButtons = VUHDO_IN_RAID_TARGET_BUTTONS[tInfo["name"]];
	if (tAllButtons == nil) then
		return;
	end

	VUHDO_CUSTOM_INFO["fixResolveId"] = aUnit;
	if (2 == anUpdateMode) then -- VUHDO_UPDATE_HEALTH
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 2, true); -- VUHDO_UPDATE_HEALTH
		end

	elseif (3 == anUpdateMode) then -- VUHDO_UPDATE_HEALTH_MAX
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 2, true); -- VUHDO_UPDATE_HEALTH
		end

	elseif (10 == anUpdateMode) then -- VUHDO_UPDATE_ALIVE
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 1, true); -- VUHDO_UPDATE_ALL
		end
	elseif (1 == anUpdateMode) then -- VUHDO_UPDATE_ALL
		for _, tButton in pairs(tAllButtons) do
			VUHDO_customizeText(tButton, 1, true); -- VUHDO_UPDATE_ALL
		end
	end
end



--
local VUHDO_getHealButton = VUHDO_getHealButton;
local tButton;
local tUnit;
local tPanelButtons;
function VUHDO_updateAllPanelBars(aPanelNum)
	tPanelButtons = VUHDO_getPanelButtons(aPanelNum);
	for _, tButton in pairs(tPanelButtons) do
		if (tButton:GetAttribute("unit") == nil) then
			break;
		end
		VUHDO_customizeHealButton(tButton);
	end

	for tUnit, _ in pairs(VUHDO_RAID) do
		VUHDO_updateIncHeal(tUnit);
		VUHDO_updateManaBars(tUnit, 3);
		VUHDO_manaBarBouquetCallback(tUnit, false, nil, nil, nil, nil, nil, nil, nil);
	end
end
local VUHDO_updateAllPanelBars = VUHDO_updateAllPanelBars;



--
local tCnt;
VUHDO_REMOVE_HOTS = true;
function VUHDO_updateAllRaidBars()
	for tCnt = 1, 10 do -- VUHDO_MAX_PANELS
		if (VUHDO_isPanelVisible(tCnt)) then
			VUHDO_updateAllPanelBars(tCnt);
		end
	end

	if (VUHDO_REMOVE_HOTS) then
		VUHDO_removeAllHots();
		VUHDO_updateAllHoTs();
	  if (VUHDO_INTERNAL_TOGGLES[18]) then -- VUHDO_UPDATE_MOUSEOVER_CLUSTER
			VUHDO_updateClusterHighlights();
		end
	else
		VUHDO_REMOVE_HOTS = true;
	end
end
