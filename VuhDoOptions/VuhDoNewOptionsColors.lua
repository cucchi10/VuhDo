local function VUHDO_hideAllPanel()
	VuhDoNewOptionsColorsModes:Hide();
	VuhDoNewOptionsColorsStates:Hide();
	VuhDoNewOptionsColorsPowers:Hide();
	VuhDoNewOptionsColorsHots:Hide();
	VuhDoNewOptionsColorsHotCharges:Hide();
	VuhDoNewOptionsColorsClasses:Hide();
	VuhDoNewOptionsColorsRaidIcons:Hide();
end



--
function VUHDO_newOptionsColorsStatesClicked(self)
	VUHDO_hideAllPanel();
	VuhDoNewOptionsColorsStates:Show();
end



--
function VUHDO_newOptionsColorsModesClicked(self)
	VUHDO_hideAllPanel();
	VuhDoNewOptionsColorsModes:Show();
end



--
function VUHDO_newOptionsColorsPowersClicked(self)
	VUHDO_hideAllPanel();
	VuhDoNewOptionsColorsPowers:Show();
end



--
function VUHDO_newOptionsColorsHotsClicked(self)
	VUHDO_hideAllPanel();
	VuhDoNewOptionsColorsHots:Show();
end



--
function VUHDO_newOptionsColorsHotChargesClicked(self)
	VUHDO_hideAllPanel();
	VuhDoNewOptionsColorsHotCharges:Show();
end



--
function VUHDO_newOptionsColorsClassesClicked(self)
	VUHDO_hideAllPanel();
	VuhDoNewOptionsColorsClasses:Show();
end



--
function VUHDO_newOptionsColorsRaidIconsClicked(self)
	VUHDO_hideAllPanel();
	VuhDoNewOptionsColorsRaidIcons:Show();
end
