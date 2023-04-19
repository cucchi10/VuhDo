

--
local tCnt, tFrame, tTexture;
local VUHDO_RAID_TARGET_COMBO_MODEL = nil;
function VUHDO_getRaidTargetComboModel(aComboBox)
	local tParent = VUHDO_GLOBAL[aComboBox:GetName() .. "SelectPanel"];
	
  if (VUHDO_RAID_TARGET_COMBO_MODEL == nil) then
    VUHDO_RAID_TARGET_COMBO_MODEL = { };
    for tCnt = 1, 8 do
      tFrame = CreateFrame("Frame", tParent:GetName() .. "Ri" .. tCnt, tParent, "VuhDoRaidTargetIconTemplate");
      tTexture = VUHDO_GLOBAL[tFrame:GetName() .. "I"];
      VUHDO_setRaidTargetIconTexture(tTexture, tCnt);
      tinsert(VUHDO_RAID_TARGET_COMBO_MODEL, { tCnt, tFrame } );
    end
  end

  return VUHDO_RAID_TARGET_COMBO_MODEL;
end
