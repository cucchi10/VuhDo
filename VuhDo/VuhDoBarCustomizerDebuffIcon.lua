
local VUHDO_FULL_DURATION_DEBUFFS = {
	[GetSpellInfo(73912)] = true, -- Necrotic Plague, Lich King
};



VUHDO_MAY_DEBUFF_ANIM = true;

local VUHDO_DEBUFF_ICONS = { };
local sScale, sIsAnim, sIsTimer, sIsStacks, sIsName;

-- BURST CACHE ---------------------------------------------------

local floor = floor;
local GetTime = GetTime;
local pairs = pairs;
local twipe = table.wipe;
local _ = _;

local VUHDO_GLOBAL = getfenv();

local VUHDO_getUnitButtons;
local VUHDO_getBarIconTimer
local VUHDO_getBarIconCounter
local VUHDO_getBarIconFrame
local VUHDO_getBarIcon
local VUHDO_getBarIconName

local VUHDO_CONFIG;
local sCuDeConfig;

function VUHDO_customDebuffIconsInitBurst()
 	-- functions
	VUHDO_getUnitButtons = VUHDO_GLOBAL["VUHDO_getUnitButtons"];
	VUHDO_getBarIconTimer = VUHDO_GLOBAL["VUHDO_getBarIconTimer"];
	VUHDO_getBarIconCounter = VUHDO_GLOBAL["VUHDO_getBarIconCounter"];
	VUHDO_getBarIconFrame = VUHDO_GLOBAL["VUHDO_getBarIconFrame"];
	VUHDO_getBarIcon = VUHDO_GLOBAL["VUHDO_getBarIcon"];
	VUHDO_getBarIconName = VUHDO_GLOBAL["VUHDO_getBarIconName"];

	VUHDO_CONFIG = VUHDO_GLOBAL["VUHDO_CONFIG"];
	sCuDeConfig = VUHDO_CONFIG["CUSTOM_DEBUFF"];
end

----------------------------------------------------

--
local tAliveTime;
local tDelta;
local tIconFrame;
local tCnt;
local tIconInfo;
local tTimestamp;
local tExpiry, tRemain;
local tStacks;
local sMaxIcons;
local tCuDeStoConfig;
local tIconIndex;

local function VUHDO_animateDebuffIcon(aButton, someIconInfos, aNow)
	for tCnt = 1, sMaxIcons do
		tIconIndex = tCnt + 39;
  	tIconInfo = someIconInfos[tCnt];
  	if (tIconInfo ~= nil) then
  		tCuDeStoConfig = sCuDeConfig["STORED_SETTINGS"][tIconInfo[3]];
     	if (tCuDeStoConfig == nil) then
     		sIsAnim = sCuDeConfig["animate"] and VUHDO_MAY_DEBUFF_ANIM;
     		sIsTimer = sCuDeConfig["timer"];
     		sIsStacks = sCuDeConfig["isStacks"];
     	else
     		sIsAnim = tCuDeStoConfig["animate"] and VUHDO_MAY_DEBUFF_ANIM;
     		sIsTimer = tCuDeStoConfig["timer"];
     		sIsStacks = tCuDeStoConfig["isStacks"];
     	end
     	sIsName = sCuDeConfig["isName"];
  		tExpiry = tIconInfo[4];

      if (sIsTimer and tExpiry ~= nil) then
      	tRemain = tExpiry - aNow;
      	if (tRemain >= 0 and (tRemain < 10 or VUHDO_FULL_DURATION_DEBUFFS[tIconInfo[3]])) then
      		VUHDO_getBarIconTimer(aButton, tIconIndex):SetText(floor(tRemain));
      	else
      		VUHDO_getBarIconTimer(aButton, tIconIndex):SetText("");
      	end
      end

	  	tStacks = tIconInfo[5];
      if (sIsStacks and (tStacks or 0) > 1) then
      	VUHDO_getBarIconCounter(aButton, tIconIndex):SetText(tStacks);
      else
      	VUHDO_getBarIconCounter(aButton, tIconIndex):SetText("");
      end

	  	tIconFrame = VUHDO_getBarIconFrame(aButton, tIconIndex);

    	if (tIconInfo[2] < 0) then
    		tTimestamp = aNow;
    		VUHDO_getBarIcon(aButton, tIconIndex):SetTexture(tIconInfo[1]);
    		if (sIsName) then
      		VUHDO_getBarIconName(aButton, tIconIndex):SetText(tIconInfo[3]);
      		VUHDO_getBarIconName(aButton, tIconIndex):SetAlpha(1);
      	end
    		tIconFrame:SetScale(0.7 * sScale);
    		tIconFrame:Show();

				if (sIsAnim) then
      		VUHDO_setDebuffAnimation(1.2);
      	end

    	else
    		tTimestamp = tIconInfo[2];
    	end

      tAliveTime = aNow - tTimestamp;
    	if (sIsAnim) then
      	if (tAliveTime <= 0.4) then
      		tIconFrame:SetScale((0.7 + (tAliveTime * 2.5)) * sScale);
      	elseif (tAliveTime <= 0.6) then
      		 -- Keep size
      	elseif (tAliveTime <= 1.1) then
      		tDelta = (tAliveTime - 0.6) * 2;
      		tIconFrame:SetScale((0.7 + (1 - tDelta)) * sScale);
      	end
      end

      if (sIsName and tAliveTime > 2) then
      	VUHDO_getBarIconName(aButton, tIconIndex):SetAlpha(0);
      end
  	end
  end
end



--
local tUnit, tIcon;
local tAllButtons, tButton;
local tNow;
local tCnt;
function VUHDO_updateAllDebuffIcons()
	tNow = GetTime();

	for tUnit, tIcon in pairs(VUHDO_DEBUFF_ICONS) do
		tAllButtons = VUHDO_getUnitButtons(tUnit);
		if (tAllButtons ~= nil) then
			for _, tButton in pairs(tAllButtons) do
				VUHDO_animateDebuffIcon(tButton, tIcon, tNow);
			end

			for tCnt = 1, sMaxIcons do
				if (tIcon[tCnt] ~= nil and tIcon[tCnt][2] < 0) then
		    	tIcon[tCnt][2] = tNow;
		    end
			end
		end
	end
end



-- 1 = icon, 2 = timestamp, 3 = name, 4 = expiration time, 5 = stacks
local tCnt;
local tSlot;
local tOldest;
function VUHDO_addDebuffIcon(aUnit, anIcon, aName, anExpiry, aStacks, anIsCustomDebuff)
	sScale = VUHDO_CONFIG["CUSTOM_DEBUFF"].scale;
	sMaxIcons = VUHDO_CONFIG["CUSTOM_DEBUFF"].max_num;

	if (VUHDO_DEBUFF_ICONS[aUnit] == nil) then
		VUHDO_DEBUFF_ICONS[aUnit] = { };
	end

	tOldest = GetTime();
	tSlot = 1;
	for tCnt = 1, sMaxIcons do
		if (VUHDO_DEBUFF_ICONS[aUnit][tCnt] == nil) then
			tSlot = tCnt;
			break;
		else
			if (VUHDO_DEBUFF_ICONS[aUnit][tCnt][2] > 0 and VUHDO_DEBUFF_ICONS[aUnit][tCnt][2] < tOldest) then
				tOldest = VUHDO_DEBUFF_ICONS[aUnit][tCnt][2];
				tSlot = tCnt;
			end
		end
	end

	VUHDO_DEBUFF_ICONS[aUnit][tSlot] = { anIcon, -1, aName, anExpiry, aStacks };
	VUHDO_updateHealthBarsFor(aUnit, VUHDO_UPDATE_RANGE);
end



--
local tCnt;
function VUHDO_updateDebuffIcon(aUnit, anIcon, aName, anExpiry, aStacks)
	if (VUHDO_DEBUFF_ICONS[aUnit] == nil) then
		VUHDO_DEBUFF_ICONS[aUnit] = { };
	end

	for tCnt = 1, sMaxIcons do
		if (VUHDO_DEBUFF_ICONS[aUnit][tCnt] ~= nil and VUHDO_DEBUFF_ICONS[aUnit][tCnt][3] == aName) then
			VUHDO_DEBUFF_ICONS[aUnit][tCnt] = { anIcon, VUHDO_DEBUFF_ICONS[aUnit][tCnt][2], aName, anExpiry, aStacks };
		end
	end
end



--
local tAllButtons2, tCnt2, tButton2;
local tMaxIcons;
function VUHDO_removeDebuffIcon(aUnit, aName)
	tAllButtons2 = VUHDO_getUnitButtons(aUnit);
	if (tAllButtons2 == nil) then
		return;
	end

	tMaxIcons = VUHDO_CONFIG["CUSTOM_DEBUFF"]["max_num"];
	for tCnt2 = 1, tMaxIcons do
		if (VUHDO_DEBUFF_ICONS[aUnit][tCnt2] ~= nil and VUHDO_DEBUFF_ICONS[aUnit][tCnt2][3] == aName) then
			VUHDO_DEBUFF_ICONS[aUnit][tCnt2][2] = 1; -- ~= -1, lock icon to not be processed by onupdate
			for _, tButton2 in pairs(tAllButtons2) do
				VUHDO_getBarIconFrame(tButton2, tCnt2 + 39):Hide();
			end

			VUHDO_DEBUFF_ICONS[aUnit][tCnt2] = nil;
		end
	end
end



--
local tAllButtons3, tCnt3, tButton3;
function VUHDO_removeAllDebuffIcons(aUnit)
	tAllButtons3 = VUHDO_getUnitButtons(aUnit);
	if (tAllButtons3 == nil) then
		return;
	end

	for _, tButton3 in pairs(tAllButtons3) do
		for tCnt3 = 1, 5 do
			VUHDO_getBarIconFrame(tButton3, tCnt3 + 39):Hide();
		end
	end

	if (VUHDO_DEBUFF_ICONS[aUnit] ~= nil) then
		twipe(VUHDO_DEBUFF_ICONS[aUnit]);
	end
end
