-- CharacterMarkdown - Enhanced Champion Points Generator
-- Phase 4: Detailed allocation analysis and optimization suggestions

local CM = CharacterMarkdown
local string_format = string.format

-- =====================================================
-- CONSTANTS
-- =====================================================

local CP_CONSTANTS = {
    MIN_CP_FOR_SYSTEM = 10,
    MAX_CP_PER_DISCIPLINE = 660,
    PROGRESS_BAR_LENGTH = 12,
}

-- =====================================================
-- UTILITIES
-- =====================================================

local function InitializeUtilities()
    if not CM.utils then
        CM.utils = {}
    end
    
    -- Lazy load utilities from correct modules
    -- FormatNumber is in CM.utils (from Formatters.lua) - should already be set, but check
    if not CM.utils.FormatNumber then
        -- Fallback: create a simple formatter if module not loaded
        CM.utils.FormatNumber = function(num)
            if not num then return "0" end
            return tostring(math.floor(num))
        end
    end
    
    -- CreateCPSkillLink is in CM.links (from Systems.lua)
    if not CM.utils.CreateCPSkillLink then
        if CM.links and CM.links.CreateCPSkillLink then
            CM.utils.CreateCPSkillLink = CM.links.CreateCPSkillLink
        else
            -- Fallback: return name as-is if links module not loaded
            CM.utils.CreateCPSkillLink = function(name, format)
                return name or ""
            end
        end
    end
    
    -- GenerateProgressBar is in CM.generators.helpers (from helpers/Utilities.lua)
    if not CM.utils.GenerateProgressBar then
        if CM.generators and CM.generators.helpers and CM.generators.helpers.GenerateProgressBar then
            CM.utils.GenerateProgressBar = CM.generators.helpers.GenerateProgressBar
        else
            -- Fallback: create a simple progress bar if module not loaded
            CM.utils.GenerateProgressBar = function(percent, width)
                width = width or 12
                local filled = math.floor((percent / 100) * width)
                local empty = width - filled
                return string.rep("█", filled) .. string.rep("░", empty)
            end
        end
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

-- Calculate available CP breakdown by discipline (⚒️ Craft - ⚔️ Warfare - 💪 Fitness)
local function GetAvailableCPBreakdown(cpData)
    if not cpData or not cpData.disciplines then
        return ""
    end
    
    local DisciplineType = CM.constants and CM.constants.DisciplineType
    if not DisciplineType then
        return ""
    end
    
    local unassignedCraft = 0
    local unassignedWarfare = 0
    local unassignedFitness = 0
    
    local totalAvailable = cpData.available or 0
    if totalAvailable == 0 and cpData.total and cpData.spent then
        totalAvailable = math.max(0, cpData.total - cpData.spent)
    end
    
    -- Get spent points and max allocated per discipline
    local cp1 = 0  -- Warfare
    local cp2 = 0  -- Fitness
    local cp3 = 0  -- Craft
    local max1 = 0  -- Warfare max
    local max2 = 0  -- Fitness max
    local max3 = 0  -- Craft max
    
    for _, discipline in ipairs(cpData.disciplines) do
        local name = discipline.name or ""
        local total = discipline.total or 0
        local maxAllocated = discipline.maxAllocated or 0
        
        if name == DisciplineType.WARFARE then
            cp1 = total
            max1 = maxAllocated
        elseif name == DisciplineType.FITNESS then
            cp2 = total
            max2 = maxAllocated
        elseif name == DisciplineType.CRAFT then
            cp3 = total
            max3 = maxAllocated
        end
    end
    
    -- Calculate unassigned points per discipline
    -- CRITICAL: In CP 3.0, GetChampionPointsInDiscipline returns the MAXIMUM that CAN be allocated
    -- (based on total CP), NOT the current allocated (spent + unassigned)
    -- We need to calculate current allocated = spent + unassigned, where unassigned is distributed from totalAvailable
    
    -- Check if maxAllocated values are actually the maximum possible (theoretical max) or current allocated
    local theoreticalMaxPerDiscipline = math.floor((cpData.total or 0) / 3)
    local usedMaxAllocated = false
    
    -- For Craft
    if max3 > 0 and max3 >= cp3 then
        -- Check if this is theoretical max or current allocated
        if max3 == theoreticalMaxPerDiscipline or max3 == theoreticalMaxPerDiscipline + 1 then
            -- This is theoretical max, not current allocated - calculate from totalAvailable
            CM.DebugPrint("CP", string_format("Craft: max3=%d is theoretical max, calculating unassigned from totalAvailable", max3))
        else
            -- This might be current allocated - use it
            unassignedCraft = max3 - cp3
            usedMaxAllocated = true
            CM.DebugPrint("CP", string_format("Craft: Using API maxAllocated %d, spent %d, unassigned %d", max3, cp3, unassignedCraft))
        end
    end
    
    if not usedMaxAllocated and totalAvailable > 0 then
        -- Calculate from totalAvailable using better distribution
        local totalSpent = cp1 + cp2 + cp3
        if totalSpent > 0 then
            -- Distribute proportionally to spent points
            local craftRatio = (cp3 > 0) and (cp3 / totalSpent) or (1 / 3)
            unassignedCraft = math.max(0, math.floor(totalAvailable * craftRatio))
        else
            unassignedCraft = math.floor(totalAvailable / 3)
        end
        CM.DebugPrint("CP", string_format("Craft: Calculated from totalAvailable %d, unassigned %d", totalAvailable, unassignedCraft))
    end
    
    usedMaxAllocated = false
    -- For Warfare
    if max1 > 0 and max1 >= cp1 then
        if max1 == theoreticalMaxPerDiscipline or max1 == theoreticalMaxPerDiscipline + 1 then
            CM.DebugPrint("CP", string_format("Warfare: max1=%d is theoretical max, calculating unassigned from totalAvailable", max1))
        else
            unassignedWarfare = max1 - cp1
            usedMaxAllocated = true
            CM.DebugPrint("CP", string_format("Warfare: Using API maxAllocated %d, spent %d, unassigned %d", max1, cp1, unassignedWarfare))
        end
    end
    
    if not usedMaxAllocated and totalAvailable > 0 then
        local totalSpent = cp1 + cp2 + cp3
        if totalSpent > 0 then
            local warfareRatio = (cp1 > 0) and (cp1 / totalSpent) or (1 / 3)
            unassignedWarfare = math.max(0, math.floor(totalAvailable * warfareRatio))
        else
            unassignedWarfare = math.floor(totalAvailable / 3)
        end
        CM.DebugPrint("CP", string_format("Warfare: Calculated from totalAvailable %d, unassigned %d", totalAvailable, unassignedWarfare))
    end
    
    usedMaxAllocated = false
    -- For Fitness
    if max2 > 0 and max2 >= cp2 then
        if max2 == theoreticalMaxPerDiscipline or max2 == theoreticalMaxPerDiscipline + 1 then
            CM.DebugPrint("CP", string_format("Fitness: max2=%d is theoretical max, calculating unassigned from totalAvailable", max2))
        else
            unassignedFitness = max2 - cp2
            usedMaxAllocated = true
            CM.DebugPrint("CP", string_format("Fitness: Using API maxAllocated %d, spent %d, unassigned %d", max2, cp2, unassignedFitness))
        end
    end
    
    if not usedMaxAllocated and totalAvailable > 0 then
        local totalSpent = cp1 + cp2 + cp3
        if totalSpent > 0 then
            local fitnessRatio = (cp2 > 0) and (cp2 / totalSpent) or (1 / 3)
            unassignedFitness = math.max(0, math.floor(totalAvailable * fitnessRatio))
        else
            unassignedFitness = math.floor(totalAvailable / 3)
        end
        CM.DebugPrint("CP", string_format("Fitness: Calculated from totalAvailable %d, unassigned %d", totalAvailable, unassignedFitness))
    end
    
    -- Adjust for rounding differences to ensure total matches totalAvailable
    -- This is critical when using fallback calculations from totalAvailable
    local calculatedTotal = unassignedCraft + unassignedWarfare + unassignedFitness
    local difference = totalAvailable - calculatedTotal
    if difference ~= 0 and totalAvailable > 0 then
        -- Distribute the difference to make total match totalAvailable exactly
        -- This handles rounding errors from proportional distribution
        if math.abs(difference) <= 3 then
            -- Small difference: distribute to balance the values
            if difference > 0 then
                -- Add to the discipline with the lowest unassigned
                if unassignedCraft <= unassignedWarfare and unassignedCraft <= unassignedFitness then
                    unassignedCraft = unassignedCraft + difference
                elseif unassignedWarfare <= unassignedFitness then
                    unassignedWarfare = unassignedWarfare + difference
                else
                    unassignedFitness = unassignedFitness + difference
                end
            else
                -- Subtract from the discipline with the highest unassigned
                if unassignedCraft >= unassignedWarfare and unassignedCraft >= unassignedFitness then
                    unassignedCraft = unassignedCraft + difference
                elseif unassignedWarfare >= unassignedFitness then
                    unassignedWarfare = unassignedWarfare + difference
                else
                    unassignedFitness = unassignedFitness + difference
                end
            end
        else
            -- Larger difference: redistribute more evenly
            -- Calculate target values that sum to totalAvailable
            local avg = math.floor(totalAvailable / 3)
            local remainder = totalAvailable - (avg * 3)
            
            -- Start with equal distribution
            unassignedCraft = avg
            unassignedWarfare = avg
            unassignedFitness = avg
            
            -- Distribute remainder (0, 1, or 2 points)
            if remainder >= 1 then
                unassignedCraft = unassignedCraft + 1
            end
            if remainder >= 2 then
                unassignedWarfare = unassignedWarfare + 1
            end
            
            CM.DebugPrint("CP", string_format("Redistributed unassigned CP: Craft=%d, Warfare=%d, Fitness=%d (total=%d)", 
                unassignedCraft, unassignedWarfare, unassignedFitness, unassignedCraft + unassignedWarfare + unassignedFitness))
        end
    end
    
    return string_format("⚒️ %d - ⚔️ %d - 💪 %d", unassignedCraft, unassignedWarfare, unassignedFitness)
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

-- Get point text (singular/plural)
local function GetPointText(points)
    return points == 1 and "point" or "points"
end

-- Get slotted champion point skill IDs
local function GetSlottedChampionSkillIds()
    local slottedIds = {}
    
    -- Check if HOTBAR_CATEGORY_CHAMPION exists (ESO API)
    local success, category = pcall(function() return HOTBAR_CATEGORY_CHAMPION end)
    if not success or not category then
        -- Fallback: try alternative API methods
        CM.DebugPrint("CP", "HOTBAR_CATEGORY_CHAMPION not available, trying alternative methods")
        return slottedIds
    end
    
    -- Champion bar typically has slots 1-12 (3 per discipline, up to 4 per discipline at higher CP)
    -- Check slots 1-12 for champion abilities
    for slotIndex = 1, 12 do
        local slotSuccess, abilityId = pcall(GetSlotBoundId, slotIndex, category)
        if slotSuccess and abilityId and abilityId > 0 then
            table.insert(slottedIds, abilityId)
            CM.DebugPrint("CP", string_format("Found slotted CP skill ID %d in slot %d", abilityId, slotIndex))
        end
    end
    
    return slottedIds
end

-- Get discipline skills (unified from multiple sources)
local function GetDisciplineSkills(discipline)
    -- Prefer main skills array if populated
    if discipline.skills and #discipline.skills > 0 then
        return discipline.skills, "mixed"
    end
    
    -- Fallback to separated arrays
    local slottable = discipline.slottableSkills or {}
    local passive = discipline.passiveSkills or {}
    if #slottable > 0 or #passive > 0 then
        local combined = {}
        for _, s in ipairs(slottable) do
            table.insert(combined, {name = s.name, points = s.points, type = "slottable", isSlottable = true})
        end
        for _, s in ipairs(passive) do
            table.insert(combined, {name = s.name, points = s.points, type = "passive", isSlottable = false})
        end
        return combined, "separated"
    end
    
    return {}, "none"
end

-- Format discipline summary (reduces duplication)
local function FormatDisciplineSummary(discipline, format)
    local emoji = discipline.emoji or "⚔️"
    local name = discipline.name
    local total = CM.utils.FormatNumber(discipline.total)
    
    if format == "discord" then
        return string_format("%s **%s** (%s)\n", emoji, name, total)
    else
        return string_format("### %s %s (%s CP)\n\n", emoji, name, total)
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
        local totalSlottable = (cpData.analysis and cpData.analysis.slottableSkills) or 0
        local maxSlottable = (cpData.analysis and cpData.analysis.maxSlottablePerDiscipline) or 3
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
    -- Optimization Suggestions section disabled - return empty string
    return ""
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
    
    if totalCP < CP_CONSTANTS.MIN_CP_FOR_SYSTEM then
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
                    markdown = markdown .. FormatDisciplineSummary(discipline, format)
                    for _, skill in ipairs(slottableSkills) do
                        local skillText = CM.utils.CreateCPSkillLink(skill.name, format)
                        markdown = markdown .. "• " .. skillText .. ": " .. skill.points .. "\n"
                    end
                    markdown = markdown .. "\n"
                else
                    markdown = markdown .. FormatDisciplineSummary(discipline, format)
                    
                    for _, skill in ipairs(slottableSkills) do
                        local maxSlottable = (cpData.analysis and cpData.analysis.maxSlottablePerDiscipline) or 3
                        local status = GetSlottableStatus(skill, maxSlottable)
                        local skillText = CM.utils.CreateCPSkillLink(skill.name, format)
                        local pointText = GetPointText(skill.points)
                        markdown = markdown .. string_format("- %s **%s**: %d %s\n", status, skillText, skill.points, pointText)
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
    
    -- Handle nil or empty cpData - always generate section header
    if not cpData then
        CM.DebugPrint("CP", "GenerateChampionPoints: cpData is nil")
        cpData = {}
    end
    
    local totalCP = cpData.total or 0
    CM.DebugPrint("CP", string_format("GenerateChampionPoints: totalCP=%d, format=%s", totalCP, format or "nil"))
    
    -- Always generate header when section is enabled
    if format == "discord" then
        markdown = markdown .. "**Champion Points:**\n"
    else
        markdown = markdown .. "## ⭐ Champion Points\n\n"
    end
    
    -- If no CP data or CP system not unlocked, show message and return
    if totalCP < CP_CONSTANTS.MIN_CP_FOR_SYSTEM then
        markdown = markdown .. "*Champion Point system unlocks at Level 50*\n\n"
        if format ~= "discord" then
            markdown = markdown .. "---\n\n"
        end
        return markdown
    end
    
    local spentCP = cpData.spent or 0
    -- Use API value for available CP if available, otherwise calculate
    local availableCP = cpData.available or (totalCP - spentCP)
    
    if format == "discord" then
        markdown = markdown .. "Total: " .. CM.utils.FormatNumber(totalCP) .. " | "
        markdown = markdown .. "Spent: " .. CM.utils.FormatNumber(spentCP) .. " | "
        markdown = markdown .. "Available: " .. CM.utils.FormatNumber(availableCP) .. "\n"
        
        if cpData.disciplines and #cpData.disciplines > 0 then
            for _, discipline in ipairs(cpData.disciplines) do
                markdown = markdown .. FormatDisciplineSummary(discipline, format)
                local skills, _ = GetDisciplineSkills(discipline)
                if #skills > 0 then
                    for _, skill in ipairs(skills) do
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
        
        -- Always show disciplines section if data exists
        if cpData.disciplines and #cpData.disciplines > 0 then
            -- Calculate max possible points per discipline (CP 3.0 system allows up to 660 per tree)
            -- Use discipline.maxAllocated if available, otherwise use constant or scale from total CP
            local defaultMaxPerDiscipline = CP_CONSTANTS.MAX_CP_PER_DISCIPLINE
            if cpData.total and cpData.total > 0 and cpData.total < 1980 then
                -- Scale down for lower CP totals (90% of equal distribution)
                defaultMaxPerDiscipline = math.floor((cpData.total / 3) * 0.9)
            end
            -- Ensure defaultMaxPerDiscipline is never 0 (fallback to constant if calculation fails)
            if defaultMaxPerDiscipline == 0 then
                defaultMaxPerDiscipline = CP_CONSTANTS.MAX_CP_PER_DISCIPLINE
            end
            
            local hasDisciplinesWithPoints = false
            
            for _, discipline in ipairs(cpData.disciplines) do
                local disciplineTotal = discipline.total or 0
                -- Use maxAllocated if it's a valid positive number, otherwise use default
                local maxPerDiscipline = (discipline.maxAllocated and discipline.maxAllocated > 0) and discipline.maxAllocated or defaultMaxPerDiscipline
                
                -- Ensure maxPerDiscipline is never 0 (use default if calculated value is 0)
                if maxPerDiscipline == 0 then
                    maxPerDiscipline = defaultMaxPerDiscipline
                end
                
                -- CRITICAL: Max can never be less than spent points
                -- If spent points exceed the calculated max, use spent points as minimum max
                -- This handles cases where API returns incorrect max or user has redistributed points
                if disciplineTotal > maxPerDiscipline then
                    CM.DebugPrint("CP", string_format("Discipline %s: spent (%d) > max (%d), adjusting max to spent", 
                        discipline.name or "Unknown", disciplineTotal, maxPerDiscipline))
                    maxPerDiscipline = disciplineTotal
                end
                
                -- Show all disciplines (even with 0 points) so user can see the structure
                -- But mark those with 0 points differently
                if disciplineTotal > 0 then
                    hasDisciplinesWithPoints = true
                    -- Safety check: avoid division by zero
                    local disciplinePercent = maxPerDiscipline > 0 and math.floor((disciplineTotal / maxPerDiscipline) * 100) or 0
                    local progressBar = CM.utils.GenerateProgressBar(disciplinePercent, CP_CONSTANTS.PROGRESS_BAR_LENGTH)
                    
                    markdown = markdown .. "### " .. (discipline.emoji or "⚔️") .. " " .. discipline.name .. 
                                         " (" .. CM.utils.FormatNumber(disciplineTotal) .. "/" .. maxPerDiscipline .. " points) " .. 
                                         progressBar .. " " .. disciplinePercent .. "%\n\n"
                    
                    -- Show skills breakdown using unified function
                    local skills, skillSource = GetDisciplineSkills(discipline)
                    local hasSkills = #skills > 0
                    
                    if hasSkills then
                        for _, skill in ipairs(skills) do
                            local skillText = CM.utils.CreateCPSkillLink(skill.name, format)
                            local pointText = GetPointText(skill.points)
                            local skillType = skill.type or (skill.isSlottable and "slottable" or "passive")
                            
                            if skillSource == "separated" then
                                -- Show type indicator when using separated arrays
                                local typeEmoji = skillType == "slottable" and "⭐" or "🔒"
                                markdown = markdown .. string_format("- %s **%s**: %d %s (%s)\n", 
                                    typeEmoji, skillText, skill.points, pointText, skillType:gsub("^%l", string.upper))
                            else
                                -- Standard format for mixed array
                                markdown = markdown .. string_format("- **%s**: %d %s\n", 
                                    skillText, skill.points, pointText)
                            end
                        end
                    end
                    
                    if hasSkills then
                        markdown = markdown .. "\n"
                    else
                        -- If discipline has points but no skills listed, show a note
                        markdown = markdown .. "*Points assigned but skill details not available*\n\n"
                    end
                else
                    -- Show discipline even with 0 points (for visibility)
                    local disciplinePercent = 0
                    local progressBar = CM.utils.GenerateProgressBar(0, CP_CONSTANTS.PROGRESS_BAR_LENGTH)
                    
                    markdown = markdown .. "### " .. (discipline.emoji or "⚔️") .. " " .. discipline.name .. 
                                         " (0/" .. maxPerDiscipline .. " points) " .. 
                                         progressBar .. " 0%\n\n"
                    markdown = markdown .. "*No points assigned to this discipline*\n\n"
                end
            end
        else
            -- No disciplines data available - still show section
            markdown = markdown .. "*Champion Point discipline data not available*\n\n"
        end
        
        if format ~= "discord" then
            markdown = markdown .. "---\n\n"
        end
    end
    
    -- Ensure we always return something (defensive check)
    if markdown == "" or (format ~= "discord" and not markdown:match("## ⭐ Champion Points")) then
        -- Fallback: return at least header
        if format == "discord" then
            return "**Champion Points:**\n*Data not available*\n\n"
        else
            return "## ⭐ Champion Points\n\n*Champion Point data not available*\n\n---\n\n"
        end
    end
    
    return markdown
end

-- =====================================================
-- CONSTELLATION TABLE GENERATOR (All Stars)
-- =====================================================

local function GenerateConstellationTable(cpData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if not cpData or not cpData.disciplines or #cpData.disciplines == 0 then
        CM.DebugPrint("CP", "GenerateConstellationTable: No CP data or disciplines available")
        return ""
    end
    
    CM.DebugPrint("CP", string_format("GenerateConstellationTable: Processing %d disciplines", #cpData.disciplines))
    
    if format == "discord" then
        markdown = markdown .. "**Constellation Breakdown:**\n"
    else
        -- Investment Summary section removed
        
        markdown = markdown .. "## ⭐ Constellation Breakdown (All Stars)\n\n"
    end
    
    -- Get slotted champion point skill IDs
    local slottedSkillIds = GetSlottedChampionSkillIds()
    
    -- Hardcoded mapping of slottable champion skills (ESO CP 2.0/Update 45)
    local slottableSkillsMap = {
        -- Craft constellation slottable skills (Update 45: many converted to passives)
        ["Steed's Blessing"] = true,
        ["Shadowstrike"] = true,
        ["Gifted Rider"] = true,
        ["Reel Technique"] = true,
        ["Master Gatherer"] = true,
        
        -- Warfare constellation slottable skills - Main Constellation
        ["Deadly Aim"] = true,
        ["Master-at-Arms"] = true,
        ["Wrathful Strikes"] = true,
        ["Thaumaturge"] = true,
        ["Backstabber"] = true,
        ["Fighting Finesse"] = true,
        
        -- Warfare - Mastered Curation (Healing Sub-constellation)
        ["Blessed"] = true,
        ["Eldritch Insight"] = true,
        ["Cleansing Revival"] = true,
        ["Foresight"] = true,
        
        -- Warfare - Extended Might (Damage Sub-constellation)
        ["Arcane Supremacy"] = true,
        ["Ironclad"] = true,
        ["Preparation"] = true,
        ["Exploiter"] = true,
        
        -- Warfare - Staving Death (Defense Sub-constellation)
        ["Fortified"] = true,
        ["Boundless Vitality"] = true,
        ["Survival Instincts"] = true,
        ["Rejuvenation"] = true,
        
        -- Fitness constellation slottable skills - Main Constellation
        ["Tumbling"] = true,
        ["Defiance"] = true,
        ["Siphoning Spells"] = true,
        ["Fortification"] = true,
        ["Hero's Vigor"] = true,
        ["Strategic Reserve"] = true,
        
        -- Fitness - Survivor's Spite (Recovery Sub-constellation)
        ["Bloody Renewal"] = true,
        ["Tireless Discipline"] = true,
        ["Relentlessness"] = true,
        ["Mystic Tenacity"] = true,
        ["Hasty"] = true,
        
        -- Fitness - Wind Chaser (Movement Sub-constellation)
        ["Celerity"] = true,
        ["Piercing Gaze"] = true,
        
        -- Fitness - Walking Fortress (Block Sub-constellation)
        ["Bracing Anchor"] = true,
        ["Shield Expert"] = true,
    }
    
    -- Collect all disciplines with their filtered stars
    -- Order: Craft (1), Warfare (2), Fitness (3)
    -- Use constants to match exact names
    local DisciplineType = CM.constants.DisciplineType
    local disciplineOrder = {
        [DisciplineType.CRAFT] = 1,      -- "Craft"
        [DisciplineType.WARFARE] = 2,    -- "Warfare"
        [DisciplineType.FITNESS] = 3     -- "Fitness"
    }
    
    local disciplinesWithStars = {}
    for _, discipline in ipairs(cpData.disciplines) do
        local allStars = discipline.allStars or {}
        
        -- Filter to only stars with points > 0 and add slot status
        local starsWithPoints = {}
        for _, star in ipairs(allStars) do
            local points = star.points
            -- Check if points exists and is a number > 0
            if points and type(points) == "number" and points > 0 then
                local isSlottable = slottableSkillsMap[star.name] or false
                local isSlotted = false
                
                if isSlottable and star.skillId then
                    for _, slottedId in ipairs(slottedSkillIds) do
                        if slottedId == star.skillId then
                            isSlotted = true
                            break
                        end
                    end
                end
                
                table.insert(starsWithPoints, {
                    name = star.name,
                    points = star.points,
                    skillId = star.skillId,
                    isSlottable = isSlottable,
                    isSlotted = isSlotted
                })
            end
        end
        
        -- Sort by points (highest first)
        table.sort(starsWithPoints, function(a, b)
            return (a.points or 0) > (b.points or 0)
        end)
        
        CM.DebugPrint("CP", string_format("ConstellationTable: %s has %d stars with points (out of %d total)", 
            discipline.name or "Unknown", #starsWithPoints, #allStars))
        
        if #starsWithPoints > 0 then
            local order = disciplineOrder[discipline.name] or 99
            table.insert(disciplinesWithStars, {
                discipline = discipline,
                stars = starsWithPoints,
                order = order
            })
        end
    end
    
    -- Sort by order (Craft, Warfare, Fitness)
    table.sort(disciplinesWithStars, function(a, b)
        return a.order < b.order
    end)
    
    if format == "discord" then
        -- Discord: vertical layout (simpler)
        for _, data in ipairs(disciplinesWithStars) do
            local discipline = data.discipline
            local starsWithPoints = data.stars
            markdown = markdown .. (discipline.emoji or "⚔️") .. " **" .. discipline.name .. "**\n"
            for _, star in ipairs(starsWithPoints) do
                local skillText = CM.utils.CreateCPSkillLink(star.name, format)
                markdown = markdown .. "• " .. skillText .. ": " .. star.points .. "\n"
            end
            markdown = markdown .. "\n"
        end
    else
        -- GitHub/VSCode: newspaper-style multi-column layout using HTML table
        if #disciplinesWithStars > 0 then
            markdown = markdown .. "<table style=\"width: 100%; border-collapse: collapse;\">\n<tr>\n"
            
            for _, data in ipairs(disciplinesWithStars) do
                local discipline = data.discipline
                local starsWithPoints = data.stars
                
                if discipline then
                    -- Calculate total assigned points in this constellation
                    local assignedPoints = 0
                    if starsWithPoints then
                        for _, star in ipairs(starsWithPoints) do
                            if star and star.points then
                                assignedPoints = assignedPoints + (star.points or 0)
                            end
                        end
                    end
                    
                    -- Calculate maximum points for this constellation
                    -- Use discipline.maxAllocated if available, otherwise calculate from total CP / 3
                    local maxPoints = 0
                    if discipline.maxAllocated and discipline.maxAllocated > 0 then
                        maxPoints = discipline.maxAllocated
                    elseif cpData and cpData.total and cpData.total > 0 then
                        -- Distribute total CP equally across 3 constellations (rounded)
                        maxPoints = math.floor(cpData.total / 3)
                    end
                    
                    -- CRITICAL: Max can never be less than assigned points
                    -- If assigned points exceed the calculated max, use assigned points as minimum max
                    if assignedPoints > maxPoints then
                        CM.DebugPrint("CP", string_format("Constellation %s: assigned (%d) > max (%d), adjusting max to assigned", 
                            discipline.name or "Unknown", assignedPoints, maxPoints))
                        maxPoints = assignedPoints
                    end
                    
                    -- Calculate available points for this constellation
                    local availablePoints = 0
                    if maxPoints > 0 then
                        availablePoints = math.max(0, maxPoints - assignedPoints)
                    end
                    
                    -- Build star count information for display below table
                    local starCountInfo = ""
                    if maxPoints > 0 then
                        starCountInfo = string_format("%d/%d star assigned - %d available", assignedPoints, maxPoints, availablePoints)
                    elseif assignedPoints > 0 then
                        starCountInfo = string_format("%d star assigned", assignedPoints)
                    end
                    
                    -- Each column gets equal width, top-aligned, with padding
                    markdown = markdown .. "<td style=\"vertical-align: top; padding: 0 15px; width: 33.33%;\">\n\n"
                    -- Title without emoji - just constellation name
                    markdown = markdown .. "### " .. (discipline.name or "Unknown") .. " Constellation\n\n"
                    
                    markdown = markdown .. "| Star | Points |\n"
                    markdown = markdown .. "|:-----|-------:|\n"
                    
                    -- Add rows for stars with points, including star icons
                    if starsWithPoints then
                        for _, star in ipairs(starsWithPoints) do
                            if star and star.name then
                                local skillText = CM.utils.CreateCPSkillLink(star.name, format)
                                local starIcon = ""
                                
                                if star.isSlottable then
                                    if star.isSlotted then
                                        starIcon = "⭐ "  -- Slotted slottable star
                                    else
                                        starIcon = "☆ "  -- Unslotted slottable star
                                    end
                                end
                                -- Passive skills get no icon
                                
                                markdown = markdown .. "| " .. starIcon .. skillText .. " | " .. (star.points or 0) .. " |\n"
                            end
                        end
                    end
                    
                    -- Add star count info below the table
                    if starCountInfo ~= "" then
                        markdown = markdown .. "\n" .. starCountInfo .. "\n"
                    end
                    
                    markdown = markdown .. "\n</td>\n"
                else
                    CM.Warn("GenerateConstellationTable: discipline is nil, skipping")
                end
            end
            
            markdown = markdown .. "</tr>\n</table>\n\n"
        end
    end
    
    return markdown
end

-- =====================================================
-- CHAMPION POINT STAR TABLES GENERATOR (Assigned Points Only)
-- =====================================================

local function GenerateChampionPointStarTables(cpData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if not cpData or not cpData.disciplines or #cpData.disciplines == 0 then
        CM.DebugPrint("CP", "GenerateChampionPointStarTables: No CP data or disciplines available")
        return ""
    end
    
    local totalCP = cpData.total or 0
    if totalCP < CP_CONSTANTS.MIN_CP_FOR_SYSTEM then
        return ""  -- Don't show tables if CP system not unlocked
    end
    
    CM.DebugPrint("CP", string_format("GenerateChampionPointStarTables: Processing %d disciplines", #cpData.disciplines))
    
    if format == "discord" then
        markdown = markdown .. "**Champion Point Star Allocations:**\n"
    else
        markdown = markdown .. "## ⭐ Champion Point Star Allocations\n\n"
    end
    
    for _, discipline in ipairs(cpData.disciplines) do
        local allStars = discipline.allStars or {}
        
        -- Filter to only stars with assigned points
        local assignedStars = {}
        for _, star in ipairs(allStars) do
            if star.points and star.points > 0 then
                table.insert(assignedStars, star)
            end
        end
        
        CM.DebugPrint("CP", string_format("StarTables: %s has %d stars with assigned points", discipline.name or "Unknown", #assignedStars))
        
        if format == "discord" then
            markdown = markdown .. (discipline.emoji or "⚔️") .. " **" .. discipline.name .. "**\n"
            if #assignedStars > 0 then
                for _, star in ipairs(assignedStars) do
                    local skillText = CM.utils.CreateCPSkillLink(star.name, format)
                    markdown = markdown .. "• " .. skillText .. ": " .. star.points .. " points\n"
                end
            else
                markdown = markdown .. "*No points assigned*\n"
            end
            markdown = markdown .. "\n"
        else
            markdown = markdown .. "### " .. (discipline.emoji or "⚔️") .. " " .. discipline.name .. "\n\n"
            
            if #assignedStars > 0 then
                -- Create table with star name and points
                markdown = markdown .. "| Star | Points |\n"
                markdown = markdown .. "|:-----|-------:|\n"
                
                for _, star in ipairs(assignedStars) do
                    local skillText = CM.utils.CreateCPSkillLink(star.name, format)
                    markdown = markdown .. "| " .. skillText .. " | " .. star.points .. " |\n"
                end
                
                markdown = markdown .. "\n"
            else
                markdown = markdown .. "*No points assigned to this discipline*\n\n"
            end
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
CM.generators.sections.GenerateConstellationTable = GenerateConstellationTable
CM.generators.sections.GenerateChampionPointStarTables = GenerateChampionPointStarTables

return {
    GenerateChampionPoints = GenerateChampionPoints,
    GenerateDetailedChampionPoints = GenerateDetailedChampionPoints,
    GenerateSlottableChampionPoints = GenerateSlottableChampionPoints,
    GenerateConstellationTable = GenerateConstellationTable,
    GenerateChampionPointStarTables = GenerateChampionPointStarTables
}
