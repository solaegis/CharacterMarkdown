-- CharacterMarkdown - Combat Data Collector
-- Combat statistics

local CM = CharacterMarkdown

-- =====================================================
-- COMBAT STATS
-- =====================================================

local function CollectCombatStatsData()
    local stats = {}
    
    stats.health = CM.utils.SafeGetPlayerStat(STAT_HEALTH_MAX, 0)
    stats.magicka = CM.utils.SafeGetPlayerStat(STAT_MAGICKA_MAX, 0)
    stats.stamina = CM.utils.SafeGetPlayerStat(STAT_STAMINA_MAX, 0)
    
    local success1, weaponPower = pcall(GetPlayerStat, STAT_POWER)
    stats.weaponPower = (success1 and weaponPower) or 0
    
    local success2, spellPower = pcall(GetPlayerStat, STAT_SPELL_POWER)
    stats.spellPower = (success2 and spellPower) or 0
    
    local success3, physicalResist = pcall(GetPlayerStat, STAT_PHYSICAL_RESIST)
    stats.physicalResist = (success3 and physicalResist) or 0
    
    local success4, spellResist = pcall(GetPlayerStat, STAT_SPELL_RESIST)
    stats.spellResist = (success4 and spellResist) or 0
    
    return stats
end

CM.collectors.CollectCombatStatsData = CollectCombatStatsData
