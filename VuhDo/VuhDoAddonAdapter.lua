VUHDO_LibSharedMedia = LibStub("LibSharedMedia-3.0");
VUHDO_LibDataBroker = LibStub("LibDataBroker-1.1", true);

VUHDO_LibSharedMedia:Register("font", "Arial Black", "Interface\\AddOns\\VuhDo\\Fonts\\ariblk.ttf");
VUHDO_LibSharedMedia:Register("font", "Emblem",	"Interface\\AddOns\\VuhDo\\Fonts\\Emblem.ttf");

VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Rhombs", "Interface\\AddOns\\VuhDo\\Images\\bar1.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Twirls", "Interface\\AddOns\\VuhDo\\Images\\bar2.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Pipe, dark", "Interface\\AddOns\\VuhDo\\Images\\bar3.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Concave, dark", "Interface\\AddOns\\VuhDo\\Images\\bar4.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Pipe, light", "Interface\\AddOns\\VuhDo\\Images\\bar5.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Flat", "Interface\\AddOns\\VuhDo\\Images\\bar6.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Concave, light", "Interface\\AddOns\\VuhDo\\Images\\bar7.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Convex", "Interface\\AddOns\\VuhDo\\Images\\bar8.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Textile", "Interface\\AddOns\\VuhDo\\Images\\bar9.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Mirrorfinish", "Interface\\AddOns\\VuhDo\\Images\\bar10.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Diagonals", "Interface\\AddOns\\VuhDo\\Images\\bar11.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Zebra", "Interface\\AddOns\\VuhDo\\Images\\bar12.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Marble", "Interface\\AddOns\\VuhDo\\Images\\bar13.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Modern Art", "Interface\\AddOns\\VuhDo\\Images\\bar14.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Polished Wood", "Interface\\AddOns\\VuhDo\\Images\\bar15.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Plain", "Interface\\AddOns\\VuhDo\\Images\\bar16.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Minimalist", "Interface\\AddOns\\VuhDo\\Images\\bar17.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Aluminium", "Interface\\AddOns\\VuhDo\\Images\\bar18.tga");
VUHDO_LibSharedMedia:Register("statusbar", "VuhDo - Bar Highlighter", "Interface\\AddOns\\VuhDo\\Images\\highlight.tga");
VUHDO_LibSharedMedia:Register("statusbar", "LiteStepLite", "Interface\\AddOns\\VuhDo\\Images\\LiteStepLite.tga");

VUHDO_LibSharedMedia:Register("sound", "Tribal Bass Drum", "Sound\\Doodad\\BellTollTribal.wav");
VUHDO_LibSharedMedia:Register("sound", "Thorns", "Sound\\Spells\\Thorns.wav	");
VUHDO_LibSharedMedia:Register("sound", "Elf Bell Toll", "Sound\\Doodad\\BellTollNightElf.wav");

LoadAddOn("FuBarPlugin-3.0");



--
function VUHDO_parseAddonMessage(anArg1, anArg2, anArg3, anArg4)
	-- PallyPower?
	if ("PLPWR" == anArg1 and VUHDO_CONFIG["IS_PALLY_POWER_COMMS"]) then
		VUHDO_parsePallyPowerMessage(anArg2, anArg3, anArg4);
	-- CTRaidAssistMessage?
  elseif ("CTRA" == anArg1) then
  	local tNick = anArg4;
  	local tMessage = anArg2;
		if (strfind(tMessage, "#")) then
			local tFragments = VUHDO_splitString(tMessage, "#");
			local tCommand;
			for _, tCommand in pairs(tFragments) do
				VUHDO_parseCtraMessage(tNick, tCommand);
			end
		else
			VUHDO_parseCtraMessage(tNick, tMessage);
		end
  end
end



--
function VUHDO_setLhcEnabled()
	local tHealComm = LibStub("LibHealComm-4.0");
	if (VUHDO_CONFIG["SHOW_INCOMING"] or VUHDO_CONFIG["SHOW_OWN_INCOMING"]) then
		tHealComm.RegisterCallback(VuhDoHealComms, "HealComm_HealStarted");
		tHealComm.RegisterCallback(VuhDoHealComms, "HealComm_HealUpdated", "HealComm_HealStarted");
		tHealComm.RegisterCallback(VuhDoHealComms, "HealComm_HealDelayed", "HealComm_HealStarted");
		tHealComm.RegisterCallback(VuhDoHealComms, "HealComm_HealStopped");
	else
		tHealComm.UnregisterCallback(VuhDoHealComms, "HealComm_HealStarted");
		tHealComm.UnregisterCallback(VuhDoHealComms, "HealComm_HealUpdated", "HealComm_HealStarted");
		tHealComm.UnregisterCallback(VuhDoHealComms, "HealComm_HealDelayed", "HealComm_HealStarted");
		tHealComm.UnregisterCallback(VuhDoHealComms, "HealComm_HealStopped");
	end
end



--
function VUHDO_setShieldCommEnabled()
	local tShieldLeft = LibStub("LibShieldLeft-1.0");
	if (VUHDO_PANEL_SETUP["BAR_COLORS"]["HOTS"]["showShieldAbsorb"]) then
		tShieldLeft.RegisterCallback(VuhDoShieldComms, "ShieldLeft_NewShield");
		tShieldLeft.RegisterCallback(VuhDoShieldComms, "ShieldLeft_RefreshShield");
		tShieldLeft.RegisterCallback(VuhDoShieldComms, "ShieldLeft_RemoveShield");
		tShieldLeft.RegisterCallback(VuhDoShieldComms, "ShieldLeft_UpdateShield");
	else
		tShieldLeft.UnregisterCallback(VuhDoShieldComms, "ShieldLeft_NewShield");
		tShieldLeft.UnregisterCallback(VuhDoShieldComms, "ShieldLeft_RefreshShield");
		tShieldLeft.UnregisterCallback(VuhDoShieldComms, "ShieldLeft_RemoveShield");
		tShieldLeft.UnregisterCallback(VuhDoShieldComms, "ShieldLeft_UpdateShield");
		VUHDO_resetShieldsLeft();
	end
	tShieldLeft:SetAegisTolerance(1.2);
end



--
function VUHDO_initFuBar()
	-- libDataBroker
  if (VUHDO_LibDataBroker ~= nil) then
    VuhDoLauncher = VUHDO_LibDataBroker:NewDataObject("VuhDo", {
      type = "launcher",
      icon = "Interface\\AddOns\\VuhDo\\Images\\VuhDo",
      OnClick = function(aClickedFrame, aButton)
        if (aButton == "RightButton") then
          ToggleDropDownMenu(1, nil, VuhDoMinimapDropDown, aClickedFrame:GetName(), 0, -5);
        else
          VUHDO_slashCmd("opt");
        end
      end,
      OnTooltipShow = function(aTooltip)
        aTooltip:AddLine("VuhDo")
        aTooltip:AddLine(VUHDO_I18N_BROKER_TOOLTIP_1)
        aTooltip:AddLine(VUHDO_I18N_BROKER_TOOLTIP_2)
      end,
    })
  end

	-- Native FuBar
	if (LibStub:GetLibrary("LibFuBarPlugin-3.0", true)
		and IsAddOnLoaded("FuBar")
		and not IsAddOnLoaded("FuBar2Broker")
		and not IsAddOnLoaded("Broker2FuBar")) then

		local tLibFuBarPlugin = LibStub:GetLibrary("LibFuBarPlugin-3.0");
		LibStub("AceAddon-3.0"):EmbedLibrary(VuhDo, "LibFuBarPlugin-3.0");
		VuhDo:SetFuBarOption("tooltipType", "GameTooltip");
		VuhDo:SetFuBarOption("hasNoColor", true);
		VuhDo:SetFuBarOption("cannotDetachTooltip", true);
		VuhDo:SetFuBarOption("hideWithoutStandby", true);
		VuhDo:SetFuBarOption("iconPath", [[Interface\AddOns\VuhDo\Images\VuhDo]]);
		VuhDo:SetFuBarOption("hasIcon", true);
		VuhDo:SetFuBarOption("defaultPosition", "RIGHT");
		VuhDo:SetFuBarOption("tooltipHiddenWhenEmpty", true);
		VuhDo:SetFuBarOption("configType", "None");
		VuhDo.title = "VuhDo";
		VuhDo.name = "VuhDo";
		tLibFuBarPlugin:OnEmbedInitialize(VuhDo, VuhDo);
		function VuhDo:OnUpdateFuBarTooltip()
			GameTooltip:AddLine("VuhDo");
			GameTooltip:AddLine(VUHDO_I18N_BROKER_TOOLTIP_1);
			GameTooltip:AddLine(VUHDO_I18N_BROKER_TOOLTIP_2);
		end
		VuhDo:Show();
		function VuhDo:OnFuBarClick(aButton)
			if ("LeftButton" == aButton) then
				VUHDO_slashCmd("opt");
			elseif ("RightButton" == aButton) then
				ToggleDropDownMenu(1, nil, VuhDoMinimapDropDown, VuhDo:GetFrame():GetName(), 0, -5);
			end
		end
	end
end



--
function VUHDO_initSharedMedia()
	local tIndex, tValue;

	-- fonts
	local tFonts = VUHDO_LibSharedMedia:List('font');
	for tIndex, tValue in ipairs(tFonts) do
		VUHDO_FONTS[tIndex] = { VUHDO_LibSharedMedia:Fetch('font', tValue), tValue };
	end

	-- status bars
	local tBars = VUHDO_LibSharedMedia:List('statusbar');
	for tIndex, tValue in ipairs(tBars) do
		VUHDO_STATUS_BARS[tIndex] = { tValue, tValue };
	end

	-- sounds
	local tSounds = VUHDO_LibSharedMedia:List('sound');
	for tIndex, tValue in ipairs(tSounds) do
		VUHDO_SOUNDS[tIndex] = { VUHDO_LibSharedMedia:Fetch('sound', tValue), tValue };
	end
	tinsert(VUHDO_SOUNDS, 1, { nil, "-- off --" } );

	-- borders
	local tBorders = VUHDO_LibSharedMedia:List('border');
	for tIndex, tValue in ipairs(tBorders) do
		VUHDO_BORDERS[tIndex] = { VUHDO_LibSharedMedia:Fetch('border', tValue), tValue };
	end
end



--
local tPanelNum, tButtonNum;
local tEmptyButton = { };
function VUHDO_initCliqueSupport()
	if (not VUHDO_CONFIG["IS_CLIQUE_COMPAT_MODE"]) then
		return;
	end

	ClickCastFrames = ClickCastFrames or {};

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		for tButtonNum = 1, 51 do -- VUHDO_MAX_BUTTONS_PANEL
			if (VUHDO_GLOBAL["VdAc" .. tPanelNum .. "HlU" .. tButtonNum] ~= nil) then
				ClickCastFrames[VUHDO_GLOBAL["VdAc" .. tPanelNum .. "HlU" .. tButtonNum]] = true;
				ClickCastFrames[VUHDO_GLOBAL["VdAc" .. tPanelNum .. "HlU" .. tButtonNum .. "Tg"]] = true;
				ClickCastFrames[VUHDO_GLOBAL["VdAc" .. tPanelNum .. "HlU" .. tButtonNum .. "Tot"]] = true;
			end
		end
	end
end
