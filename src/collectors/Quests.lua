-- CharacterMarkdown - Quest Data Collector
-- Phase 6: Comprehensive quest tracking and progress monitoring

local CM = CharacterMarkdown

-- =====================================================
-- QUEST CATEGORIES
-- =====================================================

local QUEST_CATEGORIES = {
    -- Main Story
    ["Main Story"] = {
        keywords = { "Main", "Story", "Main Quest", "Main Story", "Tutorial", "Prologue" },
        emoji = "📖",
        description = "Main storyline quests",
    },

    -- Zone Quests
    ["Zone Quests"] = {
        keywords = { "Zone", "Area", "Region", "Province", "Territory" },
        emoji = "🗺️",
        description = "Zone-specific quest lines",
    },

    -- Guild Quests
    ["Guild Quests"] = {
        keywords = { "Guild", "Fighters", "Mages", "Thieves", "Dark Brotherhood", "Psijic" },
        emoji = "🏰", -- Changed from 🏛️ for better compatibility
        description = "Guild-related quest lines",
    },

    -- DLC/Chapter Quests
    ["DLC Quests"] = {
        keywords = {
            "DLC",
            "Chapter",
            "Expansion",
            "Orsinium",
            "Thieves",
            "Dark Brotherhood",
            "Morrowind",
            "Summerset",
            "Elsweyr",
            "Greymoor",
            "Blackwood",
            "High Isle",
            "Necrom",
        },
        emoji = "📦",
        description = "DLC and chapter quest lines",
    },

    -- Daily Quests
    ["Daily Quests"] = {
        keywords = { "Daily", "Repeatable", "Writ", "Crafting", "Provisioning", "Enchanting", "Alchemy" },
        emoji = "🔄",
        description = "Daily and repeatable quests",
    },

    -- PvP Quests
    ["PvP Quests"] = {
        keywords = { "PvP", "Cyrodiil", "Battleground", "Alliance War", "Campaign", "Siege" },
        emoji = "⚔️",
        description = "Player vs Player quests",
    },

    -- Crafting Quests
    ["Crafting Quests"] = {
        keywords = { "Crafting", "Craft", "Smith", "Enchant", "Alchemy", "Provision", "Woodwork", "Cloth", "Jewelry" },
        emoji = "⚒️",
        description = "Crafting-related quests",
    },

    -- Companion Quests
    ["Companion Quests"] = {
        keywords = { "Companion", "Follower", "Bastian", "Mirri", "Ember", "Isobel", "Sharp-as-Night" },
        emoji = "👥",
        description = "Companion-related quests",
    },

    -- Event Quests
    ["Event Quests"] = {
        keywords = { "Event", "Festival", "Holiday", "Special", "Limited", "Seasonal" },
        emoji = "🎉",
        description = "Event and special quests",
    },

    -- Miscellaneous
    ["Miscellaneous"] = {
        keywords = { "Misc", "Other", "General", "Various" },
        emoji = "🔧",
        description = "Miscellaneous quests",
    },
}

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Cache string functions for performance
local string_lower = string.lower
local string_find = string.find

local function CategorizeQuest(questName, questType, questLevel)
    if not questName then
        return "Miscellaneous"
    end

    local name = string_lower(questName)
    local typeStr = string_lower(questType or "")
    local combined = name .. " " .. typeStr

    -- Check each category
    for category, categoryData in pairs(QUEST_CATEGORIES) do
        for _, keyword in ipairs(categoryData.keywords) do
            if string_find(combined, string_lower(keyword)) then
                return category
            end
        end
    end

    return "Miscellaneous"
end

local function BuildQuestProgress(activeStepText, completed)
    -- Build progress data from already-fetched quest info
    -- No redundant API calls
    return {
        totalSteps = completed and 1 or 1, -- Simple completion tracking
        completedSteps = completed and 1 or 0,
        currentStep = completed and 1 or 1,
        progressPercent = completed and 100 or 0,
        activeStepText = activeStepText or nil,
    }
end

local function GetQuestZone(questIndex)
    -- ESO doesn't provide a reliable API for quest zone lookup
    -- The quest journal doesn't expose zone information directly
    -- We could try to parse it from quest text, but that's unreliable

    -- Return the current player zone as a reasonable approximation
    -- Most active quests are in the player's current zone
    local success, zoneName = pcall(GetPlayerLocationName)
    if success and zoneName and zoneName ~= "" then
        return zoneName
    end

    -- Fallback to zone ID if location name fails
    local success2, zoneId = pcall(GetZoneId, GetUnitZoneIndex("player"))
    if success2 and zoneId then
        local success3, name = pcall(GetZoneNameById, zoneId)
        if success3 and name and name ~= "" then
            return name
        end
        return "Zone " .. tostring(zoneId)
    end

    -- Last resort: be honest about not knowing
    return "Unknown Zone"
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
            questsByCategory = {},
        },
        active = {},
        completed = {},
        categories = {},
        zones = {},
    }

    -- Wrap GetNumJournalQuests in pcall for safety
    local success, numActiveQuests = pcall(GetNumJournalQuests)
    if not success then
        CM.Error("GetNumJournalQuests failed: " .. tostring(numActiveQuests))
        return data -- Return empty but valid structure
    end

    numActiveQuests = numActiveQuests or 0
    data.summary.activeQuests = numActiveQuests

    CM.DebugPrint("QUESTS", "===== QUEST COLLECTOR STARTING =====")
    CM.DebugPrint("QUESTS", string.format("GetNumJournalQuests() returned: %d", numActiveQuests))

    if numActiveQuests == 0 then
        CM.DebugPrint("QUESTS", "No active quests found, returning empty data")
        return data
    end

    -- Initialize category tracking
    for categoryName, categoryInfo in pairs(QUEST_CATEGORIES) do
        data.categories[categoryName] = {
            name = categoryName,
            emoji = categoryInfo.emoji,
            description = categoryInfo.description,
            active = 0,
            completed = 0,
            quests = {},
        }
        data.summary.questsByCategory[categoryName] = 0
    end

    -- Process active quests
    CM.DebugPrint("QUESTS", string.format("Starting to process %d quests...", numActiveQuests))
    for i = 1, numActiveQuests do
        CM.DebugPrint("QUESTS", string.format("Processing quest %d/%d", i, numActiveQuests))
        -- Use pcall for ESO API call (returns multiple values, so we need pcall not SafeCall)
        -- Returns: questName, backgroundText, activeStepText, activeStepType, activeStepTrackerOverrideText,
        --          completed, tracked, questLevel (we only capture what we need)
        local success, questName, _, activeStepText, _, _, completed, _, questLevel = pcall(GetJournalQuestInfo, i)

        CM.DebugPrint(
            "QUESTS",
            string.format(
                "Quest %d: success=%s, name='%s', level=%s, completed=%s",
                i,
                tostring(success),
                tostring(questName),
                tostring(questLevel),
                tostring(completed)
            )
        )

        if success and questName then
            -- Get zone name (tries ESO API, falls back to current zone)
            -- Wrap in pcall to prevent any errors from crashing the collector
            local zoneSuccess, zoneName = pcall(GetQuestZone, i)
            if not zoneSuccess then
                CM.Warn("GetQuestZone failed for quest " .. i .. ": " .. tostring(zoneName))
                zoneName = "Unknown Zone"
            end

            -- Build progress data from already-fetched info (no redundant API call)
            local progress = BuildQuestProgress(activeStepText, completed)

            -- Quest type string - ESO doesn't provide easy localization for quest types
            local questTypeStr = "Quest"

            local questInfo = {
                index = i,
                name = questName or "Unknown Quest",
                level = questLevel or 0,
                type = questTypeStr,
                zone = zoneName,
                category = CategorizeQuest(questName, questTypeStr, questLevel),
                progress = progress,
                reward = nil, -- Not available via ESO API
                isActive = not completed,
                isCompleted = completed == true, -- Explicit boolean check
                activeStepText = activeStepText,
            }

            table.insert(data.active, questInfo)

            CM.DebugPrint(
                "QUESTS",
                string.format("  Added quest: '%s' to category '%s'", questName, questInfo.category)
            )

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
                    quests = {},
                }
            end
            data.zones[questInfo.zone].active = data.zones[questInfo.zone].active + 1
            table.insert(data.zones[questInfo.zone].quests, questInfo)
        else
            CM.Warn(
                string.format(
                    "Quest %d: Failed to process - success=%s, name=%s",
                    i,
                    tostring(success),
                    tostring(questName)
                )
            )
        end
    end

    -- Note: Completed quests are not easily accessible via the ESO API.
    -- ESO only provides journal access to active quests. Completed quest history
    -- would require external tracking or addon-specific saved variables.
    data.summary.totalQuests = numActiveQuests
    data.summary.completedQuests = 0 -- Not available via API

    CM.DebugPrint(
        "QUESTS",
        string.format(
            "===== QUEST COLLECTOR COMPLETE: Processed %d quests, %d in data.active =====",
            numActiveQuests,
            #data.active
        )
    )
    CM.DebugPrint(
        "QUESTS",
        string.format("Summary: activeQuests=%d, totalQuests=%d", data.summary.activeQuests, data.summary.totalQuests)
    )

    return data
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.collectors.CollectQuestData = CollectQuestData

return {
    CollectQuestData = CollectQuestData,
}
