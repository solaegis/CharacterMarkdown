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

    -- FormatNumber is already exported by Formatters.lua to CM.utils.FormatNumber
    -- Just create fallback if somehow not loaded
    if not CM.utils.FormatNumber then
        CM.utils.FormatNumber = function(num)
            if not num then
                return "0"
            end
            local formatted = tostring(num)
            return formatted:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
        end
    end

    -- GenerateProgressBar is exported by helpers/Utilities.lua
    if not CM.utils.GenerateProgressBar and CM.generators and CM.generators.helpers then
        CM.utils.GenerateProgressBar = CM.generators.helpers.GenerateProgressBar
    end

    -- Fallback progress bar if helpers not loaded
    if not CM.utils.GenerateProgressBar then
        CM.utils.GenerateProgressBar = function(percent, width)
            width = width or 10
            local filled = math.floor((percent / 100) * width)
            local empty = width - filled
            return string.rep("█", filled) .. string.rep("░", empty)
        end
    end

    -- Load GenerateAnchor from markdown utils
    if not CM.utils.GenerateAnchor and CM.utils.markdown and CM.utils.markdown.GenerateAnchor then
        CM.utils.GenerateAnchor = CM.utils.markdown.GenerateAnchor
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
        return string.format(
            "%d/%d (%d%%)",
            achievement.progress.totalProgress,
            achievement.progress.totalRequired,
            achievement.progress.progressPercent
        )
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
        ["Dungeons"] = "🏰", -- Changed from 🏛️ for better compatibility
        ["Character"] = "📈",
        ["Vampire"] = "🧛",
        ["Werewolf"] = "🐺",
        ["Collectibles"] = "🎨",
        ["Housing"] = "🏠",
        ["Events"] = "🎉",
        ["Miscellaneous"] = "🔧",
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
        local anchorId = CM.utils.GenerateAnchor and CM.utils.GenerateAnchor("🏆 Achievement Progress")
            or "achievement-progress"
        markdown = markdown .. string.format('<a id="%s"></a>\n\n', anchorId)
        markdown = markdown .. "## 🏆 Achievement Progress\n\n"
    end

    local summary = achievementData.summary

    if format == "discord" then
        markdown = markdown .. "Total: " .. CM.utils.FormatNumber(summary.totalAchievements) .. " | "
        markdown = markdown .. "Completed: " .. CM.utils.FormatNumber(summary.completedAchievements) .. " | "
        markdown = markdown .. "Progress: " .. summary.completionPercent .. "%\n"
        markdown = markdown
            .. "Points: "
            .. CM.utils.FormatNumber(summary.earnedPoints)
            .. "/"
            .. CM.utils.FormatNumber(summary.totalPoints)
            .. "\n"
    else
        -- Pivot table: metrics as columns, values as rows
        local headers = { "Metric", "Value" }
        local rows = {
            { "Total Achievements", CM.utils.FormatNumber(summary.totalAchievements) },
            { "Completed", CM.utils.FormatNumber(summary.completedAchievements) },
            { "Completion %", summary.completionPercent .. "%" },
            { "Points Earned", CM.utils.FormatNumber(summary.earnedPoints) },
            { "Total Points", CM.utils.FormatNumber(summary.totalPoints) },
        }

        -- Transpose: convert rows to columns (without Metric/Value column)
        local transposedHeaders = {}
        local transposedRows = {}

        -- Headers: metric names only (no "Metric" column)
        for _, row in ipairs(rows) do
            table.insert(transposedHeaders, row[1])
        end

        -- Row: values only (no "Value" column)
        local valueRow = {}
        for _, row in ipairs(rows) do
            table.insert(valueRow, row[2])
        end
        table.insert(transposedRows, valueRow)

        local CreateStyledTable = CM.utils.markdown.CreateStyledTable
        local options = {
            alignment = { "right", "right", "right", "right", "right" },
            format = format,
            coloredHeaders = true,
        }
        markdown = markdown .. CreateStyledTable(transposedHeaders, transposedRows, options)
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
                local percent = categoryData.total > 0
                        and math.floor((categoryData.completed / categoryData.total) * 100)
                    or 0
                markdown = markdown
                    .. emoji
                    .. " **"
                    .. categoryName
                    .. "**: "
                    .. categoryData.completed
                    .. "/"
                    .. categoryData.total
                    .. " ("
                    .. percent
                    .. "%)\n"
            end
        end
    else
        -- Use pivot table format: single table with all categories as rows
        local headers = { "Category", "Completed", "Total", "Progress", "Points" }
        local rows = {}
        local categoryOrder = {}

        -- Collect and sort categories alphabetically
        for categoryName, categoryData in pairs(categories) do
            if categoryData.total > 0 then
                table.insert(categoryOrder, categoryName)
            end
        end
        table.sort(categoryOrder, function(a, b)
            return string.lower(a or "") < string.lower(b or "")
        end)

        for _, categoryName in ipairs(categoryOrder) do
            local categoryData = categories[categoryName]
            local emoji = GetCategoryEmoji(categoryName)
            local percent = categoryData.total > 0
                    and math.floor((categoryData.completed / categoryData.total) * 100)
                or 0
            local progressBar = CM.utils.GenerateProgressBar(percent, 8)

            table.insert(rows, {
                emoji .. " **" .. categoryName .. "**",
                tostring(categoryData.completed),
                tostring(categoryData.total),
                progressBar .. " " .. percent .. "%",
                CM.utils.FormatNumber(categoryData.points),
            })
        end

        local CreateStyledTable = CM.utils.markdown.CreateStyledTable
        if CreateStyledTable then
            local options = {
                alignment = { "left", "right", "right", "left", "right" },
                format = format,
                coloredHeaders = true,
            }
            markdown = markdown .. CreateStyledTable(headers, rows, options)
        else
            -- Fallback to simple markdown table if CreateStyledTable not available
            local lines = {}
            table.insert(lines, "| " .. table.concat(headers, " | ") .. " |")
            table.insert(lines, "| " .. string.rep("---|", #headers))
            for _, row in ipairs(rows) do
                table.insert(lines, "| " .. table.concat(row, " | ") .. " |")
            end
            markdown = markdown .. table.concat(lines, "\n") .. "\n\n"
        end
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
            markdown = markdown
                .. statusIcon
                .. " **"
                .. achievement.name
                .. "**: "
                .. progressText
                .. " ("
                .. achievement.points
                .. " pts)\n"
        end
    else
        -- Group achievements by category, then by subcategory
        local categories = {}
        for _, achievement in ipairs(inProgress) do
            local category = achievement.category or "Miscellaneous"
            if not categories[category] then
                categories[category] = {}
            end
            
            -- Group by subcategory within category
            local subcategory = achievement.subcategory or "General"
            if not categories[category][subcategory] then
                categories[category][subcategory] = {}
            end
            table.insert(categories[category][subcategory], achievement)
        end

        -- Sort achievements by name within each subcategory
        for category, subcategories in pairs(categories) do
            for subcategory, achievements in pairs(subcategories) do
                table.sort(achievements, function(a, b)
                    return (a.name or "") < (b.name or "")
                end)
            end
        end

        -- Create styled tables for each category/subcategory
        -- Don't sort categories alphabetically - preserve order for better layout density
        local categoryOrder = {}
        for category, _ in pairs(categories) do
            table.insert(categoryOrder, category)
        end

        local CreateStyledTable = CM.utils.markdown.CreateStyledTable
        if CreateStyledTable then
            -- Create one table per subcategory, grouped by category
            local allTables = {}
            
            -- Process categories in order (no alphabetical sorting for better density)
            for _, category in ipairs(categoryOrder) do
                local subcategories = categories[category]
                local categoryEmoji = GetCategoryEmoji(category)
                
                -- Get subcategories and sort them alphabetically
                local subcategoryOrder = {}
                for subcategory, _ in pairs(subcategories) do
                    table.insert(subcategoryOrder, subcategory or "General")
                end
                table.sort(subcategoryOrder, function(a, b)
                    return string.lower(a or "") < string.lower(b or "")
                end)
                
                -- Create one table per subcategory
                for _, subcategory in ipairs(subcategoryOrder) do
                    local achievements = subcategories[subcategory]
                    if achievements and #achievements > 0 then
                        -- Sort achievements by name within subcategory
                        table.sort(achievements, function(a, b)
                            return (a.name or "") < (b.name or "")
                        end)
                        
                        local headers = { "Achievement", "Progress", "Points" }
                        local rows = {}
                        
                        for _, achievement in ipairs(achievements) do
                            local statusIcon = GetAchievementStatusIcon(achievement)
                            local progressText = GetProgressText(achievement)
                            
                            table.insert(rows, {
                                statusIcon .. " **" .. achievement.name .. "**",
                                progressText,
                                tostring(achievement.points),
                            })
                        end
                        
                        local options = {
                            alignment = { "left", "left", "right" },
                            format = format,
                            coloredHeaders = true,
                        }
                        
                        -- Ensure category and subcategory are valid strings
                        local safeCategory = category or "Miscellaneous"
                        local safeSubcategory = subcategory or "General"
                        local safeCategoryEmoji = categoryEmoji or "🔧"
                        
                        -- Create table with category as header and subcategory in title
                        local tableMarkdown = "#### " .. safeCategoryEmoji .. " " .. safeCategory .. "\n\n"
                        tableMarkdown = tableMarkdown .. "##### " .. safeSubcategory .. "\n\n"
                        local styledTable = CreateStyledTable(headers, rows, options)
                        if styledTable and styledTable ~= "" then
                            tableMarkdown = tableMarkdown .. styledTable
                            table.insert(allTables, tableMarkdown)
                        else
                            -- Fallback: log error and skip this table
                            CM.DebugPrint("ERROR", string.format(
                                "Failed to create styled table for %s > %s",
                                safeCategory,
                                safeSubcategory
                            ))
                        end
                    end
                end
            end

            -- Use multi-column layout for better density (no need to sort categories)
            local CreateResponsiveColumns = CM.utils.markdown.CreateResponsiveColumns
            if CreateResponsiveColumns and #allTables > 1 then
                -- Filter out any nil or empty entries
                local validTables = {}
                for _, tableContent in ipairs(allTables) do
                    if tableContent and tableContent ~= "" then
                        table.insert(validTables, tableContent)
                    end
                end
                
                if #validTables > 1 then
                    -- Calculate optimal layout based on table content
                    local LayoutCalculator = CM.utils.LayoutCalculator
                    local minWidth, gap
                    if LayoutCalculator then
                        minWidth, gap = LayoutCalculator.GetLayoutParamsWithFallback(
                            validTables,
                            #validTables > 6 and "300px" or "250px",
                            "20px"
                        )
                    else
                        minWidth = #validTables > 6 and "300px" or "250px"
                        gap = "20px"
                    end
                    markdown = markdown .. CreateResponsiveColumns(validTables, minWidth, gap)
                elseif #validTables == 1 then
                    -- Single table: append directly
                    markdown = markdown .. validTables[1]
                end
            else
                -- Single column or fallback
                for _, tableContent in ipairs(allTables) do
                    markdown = markdown .. tableContent
                end
            end
        else
            -- Fallback to simple markdown table if CreateStyledTable not available
            -- Create one table per subcategory, grouped by category
            for _, category in ipairs(categoryOrder) do
                local subcategories = categories[category]
                local categoryEmoji = GetCategoryEmoji(category)
                
                -- Get subcategories and sort them alphabetically
                local subcategoryOrder = {}
                for subcategory, _ in pairs(subcategories) do
                    table.insert(subcategoryOrder, subcategory or "General")
                end
                table.sort(subcategoryOrder, function(a, b)
                    return string.lower(a or "") < string.lower(b or "")
                end)
                
                -- Create one table per subcategory
                for _, subcategory in ipairs(subcategoryOrder) do
                    local achievements = subcategories[subcategory]
                    if achievements and #achievements > 0 then
                        -- Sort achievements by name within subcategory
                        table.sort(achievements, function(a, b)
                            return (a.name or "") < (b.name or "")
                        end)
                        
                        markdown = markdown .. "#### " .. categoryEmoji .. " " .. category .. "\n\n"
                        markdown = markdown .. "##### " .. subcategory .. "\n\n"
                        markdown = markdown .. "| Achievement | Progress | Points |\n"
                        markdown = markdown .. "|:-----------|:---------|------:|\n"
                        
                        for _, achievement in ipairs(achievements) do
                            local statusIcon = GetAchievementStatusIcon(achievement)
                            local progressText = GetProgressText(achievement)
                            
                            local row = "| "
                                .. statusIcon
                                .. " **"
                                .. achievement.name
                                .. "** | "
                                .. progressText
                                .. " | "
                                .. achievement.points
                                .. " |"
                            row = row:gsub("%s+$", "") .. "\n"
                            markdown = markdown .. row
                        end
                        markdown = markdown .. "\n"
                    end
                end
            end
        end
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
            markdown = markdown
                .. "✅ **"
                .. achievement.name
                .. "** ("
                .. achievement.points
                .. " pts) - "
                .. categoryEmoji
                .. " "
                .. achievement.category
                .. "\n"
        end
    else
        local CreateStyledTable = CM.utils.markdown.CreateStyledTable
        if CreateStyledTable then
            local headers = { "Achievement", "Points", "Category" }
            local rows = {}

            for _, achievement in ipairs(recent) do
                local categoryEmoji = GetCategoryEmoji(achievement.category)
                table.insert(rows, {
                    "✅ **" .. achievement.name .. "**",
                    tostring(achievement.points),
                    categoryEmoji .. " " .. achievement.category,
                })
            end

            local options = {
                alignment = { "left", "right", "left" },
                format = format,
                coloredHeaders = true,
            }
            markdown = markdown .. CreateStyledTable(headers, rows, options)
        else
            -- Fallback to markdown table
            markdown = markdown .. "| Achievement | Points | Category |\n"
            markdown = markdown .. "|:------------|-------:|:--------|\n"

            for _, achievement in ipairs(recent) do
                local categoryEmoji = GetCategoryEmoji(achievement.category)
                local row = "| ✅ **"
                    .. achievement.name
                    .. "** | "
                    .. achievement.points
                    .. " | "
                    .. categoryEmoji
                    .. " "
                    .. achievement.category
                    .. " |"
                row = row:gsub("%s+$", "") .. "\n"
                markdown = markdown .. row
            end
            markdown = markdown .. "\n"
        end
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
        markdown = markdown
            .. "| **Progress** | "
            .. CM.utils.GenerateProgressBar(math.floor((skyshardData.collected / skyshardData.total) * 100), 12)
            .. " |\n"
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
        markdown = markdown
            .. "| **Progress** | "
            .. CM.utils.GenerateProgressBar(math.floor((lorebookData.collected / lorebookData.total) * 100), 12)
            .. " |\n"
        markdown = markdown .. "\n"
    end

    return markdown
end

-- =====================================================
-- MAIN ACHIEVEMENT GENERATOR
-- =====================================================

local function GenerateAchievements(achievementData, format)
    InitializeUtilities()

    -- Return empty if no achievement data
    if not achievementData or not achievementData.summary then
        return ""
    end

    local markdown = ""

    -- Generate achievement summary (always shown)
    markdown = markdown .. GenerateAchievementSummary(achievementData, format)

    -- Generate category breakdown (always shown when achievements enabled)
    markdown = markdown .. GenerateAchievementCategories(achievementData, format)

    -- Show in-progress achievements
    if #achievementData.inProgress > 0 then
        markdown = markdown .. GenerateInProgressAchievements(achievementData, format)
    end

    -- Show recent achievements
    if #achievementData.recent > 0 then
        markdown = markdown .. GenerateRecentAchievements(achievementData, format)
    end

    return markdown
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
    GenerateLorebookAchievements = GenerateLorebookAchievements,
}
