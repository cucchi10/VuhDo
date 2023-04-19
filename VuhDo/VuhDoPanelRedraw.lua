local VUHDO_GLOBAL = getfenv();

local VUHDO_STD_BACKDROP = nil;
local VUHDO_DESIGN_BACKDROP = nil;
local VUHDO_FONT_HOTS;



local tonumber = tonumber;
local ipairs = ipairs;
local strfind = strfind;
local twipe = table.wipe;
local InCombatLockdown = InCombatLockdown;


--
local sBarScaling;
local sHeaderColSetup;
local sSortCriterion;
local sMainFont;
local sStatusTexture;
local sTextAnchors;
local sLifeConfig;
local sMainFontHeight;
local sLifeFontHeight;
local sHotConfig;
local sHotIconSize;
local sHotColSetup;
local sHotPos;
local sBarHeight;
local sManaBarHeight;
local sTargetColor;
local sTotColor;
local sIsOutline;
local sRaidIconSetup;
local sOverhealTextSetup;
local sHotFontRatio;
local sIsManaBouquet;



--
function VUHDO_panelRedrawInitBurst()
	sHotConfig = VUHDO_PANEL_SETUP["HOTS"];
	VUHDO_FONT_HOTS = VUHDO_PANEL_SETUP["HOTS"]["font"];
	sHotColSetup = VUHDO_PANEL_SETUP["BAR_COLORS"]["HOTS"];
	sHotPos = sHotConfig["radioValue"];
	sIsManaBouquet = VUHDO_INDICATOR_CONFIG["BOUQUETS"]["MANA_BAR"] ~= "";
end



function VUHDO_initLocalVars(aPanelNum)
	sBarScaling = VUHDO_PANEL_SETUP[aPanelNum]["SCALING"];
	sRaidIconSetup = VUHDO_PANEL_SETUP[aPanelNum]["RAID_ICON"];
	sOverhealTextSetup = VUHDO_PANEL_SETUP[aPanelNum]["OVERHEAL_TEXT"];
	sHeaderColSetup = VUHDO_PANEL_SETUP[aPanelNum]["PANEL_COLOR"]["HEADER"];
	sTargetColor = VUHDO_PANEL_SETUP[aPanelNum]["PANEL_COLOR"]["TARGET"];
	sTotColor = VUHDO_PANEL_SETUP[aPanelNum]["PANEL_COLOR"]["TOT"];
	sSortCriterion = VUHDO_PANEL_SETUP[aPanelNum]["MODEL"]["sort"];
	sMainFont = VUHDO_getFont(VUHDO_PANEL_SETUP[aPanelNum]["PANEL_COLOR"]["TEXT"]["font"]);
	sStatusTexture = VUHDO_LibSharedMedia:Fetch('statusbar', VUHDO_PANEL_SETUP[aPanelNum]["PANEL_COLOR"]["barTexture"]);
	sTextAnchors = VUHDO_splitString(VUHDO_PANEL_SETUP[aPanelNum]["ID_TEXT"]["position"], "+");
	sLifeConfig = VUHDO_PANEL_SETUP[aPanelNum]["LIFE_TEXT"];
	sMainFontHeight = VUHDO_PANEL_SETUP[aPanelNum]["PANEL_COLOR"]["TEXT"]["textSize"];
	sLifeFontHeight = VUHDO_PANEL_SETUP[aPanelNum]["PANEL_COLOR"]["TEXT"]["textSizeLife"];
	sIsOutline = VUHDO_PANEL_SETUP[aPanelNum]["PANEL_COLOR"]["TEXT"]["outline"];

	sHotIconSize = sBarScaling["barHeight"] * VUHDO_PANEL_SETUP[aPanelNum]["HOTS"]["size"] * 0.01;
	if (sHotIconSize == 0) then
		sHotIconSize = 0.001;
	end
	sHotFontRatio = VUHDO_PANEL_SETUP[aPanelNum]["HOTS"]["textSize"] * 0.01;

	sBarHeight  = VUHDO_getHealthBarHeight(aPanelNum);
	sManaBarHeight  = VUHDO_getManaBarHeight(aPanelNum);
	if (sManaBarHeight == 0) then
		sManaBarHeight = 0.001;
	end
end
local VUHDO_initLocalVars = VUHDO_initLocalVars;



--
function VUHDO_isPanelVisible(aPanelNum)
	if (not VUHDO_CONFIG["SHOW_PANELS"] or VUHDO_PANEL_MODELS[aPanelNum] == nil or not VUHDO_IS_SHOWN_BY_GROUP) then
		return false;
	end

	if (VUHDO_CONFIG["HIDE_EMPTY_PANELS"] and not VUHDO_isConfigPanelShowing()
		and #VUHDO_PANEL_UNITS[aPanelNum] == 0) then
		return false;
	end

	return true;
end
local VUHDO_isPanelVisible = VUHDO_isPanelVisible;



--
function VUHDO_isPanelPopulated(aPanelNum)
	return VUHDO_CONFIG["SHOW_PANELS"] and VUHDO_PANEL_MODELS[aPanelNum] ~= nil and VUHDO_IS_SHOWN_BY_GROUP;
end
local VUHDO_isPanelPopulated = VUHDO_isPanelPopulated;



--
local function VUHDO_initGroupOrderPanel(aGroupOrderPanel)
	if (aGroupOrderPanel ~= nil) then
		aGroupOrderPanel:Hide();
	end
end



--
local tCnt;
local tHeader;
local tX, tY
local tAnzCols;
local tHealthBar;
local tHeaderText;
local tModel;
local tWidth;
local tHeight;
local tStatusFile;
local tFont;
local tTextSize;
local tBarWidth;

local function VUHDO_positionTableHeaders(aPanel, aPanelNum)

	tModel  = VUHDO_PANEL_DYN_MODELS[aPanelNum];
	tWidth  = VUHDO_getHeaderWidth(aPanelNum);
	tHeight = VUHDO_getHeaderHeight(aPanelNum);

	if (VUHDO_isTableHeaderOrFooter(aPanelNum)) then
		tAnzCols = #tModel;

		if (tAnzCols > 15) then -- VUHDO_MAX_GROUPS_PER_PANEL
			tAnzCols = 15; -- VUHDO_MAX_GROUPS_PER_PANEL
		end
	else
		tAnzCols = 0;
	end

	tStatusFile = VUHDO_LibSharedMedia:Fetch('statusbar', sHeaderColSetup["barTexture"]);
	tFont = VUHDO_getFont(sHeaderColSetup["font"]);
	tTextSize = tonumber(sHeaderColSetup["textSize"]);
	tBarWidth = sBarScaling["headerWidth"] * 0.01;
	for tCnt  = 1, 15 do -- VUHDO_MAX_GROUPS_PER_PANEL
		tHeader = VUHDO_getHeader(tCnt, aPanelNum);
		tHeader:SetWidth(tWidth * tBarWidth + 0.01);
		tHeader:SetHeight(tHeight);

		tHealthBar = VUHDO_getHeaderBar(tHeader);
		tHealthBar:SetValue(100);
		tHealthBar:SetHeight(tHeight);

		if (tStatusFile ~= nil) then
			tHealthBar:SetStatusBarTexture(tStatusFile);
		end

		tHeaderText = VUHDO_getHeaderTextId(tHeader);
		tHeaderText:SetFont(tFont, tTextSize, "OUTLINE");
	end

	for tCnt  = 1, tAnzCols do
		tHeader = VUHDO_getHeader(tCnt, aPanelNum);
		tX, tY = VUHDO_getHeaderPos(tCnt, aPanelNum);
		tHeader:SetPoint("TOPLEFT", aPanel:GetName(), "TOPLEFT",  tX + tWidth * 0.5 * (1 - tBarWidth), -tY);
		VUHDO_customizeHeader(tHeader,  aPanelNum, tModel[tCnt]);
		tHeader:Show();
	end

	for tCnt = tAnzCols + 1, 15 do -- VUHDO_MAX_GROUPS_PER_PANEL
		VUHDO_getHeader(tCnt, aPanelNum):Hide();
	end
end



--
local tModelArray;
local tModelIndex, tModelId;
local tMemberNum;
local function VUHDO_getNumButtonsPanel(aPanelNum)
	tModelArray = VUHDO_getDynamicModelArray(aPanelNum);
	tMemberNum = 0;

	for tModelIndex, tModelId in ipairs(tModelArray)  do
		tMemberNum = tMemberNum + #VUHDO_getGroupMembers(tModelId, aPanelNum, tModelIndex);
	end

	return tMemberNum;
end



--
local tBackdrop, tBorderCol;
local function VUHDO_initPlayerTargetBorder(aButton, aBorderFrame)
	aBorderFrame:SetPoint("TOPLEFT", aButton:GetName(), "TOPLEFT", -VUHDO_INDICATOR_CONFIG["CUSTOM"]["BAR_BORDER"]["WIDTH"], VUHDO_INDICATOR_CONFIG["CUSTOM"]["BAR_BORDER"]["WIDTH"]);
	aBorderFrame:SetPoint("BOTTOMRIGHT", aButton:GetName(), "BOTTOMRIGHT", VUHDO_INDICATOR_CONFIG["CUSTOM"]["BAR_BORDER"]["WIDTH"], -VUHDO_INDICATOR_CONFIG["CUSTOM"]["BAR_BORDER"]["WIDTH"]);
	if (tBackdrop ==  nil) then
		tBackdrop = aBorderFrame:GetBackdrop();
		tBackdrop["edgeSize"] = VUHDO_INDICATOR_CONFIG["CUSTOM"]["BAR_BORDER"]["WIDTH"];
	end
	aBorderFrame:SetBackdrop(tBackdrop);
	aBorderFrame:SetBackdropBorderColor(0, 0, 0, 0);
	aBorderFrame:Hide();
end



--
local tBackdropCluster;
local tClusterFrame;
local function VUHDO_initClusterBorder(aButton)
	tClusterFrame = VUHDO_getClusterBorderFrame(aButton);
	tClusterFrame:SetPoint("TOPLEFT", aButton:GetName(), "TOPLEFT", 0, 0);
	tClusterFrame:SetPoint("BOTTOMRIGHT", aButton:GetName(), "BOTTOMRIGHT", 0, 0);
	if (tBackdropCluster ==  nil) then
		tBackdropCluster = tClusterFrame:GetBackdrop();
		tBackdropCluster["edgeSize"] = VUHDO_INDICATOR_CONFIG["CUSTOM"]["CLUSTER_BORDER"]["WIDTH"];
	end
	tClusterFrame:SetBackdrop(tBackdropCluster);
	tClusterFrame:SetBackdropColor(0, 0, 0, 0);
	tClusterFrame:Hide();
end



--
local tIncBar;
function VUHDO_positionHealButton(aButton)
	aButton:SetWidth(sBarScaling["barWidth"]);
	aButton:SetHeight(sBarScaling["barHeight"]);

	tIncBar = VUHDO_getHealthBar(aButton, 6);
	tIncBar:SetPoint("TOPLEFT", VUHDO_getHealthBar(aButton, 3):GetName(), "TOPLEFT", 0, 0);
	tIncBar:SetWidth(sBarScaling["barWidth"]);
	tIncBar:SetHeight(sBarHeight);

	-- Player Target
	VUHDO_initPlayerTargetBorder(aButton, VUHDO_getPlayerTargetFrame(aButton));
	VUHDO_initPlayerTargetBorder(VUHDO_getTargetButton(aButton), VUHDO_getPlayerTargetFrameTarget(aButton));
	VUHDO_initPlayerTargetBorder(VUHDO_getTotButton(aButton), VUHDO_getPlayerTargetFrameToT(aButton));

	-- Cluster indicator
	VUHDO_initClusterBorder(aButton);
end
local VUHDO_positionHealButton = VUHDO_positionHealButton;



--
local tModelIndex;
local tBorderCol;
local tXPos,  tYPos;
local tHealButton;
local tUnit;
local tGroupArray;
local tModelId;
local tGroupIndex, tColumnIndex, tButtonIndex;
local tCnt;
local tBorderCol;
local tModelArray;
local tPanelName;
local function VUHDO_positionAllHealButtons(aPanel, aPanelNum)
	tModelArray = VUHDO_getDynamicModelArray(aPanelNum);
	tPanelName  = aPanel:GetName();

	tColumnIndex = 1;
	tButtonIndex = 1;

	tBorderCol  = nil;

	for tModelIndex,  tModelId  in ipairs(tModelArray)  do
		tGroupArray = VUHDO_getGroupMembersSorted(tModelId, sSortCriterion, aPanelNum, tModelIndex);
		tGroupIndex = 1;
		for _, tUnit  in ipairs(tGroupArray)  do
			tHealButton = VUHDO_getHealButton(tButtonIndex, aPanelNum);

			tButtonIndex  = tButtonIndex  + 1;
			if (tButtonIndex > 51) then -- VUHDO_MAX_BUTTONS_PANEL
				return;
			end

			VUHDO_positionHealButton(tHealButton);

			tXPos,  tYPos = VUHDO_getHealButtonPos(tColumnIndex, tGroupIndex, aPanelNum);
			if (VUHDO_isDifferentButtonPoint(tHealButton, tXPos, -tYPos)) then
				tHealButton:SetPoint("TOPLEFT", tPanelName, "TOPLEFT", tXPos, -tYPos);
			end

			VUHDO_setupAllHealButtonAttributes(tHealButton, tUnit, false, 70 == tModelId, false); -- VUHDO_ID_VEHICLES
			VUHDO_setupAllTargetButtonAttributes(VUHDO_getTargetButton(tHealButton),  tUnit);
			VUHDO_setupAllTotButtonAttributes(VUHDO_getTotButton(tHealButton), tUnit);

			VUHDO_addUnitButton(tHealButton);

			tHealButton:Show();
			tGroupIndex = tGroupIndex + 1;
		end

		tColumnIndex = tColumnIndex + 1;
	end
end


--


local sButton;
local sHealthBar;
local sPanelSetup;



--
local function VUHDO_initAggroTexture()
	VUHDO_getAggroTexture(sHealthBar):Hide();
end



--
local tInfo;
local tManaHeight;
local function VUHDO_initManaBar(aButton, aManaBar, aWidth, anIsForceBar)
	aManaBar:SetPoint("BOTTOMLEFT", aButton:GetName(),  "BOTTOMLEFT", 0, 0);
	VUHDO_setLlcStatusBarTexture(aManaBar, VUHDO_INDICATOR_CONFIG["CUSTOM"]["MANA_BAR"]["TEXTURE"]);

	tInfo = VUHDO_RAID[aButton["raidid"]];
	if (anIsForceBar or tInfo == nil or sIsManaBouquet) then
		tManaHeight = sManaBarHeight;
	else
		tManaHeight = 0;
	end

	aManaBar:SetWidth(aWidth);
	aButton["regularHeight"] = sBarScaling["barHeight"];
	if (sIsManaBouquet) then
		aManaBar:Show();
		aManaBar:SetHeight(tManaHeight);
		if (VUHDO_getHealthBar(aButton, 1):GetHeight(sBarHeight) == 0) then
			VUHDO_getHealthBar(aButton, 1):SetHeight(sBarHeight);
		end
	else
		aManaBar:Hide();
	  VUHDO_getHealthBar(aButton, 1):SetHeight(sBarHeight + sManaBarHeight);
	end
end



--
local function VUHDO_initBackgroundBar(aBgBar)
	VUHDO_setLlcStatusBarTexture(aBgBar, VUHDO_INDICATOR_CONFIG["CUSTOM"]["BACKGROUND_BAR"]["TEXTURE"]);
	aBgBar:SetHeight(sBarScaling["barHeight"]);
	aBgBar:SetValue(100);
	aBgBar:SetStatusBarColor(0, 0, 0, 0);
	aBgBar:Show();
end



--
local function VUHDO_initIncomingBar()
	VUHDO_getHealthBar(sButton, 6):SetValueRange(0, 0);
end



--
local tThreatBar;
local function VUHDO_initThreatBar()
	tThreatBar =  VUHDO_getHealthBar(sButton, 7);
	VUHDO_setLlcStatusBarTexture(tThreatBar, VUHDO_INDICATOR_CONFIG["CUSTOM"]["THREAT_BAR"]["TEXTURE"]);
	tThreatBar:SetValue(0);
	tThreatBar:SetStatusBarColor(0, 0, 0, 0);
	tThreatBar:SetHeight(VUHDO_INDICATOR_CONFIG["CUSTOM"]["THREAT_BAR"]["HEIGHT"]);
end



--
local tTextPanel;
local tNameText;
local tLifeText;
local tAddHeight;
local tShadowAlpha, tOutlineText;
local function VUHDO_initBarTexts(aButton, aHealthBar, aWidth)
	tTextPanel  = VUHDO_getTextPanel(aHealthBar);
	tNameText = VUHDO_getBarText(aHealthBar);
	tLifeText = VUHDO_getLifeText(aHealthBar);

	if (sIsOutline) then
		tShadowAlpha = 0;
		tOutlineText = "OUTLINE";
	else
		tShadowAlpha = 1;
		tOutlineText = "";
	end

	tNameText:SetWidth(aWidth);
	tNameText:SetHeight(sMainFontHeight);
	tNameText:SetFont(sMainFont, sMainFontHeight, tOutlineText);
	tNameText:SetShadowColor(0, 0, 0, tShadowAlpha);

	tLifeText:SetFont(sMainFont, sLifeFontHeight, tOutlineText);
	tLifeText:SetShadowColor(0, 0, 0, tShadowAlpha);

	tNameText:ClearAllPoints();
	tAddHeight  = 0;
	if (not sLifeConfig["show"] or VUHDO_LT_POS_RIGHT == sLifeConfig["position"] or VUHDO_LT_POS_LEFT == sLifeConfig["position"]) then
		tLifeText:SetWidth(0);
		tLifeText:SetHeight(0);
		tLifeText:Hide();
		tNameText:SetPoint("CENTER",  tTextPanel:GetName(), "CENTER", 0,  0);
	else
		tLifeText:ClearAllPoints();
		tLifeText:SetWidth(aWidth);
		tLifeText:SetHeight(sLifeFontHeight);
		tAddHeight  = sLifeFontHeight;

		if (VUHDO_LT_POS_BELOW == sLifeConfig["position"]) then
			tNameText:SetPoint("TOP", tTextPanel:GetName(), "TOP", 0, 0);
			tLifeText:SetPoint("TOP", tNameText:GetName(), "BOTTOM", 0, 0);
		else
			tNameText:SetPoint("BOTTOM",  tTextPanel:GetName(), "BOTTOM", 0,  0);
			tLifeText:SetPoint("BOTTOM",  tNameText:GetName(),  "TOP", 0, 0);
		end

		tLifeText:Show();
	end

	tTextPanel:SetHeight(tNameText:GetHeight() + tAddHeight);
	tTextPanel:SetWidth(aWidth);

	sPanelSetup["ID_TEXT"]["_spacing"] = tTextPanel:GetHeight(); -- internal marker

	if (strfind(sTextAnchors[1], "LEFT", 1, true)) then
		tNameText:SetJustifyH("LEFT");
		tLifeText:SetJustifyH("LEFT");
	elseif (strfind(sTextAnchors[1], "RIGHT", 1, true)) then
		tNameText:SetJustifyH("RIGHT");
		tLifeText:SetJustifyH("RIGHT");
	else
		tNameText:SetJustifyH("CENTER");
		tLifeText:SetJustifyH("CENTER");
	end

	local tAnchorObject;
	if (strfind(sTextAnchors[2], "BOTTOM", 1, true) and strfind(sTextAnchors[1], "TOP", 1, true)) then
		tAnchorObject = aButton;
	else
		tAnchorObject = aHealthBar;
	end

	tTextPanel:ClearAllPoints();
	tTextPanel:SetPoint(sTextAnchors[1],  tAnchorObject:GetName(),  sTextAnchors[2], 0, 0);
end



--
local tX, tY;
local tOvhColor;
local tOverhealText;
local tOverhealPanel;
local function VUHDO_initOverhealText(aHealthBar, aWidth)
	tOverhealText = VUHDO_getOverhealText(aHealthBar);
	tOverhealText:SetWidth(400);
	tOverhealText:SetHeight(sMainFontHeight);
	tOvhColor = VUHDO_PANEL_SETUP["BAR_COLORS"]["OVERHEAL_TEXT"];
	tOverhealText:SetTextColor(tOvhColor["TR"], tOvhColor["TG"], tOvhColor["TB"], tOvhColor["TO"]);
	tOverhealText:SetFont(sMainFont, sMainFontHeight);
	tOverhealText:SetJustifyH("CENTER");
	tOverhealText:SetText("");

	tOverhealPanel = VUHDO_getOverhealPanel(aHealthBar);
	tOverhealPanel:SetHeight(1);
	tOverhealPanel:SetWidth(1);

	tX = sOverhealTextSetup["xAdjust"] * aWidth * 0.01;
	tY = -sOverhealTextSetup["yAdjust"] * sBarScaling["barHeight"] * 0.01;
	tOverhealPanel:ClearAllPoints();
	tOverhealPanel:SetPoint(sOverhealTextSetup["point"],  aHealthBar:GetName(), sOverhealTextSetup["point"], tX, tY);
end



--
local tAggroBar;
local function VUHDO_initAggroBar()
	tAggroBar = VUHDO_getHealthBar(sButton, 4);
	VUHDO_setLlcStatusBarTexture(tAggroBar, VUHDO_INDICATOR_CONFIG["CUSTOM"]["AGGRO_BAR"]["TEXTURE"]);

	tAggroBar:SetPoint("BOTTOM", sHealthBar:GetName(), "TOP", 0, 0);
	tAggroBar:SetWidth(sBarScaling["barWidth"]);
	tAggroBar:SetHeight(sBarScaling["rowSpacing"]);
	tAggroBar:SetValue(0);
	tAggroBar:Show();
end



--
local tHotBarHeight;
local tHotBar;
local tHotBarColor;
local tCnt;
local function VUHDO_initHotBars()
	tHotBarHeight = sBarScaling["barHeight"] * sHotConfig["BARS"]["width"] * 0.01;

	for tCnt = 1, 3 do
		tHotBar = VUHDO_getHealthBar(sButton, tCnt + 8);
		tHotBar:ClearAllPoints();
		tHotBar:SetWidth(sBarScaling["barWidth"]);
		tHotBar:SetHeight(tHotBarHeight);
		tHotBar:SetValue(0);
		tHotBarColor = VUHDO_PANEL_SETUP["BAR_COLORS"]["HOT" .. tCnt + 5];
		tHotBar:SetStatusBarColor(tHotBarColor["R"], tHotBarColor["G"], tHotBarColor["B"], tHotBarColor["O"]);
	end

	if (sHotConfig["BARS"]["radioValue"] == 1) then -- edges
		VUHDO_getHealthBar(sButton, 9):SetPoint("TOP", sHealthBar:GetName(), "TOP", 0, 0);
		VUHDO_getHealthBar(sButton, 10):SetPoint("CENTER", sHealthBar:GetName(), "CENTER",  0, 0);
		VUHDO_getHealthBar(sButton, 11):SetPoint("BOTTOM", sHealthBar:GetName(), "BOTTOM",  0, 0);
	elseif (sHotConfig["BARS"]["radioValue"] == 2) then -- center
		VUHDO_getHealthBar(sButton, 9):SetPoint("CENTER", sHealthBar:GetName(), "CENTER", 0, tHotBarHeight);
		VUHDO_getHealthBar(sButton, 10):SetPoint("CENTER", sHealthBar:GetName(), "CENTER",  0, 0);
		VUHDO_getHealthBar(sButton, 11):SetPoint("CENTER", sHealthBar:GetName(), "CENTER",  0, -tHotBarHeight);
	elseif (sHotConfig["BARS"]["radioValue"] == 3) then -- top
		VUHDO_getHealthBar(sButton, 9):SetPoint("TOP", sHealthBar:GetName(), "TOP", 0, 0);
		VUHDO_getHealthBar(sButton, 10):SetPoint("TOP", sHealthBar:GetName(), "TOP",  0, -tHotBarHeight);
		VUHDO_getHealthBar(sButton, 11):SetPoint("TOP", sHealthBar:GetName(), "TOP",  0, -2 * tHotBarHeight);
	else -- bottom
		VUHDO_getHealthBar(sButton, 9):SetPoint("BOTTOM", sHealthBar:GetName(), "BOTTOM", 0, 0);
		VUHDO_getHealthBar(sButton, 10):SetPoint("BOTTOM", sHealthBar:GetName(), "BOTTOM",  0, tHotBarHeight);
		VUHDO_getHealthBar(sButton, 11):SetPoint("BOTTOM", sHealthBar:GetName(), "BOTTOM",  0, 2 * tHotBarHeight);
	end

	tHotBar:Show();
end



--
local tHotIcon;
local tOffset;
local tHotColor;
local tIsBothBottom, tIsBothTop;
local tTimer;
local tCounter;
local tHotName;
local tOutlineText;
local tChargeIcon;
local tShadowAlpha;

local function VUHDO_initHotIcon(tCnt)
	VUHDO_getBarIconTimer(sButton, tCnt):SetText("");
	VUHDO_getBarIconCounter(sButton, tCnt):SetText("");
	tHotIcon  = VUHDO_getBarIcon(sButton,  tCnt);
	tHotIcon:ClearAllPoints();
	tHotIcon:SetTexCoord(0, 1, 0, 1);

	tHotColor = VUHDO_PANEL_SETUP["BAR_COLORS"]["HOT" ..  tCnt];

	if (sHotConfig["iconRadioValue"] ~= 1) then
		tHotIcon:SetVertexColor(tHotColor["R"], tHotColor["G"], tHotColor["B"]);
	else
		tHotIcon:SetVertexColor(1, 1, 1);
	end

	if (sHotConfig["radioValue"] >= 20) then
		tHotIcon:SetWidth(sHotIconSize  * 0.5);
		tHotIcon:SetHeight(sHotIconSize * 0.5);
	else
		tHotIcon:SetWidth(sHotIconSize);
		tHotIcon:SetHeight(sHotIconSize);
	end

	if (tCnt < 9) then
		tOffset = (tCnt - 1) * sHotIconSize;
	else
		tOffset = (tCnt - 4) * sHotIconSize;
	end

	if (sHotPos == 2) then
		tHotIcon:SetPoint("LEFT", sHealthBar:GetName(), "LEFT", tOffset,  0); -- li
	elseif (sHotPos == 3) then
		tHotIcon:SetPoint("RIGHT",  sHealthBar:GetName(), "RIGHT",  -tOffset, 0); --  ri
	elseif (sHotPos == 1) then
		tHotIcon:SetPoint("RIGHT",  sHealthBar:GetName(), "LEFT", -tOffset, 0); -- lo
	elseif (sHotPos == 4) then
		tHotIcon:SetPoint("LEFT", sHealthBar:GetName(), "RIGHT", tOffset, 0); --  ro
	elseif (sHotPos == 5) then
		tHotIcon:SetPoint("TOPLEFT",  sHealthBar:GetName(), "BOTTOMLEFT", tOffset, sHotIconSize / 2); -- lb
	elseif (sHotPos == 6) then
		tHotIcon:SetPoint("TOPRIGHT", sHealthBar:GetName(), "BOTTOMRIGHT", -tOffset,  sHotIconSize / 2); -- rb
	elseif (sHotPos == 7) then
		tHotIcon:SetPoint("TOPLEFT",  sButton:GetName(), "BOTTOMLEFT", tOffset, 0); -- lu
	elseif (sHotPos == 8) then
		tHotIcon:SetPoint("TOPRIGHT", sButton:GetName(), "BOTTOMRIGHT", -tOffset,  0); -- ru
	elseif (sHotPos == 9) then
		tHotIcon:SetPoint("TOPLEFT",  sHealthBar:GetName(), "TOPLEFT",  tOffset,  sBarScaling["barHeight"] / 3); -- la

	elseif (sHotPos == 10) then
		tHotIcon:SetPoint("TOPLEFT",  sButton:GetName(), "TOPLEFT", tOffset,  0); -- lu corner
	elseif (sHotPos == 12) then
		tHotIcon:SetPoint("BOTTOMLEFT", sHealthBar:GetName(), "BOTTOMLEFT",  tOffset, 0);  -- lb corner
	elseif (sHotPos == 11) then
		tHotIcon:SetPoint("BOTTOMRIGHT", sHealthBar:GetName(), "BOTTOMRIGHT", -tOffset, 0);  -- rb corner
	elseif (sHotPos == 13) then
		tHotIcon:SetPoint("BOTTOMLEFT",  sButton:GetName(), "BOTTOMLEFT", tOffset, 0); -- lb
	elseif (sHotPos == 14) then
		tHotIcon:SetPoint("BOTTOMRIGHT", sButton:GetName(), "BOTTOMRIGHT", -tOffset,  0); -- rb

	elseif (sHotPos == 20) then
		tIsBothBottom = sHotConfig["SLOTS"][4] ~= nil	and sHotConfig["SLOTS"][5] ~= nil;
		tIsBothTop = sHotConfig["SLOTS"][2] ~= nil	and sHotConfig["SLOTS"][9] ~= nil;

		if (tCnt  == 1) then
			tHotIcon:SetPoint("LEFT", sHealthBar:GetName(), "LEFT", 0, 0);
		elseif (tCnt  == 2) then
			if (tIsBothTop)  then
				tHotIcon:SetPoint("TOP",  sHealthBar:GetName(), "TOP",  -sBarScaling["barWidth"] * 0.2, 0);
			else
				tHotIcon:SetPoint("TOP",  sHealthBar:GetName(), "TOP",  0, 0);
			end
		elseif (tCnt  == 9) then
			if (tIsBothTop)  then
				tHotIcon:SetPoint("TOP",  sHealthBar:GetName(), "TOP",  sBarScaling["barWidth"] * 0.2, 0);
			else
				tHotIcon:SetPoint("TOP",  sHealthBar:GetName(), "TOP",  0, 0);
			end
		elseif (tCnt  == 3) then
			tHotIcon:SetPoint("RIGHT",  sHealthBar:GetName(), "RIGHT",  0, 0);
		elseif (tCnt  == 4) then
			if (tIsBothBottom)  then
				tHotIcon:SetPoint("BOTTOM", sHealthBar:GetName(), "BOTTOM", sBarScaling["barWidth"] * 0.2, 0);
			else
				tHotIcon:SetPoint("BOTTOM", sHealthBar:GetName(), "BOTTOM", 0, 0);
			end
		elseif (tCnt == 5) then
			if (tIsBothBottom)  then
				tHotIcon:SetPoint("BOTTOM", sHealthBar:GetName(), "BOTTOM", -sBarScaling["barWidth"] * 0.2, 0);
			else
				tHotIcon:SetPoint("BOTTOM", sHealthBar:GetName(), "BOTTOM", 0, 0);
			end
		end
	elseif (sHotPos == 21) then
		if (tCnt  == 1) then
			tHotIcon:SetPoint("TOPLEFT",  sHealthBar:GetName(), "TOPLEFT",  0, 0);
		elseif (tCnt  == 2) then
			tHotIcon:SetPoint("TOPRIGHT", sHealthBar:GetName(), "TOPRIGHT", 0, 0);
		elseif (tCnt  == 3) then
			tHotIcon:SetPoint("BOTTOMLEFT", sHealthBar:GetName(), "BOTTOMLEFT", 0, 0);
		elseif (tCnt  == 4) then
			tHotIcon:SetPoint("BOTTOMRIGHT",  sHealthBar:GetName(), "BOTTOMRIGHT",  0, 0);
		elseif (tCnt  == 5) then
			tHotIcon:SetPoint("BOTTOM", sHealthBar:GetName(), "BOTTOM", 0, 0);
		elseif (tCnt  == 9) then
			tHotIcon:SetPoint("TOP", sHealthBar:GetName(), "TOP", 0, 0);
		end
	end

	tTimer  = VUHDO_getBarIconTimer(sButton, tCnt);
	tCounter  = VUHDO_getBarIconCounter(sButton, tCnt);

	tHotIcon:SetAlpha(0);
	tTimer:SetText("");
	tCounter:SetText("");

	tHotIcon:Show();
	tTimer:Show();
	tCounter:Show();

	tHotName  = sHotConfig["SLOTS"][tCnt];
	tTimer:ClearAllPoints();

	if (sHotColSetup["TEXT"]["outline"]) then
		tOutlineText = "OUTLINE";
	else
		tOutlineText = "";
	end

	if (sHotColSetup["TEXT"]["shadow"]) then
		tShadowAlpha = 1;
	else
		tShadowAlpha = 0;
	end

	if (tHotName  ~= nil) then
		tTimer:SetShadowOffset(1, -0.5);
		tTimer:SetShadowColor(0,  0, 0, tShadowAlpha);

		if (sHotConfig["stacksRadioValue"] == 2 or "CLUSTER" == tHotName) then -- Counter text
			tHotIcon:SetVertexColor(1, 1, 1);
			tTimer:SetPoint("BOTTOMRIGHT",  tHotIcon:GetName(), "BOTTOMRIGHT", 2, 0);
			if (sHotIconSize > 1) then
				tTimer:SetFont(VUHDO_FONT_HOTS, tHotIcon:GetHeight() / 1.7 * sHotFontRatio, tOutlineText);
			else
				tTimer:Hide();
			end
			tCounter:SetTextColor(tHotColor["TR"], tHotColor["TG"], tHotColor["TB"]);
		else
			tTimer:SetPoint("CENTER", tHotIcon:GetName(), "CENTER", 1, 0);
			tTimer:SetTextColor(tHotColor["TR"], tHotColor["TG"], tHotColor["TB"], tHotColor["TO"]);
			if (sHotIconSize > 1) then
				tTimer:SetFont(VUHDO_FONT_HOTS, tHotIcon:GetHeight() / 1.2 * sHotFontRatio, tOutlineText);
			else
				tTimer:Hide();
			end
			tCounter:Hide();
		end

		if ("CLUSTER" == tHotName) then
			tHotIcon:SetTexture("Interface\\AddOns\\VuhDo\\Images\\cluster2");
		elseif (sHotConfig["iconRadioValue"] == 3) then -- Flat
			tHotIcon:SetTexture("Interface\\AddOns\\VuhDo\\Images\\hot_flat_16_16");
		elseif (sHotConfig["iconRadioValue"] == 2) then -- Glossy
			tHotIcon:SetTexture("Interface\\AddOns\\VuhDo\\Images\\icon_white_square");
		else
			if (VUHDO_CAST_ICON_DIFF[tHotName] ~= nil and VUHDO_CAST_ICON_DIFF[tHotName] ~= "*") then
				tHotIcon:SetTexture(VUHDO_CAST_ICON_DIFF[tHotName]);
			elseif (VUHDO_SPELLS[tHotName] ~= nil) then
				tHotIcon:SetTexture(VUHDO_SPELLS[tHotName]["icon"]);
			end
		end

		tChargeIcon = VUHDO_getBarIconCharge(sButton, tCnt);
		tChargeIcon:SetWidth(tHotIcon:GetWidth() + 4);
		tChargeIcon:SetHeight(tHotIcon:GetHeight() + 4);
		tChargeIcon:SetVertexColor(tHotColor["R"] * 2, tHotColor["G"] * 2, tHotColor["B"] * 2);
		tChargeIcon:Hide();
		tChargeIcon:SetPoint("TOPLEFT", tHotIcon:GetName(), "TOPLEFT", -2, 2);

		if (VUHDO_PANEL_SETUP["BAR_COLORS"]["HOT" .. tCnt]["countdownMode"] == 0 or sHotIconSize < 1) then
			tTimer:Hide();
		else
			tTimer:Show();
		end
	end

	tCounter:SetPoint("TOPLEFT",  tHotIcon:GetName(), "TOPLEFT",  -2, 0);

	if (sHotIconSize > 1) then
		tCounter:SetFont(VUHDO_FONT_HOTS, tHotIcon:GetHeight() / 1.5 * sHotFontRatio, tOutlineText);
	else
		tCounter:Hide();
	end
	tCounter:SetShadowColor(0, 0, 0, tShadowAlpha);
	tCounter:SetShadowOffset(1, -0.5);
end



--
local tCnt;
function VUHDO_initAllHotIcons()
	for tCnt  = 1, 5 do
		VUHDO_initHotIcon(tCnt);
	end

	VUHDO_initHotIcon(9);
end
local VUHDO_initAllHotIcons = VUHDO_initAllHotIcons;



--
local tIcon,  tCounter, tName;
local tDebuffConfig;
local tCnt;
local tX, tY;
local tSign;
local function VUHDO_initCustomDebuffs()
	tDebuffConfig = VUHDO_CONFIG["CUSTOM_DEBUFF"];

	tX = tDebuffConfig["xAdjust"] * sBarScaling["barWidth"] * 0.01;
	tY = -tDebuffConfig["yAdjust"] * sBarScaling["barHeight"] * 0.01;

	if ("TOPLEFT" == tDebuffConfig["point"] or "BOTTOMLEFT" == tDebuffConfig["point"]) then
		tSign = 1;
	else
		tSign = -1;
	end

	for tCnt =  0, 4  do
		tIcon = VUHDO_getBarIcon(sButton, 40 + tCnt);
		tIcon:ClearAllPoints();
		tIcon:SetPoint(tDebuffConfig["point"], sHealthBar:GetName(), tDebuffConfig["point"],
			 tX + (tSign * tCnt * sBarScaling["barHeight"]), tY); -- center
		tIcon:SetWidth(sBarScaling["barHeight"]);
		tIcon:SetHeight(sBarScaling["barHeight"]);

		tTimer = VUHDO_getBarIconTimer(sButton, tCnt + 40);
		--tTimer:ClearAllPoints();
		tTimer:SetPoint("BOTTOMRIGHT", tIcon:GetName(), "BOTTOMRIGHT", 3, -3);
		tTimer:SetFont(VUHDO_FONT_HOTS, 18, tOutlineText);
		tTimer:SetShadowColor(0,  0, 0, tShadowAlpha);
		tTimer:SetShadowOffset(1, -0.5);

		tTimer:SetText("");
		tTimer:Show();

		tCounter = VUHDO_getBarIconCounter(sButton, tCnt + 40);
		--tCounter:ClearAllPoints();
		tCounter:SetPoint("TOPLEFT", tIcon:GetName(), "TOPLEFT", 0, 5);
		tCounter:SetFont(VUHDO_FONT_HOTS, 15, tOutlineText);
		tCounter:SetShadowColor(0,  0, 0, tShadowAlpha);
		tCounter:SetShadowOffset(1, -0.5);
		tCounter:SetTextColor(0, 1, 0, 1);

		tCounter:SetText("");
		tCounter:Show();

		tName = VUHDO_getBarIconName(sButton, tCnt + 40);
		--tName:ClearAllPoints();
		tName:SetPoint("BOTTOM", tIcon:GetName(), "TOP", 0, 0);
	  tName:SetFont(GameFontNormalSmall:GetFont(), 12, tOutlineText, "");
		tName:SetShadowColor(0,  0, 0, tShadowAlpha);
		tName:SetShadowOffset(1, -0.5);
		tName:SetTextColor(1, 1, 1, 1);
		tName:SetText("");
		tName:Show();
	end
end



--
local tX, tY;
local function VUHDO_initRaidIcon(aHealthBar, anIcon, aWidth)
	tX = sRaidIconSetup["xAdjust"] * aWidth * 0.01;
	tY = -sRaidIconSetup["yAdjust"] * sBarScaling["barHeight"] * 0.01;

	anIcon:ClearAllPoints();
	anIcon:SetPoint(sRaidIconSetup["point"], aHealthBar:GetName(), sRaidIconSetup["point"], tX, tY);
	anIcon:SetWidth(sBarScaling["barHeight"]  * sRaidIconSetup["scale"] /  1.5);
	anIcon:SetHeight(sBarScaling["barHeight"] * sRaidIconSetup["scale"] / 1.5);
	anIcon:Hide();
end



--
local tIcon, tHeight;
local function VUHDO_initSwiftmendIndicator()
	tIcon = VUHDO_getBarRoleIcon(sButton, 51);
	tIcon:ClearAllPoints();
	tIcon:SetPoint("CENTER",  sHealthBar:GetName(), "TOPLEFT",  sBarScaling["barWidth"] / 5.5, -sBarScaling["barHeight"]  / 14);
	tHeight = sHotIconSize * 0.5 * VUHDO_INDICATOR_CONFIG["CUSTOM"]["SWIFTMEND_INDICATOR"]["SCALE"];
	tIcon:SetWidth(tHeight);
	tIcon:SetHeight(tHeight);
	tIcon:Hide();
end



--
local tTgButton;
local tTgHealthBar;
local tBackgroundBar;
local function VUHDO_initTargetBar()
	if (sBarScaling["showTarget"]) then
		tTgButton = VUHDO_getTargetButton(sButton);
		tTgButton:SetAlpha(0);
		tTgButton:ClearAllPoints();

		if (sBarScaling["targetOrientation"] == 1) then
			tTgButton:SetPoint("TOPLEFT", sHealthBar:GetName(), "TOPRIGHT", sBarScaling["targetSpacing"],  0);
		else
			tTgButton:SetPoint("TOPRIGHT",  sHealthBar:GetName(), "TOPLEFT", -sBarScaling["targetSpacing"],  0);
		end

		tTgButton:SetWidth(sBarScaling["targetWidth"]);
		tTgButton:SetHeight(sBarScaling["barHeight"]);
		tTgButton:Show();

		tTgHealthBar = VUHDO_getHealthBar(sButton, 5);
		tTgHealthBar:SetValue(100);
		tTgHealthBar:SetHeight(sBarHeight);

		VUHDO_getBarText(tTgHealthBar):SetTextColor(sTargetColor["TR"], sTargetColor["TG"], sTargetColor["TB"], sTargetColor["TO"]);
		VUHDO_getLifeText(tTgHealthBar):SetTextColor(sTargetColor["TR"], sTargetColor["TG"], sTargetColor["TB"], sTargetColor["TO"]);

		VUHDO_initBackgroundBar(VUHDO_getHealthBar(sButton, 12));
		VUHDO_initManaBar(tTgButton, VUHDO_getHealthBar(sButton, 13), sBarScaling["targetWidth"], true);
		VUHDO_initRaidIcon(tTgHealthBar, VUHDO_getTargetBarRoleIcon(tTgButton, 50), sBarScaling["targetWidth"]);
		VUHDO_initBarTexts(tTgButton, tTgHealthBar, sBarScaling["targetWidth"]);
		VUHDO_initOverhealText(tTgHealthBar, sBarScaling["targetWidth"]);
		tBackgroundBar = VUHDO_getHealthBar(tTgButton, 3);
		if (VUHDO_INDICATOR_CONFIG["BOUQUETS"]["BACKGROUND_BAR"] ~= "") then
			tBackgroundBar:SetStatusBarColor(0, 0, 0, 0.4);
		else
			tBackgroundBar:SetStatusBarColor(0, 0, 0, 0);
		end
	else
		VUHDO_getTargetButton(sButton):Hide();
	end
end



--
local tTotButton;
local function VUHDO_initTotBar()
	if (sBarScaling["showTot"])  then
		tTotButton  = VUHDO_getTotButton(sButton);
		tTotButton:SetAlpha(0);
		tTotButton:ClearAllPoints();

		if (sBarScaling["targetOrientation"] == 1) then
			if (sBarScaling["showTarget"]) then
				tTgButton = VUHDO_getTargetButton(sButton);
				tTotButton:SetPoint("TOPLEFT",  tTgButton:GetName(), "TOPRIGHT", sBarScaling["totSpacing"],  0);
			else
				tTotButton:SetPoint("TOPLEFT",  sHealthBar:GetName(), "TOPRIGHT", sBarScaling["totSpacing"], 0);
			end
		else
			if (sBarScaling["showTarget"]) then
				tTgButton = VUHDO_getTargetButton(sButton);
				tTotButton:SetPoint("TOPRIGHT", tTgButton:GetName(), "TOPLEFT", -sBarScaling["totSpacing"],  0);
			else
				tTotButton:SetPoint("TOPRIGHT", sHealthBar:GetName(), "TOPLEFT", -sBarScaling["totSpacing"], 0);
			end
		end

		tTotButton:SetWidth(sBarScaling["totWidth"]);
		tTotButton:SetHeight(sBarScaling["barHeight"]);
		tTotButton:Show();

		tTgHealthBar = VUHDO_getHealthBar(sButton, 14);
		tTgHealthBar:SetValue(100);
		tTgHealthBar:SetHeight(sBarHeight);

		VUHDO_getBarText(tTgHealthBar):SetTextColor(sTotColor["TR"], sTotColor["TG"], sTotColor["TB"], sTotColor["TO"]);
		VUHDO_getLifeText(tTgHealthBar):SetTextColor(sTotColor["TR"], sTotColor["TG"], sTotColor["TB"], sTotColor["TO"]);

		VUHDO_initBackgroundBar(VUHDO_getHealthBar(sButton, 15));
		VUHDO_initManaBar(tTotButton, VUHDO_getHealthBar(sButton, 16), sBarScaling["totWidth"], true);
		VUHDO_initRaidIcon(tTgHealthBar, VUHDO_getTargetBarRoleIcon(tTotButton, 50), sBarScaling["totWidth"]);
		VUHDO_initBarTexts(tTgButton, tTgHealthBar, sBarScaling["totWidth"]);
		VUHDO_initOverhealText(tTgHealthBar, sBarScaling["totWidth"]);

		tBackgroundBar = VUHDO_getHealthBar(tTotButton, 3);
		if (VUHDO_INDICATOR_CONFIG["BOUQUETS"]["BACKGROUND_BAR"] ~= "") then
			tBackgroundBar:SetStatusBarColor(0, 0, 0, 0.4);
		else
			tBackgroundBar:SetStatusBarColor(0, 0, 0, 0);
		end
	else
		VUHDO_getTotButton(sButton):Hide();
	end
end



--
local tFlashBar;
local function VUHDO_initFlashBar()
	tFlashBar = VUHDO_GLOBAL[sButton:GetName() .. "BgBarIcBarHlBarFlBar"];
	tFlashBar:SetStatusBarTexture("Interface\\AddOns\\VuhDo\\Images\\white_square_16_16");
	tFlashBar:SetStatusBarColor(1, 0.8, 0.8, 1);
	tFlashBar:Hide();
end



--
function VUHDO_initReadyCheckIcon(aButton)
  VUHDO_getBarRoleIcon(aButton, 20):Hide();
end



--
local tHighlightBar;
local function VUHDO_initHighlightBar()
	tHighlightBar = VUHDO_getHealthBar(sButton, 8);
	tHighlightBar:SetAlpha(0);
	tHighlightBar:Show();
	VUHDO_setLlcStatusBarTexture(tHighlightBar, VUHDO_INDICATOR_CONFIG["CUSTOM"]["MOUSEOVER_HIGHLIGHT"]["TEXTURE"]);
	tHighlightBar:SetValue(0);
end



--
function VUHDO_initButtonStatics(aButton, aPanelNum)
	sButton = aButton;
	sHealthBar = VUHDO_getHealthBar(aButton,  1);
	sPanelSetup = VUHDO_PANEL_SETUP[aPanelNum];
end
local VUHDO_initButtonStatics = VUHDO_initButtonStatics;




--
local tCnt;
local tHealthBar, tIsInverted, tIsTurned, tIsVertical, tOrientation;

function VUHDO_initHealButton(aButton, aPanelNum)
	if (VUHDO_CONFIG["ON_MOUSE_UP"]) then
		aButton:RegisterForClicks("AnyUp");
	else
		aButton:RegisterForClicks("AnyDown");
	end

	-- Texture
	for tCnt =  1, 16 do
		tHealthBar = VUHDO_getHealthBar(aButton, tCnt);

		if (sStatusTexture ~= nil) then
			tHealthBar:SetStatusBarTexture(sStatusTexture);
		end
	end

	-- Invert Growth
	tIsInverted = VUHDO_INDICATOR_CONFIG["CUSTOM"]["HEALTH_BAR"]["invertGrowth"];
	VUHDO_getHealthBar(aButton, 1):SetIsInverted(tIsInverted);
	VUHDO_getHealthBar(aButton, 5):SetIsInverted(tIsInverted);
	VUHDO_getHealthBar(aButton, 6):SetIsInverted(tIsInverted);
	VUHDO_getHealthBar(aButton, 8):SetIsInverted(tIsInverted);
	VUHDO_getHealthBar(aButton, 14):SetIsInverted(tIsInverted);

	tIsInverted = VUHDO_INDICATOR_CONFIG["CUSTOM"]["MANA_BAR"]["invertGrowth"];
	VUHDO_getHealthBar(aButton, 2):SetIsInverted(tIsInverted);
	VUHDO_getHealthBar(aButton, 13):SetIsInverted(tIsInverted);
	VUHDO_getHealthBar(aButton, 16):SetIsInverted(tIsInverted);

	tIsInverted = VUHDO_INDICATOR_CONFIG["CUSTOM"]["THREAT_BAR"]["invertGrowth"];
	VUHDO_getHealthBar(aButton, 7):SetIsInverted(tIsInverted);

	-- Orient Health
	tIsTurned = VUHDO_INDICATOR_CONFIG["CUSTOM"]["HEALTH_BAR"]["turnAxis"];
	tIsVertical = VUHDO_INDICATOR_CONFIG["CUSTOM"]["HEALTH_BAR"]["vertical"]
	if (tIsVertical) then
		if (tIsTurned) then
			tOrientation = "VERTICAL_INV";
		else
			tOrientation = "VERTICAL";
		end
	else
		if (tIsTurned) then
			tOrientation = "HORIZONTAL_INV";
		else
			tOrientation = "HORIZONTAL";
		end
	end
	VUHDO_getHealthBar(aButton, 1):SetOrientation(tOrientation);
	VUHDO_getHealthBar(aButton, 5):SetOrientation(tOrientation);
	VUHDO_getHealthBar(aButton, 6):SetOrientation(tOrientation);
	VUHDO_getHealthBar(aButton, 8):SetOrientation(tOrientation);
	VUHDO_getHealthBar(aButton, 14):SetOrientation(tOrientation);

	-- Orient Mana
	tIsTurned = VUHDO_INDICATOR_CONFIG["CUSTOM"]["MANA_BAR"]["turnAxis"];
	if (tIsTurned) then
		tOrientation = "HORIZONTAL_INV";
	else
		tOrientation = "HORIZONTAL";
	end
	VUHDO_getHealthBar(aButton, 2):SetOrientation(tOrientation);
	VUHDO_getHealthBar(aButton, 13):SetOrientation(tOrientation);
	VUHDO_getHealthBar(aButton, 16):SetOrientation(tOrientation);

	-- Orient Threat
	tIsTurned = VUHDO_INDICATOR_CONFIG["CUSTOM"]["THREAT_BAR"]["turnAxis"];
	if (tIsTurned) then
		tOrientation = "HORIZONTAL_INV";
	else
		tOrientation = "HORIZONTAL";
	end
	VUHDO_getHealthBar(aButton, 7):SetOrientation(tOrientation);

	VUHDO_initButtonStatics(aButton, aPanelNum);
	VUHDO_initAggroTexture();
	VUHDO_initManaBar(sButton, VUHDO_getHealthBar(sButton,  2), sBarScaling["barWidth"], false);
	VUHDO_initBackgroundBar(VUHDO_getHealthBar(sButton, 3));
	VUHDO_initTargetBar();
	VUHDO_initTotBar();
	VUHDO_initIncomingBar();
	VUHDO_initThreatBar();
	VUHDO_initBarTexts(aButton, sHealthBar, sBarScaling["barWidth"]);
	VUHDO_initOverhealText(sHealthBar, sBarScaling["barWidth"]);
	VUHDO_initHighlightBar(aButton);

	VUHDO_initAggroBar();
	VUHDO_initHotBars();
	VUHDO_initAllHotIcons();
	VUHDO_initCustomDebuffs();
	VUHDO_initRaidIcon(sHealthBar, VUHDO_getBarRoleIcon(sButton, 50), sBarScaling["barWidth"]);
	VUHDO_initSwiftmendIndicator();
	VUHDO_initFlashBar();
	VUHDO_initReadyCheckIcon(aButton);

	if (VUHDO_CONFIG["IS_CLIQUE_COMPAT_MODE"]) then
		ClickCastFrames = ClickCastFrames or {};
		ClickCastFrames[aButton] = true;
		ClickCastFrames[VUHDO_GLOBAL[aButton:GetName() .. "Tg"]] = true;
		ClickCastFrames[VUHDO_GLOBAL[aButton:GetName() .. "Tot"]] = true;
	end
end

local VUHDO_initHealButton = VUHDO_initHealButton;



--
local tHealButton,  tGroupPanel;
local tCnt;
local tNumButtons;
local function VUHDO_initAllHealButtons(aPanel, aPanelNum)
	tNumButtons = VUHDO_getNumButtonsPanel(aPanelNum);
	for tCnt  = 1, tNumButtons do
		tHealButton = VUHDO_getOrCreateHealButton(tCnt, aPanelNum);
		VUHDO_initHealButton(tHealButton, aPanelNum);
	end

	for tCnt  = tNumButtons + 1, 51 do -- VUHDO_MAX_BUTTONS_PANEL
		tHealButton = VUHDO_getHealButton(tCnt, aPanelNum);
		if(tHealButton ~= nil) then
			tHealButton["raidid"] = nil;
			tHealButton["target"] = nil;
			tHealButton:SetAttribute("unit", nil);
			tHealButton:ClearAllPoints();
			tHealButton:Hide();
		else
			break;
		end
	end

	for tCnt = 1, 15 do -- VUHDO_MAX_GROUPS_PER_PANEL
		tGroupPanel = VUHDO_getGroupOrderPanel(aPanelNum, tCnt);
		VUHDO_initGroupOrderPanel(tGroupPanel);
		tGroupPanel = VUHDO_getGroupSelectPanel(aPanelNum,  tCnt);
		VUHDO_initGroupOrderPanel(tGroupPanel);
	end

end



--
local tSetup;
local tPosition;
local tPanelColor;
local tLabel;
local tWidth, tHeight;
local tGrowth;
local tScale;
local tFactor;
local tX, tY;

VUHDO_PROHIBIT_REPOS = false;

local function VUHDO_initPanel(aPanel, aPanelNum)
	tSetup  = VUHDO_PANEL_SETUP[aPanelNum];
	tPosition = tSetup["POSITION"];
	tPanelColor = tSetup["PANEL_COLOR"];

	tScale  = tSetup["SCALING"]["scale"];
	tFactor = tScale / aPanel:GetScale();

	tGrowth = tPosition["growth"];

	aPanel:ClearAllPoints();
	aPanel:SetWidth(tPosition["width"]);
	aPanel:SetHeight(tPosition["height"]);
	aPanel:SetScale(tScale);
	aPanel:SetPoint(tPosition["orientation"],  "UIParent", tPosition["relativePoint"],  tPosition["x"],  tPosition["y"]);
	aPanel:EnableMouseWheel(1);

  if (aPanel:IsShown()) then
  	tX, tY = VUHDO_getAnchorCoords(aPanel, tGrowth, tFactor);
  	aPanel:ClearAllPoints();
  	if (VUHDO_PROHIBIT_REPOS) then
  		aPanel:SetPoint(tGrowth,  "UIParent", "BOTTOMLEFT", tX, tY);
  	else
  		aPanel:SetPoint(tGrowth,  "UIParent", "BOTTOMLEFT", tX  * tFactor,  tY  * tFactor);
  	end
  end

	VUHDO_PANEL_SETUP[aPanelNum]["POSITION"]["orientation"] = tGrowth;

	tWidth  = VUHDO_getHealPanelWidth(aPanelNum);
	tHeight = VUHDO_getHealPanelHeight(aPanelNum);

	if (tHeight < 30) then
		tHeight = 30;
	end

	aPanel:SetWidth(tWidth);
	aPanel:SetHeight(tHeight);

	VUHDO_savePanelCoords(aPanel);

	tLabel = VUHDO_getPanelNumLabel(aPanel);

	VUHDO_STD_BACKDROP = aPanel:GetBackdrop();
	VUHDO_STD_BACKDROP["edgeFile"] = tPanelColor["BORDER"]["file"];
	VUHDO_STD_BACKDROP["edgeSize"] = tPanelColor["BORDER"]["edgeSize"];
	VUHDO_STD_BACKDROP["insets"]["left"] = tPanelColor["BORDER"]["insets"];
	VUHDO_STD_BACKDROP["insets"]["right"] = tPanelColor["BORDER"]["insets"];
	VUHDO_STD_BACKDROP["insets"]["top"] = tPanelColor["BORDER"]["insets"];
	VUHDO_STD_BACKDROP["insets"]["bottom"] = tPanelColor["BORDER"]["insets"];

	aPanel:SetBackdrop(VUHDO_STD_BACKDROP);
	aPanel:SetBackdropBorderColor(
		tPanelColor["BORDER"]["R"],
		tPanelColor["BORDER"]["G"],
		tPanelColor["BORDER"]["B"],
		tPanelColor["BORDER"]["O"]
	);

	if (VUHDO_IS_PANEL_CONFIG) then
		tLabel:SetText("[PANEL "  .. aPanelNum .. "]");
		tLabel:GetParent():ClearAllPoints();
		tLabel:GetParent():SetPoint("BOTTOM", aPanel:GetName(), "TOP", 0, 3);
		tLabel:GetParent():Show();

		if (DESIGN_MISC_PANEL_NUM ~= nil and DESIGN_MISC_PANEL_NUM == aPanelNum
			and VuhDoNewOptionsPanelPanel ~= nil and VuhDoNewOptionsPanelPanel:IsVisible()) then
			VUHDO_DESIGN_BACKDROP = VUHDO_deepCopyTable(VUHDO_STD_BACKDROP);
			tLabel:SetTextColor(0, 1, 0, 1);
			UIFrameFlash(tLabel, 0.6, 0.6, 10000, true, 0.7, 0);

			aPanel:SetBackdrop(VUHDO_DESIGN_BACKDROP);
			aPanel:SetBackdropBorderColor(1, 1, 1, 1);
		else
			aPanel:SetBackdrop(VUHDO_STD_BACKDROP);
			tLabel:SetTextColor(0.4,  0.4, 0.4, 1);
			UIFrameFlashRemoveFrame(tLabel);
			aPanel:SetBackdropBorderColor(
				tPanelColor["BORDER"]["R"],
				tPanelColor["BORDER"]["G"],
				tPanelColor["BORDER"]["B"],
				tPanelColor["BORDER"]["O"]
			);
		end

		if (DESIGN_MISC_PANEL_NUM ~= nil) then
			VuhDoNewOptionsTabbedFramePanelNumLabelLabel:SetText(VUHDO_I18N_PANEL .. " #" .. DESIGN_MISC_PANEL_NUM);
			VuhDoNewOptionsTabbedFramePanelNumLabelLabel:Show();
		else
			VuhDoNewOptionsTabbedFramePanelNumLabelLabel:Hide();
		end

		if (not VUHDO_CONFIG_SHOW_RAID) then
			VUHDO_GLOBAL[aPanel:GetName() .. "NewTxu"]:Show();
			VUHDO_GLOBAL[aPanel:GetName() .. "ClrTxu"]:Show();
		else
			VUHDO_GLOBAL[aPanel:GetName() .. "NewTxu"]:Hide();
			VUHDO_GLOBAL[aPanel:GetName() .. "ClrTxu"]:Hide();
		end
	else
		VUHDO_GLOBAL[aPanel:GetName() .. "NewTxu"]:Hide();
		VUHDO_GLOBAL[aPanel:GetName() .. "ClrTxu"]:Hide();
		tLabel:GetParent():Hide();
		tLabel:GetParent():ClearAllPoints();
		if (VuhDoNewOptionsTabbedFrame ~= nil) then
			VuhDoNewOptionsTabbedFramePanelNumLabelLabel:Hide();
		end
	end

	aPanel:SetBackdropColor(
		tPanelColor["BACK"]["R"],
		tPanelColor["BACK"]["G"],
		tPanelColor["BACK"]["B"],
		tPanelColor["BACK"]["O"]
	);

	if (VUHDO_CONFIG["LOCK_CLICKS_THROUGH"]) then
		aPanel:EnableMouse(false);
	else
		aPanel:EnableMouse(true);
	end

	aPanel:StopMovingOrSizing();
	aPanel["isMoving"] = false;
end



--
local tPanel;
function VUHDO_redrawPanel(aPanelNum)

	if (VUHDO_isPanelPopulated(aPanelNum)) then
		tPanel = VUHDO_getActionPanel(aPanelNum);
		VUHDO_initLocalVars(aPanelNum);
		VUHDO_initAllHealButtons(tPanel, aPanelNum);

		if (VUHDO_isConfigPanelShowing()) then
			VUHDO_positionAllGroupConfigPanels(aPanelNum);
		else
			VUHDO_positionAllHealButtons(tPanel, aPanelNum);
		end

		VUHDO_positionTableHeaders(tPanel,  aPanelNum);
		VUHDO_initPanel(tPanel, aPanelNum);
		if (VUHDO_isPanelVisible(aPanelNum)) then
			tPanel:Show();
		else
			tPanel:Hide();
		end
	else
		VUHDO_getActionPanel(aPanelNum):Hide();
	end
end
local VUHDO_redrawPanel = VUHDO_redrawPanel;



--
local tCnt, tGcdCol;
function VUHDO_redrawAllPanels()
  VUHDO_resetMacroCaches();
	resetSizeCalcCaches();
	twipe(VUHDO_UNIT_BUTTONS);

	tBackdrop = nil;
	tBackdropCluster = nil;
	for tCnt  = 1, 10 do -- VUHDO_MAX_PANELS
		VUHDO_redrawPanel(tCnt);
	end

	VUHDO_updateAllRaidBars();

	-- GCD bar
	VuhDoGcdStatusBar:SetFrameStrata("HIGH");
	tGcdCol = VUHDO_PANEL_SETUP["BAR_COLORS"]["GCD_BAR"];
	VuhDoGcdStatusBar:SetStatusBarColor(tGcdCol["R"], tGcdCol["G"], tGcdCol["B"], tGcdCol["O"]);
	VuhDoGcdStatusBar:SetStatusBarTexture("Interface\\AddOns\\VuhDo\\Images\\white_square_16_16");
	VuhDoGcdStatusBar:SetValue(0);
	VuhDoGcdStatusBar:Hide();

	-- Direction arrow
	VuhDoDirectionFrameArrow:SetVertexColor(1, 0.4, 0.4);
	VuhDoDirectionFrameText:SetFont(VUHDO_getFont(VUHDO_PANEL_SETUP["HOTS"]["font"]), 6, "OUTLINE");
	VuhDoDirectionFrameText:SetPoint("TOP", "VuhDoDirectionFrameArrow", "CENTER", 5,  -2);

	VUHDO_initAllEventBouquets();
end
local VUHDO_redrawAllPanels = VUHDO_redrawAllPanels;



--
function VUHDO_reloadUI()
	if (InCombatLockdown()) then
		return;
	end

	VUHDO_IS_RELOADING = true;

	VUHDO_reloadRaidMembers();
	VUHDO_resetNameTextCache();
	if (not VUHDO_IN_COMBAT_RELOG) then
		twipe(VUHDO_FAST_ACCESS_ACTIONS);
	end

	VUHDO_redrawAllPanels();
	VUHDO_updateAllCustomDebuffs(true);
	VUHDO_rebuildTargets();
	VUHDO_IS_RELOADING = false;
	VUHDO_reloadBuffPanel();
end



--
function VUHDO_lnfReloadUI()
	if (InCombatLockdown()) then
		return;
	end
	VUHDO_IS_RELOADING = true;

	VUHDO_initAllBurstCaches();
	VUHDO_refreshRaidMembers();
	--VUHDO_reloadRaidMembers();
	VUHDO_redrawAllPanels();
	--VUHDO_updateAllCustomDebuffs(false);
	--VUHDO_rebuildTargets();
	VUHDO_buildGenericHealthBarBouquet();
	VUHDO_bouqetsChanged();
	VUHDO_initAllBurstCaches();
	collectgarbage('collect');
	VUHDO_IS_RELOADING = false;
end
