


--
local tHotNum;
function VUHDO_initHotTimerRadioButton(aButton, aMode)
	tHotNum = VUHDO_getNumbersFromString(aButton:GetName(), 1)[1];
	VUHDO_lnfSetRadioModel(aButton, "VUHDO_PANEL_SETUP.BAR_COLORS.HOT" .. tHotNum .. ".countdownMode", aMode);
end



--
local tHotNum;
function VUHDO_initHotTimerCheckButton(aButton)
	tHotNum = VUHDO_getNumbersFromString(aButton:GetName(), 1)[1];
	VUHDO_lnfSetModel(aButton, "VUHDO_PANEL_SETUP.BAR_COLORS.HOT" .. tHotNum .. ".isFullDuration");
end



--
local tHotName;
function	VUHDO_colorsHotsSetSwatchHotName(aTexture, aHotNum)
	tHotName = VUHDO_PANEL_SETUP["HOTS"]["SLOTS"][aHotNum];

	if (tHotName ~= nil and strlen(tHotName) > 0) then
		VUHDO_GLOBAL[aTexture:GetName() .. "TitleString"]:SetText(tHotName);
	end
end
