


--
local function VUHDO_hideAllPanel()
	VuhDoNewOptionsDebuffsStandard:Hide();
	VuhDoNewOptionsDebuffsCustom:Hide();
end



--
function VUHDO_newOptionsDebuffsCustomClicked()
	VUHDO_hideAllPanel();
	VuhDoNewOptionsDebuffsCustom:Show();
end



--
function VUHDO_newOptionsDebuffsStandardClicked()
	VUHDO_hideAllPanel();
	VuhDoNewOptionsDebuffsStandard:Show();
end