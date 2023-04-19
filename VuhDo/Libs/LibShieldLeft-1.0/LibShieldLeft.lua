local MAJOR_VERSION = "LibShieldLeft-1.0"
local MINOR_VERSION = tonumber(("$Revision: 9999 $"):match("%d+"))

local lib = LibStub:NewLibrary(MAJOR_VERSION, MINOR_VERSION)
if not lib then return end

local playerName = UnitName('player')
local playerGUID = UnitGUID('player')
local playerClass = select(2, UnitClass('player'))
local isShielder = (playerClass == "PRIEST")

-----------------
-- Event Frame --
-----------------

lib.EventFrame = lib.EventFrame or CreateFrame("Frame")
lib.EventFrame:SetScript("OnEvent", function (this, event, ...) lib[event](lib, ...) end)
--lib.EventFrame:SetScript("OnUpdate", function (this, elapsed, ...) lib:OnUpdate(lib, elapsed, ...) end)
lib.EventFrame:UnregisterAllEvents()

-- Register Events
lib.EventFrame:RegisterEvent("LEARNED_SPELL_IN_TAB")
lib.EventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

-- Prune data at zone change
--lib.EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
--lib.EventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
--lib.EventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")


----------------------
-- Scanning Tooltip --
----------------------

if (not lib.Tooltip) then
    lib.Tooltip = CreateFrame("GameTooltip")
    lib.Tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    for i = 1, 5 do
        lib["TooltipTextLeft" .. i] = lib.Tooltip:CreateFontString()
        lib["TooltipTextRight" .. i] = lib.Tooltip:CreateFontString()
        lib.Tooltip:AddFontStrings(lib["TooltipTextLeft" .. i], lib["TooltipTextRight" .. i])
    end
end


-------------------------------
-- Embed CallbackHandler-1.0 --
-------------------------------

lib.Callbacks = LibStub("CallbackHandler-1.0"):New(lib)

-----------------
-- Static Data --
-----------------

-- Cache of spells and shield sizes
local SpellCache = {}

local bubHamID = 64413 -- since have no "i have to compensate for something"-legendary bubble hammer ;)
-- bubHamID = 47930       -- I use grace as "proc" aura for testing purposes instead...

local Shields = {
    --Protection of Ancient Kings
    [GetSpellInfo(bubHamID)] = {
        name = GetSpellInfo(bubHamID),
        duration = 8,
        order = 8,
    },
    --Power World: Shield
    [GetSpellInfo(17)] = {
        name = GetSpellInfo(17),
        duration = 30,
        order = 30,
        minAmount = {
            [12] = 1265,
            [13] = 1920,
            [14] = 2230,
        },
    },
    --Divine Aegis
    [GetSpellInfo(47753)] = {
        name = GetSpellInfo(47753),
        duration = 12,
        order = 12,
    },
    --Ice Barrier
    [GetSpellInfo(13031)] = {
        name = GetSpellInfo(13031),
        duration = 60,
        order = 100,
        minAmount = {
            [6] = 1075,
            [7] = 2800,
            [8] = 3300,
        },
    },
    --Mana Shield
    [GetSpellInfo(10193)] = {
        name = GetSpellInfo(10193),
        duration = 60,
        order = 150,
        minAmount = {
            [7] = 715,
            [8] = 1080,
            [9] = 1330,
        }
    },
    --Fire Ward
    [GetSpellInfo(43010)] = {
        name = GetSpellInfo(43010),
        duration = 30,
        order = 0,
        school = 0x04, --fire
        minAmount = {
            [6] = 1125,
            [7] = 1950,
        }
    },
    --Frost Ward
    [GetSpellInfo(6143)] = {
        name = GetSpellInfo(6143),
        duration = 30,
        order = 0,
        school = 0x10, --frost
        minAmount = {
            [6] = 1125,
            [7] = 1950,
        }
    },
    --Hand of protection
    [GetSpellInfo(5599)] = {
        name = GetSpellInfo(5599),
        duration = 8,
        order = 0,
        school = 0x01, --physical
    },

    --Fell blossom 28527
    [28527] = {
        name = GetSpellInfo(28527),
        duration = 15,
        order = 15,
        minAmount = 750,
    },
    --Sonic Shield 55019
    [55019] = {
        name = GetSpellInfo(55019),
        duration = 15,
        order = 15,
        minAmount = 750,
    },
    --Sacrifice 27273
    [GetSpellInfo(27273)] = {
        name = GetSpellInfo(27273),
        duration = 30,
        order = 30,
        minAmount = {
            [7] = 2855,
            [8] = 6750,
            [9] = 8350,
        },
    },
    --Lesser ward of shielding 29674
    [29674] = {
        name = GetSpellInfo(29674),
        duration = 99999,
        order = 60,
        minAmount = 1000,
    },
    --Greater ward of shielding 29719
    [29719] = {
        name = GetSpellInfo(29719),
        duration = 99999,
        order = 60,
        minAmount = 4000,
    },
    --Major Holy Protection Potion 28538
    [28538] = {
        name = GetSpellInfo(28538),
        duration = 120,
        order = 0,
        school = 0x02,
        minAmount = 2800,
    },
    --Major Shadow Protection Potion 28537
    [28537] = {
        name = GetSpellInfo(28537),
        id = 28537,
        duration = 120,
        order = 0,
        school = 0x20,
        minAmount = 2800,
    },
    --Major Arcane Protection Potion 28536
    [28536] = {
        name = GetSpellInfo(28536),
        duration = 120,
        order = 0,
        school = 0x40,
        minAmount = 2800,
    },
    --Major Frost Protection Potion 28512
    [28512] = {
        name = GetSpellInfo(28512),
        duration = 120,
        order = 0,
        school = 0x10,
        minAmount = 2800,
    },
    --Major Nature Protection Potion 28513
    [28513] = {
        name = GetSpellInfo(28513),
        duration = 120,
        order = 0,
        school = 0x08,
        minAmount = 2800,
    },
    --Major Fire Protection Potion 28511
    [28511] = {
        name = GetSpellInfo(28511),
        duration = 120,
        order = 0,
        school = 0x04,
        minAmount = 2800,
    },

    --Mighty Shadow Protection Potion 53915
    [53915] = {
        name = GetSpellInfo(53915),
        id = 53915,
        duration = 120,
        order = 0,
        school = 0x20,
        minAmount = 4200,
    },
    --Mighty Arcane Protection Potion 53910
    [53910] = {
        name = GetSpellInfo(53910),
        duration = 120,
        order = 0,
        school = 0x40,
        minAmount = 4200,
    },
    --Mighty Frost Protection Potion 53913
    [53913] = {
        name = GetSpellInfo(53913),
        duration = 120,
        order = 0,
        school = 0x10,
        minAmount = 4200,
    },
    --Mighty Nature Protection Potion 53914
    [53914] = {
        name = GetSpellInfo(53914),
        duration = 120,
        order = 0,
        school = 0x08,
        minAmount = 4200,
    },
    --Mighty Fire Protection Potion 53911
    [53911] = {
        name = GetSpellInfo(53911),
        duration = 120,
        order = 0,
        school = 0x04,
        minAmount = 4200,
    },

    --Darkmoon Card: Illusion 57350
    [GetSpellInfo(57350)] = {
        name = GetSpellInfo(57350),
        duration = 6,
        order = 6,
        minAmount = 400,
    },

    --Sacred Shield
    [58597] = {
        id = 58597,
        name = GetSpellInfo(58597),
        duration = 6,
        order = 6,
        minAmount = 500,
    },
    --Shadow ward 6229
    [GetSpellInfo(6229)] = {
        name = GetSpellInfo(6229),
        duration = 30,
        order = 0,
        school = 0x20,
        minAmount = {
            [4] = 875,
            [5] = 2750,
            [6] = 3300,
        },
    },
    --Hardened Skin 71586
    [GetSpellInfo(71586)] = {
        name = GetSpellInfo(71586),
        duration = 10,
        order = 10,
        minAmount = 6400,
    },

--[[
    --Astral shift 52179
    [GetSpellInfo(52179)] = {
        name = GetSpellInfo(52179),
        order = 1,
        percentAbsorbed = 0.3,
    },
    --Anti-magic shell 48707
    [GetSpellInfo(48707)] = {
        name = GetSpellInfo(48707),
        order = 2,
        duration = 5,
        percentAbsorbed = 0.75,
    },
    --Anti-magic zone 51052
    [GetSpellInfo(51052)] = {
        name = GetSpellInfo(51052),
        order = 2,
        percentAbsorbed = 0.75,
    },
]]
}

local AbsorbBuffs = {
    [73762] = 1.05, --strength of wrynn 5%
    [73824] = 1.1,  --strength of wrynn 10%
    [73825] = 1.15,  --strength of wrynn 15%
    [73826] = 1.2,  --strength of wrynn 20%
    [73827] = 1.25,  --strength of wrynn 25%
    [73828] = 1.3,  --strength of wrynn 30%

    [73816] = 1.05, --hellscream's warsong 5%    ... idiot apostrophe? seriously blizz?
    [73818] = 1.1,  --hellscream's warsong 10%
    [73819] = 1.15,  --hellscream's warsong 15%
    [73820] = 1.2,  --hellscream's warsong 20%
    [73821] = 1.25,  --hellscream's warsong 25%
    [73822] = 1.3,  --hellscream's warsong 30%

    --[72968] = 2, -- precious's ribbon (testing buff)
}

local ActiveAbsorbBuffs = {}

local EventParse =
{

}

-- active Shields
local unitData = {}

local currentTimestamp = 0
local timeGone = 0
local aegisTolerance = 1.2
--lib.debugging = 0

---------------------------------
-- Frequently Accessed Globals --
---------------------------------
local bit_band = _G.bit.band


---------------
-- Utilities --
---------------

function getShieldData(spellName, spellId)

    local shield = Shields[spellId]
    return shield or Shields[spellName]
end

local function unitFullName(unit)
    local name, realm = UnitName(unit)
    if (realm and realm ~= "") then
        return name .. "-" .. realm
    else
        return name
    end
end

-- Spellbook Scanner --
local function getBaseShieldSize(name)

    -- Check if info is already cached
    if (SpellCache[name]) then
        return SpellCache[name]
    end

    SpellCache[name] = {}

    -- Gather info (only done if not in cache)
    local i = 1

    while true do

        local spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)

        if (not spellName) then
            break
        end

        if (spellName == name) then
            -- This is the spell we're looking for, gather info

            -- Determine rank
            spellRank = tonumber(spellRank:match("(%d+)"))
            lib.Tooltip:SetSpell(i, BOOKTYPE_SPELL)

            -- Determine absorb
            local shieldSize = select(3, string.find(lib.TooltipTextLeft5:GetText() or lib.TooltipTextLeft4:GetText() or "", "[(absorb)]+.-(%d+).-[(damage)(Schaden)]+"))

            SpellCache[spellName][spellRank] = shieldSize
        end
        i = i + 1
    end

    return SpellCache[name]
end


-- Detects if a buff is present on the unit and returns the application number
local function detectBuff(unit, buffName)
    local idTable = {}
    local buffID = 1
    local name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitBuff(unit, buffID)

    while name do
        if name == buffName then
            tinsert(idTable, buffID)
        end
        buffID = buffID + 1
        name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitBuff(unit, buffID)
    end

    return idTable
end

local function isInPartyOrRaidOrMe(unitFlags)
    return  bit_band(unitFlags, COMBATLOG_OBJECT_AFFILIATION_RAID) == COMBATLOG_OBJECT_AFFILIATION_RAID or
            bit_band(unitFlags, COMBATLOG_OBJECT_AFFILIATION_PARTY) == COMBATLOG_OBJECT_AFFILIATION_PARTY or
            bit_band(unitFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE
end


--function lsl_debug(msg, level)
--    if (level or 0) <= (lib.debugging or -1) then
--        --print(msg)
--    end
--end

-----------------------------
-- Unit Data Management --
-----------------------------

local function getUnitData(unitGUID, dontCreate)
    local data = unitData[unitGUID]
    if not data and not dontCreate then
        data = {}
        unitData[unitGUID] = data
    end

    return data
end

local function getUnitActiveShields(unitGUID, dontCreate)
    local data = getUnitData(unitGUID, dontCreate)

    if not data then return end

    local activeShields = data.activeShields

    if not activeShields and not dontCreate then
        activeShields = {amount = 0, count = 0}
        data.activeShields = activeShields
    end

    return activeShields
end

----------------------
-- Public Functions --
----------------------

function lib:SetAegisTolerance(tolerance)
    --lsl_debug(tolerance)
    if tolerance then
        aegisTolerance = tolerance
    end
end

--------------------
-- Class Specific --
--------------------

local ClassSpecific = nil


-- Priest --

if (playerClass == "PRIEST") then
    ClassSpecific = {}

    local PWShield = GetSpellInfo(17)
    local DivineAegis = GetSpellInfo(47753)
    local HammerBubble = GetSpellInfo(bubHamID)
    local NoDAHeal = {
    }

    ClassSpecific.Heal = function (lib, timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellName, spellSchool, amount, overhealing, absorb, critical)
        if not srcName then
            error("Error: Got a heal ("..spellName..") withouth source on "..dstName)
            return
        end

        --if absorb and absorb > 0 then
        --    print ("Absorbed: "..absorb)
        --end

        local data = getUnitData(dstGUID)

        if srcName ~= playerName then
            return
        end

        timeGone = timestamp - currentTimestamp
        currentTimestamp = timestamp

        if data.lastHealTime and data.lastHamBub then
            local critBeforeHamBub = data.lastHamBub - data.lastHealTime
            local critAfterHamBub = currentTimestamp - data.lastHamBub

            data.lastHealAmount = amount
            data.lastHealTime = currentTimestamp
            data.lastHeal = nil
            --check if the crit after the aegis proc is way nearer than the crit before it
            if critAfterHamBub <= aegisTolerance * 0.5 and critAfterHamBub < 0.5 * critBeforeHamBub then
                --lsl_debug("Crit short after hammer bubble, updating.")
                lib:RefreshShield(Shields[HammerBubble], dstGUID, unitFullName(dstName))
            end
        else
            data.lastHealAmount = amount
            data.lastHealTime = currentTimestamp
        end

        if critical and not NoDAHeal[spellId] then
            --lsl_debug(timeGone..": Crit Heal")
            local data = getUnitData(dstGUID)

            if data.lastCritTime and data.lastAegis then
                local critBeforeAegis = data.lastAegis - data.lastCritTime
                local critAfterAegis = currentTimestamp - data.lastAegis

                data.lastCritAmount = amount
                data.lastCritTime = currentTimestamp
                data.lastAegis = nil
                --check if the crit after the aegis proc is way nearer than the crit before it
                if critAfterAegis <= aegisTolerance * 0.5 and critAfterAegis < 0.5 * critBeforeAegis then
                    --lsl_debug("Crit short after aegis, updating.")
                    lib:RefreshShield(Shields[DivineAegis], dstGUID, unitFullName(dstName))
                end
            else
                data.lastCritAmount = amount
                data.lastCritTime = currentTimestamp
            end
        end
    end

    EventParse["SPELL_HEAL"] = ClassSpecific.Heal
    EventParse["SPELL_PERIODIC_HEAL"] = ClassSpecific.Heal
    EventParse["SPELL_BUILDING_HEAL"] = ClassSpecific.Heal
    EventParse["RANGE_HEAL"] = ClassSpecific.Heal

    ClassSpecific.GetDurationForShield = function(shieldData, target)
        return shieldData.duration
    end

    ClassSpecific.GatherShieldData = function(shield, shieldData, tgtGUID, target, rank, duration, count)

        if shieldData == Shields[PWShield] then
            local base = getBaseShieldSize(shieldData.name)[rank]
            if not base then
                --lsl_debug("Error: Could not find base shield size for "..shieldData.name)
                return lib:DefaultShieldData(shieldData, rank, duration, count)
            end

            local bonus = GetSpellBonusHealing();

            -- Twin disciplines - increases heal/dmg of instants by 1/2/3/4/5%
            local _, _, _, _, talentTwinDisc = GetTalentInfo(1,2);
            talentTwinDisc = talentTwinDisc * 0.01

            -- Borrowed Time - increases absorbed value by 8/16/24/32/40% of spell power
            local _, _, _, _, talentBrwdTime = GetTalentInfo(1,27);
            talentBrwdTime = talentBrwdTime * 0.08

            -- Improved Power word: Shield - increases absorbed value by 5/10/15%
            local _, _, _, _, talentImprShield = GetTalentInfo(1,9);
            talentImprShield = 1 + talentImprShield * 0.05

            -- Focused Power: - increases heal/dmg by 2/4%
            local _, _, _, _, talentFocusedPower = GetTalentInfo(1,16);
            talentFocusedPower = talentFocusedPower * 0.02

            -- Absorbbuffs (wryn and hellscream)
            local absorbBuff = 1
            for id, factor in pairs(ActiveAbsorbBuffs) do
                absorbBuff = absorbBuff * factor
            end

            --print("base: "..base.." TD: "..talentTwinDisc.." BT: "..talentBrwdTime.." IS: "..talentImprShield.." FP: "..talentFocusedPower)

            return floor((base / talentImprShield + bonus * (1.5/3.5*1.883 + talentBrwdTime))
                    * (1+talentTwinDisc+talentFocusedPower))
                    * absorbBuff * talentImprShield

        elseif shieldData == Shields[DivineAegis] then
            local data = getUnitData(tgtGUID)

            --in can happen that the crit heal message comes after the aegis message
            --this value is used at the next crit to check if this had happened
            data.lastAegis = currentTimestamp

            if not data.lastCritTime or currentTimestamp - data.lastCritTime > aegisTolerance then
                --lsl_debug("No crit before aegis "..(data.lastCritTime or "nil").." - "..currentTimestamp.." tol:"..aegisTolerance)
                return lib:DefaultShieldData(shieldData, rank, duration, count)
            end

            -- Divine Aegis - adds an aegis which absorbes 10/20/30% of last crit heal
            local _, _, _, _, talentDivAegis = GetTalentInfo(1,24);
            if not talentDivAegis or talentDivAegis == 0 then
                --print("Error: Aegis of player although he doesn't have skilled it. Please report this error to addon author.")
                return lib:DefaultShieldData(shieldData, rank, duration, count)
            end

            local unitLevel = (UnitLevel(target)) or UnitLevel("player")

            return min(unitLevel * 125, (shield.amountLeft or 0) + data.lastCritAmount * talentDivAegis * 0.1), duration

        elseif shieldData == Shields[HammerBubble] then
            local data = getUnitData(tgtGUID)

            --in can happen that the heal message comes after the bubble message
            --this value is used at the next crit to check if this had happened
            data.lastHamBub = currentTimestamp

            if not data.lastHealTime or currentTimestamp - data.lastHealTime > aegisTolerance then
                --lsl_debug("No heal before hammer bubble "..(data.lastHealTime or "nil").." - "..currentTimestamp.." tol:"..aegisTolerance)
                return lib:DefaultShieldData(shieldData, rank, duration, count)
            end

            -- Protection of Ancient Kings - adds a hammer bubble which absorbes 15% of last crit heal
            local unitLevel = (UnitLevel(target)) or UnitLevel("player")

            return min(unitLevel * 125, (shield.amountLeft or 0) + data.lastHealAmount * 0.15), duration

        else
            --print("Error: Not handled shield("..shieldData.name.."! Please report this error to addon author.")
            return lib:DefaultShieldData(shieldData, rank, duration, count)
        end
    end
end

function lib:DefaultShieldData(shieldData, rank, duration, count)
    if not shieldData.minAmount then
        return 0, duration
    end

    if type(shieldData.minAmount) == "table" then
        return shieldData.minAmount[rank] or 0, duration
    else
        return shieldData.minAmount, duration
    end
end

local function printBuffs(unitName)
    local buffID = 1
    local name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitBuff(unitName, buffID)

    while buffID < 40 do
        if name then
            --print(name)
        end
        buffID = buffID + 1
        name, rank, icon, count, debuffType, duration, expirationTime, isMine, isStealable = UnitBuff(unitName, buffID)
    end
end

function lib:GatherShieldData(shield, shieldData, tgtGUID, target)
    local name, rank, icon, count, debuffType, duration, expirationTime, owner, isStealable = UnitBuff(target, shieldData.name)

    if not name then
        --print("Warning: Could not find "..shieldData.name.." as aura on unit "..target)
        --printBuffs(target)
        return false, 0, 0
    end

    local isMine = (owner and UnitIsUnit("player", owner))

    rank = tonumber(rank:match("(%d+)"))

    if isMine and ClassSpecific then
        return true, ClassSpecific.GatherShieldData(shield, shieldData, tgtGUID, target, rank, duration, count)
    else
        return isMine, self:DefaultShieldData(shieldData, rank, duration, count)
    end
end

function lib:RemoveShieldFromList(shieldData, list)
    local shield = list.first

    if not shield then
        return
    end

    if shield.data == shieldData then --shield to be removed is first
        list.first = shield.next

    else
        --find predecessor of the shield to be removed
        while shield.next and shield.next.data ~= shieldData and shield.next.data.order <= shieldData.order do
            shield = shield.next
        end

        if not shield.next or shield.next.data ~= shieldData then --shield not in list
            return
        end

        --remove shield from list
        local buff = shield.next
        shield.next = buff.next
        shield = buff
    end

    return shield
end

function lib:GetShieldFromList(shieldData, list)
    --get head of shield list
    local shield = list.first

    if not shield  or shield.data.order > shieldData.order then --shield list is empty or our new entry is smallest, add new shield as first
       return nil
    else --otherwise find position to insert new shieldData entry
        while shield.data ~= shieldData and shield.next and shield.data.order <= shieldData.order do
            shield = shield.next
        end

        if shield.data ~= shieldData then
            return nil
        end
    end

    return shield
end

function lib:NewShieldToList(shieldData, list)
    local shield = list.first

    if not shield  or shield.data.order > shieldData.order then --shield list is empty or our new entry is smallest, add new shield as first
        shield = {data = shieldData} --create new entry
        shield.next = list.first --set current first as next of new entry
        list.first = shield --new entry becomes new current first
    else --otherwise find position to insert new shieldData entry
        while shield.data ~= shieldData and shield.next and shield.data.order <= shieldData.order do
            shield = shield.next
        end

        if shield.data ~= shieldData then
            local buff = shield.next --buffer successor
            shield.next = {data = shieldData} --create new entry as successor
            shield = shield.next --go to new entry
            shield.next = buff --set buffer as next of new entry
        else
            return shield, true
        end
    end

    return shield
end

function lib:CheckShields(unitGUID, source, name)
    local activeShields = getUnitActiveShields(unitGUID, true)
    if not activeShields then
        return
    end

    --get head of shield list
    local shield = activeShields.first
    local amount = 0
    local count = 0
    while shield do
        if not shield.removedAt then
            count = count + 1
            if shield.amountLeft > 0 then
                amount = amount + max(shield.amountLeft, 0)
            end
        end
        shield = shield.next
    end

    if abs(amount - activeShields.amount) > 0.1 or count ~= activeShields.count then
        self.debugging = 1
        --print("Difference on "..(name or "").." from "..source..": "..(amount - activeShields.amount))
        --print("Countdiff: "..(count - activeShields.count))
        self:PrintShields(unitGUID)
        self.debugging = -1
    end
end

function lib:PrintShields(unitGUID)
    local activeShields = getUnitActiveShields(unitGUID, true)
    if not activeShields then
        --lsl_debug("no active shields", 1)
        return
    end

    --get head of shield list
    local shield = activeShields.first
    --lsl_debug(activeShields.count.." shields with "..activeShields.amount, 1)
    while shield do
        --lsl_debug(shield.data.name.." - L:["..shield.amountLeft.."] R:["..(shield.removedAt or 0).."]", 1)
        shield = shield.next
    end
end

function lib:NewShield(shieldData, unitGUID, unitName)
    --lsl_debug("-------New shield "..shieldData.name.." on "..unitName.."-------",1)
    self:PrintShields(unitGUID)
    --lsl_debug(timeGone..": New shield("..shieldData.name..") on "..unitName)
    --get active shields of the unit
    self:CheckShields(unitGUID, "new-pre", unitName)
    local activeShields = getUnitActiveShields(unitGUID)

    local shield, wasInList = self:NewShieldToList(shieldData, activeShields)


    if wasInList then
        if shield.removedAt then
            shield.removedAt = nil
            activeShields.count = activeShields.count + 1
        else
            --error("Error: New shield "..shieldData.name.." already in list")
            --self.debugging = 1
            --print("Error: New shield "..shieldData.name.." already in list")
            --self:PrintShields(unitGUID)
            --self.debugging = -1

            if shield.amountLeft and shield.amountLeft > 0 then
                activeShields.amount = activeShields.amount - shield.amountLeft
            end
        end
    else
        activeShields.count = activeShields.count + 1
    end
    shield.amountLeft = 0
    shield.isMine, shield.amountLeft, shield.expTime = self:GatherShieldData(shield, shieldData, unitGUID, unitName)
    --lsl_debug(shield.amountLeft)
    if shield.amountLeft > 0 then
        activeShields.amount = (activeShields.amount or 0) + shield.amountLeft
    end

    self.Callbacks:Fire("ShieldLeft_NewShield", unitGUID, unitName, shieldData.name, shield.amountLeft, activeShields.amount, activeShields.count)
    self:PrintShields(unitGUID)

    self:CheckShields(unitGUID, "NewShield")
end

function lib:RefreshShield(shieldData, unitGUID, unitName, expTime)
    --lsl_debug("-------Refresh shield "..shieldData.name.." on "..unitName.."-------",1)
    self:PrintShields(unitGUID)
    --lsl_debug(timeGone..": Refresh shield("..shieldData.name..") on "..unitName)

    self:CheckShields(unitGUID, "Refresh-pre", unitName)

    --get active shields of the unit
    local activeShields = getUnitActiveShields(unitGUID)

    --get head of shield list
    local shield = self:GetShieldFromList(shieldData, activeShields)

    if not shield or shield.removedAt then
        --print("Error: Refreshed shield not in list")
        if not shield then
            shield = self:NewShieldToList(shieldData, activeShields)
        end
        shield.amountLeft = 0
        shield.expTime = 0
        shield.removedAt = nil
        activeShields.count = activeShields.count + 1
    end

    local newAmount
    shield.isMine, newAmount, shield.expTime, additive = self:GatherShieldData(shield, shieldData, unitGUID, unitName, true)
    --lsl_debug(newAmount)
    if newAmount > 0 then
        if additive then
            activeShields.amount = (activeShields.amount or 0) + newAmount
            shield.amountLeft = (shield.amountLeft or 0) + newAmount
        else
            activeShields.amount = activeShields.amount + (newAmount - max(shield.amountLeft,0))
            shield.amountLeft = newAmount
        end
    end
    self.Callbacks:Fire("ShieldLeft_RefreshShield", unitGUID, unitName, shieldData.name, shield.amountLeft, activeShields.amount, activeShields.count)
    self:PrintShields(unitGUID)

    self:CheckShields(unitGUID, "RefreshShield")
end

function lib:RemoveShield(shieldData, unitGUID, unitName)
    --lsl_debug("-------Remove shield "..shieldData.name.." on "..unitName.."-------",1)
    self:PrintShields(unitGUID)
    --lsl_debug(timeGone..": Remove shield("..shieldData.name..") on "..unitName)
    --get active shields of the unit
    local activeShields = getUnitActiveShields(unitGUID, true)
    if not activeShields then
        return
    end

    self:CheckShields(unitGUID, "Remove-pre", unitName)

    local shield = self:GetShieldFromList(shieldData, activeShields)

    if not shield or shield.removedAt then  --shield was not in list
        --error("Error: Removed shield "..shieldData.name.." was not in list.")
        --self.debugging = 1
        --print("Error: Removed shield "..shieldData.name.." was not in list.")
        --self:PrintShields(unitGUID)
        --self.debugging = -1
        return
    end

    --lsl_debug("Shield gone with "..shield.amountLeft.." left.")
    if shield.amountLeft <= 0 then
        self:RemoveShieldFromList(shieldData, activeShields)
        activeShields.count = activeShields.count - 1
        --a negative amount left means the shield has absorbed more than it could (or we expect)
        --if the last hit just happened we transfer this amount as damage to the next shield
        if shield.amountLeft < 0 then
            if currentTimestamp - getUnitData(unitGUID).lastAbsorb < 1 then
                --lsl_debug("Forwarding damage to next shield")
                self:UnitAbsorbed(unitGUID, unitName, -shield.amountLeft, shield.data.school or 0x01)
            end
        end
    else
        --a positive amount left means the shield has absorbed less than it could (or we expected)
        --this could happen because the actual absorb message of the damage which destroyed this shield
        --comes short after this message. For this case we keep the shield as inactive in the list
        --and if the next absorb message is short enough after the remove of this shield we will
        --assume the shield absorbed that value too
        --In any case we will remove any inactive shield on the next absorb
        shield.removedAt = currentTimestamp
        activeShields.count = activeShields.count - 1

        --since we don't know if in the next milliseconds comes the actual absorb message which destroys this
        --shield we have to assume the amount left lost
        activeShields.amount = activeShields.amount - shield.amountLeft
    end


    self.Callbacks:Fire("ShieldLeft_RemoveShield", unitGUID, unitName, shieldData.name, shield.amountLeft, activeShields.amount, activeShields.count)

    self:PrintShields(unitGUID)

    self:CheckShields(unitGUID, "RemoveShield")
end

function lib:UnitAbsorbed(unitGUID, unitName, amount, school, partly)
    --lsl_debug("-------Remove shield "..shieldData.name.." on "..unitName.."-------",1)
    --self:PrintShields(unitGUID)

    --lsl_debug(timeGone..": Absorb on "..unitName.." for "..amount)
    --get active shields of the unit
    local activeShields = getUnitActiveShields(unitGUID, true)
    if not activeShields then
        --print("no active shield")
        return
    end

    --get head of shield list
    local shield = activeShields.first
    local prev = activeShields

    self:CheckShields(unitGUID, "UnitAbsorbed-pre", unitName)

    while shield do
        if amount > 0 and (not shield.data.school or shield.data.school == school) then
            amount = self:AbsorbFromShield(activeShields, shield, unitGUID, unitName, amount, school, partly)
        end

        --we remove any already removed shields when an absorb occurs, they had the chance to
        if shield.removedAt then --absorb there last remaining amount in the lines above
            if prev == activeShields then
                prev.first = shield.next
            else
                prev.next = shield.next
            end
            self:CheckShields(unitGUID, "UnitAbsorbed-remove removedAt")
        else
            prev = shield
        end
        shield = shield.next
    end

    getUnitData(unitGUID).lastAbsorb = currentTimestamp
    --self:PrintShields(unitGUID)
    self:CheckShields(unitGUID, "UnitAbsorbed", unitName)
end

function lib:AbsorbFromShield(activeShields, shield, unitGUID, unitName, amount, school, partly)
    self:CheckShields(unitGUID, "AbsorbedFrom-pre", unitName)
    --lsl_debug("Absorb shield("..shield.data.name..") on "..unitName.." for "..amount)
     --is this shield already removed
    if shield.removedAt then
        --lsl_debug("Shield is already removed...")
        local absorbed = 0
        --if the shield was removed short before we will assume that it also absorbed the the
        --current absorb (because an absorb message which removed a shield can happen after
        --the remove message of the shield)
        if currentTimestamp - shield.removedAt < 0.5 then
            absorbed = min(shield.amountLeft, amount)
            --lsl_debug("...but not long ago -> absorbed "..absorbed)
            self.Callbacks:Fire("ShieldLeft_ShieldAbsorbed", currentTimestamp, unitGUID, unitName, shield.data.name, shield.isMine, absorbed, amount - absorbed + (partly or 0))
        end

        self:CheckShields(unitGUID, "RemovedShieldAbsorbed")
        return amount - absorbed
    end

    local time = currentTimestamp

    if shield.amountLeft > amount then
        self.Callbacks:Fire("ShieldLeft_ShieldAbsorbed", currentTimestamp, unitGUID, unitName, shield.data.name, shield.isMine, amount, partly)
    else
        local absorbed = max(shield.amountLeft, 0)
        self.Callbacks:Fire("ShieldLeft_ShieldAbsorbed", currentTimestamp, unitGUID, unitName, shield.data.name, shield.isMine, absorbed, amount - absorbed + (partly or 0))
    end

    --an negative amount left ist transfered as damage to the next shield
    --when this shield is removed but maximum the amount of the last hit
    if shield.amountLeft > 0 then
        shield.amountLeft = shield.amountLeft - amount
        activeShields.amount = activeShields.amount - (amount + min(shield.amountLeft,0))
    else
        shield.amountLeft = -amount
    end

    self.Callbacks:Fire("ShieldLeft_UpdateShield", unitGUID, unitName, shield.data.name, shield.amountLeft, activeShields.amount, activeShields.count)

    self:CheckShields(unitGUID, "AbsorbFromShield")
    return 0
end

function lib:CaptureRunningShields()
    if GetNumRaidMembers() > 0 then
        for id = 1, GetNumRaidMembers() do
            local unitid = "raid"..id
            local name = UnitName(unitid)
            if name then
                self:CaptureUnitsRunningShields(UnitGUID(unitid), name)
            end
        end
    elseif GetNumPartyMembers() > 0 then
        for id = 1, GetNumPartyMembers() do
            local unitid = "party"..id
            local name = UnitName(unitid)
            if name then
                self:CaptureUnitsRunningShields(UnitGUID(unitid), name)
            end
        end
    end
    self:CaptureUnitsRunningShields(UnitGUID("player"), playerName)
end

function lib:CaptureUnitsRunningShields(unitGUID, unitName)
    --lsl_debug("Capturing shields on "..unitName)
    local fullName = unitFullName(unitName)
    if not fullName then
        --lsl_debug("Error: Could not get full name for unit:"..unitName)
        return
    end

    --if getUnitData(fullName, true) then --dont capture for units we already know
    --    return
    --end

    local activeShields = getUnitActiveShields(unitGUID, true)

    local buffID = 1
    local name, rank, icon, count, debuffType, duration, expirationTime, owner, isStealable = UnitBuff(unitName, buffID)
    --Iterate through active auras and check for active shields
    while name do
        local isMine = (owner and UnitIsUnit("player", owner))
        --lsl_debug("Found aura "..name)
        local shieldData = getShieldData(name)
        if shieldData then
            --lsl_debug("Is shield aura "..shieldData.name)

            --if we have shield data stored for this unit...
            if activeShields then

                local shield = self:GetShieldFromList(shieldData, activeShields)
                if not shield or shield.removedAt then
                    --lsl_debug("New shield "..shieldData.name.." after zone switch.")
                    self:NewShield(shieldData, unitGUID, fullName)
                    shield = self:GetShieldFromList(shieldData, activeShields)
                    assert(shield, "Shield should exist after call to NewShield")
                else
                    --lsl_debug("Already in list")
                end

                shield.stillActive = true --mark this shield as still active we will remove all shields later which haven't been marked
            else
                --lsl_debug("New shield "..shieldData.name.." after zone switch.")
                self:NewShield(shieldData, unitGUID, fullName)
            end
        end
        buffID = buffID + 1
        name, rank, icon, count, debuffType, duration, expirationTime, owner, isStealable = UnitBuff(unitName, buffID)
    end

    if activeShields then
        local shield = activeShields.first

        --iterate through shields stored and removed which are not marked as still active
        while shield do
            local tmp = shield      --we need to get the pointer to the next shield
            shield = shield.next    --before we remove it from the list

            if not tmp.stillActive and not tmp.removedAt then
                --lsl_debug("Shield "..tmp.data.name.." run out during zone switch.",-1)
                self:RemoveShield(tmp.data, unitGUID, fullName)
            end

            if tmp.removedAt then   --remove shields from list which are marked already removed even or especially
                --lsl_debug("Shield "..tmp.data.name.." run out during zone switch- already.",-1)
                self:RemoveShieldFromList(tmp.data, activeShields) --if it has been removed in this method
            end

            tmp.stillActive = nil
        end
    end

    self:CheckShields(unitGUID, "CaptureUnitsRunningShields")
end

--------------------
-- Event Handlers --
--------------------

function lib:OnUpdate(elpased)
    if self.checkAuras then
        if GetTalentInfo(1,1) then --check if talents are available, we hope that auras are than too
            local name = UnitName("player") --check if UnitNames are accessable by name
            if name and UnitName(name) then
                self.checkAuras = nil
                --lsl_debug("talents and name available")
                self:CaptureRunningShields()
            end
        end
    end
end

function lib:AuraApplied(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellName, spellSchool, auraType)

    local shieldData = getShieldData(spellName, spellId)
    if shieldData then
        local fullName = unitFullName(dstName)
        if not fullName then return end

        self:NewShield(shieldData, dstGUID, fullName)
    end

    if dstGUID == playerGUID then
        if AbsorbBuffs[spellId] then
            ActiveAbsorbBuffs[spellId] = AbsorbBuffs[spellId]
        end
    end
end

function lib:AuraRefresh(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellName, spellSchool, auraType)
    local shieldData = getShieldData(spellName, spellId)
    if not shieldData then return end

    local fullName = unitFullName(dstName)
    if not fullName then return end

    self:RefreshShield(shieldData, dstGUID, fullName)
end

function lib:AuraRemoved(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellName, spellSchool, auraType)

    local shieldData = getShieldData(spellName, spellId)
    if shieldData then
        local fullName = unitFullName(dstName)
        if not fullName then return end

        self:RemoveShield(shieldData, dstGUID, fullName)
    end

    if dstGUID == playerGUID then
        if AbsorbBuffs[spellId] then
            ActiveAbsorbBuffs[spellId] = nil
        end
    end
end

function lib:AuraBroken(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellName, spellSchool, auraType)
    local shieldData = getShieldData(spellName, spellId)
    if not shieldData then return end

    local fullName = unitFullName(dstName)
    if not fullName then return end

    self:RemoveShield(shieldData, dstGUID, fullName)
end

function lib:AuraBrokenSpell(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellName, spellSchool, auraType)
    local shieldData = getShieldData(spellName, spellId)
    if not shieldData then return end

    local fullName = unitFullName(dstName)
    if not fullName then return end

    self:RemoveShield(shieldData, dstGUID, fullName, true)
end

function lib:SwingDamage(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, amount, overkill, school, resisted, blocked, absorbed)
    if absorbed and absorbed > 0 then
        local fullName = unitFullName(dstName)
        if not fullName then return end

        self:UnitAbsorbed(dstGUID, fullName, absorbed, school, amount)
    end
end

function lib:SwingMissed(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, missType, amount)
    if missType == "ABSORB" then
        local fullName = unitFullName(dstName)
        if not fullName then return end

        self:UnitAbsorbed(dstGUID, fullName, amount, 0x01)
    end
end



function lib:SpellDamage(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed)
    if absorbed and absorbed > 0 then
        local fullName = unitFullName(dstName)
        if not fullName then return end

        self:UnitAbsorbed(dstGUID, fullName, absorbed, school, amount)
    end
end

function lib:SpellMissed(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellName, spellSchool, missType, amount)

    if missType == "ABSORB" then
        local fullName = unitFullName(dstName)
        if not fullName then return end

        self:UnitAbsorbed(dstGUID, fullName, amount, spellSchool)
    end
end

local envSchools = {

    ["FIRE"] = 0x04,
    ["LAVA"] = 0x04,
    ["SLIME"] = 0x20,
}

function lib:EnvironmentalDamage(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, environmentalType, amount, overkill, school, resisted, blocked, absorbed)
    if absorbed and absorbed > 0 then
        local fullName = unitFullName(dstName)
        if not fullName then return end

        if school then
            self:UnitAbsorbed(dstGUID, fullName, absorbed, school, amount)
        end
    end
end

function lib:EnvironmentalMissed(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, environmentalType, missType, amount)
    if missType == "ABSORB" then
        local fullName = unitFullName(dstName)
        if not fullName then return end

        local school = envSchools[environmentalType]
        if school then
            self:UnitAbsorbed(dstGUID, fullName, absorbed, school)
        end
    end
end

function lib:UnitDead(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags)

end

EventParse["SPELL_AURA_APPLIED"] = lib.AuraApplied
EventParse["SPELL_AURA_REFRESH"] = lib.AuraRefresh
EventParse["SPELL_AURA_REMOVED"] = lib.AuraRemoved
EventParse["SPELL_AURA_BROKEN"] = lib.AuraBroken
EventParse["SPELL_AURA_BROKEN_SPELL"] = lib.AuraBrokenSpell

EventParse["SWING_DAMAGE"] = lib.SwingDamage
EventParse["SWING_MISSED"] = lib.SwingMissed
EventParse["ENVIRONMENTAL_DAMAGE"] = lib.EnvironmentalDamage
EventParse["ENVIRONMENTAL_MISSED"] = lib.EnvironmentalMissed
EventParse["SPELL_DAMAGE"] = lib.SpellDamage
EventParse["SPELL_MISSED"] = lib.SpellMissed
EventParse["SPELL_PERIODIC_DAMAGE"] = lib.SpellDamage
EventParse["SPELL_PERIODIC_MISSED"] = lib.SpellMissed
EventParse["SPELL_BUILDING_DAMAGE"] = lib.SpellDamage
EventParse["SPELL_BUILDING_MISSED"] = lib.SpellMissed
EventParse["RANGE_DAMAGE"] = lib.SpellDamage
EventParse["RANGE_MISSED"] = lib.SpellMissed

function lib:COMBAT_LOG_EVENT_UNFILTERED(timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
    if self.checkAuras or not (isInPartyOrRaidOrMe(dstFlags)) then
        return
    end
	local parsefunc = EventParse[eventtype]

    --print("Event: "..eventtype)
	if parsefunc then
        timeGone = timestamp - currentTimestamp
        currentTimestamp = timestamp
		parsefunc(self, timestamp, eventtype, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, ...)
	end
end

function lib:LEARNED_SPELL_IN_TAB()
    -- Invalidate cached spell data when learning new spells
    SpellCache = {};
end

function lib:PLAYER_ENTERING_WORLD()
    --self.checkAuras = true
end

function lib:PARTY_MEMBERS_CHANGED()
    --self.checkAuras = true
end

function lib:RAID_ROSTER_UPDATE()
    --self.checkAuras = true
end



---API-------------------------------------------
function lib:KnownShields()
    return Shields;
end

function lib:IsShield(name, id)
    local shield = getShieldData(name, id)
    if not shield then return false end
    if shield.id then return shield.id end
    return true
end

function lib:GetActiveShield(guid, name)
    local activeShields = getUnitActiveShields(guid)

    local current = activeShields.first

    while current do
        if not current.removedAt and current.data.name == name then
            return current
        end
        current = current.next
    end
end

function lib:GetActiveShields(guid, all)
    local activeShields = getUnitActiveShields(guid, false)

    local shields = {}
    local current = activeShields.first

    while current do
        if all or not current.removedAt then
            tinsert(shields, current)
        end
        current = current.next
    end

    return shields
end
