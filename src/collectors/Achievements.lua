-- CharacterMarkdown - Achievement Data Collector
-- Phase 5: Comprehensive achievement tracking and categorization

local CM = CharacterMarkdown

-- =====================================================
-- ACHIEVEMENT CATEGORIES
-- =====================================================

local ACHIEVEMENT_CATEGORIES = {
    -- Combat & PvP
    ["Combat"] = {
        keywords = { "Combat", "Battle", "Fight", "Kill", "Defeat", "Slay", "Destroy", "Vanquish" },
        emoji = "⚔️",
        description = "Combat and battle-related achievements",
    },
    ["PvP"] = {
        keywords = { "PvP", "Cyrodiil", "Battleground", "Alliance War", "Emperor", "Campaign", "Siege" },
        emoji = "🏰",
        description = "Player vs Player achievements",
    },

    -- Exploration & World
    ["Exploration"] = {
        keywords = { "Explorer", "Discover", "Visit", "Travel", "Journey", "Wanderer", "Pathfinder" },
        emoji = "🗺️",
        description = "Exploration and world discovery achievements",
    },
    ["Skyshards"] = {
        keywords = { "Skyshard", "Skyshards" },
        emoji = "⭐",
        description = "Skyshard collection achievements",
    },
    ["Lorebooks"] = {
        keywords = { "Lorebook", "Lorebooks", "Lore", "Book", "Knowledge" },
        emoji = "📚",
        description = "Lorebook collection achievements",
    },

    -- Crafting & Economy
    ["Crafting"] = {
        keywords = { "Craft", "Crafting", "Smith", "Enchant", "Alchemy", "Provision", "Woodwork", "Cloth", "Jewelry" },
        emoji = "⚒️",
        description = "Crafting and profession achievements",
    },
    ["Economy"] = {
        keywords = { "Gold", "Money", "Trade", "Merchant", "Vendor", "Sell", "Buy", "Market" },
        emoji = "💰",
        description = "Economic and trading achievements",
    },

    -- Social & Guild
    ["Social"] = {
        keywords = { "Guild", "Friend", "Social", "Group", "Party", "Team", "Guildmate" },
        emoji = "👥",
        description = "Social and guild-related achievements",
    },
    ["Dungeons"] = {
        keywords = { "Dungeon", "Dungeons", "Trial", "Trials", "Group", "Raid", "Instance" },
        emoji = "🏰", -- Changed from 🏛️ for better compatibility
        description = "Dungeon and trial achievements",
    },

    -- Character Development
    ["Character"] = {
        keywords = { "Level", "Experience", "Skill", "Champion", "CP", "Progression", "Advancement" },
        emoji = "📈",
        description = "Character progression achievements",
    },
    ["Vampire"] = {
        keywords = { "Vampire", "Vampirism", "Blood", "Undead" },
        emoji = "🧛",
        description = "Vampire-related achievements",
    },
    ["Werewolf"] = {
        keywords = { "Werewolf", "Lycanthropy", "Wolf", "Beast", "Transformation" },
        emoji = "🐺",
        description = "Werewolf-related achievements",
    },

    -- Collectibles & Housing
    ["Collectibles"] = {
        keywords = { "Collectible", "Collectibles", "Mount", "Pet", "Costume", "Outfit", "Style" },
        emoji = "🎨",
        description = "Collectible and cosmetic achievements",
    },
    ["Housing"] = {
        keywords = { "House", "Housing", "Home", "Furniture", "Decorate", "Residence" },
        emoji = "🏠",
        description = "Housing and decoration achievements",
    },

    -- Events & Special
    ["Events"] = {
        keywords = { "Event", "Festival", "Holiday", "Special", "Limited", "Seasonal" },
        emoji = "🎉",
        description = "Event and special occasion achievements",
    },
    ["Miscellaneous"] = {
        keywords = { "Misc", "Other", "General", "Various" },
        emoji = "🔧",
        description = "Miscellaneous achievements",
    },
}

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

local function CategorizeAchievement(achievementName, achievementDescription)
    if not achievementName then
        return "Miscellaneous"
    end

    local name = string.lower(achievementName)
    local description = string.lower(achievementDescription or "")
    local combined = name .. " " .. description

    -- Check each category
    for category, data in pairs(ACHIEVEMENT_CATEGORIES) do
        for _, keyword in ipairs(data.keywords) do
            if string.find(combined, string.lower(keyword)) then
                return category
            end
        end
    end

    return "Miscellaneous"
end

local function GetAchievementProgress(achievementId)
    local numCriteria = GetAchievementNumCriteria(achievementId) or 0
    local totalProgress = 0
    local totalRequired = 0
    local completedCriteria = 0

    for i = 1, numCriteria do
        local success, criterionName, numCompleted, numRequired = pcall(GetAchievementCriterion, achievementId, i)
        if success and numRequired and numRequired > 0 then
            totalProgress = totalProgress + (numCompleted or 0)
            totalRequired = totalRequired + numRequired
            if numCompleted and numCompleted >= numRequired then
                completedCriteria = completedCriteria + 1
            end
        end
    end

    return {
        totalProgress = totalProgress,
        totalRequired = totalRequired,
        completedCriteria = completedCriteria,
        totalCriteria = numCriteria,
        progressPercent = totalRequired > 0 and math.floor((totalProgress / totalRequired) * 100) or 0,
    }
end

local function GetAchievementPoints(achievementId)
    local success, points = pcall(GetAchievementPoints, achievementId)
    return success and points or 0
end

local function IsAchievementCompleted(achievementId)
    local success, completed = pcall(GetAchievementCompleted, achievementId)
    return success and completed or false
end

-- =====================================================
-- MAIN ACHIEVEMENT COLLECTOR
-- =====================================================

local function CollectAchievementData()
    local data = {
        summary = {
            totalAchievements = 0,
            completedAchievements = 0,
            totalPoints = 0,
            earnedPoints = 0,
            completionPercent = 0,
        },
        categories = {},
        recent = {},
        inProgress = {},
        completed = {},
    }

    -- Initialize category tracking
    for category, _ in pairs(ACHIEVEMENT_CATEGORIES) do
        data.categories[category] = {
            name = category,
            emoji = ACHIEVEMENT_CATEGORIES[category].emoji,
            description = ACHIEVEMENT_CATEGORIES[category].description,
            total = 0,
            completed = 0,
            points = 0,
            achievements = {},
        }
    end

    -- Use ESO's built-in functions for overall stats (much simpler!)
    data.summary.earnedPoints = CM.SafeCall(GetEarnedAchievementPoints) or 0
    data.summary.totalPoints = CM.SafeCall(GetTotalAchievementPoints) or 0

    local totalAchievements = 0
    local completedCount = 0

    -- ESO uses a category-based achievement system
    -- Iterate through all achievement categories
    local numCategories = CM.SafeCall(GetNumAchievementCategories) or 0
    CM.DebugPrint("ACHIEVEMENTS", string.format("Found %d achievement categories", numCategories))

    if numCategories == 0 then
        CM.Error("[ACHIEVEMENTS] WARNING: No achievement categories found - this is unexpected!")
        return data
    end

    -- Process each top-level category
    for topIndex = 1, numCategories do
        -- GetAchievementCategoryInfo returns: name, numSubCats, numAchievements, earnedPoints, totalPoints, hidesPoints
        local success, catName, numSubCats, numAchievements, earnedPoints, catTotalPoints =
            pcall(GetAchievementCategoryInfo, topIndex)

        CM.DebugPrint(
            "ACHIEVEMENTS",
            string.format(
                "Category %d: success=%s, name=%s, numSubCats=%s, numAchievements=%s",
                topIndex,
                tostring(success),
                tostring(catName),
                tostring(numSubCats),
                tostring(numAchievements)
            )
        )

        if success and catName then
            -- If category has subcategories, iterate through them
            if numSubCats and numSubCats > 0 then
                for subIndex = 1, numSubCats do
                    -- GetAchievementSubCategoryInfo returns: subName, numAchievements, earnedPoints, totalPoints
                    local success2, subName, subNumAchievements =
                        pcall(GetAchievementSubCategoryInfo, topIndex, subIndex)

                    if success2 and subName and subNumAchievements then
                        -- Iterate through achievements in this subcategory
                        for achIndex = 1, subNumAchievements do
                            local achievementId = CM.SafeCall(GetAchievementId, topIndex, subIndex, achIndex)

                            if achievementId and achievementId > 0 then
                                totalAchievements = totalAchievements + 1

                                -- GetAchievementInfo returns: name, description, points, icon, completed, date, time
                                local success, name, description, points, icon, completed =
                                    pcall(GetAchievementInfo, achievementId)
                                local timestamp = CM.SafeCall(GetAchievementTimestamp, achievementId) or 0

                                if success and name and name ~= "" then
                                    local category = CategorizeAchievement(name, description or "")
                                    local achievementData = {
                                        id = achievementId,
                                        name = name,
                                        description = description or "",
                                        points = points or 0,
                                        completed = completed or false,
                                        timestamp = timestamp,
                                        category = category,
                                        subcategory = subName or nil, -- Store ESO API subcategory
                                        progress = GetAchievementProgress(achievementId),
                                    }

                                    -- Track completed vs in-progress
                                    if completed then
                                        completedCount = completedCount + 1
                                        table.insert(data.completed, achievementData)
                                    else
                                        -- Check if in progress
                                        if
                                            achievementData.progress.totalRequired > 0
                                            and achievementData.progress.totalProgress > 0
                                        then
                                            table.insert(data.inProgress, achievementData)
                                        end
                                    end

                                    -- Update category data
                                    if data.categories[category] then
                                        data.categories[category].total = data.categories[category].total + 1
                                        data.categories[category].points = data.categories[category].points + points
                                        if completed then
                                            data.categories[category].completed = data.categories[category].completed
                                                + 1
                                        end
                                        table.insert(data.categories[category].achievements, achievementData)
                                    end
                                end
                            end
                        end
                    end
                end
            else
                -- Category has no subcategories, check for direct achievements
                if numAchievements and numAchievements > 0 then
                    for achIndex = 1, numAchievements do
                        -- For categories without subcategories, use nil for subIndex
                        local achievementId = CM.SafeCall(GetAchievementId, topIndex, nil, achIndex)

                        if achievementId and achievementId > 0 then
                            totalAchievements = totalAchievements + 1

                            -- GetAchievementInfo returns: name, description, points, icon, completed, date, time
                            local success, name, description, points, icon, completed =
                                pcall(GetAchievementInfo, achievementId)
                            local timestamp = CM.SafeCall(GetAchievementTimestamp, achievementId) or 0

                            if success and name and name ~= "" then
                                local category = CategorizeAchievement(name, description or "")
                                local achievementData = {
                                    id = achievementId,
                                    name = name,
                                    description = description or "",
                                    points = points or 0,
                                    completed = completed or false,
                                    timestamp = timestamp,
                                    category = category,
                                    subcategory = nil, -- No subcategory for categories without subcategories
                                    progress = GetAchievementProgress(achievementId),
                                }

                                -- Track completed vs in-progress
                                if completed then
                                    completedCount = completedCount + 1
                                    table.insert(data.completed, achievementData)
                                else
                                    -- Check if in progress
                                    if
                                        achievementData.progress.totalRequired > 0
                                        and achievementData.progress.totalProgress > 0
                                    then
                                        table.insert(data.inProgress, achievementData)
                                    end
                                end

                                -- Update category data
                                if data.categories[category] then
                                    data.categories[category].total = data.categories[category].total + 1
                                    data.categories[category].points = data.categories[category].points + (points or 0)
                                    if completed then
                                        data.categories[category].completed = data.categories[category].completed + 1
                                    end
                                    table.insert(data.categories[category].achievements, achievementData)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Update summary totals
    data.summary.totalAchievements = totalAchievements
    data.summary.completedAchievements = completedCount
    data.summary.completionPercent = totalAchievements > 0 and math.floor((completedCount / totalAchievements) * 100)
        or 0

    CM.DebugPrint(
        "ACHIEVEMENTS",
        string.format(
            "Collection complete: %d total, %d completed, %d/%d points",
            totalAchievements,
            completedCount,
            data.summary.earnedPoints,
            data.summary.totalPoints
        )
    )

    -- Get recent achievements using ESO's built-in function
    -- GetRecentlyCompletedAchievements returns variable number of values
    local recentResults = { pcall(GetRecentlyCompletedAchievements, 10) }
    if recentResults[1] then -- success
        -- First return value is success, rest are achievement IDs
        for i = 2, #recentResults do
            local achievementId = recentResults[i]
            if achievementId and achievementId > 0 then
                local success, name, description, points, icon, completed = pcall(GetAchievementInfo, achievementId)
                local timestamp = CM.SafeCall(GetAchievementTimestamp, achievementId) or 0

                if success and name and name ~= "" then
                    local category = CategorizeAchievement(name, description or "")
                    table.insert(data.recent, {
                        id = achievementId,
                        name = name,
                        description = description or "",
                        points = points or 0,
                        completed = true,
                        timestamp = timestamp,
                        category = category,
                    })
                end
            end
        end
    else
        -- Fallback: sort completed by timestamp
        table.sort(data.completed, function(a, b)
            return (a.timestamp or 0) > (b.timestamp or 0)
        end)
        for i = 1, math.min(10, #data.completed) do
            table.insert(data.recent, data.completed[i])
        end
    end

    -- Sort in-progress by progress percentage
    table.sort(data.inProgress, function(a, b)
        return a.progress.progressPercent > b.progress.progressPercent
    end)

    return data
end

-- =====================================================
-- SPECIALIZED COLLECTORS
-- =====================================================

local function CollectSkyshardAchievements()
    local skyshards = {
        total = 0,
        collected = 0,
        skillPoints = 0,
        achievements = {},
    }

    local numAchievements = GetNumAchievements() or 0

    for i = 1, numAchievements do
        local success, name = pcall(GetAchievementInfo, i)
        if success and name and string.find(name, "Skyshard") then
            local progress = GetAchievementProgress(i)
            local _, _, points, _, _, completed = GetAchievementInfo(i)

            table.insert(skyshards.achievements, {
                name = name,
                points = points or 0,
                completed = completed or false,
                progress = progress,
            })

            skyshards.total = skyshards.total + progress.totalRequired
            skyshards.collected = skyshards.collected + progress.totalProgress
        end
    end

    skyshards.skillPoints = math.floor(skyshards.collected / 3)

    return skyshards
end

local function CollectLorebookAchievements()
    local lorebooks = {
        total = 0,
        collected = 0,
        achievements = {},
    }

    local numAchievements = GetNumAchievements() or 0

    for i = 1, numAchievements do
        local success, name = pcall(GetAchievementInfo, i)
        if success and name and (string.find(name, "Lorebook") or string.find(name, "Lore")) then
            local progress = GetAchievementProgress(i)
            local _, _, points, _, _, completed = GetAchievementInfo(i)

            table.insert(lorebooks.achievements, {
                name = name,
                points = points or 0,
                completed = completed or false,
                progress = progress,
            })

            lorebooks.total = lorebooks.total + progress.totalRequired
            lorebooks.collected = lorebooks.collected + progress.totalProgress
        end
    end

    return lorebooks
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.collectors.CollectAchievementData = CollectAchievementData
CM.collectors.CollectSkyshardAchievements = CollectSkyshardAchievements
CM.collectors.CollectLorebookAchievements = CollectLorebookAchievements

return {
    CollectAchievementData = CollectAchievementData,
    CollectSkyshardAchievements = CollectSkyshardAchievements,
    CollectLorebookAchievements = CollectLorebookAchievements,
}
