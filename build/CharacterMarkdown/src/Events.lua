-- CharacterMarkdown - Event System
-- Event registration and handlers (ESO Guideline Compliant)

local CM = CharacterMarkdown

-- =====================================================
-- EVENT HANDLERS
-- =====================================================

local function OnAddOnLoaded(event, addonName)
    -- Only process our addon
    if addonName ~= CM.name then return end
    
    CM.Info("v" .. CM.version .. " Loading...")
    
    -- Unregister this event immediately (guideline: cleanup after use)
    EVENT_MANAGER:UnregisterForEvent(CM.name, EVENT_ADD_ON_LOADED)
    
    -- Validate all modules loaded
    if not CM.ValidateModules() then
        CM.Error("Module validation failed! Addon may not work correctly.")
        return
    end
    
    -- Initialize settings (deferred to allow SavedVariables to fully load)
    -- ESO creates SavedVariables during EVENT_ADD_ON_LOADED but may not
    -- populate them until after the event completes
    zo_callLater(function()
        -- Initialize settings system
        
        -- Try to access via _G if direct access fails
        if not CharacterMarkdownSettings and _G.CharacterMarkdownSettings then
            CharacterMarkdownSettings = _G.CharacterMarkdownSettings
        end
        if not CharacterMarkdownData and _G.CharacterMarkdownData then
            CharacterMarkdownData = _G.CharacterMarkdownData
        end
        
        -- Additional check - try to access via different methods
        if not CharacterMarkdownSettings then
            -- Try to access via getfenv
            local env = getfenv(2)
            if env.CharacterMarkdownSettings then
                CharacterMarkdownSettings = env.CharacterMarkdownSettings
            end
            if env.CharacterMarkdownData then
                CharacterMarkdownData = env.CharacterMarkdownData
            end
        end
        
        -- Final check - if still no SavedVariables, wait a bit more
        if not CharacterMarkdownSettings then
            CM.DebugPrint("EVENTS", "SavedVariables not ready yet, waiting longer...")
            zo_callLater(function()
                if CM.Settings and CM.Settings.Initializer then
                    CM.Settings.Initializer:Initialize()
                end
                
                if CM.Settings and CM.Settings.Panel then
                    CM.Settings.Panel:Initialize()
                end
                
                -- Mark as initialized
                CM.isInitialized = true
                
                CM.Success("Ready! Use /markdown to generate character profile")
            end, 2000)
            return
        end
        
        if CM.Settings and CM.Settings.Initializer then
            CM.Settings.Initializer:Initialize()
        end
        
        if CM.Settings and CM.Settings.Panel then
            CM.Settings.Panel:Initialize()
        end
        
        -- Mark as initialized
        CM.isInitialized = true
        
        CM.Success("Ready! Use /markdown to generate character profile")
        
    end, 1000)  -- Reduced delay, but with fallback
end

-- =====================================================
-- PLAYER ACTIVATED (Optional - for future features)
-- =====================================================

local function OnPlayerActivated(event)
    
    -- Check if SavedVariables are now available
    if not CharacterMarkdownSettings and _G.CharacterMarkdownSettings then
        CharacterMarkdownSettings = _G.CharacterMarkdownSettings
        CharacterMarkdownData = _G.CharacterMarkdownData
        CM.DebugPrint("EVENTS", "SavedVariables found on player activation - reinitializing settings")
        
        if CM.Settings and CM.Settings.Initializer then
            CM.Settings.Initializer:Initialize()
        end
    end
    
    -- Future: Could refresh data when player changes zones
    -- For now, data collection is on-demand only
    
    -- Unregister if we only need this once
    EVENT_MANAGER:UnregisterForEvent(CM.name, EVENT_PLAYER_ACTIVATED)
end

-- =====================================================
-- EVENT REGISTRATION
-- =====================================================

local function RegisterEvents()
    
    -- Register for addon loaded event
    EVENT_MANAGER:RegisterForEvent(CM.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
    
    -- Register for player activated to catch SavedVariables if they're created later
    EVENT_MANAGER:RegisterForEvent(CM.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    
end

-- =====================================================
-- EVENT CLEANUP (for /reloadui or addon disable)
-- =====================================================

local function UnregisterEvents()
    
    EVENT_MANAGER:UnregisterForEvent(CM.name, EVENT_ADD_ON_LOADED)
    -- EVENT_MANAGER:UnregisterForEvent(CM.name, EVENT_PLAYER_ACTIVATED)
    
end

-- =====================================================
-- MODULE EXPORTS
-- =====================================================

CM.events.OnAddOnLoaded = OnAddOnLoaded
CM.events.OnPlayerActivated = OnPlayerActivated
CM.events.RegisterEvents = RegisterEvents
CM.events.UnregisterEvents = UnregisterEvents

-- Auto-register events on module load
RegisterEvents()

