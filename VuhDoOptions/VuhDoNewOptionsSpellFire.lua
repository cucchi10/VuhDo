VUHDO_KEY_LAYOUT_COMBO_MODEL = { };
VUHDO_CURR_LAYOUT = "";



--
function VUHDO_initKeyLayoutComboModel()
	local tName;
	table.wipe(VUHDO_KEY_LAYOUT_COMBO_MODEL);

	for tName, _ in pairs(VUHDO_SPELL_LAYOUTS) do
		tinsert(VUHDO_KEY_LAYOUT_COMBO_MODEL, { tName, tName });
	end

	table.sort(VUHDO_KEY_LAYOUT_COMBO_MODEL,
		function(anInfo, anotherInfo)
			return anInfo[1] < anotherInfo[1];
		end
	);

	tinsert(VUHDO_KEY_LAYOUT_COMBO_MODEL, 1, {"", " -- none --" });
end



--
function VUHDO_keyLayoutComboChanged(aComboBox, aValue)
	if (VUHDO_SPELL_LAYOUTS[aValue] ~= nil) then
		VUHDO_CURR_LAYOUT = aValue;
	end

	VUHDO_GLOBAL[aComboBox:GetParent():GetName() .. "Spec1CheckButton"]:SetChecked(aValue == VUHDO_SPEC_LAYOUTS["1"]);
	VUHDO_GLOBAL[aComboBox:GetParent():GetName() .. "Spec2CheckButton"]:SetChecked(aValue == VUHDO_SPEC_LAYOUTS["2"]);
	VUHDO_lnfCheckButtonClicked(VUHDO_GLOBAL[aComboBox:GetParent():GetName() .. "Spec1CheckButton"]);
	VUHDO_lnfCheckButtonClicked(VUHDO_GLOBAL[aComboBox:GetParent():GetName() .. "Spec2CheckButton"]);
end



--
function VUHDO_keyLayoutSpecOnClick(aCheckButton, aSpecId)
	if (VUHDO_CURR_LAYOUT ~= nil and VUHDO_CURR_LAYOUT ~= "") then
		if (aCheckButton:GetChecked()) then
			VUHDO_SPEC_LAYOUTS[aSpecId] = VUHDO_CURR_LAYOUT;
			--VUHDO_Msg("Default layout for Spec #" .. aSpecId .. " set to \"" .. VUHDO_CURR_LAYOUT .. "\".");
		else
			VUHDO_SPEC_LAYOUTS[aSpecId] = "";
			--VUHDO_Msg("Removed default layout for Spec #" .. aSpecId .. ".");
		end
	else
		VUHDO_Msg("Please select a key layout first.", 1, 0.4, 0.4);
	end
end



--
function VUHDO_deleteKeyLayoutCallback(aDecision)
	if (VUHDO_YES == aDecision) then
		VUHDO_Msg("Deleted key layout \"" .. VUHDO_CURR_LAYOUT .. "\".");
		VUHDO_SPELL_LAYOUTS[VUHDO_CURR_LAYOUT] = nil;
		VUHDO_CURR_LAYOUT = "";
		VUHDO_SPEC_LAYOUTS["selected"] = "";
		VUHDO_initKeyLayoutComboModel();
		--VUHDO_lnfComboBoxInitFromModel(VuhDoNewOptionsSpellFireStorePanelLayoutCombo);
		VuhDoNewOptionsSpellFire:Hide();
		VuhDoNewOptionsSpellFire:Show();
	end
end



--
function VUHDO_keyLayoutDeleteOnClick(aButton)
	if (VUHDO_CURR_LAYOUT ~= nil and VUHDO_CURR_LAYOUT ~= "") then
		VuhDoYesNoFrameText:SetText("Really delete key layout \"" .. VUHDO_CURR_LAYOUT .. "\"?");
		VuhDoYesNoFrame:SetAttribute("callback", VUHDO_deleteKeyLayoutCallback);
		VuhDoYesNoFrame:Show();
	else
		VUHDO_Msg("Please select a key layout first.", 1, 0.4, 0.4);
	end
end



--
function VUHDO_applyKeyLayoutCallback(aDecision)
	if (VUHDO_YES == aDecision) then
		VUHDO_activateLayout(VUHDO_CURR_LAYOUT);
		VuhDoNewOptionsSpellFireTriggerWhatPanel:Hide();
		VuhDoNewOptionsSpellFireTriggerWhatPanel:Show();
	end
end



--
function VUHDO_keyLayoutApplyOnClick(aButton)
	if (VUHDO_CURR_LAYOUT ~= nil and VUHDO_CURR_LAYOUT ~= "") then
		VuhDoYesNoFrameText:SetText("This will overwrite current\nkey layout. Continue?");
		VuhDoYesNoFrame:SetAttribute("callback", VUHDO_applyKeyLayoutCallback);
		VuhDoYesNoFrame:Show();
	else
		VUHDO_Msg("Please select a key layout first.", 1, 0.4, 0.4);
	end
end


--
function VUHDO_saveKeyLayoutCallback(aDecision)
	if (VUHDO_YES == aDecision) then
		VUHDO_SPELL_LAYOUTS[VUHDO_CURR_LAYOUT] = { };
		VUHDO_SPELL_LAYOUTS[VUHDO_CURR_LAYOUT]["MOUSE"] = VUHDO_deepCopyTable(VUHDO_SPELL_ASSIGNMENTS);
		VUHDO_SPELL_LAYOUTS[VUHDO_CURR_LAYOUT]["HOSTILE_MOUSE"] = VUHDO_deepCopyTable(VUHDO_HOSTILE_SPELL_ASSIGNMENTS);
		VUHDO_SPELL_LAYOUTS[VUHDO_CURR_LAYOUT]["KEYS"] = VUHDO_deepCopyTable(VUHDO_SPELLS_KEYBOARD);
		VUHDO_SPELL_LAYOUTS[VUHDO_CURR_LAYOUT]["FIRE"] = { };
		VUHDO_SPELL_LAYOUTS[VUHDO_CURR_LAYOUT]["FIRE"]["T1"] = VUHDO_SPELL_CONFIG["IS_FIRE_TRINKET_1"];
		VUHDO_SPELL_LAYOUTS[VUHDO_CURR_LAYOUT]["FIRE"]["T2"] = VUHDO_SPELL_CONFIG["IS_FIRE_TRINKET_2"];
		VUHDO_SPELL_LAYOUTS[VUHDO_CURR_LAYOUT]["FIRE"]["I1"] = VUHDO_SPELL_CONFIG["IS_FIRE_CUSTOM_1"];
		VUHDO_SPELL_LAYOUTS[VUHDO_CURR_LAYOUT]["FIRE"]["I2"] = VUHDO_SPELL_CONFIG["IS_FIRE_CUSTOM_2"];
		VUHDO_SPELL_LAYOUTS[VUHDO_CURR_LAYOUT]["FIRE"]["I1N"] = VUHDO_SPELL_CONFIG["FIRE_CUSTOM_1_SPELL"];
		VUHDO_SPELL_LAYOUTS[VUHDO_CURR_LAYOUT]["FIRE"]["I2N"] = VUHDO_SPELL_CONFIG["FIRE_CUSTOM_2_SPELL"];

		VUHDO_SPELL_LAYOUTS[VUHDO_CURR_LAYOUT]["HOTS"] = VUHDO_deepCopyTable(VUHDO_PANEL_SETUP["HOTS"]);

		VUHDO_Msg("Key layout \"" .. VUHDO_CURR_LAYOUT .. "\" successfully saved.");
		VUHDO_initKeyLayoutComboModel();
		VUHDO_lnfComboBoxInitFromModel(VuhDoNewOptionsSpellFireStorePanelLayoutCombo);
		VuhDoNewOptionsSpellFireTriggerWhatPanel:Hide();
		VuhDoNewOptionsSpellFireTriggerWhatPanel:Show();
	end
end



--
local tEditBox;
function VUHDO_saveKeyLayoutOnClick(aButton)
	tEditBox = VUHDO_GLOBAL[aButton:GetParent():GetName() .. "SaveAsEditBox"];
	VUHDO_CURR_LAYOUT = strtrim(tEditBox:GetText());

	if (strlen(VUHDO_CURR_LAYOUT) == 0) then
		VUHDO_Msg("Please enter a key layout name.", 1, 0.4, 0.4);
		return;
	end

	if (VUHDO_SPELL_LAYOUTS[VUHDO_CURR_LAYOUT] ~= nil) then
		VuhDoYesNoFrameText:SetText("A key layout called " .. VUHDO_CURR_LAYOUT .. " already exists. Overwrite?");
		VuhDoYesNoFrame:SetAttribute("callback", VUHDO_saveKeyLayoutCallback);
		VuhDoYesNoFrame:Show();
	else
		VUHDO_saveKeyLayoutCallback(VUHDO_YES);
	end
end
