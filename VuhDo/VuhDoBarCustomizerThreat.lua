local pairs = pairs;


local tAllButtons;
local tButton, tTexture;
function VUHDO_threatIndicatorsBouquetCallback(aUnit, anIsActive, anIcon, aTimer, aCounter, aDuration, aColor, aBuffName, aBouquetName)
	tAllButtons = VUHDO_getUnitButtons(aUnit);
	if (tAllButtons ~= nil) then
		for _, tButton in pairs(tAllButtons) do
			tTexture = VUHDO_getAggroTexture(VUHDO_getHealthBar(tButton, 1));
			if (anIsActive) then
				tTexture:SetVertexColor(aColor["R"], aColor["G"], aColor["B"], aColor["O"]);
				tTexture:Show();
				UIFrameFlash(tTexture, 0.2, 0.5, 3.2, true, 0, 0);
			else
				UIFrameFlashRemoveFrame(tTexture);
				tTexture:Hide();
			end
		end
	end
end



--
local tAllButtons, tButton;
local tBar;
local tQuota;
function VUHDO_threatBarBouquetCallback(aUnit, anIsActive, anIcon, aCurrValue, aCounter, aMaxValue, aColor, aBuffName, aBouquetName)
	if (aCurrValue == 0 and aMaxValue == 0) then
		if (anIsActive) then
			tQuota = 100;
		else
			tQuota = 0;
		end
	elseif ((aMaxValue or 0) > 1) then
		tQuota = 100 * aCurrValue / aMaxValue;
	else
		tQuota = 0;
	end

	tAllButtons = VUHDO_getUnitButtons(aUnit);
	if (tAllButtons ~= nil) then
		for _, tButton in pairs(tAllButtons) do
			if (tQuota > 0) then
				tBar = VUHDO_getHealthBar(tButton, 7);
				tBar:SetValue(tQuota);
				tBar:SetStatusBarColor(aColor["R"], aColor["G"], aColor["B"], aColor["O"]);
			else
				VUHDO_getHealthBar(tButton, 7):SetValue(0);
			end
		end
	end
end
