-- CharacterMarkdown - Crafting Data Collector
-- Composition logic moved from API layer

local CM = CharacterMarkdown

local function CollectCraftingData()
    -- Use API layer granular functions (composition at collector level)
    local timers = CM.api.crafting.GetActiveTimers()

    local crafting = {}

    -- Transform API data to expected format (backward compatibility)
    crafting.timers = timers or {}

    -- Research info (optional, can be large)
    crafting.research = {
        blacksmithing = CM.api.crafting.GetResearchInfo(CRAFTING_TYPE_BLACKSMITHING),
        clothing = CM.api.crafting.GetResearchInfo(CRAFTING_TYPE_CLOTHIER),
        woodworking = CM.api.crafting.GetResearchInfo(CRAFTING_TYPE_WOODWORKING),
        jewelry = CM.api.crafting.GetResearchInfo(CRAFTING_TYPE_JEWELRYCRAFTING),
    }

    -- Styles (optional, can be large)
    crafting.styles = CM.api.crafting.GetKnownStyles()

    -- Add computed summary
    local activeTimers = crafting.timers and #crafting.timers or 0
    local totalStyles = crafting.styles and #crafting.styles or 0

    -- Calculate research progress
    local researchProgress = {
        blacksmithing = 0,
        clothing = 0,
        woodworking = 0,
        jewelry = 0,
    }

    for craftType, researchInfo in pairs(crafting.research) do
        if researchInfo and researchInfo.total > 0 then
            researchProgress[craftType] = math.floor((researchInfo.completed / researchInfo.total) * 100)
        end
    end

    crafting.summary = {
        activeTimers = activeTimers,
        totalStyles = totalStyles,
        researchProgress = researchProgress,
    }

    return crafting
end

CM.collectors.CollectCraftingData = CollectCraftingData

CM.DebugPrint("COLLECTOR", "Crafting collector module loaded")
