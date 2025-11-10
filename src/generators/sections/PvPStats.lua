-- CharacterMarkdown - PvP Stats Section Generator
-- Generates PvP statistics and campaign data markdown sections

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local FormatNumber, GenerateProgressBar, GenerateAnchor

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        FormatNumber = CM.utils.FormatNumber
        GenerateProgressBar = CM.generators.helpers.GenerateProgressBar
        GenerateAnchor = CM.utils and CM.utils.markdown and CM.utils.markdown.GenerateAnchor
    end
end

-- =====================================================
-- FIX #7: MERGED PVP SECTION
-- This function now handles both pvpData (from CollectPvPData) 
-- and pvpStatsData (from CollectPvPStatsData) to avoid duplication
-- =====================================================

local function GeneratePvPStats(pvpData, pvpStatsData, format)
    InitializeUtilities()
    
    local CreateCampaignLink = CM.links and CM.links.CreateCampaignLink
    
    -- Require at least one data source
    if not pvpData and not pvpStatsData then
        return ""
    end
    
    -- Merge data from both sources, preferring pvpStatsData for detailed info
    local rank = 0
    local rankName = "None"
    local allianceName = ""
    local campaignName = ""
    local campaignType = ""
    local campaignStatus = ""
    
    -- Get basic info from pvpData (from CollectPvPData)
    if pvpData then
        rank = pvpData.rank or 0
        rankName = pvpData.rankName or "None"
        allianceName = pvpData.allianceName or ""
        campaignName = pvpData.campaignName or ""
    end
    
    -- Get detailed stats from pvpStatsData (from CollectPvPStatsData)
    local stats = {}
    if pvpStatsData then
        -- Override with pvpStatsData if it has better/more complete info
        if pvpStatsData.rank and pvpStatsData.rank > 0 then
            rank = pvpStatsData.rank
            rankName = pvpStatsData.rankName or rankName
        end
        if pvpStatsData.allianceName and pvpStatsData.allianceName ~= "" then
            allianceName = pvpStatsData.allianceName
        end
        if pvpStatsData.campaign and pvpStatsData.campaign.name then
            campaignName = pvpStatsData.campaign.name
            campaignType = pvpStatsData.campaign.type or ""
            campaignStatus = pvpStatsData.campaign.status or ""
        end
        stats = pvpStatsData.stats or {}
    end
    
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**PvP:**\n"
        
        -- Alliance War Rank removed - now shown in Overview section
        
        if allianceName and allianceName ~= "" then
            markdown = markdown .. "• Alliance: " .. allianceName .. "\n"
        end
        
        if campaignName and campaignName ~= "" and campaignName ~= "None" then
            markdown = markdown .. "• Campaign: " .. campaignName
            if campaignType ~= "" then
                markdown = markdown .. " (" .. campaignType .. ")"
            end
            markdown = markdown .. "\n"
        end
        
        if stats.kills and stats.kills > 0 then
            markdown = markdown .. "• Kills: " .. FormatNumber(stats.kills) .. "\n"
        end
        if stats.deaths and stats.deaths > 0 then
            markdown = markdown .. "• Deaths: " .. FormatNumber(stats.deaths) .. "\n"
        end
        if stats.assists and stats.assists > 0 then
            markdown = markdown .. "• Assists: " .. FormatNumber(stats.assists) .. "\n"
        end
        if stats.morale and stats.morale > 0 then
            markdown = markdown .. "• Morale: " .. FormatNumber(stats.morale) .. "\n"
        end
        
        markdown = markdown .. "\n"
    else
        local anchorId = GenerateAnchor and GenerateAnchor("⚔️ PvP") or "pvp"
        markdown = markdown .. string.format('<a id="%s"></a>\n\n', anchorId)
        markdown = markdown .. "## ⚔️ PvP\n\n"
        markdown = markdown .. "| Category | Value |\n"
        markdown = markdown .. "|:---------|:------|\n"
        
        -- Alliance War Rank removed - now shown in Overview section
        
        if allianceName and allianceName ~= "" then
            markdown = markdown .. "| **Alliance** | " .. allianceName .. " |\n"
        end
        
        if campaignName and campaignName ~= "" and campaignName ~= "None" then
            local campaignLink = campaignName
            if CreateCampaignLink then
                campaignLink = CreateCampaignLink(campaignName, format) or campaignName
            end
            markdown = markdown .. "| **Campaign** | " .. campaignLink
            if campaignType ~= "" then
                markdown = markdown .. " (" .. campaignType .. ")"
            end
            markdown = markdown .. " |\n"
            
            if campaignStatus and campaignStatus ~= "" then
                markdown = markdown .. "| **Campaign Status** | " .. campaignStatus .. " |\n"
            end
        end
        
        if stats.kills or stats.deaths or stats.assists or stats.morale then
            local combatStats = {}
            if stats.kills and stats.kills > 0 then
                table.insert(combatStats, "Kills: " .. FormatNumber(stats.kills))
            end
            if stats.deaths and stats.deaths > 0 then
                table.insert(combatStats, "Deaths: " .. FormatNumber(stats.deaths))
            end
            if stats.assists and stats.assists > 0 then
                table.insert(combatStats, "Assists: " .. FormatNumber(stats.assists))
            end
            if stats.morale and stats.morale > 0 then
                table.insert(combatStats, "Morale: " .. FormatNumber(stats.morale))
            end
            
            if #combatStats > 0 then
                markdown = markdown .. "| **Combat Stats** | " .. table.concat(combatStats, " • ") .. " |\n"
            end
        end
        
        markdown = markdown .. "\n---\n\n"
    end
    
    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GeneratePvPStats = GeneratePvPStats
-- Also export as GeneratePvP to maintain compatibility
CM.generators.sections.GeneratePvP = GeneratePvPStats

return {
    GeneratePvPStats = GeneratePvPStats,
    GeneratePvP = GeneratePvPStats,  -- Alias for compatibility
}

