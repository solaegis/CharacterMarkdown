-- CharacterMarkdown - API Layer - Undaunted Pledges
-- Abstraction for Undaunted pledges, dungeon progress, and keys

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.undauntedPledges = {}

local api = CM.api.undauntedPledges

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

-- GetActivePledges() removed - active pledges are quests, handled by Quests collector

function api.GetDailyPledges()
    local pledges = { normal = {}, veteran = {} }
    local numDailyPledges = CM.SafeCall(GetNumDailyPledges) or 0
    
    for i = 1, numDailyPledges do
        local success, pledgeName, isCompleted, difficulty = pcall(GetDailyPledgeInfo, i)
        if success and pledgeName then
            local pledgeData = {
                name = pledgeName,
                completed = isCompleted or false,
                difficulty = difficulty or "normal",
                index = i
            }
            
            if difficulty == "veteran" then
                table.insert(pledges.veteran, pledgeData)
            else
                table.insert(pledges.normal, pledgeData)
            end
        end
    end
    
    return pledges
end

function api.GetWeeklyPledges()
    local pledges = { normal = {}, veteran = {} }
    local numWeeklyPledges = CM.SafeCall(GetNumWeeklyPledges) or 0
    
    for i = 1, numWeeklyPledges do
        local success, pledgeName, isCompleted, difficulty = pcall(GetWeeklyPledgeInfo, i)
        if success and pledgeName then
            local pledgeData = {
                name = pledgeName,
                completed = isCompleted or false,
                difficulty = difficulty or "normal",
                index = i
            }
            
            if difficulty == "veteran" then
                table.insert(pledges.veteran, pledgeData)
            else
                table.insert(pledges.normal, pledgeData)
            end
        end
    end
    
    return pledges
end

function api.GetPledgeKeys()
    return {
        daily = CM.SafeCall(GetDailyPledgeKeys) or 0,
        weekly = CM.SafeCall(GetWeeklyPledgeKeys) or 0
    }
end

function api.GetDungeonProgress()
    local progress = {
        normal = { total = 0, completed = 0, dungeons = {} },
        veteran = { total = 0, completed = 0, dungeons = {} },
        hardmode = { total = 0, completed = 0, dungeons = {} }
    }
    
    -- Normal dungeons
    local numNormalDungeons = CM.SafeCall(GetNumNormalDungeons) or 0
    progress.normal.total = numNormalDungeons
    
    for i = 1, numNormalDungeons do
        local success, dungeonName, isCompleted = pcall(GetNormalDungeonInfo, i)
        if success and dungeonName then
            if isCompleted then
                progress.normal.completed = progress.normal.completed + 1
            end
            table.insert(progress.normal.dungeons, {
                name = dungeonName,
                completed = isCompleted or false,
                index = i
            })
        end
    end
    
    -- Veteran dungeons
    local numVeteranDungeons = CM.SafeCall(GetNumVeteranDungeons) or 0
    progress.veteran.total = numVeteranDungeons
    
    for i = 1, numVeteranDungeons do
        local success, dungeonName, isCompleted = pcall(GetVeteranDungeonInfo, i)
        if success and dungeonName then
            if isCompleted then
                progress.veteran.completed = progress.veteran.completed + 1
            end
            table.insert(progress.veteran.dungeons, {
                name = dungeonName,
                completed = isCompleted or false,
                index = i
            })
        end
    end
    
    -- Hardmode dungeons
    local numHardmodeDungeons = CM.SafeCall(GetNumHardmodeDungeons) or 0
    progress.hardmode.total = numHardmodeDungeons
    
    for i = 1, numHardmodeDungeons do
        local success, dungeonName, isCompleted = pcall(GetHardmodeDungeonInfo, i)
        if success and dungeonName then
            if isCompleted then
                progress.hardmode.completed = progress.hardmode.completed + 1
            end
            table.insert(progress.hardmode.dungeons, {
                name = dungeonName,
                completed = isCompleted or false,
                index = i
            })
        end
    end
    
    return progress
end

function api.GetUndauntedKeys()
    local keys = {
        total = 0,
        categories = {}
    }
    
    local numKeyCategories = CM.SafeCall(GetNumUndauntedKeyCategories) or 0
    
    for categoryIndex = 1, numKeyCategories do
        local success, categoryName, numKeys = pcall(GetUndauntedKeyCategoryInfo, categoryIndex)
        if success and categoryName and numKeys then
            local categoryData = {
                name = categoryName,
                total = numKeys,
                keys = {}
            }
            
            for keyIndex = 1, numKeys do
                local success2, keyName, keyCount = pcall(GetUndauntedKeyInfo, categoryIndex, keyIndex)
                if success2 and keyName then
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
    
    return keys
end

-- Composition functions moved to collector level

CM.DebugPrint("API", "UndauntedPledges API module loaded")

