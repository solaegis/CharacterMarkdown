-- CharacterMarkdown - Event System
-- Event registration and handlers

local CM = CharacterMarkdown

-- =====================================================
-- EVENT HANDLERS
-- =====================================================

local function OnAddOnLoaded(event, addonName)
    if addonName ~= CM.name then
        return
    end
    
    d("[CharacterMarkdown] v" .. CM.version .. " loaded")
    
    -- Initialize settings (data defaults and saved variables)
    if CM.Settings and CM.Settings.Initializer then
        CM.Settings.Initializer:Initialize()
    end
    
    -- Initialize settings UI panel (LibAddonMenu)
    if CM.Settings and CM.Settings.Panel then
        CM.Settings.Panel:Initialize()
    end
    
    -- Unregister this event
    EVENT_MANAGER:UnregisterForEvent(CM.name, EVENT_ADD_ON_LOADED)
end

CM.events.OnAddOnLoaded = OnAddOnLoaded

-- =====================================================
-- EVENT REGISTRATION
-- =====================================================

local function RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(CM.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
end

CM.events.RegisterEvents = RegisterEvents

-- Auto-register events
RegisterEvents()
