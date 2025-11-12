-- CharacterMarkdown - Combat Data Collector
-- Comprehensive combat statistics (Tier 1 - Validated)

local CM = CharacterMarkdown

-- =====================================================
-- CACHED GLOBALS (PERFORMANCE)
-- =====================================================

local GetPlayerStat = GetPlayerStat
local GetUnitLevel = GetUnitLevel
local math_floor = math.floor

-- =====================================================
-- COMBAT STATS (TIER 1 - ALL VALIDATED)
-- =====================================================

local function CollectCombatStatsData()
    local stats = {}

    -- ===== RESOURCES =====
    stats.health = CM.utils.SafeGetPlayerStat(STAT_HEALTH_MAX, 0)
    stats.magicka = CM.utils.SafeGetPlayerStat(STAT_MAGICKA_MAX, 0)
    stats.stamina = CM.utils.SafeGetPlayerStat(STAT_STAMINA_MAX, 0)

    -- ===== OFFENSIVE POWER =====
    stats.weaponPower = CM.utils.SafeGetPlayerStat(STAT_POWER, 0)
    stats.spellPower = CM.utils.SafeGetPlayerStat(STAT_SPELL_POWER, 0)

    -- ===== CRITICAL STRIKE =====
    stats.weaponCritRating = CM.utils.SafeGetPlayerStat(STAT_CRITICAL_STRIKE, 0)
    stats.spellCritRating = CM.utils.SafeGetPlayerStat(STAT_SPELL_CRITICAL, 0)

    -- Calculate crit chance percentages (ESO formula: Rating / 219 = % at CP 160+)
    stats.weaponCritChance = stats.weaponCritRating > 0 and math_floor((stats.weaponCritRating / 219) * 10) / 10 or 0
    stats.spellCritChance = stats.spellCritRating > 0 and math_floor((stats.spellCritRating / 219) * 10) / 10 or 0

    -- ===== PENETRATION =====
    stats.physicalPenetration = CM.utils.SafeGetPlayerStat(STAT_PHYSICAL_PENETRATION, 0)
    stats.spellPenetration = CM.utils.SafeGetPlayerStat(STAT_SPELL_PENETRATION, 0)

    -- ===== RESISTANCES =====
    stats.physicalResist = CM.utils.SafeGetPlayerStat(STAT_PHYSICAL_RESIST, 0)
    stats.spellResist = CM.utils.SafeGetPlayerStat(STAT_SPELL_RESIST, 0)

    -- Calculate mitigation percentage (ESO formula: Resist / (Resist + 50 * Level))
    local playerLevel = GetUnitLevel("player") or 50
    local resistDivisor = 50 * playerLevel
    stats.physicalMitigation = stats.physicalResist > 0
            and math_floor((stats.physicalResist / (stats.physicalResist + resistDivisor)) * 1000) / 10
        or 0
    stats.spellMitigation = stats.spellResist > 0
            and math_floor((stats.spellResist / (stats.spellResist + resistDivisor)) * 1000) / 10
        or 0

    -- ===== RECOVERY =====
    stats.healthRecovery = CM.utils.SafeGetPlayerStat(STAT_HEALTH_REGEN_COMBAT, 0)
    stats.magickaRecovery = CM.utils.SafeGetPlayerStat(STAT_MAGICKA_REGEN_COMBAT, 0)
    stats.staminaRecovery = CM.utils.SafeGetPlayerStat(STAT_STAMINA_REGEN_COMBAT, 0)

    return stats
end

CM.collectors.CollectCombatStatsData = CollectCombatStatsData
