
VUHDO_INTERNAL_TOGGLES = { };
local VUHDO_INTERNAL_TOGGLES = VUHDO_INTERNAL_TOGGLES;

local VUHDO_DEBUFF_ANIMATION = 0;

local VUHDO_EVENT_COUNT = 0;
local VUHDO_LAST_TIME_NO_EVENT = GetTime();

-- BURST CACHE ---------------------------------------------------

local VUHDO_RAID;
local VUHDO_PANEL_SETUP;
VUHDO_RELOAD_UI_IS_LNF= false;

local VUHDO_parseAddonMessage;
local VUHDO_spellcastStop;
local VUHDO_spellcastFailed;
local VUHDO_spellcastSucceeded;
local VUHDO_spellcastSent;
local VUHDO_parseCombatLogEvent;
local VUHDO_updateAllOutRaidTargetButtons;
local VUHDO_updateAllRaidTargetIndices;
local VUHDO_updateDirectionFrame;

local VUHDO_updateHealth;
local VUHDO_updateManaBars;
local VUHDO_updateTargetBars;
local VUHDO_updateAllRaidBars;
local VUHDO_updateHealthBarsFor;
local VUHDO_updateAllHoTs;
local VUHDO_updateAllCyclicBouquets;
local VUHDO_updateAllDebuffIcons;
local VUHDO_updateAllClusters;
local VUHDO_clearObsoleteInc;
local VUHDO_updateBouquetsForEvent;
local VUHDO_getUnitZoneName;
local VUHDO_updateClusterHighlights;

local GetTime = GetTime;
local CheckInteractDistance = CheckInteractDistance;
local UnitInRange = UnitInRange;
local IsSpellInRange = IsSpellInRange;
local UnitDetailedThreatSituation = UnitDetailedThreatSituation;
local UnitIsCharmed = UnitIsCharmed;
local UnitCanAttack = UnitCanAttack;
local UnitName = UnitName;
local UnitIsEnemy = UnitIsEnemy;
local GetSpellCooldown = GetSpellCooldown;
local HasFullControl = HasFullControl;
local pairs = pairs;
local UnitThreatSituation = UnitThreatSituation;
local InCombatLockdown = InCombatLockdown;
local sRangeSpell, sIsRangeKnown, sIsHealerMode;
local sIsDirectionArrow = false;

local VuhDoGcdStatusBar;

local function VUHDO_eventHandlerInitBurst()
	VUHDO_RAID = VUHDO_GLOBAL["VUHDO_RAID"];
	VUHDO_PANEL_SETUP = VUHDO_GLOBAL["VUHDO_PANEL_SETUP"];

	VUHDO_updateHealth = VUHDO_GLOBAL["VUHDO_updateHealth"];
	VUHDO_updateManaBars = VUHDO_GLOBAL["VUHDO_updateManaBars"];
	VUHDO_updateTargetBars = VUHDO_GLOBAL["VUHDO_updateTargetBars"];
	VUHDO_updateAllRaidBars = VUHDO_GLOBAL["VUHDO_updateAllRaidBars"];
	VUHDO_updateAllOutRaidTargetButtons = VUHDO_GLOBAL["VUHDO_updateAllOutRaidTargetButtons"];
	VUHDO_parseAddonMessage = VUHDO_GLOBAL["VUHDO_parseAddonMessage"];
	VUHDO_spellcastStop = VUHDO_GLOBAL["VUHDO_spellcastStop"];
	VUHDO_spellcastFailed = VUHDO_GLOBAL["VUHDO_spellcastFailed"];
	VUHDO_spellcastSucceeded = VUHDO_GLOBAL["VUHDO_spellcastSucceeded"];
	VUHDO_spellcastSent = VUHDO_GLOBAL["VUHDO_spellcastSent"];
	VUHDO_parseCombatLogEvent = VUHDO_GLOBAL["VUHDO_parseCombatLogEvent"];
	VUHDO_updateHealthBarsFor = VUHDO_GLOBAL["VUHDO_updateHealthBarsFor"];
	VUHDO_updateAllHoTs = VUHDO_GLOBAL["VUHDO_updateAllHoTs"];
	VUHDO_updateAllCyclicBouquets = VUHDO_GLOBAL["VUHDO_updateAllCyclicBouquets"];
	VUHDO_updateAllDebuffIcons = VUHDO_GLOBAL["VUHDO_updateAllDebuffIcons"];
	VUHDO_clearObsoleteInc = VUHDO_GLOBAL["VUHDO_clearObsoleteInc"];
	VUHDO_updateAllRaidTargetIndices = VUHDO_GLOBAL["VUHDO_updateAllRaidTargetIndices"];
	VUHDO_updateAllClusters = VUHDO_GLOBAL["VUHDO_updateAllClusters"];
	VUHDO_updateBouquetsForEvent = VUHDO_GLOBAL["VUHDO_updateBouquetsForEvent"];
	VuhDoGcdStatusBar = VUHDO_GLOBAL["VuhDoGcdStatusBar"];
	VUHDO_updateDirectionFrame = VUHDO_GLOBAL["VUHDO_updateDirectionFrame"];
	VUHDO_getUnitZoneName = VUHDO_GLOBAL["VUHDO_getUnitZoneName"];
  VUHDO_updateClusterHighlights = VUHDO_GLOBAL["VUHDO_updateClusterHighlights"];

	sRangeSpell = VUHDO_CONFIG["RANGE_SPELL"] or "*foo*";
	sIsHealerMode = not VUHDO_CONFIG["THREAT"]["IS_TANK_MODE"];
	sIsRangeKnown = not VUHDO_CONFIG["RANGE_PESSIMISTIC"] and GetSpellInfo(sRangeSpell) ~= nil;
	sIsDirectionArrow = VUHDO_CONFIG["DIRECTION"]["enable"];
end

----------------------------------------------------

local VUHDO_VARIABLES_LOADED = false;
local VUHDO_IS_RELOAD_BUFFS = false;
local VUHDO_LOST_CONTROL = false;
local VUHDO_RELOAD_AFTER_BATTLE = false;
local VUHDO_GCD_UPDATE = false;

local VUHDO_RELOAD_PANEL_NUM = nil;
local VUHDO_REFRESH_TOOLTIP_DELAY = 2.3;


VUHDO_TIMERS = {
	["RELOAD_UI"] = 0,
	["RELOAD_PANEL"] = 0,
	["CUSTOMIZE"] = 0,
	["CHECK_PROFILES"] = 6.2,
	["RELOAD_ZONES"] = 2.4,
	["UPDATE_CLUSTERS"] = 0,
	["REFRESH_INSPECT"] = 2.1,
	["REFRESH_TOOLTIP"] = VUHDO_REFRESH_TOOLTIP_DELAY,
	["UPDATE_AGGRO"] = 0,
	["UPDATE_RANGE"] = 1,
	["UPDATE_HOTS"] = 0.25,
	["REFRESH_TARGETS"] = 0.51,
	["RELOAD_RAID"] = 0,
	["RELOAD_ROSTER"] = 0,
	["REFRESH_DRAG"] = 0.05,
	["MIRROR_TO_MACRO"] = 8,
};
local VUHDO_TIMERS = VUHDO_TIMERS;


local tUnit, tInfo;


VUHDO_CONFIG = nil;
VUHDO_PANEL_SETUP = nil;
VUHDO_SPELL_ASSIGNMENTS = nil;
VUHDO_SPELLS_KEYBOARD = nil;
VUHDO_SPELL_CONFIG = nil;

VUHDO_IS_RELOADING = false;
VUHDO_FONTS = { };
VUHDO_STATUS_BARS = { };
VUHDO_SOUNDS = { };
VUHDO_BORDERS = { };
VUHDO_LAST_AUTO_ARRANG = nil;


VUHDO_MAINTANK_NAMES = { };
VUHDO_RESSING_NAMES = { };
local VUHDO_FIRST_RELOAD_UI = false;


--
function VUHDO_isVariablesLoaded()
	return VUHDO_VARIABLES_LOADED;
end



--
function VUHDO_setTooltipDelay(aSecs)
	VUHDO_REFRESH_TOOLTIP_DELAY = aSecs;
end



--
local VUHDO_INSTANCE = nil;
function VUHDO_OnLoad(anInstance)
	VUHDO_INSTANCE = anInstance;
	anInstance:RegisterEvent("VARIABLES_LOADED");
	anInstance:RegisterEvent("PLAYER_ENTERING_WORLD");
	anInstance:RegisterEvent("UNIT_HEALTH");
	anInstance:RegisterEvent("UNIT_MAXHEALTH");
	anInstance:RegisterEvent("UNIT_AURA");
	anInstance:RegisterEvent("UNIT_TARGET");

	anInstance:RegisterEvent("PLAYER_REGEN_ENABLED");
	anInstance:RegisterEvent("RAID_ROSTER_UPDATE");
	anInstance:RegisterEvent("PARTY_MEMBERS_CHANGED");
	anInstance:RegisterEvent("UNIT_PET");
	anInstance:RegisterEvent("UNIT_ENTERED_VEHICLE");
	anInstance:RegisterEvent("UNIT_EXITED_VEHICLE");
	anInstance:RegisterEvent("UNIT_EXITING_VEHICLE");
	anInstance:RegisterEvent("CHAT_MSG_ADDON");
	anInstance:RegisterEvent("RAID_TARGET_UPDATE");
	anInstance:RegisterEvent("LEARNED_SPELL_IN_TAB");
	anInstance:RegisterEvent("PLAYER_FLAGS_CHANGED");

	anInstance:RegisterEvent("UNIT_DISPLAYPOWER");

	anInstance:RegisterEvent("UNIT_MAXMANA");
	anInstance:RegisterEvent("UNIT_MAXENERGY");
	anInstance:RegisterEvent("UNIT_MAXRAGE");
	anInstance:RegisterEvent("UNIT_MAXRUNIC_POWER");

	anInstance:RegisterEvent("UNIT_MANA");
	anInstance:RegisterEvent("UNIT_ENERGY");
	anInstance:RegisterEvent("UNIT_RAGE");
	anInstance:RegisterEvent("UNIT_RUNIC_POWER");

	anInstance:RegisterEvent("UNIT_SPELLCAST_STOP");
	anInstance:RegisterEvent("UNIT_SPELLCAST_FAILED");
	anInstance:RegisterEvent("UNIT_SPELLCAST_SENT");
	anInstance:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
	anInstance:RegisterEvent("PARTY_MEMBER_ENABLE");
	anInstance:RegisterEvent("PARTY_MEMBER_DISABLE");
	anInstance:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
	anInstance:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE");
	anInstance:RegisterEvent("UPDATE_BINDINGS");
	anInstance:RegisterEvent("PLAYER_TARGET_CHANGED");
	anInstance:RegisterEvent("PLAYER_FOCUS_CHANGED");

	anInstance:RegisterEvent("READY_CHECK");
	anInstance:RegisterEvent("READY_CHECK_CONFIRM");
	anInstance:RegisterEvent("READY_CHECK_FINISHED");
	anInstance:RegisterEvent("CVAR_UPDATE");
	anInstance:RegisterEvent("INSPECT_TALENT_READY");

	anInstance:RegisterEvent("MODIFIER_STATE_CHANGED");

	SLASH_VUHDO1 = "/vuhdo";
	SLASH_VUHDO2 = "/vd";
	SlashCmdList["VUHDO"] = function(aMessage)
		VUHDO_slashCmd(aMessage);
	end

	VUHDO_Msg("VuhDo |cffffe566['vu:du:]|r v".. VUHDO_VERSION .. ". by Iza(ak)@Gilneas, dedicated to Vuh (use /vd)");
end



--
function VUHDO_initBuffs()
	VUHDO_initBuffsFromSpellBook();
	VUHDO_reloadBuffPanel();
	VUHDO_resetHotBuffCache();
end



--
function VUHDO_initTooltipTimer()
	VUHDO_TIMERS["REFRESH_TOOLTIP"] = VUHDO_REFRESH_TOOLTIP_DELAY;
end



--
-- 3 = Tanking, all others less 100%
-- 2 = Tanking, others > 100%
-- 1 = Not Tanking, more than 100%
-- 0 = Not Tanking, less than 100%
local tInfo, tIsAggroed;
local function VUHDO_updateThreat(aUnit)
	if (not VUHDO_VARIABLES_LOADED or VUHDO_RAID == nil) then
		return;
	end

	tInfo = VUHDO_RAID[aUnit];
	if (tInfo ~= nil) then
		tInfo["threat"] = UnitThreatSituation(aUnit);
		VUHDO_updateBouquetsForEvent(aUnit, 17); -- VUHDO_UPDATE_THREAT_LEVEL

		tIsAggroed = VUHDO_INTERNAL_TOGGLES[7] and (tInfo["threat"] or 0) >= 2; -- VUHDO_UPDATE_AGGRO

		if (tIsAggroed ~= tInfo["aggro"]) then
			tInfo["aggro"] = tIsAggroed;
			VUHDO_updateHealthBarsFor(aUnit, 7); -- VUHDO_UPDATE_AGGRO
		end
	end
end



--
function VUHDO_initAllBurstCaches()
	VUHDO_toolboxInitBurst();
  VUHDO_guiToolboxInitBurst();
	VUHDO_vuhdoInitBurst();
	VUHDO_spellEventHandlerInitBurst();
	VUHDO_macroFactoryInitBurst();
	VUHDO_keySetupInitBurst();
	VUHDO_combatLogInitBurst();
	VUHDO_eventHandlerInitBurst();
	VUHDO_customHealthInitBurst();
	VUHDO_customManaInitBurst();
	VUHDO_customTargetInitBurst();
	VUHDO_customClustersInitBurst();
	VUHDO_panelInitBurst();
	VUHDO_panelRedrawInitBurst();
	VUHDO_panelRefreshInitBurst();
	VUHDO_roleCheckerInitBurst();
	VUHDO_sizeCalculatorInitBurst();
	VUHDO_customHotsInitBurst();
	VUHDO_customDebuffIconsInitBurst();
	VUHDO_debuffsInitBurst();
	VUHDO_healCommAdapterInitBurst();
	VUHDO_buffWatchInitBurst();
	VUHDO_clusterBuilderInitBurst();
	VUHDO_bouquetValidatorsInitBurst();
	VUHDO_bouquetsInitBurst();
	VUHDO_actionEventHandlerInitBurst();
	VUHDO_directionsInitBurst();
	VUHDO_dcShieldInitBurst();
end



--
local function VUHDO_initOptions()
	if (VuhDoNewOptionsTabbedFrame ~= nil) then
		VUHDO_initHotComboModels();
		VUHDO_initHotBarComboModels();
		VUHDO_initDebuffIgnoreComboModel();
		VUHDO_initBouquetComboModel();
		VUHDO_initBouquetSlotsComboModel();
		VUHDO_initProfileTableModels();
		VUHDO_bouquetsUpdateDefaultColors();
	end
end



--
local function VUHDO_loadDefaultProfile()
	local tName, tExistIndex, tProfile;

	if (VUHDO_CONFIG == nil) then
		return;
	end

	tName = VUHDO_CONFIG["CURRENT_PROFILE"];
	if (tName ~= nil and tName ~= "") then

		tExistIndex, tProfile = VUHDO_getProfileNamed(tName);

		if (tExistIndex ~= nil) then
			if (tProfile ~= nil and tProfile["LOCKED"]) then -- Nicht laden, Einstellungen wurden ja auch nicht automat. gespeichert
				VUHDO_Msg("Profile " .. tProfile["NAME"] .. " is currently locked and has NOT been loaded on startup.");
				return;
			end

			VUHDO_loadProfileNoInit(tName);
		end
	end
end



--
local tLevel = 0;
local function VUHDO_init()
	if (tLevel == 0 or VUHDO_VARIABLES_LOADED) then
		tLevel = 1;
		return;
	end

	if (VUHDO_RAID == nil) then
		VUHDO_RAID = { };
	end

	VUHDO_initFastCache();
	VUHDO_loadDefaultProfile(); -- 1. Diese Reihenfolge scheint wichtig zu sein, erzeugt
	VUHDO_loadVariables(); -- 2. umgekehrt undefiniertes Verhalten (VUHDO_CONFIG ist nil etc.)
	VUHDO_initAllBurstCaches();
	VUHDO_VARIABLES_LOADED = true;

	VUHDO_initPanelModels();
	VUHDO_initFromSpellbook();
	VUHDO_initBuffs();
	VUHDO_initDebuffs();
	VUHDO_clearUndefinedModelEntries();
	VUHDO_reloadUI();
	VUHDO_getAutoProfile();
	VUHDO_setLhcEnabled();
	VUHDO_setShieldCommEnabled();
	VUHDO_initCliqueSupport(false);
	if (VuhDoNewOptionsTabbedFrame ~= nil) then
		VuhDoNewOptionsTabbedFrame:ClearAllPoints();
		VuhDoNewOptionsTabbedFrame:SetPoint("CENTER",  "UIParent", "CENTER",  0,  0);
	end

	VUHDO_registerAllBouquets();
	VUHDO_initSharedMedia();
	VUHDO_initFuBar();
	VUHDO_initHideBlizzFrames();
	if (not InCombatLockdown()) then
		VUHDO_initKeyboardMacros();
	end
	VUHDO_timeReloadUI(3);
end



--VUHDO_EVENT_TIMES = { };
--
local tUnit;
local tEmptyRaid = { };
function VUHDO_OnEvent(anInstance, anEvent, anArg1, anArg2, anArg3, anArg4, _, anArg6, _, _, anArg9, anArg10, _, anArg12)

--	if (VUHDO_EVENT_TIMES["all"] == nil) then
--		VUHDO_EVENT_TIMES["all"] = 0;
--	end
--	if (VUHDO_EVENT_TIMES[anEvent] == nil) then
--		VUHDO_EVENT_TIMES[anEvent] = { 0, 0, 0, 0, 0, 0 };
--	end
--	local tDuration = GetTime();

	VUHDO_EVENT_COUNT = VUHDO_EVENT_COUNT + 1;

	if ("COMBAT_LOG_EVENT_UNFILTERED" == anEvent) then
		if (VUHDO_VARIABLES_LOADED) then
			VUHDO_parseCombatLogEvent(anArg2, anArg6, anArg9, anArg10, anArg12);
		end
	elseif ("UNIT_AURA" == anEvent) then
		if ((VUHDO_RAID or tEmptyRaid)[anArg1] ~= nil) then
			VUHDO_updateHealth(anArg1, 4); -- VUHDO_UPDATE_DEBUFF
		end
	elseif ("UNIT_HEALTH" == anEvent) then
		if ((VUHDO_RAID or tEmptyRaid)[anArg1] ~= nil) then
			VUHDO_updateHealth(anArg1, 2); -- VUHDO_UPDATE_HEALTH
		end
	elseif ("UNIT_MANA" == anEvent
		or "UNIT_ENERGY" == anEvent
		or "UNIT_RAGE" == anEvent
		or "UNIT_RUNIC_POWER" == anEvent) then
		if ((VUHDO_RAID or tEmptyRaid)[anArg1] ~= nil) then
			VUHDO_updateManaBars(anArg1, 1);
		end
	elseif ("UNIT_SPELLCAST_SUCCEEDED" == anEvent) then
		if ((VUHDO_RAID or tEmptyRaid)[anArg1] ~= nil) then
			VUHDO_spellcastSucceeded(anArg1, anArg2);
		end
	elseif ("UNIT_SPELLCAST_STOP" == anEvent) then
		if (VUHDO_VARIABLES_LOADED) then
			VUHDO_spellcastStop(anArg1);
		end
	elseif ("UNIT_SPELLCAST_FAILED" == anEvent) then
		if (VUHDO_VARIABLES_LOADED) then
			VUHDO_spellcastFailed(anArg1);
		end
	elseif ("UNIT_SPELLCAST_SENT" == anEvent) then
		if (VUHDO_VARIABLES_LOADED) then
			VUHDO_spellcastSent(anArg1, anArg2, anArg3, anArg4);
		end
	elseif ("UNIT_THREAT_SITUATION_UPDATE" == anEvent) then
		VUHDO_updateThreat(anArg1);

	elseif ("UNIT_MAXHEALTH" == anEvent) then
		if ((VUHDO_RAID or tEmptyRaid)[anArg1] ~= nil) then
			VUHDO_updateHealth(anArg1, VUHDO_UPDATE_HEALTH_MAX);
		end

	elseif ("UNIT_TARGET" == anEvent) then
		if (VUHDO_VARIABLES_LOADED) then
			VUHDO_updateTargetBars(anArg1);
			if ("player" == anArg1) then
				VUHDO_updateTargetBars("target");
			end
		end

	elseif ("UNIT_DISPLAYPOWER" == anEvent) then
		if ((VUHDO_RAID or tEmptyRaid)[anArg1] ~= nil) then
			VUHDO_updateManaBars(anArg1, 3);
		end
	elseif ("UNIT_MAXMANA" == anEvent
		or "UNIT_MAXENERGY" == anEvent
		or "UNIT_MAXRAGE" == anEvent
		or "UNIT_MAXRUNIC_POWER" == anEvent) then
		if ((VUHDO_RAID or tEmptyRaid)[anArg1] ~= nil) then
			VUHDO_updateManaBars(anArg1, 2);
		end

	elseif ("UNIT_PET" == anEvent) then
		if (VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_PETS] or not InCombatLockdown()) then
			VUHDO_REMOVE_HOTS = false;
			VUHDO_normalRaidReload();
		end

	elseif ("UNIT_ENTERED_VEHICLE" == anEvent
		or "UNIT_EXITED_VEHICLE" == anEvent
		or "UNIT_EXITING_VEHICLE" == anEvent ) then
		VUHDO_REMOVE_HOTS = false;
		VUHDO_normalRaidReload();
	elseif ("RAID_TARGET_UPDATE" == anEvent) then
		VUHDO_TIMERS["CUSTOMIZE"] = 0.1;
	elseif ("PLAYER_REGEN_ENABLED" == anEvent) then
		if (not VUHDO_isReloadPending()) then
			VUHDO_quickRaidReload();
		end
	elseif ("PARTY_MEMBERS_CHANGED" == anEvent
			 or "RAID_ROSTER_UPDATE" == anEvent) then
		if (VUHDO_FIRST_RELOAD_UI) then
			VUHDO_normalRaidReload(true);
			if (VUHDO_TIMERS["RELOAD_ROSTER"] < 0.2) then
				VUHDO_TIMERS["RELOAD_ROSTER"] = 0.3;
			end
		end
	elseif ("PLAYER_FOCUS_CHANGED" == anEvent) then
		VUHDO_quickRaidReload();
		VUHDO_clParserSetCurrentFocus();
	elseif ("PARTY_MEMBER_ENABLE" == anEvent
			 or "PARTY_MEMBER_DISABLE" == anEvent) then
		VUHDO_TIMERS["CUSTOMIZE"] = 0.2;
	elseif ("PLAYER_FLAGS_CHANGED" == anEvent) then
		if ((VUHDO_RAID or tEmptyRaid)[anArg1] ~= nil) then
			VUHDO_updateHealth(anArg1, VUHDO_UPDATE_AFK);
			VUHDO_updateBouquetsForEvent(anArg1, VUHDO_UPDATE_AFK);
		end
	elseif ("PLAYER_ENTERING_WORLD" == anEvent) then
		VUHDO_init();

	elseif ("LEARNED_SPELL_IN_TAB" == anEvent) then
		VUHDO_initFromSpellbook();
		VUHDO_registerAllBouquets();
		VUHDO_initBuffs();
		VUHDO_initDebuffs();

	elseif ("VARIABLES_LOADED" == anEvent) then
		VUHDO_init();

	elseif ("UPDATE_BINDINGS" == anEvent) then
		if (not InCombatLockdown() and VUHDO_VARIABLES_LOADED) then
			VUHDO_initKeyboardMacros();
		end
	elseif ("PLAYER_TARGET_CHANGED" == anEvent) then
		VUHDO_updatePlayerTarget();
	elseif ("CHAT_MSG_ADDON" == anEvent) then
		if (VUHDO_VARIABLES_LOADED) then
			VUHDO_parseAddonMessage(anArg1, anArg2, anArg3, anArg4);
		end
	elseif ("READY_CHECK" == anEvent) then
		if (VUHDO_RAID ~= nil) then
			local tRank, _ = VUHDO_getPlayerRank();
			if (tRank >= 1) then
				VUHDO_readyStartCheck(anArg1, anArg2);
			end
		end
	elseif ("READY_CHECK_CONFIRM" == anEvent) then
		if (VUHDO_RAID ~= nil) then
			local tRank, _ = VUHDO_getPlayerRank();
			if (tRank >= 1) then
				VUHDO_readyCheckConfirm(anArg1, anArg2);
			end
		end
	elseif ("READY_CHECK_FINISHED" == anEvent) then
		if (VUHDO_RAID ~= nil) then
			local tRank, _ = VUHDO_getPlayerRank();
			if (tRank >= 1) then
				VUHDO_readyCheckEnds();
			end
		end
	elseif("CVAR_UPDATE" == anEvent) then
		VUHDO_IS_SFX_ENABLED = tonumber(GetCVar("Sound_EnableSFX")) == 1;
		if (VUHDO_VARIABLES_LOADED) then
			VUHDO_reloadUI();
		end
	elseif("INSPECT_TALENT_READY" == anEvent) then
		VUHDO_inspectLockRole();
	elseif("MODIFIER_STATE_CHANGED" == anEvent) then
		if (VuhDoTooltip:IsShown()) then
			VUHDO_updateTooltip();
		end
	else
		VUHDO_Msg("Error: Unexpected event: " .. anEvent, 1, 0.4, 0.4);
	end

	VUHDO_EVENT_COUNT = VUHDO_EVENT_COUNT - 1;

	if (VUHDO_EVENT_COUNT < 0) then
		VUHDO_EVENT_COUNT = 0;
	end

	if (VUHDO_EVENT_COUNT == 0) then
		VUHDO_LAST_TIME_NO_EVENT = GetTime();
	end

--	tDuration = GetTime() - tDuration;
--	if (tDuration > VUHDO_EVENT_TIMES[anEvent][1]) then
--		VUHDO_EVENT_TIMES[anEvent][1] = tDuration;
--	end
--	VUHDO_EVENT_TIMES[anEvent][2] = VUHDO_EVENT_TIMES[anEvent][2] + tDuration;
--	VUHDO_EVENT_TIMES[anEvent][3] = VUHDO_EVENT_TIMES[anEvent][3] + 1;
--	VUHDO_EVENT_TIMES["all"] = VUHDO_EVENT_TIMES["all"] + tDuration;
end



--
function VUHDO_slashCmd(aCommand)
	local tParsedTexts = VUHDO_textParse(aCommand);
	local tCommandWord = strlower(tParsedTexts[1]);

	if (strfind(tCommandWord, "opt")) then
		if (VuhDoNewOptionsTabbedFrame ~= nil) then
			if (InCombatLockdown() and not VuhDoNewOptionsTabbedFrame:IsShown()) then
				VUHDO_Msg("Leave combat first!", 1, 0.4, 0.4);
			else
				VUHDO_toggleMenu(VuhDoNewOptionsTabbedFrame);
			end
		else
			VUHDO_Msg(VUHDO_I18N_OPTIONS_NOT_LOADED, 1, 0.4, 0.4);
		end
	elseif (tCommandWord == "load" and tParsedTexts[2] ~= nil) then
		local tTokens = VUHDO_splitString(tParsedTexts[2], ",");

		if (#tTokens >= 2 and strlen(strtrim(tTokens[2])) > 0) then
			local tName = strtrim(tTokens[2]);
			if (VUHDO_SPELL_LAYOUTS[tName] ~= nil) then
				VUHDO_activateLayout(tName);
			else
				VUHDO_Msg(VUHDO_I18N_SPELL_LAYOUT_NOT_EXIST_1 .. tName .. VUHDO_I18N_SPELL_LAYOUT_NOT_EXIST_2, 1, 0.4, 0.4);
			end
		end
		if (#tTokens >= 1 and strlen(strtrim(tTokens[1])) > 0) then
			VUHDO_loadProfile(strtrim(tTokens[1]));
		end
	elseif (strfind(tCommandWord, "res")) then
		local tPanelNum;
		for tPanelNum = 1, VUHDO_MAX_PANELS do
			VUHDO_PANEL_SETUP[tPanelNum]["POSITION"] = nil;
		end
		VUHDO_BUFF_SETTINGS["CONFIG"]["POSITION"] = {
			["x"] = 100,
			["y"] = -100,
			["point"] = "TOPLEFT",
			["relativePoint"] = "TOPLEFT",
		};
		VUHDO_loadDefaultPanelSetup();
		VUHDO_reloadUI();
		VUHDO_Msg(VUHDO_I18N_PANELS_RESET);

	elseif (tCommandWord == "lock") then
		VUHDO_CONFIG["LOCK_PANELS"] = not VUHDO_CONFIG["LOCK_PANELS"];
		local tMessage = VUHDO_I18N_LOCK_PANELS_PRE;
		if (VUHDO_CONFIG["LOCK_PANELS"]) then
			tMessage = tMessage .. VUHDO_I18N_LOCK_PANELS_LOCKED;
		else
			tMessage = tMessage .. VUHDO_I18N_LOCK_PANELS_UNLOCKED;
		end
		VUHDO_Msg(tMessage);
		VUHDO_saveCurrentProfile();

	elseif (tCommandWord == "show") then
		VUHDO_CONFIG["SHOW_PANELS"] = true;
		VUHDO_redrawAllPanels();
		VUHDO_Msg(VUHDO_I18N_PANELS_SHOWN);
		VUHDO_saveCurrentProfile();

	elseif (tCommandWord == "hide") then
		VUHDO_CONFIG["SHOW_PANELS"] = false;
		VUHDO_redrawAllPanels();
		VUHDO_Msg(VUHDO_I18N_PANELS_HIDDEN);
		VUHDO_saveCurrentProfile();

	elseif (tCommandWord == "toggle") then
		VUHDO_CONFIG["SHOW_PANELS"] = not VUHDO_CONFIG["SHOW_PANELS"];
		if (VUHDO_CONFIG["SHOW_PANELS"]) then
			VUHDO_Msg(VUHDO_I18N_PANELS_SHOWN);
		else
			VUHDO_Msg(VUHDO_I18N_PANELS_HIDDEN);
		end
		VUHDO_redrawAllPanels();
		VUHDO_saveCurrentProfile();

	elseif (strfind(tCommandWord, "cast") or strfind(tCommandWord, "mt")) then
		VUHDO_ctraBroadCastMaintanks();
		VUHDO_Msg(VUHDO_I18N_MTS_BROADCASTED);

	elseif (tCommandWord == "pron") then
		SetCVar("scriptProfile", "1");
		ReloadUI();
	elseif (tCommandWord == "proff") then
		SetCVar("scriptProfile", "0");
		ReloadUI();
--	elseif (strfind(tCommandWord, "fupro")) then
--		local tData, tFName;
--		table.wipe(FunctionProfiler_Settings["watched"]);
--		for tFName, tData in pairs(VUHDO_GLOBAL) do
--			if (strsub(tFName, 1, 5) == "VUHDO") then
--				if (type(tData) == "function") then
--					table.insert(FunctionProfiler_Settings["watched"], tFName);
--				end
--			elseif(strsub(tFName, 1, 4) == "t") then
--				VUHDO_Msg("Emerging local variable " .. tFName);
--			end
--		end
--	elseif (strfind(tCommandWord, "chkvars")) then
--		for tFName, tData in pairs(VUHDO_GLOBAL) do
--			if(strsub(tFName, 1, 1) == "t") then
--				VUHDO_Msg("Emerging local variable " .. tFName);
--			end
--		end

	elseif (strfind(tCommandWord, "mm")
		or strfind(tCommandWord, "map")) then

		VUHDO_CONFIG["SHOW_MINIMAP"] = not VUHDO_CONFIG["SHOW_MINIMAP"];
		VUHDO_initShowMinimap();
		local tMessage = VUHDO_I18N_MM_ICON;
		if (VUHDO_CONFIG["SHOW_MINIMAP"]) then
			tMessage = tMessage .. VUHDO_I18N_CHAT_SHOWN;
		else
			tMessage = tMessage .. VUHDO_I18N_CHAT_HIDDEN;
		end

		VUHDO_Msg(tMessage);
		VUHDO_saveCurrentProfile();

	elseif (tCommandWord == "ui") then
	  VUHDO_reloadUI();
	elseif (tCommandWord == "rui") then
	  VUHDO_refreshUI();
	elseif (strfind(tCommandWord, "role")) then
		VUHDO_Msg("Player roles have been reset.");
		VUHDO_resetTalentScan();
		VUHDO_reloadUI();
--	elseif (strfind(tCommandWord, "cluster")) then
--		VUHDO_Msg("Map dimensions for cluster builder have been reset.");
--		table.wipe(VUHDO_STORED_ZONES);
--	elseif (strfind(tCommandWord, "debug")) then
		--VUHDO_DEBUG_AUTO_ARRANG = tonumber(tParsedTexts[2]);
--	elseif (strfind(tCommandWord, "bench")) then
		--VUHDO_sendPallyPowerRequest();
	  --elseif (strfind(tCommandWord, "test")) then
		--VUHDO_EVENT_TIMES = { };
--		local tCnt;
--		VUHDO_initProfiler();
--		for tCnt = 1, 1000 do
--			VUHDO_refreshUI();
--		end
--		VUHDO_seeProfiler();
	elseif (aCommand == "?"
		or strfind(tCommandWord, "help")
		or aCommand == "") then
		local tLines = VUHDO_splitString(VUHDO_I18N_COMMAND_LIST, "§");
		local tCurLine;
		for _, tCurLine in ipairs(tLines) do
			VUHDO_MsgC(tCurLine);
		end
	else
		VUHDO_Msg(VUHDO_I18N_BAD_COMMAND, 1, 0.4, 0.4);
	end
end



--
function VUHDO_updateGlobalToggles()
	if (VUHDO_INSTANCE == nil) then
		return;
	end

	if (VUHDO_isAnyoneInterstedIn(VUHDO_UPDATE_THREAT_LEVEL) or VUHDO_isAnyoneInterstedIn(VUHDO_UPDATE_AGGRO)) then
		VUHDO_INSTANCE:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE");
	else
		VUHDO_INSTANCE:UnregisterEvent("UNIT_THREAT_SITUATION_UPDATE");
	end

	if (VUHDO_isAnyoneInterstedIn(VUHDO_UPDATE_THREAT_PERC)) then
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_THREAT_PERC] = true;
	else
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_THREAT_PERC] = false;
	end

	if (VUHDO_isAnyoneInterstedIn(VUHDO_UPDATE_AGGRO)) then
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_AGGRO] = true;
	else
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_AGGRO] = false;
	end

	if (not VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_THREAT_PERC] and not VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_AGGRO]) then
		VUHDO_TIMERS["UPDATE_AGGRO"] = -1;
	else
		VUHDO_TIMERS["UPDATE_AGGRO"] = 1;
	end

	if (VUHDO_isAnyoneInterstedIn(VUHDO_UPDATE_RANGE)) then
		VUHDO_TIMERS["UPDATE_RANGE"] = 1;
	else
		VUHDO_TIMERS["UPDATE_RANGE"] = -1;
	end



	if (VUHDO_isAnyoneInterstedIn(VUHDO_UPDATE_NUM_CLUSTER)) then
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_NUM_CLUSTER] = true;
	else
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_NUM_CLUSTER] = false;
	end

	if (VUHDO_isAnyoneInterstedIn(VUHDO_UPDATE_MOUSEOVER_CLUSTER)) then
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_MOUSEOVER_CLUSTER] = true;
	else
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_MOUSEOVER_CLUSTER] = false;
	end

	if (VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_NUM_CLUSTER]
	 or VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_MOUSEOVER_CLUSTER]
	 or (VUHDO_CONFIG["DIRECTION"]["enable"] and VUHDO_CONFIG["DIRECTION"]["isDistanceText"])) then
		VUHDO_TIMERS["UPDATE_CLUSTERS"] = 1;
	else
		VUHDO_TIMERS["UPDATE_CLUSTERS"] = -1;
	end
	if (VUHDO_isAnyoneInterstedIn(VUHDO_UPDATE_MOUSEOVER)) then
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_MOUSEOVER] = true;
	else
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_MOUSEOVER] = false;
	end

	if (VUHDO_isAnyoneInterstedIn(VUHDO_UPDATE_MOUSEOVER_GROUP)) then
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_MOUSEOVER_GROUP] = true;
	else
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_MOUSEOVER_GROUP] = false;
	end

	if (VUHDO_isAnyoneInterstedIn(VUHDO_UPDATE_MANA)) then
		VUHDO_INSTANCE:RegisterEvent("UNIT_DISPLAYPOWER");
		VUHDO_INSTANCE:RegisterEvent("UNIT_MAXMANA");
		VUHDO_INSTANCE:RegisterEvent("UNIT_MANA");

		if (VUHDO_isAnyoneInterstedIn(VUHDO_UPDATE_OTHER_POWERS)) then
			VUHDO_INSTANCE:RegisterEvent("UNIT_MAXENERGY");
			VUHDO_INSTANCE:RegisterEvent("UNIT_MAXRAGE");
			VUHDO_INSTANCE:RegisterEvent("UNIT_MAXRUNIC_POWER");

			VUHDO_INSTANCE:RegisterEvent("UNIT_ENERGY");
			VUHDO_INSTANCE:RegisterEvent("UNIT_RAGE");
			VUHDO_INSTANCE:RegisterEvent("UNIT_RUNIC_POWER");
		else
			VUHDO_INSTANCE:UnregisterEvent("UNIT_MAXENERGY");
			VUHDO_INSTANCE:UnregisterEvent("UNIT_MAXRAGE");
			VUHDO_INSTANCE:UnregisterEvent("UNIT_MAXRUNIC_POWER");

			VUHDO_INSTANCE:UnregisterEvent("UNIT_ENERGY");
			VUHDO_INSTANCE:UnregisterEvent("UNIT_RAGE");
			VUHDO_INSTANCE:UnregisterEvent("UNIT_RUNIC_POWER");
		end

	else
		VUHDO_INSTANCE:UnregisterEvent("UNIT_DISPLAYPOWER");
		VUHDO_INSTANCE:UnregisterEvent("UNIT_MAXMANA");
		VUHDO_INSTANCE:UnregisterEvent("UNIT_MANA");

		VUHDO_INSTANCE:UnregisterEvent("UNIT_MAXENERGY");
		VUHDO_INSTANCE:UnregisterEvent("UNIT_MAXRAGE");
		VUHDO_INSTANCE:UnregisterEvent("UNIT_MAXRUNIC_POWER");

		VUHDO_INSTANCE:UnregisterEvent("UNIT_ENERGY");
		VUHDO_INSTANCE:UnregisterEvent("UNIT_RAGE");
		VUHDO_INSTANCE:UnregisterEvent("UNIT_RUNIC_POWER");
	end

	if (VUHDO_isAnyoneInterstedIn(VUHDO_UPDATE_UNIT_TARGET)) then
		VUHDO_INSTANCE:RegisterEvent("UNIT_TARGET");
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_UNIT_TARGET] = true;
		VUHDO_TIMERS["REFRESH_TARGETS"] = 1;
	else
		VUHDO_INSTANCE:UnregisterEvent("UNIT_TARGET");
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_UNIT_TARGET] = false;
		VUHDO_TIMERS["REFRESH_TARGETS"] = -1;
	end

	if (VUHDO_CONFIG["IS_SCAN_TALENTS"]) then
		VUHDO_TIMERS["REFRESH_INSPECT"] = 1;
	else
		VUHDO_TIMERS["REFRESH_INSPECT"] = -1;
	end

	if (VUHDO_isModelConfigured(VUHDO_ID_PETS)) then -- Event nicht deregistrieren => Problem mit manchen Vehikeln
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_PETS] = true;
	else
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_PETS] = false;
	end

	if (VUHDO_isModelConfigured(VUHDO_ID_PRIVATE_TANKS) and not VUHDO_CONFIG["OMIT_TARGET"]) then
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_PLAYER_TARGET] = true;
	else
		VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_PLAYER_TARGET] = false;
	end
end



--
function VUHDO_loadVariables()
	_, VUHDO_PLAYER_CLASS = UnitClass("player");
	VUHDO_PLAYER_NAME = UnitName("player");

	VUHDO_loadSpellArray();
	VUHDO_loadDefaultPanelSetup();
	VUHDO_initBuffSettings();
	VUHDO_loadDefaultConfig();
	VUHDO_initMinimap();
	VUHDO_loadDefaultBouquets();
	--VUHDO_importSkinsArrangements();
	VUHDO_initClassColors();

	VUHDO_lnfPatchFont(VuhDoOptionsTooltipText, "Text");
end



--
local tOldAggro = { };
local tOldThreat = { };
local tTarget;
local tAggroUnit;
local tThreatPerc;
function VUHDO_updateAllAggro()
	for tUnit, tInfo in pairs(VUHDO_RAID) do
		tOldAggro[tUnit] = tInfo["aggro"];
		tOldThreat[tUnit] = tInfo["threatPerc"];
		tInfo["aggro"] = false;
		tInfo["threatPerc"] = 0;
	end

	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if (tInfo["connected"] and not tInfo["dead"]) then
			if (VUHDO_INTERNAL_TOGGLES[7] and (tInfo["threat"] or 0) >= 2) then -- VUHDO_UPDATE_AGGRO
				tInfo["aggro"] = true;
			end
			tTarget = tInfo["targetUnit"];
			if (UnitIsEnemy(tUnit, tTarget)) then
				if (VUHDO_INTERNAL_TOGGLES[14]) then -- VUHDO_UPDATE_AGGRO
					_, _, tThreatPerc = UnitDetailedThreatSituation(tUnit, tTarget);
					tInfo["threatPerc"] = tThreatPerc or 0;
				end

				tAggroUnit = VUHDO_RAID_NAMES[UnitName(tTarget .. "target")];

				if (tAggroUnit ~= nil) then
					if (VUHDO_INTERNAL_TOGGLES[14]) then -- VUHDO_UPDATE_AGGRO
						_, _, tThreatPerc = UnitDetailedThreatSituation(tAggroUnit, tTarget);
						VUHDO_RAID[tAggroUnit]["threatPerc"] = tThreatPerc or 0;
					end

					if (sIsHealerMode and VUHDO_INTERNAL_TOGGLES[7]) then -- VUHDO_UPDATE_AGGRO
						VUHDO_RAID[tAggroUnit]["aggro"] = true;
					end
				end
			end
		else
			tInfo["aggro"] = false;
		end
	end

	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if (tInfo["aggro"] ~= tOldAggro[tUnit]) then
			VUHDO_updateHealthBarsFor(tUnit, 7); -- VUHDO_UPDATE_AGGRO
		end

		if (tInfo["threatPerc"] ~= tOldThreat[tUnit]) then
			VUHDO_updateBouquetsForEvent(tUnit, 14); -- VUHDO_UPDATE_THREAT_PERC
		end
	end
end
local VUHDO_updateAllAggro = VUHDO_updateAllAggro;



--
local tUnit, tInfo;
local tIsInRange, tIsCharmed;
local function VUHDO_updateAllRange()
	for tUnit, tInfo in pairs(VUHDO_RAID) do
		-- Check if unit is charmed
		tIsCharmed = UnitIsCharmed(tUnit) and UnitCanAttack("player", tUnit) and not tInfo["dead"];
		if (tInfo["charmed"] ~= tIsCharmed) then
			tInfo["charmed"] = tIsCharmed;
			VUHDO_updateHealthBarsFor(tUnit, 4); -- VUHDO_UPDATE_DEBUFF
		end

		-- Check if unit is in range
		if (sIsRangeKnown) then
			tIsInRange = tInfo["connected"]
			           and (1 == IsSpellInRange(sRangeSpell, tUnit)
			           			or ((tInfo["dead"] or tInfo["charmed"]) and tInfo["baseRange"])
							        or "player" == tUnit
							        or ((tUnit == "focus" or tUnit == "target") and CheckInteractDistance(tUnit, 1))
							       );
		else
			tIsInRange = tInfo["connected"]
								 and (tInfo["baseRange"]
								 			or "player" == tUnit
								 			or ((tUnit == "focus" or tUnit == "target") and CheckInteractDistance(tUnit, 1))
								 		 );
		end

		if (tInfo["range"] ~= tIsInRange) then
			tInfo["range"] = tIsInRange;
			VUHDO_updateHealthBarsFor(tUnit, 5); -- VUHDO_UPDATE_RANGE
			if (sIsDirectionArrow and VUHDO_getCurrentMouseOver() == tUnit and (VuhDoDirectionFrame["shown"] or not tIsInRange)) then
				VUHDO_updateDirectionFrame();
			end
		end

	end
end



--
function VUHDO_normalRaidReload(anIsReloadBuffs)
	if (VUHDO_isConfigPanelShowing()) then
		return;
	end
	VUHDO_TIMERS["RELOAD_RAID"] = 2.3;
	if (anIsReloadBuffs ~= nil) then
		VUHDO_IS_RELOAD_BUFFS = true;
	end
end



--
function VUHDO_quickRaidReload()
	VUHDO_TIMERS["RELOAD_RAID"] = 0.3;
end



--
function VUHDO_lateRaidReload()
	if (not VUHDO_isReloadPending()) then
		VUHDO_TIMERS["RELOAD_RAID"] = 5;
	end
end


--
function VUHDO_isReloadPending()
	return VUHDO_TIMERS["RELOAD_RAID"] > 0
		or VUHDO_TIMERS["RELOAD_UI"] > 0
		or VUHDO_IS_RELOADING;
end



--
function VUHDO_timeReloadUI(someSecs, anIsLnf)
	VUHDO_TIMERS["RELOAD_UI"] = someSecs;
	VUHDO_RELOAD_UI_IS_LNF = anIsLnf;
end



--
function VUHDO_timeRedrawPanel(aPanelNum, someSecs)
	VUHDO_RELOAD_PANEL_NUM = aPanelNum;
	VUHDO_TIMERS["RELOAD_PANEL"] = someSecs;
end



--
function VUHDO_setDebuffAnimation(aTimeSecs)
	VUHDO_DEBUFF_ANIMATION = aTimeSecs;
end



--
function VUHDO_initGcd()
	VUHDO_GCD_UPDATE = true;
end



--
local function VUHDO_doReloadRoster(anIsQuick)
	if (not VUHDO_isConfigPanelShowing()) then
		if (VUHDO_IS_RELOADING) then
			VUHDO_quickRaidReload();
		else
			VUHDO_rebuildTargets();

			if (InCombatLockdown()) then
				VUHDO_RELOAD_AFTER_BATTLE = true;

				VUHDO_IS_RELOADING = true;
				VUHDO_updateAllRaidBars();
				VUHDO_initAllEventBouquets();

				VUHDO_refreshRaidMembers();

				VUHDO_updateAllRaidBars();
				VUHDO_initAllEventBouquets();
				VUHDO_IS_RELOADING = false;

			else
				VUHDO_refreshUI();
				if (VUHDO_IS_RELOAD_BUFFS and not anIsQuick) then
					VUHDO_reloadBuffPanel();
					VUHDO_IS_RELOAD_BUFFS = false;
				end
			end
		end
	end
end



--
local tNow;
local tTimeDelta = 0;
local tAutoProfile;
local tUnit, tInfo;
local tGcdStart, tGcdDuration;
local tHotDebuffToggle = 1;
function VUHDO_OnUpdate(anInstance, aTimeDelta)

	-----------------------------------------------------
	-- These need to update very frequenly to not stutter
	-- --------------------------------------------------

	-- Update custom debuff animation with every tick
	if (VUHDO_DEBUFF_ANIMATION > 0) then
		VUHDO_updateAllDebuffIcons();
		VUHDO_DEBUFF_ANIMATION = VUHDO_DEBUFF_ANIMATION - aTimeDelta;
	end

	tNow = GetTime();

	-- Update GCD-Bar
	if (VUHDO_GCD_UPDATE and VUHDO_GCD_SPELLS[VUHDO_PLAYER_CLASS] ~= nil) then
		tGcdStart, tGcdDuration, _ = GetSpellCooldown(VUHDO_GCD_SPELLS[VUHDO_PLAYER_CLASS]);
		if (tGcdDuration == 0 or tGcdDuration == nil) then
			VuhDoGcdStatusBar:SetValue(0);
			VUHDO_GCD_UPDATE = false;
		else
			VuhDoGcdStatusBar:SetValue(100 * (tGcdDuration - (tNow - tGcdStart)) / tGcdDuration);
		end
	end

	-- Direction Frame
	if (sIsDirectionArrow and VuhDoDirectionFrame["shown"]) then
		VUHDO_updateDirectionFrame();
	end

	------------------------------------------------------------------
	-- In all other cases 0.05 (50 msec) sec tick should be sufficient
	------------------------------------------------------------------

	if (tTimeDelta < 0.05) then
		tTimeDelta = tTimeDelta + aTimeDelta;
		return;
	else
		aTimeDelta = aTimeDelta + tTimeDelta;
		tTimeDelta = 0;
	end

	if (VUHDO_EVENT_COUNT > 0) then
		if (VUHDO_LAST_TIME_NO_EVENT + 3 < tNow) then
			VUHDO_LAST_TIME_NO_EVENT = tNow;
			VUHDO_EVENT_COUNT = 0;
		end

		return;
	end

	-- reload UI?
	if (VUHDO_TIMERS["RELOAD_UI"] > 0) then
		VUHDO_TIMERS["RELOAD_UI"] = VUHDO_TIMERS["RELOAD_UI"] - aTimeDelta;
		if (VUHDO_TIMERS["RELOAD_UI"] <= 0) then
			if (VUHDO_IS_RELOADING or InCombatLockdown()) then
				VUHDO_TIMERS["RELOAD_UI"] = 0.3;
			else
				if (VUHDO_RELOAD_UI_IS_LNF) then
					VUHDO_lnfReloadUI();
				else
					VUHDO_reloadUI();
				end
				VUHDO_initOptions();
				VUHDO_FIRST_RELOAD_UI = true;
			end
		end
	end

	-- redraw single panel?
	if (VUHDO_TIMERS["RELOAD_PANEL"] > 0) then
		VUHDO_TIMERS["RELOAD_PANEL"] = VUHDO_TIMERS["RELOAD_PANEL"] - aTimeDelta;
		if (VUHDO_TIMERS["RELOAD_PANEL"] <= 0) then
			if (VUHDO_IS_RELOADING or InCombatLockdown()) then
				VUHDO_TIMERS["RELOAD_PANEL"] = 0.3;
			else
				VUHDO_PROHIBIT_REPOS = true;
				VUHDO_initAllBurstCaches();
				VUHDO_redrawPanel(VUHDO_RELOAD_PANEL_NUM);
				VUHDO_updateAllPanelBars(VUHDO_RELOAD_PANEL_NUM);
				VUHDO_buildGenericHealthBarBouquet();
				collectgarbage('collect');
				VUHDO_registerAllBouquets();
				VUHDO_initAllEventBouquets();
				VUHDO_PROHIBIT_REPOS = false;
			end
		end
	end

  ---------------------------------------------------
	------------------------- below only if vars loaded
	---------------------------------------------------
	if (not VUHDO_VARIABLES_LOADED) then
		return;
	end

	-- reload after battle
	if (VUHDO_RELOAD_AFTER_BATTLE and not InCombatLockdown()) then
		VUHDO_RELOAD_AFTER_BATTLE = false;

		if (VUHDO_TIMERS["RELOAD_RAID"] <= 0) then
			VUHDO_quickRaidReload();
			if (VUHDO_IS_RELOAD_BUFFS) then
				VUHDO_reloadBuffPanel();
				VUHDO_IS_RELOAD_BUFFS = false;
			end
		end
	end

	-- Reload raid roster?
	if (VUHDO_TIMERS["RELOAD_RAID"] > 0) then
		VUHDO_TIMERS["RELOAD_RAID"] = VUHDO_TIMERS["RELOAD_RAID"] - aTimeDelta;
		if (VUHDO_TIMERS["RELOAD_RAID"] <= 0) then
			VUHDO_doReloadRoster(false);
		end
	end

	-- Quick update after raid roster change?
	if (VUHDO_TIMERS["RELOAD_ROSTER"] > 0) then
		VUHDO_TIMERS["RELOAD_ROSTER"] = VUHDO_TIMERS["RELOAD_ROSTER"] - aTimeDelta;
		if (VUHDO_TIMERS["RELOAD_ROSTER"] <= 0) then
			VUHDO_doReloadRoster(true);
		end
	end

	-- refresh HoTs, cyclic bouquets and customs debuffs?
	if (VUHDO_TIMERS["UPDATE_HOTS"] > 0) then
		VUHDO_TIMERS["UPDATE_HOTS"] = VUHDO_TIMERS["UPDATE_HOTS"] - aTimeDelta;
		if (VUHDO_TIMERS["UPDATE_HOTS"] <= 0) then

			if (tHotDebuffToggle == 1) then
				VUHDO_updateAllHoTs();
			  if (VUHDO_INTERNAL_TOGGLES[18]) then -- VUHDO_UPDATE_MOUSEOVER_CLUSTER
					VUHDO_updateClusterHighlights();
				end
			elseif (tHotDebuffToggle == 2) then
				VUHDO_updateAllCyclicBouquets();
			else
				if (VUHDO_DEBUFF_ANIMATION <= 0) then
					VUHDO_updateAllDebuffIcons();
				end

  			-- Reload after player gained control
				if (not HasFullControl()) then
					VUHDO_LOST_CONTROL = true;
				else
					if (VUHDO_LOST_CONTROL) then
						if (VUHDO_TIMERS["RELOAD_RAID"] <= 0) then
							VUHDO_TIMERS["CUSTOMIZE"] = 0.3;
						end
						VUHDO_LOST_CONTROL = false;
					end
				end
			end

			tHotDebuffToggle = tHotDebuffToggle + 1;
			if (tHotDebuffToggle > 3) then
				tHotDebuffToggle = 1;
			end

			VUHDO_TIMERS["UPDATE_HOTS"] = VUHDO_CONFIG["UPDATE_HOTS_MS"] * 0.00033;
		end
	end

	-- track dragged panel coords
	if (VUHDO_DRAG_PANEL ~= nil) then
		VUHDO_TIMERS["REFRESH_DRAG"] = VUHDO_TIMERS["REFRESH_DRAG"] - aTimeDelta;
		if (VUHDO_TIMERS["REFRESH_DRAG"] <= 0) then
			VUHDO_TIMERS["REFRESH_DRAG"] = 0.05;
			VUHDO_refreshDragTarget(VUHDO_DRAG_PANEL);
		end
	end

	-- Set Button colors without repositioning
	if (VUHDO_TIMERS["CUSTOMIZE"] > 0) then
		VUHDO_TIMERS["CUSTOMIZE"] = VUHDO_TIMERS["CUSTOMIZE"] - aTimeDelta;
		if (VUHDO_TIMERS["CUSTOMIZE"] <= 0) then
			VUHDO_updateAllRaidTargetIndices();
			VUHDO_updateAllRaidBars();
			VUHDO_initAllEventBouquets();
		end
	end

	-- Refresh Tooltip, clear obsolete incoming heals
	if (VUHDO_TIMERS["REFRESH_TOOLTIP"] > 0) then
		VUHDO_TIMERS["REFRESH_TOOLTIP"] = VUHDO_TIMERS["REFRESH_TOOLTIP"] - aTimeDelta;
		if (VUHDO_TIMERS["REFRESH_TOOLTIP"] <= 0) then
			VUHDO_TIMERS["REFRESH_TOOLTIP"] = VUHDO_REFRESH_TOOLTIP_DELAY;
			if (VuhDoTooltip:IsShown()) then
				VUHDO_updateTooltip();
			end

			VUHDO_clearObsoleteInc();
		end
	end

	-- automatic profiles
	if (VUHDO_TIMERS["CHECK_PROFILES"] > 0) then
		VUHDO_TIMERS["CHECK_PROFILES"] = VUHDO_TIMERS["CHECK_PROFILES"] - aTimeDelta;
		if (VUHDO_TIMERS["CHECK_PROFILES"] <= 0) then

			-- Auto profiles
			if (not InCombatLockdown()) then
				if (VUHDO_LAST_AUTO_ARRANG == nil) then
					VUHDO_LAST_AUTO_ARRANG = VUHDO_getAutoProfile();
				else
					tAutoProfile, tTrigger = VUHDO_getAutoProfile();
					if (tAutoProfile ~= nil and VUHDO_LAST_AUTO_ARRANG ~= tAutoProfile and not VUHDO_IS_CONFIG) then
						VUHDO_Msg(VUHDO_I18N_AUTO_ARRANG_1 .. tTrigger .. VUHDO_I18N_AUTO_ARRANG_2 .. "|cffffffff" .. tAutoProfile .. "|r\"");

						VUHDO_loadProfile(tAutoProfile);
						VUHDO_LAST_AUTO_ARRANG = tAutoProfile;
					end
				end
			end

			VUHDO_TIMERS["CHECK_PROFILES"] = 3.1;
		end
	end


	-- Unit Zones
	if (VUHDO_TIMERS["RELOAD_ZONES"] > 0) then
		VUHDO_TIMERS["RELOAD_ZONES"] = VUHDO_TIMERS["RELOAD_ZONES"] - aTimeDelta;
		if (VUHDO_TIMERS["RELOAD_ZONES"] <= 0) then

			-- Unit Zones
			for tUnit, tInfo in pairs(VUHDO_RAID) do
				tInfo["baseRange"] = UnitInRange(tUnit);
				tInfo["visible"] = UnitIsVisible(tUnit); -- Reihenfolge beachten
				tInfo["zone"], tInfo["map"] = VUHDO_getUnitZoneName(tUnit); -- ^^
			end

			VUHDO_TIMERS["RELOAD_ZONES"] = 3.45;
		end
	end


	-- Refresh Buff Watch
	if (VUHDO_REFRESH_BUFFS_TIMER > 0) then
		VUHDO_REFRESH_BUFFS_TIMER = VUHDO_REFRESH_BUFFS_TIMER - aTimeDelta;
		if (VUHDO_REFRESH_BUFFS_TIMER <= 0) then
			VUHDO_updateBuffPanel();
			VUHDO_REFRESH_BUFFS_TIMER = VUHDO_BUFF_SETTINGS["CONFIG"]["REFRESH_SECS"];
		end
	end


	-- Refresh Inspect, check timeout
	if (VUHDO_NEXT_INSPECT_UNIT ~= nil and tNow > VUHDO_NEXT_INSPECT_TIME_OUT) then
		VUHDO_setRoleUndefined(VUHDO_NEXT_INSPECT_UNIT);
		VUHDO_NEXT_INSPECT_UNIT = nil;
	end


	-- Refresh targets not in raid
	if (VUHDO_TIMERS["REFRESH_TARGETS"] > 0) then
		VUHDO_TIMERS["REFRESH_TARGETS"] = VUHDO_TIMERS["REFRESH_TARGETS"] - aTimeDelta;
		if (VUHDO_TIMERS["REFRESH_TARGETS"] <= 0) then
			VUHDO_updateAllOutRaidTargetButtons();
			VUHDO_TIMERS["REFRESH_TARGETS"] = 0.51;
		end
	end

	-----------------------------------------------------------------------------------------

	if (VUHDO_CONFIG_SHOW_RAID) then
		return;
	end


	-- refresh aggro?
	if (VUHDO_TIMERS["UPDATE_AGGRO"] > 0) then
		VUHDO_TIMERS["UPDATE_AGGRO"] = VUHDO_TIMERS["UPDATE_AGGRO"] - aTimeDelta;
		if (VUHDO_TIMERS["UPDATE_AGGRO"] <= 0) then
			VUHDO_updateAllAggro();
			VUHDO_TIMERS["UPDATE_AGGRO"] = VUHDO_CONFIG["THREAT"]["AGGRO_REFRESH_MS"] * 0.001;
		end
	end


	-- refresh range?
	if (VUHDO_TIMERS["UPDATE_RANGE"] > 0) then
		VUHDO_TIMERS["UPDATE_RANGE"] = VUHDO_TIMERS["UPDATE_RANGE"] - aTimeDelta;
		if (VUHDO_TIMERS["UPDATE_RANGE"] <= 0) then
			VUHDO_updateAllRange();
			VUHDO_TIMERS["UPDATE_RANGE"] = VUHDO_CONFIG["RANGE_CHECK_DELAY"] * 0.001;
		end
	end


	-- Refresh Inspect, set new unit if no server request pending
	if (VUHDO_TIMERS["REFRESH_INSPECT"] > 0 and VUHDO_NEXT_INSPECT_UNIT == nil and not InCombatLockdown()) then
		VUHDO_TIMERS["REFRESH_INSPECT"] = VUHDO_TIMERS["REFRESH_INSPECT"] - aTimeDelta;
		if (VUHDO_TIMERS["REFRESH_INSPECT"] <= 0) then
			VUHDO_tryInspectNext();
			VUHDO_TIMERS["REFRESH_INSPECT"] = 2.1;
		end
	end


	-- Refresh Clusters
	if (VUHDO_TIMERS["UPDATE_CLUSTERS"] > 0) then
		VUHDO_TIMERS["UPDATE_CLUSTERS"] = VUHDO_TIMERS["UPDATE_CLUSTERS"] - aTimeDelta;
		if (VUHDO_TIMERS["UPDATE_CLUSTERS"] <= 0) then
			VUHDO_updateAllClusters();
			VUHDO_TIMERS["UPDATE_CLUSTERS"] = VUHDO_CONFIG["CLUSTER"]["REFRESH"] * 0.001;
		end
	end

	-- Refresh d/c shield macros?
	if (VUHDO_TIMERS["MIRROR_TO_MACRO"] > 0) then
		VUHDO_TIMERS["MIRROR_TO_MACRO"] = VUHDO_TIMERS["MIRROR_TO_MACRO"] - aTimeDelta;
		if (VUHDO_TIMERS["MIRROR_TO_MACRO"] <= 0) then
			if (InCombatLockdown()) then
				VUHDO_TIMERS["MIRROR_TO_MACRO"] = 2;
			else
				VUHDO_mirrorToMacro();
			end
		end
	end

end
