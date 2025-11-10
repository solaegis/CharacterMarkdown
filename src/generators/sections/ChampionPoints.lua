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
    
    -- GenerateAnchor is in CM.utils.markdown (from AdvancedMarkdown.lua)
    if not CM.utils.GenerateAnchor then
        if CM.utils and CM.utils.markdown and CM.utils.markdown.GenerateAnchor then
            CM.utils.GenerateAnchor = CM.utils.markdown.GenerateAnchor
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
-- Note: Unassigned CP is a shared pool, but we show it per discipline to indicate
-- "available capacity" (max - assigned) for each discipline
local function GetAvailableCPBreakdown(cpData)
    if not cpData or not cpData.disciplines then
        return ""
    end
    
    local DisciplineType = CM.constants and CM.constants.DisciplineType
    if not DisciplineType then
        return ""
    end
    
    -- Get unassigned CP (shared pool)
    local totalUnassigned = cpData.available or 0
    if totalUnassigned == 0 and cpData.total and cpData.spent then
        totalUnassigned = math.max(0, cpData.total - cpData.spent)
    end
    
    -- Get assigned points per discipline
    local craftAssigned = 0
    local warfareAssigned = 0
    local fitnessAssigned = 0
    
    for _, discipline in ipairs(cpData.disciplines) do
        local name = discipline.name or ""
        local assigned = discipline.assigned or discipline.total or 0
        
        if name == DisciplineType.CRAFT then
            craftAssigned = assigned
        elseif name == DisciplineType.WARFARE then
            warfareAssigned = assigned
        elseif name == DisciplineType.FITNESS then
            fitnessAssigned = assigned
        end
    end
    
    -- Calculate "available capacity" per discipline
    -- Max per discipline = assigned + unassigned (shared pool)
    -- Available capacity = max - assigned = (assigned + unassigned) - assigned = unassigned
    -- Since unassigned is shared, all disciplines show the same available capacity
    -- This represents "how much more can be allocated to this discipline"
    local unassignedCraft = totalUnassigned
    local unassignedWarfare = totalUnassigned
    local unassignedFitness = totalUnassigned
    
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
        local anchorId = CM.utils.GenerateAnchor and CM.utils.GenerateAnchor("⭐ Slottable Champion Points") or "slottable-champion-points"
        markdown = markdown .. string_format('<a id="%s"></a>\n\n', anchorId)
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
        local anchorId = CM.utils.GenerateAnchor and CM.utils.GenerateAnchor("⭐ Champion Points") or "champion-points"
        markdown = markdown .. string_format('<a id="%s"></a>\n\n', anchorId)
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
        -- Compact table format (row layout)
        markdown = markdown .. "| **Total** | **Spent** | **Available** |\n"
        markdown = markdown .. "|:---------:|:---------:|:-------------:|\n"
        if availableCP > 0 then
            markdown = markdown .. "| " .. CM.utils.FormatNumber(totalCP) .. " | " .. CM.utils.FormatNumber(spentCP) .. " | " .. CM.utils.FormatNumber(availableCP) .. " ⚠️ |\n"
        else
            markdown = markdown .. "| " .. CM.utils.FormatNumber(totalCP) .. " | " .. CM.utils.FormatNumber(spentCP) .. " | " .. CM.utils.FormatNumber(availableCP) .. " |\n"
        end
        markdown = markdown .. "\n"
        
        -- Always show disciplines section if data exists
        if cpData.disciplines and #cpData.disciplines > 0 then
            local hasDisciplinesWithPoints = false
            local unassignedCP = availableCP or 0  -- Unassigned CP (shared pool)
            
            for _, discipline in ipairs(cpData.disciplines) do
                local disciplineTotal = discipline.total or 0
                local disciplineAssigned = discipline.assigned or disciplineTotal  -- Use assigned from API, fallback to total
                
                -- Calculate max per discipline: assigned + unassigned (per API guide)
                -- Max = what's already assigned + what's available to assign
                local maxPerDiscipline = disciplineAssigned + unassignedCP
                
                -- Ensure max is at least equal to assigned (safety check)
                if maxPerDiscipline < disciplineAssigned then
                    maxPerDiscipline = disciplineAssigned
                end
                
                -- Use total (spent) for display, but assigned for max calculation
                -- This ensures progress bar shows correct percentage
                
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
                    local disciplineAssigned = discipline.assigned or 0
                    local maxPerDiscipline = disciplineAssigned + unassignedCP
                    if maxPerDiscipline == 0 then
                        maxPerDiscipline = unassignedCP  -- At least show unassigned as max if nothing assigned
                    end
                    
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
        
        local anchorId = CM.utils.GenerateAnchor and CM.utils.GenerateAnchor("⭐ Constellation Breakdown (All Stars)") or "constellation-breakdown-all-stars"
        markdown = markdown .. string_format('<a id="%s"></a>\n\n', anchorId)
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
        -- Create lookup map from discipline.skills for isSlottable flag
        local skillSlottableMap = {}
        if discipline.skills then
            for _, skill in ipairs(discipline.skills) do
                if skill.skillId then
                    skillSlottableMap[skill.skillId] = skill.isSlottable or false
                end
            end
        end
        
        for _, star in ipairs(allStars) do
            local points = star.points
            -- Check if points exists and is a number > 0
            if points and type(points) == "number" and points > 0 then
                -- Get isSlottable from collector data (API-based), fallback to hardcoded map if needed
                local isSlottable = false
                if star.skillId and skillSlottableMap[star.skillId] ~= nil then
                    isSlottable = skillSlottableMap[star.skillId]
                else
                    -- Fallback to hardcoded map (shouldn't happen if collector worked correctly)
                    isSlottable = slottableSkillsMap[star.name] or false
                end
                
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
                    -- Max = assigned + unassigned (shared pool)
                    local unassignedCP = (cpData and cpData.available) or 0
                    local disciplineAssigned = discipline.assigned or assignedPoints
                    local maxPoints = disciplineAssigned + unassignedCP
                    
                    -- Ensure max is at least equal to assigned (safety check)
                    if maxPoints < assignedPoints then
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
        local anchorId = CM.utils.GenerateAnchor and CM.utils.GenerateAnchor("⭐ Champion Point Star Allocations") or "champion-point-star-allocations"
        markdown = markdown .. string_format('<a id="%s"></a>\n\n', anchorId)
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
