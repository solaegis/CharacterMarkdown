-- CharacterMarkdown - Achievement Data Collector
-- Phase 5: Comprehensive achievement tracking and categorization

local CM = CharacterMarkdown

-- =====================================================
-- ACHIEVEMENT CATEGORIES
-- =====================================================

local ACHIEVEMENT_CATEGORIES = {
    -- Combat & PvP
    ["Combat"] = {
        keywords = {"Combat", "Battle", "Fight", "Kill", "Defeat", "Slay", "Destroy", "Vanquish"},
        emoji = "⚔️",
        description = "Combat and battle-related achievements"
    },
    ["PvP"] = {
        keywords = {"PvP", "Cyrodiil", "Battleground", "Alliance War", "Emperor", "Campaign", "Siege"},
        emoji = "🏰",
        description = "Player vs Player achievements"
    },
    
    -- Exploration & World
    ["Exploration"] = {
        keywords = {"Explorer", "Discover", "Visit", "Travel", "Journey", "Wanderer", "Pathfinder"},
        emoji = "🗺️",
        description = "Exploration and world discovery achievements"
    },
    ["Skyshards"] = {
        keywords = {"Skyshard", "Skyshards"},
        emoji = "⭐",
        description = "Skyshard collection achievements"
    },
    ["Lorebooks"] = {
        keywords = {"Lorebook", "Lorebooks", "Lore", "Book", "Knowledge"},
        emoji = "📚",
        description = "Lorebook collection achievements"
    },
    
    -- Crafting & Economy
    ["Crafting"] = {
        keywords = {"Craft", "Crafting", "Smith", "Enchant", "Alchemy", "Provision", "Woodwork", "Cloth", "Jewelry"},
        emoji = "⚒️",
        description = "Crafting and profession achievements"
    },
    ["Economy"] = {
        keywords = {"Gold", "Money", "Trade", "Merchant", "Vendor", "Sell", "Buy", "Market"},
        emoji = "💰",
        description = "Economic and trading achievements"
    },
    
    -- Social & Guild
    ["Social"] = {
        keywords = {"Guild", "Friend", "Social", "Group", "Party", "Team", "Guildmate"},
        emoji = "👥",
        description = "Social and guild-related achievements"
    },
    ["Dungeons"] = {
        keywords = {"Dungeon", "Dungeons", "Trial", "Trials", "Group", "Raid", "Instance"},
        emoji = "🏛️",
        description = "Dungeon and trial achievements"
    },
    
    -- Character Development
    ["Character"] = {
        keywords = {"Level", "Experience", "Skill", "Champion", "CP", "Progression", "Advancement"},
        emoji = "📈",
        description = "Character progression achievements"
    },
    ["Vampire"] = {
        keywords = {"Vampire", "Vampirism", "Blood", "Undead"},
        emoji = "🧛",
        description = "Vampire-related achievements"
    },
    ["Werewolf"] = {
        keywords = {"Werewolf", "Lycanthropy", "Wolf", "Beast", "Transformation"},
        emoji = "🐺",
        description = "Werewolf-related achievements"
    },
    
    -- Collectibles & Housing
    ["Collectibles"] = {
        keywords = {"Collectible", "Collectibles", "Mount", "Pet", "Costume", "Outfit", "Style"},
        emoji = "🎨",
        description = "Collectible and cosmetic achievements"
    },
    ["Housing"] = {
        keywords = {"House", "Housing", "Home", "Furniture", "Decorate", "Residence"},
        emoji = "🏠",
        description = "Housing and decoration achievements"
    },
    
    -- Events & Special
    ["Events"] = {
        keywords = {"Event", "Festival", "Holiday", "Special", "Limited", "Seasonal"},
        emoji = "🎉",
        description = "Event and special occasion achievements"
    },
    ["Miscellaneous"] = {
        keywords = {"Misc", "Other", "General", "Various"},
        emoji = "🔧",
        description = "Miscellaneous achievements"
    }
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
        progressPercent = totalRequired > 0 and math.floor((totalProgress / totalRequired) * 100) or 0
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
            completionPercent = 0
        },
        categories = {},
        recent = {},
        inProgress = {},
        completed = {}
    }
    
    local success, numAchievements = pcall(GetNumAchievements)
    if not success or not numAchievements then
        numAchievements = 0
    end
    data.summary.totalAchievements = numAchievements
    
    if numAchievements == 0 then
        return data
    end
    
    local completedCount = 0
    local earnedPoints = 0
    local totalPoints = 0
    
    -- Initialize category tracking
    for category, _ in pairs(ACHIEVEMENT_CATEGORIES) do
        data.categories[category] = {
            name = category,
            emoji = ACHIEVEMENT_CATEGORIES[category].emoji,
            description = ACHIEVEMENT_CATEGORIES[category].description,
            total = 0,
            completed = 0,
            points = 0,
            achievements = {}
        }
    end
    
    -- Process each achievement
    for i = 1, numAchievements do
        local success, name, description, points, icon, completed = pcall(GetAchievementInfo, i)
        
        if success and name then
            local category = CategorizeAchievement(name, description)
            local achievementData = {
                id = i,
                name = name,
                description = description or "",
                points = points or 0,
                completed = completed or false,
                category = category,
                progress = GetAchievementProgress(i)
            }
            
            -- Update summary
            totalPoints = totalPoints + (points or 0)
            if completed then
                completedCount = completedCount + 1
                earnedPoints = earnedPoints + (points or 0)
                table.insert(data.completed, achievementData)
            else
                -- Check if in progress (has some progress but not completed)
                if achievementData.progress.totalRequired > 0 and achievementData.progress.totalProgress > 0 then
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
    
    -- Update summary
    data.summary.completedAchievements = completedCount
    data.summary.totalPoints = totalPoints
    data.summary.earnedPoints = earnedPoints
    data.summary.completionPercent = numAchievements > 0 and math.floor((completedCount / numAchievements) * 100) or 0
    
    -- Sort recent achievements (last 10 completed)
    table.sort(data.completed, function(a, b)
        return a.id > b.id  -- Assuming higher ID = more recent
    end)
    data.recent = {}
    for i = 1, math.min(10, #data.completed) do
        table.insert(data.recent, data.completed[i])
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
        achievements = {}
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
                progress = progress
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
        achievements = {}
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
                progress = progress
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
    CollectLorebookAchievements = CollectLorebookAchievements
}
