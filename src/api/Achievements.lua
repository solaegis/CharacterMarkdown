-- CharacterMarkdown - API Layer - Achievements
-- Abstraction for achievement points and categories

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.achievements = {}

local api = CM.api.achievements

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

function api.GetPoints()
    local earned = CM.SafeCall(GetEarnedAchievementPoints) or 0
    local total = CM.SafeCall(GetTotalAchievementPoints) or 0
    return {
        earned = earned,
        total = total
    }
end

function api.GetNumCategories()
    return CM.SafeCall(GetNumAchievementCategories) or 0
end

function api.GetCategoryInfo(catIndex)
    local success, name, numSubCats, numAch, earned, total, hidesPoints = CM.SafeCallMulti(GetAchievementCategoryInfo, catIndex)

    return {
        name = name,
        earned = earned,
        total = total,
        numSubCategories = numSubCats,
        numAchievements = numAch
    }
end

function api.GetSubCategoryInfo(catIndex, subCatIndex)
    local success, name, numAch, earned, total = CM.SafeCallMulti(GetAchievementSubCategoryInfo, catIndex, subCatIndex)
    return {
        name = name,
        earned = earned,
        total = total,
        numAchievements = numAch
    }
end

function api.GetRecent()
    local ids = { CM.SafeCall(GetRecentlyCompletedAchievements, 5) }
    local recent = {}
    for _, id in ipairs(ids) do
        if type(id) == "number" then
            local success, name, desc, points, icon, completed, date, time = CM.SafeCallMulti(GetAchievementInfo, id)
            if name then
                table.insert(recent, {
                    id = id,
                    name = name,
                    date = date,
                    time = time
                })
            end
        end
    end
    return recent
end

-- Composition functions moved to collector level
