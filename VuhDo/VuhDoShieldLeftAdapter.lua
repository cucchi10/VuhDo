local ceil = ceil;
local twipe = table.wipe;


VuhDoShieldComms = { };

local VUHDO_SHIELDS = { };
local VUHDO_INIT_SHIELDS = { };



--
function VUHDO_resetShieldsLeft()
	twipe(VUHDO_SHIELDS);
	twipe(VUHDO_INIT_SHIELDS);
end


--
local tInit;
local tEmptyShields = { };
function VUHDO_getShieldLeftCount(aUnit, aShield)
	tInit = (VUHDO_INIT_SHIELDS[aUnit] or tEmptyShields)[aShield] or 0;

	if (tInit > 0) then
		return ceil(4 * ((VUHDO_SHIELDS[aUnit] or tEmptyShields)[aShield] or 0) / tInit);
	else
		return 0;
	end
end



--
local tUnit;
local function VUHDO_setShieldAmount(aGUID, aShield, anAmount, anInitAmount)
	tUnit = VUHDO_RAID_GUIDS[aGUID];
	if (tUnit ~= nil) then
		if (VUHDO_SHIELDS[tUnit] == nil) then
			VUHDO_SHIELDS[tUnit] = { };
			VUHDO_INIT_SHIELDS[tUnit] = { };
		end

		VUHDO_SHIELDS[tUnit][aShield] = anAmount;

		if (anAmount == nil) then
			VUHDO_INIT_SHIELDS[tUnit][aShield] = nil;
		elseif (anInitAmount ~= nil) then
			VUHDO_INIT_SHIELDS[tUnit][aShield] = anInitAmount;
		end
	end
end



-- (anEvent, aGUID, aName, aShield, anAmount, anTotalAmount [, aCount])
function VuhDoShieldComms:ShieldLeft_UpdateShield(_, aGUID, _, aShield, anAmount, _)
	VUHDO_setShieldAmount(aGUID, aShield, anAmount, nil);
end



--
function VuhDoShieldComms:ShieldLeft_RefreshShield(_, aGUID, _, aShield, anAmount, _)
	VUHDO_setShieldAmount(aGUID, aShield, anAmount, anAmount);
end



--
function VuhDoShieldComms:ShieldLeft_NewShield(_, aGUID, _, aShield, anAmount, _)
	VUHDO_setShieldAmount(aGUID, aShield, anAmount, anAmount);
end



--
function VuhDoShieldComms:ShieldLeft_RemoveShield(_, aGUID, _, aShield, anAmount, _, _)
	VUHDO_setShieldAmount(aGUID, aShield, nil, nil);
end
