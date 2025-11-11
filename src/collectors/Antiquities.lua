-- CharacterMarkdown - Antiquity Data Collector
-- Collects data about antiquities, leads, and scrying progress

local CM = CharacterMarkdown

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

local function GetAntiquityQuality(antiquityId)
    local success, quality = pcall(GetAntiquityQuality, antiquityId)
    return success and quality or ANTIQUITY_QUALITY_MAGIC
end

local function GetAntiquityName(antiquityId)
    local success, name = pcall(GetAntiquityName, antiquityId)
    return success and name or "Unknown"
end

local function GetAntiquitySetIcon(setId)
    local success, icon = pcall(GetAntiquitySetIcon, setId)
    return success and icon or ""
end

local function GetAntiquitySetName(setId)
    local success, name = pcall(GetAntiquitySetName, setId)
    return success and name or "Unknown Set"
end

local function GetNumAntiquitySetAntiquities(setId)
    local success, count = pcall(GetNumAntiquitySetAntiquities, setId)
    return success and count or 0
end

local function GetAntiquityHasLead(antiquityId)
    local success, hasLead = pcall(GetAntiquityHasLead, antiquityId)
    return success and hasLead or false
end

local function GetAntiquityIsRepeatable(antiquityId)
    local success, isRepeatable = pcall(GetAntiquityIsRepeatable, antiquityId)
    return success and isRepeatable or false
end

local function GetNumAntiquitySets()
    local success, count = pcall(GetNumAntiquitySets)
    return success and count or 0
end

-- =====================================================
-- ANTIQUITY DATA COLLECTION
-- =====================================================

local function CollectAntiquityData()
    local data = {
        summary = {
            totalAntiquities = 0,
            discoveredAntiquities = 0,
            activeLeads = 0,
            completedAntiquities = 0,
            totalSets = 0,
            completedSets = 0
        },
        sets = {},
        activeLeads = {},
        recentDiscoveries = {}
    }
    
    CM.Info("[ANTIQUITIES] Starting antiquity data collection...")
    
    -- Get total number of antiquity sets
    local numSets = GetNumAntiquitySets()
    CM.Info(string.format("[ANTIQUITIES] Found %d antiquity sets", numSets))
    
    if numSets == 0 then
        CM.Warn("[ANTIQUITIES] No antiquity sets found - player may not have access to antiquities system")
        return data
    end
    
    data.summary.totalSets = numSets
    
    -- Iterate through all antiquity sets
    for setIndex = 1, numSets do
        local setId = CM.SafeCall(GetAntiquitySetId, setIndex)
        
        if setId then
            local setName = GetAntiquitySetName(setId)
            local setIcon = GetAntiquitySetIcon(setId)
            local numAntiquities = GetNumAntiquitySetAntiquities(setId)
            
            local setData = {
                id = setId,
                name = setName,
                icon = setIcon,
                totalAntiquities = numAntiquities,
                discoveredAntiquities = 0,
                completedAntiquities = 0,
                antiquities = {}
            }
            
            -- Iterate through antiquities in this set
            for antiquityIndex = 1, numAntiquities do
                local antiquityId = CM.SafeCall(GetAntiquitySetAntiquityId, setId, antiquityIndex)
                
                if antiquityId then
                    data.summary.totalAntiquities = data.summary.totalAntiquities + 1
                    
                    local name = GetAntiquityName(antiquityId)
                    local quality = GetAntiquityQuality(antiquityId)
                    local hasLead = GetAntiquityHasLead(antiquityId)
                    local isRepeatable = GetAntiquityIsRepeatable(antiquityId)
                    
                    -- Check if antiquity has been discovered
                    local success, isDiscovered = pcall(GetHasAntiquityBeenDiscovered, antiquityId)
                    isDiscovered = success and isDiscovered or false
                    
                    -- Check if antiquity is in progress (has lead and not completed)
                    local isInProgress = hasLead and not isDiscovered
                    
                    local antiquityData = {
                        id = antiquityId,
                        name = name,
                        quality = quality,
                        hasLead = hasLead,
                        isDiscovered = isDiscovered,
                        isRepeatable = isRepeatable,
                        isInProgress = isInProgress
                    }
                    
                    table.insert(setData.antiquities, antiquityData)
                    
                    -- Update counters
                    if isDiscovered then
                        data.summary.discoveredAntiquities = data.summary.discoveredAntiquities + 1
                        data.summary.completedAntiquities = data.summary.completedAntiquities + 1
                        setData.discoveredAntiquities = setData.discoveredAntiquities + 1
                        setData.completedAntiquities = setData.completedAntiquities + 1
                    end
                    
                    if hasLead and not isDiscovered then
                        data.summary.activeLeads = data.summary.activeLeads + 1
                        table.insert(data.activeLeads, antiquityData)
                    end
                end
            end
            
            -- Check if set is complete
            if setData.completedAntiquities == setData.totalAntiquities and setData.totalAntiquities > 0 then
                data.summary.completedSets = data.summary.completedSets + 1
            end
            
            table.insert(data.sets, setData)
        end
    end
    
    -- Sort active leads by quality (highest first)
    table.sort(data.activeLeads, function(a, b)
        return a.quality > b.quality
    end)
    
    CM.Info(string.format("[ANTIQUITIES] Collection complete: %d total antiquities, %d discovered, %d active leads, %d/%d sets complete",
        data.summary.totalAntiquities, 
        data.summary.discoveredAntiquities,
        data.summary.activeLeads,
        data.summary.completedSets,
        data.summary.totalSets))
    
    return data
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.collectors = CM.collectors or {}
CM.collectors.CollectAntiquityData = CollectAntiquityData

return {
    CollectAntiquityData = CollectAntiquityData
}

