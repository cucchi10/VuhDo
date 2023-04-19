


--
function VUHDO_sendCtraMessage(aMessage)
	SendAddonMessage("CTRA", aMessage, VUHDO_getAddOnDistribution());
end



-- return the ordinality of aUnits main tank entry, returns nil if unit is no main tank
local function VUHDO_getMainTankNumber(aUnit)
	local tMTNumber, tMTName;
	for tMTNumber, tMTName in pairs(VUHDO_MAINTANK_NAMES) do
		if (tMTName == VUHDO_RAID[aUnit].name)	then
			return tMTNumber;
		end
	end

	return nil;
end



--
function VUHDO_ctraBroadCastMaintanks()
	local tUnit, tInfo, tMtNumber;
	for tUnit, tInfo in pairs(VUHDO_RAID) do
		tMtNumber = VUHDO_getMainTankNumber(tUnit);
		if (tMtNumber ~= nil) then
			VUHDO_sendCtraMessage("SET " .. tMtNumber .. " " .. tInfo.name);
		else
			VUHDO_sendCtraMessage("R " .. tInfo.name);
		end
	end
end



--
function VUHDO_parseCtraMessage(aNick, aMessage)
	local tCnt;
	local tNum, tName;
	local tKey;

	-- ended resurrection
	if (aMessage == "RESNO") then
		local tObject, tSubject;
		for tObject, tSubject in pairs(VUHDO_RESSING_NAMES) do
			if (tSubject == aNick) then
				VUHDO_RESSING_NAMES[tObject] = nil;
				local tUnit = VUHDO_RAID_NAMES[tObject];
				if (tUnit ~= nil) then
					VUHDO_updateHealth(tUnit, VUHDO_UPDATE_RESURRECTION);
				end
			end
		end
	-- started resurrection
	elseif (strsub(aMessage, 1, 3) == "RES") then
		local tObject;
		_, _, tObject = strfind(aMessage, "^RES (.+)$");
		if (tObject ~= nil) then
			VUHDO_RESSING_NAMES[tObject] = aNick;
			local tUnit = VUHDO_RAID_NAMES[tObject];
			if (tUnit ~= nil) then
				VUHDO_updateHealth(tUnit, VUHDO_UPDATE_RESURRECTION);
			end
		end
	-- Setting main tanks
	elseif (strsub(aMessage, 1, 4) == "SET ") then
		local _, _, tNum, tName = strfind(aMessage, "^SET (%d+) (.+)$");
		if (tNum ~= nil and tName ~= nil) then
			for tKey, _ in pairs(VUHDO_MAINTANK_NAMES) do
				if (VUHDO_MAINTANK_NAMES[tKey] == tName) then
					VUHDO_MAINTANK_NAMES[tKey] = nil;
				end
			end
			VUHDO_MAINTANK_NAMES[tonumber(tNum)] = tName;
			VUHDO_normalRaidReload();
		end
	-- Removing main tanks
	elseif(strsub(aMessage, 1, 2) == "R ") then
		local _, _, tName = strfind(aMessage, "^R (.+)$");
		if (tName ~= nil) then
			for tKey, _ in pairs(VUHDO_MAINTANK_NAMES) do
				if (VUHDO_MAINTANK_NAMES[tKey] == tName) then
					VUHDO_MAINTANK_NAMES[tKey] = nil;
					break;
				end
			end
			VUHDO_normalRaidReload();
		end
	end
end
