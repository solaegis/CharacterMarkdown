-- CharacterMarkdown - API Layer - Crafting
-- Abstraction for research, motifs, and recipes

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.crafting = {}

local api = CM.api.crafting

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

function api.GetResearchInfo(craftingType)
    -- craftingType: CRAFTING_TYPE_BLACKSMITHING, etc.
    local numLines = CM.SafeCall(GetNumSmithingResearchLines, craftingType) or 0
    local lines = {}
    
    for l = 1, numLines do
        local success, name, icon, numTraits, timeRequired = CM.SafeCallMulti(GetSmithingResearchLineInfo, craftingType, l)
        if name then
            local traits = {}
            -- Check traits
            -- GetNumSmithingResearchLineTraits usually 9
            local numTraitItems = CM.SafeCall(GetNumSmithingResearchLineTraits, craftingType, l) or 9
            for t = 1, numTraitItems do
                local success_trait, traitType, desc, known = CM.SafeCallMulti(GetSmithingResearchLineTraitInfo, craftingType, l, t)
                table.insert(traits, {
                    id = traitType,
                    known = known
                })
            end
            table.insert(lines, {
                name = name,
                traits = traits
            })
        end
    end
    
    return lines
end

function api.GetActiveTimers()
    -- Get active research timers
    local numTimers = CM.SafeCall(GetNumCurrentResearchTimers) or 0
    local timers = {}
    for i = 1, numTimers do
        local success, craftType, lineIdx, traitIdx, secondsRemaining = CM.SafeCallMulti(GetCurrentResearchTimerInfo, i)
        if craftType then
            table.insert(timers, {
                craftType = craftType,
                seconds = secondsRemaining
            })
        end
    end
    return timers
end

function api.GetKnownStyles()
    -- Helper for Motifs/Styles
    -- Note: IsSmithingStyleKnown might need styleId
    -- GetHighestItemStyleId() returns max ID
    local maxId = CM.SafeCall(GetHighestItemStyleId) or 0
    local known = {}
    local count = 0
    
    for i = 1, maxId do
        local isKnown = CM.SafeCall(IsItemStyleKnown, i)
        if isKnown then
            local name = CM.SafeCall(GetItemStyleName, i)
            table.insert(known, {
                id = i,
                name = name or "Unknown"
            })
            count = count + 1
        end
    end
    
    return {
        count = count,
        list = known
    }
end

-- Composition functions moved to collector level
