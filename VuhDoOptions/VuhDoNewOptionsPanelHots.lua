VUHDO_HOT_MODELS = { };
VUHDO_HOT_BAR_MODELS = { };

--
local tCnt, tName, tIndex, tModel;
local tSortTable = { };
function VUHDO_initHotComboModels()
	table.wipe(VUHDO_HOT_MODELS);

	VUHDO_HOT_MODELS[1] = { nil, "-- " .. VUHDO_I18N_EMPTY_HOTS .. " --" };
	VUHDO_HOT_MODELS[2] = { "OTHER", "|cff0000ff[s]|r " .. VUHDO_I18N_OTHER_HOTS};
	VUHDO_HOT_MODELS[3] = { "CLUSTER", "|cff0000ff[s]|r " .. VUHDO_I18N_CLUSTER_FINDER};

	for tCnt = 1, VUHDO_MAX_HOTS do
		VUHDO_HOT_MODELS[tCnt + 3] = { VUHDO_PLAYER_HOTS[tCnt], "[h] " .. VUHDO_PLAYER_HOTS[tCnt] };
	end

	table.wipe(tSortTable);
	for tName, _ in pairs(VUHDO_BOUQUETS["STORED"]) do
		tinsert(tSortTable, {"BOUQUET_" .. tName, "|cff000000[b]|r " .. tName} );
	end

	table.sort(tSortTable,
		function(anInfo, anotherInfo)
			return anInfo[2] < anotherInfo[2];
		end
	);

	for _, tModel in ipairs(tSortTable) do
		tinsert(VUHDO_HOT_MODELS, tModel);
	end
end



--
local tSortTable = { };
function VUHDO_initHotBarComboModels()
	table.wipe(VUHDO_HOT_BAR_MODELS);

	VUHDO_HOT_BAR_MODELS[1] = { nil, "-- " .. VUHDO_I18N_EMPTY_HOTS .. " --" };
	for tCnt = 1, VUHDO_MAX_HOTS do
		VUHDO_HOT_BAR_MODELS[tCnt + 1] = { VUHDO_PLAYER_HOTS[tCnt], VUHDO_PLAYER_HOTS[tCnt] };
	end

	table.wipe(tSortTable);
	for tName, _ in pairs(VUHDO_BOUQUETS["STORED"]) do
		tinsert(tSortTable, {"BOUQUET_" .. tName, "|cff000000[b]|r " .. tName} );
	end

	table.sort(tSortTable,
		function(anInfo, anotherInfo)
			return anInfo[2] < anotherInfo[2];
		end
	);

	for _, tModel in ipairs(tSortTable) do
		tinsert(VUHDO_HOT_BAR_MODELS, tModel);
	end
end



--
local tNum;
function VUHDO_squareDemoOnShow(aTexture)
	tNum = VUHDO_getNumbersFromString(aTexture:GetName(), 1);
	VUHDO_GLOBAL[aTexture:GetName() .. "Label"]:SetText("" .. tNum[1]);
end


--
local tMineBox, tOthersBox, tEditButton, tNumber;
local tFrameName;
function VUHDO_notifyHotSelect(aComboBox, aValue)
	tFrameName = aComboBox:GetParent():GetParent():GetName();

  tNumber = VUHDO_getNumbersFromString(aComboBox:GetName(), 1)[1];
	tMineBox = VUHDO_GLOBAL[tFrameName .. "HotOrderPanelSlot" .. tNumber .. "Mine"];
	tOthersBox = VUHDO_GLOBAL[tFrameName .. "HotOrderPanelSlot" .. tNumber .. "Others"];
	tEditButton = VUHDO_GLOBAL[tFrameName .. "HotOrderPanelSlot" .. tNumber .. "EditButton"];
	if (aValue == nil or aValue == "CLUSTER" or aValue == "OTHER" or strsub(aValue, 1, 8) == "BOUQUET_") then
		tMineBox:Hide();
		tOthersBox:Hide();
		if (aValue ~= nil and strsub(aValue, 1, 8) == "BOUQUET_") then
			tEditButton:Show();
		else
			tEditButton:Hide();
		end
	else
		tMineBox:Show();
		tOthersBox:Show();
		tEditButton:Hide();
	end
end



--
function VUHDO_notifyBouquetUpdate()
	VUHDO_registerAllBouquets();
	VUHDO_initAllEventBouquets();
end



--
local tNum, tCombo;
function VUHDO_panelsHotsEditButtonClicked(aButton)
	tNum = VUHDO_getNumbersFromString(aButton:GetName(), 1)[1];
	tCombo = VUHDO_GLOBAL[aButton:GetParent():GetName() .. "Slot" .. tNum .. "ComboBox"];
	VUHDO_BOUQUETS["SELECTED"] = strsub(VUHDO_lnfGetValueFromModel(tCombo), 9);

	VUHDO_MENU_RETURN_FUNC = nil;
	VUHDO_MENU_RETURN_TARGET = nil;
	VUHDO_MENU_RETURN_TARGET_MAIN = VuhDoNewOptionsTabbedFrameTabsPanelPanelsRadioButton;

	VUHDO_newOptionsTabbedClickedClicked(VuhDoNewOptionsTabbedFrameTabsPanelGeneralRadioButton);
	VUHDO_lnfRadioButtonClicked(VuhDoNewOptionsTabbedFrameTabsPanelGeneralRadioButton);

	VUHDO_newOptionsGeneralBouquetClicked(VuhDoNewOptionsGeneralRadioPanelBouquetRadioButton);
	VUHDO_lnfRadioButtonClicked(VuhDoNewOptionsGeneralRadioPanelBouquetRadioButton);
end