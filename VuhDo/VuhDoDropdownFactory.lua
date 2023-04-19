VUHDO_MM_SETTINGS = { };
local VUHDO_MENU_UNIT = nil;



--
function VUHDO_playerTargetDropdownOnLoad()
	UIDropDownMenu_Initialize(VuhDoPlayerTargetDropDown, VUHDO_playerTargetDropDown_Initialize, "MENU", 1);
end



--
function VUHDO_setMenuUnit(aButton)
	VUHDO_MENU_UNIT = VUHDO_resolveButtonUnit(aButton);
end



--
function VUHDO_ptBuffSelected(_, aName, aCategName)
	VUHDO_Msg(VUHDO_I18N_BUFF_ASSIGN_1 .. aCategName .. VUHDO_I18N_BUFF_ASSIGN_2 .. aName .. VUHDO_I18N_BUFF_ASSIGN_3);
	VUHDO_BUFF_SETTINGS[aCategName].name = aName;
	VUHDO_reloadBuffPanel();
end



--
function VUHDO_roleOverrideSelected(_, aModelId, aName)
	VUHDO_MANUAL_ROLES[aName] = aModelId;
	VUHDO_reloadUI();
end



--
function VUHDO_playerTargetDropDown_Initialize(aFrame, aLevel)
	local tInfo;

	if (VUHDO_MENU_UNIT == nil or VUHDO_RAID[VUHDO_MENU_UNIT] == nil) then
		return;
	end

	local tName = VUHDO_RAID[VUHDO_MENU_UNIT].name;

	if (aLevel > 1) then
		local tUniqueBuffs, _ = VUHDO_getAllUniqueSpells();
		local tBuffName;

		for _, tBuffName in pairs(tUniqueBuffs) do
			local tCategory = strsub(VUHDO_getBuffCategory(tBuffName), 3);
			tInfo = UIDropDownMenu_CreateInfo();
			tInfo.text = tBuffName;
			tInfo.arg1 = tName;
			tInfo.arg2 = tCategory;
			tInfo.icon = VUHDO_BUFFS[tBuffName].icon;
			tInfo.func = VUHDO_ptBuffSelected;
			tInfo.checked = VUHDO_BUFF_SETTINGS[tCategory].name == tName;
			tInfo.level = 2;
			UIDropDownMenu_AddButton(tInfo, 2);
		end

		return;
	end

	tInfo = UIDropDownMenu_CreateInfo();
	tInfo.text = VUHDO_I18N_ROLE;
	tInfo.text = tInfo.text .. " (" .. tName .. ")";
	tInfo.isTitle = true;
	UIDropDownMenu_AddButton(tInfo);

	tInfo = UIDropDownMenu_CreateInfo();
	tInfo.text = "";
	tInfo.isTitle = true;
	UIDropDownMenu_AddButton(tInfo);

	local tUnitRank, tUnitIsMl = VUHDO_getUnitRank(VUHDO_MENU_UNIT);
	local tPlayerRank, tPlayerIsMl = VUHDO_getPlayerRank();

	-- Raid leader
	tInfo = UIDropDownMenu_CreateInfo();
	tInfo.text = VUHDO_I18N_PROMOTE_RAID_LEADER;
	tInfo.checked = tUnitRank == 2;
	tInfo.arg1 = "LEAD";
	tInfo.arg2 = VUHDO_MENU_UNIT;
	tInfo.func = VUHDO_unitRoleItemSelected;
	VUHDO_disableMenu(tInfo, tPlayerRank < 2);
	UIDropDownMenu_AddButton(tInfo);

	if (tUnitRank == 0) then
		-- + assist
		tInfo = UIDropDownMenu_CreateInfo();
		tInfo.text = VUHDO_I18N_PROMOTE_ASSISTANT;
		tInfo.checked = false;
		tInfo.arg1 = "+A";
		tInfo.arg2 = VUHDO_MENU_UNIT;
		tInfo.func = VUHDO_unitRoleItemSelected;
		VUHDO_disableMenu(tInfo, tPlayerRank < 2);
		UIDropDownMenu_AddButton(tInfo);
	end

	if (tUnitRank == 1) then
	-- - assist
		tInfo = UIDropDownMenu_CreateInfo();
		tInfo.text = VUHDO_I18N_DEMOTE_ASSISTANT;
		tInfo.checked = false;
		tInfo.arg1 = "-A";
		tInfo.arg2 = VUHDO_MENU_UNIT;
		tInfo.func = VUHDO_unitRoleItemSelected;
		VUHDO_disableMenu(tInfo, tPlayerRank < 2);
		UIDropDownMenu_AddButton(tInfo);
	end

	-- Master looter
	tInfo = UIDropDownMenu_CreateInfo();
	tInfo.text = VUHDO_I18N_PROMOTE_MASTER_LOOTER;
	tInfo.checked = tUnitIsMl;
	tInfo.arg1 = "ML";
	tInfo.arg2 = VUHDO_MENU_UNIT;
	tInfo.func = VUHDO_unitRoleItemSelected;
	VUHDO_disableMenu(tInfo, tPlayerRank < 2 and not tPlayerIsMl);
	UIDropDownMenu_AddButton(tInfo);

	tInfo = UIDropDownMenu_CreateInfo();
	tInfo.text = "";
	tInfo.isTitle = true;
	UIDropDownMenu_AddButton(tInfo);


	tInfo = UIDropDownMenu_CreateInfo();
	tInfo.text = VUHDO_I18N_PRIVATE_TANK;
	if (VUHDO_MENU_UNIT ~= nil and VUHDO_RAID[VUHDO_MENU_UNIT] ~= nil) then
		tInfo.checked = VUHDO_PLAYER_TARGETS[tName] ~= nil;
	else
		tInfo.checked = false;
	end
	tInfo.arg1 = VUHDO_MENU_UNIT;
	tInfo.func = VUHDO_playerTargetItemSelected;
	UIDropDownMenu_AddButton(tInfo);

	tInfo = UIDropDownMenu_CreateInfo();
	tInfo.text = "";
	tInfo.isTitle = true;
	UIDropDownMenu_AddButton(tInfo);

	local tCnt;
	for tCnt = 1, VUHDO_MAX_MTS do
		tInfo = UIDropDownMenu_CreateInfo();
		tInfo.text = VUHDO_I18N_MT_NUMBER .. tCnt;

		tInfo.checked = VUHDO_MAINTANK_NAMES[tCnt] == tName;
		tInfo.arg1 = tCnt;
		tInfo.arg2 = VUHDO_MENU_UNIT;
		tInfo.func = VUHDO_mainTankItemSelected;
		tInfo.disabled = VUHDO_getPlayerRank() < 1;

		if (tInfo.checked) then
			tInfo.text = tInfo.text .. " (" .. VUHDO_MAINTANK_NAMES[tCnt] .. ")";
			tInfo.colorCode = "|cffffe466";
		elseif (VUHDO_MAINTANK_NAMES[tCnt] == nil) then
			tInfo.colorCode = "|cffcccccc";
		else
			tInfo.text = tInfo.text .. " (" .. VUHDO_MAINTANK_NAMES[tCnt] .. ")";
			tInfo.colorCode = "|cffffb233";
		end

		UIDropDownMenu_AddButton(tInfo);
	end

	local tUniques, _ = VUHDO_getAllUniqueSpells();
	if (#tUniques > 0) then
		tInfo = UIDropDownMenu_CreateInfo();
		tInfo.text = "";
		tInfo.isTitle = true;
		UIDropDownMenu_AddButton(tInfo);

		tInfo = UIDropDownMenu_CreateInfo();
		tInfo.text = VUHDO_I18N_SET_BUFF;
		tInfo.hasArrow = true;
		tInfo.disabled = false;
		UIDropDownMenu_AddButton(tInfo);
	end

	tInfo = UIDropDownMenu_CreateInfo();
	tInfo.text = "";
	tInfo.isTitle = true;
	UIDropDownMenu_AddButton(tInfo);

	tInfo = UIDropDownMenu_CreateInfo();
	tInfo.text = VUHDO_I18N_ROLE_OVERRIDE;
	tInfo.isTitle = true;
	tInfo.disabled = false;
	UIDropDownMenu_AddButton(tInfo);

	tInfo = UIDropDownMenu_CreateInfo();
	tInfo.text = VUHDO_I18N_MELEE_TANK;
	tInfo.checked = VUHDO_MANUAL_ROLES[tName] == VUHDO_ID_MELEE_TANK;
	tInfo.arg1 = VUHDO_ID_MELEE_TANK;
	tInfo.arg2 = tName;
	tInfo.func = VUHDO_roleOverrideSelected;
	tInfo.disabled = false;
	UIDropDownMenu_AddButton(tInfo);

	tInfo = UIDropDownMenu_CreateInfo();
	tInfo.text = VUHDO_I18N_MELEE_DPS;
	tInfo.checked = VUHDO_MANUAL_ROLES[tName] == VUHDO_ID_MELEE_DAMAGE;
	tInfo.arg1 = VUHDO_ID_MELEE_DAMAGE;
	tInfo.arg2 = tName;
	tInfo.func = VUHDO_roleOverrideSelected;
	tInfo.disabled = false;
	UIDropDownMenu_AddButton(tInfo);

	tInfo = UIDropDownMenu_CreateInfo();
	tInfo.text = VUHDO_I18N_RANGED_DPS;
	tInfo.checked = VUHDO_MANUAL_ROLES[tName] == VUHDO_ID_RANGED_DAMAGE;
	tInfo.arg1 = VUHDO_ID_RANGED_DAMAGE;
	tInfo.arg2 = tName;
	tInfo.func = VUHDO_roleOverrideSelected;
	tInfo.disabled = false;
	UIDropDownMenu_AddButton(tInfo);

	tInfo = UIDropDownMenu_CreateInfo();
	tInfo.text = VUHDO_I18N_RANGED_HEALERS;
	tInfo.checked = VUHDO_MANUAL_ROLES[tName] == VUHDO_ID_RANGED_HEAL;
	tInfo.arg1 = VUHDO_ID_RANGED_HEAL;
	tInfo.arg2 = tName;
	tInfo.func = VUHDO_roleOverrideSelected;
	tInfo.disabled = false;
	UIDropDownMenu_AddButton(tInfo);

	tInfo = UIDropDownMenu_CreateInfo();
	tInfo.text = VUHDO_I18N_AUTO_DETECT;
	tInfo.checked = VUHDO_MANUAL_ROLES[tName] == nil;
	tInfo.arg1 = nil;
	tInfo.arg2 = tName;
	tInfo.func = VUHDO_roleOverrideSelected;
	tInfo.disabled = false;
	UIDropDownMenu_AddButton(tInfo);
end



--
function VUHDO_disableMenu(anInfo, aCondition)
	anInfo.disabled = aCondition;

	if (aCondition) then
		anInfo.colorCode = "|cff808080";
	else
		anInfo.colorCode = "|cffffffff";
	end
end



--
function VUHDO_playerTargetItemSelected(_, aUnit)
	local tName = VUHDO_RAID[aUnit].name;
	if (VUHDO_PLAYER_TARGETS[tName] ~= nil) then
		VUHDO_PLAYER_TARGETS[tName] = nil;
	else
		VUHDO_PLAYER_TARGETS[tName] = true;
	end

	-- Reload assist group
	VUHDO_quickRaidReload();
end



--
function VUHDO_mainTankItemSelected(_, aMtPos, aUnit)
	local tName = VUHDO_RAID[aUnit].name;

	-- remove Maintankt?
	if (VUHDO_MAINTANK_NAMES[aMtPos] == tName) then
		VUHDO_sendCtraMessage("R " .. tName);
	else
		if (VUHDO_MAINTANK_NAMES[aMtPos] ~= nil) then
			VUHDO_sendCtraMessage("R " .. VUHDO_MAINTANK_NAMES[aMtPos]);
		end

		VUHDO_sendCtraMessage("SET " .. aMtPos .. " " .. tName);
	end

	VUHDO_reloadUI();
end



--
function VUHDO_unitRoleItemSelected(_, aCommand, aUnit)
	if ("LEAD" == aCommand) then
		PromoteToLeader(aUnit);
	elseif ("+A" == aCommand) then
		PromoteToAssistant(aUnit);
		VUHDO_Msg(VUHDO_I18N_PROMOTE_ASSIST_MSG_1 .. UnitName(aUnit) .. VUHDO_I18N_PROMOTE_ASSIST_MSG_2);
	elseif ("-A" == aCommand) then
		VUHDO_Msg(VUHDO_I18N_DEMOTE_ASSIST_MSG_1 .. UnitName(aUnit) .. VUHDO_I18N_DEMOTE_ASSIST_MSG_2);
		DemoteAssistant(aUnit);
	elseif ("ML" == aCommand) then
		SetLootMethod("master", UnitName(aUnit));
	end
end



--
function VUHDO_minimapLeftClick()
	VUHDO_slashCmd("options");
end



--
function VUHDO_minimapDropdownOnLoad()
	UIDropDownMenu_Initialize(VuhDoMinimapDropDown, VUHDO_miniMapDropDown_Initialize, "MENU", 1);
end




--
function VUHDO_minimapRightClick()
	ToggleDropDownMenu(1, nil, VuhDoMinimapDropDown, "VuhDoMinimapButton", 0, -5);
end



--
function VUHDO_mmLoadProfile(_, aName)
	VUHDO_loadProfile(aName);
	VUHDO_CONFIG["CURRENT_PROFILE"] = aName;
end



--
function VUHDO_mmLoadKeyLayout(_, aName)
	VUHDO_activateLayout(aName);
end



--
local function VUHDO_createMinimapToggle(aName, anArg1, anIsChecked)
	local tInfo = UIDropDownMenu_CreateInfo();
	tInfo.text = aName;
	tInfo.keepShownOnClick = true;
	tInfo.arg1 = anArg1;
	tInfo.func = VUHDO_minimapItemSelected;
	tInfo.checked = anIsChecked;
	UIDropDownMenu_AddButton(tInfo);
end



--
local function VUHDO_createEmptyLine()
	local tInfo = UIDropDownMenu_CreateInfo();
	tInfo.text = "";
	tInfo.isTitle = true;
	UIDropDownMenu_AddButton(tInfo);
end



--
function VUHDO_miniMapDropDown_Initialize(aFrame, aLevel)
	local tInfo;
	local tName;

	if (VUHDO_CONFIG == nil) then
		return;
	end

	if (aLevel > 1) then
		if ("S" == UIDROPDOWNMENU_MENU_VALUE) then
  		local tSetup;

  		for _, tSetup in ipairs(VUHDO_PROFILES) do
  			tInfo = UIDropDownMenu_CreateInfo();
  			tInfo.text = tSetup["NAME"];
  			tInfo.arg1 = tSetup["NAME"];
  			tInfo.func = VUHDO_mmLoadProfile;
  			tInfo.checked = tSetup["NAME"] == VUHDO_CONFIG["CURRENT_PROFILE"];
  			tInfo.level = 2;
  			UIDropDownMenu_AddButton(tInfo, 2);
  		end
		elseif ("K" == UIDROPDOWNMENU_MENU_VALUE) then
  		for tName, _ in pairs(VUHDO_SPELL_LAYOUTS) do
  			tInfo = UIDropDownMenu_CreateInfo();
  			tInfo.text = tName;
  			tInfo.arg1 = tName;
  			tInfo.func = VUHDO_mmLoadKeyLayout;
  			tInfo.checked = tName == VUHDO_SPEC_LAYOUTS["selected"];
  			tInfo.level = 2;
  			UIDropDownMenu_AddButton(tInfo, 2);
  		end
		end
		return;
	end

	tInfo = UIDropDownMenu_CreateInfo();
	tInfo.text = VUHDO_I18N_VUHDO_OPTIONS;
	tInfo.isTitle = true;
	UIDropDownMenu_AddButton(tInfo);

	tInfo = UIDropDownMenu_CreateInfo();
	tInfo.text = VUHDO_I18N_PANEL_SETUP;
	tInfo.checked = nil;
	tInfo.func = VUHDO_minimapItemSelected;
	tInfo.icon = nil;
	tInfo.arg1 = "" .. 1;
	tInfo.tCoordLeft = 0;
	tInfo.tCoordRight = 1;
	tInfo.tCoordTop = 0;
	tInfo.tCoordBottom = 1;
	UIDropDownMenu_AddButton(tInfo);

	VUHDO_createEmptyLine();

	tInfo = UIDropDownMenu_CreateInfo();
	tInfo.text = VUHDO_I18N_BROADCAST_MTS;
	tInfo.checked = nil;
	tInfo.func = VUHDO_minimapItemSelected;
	tInfo.arg1 = "BROAD";
	tInfo.notClickable = VUHDO_getPlayerRank() < 1;
	UIDropDownMenu_AddButton(tInfo);

	tInfo = UIDropDownMenu_CreateInfo();
	tInfo.text = VUHDO_I18N_RESET_ROLES;
	tInfo.checked = nil;
	tInfo.func = VUHDO_minimapItemSelected;
	tInfo.arg1 = "ROLES";
	UIDropDownMenu_AddButton(tInfo);

	VUHDO_createEmptyLine();

	tInfo = UIDropDownMenu_CreateInfo();
	tInfo.text = VUHDO_I18N_LOAD_PROFILE;
	tInfo.hasArrow = true;
	tInfo.value = "S";
	UIDropDownMenu_AddButton(tInfo);

	tInfo = UIDropDownMenu_CreateInfo();
	tInfo.text = VUHDO_I18N_LOAD_KEY_SETUP;
	tInfo.hasArrow = true;
	tInfo.value = "K";
	UIDropDownMenu_AddButton(tInfo);

	VUHDO_createEmptyLine();

	tInfo = UIDropDownMenu_CreateInfo();
	tInfo.text = VUHDO_I18N_TOGGLES;
	tInfo.isTitle = true;
	UIDropDownMenu_AddButton(tInfo);

	VUHDO_createMinimapToggle(VUHDO_I18N_LOCK_PANELS, "LOCK", VUHDO_CONFIG["LOCK_PANELS"]);
	VUHDO_createMinimapToggle(VUHDO_I18N_SHOW_PANELS, "SHOW", VUHDO_CONFIG["SHOW_PANELS"]);
	VUHDO_createMinimapToggle(VUHDO_I18N_SHOW_BUFF_WATCH, "BUFF", VUHDO_BUFF_SETTINGS["CONFIG"]["SHOW"]);
	VUHDO_createMinimapToggle(VUHDO_I18N_MM_BUTTON, "MINIMAP", VUHDO_CONFIG["SHOW_MINIMAP"]);

	VUHDO_createEmptyLine();

	tInfo = UIDropDownMenu_CreateInfo();
	tInfo.text = VUHDO_I18N_CLOSE;
	UIDropDownMenu_AddButton(tInfo);
end



--
function VUHDO_minimapItemSelected(_, anId)
  local tCmd;
	if ("LOCK" == anId) then
		tCmd = "lock";
	elseif ("MINIMAP" == anId) then
		tCmd = "minimap";
	elseif ("SHOW" == anId) then
		tCmd = "toggle";
	elseif ("BROAD" == anId) then
		tCmd = "cast";
	elseif ("1" == anId) then
		tCmd = "options";
	elseif ("BUFF" == anId) then
		VUHDO_BUFF_SETTINGS["CONFIG"]["SHOW"] = not VUHDO_BUFF_SETTINGS["CONFIG"]["SHOW"];
		VUHDO_reloadBuffPanel();
		VUHDO_saveCurrentProfile();
		return;
	elseif ("ROLES" == anId) then
		table.wipe(VUHDO_MANUAL_ROLES);
		VUHDO_reloadUI();
		return;
	end

	VUHDO_slashCmd(tCmd);
end



--
function VUHDO_initMinimap()
  MyMinimapButton:Create("VuhDo", VUHDO_MM_SETTINGS, VUHDO_MM_LAYOUT);
  MyMinimapButton:SetLeftClick("VuhDo", VUHDO_minimapLeftClick);
  MyMinimapButton:SetRightClick("VuhDo", VUHDO_minimapRightClick);
  VUHDO_initShowMinimap();
end



--
function VUHDO_initShowMinimap()
	if (VUHDO_CONFIG["SHOW_MINIMAP"]) then
		VuhDoMinimapButton:Show();
	else
		VuhDoMinimapButton:Hide();
	end
end
