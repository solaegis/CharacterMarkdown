-- CharacterMarkdown - Event System

local CM = CharacterMarkdown

local function OnAddOnLoaded(event, addonName)
    if addonName ~= CM.name then
        return
    end

    -- Update version from manifest now that addon is loaded
    CM.UpdateVersion()

    CM.Info("v" .. CM.version .. " Loading...")
    EVENT_MANAGER:UnregisterForEvent(CM.name, EVENT_ADD_ON_LOADED)

    if not CM.ValidateModules() then
        CM.Error("Module validation failed! Addon may not work correctly.")
        return
    end

    -- Initialize SavedVariables in ADD_ON_LOADED
    -- Per ESO best practices, SavedVariables MUST be initialized during ADD_ON_LOADED
    if CM.Settings and CM.Settings.Initializer then
        -- Use full Initialize() method which handles all initialization including format sync
        local success = CM.Settings.Initializer:Initialize()
        if not success then
            CM.Error("Settings initialization failed!")
        end
    else
        CM.Error("Settings.Initializer not available!")
    end
end

local function OnPlayerActivated(event)
    if not CM.isInitialized then
        if CM.Settings and CM.Settings.Panel then
            CM.Settings.Panel:Initialize()
        end

        CM.isInitialized = true
        CM.Success("Ready! Use /markdown to generate character profile")

        EVENT_MANAGER:UnregisterForEvent(CM.name, EVENT_PLAYER_ACTIVATED)
        return
    end

    EVENT_MANAGER:UnregisterForEvent(CM.name, EVENT_PLAYER_ACTIVATED)
end

-- =====================================================
-- CACHE INVALIDATION HANDLERS
-- =====================================================

-- Throttling mechanism to prevent rapid successive cache clears
local pendingCacheClear = {}
local CACHE_CLEAR_DELAY_MS = 500

local function ThrottledCacheClear(cacheKey, clearFunc, debugMessage)
    if pendingCacheClear[cacheKey] then
        return
    end
    pendingCacheClear[cacheKey] = true

    zo_callLater(function()
        if clearFunc then
            clearFunc()
            CM.DebugPrint("CACHE", debugMessage)
        end
        pendingCacheClear[cacheKey] = nil
    end, CACHE_CLEAR_DELAY_MS)
end

local function OnCollectibleUnlocked(event, collectibleId)
    -- Clear collectibles cache when a collectible is unlocked (throttled)
    if CM.api and CM.api.collectibles and CM.api.collectibles.ClearCache then
        ThrottledCacheClear(
            "collectibles",
            CM.api.collectibles.ClearCache,
            "Collectibles cache cleared (collectible unlocked: " .. tostring(collectibleId) .. ")"
        )
    end
end

local function OnSkillRankUpdate(event, skillType, skillLineIndex, skillIndex, rank)
    -- Clear skills cache when a skill rank changes (throttled)
    if CM.api and CM.api.skills and CM.api.skills.ClearCache then
        ThrottledCacheClear("skills", CM.api.skills.ClearCache, "Skills cache cleared (skill rank updated)")
    end
end

local function OnSkillPointsChanged(event)
    -- Clear skills cache when skill points change (throttled)
    if CM.api and CM.api.skills and CM.api.skills.ClearCache then
        ThrottledCacheClear("skills", CM.api.skills.ClearCache, "Skills cache cleared (skill points changed)")
    end
end

local function OnTitleUnlocked(event, titleId)
    -- Clear titles cache when a title is unlocked (throttled)
    if CM.api and CM.api.titles and CM.api.titles.ClearCache then
        ThrottledCacheClear(
            "titles",
            CM.api.titles.ClearCache,
            "Titles cache cleared (title unlocked: " .. tostring(titleId) .. ")"
        )
    end
end

local function OnAntiquityUnlocked(event, antiquityId)
    -- Clear antiquities cache when an antiquity is unlocked (throttled)
    if CM.api and CM.api.antiquities and CM.api.antiquities.ClearCache then
        ThrottledCacheClear(
            "antiquities",
            CM.api.antiquities.ClearCache,
            "Antiquities cache cleared (antiquity unlocked: " .. tostring(antiquityId) .. ")"
        )
    end
end

local function OnHouseOwnershipChanged(event, houseId)
    -- Clear collectibles cache when house ownership changes (throttled)
    if CM.api and CM.api.collectibles and CM.api.collectibles.ClearCache then
        ThrottledCacheClear(
            "collectibles",
            CM.api.collectibles.ClearCache,
            "Collectibles cache cleared (house ownership changed: " .. tostring(houseId) .. ")"
        )
    end
end

local function RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(CM.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
    EVENT_MANAGER:RegisterForEvent(CM.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

    -- Register cache invalidation events (only if events exist)
    -- Use pcall to safely register events that may not exist in all ESO versions

    -- Collectibles cache invalidation
    local success1 = pcall(function()
        EVENT_MANAGER:RegisterForEvent(CM.name, EVENT_COLLECTIBLE_UNLOCKED, OnCollectibleUnlocked)
    end)
    if not success1 then
        CM.DebugPrint("CACHE", "EVENT_COLLECTIBLE_UNLOCKED not available")
    end

    -- Skills cache invalidation
    local success2 = pcall(function()
        EVENT_MANAGER:RegisterForEvent(CM.name, EVENT_SKILL_RANK_UPDATE, OnSkillRankUpdate)
    end)
    if not success2 then
        CM.DebugPrint("CACHE", "EVENT_SKILL_RANK_UPDATE not available")
    end

    local success3 = pcall(function()
        EVENT_MANAGER:RegisterForEvent(CM.name, EVENT_SKILL_POINTS_CHANGED, OnSkillPointsChanged)
    end)
    if not success3 then
        CM.DebugPrint("CACHE", "EVENT_SKILL_POINTS_CHANGED not available")
    end

    -- Titles cache invalidation
    local success4 = pcall(function()
        EVENT_MANAGER:RegisterForEvent(CM.name, EVENT_TITLE_UNLOCKED, OnTitleUnlocked)
    end)
    if not success4 then
        CM.DebugPrint("CACHE", "EVENT_TITLE_UNLOCKED not available")
    end

    -- Antiquities cache invalidation
    local success5 = pcall(function()
        EVENT_MANAGER:RegisterForEvent(CM.name, EVENT_ANTIQUITY_UNLOCKED, OnAntiquityUnlocked)
    end)
    if not success5 then
        CM.DebugPrint("CACHE", "EVENT_ANTIQUITY_UNLOCKED not available")
    end

    -- House ownership changes (houses are collectibles)
    local success6 = pcall(function()
        EVENT_MANAGER:RegisterForEvent(CM.name, EVENT_HOUSE_OWNERSHIP_CHANGED, OnHouseOwnershipChanged)
    end)
    if not success6 then
        CM.DebugPrint("CACHE", "EVENT_HOUSE_OWNERSHIP_CHANGED not available")
    end
end

local function UnregisterEvents()
    EVENT_MANAGER:UnregisterForEvent(CM.name, EVENT_ADD_ON_LOADED)

    -- Unregister cache invalidation events (safely handle missing events)
    pcall(function()
        EVENT_MANAGER:UnregisterForEvent(CM.name, EVENT_COLLECTIBLE_UNLOCKED)
    end)
    pcall(function()
        EVENT_MANAGER:UnregisterForEvent(CM.name, EVENT_SKILL_RANK_UPDATE)
    end)
    pcall(function()
        EVENT_MANAGER:UnregisterForEvent(CM.name, EVENT_SKILL_POINTS_CHANGED)
    end)
    pcall(function()
        EVENT_MANAGER:UnregisterForEvent(CM.name, EVENT_TITLE_UNLOCKED)
    end)
    pcall(function()
        EVENT_MANAGER:UnregisterForEvent(CM.name, EVENT_ANTIQUITY_UNLOCKED)
    end)
    pcall(function()
        EVENT_MANAGER:UnregisterForEvent(CM.name, EVENT_HOUSE_OWNERSHIP_CHANGED)
    end)
end

CM.events.OnAddOnLoaded = OnAddOnLoaded
CM.events.OnPlayerActivated = OnPlayerActivated
CM.events.RegisterEvents = RegisterEvents
CM.events.UnregisterEvents = UnregisterEvents

-- Export cache invalidation handlers for manual clearing if needed
CM.events.OnCollectibleUnlocked = OnCollectibleUnlocked
CM.events.OnSkillRankUpdate = OnSkillRankUpdate
CM.events.OnSkillPointsChanged = OnSkillPointsChanged
CM.events.OnTitleUnlocked = OnTitleUnlocked
CM.events.OnAntiquityUnlocked = OnAntiquityUnlocked
CM.events.OnHouseOwnershipChanged = OnHouseOwnershipChanged

-- Register event handlers
RegisterEvents()
