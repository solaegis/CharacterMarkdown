-- Luacheck configuration for CharacterMarkdown
-- Ignore empty if branch warnings for intentionally empty conditional blocks

std = "lua51"

ignore = {
    "212", -- empty if branch
}

-- Allow specific globals that are ESO API functions
globals = {
    "GetWorldName",
    "GetCurrentWorldId", 
    "GetUnitName",
    "GetUnitRace",
    "GetUnitClass",
    "GetUnitAlliance",
    "GetAllianceName",
    "GetUnitLevel",
    "GetPlayerChampionPointsEarned",
    "GetCurrentTitleIndex",
    "GetTitle",
    "IsESOPlusSubscriber",
    "GetAttributeSpentPoints",
    "GetTimeStamp",
    "GetDateStringFromTimestamp",
    "CanJumpToPlayerInZone",
    "GetDisplayName",
    "GetNumAchievements",
    "GetAchievementInfo",
    "ATTRIBUTE_MAGICKA",
    "ATTRIBUTE_HEALTH", 
    "ATTRIBUTE_STAMINA",
    "CharacterMarkdownSettings",
    "CharacterMarkdownData"
}