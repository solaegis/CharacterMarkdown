-- CharacterMarkdown - Stats Utilities
-- Safe stat retrieval with error handling

local CM = CharacterMarkdown

-- =====================================================
-- SAFE STAT RETRIEVAL
-- =====================================================

-- Safely get player stat with default value on error
local function SafeGetPlayerStat(statType, defaultValue)
    defaultValue = defaultValue or 0
    if not statType then
        return defaultValue
    end
    local success, value = pcall(function() return GetPlayerStat(statType) end)
    if success and value then
        return value
    end
    return defaultValue
end

CM.utils.SafeGetPlayerStat = SafeGetPlayerStat
