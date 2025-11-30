-- CharacterMarkdown - Quest Markdown Generator
-- Phase 6: Comprehensive quest tracking and display

local CM = CharacterMarkdown

-- =====================================================
-- CONSTANTS
-- =====================================================

local PROGRESS_BAR_WIDTH = 12

-- Cache frequently used functions for performance
local table_insert = table.insert
local table_concat = table.concat
local table_sort = table.sort

-- =====================================================
-- UTILITIES
-- =====================================================

-- Initialize utilities once at module load
local utilitiesInitialized = false

local function InitializeUtilities()
    if utilitiesInitialized then
        return true
    end

    -- Verify required utilities are loaded
    -- FormatNumber is exported by src/utils/Formatters.lua as CM.utils.FormatNumber
    if not CM.utils or not CM.utils.FormatNumber then
        CM.Error("Quest generator: CM.utils.FormatNumber not available!")
        return false
    end

    -- Load GenerateAnchor if available
    if not CM.utils.GenerateAnchor and CM.utils.markdown and CM.utils.markdown.GenerateAnchor then
        CM.utils.GenerateAnchor = CM.utils.markdown.GenerateAnchor
    end

    utilitiesInitialized = true
    return true
end

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

local function GetSortedKeys(tbl)
    -- Return sorted keys for deterministic output
    local keys = {}
    for key, _ in pairs(tbl) do
        table_insert(keys, key)
    end
    table_sort(keys)
    return keys
end

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
        return "✅ Completed"
    elseif quest.activeStepText and quest.activeStepText ~= "" then
        -- Show the active step text from the quest
        return "🔄 " .. quest.activeStepText
    elseif quest.progress and quest.progress.activeStepText and quest.progress.activeStepText ~= "" then
        return "🔄 " .. quest.progress.activeStepText
    else
        return "⚪ Active"
    end
end

local function GetCategoryEmoji(categoryName)
    local emojis = {
        ["Main Story"] = "📖",
        ["Zone Quests"] = "🗺️",
        ["Guild Quests"] = "🏰", -- Changed from 🏛️ for better compatibility
        ["DLC Quests"] = "📦",
        ["Daily Quests"] = "🔄",
        ["PvP Quests"] = "⚔️",
        ["Crafting Quests"] = "⚒️",
        ["Companion Quests"] = "👥",
        ["Event Quests"] = "🎉",
        ["Miscellaneous"] = "🔧",
    }
    return emojis[categoryName] or "🔧"
end

local function GetQuestTypeEmoji(questType)
    local emojis = {
        ["Main Quest"] = "📖",
        ["Side Quest"] = "📝",
        ["Guild Quest"] = "🏰", -- Changed from 🏛️ for better compatibility
        ["Daily Quest"] = "🔄",
        ["PvP Quest"] = "⚔️",
        ["Crafting Quest"] = "⚒️",
        ["Companion Quest"] = "👥",
        ["Event Quest"] = "🎉",
    }
    return emojis[questType] or "📝"
end

-- =====================================================
-- QUEST SUMMARY GENERATOR
-- =====================================================

local function GenerateQuestSummary(questData, format)
    if not InitializeUtilities() then
        return ""
    end

    CM.DebugPrint("QUESTS", "GenerateQuestSummary called")

    local parts = {}
    local summary = questData.summary

    CM.DebugPrint(
        "QUESTS",
        string.format("Summary: active=%d, total=%d", summary.activeQuests or 0, summary.totalQuests or 0)
    )

    if format == "discord" then
        table_insert(parts, "**Quest Progress:**\n")
        table_insert(parts, "Active: " .. CM.utils.FormatNumber(summary.activeQuests) .. " | ")
        table_insert(parts, "Total: " .. CM.utils.FormatNumber(summary.totalQuests) .. " | ")
        table_insert(parts, "Completed: " .. CM.utils.FormatNumber(summary.completedQuests) .. "\n")
    else
        local anchorId = CM.utils.GenerateAnchor and CM.utils.GenerateAnchor("📝 Quest Progress") or "quest-progress"
        table_insert(parts, string.format('<a id="%s"></a>\n\n', anchorId))
        table_insert(parts, "## 📝 Quest Progress\n\n")
        table_insert(parts, "| **Active Quests** | **Total Quests** | **Completed Quests** |\n")
        table_insert(parts, "|------------------:|----------------:|---------------------:|\n")
        table_insert(
            parts,
            "| "
                .. CM.utils.FormatNumber(summary.activeQuests)
                .. " | "
                .. CM.utils.FormatNumber(summary.totalQuests)
                .. " | "
                .. CM.utils.FormatNumber(summary.completedQuests)
                .. " |\n"
        )
        table_insert(parts, "\n")
    end

    return table_concat(parts)
end

-- =====================================================
-- QUEST CATEGORIES GENERATOR
-- =====================================================

local function GenerateQuestCategories(questData, format)
    if not InitializeUtilities() then
        return ""
    end

    local parts = {}
    local categories = questData.categories

    if format == "discord" then
        table_insert(parts, "**Quest Categories:**\n")

        -- Sort categories for deterministic output
        for _, categoryName in ipairs(GetSortedKeys(categories)) do
            local categoryData = categories[categoryName]
            if categoryData.active > 0 then
                local emoji = GetCategoryEmoji(categoryName)
                table_insert(parts, emoji .. " **" .. categoryName .. "**: " .. categoryData.active .. " active\n")
            end
        end
    else
        table_insert(parts, "### 📊 Quest Categories\n\n")
        table_insert(parts, "| Category | Active | Completed | Total |\n")
        table_insert(parts, "|:---------|-------:|----------:|------:|\n")

        -- Sort categories for deterministic output
        for _, categoryName in ipairs(GetSortedKeys(categories)) do
            local categoryData = categories[categoryName]
            if categoryData.active > 0 or categoryData.completed > 0 then
                local emoji = GetCategoryEmoji(categoryName)
                local total = categoryData.active + categoryData.completed

                table_insert(
                    parts,
                    "| "
                        .. emoji
                        .. " **"
                        .. categoryName
                        .. "** | "
                        .. categoryData.active
                        .. " | "
                        .. categoryData.completed
                        .. " | "
                        .. total
                        .. " |\n"
                )
            end
        end
        table_insert(parts, "\n")
    end

    return table_concat(parts)
end

-- =====================================================
-- ACTIVE QUESTS GENERATOR
-- =====================================================

local function GenerateActiveQuests(questData, format)
    if not InitializeUtilities() then
        return ""
    end

    local parts = {}
    local active = questData.active

    -- Sort active quests alphabetically by name
    if active and #active > 0 then
        table.sort(active, function(a, b)
            return (a.name or "") < (b.name or "")
        end)
    end

    if format == "discord" then
        table_insert(parts, "**Active Quests:**\n")
    else
        table_insert(parts, "### 🔄 Active Quests\n\n")
    end

    if #active == 0 then
        table_insert(parts, "*No active quests*\n\n")
        return table_concat(parts)
    end

    if format == "discord" then
        for _, quest in ipairs(active) do
            local statusIcon = GetQuestStatusIcon(quest)
            local progressText = GetProgressText(quest)
            local typeEmoji = GetQuestTypeEmoji(quest.type)
            table_insert(
                parts,
                statusIcon
                    .. " **"
                    .. quest.name
                    .. "** ("
                    .. quest.level
                    .. ") - "
                    .. typeEmoji
                    .. " "
                    .. quest.type
                    .. " - "
                    .. progressText
                    .. "\n"
            )
        end
    else
        table_insert(parts, "| Quest | Level | Type | Progress | Zone |\n")
        table_insert(parts, "|:------|------:|:-----|:---------|:-----|\n")

        for _, quest in ipairs(active) do
            local statusIcon = GetQuestStatusIcon(quest)
            local progressText = GetProgressText(quest)
            local typeEmoji = GetQuestTypeEmoji(quest.type)

            -- Safely convert all quest fields to strings (handle boolean/nil)
            local questName = ""
            if quest.name then
                if type(quest.name) == "string" then
                    questName = quest.name
                else
                    questName = tostring(quest.name)
                end
            end
            
            local questLevel = tostring(quest.level or "")
            local questType = ""
            if quest.type then
                if type(quest.type) == "string" then
                    questType = quest.type
                else
                    questType = tostring(quest.type)
                end
            end
            
            local questZone = ""
            if quest.zone then
                if type(quest.zone) == "string" then
                    questZone = quest.zone
                else
                    questZone = tostring(quest.zone)
                end
            end

            table_insert(
                parts,
                "| "
                    .. statusIcon
                    .. " **"
                    .. questName
                    .. "** | "
                    .. questLevel
                    .. " | "
                    .. typeEmoji
                    .. " "
                    .. questType
                    .. " | "
                    .. progressText
                    .. " | "
                    .. questZone
                    .. " |\n"
            )
        end
        table_insert(parts, "\n")
    end

    return table_concat(parts)
end

-- =====================================================
-- ZONE QUESTS GENERATOR
-- =====================================================

local function GenerateZoneQuests(questData, format)
    if not InitializeUtilities() then
        return ""
    end

    local parts = {}
    local zones = questData.zones

    if format == "discord" then
        table_insert(parts, "**Quests by Zone:**\n")

        -- Sort zones for deterministic output
        for _, zoneName in ipairs(GetSortedKeys(zones)) do
            local zoneData = zones[zoneName]
            if zoneData.active > 0 then
                table_insert(parts, "🗺️ **" .. zoneName .. "**: " .. zoneData.active .. " active\n")
            end
        end
    else
        table_insert(parts, "### 🗺️ Quests by Zone\n\n")
        table_insert(parts, "| Zone | Active | Completed | Total |\n")
        table_insert(parts, "|:-----|-------:|----------:|------:|\n")

        -- Sort zones for deterministic output
        for _, zoneName in ipairs(GetSortedKeys(zones)) do
            local zoneData = zones[zoneName]
            if zoneData.active > 0 or zoneData.completed > 0 then
                local total = zoneData.active + zoneData.completed
                table_insert(
                    parts,
                    "| 🗺️ **"
                        .. zoneName
                        .. "** | "
                        .. zoneData.active
                        .. " | "
                        .. zoneData.completed
                        .. " | "
                        .. total
                        .. " |\n"
                )
            end
        end
        table_insert(parts, "\n")
    end

    return table_concat(parts)
end

-- =====================================================
-- MAIN QUEST GENERATOR
-- =====================================================

local function GenerateQuests(questData, format)
    CM.DebugPrint("QUESTS", "=== GenerateQuests called ===")
    CM.DebugPrint("QUESTS", string.format("Format: %s", tostring(format)))

    if not InitializeUtilities() then
        CM.Error("Quest generator failed to initialize utilities")
        -- Return visible error message instead of empty string
        if format == "discord" then
            return "**📝 Quests:**\n*Error: Quest utilities not available*\n\n"
        else
            return "## 📝 Quests\n\n*Error: Quest utilities not available*\n\n---\n\n"
        end
    end

    if not questData then
        CM.Error("GenerateQuests: questData is nil!")
        -- Return visible message instead of empty string
        if format == "discord" then
            return "**📝 Quests:**\n*Error: Quest data not collected*\n\n"
        else
            return "## 📝 Quests\n\n*Error: Quest data not collected*\n\n---\n\n"
        end
    end

    CM.DebugPrint("QUESTS", "questData exists, checking structure...")
    CM.DebugPrint("QUESTS", string.format("questData.summary: %s", tostring(questData.summary ~= nil)))
    CM.DebugPrint("QUESTS", string.format("questData.active: %s", tostring(questData.active ~= nil)))
    CM.DebugPrint("QUESTS", string.format("questData.categories: %s", tostring(questData.categories ~= nil)))
    CM.DebugPrint("QUESTS", string.format("questData.zones: %s", tostring(questData.zones ~= nil)))

    if not questData.summary then
        CM.Error("GenerateQuests: questData.summary is nil!")
        if format == "discord" then
            return "**📝 Quests:**\n*Error: Quest summary missing*\n\n"
        else
            return "## 📝 Quests\n\n*Error: Quest summary missing*\n\n---\n\n"
        end
    end

    -- Get values safely for debug output
    local activeQuestsDebug = (questData.summary and questData.summary.activeQuests) or (questData.summary and questData.summary.activeCount) or "nil"
    local totalQuestsDebug = (questData.summary and questData.summary.totalQuests) or "nil"
    CM.DebugPrint(
        "QUESTS",
        string.format(
            "Summary - activeQuests/activeCount: %s, totalQuests: %s",
            tostring(activeQuestsDebug),
            tostring(totalQuestsDebug)
        )
    )
    CM.DebugPrint("QUESTS", string.format("Active quests count: %d", #(questData.active or {})))

    -- Check if there are any quests at all
    -- Handle nil values safely
    local activeQuests = (questData.summary and questData.summary.activeQuests) or (questData.summary and questData.summary.activeCount) or 0
    local totalQuests = (questData.summary and questData.summary.totalQuests) or 0
    local hasQuests = activeQuests > 0 or totalQuests > 0

    if not hasQuests then
        CM.DebugPrint("QUESTS", "No quests found, generating empty section message")
        if format == "discord" then
            return "**📝 Quests:**\n*No active quests*\n\n"
        else
            return "## 📝 Quests\n\n*No active quests*\n\n---\n\n"
        end
    end

    CM.DebugPrint("QUESTS", "Generating quest sections...")

    local parts = {}

    -- Always show summary
    table_insert(parts, GenerateQuestSummary(questData, format))

    -- Show categories if detailed mode is enabled
    if questData.categories then
        table_insert(parts, GenerateQuestCategories(questData, format))
    end

    -- Show active quests
    if questData.active and #questData.active > 0 then
        table_insert(parts, GenerateActiveQuests(questData, format))
    end

    -- Show zone breakdown if detailed mode is enabled
    if questData.zones then
        table_insert(parts, GenerateZoneQuests(questData, format))
    end

    -- Add section separator (except for discord)
    if format ~= "discord" then
        -- Use CreateSeparator for consistent separator styling
        local CreateSeparator = CM.utils.markdown and CM.utils.markdown.CreateSeparator
        if CreateSeparator then
            table_insert(parts, CreateSeparator("hr"))
        else
            table_insert(parts, "---\n\n")
        end
    end

    local markdown = table_concat(parts)
    CM.DebugPrint("QUESTS", string.format("GenerateQuests complete: %d chars", #markdown))
    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateQuests = GenerateQuests

return {
    GenerateQuests = GenerateQuests,
}
