-- CharacterMarkdown - Character Data Collector

local CM = CharacterMarkdown

-- Cached globals
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
local GetWorldName = GetWorldName -- luacheck: ignore
local GetDisplayName = GetDisplayName

local function CollectCharacterData()
    CM.DebugPrint("COLLECTOR", "Collecting character data...")
    
    local data = {}
    
    data.name = CM.SafeCall(GetUnitName, "player") or "Unknown"
    data.race = CM.SafeCall(GetUnitRace, "player") or "Unknown"
    data.class = CM.SafeCall(GetUnitClass, "player") or "Unknown"
    
    local alliance = CM.SafeCall(GetUnitAlliance, "player")
    data.alliance = alliance and CM.SafeCall(GetAllianceName, alliance) or "Unknown"
    
    data.level = CM.SafeCall(GetUnitLevel, "player") or 0
    data.cp = CM.SafeCall(GetPlayerChampionPointsEarned) or 0
    
    -- Get title (check for custom title first)
    local customTitle = ""
    if CM.charData then
        customTitle = CM.charData.customTitle or ""
    end
    
    if customTitle and customTitle ~= "" then
        data.title = customTitle
    else
        local titleIndex = CM.SafeCall(GetCurrentTitleIndex)
        data.title = (titleIndex and titleIndex > 0) and CM.SafeCall(GetTitle, titleIndex) or ""
    end
    
    data.esoPlus = CM.SafeCall(IsESOPlusSubscriber) or false
    
    -- Get server name and account name
    data.server = CM.SafeCall(GetWorldName) or "Unknown"
    data.account = CM.SafeCall(GetDisplayName) or "Unknown"
    
    data.attributes = {
        magicka = CM.SafeCall(GetAttributeSpentPoints, ATTRIBUTE_MAGICKA) or 0,
        health = CM.SafeCall(GetAttributeSpentPoints, ATTRIBUTE_HEALTH) or 0,
        stamina = CM.SafeCall(GetAttributeSpentPoints, ATTRIBUTE_STAMINA) or 0,
    }
    
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

local function CollectDLCAccess()
    CM.DebugPrint("COLLECTOR", "Collecting DLC access data...")
    
    local dlcAccess = {
        hasESOPlus = CM.SafeCall(IsESOPlusSubscriber) or false,
        accessible = {},
        locked = {}
    }
    
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
    
    if dlcAccess.hasESOPlus then
        for _, dlc in ipairs(dlcZones) do
            table.insert(dlcAccess.accessible, dlc.name)
        end
        CM.DebugPrint("COLLECTOR", "DLC access: ESO Plus (all accessible)")
        return dlcAccess
    end
    
    for _, dlc in ipairs(dlcZones) do
        local success, canJump, result = pcall(CanJumpToPlayerInZone, dlc.zoneId)
        
        if success and result then
            if result == JUMP_TO_PLAYER_RESULT_ZONE_COLLECTIBLE_LOCKED then
                table.insert(dlcAccess.locked, dlc.name)
            else
                table.insert(dlcAccess.accessible, dlc.name)
            end
        else
            CM.DebugPrint("COLLECTOR", "Failed to check DLC:", dlc.name)
            table.insert(dlcAccess.locked, dlc.name)
        end
    end
    
    CM.DebugPrint("COLLECTOR", "DLC access collected:", #dlcAccess.accessible, "accessible")
    return dlcAccess
end

CM.collectors.CollectDLCAccess = CollectDLCAccess

CM.DebugPrint("COLLECTOR", "Character collector module loaded")
