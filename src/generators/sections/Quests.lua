-- CharacterMarkdown - Quest Markdown Generator
-- Phase 6: Comprehensive quest tracking and display

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

local function GetQuestStatusIcon(quest)
    if quest.isCompleted then
        return "✅"
    elseif quest.progress and quest.progress.totalSteps > 0 then
        return "🔄"
    else
        return "⚪"
    end
end

local function GetProgressText(quest)
    if quest.isCompleted then
        return "Completed"
    elseif quest.progress and quest.progress.totalSteps > 0 then
        return string.format("Step %d/%d (%d%%)", 
            quest.progress.currentStep, 
            quest.progress.totalSteps, 
            quest.progress.progressPercent)
    else
        return "Not Started"
    end
end

local function GetCategoryEmoji(categoryName)
    local emojis = {
        ["Main Story"] = "📖",
        ["Zone Quests"] = "🗺️",
        ["Guild Quests"] = "🏛️",
        ["DLC Quests"] = "📦",
        ["Daily Quests"] = "🔄",
        ["PvP Quests"] = "⚔️",
        ["Crafting Quests"] = "⚒️",
        ["Companion Quests"] = "👥",
        ["Event Quests"] = "🎉",
        ["Miscellaneous"] = "🔧"
    }
    return emojis[categoryName] or "🔧"
end

local function GetQuestTypeEmoji(questType)
    local emojis = {
        ["Main Quest"] = "📖",
        ["Side Quest"] = "📝",
        ["Guild Quest"] = "🏛️",
        ["Daily Quest"] = "🔄",
        ["PvP Quest"] = "⚔️",
        ["Crafting Quest"] = "⚒️",
        ["Companion Quest"] = "👥",
        ["Event Quest"] = "🎉"
    }
    return emojis[questType] or "📝"
end

-- =====================================================
-- QUEST SUMMARY GENERATOR
-- =====================================================

local function GenerateQuestSummary(questData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Quest Progress:**\n"
    else
        markdown = markdown .. "## 📝 Quest Progress\n\n"
    end
    
    local summary = questData.summary
    
    if format == "discord" then
        markdown = markdown .. "Active: " .. CM.utils.FormatNumber(summary.activeQuests) .. " | "
        markdown = markdown .. "Total: " .. CM.utils.FormatNumber(summary.totalQuests) .. " | "
        markdown = markdown .. "Completed: " .. CM.utils.FormatNumber(summary.completedQuests) .. "\n"
    else
        markdown = markdown .. "| Metric | Value |\n"
        markdown = markdown .. "|:-------|------:|\n"
        markdown = markdown .. "| **Active Quests** | " .. CM.utils.FormatNumber(summary.activeQuests) .. " |\n"
        markdown = markdown .. "| **Total Quests** | " .. CM.utils.FormatNumber(summary.totalQuests) .. " |\n"
        markdown = markdown .. "| **Completed Quests** | " .. CM.utils.FormatNumber(summary.completedQuests) .. " |\n"
        markdown = markdown .. "\n"
    end
    
    return markdown
end

-- =====================================================
-- QUEST CATEGORIES GENERATOR
-- =====================================================

local function GenerateQuestCategories(questData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Quest Categories:**\n"
    else
        markdown = markdown .. "### 📊 Quest Categories\n\n"
    end
    
    local categories = questData.categories
    
    if format == "discord" then
        for categoryName, categoryData in pairs(categories) do
            if categoryData.active > 0 then
                local emoji = GetCategoryEmoji(categoryName)
                markdown = markdown .. emoji .. " **" .. categoryName .. "**: " .. categoryData.active .. " active\n"
            end
        end
    else
        markdown = markdown .. "| Category | Active | Completed | Total |\n"
        markdown = markdown .. "|:---------|-------:|----------:|------:|\n"
        
        for categoryName, categoryData in pairs(categories) do
            if categoryData.active > 0 or categoryData.completed > 0 then
                local emoji = GetCategoryEmoji(categoryName)
                local total = categoryData.active + categoryData.completed
                
                markdown = markdown .. "| " .. emoji .. " **" .. categoryName .. "** | " .. 
                    categoryData.active .. " | " .. categoryData.completed .. " | " .. total .. " |\n"
            end
        end
        markdown = markdown .. "\n"
    end
    
    return markdown
end

-- =====================================================
-- ACTIVE QUESTS GENERATOR
-- =====================================================

local function GenerateActiveQuests(questData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Active Quests:**\n"
    else
        markdown = markdown .. "### 🔄 Active Quests\n\n"
    end
    
    local active = questData.active
    
    if #active == 0 then
        markdown = markdown .. "*No active quests*\n\n"
        return markdown
    end
    
    if format == "discord" then
        for _, quest in ipairs(active) do
            local statusIcon = GetQuestStatusIcon(quest)
            local progressText = GetProgressText(quest)
            local typeEmoji = GetQuestTypeEmoji(quest.type)
            markdown = markdown .. statusIcon .. " **" .. quest.name .. "** (" .. quest.level .. ") - " .. 
                typeEmoji .. " " .. quest.type .. " - " .. progressText .. "\n"
        end
    else
        markdown = markdown .. "| Quest | Level | Type | Progress | Zone |\n"
        markdown = markdown .. "|:------|------:|:-----|:---------|:-----|\n"
        
        for _, quest in ipairs(active) do
            local statusIcon = GetQuestStatusIcon(quest)
            local progressText = GetProgressText(quest)
            local typeEmoji = GetQuestTypeEmoji(quest.type)
            
            markdown = markdown .. "| " .. statusIcon .. " **" .. quest.name .. "** | " .. 
                quest.level .. " | " .. typeEmoji .. " " .. quest.type .. " | " .. 
                progressText .. " | " .. quest.zone .. " |\n"
        end
        markdown = markdown .. "\n"
    end
    
    return markdown
end

-- =====================================================
-- ZONE QUESTS GENERATOR
-- =====================================================

local function GenerateZoneQuests(questData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Quests by Zone:**\n"
    else
        markdown = markdown .. "### 🗺️ Quests by Zone\n\n"
    end
    
    local zones = questData.zones
    
    if format == "discord" then
        for zoneName, zoneData in pairs(zones) do
            if zoneData.active > 0 then
                markdown = markdown .. "🗺️ **" .. zoneName .. "**: " .. zoneData.active .. " active\n"
            end
        end
    else
        markdown = markdown .. "| Zone | Active | Completed | Total |\n"
        markdown = markdown .. "|:-----|-------:|----------:|------:|\n"
        
        for zoneName, zoneData in pairs(zones) do
            if zoneData.active > 0 or zoneData.completed > 0 then
                local total = zoneData.active + zoneData.completed
                markdown = markdown .. "| 🗺️ **" .. zoneName .. "** | " .. 
                    zoneData.active .. " | " .. zoneData.completed .. " | " .. total .. " |\n"
            end
        end
        markdown = markdown .. "\n"
    end
    
    return markdown
end

-- =====================================================
-- SPECIALIZED QUEST GENERATORS
-- =====================================================

local function GenerateMainStoryQuests(mainStoryData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Main Story Progress:**\n"
        markdown = markdown .. "Active: " .. mainStoryData.active .. " | Total: " .. mainStoryData.total .. "\n"
    else
        markdown = markdown .. "### 📖 Main Story Progress\n\n"
        markdown = markdown .. "| Metric | Value |\n"
        markdown = markdown .. "|:-------|------:|\n"
        markdown = markdown .. "| **Active** | " .. mainStoryData.active .. " |\n"
        markdown = markdown .. "| **Total** | " .. mainStoryData.total .. " |\n"
        markdown = markdown .. "| **Progress** | " .. CM.utils.GenerateProgressBar(math.floor((mainStoryData.active / mainStoryData.total) * 100), 12) .. " |\n"
        markdown = markdown .. "\n"
    end
    
    return markdown
end

local function GenerateGuildQuests(guildData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Guild Quest Progress:**\n"
    else
        markdown = markdown .. "### 🏛️ Guild Quest Progress\n\n"
    end
    
    local byGuild = guildData.byGuild
    
    if format == "discord" then
        for guildName, guildInfo in pairs(byGuild) do
            if guildInfo.active > 0 then
                markdown = markdown .. "🏛️ **" .. guildName .. "**: " .. guildInfo.active .. " active\n"
            end
        end
    else
        markdown = markdown .. "| Guild | Active | Completed | Total |\n"
        markdown = markdown .. "|:------|-------:|----------:|------:|\n"
        
        for guildName, guildInfo in pairs(byGuild) do
            if guildInfo.active > 0 or guildInfo.completed > 0 then
                local total = guildInfo.active + guildInfo.completed
                markdown = markdown .. "| 🏛️ **" .. guildName .. "** | " .. 
                    guildInfo.active .. " | " .. guildInfo.completed .. " | " .. total .. " |\n"
            end
        end
        markdown = markdown .. "\n"
    end
    
    return markdown
end

local function GenerateDailyQuests(dailyData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Daily Quest Progress:**\n"
    else
        markdown = markdown .. "### 🔄 Daily Quest Progress\n\n"
    end
    
    local byType = dailyData.byType
    
    if format == "discord" then
        for typeName, typeInfo in pairs(byType) do
            if typeInfo.active > 0 then
                markdown = markdown .. "🔄 **" .. typeName .. "**: " .. typeInfo.active .. " active\n"
            end
        end
    else
        markdown = markdown .. "| Type | Active | Completed | Total |\n"
        markdown = markdown .. "|:-----|-------:|----------:|------:|\n"
        
        for typeName, typeInfo in pairs(byType) do
            if typeInfo.active > 0 or typeInfo.completed > 0 then
                local total = typeInfo.active + typeInfo.completed
                markdown = markdown .. "| 🔄 **" .. typeName .. "** | " .. 
                    typeInfo.active .. " | " .. typeInfo.completed .. " | " .. total .. " |\n"
            end
        end
        markdown = markdown .. "\n"
    end
    
    return markdown
end

-- =====================================================
-- MAIN QUEST GENERATOR
-- =====================================================

local function GenerateQuests(questData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if not questData or not questData.summary then
        return markdown
    end
    
    -- Always show summary
    markdown = markdown .. GenerateQuestSummary(questData, format)
    
    -- Show categories if detailed mode is enabled
    if questData.categories then
        markdown = markdown .. GenerateQuestCategories(questData, format)
    end
    
    -- Show active quests
    if questData.active and #questData.active > 0 then
        markdown = markdown .. GenerateActiveQuests(questData, format)
    end
    
    -- Show zone breakdown if detailed mode is enabled
    if questData.zones then
        markdown = markdown .. GenerateZoneQuests(questData, format)
    end
    
    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateQuests = GenerateQuests
CM.generators.sections.GenerateMainStoryQuests = GenerateMainStoryQuests
CM.generators.sections.GenerateGuildQuests = GenerateGuildQuests
CM.generators.sections.GenerateDailyQuests = GenerateDailyQuests

return {
    GenerateQuests = GenerateQuests,
    GenerateMainStoryQuests = GenerateMainStoryQuests,
    GenerateGuildQuests = GenerateGuildQuests,
    GenerateDailyQuests = GenerateDailyQuests
}
