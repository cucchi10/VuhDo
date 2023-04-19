local GetNumRaidMembers = GetNumRaidMembers;
local GetNumPartyMembers = GetNumPartyMembers;
local table = table;
local tonumber = tonumber;
local pairs = pairs;


VUHDO_PROFILES = { };


--
VUHDO_DEBUG_AUTO_ARRANG = nil;
VUHDO_IS_SHOWN_BY_GROUP = true;
local tNumMembers;
local tCnt, tIndex;
local tAutoProfileIndices = { "1", "5", "10", "15", "25", "40" };
local VUHDO_PROFILE_CFG;
function VUHDO_getAutoProfile()
	tNumMembers = 1;
  if (GetNumRaidMembers() > 0 or VUHDO_IS_CONFIG) then
  	tNumMembers = GetNumRaidMembers();

  	if (not VUHDO_IS_SHOWN_BY_GROUP and VUHDO_CONFIG["SHOW_PANELS"]) then
  	  VUHDO_IS_SHOWN_BY_GROUP = true;
  	  VUHDO_timeReloadUI(0.1);
  	end
	elseif (GetNumPartyMembers() > 0) then
		tNumMembers = GetNumPartyMembers() + 1;

  	if (not VUHDO_IS_SHOWN_BY_GROUP) then
  	  if (not VUHDO_CONFIG["HIDE_PANELS_PARTY"] and VUHDO_CONFIG["SHOW_PANELS"]) then
    	  VUHDO_IS_SHOWN_BY_GROUP = true;
	  	  VUHDO_timeReloadUI(0.1);
  	  end
  	else
  	  if (VUHDO_CONFIG["HIDE_PANELS_PARTY"]) then
    	  VUHDO_IS_SHOWN_BY_GROUP = false;
	  	  VUHDO_timeReloadUI(0.1);
  	  end
  	end
	else
  	if (not VUHDO_IS_SHOWN_BY_GROUP) then
  	  if (not VUHDO_CONFIG["HIDE_PANELS_SOLO"] and VUHDO_CONFIG["SHOW_PANELS"]) then
    	  VUHDO_IS_SHOWN_BY_GROUP = true;
	  	  VUHDO_timeReloadUI(0.1);
  	  end
  	else
  	  if (VUHDO_CONFIG["HIDE_PANELS_SOLO"]) then
    	  VUHDO_IS_SHOWN_BY_GROUP = false;
	  	  VUHDO_timeReloadUI(0.1);
  	  end
  	end
	end

	if (VUHDO_DEBUG_AUTO_ARRANG ~= nil) then
		tNumMembers = VUHDO_DEBUG_AUTO_ARRANG;
	end

	if (tNumMembers == 1) then
		table.wipe(VUHDO_MAINTANK_NAMES);
	end

	VUHDO_PROFILE_CFG = VUHDO_CONFIG["AUTO_PROFILES"];
	for _, tIndex in ipairs(tAutoProfileIndices) do
		if (VUHDO_PROFILE_CFG[tIndex] ~= nil and tNumMembers <= tonumber(tIndex)) then
			return VUHDO_PROFILE_CFG[tIndex], tNumMembers;
		end
	end

	return nil, nil;
end


---------------------------------------------------------------------------------






VUHDO_PROFILE_MODEL_MATCH_ALL = 0;
VUHDO_PROFILE_MODEL_MATCH_CLASS = 1;
VUHDO_PROFILE_MODEL_MATCH_TOON = 2;
VUHDO_PROFILE_MODEL_MATCH_NEVER = 99;




--
local tIndex, tValue;
function VUHDO_getProfileNamed(aName)
	for tIndex, tValue in pairs(VUHDO_PROFILES) do
		if (tValue["NAME"] == aName) then
			return tIndex, tValue;
		end
	end
	return nil, nil;
end



--
local function VUHDO_createNewProfile(aName)
	local _, tProfile = VUHDO_getProfileNamed(VUHDO_CONFIG["CURRENT_PROFILE"]);
	return {
		["NAME"] = aName,
		["LOCKED"] = tProfile ~= nil and tProfile["LOCKED"];
		["ORIGINATOR_CLASS"] = VUHDO_PLAYER_CLASS,
		["ORIGINATOR_TOON"] = VUHDO_PLAYER_NAME,
		["CONFIG"] = VUHDO_deepCopyTable(VUHDO_CONFIG),
		["PANEL_SETUP"] = VUHDO_deepCopyTable(VUHDO_PANEL_SETUP),
		["POWER_TYPE_COLORS"] = VUHDO_deepCopyTable(VUHDO_POWER_TYPE_COLORS),
		["SPELL_CONFIG"] = VUHDO_deepCopyTable(VUHDO_SPELL_CONFIG),
		["BUFF_SETTINGS"] = VUHDO_deepCopyTable(VUHDO_BUFF_SETTINGS),
		["BUFF_ORDER"] = VUHDO_deepCopyTable(VUHDO_BUFF_ORDER),
		["INDICATOR_CONFIG"] = VUHDO_deepCopyTable(VUHDO_INDICATOR_CONFIG),
	};

end



--
local function VUHDO_createNewProfileName(aName)
	local tIdx = 1;
	local tProfile = { };
	local tPrefix = VUHDO_PLAYER_NAME .. ": ";

	while (tProfile ~= nil) do
		tNewName = tPrefix .. aName;
		_, tProfile = VUHDO_getProfileNamed(tNewName);

		tIdx = tIdx + 1;
		tPrefix = VUHDO_PLAYER_NAME .. "(" .. tIdx .. "): ";
	end
	return tNewName;
end



local VUHDO_TARGET_PROFILE_NAME = nil;



--
local function VUHDO_askSaveProfileCallback(aButtonNum)
	if (1 == aButtonNum) then -- Copy
		VUHDO_TARGET_PROFILE_NAME = VUHDO_createNewProfileName(VUHDO_TARGET_PROFILE_NAME);
		VUHDO_CONFIG["CURRENT_PROFILE"] = VUHDO_TARGET_PROFILE_NAME;
	elseif (2 == aButtonNum) then -- Overwrite
	elseif (3 == aButtonNum) then-- Discard
		return;
	end

	local tIndex = VUHDO_getProfileNamed(VUHDO_TARGET_PROFILE_NAME);
	if (tIndex == nil) then
		tIndex = #VUHDO_PROFILES + 1;
	end

	VUHDO_PROFILES[tIndex] = VUHDO_createNewProfile(VUHDO_TARGET_PROFILE_NAME);
	VUHDO_Msg(VUHDO_I18N_PROFILE_SAVED .. "\"" .. VUHDO_TARGET_PROFILE_NAME .. "\"");
	VUHDO_updateProfileSelectCombo();
end



--
function VUHDO_saveProfile(aName)
	local tExistingIndex, tExistingProfile = VUHDO_getProfileNamed(aName);
	if (tExistingProfile ~= nil)  then
		VUHDO_TARGET_PROFILE_NAME = aName;

		if (tExistingProfile["ORIGINATOR_TOON"] ~= VUHDO_PLAYER_NAME and not VUHDO_CONFIG["IS_ALWAYS_OVERWRITE_PROFILE"]) then

			VuhDoThreeSelectFrameText:SetText(
				VUHDO_I18N_PROFILE_OVERWRITE_1 .. " \"" .. aName .. "\" "
				.. VUHDO_I18N_PROFILE_OVERWRITE_2 .. " (" .. tExistingProfile["ORIGINATOR_TOON"] .. ")."
				.. VUHDO_I18N_PROFILE_OVERWRITE_3
			);
			VuhDoThreeSelectFrameButton1:SetText(VUHDO_I18N_COPY);
			VuhDoThreeSelectFrameButton2:SetText(VUHDO_I18N_OVERWRITE);
			VuhDoThreeSelectFrameButton3:SetText(VUHDO_I18N_DISCARD);
			VuhDoThreeSelectFrame:SetAttribute("callback", VUHDO_askSaveProfileCallback);
			VuhDoThreeSelectFrame:Show();
		else
			VUHDO_askSaveProfileCallback(2);
		end
	else
		VUHDO_TARGET_PROFILE_NAME = aName;
		VUHDO_askSaveProfileCallback(2);
	end
end



--
function VUHDO_saveCurrentProfile()
	local _, tProfile = VUHDO_getProfileNamed(VUHDO_CONFIG["CURRENT_PROFILE"]);
	if (tProfile ~= nil and not tProfile["LOCKED"]) then
		VUHDO_saveProfile(VUHDO_CONFIG["CURRENT_PROFILE"]);
	end
end



--
function VUHDO_saveCurrentProfilePanelPosition(aPanelNum)
	local _, tProfile = VUHDO_getProfileNamed(VUHDO_CONFIG["CURRENT_PROFILE"]);
	if (tProfile ~= nil and tProfile["PANEL_SETUP"] ~= nil) then
		tProfile["PANEL_SETUP"][aPanelNum]["POSITION"] = VUHDO_deepCopyTable(VUHDO_PANEL_SETUP[aPanelNum]["POSITION"]);
	end
end



--
local function VUHDO_isProfileRuleAllowed(tRule, aClass, aToon)
	if (VUHDO_PROFILE_MODEL_MATCH_ALL == tRule) then
		return true;
	elseif (VUHDO_PROFILE_MODEL_MATCH_CLASS == tRule) then
		return VUHDO_PLAYER_CLASS == aClass;
	elseif (VUHDO_PROFILE_MODEL_MATCH_TOON == tRule) then
		return VUHDO_PLAYER_NAME == aToon;
	elseif (VUHDO_PROFILE_MODEL_MATCH_NEVER == tRule) then
		return false;
	else
		return true;
	end
end




local VUHDO_PER_PANEL_PROFILE_MODEL = {
	["-root-"] = VUHDO_PROFILE_MODEL_MATCH_ALL,
}




local VUHDO_PROFILE_MODEL = {
	["CONFIG"] = {
		["-root-"] = VUHDO_PROFILE_MODEL_MATCH_ALL,

		["RANGE_SPELL"] = VUHDO_PROFILE_MODEL_MATCH_NEVER,
		["RANGE_PESSIMISTIC"] = VUHDO_PROFILE_MODEL_MATCH_NEVER,
		["CURRENT_PROFILE"] = VUHDO_PROFILE_MODEL_MATCH_NEVER,
		["IS_CLIQUE_COMPAT_MODE"] = VUHDO_PROFILE_MODEL_MATCH_NEVER,
		["AUTO_PROFILES"] = {
			["-root-"] = VUHDO_PROFILE_MODEL_MATCH_NEVER,
		},
		["CLUSTER"] = {
			["-root-"] = VUHDO_PROFILE_MODEL_MATCH_CLASS,
		},
	},

	["PANEL_SETUP"] = {
		["-root-"] = VUHDO_PROFILE_MODEL_MATCH_ALL,

		["HOTS"] = {
			["-root-"] = VUHDO_PROFILE_MODEL_MATCH_ALL,

			["SLOTS"] = {
				["-root-"] = VUHDO_PROFILE_MODEL_MATCH_CLASS,
			},

			["SLOTCFG"] = {
				["-root-"] = VUHDO_PROFILE_MODEL_MATCH_CLASS,
			},
		},

		[1] = VUHDO_PER_PANEL_PROFILE_MODEL,
		[2] = VUHDO_PER_PANEL_PROFILE_MODEL,
		[3] = VUHDO_PER_PANEL_PROFILE_MODEL,
		[4] = VUHDO_PER_PANEL_PROFILE_MODEL,
		[5] = VUHDO_PER_PANEL_PROFILE_MODEL,
		[6] = VUHDO_PER_PANEL_PROFILE_MODEL,
		[7] = VUHDO_PER_PANEL_PROFILE_MODEL,
		[8] = VUHDO_PER_PANEL_PROFILE_MODEL,
		[9] = VUHDO_PER_PANEL_PROFILE_MODEL,
		[10] = VUHDO_PER_PANEL_PROFILE_MODEL,
	},

	["POWER_TYPE_COLORS"] = {
		["-root-"] = VUHDO_PROFILE_MODEL_MATCH_ALL,
	},

	["SPELL_CONFIG"] = {
		["-root-"] = VUHDO_PROFILE_MODEL_MATCH_TOON,
	},

	["BUFF_SETTINGS"] = {
		["-root-"] = VUHDO_PROFILE_MODEL_MATCH_CLASS,

		["CONFIG"] = {
			["-root-"] = VUHDO_PROFILE_MODEL_MATCH_ALL,
		},
	},

	["BUFF_ORDER"] = {
		["-root-"] = VUHDO_PROFILE_MODEL_MATCH_CLASS,
	},

	["INDICATOR_CONFIG"] = {
		["-root-"] = VUHDO_PROFILE_MODEL_MATCH_ALL,
	},
};




--
local tOriginatorClass = nil;
local tOriginatorToon = nil;
local function VUHDO_smartLoadFromProfile(aDestArray, aSourceArray, aProfileModel, aDerivedRule)
	if (aSourceArray == nil) then
		return aDestArray;
	end

	if (aSourceArray["ORIGINATOR_CLASS"] ~= nil) then
		tOriginatorClass = aSourceArray["ORIGINATOR_CLASS"];
	end

	if (aSourceArray["ORIGINATOR_TOON"] ~= nil) then
		tOriginatorToon = aSourceArray["ORIGINATOR_TOON"];
	end

	local tRootRule;
	if (aProfileModel ~= nil) then
		tRootRule = aProfileModel["-root-"];
	else
		tRootRule = nil;
	end

	local tSourceValue;
	local tKey, tDestValue;
	for tKey, tDestValue in pairs(aDestArray) do

		tSourceValue = aSourceArray[tKey];
		if (tSourceValue ~= nil) then
			local tSubModel = (aProfileModel or { })[tKey];

			if ("table" == type(tSourceValue)) then

				if ("table" == type(tDestValue)) then
					aDestArray[tKey] = VUHDO_smartLoadFromProfile(aDestArray[tKey], aSourceArray[tKey], tSubModel, tRootRule or aDerivedRule);
				--else
					--VUHDO_Msg("Data structures incompatible in field: " .. tKey);
				end
			else -- Flacher Wert
				local tRule = tSubModel or tRootRule or aDerivedRule;
				if (VUHDO_isProfileRuleAllowed(tRule, tOriginatorClass, tOriginatorToon)) then
					aDestArray[tKey] = aSourceArray[tKey];
				--else
					--VUHDO_Msg("Prohibit: " .. tKey);
				end
			end
		end
	end

	return aDestArray;
end



--
local function VUHDO_fixDominantProfileSettings(aProfile)
	local tCnt;

	for tCnt = 1, VUHDO_MAX_PANELS do
		if (aProfile["PANEL_SETUP"][tCnt]["MODEL"].groups == nil) then
			VUHDO_PANEL_SETUP[tCnt]["MODEL"].groups = nil;
		else
			VUHDO_PANEL_SETUP[tCnt]["MODEL"].groups = VUHDO_deepCopyTable(aProfile["PANEL_SETUP"][tCnt]["MODEL"].groups);
		end
	end
end



--
function VUHDO_loadProfileNoInit(aName)
	local tIndex, tProfile = VUHDO_getProfileNamed(aName);
	if (tIndex == nil) then
		VUHDO_Msg(VUHDO_I18N_ERROR_NO_PROFILE .. "\"" .. aName .. "\" !", 1, 0.4, 0.4);
		return;
	end

	tOriginatorClass = tProfile["ORIGINATOR_CLASS"];
	tOriginatorToon = tProfile["ORIGINATOR_TOON"];

	VUHDO_CONFIG            = VUHDO_smartLoadFromProfile(VUHDO_CONFIG,            tProfile["CONFIG"],            VUHDO_PROFILE_MODEL["CONFIG"],            VUHDO_PROFILE_MODEL_MATCH_ALL);
	VUHDO_PANEL_SETUP       = VUHDO_smartLoadFromProfile(VUHDO_PANEL_SETUP,       tProfile["PANEL_SETUP"],       VUHDO_PROFILE_MODEL["PANEL_SETUP"],       VUHDO_PROFILE_MODEL_MATCH_ALL);
	VUHDO_POWER_TYPE_COLORS = VUHDO_smartLoadFromProfile(VUHDO_POWER_TYPE_COLORS, tProfile["POWER_TYPE_COLORS"], VUHDO_PROFILE_MODEL["POWER_TYPE_COLORS"], VUHDO_PROFILE_MODEL_MATCH_ALL);
	VUHDO_SPELL_CONFIG      = VUHDO_smartLoadFromProfile(VUHDO_SPELL_CONFIG,      tProfile["SPELL_CONFIG"],      VUHDO_PROFILE_MODEL["SPELL_CONFIG"],      VUHDO_PROFILE_MODEL_MATCH_ALL);
	VUHDO_BUFF_SETTINGS     = VUHDO_smartLoadFromProfile(VUHDO_BUFF_SETTINGS,     tProfile["BUFF_SETTINGS"],     VUHDO_PROFILE_MODEL["BUFF_SETTINGS"],     VUHDO_PROFILE_MODEL_MATCH_ALL);
	VUHDO_BUFF_ORDER        = VUHDO_smartLoadFromProfile(VUHDO_BUFF_ORDER,        tProfile["BUFF_ORDER"],        VUHDO_PROFILE_MODEL["BUFF_ORDER"],        VUHDO_PROFILE_MODEL_MATCH_ALL);
	VUHDO_INDICATOR_CONFIG  = VUHDO_smartLoadFromProfile(VUHDO_INDICATOR_CONFIG,  tProfile["INDICATOR_CONFIG"],  VUHDO_PROFILE_MODEL["INDICATOR_CONFIG"],  VUHDO_PROFILE_MODEL_MATCH_ALL);

	VUHDO_fixDominantProfileSettings(tProfile);
	VUHDO_CONFIG["CURRENT_PROFILE"] = aName;
	VUHDO_Msg(VUHDO_I18N_PROFILE_LOADED .. aName);
end



--
function VUHDO_loadProfile(aName)
	VUHDO_loadProfileNoInit(aName);
	VUHDO_initAllBurstCaches();
	VUHDO_loadVariables();
	VUHDO_initPanelModels();
	VUHDO_initDynamicPanelModels();
	VUHDO_registerAllBouquets();
	VUHDO_initAllEventBouquets();
	VUHDO_initDebuffs();
	VUHDO_reloadUI();
	VUHDO_resetTooltip();
	VUHDO_initBlizzFrames();
	if (VUHDO_initCustomDebuffComboModel ~= nil) then
		VUHDO_initCustomDebuffComboModel();
	end
end



--[[
local Arrangement;
local tProfile;
local tCnt;
local tName;
function VUHDO_importSkinsArrangements()
	VUHDO_SKINS = nil;
	VUHDO_CONFIG["CURRENT_SKIN"] = nil;

	if (VUHDO_ARRANGEMENTS ~= nil) then
		for _, tArrangement in pairs(VUHDO_ARRANGEMENTS) do
			tName = tArrangement["NAME"];
			if (VUHDO_getProfileNamed(tName) == nil) then
				tProfile = {
					["NAME"] = tName,
					["ORIGINATOR_CLASS"] = -1,
					["ORIGINATOR_TOON"] = "*ImportBot*",
					["PANEL_SETUP"] = { },
					["BUFF_SETTINGS"] = { }
				};

				for tCnt = 1, VUHDO_MAX_PANELS do
					tProfile["PANEL_SETUP"][tCnt] = VUHDO_deepCopyTable(tArrangement["DATA"][tCnt]);
				end

				tProfile["BUFF_SETTINGS"]["CONFIG"] = VUHDO_deepCopyTable(tArrangement["DATA"]["BUFF_CONFIG"]);
				tinsert(VUHDO_PROFILES, tProfile);
				--VUHDO_Msg("Profile import: " .. tName);
			end
		end
		if (VUHDO_CONFIG["AUTO_ARRANGEMENTS"] ~= nil) then
			VUHDO_CONFIG["AUTO_PROFILES"] = VUHDO_deepCopyTable(VUHDO_CONFIG["AUTO_ARRANGEMENTS"]);
			VUHDO_CONFIG["AUTO_ARRANGEMENTS"] = nil;
		end

		VUHDO_ARRANGEMENTS = nil;
		VUHDO_CONFIG["CURRENT_ARRANGEMENT"] = nil
	end
end
--]]
