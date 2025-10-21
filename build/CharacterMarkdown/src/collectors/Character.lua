-- CharacterMarkdown - Character Data Collector
-- Basic character identity and DLC access (ESO Guideline Compliant)

local CM = CharacterMarkdown

-- =====================================================
-- CACHED GLOBALS (PERFORMANCE)
-- =====================================================

local GetUnitName = GetUnitName
local GetUnitRace = GetUnitRace
local GetUnitClass = GetUnitClass
local GetAllianceName = GetAllianceName
local GetUnitAlliance = GetUnitAlliance
local GetUnitLevel = GetUnitLevel
local GetPlayerChampionPointsEarned = GetPlayerChampionPointsEarned
local GetTitle = GetTitle
local GetCurrentTitleIndex = GetCurrentTitleIndex
local IsESOPlusSubscriber = IsESOPlusSubscriber
local GetAttributeSpentPoints = GetAttributeSpentPoints
local GetTimeStamp = GetTimeStamp
local GetDateStringFromTimestamp = GetDateStringFromTimestamp
local CanJumpToPlayerInZone = CanJumpToPlayerInZone
local pcall = pcall

-- =====================================================
-- CHARACTER DATA
-- =====================================================

local function CollectCharacterData()
    CM.DebugPrint("COLLECTOR", "Collecting character data...")
    
    local data = {}
    
    -- Basic identity (with safe calls and defaults)
    data.name = CM.SafeCall(GetUnitName, "player") or "Unknown"
    data.race = CM.SafeCall(GetUnitRace, "player") or "Unknown"
    data.class = CM.SafeCall(GetUnitClass, "player") or "Unknown"
    
    -- Alliance (nested call requires extra care)
    local alliance = CM.SafeCall(GetUnitAlliance, "player")
    if alliance then
        data.alliance = CM.SafeCall(GetAllianceName, alliance) or "Unknown"
    else
        data.alliance = "Unknown"
    end
    
    data.level = CM.SafeCall(GetUnitLevel, "player") or 0
    data.cp = CM.SafeCall(GetPlayerChampionPointsEarned) or 0
    
    -- Title (nested call)
    local titleIndex = CM.SafeCall(GetCurrentTitleIndex)
    if titleIndex and titleIndex > 0 then
        data.title = CM.SafeCall(GetTitle, titleIndex) or ""
    else
        data.title = ""
    end
    
    -- ESO Plus detection
    data.esoPlus = CM.SafeCall(IsESOPlusSubscriber) or false
    
    -- Attribute distribution
    data.attributes = {
        magicka = CM.SafeCall(GetAttributeSpentPoints, ATTRIBUTE_MAGICKA) or 0,
        health = CM.SafeCall(GetAttributeSpentPoints, ATTRIBUTE_HEALTH) or 0,
        stamina = CM.SafeCall(GetAttributeSpentPoints, ATTRIBUTE_STAMINA) or 0,
    }
    
    -- Timestamp
    local timeStamp = CM.SafeCall(GetTimeStamp)
    if timeStamp then
        local dateStr = CM.SafeCall(GetDateStringFromTimestamp, timeStamp)
        if dateStr then
            data.timestamp = dateStr
        end
    end
    
    CM.DebugPrint("COLLECTOR", "Character data collected:", data.name)
    return data
end

CM.collectors.CollectCharacterData = CollectCharacterData

-- =====================================================
-- DLC ACCESS
-- =====================================================

local function CollectDLCAccess()
    CM.DebugPrint("COLLECTOR", "Collecting DLC access data...")
    
    local dlcAccess = {
        hasESOPlus = CM.SafeCall(IsESOPlusSubscriber) or false,
        accessible = {},
        locked = {}
    }
    
    -- Major DLCs and Chapters with their zone IDs
    -- (Guideline: Use local table to avoid repeated global lookups)
    local dlcZones = {
        {name = "Morrowind (Vvardenfell)", zoneId = 849},
        {name = "Summerset", zoneId = 1011},
        {name = "Elsweyr (Northern)", zoneId = 1086},
        {name = "Greymoor (Western Skyrim)", zoneId = 1160},
        {name = "Blackwood", zoneId = 1261},
        {name = "High Isle", zoneId = 1318},
        {name = "Necrom (Telvanni Peninsula)", zoneId = 1413},
        {name = "Gold Road (West Weald)", zoneId = 1443},
        {name = "Gold Coast", zoneId = 823},
        {name = "Hew's Bane", zoneId = 816},
        {name = "Wrothgar", zoneId = 684},
        {name = "Clockwork City", zoneId = 980},
        {name = "Murkmire", zoneId = 726},
    }
    
    -- If ESO Plus, all DLCs are accessible
    if dlcAccess.hasESOPlus then
        for _, dlc in ipairs(dlcZones) do
            table.insert(dlcAccess.accessible, dlc.name)
        end
        
        CM.DebugPrint("COLLECTOR", "DLC access: ESO Plus (all accessible)")
        return dlcAccess
    end
    
    -- Check each DLC zone for accessibility (with safe calls)
    for _, dlc in ipairs(dlcZones) do
        local success, canJump, result = pcall(CanJumpToPlayerInZone, dlc.zoneId)
        
        if success and result then
            if result == JUMP_TO_PLAYER_RESULT_ZONE_COLLECTIBLE_LOCKED then
                table.insert(dlcAccess.locked, dlc.name)
            else
                table.insert(dlcAccess.accessible, dlc.name)
            end
        else
            -- If API call failed, assume locked
            CM.DebugPrint("COLLECTOR", "Failed to check DLC:", dlc.name)
            table.insert(dlcAccess.locked, dlc.name)
        end
    end
    
    CM.DebugPrint("COLLECTOR", "DLC access collected:", #dlcAccess.accessible, "accessible")
    return dlcAccess
end

CM.collectors.CollectDLCAccess = CollectDLCAccess

CM.DebugPrint("COLLECTOR", "Character collector module loaded")
