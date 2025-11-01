-- CharacterMarkdown - PvP Stats Section Generator
-- Generates PvP statistics and campaign data markdown sections

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local FormatNumber, GenerateProgressBar

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        FormatNumber = CM.utils.FormatNumber
        GenerateProgressBar = CM.generators.helpers.GenerateProgressBar
    end
end

-- =====================================================
-- PVP STATISTICS
-- =====================================================

local function GeneratePvPStats(pvpStatsData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if not pvpStatsData then
        -- Show placeholder when enabled but no data available
        if format ~= "discord" then
            markdown = markdown .. "## ⚔️ PvP Statistics\n\n"
            markdown = markdown .. "*No PvP statistics available*\n\n---\n\n"
        end
        return markdown
    end
    
    -- Always show section when enabled (even if rank is 0 or minimal data)
    
    if format == "discord" then
        markdown = markdown .. "**PvP Statistics:**\n"
        
        if pvpStatsData.rank and pvpStatsData.rank > 0 and pvpStatsData.rankName and pvpStatsData.rankName ~= "" then
            markdown = markdown .. "• Rank: " .. pvpStatsData.rankName .. " (Rank " .. pvpStatsData.rank .. ")\n"
        else
            markdown = markdown .. "• Rank: None (Rank 0)\n"
        end
        
        if pvpStatsData.allianceName and pvpStatsData.allianceName ~= "" then
            markdown = markdown .. "• Alliance: " .. pvpStatsData.allianceName .. "\n"
        end
        
        if pvpStatsData.campaign and pvpStatsData.campaign.name and pvpStatsData.campaign.name ~= "" then
            markdown = markdown .. "• Campaign: " .. pvpStatsData.campaign.name .. " (" .. (pvpStatsData.campaign.type or "Unknown") .. ")\n"
        end
        
        if pvpStatsData.stats then
            if pvpStatsData.stats.kills > 0 then
                markdown = markdown .. "• Kills: " .. FormatNumber(pvpStatsData.stats.kills) .. "\n"
            end
            if pvpStatsData.stats.deaths > 0 then
                markdown = markdown .. "• Deaths: " .. FormatNumber(pvpStatsData.stats.deaths) .. "\n"
            end
            if pvpStatsData.stats.assists > 0 then
                markdown = markdown .. "• Assists: " .. FormatNumber(pvpStatsData.stats.assists) .. "\n"
            end
            if pvpStatsData.stats.morale and pvpStatsData.stats.morale > 0 then
                markdown = markdown .. "• Morale: " .. FormatNumber(pvpStatsData.stats.morale) .. "\n"
            end
        end
        
        markdown = markdown .. "\n"
    else
        markdown = markdown .. "## ⚔️ PvP Statistics\n\n"
        markdown = markdown .. "| Category | Value |\n"
        markdown = markdown .. "|:---------|:------|\n"
        
        if pvpStatsData.rank and pvpStatsData.rank > 0 and pvpStatsData.rankName and pvpStatsData.rankName ~= "" then
            markdown = markdown .. "| **Alliance War Rank** | " .. pvpStatsData.rankName .. " (Rank " .. pvpStatsData.rank .. ") |\n"
        else
            markdown = markdown .. "| **Alliance War Rank** | None (Rank 0) |\n"
        end
        
        if pvpStatsData.allianceName and pvpStatsData.allianceName ~= "" then
            markdown = markdown .. "| **Alliance** | " .. pvpStatsData.allianceName .. " |\n"
        end
        
        if pvpStatsData.campaign and pvpStatsData.campaign.name and pvpStatsData.campaign.name ~= "" then
            markdown = markdown .. "| **Campaign** | " .. pvpStatsData.campaign.name .. " (" .. (pvpStatsData.campaign.type or "Unknown") .. ") |\n"
            if pvpStatsData.campaign.status and pvpStatsData.campaign.status ~= "" then
                markdown = markdown .. "| **Campaign Status** | " .. pvpStatsData.campaign.status .. " |\n"
            end
        end
        
        if pvpStatsData.stats then
            if pvpStatsData.stats.kills > 0 or pvpStatsData.stats.deaths > 0 then
                markdown = markdown .. "| **Combat Stats** | "
                local stats = {}
                if pvpStatsData.stats.kills > 0 then
                    table.insert(stats, "Kills: " .. FormatNumber(pvpStatsData.stats.kills))
                end
                if pvpStatsData.stats.deaths > 0 then
                    table.insert(stats, "Deaths: " .. FormatNumber(pvpStatsData.stats.deaths))
                end
                if pvpStatsData.stats.assists > 0 then
                    table.insert(stats, "Assists: " .. FormatNumber(pvpStatsData.stats.assists))
                end
                if pvpStatsData.stats.morale and pvpStatsData.stats.morale > 0 then
                    table.insert(stats, "Morale: " .. FormatNumber(pvpStatsData.stats.morale))
                end
                markdown = markdown .. table.concat(stats, " | ") .. " |\n"
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

return {
    GeneratePvPStats = GeneratePvPStats,
}

