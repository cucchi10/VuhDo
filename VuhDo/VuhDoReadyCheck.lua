local VUHDO_IS_ON_READY_CHECK = false;



--
local function VUHDO_placeReadyIcon(aButton)
	local tUnit = VUHDO_resolveButtonUnit(aButton);
	local tInfo = VUHDO_RAID[tUnit];
	local tIcon = VUHDO_getBarRoleIcon(aButton, 20);

	if (tInfo == nil or tInfo.isPet) then
		tIcon:Hide();
	else
		UIFrameFlashRemoveFrame(tIcon);
		tIcon:SetTexture("Interface\\AddOns\\VuhDo\\Images\\icon_info");
		tIcon:ClearAllPoints();
		tIcon:SetPoint("LEFT", aButton:GetName(), "LEFT", -5, 0);
		tIcon:SetWidth(16);
		tIcon:SetHeight(16);
		tIcon:Show();
	end
end



--
local function VUHDO_placeAllReadyIcons()
	local tPanelNum;
	local tAllButtons;
	local tButton;

	for tPanelNum = 1, VUHDO_MAX_PANELS do
		tAllButtons = VUHDO_getPanelButtons(tPanelNum);

		for _, tButton in pairs(tAllButtons) do
			if (tButton:GetAttribute("unit") ~= nil) then
				VUHDO_placeReadyIcon(tButton);
			else
				break;
			end
		end
	end
end



--
local function VUHDO_hideAllReadyIcons()
	local tPanelNum;
	local tAllButtons;
	local tPanel;
	local tButton;

	for tPanelNum = 1, VUHDO_MAX_PANELS do
		tAllButtons = VUHDO_getPanelButtons(tPanelNum);

		for _, tButton in pairs(tAllButtons) do
			if (tButton:GetAttribute("unit") ~= nil) then
				UIFrameFlash(VUHDO_getBarRoleIcon(tButton, 20), 0, 2, 10, false, 0, 8);
			else
				break;
			end
		end
	end
end



--
function VUHDO_readyCheckStarted()
	VUHDO_IS_ON_READY_CHECK = true;
	VUHDO_hideAllPlayerIcons();
	VUHDO_placeAllReadyIcons();
end



-- Status true = ready, nil = not ready
local function VUHDO_updateReadyIcon(aUnit, anIsReady)
	local tAllButtons = VUHDO_getUnitButtons(aUnit);
	if (tAllButtons == nil) then
		return;
	end

	local tTexture;
	if (anIsReady) then
		tTexture = "Interface\\AddOns\\VuhDo\\Images\\icon_check_2";
	else
		tTexture = "Interface\\AddOns\\VuhDo\\Images\\icon_cancel_1";
	end

	local tButton;
	for _, tButton in pairs(tAllButtons) do
		VUHDO_getBarRoleIcon(tButton, 20):SetTexture(tTexture);
	end
end



--
function VUHDO_readyCheckConfirm(aUnit, anIsReady)
	if (VUHDO_RAID[aUnit] == nil) then
		return;
	end

	if (not VUHDO_IS_ON_READY_CHECK) then
		VUHDO_readyCheckStarted();
	end

	VUHDO_updateReadyIcon(aUnit, anIsReady);
end



--
function VUHDO_readyStartCheck(aName, aDuration)
	if (VUHDO_RAID_NAMES[aName] ~= nil) then
		VUHDO_readyCheckConfirm(VUHDO_RAID_NAMES[aName], true); -- Originator is always ready
	end
end



--
function VUHDO_readyCheckEnds()
	if (not VUHDO_IS_ON_READY_CHECK) then -- Client send READY_CHECK_ENDS on startup
		return;
	end

	VUHDO_hideAllReadyIcons();
	VUHDO_IS_ON_READY_CHECK = false;
end
