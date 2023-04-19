

-- BURST CACHE ---------------------------------------------------

local table = table;
local floor = floor;
local ipairs = ipairs;
local twipe = table.wipe;

local VUHDO_CONFIG;
local VUHDO_PANEL_SETUP;
local VUHDO_RAID;

local VUHDO_getHeader;
local VUHDO_getHeaderPos;
local VUHDO_customizeHeader;
local VUHDO_getDynamicModelArray;
local VUHDO_getGroupMembersSorted;
local VUHDO_getHealButton;
local VUHDO_getHealButtonPos;
local VUHDO_setupAllHealButtonAttributes;
local VUHDO_isDifferentButtonPoint;
local VUHDO_addUnitButton;
local VUHDO_getTargetButton;
local VUHDO_getTotButton;
local VUHDO_getOrCreateHealButton;
local VUHDO_updateAllCustomDebuffs;
local VUHDO_getHeaderWidth;
local VUHDO_initAllEventBouquets;
local VUHDO_getActionPanel;
local VUHDO_isPanelPopulated;
local VUHDO_updateAllRaidBars;
local VUHDO_isTableHeaderOrFooter;

function VUHDO_panelRefreshInitBurst()
  VUHDO_CONFIG = VUHDO_GLOBAL["VUHDO_CONFIG"];
  VUHDO_PANEL_SETUP = VUHDO_GLOBAL["VUHDO_PANEL_SETUP"];
  VUHDO_RAID = VUHDO_GLOBAL["VUHDO_RAID"];

  VUHDO_getHeader = VUHDO_GLOBAL["VUHDO_getHeader"];
  VUHDO_getHeaderPos = VUHDO_GLOBAL["VUHDO_getHeaderPos"];
  VUHDO_customizeHeader = VUHDO_GLOBAL["VUHDO_customizeHeader"];
  VUHDO_getDynamicModelArray = VUHDO_GLOBAL["VUHDO_getDynamicModelArray"];
  VUHDO_getGroupMembersSorted = VUHDO_GLOBAL["VUHDO_getGroupMembersSorted"];
  VUHDO_getHealButton = VUHDO_GLOBAL["VUHDO_getHealButton"];
  VUHDO_getHealButtonPos = VUHDO_GLOBAL["VUHDO_getHealButtonPos"];
  VUHDO_setupAllHealButtonAttributes = VUHDO_GLOBAL["VUHDO_setupAllHealButtonAttributes"];
  VUHDO_isDifferentButtonPoint = VUHDO_GLOBAL["VUHDO_isDifferentButtonPoint"];
  VUHDO_addUnitButton = VUHDO_GLOBAL["VUHDO_addUnitButton"];
	VUHDO_getTargetButton = VUHDO_GLOBAL["VUHDO_getTargetButton"];
	VUHDO_getTotButton = VUHDO_GLOBAL["VUHDO_getTotButton"];
	VUHDO_getOrCreateHealButton = VUHDO_GLOBAL["VUHDO_getOrCreateHealButton"];
	VUHDO_updateAllCustomDebuffs = VUHDO_GLOBAL["VUHDO_updateAllCustomDebuffs"];
	VUHDO_getHeaderWidth = VUHDO_GLOBAL["VUHDO_getHeaderWidth"];
	VUHDO_initAllEventBouquets = VUHDO_GLOBAL["VUHDO_initAllEventBouquets"];
	VUHDO_getActionPanel = VUHDO_GLOBAL["VUHDO_getActionPanel"];
	VUHDO_isPanelPopulated = VUHDO_GLOBAL["VUHDO_isPanelPopulated"];
	VUHDO_updateAllRaidBars = VUHDO_GLOBAL["VUHDO_updateAllRaidBars"];
	VUHDO_isTableHeaderOrFooter = VUHDO_GLOBAL["VUHDO_isTableHeaderOrFooter"];
end
-- BURST CACHE ---------------------------------------------------



--
local tModels, tEmptyModel;
local function VUHDO_hasPanelButtons(aPanelNum)
	if (not VUHDO_CONFIG["SHOW_PANELS"] or not VUHDO_IS_SHOWN_BY_GROUP) then
		return false;
	end

	tModels = VUHDO_PANEL_DYN_MODELS[aPanelNum] or tEmptyModel;
	return #tModels > 0;
end



--
local tCnt;
local tHeader;
local tX, tY;
local tHeaderWidth;
local tModel;
local tAnzCols;
local tWidth;
local function VUHDO_refreshPositionTableHeaders(aPanel, aPanelNum)

  tHeaderWidth = 1 - (VUHDO_PANEL_SETUP[aPanelNum]["SCALING"]["headerWidth"] * 0.01);
	tModel = VUHDO_PANEL_DYN_MODELS[aPanelNum];
	tWidth = VUHDO_getHeaderWidth(aPanelNum);

	if (VUHDO_isTableHeaderOrFooter(aPanelNum)) then
		tAnzCols = #tModel;

		if (tAnzCols > 15) then -- VUHDO_MAX_GROUPS_PER_PANEL
			tAnzCols = 15; -- VUHDO_MAX_GROUPS_PER_PANEL
		end
	else
		tAnzCols = 0;
	end

	for tCnt = 1, tAnzCols do
		tHeader = VUHDO_getHeader(tCnt, aPanelNum);
		tX, tY = VUHDO_getHeaderPos(tCnt, aPanelNum);
		tX = floor(tX + tWidth * 0.5 * tHeaderWidth);

	  if (VUHDO_isDifferentButtonPoint(tHeader, tX, -tY)) then
    	tHeader:SetPoint("TOPLEFT", aPanel:GetName(), "TOPLEFT", tX, -tY);
    end

    VUHDO_customizeHeader(tHeader, aPanelNum, tModel[tCnt]);
		tHeader:Show();
	end

	for tCnt = tAnzCols + 1, 15 do -- VUHDO_MAX_GROUPS_PER_PANEL
		VUHDO_getHeader(tCnt, aPanelNum):Hide();
	end
end



--
local tModelIndex;
local tCnt;
local tGroupIdx;
local tColIdx;
local tButtonIdx;
local tModels;
local tSortBy;
local tPanelName;
local tSetup;
local tX, tY;
local tButton;
local tUnit;
local tGroupArray;
local tModelId;
local function VUHDO_refreshPositionAllHealButtons(aPanel, aPanelNum)
	tSetup = VUHDO_PANEL_SETUP[aPanelNum];
	tModels = VUHDO_getDynamicModelArray(aPanelNum);
  tSortBy = tSetup["MODEL"]["sort"];
  tPanelName = aPanel:GetName();

	tColIdx = 1;
	tButtonIdx = 1;

  for tModelIndex, tModelId in ipairs(tModels) do
  	tGroupArray = VUHDO_getGroupMembersSorted(tModelId, tSortBy, aPanelNum, tModelIndex);

  	for tGroupIdx, tUnit in ipairs(tGroupArray) do

	  	tButton = VUHDO_getOrCreateHealButton(tButtonIdx, aPanelNum);
	  	tButtonIdx = tButtonIdx + 1;
	  	if (tButtonIdx > 51) then -- VUHDO_MAX_BUTTONS_PANEL
	  		return;
	  	end

	  	tX, tY = VUHDO_getHealButtonPos(tColIdx, tGroupIdx, aPanelNum);
	  	if (VUHDO_isDifferentButtonPoint(tButton, tX, -tY)) then
      	tButton:SetPoint("TOPLEFT", tPanelName, "TOPLEFT", tX, -tY);
      end

      if (tButton["raidid"] ~= tUnit) then
				VUHDO_setupAllHealButtonAttributes(tButton, tUnit, false, 70 == tModelId, false); -- VUHDO_ID_VEHICLES
	      VUHDO_setupAllTargetButtonAttributes(VUHDO_getTargetButton(tButton), tUnit);
				VUHDO_setupAllTotButtonAttributes(VUHDO_getTotButton(tButton), tUnit);
			end

	  	VUHDO_addUnitButton(tButton);
      tButton:Show();
  	end

  	tColIdx = tColIdx + 1;
  end

  for tCnt = tButtonIdx, 51 do -- VUHDO_MAX_BUTTONS_PANEL
		tButton = VUHDO_getHealButton(tCnt, aPanelNum);
		if (tButton == nil) then
			break;
		end
		tButton["raidid"] = nil;
		tButton["target"] = nil;
		tButton:SetAttribute("unit", nil);
		tButton:Hide();
  end
end



--
local tHeight;
local function VUHDO_refreshInitPanel(aPanel, aPanelNum)
	tHeight = VUHDO_getHealPanelHeight(aPanelNum);
	if (tHeight < 30) then
		tHeight = 30;
	end
	aPanel:SetHeight(tHeight);
	aPanel:SetWidth(VUHDO_getHealPanelWidth(aPanelNum));
	aPanel:StopMovingOrSizing();
	aPanel["isMoving"] = false;
end



--
local tPanel;
local function VUHDO_refreshPanel(aPanelNum)
  if (VUHDO_hasPanelButtons(aPanelNum)) then
		tPanel = VUHDO_getActionPanel(aPanelNum);
	  tPanel:Show();

		VUHDO_refreshInitPanel(tPanel, aPanelNum);
		VUHDO_refreshPositionTableHeaders(tPanel, aPanelNum);
	end

	-- Even if model is not in panel, we need to refresh VUHDO_UNIT_BUTTONS
	if (VUHDO_isPanelPopulated(aPanelNum)) then
		tPanel = VUHDO_getActionPanel(aPanelNum);
		VUHDO_refreshPositionAllHealButtons(tPanel, aPanelNum);
	end
end



--
local tCnt;
local tPanel;
local function VUHDO_refreshAllPanels()
	for tCnt = 1, 10 do -- VUHDO_MAX_PANELS
		if (VUHDO_isPanelVisible(tCnt)) then
			VUHDO_refreshPanel(tCnt);
		else
			VUHDO_getActionPanel(tCnt):Hide();
		end
	end

	VUHDO_updateAllRaidBars();
	VuhDoGcdStatusBar:Hide();
end



--
function VUHDO_refreshUI()
	VUHDO_IS_RELOADING = true;
	VUHDO_reloadRaidMembers();
	VUHDO_resetNameTextCache();
	twipe(VUHDO_UNIT_BUTTONS);
	VUHDO_refreshAllPanels();
	VUHDO_updateAllCustomDebuffs(true);
	if (VUHDO_INTERNAL_TOGGLES[22]) then -- VUHDO_UPDATE_UNIT_TARGET
		VUHDO_rebuildTargets();
	end
	VUHDO_initAllEventBouquets();
	VUHDO_IS_RELOADING = false;
end
