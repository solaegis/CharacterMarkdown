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
            keys = 0
        },
        weekly = {
            normal = {},
            veteran = {},
            keys = 0
        },
        progress = {
            totalCompleted = 0,
            totalAvailable = 0
        }
    }
    
    -- Get daily pledges
    local success, numDailyPledges = pcall(GetNumDailyPledges)
    if success and numDailyPledges then
        for i = 1, numDailyPledges do
            local success2, pledgeName, isCompleted, difficulty = pcall(GetDailyPledgeInfo, i)
            if success2 and pledgeName then
                local pledgeData = {
                    name = pledgeName,
                    completed = isCompleted or false,
                    difficulty = difficulty or "normal",
                    index = i
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
    local success3, numWeeklyPledges = pcall(GetNumWeeklyPledges)
    if success3 and numWeeklyPledges then
        for i = 1, numWeeklyPledges do
            local success4, pledgeName, isCompleted, difficulty = pcall(GetWeeklyPledgeInfo, i)
            if success4 and pledgeName then
                local pledgeData = {
                    name = pledgeName,
                    completed = isCompleted or false,
                    difficulty = difficulty or "normal",
                    index = i
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
    local success5, dailyKeys = pcall(GetDailyPledgeKeys)
    if success5 and dailyKeys then
        pledges.daily.keys = dailyKeys
    end
    
    local success6, weeklyKeys = pcall(GetWeeklyPledgeKeys)
    if success6 and weeklyKeys then
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
            dungeons = {}
        },
        veteran = {
            total = 0,
            completed = 0,
            dungeons = {}
        },
        hardmode = {
            total = 0,
            completed = 0,
            dungeons = {}
        }
    }
    
    -- Get normal dungeon progress
    local success, numNormalDungeons = pcall(GetNumNormalDungeons)
    if success and numNormalDungeons then
        dungeonProgress.normal.total = numNormalDungeons
        
        for i = 1, numNormalDungeons do
            local success2, dungeonName, isCompleted = pcall(GetNormalDungeonInfo, i)
            if success2 and dungeonName then
                if isCompleted then
                    dungeonProgress.normal.completed = dungeonProgress.normal.completed + 1
                end
                
                table.insert(dungeonProgress.normal.dungeons, {
                    name = dungeonName,
                    completed = isCompleted or false,
                    index = i
                })
            end
        end
    end
    
    -- Get veteran dungeon progress
    local success3, numVeteranDungeons = pcall(GetNumVeteranDungeons)
    if success3 and numVeteranDungeons then
        dungeonProgress.veteran.total = numVeteranDungeons
        
        for i = 1, numVeteranDungeons do
            local success4, dungeonName, isCompleted = pcall(GetVeteranDungeonInfo, i)
            if success4 and dungeonName then
                if isCompleted then
                    dungeonProgress.veteran.completed = dungeonProgress.veteran.completed + 1
                end
                
                table.insert(dungeonProgress.veteran.dungeons, {
                    name = dungeonName,
                    completed = isCompleted or false,
                    index = i
                })
            end
        end
    end
    
    -- Get hardmode dungeon progress
    local success5, numHardmodeDungeons = pcall(GetNumHardmodeDungeons)
    if success5 and numHardmodeDungeons then
        dungeonProgress.hardmode.total = numHardmodeDungeons
        
        for i = 1, numHardmodeDungeons do
            local success6, dungeonName, isCompleted = pcall(GetHardmodeDungeonInfo, i)
            if success6 and dungeonName then
                if isCompleted then
                    dungeonProgress.hardmode.completed = dungeonProgress.hardmode.completed + 1
                end
                
                table.insert(dungeonProgress.hardmode.dungeons, {
                    name = dungeonName,
                    completed = isCompleted or false,
                    index = i
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
        categories = {}
    }
    
    -- Get key categories
    local success, numKeyCategories = pcall(GetNumUndauntedKeyCategories)
    if success and numKeyCategories then
        for categoryIndex = 1, numKeyCategories do
            local success2, categoryName, numKeys = pcall(GetUndauntedKeyCategoryInfo, categoryIndex)
            if success2 and categoryName and numKeys then
                local categoryData = {
                    name = categoryName,
                    total = numKeys,
                    keys = {}
                }
                
                -- Get keys in this category
                for keyIndex = 1, numKeys do
                    local success3, keyName, keyCount = pcall(GetUndauntedKeyInfo, categoryIndex, keyIndex)
                    if success3 and keyName then
                        table.insert(categoryData.keys, {
                            name = keyName,
                            count = keyCount or 0,
                            categoryIndex = categoryIndex,
                            keyIndex = keyIndex
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
        keys = CollectUndauntedKeysData()
    }
end

CM.collectors.CollectUndauntedPledgesData = CollectUndauntedPledgesDataMain
