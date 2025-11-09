-- CharacterMarkdown - Achievement Markdown Generator
-- Phase 5: Comprehensive achievement tracking and display

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
        CM.utils.GenerateProgressBar = Formatters.GenerateProgressBar
    end
end

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

local function GetAchievementStatusIcon(achievement)
    if achievement.completed then
        return "✅"
    elseif achievement.progress.totalRequired > 0 and achievement.progress.totalProgress > 0 then
        return "🔄"
    else
        return "⚪"
    end
end

local function GetProgressText(achievement)
    if achievement.completed then
        return "Completed"
    elseif achievement.progress.totalRequired > 0 then
        return string.format("%d/%d (%d%%)", 
            achievement.progress.totalProgress, 
            achievement.progress.totalRequired, 
            achievement.progress.progressPercent)
    else
        return "Not Started"
    end
end

local function GetCategoryEmoji(categoryName)
    local emojis = {
        ["Combat"] = "⚔️",
        ["PvP"] = "🏰",
        ["Exploration"] = "🗺️",
        ["Skyshards"] = "⭐",
        ["Lorebooks"] = "📚",
        ["Crafting"] = "⚒️",
        ["Economy"] = "💰",
        ["Social"] = "👥",
        ["Dungeons"] = "🏰",  -- Changed from 🏛️ for better compatibility
        ["Character"] = "📈",
        ["Vampire"] = "🧛",
        ["Werewolf"] = "🐺",
        ["Collectibles"] = "🎨",
        ["Housing"] = "🏠",
        ["Events"] = "🎉",
        ["Miscellaneous"] = "🔧"
    }
    return emojis[categoryName] or "🔧"
end

-- =====================================================
-- ACHIEVEMENT SUMMARY GENERATOR
-- =====================================================

local function GenerateAchievementSummary(achievementData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Achievement Progress:**\n"
    else
        markdown = markdown .. "## 🏆 Achievement Progress\n\n"
    end
    
    local summary = achievementData.summary
    
    if format == "discord" then
        markdown = markdown .. "Total: " .. CM.utils.FormatNumber(summary.totalAchievements) .. " | "
        markdown = markdown .. "Completed: " .. CM.utils.FormatNumber(summary.completedAchievements) .. " | "
        markdown = markdown .. "Progress: " .. summary.completionPercent .. "%\n"
        markdown = markdown .. "Points: " .. CM.utils.FormatNumber(summary.earnedPoints) .. "/" .. CM.utils.FormatNumber(summary.totalPoints) .. "\n"
    else
        markdown = markdown .. "| Metric | Value |\n"
        markdown = markdown .. "|:-------|------:|\n"
        markdown = markdown .. "| **Total Achievements** | " .. CM.utils.FormatNumber(summary.totalAchievements) .. " |\n"
        markdown = markdown .. "| **Completed** | " .. CM.utils.FormatNumber(summary.completedAchievements) .. " |\n"
        markdown = markdown .. "| **Completion %** | " .. summary.completionPercent .. "% |\n"
        markdown = markdown .. "| **Points Earned** | " .. CM.utils.FormatNumber(summary.earnedPoints) .. " |\n"
        markdown = markdown .. "| **Total Points** | " .. CM.utils.FormatNumber(summary.totalPoints) .. " |\n"
        markdown = markdown .. "\n"
    end
    
    return markdown
end

-- =====================================================
-- ACHIEVEMENT CATEGORIES GENERATOR
-- =====================================================

local function GenerateAchievementCategories(achievementData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    local categories = achievementData.categories
    if not categories then
        return markdown
    end
    
    -- Check if there are any categories with data
    local hasCategories = false
    for categoryName, categoryData in pairs(categories) do
        if categoryData.total > 0 then
            hasCategories = true
            break
        end
    end
    
    -- Only generate section if there are categories with data
    if not hasCategories then
        return markdown
    end
    
    if format == "discord" then
        markdown = markdown .. "**Achievement Categories:**\n"
    else
        markdown = markdown .. "### 📊 Achievement Categories\n\n"
    end
    
    if format == "discord" then
        for categoryName, categoryData in pairs(categories) do
            if categoryData.total > 0 then
                local emoji = GetCategoryEmoji(categoryName)
                local percent = categoryData.total > 0 and math.floor((categoryData.completed / categoryData.total) * 100) or 0
                markdown = markdown .. emoji .. " **" .. categoryName .. "**: " .. categoryData.completed .. "/" .. categoryData.total .. " (" .. percent .. "%)\n"
            end
        end
    else
        markdown = markdown .. "| Category | Completed | Total | Progress | Points |\n"
        markdown = markdown .. "|:---------|----------:|------:|---------:|------:|\n"
        
        for categoryName, categoryData in pairs(categories) do
            if categoryData.total > 0 then
                local emoji = GetCategoryEmoji(categoryName)
                local percent = categoryData.total > 0 and math.floor((categoryData.completed / categoryData.total) * 100) or 0
                local progressBar = CM.utils.GenerateProgressBar(percent, 8)
                
                markdown = markdown .. "| " .. emoji .. " **" .. categoryName .. "** | " .. 
                    categoryData.completed .. " | " .. categoryData.total .. " | " .. 
                    progressBar .. " " .. percent .. "% | " .. CM.utils.FormatNumber(categoryData.points) .. " |\n"
            end
        end
        markdown = markdown .. "\n"
    end
    
    return markdown
end

-- =====================================================
-- IN-PROGRESS ACHIEVEMENTS GENERATOR
-- =====================================================

local function GenerateInProgressAchievements(achievementData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**In-Progress Achievements:**\n"
    else
        markdown = markdown .. "### 🔄 In-Progress Achievements\n\n"
    end
    
    local inProgress = achievementData.inProgress
    
    if #inProgress == 0 then
        markdown = markdown .. "*No achievements currently in progress*\n\n"
        return markdown
    end
    
    if format == "discord" then
        for _, achievement in ipairs(inProgress) do
            local statusIcon = GetAchievementStatusIcon(achievement)
            local progressText = GetProgressText(achievement)
            markdown = markdown .. statusIcon .. " **" .. achievement.name .. "**: " .. progressText .. " (" .. achievement.points .. " pts)\n"
        end
    else
        markdown = markdown .. "| Achievement | Progress | Points | Category |\n"
        markdown = markdown .. "|:------------|:---------|-------:|:--------|\n"
        
        for _, achievement in ipairs(inProgress) do
            local statusIcon = GetAchievementStatusIcon(achievement)
            local progressText = GetProgressText(achievement)
            local categoryEmoji = GetCategoryEmoji(achievement.category)
            
            markdown = markdown .. "| " .. statusIcon .. " **" .. achievement.name .. "** | " .. progressText .. " | " .. achievement.points .. " | " .. categoryEmoji .. " " .. achievement.category .. " |\n"
        end
        markdown = markdown .. "\n"
    end
    
    return markdown
end

-- =====================================================
-- RECENT ACHIEVEMENTS GENERATOR
-- =====================================================

local function GenerateRecentAchievements(achievementData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Recent Achievements:**\n"
    else
        markdown = markdown .. "### 🎉 Recent Achievements\n\n"
    end
    
    local recent = achievementData.recent
    
    if #recent == 0 then
        markdown = markdown .. "*No recent achievements*\n\n"
        return markdown
    end
    
    if format == "discord" then
        for _, achievement in ipairs(recent) do
            local categoryEmoji = GetCategoryEmoji(achievement.category)
            markdown = markdown .. "✅ **" .. achievement.name .. "** (" .. achievement.points .. " pts) - " .. categoryEmoji .. " " .. achievement.category .. "\n"
        end
    else
        markdown = markdown .. "| Achievement | Points | Category |\n"
        markdown = markdown .. "|:------------|-------:|:--------|\n"
        
        for _, achievement in ipairs(recent) do
            local categoryEmoji = GetCategoryEmoji(achievement.category)
            markdown = markdown .. "| ✅ **" .. achievement.name .. "** | " .. achievement.points .. " | " .. categoryEmoji .. " " .. achievement.category .. " |\n"
        end
        markdown = markdown .. "\n"
    end
    
    return markdown
end

-- =====================================================
-- SPECIALIZED ACHIEVEMENT GENERATORS
-- =====================================================

local function GenerateSkyshardAchievements(skyshardData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Skyshard Collection:**\n"
        markdown = markdown .. "Collected: " .. skyshardData.collected .. "/" .. skyshardData.total .. " | "
        markdown = markdown .. "Skill Points: " .. skyshardData.skillPoints .. "\n"
    else
        markdown = markdown .. "### ⭐ Skyshard Collection\n\n"
        markdown = markdown .. "| Metric | Value |\n"
        markdown = markdown .. "|:-------|------:|\n"
        markdown = markdown .. "| **Collected** | " .. skyshardData.collected .. " |\n"
        markdown = markdown .. "| **Total** | " .. skyshardData.total .. " |\n"
        markdown = markdown .. "| **Skill Points Earned** | " .. skyshardData.skillPoints .. " |\n"
        markdown = markdown .. "| **Progress** | " .. CM.utils.GenerateProgressBar(math.floor((skyshardData.collected / skyshardData.total) * 100), 12) .. " |\n"
        markdown = markdown .. "\n"
    end
    
    return markdown
end

local function GenerateLorebookAchievements(lorebookData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Lorebook Collection:**\n"
        markdown = markdown .. "Collected: " .. lorebookData.collected .. "/" .. lorebookData.total .. "\n"
    else
        markdown = markdown .. "### 📚 Lorebook Collection\n\n"
        markdown = markdown .. "| Metric | Value |\n"
        markdown = markdown .. "|:-------|------:|\n"
        markdown = markdown .. "| **Collected** | " .. lorebookData.collected .. " |\n"
        markdown = markdown .. "| **Total** | " .. lorebookData.total .. " |\n"
        markdown = markdown .. "| **Progress** | " .. CM.utils.GenerateProgressBar(math.floor((lorebookData.collected / lorebookData.total) * 100), 12) .. " |\n"
        markdown = markdown .. "\n"
    end
    
    return markdown
end

-- =====================================================
-- MAIN ACHIEVEMENT GENERATOR
-- =====================================================

local function GenerateAchievements(achievementData, format)
    -- Section disabled - return empty string
    return ""
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateAchievements = GenerateAchievements
CM.generators.sections.GenerateSkyshardAchievements = GenerateSkyshardAchievements
CM.generators.sections.GenerateLorebookAchievements = GenerateLorebookAchievements

return {
    GenerateAchievements = GenerateAchievements,
    GenerateSkyshardAchievements = GenerateSkyshardAchievements,
    GenerateLorebookAchievements = GenerateLorebookAchievements
}
