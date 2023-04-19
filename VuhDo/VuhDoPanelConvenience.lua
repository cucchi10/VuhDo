local VUHDO_GLOBAL = getfenv();
local pairs = pairs;

-- Fast caches
local VUHDO_HEALTH_BAR = { };
local VUHDO_HEAL_BUTTON = { };
local VUHDO_BUFF_SWATCHES = { };
local VUHDO_BUFF_PANELS = { };

local VUHDO_BAR_ICON_FRAMES = { };
local VUHDO_BAR_ICONS = { };
local VUHDO_BAR_ICON_TIMERS = { };
local VUHDO_BAR_ICON_COUNTERS = { };
local VUHDO_BAR_ICON_CHARGES = { };
local VUHDO_BAR_ICON_NAMES = { };


VUHDO_BUTTON_CACHE = { };
local VUHDO_BUTTON_CACHE = VUHDO_BUTTON_CACHE;



--
function VUHDO_getBarRoleIcon(aButton, anIconNumber)
  return VUHDO_GLOBAL[aButton:GetName() .. "BgBarIcBarHlBarIc" .. anIconNumber];
end



--
function VUHDO_getTargetBarRoleIcon(aButton, anIconNumber)
  return VUHDO_GLOBAL[aButton:GetName() .. "BgBarHlBarIc" .. anIconNumber];
end



--
function VUHDO_getBarIconFrame(aButton, anIconNumber)
  return VUHDO_BAR_ICON_FRAMES[aButton][anIconNumber];
end



--
function VUHDO_getBarIcon(aButton, anIconNumber)
  return VUHDO_BAR_ICONS[aButton][anIconNumber];
end



--
function VUHDO_getBarIconTimer(aButton, anIconNumber)
	return VUHDO_BAR_ICON_TIMERS[aButton][anIconNumber];
end



--
function VUHDO_getBarIconCounter(aButton, anIconNumber)
	return VUHDO_BAR_ICON_COUNTERS[aButton][anIconNumber];
end



--
function VUHDO_getBarIconCharge(aButton, anIconNumber)
	return VUHDO_BAR_ICON_CHARGES[aButton][anIconNumber];
end



--
function VUHDO_getBarIconName(aButton, anIconNumber)
	return VUHDO_BAR_ICON_NAMES[aButton][anIconNumber];
end



--
function VUHDO_getRaidTargetTexture(aTargetBar)
	return VUHDO_GLOBAL[aTargetBar:GetName() .. "TgTxu"];
end



--
function VUHDO_getRaidTargetTextureFrame(aTargetBar)
	return VUHDO_GLOBAL[aTargetBar:GetName() .. "Tg"];
end



--
function VUHDO_getGroupOrderLabel2(aGroupOrderPanel)
  return VUHDO_GLOBAL[aGroupOrderPanel:GetName() .. "DrgLbl2Lbl"];
end



--
function VUHDO_getPanelNumLabel(aPanel)
  return VUHDO_GLOBAL[aPanel:GetName() .. "GrpLblLbl"];
end



--
function VUHDO_getGroupOrderPanel(aParentPanelNum, aPanelNum)
	return VUHDO_GLOBAL["VdAc" .. aParentPanelNum .. "GrpOrd" .. aPanelNum];
end



--
function VUHDO_getGroupSelectPanel(aParentPanelNum, aPanelNum)
	return VUHDO_GLOBAL["VdAc" .. aParentPanelNum .. "GrpSel" .. aPanelNum];
end



--
function VUHDO_getActionPanel(aPanelNum)
  return VUHDO_GLOBAL["VdAc" .. aPanelNum];
end



--
function VUHDO_getHealthBar(aButton, aBarNumber)
	return VUHDO_HEALTH_BAR[aButton][aBarNumber];
end



--
function VUHDO_getHeaderBar(aButton)
  return VUHDO_GLOBAL[aButton:GetName() .. "Bar"];
end



--
function VUHDO_getPlayerTargetFrame(aButton)
  return VUHDO_GLOBAL[VUHDO_HEALTH_BAR[aButton][1]:GetName() .. "PlTg"];
end


--
function VUHDO_getPlayerTargetFrameTarget(aButton)
  return VUHDO_GLOBAL[aButton:GetName() .. "TgPlTg"];
end



--
function VUHDO_getPlayerTargetFrameToT(aButton)
  return VUHDO_GLOBAL[aButton:GetName() .. "TotPlTg"];
end



--
function VUHDO_getClusterBorderFrame(aButton)
  return VUHDO_GLOBAL[VUHDO_HEALTH_BAR[aButton][1]:GetName() .. "Clu"];
end



--
function VUHDO_getTargetButton(aButton)
	return VUHDO_GLOBAL[aButton:GetName() .. "Tg"];
end



--
function VUHDO_getTotButton(aButton)
	return VUHDO_GLOBAL[aButton:GetName() .. "Tot"];
end



--
function VUHDO_getHealButton(aButtonNum, aPanelNum)
	return VUHDO_HEAL_BUTTON[aPanelNum][aButtonNum];
end



--
function VUHDO_getTextPanel(aBar)
	return VUHDO_GLOBAL[aBar:GetName() .. "TxPnl"];
end



--
function VUHDO_getBarText(aBar)
	return VUHDO_GLOBAL[aBar:GetName() .. "TxPnlUnN"];
end



--
function VUHDO_getHeaderTextId(aHeader)
	return VUHDO_GLOBAL[aHeader:GetName() .. "BarUnN"];
end



--
function VUHDO_getLifeText(aBar)
	return VUHDO_GLOBAL[aBar:GetName() .. "TxPnlLife"];
end



--
function VUHDO_getOverhealPanel(aBar)
	return VUHDO_GLOBAL[aBar:GetName() .. "OvhPnl"];
end



--
function VUHDO_getOverhealText(aBar)
	return VUHDO_GLOBAL[aBar:GetName() .. "OvhPnlT"];
end



--
function VUHDO_getHeader(aHeaderNo, aPanelNum)
	return VUHDO_GLOBAL["VdAc" .. aPanelNum .. "Hd" .. aHeaderNo];
end



--
local tButton;
function VUHDO_getOrCreateBuffSwatch(aName, aParent)

	if (VUHDO_BUFF_SWATCHES[aName] == nil) then
		VUHDO_BUFF_SWATCHES[aName] = CreateFrame("Frame", aName, aParent, "VuhDoBuffSwatchPanelTemplate");
		tButton = VUHDO_GLOBAL[aName .. "GlassButton"];

		tButton:SetAttribute("_onleave", [=[
			self:ClearBindings();
		]=]);

		tButton:SetAttribute("_onshow", [=[
			self:ClearBindings();
		]=]);

		tButton:SetAttribute("_onhide", [=[
			self:ClearBindings();
		]=]);
	else
		tButton = VUHDO_GLOBAL[aName .. "GlassButton"];
	end

	if (VUHDO_BUFF_SETTINGS["CONFIG"]["WHEEL_SMART_BUFF"]) then
		tButton:SetAttribute("_onenter", [=[
				self:ClearBindings();
				self:SetBindingClick(0, "MOUSEWHEELUP" , "VuhDoSmartCastGlassButton", "LeftButton");
				self:SetBindingClick(0, "MOUSEWHEELDOWN" , "VuhDoSmartCastGlassButton", "LeftButton");
		]=]);
	else
		tButton:SetAttribute("_onenter", [=[
			self:ClearBindings();
		]=]);
	end

	return VUHDO_BUFF_SWATCHES[aName];
end



--
function VUHDO_getOrCreateBuffPanel(aName)
	if (VUHDO_BUFF_PANELS[aName] == nil) then
		VUHDO_BUFF_PANELS[aName] = CreateFrame("Frame", aName, VuhDoBuffWatchMainFrame, "VuhDoBuffWatchBuffTemplate");
	end

	return VUHDO_BUFF_PANELS[aName];
end



--
function VUHDO_resetAllBuffPanels()
	VUHDO_resetAllBuffSwatches();

	local tPanel;

	for _, tPanel in pairs(VUHDO_BUFF_SWATCHES) do
		tPanel:Hide();
		tPanel:ClearAllPoints();
	end

	for _, tPanel in pairs(VUHDO_BUFF_PANELS) do
		tPanel:Hide();
		tPanel:ClearAllPoints();
	end
end



--
function VUHDO_resetAllBuffSwatches()
	local tSwatch;
	for _, tSwatch in pairs(VUHDO_BUFF_SWATCHES) do
		tSwatch:Hide();
		tSwatch:ClearAllPoints();
	end
end



--
function VUHDO_getAllBuffSwatches()
	return VUHDO_BUFF_SWATCHES;
end



--
function VUHDO_getAggroTexture(aHealthBar)
	return VUHDO_GLOBAL[aHealthBar:GetName() .. "Aggro"];
end



--
local VUHDO_STATUSBAR_LEFT_TO_RIGHT = 1;
local VUHDO_STATUSBAR_RIGHT_TO_LEFT = 2;
local VUHDO_STATUSBAR_BOTTOM_TO_TOP = 3;
local VUHDO_STATUSBAR_TOP_TO_BOTTOM = 4;
function VUHDO_repairStatusbar(tBar)
	tBar["texture"] = tBar:CreateTexture(nil, "ARTWORK");
	tBar["txOrient"] = VUHDO_STATUSBAR_LEFT_TO_RIGHT;
	tBar["value"] = 0;
	tBar["isInverted"] = false;
  tBar["tValue"] = nil;
  tBar["tWidth"] = nil;
  tBar["tHeight"] = nil;


	tBar["SetStatusBarColor"] = function(self, r, g, b, a)
		self["texture"]:SetVertexColor(r, g, b, a);
	end



	tBar["GetStatusBarColor"] = function(self)
		return self["texture"]:GetVertexColor();
	end



	tBar["SetAlpha"] = function(self, a)
		self["texture"]:SetAlpha(a);
	end



	tBar["SetValue"] = function(self, aValue)
		if ((aValue or -1) < 0) then
			aValue = 0;
		elseif (aValue > 100) then
			aValue = 100;
		end

		self["value"] = aValue;
		aValue = aValue * 0.01;
		if (self["isInverted"]) then
			aValue = 1 - aValue;
		end

		if (1 == self["txOrient"]) then -- VUHDO_STATUSBAR_LEFT_TO_RIGHT
			self["texture"]:SetTexCoord(0, aValue, 0, 1);
			self["texture"]:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", (aValue - 1) * self:GetWidth(), 0);

		elseif (2 == self["txOrient"]) then -- VUHDO_STATUSBAR_RIGHT_TO_LEFT
			self["texture"]:SetTexCoord(1 - aValue, 1, 0, 1);
			self["texture"]:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", (1 - aValue) * self:GetWidth(), 0);

		elseif (3 == self["txOrient"]) then -- VUHDO_STATUSBAR_BOTTOM_TO_TOP
			self["texture"]:SetTexCoord(0, 1, 1 - aValue, 1);
			self["texture"]:SetPoint("TOPLEFT", self, "TOPLEFT", 0, (aValue - 1) * self:GetHeight());

		else --if (VUHDO_STATUSBAR_TOP_TO_BOTTOM == self["txOrient"]) then
			self["texture"]:SetTexCoord(0, 1, 0, aValue);
			self["texture"]:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, (1 - aValue) * self:GetHeight());
		end
	end



	tBar["SetValueRange"] = function(self, aMinValue, aMaxValue)

		if ((aMinValue or -1) < 0) then
			aMinValue = 0;
		elseif (aMinValue > 100) then
			aMinValue = 100;
		end

		if ((aMaxValue or -1) < 0) then
			aMaxValue = 0;
		elseif (aMaxValue > 100) then
			aMaxValue = 100;
		end

		tValue = aMaxValue - aMinValue;
		self["value"] = tValue;
		tValue = tValue * 0.01;

		aMinValue = aMinValue * 0.01;
		aMaxValue = aMaxValue * 0.01;
		if (self["isInverted"]) then
			tValue = 1 - tValue;
			aMinValue, aMaxValue = 1 - aMaxValue, 1 - aMinValue;
		end

		if (1 == self["txOrient"]) then -- VUHDO_STATUSBAR_LEFT_TO_RIGHT
			tWidth = self:GetWidth();
			self["texture"]:SetTexCoord(0, tValue, 0, 1);
			self["texture"]:SetPoint("TOPLEFT", self, "TOPLEFT", aMinValue * tWidth, 0);
			self["texture"]:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", (aMaxValue - 1) * tWidth, 0);

		elseif (2 == self["txOrient"]) then -- VUHDO_STATUSBAR_RIGHT_TO_LEFT
			tWidth = self:GetWidth();
			self["texture"]:SetTexCoord(1 - tValue, 1, 0, 1);
			self["texture"]:SetPoint("TOPRIGHT", self, "TOPRIGHT", -aMinValue * tWidth, 0);
			self["texture"]:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", (1 - aMaxValue) * tWidth, 0);

		elseif (3 == self["txOrient"]) then -- VUHDO_STATUSBAR_BOTTOM_TO_TOP
			tHeight = self:GetHeight();
			self["texture"]:SetTexCoord(0, 1, 1 - tValue, 1);
			self["texture"]:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, aMinValue * tHeight);
			self["texture"]:SetPoint("TOPLEFT", self, "TOPLEFT", 0, (aMaxValue - 1) * tHeight);

		else --if (VUHDO_STATUSBAR_TOP_TO_BOTTOM == self["txOrient"]) then
			tHeight = self:GetHeight();
			self["texture"]:SetTexCoord(0, 1, 0, tValue);
			self["texture"]:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -aMinValue * tHeight);
			self["texture"]:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, (1 - aMaxValue) * tHeight);
		end
	end



	tBar["GetValue"] = function(self)
		return self["value"];
	end



	tBar["SetStatusBarTexture"] = function(self, aTexture)
		self["texture"]:SetTexture(aTexture);
	end



	tBar["SetMinMaxValues"] = function(self, aMinValue, aMaxValue)
		-- Dummy
	end



	tBar["SetOrientation"] = function(self, anOrientation)
		self["texture"]:ClearAllPoints();

		if ("HORIZONTAL" == anOrientation) then
			self["texture"]:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0);
			self["txOrient"] = VUHDO_STATUSBAR_LEFT_TO_RIGHT;
		elseif ("HORIZONTAL_INV" == anOrientation) then
			self["texture"]:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0);
			self["txOrient"] = VUHDO_STATUSBAR_RIGHT_TO_LEFT;
		elseif ("VERTICAL" == anOrientation) then
			self["texture"]:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0);
			self["txOrient"] = VUHDO_STATUSBAR_BOTTOM_TO_TOP;
		else -- VERTICAL_INV
			self["texture"]:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0);
			self["txOrient"] = VUHDO_STATUSBAR_TOP_TO_BOTTOM;
		end

		self:SetValue(self["value"]);
	end



	tBar["SetIsInverted"] = function(self, anIsInverted)
		self["isInverted"] = anIsInverted;
	end



	tBar["SetOrientation"](tBar, "HORIZONTAL");
	return tBar;
end



--
local tPrefix;
local function VUHDO_initIconCounterTimerStacks(aButton, anIndex)
	tPrefix = aButton:GetName() .. "BgBarIcBarHlBarIc" .. anIndex;
	VUHDO_BAR_ICON_FRAMES[aButton][anIndex] = VUHDO_GLOBAL[tPrefix];
	VUHDO_BAR_ICONS[aButton][anIndex] = VUHDO_GLOBAL[tPrefix .. "I"];
	VUHDO_BAR_ICON_TIMERS[aButton][anIndex] = VUHDO_GLOBAL[tPrefix .. "T"];
	VUHDO_BAR_ICON_COUNTERS[aButton][anIndex] = VUHDO_GLOBAL[tPrefix .. "C"];
	VUHDO_BAR_ICON_CHARGES[aButton][anIndex] = VUHDO_GLOBAL[tPrefix .. "A"];
	VUHDO_BAR_ICON_NAMES[aButton][anIndex] = VUHDO_GLOBAL[tPrefix .. "N"];
end



--
local function VUHDO_fastCacheInitButton(aPanelNum, aButtonNum)
	local tButtonName = "VdAc" .. aPanelNum .. "HlU" .. aButtonNum;
	local tButton = VUHDO_GLOBAL[tButtonName];
	local tTargetButton = VUHDO_GLOBAL[tButtonName .. "Tg"];
	local tTotButton = VUHDO_GLOBAL[tButtonName .. "Tot"];

	VUHDO_HEALTH_BAR[tButton] = { };
	VUHDO_HEALTH_BAR[tTargetButton] = { };
	VUHDO_HEALTH_BAR[tTotButton] = { };

	--Health
	VUHDO_HEALTH_BAR[tButton][1] = VUHDO_GLOBAL[tButtonName .. "BgBarIcBarHlBar"];
	-- Mana
	VUHDO_HEALTH_BAR[tButton][2] = VUHDO_GLOBAL[tButtonName .. "BgBarIcBarHlBarMaBar"];
	-- Background
	VUHDO_HEALTH_BAR[tButton][3] = VUHDO_GLOBAL[tButtonName .. "BgBar"];
	-- Aggro
	VUHDO_HEALTH_BAR[tButton][4] = VUHDO_GLOBAL[tButtonName .. "BgBarIcBarHlBarAgBar"];
	-- Target Health
	VUHDO_HEALTH_BAR[tButton][5] = VUHDO_GLOBAL[tButtonName .. "TgBgBarHlBar"];
	VUHDO_HEALTH_BAR[tTargetButton][1] = VUHDO_GLOBAL[tButtonName .. "TgBgBarHlBar"];
	-- Incoming
	VUHDO_HEALTH_BAR[tButton][6] = VUHDO_GLOBAL[tButtonName .. "BgBarIcBar"];
	VUHDO_HEALTH_BAR[tTargetButton][6] = VuhDoDummyStatusBar;
	VUHDO_HEALTH_BAR[tTotButton][6] = VuhDoDummyStatusBar;
	-- Threat
	VUHDO_HEALTH_BAR[tButton][7] = VUHDO_GLOBAL[tButtonName .. "ThBar"];
	-- Group Highlight
	VUHDO_HEALTH_BAR[tButton][8] = VUHDO_GLOBAL[tButtonName .. "BgBarIcBarHlBarHiBar"];
	VUHDO_HEALTH_BAR[tTargetButton][8] = VuhDoDummyStatusBar;
	VUHDO_HEALTH_BAR[tTotButton][8] = VuhDoDummyStatusBar;
	-- HoT 1
	VUHDO_HEALTH_BAR[tButton][9] = VUHDO_GLOBAL[tButtonName .. "BgBarIcBarHlBarHotBar1"];
	-- HoT 2
	VUHDO_HEALTH_BAR[tButton][10] = VUHDO_GLOBAL[tButtonName .. "BgBarIcBarHlBarHotBar2"];
	-- HoT 3
	VUHDO_HEALTH_BAR[tButton][11] = VUHDO_GLOBAL[tButtonName .. "BgBarIcBarHlBarHotBar3"];

	-- Target Background
	VUHDO_HEALTH_BAR[tButton][12] = VUHDO_GLOBAL[tButtonName .. "TgBgBar"];
	VUHDO_HEALTH_BAR[tTargetButton][3] = VUHDO_GLOBAL[tButtonName .. "TgBgBar"];
	-- Target Mana
	VUHDO_HEALTH_BAR[tButton][13] = VUHDO_GLOBAL[tButtonName .. "TgBgBarHlBarMaBar"];
	VUHDO_HEALTH_BAR[tTargetButton][2] = VUHDO_GLOBAL[tButtonName .. "TgBgBarHlBarMaBar"];

	-- Tot Health
	VUHDO_HEALTH_BAR[tButton][14] = VUHDO_GLOBAL[tButtonName .. "TotBgBarHlBar"];
	VUHDO_HEALTH_BAR[tTotButton][1] = VUHDO_GLOBAL[tButtonName .. "TotBgBarHlBar"];
	-- Tot Background
	VUHDO_HEALTH_BAR[tButton][15] = VUHDO_GLOBAL[tButtonName .. "TotBgBar"];
	VUHDO_HEALTH_BAR[tTotButton][3] = VUHDO_GLOBAL[tButtonName .. "TotBgBar"];
	-- Tot Mana
	VUHDO_HEALTH_BAR[tButton][16] = VUHDO_GLOBAL[tButtonName .. "TotBgBarHlBarMaBar"];
	VUHDO_HEALTH_BAR[tTotButton][2] = VUHDO_GLOBAL[tButtonName .. "TotBgBarHlBarMaBar"];

	VUHDO_HEAL_BUTTON[aPanelNum][aButtonNum] = tButton;
	VUHDO_BUTTON_CACHE[tButton] = aPanelNum;
	VUHDO_BUTTON_CACHE[tTargetButton] = aPanelNum;
	VUHDO_BUTTON_CACHE[tTotButton] = aPanelNum;

	VUHDO_BAR_ICON_FRAMES[tButton] = { };
	VUHDO_BAR_ICONS[tButton] = { };
	VUHDO_BAR_ICON_TIMERS[tButton] = { };
	VUHDO_BAR_ICON_COUNTERS[tButton] = { };
	VUHDO_BAR_ICON_CHARGES[tButton] = { };
	VUHDO_BAR_ICON_NAMES[tButton] = { };

	local tCnt;
	for tCnt = 1, 5 do
		VUHDO_initIconCounterTimerStacks(tButton, tCnt);
	end
	VUHDO_initIconCounterTimerStacks(tButton, 9);
	for tCnt = 40, 44 do
		VUHDO_initIconCounterTimerStacks(tButton, tCnt);
	end
end



--
function VUHDO_getOrCreateHealButton(aButtonNum, aPanelNum)
	if (VUHDO_HEAL_BUTTON[aPanelNum][aButtonNum] == nil) then
		local tNewButton = CreateFrame("Button", "VdAc" .. aPanelNum .. "HlU" .. aButtonNum, VUHDO_GLOBAL["VdAc" .. aPanelNum], "VuhDoButtonSecureTemplate");
		VUHDO_fastCacheInitButton(aPanelNum, aButtonNum);
		VUHDO_initLocalVars(aPanelNum);
		VUHDO_initHealButton(tNewButton, aPanelNum);
		VUHDO_positionHealButton(tNewButton);
	end
	return VUHDO_HEAL_BUTTON[aPanelNum][aButtonNum];
end



--
function VUHDO_getPanelButtons(aPanelNum)
  return VUHDO_HEAL_BUTTON[aPanelNum];
end



--
function VUHDO_initFastCache()
	local tCnt;
	for tCnt = 1, VUHDO_MAX_PANELS do
		VUHDO_HEAL_BUTTON[tCnt] = { };
	end
end
