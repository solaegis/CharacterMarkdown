-- CharacterMarkdown - API Layer - Antiquities
-- Abstraction for antiquity sets, leads, and scrying progress

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.antiquities = {}

local api = CM.api.antiquities

-- =====================================================
-- CACHING
-- =====================================================

local _antiquityCache = {} -- Cache by antiquityId

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

function api.GetNumSets()
    return CM.SafeCall(GetNumAntiquitySets) or 0
end

function api.GetSetId(setIndex)
    return CM.SafeCall(GetAntiquitySetId, setIndex)
end

function api.GetSetInfo(setId)
    if not setId then
        return nil
    end

    local name = CM.SafeCall(GetAntiquitySetName, setId) or "Unknown Set"
    local icon = CM.SafeCall(GetAntiquitySetIcon, setId) or ""
    local numAntiquities = CM.SafeCall(GetNumAntiquitySetAntiquities, setId) or 0

    return {
        id = setId,
        name = name,
        icon = icon,
        numAntiquities = numAntiquities,
    }
end

function api.GetAntiquityId(setId, antiquityIndex)
    return CM.SafeCall(GetAntiquitySetAntiquityId, setId, antiquityIndex)
end

function api.GetAntiquityInfo(antiquityId)
    if not antiquityId then
        return nil
    end

    -- Return cached if available
    if _antiquityCache[antiquityId] then
        return _antiquityCache[antiquityId]
    end

    local name = CM.SafeCall(GetAntiquityName, antiquityId) or "Unknown"
    local quality = CM.SafeCall(GetAntiquityQuality, antiquityId) or ANTIQUITY_QUALITY_MAGIC
    local hasLead = CM.SafeCall(GetAntiquityHasLead, antiquityId) or false
    local isRepeatable = CM.SafeCall(GetAntiquityIsRepeatable, antiquityId) or false

    local success, isDiscovered = pcall(GetHasAntiquityBeenDiscovered, antiquityId)
    local discovered = (success and isDiscovered) or false

    local result = {
        id = antiquityId,
        name = name,
        quality = quality,
        hasLead = hasLead,
        isDiscovered = discovered,
        isRepeatable = isRepeatable,
        isInProgress = hasLead and not discovered,
    }

    -- Cache the result
    _antiquityCache[antiquityId] = result
    return result
end

function api.ClearCache()
    _antiquityCache = {}
end

function api.GetSets()
    local numSets = api.GetNumSets()
    local sets = {}

    for setIndex = 1, numSets do
        local setId = api.GetSetId(setIndex)
        if setId then
            local setInfo = api.GetSetInfo(setId)
            if setInfo then
                setInfo.antiquities = {}

                -- Get antiquities in this set
                for antiquityIndex = 1, setInfo.numAntiquities do
                    local antiquityId = api.GetAntiquityId(setId, antiquityIndex)
                    if antiquityId then
                        local antiquityInfo = api.GetAntiquityInfo(antiquityId)
                        if antiquityInfo then
                            table.insert(setInfo.antiquities, antiquityInfo)
                        end
                    end
                end

                table.insert(sets, setInfo)
            end
        end
    end

    return sets
end

-- Composition functions moved to collector level

CM.DebugPrint("API", "Antiquities API module loaded")
