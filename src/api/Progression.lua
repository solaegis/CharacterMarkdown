-- CharacterMarkdown - API Layer - Progression
-- Abstraction for riding skills, age, enlightenment, and level

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.progression = {}

local api = CM.api.progression

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

function api.GetRidingSkills()
    local success, capacity, maxCapacity, stamina, maxStamina, speed, maxSpeed = CM.SafeCallMulti(GetRidingStats)
    return {
        speed = speed or 0,
        stamina = stamina or 0,
        capacity = capacity or 0,
    }
end

function api.GetEnlightenment()
    local pool = CM.SafeCall(GetEnlightenedPool) or 0
    local cap = CM.SafeCall(GetEnlightenedPoolCap) or 0
    return {
        current = pool,
        max = cap,
    }
end

function api.GetAge()
    local seconds = CM.SafeCall(GetSecondsPlayed) or 0
    return seconds
end

function api.GetVeterancy()
    -- Historical check, mostly returns 0 now or maps to CP
    local rank = 0
    if GetUnitVeteranRank then
        rank = CM.SafeCall(GetUnitVeteranRank, "player") or 0
    end
    return rank
end

-- Composition functions moved to collector level
