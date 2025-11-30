-- CharacterMarkdown - API Layer - Titles
-- Abstraction for character titles

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.titles = {}

local api = CM.api.titles

-- =====================================================
-- CACHING
-- =====================================================

local _titleCache = {}  -- Cache by titleId

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

function api.GetCurrentTitle()
    -- Use utility function if available, otherwise try direct API
    if CM.utils and CM.utils.GetPlayerTitle then
        return CM.utils.GetPlayerTitle() or ""
    end
    
    -- Fallback to direct API call
    local title = CM.SafeCall(GetUnitTitle, "player")
    return title or ""
end

function api.GetNumTitles()
    return CM.SafeCall(GetNumTitles) or 0
end

function api.GetTitle(titleId)
    -- Return cached if available
    if _titleCache[titleId] then
        return _titleCache[titleId]
    end
    
    local name = CM.SafeCall(GetTitle, titleId) or ""
    
    -- Cache the result (even if empty, to avoid repeated API calls)
    _titleCache[titleId] = name
    return name
end

function api.ClearCache()
    _titleCache = {}
end

function api.GetTitles()
    -- Returns array of owned title IDs
    return CM.SafeCall(GetTitles) or {}
end

function api.GetAllTitles()
    -- Returns list of all titles (owned and unowned)
    local titles = {}
    local ownedIds = api.GetTitles()
    local maxIndex = api.GetNumTitles()
    
    -- First, add owned titles
    local ownedMap = {}
    for _, id in ipairs(ownedIds) do
        ownedMap[id] = true
        local name = api.GetTitle(id)
        if name and name ~= "" then
            table.insert(titles, {
                id = id,
                name = name,
                owned = true
            })
        end
    end
    
    -- Then, iterate through all indices to find any missing owned titles
    -- (fallback for cases where GetTitles() doesn't return all)
    if maxIndex > 0 then
        for i = 1, maxIndex do
            if not ownedMap[i] then
                local name = api.GetTitle(i)
                if name and name ~= "" then
                    table.insert(titles, {
                        id = i,
                        name = name,
                        owned = true
                    })
                end
            end
        end
    end
    
    -- Sort by name
    table.sort(titles, function(a, b)
        return a.name < b.name
    end)
    
    return titles
end

-- Composition functions moved to collector level

CM.DebugPrint("API", "Titles API module loaded")

