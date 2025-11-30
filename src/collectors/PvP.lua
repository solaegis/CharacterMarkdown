-- CharacterMarkdown - PvP Data Collector
-- Composition logic moved from API layer

local CM = CharacterMarkdown

-- =====================================================
-- BASIC PVP DATA
-- =====================================================

local function CollectBasicPvPData()
    -- Use API layer granular functions (composition at collector level)
    -- Get gender from Character API to pass to PvP API
    local characterInfo = CM.api.character.GetGender()
    local genderId = characterInfo and characterInfo.id or 1  -- Default to 1 (Female) if not available
    
    local rank = CM.api.pvp.GetRank(genderId)
    local campaign = CM.api.pvp.GetCampaign()
    local battleground = CM.api.pvp.GetBattlegroundInfo()
    
    local basic = {}
    
    -- Transform API data to expected format (backward compatibility)
    if rank then
        basic.rank = rank.rank or 0
        basic.rankName = rank.name or "Recruit"
        basic.rankPoints = rank.points or 0
    else
        basic.rank = 0
        basic.rankName = "Recruit"
        basic.rankPoints = 0
    end
    
    if campaign then
        basic.campaignId = campaign.id or nil
        basic.campaignName = campaign.name or "None"
        basic.hasEmperor = campaign.hasEmperor or false
        basic.emperor = campaign.emperor
    else
        basic.campaignName = "None"
        basic.campaignId = nil
        basic.hasEmperor = false
        basic.emperor = nil
    end
    
    if battleground then
        basic.isInBattleground = battleground.isActive or false
    else
        basic.isInBattleground = false
    end
    
    return basic
end

-- =====================================================
-- UNIFIED PVP COLLECTOR
-- =====================================================

local function CollectPvPData()
    -- Always collect basic PvP data
    local basic = CollectBasicPvPData()
    
    -- Check settings to determine if detailed stats should be collected
    local settings = CM.GetSettings()
    local includePvPStats = settings and settings.includePvPStats or false
    
    local result = {
        basic = basic,
        stats = nil,  -- Only populated if includePvPStats is true
        summary = {}
    }
    
    -- Add computed metrics
    if basic.rank then
        result.summary.rankProgress = {
            currentRank = basic.rank,
            rankName = basic.rankName or "Recruit",
            rankPoints = basic.rankPoints or 0
        }
    end
    
    if basic.campaignName and basic.campaignName ~= "None" then
        result.summary.campaignParticipation = {
            active = true,
            campaignName = basic.campaignName,
            hasEmperor = basic.hasEmperor or false
        }
    else
        result.summary.campaignParticipation = {
            active = false
        }
    end
    
    result.summary.battlegroundStatus = {
        isActive = basic.isInBattleground or false
    }
    
    -- Note: Detailed PvP stats collection would go here if needed
    -- For now, just return basic data
    
    return result
end

CM.collectors.CollectPvPData = CollectPvPData

-- Maintain backward compatibility
CM.collectors.CollectPvPStatsData = function()
    local settings = CM.GetSettings()
    local includePvPStats = settings and settings.includePvPStats or false
    
    if includePvPStats then
        return {
            pvp = {},
            leaderboards = {},
            battlegrounds = {},
        }
    else
        return {
            pvp = {},
            leaderboards = {},
            battlegrounds = {},
        }
    end
end

CM.DebugPrint("COLLECTOR", "PvP collector module loaded")

