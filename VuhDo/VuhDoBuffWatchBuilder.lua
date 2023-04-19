local pairs = pairs;
local ipairs = ipairs;
local InCombatLockdown = InCombatLockdown;


local VUHDO_BUFF_PANEL_BASE_HEIGHT = nil;
local VUHDO_BUFF_PANEL_BASE_WIDTH = nil;
local VUHDO_IN_PANEL_X;
local VUHDO_IN_PANEL_Y;
local VUHDO_IN_GRID_X;
local VUHDO_IN_PANEL_WIDTH;
local VUHDO_IN_PANEL_HEIGHT;
local VUHDO_PANEL_OFFSET_Y;
local VUHDO_PANEL_OFFSET_X;
local VUHDO_PANEL_WIDTH = 0;
local VUHDO_PANEL_HEIGHT = 0;
local VUHDO_BUFF_PANEL_GAP_X = 4;
local VUHDO_BUFF_PANEL_GAP_TOP = 4;


--
local tMaxVariant;
local tMaxTargetName;
local tPostfix;
local tColor;
local tIcon;
local tButton;
local tSwatch;
local tIsSingle;
local tTarget;
local tBuff;
local function VUHDO_addBuffSwatch(aBuffPanel, aGroupName, someVariants, aBuffTarget, aCategSpec)
	if (someVariants == nil) then
		return nil;
	end
	tMaxVariant = VUHDO_getBuffVariantMaxTarget(someVariants);
	tMaxTargetName = tMaxVariant[1];

	tPostfix = tMaxTargetName .. (aBuffTarget or "");

	tSwatch = VUHDO_getOrCreateBuffSwatch("VuhDoBuffSwatch_" .. tPostfix, aBuffPanel);
	tSwatch:SetAttribute("buff", someVariants);
	tSwatch:SetAttribute("target", aBuffTarget);
	tSwatch:SetAttribute("buffname", aCategSpec);

	VUHDO_GLOBAL[tSwatch:GetName() .. "GroupLabelLabel"]:SetText(aGroupName);

	tIcon = VUHDO_GLOBAL[tSwatch:GetName() .. "BuffIconTexture"];
	if (VUHDO_BUFF_TARGET_CLASS == tMaxVariant[2]) then
		VUHDO_GLOBAL[tIcon:GetName() .. "Texture"]:SetTexture(VUHDO_BUFFS[tMaxTargetName].icon);
		tIcon:SetAlpha(0.5);
		tIcon:Show();
	else
		tIcon:Hide();
	end

	tSwatch:ClearAllPoints();
	tSwatch:SetPoint("TOPLEFT", aBuffPanel:GetName(), "TOPLEFT", VUHDO_IN_PANEL_X, -VUHDO_IN_PANEL_Y);

	tColor = VUHDO_BUFF_SETTINGS["CONFIG"]["SWATCH_BORDER_COLOR"];
	tSwatch:SetBackdropBorderColor(tColor.R, tColor.G, tColor.B, tColor.O);
	tSwatch:Show();

	tButton = VUHDO_GLOBAL[tSwatch:GetName() .. "GlassButton"];
	if (tButton:GetAttribute("unit") == nil) then
		VUHDO_setupAllBuffButtonsTo(tButton, tMaxTargetName, "player", tMaxTargetName);
	end

	if (VUHDO_IN_PANEL_X > VUHDO_IN_PANEL_WIDTH) then
		VUHDO_IN_PANEL_WIDTH = VUHDO_IN_PANEL_X;
	end

	if (VUHDO_IN_PANEL_Y + tSwatch:GetHeight() > VUHDO_IN_PANEL_HEIGHT) then
		VUHDO_IN_PANEL_HEIGHT = VUHDO_IN_PANEL_Y + tSwatch:GetHeight();
	end

	if (VUHDO_IN_GRID_X > VUHDO_IN_GRID_MAX_X) then
		VUHDO_IN_GRID_MAX_X = VUHDO_IN_GRID_X;
	end

	VUHDO_IN_GRID_X = VUHDO_IN_GRID_X + 1;
	if (VUHDO_IN_GRID_X > VUHDO_BUFF_SETTINGS["CONFIG"]["SWATCH_MAX_ROWS"]) then
		VUHDO_IN_GRID_X = 1;
		VUHDO_IN_PANEL_X = VUHDO_BUFF_PANEL_BASE_WIDTH;
		VUHDO_IN_PANEL_Y = VUHDO_IN_PANEL_Y + tSwatch:GetHeight();
	else
		VUHDO_IN_PANEL_X = VUHDO_IN_PANEL_X + tSwatch:GetWidth();
	end

	VUHDO_updateBuffSwatch(tSwatch);
	tIsSingle = VUHDO_isUseSingleBuff(tSwatch);
	if (tIsSingle ~= 2) then
		if (tIsSingle) then
			tTarget = tSwatch:GetAttribute("lowtarget");
			tBuff = VUHDO_getBuffVariantSingleTarget(someVariants)[1];
			VUHDO_setupAllBuffButtonsTo(tButton, tBuff, tTarget, VUHDO_getBuffVariantMaxTarget(someVariants)[1]);
		else
			tTarget = tSwatch:GetAttribute("goodtarget");
			VUHDO_setupAllBuffButtonUnits(tButton, tTarget);
		end
	end

	return tSwatch;
end



--
local tClassName;
local tGroups = {};
local function VUHDO_getValidBuffClasses(someSettings)
	table.wipe(tGroups);

	if (someSettings["classes"] == nil) then
		someSettings["classes"] = { };
	end

	for _, tClassName in ipairs(VUHDO_CLASS_NAMES_ORDERED) do
		if (someSettings["classes"][tClassName] ~= nil) then
			tinsert(tGroups, VUHDO_CLASS_IDS[tClassName]);
		end
	end

	return tGroups;
end



--
local tClassBuffs;
local tCategBuffs, tBuffVariants, tVariant;
local function VUHDO_getBuffVariants(aBuffName)
	tClassBuffs = VUHDO_CLASS_BUFFS[VUHDO_PLAYER_CLASS];

	for _, tCategBuffs in pairs(tClassBuffs) do
		for _, tBuffVariants in pairs(tCategBuffs) do
			for _, tVariant in pairs(tBuffVariants) do
				if (aBuffName == tVariant[1]) then
					return tBuffVariants;
				end
			end
		end
	end

	return nil;
end



--
local function VUHDO_addBuffPanel(aCategorySpec)
	local tCategName = strsub(aCategorySpec, 3);
	local tSettings = VUHDO_BUFF_SETTINGS[tCategName];
	local tClassBuffs = VUHDO_CLASS_BUFFS[VUHDO_PLAYER_CLASS];
	local tCategBuffs = tClassBuffs[aCategorySpec];
	local tTestVariants = tCategBuffs[1];
	local tMaxVariant = VUHDO_getBuffVariantMaxTarget(tTestVariants);
	local tSingleVariant = VUHDO_getBuffVariantSingleTarget(tTestVariants);
	local tBuffPanel, tSwatch;
	local tIcon;
	local tAddWidth;
	local tBuffTarget;
	local tIconFrame;
	local tNewSwatch;

	-- Happens on emergency login
	if (VUHDO_BUFFS[tMaxVariant[1]] == nil) then
		return nil;
	end

  if (VUHDO_BUFFS[tMaxVariant[1]]["present"]) then
  	tBuffTarget = tMaxVariant[2];
  else
  	tBuffTarget = tSingleVariant[2];
  end

	local tLabelText;
	if (VUHDO_BUFF_TARGET_CLASS == tBuffTarget) then
		-- or VUHDO_BUFF_TARGET_GROUP == tBuffTarget
		tLabelText = tCategName;
	elseif (VUHDO_BUFF_SETTINGS[tCategName].buff ~= nil) then
		tLabelText = VUHDO_BUFF_SETTINGS[tCategName]["buff"];
	else
		tLabelText = tMaxVariant[1];
	end

	tBuffPanel = VUHDO_getOrCreateBuffPanel("VuhDoBuffPanel" .. tLabelText);

	if (VUHDO_BUFF_SETTINGS["CONFIG"]["COMPACT"]) then
		VUHDO_BUFF_PANEL_BASE_WIDTH = 24;
		VUHDO_BUFF_PANEL_BASE_HEIGHT = 0;
	else
		VUHDO_BUFF_PANEL_BASE_WIDTH = 0;
		VUHDO_BUFF_PANEL_BASE_HEIGHT = 30;
	end

	if (VUHDO_BUFFS[tLabelText] ~= nil and VUHDO_BUFFS[tLabelText]["icon"] ~= nil) then
		tIcon = VUHDO_BUFFS[tLabelText]["icon"];
	else
	  if (VUHDO_BUFFS[tMaxVariant[1]].present) then
			tIcon = VUHDO_BUFFS[tMaxVariant[1]]["icon"];
		else
			tIcon = VUHDO_BUFFS[tSingleVariant[1]]["icon"];
		end
	end

	if (tIcon == nil) then
		return nil;
	end

	local tLabel = VUHDO_GLOBAL[tBuffPanel:GetName() .. "BuffNameLabelLabel"];
	if (VUHDO_BUFF_SETTINGS["CONFIG"]["SHOW_LABEL"] and not VUHDO_BUFF_SETTINGS["CONFIG"]["COMPACT"]) then
		tLabel:SetText(tLabelText);
		tLabel:Show();
	else
		tLabel:Hide();
	end
	VUHDO_GLOBAL[tBuffPanel:GetName() .. "IconTextureTexture"]:SetTexture(tIcon);

	tIconFrame = VUHDO_GLOBAL[tBuffPanel:GetName() .. "IconTexture"];
	tIconFrame:ClearAllPoints();
	if (VUHDO_BUFF_SETTINGS["CONFIG"]["COMPACT"]) then
		tIconFrame:SetPoint("TOPLEFT", tBuffPanel:GetName(), "TOPLEFT" , 0, 0);
	else
		tIconFrame:SetPoint("TOPLEFT", tBuffPanel:GetName(), "TOPLEFT" , 3, -3);
	end


	VUHDO_IN_PANEL_X = VUHDO_BUFF_PANEL_BASE_WIDTH;
	VUHDO_IN_PANEL_Y = VUHDO_BUFF_PANEL_BASE_HEIGHT;

	VUHDO_IN_GRID_X = 1;
	VUHDO_IN_PANEL_WIDTH = 0;
	VUHDO_IN_PANEL_HEIGHT = 0;

	tSwatch = nil;

	if (VUHDO_BUFF_TARGET_SINGLE == tBuffTarget) then
		local tVariants = VUHDO_getBuffVariants(tSettings["buff"]) or VUHDO_getBuffVariants(tMaxVariant[1]);
		if (tVariants ~= nil) then
			tSwatch = VUHDO_addBuffSwatch(tBuffPanel, VUHDO_I18N_PLAYER, tVariants, "S", aCategorySpec);
		end
--	elseif (VUHDO_BUFF_TARGET_GROUP == tBuffTarget) then
--		local tGroups = VUHDO_getValidBuffGroups(tSettings);
--		local tGroupNo;
--		for _, tGroupNo in ipairs(tGroups) do
--			if (VUHDO_BUFF_SETTINGS["CONFIG"]["SHOW_EMPTY"] or VUHDO_getNumGroupMembers(tGroupNo) > 0) then
--				tNewSwatch = VUHDO_addBuffSwatch(tBuffPanel, VUHDO_HEADER_TEXTS[tGroupNo], tCategBuffs[1], "G" .. tGroupNo, aCategorySpec);
--				if (tSwatch == nil) then
--					tSwatch = tNewSwatch;
--				end
--			end
--		end
	elseif (VUHDO_BUFF_TARGET_CLASS == tBuffTarget) then
		local tGroups = VUHDO_getValidBuffClasses(tSettings);
		local tGroupId;
		for _, tGroupId in ipairs(tGroups) do
			if (VUHDO_BUFF_SETTINGS["CONFIG"]["SHOW_EMPTY"] or VUHDO_getNumGroupMembers(tGroupId) > 0) then
				local tClassName = VUHDO_ID_CLASSES[tGroupId];
				local tClassText = VUHDO_HEADER_TEXTS[tGroupId];
				local tBuffName = tSettings["classes"][tClassName];
				local tBuffVariants = VUHDO_getBuffVariants(tBuffName);
				tNewSwatch = VUHDO_addBuffSwatch(tBuffPanel, tClassText, tBuffVariants, "C" .. tClassName, aCategorySpec);
				if (tSwatch == nil) then
					tSwatch = tNewSwatch;
				end
			end
		end
	elseif (VUHDO_BUFF_TARGET_UNIQUE == tBuffTarget) then
		tSwatch = VUHDO_addBuffSwatch(tBuffPanel, tSettings["name"], tCategBuffs[1], "N" .. tSettings["name"], aCategorySpec);
	else
		local tVariants = VUHDO_getBuffVariants(tSettings["buff"]) or VUHDO_getBuffVariants(tMaxVariant[1]);
		if (tVariants ~= nil) then
			tSwatch = VUHDO_addBuffSwatch(tBuffPanel, VUHDO_I18N_PLAYER, tVariants, "S", aCategorySpec);
		end
	end

	if (tSwatch ~= nil) then
		tBuffPanel:ClearAllPoints();
		tBuffPanel:SetPoint("TOPLEFT", "VuhDoBuffWatchMainFrame", "TOPLEFT", VUHDO_PANEL_OFFSET_X, -VUHDO_PANEL_OFFSET_Y);
		tBuffPanel:SetWidth(tSwatch:GetWidth() * VUHDO_IN_GRID_MAX_X + VUHDO_BUFF_PANEL_BASE_WIDTH);
		tBuffPanel:SetHeight(VUHDO_IN_PANEL_HEIGHT);
		VUHDO_GLOBAL[tBuffPanel:GetName() .. "BuffNameLabel"]:SetWidth(tBuffPanel:GetWidth() - 30);
		tBuffPanel:Show();
	end

	return tBuffPanel;
end



--
local function VUHDO_addAllBuffPanels()
	local tCategSepc, tCategName;
	local tAllClassBuffs = VUHDO_CLASS_BUFFS[VUHDO_PLAYER_CLASS];
	local tBuffPanel;
	local tColPanels;

	VUHDO_PANEL_OFFSET_Y = VUHDO_BUFF_PANEL_GAP_TOP;
	VUHDO_PANEL_OFFSET_X = VUHDO_BUFF_PANEL_GAP_X;
	VUHDO_PANEL_HEIGHT = VUHDO_BUFF_PANEL_GAP_TOP;
	VUHDO_PANEL_WIDTH = VUHDO_BUFF_PANEL_GAP_X;
  VUHDO_IN_GRID_MAX_X = 0;

	tColPanels = 0;
	local tIndex = 0;

	for _, _ in pairs(tAllClassBuffs) do
  	for tCategSepc, _ in pairs(tAllClassBuffs) do
  		tCategName = strsub(tCategSepc, 3);
  		local tNumber;
  		if (VUHDO_BUFF_ORDER[tCategSepc] == nil) then
  			tNumber = tonumber(strsub(tCategSepc, 1, 2));
  		else
  			tNumber = VUHDO_BUFF_ORDER[tCategSepc];
  		end
  		local tCategSettings = VUHDO_BUFF_SETTINGS[tCategName];
			if (tNumber == tIndex + 1) then
  			tIndex = tIndex + 1;
    		if (tCategSettings ~= nil and tCategSettings.enabled) then

    			tBuffPanel = VUHDO_addBuffPanel(tCategSepc);
    			if (tBuffPanel ~= nil) then
      			tColPanels = tColPanels + 1;

      			VUHDO_PANEL_OFFSET_Y = VUHDO_PANEL_OFFSET_Y + VUHDO_IN_PANEL_HEIGHT;

      			if (VUHDO_PANEL_OFFSET_Y > VUHDO_PANEL_HEIGHT) then
      				VUHDO_PANEL_HEIGHT = VUHDO_PANEL_OFFSET_Y;
      			end

      			if (VUHDO_PANEL_OFFSET_X > VUHDO_PANEL_WIDTH) then
      				VUHDO_PANEL_WIDTH = VUHDO_PANEL_OFFSET_X;
      			end

      			if (tColPanels >= VUHDO_BUFF_SETTINGS["CONFIG"]["PANEL_MAX_BUFFS"]) then
      				VUHDO_PANEL_OFFSET_Y = VUHDO_BUFF_PANEL_GAP_TOP;
      				VUHDO_PANEL_OFFSET_X = VUHDO_PANEL_OFFSET_X + tBuffPanel:GetWidth();
     					VUHDO_IN_GRID_MAX_X = 0;

      				tColPanels = 0;
      			end
    			end
    		end

			end
  	end
  end

	if (tBuffPanel ~= nil) then
		VUHDO_PANEL_WIDTH = VUHDO_PANEL_WIDTH + tBuffPanel:GetWidth();
	end

	return tBuffPanel;
end




--
function VUHDO_reloadBuffPanel()
	if (InCombatLockdown()) then
		return;
	end

	if (VUHDO_BUFF_SETTINGS["CONFIG"] == nil) then
		if (VuhDoBuffWatchMainFrame ~= nil) then
			VuhDoBuffWatchMainFrame:Hide();
		end
		return;
	end

	VUHDO_REFRESH_BUFFS_TIMER = 0;
	VUHDO_resetBuffSwatchInfos();
	VUHDO_resetAllBuffPanels();

	if (VUHDO_CLASS_BUFFS[VUHDO_PLAYER_CLASS] == nil) then
		return;
	end

	if (VuhDoBuffWatchMainFrame == nil) then
		CreateFrame("Frame", "VuhDoBuffWatchMainFrame", UIParent, "VuhDoBuffWatchMainFrameTemplate");
	end

	local tBuffPanel = VUHDO_addAllBuffPanels();

	if (VUHDO_PANEL_HEIGHT < 10) then
		VUHDO_PANEL_HEIGHT = 24;
		VUHDO_PANEL_WIDTH = 150;
		VuhDoBuffWatchMainFrameInfoLabel:Show();
	else
		VuhDoBuffWatchMainFrameInfoLabel:Hide();
	end

	VuhDoBuffWatchMainFrame:ClearAllPoints();
	local tPosition = VUHDO_BUFF_SETTINGS["CONFIG"]["POSITION"];
	VuhDoBuffWatchMainFrame:SetPoint(tPosition["point"], "UIParent", tPosition["relativePoint"], tPosition["x"], tPosition["y"]);
	VuhDoBuffWatchMainFrame:SetWidth(VUHDO_PANEL_WIDTH + VUHDO_BUFF_PANEL_GAP_X);
	VuhDoBuffWatchMainFrame:SetHeight(VUHDO_PANEL_HEIGHT + VUHDO_BUFF_PANEL_GAP_TOP);


	local tColor = VUHDO_BUFF_SETTINGS["CONFIG"]["PANEL_BG_COLOR"];
	VuhDoBuffWatchMainFrame:SetBackdropColor(tColor["R"], tColor["G"], tColor["B"], tColor["O"]);
	tColor = VUHDO_BUFF_SETTINGS["CONFIG"]["PANEL_BORDER_COLOR"];
	VuhDoBuffWatchMainFrame:SetBackdropBorderColor(tColor["R"], tColor["G"], tColor["B"], tColor["O"]);
	VuhDoBuffWatchMainFrame:SetScale(VUHDO_BUFF_SETTINGS["CONFIG"]["SCALE"]);

	if (VUHDO_BUFF_SETTINGS["CONFIG"]["SHOW"]) then
		VuhDoBuffWatchMainFrame:Show();
	else
		VuhDoBuffWatchMainFrame:Hide();
	end

	VUHDO_REFRESH_BUFFS_TIMER = VUHDO_BUFF_SETTINGS["CONFIG"]["REFRESH_SECS"];
end
