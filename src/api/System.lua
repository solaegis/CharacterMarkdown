-- CharacterMarkdown - API Layer - System
-- Abstraction for System, Events, and metadata

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.system = {}

local api = CM.api.system

-- =====================================================
-- SYSTEM / EVENTS
-- =====================================================

function api.RegisterEvent(addonName, eventType, callback)
    if EVENT_MANAGER then
        EVENT_MANAGER:RegisterForEvent(addonName, eventType, callback, false)
    end
end

function api.UnregisterEvent(addonName, eventType)
    if EVENT_MANAGER then
        EVENT_MANAGER:UnregisterForEvent(addonName, eventType)
    end
end

function api.GetAPIVersion()
    return CM.SafeCall(GetAPIVersion) or 0
end

function api.GetAddOnMetadata(name, field)
    if GetAddOnMetadata then
        return GetAddOnMetadata(name, field)
    end
    return nil
end

function api.Print(msg)
    if d then
        d(msg)
    end
end

-- Composition functions moved to collector level

CM.DebugPrint("API", "System API module loaded")
