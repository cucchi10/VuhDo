VUHDO_BOUQUET_CUSTOM_TYPE_PERCENT = 1;
VUHDO_BOUQUET_CUSTOM_TYPE_PLAYERS = 2;
VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR = 3;
VUHDO_BOUQUET_CUSTOM_TYPE_BRIGHTNESS = 4;

VUHDO_FORCE_RESET = false;

local table = table;
local floor = floor;
local select = select;
local GetRaidTargetIndex = GetRaidTargetIndex;

local VUHDO_RAID = { };
local VUHDO_RESSING_NAMES = { };

local VUHDO_getOtherPlayersHotInfo;
local VUHDO_getChosenDebuffInfo;
local VUHDO_getCurrentPlayerTarget;
local VUHDO_getCurrentMouseOver;
local VUHDO_getDistanceBetween;
local VUHDO_isUnitSwiftmendable;
local VUHDO_getNumInUnitCluster;
local VUHDO_getIsInHiglightCluster;
local VUHDO_getDebuffColor;
local VUHDO_getCurrentBouquetColor;
local VUHDO_getIncHealOnUnit;
local VUHDO_getUnitDebuffSchoolInfos;
local VUHDO_getCurrentBouquetStacks;
local VUHDO_getIncHealOnUnit;
local sIsInverted;
local sBarColors;

----------------------------------------------------------



function VUHDO_bouquetValidatorsInitBurst()
	VUHDO_RAID = VUHDO_GLOBAL["VUHDO_RAID"];
	VUHDO_RESSING_NAMES = VUHDO_GLOBAL["VUHDO_RESSING_NAMES"];

	VUHDO_getOtherPlayersHotInfo = VUHDO_GLOBAL["VUHDO_getOtherPlayersHotInfo"];
	VUHDO_getChosenDebuffInfo = VUHDO_GLOBAL["VUHDO_getChosenDebuffInfo"];
	VUHDO_getCurrentPlayerTarget = VUHDO_GLOBAL["VUHDO_getCurrentPlayerTarget"];
	VUHDO_getCurrentMouseOver = VUHDO_GLOBAL["VUHDO_getCurrentMouseOver"];
	VUHDO_getDistanceBetween = VUHDO_GLOBAL["VUHDO_getDistanceBetween"];
	VUHDO_isUnitSwiftmendable = VUHDO_GLOBAL["VUHDO_isUnitSwiftmendable"];
	VUHDO_getNumInUnitCluster = VUHDO_GLOBAL["VUHDO_getNumInUnitCluster"];
	VUHDO_getIsInHiglightCluster = VUHDO_GLOBAL["VUHDO_getIsInHiglightCluster"];
	VUHDO_getDebuffColor = VUHDO_GLOBAL["VUHDO_getDebuffColor"];
	VUHDO_getCurrentBouquetColor = VUHDO_GLOBAL["VUHDO_getCurrentBouquetColor"];
	VUHDO_getIncHealOnUnit = VUHDO_GLOBAL["VUHDO_getIncHealOnUnit"];
	VUHDO_getUnitDebuffSchoolInfos = VUHDO_GLOBAL["VUHDO_getUnitDebuffSchoolInfos"];
	VUHDO_getCurrentBouquetStacks = VUHDO_GLOBAL["VUHDO_getCurrentBouquetStacks"];
	VUHDO_getIncHealOnUnit = VUHDO_GLOBAL["VUHDO_getIncHealOnUnit"];

	sIsInverted = VUHDO_INDICATOR_CONFIG["CUSTOM"]["HEALTH_BAR"]["invertGrowth"];
	sBarColors = VUHDO_PANEL_SETUP["BAR_COLORS"];
end

----------------------------------------------------------



local VUHDO_ICONS_BY_ROLE = {
	[VUHDO_ID_MELEE_TANK] = "Interface\\AddOns\\VuhDo\\Images\\roleicons\\tank",
	[VUHDO_ID_MELEE_DAMAGE] = "Interface\\AddOns\\VuhDo\\Images\\roleicons\\damage",
	[VUHDO_ID_RANGED_DAMAGE] = "Interface\\AddOns\\VuhDo\\Images\\roleicons\\damage",
	[VUHDO_ID_RANGED_HEAL] = "Interface\\AddOns\\VuhDo\\Images\\roleicons\\healer",
};



local VUHDO_ICONS_BY_RAID_ICON = {
	[1] = "Interface\\AddOns\\VuhDo\\Images\\raidicons\\0",
	[2] = "Interface\\AddOns\\VuhDo\\Images\\raidicons\\1",
	[3] = "Interface\\AddOns\\VuhDo\\Images\\raidicons\\2",
	[4] = "Interface\\AddOns\\VuhDo\\Images\\raidicons\\3",
	[5] = "Interface\\AddOns\\VuhDo\\Images\\raidicons\\4",
	[6] = "Interface\\AddOns\\VuhDo\\Images\\raidicons\\5",
	[7] = "Interface\\AddOns\\VuhDo\\Images\\raidicons\\6",
	[8] = "Interface\\AddOns\\VuhDo\\Images\\raidicons\\7",
};



local VUHDO_ICONS_BY_CLASS_ID = {
	[VUHDO_ID_WARRIORS] = "Interface\\AddOns\\VuhDo\\Images\\classicons\\warrior",
	[VUHDO_ID_ROGUES] = "Interface\\AddOns\\VuhDo\\Images\\classicons\\rogue",
	[VUHDO_ID_HUNTERS] = "Interface\\AddOns\\VuhDo\\Images\\classicons\\hunter",
	[VUHDO_ID_PALADINS] = "Interface\\AddOns\\VuhDo\\Images\\classicons\\paladin",
	[VUHDO_ID_MAGES] = "Interface\\AddOns\\VuhDo\\Images\\classicons\\mage",
	[VUHDO_ID_WARLOCKS] = "Interface\\AddOns\\VuhDo\\Images\\classicons\\warlock",
	[VUHDO_ID_SHAMANS] = "Interface\\AddOns\\VuhDo\\Images\\classicons\\shaman",
	[VUHDO_ID_DRUIDS] = "Interface\\AddOns\\VuhDo\\Images\\classicons\\druid",
	[VUHDO_ID_PRIESTS] = "Interface\\AddOns\\VuhDo\\Images\\classicons\\priest",
	[VUHDO_ID_DEATH_KNIGHT] = "Interface\\AddOns\\VuhDo\\Images\\classicons\\deathknight",
};



local VUHDO_CHARGE_COLORS = {
  "HOT_CHARGE_1",
  "HOT_CHARGE_2",
  "HOT_CHARGE_3",
  "HOT_CHARGE_4",
};



--
local tCopy = { };
local tEmptyColor = { };
local function VUHDO_copyColor(aColor)
	if (aColor == nil) then
		return tEmptyColor;
	end
	tCopy["R"], tCopy["G"], tCopy["B"], tCopy["O"] = aColor["R"], aColor["G"], aColor["B"], aColor["O"];
	tCopy["TR"], tCopy["TG"], tCopy["TB"], tCopy["TO"] = aColor["TR"], aColor["TG"], aColor["TB"], aColor["TO"];
	tCopy["useBackground"], tCopy["useText"], tCopy["useOpacity"] = aColor["useBackground"], aColor["useText"], aColor["useOpacity"];
	return tCopy;
end



--
local tSummand;
local function VUHDO_brightenColor(aColor, aFactor)
	if (aColor == nil) then
		return;
	end
	tSummand = aFactor - 1;
	aColor["R"], aColor["G"], aColor["B"] = (aColor["R"] or 0) + tSummand, (aColor["G"] or 0) + tSummand, (aColor["B"] or 0) + tSummand;
	return aColor;
end






-- return tIsActive, tIcon, tTimer, tCounter, tDuration, tColor, tTimer2

--
local function VUHDO_aggroValidator(anInfo, _)
	return anInfo["aggro"], nil, -1, -1, -1, nil, nil;
end



--
local function VUHDO_outOfRangeValidator(anInfo, _)
	return not anInfo["range"], nil, -1, -1, -1, nil, nil;
end



--
local function VUHDO_inRangeValidator(anInfo, _)
	return anInfo["range"], nil, -1, -1, -1, nil, nil;
end



--
local tDistance;
local function VUHDO_inYardsRangeValidator(anInfo, someCustom)
	tDistance = VUHDO_getDistanceBetween("player", anInfo["unit"]);
	return (tDistance ~= nil) and (tDistance <= someCustom["custom"][1]), nil, -1, -1, -1, nil, nil;
end



--
local tDistance;
local function VUHDO_swiftmendValidator(anInfo, _)
	return VUHDO_isUnitSwiftmendable(anInfo["unit"]), nil, -1, -1, -1, nil, nil;
end



--
local tOPHotInfo;
local function VUHDO_otherPlayersHotsValidator(anInfo, _)
	tOPHotInfo = VUHDO_getOtherPlayersHotInfo(anInfo["unit"]);
	return tOPHotInfo[1] ~= nil, tOPHotInfo[1], -1, tOPHotInfo[2], -1, nil, nil;
end



--
local tDebuffInfo;
local function VUHDO_debuffMagicValidator(anInfo, _)
	tDebuffInfo = VUHDO_getUnitDebuffSchoolInfos(anInfo["unit"], VUHDO_DEBUFF_TYPE_MAGIC);
	if (tDebuffInfo[2] ~= nil) then
		return true, tDebuffInfo[1], tDebuffInfo[2], tDebuffInfo[3], tDebuffInfo[4], nil, nil;
	else
		return false, nil, -1, -1, -1;
	end
end



--
local tDebuffInfo;
local function VUHDO_debuffDiseaseValidator(anInfo, _)
	tDebuffInfo = VUHDO_getUnitDebuffSchoolInfos(anInfo["unit"], VUHDO_DEBUFF_TYPE_DISEASE);
	if (tDebuffInfo[2] ~= nil) then
		return true, tDebuffInfo[1], tDebuffInfo[2], tDebuffInfo[3], tDebuffInfo[4], nil, nil;
	else
		return false, nil, -1, -1, -1;
	end
end



--
local tDebuffInfo;
local function VUHDO_debuffPoisonValidator(anInfo, _)
	tDebuffInfo = VUHDO_getUnitDebuffSchoolInfos(anInfo["unit"], VUHDO_DEBUFF_TYPE_POISON);
	if (tDebuffInfo[2] ~= nil) then
		return true, tDebuffInfo[1], tDebuffInfo[2], tDebuffInfo[3], tDebuffInfo[4], nil, nil;
	else
		return false, nil, -1, -1, -1;
	end
end



--
local tDebuffInfo;
local function VUHDO_debuffCurseValidator(anInfo, _)
	tDebuffInfo = VUHDO_getUnitDebuffSchoolInfos(anInfo["unit"], VUHDO_DEBUFF_TYPE_CURSE);
	if (tDebuffInfo[2] ~= nil) then
		return true, tDebuffInfo[1], tDebuffInfo[2], tDebuffInfo[3], tDebuffInfo[4], nil, nil;
	else
		return false, nil, -1, -1, -1;
	end
end



local function VUHDO_debuffBarColorValidator(anInfo, _)
	if (anInfo["charmed"]) then
		return true, nil, -1, -1, -1, VUHDO_getDebuffColor(anInfo);
	elseif (0 ~= anInfo["debuff"]) then -- VUHDO_DEBUFF_TYPE_NONE
		tDebuffInfo = VUHDO_getChosenDebuffInfo(anInfo["unit"]);
		return true, tDebuffInfo[1], -1, tDebuffInfo[3], -1, VUHDO_getDebuffColor(anInfo), nil;
	else
		return false, nil, -1, -1, -1, nil;
	end
end



--
local function VUHDO_debuffCharmedValidator(anInfo, _)
	return anInfo["charmed"], nil, -1, -1, -1, nil, nil;
end



--
local function VUHDO_deadValidator(anInfo, _)
	return anInfo["dead"], nil, 100, -1, 100, nil, nil;
end



--
function VUHDO_disconnectedValidator(anInfo, _)
	return anInfo == nil or not anInfo["connected"], nil, 100, -1, 100, nil, nil;
end
local VUHDO_disconnectedValidator = VUHDO_disconnectedValidator;



--
local function VUHDO_afkValidator(anInfo, _)
	return anInfo["afk"], nil, -1, -1, -1, nil, nil;
end



--
local tEmptyInfo = { };
local function VUHDO_playerTargetValidator(anInfo, _)
	if (anInfo["isPet"] and (VUHDO_RAID[anInfo["ownerUnit"]] or tEmptyInfo)["isVehicle"]) then
		return anInfo["ownerUnit"] == VUHDO_getCurrentPlayerTarget(), nil, VUHDO_RAID[anInfo["ownerUnit"]]["health"], -1, VUHDO_RAID[anInfo["ownerUnit"]]["healthmax"], nil, nil;
	else
		return anInfo["unit"] == VUHDO_getCurrentPlayerTarget(), nil, anInfo["health"], -1, anInfo["healthmax"], nil, nil;
	end

end



--
local tEmptyInfo = { };
local function VUHDO_mouseOverTargetValidator(anInfo, _)
	if (anInfo["isPet"] and (VUHDO_RAID[anInfo["ownerUnit"]] or tEmptyInfo)["isVehicle"]) then
		return anInfo["ownerUnit"] == VUHDO_getCurrentMouseOver(), nil, VUHDO_RAID[anInfo["ownerUnit"]]["health"], -1, VUHDO_RAID[anInfo["ownerUnit"]]["healthmax"], nil, nil;
	else
		return anInfo["unit"] == VUHDO_getCurrentMouseOver(), nil, anInfo["health"], -1, anInfo["healthmax"], nil, nil;
	end
end



--
local tMouseOverUnit;
local function VUHDO_mouseOverGroupValidator(anInfo, _)
	tMouseOverUnit = VUHDO_getCurrentMouseOver();
	return VUHDO_RAID[tMouseOverUnit] ~= nil and anInfo["group"] == VUHDO_RAID[tMouseOverUnit]["group"], nil, -1, -1, -1, nil, nil;
end



--
local function VUHDO_healthBelowValidator(anInfo, someCustom)
	return 100 * anInfo["health"] / anInfo["healthmax"] < someCustom["custom"][1], nil, -1, -1, -1, nil, nil;
end



--
local function VUHDO_healthAboveValidator(anInfo, someCustom)
	return 100 * anInfo["health"] / anInfo["healthmax"] >= someCustom["custom"][1], nil, -1, -1, -1, nil, nil;
end



--
local function VUHDO_manaBelowValidator(anInfo, someCustom)
	return anInfo["powertype"] == 0 and 100 * anInfo["power"] / anInfo["powermax"] < someCustom["custom"][1], nil, -1, -1, -1, nil, nil;
end



--
local function VUHDO_threatAboveValidator(anInfo, someCustom)
	return anInfo["threatPerc"] > someCustom["custom"][1], nil, -1, -1, -1, nil, nil;
end



--
local tNumInCluster;
local function VUHDO_numInClusterValidator(anInfo, someCustom)
	tNumInCluster = VUHDO_getNumInUnitCluster(anInfo["unit"]);
	return tNumInCluster >= someCustom["custom"][1], nil, -1, tNumInCluster, -1, nil, nil;
end



--
local function VUHDO_mouseClusterValidator(anInfo, _)
	return VUHDO_getIsInHiglightCluster(anInfo["unit"]), nil, -1, -1, -1, nil, nil;
end



--
local function VUHDO_threatMediumValidator(anInfo, _)
	return anInfo["threat"] == 2, nil, -1, -1, -1, nil, nil;
end



--
local function VUHDO_threatHighValidator(anInfo, _)
	return anInfo["threat"] == 3, nil, -1, -1, -1, nil, nil;
end


--
local tIsRaidIconColor;
local tColor, tIcon;
local function VUHDO_raidTargetValidator(anInfo, _)
	if (anInfo["raidIcon"] ~= nil) then
		tIcon = tostring(anInfo["raidIcon"]);
		tIsRaidIconColor = not sBarColors["RAID_ICONS"]["filterOnly"] or VUHDO_PANEL_SETUP["RAID_ICON_FILTER"][tIcon];

		if (tIsRaidIconColor) then
			tColor = sBarColors["RAID_ICONS"][tIcon];
		else
			tColor = nil;
		end
		return tIsRaidIconColor, nil, -1, -1, -1, tColor, nil;
	else
		return false, nil, -1, -1, -1, nil, nil;
	end
end



--
local tOverheal;
local function VUHDO_overhealHighlightValidator(anInfo, _)
	tOverheal = VUHDO_getIncHealOnUnit(anInfo["name"]) + anInfo["health"];
	if (tOverheal > anInfo["healthmax"]) then
		VUHDO_brightenColor(VUHDO_getCurrentBouquetColor(), tOverheal / anInfo["healthmax"]);
	end
	return false, nil, -1, -1, -1, nil, nil;
end




--
local tStacks;
local function VUHDO_stacksColorValidator(anInfo, _)
  tStacks = VUHDO_getCurrentBouquetStacks() or 0;
  if (tStacks > 4) then
    tStacks = 4;
  end

  if (tStacks > 1) then
    return true, nil, -1, -1, -1, VUHDO_copyColor(sBarColors[VUHDO_CHARGE_COLORS[tStacks]]), nil;
  else
    return false, nil, -1, -1, -1, nil, nil;
  end
end



--
local tIndex, tFactor, tColor;
local function VUHDO_emergencyColorValidator(anInfo, someCustom)
	if (not VUHDO_FORCE_RESET) then
  	tIndex = VUHDO_EMERGENCIES[anInfo["unit"]];
  	if (tIndex ~= nil) then
  		tFactor = 1 / tIndex;

  		tColor = VUHDO_copyColor(someCustom["color"]);
  		tColor["R"], tColor["G"], tColor["B"] = (tColor["R"] or 0) * tFactor, (tColor["G"] or 0) * tFactor, (tColor["B"] or 0) * tFactor;
			return true, nil, -1, -1, -1, tColor;
  	end
  end

	return false, nil, -1, -1, -1, nil, nil;
end



--
local function VUHDO_resurrectionValidator(anInfo, someCustom)
  return VUHDO_RESSING_NAMES[anInfo["name"]], nil, -1, -1, -1, nil, nil;
end



-- return tIsActive, tIcon, tTimer, tCounter, tDuration, tColor

--
local function VUHDO_statusHealthValidator(anInfo, _)
  if (sIsInverted) then
		return true, nil, anInfo["health"] + VUHDO_getIncHealOnUnit(anInfo["name"]), -1, anInfo["healthmax"], nil, anInfo["health"];
  else
		return true, nil, anInfo["health"], -1, anInfo["healthmax"], nil, anInfo["health"];
	end
end



--
local function VUHDO_statusManaValidator(anInfo, _)
	return anInfo["powertype"] == 0, nil, anInfo["power"], -1, anInfo["powermax"], VUHDO_copyColor(VUHDO_POWER_TYPE_COLORS[0]), nil;
end



--
local function VUHDO_statusOtherPowersValidator(anInfo, _)
	return anInfo["powertype"] ~= 0, nil, anInfo["power"], -1, anInfo["powermax"], VUHDO_copyColor(VUHDO_POWER_TYPE_COLORS[anInfo["powertype"] or 0]), nil;
end



--
local function VUHDO_statusIncomingValidator(anInfo, _)
	return true, nil, VUHDO_getIncHealOnUnit(anInfo["name"]), -1, anInfo["healthmax"], nil, nil;
end



--
local function VUHDO_statusThreatValidator(anInfo, _)
	return true, nil, anInfo["threatPerc"], -1, 100, nil, nil;
end



--
local tIcon;
local function VUHDO_classIconValidator(anInfo, _)
	tIcon = VUHDO_ICONS_BY_CLASS_ID[anInfo["classId"] or -1];

	if (tIcon ~= nil) then
		return true, tIcon, -1, -1, -1, nil, nil;
	else
		return false, nil, -1, -1, -1, nil, nil;
	end
end



--
local tIcon;
local function VUHDO_raidIconValidator(anInfo, _)
	tIcon = VUHDO_ICONS_BY_RAID_ICON[GetRaidTargetIndex(anInfo["unit"]) or -1];

	if (tIcon ~= nil) then
		return true, tIcon, -1, -1, -1, nil, nil;
	else
		return false, nil, -1, -1, -1, nil, nil;
	end
end



--
local tIcon;
local function VUHDO_roleIconValidator(anInfo, _)
	tIcon = VUHDO_ICONS_BY_ROLE[anInfo["role"] or -1];

	if (tIcon ~= nil) then
		return true, tIcon, -1, -1, -1, nil, nil;
	else
		return false, nil, -1, -1, -1, nil, nil;
	end
end



--
local function VUHDO_classColorValidator(anInfo, _)
	return true, nil, -1, -1, -1, VUHDO_copyColor(VUHDO_USER_CLASS_COLORS[anInfo["classId"]]), nil;
end



--
local function VUHDO_alwaysTrueValidator(_, _)
	return true, nil, -1, -1, -1, nil, nil;
end



--
VUHDO_BOUQUET_BUFFS_SPECIAL = {
	["AGGRO"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_AGGRO,
		["validator"] = VUHDO_aggroValidator,
		["interests"] = { VUHDO_UPDATE_AGGRO },
	},

	["NO_RANGE"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_OUT_OF_RANGE,
		["validator"] = VUHDO_outOfRangeValidator,
		["interests"] = { VUHDO_UPDATE_RANGE },
	},

	["IN_RANGE"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_IN_RANGE,
		["validator"] = VUHDO_inRangeValidator,
		["interests"] = { VUHDO_UPDATE_RANGE },
	},

	["YARDS_RANGE"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_IN_YARDS,
		["validator"] = VUHDO_inYardsRangeValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_PERCENT,
		["updateCyclic"] = true,
		["interests"] = { },
	},

	["OTHER"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_OTHER_HOTS,
		["validator"] = VUHDO_otherPlayersHotsValidator,
		["updateCyclic"] = true,
		["interests"] = { },
	},

	["SWIFTMEND"] = {
		["displayName"] = VUHDO_I18N_SWIFTMEND_POSSIBLE,
		["validator"] = VUHDO_swiftmendValidator,
		["updateCyclic"] = true,
		["interests"] = { },
	},

	["DEBUFF_MAGIC"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_DEBUFF_MAGIC,
		["validator"] = VUHDO_debuffMagicValidator,
		["interests"] = { VUHDO_UPDATE_DEBUFF },
	},

	["DEBUFF_DISEASE"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_DEBUFF_DISEASE,
		["validator"] = VUHDO_debuffDiseaseValidator,
		["interests"] = { VUHDO_UPDATE_DEBUFF },
	},

	["DEBUFF_POISON"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_DEBUFF_POISON,
		["validator"] = VUHDO_debuffPoisonValidator,
		["interests"] = { VUHDO_UPDATE_DEBUFF },
	},

	["DEBUFF_CURSE"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_DEBUFF_CURSE,
		["validator"] = VUHDO_debuffCurseValidator,
		["interests"] = { VUHDO_UPDATE_DEBUFF },
	},

	["DEBUFF_CHARMED"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_CHARMED,
		["validator"] = VUHDO_debuffCharmedValidator,
		["interests"] = { VUHDO_UPDATE_DEBUFF },
	},

	["DEBUFF_BAR_COLOR"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_DEBUFF_BAR_COLOR,
		["validator"] = VUHDO_debuffBarColorValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_BRIGHTNESS,
		["no_color"] = true,
		["interests"] = { VUHDO_UPDATE_DEBUFF },
	},

	["DEAD"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_DEAD,
		["validator"] = VUHDO_deadValidator,
		["interests"] = { VUHDO_UPDATE_ALIVE },
	},

	["DISCONNECTED"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_DISCONNECTED,
		["validator"] = VUHDO_disconnectedValidator,
		["interests"] = { VUHDO_UPDATE_DC },
	},

	["AFK"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_AFK,
		["validator"] = VUHDO_afkValidator,
		["interests"] = { VUHDO_UPDATE_AFK },
	},

	["PLAYER_TARGET"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_PLAYER_TARGET,
		["validator"] = VUHDO_playerTargetValidator,
		["interests"] = { VUHDO_UPDATE_TARGET },
	},

	["MOUSE_TARGET"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_MOUSEOVER_TARGET,
		["validator"] = VUHDO_mouseOverTargetValidator,
		["interests"] = { VUHDO_UPDATE_MOUSEOVER, VUHDO_UPDATE_HEALTH, VUHDO_UPDATE_HEALTH_MAX },
	},

	["MOUSE_GROUP"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_MOUSEOVER_GROUP,
		["validator"] = VUHDO_mouseOverGroupValidator,
		["interests"] = { VUHDO_UPDATE_MOUSEOVER_GROUP, VUHDO_UPDATE_HEALTH, VUHDO_UPDATE_HEALTH_MAX },
	},

	["HEALTH_BELOW"] = {
	  ["displayName"] = VUHDO_I18N_BOUQUET_HEALTH_BELOW,
		["validator"] = VUHDO_healthBelowValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_PERCENT,
		["interests"] = { VUHDO_UPDATE_HEALTH, VUHDO_UPDATE_HEALTH_MAX },
	},

	["HEALTH_ABOVE"] = {
	  ["displayName"] = VUHDO_I18N_BOUQUET_HEALTH_ABOVE,
		["validator"] = VUHDO_healthAboveValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_PERCENT,
		["interests"] = { VUHDO_UPDATE_HEALTH, VUHDO_UPDATE_HEALTH_MAX },
	},

	["MANA_BELOW"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_MANA_BELOW,
		["validator"] = VUHDO_manaBelowValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_PERCENT,
		["interests"] = { VUHDO_UPDATE_MANA },
	},

	["THREAT_ABOVE"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_THREAT_ABOVE,
		["validator"] = VUHDO_threatAboveValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_PERCENT,
		["interests"] = { VUHDO_UPDATE_THREAT_PERC },
	},

	["NUM_CLUSTER"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_NUM_IN_CLUSTER,
		["validator"] = VUHDO_numInClusterValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_PLAYERS,
		["interests"] = { VUHDO_UPDATE_NUM_CLUSTER },
	},

	["MOUSE_CLUSTER"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_MOUSEOVER_CLUSTER,
		["validator"] = VUHDO_mouseClusterValidator,
		["updateCyclic"] = true,
		["interests"] = { VUHDO_UPDATE_MOUSEOVER_CLUSTER },
	},

	["THREAT_LEVEL_MEDIUM"] = {
		["displayName"] = VUHDO_I18N_THREAT_LEVEL_MEDIUM,
		["validator"] = VUHDO_threatMediumValidator,
		["interests"] = { VUHDO_UPDATE_THREAT_LEVEL },
	},

	["THREAT_LEVEL_HIGH"] = {
		["displayName"] = VUHDO_I18N_THREAT_LEVEL_HIGH,
		["validator"] = VUHDO_threatHighValidator,
		["interests"] = { VUHDO_UPDATE_THREAT_LEVEL },
	},

	["RAID_ICON_COLOR"] = {
		["displayName"] = VUHDO_I18N_UPDATE_RAID_TARGET,
		["validator"] = VUHDO_raidTargetValidator,
		["no_color"] = true,
		["interests"] = { VUHDO_UPDATE_RAID_TARGET },
	},

	["OVERHEAL_HIGHLIGHT"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_OVERHEAL_HIGHLIGHT,
		["validator"] = VUHDO_overhealHighlightValidator,
		["no_color"] = true,
		["interests"] = { VUHDO_UPDATE_INC },
	},

	["EMERGENCY_COLOR"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_EMERGENCY_COLOR,
		["validator"] = VUHDO_emergencyColorValidator,
		["interests"] = { VUHDO_UPDATE_EMERGENCY },
	},

	["RESURRECTION"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_RESURRECTION,
		["validator"] = VUHDO_resurrectionValidator,
		["interests"] = { VUHDO_UPDATE_RESURRECTION },
	},

	["STATUS_HEALTH"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_STATUS_HEALTH,
		["validator"] = VUHDO_statusHealthValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR,
		["interests"] = { VUHDO_UPDATE_HEALTH, VUHDO_UPDATE_HEALTH_MAX, VUHDO_UPDATE_INC },
	},

	["STATUS_MANA"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_STATUS_MANA,
		["validator"] = VUHDO_statusManaValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR,
		["no_color"] = true,
		["interests"] = { VUHDO_UPDATE_MANA, VUHDO_UPDATE_DC },
	},

	["STATUS_OTHER_POWERS"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_STATUS_OTHER_POWERS,
		["validator"] = VUHDO_statusOtherPowersValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR,
		["no_color"] = true,
		["interests"] = { VUHDO_UPDATE_OTHER_POWERS, VUHDO_UPDATE_DC },
	},

	["STATUS_INCOMING"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_STATUS_INCOMING,
		["validator"] = VUHDO_statusIncomingValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR,
		["interests"] = { VUHDO_UPDATE_INC },
	},

	["STATUS_THREAT"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_STATUS_THREAT,
		["validator"] = VUHDO_statusThreatValidator,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_STATUSBAR,
		["interests"] = { VUHDO_UPDATE_THREAT_PERC },
	},

  ["STACKS_COLOR"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_STACKS_COLOR,
		["validator"] = VUHDO_stacksColorValidator,
		["updateCyclic"] = true,
		["no_color"] = true,
		["interests"] = { },
  },

	["CLASS_ICON"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_CLASS_ICON,
		["validator"] = VUHDO_classIconValidator,
		["no_color"] = true,
		["interests"] = { },
	},

	["RAID_ICON"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_RAID_ICON,
		["validator"] = VUHDO_raidIconValidator,
		["no_color"] = true,
		["interests"] = { },
	},

	["ROLE_ICON"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_ROLE_ICON,
		["validator"] = VUHDO_roleIconValidator,
		["no_color"] = true,
		["interests"] = { },
	},

	["CLASS_COLOR"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_CLASS_COLOR,
		["validator"] = VUHDO_classColorValidator,
		["no_color"] = true,
		["custom_type"] = VUHDO_BOUQUET_CUSTOM_TYPE_BRIGHTNESS,
		["interests"] = { },
	},

	["ALWAYS"] = {
		["displayName"] = VUHDO_I18N_BOUQUET_ALWAYS,
		["validator"] = VUHDO_alwaysTrueValidator,
		["interests"] = { },
	},
};
