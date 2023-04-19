local pairs = pairs;



--
local VUHDO_CURR_PLAYER_TARGET = nil;
local tTargetUnit, tUnit;
local tOldTarget;
local tInfo;
local tEmptyInfo = { };
function VUHDO_updatePlayerTarget()
	tTargetUnit = nil;
	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if (UnitIsUnit("target", tUnit) and tUnit ~= "focus" and tUnit ~= "target") then
			if (tInfo.isPet and (VUHDO_RAID[tInfo.ownerUnit] or tEmptyInfo).isVehicle) then
				tTargetUnit = tInfo.ownerUnit;
			else
				tTargetUnit = tUnit;
			end
			break;
		end
	end
	tOldTarget = VUHDO_CURR_PLAYER_TARGET;
	VUHDO_CURR_PLAYER_TARGET = tTargetUnit; -- Wg. callback erst umkopieren
	VUHDO_updateBouquetsForEvent(tOldTarget, VUHDO_UPDATE_TARGET);
	VUHDO_updateBouquetsForEvent(tTargetUnit, VUHDO_UPDATE_TARGET);
	VUHDO_clParserSetCurrentTarget(tTargetUnit);

	if (VUHDO_INTERNAL_TOGGLES[VUHDO_UPDATE_PLAYER_TARGET]) then
		if (UnitExists("target")) then
			VUHDO_setHealth("target", VUHDO_UPDATE_ALL);
		else
			VUHDO_removeHots("target");
			VUHDO_removeAllDebuffIcons("target");
			VUHDO_updateTargetBars("target");
			VUHDO_RAID["target"] = nil;
		end

	  VUHDO_updateHealthBarsFor("target", VUHDO_UPDATE_ALL);
		VUHDO_REMOVE_HOTS = false;
	  VUHDO_updateAllRaidBars();
		VUHDO_initAllEventBouquets();
	end
end



--
local tAllButtons, tButton, tBorder;
function VUHDO_barBorderBouquetCallback(aUnit, anIsActive, anIcon, aTimer, aCounter, aDuration, aColor, aBuffName, aBouquetName, anImpact)
	tAllButtons =  VUHDO_getUnitButtons(aUnit);
	if (tAllButtons ~= nil) then
		for _, tButton in pairs(tAllButtons) do
			tBorder = VUHDO_getPlayerTargetFrame(tButton);
			if (aColor ~= nil) then
				tBorder:SetFrameLevel(tButton:GetFrameLevel() + (anImpact or 0));
				tBorder:SetBackdropBorderColor(aColor.R, aColor.G, aColor.B, aColor.O);
				tBorder:Show();
			else
				tBorder:Hide();
			end
		end
	end
end



--
function VUHDO_getCurrentPlayerTarget()
	return VUHDO_CURR_PLAYER_TARGET;
end
