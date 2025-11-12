-- CharacterMarkdown - Undaunted Pledges Data Collector
-- Undaunted pledges, dungeon progress, and keys

local CM = CharacterMarkdown

-- =====================================================
-- UNDAUNTED PLEDGES
-- =====================================================

local function CollectUndauntedPledgesData()
    local pledges = {
        daily = {
            normal = {},
            veteran = {},
            keys = 0,
        },
        weekly = {
            normal = {},
            veteran = {},
            keys = 0,
        },
        active = {}, -- Active pledges from quest journal
        progress = {
            totalCompleted = 0,
            totalAvailable = 0,
        },
    }

    -- Check quest journal for active pledges
    -- Cached globals - standard ESO APIs
    local GetNumJournalQuests = GetNumJournalQuests
    local GetJournalQuestName = GetJournalQuestName
    local GetJournalQuestLocationInfo = GetJournalQuestLocationInfo

    local numQuests = CM.SafeCall(GetNumJournalQuests)
    if numQuests and numQuests > 0 then
        for i = 1, numQuests do
            local questName = CM.SafeCall(GetJournalQuestName, i)
            if questName and questName ~= "" then
                -- Check if quest name contains "Pledge" (case-insensitive)
                if questName:lower():find("pledge") then
                    local locationInfo = CM.SafeCall(GetJournalQuestLocationInfo, i) or ""
                    table.insert(pledges.active, {
                        name = questName,
                        location = locationInfo,
                        index = i,
                    })
                end
            end
        end
    end

    -- Get daily pledges
    local numDailyPledges = CM.SafeCall(GetNumDailyPledges)
    if numDailyPledges then
        for i = 1, numDailyPledges do
            -- GetDailyPledgeInfo returns multiple values, need to use pcall
            local success, pledgeName, isCompleted, difficulty = pcall(GetDailyPledgeInfo, i)
            if success and pledgeName then
                local pledgeData = {
                    name = pledgeName,
                    completed = isCompleted or false,
                    difficulty = difficulty or "normal",
                    index = i,
                }

                if difficulty == "veteran" then
                    table.insert(pledges.daily.veteran, pledgeData)
                else
                    table.insert(pledges.daily.normal, pledgeData)
                end

                if isCompleted then
                    pledges.progress.totalCompleted = pledges.progress.totalCompleted + 1
                end
                pledges.progress.totalAvailable = pledges.progress.totalAvailable + 1
            end
        end
    end

    -- Get weekly pledges
    local numWeeklyPledges = CM.SafeCall(GetNumWeeklyPledges)
    if numWeeklyPledges then
        for i = 1, numWeeklyPledges do
            -- GetWeeklyPledgeInfo returns multiple values, need to use pcall
            local success, pledgeName, isCompleted, difficulty = pcall(GetWeeklyPledgeInfo, i)
            if success and pledgeName then
                local pledgeData = {
                    name = pledgeName,
                    completed = isCompleted or false,
                    difficulty = difficulty or "normal",
                    index = i,
                }

                if difficulty == "veteran" then
                    table.insert(pledges.weekly.veteran, pledgeData)
                else
                    table.insert(pledges.weekly.normal, pledgeData)
                end

                if isCompleted then
                    pledges.progress.totalCompleted = pledges.progress.totalCompleted + 1
                end
                pledges.progress.totalAvailable = pledges.progress.totalAvailable + 1
            end
        end
    end

    -- Get pledge keys
    local dailyKeys = CM.SafeCall(GetDailyPledgeKeys)
    if dailyKeys then
        pledges.daily.keys = dailyKeys
    end

    local weeklyKeys = CM.SafeCall(GetWeeklyPledgeKeys)
    if weeklyKeys then
        pledges.weekly.keys = weeklyKeys
    end

    return pledges
end

-- =====================================================
-- DUNGEON PROGRESS
-- =====================================================

local function CollectDungeonProgressData()
    local dungeonProgress = {
        normal = {
            total = 0,
            completed = 0,
            dungeons = {},
        },
        veteran = {
            total = 0,
            completed = 0,
            dungeons = {},
        },
        hardmode = {
            total = 0,
            completed = 0,
            dungeons = {},
        },
    }

    -- Get normal dungeon progress
    local numNormalDungeons = CM.SafeCall(GetNumNormalDungeons)
    if numNormalDungeons then
        dungeonProgress.normal.total = numNormalDungeons

        for i = 1, numNormalDungeons do
            -- GetNormalDungeonInfo returns multiple values, need to use pcall
            local success, dungeonName, isCompleted = pcall(GetNormalDungeonInfo, i)
            if success and dungeonName then
                if isCompleted then
                    dungeonProgress.normal.completed = dungeonProgress.normal.completed + 1
                end

                table.insert(dungeonProgress.normal.dungeons, {
                    name = dungeonName,
                    completed = isCompleted or false,
                    index = i,
                })
            end
        end
    end

    -- Get veteran dungeon progress
    local numVeteranDungeons = CM.SafeCall(GetNumVeteranDungeons)
    if numVeteranDungeons then
        dungeonProgress.veteran.total = numVeteranDungeons

        for i = 1, numVeteranDungeons do
            -- GetVeteranDungeonInfo returns multiple values, need to use pcall
            local success, dungeonName, isCompleted = pcall(GetVeteranDungeonInfo, i)
            if success and dungeonName then
                if isCompleted then
                    dungeonProgress.veteran.completed = dungeonProgress.veteran.completed + 1
                end

                table.insert(dungeonProgress.veteran.dungeons, {
                    name = dungeonName,
                    completed = isCompleted or false,
                    index = i,
                })
            end
        end
    end

    -- Get hardmode dungeon progress
    local numHardmodeDungeons = CM.SafeCall(GetNumHardmodeDungeons)
    if numHardmodeDungeons then
        dungeonProgress.hardmode.total = numHardmodeDungeons

        for i = 1, numHardmodeDungeons do
            -- GetHardmodeDungeonInfo returns multiple values, need to use pcall
            local success, dungeonName, isCompleted = pcall(GetHardmodeDungeonInfo, i)
            if success and dungeonName then
                if isCompleted then
                    dungeonProgress.hardmode.completed = dungeonProgress.hardmode.completed + 1
                end

                table.insert(dungeonProgress.hardmode.dungeons, {
                    name = dungeonName,
                    completed = isCompleted or false,
                    index = i,
                })
            end
        end
    end

    return dungeonProgress
end

-- =====================================================
-- UNDAUNTED KEYS
-- =====================================================

local function CollectUndauntedKeysData()
    local keys = {
        total = 0,
        categories = {},
    }

    -- Get key categories
    local numKeyCategories = CM.SafeCall(GetNumUndauntedKeyCategories)
    if numKeyCategories then
        for categoryIndex = 1, numKeyCategories do
            -- GetUndauntedKeyCategoryInfo returns multiple values, need to use pcall
            local success, categoryName, numKeys = pcall(GetUndauntedKeyCategoryInfo, categoryIndex)
            if success and categoryName and numKeys then
                local categoryData = {
                    name = categoryName,
                    total = numKeys,
                    keys = {},
                }

                -- Get keys in this category
                for keyIndex = 1, numKeys do
                    -- GetUndauntedKeyInfo returns multiple values, need to use pcall
                    local success, keyName, keyCount = pcall(GetUndauntedKeyInfo, categoryIndex, keyIndex)
                    if success and keyName then
                        table.insert(categoryData.keys, {
                            name = keyName,
                            count = keyCount or 0,
                            categoryIndex = categoryIndex,
                            keyIndex = keyIndex,
                        })
                    end
                end

                keys.categories[categoryName] = categoryData
                keys.total = keys.total + numKeys
            end
        end
    end

    return keys
end

-- =====================================================
-- MAIN UNDAUNTED PLEDGES COLLECTOR
-- =====================================================

local function CollectUndauntedPledgesDataMain()
    return {
        pledges = CollectUndauntedPledgesData(),
        dungeonProgress = CollectDungeonProgressData(),
        keys = CollectUndauntedKeysData(),
    }
end

CM.collectors.CollectUndauntedPledgesData = CollectUndauntedPledgesDataMain
