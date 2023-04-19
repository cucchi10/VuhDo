
VUHDO_FAST_ACCESS_ACTIONS = { };



-- BURST CACHE ---------------------------------------------------

local VUHDO_RAID_NAMES;
local VUHDO_RAID;
local VUHDO_BUFF_REMOVAL_SPELLS;
local VUHDO_SPELL_ASSIGNMENTS;
local VUHDO_CONFIG;

local VUHDO_resolveButtonUnit;
local VUHDO_buildMacroText;
local VUHDO_buildTargetButtonMacroText;
local VUHDO_buildTargetMacroText;
local VUHDO_buildFocusMacroText;
local VUHDO_buildAssistMacroText;
local VUHDO_getDebuffAbilities;

local string = string;
local GetMacroIndexByName = GetMacroIndexByName;
local GetSpellInfo = GetSpellInfo;
local UnitIsDeadOrGhost = UnitIsDeadOrGhost;
local gsub = gsub;
local strlower = strlower;
local strtrim = strtrim;
local UnitBuff = UnitBuff;
local GetCursorInfo = GetCursorInfo;
local GetShapeshiftForm = GetShapeshiftForm;
local InCombatLockdown = InCombatLockdown;
local pairs = pairs;

function VUHDO_keySetupInitBurst()
	VUHDO_RAID_NAMES = VUHDO_GLOBAL["VUHDO_RAID_NAMES"];
	VUHDO_RAID = VUHDO_GLOBAL["VUHDO_RAID"];
	VUHDO_BUFF_REMOVAL_SPELLS = VUHDO_GLOBAL["VUHDO_BUFF_REMOVAL_SPELLS"];
	VUHDO_SPELL_ASSIGNMENTS = VUHDO_GLOBAL["VUHDO_SPELL_ASSIGNMENTS"];
	VUHDO_CONFIG = VUHDO_GLOBAL["VUHDO_CONFIG"];

	VUHDO_resolveButtonUnit = VUHDO_GLOBAL["VUHDO_resolveButtonUnit"];
	VUHDO_buildMacroText = VUHDO_GLOBAL["VUHDO_buildMacroText"];
	VUHDO_buildTargetButtonMacroText = VUHDO_GLOBAL["VUHDO_buildTargetButtonMacroText"];
	VUHDO_buildTargetMacroText = VUHDO_GLOBAL["VUHDO_buildTargetMacroText"];
	VUHDO_buildFocusMacroText = VUHDO_GLOBAL["VUHDO_buildFocusMacroText"];
	VUHDO_buildAssistMacroText = VUHDO_GLOBAL["VUHDO_buildAssistMacroText"];
	VUHDO_getDebuffAbilities = VUHDO_GLOBAL["VUHDO_getDebuffAbilities"];
end
----------------------------------------------------



local VUHDO_REZ_SPELLS_NAMES = {
	[VUHDO_SPELL_ID_REDEMPTION] = true,
	[VUHDO_SPELL_ID_ANCESTRAL_SPIRIT] = true,
	[VUHDO_SPELL_ID_REVIVE] = true,
	[VUHDO_SPELL_ID_REBIRTH] = true,
	[VUHDO_SPELL_ID_RESURRECTION] = true,
};



--
function VUHDO_replaceMacroTemplates(aText, aUnit)
	if (VUHDO_RAID_NAMES[aUnit] ~= nil) then
		aUnit = VUHDO_RAID_NAMES[aUnit];
	end
	if (aUnit ~= nil) then
		aText = gsub(aText, "vuhdo", aUnit);

		if (VUHDO_RAID_NAMES[aUnit] ~= nil) then
			aUnit = VUHDO_RAID_NAMES[aUnit];
		end

		if (VUHDO_RAID[aUnit] ~= nil) then
			aText = gsub(aText, "vdname", VUHDO_RAID[aUnit]["name"]);

			if (VUHDO_RAID[aUnit].petUnit ~= nil) then
				aText = gsub(aText, "vdpet", VUHDO_RAID[aUnit]["petUnit"]);
			end

			if (VUHDO_RAID[aUnit].targetUnit ~= nil) then
				aText = gsub(aText, "vdtarget", VUHDO_RAID[aUnit]["targetUnit"]);
			end
		end
	end

	return aText;
end
local VUHDO_replaceMacroTemplates = VUHDO_replaceMacroTemplates;


--
local sDropdown;
local sUnit, sInfo, sIdent;
local tButtonName;
local tHostSpell;
local tMacroId, tMacroText;
local tActionLow;
local tBaseSpell;
local tSpellInfo;
local function VUHDO_setupHealButtonAttributes(aModiKey, aButtonId, anAction, aButton, anIsTgButton, anIndex)

	if (anIsTgButton or aButton["target"] == "focus" or aButton["target"] == "target") then
		if (anIndex == nil) then
			tHostSpell = VUHDO_HOSTILE_SPELL_ASSIGNMENTS[gsub(aModiKey, "-", "") .. aButtonId][3];
		else
			tHostSpell = VUHDO_SPELLS_KEYBOARD["HOSTILE_WHEEL"][anIndex][3];
		end
		aButton:SetAttribute(aModiKey .. "type" .. aButtonId, "macro");
		aButton:SetAttribute(aModiKey .. "macrotext" .. aButtonId,
			VUHDO_buildTargetButtonMacroText(aButton["target"], anAction, tHostSpell));
		return;
	end

	if (anAction == nil or anAction == "") then
		return;
	end

	tActionLow = strlower(anAction);

	if (VUHDO_SPELL_KEY_ASSIST == tActionLow) then
		aButton:SetAttribute(aModiKey .. "type" .. aButtonId, "macro");
		aButton:SetAttribute(aModiKey .. "macrotext" .. aButtonId,
			VUHDO_buildAssistMacroText(aButton["target"]));
	elseif (VUHDO_SPELL_KEY_FOCUS == tActionLow) then
		aButton:SetAttribute(aModiKey .. "type" .. aButtonId, "macro");
		aButton:SetAttribute(aModiKey .. "macrotext" .. aButtonId,
			VUHDO_buildFocusMacroText(aButton["target"]));

	elseif (VUHDO_SPELL_KEY_TARGET == tActionLow) then
		aButton:SetAttribute(aModiKey .. "type" .. aButtonId, "macro");
		aButton:SetAttribute(aModiKey .. "macrotext" .. aButtonId,
			VUHDO_buildTargetMacroText(aButton["target"]));
	elseif (VUHDO_SPELL_KEY_MENU == tActionLow
		or VUHDO_SPELL_KEY_TELL == tActionLow) then
		aButton:SetAttribute(aModiKey .. "type" .. aButtonId, nil);
	elseif (VUHDO_SPELL_KEY_DROPDOWN == tActionLow) then
		aButton:SetAttribute(aModiKey .."type" .. aButtonId, "VUHDO_contextMenu");

		VUHDO_contextMenu = function()
			sDropdown = nil;

			if (aButton["raidid"] == "player") then
				sDropdown = PlayerFrameDropDown;
			elseif (UnitIsUnit(aButton["raidid"], "pet")) then
				sDropdown = PetFrameDropDown;
			else
				sUnit = aButton["raidid"];
				sInfo = VUHDO_RAID[sUnit];

				if (sInfo ~= nil) then
					if (not UnitInRaid("player")) then
						sDropdown = VUHDO_GLOBAL['PartyMemberFrame' .. sInfo["number"] .. 'DropDown']
					else
						sIdent = sInfo.number;
						if (sIdent == 0) then
							sIdent = aButton["index"];
						end
						FriendsDropDown["name"] = sInfo["name"];
						FriendsDropDown["id"] = sIdent;
						FriendsDropDown["unit"] = sUnit;
						FriendsDropDown["initialize"] = RaidFrameDropDown_Initialize;
						FriendsDropDown["displayMode"] = "MENU";
						sDropdown = FriendsDropDown;
					end
				end
			end

			if (sDropdown ~= nil) then
				ToggleDropDownMenu(1, nil, sDropdown, "cursor", 0, 0);
			end
		end

		aButton.VUHDO_contextMenu = VUHDO_contextMenu;
	else
		tMacroId = GetMacroIndexByName(anAction);
		if (tMacroId ~= 0) then
			_, _, tMacroText = GetMacroInfo(tMacroId);
			tMacroText = VUHDO_replaceMacroTemplates(tMacroText, aButton["raidid"]);
			aButton:SetAttribute(aModiKey .. "type" .. aButtonId, "macro");
			aButton:SetAttribute(aModiKey .. "macrotext" .. aButtonId, tMacroText);
		else
			tBaseSpell = strtrim(anAction);
			tSpellInfo = GetSpellInfo(tBaseSpell);
			if (tSpellInfo ~= nil or (VUHDO_IN_COMBAT_RELOG and VUHDO_FAST_ACCESS_ACTIONS[anAction] == "S")) then
				if (VUHDO_REZ_SPELLS_NAMES[tBaseSpell] ~= nil) then
					aButton:SetAttribute(aModiKey .. "type" .. aButtonId, "spell");
					aButton:SetAttribute(aModiKey .. "spell" .. aButtonId, tBaseSpell);
					return;
				-- Cleansing charmed players is an offensive thing to do
				elseif (VUHDO_BUFF_REMOVAL_SPELLS[tBaseSpell] ~= nil) then
					aButton:SetAttribute(aModiKey .. "type" .. aButtonId, "macro");
					aButton:SetAttribute(aModiKey .. "macrotext" .. aButtonId,
						VUHDO_buildPurgeMacroText(tBaseSpell, aButton["target"]));
					return;
				else
					-- build a spell macro
					aButton:SetAttribute(aModiKey .. "type" .. aButtonId, "macro");
					aButton:SetAttribute(aModiKey .. "macrotext" .. aButtonId,
						VUHDO_buildMacroText(tBaseSpell, false, aButton["target"]));
				end

				VUHDO_FAST_ACCESS_ACTIONS[anAction] = "S";
			else -- try to use item
				aButton:SetAttribute(aModiKey .. "type" .. aButtonId, "item");
				aButton:SetAttribute(aModiKey .. "item" .. aButtonId, tBaseSpell);
			end
		end
	end
end



-- Parse and interpret action-type
local tPreAction;
local tTarget;
local tIndex;
local tSpellDescr;
--local tInfo;
local tIsWheel;
local tHostSpell;
function VUHDO_setupAllHealButtonAttributes(aButton, aUnit, anIsDisable, aForceTarget, anIsTgButton)

	if (aUnit ~= nil) then
		aButton:SetAttribute("unit", aUnit);
		aButton["raidid"] = aUnit;
		aButton["target"] = aUnit;
	end

	if (aButton:GetAttribute("vd_tt_hook") == nil and not anIsTgButton and VUHDO_BUTTON_CACHE[aButton] ~= nil) then
		aButton:HookScript("OnEnter",
			function(self)
				VuhDoActionOnEnter(self);
			end
		);

		aButton:HookScript("OnLeave",
			function(self)
				VuhDoActionOnLeave(self);
			end
		);

		aButton:SetAttribute("vd_tt_hook", true);
	end

	if (VUHDO_CONFIG["IS_CLIQUE_COMPAT_MODE"]) then
		return;
	end

	if (anIsDisable) then
		tPreAction = "";
	elseif (aForceTarget) then
		tPreAction = "target";
	else
		tPreAction = nil;
	end

	if (tPreAction ~= nil) then
		for _, tSpellDescr in pairs(VUHDO_SPELL_ASSIGNMENTS) do
			VUHDO_setupHealButtonAttributes(tSpellDescr[1], tSpellDescr[2], tPreAction, aButton, anIsTgButton);
		end
	else
		for _, tSpellDescr in pairs(VUHDO_SPELL_ASSIGNMENTS) do
			VUHDO_setupHealButtonAttributes(tSpellDescr[1], tSpellDescr[2], tSpellDescr[3], aButton, anIsTgButton);
		end
	end

	tIsWheel = false;
	for tIndex, tSpellDescr in pairs(VUHDO_SPELLS_KEYBOARD["WHEEL"]) do
		tHostSpell = VUHDO_SPELLS_KEYBOARD["HOSTILE_WHEEL"][tIndex][3];
		if ( (tSpellDescr[3] ~= nil and strlen(strtrim(tSpellDescr[3])) > 0)
			or (tHostSpell ~= nil     and strlen(strtrim(tHostSpell)) > 0) ) then

			tIsWheel = true;
			VUHDO_setupHealButtonAttributes("", tSpellDescr[2] , tSpellDescr[3], aButton, anIsTgButton, tIndex);
		end
	end

	-- Tooltips and stuff for raid members only (not: target buttons)
	if (VUHDO_BUTTON_CACHE[aButton] ~= nil) then

		if (tIsWheel) then
			aButton:SetAttribute("_onenter", [=[
					self:ClearBindings();
					self:SetBindingClick(0, "MOUSEWHEELUP" , self:GetName(), "w1");
					self:SetBindingClick(0, "MOUSEWHEELDOWN" , self:GetName(), "w2");

					self:SetBindingClick(0, "ALT-MOUSEWHEELUP" , self:GetName(), "w3");
					self:SetBindingClick(0, "ALT-MOUSEWHEELDOWN" , self:GetName(), "w4");

					self:SetBindingClick(0, "CTRL-MOUSEWHEELUP" , self:GetName(), "w5");
					self:SetBindingClick(0, "CTRL-MOUSEWHEELDOWN" , self:GetName(), "w6");

					self:SetBindingClick(0, "SHIFT-MOUSEWHEELUP" , self:GetName(), "w7");
					self:SetBindingClick(0, "SHIFT-MOUSEWHEELDOWN" , self:GetName(), "w8");

					self:SetBindingClick(0, "ALT-CTRL-MOUSEWHEELUP" , self:GetName(), "w9");
					self:SetBindingClick(0, "ALT-CTRL-MOUSEWHEELDOWN" , self:GetName(), "w10");

					self:SetBindingClick(0, "ALT-SHIFT-MOUSEWHEELUP" , self:GetName(), "w11");
					self:SetBindingClick(0, "ALT-SHIFT-MOUSEWHEELDOWN" , self:GetName(), "w12");

					self:SetBindingClick(0, "CTRL-SHIFT-MOUSEWHEELUP" , self:GetName(), "w13");
					self:SetBindingClick(0, "CTRL-SHIFT-MOUSEWHEELDOWN" , self:GetName(), "w14");

					self:SetBindingClick(0, "ALT-CTRL-SHIFT-MOUSEWHEELUP" , self:GetName(), "w15");
					self:SetBindingClick(0, "ALT-CTRL-SHIFT-MOUSEWHEELDOWN" , self:GetName(), "w16");
			]=]);
		else
			aButton:SetAttribute("_onenter", [=[
				self:ClearBindings();
			]=]);
		end


		aButton:SetAttribute("_onleave", [=[
			self:ClearBindings();
		]=]);

		aButton:SetAttribute("_onshow", [=[
			self:ClearBindings();
		]=]);

		aButton:SetAttribute("_onhide", [=[
			self:ClearBindings();
		]=]);
	end
end
local VUHDO_setupAllHealButtonAttributes = VUHDO_setupAllHealButtonAttributes;



--
local tSpellDescr;
local tModiKey, tButtonId, tAction;
local function VUHDO_setupAllButtonsTo(aButton, aSpellName)
	for _, tSpellDescr in pairs(VUHDO_SPELL_ASSIGNMENTS) do
		tModiKey = tSpellDescr[1];
		tButtonId = tSpellDescr[2];
		tAction = tSpellDescr[3];

		if ("target" == tAction or "assist" == tAction or "focus" == tAction) then
			VUHDO_setupHealButtonAttributes(tModiKey, tButtonId, tAction, aButton, false);
		else
			VUHDO_setupHealButtonAttributes(tModiKey, tButtonId, aSpellName, aButton, false);
		end
	end
end



--
function VUHDO_setupAllTargetButtonAttributes(aButton, aUnit)
	VUHDO_setupAllHealButtonAttributes(aButton, aUnit .. "target", false, false, true);
end



--
function VUHDO_setupAllTotButtonAttributes(aButton, aUnit)
	VUHDO_setupAllHealButtonAttributes(aButton, aUnit .. "targettarget", false, false, true);
end



--
function VUHDO_disableActions(aButton)
	VUHDO_setupAllHealButtonAttributes(aButton, nil, true, false, false);
	aButton:Hide(); -- For clearing mouse-wheel click bindings
	aButton:Show();
end



--
local tIsShadowFrom, tIsImproved;
local function VUHDO_isShadowForm()
	_, _, tIsShadowFrom = UnitBuff("player", VUHDO_SPELL_ID_SHADOWFORM);
	_, _, tIsImproved = UnitBuff("player", VUHDO_SPELL_ID_IMPROVED_SHADOWFORM);
	return tIsShadowFrom or tIsImproved;
end



--
local tCursorItemType;
local tAbilities;
local tUnit;
local tInfo;
local tVariants, tMaxVariant;
function VUHDO_setupSmartCast(aButton)
	if (InCombatLockdown() or UnitIsDeadOrGhost("player")
		or (VUHDO_PLAYER_CLASS == "PRIEST" and GetShapeshiftForm() ~= 0 and not VUHDO_isShadowForm())) then
		return false;
	end

	tUnit = aButton["raidid"];
	tInfo = VUHDO_RAID[tUnit];

	if (tInfo == nil or not tInfo["baseRange"]) then
		return false;
	end;
	-- Trade?
	tCursorItemType, _, _ = GetCursorInfo();
	if ("item" == tCursorItemType or "money" == tCursorItemType) then
		DropItemOnUnit(tUnit);
		VUHDO_disableActions(aButton);
		return true;
	end

	-- Resurrect?
	if (VUHDO_CONFIG["SMARTCAST_RESURRECT"] and tInfo["dead"]) then
		local tMainRes, _ = VUHDO_getResurrectionSpells();
		if (tMainRes ~= nil) then
			if (not UnitIsGhost(tUnit)) then

				VUHDO_setupAllButtonsTo(aButton, tMainRes);
				return true;
			else
				UIErrorsFrame:AddMessage(VUHDO_I18N_RESS_ERR_1 .. UnitName(tUnit) .. VUHDO_I18N_RESS_ERR_2, 1, 0.1, 0.1, 1);
				return false;
			end
		end
	end

	-- Cleanse?
	if (VUHDO_CONFIG["SMARTCAST_CLEANSE"] and not tInfo["dead"]) then
		if (VUHDO_DEBUFF_TYPE_NONE ~= tInfo["debuff"]) then
			tAbilities = VUHDO_getDebuffAbilities(VUHDO_PLAYER_CLASS);
			if (tAbilities[tInfo["debuff"]] ~= nil) then
				VUHDO_setupAllButtonsTo(aButton, tAbilities[tInfo["debuff"]]);
				return true;
			end
		end
	end

	-- Buff?
	if (VUHDO_CONFIG["SMARTCAST_BUFF"] and tInfo["missbuff"] ~= nil and not tInfo["dead"]) then
		tVariants = tInfo["mibuvariants"];
		VUHDO_setupAllButtonsTo(aButton, VUHDO_getBuffVariantSingleTarget(tVariants)[1]);
		tMaxVariant = VUHDO_getBuffVariantMaxTarget(tVariants)[1];
		if ((VUHDO_buffWatchGetNumLow(tMaxVariant) >= VUHDO_BUFF_SETTINGS["CONFIG"]["AT_LEAST_MISSING"]
			   and "smart" == VUHDO_BUFF_SETTINGS["CONFIG"]["GROUP_SPELL_VERSION"]
				)
				or "always" == VUHDO_BUFF_SETTINGS["CONFIG"]["GROUP_SPELL_VERSION"]) then

			VUHDO_setupHealButtonAttributes("", "2", tMaxVariant, aButton, false);
		else
			VUHDO_setupHealButtonAttributes("", "2", VUHDO_getBuffVariantSingleTarget(tVariants)[1], aButton, false);
		end
		return true;
	end

	return false;
end
