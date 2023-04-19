local pairs = pairs;


local VUHDO_CLASS_MAPPINGS = {
	["1"] = "WARRIOR",
	["2"] = "ROGUE",
	["3"] = "PRIEST",
	["4"] = "DRUID",
	["5"] = "PALADIN",
	["6"] = "HUNTER",
	["7"] = "MAGE",
	["8"] = "WARLOCK",
	["9"] = "SHAMAN",
	["10"] = "DEATHKNIGHT",
};



local VUHDO_CLASS_MAPPINGS_REV = {
	["WARRIOR"] = "1",
	["ROGUE"] = "2",
	["PRIEST"] = "3",
	["DRUID"] = "4",
	["PALADIN"] = "5",
	["HUNTER"] = "6",
	["MAGE"] = "7",
	["WARLOCK"] = "8",
	["SHAMAN"] = "9",
	["DEATHKNIGHT"] = "10",
};



local VUHDO_BUFF_MAPPINGS = {
	["0"] = "",
	["1"] = VUHDO_SPELL_ID_BUFF_BLESSING_OF_WISDOM,
	["2"] = VUHDO_SPELL_ID_BUFF_BLESSING_OF_MIGHT,
	["3"] = VUHDO_SPELL_ID_BUFF_BLESSING_OF_THE_KINGS,
	["4"] = VUHDO_SPELL_ID_BUFF_BLESSING_OF_SANCTUARY,
};



local VUHDO_BUFF_MAPPINGS_REV = {
	[""] = "0",
	[VUHDO_SPELL_ID_BUFF_BLESSING_OF_WISDOM] = "1",
	[VUHDO_SPELL_ID_BUFF_BLESSING_OF_MIGHT] = "2",
	[VUHDO_SPELL_ID_BUFF_BLESSING_OF_THE_KINGS] = "3",
	[VUHDO_SPELL_ID_BUFF_BLESSING_OF_SANCTUARY] = "4",
};



local VUHDO_AURA_MAPPINGS = {
	["0"] = "",
	["1"] = VUHDO_SPELL_ID_BUFF_DEVOTION_AURA,
	["2"] = VUHDO_SPELL_ID_BUFF_RETRIBUTION_AURA,
	["3"] = VUHDO_SPELL_ID_BUFF_CONCENTRATION_AURA,
	["4"] = VUHDO_SPELL_ID_BUFF_SHADOW_RESISTANCE_AURA,
	["5"] = VUHDO_SPELL_ID_BUFF_FROST_RESISTANCE_AURA,
	["6"] = VUHDO_SPELL_ID_BUFF_FIRE_RESISTANCE_AURA,
	["7"] = VUHDO_SPELL_ID_BUFF_CRUSADER_AURA,
};



local VUHDO_AURA_MAPPINGS_REV = {
	[""] = "0",
	[VUHDO_SPELL_ID_BUFF_DEVOTION_AURA] = "1",
	[VUHDO_SPELL_ID_BUFF_RETRIBUTION_AURA] = "2",
	[VUHDO_SPELL_ID_BUFF_CONCENTRATION_AURA] = "3",
	[VUHDO_SPELL_ID_BUFF_SHADOW_RESISTANCE_AURA] = "4",
	[VUHDO_SPELL_ID_BUFF_FROST_RESISTANCE_AURA] = "5",
	[VUHDO_SPELL_ID_BUFF_FIRE_RESISTANCE_AURA] = "6",
	[VUHDO_SPELL_ID_BUFF_CRUSADER_AURA] = "7",
};



--
function VUHDO_parsePallyPowerMessage(anArg2, anArg3, anArg4)
	if ("PALADIN" ~= VUHDO_PLAYER_CLASS) then
		return;
	end

	--VUHDO_xMsg(anArg2, anArg3, anArg4);

	local tCommand, tName, tArg3, tArg4 = strsplit(" ", anArg2);


	if ("CLEAR" == tCommand) then
		local tCategName = strsub(VUHDO_I18N_BUFFC_BLESSING, 3);
		if (VUHDO_BUFF_SETTINGS[tCategName]["enabled"]) then
			for tKey, _ in pairs(VUHDO_BUFF_SETTINGS[tCategName]["classes"]) do
				VUHDO_BUFF_SETTINGS[tCategName]["classes"][tKey] = "";
			end
		end

		tCategName = strsub(VUHDO_I18N_BUFFC_AURA, 3);
		if (VUHDO_BUFF_SETTINGS[tCategName]["enabled"]) then
			VUHDO_BUFF_SETTINGS[tCategName]["buff"] = "";
		end
	elseif ("REQ" == tCommand) then

	else

		if (tName ~= VUHDO_PLAYER_NAME) then
			return;
		end

		if ("ASSIGN" == tCommand) then
			local tCategName = strsub(VUHDO_I18N_BUFFC_BLESSING, 3);
			if (not VUHDO_BUFF_SETTINGS[tCategName]["enabled"]) then
				return;
			end
			local tClassName, tBuffName = VUHDO_CLASS_MAPPINGS[tArg3], VUHDO_BUFF_MAPPINGS[tArg4];
			if (tClassName == nil or tBuffName == nil) then
				return;
			end
			--VUHDO_xMsg("Assign", tName, tClassName, tBuffName);
			VUHDO_BUFF_SETTINGS[tCategName]["classes"][tClassName] = tBuffName;
		elseif ("MASSIGN" == tCommand) then
			local tCategName = strsub(VUHDO_I18N_BUFFC_BLESSING, 3);
			if (not VUHDO_BUFF_SETTINGS[tCategName]["enabled"]) then
				return;
			end

			local tBuffName = VUHDO_BUFF_MAPPINGS[tArg3];
			if (tBuffName == nil) then
				return;
			end

			for tKey, _ in pairs(VUHDO_BUFF_SETTINGS[tCategName]["classes"]) do
				VUHDO_BUFF_SETTINGS[tCategName]["classes"][tKey] = tBuffName;
			end

			--VUHDO_xMsg("Multi-Assign", tName, tBuffName);
		elseif ("AASSIGN" == tCommand) then
			local tCategName = strsub(VUHDO_I18N_BUFFC_AURA, 3);
			if (not VUHDO_BUFF_SETTINGS[tCategName]["enabled"]) then
				return;
			end

			local tAuraName = VUHDO_AURA_MAPPINGS[tArg3];
			if (tAuraName == nil) then
				return;
			end
			VUHDO_BUFF_SETTINGS[tCategName]["buff"] = tAuraName;
			--VUHDO_Msg(tCategName);
			--VUHDO_xMsg("Aura-Assign", tName, tAuraName);
		end
	end

	VUHDO_reloadBuffPanel();
	VUHDO_updateBuffPanel();
end



--
local function VUHDO_sendPallyPowerMessage(aMessage)
	SendAddonMessage("PLPWR", aMessage, VUHDO_getAddOnDistribution());
end



--
function VUHDO_sendPallyPowerAuraUpdate(aNewAuraName)
	if (not VUHDO_CONFIG["IS_PALLY_POWER_COMMS"]) then
		return;
	end

	local tAuraNum = VUHDO_AURA_MAPPINGS_REV[aNewAuraName];
	if (tAuraNum == nil) then
		return;
	end
	local tMessage = "AASSIGN " .. VUHDO_PLAYER_NAME .. " " .. tAuraNum;
	VUHDO_sendPallyPowerMessage(tMessage);
end



--
function VUHDO_sendPallyPowerBlessingUpdate(aNewBlessingName, aTargetClass)
	if (not VUHDO_CONFIG["IS_PALLY_POWER_COMMS"]) then
		return;
	end

	local tBuffNum = VUHDO_BUFF_MAPPINGS_REV[aNewBlessingName];
	local tClassNum = VUHDO_CLASS_MAPPINGS_REV[aTargetClass];
	if (tBuffNum == nil or tClassNum == nil) then
		return;
	end
	local tMessage = "ASSIGN " .. VUHDO_PLAYER_NAME .. " " .. tClassNum .. " " .. tBuffNum;
	VUHDO_sendPallyPowerMessage(tMessage);
end



--
function VUHDO_sendPallyPowerRequest()
	VUHDO_sendPallyPowerMessage("REQ");
end