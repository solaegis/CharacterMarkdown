-- CharacterMarkdown - Enhanced Champion Points Generator
-- Phase 4: Detailed allocation analysis and optimization suggestions

local CM = CharacterMarkdown

-- =====================================================
-- UTILITIES
-- =====================================================

local function InitializeUtilities()
    if not CM.utils then
        CM.utils = {}
    end
    
    -- Lazy load utilities
    if not CM.utils.FormatNumber then
        local Formatters = CM.generators.helpers.Utilities
        CM.utils.FormatNumber = Formatters.FormatNumber
        CM.utils.CreateCPSkillLink = Formatters.CreateCPSkillLink
        CM.utils.GenerateProgressBar = Formatters.GenerateProgressBar
    end
end

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

local function GetInvestmentLevelEmoji(level)
    local emojis = {
        ["very-high"] = "🔥",
        ["high"] = "⭐",
        ["medium-high"] = "💪",
        ["medium"] = "📈",
        ["low"] = "🌱"
    }
    return emojis[level] or "🌱"
end

local function GetInvestmentLevelDescription(level)
    local descriptions = {
        ["very-high"] = "Expert level (1500+ CP)",
        ["high"] = "Advanced level (1200+ CP)",
        ["medium-high"] = "Intermediate level (800+ CP)",
        ["medium"] = "Developing level (400+ CP)",
        ["low"] = "Beginner level (<400 CP)"
    }
    return descriptions[level] or "Beginner level"
end

local function GetSlottableStatus(skill, maxSlottable)
    if not skill.isSlottable then
        return "🔒 Passive"
    end
    
    local points = skill.points or 0
    if points >= 50 then
        return "⭐ Maxed Slottable"
    elseif points >= 30 then
        return "🔸 High Slottable"
    elseif points >= 15 then
        return "🔹 Medium Slottable"
    else
        return "🔸 Low Slottable"
    end
end

local function GenerateOptimizationSuggestions(cpData)
    local suggestions = {}
    
    -- Check for unspent points
    if cpData.available and cpData.available > 0 then
        table.insert(suggestions, "⚠️ You have " .. CM.utils.FormatNumber(cpData.available) .. " unspent Champion Points")
    end
    
    -- Check slottable allocation
    if cpData.analysis then
        local totalSlottable = cpData.analysis.slottableSkills or 0
        local maxSlottable = cpData.analysis.maxSlottablePerDiscipline or 3
        local totalMaxSlottable = maxSlottable * 3  -- 3 disciplines
        
        if totalSlottable < totalMaxSlottable then
            table.insert(suggestions, "💡 Consider investing in more slottable skills (" .. totalSlottable .. "/" .. totalMaxSlottable .. " used)")
        end
        
        -- Check for discipline balance
        if cpData.disciplines then
            local disciplineTotals = {}
            for _, discipline in ipairs(cpData.disciplines) do
                disciplineTotals[discipline.name] = discipline.total or 0
            end
            
            local craftTotal = disciplineTotals.Craft or 0
            local warfareTotal = disciplineTotals.Warfare or 0
            local fitnessTotal = disciplineTotals.Fitness or 0
            
            local maxDiscipline = math.max(craftTotal, warfareTotal, fitnessTotal)
            local minDiscipline = math.min(craftTotal, warfareTotal, fitnessTotal)
            
            if maxDiscipline > 0 and (maxDiscipline - minDiscipline) > 200 then
                table.insert(suggestions, "⚖️ Consider balancing CP allocation across disciplines")
            end
        end
    end
    
    return suggestions
end

-- =====================================================
-- DETAILED CHAMPION POINTS GENERATOR
-- =====================================================

local function GenerateDetailedChampionPoints(cpData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Champion Points Analysis:**\n"
    else
        markdown = markdown .. "## 🎯 Champion Points Analysis\n\n"
    end
    
    local totalCP = cpData.total or 0
    local spentCP = cpData.spent or 0
    local availableCP = cpData.available or 0
    
    if totalCP < 10 then
        markdown = markdown .. "*Champion Point system unlocks at Level 50*\n\n"
        return markdown
    end
    
    -- Investment level analysis
    local investmentLevel = cpData.analysis and cpData.analysis.investmentLevel or "low"
    local levelEmoji = GetInvestmentLevelEmoji(investmentLevel)
    local levelDesc = GetInvestmentLevelDescription(investmentLevel)
    
    if format == "discord" then
        markdown = markdown .. levelEmoji .. " **" .. levelDesc .. "**\n"
        markdown = markdown .. "Total: " .. CM.utils.FormatNumber(totalCP) .. " | "
        markdown = markdown .. "Spent: " .. CM.utils.FormatNumber(spentCP) .. " | "
        markdown = markdown .. "Available: " .. CM.utils.FormatNumber(availableCP) .. "\n"
        
        -- Analysis summary
        if cpData.analysis then
            local slottable = cpData.analysis.slottableSkills or 0
            local passive = cpData.analysis.passiveSkills or 0
            markdown = markdown .. "Slottable: " .. slottable .. " | Passive: " .. passive .. "\n"
        end
    else
        -- Detailed analysis table
        markdown = markdown .. "### 📊 Investment Summary\n\n"
        markdown = markdown .. "| Metric | Value |\n"
        markdown = markdown .. "|:-------|------:|\n"
        markdown = markdown .. "| **Total CP** | " .. CM.utils.FormatNumber(totalCP) .. " |\n"
        markdown = markdown .. "| **Spent CP** | " .. CM.utils.FormatNumber(spentCP) .. " |\n"
        markdown = markdown .. "| **Available CP** | " .. CM.utils.FormatNumber(availableCP) .. " |\n"
        markdown = markdown .. "| **Investment Level** | " .. levelEmoji .. " " .. levelDesc .. " |\n"
        
        if cpData.analysis then
            local slottable = cpData.analysis.slottableSkills or 0
            local passive = cpData.analysis.passiveSkills or 0
            local maxSlottable = cpData.analysis.maxSlottablePerDiscipline or 3
            markdown = markdown .. "| **Slottable Skills** | " .. slottable .. " |\n"
            markdown = markdown .. "| **Passive Skills** | " .. passive .. " |\n"
            markdown = markdown .. "| **Max Slottable/Discipline** | " .. maxSlottable .. " |\n"
        end
        
        markdown = markdown .. "\n"
    end
    
    -- Discipline breakdown
    if cpData.disciplines and #cpData.disciplines > 0 then
        if format == "discord" then
            for _, discipline in ipairs(cpData.disciplines) do
                local slottable = discipline.slottable or 0
                local passive = discipline.passive or 0
                markdown = markdown .. (discipline.emoji or "⚔️") .. " **" .. discipline.name .. "** (" .. CM.utils.FormatNumber(discipline.total) .. ")\n"
                markdown = markdown .. "  Slottable: " .. slottable .. " | Passive: " .. passive .. "\n"
            end
        else
            markdown = markdown .. "### 🌟 Discipline Breakdown\n\n"
            
            for _, discipline in ipairs(cpData.disciplines) do
                local slottable = discipline.slottable or 0
                local passive = discipline.passive or 0
                local slottableSkills = discipline.slottableSkills or {}
                local passiveSkills = discipline.passiveSkills or {}
                
                markdown = markdown .. "#### " .. (discipline.emoji or "⚔️") .. " " .. discipline.name .. " (" .. CM.utils.FormatNumber(discipline.total) .. " CP)\n\n"
                
                -- Summary
                markdown = markdown .. "| Type | Points | Skills |\n"
                markdown = markdown .. "|:-----|-------:|-------:|\n"
                markdown = markdown .. "| **Slottable** | " .. CM.utils.FormatNumber(slottable) .. " | " .. #slottableSkills .. " |\n"
                markdown = markdown .. "| **Passive** | " .. CM.utils.FormatNumber(passive) .. " | " .. #passiveSkills .. " |\n"
                markdown = markdown .. "\n"
                
                -- Slottable skills
                if #slottableSkills > 0 then
                    markdown = markdown .. "**Slottable Skills:**\n"
                    for _, skill in ipairs(slottableSkills) do
                        local status = GetSlottableStatus(skill, cpData.analysis and cpData.analysis.maxSlottablePerDiscipline or 3)
                        local skillText = CM.utils.CreateCPSkillLink(skill.name, format)
                        markdown = markdown .. "- " .. status .. " **" .. skillText .. "**: " .. skill.points .. " points\n"
                    end
                    markdown = markdown .. "\n"
                end
                
                -- Passive skills
                if #passiveSkills > 0 then
                    markdown = markdown .. "**Passive Skills:**\n"
                    for _, skill in ipairs(passiveSkills) do
                        local skillText = CM.utils.CreateCPSkillLink(skill.name, format)
                        markdown = markdown .. "- 🔒 **" .. skillText .. "**: " .. skill.points .. " points\n"
                    end
                    markdown = markdown .. "\n"
                end
            end
        end
    end
    
    -- Optimization suggestions
    local suggestions = GenerateOptimizationSuggestions(cpData)
    if #suggestions > 0 then
        if format == "discord" then
            markdown = markdown .. "**Suggestions:**\n"
            for _, suggestion in ipairs(suggestions) do
                markdown = markdown .. suggestion .. "\n"
            end
        else
            markdown = markdown .. "### 💡 Optimization Suggestions\n\n"
            for _, suggestion in ipairs(suggestions) do
                markdown = markdown .. "- " .. suggestion .. "\n"
            end
            markdown = markdown .. "\n"
        end
    end
    
    return markdown
end

-- =====================================================
-- SLOTTABLE-ONLY CHAMPION POINTS GENERATOR
-- =====================================================

local function GenerateSlottableChampionPoints(cpData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Slottable Champion Points:**\n"
    else
        markdown = markdown .. "## ⭐ Slottable Champion Points\n\n"
    end
    
    local totalCP = cpData.total or 0
    
    if totalCP < 10 then
        markdown = markdown .. "*Champion Point system unlocks at Level 50*\n\n"
        return markdown
    end
    
    local hasSlottableSkills = false
    
    if cpData.disciplines and #cpData.disciplines > 0 then
        for _, discipline in ipairs(cpData.disciplines) do
            local slottableSkills = discipline.slottableSkills or {}
            if #slottableSkills > 0 then
                hasSlottableSkills = true
                
                if format == "discord" then
                    markdown = markdown .. (discipline.emoji or "⚔️") .. " **" .. discipline.name .. "**\n"
                    for _, skill in ipairs(slottableSkills) do
                        local skillText = CM.utils.CreateCPSkillLink(skill.name, format)
                        markdown = markdown .. "• " .. skillText .. ": " .. skill.points .. "\n"
                    end
                    markdown = markdown .. "\n"
                else
                    markdown = markdown .. "### " .. (discipline.emoji or "⚔️") .. " " .. discipline.name .. "\n\n"
                    
                    for _, skill in ipairs(slottableSkills) do
                        local status = GetSlottableStatus(skill, cpData.analysis and cpData.analysis.maxSlottablePerDiscipline or 3)
                        local skillText = CM.utils.CreateCPSkillLink(skill.name, format)
                        markdown = markdown .. "- " .. status .. " **" .. skillText .. "**: " .. skill.points .. " points\n"
                    end
                    markdown = markdown .. "\n"
                end
            end
        end
    end
    
    if not hasSlottableSkills then
        markdown = markdown .. "*No slottable Champion Point skills found*\n\n"
    end
    
    return markdown
end

-- =====================================================
-- MAIN CHAMPION POINTS GENERATOR (ENHANCED)
-- =====================================================

local function GenerateChampionPoints(cpData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    local totalCP = cpData.total or 0
    
    if format == "discord" then
        markdown = markdown .. "**Champion Points:**\n"
    else
        markdown = markdown .. "## ⭐ Champion Points\n\n"
    end
    
    if totalCP < 10 then
        markdown = markdown .. "*Champion Point system unlocks at Level 50*\n\n"
    else
        local spentCP = cpData.spent or 0
        -- Use API value for available CP if available, otherwise calculate
        local availableCP = cpData.available or (totalCP - spentCP)
        
        if format == "discord" then
            markdown = markdown .. "Total: " .. CM.utils.FormatNumber(totalCP) .. " | "
            markdown = markdown .. "Spent: " .. CM.utils.FormatNumber(spentCP) .. " | "
            markdown = markdown .. "Available: " .. CM.utils.FormatNumber(availableCP) .. "\n"
            
            if cpData.disciplines and #cpData.disciplines > 0 then
                for _, discipline in ipairs(cpData.disciplines) do
                    markdown = markdown .. (discipline.emoji or "⚔️") .. " **" .. discipline.name .. "** (" .. CM.utils.FormatNumber(discipline.total) .. ")\n"
                    if discipline.skills and #discipline.skills > 0 then
                        for _, skill in ipairs(discipline.skills) do
                            local skillText = CM.utils.CreateCPSkillLink(skill.name, format)
                            markdown = markdown .. "• " .. skillText .. ": " .. skill.points .. "\n"
                        end
                    end
                    markdown = markdown .. "\n"
                end
            end
        else
            -- Compact table format
            markdown = markdown .. "| Category | Value |\n"
            markdown = markdown .. "|:---------|------:|\n"
            markdown = markdown .. "| **Total** | " .. CM.utils.FormatNumber(totalCP) .. " |\n"
            markdown = markdown .. "| **Spent** | " .. CM.utils.FormatNumber(spentCP) .. " |\n"
            if availableCP > 0 then
                markdown = markdown .. "| **Available** | " .. CM.utils.FormatNumber(availableCP) .. " ⚠️ |\n"
            else
                markdown = markdown .. "| **Available** | " .. CM.utils.FormatNumber(availableCP) .. " |\n"
            end
            markdown = markdown .. "\n"
            
            if cpData.disciplines and #cpData.disciplines > 0 then
                -- Calculate max possible points per discipline (CP 3.0 system allows up to 660 per tree)
                local maxPerDiscipline = 660
                
                for _, discipline in ipairs(cpData.disciplines) do
                    local disciplinePercent = math.floor((discipline.total / maxPerDiscipline) * 100)
                    local progressBar = CM.utils.GenerateProgressBar(disciplinePercent, 12)
                    
                    markdown = markdown .. "### " .. (discipline.emoji or "⚔️") .. " " .. discipline.name .. 
                                         " (" .. CM.utils.FormatNumber(discipline.total) .. "/" .. maxPerDiscipline .. " points) " .. 
                                         progressBar .. " " .. disciplinePercent .. "%\n\n"
                    if discipline.skills and #discipline.skills > 0 then
                        for _, skill in ipairs(discipline.skills) do
                            local skillText = CM.utils.CreateCPSkillLink(skill.name, format)
                            local pointText = skill.points == 1 and "point" or "points"
                            markdown = markdown .. "- **" .. skillText .. "**: " .. skill.points .. " " .. pointText .. "\n"
                        end
                        markdown = markdown .. "\n"
                    end
                end
            end
            
            markdown = markdown .. "---\n\n"
        end
    end
    
    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateChampionPoints = GenerateChampionPoints
CM.generators.sections.GenerateDetailedChampionPoints = GenerateDetailedChampionPoints
CM.generators.sections.GenerateSlottableChampionPoints = GenerateSlottableChampionPoints

return {
    GenerateChampionPoints = GenerateChampionPoints,
    GenerateDetailedChampionPoints = GenerateDetailedChampionPoints,
    GenerateSlottableChampionPoints = GenerateSlottableChampionPoints
}
