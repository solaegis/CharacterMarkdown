-- CharacterMarkdown - Quest Data Collector
-- Phase 6: Comprehensive quest tracking and progress monitoring

local CM = CharacterMarkdown

-- =====================================================
-- QUEST CATEGORIES
-- =====================================================

local QUEST_CATEGORIES = {
    -- Main Story
    ["Main Story"] = {
        keywords = {"Main", "Story", "Main Quest", "Main Story", "Tutorial", "Prologue"},
        emoji = "📖",
        description = "Main storyline quests"
    },
    
    -- Zone Quests
    ["Zone Quests"] = {
        keywords = {"Zone", "Area", "Region", "Province", "Territory"},
        emoji = "🗺️",
        description = "Zone-specific quest lines"
    },
    
    -- Guild Quests
    ["Guild Quests"] = {
        keywords = {"Guild", "Fighters", "Mages", "Thieves", "Dark Brotherhood", "Psijic"},
        emoji = "🏰",  -- Changed from 🏛️ for better compatibility
        description = "Guild-related quest lines"
    },
    
    -- DLC/Chapter Quests
    ["DLC Quests"] = {
        keywords = {"DLC", "Chapter", "Expansion", "Orsinium", "Thieves", "Dark Brotherhood", "Morrowind", "Summerset", "Elsweyr", "Greymoor", "Blackwood", "High Isle", "Necrom"},
        emoji = "📦",
        description = "DLC and chapter quest lines"
    },
    
    -- Daily Quests
    ["Daily Quests"] = {
        keywords = {"Daily", "Repeatable", "Writ", "Crafting", "Provisioning", "Enchanting", "Alchemy"},
        emoji = "🔄",
        description = "Daily and repeatable quests"
    },
    
    -- PvP Quests
    ["PvP Quests"] = {
        keywords = {"PvP", "Cyrodiil", "Battleground", "Alliance War", "Campaign", "Siege"},
        emoji = "⚔️",
        description = "Player vs Player quests"
    },
    
    -- Crafting Quests
    ["Crafting Quests"] = {
        keywords = {"Crafting", "Craft", "Smith", "Enchant", "Alchemy", "Provision", "Woodwork", "Cloth", "Jewelry"},
        emoji = "⚒️",
        description = "Crafting-related quests"
    },
    
    -- Companion Quests
    ["Companion Quests"] = {
        keywords = {"Companion", "Follower", "Bastian", "Mirri", "Ember", "Isobel", "Sharp-as-Night"},
        emoji = "👥",
        description = "Companion-related quests"
    },
    
    -- Event Quests
    ["Event Quests"] = {
        keywords = {"Event", "Festival", "Holiday", "Special", "Limited", "Seasonal"},
        emoji = "🎉",
        description = "Event and special quests"
    },
    
    -- Miscellaneous
    ["Miscellaneous"] = {
        keywords = {"Misc", "Other", "General", "Various"},
        emoji = "🔧",
        description = "Miscellaneous quests"
    }
}

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

local function CategorizeQuest(questName, questType, questLevel)
    if not questName then
        return "Miscellaneous"
    end
    
    local name = string.lower(questName)
    local typeStr = string.lower(questType or "")
    local combined = name .. " " .. typeStr
    
    -- Check each category
    for category, data in pairs(QUEST_CATEGORIES) do
        for _, keyword in ipairs(data.keywords) do
            if string.find(combined, string.lower(keyword)) then
                return category
            end
        end
    end
    
    return "Miscellaneous"
end

local function GetQuestProgress(questIndex)
    local numSteps = GetJournalQuestNumSteps(questIndex) or 0
    local completedSteps = 0
    local currentStep = 0
    
    for i = 1, numSteps do
        local success, stepText, stepType, stepTracker, stepCompleted = pcall(GetJournalQuestStepInfo, questIndex, i)
        if success then
            if stepCompleted then
                completedSteps = completedSteps + 1
            else
                currentStep = i
                break
            end
        end
    end
    
    return {
        totalSteps = numSteps,
        completedSteps = completedSteps,
        currentStep = currentStep,
        progressPercent = numSteps > 0 and math.floor((completedSteps / numSteps) * 100) or 0
    }
end

local function GetQuestZone(questIndex)
    local success, zoneName = pcall(GetJournalQuestZoneInfo, questIndex)
    return success and zoneName or "Unknown Zone"
end

local function GetQuestReward(questIndex)
    local success, rewardType, rewardAmount = pcall(GetJournalQuestRewardInfo, questIndex)
    if success and rewardType and rewardAmount then
        return {
            type = rewardType,
            amount = rewardAmount,
            description = GetString("SI_QUESTREWARDTYPE", rewardType) or "Unknown Reward"
        }
    end
    return nil
end

-- =====================================================
-- MAIN QUEST COLLECTOR
-- =====================================================

local function CollectQuestData()
    local data = {
        summary = {
            activeQuests = 0,
            totalQuests = 0,
            completedQuests = 0,
            questsByCategory = {}
        },
        active = {},
        completed = {},
        categories = {},
        zones = {}
    }
    
    local numActiveQuests = GetNumJournalQuests() or 0
    data.summary.activeQuests = numActiveQuests
    
    if numActiveQuests == 0 then
        return data
    end
    
    -- Initialize category tracking
    for category, _ in pairs(QUEST_CATEGORIES) do
        data.categories[category] = {
            name = category,
            emoji = QUEST_CATEGORIES[category].emoji,
            description = QUEST_CATEGORIES[category].description,
            active = 0,
            completed = 0,
            quests = {}
        }
        data.summary.questsByCategory[category] = 0
    end
    
    -- Process active quests
    for i = 1, numActiveQuests do
        local success, questInfo = pcall(function()
            local questName, _, _, _, _, _, questLevel, questType = GetJournalQuestInfo(i)
            local zoneName = GetQuestZone(i)
            local progress = GetQuestProgress(i)
            local reward = GetQuestReward(i)
            
            return {
                index = i,
                name = questName or "Unknown Quest",
                level = questLevel or 0,
                type = questType and GetString("SI_QUESTTYPE", questType) or "Quest",
                zone = zoneName,
                category = CategorizeQuest(questName, questType, questLevel),
                progress = progress,
                reward = reward,
                isActive = true,
                isCompleted = false
            }
        end)
        
        if success and questInfo then
            table.insert(data.active, questInfo)
            
            -- Update category data
            local category = questInfo.category
            if data.categories[category] then
                data.categories[category].active = data.categories[category].active + 1
                data.summary.questsByCategory[category] = data.summary.questsByCategory[category] + 1
                table.insert(data.categories[category].quests, questInfo)
            end
            
            -- Update zone data
            if not data.zones[questInfo.zone] then
                data.zones[questInfo.zone] = {
                    name = questInfo.zone,
                    active = 0,
                    completed = 0,
                    quests = {}
                }
            end
            data.zones[questInfo.zone].active = data.zones[questInfo.zone].active + 1
            table.insert(data.zones[questInfo.zone].quests, questInfo)
        end
    end
    
    -- Note: Completed quests are not easily accessible via the ESO API
    -- This would require additional tracking or external data sources
    data.summary.totalQuests = numActiveQuests
    data.summary.completedQuests = 0  -- Not available via API
    
    return data
end

-- =====================================================
-- SPECIALIZED QUEST COLLECTORS
-- =====================================================

local function CollectMainStoryQuests()
    local mainStory = {
        total = 0,
        completed = 0,
        active = 0,
        quests = {}
    }
    
    local numQuests = GetNumJournalQuests() or 0
    
    for i = 1, numQuests do
        local success, questName, _, _, _, _, questLevel, questType = pcall(GetJournalQuestInfo, i)
        if success and questName then
            local category = CategorizeQuest(questName, questType, questLevel)
            if category == "Main Story" then
                local progress = GetQuestProgress(i)
                local zone = GetQuestZone(i)
                
                table.insert(mainStory.quests, {
                    name = questName,
                    level = questLevel or 0,
                    type = questType and GetString("SI_QUESTTYPE", questType) or "Quest",
                    zone = zone,
                    progress = progress,
                    isActive = true,
                    isCompleted = false
                })
                
                mainStory.active = mainStory.active + 1
                mainStory.total = mainStory.total + 1
            end
        end
    end
    
    return mainStory
end

local function CollectGuildQuests()
    local guildQuests = {
        total = 0,
        completed = 0,
        active = 0,
        byGuild = {}
    }
    
    local guilds = {
        "Fighters Guild",
        "Mages Guild", 
        "Thieves Guild",
        "Dark Brotherhood",
        "Psijic Order"
    }
    
    for _, guildName in ipairs(guilds) do
        guildQuests.byGuild[guildName] = {
            name = guildName,
            active = 0,
            completed = 0,
            quests = {}
        }
    end
    
    local numQuests = GetNumJournalQuests() or 0
    
    for i = 1, numQuests do
        local success, questName, _, _, _, _, questLevel, questType = pcall(GetJournalQuestInfo, i)
        if success and questName then
            local category = CategorizeQuest(questName, questType, questLevel)
            if category == "Guild Quests" then
                local progress = GetQuestProgress(i)
                local zone = GetQuestZone(i)
                
                -- Determine which guild this quest belongs to
                local guildName = "Unknown Guild"
                local questNameLower = string.lower(questName)
                if string.find(questNameLower, "fighter") then
                    guildName = "Fighters Guild"
                elseif string.find(questNameLower, "mage") then
                    guildName = "Mages Guild"
                elseif string.find(questNameLower, "thief") then
                    guildName = "Thieves Guild"
                elseif string.find(questNameLower, "dark brotherhood") or string.find(questNameLower, "brotherhood") then
                    guildName = "Dark Brotherhood"
                elseif string.find(questNameLower, "psijic") then
                    guildName = "Psijic Order"
                end
                
                local questData = {
                    name = questName,
                    level = questLevel or 0,
                    type = questType and GetString("SI_QUESTTYPE", questType) or "Quest",
                    zone = zone,
                    progress = progress,
                    isActive = true,
                    isCompleted = false
                }
                
                table.insert(guildQuests.byGuild[guildName].quests, questData)
                guildQuests.byGuild[guildName].active = guildQuests.byGuild[guildName].active + 1
                guildQuests.active = guildQuests.active + 1
                guildQuests.total = guildQuests.total + 1
            end
        end
    end
    
    return guildQuests
end

local function CollectDailyQuests()
    local dailyQuests = {
        total = 0,
        completed = 0,
        active = 0,
        byType = {}
    }
    
    local dailyTypes = {
        "Crafting Writs",
        "Provisioning Writs", 
        "Enchanting Writs",
        "Alchemy Writs",
        "Daily Quests",
        "Repeatable Quests"
    }
    
    for _, typeName in ipairs(dailyTypes) do
        dailyQuests.byType[typeName] = {
            name = typeName,
            active = 0,
            completed = 0,
            quests = {}
        }
    end
    
    local numQuests = GetNumJournalQuests() or 0
    
    for i = 1, numQuests do
        local success, questName, _, _, _, _, questLevel, questType = pcall(GetJournalQuestInfo, i)
        if success and questName then
            local category = CategorizeQuest(questName, questType, questLevel)
            if category == "Daily Quests" then
                local progress = GetQuestProgress(i)
                local zone = GetQuestZone(i)
                
                -- Determine daily quest type
                local typeName = "Daily Quests"
                local questNameLower = string.lower(questName)
                if string.find(questNameLower, "writ") then
                    if string.find(questNameLower, "craft") then
                        typeName = "Crafting Writs"
                    elseif string.find(questNameLower, "provision") then
                        typeName = "Provisioning Writs"
                    elseif string.find(questNameLower, "enchant") then
                        typeName = "Enchanting Writs"
                    elseif string.find(questNameLower, "alchemy") then
                        typeName = "Alchemy Writs"
                    end
                elseif string.find(questNameLower, "repeat") then
                    typeName = "Repeatable Quests"
                end
                
                local questData = {
                    name = questName,
                    level = questLevel or 0,
                    type = questType and GetString("SI_QUESTTYPE", questType) or "Quest",
                    zone = zone,
                    progress = progress,
                    isActive = true,
                    isCompleted = false
                }
                
                table.insert(dailyQuests.byType[typeName].quests, questData)
                dailyQuests.byType[typeName].active = dailyQuests.byType[typeName].active + 1
                dailyQuests.active = dailyQuests.active + 1
                dailyQuests.total = dailyQuests.total + 1
            end
        end
    end
    
    return dailyQuests
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.collectors.CollectQuestData = CollectQuestData
CM.collectors.CollectMainStoryQuests = CollectMainStoryQuests
CM.collectors.CollectGuildQuests = CollectGuildQuests
CM.collectors.CollectDailyQuests = CollectDailyQuests

return {
    CollectQuestData = CollectQuestData,
    CollectMainStoryQuests = CollectMainStoryQuests,
    CollectGuildQuests = CollectGuildQuests,
    CollectDailyQuests = CollectDailyQuests
}
