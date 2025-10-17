-- CharacterMarkdown - Character Data Collector
-- Basic character identity and DLC access

local CM = CharacterMarkdown

-- =====================================================
-- CHARACTER DATA
-- =====================================================

local function CollectCharacterData()
    local data = {}
    
    -- Basic identity
    data.name = GetUnitName("player") or "Unknown"
    data.race = GetUnitRace("player") or "Unknown"
    data.class = GetUnitClass("player") or "Unknown"
    data.alliance = GetAllianceName(GetUnitAlliance("player")) or "Unknown"
    data.level = GetUnitLevel("player") or 0
    data.cp = GetPlayerChampionPointsEarned() or 0
    data.title = GetTitle(GetCurrentTitleIndex()) or ""
    
    -- ESO Plus detection (using official API)
    data.esoPlus = IsESOPlusSubscriber() or false
    
    -- Attribute distribution
    data.attributes = {
        magicka = GetAttributeSpentPoints(ATTRIBUTE_MAGICKA) or 0,
        health = GetAttributeSpentPoints(ATTRIBUTE_HEALTH) or 0,
        stamina = GetAttributeSpentPoints(ATTRIBUTE_STAMINA) or 0,
    }
    
    -- Timestamp
    local timeStamp = GetTimeStamp()
    if timeStamp then
        local dateStr = GetDateStringFromTimestamp(timeStamp)
        if dateStr then
            data.timestamp = dateStr
        end
    end
    
    return data
end

CM.collectors.CollectCharacterData = CollectCharacterData

-- =====================================================
-- DLC ACCESS
-- =====================================================

local function CollectDLCAccess()
    local dlcAccess = {
        hasESOPlus = IsESOPlusSubscriber() or false,
        accessible = {},
        locked = {}
    }
    
    -- Major DLCs and Chapters with their zone IDs
    local dlcZones = {
        {name = "Morrowind (Vvardenfell)", zoneId = 849},
        {name = "Summerset", zoneId = 1011},
        {name = "Elsweyr (Northern)", zoneId = 1086},
        {name = "Greymoor (Western Skyrim)", zoneId = 1160},
        {name = "Blackwood", zoneId = 1261},
        {name = "High Isle", zoneId = 1318},
        {name = "Necrom (Telvanni Peninsula)", zoneId = 1413},
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
        return dlcAccess
    end
    
    -- Check each DLC zone for accessibility
    for _, dlc in ipairs(dlcZones) do
        local success, canJump, result = pcall(function()
            return CanJumpToPlayerInZone(dlc.zoneId)
        end)
        
        if success then
            if result == JUMP_TO_PLAYER_RESULT_ZONE_COLLECTIBLE_LOCKED then
                table.insert(dlcAccess.locked, dlc.name)
            else
                table.insert(dlcAccess.accessible, dlc.name)
            end
        end
    end
    
    return dlcAccess
end

CM.collectors.CollectDLCAccess = CollectDLCAccess
