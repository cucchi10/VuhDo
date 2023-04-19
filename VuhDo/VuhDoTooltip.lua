local UnitLevel = UnitLevel;
local UnitRace = UnitRace;
local UnitCreatureType = UnitCreatureType;
local GetGuildInfo = GetGuildInfo;
local UnitIsGhost = UnitIsGhost;
local UnitIsDead = UnitIsDead;
local IsAltKeyDown = IsAltKeyDown;
local IsControlKeyDown = IsControlKeyDown;
local IsShiftKeyDown = IsShiftKeyDown;
local InCombatLockdown = InCombatLockdown;
local pairs = pairs;
local twipe = table.wipe;
local abs = abs;
local floor = floor;



local VUHDO_TOOLTIP_POS_CUSTOM = 1;
local VUHDO_TOOLTIP_POS_STANDARD = 2;
local VUHDO_TOOLTIP_POS_MOUSE = 3;
local VUHDO_TOOLTIP_POS_LEFT = 50;
local VUHDO_TOOLTIP_POS_LEFT_UP = 51;
local VUHDO_TOOLTIP_POS_LEFT_DOWN = 52;
local VUHDO_TOOLTIP_POS_RIGHT = 60;
local VUHDO_TOOLTIP_POS_RIGHT_UP = 61;
local VUHDO_TOOLTIP_POS_RIGHT_DOWN = 62;
local VUHDO_TOOLTIP_POS_UP = 70;
local VUHDO_TOOLTIP_POS_UP_LEFT = 71;
local VUHDO_TOOLTIP_POS_UP_RIGHT = 72;
local VUHDO_TOOLTIP_POS_DOWN = 80;
local VUHDO_TOOLTIP_POS_DOWN_LEFT = 81;
local VUHDO_TOOLTIP_POS_DOWN_RIGHT = 82;


local VUHDO_TOOLTIP_MAX_LINES_RIGHT = 8;
local VUHDO_TOOLTIP_MAX_LINES_LEFT = 16;

local VUHDO_TOOLTIP_AKT_LINE_LEFT = 1;
local VUHDO_TOOLTIP_AKT_LINE_RIGHT = 1;

local VUHDO_TEXT_SIZE_LEFT = { };


local VUHDO_TT_UNIT = nil;
local VUHDO_TT_PANEL_NUM = nil;
local VUHDO_TT_RESET = true;


local VUHDO_VALUE_COLOR = {
	["TR"] = 1,
	["TG"] = 0.898,
	["TB"] = 0.4,
};


--
local function VUHDO_clearTooltipLines()
  VUHDO_TOOLTIP_AKT_LINE_LEFT = 1;
	VUHDO_TOOLTIP_AKT_LINE_RIGHT = 1;
	twipe(VUHDO_TEXT_SIZE_LEFT);
end



--
local tLabel;
local function VUHDO_setTooltipLine(aText, anIsLeft, aLineNum, aColor, aTextSize)
	if (anIsLeft) then
		tLabel = VUHDO_GLOBAL["VuhDoTooltipTextL" .. aLineNum];
	else
		tLabel = VUHDO_GLOBAL["VuhDoTooltipTextR" .. aLineNum];
	end

	tLabel:SetText(aText);

	if (aColor ~= nil) then
		tLabel:SetTextColor(aColor["TR"], aColor["TG"], aColor["TB"], 1);
	end

	if (aTextSize ~= nil) then
		tLabel:SetFont(GameFontNormal:GetFont(), aTextSize);
		tLabel:SetShadowColor(0, 0, 0, 1);
		tLabel:SetShadowOffset(1, -0.5);
	end

	if (anIsLeft) then
		_, VUHDO_TEXT_SIZE_LEFT[aLineNum] = tLabel:GetFont();
	else
		tLabel:SetHeight(VUHDO_TEXT_SIZE_LEFT[aLineNum]);
	end

	tLabel:Show();
end



--
local function VUHDO_addTooltipLineLeft(aText, aColor, aTextSize)
	if (VUHDO_TOOLTIP_AKT_LINE_LEFT < VUHDO_TOOLTIP_MAX_LINES_LEFT) then
		VUHDO_setTooltipLine(aText, true, VUHDO_TOOLTIP_AKT_LINE_LEFT, aColor, aTextSize)
		VUHDO_TOOLTIP_AKT_LINE_LEFT = VUHDO_TOOLTIP_AKT_LINE_LEFT + 1;
	end
end



--
local function VUHDO_addTooltipLineRight(aText, aColor, aTextSize)
	if (VUHDO_TOOLTIP_AKT_LINE_RIGHT < VUHDO_TOOLTIP_MAX_LINES_RIGHT) then
		VUHDO_setTooltipLine(aText, false, VUHDO_TOOLTIP_AKT_LINE_RIGHT, aColor, aTextSize)
  	VUHDO_TOOLTIP_AKT_LINE_RIGHT = VUHDO_TOOLTIP_AKT_LINE_RIGHT + 1;
  end
end



--
local VUHDO_TT_FIX_POINTS = {
	[VUHDO_TOOLTIP_POS_LEFT] = {"RIGHT", "LEFT" },
	[VUHDO_TOOLTIP_POS_LEFT_UP] = { "TOPRIGHT", "TOPLEFT" },
	[VUHDO_TOOLTIP_POS_LEFT_DOWN] = { "BOTTOMRIGHT" , "BOTTOMLEFT" },
	[VUHDO_TOOLTIP_POS_RIGHT] = { "LEFT", "RIGHT" },
	[VUHDO_TOOLTIP_POS_RIGHT_UP] = { "TOPLEFT", "TOPRIGHT" },
	[VUHDO_TOOLTIP_POS_RIGHT_DOWN] = { "BOTTOMLEFT", "BOTTOMRIGHT" },
	[VUHDO_TOOLTIP_POS_UP] = { "BOTTOM", "TOP" },
	[VUHDO_TOOLTIP_POS_UP_LEFT] = { "BOTTOMLEFT", "TOPLEFT" },
	[VUHDO_TOOLTIP_POS_UP_RIGHT] = { "BOTTOMRIGHT", "TOPRIGHT" },
	[VUHDO_TOOLTIP_POS_DOWN] = { "TOP", "BOTTOM" },
	[VUHDO_TOOLTIP_POS_DOWN_LEFT] = { "TOPLEFT", "BOTTOMLEFT" },
	[VUHDO_TOOLTIP_POS_DOWN_RIGHT] = { "TOPRIGHT", "BOTTOMRIGHT" },
};



--
local tMouseX, tMouseY;
local aConfig;
local tPos;
local tFactorScale;
local tFixPos;
local function VUHDO_initTooltip()
	aConfig = VUHDO_PANEL_SETUP[VUHDO_TT_PANEL_NUM]["TOOLTIP"];
	tPos = aConfig["position"];

	if (VUHDO_TT_RESET) then
		VUHDO_TT_RESET = false;

		VuhDoTooltip:SetScale(aConfig["SCALE"]);

		VuhDoTooltip:SetBackdropColor(
			aConfig["BACKGROUND"]["R"],
			aConfig["BACKGROUND"]["G"],
			aConfig["BACKGROUND"]["B"],
			aConfig["BACKGROUND"]["O"]
		);

		VuhDoTooltip:SetBackdropBorderColor(
			aConfig["BORDER"]["R"],
			aConfig["BORDER"]["G"],
			aConfig["BORDER"]["B"],
			aConfig["BORDER"]["O"]
		);

		VuhDoTooltip:ClearAllPoints();
		tFixPos = VUHDO_TT_FIX_POINTS[tPos];
		if (tFixPos ~= nil) then
	  	VuhDoTooltip:SetPoint(tFixPos[1], VUHDO_getActionPanel(VUHDO_TT_PANEL_NUM):GetName(), tFixPos[2], 0, 0);
		elseif (VUHDO_TOOLTIP_POS_CUSTOM == tPos) then
		  VuhDoTooltip:SetPoint(aConfig["point"], "UIParent", aConfig["relativePoint"], aConfig["x"], aConfig["y"]);
		elseif (VUHDO_TOOLTIP_POS_STANDARD == tPos) then
			if (not VUHDO_CONFIG["STANDARD_TOOLTIP"]) then
				GameTooltip:Hide();
			end

			VuhDoTooltip:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -CONTAINER_OFFSET_X - 13, CONTAINER_OFFSET_Y);
		end

		if (VUHDO_TOOLTIP_POS_MOUSE == tPos) then
			VUHDO_setTooltipDelay(0.01);
		else
			VUHDO_setTooltipDelay(2.3);
		end
		VuhDoTooltip:SetWidth(200);
	end

	if (VUHDO_TOOLTIP_POS_MOUSE == tPos) then
		tMouseX, tMouseY = VUHDO_getMouseCoords();
		tFactorScale = VuhDoTooltip:GetScale();
		VuhDoTooltip:ClearAllPoints();
	  VuhDoTooltip:SetPoint("TOPLEFT", "UIParent", "BOTTOMLEFT", (tMouseX  +  16) / tFactorScale, (tMouseY - 16) / tFactorScale);
	end
end



--
function VUHDO_resetTooltip()
	VUHDO_TT_RESET = true;
end


--
local tHeight;
local tTextHeight;
local function VUHDO_finishTooltip()
	tHeight = 28;
	for _, tTextHeight in pairs(VUHDO_TEXT_SIZE_LEFT) do
		tHeight = tHeight + tTextHeight;
	end

	VuhDoTooltip:SetHeight(tHeight);
  VuhDoTooltip:Show();
end



--
local tSpellText;
local function VUHDO_getSpellTooltip(aModifier, aButtonNum)
	tSpellText = "|cffffffff";

	if (aButtonNum < 6) then
		if (VUHDO_SPELL_ASSIGNMENTS[aModifier .. aButtonNum][3] ~= nil) then
			tSpellText = tSpellText .. VUHDO_SPELL_ASSIGNMENTS[aModifier .. aButtonNum][3];
		end
	else
		if (VUHDO_SPELL_ASSIGNMENTS[aModifier .. aButtonNum - 5][3] ~= nil) then
			tSpellText = tSpellText .. VUHDO_SPELLS_KEYBOARD["WHEEL"][aModifier .. aButtonNum - 5][3];
		end
	end

	tSpellText = tSpellText .. "|r";
	return tSpellText;
end



--
local function VUHDO_getKiloText(aNumber)
	if (abs(aNumber) < 10000) then
		return aNumber;
	end

  return floor(aNumber * 0.01) * 0.1 .. "k";
end



--
local tInfo;
local tLevel;
local tRace;
local tClassColor;
local tLeftText;
local tRightText;
local tModifier;
local tKey;
local tGuildName, tGuildRank;
local tRole;
local tGuild;
local tDistance;
function VUHDO_updateTooltip()
	tInfo = VUHDO_RAID[VUHDO_TT_UNIT];

	if (tInfo == nil) then
		return;
	end

	VUHDO_initTooltip();
	VUHDO_clearTooltipLines();

	-- Name
	tClassColor = VUHDO_getClassColor(tInfo);
	if (tClassColor == nil) then
		tClassColor = VUHDO_PANEL_SETUP[VUHDO_TT_PANEL_NUM]["PANEL_COLOR"]["TEXT"];
	end

	if (tInfo["role"] ~= nil) then
		tRole = "(" .. VUHDO_HEADER_TEXTS[tInfo["role"]] .. ")";
	else
		tRole = "";
	end

	VUHDO_addTooltipLineLeft(tInfo["fullName"], tClassColor, 10);
	VUHDO_addTooltipLineRight(tRole, tClassColor, 8);

	-- Level, Klasse, Rasse
	tLevel = UnitLevel(VUHDO_TT_UNIT) or "";

	VUHDO_addTooltipLineLeft(VUHDO_I18N_TT_LEVEL .. tLevel .. " " .. (tInfo["className"] or "?"), tClassColor, 9);

	tRace = UnitRace(VUHDO_TT_UNIT) or UnitCreatureType(VUHDO_TT_UNIT);
	if (tRace ~= nil) then
		VUHDO_addTooltipLineRight(tRace, tClassColor, 9);
	end

	-- Guild
	tGuildName, tGuildRank, _ = GetGuildInfo(VUHDO_TT_UNIT);
	if (tGuildName ~= nil) then
	  tGuildRank = tGuildRank or "";
	  tGuild = tGuildRank .. " " .. VUHDO_I18N_TT_OF .. " <" .. tGuildName .. ">";
	else
		tGuild = " ";
	end

	VUHDO_addTooltipLineLeft(tGuild, tClassColor, 9);
	VUHDO_addTooltipLineRight("");

	tDistance = VUHDO_getDistanceText(VUHDO_TT_UNIT);

	VUHDO_addTooltipLineLeft(VUHDO_I18N_TT_DISTANCE);
	VUHDO_addTooltipLineRight(tDistance, VUHDO_VALUE_COLOR);

	-- Position
	VUHDO_addTooltipLineLeft(VUHDO_I18N_TT_POSITION);
	VUHDO_addTooltipLineRight(tInfo["zone"] or "", VUHDO_VALUE_COLOR);

	tLeftText = " ";
	if (UnitIsGhost(VUHDO_TT_UNIT)) then
		tLeftText = VUHDO_I18N_TT_GHOST;
	elseif (UnitIsDead(VUHDO_TT_UNIT)) then
		tLeftText = VUHDO_I18N_TT_DEAD;
	end

	tRightText = " ";
	if (not tInfo["connected"]) then
		tRightText = VUHDO_getDurationTextSince(VUHDO_getAfkDcTime(VUHDO_TT_UNIT));
	elseif (tInfo["afk"]) then
		tRightText = VUHDO_I18N_TT_AFK .. " " .. VUHDO_getDurationTextSince(VUHDO_getAfkDcTime(VUHDO_TT_UNIT));
	elseif(UnitIsDND(VUHDO_TT_UNIT)) then
		tRightText = VUHDO_I18N_TT_DND;
	end

	if (tLeftText ~= " " or tRightText ~= " ") then
		VUHDO_addTooltipLineLeft(tLeftText, VUHDO_VALUE_COLOR);
		VUHDO_addTooltipLineRight(tRightText, VUHDO_VALUE_COLOR);
	end

	tLeftText = VUHDO_I18N_TT_LIFE .. VUHDO_getKiloText(tInfo["health"]) .. "/" .. VUHDO_getKiloText(tInfo["healthmax"]);
	if (VUHDO_UNIT_POWER_MANA == tInfo["powertype"]) then
		tRightText = VUHDO_I18N_TT_MANA .. VUHDO_getKiloText(tInfo["power"]) .. "/" .. VUHDO_getKiloText(tInfo["powermax"]);
	else
		tRightText = "";
	end
	VUHDO_addTooltipLineLeft(tLeftText, VUHDO_VALUE_COLOR, 8);
	VUHDO_addTooltipLineRight(tRightText, VUHDO_VALUE_COLOR, 8);

	if (VUHDO_SPELL_CONFIG["IS_TOOLTIP_INFO"]) then
		tModifier = "";
		if (IsAltKeyDown()) then
			tModifier = tModifier .. "alt";
		end

		if (IsControlKeyDown()) then
			tModifier = tModifier .. "ctrl";
		end

		if (IsShiftKeyDown()) then
			tModifier = tModifier .. "shift";
		end

		VUHDO_addTooltipLineLeft(tModifier .. VUHDO_I18N_TT_LEFT .. VUHDO_getSpellTooltip(tModifier, 1), VUHDO_VALUE_COLOR, 8);
		VUHDO_addTooltipLineLeft(tModifier .. VUHDO_I18N_TT_RIGHT .. VUHDO_getSpellTooltip(tModifier, 2), VUHDO_VALUE_COLOR, 8);
		VUHDO_addTooltipLineLeft(tModifier .. VUHDO_I18N_TT_MIDDLE .. VUHDO_getSpellTooltip(tModifier, 3), VUHDO_VALUE_COLOR, 8);
		VUHDO_addTooltipLineLeft(tModifier .. VUHDO_I18N_TT_BTN_4 .. VUHDO_getSpellTooltip(tModifier, 4), VUHDO_VALUE_COLOR, 8);
		VUHDO_addTooltipLineLeft(tModifier .. VUHDO_I18N_TT_BTN_5 .. VUHDO_getSpellTooltip(tModifier, 5), VUHDO_VALUE_COLOR, 8);
		VUHDO_addTooltipLineLeft(tModifier .. VUHDO_I18N_TT_WHEEL_UP .. VUHDO_getSpellTooltip(tModifier, 6), VUHDO_VALUE_COLOR, 8);
		VUHDO_addTooltipLineLeft(tModifier .. VUHDO_I18N_TT_WHEEL_DOWN .. VUHDO_getSpellTooltip(tModifier, 7), VUHDO_VALUE_COLOR, 8);
		VUHDO_addTooltipLineLeft(" ", VUHDO_VALUE_COLOR, 8);
	else
		VUHDO_addTooltipLineLeft("", VUHDO_VALUE_COLOR, 1);
		VUHDO_addTooltipLineLeft("", VUHDO_VALUE_COLOR, 1);
		VUHDO_addTooltipLineLeft("", VUHDO_VALUE_COLOR, 1);
		VUHDO_addTooltipLineLeft("", VUHDO_VALUE_COLOR, 1);
		VUHDO_addTooltipLineLeft("", VUHDO_VALUE_COLOR, 1);
		VUHDO_addTooltipLineLeft("", VUHDO_VALUE_COLOR, 1);
		VUHDO_addTooltipLineLeft("", VUHDO_VALUE_COLOR, 1);
	end

	VUHDO_addTooltipLineLeft("", VUHDO_VALUE_COLOR, 1);
	VUHDO_addTooltipLineRight("", VUHDO_VALUE_COLOR, 1);

	VUHDO_finishTooltip();
end



--
local tPanelNum;
local tTipConfig;
local tUnit;
function VUHDO_showTooltip(aButton)
	tPanelNum = VUHDO_BUTTON_CACHE[aButton];
	tTipConfig = VUHDO_PANEL_SETUP[tPanelNum]["TOOLTIP"];

	if (not tTipConfig["show"]
		or VUHDO_IS_PANEL_CONFIG
		or (InCombatLockdown() and not tTipConfig["inFight"])) then
		return;
	end

	tUnit = VUHDO_resolveButtonUnit(aButton);

	if (VUHDO_RAID[tUnit] == nil) then
		-- Must not happen
		return;
	end

	if (VUHDO_CONFIG["STANDARD_TOOLTIP"]) then
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
		GameTooltip:SetUnit(tUnit);
		GameTooltip:Show();
		return;
	end

	VUHDO_TT_UNIT = tUnit;
	VUHDO_TT_PANEL_NUM = tPanelNum;
  VUHDO_updateTooltip();
end



--
function VUHDO_demoTooltip(aPanelNum)
	if (not VUHDO_PANEL_SETUP[aPanelNum]["TOOLTIP"]["show"]) then
		return;
	end

	tUnit = VUHDO_getPlayerRaidUnit();

	if (VUHDO_RAID[tUnit] == nil) then
		-- Must not happen
		return;
	end

	VUHDO_TT_UNIT = tUnit;
	VUHDO_TT_PANEL_NUM = aPanelNum;
	VUHDO_TT_RESET = true;
  VUHDO_updateTooltip();
end



--
function VUHDO_hideTooltip()
	if (not VUHDO_IS_PANEL_CONFIG) then
		if (VUHDO_CONFIG["STANDARD_TOOLTIP"]) then
			GameTooltip:Hide();
		else
			VuhDoTooltip:Hide();
		end
	end
end


--
function VuhDoTooltipOnMouseDown(aTooltip)
	if (VUHDO_IS_PANEL_CONFIG and VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM]["TOOLTIP"]["position"] == VUHDO_TOOLTIP_POS_CUSTOM) then
		VUHDO_REFRESH_TOOLTIP_TIMER = 0;
		aTooltip:StartMoving();
	end
end



--
local tPosition;
function VuhDoTooltipOnMouseUp(aTooltip)
	aTooltip:StopMovingOrSizing();

	local tSetup;
	local tConfig;
	local tX, tY, tRelative, tOrientation;

	tPosition = VUHDO_PANEL_SETUP[DESIGN_MISC_PANEL_NUM]["TOOLTIP"];
	tOrientation, _, tRelative, tX, tY = aTooltip:GetPoint(0);

	tPosition["x"] = tX;
	tPosition["y"] = tY;
	tPosition["point"] = tOrientation;
	tPosition["relativePoint"] = tRelative;

	VUHDO_initTooltipTimer();
end
