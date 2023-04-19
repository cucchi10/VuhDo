VUHDO_PROFILE_TABLE_MODEL = { };
VUHDO_CUSTOM_DEBUFF_PROFILE = nil;
VUHDO_EXPORT_CUDE_TO_RADIO_VALUE = 3;
VUHDO_EXPORT_CUDE_IS_REPLACE = false;

--
function VUHDO_initProfileTableModels(aButton)
	local tIndex, tValue;

	table.wipe(VUHDO_PROFILE_TABLE_MODEL);
	VUHDO_PROFILE_TABLE_MODEL[1] = { "", "-- " .. VUHDO_I18N_EMPTY_HOTS .. " --" };
	for tIndex, tValue in ipairs(VUHDO_PROFILES) do
		VUHDO_PROFILE_TABLE_MODEL[tIndex + 1] = { tValue["NAME"], tValue["NAME"] };
	end

	table.sort(VUHDO_PROFILE_TABLE_MODEL,
	function(anInfo, anotherInfo)
		return anInfo[1] < anotherInfo[1];
	end
	);

end



local VUHDO_PROFILE_COMBO = nil;
local VUHDO_PROFILE_EDIT = nil;



--
function VUHDO_setProfileCombo(aComboBox)
	VUHDO_PROFILE_COMBO = aComboBox;
end



--
function VUHDO_setProfileEditBox(anEditBox)
	VUHDO_PROFILE_EDIT = anEditBox;
end



--
function VUHDO_updateProfileSelectCombo()
	VUHDO_initProfileTableModels();
  VUHDO_lnfComboBoxInitFromModel(VUHDO_PROFILE_COMBO);
  VUHDO_lnfEditBoxInitFromModel(VUHDO_PROFILE_EDIT);
end



--
local tCnt;
local function VUHDO_deleteAutoProfile(tName)
	for tCnt = 1, 40 do
		if (VUHDO_CONFIG["AUTO_PROFILES"]["" .. tCnt] == tName) then
			VUHDO_CONFIG["AUTO_PROFILES"]["" .. tCnt] = nil;
		end
	end

	if (VUHDO_CONFIG["AUTO_PROFILES"]["SPEC_1"] == tName) then
		VUHDO_CONFIG["AUTO_PROFILES"]["SPEC_1"] = nil;
	end

	if (VUHDO_CONFIG["AUTO_PROFILES"]["SPEC_2"] == tName) then
		VUHDO_CONFIG["AUTO_PROFILES"]["SPEC_2"] = nil;
	end
end



--
function VUHDO_skinsInitAutoCheckButton(aButton, anIndex)
	local tEditBox = VUHDO_GLOBAL[aButton:GetParent():GetParent():GetName() .. "LoadSavePanelEnterProfileNameEditBox"];
	local tSelected = strtrim(tEditBox:GetText());

	aButton:SetChecked(VUHDO_CONFIG["AUTO_PROFILES"][anIndex] == tSelected);
	VUHDO_lnfCheckButtonClicked(aButton);
end



--
function VUHDO_skinsLockCheckButtonClicked(aButton)
  local tIndex, tProfile = VUHDO_getProfileNamed(VUHDO_CONFIG["CURRENT_PROFILE"]);
  if (tIndex ~= nil) then
  	if (aButton:GetChecked()) then -- Achtung GetChecked liefert 1<->nil => Problem mit model consistency checker
  		tProfile["LOCKED"] = true;
  	else
  		tProfile["LOCKED"] = false;
  	end
  end
end



--
function VUHDO_skinsInitLockCheckButton(aButton)
  local tIndex, tProfile = VUHDO_getProfileNamed(VUHDO_CONFIG["CURRENT_PROFILE"]);
	aButton:SetChecked(tIndex ~= nil and tProfile["LOCKED"]);
	VUHDO_lnfCheckButtonClicked(aButton);
end



--
local tCnt;
local tButton;
local function VUHDO_updateAllAutoProfiles(aComponent)
	for tCnt = 1, 40 do
		tButton = VUHDO_GLOBAL[aComponent:GetParent():GetParent():GetName() .. "AutoEnablePanel" .. tCnt .. "CheckButton"];
		if (tButton ~= nil) then
			VUHDO_skinsInitAutoCheckButton(tButton, "" .. tCnt);
		end
	end

	tButton = VUHDO_GLOBAL[aComponent:GetParent():GetParent():GetName() .. "AutoEnablePanelSpec1CheckButton"];
	VUHDO_skinsInitAutoCheckButton(tButton, "SPEC_1");

	tButton = VUHDO_GLOBAL[aComponent:GetParent():GetParent():GetName() .. "AutoEnablePanelSpec2CheckButton"];
	VUHDO_skinsInitAutoCheckButton(tButton, "SPEC_2");

	tButton = VUHDO_GLOBAL[aComponent:GetParent():GetParent():GetName() .. "SettingsPanelLockCheckButton"];
	VUHDO_skinsInitLockCheckButton(tButton);
end



--
function VUHDO_profileComboValueChanged(aComboBox, aValue)
	VUHDO_updateAllAutoProfiles(aComboBox);
end



--
function VUHDO_skinsAutoCheckButtonClicked(aButton, anIndex)
	local tEditBox = VUHDO_GLOBAL[aButton:GetParent():GetParent():GetName() .. "LoadSavePanelEnterProfileNameEditBox"];
	local tSelected = strtrim(tEditBox:GetText());

	local tExistIndex, _ = VUHDO_getProfileNamed(tSelected);
	if (tExistIndex == nil) then
		VUHDO_Msg(VUHDO_I18N_ERROR_NO_PROFILE .. "\"" .. tSelected .. "\" !", 1, 0.4, 0.4);
		aButton:SetChecked(false);
		VUHDO_lnfCheckButtonClicked(aButton);
		return;
	end

	if (aButton:GetChecked()) then
		VUHDO_CONFIG["AUTO_PROFILES"][anIndex] = tSelected;
	else
		VUHDO_CONFIG["AUTO_PROFILES"][anIndex] = nil;
	end
end





-- Delete -------------------------------


--
function VUHDO_deleteProfile(aName)
	local tIndex, _ = VUHDO_getProfileNamed(aName);

	if (tIndex ~= nil) then
		tremove(VUHDO_PROFILES, tIndex);
		VUHDO_deleteAutoProfile(aName);
		VUHDO_CONFIG["CURRENT_PROFILE"] = "";
		VUHDO_updateProfileSelectCombo();
		VUHDO_Msg(VUHDO_I18N_DELETED_PROFILE .. " \"" .. aName .."\".");
	end
end



--
function VUHDO_yesNoDeleteProfileCallback(aDecision)
	if (VUHDO_YES == aDecision) then
		VUHDO_deleteProfile(VuhDoYesNoFrame:GetAttribute("profileName"));
		VUHDO_updateProfileSelectCombo();
	end
end



--
function VUHDO_deleteProfileClicked(aButton)
	local tEditBox = VUHDO_GLOBAL[aButton:GetParent():GetName() .. "EnterProfileNameEditBox"];
	local tName = tEditBox:GetText();

	if (tName == nil or strlen(tName) == 0) then
		VUHDO_Msg(VUHDO_I18N_MUST_ENTER_SELECT_PROFILE);
		return;
	end

	local tIndex, tProfile = VUHDO_getProfileNamed(tName);
	if (tIndex == nil) then
		VUHDO_Msg(VUHDO_I18N_ERROR_NO_PROFILE .. "\"" .. tName .. "\" !", 1, 0.4, 0.4);
		return;
	end

	VuhDoYesNoFrameText:SetText(VUHDO_I18N_REALLY_DELETE_PROFILE .. " \"" .. tName .. "\"?");
	VuhDoYesNoFrame:SetAttribute("callback", VUHDO_yesNoDeleteProfileCallback);
	VuhDoYesNoFrame:SetAttribute("profileName", tName);
	VuhDoYesNoFrame:Show();
end



--
function VUHDO_saveProfileClicked(aButton)
	local tEditBox = VUHDO_GLOBAL[aButton:GetParent():GetName() .. "EnterProfileNameEditBox"];
	local tName = tEditBox:GetText();

	if (tName == nil or strlen(tName) == 0) then
		VUHDO_Msg(VUHDO_I18N_MUST_ENTER_SELECT_PROFILE);
		return;
	end

	local _, tProfile = VUHDO_getProfileNamed(tName);
	if (tProfile ~= nil and tProfile["LOCKED"]) then
		VUHDO_Msg("Profile " .. tName .. " is currently locked. Please unlock before saving.");
		return;
	end

	VUHDO_saveProfile(tName);
end



--
function VUHDO_loadProfileClicked(aButton)
	local tEditBox = VUHDO_GLOBAL[aButton:GetParent():GetName() .. "EnterProfileNameEditBox"];
	local tName = tEditBox:GetText();

	if (tName == nil or strlen(tName) == 0) then
		VUHDO_Msg(VUHDO_I18N_MUST_ENTER_SELECT_PROFILE);
		return;
	end

	VUHDO_loadProfile(tName);
end


--------------



--
local function VUHDO_broadcastCustomDebuffsToProfile(aDestProfile, anIsReplace)
	local tIndex, tProfile;
	local tDebuffName, tSettings;

	tIndex, tProfile = VUHDO_getProfileNamed(aDestProfile);
	if (tIndex == nil) then
		VUHDO_Msg("Error: No profile named \"" .. (aDestProfile or "<not selected>") .. "\" exists.");
		return;
	end

	if (anIsReplace) then
		table.wipe(VUHDO_PROFILES[tIndex]["CONFIG"]["CUSTOM_DEBUFF"]["STORED"]);
		table.wipe(VUHDO_PROFILES[tIndex]["CONFIG"]["CUSTOM_DEBUFF"]["STORED_SETTINGS"]);
	end

	for _, tDebuffName in pairs(VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED"]) do
		tSettings = VUHDO_deepCopyTable(VUHDO_CONFIG["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tDebuffName]);
		VUHDO_PROFILES[tIndex]["CONFIG"]["CUSTOM_DEBUFF"]["STORED_SETTINGS"][tDebuffName] = tSettings;

		if (VUHDO_tableUniqueAdd(VUHDO_PROFILES[tIndex]["CONFIG"]["CUSTOM_DEBUFF"]["STORED"], tDebuffName)) then
			VUHDO_Msg("Added " .. tDebuffName .. " to " .. aDestProfile);
		end
	end

	VUHDO_Msg("Custom debuffs exported to profile " .. aDestProfile);
end



--
local function VUHDO_broadcastCustomDebuffsToAllProfiles(anIsSameToonOnly, anIsReplace)
	local tProfileNum, tProfile;

	for tProfileNum, tProfile in pairs(VUHDO_PROFILES) do
		if (VUHDO_PLAYER_NAME == tProfile["ORIGINATOR_TOON"] or not anIsSameToonOnly) then
			VUHDO_broadcastCustomDebuffsToProfile(tProfile["NAME"], anIsReplace);
		end
	end

	VUHDO_Msg("Custom debuff export done.");
end



--
function VUHDO_profilesReplaceCudeClicked(_, anIsReplace)
	VUHDO_EXPORT_CUDE_IS_REPLACE = anIsReplace;

	VuhDoYesNoFrameText:SetText("Really export to profile(s)?");
	VuhDoYesNoFrame:SetAttribute("callback",
		function(aDecision)
			if (VUHDO_YES == aDecision) then

				if (VUHDO_EXPORT_CUDE_TO_RADIO_VALUE == 1) then -- all
					VUHDO_broadcastCustomDebuffsToAllProfiles(false, VUHDO_EXPORT_CUDE_IS_REPLACE);
				elseif(VUHDO_EXPORT_CUDE_TO_RADIO_VALUE == 2) then -- own toon
					VUHDO_broadcastCustomDebuffsToAllProfiles(true, VUHDO_EXPORT_CUDE_IS_REPLACE);
				else -- selected profile
					VUHDO_broadcastCustomDebuffsToProfile(VUHDO_CUSTOM_DEBUFF_PROFILE, VUHDO_EXPORT_CUDE_IS_REPLACE);
				end

				VUHDO_initCustomDebuffComboModel();
			end
		end
	);
	VuhDoYesNoFrame:Show();


end
