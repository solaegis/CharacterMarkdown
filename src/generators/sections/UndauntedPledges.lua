-- CharacterMarkdown - Undaunted Pledges Section Generator
-- Generates Undaunted pledges, dungeon progress, and keys markdown sections

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
-- UNDAUNTED PLEDGES
-- =====================================================

local function GenerateUndauntedPledges(pledgesData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if not pledgesData or not pledgesData.pledges then
        return ""  -- No Undaunted data available
    end
    
    local pledges = pledgesData.pledges or {}
    local dungeonProgress = pledgesData.dungeonProgress or {}
    local keys = pledgesData.keys or {}
    
    if format == "discord" then
        markdown = markdown .. "**Undaunted Pledges:**\n"
        
        -- Daily pledges
        if pledges.daily then
            local dailyNormal = #pledges.daily.normal or 0
            local dailyVeteran = #pledges.daily.veteran or 0
            if dailyNormal > 0 or dailyVeteran > 0 then
                markdown = markdown .. "• Daily: " .. (dailyNormal + dailyVeteran) .. " available"
                if pledges.daily.keys > 0 then
                    markdown = markdown .. " (" .. pledges.daily.keys .. " keys)"
                end
                markdown = markdown .. "\n"
            end
        end
        
        -- Weekly pledges
        if pledges.weekly then
            local weeklyNormal = #pledges.weekly.normal or 0
            local weeklyVeteran = #pledges.weekly.veteran or 0
            if weeklyNormal > 0 or weeklyVeteran > 0 then
                markdown = markdown .. "• Weekly: " .. (weeklyNormal + weeklyVeteran) .. " available"
                if pledges.weekly.keys > 0 then
                    markdown = markdown .. " (" .. pledges.weekly.keys .. " keys)"
                end
                markdown = markdown .. "\n"
            end
        end
        
        -- Progress
        if pledges.progress and pledges.progress.totalAvailable > 0 then
            local percent = math.floor((pledges.progress.totalCompleted / pledges.progress.totalAvailable) * 100)
            markdown = markdown .. "• Progress: " .. pledges.progress.totalCompleted .. "/" .. pledges.progress.totalAvailable .. " (" .. percent .. "%)\n"
        end
        
        markdown = markdown .. "\n"
    else
        markdown = markdown .. "## 🏛️ Undaunted Pledges\n\n"
        
        -- Pledges summary
        if pledges.daily or pledges.weekly then
            markdown = markdown .. "| Type | Available | Keys |\n"
            markdown = markdown .. "|:-----|:----------|:-----|\n"
            
            if pledges.daily then
                local dailyTotal = (#pledges.daily.normal or 0) + (#pledges.daily.veteran or 0)
                if dailyTotal > 0 then
                    markdown = markdown .. "| **Daily** | " .. dailyTotal .. " | " .. (pledges.daily.keys or 0) .. " |\n"
                end
            end
            
            if pledges.weekly then
                local weeklyTotal = (#pledges.weekly.normal or 0) + (#pledges.weekly.veteran or 0)
                if weeklyTotal > 0 then
                    markdown = markdown .. "| **Weekly** | " .. weeklyTotal .. " | " .. (pledges.weekly.keys or 0) .. " |\n"
                end
            end
            
            markdown = markdown .. "\n"
        end
        
        -- Progress section
        if pledges.progress and pledges.progress.totalAvailable > 0 then
            local percent = math.floor((pledges.progress.totalCompleted / pledges.progress.totalAvailable) * 100)
            local progressBar = GenerateProgressBar(percent, 20)
            markdown = markdown .. "### 📊 Progress\n\n"
            markdown = markdown .. "| Completed | " .. progressBar .. " " .. percent .. "% (" .. pledges.progress.totalCompleted .. "/" .. pledges.progress.totalAvailable .. ") |\n\n"
        end
        
        -- Dungeon progress section
        if dungeonProgress and (dungeonProgress.normal.total > 0 or dungeonProgress.veteran.total > 0) then
            markdown = markdown .. "### 🏰 Dungeon Progress\n\n"
            markdown = markdown .. "| Difficulty | Completed | Total | Progress |\n"
            markdown = markdown .. "|:-----------|:----------|:------|:--------|\n"
            
            if dungeonProgress.normal.total > 0 then
                local normalPercent = math.floor((dungeonProgress.normal.completed / dungeonProgress.normal.total) * 100)
                local normalProgressBar = GenerateProgressBar(normalPercent, 20)
                markdown = markdown .. "| **Normal** | " .. dungeonProgress.normal.completed .. " | " .. dungeonProgress.normal.total .. " | " .. normalProgressBar .. " " .. normalPercent .. "% |\n"
            end
            
            if dungeonProgress.veteran.total > 0 then
                local veteranPercent = math.floor((dungeonProgress.veteran.completed / dungeonProgress.veteran.total) * 100)
                local veteranProgressBar = GenerateProgressBar(veteranPercent, 20)
                markdown = markdown .. "| **Veteran** | " .. dungeonProgress.veteran.completed .. " | " .. dungeonProgress.veteran.total .. " | " .. veteranProgressBar .. " " .. veteranPercent .. "% |\n"
            end
            
            if dungeonProgress.hardmode and dungeonProgress.hardmode.total > 0 then
                local hardmodePercent = math.floor((dungeonProgress.hardmode.completed / dungeonProgress.hardmode.total) * 100)
                local hardmodeProgressBar = GenerateProgressBar(hardmodePercent, 20)
                markdown = markdown .. "| **Hardmode** | " .. dungeonProgress.hardmode.completed .. " | " .. dungeonProgress.hardmode.total .. " | " .. hardmodeProgressBar .. " " .. hardmodePercent .. "% |\n"
            end
            
            markdown = markdown .. "\n"
        end
        
        -- Keys section
        if keys and keys.total > 0 then
            markdown = markdown .. "### 🔑 Undaunted Keys\n\n"
            if keys.categories then
                for categoryName, categoryData in pairs(keys.categories) do
                    if categoryData.total > 0 then
                        markdown = markdown .. "#### " .. categoryName .. "\n\n"
                        if categoryData.keys and #categoryData.keys > 0 then
                            for _, key in ipairs(categoryData.keys) do
                                if key.count > 0 then
                                    markdown = markdown .. "- " .. key.name .. ": " .. key.count .. "\n"
                                end
                            end
                        end
                        markdown = markdown .. "\n"
                    end
                end
            end
        end
        
        markdown = markdown .. "---\n\n"
    end
    
    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateUndauntedPledges = GenerateUndauntedPledges

return {
    GenerateUndauntedPledges = GenerateUndauntedPledges,
}

