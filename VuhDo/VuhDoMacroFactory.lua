VUHDO_IS_SFX_ENABLED = true;

local VUHDO_RAID;
local VUHDO_RAID_NAMES;
local VUHDO_SPELL_CONFIG;
local VUHDO_SPELLS;
local VUHDO_SPELL_CONFIG;

local GetMacroIndexByName = GetMacroIndexByName;
local GetMacroInfo = GetMacroInfo;
local GetSpellInfo = GetSpellInfo;
local strlen = strlen;
local gsub = gsub;



function VUHDO_macroFactoryInitBurst()
	VUHDO_RAID = VUHDO_GLOBAL["VUHDO_RAID"];
	VUHDO_RAID_NAMES = VUHDO_GLOBAL["VUHDO_RAID_NAMES"];
	VUHDO_SPELL_CONFIG = VUHDO_GLOBAL["VUHDO_SPELL_CONFIG"];
	VUHDO_SPELLS = VUHDO_GLOBAL["VUHDO_SPELLS"];
	VUHDO_SPELL_CONFIG = VUHDO_GLOBAL["VUHDO_SPELL_CONFIG"];
end



local VUHDO_RAID_MACRO_CACHE = { };
local VUHDO_TARGET_MACRO_CACHE = { };
local sFireText = nil;


--
function VUHDO_resetMacroCaches()
  table.wipe(VUHDO_RAID_MACRO_CACHE);
  table.wipe(VUHDO_TARGET_MACRO_CACHE);
  sFireText = nil;
end



--
local function VUHDO_isFireSomething(anAction)
	if (not VUHDO_SPELL_CONFIG["IS_AUTO_FIRE"]) then
		return false;
	end

	if (VUHDO_SPELLS[anAction] ~= nil and VUHDO_SPELLS[anAction]["type"] == VUHDO_SPELL_TYPE_HOT
		and not VUHDO_SPELL_CONFIG["IS_FIRE_HOT"]) then
		return false;
	end

	if (VUHDO_SPELL_CONFIG["IS_FIRE_TRINKET_1"] or VUHDO_SPELL_CONFIG["IS_FIRE_TRINKET_2"]) then
		return true;
	end

	if (VUHDO_SPELL_CONFIG["IS_FIRE_CUSTOM_1"] and VUHDO_SPELL_CONFIG["FIRE_CUSTOM_1_SPELL"] ~= nil and strlen(VUHDO_SPELL_CONFIG["FIRE_CUSTOM_1_SPELL"]) > 0) then
		return true;
	end

	if (VUHDO_SPELL_CONFIG["IS_FIRE_CUSTOM_2"] and VUHDO_SPELL_CONFIG["FIRE_CUSTOM_2_SPELL"] ~= nil and strlen(VUHDO_SPELL_CONFIG["FIRE_CUSTOM_2_SPELL"]) > 0) then
		return true;
	end

	return false;
end



--
local function VUHDO_getFireText(anAction)

	if (VUHDO_isFireSomething(anAction)) then
		if (sFireText == nil) then
			sFireText = "";
			if (VUHDO_IS_SFX_ENABLED) then
	  		sFireText = sFireText .. "/console Sound_EnableSFX 0\n";
	  	end

	  	if (VUHDO_SPELL_CONFIG["IS_FIRE_OUT_FIGHT"]) then
	  		tModi = " ";
	  	else
	  		tModi = " [combat] ";
	  	end

			if (VUHDO_SPELL_CONFIG["IS_FIRE_TRINKET_1"]) then
	  		sFireText = sFireText .. "/use".. tModi .."13\n";
	  	end

			if (VUHDO_SPELL_CONFIG["IS_FIRE_TRINKET_2"]) then
	  		sFireText = sFireText .. "/use".. tModi .."14\n";
	  	end

			-- Instant 1
			tInstant = VUHDO_SPELL_CONFIG["FIRE_CUSTOM_1_SPELL"];
			if (VUHDO_SPELL_CONFIG["IS_FIRE_CUSTOM_1"] and tInstant ~= nil and strlen(tInstant) > 0) then

				if (VUHDO_SPELL_CONFIG["IS_FIRE_OUT_FIGHT"]) then
					if (VUHDO_SPELLS[tInstant] ~= nil and VUHDO_SPELLS[tInstant].noselftarget) then
						tModi2 = " ";
					else
						tModi2 = " [@player] ";
					end
				else
					if (VUHDO_SPELLS[tInstant] ~= nil and VUHDO_SPELLS[tInstant].noselftarget) then
						tModi2 = " [combat] ";
					else
						tModi2 = " [combat,@player] ";
					end
				end

	  		sFireText = sFireText .. "/cast" .. tModi2 .. VUHDO_SPELL_CONFIG["FIRE_CUSTOM_1_SPELL"] .. "\n";
	  	end

			-- Instant 2
			tInstant = VUHDO_SPELL_CONFIG["FIRE_CUSTOM_2_SPELL"];
			if (VUHDO_SPELL_CONFIG["IS_FIRE_CUSTOM_2"] and tInstant ~= nil and strlen(tInstant) > 0) then

				if (VUHDO_SPELL_CONFIG["IS_FIRE_OUT_FIGHT"]) then
					if (VUHDO_SPELLS[tInstant] ~= nil and VUHDO_SPELLS[tInstant].noselftarget) then
						tModi2 = " ";
					else
						tModi2 = " [@player] ";
					end
				else
					if (VUHDO_SPELLS[tInstant] ~= nil and VUHDO_SPELLS[tInstant].noselftarget) then
						tModi2 = " [combat] ";
					else
						tModi2 = " [combat,@player] ";
					end
				end

	  		sFireText = sFireText .. "/cast" .. tModi2 .. VUHDO_SPELL_CONFIG["FIRE_CUSTOM_2_SPELL"] .. "\n";
	  	end

			-- Ton wieder an
			if (VUHDO_IS_SFX_ENABLED) then
	  		sFireText = sFireText .. "/console Sound_EnableSFX 1\n";
	  	end

	  	sFireText = sFireText .. "/run UIErrorsFrame:Clear()\n";
	  end

		return sFireText;
	else
		return "";
	end

end



--
local tPet;
local function VUHDO_getMacroPetUnit(aTarget)
	if (VUHDO_RAID[aTarget] ~= nil and not VUHDO_RAID[aTarget]["isPet"]) then
		return VUHDO_RAID[aTarget]["petUnit"];
	else
		return nil;
	end
end



--
local tFriendText;
local tEnemyText;
local tModiSpell;
local tMacroId, tMacroText;
local tLowerFriendly, tLowerHostile, tStopText;
local function VUHDO_generateTargetMacroText(aTarget, aFriendlyAction, aHostileAction)
	if (aFriendlyAction == nil or aHostileAction == nil) then
		return "";
	end

	tMacroId = GetMacroIndexByName(aHostileAction);
	if (tMacroId ~= 0) then
		_, _, tMacroText = GetMacroInfo(tMacroId);
		return tMacroText;
	end

	tLowerFriendly = strlower(aFriendlyAction);
	tLowerHostile = strlower(aHostileAction);

	if ("target" == tLowerFriendly) then
		tFriendText = "/tar [noharm,@vuhdo]\n";
	elseif ("focus" == tLowerFriendly) then
		tFriendText = "/focus [noharm,@vuhdo]\n";
	elseif ("assist" == tLowerFriendly) then
		tFriendText = "/assist [noharm,@vuhdo]\n";
	elseif (strlen(aFriendlyAction) > 0 and GetSpellInfo(aFriendlyAction) ~= nil) then
		tModiSpell = "[noharm,@vuhdo";

		if (VUHDO_SPELL_CONFIG["IS_KEEP_STANCE"]) then
  		if ("DRUID" == VUHDO_PLAYER_CLASS) then
  			tModiSpell = tModiSpell .. ",noform:1/3";
  		end

  		if ("PRIEST" == VUHDO_PLAYER_CLASS) then
  			tModiSpell = tModiSpell .. ",noform:1";
  		end
		end
  	tModiSpell = tModiSpell .. "] ";
		tFriendText = "/cast " .. tModiSpell .. aFriendlyAction .. "\n";
		if (VUHDO_SPELL_CONFIG["IS_AUTO_TARGET"]) then
			tFriendText = tFriendText .. "/tar [@vuhdo]\n";
		end
	else
		tFriendText = "";
	end

	if ("target" == tLowerHostile) then
		tEnemyText = "/tar [harm,@vuhdo]\n";
	elseif ("focus" == tLowerHostile) then
		tEnemyText = "/focus [harm,@vuhdo]\n";
	elseif ("assist" == tLowerHostile) then
		tEnemyText = "/assist [harm,@vuhdo]\n";
	elseif (strlen(aHostileAction) > 0 and GetSpellInfo(aHostileAction) ~= nil) then
		tEnemyText = "/cast [harm,@vuhdo] " .. aHostileAction .. "\n";
	else
		tEnemyText = "";
	end

	if (VUHDO_SPELL_CONFIG["IS_CANCEL_CURRENT"]) then
		tStopText = "/stopcasting\n";
	else
		tStopText = "";
	end

	return tStopText .. VUHDO_getFireText(aFriendlyAction) .. tFriendText .. tEnemyText;
end



--
local tIndex, tText;
function VUHDO_buildTargetButtonMacroText(aTarget, aFriendlyAction, aHostileAction)
  tIndex = aFriendlyAction .. aHostileAction;

  if (VUHDO_TARGET_MACRO_CACHE[tIndex] == nil) then
    VUHDO_TARGET_MACRO_CACHE[tIndex] = VUHDO_generateTargetMacroText(aTarget, aFriendlyAction, aHostileAction);
  end

  tText = gsub(VUHDO_TARGET_MACRO_CACHE[tIndex], "vuhdo", aTarget);
	return tText;
end



--
function VUHDO_buildFocusMacroText(aTarget)
	tPet = VUHDO_getMacroPetUnit(aTarget);

	if (tPet ~= nil) then
		return "/focus [@" .. aTarget .. ",help][@" .. tPet .. ",help][@" .. aTarget .. "]";
	else
		return "/focus [@" .. aTarget .. "]";
	end
end



--
function VUHDO_buildTargetMacroText(aTarget)
	tPet = VUHDO_getMacroPetUnit(aTarget);

	if (tPet ~= nil) then
		return "/tar [@" .. aTarget .. ",help][@" .. tPet .. ",help][@" .. aTarget .. "]";
	else
		return "/tar [@" .. aTarget .. "]";
	end
end



--
function VUHDO_buildAssistMacroText(aTarget)
	tPet = VUHDO_getMacroPetUnit(aTarget);

	if (tPet ~= nil) then
		return "/assist [@" .. aTarget .. ",help][@" .. tPet .. ",help][@" .. aTarget .. "]";
	else
		return "/assist [@" .. aTarget .. "]";
	end
end




local VUHDO_PROHIBIT_HELP = {
	[VUHDO_SPELL_ID_REBIRTH] = true,
}



--
local tText;
local tModi;
local tModi2;

local tModiSpell;
local tSpellPost;
local tVehicleCond;
local tInstant;
local tStopText;
local function VUHDO_generateRaidMacroTemplate(anAction, anIsKeyboard, aTarget, aPet)
	if (VUHDO_SPELL_CONFIG["IS_CANCEL_CURRENT"]) then
		tStopText = "/stopcasting\n";
	else
		tStopText = "";
	end

	tText = tStopText .. VUHDO_getFireText(anAction);

	if (VUHDO_SPELLS[anAction] ~= nil and not VUHDO_SPELLS[anAction].nohelp and not VUHDO_PROHIBIT_HELP[anAction]) then
		tModiSpell = "help,";
	else
		tModiSpell = "";
	end

	tSpellPost = "";
	if ("DRUID" == VUHDO_PLAYER_CLASS) then
		if (VUHDO_SPELL_CONFIG["autoBattleRez"]) then
			tModiSpell = tModiSpell .. "nodead,";
			tSpellPost = "/cast [dead,nobonusbar:5,combat,";
			if (VUHDO_SPELL_CONFIG["smartCastModi"] ~= "all") then
				tSpellPost = tSpellPost .. "mod:" .. VUHDO_SPELL_CONFIG["smartCastModi"] .. ",";
			end
			tSpellPost =  tSpellPost .. "@mouseover] " .. VUHDO_SPELL_ID_REBIRTH .. "\n";
		end
	end

	if (VUHDO_SPELL_CONFIG["IS_KEEP_STANCE"] and VUHDO_SPELL_ID_REBIRTH ~= anAction and VUHDO_SPELLS[anAction] ~= nil and not VUHDO_SPELLS[anAction].nostance) then
  	if ("DRUID" == VUHDO_PLAYER_CLASS) then
  		tModiSpell = tModiSpell .. "noform:1/3,";

			if (anIsKeyboard) then
  			tSpellPost = "/tar [form:1/3,nobonusbar:5,@mouseover]\n";
  		else
  			tSpellPost = "/tar [form:1/3,nobonusbar:5,@vuhdo]\n";
  		end
  	end

  	if ("PRIEST" == VUHDO_PLAYER_CLASS) then
  		tModiSpell = tModiSpell .. "noform:1,";
			if (anIsKeyboard) then
	  		tSpellPost = "/tar [form:1,nobonusbar:5,@mouseover]\n";
  		else
	  		tSpellPost = "/tar [form:1,nobonusbar:5,@vuhdo]\n";
  		end
  	end
	end

	if (anIsKeyboard) then
		tText = tText .. "/cast [" .. tModiSpell .. "@mouseover] " .. anAction .. "\n";
		tText = tText .. tSpellPost;
	else
		if (aPet ~= nil and VUHDO_SPELL_ID_REBIRTH ~= anAction) then
			tVehicleCond = "[nodead,help,nobonusbar:5,@vdpet]";
		else
			tVehicleCond = "";
		end
		tText = tText .. "/cast [" .. tModiSpell .. "nobonusbar:5,@vuhdo]" .. tVehicleCond .. " " .. anAction .. "\n";
		tText = tText .. tSpellPost;
		if (aPet ~= nil) then
			tText = tText .. "/tar [bonusbar:5,@vdpet]\n";
		end
	end

	--if (not anIsKeyboard) then
		if (VUHDO_SPELL_CONFIG["IS_AUTO_TARGET"]) then
			tText = tText .. "/tar [@vuhdo]\n";
		else
			tText = tText .. "/tar [harm,@vuhdo]\n";
		end
	--end

	return tText;
end


--
local tIndex;
local tPet;
local tText;
function VUHDO_buildMacroText(anAction, anIsKeyboard, aTarget)
  if (anIsKeyboard) then
    tIndex = anAction .. "$K";
  else
    tIndex = anAction .. "$M";
  end

	tPet = VUHDO_getMacroPetUnit(aTarget);
  if (tPet == nil) then
  	tIndex = tIndex .. "P";
  end

  if (VUHDO_RAID_MACRO_CACHE[tIndex] == nil) then
    VUHDO_RAID_MACRO_CACHE[tIndex] = VUHDO_generateRaidMacroTemplate(anAction, anIsKeyboard, aTarget, tPet);
  end

	tText = VUHDO_RAID_MACRO_CACHE[tIndex];
	if (aTarget ~= nil) then
	  tText = gsub(tText, "vuhdo", aTarget);
	  tPet = VUHDO_getMacroPetUnit(aTarget);
	  if (tPet ~= nil) then
		  tText = gsub(tText, "vdpet", tPet);
		end
	end

	if (anIsKeyboard and strlen(tText) > 256) then
		VUHDO_Msg(VUHDO_I18N_MACRO_KEY_ERR_1 .. anAction .. " (" .. strlen(tText) .. VUHDO_I18N_MACRO_KEY_ERR_2, 1, 0.3, 0.3);
	end
	return tText;
end



--
function VUHDO_buildPurgeMacroText(anAction, aTarget)
	return "/cast [@" .. aTarget .. "] " .. anAction;
end



--
local tName;
local tIndex;
local function VUHDO_createOrUpdateMacro(aMacroNum, aMacroText, aSpell)
	tName = "VuhDoAuto" .. aMacroNum;
	local tIndex = GetMacroIndexByName(tName);
	if (tIndex == 0) then
		local _, tNumLocal = GetNumMacros();
		if (tNumLocal >= 18) then
			VUHDO_Msg(VUHDO_I18N_MACRO_NUM_ERR .. aSpell, 1, 0.4, 0.4);
			return nil;
		end
		return CreateMacro(tName, 1, aMacroText, true, nil);
	else
		return EditMacro(tIndex, tName, 1, aMacroText, true, nil)
	end
end



--
local tBody;
local tKey1, tKey2;
local tBindPrefix = "VUHDO_KEY_ASSIGN_";
local tCnt;
local tSpell;
local tMacroId;
local tBindingName;
local tCommand;

function VUHDO_initKeyboardMacros()
	VUHDO_IS_SFX_ENABLED = tonumber(GetCVar("Sound_EnableSFX")) == 1;

	if (VUHDO_SPELLS_KEYBOARD == nil) then
		return;
	end

	ClearOverrideBindings(VUHDO_GLOBAL["VuhDo"]);
	for tCnt = 1, 16 do
		tSpell = VUHDO_SPELLS_KEYBOARD["SPELL" .. tCnt];
		tBindingName = VUHDO_I18N_MOUSE_OVER_BINDING .. " " .. tCnt;

		if (tSpell == nil or strlen(tSpell) == 0) then
			tBindingName = tBindingName .. "\n|cff505050" .. VUHDO_I18N_UNASSIGNED .. "|r";
		else
			if (VUHDO_SPELLS[tSpell] and VUHDO_SPELLS[tSpell].present) then
				tBindingName = tBindingName .. "\n(|cff00ff00" .. tSpell .. "|r)";
			elseif (VUHDO_isSpellKnown(tSpell)) then
				tBindingName = tBindingName .. "\n(|cffffff00" .. tSpell .. "|r)";
			else
				tBindingName = tBindingName .. "\n(|cffff0000" .. tSpell .. "|r)";
			end
		end

		VUHDO_GLOBAL["BINDING_NAME_VUHDO_KEY_ASSIGN_" .. tCnt] = tBindingName;

		tKey1, tKey2 = GetBindingKey(tBindPrefix .. tCnt);
		if (tSpell ~= nil and strlen(tSpell) > 0 and (tKey1 ~= nil or tKey2 ~= nil)) then
			tBody = VUHDO_buildMacroText(tSpell, true, nil);
			tMacroId = VUHDO_createOrUpdateMacro(tCnt, tBody, tSpell);
			if (tMacroId ~= nil) then
				if (tKey1 ~= nil) then
					SetOverrideBindingMacro(VUHDO_GLOBAL["VuhDo"], true, tKey1, tMacroId);
				end

				if (tKey2 ~= nil) then
					SetOverrideBindingMacro(VUHDO_GLOBAL["VuhDo"], true, tKey2, tMacroId);
				end
			end
		else
			DeleteMacro("VuhDoAuto" .. tCnt);
		end
	end

	-- Buff watch smart cast binding
	tKey1, tKey2 = GetBindingKey("VUHDO_KEY_ASSIGN_SMART_BUFF");
	if (tKey1 ~= nil) then
		SetOverrideBindingClick(VUHDO_GLOBAL["VuhDo"], true, tKey1, "VuhDoSmartCastGlassButton", "LeftButton");
	end
	if (tKey2 ~= nil) then
		SetOverrideBindingClick(VUHDO_GLOBAL["VuhDo"], true, tKey2, "VuhDoSmartCastGlassButton", "LeftButton");
	end
end
