VUHDO_COMBO_MAX_ENTRIES = 10000;

local floor = floor;
local mod = mod;
local tonumber = tonumber;
local strlen = strlen;
local strsub = strsub;
local GetLocale = GetLocale;
local InCombatLockdown = InCombatLockdown;
local sIsNotInChina = GetLocale() ~= "zhCN" and GetLocale() ~= "zhTW" and GetLocale() ~= "koKR";
local sIsManaBar;


-----------------------------------------------------------------------
local VUHDO_getNumbersFromString;

local VUHDO_CONFIG = { };
local VUHDO_PANEL_SETUP = { };
local VUHDO_USER_CLASS_COLORS = { };
function VUHDO_guiToolboxInitBurst()
  VUHDO_getNumbersFromString = VUHDO_GLOBAL["VUHDO_getNumbersFromString"];

  VUHDO_CONFIG = VUHDO_GLOBAL["VUHDO_CONFIG"];
  VUHDO_PANEL_SETUP = VUHDO_GLOBAL["VUHDO_PANEL_SETUP"];
  VUHDO_USER_CLASS_COLORS = VUHDO_GLOBAL["VUHDO_USER_CLASS_COLORS"];

  sIsManaBar = VUHDO_INDICATOR_CONFIG["BOUQUETS"]["MANA_BAR"] ~= "";
end
------------------------------------------------------------------------



--
function VUHDO_mayMoveHealPanels()
  return VUHDO_IS_PANEL_CONFIG or not VUHDO_CONFIG["LOCK_PANELS"];
end



--
function VUHDO_isConfigPanelShowing()
	return VUHDO_IS_PANEL_CONFIG and not VUHDO_CONFIG_SHOW_RAID;
end



--
function VUHDO_getComponentPanelNum(aComponent)
	return VUHDO_getNumbersFromString(aComponent:GetName(), 1)[1];
end



--
local tX, tY;
function VUHDO_getAnchorCoords(aPanel, anOrientation, aScaleDiff)

	if (anOrientation == "TOP") then
		tX = (aPanel:GetRight() + aPanel:GetLeft()) * 0.5;
		tY = aPanel:GetTop();
	elseif (anOrientation == "BOTTOM") then
		tX = (aPanel:GetRight() + aPanel:GetLeft()) * 0.5;
		tY = aPanel:GetBottom();
	elseif (anOrientation == "LEFT") then
		tX = aPanel:GetLeft();
		tY = (aPanel:GetBottom() + aPanel:GetTop()) * 0.5;
	elseif (anOrientation == "RIGHT") then
		tX = aPanel:GetRight();
		tY = (aPanel:GetBottom() + aPanel:GetTop()) * 0.5;
	elseif (anOrientation == "TOPRIGHT") then
		tX = aPanel:GetRight();
		tY = aPanel:GetTop();
	elseif (anOrientation == "BOTTOMLEFT") then
		tX = aPanel:GetLeft();
		tY = aPanel:GetBottom();
	elseif (anOrientation == "BOTTOMRIGHT") then
		tX = aPanel:GetRight();
		tY = aPanel:GetBottom();
	else -- TOPLEFT
		tX = aPanel:GetLeft();
		tY = aPanel:GetTop();
	end

	return (tX or 0) / aScaleDiff, (tY or 0) / aScaleDiff;
end



--
function VUHDO_isLooseOrderingShowing(aPanelNum)
	return VUHDO_PANEL_SETUP[aPanelNum]["MODEL"]["ordering"] ~= 0 -- VUHDO_ORDERING_STRICT
	  and (not VUHDO_IS_PANEL_CONFIG or VUHDO_CONFIG_SHOW_RAID);
end
local VUHDO_isLooseOrderingShowing = VUHDO_isLooseOrderingShowing;



--
function VUHDO_isTableHeadersShowing(aPanelNum)
  return not VUHDO_isLooseOrderingShowing(aPanelNum)
  	and VUHDO_PANEL_SETUP[aPanelNum]["SCALING"]["showHeaders"]
  	and not VUHDO_PANEL_SETUP[aPanelNum]["SCALING"]["alignBottom"];
end



--
function VUHDO_isTableFootersShowing(aPanelNum)
  return not VUHDO_isLooseOrderingShowing(aPanelNum)
  	and VUHDO_PANEL_SETUP[aPanelNum]["SCALING"]["showHeaders"]
  	and VUHDO_PANEL_SETUP[aPanelNum]["SCALING"]["alignBottom"];
end



--
function VUHDO_isTableHeaderOrFooter(aPanelNum)
  return not VUHDO_isLooseOrderingShowing(aPanelNum)
  	and VUHDO_PANEL_SETUP[aPanelNum]["SCALING"]["showHeaders"];
end



---
function VUHDO_toggleMenu(aPanel)
	if (aPanel:IsShown()) then
		aPanel:Hide();
	else
		aPanel:Show();
	end
end



--
local tPanelName;
function VUHDO_getPanelNum(aPanel)
	tPanelName = aPanel:GetName();
	return tonumber(strsub(tPanelName, -2)) or tonumber(strsub(tPanelName, -1)) or 1;
end



--
function VUHDO_getClassColor(anInfo)
	return VUHDO_USER_CLASS_COLORS[anInfo["classId"]];
end



--
function VUHDO_getClassColorByModelId(aModelId)
	return VUHDO_USER_CLASS_COLORS[aModelId];
end



--
function VUHDO_getManaBarHeight(aPanelNum)
	if (sIsManaBar) then
		return VUHDO_PANEL_SETUP[aPanelNum]["SCALING"]["manaBarHeight"];
	else
		return 0;
	end
end
local VUHDO_getManaBarHeight = VUHDO_getManaBarHeight;



--
function VUHDO_getHealthBarHeight(aPanelNum)
	return VUHDO_PANEL_SETUP[aPanelNum]["SCALING"]["barHeight"] - VUHDO_getManaBarHeight(aPanelNum);
end



--
function VUHDO_getDiffColor(aBaseColor, aModColor)
	if (aModColor["useText"]) then
		aBaseColor["useText"] = true;
		aBaseColor["TR"], aBaseColor["TG"], aBaseColor["TB"], aBaseColor["TO"]
			= aModColor["TR"], aModColor["TG"], aModColor["TB"], aModColor["TO"];
	end

	if (aModColor["useBackground"]) then
		aBaseColor["useBackground"] = true;
		aBaseColor["R"], aBaseColor["G"], aBaseColor["B"] = aModColor["R"], aModColor["G"], aModColor["B"];
	end

	if (aModColor["useOpacity"]) then
		aBaseColor["useOpacity"] = true;
		aBaseColor["O"], aBaseColor["TO"] = aModColor["O"], aModColor["TO"];
	end

	return aBaseColor;
end



--
function VUHDO_brightenTextColor(aColor, aSummand)
	aColor["TR"], aColor["TG"], aColor["TB"]
		= aColor["TR"] + aSummand, aColor["TG"] + aSummand, aColor["TB"] + aSummand;
	return aColor;
end



-- Bitmap ist 256*256 pixel mit 16 (4*4) Icons (je 64*64 pixel)
local tLeft, tTop;
function VUHDO_setRaidTargetIconTexture(aTexture, anIndex)
	anIndex = anIndex - 1;
	tLeft = mod(anIndex, 4) * 0.25;
	tTop = floor(anIndex / 4) * 0.25;
	aTexture:SetTexCoord(tLeft, tLeft + 0.25, tTop, tTop + 0.25);
end



--
local tMX, tMY;
function VUHDO_getMouseCoords()
	tMX, tMY = GetCursorPosition();
	return tMX / UIParent:GetEffectiveScale(), tMY / UIParent:GetEffectiveScale();
end



-- Liefert sicheren Fontnamen. Falls in LSM nicht (mehr) vorhanden oder
-- in asiatischem Land den Standard-Font zurückliefern. Genauso wenn als Argument nil geliefert wurde
local tFontInfo;
function VUHDO_getFont(aFont)
	if (strlen(aFont or "") > 0 and sIsNotInChina) then
		for _, tFontInfo in pairs(VUHDO_FONTS) do
			if (aFont == tFontInfo[1]) then
				return aFont;
			end
		end
	end

	return GameFontNormal:GetFont();
end



--
local function VUHDO_hidePartyFrame()
	local tCnt;
  HIDE_PARTY_INTERFACE = "1";

	hooksecurefunc("ShowPartyFrame",
		function()
	  	if (not InCombatLockdown()) then
  	  	for tCnt = 1, 4 do
    	  	VUHDO_GLOBAL["PartyMemberFrame" .. tCnt]:Hide();
      	end
    	end
  	end
  );

	local tPartyFrame;
  for tCnt = 1, 4 do
    tPartyFrame = VUHDO_GLOBAL["PartyMemberFrame" .. tCnt];
    tPartyFrame:Hide();
    tPartyFrame:UnregisterAllEvents();
    VUHDO_GLOBAL["PartyMemberFrame" .. tCnt .. "HealthBar"]:UnregisterAllEvents();
    VUHDO_GLOBAL["PartyMemberFrame" .. tCnt .. "ManaBar"]:UnregisterAllEvents();
  end
end



--
local function VUHDO_showPartyFrame()
	local tCnt;
  HIDE_PARTY_INTERFACE = "0";

	hooksecurefunc("ShowPartyFrame",
		function()
	  	if (not InCombatLockdown()) then
  	  	for tCnt = 1, 4 do
    	  	VUHDO_GLOBAL["PartyMemberFrame" .. tCnt]:Show();
      	end
    	end
  	end
  );

	local tPartyFrame;
  for tCnt = 1, 4 do
    tPartyFrame = VUHDO_GLOBAL["PartyMemberFrame" .. tCnt];
    if GetPartyMember(tCnt) then
	    tPartyFrame:Show();
	  end

    tPartyFrame:RegisterAllEvents();
    VUHDO_GLOBAL["PartyMemberFrame" .. tCnt .. "HealthBar"]:RegisterAllEvents();
    VUHDO_GLOBAL["PartyMemberFrame" .. tCnt .. "ManaBar"]:RegisterAllEvents();
  end
end



--
local function VUHDO_hidePlayerFrame()
  PlayerFrame:UnregisterAllEvents();
  PlayerFrameHealthBar:UnregisterAllEvents();
  PlayerFrameManaBar:UnregisterAllEvents();
  PlayerFrame:Hide();
end



--
local function VUHDO_showPlayerFrame()
  PlayerFrame:RegisterAllEvents();
  PlayerFrameHealthBar:RegisterAllEvents();
  PlayerFrameManaBar:RegisterAllEvents();
  PlayerFrame:Show();
end



--
local function VUHDO_hidePetFrame()
  PetFrame:UnregisterAllEvents();
  PetFrame:Hide();
end



--
local function VUHDO_showPetFrame()
  PetFrame:RegisterAllEvents();
  PetFrame:Show();
end



--
local function VUHDO_hideFocusFrame()
  FocusFrame:UnregisterAllEvents();
  FocusFrame:Hide();
end



--
local function VUHDO_showFocusFrame()
  FocusFrame:RegisterAllEvents();
  TargetFrame_OnLoad(FocusFrame, "focus", FocusFrameDropDown_Initialize);
end



--
local function VUHDO_hideTargetFrame()
	TargetFrame:UnregisterAllEvents();
	TargetFrameHealthBar:UnregisterAllEvents();
	TargetFrameManaBar:UnregisterAllEvents();
	TargetFrame:Hide();

	TargetFrameToT:UnregisterAllEvents();
	TargetFrameToT:Hide();

  FocusFrameToT:UnregisterAllEvents();
  FocusFrameToT:Hide();

  ComboFrame:ClearAllPoints();
end



--
local function VUHDO_showTargetFrame()
	TargetFrame:RegisterAllEvents();
	TargetFrameHealthBar:RegisterAllEvents();
	TargetFrameManaBar:RegisterAllEvents();

	TargetFrameToT:RegisterAllEvents();
	FocusFrameToT:RegisterAllEvents();
  ComboFrame:SetPoint("TOPRIGHT", "TargetFrame", "TOPRIGHT", -44, -9);
end



--
local function VUHDO_hideBlizzParty()
	VUHDO_hidePartyFrame();
end



--
local function VUHDO_showBlizzParty()
	VUHDO_showPartyFrame();
end



--
local function VUHDO_hideBlizzPlayer()
	VUHDO_hidePlayerFrame();
end



--
local function VUHDO_showBlizzPlayer()
	VUHDO_showPlayerFrame();
end



--
local function VUHDO_hideBlizzTarget()
	VUHDO_hideTargetFrame();
end



--
local function VUHDO_showBlizzTarget()
	VUHDO_showTargetFrame();
end



--
local function VUHDO_hideBlizzPet()
	VUHDO_hidePetFrame();
end



--
local function VUHDO_showBlizzPet()
	VUHDO_showPetFrame();
end


--
local function VUHDO_hideBlizzFocus()
	VUHDO_hideFocusFrame();
end



--
local function VUHDO_showBlizzFocus()
	VUHDO_showFocusFrame();
end




--
function VUHDO_initBlizzFrames()
	if (VUHDO_CONFIG["BLIZZ_UI_HIDE_PARTY"]) then
		VUHDO_hideBlizzParty();
	else
		VUHDO_showBlizzParty();
	end

	if (VUHDO_CONFIG["BLIZZ_UI_HIDE_PLAYER"]) then
		VUHDO_hideBlizzPlayer();
	else
		VUHDO_showBlizzPlayer();
	end

	if (VUHDO_CONFIG["BLIZZ_UI_HIDE_TARGET"]) then
		VUHDO_hideBlizzTarget();
	else
		VUHDO_showBlizzTarget();
	end

	if (VUHDO_CONFIG["BLIZZ_UI_HIDE_PET"]) then
		VUHDO_hideBlizzPet();
	else
		VUHDO_showBlizzPet();
	end

	if (VUHDO_CONFIG["BLIZZ_UI_HIDE_FOCUS"]) then
		VUHDO_hideBlizzFocus();
	else
		VUHDO_showBlizzFocus();
	end
end



--
function VUHDO_initHideBlizzFrames()
	if (InCombatLockdown()) then
		return;
	end

	if (VUHDO_CONFIG["BLIZZ_UI_HIDE_PARTY"]) then
		VUHDO_hideBlizzParty();
	end

	if (VUHDO_CONFIG["BLIZZ_UI_HIDE_PLAYER"]) then
		VUHDO_hideBlizzPlayer();
	end

	if (VUHDO_CONFIG["BLIZZ_UI_HIDE_TARGET"]) then
		VUHDO_hideBlizzTarget();
	end

	if (VUHDO_CONFIG["BLIZZ_UI_HIDE_PET"]) then
		VUHDO_hideBlizzPet();
	end

	if (VUHDO_CONFIG["BLIZZ_UI_HIDE_FOCUS"]) then
		VUHDO_hideBlizzFocus();
	end
end



--
local tOldX, tOldY;
function VUHDO_isDifferentButtonPoint(aRegion, aPointX, aPointY)
	_, _, _, tOldX, tOldY	= aRegion:GetPoint();
	if (tOldX ~= nil) then
		tOldX = floor(tOldX + 0.5);
		tOldY = floor(tOldY + 0.5);
	end
	return aPointX ~= tOldX or aPointY ~= tOldY;
end



--
local tFontHeight;
function VUHDO_lnfPatchFont(aComponent, aLabelName)
	if (not sIsNotInChina) then
		VUHDO_GLOBAL[aComponent:GetName() .. aLabelName]:SetFont(VUHDO_OPTIONS_FONT_NAME, 12);
	end
end


--
function VUHDO_isConfigDemoUsers()
	return VUHDO_IS_PANEL_CONFIG and VUHDO_CONFIG_SHOW_RAID and VUHDO_CONFIG_TEST_USERS > 0;
end



--
local tFile;
function VUHDO_setLlcStatusBarTexture(aStatusBar, aTextureName)
	tFile = VUHDO_LibSharedMedia:Fetch('statusbar', aTextureName);
	if (tFile ~= nil) then
		aStatusBar:SetStatusBarTexture(tFile);
	end
end
