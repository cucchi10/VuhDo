VUHDO_PANEL_UNITS = { {}, {}, {}, {}, {}, {}, {}, {}, {}, {} };
local VUHDO_PANEL_UNITS = VUHDO_PANEL_UNITS;

VUHDO_UNIT_BUTTONS = {};
local VUHDO_UNIT_BUTTONS = VUHDO_UNIT_BUTTONS;

local table = table;
local tinsert = tinsert;
local ipairs = ipairs;
local twipe = table.wipe;
local tsort = table.sort;



-- BURST CACHE ---------------------------------------------------

local VUHDO_ORDERING_STRICT = 0;
local VUHDO_ID_ALL = 999;

local VUHDO_PANEL_SETUP;
local VUHDO_HEADER_TEXTS;
local VUHDO_GROUPS;
local VUHDO_RAID;

local VUHDO_getUnitGroup;
local VUHDO_getHeaderTextId;
local VUHDO_getClassColorByModelId;
local VUHDO_getHeaderBar;
local VUHDO_getModelType;

--
function VUHDO_panelInitBurst()
	VUHDO_PANEL_SETUP = VUHDO_GLOBAL["VUHDO_PANEL_SETUP"];
	VUHDO_HEADER_TEXTS = VUHDO_GLOBAL["VUHDO_HEADER_TEXTS"];
	VUHDO_GROUPS = VUHDO_GLOBAL["VUHDO_GROUPS"];
	VUHDO_RAID = VUHDO_GLOBAL["VUHDO_RAID"];

	VUHDO_getUnitGroup = VUHDO_GLOBAL["VUHDO_getUnitGroup"];
	VUHDO_getHeaderTextId = VUHDO_GLOBAL["VUHDO_getHeaderTextId"];
	VUHDO_getClassColorByModelId = VUHDO_GLOBAL["VUHDO_getClassColorByModelId"];
	VUHDO_getHeaderBar = VUHDO_GLOBAL["VUHDO_getHeaderBar"];
	VUHDO_getModelType = VUHDO_GLOBAL["VUHDO_getModelType"];
end
-- BURST CACHE ---------------------------------------------------



--
local tIdAll = { VUHDO_ID_ALL };
local tEmpty = { };
function VUHDO_getDynamicModelArray(aPanelNum)
	if (0 == VUHDO_PANEL_SETUP[aPanelNum]["MODEL"]["ordering"]) then -- VUHDO_ORDERING_STRICT
		return VUHDO_PANEL_DYN_MODELS[aPanelNum] or tEmpty;
	else
		return tIdAll;
	end
end
local VUHDO_getDynamicModelArray = VUHDO_getDynamicModelArray;



--
function VUHDO_getHeaderText(aModelId)
	if (10 == aModelId) then -- VUHDO_ID_GROUP_OWN
		return  VUHDO_HEADER_TEXTS[aModelId] .. " (" .. VUHDO_PLAYER_GROUP .. ")";
	else
		return VUHDO_HEADER_TEXTS[aModelId];
	end
end
local VUHDO_getHeaderText = VUHDO_getHeaderText;



--
local tHeaderText;
local tColor;
function VUHDO_customizeHeader(aHeader, aPanelNum, aModelId)
	tHeaderText = VUHDO_getHeaderTextId(aHeader);
	tHeaderText:SetText(VUHDO_getHeaderText(aModelId));

	if (VUHDO_PANEL_SETUP[aPanelNum]["PANEL_COLOR"]["classColorsHeader"]
		and VUHDO_ID_TYPE_CLASS == VUHDO_getModelType(aModelId)) then
		tColor = VUHDO_getClassColorByModelId(aModelId);
	else
		tColor = VUHDO_PANEL_SETUP[aPanelNum]["PANEL_COLOR"]["HEADER"];
	end
	tHeaderText:SetTextColor(tColor["TR"], tColor["TG"], tColor["TB"], tColor["TO"]);

	if (VUHDO_PANEL_SETUP[aPanelNum]["PANEL_COLOR"]["classColorsBackHeader"]
		and VUHDO_ID_TYPE_CLASS == VUHDO_getModelType(aModelId)) then
		tColor = VUHDO_getClassColorByModelId(aModelId);
	else
		tColor = VUHDO_PANEL_SETUP[aPanelNum]["PANEL_COLOR"]["HEADER"];
	end
	VUHDO_getHeaderBar(aHeader):SetStatusBarColor(tColor["R"], tColor["G"], tColor["B"], tColor["O"]);
end



--
local tSubTable = { };
local tSubCount;
local tEnd;
local function VUHDO_getSubTable(aTable, anIndex, aCount)
	twipe(tSubTable);

	tEnd = anIndex + aCount - 1;
	for tSubCount = anIndex, tEnd do
		if (aTable[tSubCount] ~= nil) then
			tinsert(tSubTable, aTable[tSubCount]);
		else
			break;
		end
	end

	return tSubTable;
end



--
local tOccurrence;
local tDynModel;
local tMaxRows;
local tModelNo;
local tEmptyGroup = { };
local function VUHDO_cutSubGroup(anIdentifier, aPanelNum, aModelIndex)
	tDynModel = VUHDO_getDynamicModelArray(aPanelNum);
	tOccurrence = 0;
	for tModelNo = 1, aModelIndex do
		if (tDynModel[tModelNo] == anIdentifier) then
			tOccurrence = tOccurrence + 1;
		end
	end

	tMaxRows = VUHDO_PANEL_SETUP[aPanelNum]["SCALING"]["maxRowsWhenLoose"];
	return VUHDO_getSubTable(VUHDO_GROUPS[anIdentifier] or tEmptyGroup, (tOccurrence - 1) * tMaxRows + 1, tMaxRows);
end



--
local tEmptyArray = { };
local tGroupArray;
function VUHDO_getGroupMembers(anIdentifier, aPanelNum, aModelIndex)
	if (999 ~= anIdentifier) then -- VUHDO_ID_ALL
		if (aModelIndex == nil) then
			tGroupArray = VUHDO_GROUPS[anIdentifier];
		else
			tGroupArray = VUHDO_cutSubGroup(anIdentifier, aPanelNum, aModelIndex);
		end
	else
		tGroupArray = VUHDO_PANEL_UNITS[aPanelNum];
	end

	return tGroupArray or tEmptyArray;
end
local VUHDO_getGroupMembers = VUHDO_getGroupMembers;



local sPanelNum;
local sIsPlayerFirst;
local tInfo1, tInfo2;
local tEmpty = { };



--
local VUHDO_RAID_SORTERS = {
	[VUHDO_SORT_RAID_UNITID]
		= function(aUnitId, anotherUnitId)
				if (sIsPlayerFirst and aUnitId == "player") then
					return true;
				elseif (sIsPlayerFirst and anotherUnitId == "player") then
					return false;
				else
					if (VUHDO_PANEL_SETUP[sPanelNum]["MODEL"]["isReverse"]) then
						aUnitId, anotherUnitId = anotherUnitId, aUnitId;
					end
					tInfo1, tInfo2 = VUHDO_RAID[aUnitId] or tEmpty, VUHDO_RAID[anotherUnitId] or tEmpty;
					return (tInfo1["number"] or 0) < (tInfo2["number"] or 0); -- comparing strings doesn't work
				end
			end,

	[VUHDO_SORT_RAID_NAME]
		= function(aUnitId, anotherUnitId)
				if (sIsPlayerFirst and aUnitId == "player") then
					return true;
				elseif (sIsPlayerFirst and anotherUnitId == "player") then
					return false;
				else
					if (VUHDO_PANEL_SETUP[sPanelNum]["MODEL"]["isReverse"]) then
						aUnitId, anotherUnitId = anotherUnitId, aUnitId;
					end
					tInfo1, tInfo2 = VUHDO_RAID[aUnitId] or tEmpty, VUHDO_RAID[anotherUnitId] or tEmpty;
					return (tInfo1["name"] or "") < (tInfo2["name"] or "");
				end
			end,

	[VUHDO_SORT_RAID_CLASS]
		= function(aUnitId, anotherUnitId)
				if (sIsPlayerFirst and aUnitId == "player") then
					return true;
				elseif (sIsPlayerFirst and anotherUnitId == "player") then
					return false;
				elseif (VUHDO_RAID[aUnitId]["class"]~= nil and VUHDO_RAID[anotherUnitId]["class"] ~= nil) then
					if (VUHDO_PANEL_SETUP[sPanelNum]["MODEL"]["isReverse"]) then
						aUnitId, anotherUnitId = anotherUnitId, aUnitId;
					end
					tInfo1, tInfo2 = VUHDO_RAID[aUnitId] or tEmpty, VUHDO_RAID[anotherUnitId] or tEmpty;
					return (tInfo1["class"] or "") .. (tInfo1["name"] or "") > (tInfo2["class"] or "") .. (tInfo2["name"] or "");
				else
					if (VUHDO_PANEL_SETUP[sPanelNum]["MODEL"]["isReverse"]) then
						aUnitId, anotherUnitId = anotherUnitId, aUnitId;
					end
					tInfo1, tInfo2 = VUHDO_RAID[aUnitId] or tEmpty, VUHDO_RAID[anotherUnitId] or tEmpty;
					return (tInfo1["name"] or "") < (tInfo2["name"] or "");
				end
			end,

	[VUHDO_SORT_RAID_MAX_HP]
		= function(aUnitId, anotherUnitId)
				if (sIsPlayerFirst and aUnitId == "player") then
					return true;
				elseif (sIsPlayerFirst and anotherUnitId == "player") then
					return false;
				elseif (VUHDO_RAID[aUnitId]["sortMaxHp"] ~= nil and VUHDO_RAID[anotherUnitId]["sortMaxHp"] ~= nil) then
					if (VUHDO_PANEL_SETUP[sPanelNum]["MODEL"]["isReverse"]) then
						aUnitId, anotherUnitId = anotherUnitId, aUnitId;
					end
					tInfo1, tInfo2 = VUHDO_RAID[aUnitId] or tEmpty, VUHDO_RAID[anotherUnitId] or tEmpty;
					return (tInfo1["sortMaxHp"] or 0) > (tInfo2["sortMaxHp"] or 0);
				else
					if (VUHDO_PANEL_SETUP[sPanelNum]["MODEL"]["isReverse"]) then
						aUnitId, anotherUnitId = anotherUnitId, aUnitId;
					end
					tInfo1, tInfo2 = VUHDO_RAID[aUnitId] or tEmpty, VUHDO_RAID[anotherUnitId] or tEmpty;
					return (tInfo1["name"] or "") < (tInfo2["name"] or "");
				end
			end,

	[VUHDO_SORT_RAID_MODELS]
		= function(aUnitId, anotherUnitId)
				if (sIsPlayerFirst and aUnitId == "player") then
					return true;
				elseif (sIsPlayerFirst and anotherUnitId == "player") then
					return false;
				else
					if (VUHDO_PANEL_SETUP[sPanelNum]["MODEL"]["isReverse"]) then
						aUnitId, anotherUnitId = anotherUnitId, aUnitId;
					end
					tFirstIdx = VUHDO_getPanelUnitFirstModel(sPanelNum, aUnitId);
					tSecondIdx = VUHDO_getPanelUnitFirstModel(sPanelNum, anotherUnitId);
					if (tFirstIdx ~= tSecondIdx) then
						return tFirstIdx < tSecondIdx;
					else
						tInfo1, tInfo2 = VUHDO_RAID[aUnitId] or tEmpty, VUHDO_RAID[anotherUnitId] or tEmpty;
						return (tInfo1["name"] or "") < (tInfo2["name"] or "");
					end
				end
			end,
};



--
local tSorted = { };
local tMembers;
local tUnit;
local tNoExists;
local tWasTarget, tWasFocus;
function VUHDO_getGroupMembersSorted(anIdentifier, aSortCriterion, aPanelNum, aModelIndex)
	tMembers = VUHDO_getGroupMembers(anIdentifier, aPanelNum, aModelIndex);
	sIsPlayerFirst = VUHDO_PANEL_SETUP[aPanelNum]["SCALING"]["isPlayerOnTop"];

	if (41 ~= anIdentifier) then -- VUHDO_ID_MAINTANKS
		twipe(tSorted);
		tNoExists = false;
		tWasTarget, tWasFocus = false, false;
		for _, tUnit in ipairs(tMembers) do
			if (tUnit == "target") then
				tWasTarget = true;
			elseif (tUnit == "focus") then
				tWasFocus = true;
			else
				tinsert(tSorted, tUnit);
			end
			if (VUHDO_RAID[tUnit] == nil) then
				tNoExists = true;
			end
		end
		if (70 == anIdentifier or tNoExists or tWasTarget or tWasFocus) then -- VUHDO_ID_VEHICLES
			tsort(tSorted,
				function(aUnitId, anotherUnitId)
					if (sIsPlayerFirst and aUnitId == "player") then
						return true;
					elseif (sIsPlayerFirst and anotherUnitId == "player") then
						return false;
					else
						return aUnitId < anotherUnitId;
					end
				end
			);
			if (tWasFocus) then
				tinsert(tSorted, 1, "focus");
			end
			if (tWasTarget) then
				tinsert(tSorted, 1, "target");
			end
		else
			sPanelNum = aPanelNum;
			tsort(tSorted, VUHDO_RAID_SORTERS[aSortCriterion]);
		end

	else -- for main tanks keep the order of CTRA/ORA
		twipe(tSorted); -- has to be copied!!! conflicts in size calculator otherwise!
		for _, tUnit in ipairs(tMembers) do
			tinsert(tSorted, tUnit);
		end
	end

	return tSorted;
end



--
local tUnit;
function VUHDO_addUnitButton(aHealButton)
	tUnit = aHealButton:GetAttribute("unit");
	if (VUHDO_UNIT_BUTTONS[tUnit] == nil) then
		VUHDO_UNIT_BUTTONS[tUnit] = { };
	end
	tinsert(VUHDO_UNIT_BUTTONS[tUnit], aHealButton);
end
