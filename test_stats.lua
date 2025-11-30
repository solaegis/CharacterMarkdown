-- Temporary script to find STAT_ constants
-- Run this with /script in ESO chat

d("=== Testing STAT_ Constants ===")

-- Try common stat constant names
local statsToTest = {
    "STAT_BASH_COST",
    "STAT_BLOCK_COST", 
    "STAT_BREAK_FREE_COST",
    "STAT_DODGE_ROLL_COST",
    "STAT_SNEAK_COST",
    "STAT_SPRINT_COST",
    "STAT_BASH_DAMAGE",
    "STAT_BLOCK_MITIGATION",
    "STAT_BLOCK_SPEED",
    "STAT_CRITICAL_DAMAGE",
    "STAT_PHYSICAL_DAMAGE_BONUS",
    "STAT_SPELL_DAMAGE_BONUS",
}

for _, statName in ipairs(statsToTest) do
    local statId = _G[statName]
    if statId then
        local value = GetPlayerStat(statId)
        d(string.format("%s (ID %d) = %s", statName, statId, tostring(value)))
    else
        d(string.format("%s = NOT FOUND", statName))
    end
end

d("=== Done ===")
