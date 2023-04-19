


--
local function VUHDO_hideAllPanel()
	VuhDoNewOptionsToolsSkins:Hide();
	VuhDoNewOptionsToolsWizard:Hide();
	VuhDoNewOptionsToolsReset:Hide();
end



--
function VUHDO_newOptionsToolsWizardClicked()
	VUHDO_hideAllPanel();
	VuhDoNewOptionsToolsWizard:Show();
end



--
function VUHDO_newOptionsToolsSkinsClicked()
	VUHDO_hideAllPanel();
	VuhDoNewOptionsToolsSkins:Show();
end



--
function VUHDO_newOptionsToolsResetClicked()
	VUHDO_hideAllPanel();
	VuhDoNewOptionsToolsReset:Show();
end
