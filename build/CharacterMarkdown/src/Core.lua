-- CharacterMarkdown v2.1.0 - Core Namespace
-- Author: solaegis
-- Compliant with ESO Addon Development Guidelines

-- =====================================================
-- NAMESPACE INITIALIZATION
-- =====================================================

-- Create the main addon namespace (safe initialization)
CharacterMarkdown = CharacterMarkdown or {}
local CM = CharacterMarkdown

-- =====================================================
-- ADDON METADATA
-- =====================================================

CM.name = "CharacterMarkdown"
CM.version = "2.1.1"
CM.author = "solaegis"
CM.apiVersion = 101047

-- =====================================================
-- SUB-NAMESPACES
-- =====================================================

CM.utils = CM.utils or {}
CM.links = CM.links or {}
CM.collectors = CM.collectors or {}
CM.generators = CM.generators or {}
CM.commands = CM.commands or {}
CM.events = CM.events or {}
CM.Settings = CM.Settings or {}

-- =====================================================
-- STATE MANAGEMENT
-- =====================================================

CM.currentFormat = "github"  -- Default export format
CM.isInitialized = false     -- Initialization flag

-- =====================================================
-- DEBUG SYSTEM (GUIDELINE COMPLIANT)
-- =====================================================

-- Debug mode (DISABLED in production, enable via settings)
CM.debug = false

-- Debug print helper (only outputs when debug mode enabled)
function CM.DebugPrint(category, ...)
    if not CM.debug then return end
    
    local prefix = string.format("[CharacterMarkdown:%s]", category or "CORE")
    d(prefix, ...)
end

-- Safe debug wrapper (catches errors in debug output)
function CM.SafeDebug(category, message, data)
    if not CM.debug then return end
    
    local success, err = pcall(function()
        local output = string.format("[CharacterMarkdown:%s] %s", category, message)
        if data ~= nil then
            output = output .. ": " .. tostring(data)
        end
        d(output)
    end)
    
    if not success then
        d("[CharacterMarkdown:DEBUG] Error in debug output:", err)
    end
end

-- Info-level messages (always shown, regardless of debug mode)
function CM.Info(message)
    d("[CharacterMarkdown]", message)
end

-- Warning messages (always shown)
function CM.Warn(message)
    d("|cFFFF00[CharacterMarkdown] WARNING:|r", message)
end

-- Error messages (always shown)
function CM.Error(message)
    d("|cFF0000[CharacterMarkdown] ERROR:|r", message)
end

-- Success messages (always shown)
function CM.Success(message)
    d("|c00FF00[CharacterMarkdown]|r", message)
end

-- =====================================================
-- GLOBAL API CACHING (PERFORMANCE OPTIMIZATION)
-- =====================================================

-- Cache frequently used global functions (guideline: avoid repeated global lookups)
CM.cached = {
    -- Event Manager
    EVENT_MANAGER = EVENT_MANAGER,
    
    -- String functions
    string_format = string.format,
    string_gsub = string.gsub,
    string_sub = string.sub,
    string_len = string.len,
    string_lower = string.lower,
    string_upper = string.upper,
    
    -- Table functions
    table_insert = table.insert,
    table_concat = table.concat,
    
    -- Math functions
    math_floor = math.floor,
    math_ceil = math.ceil,
    math_min = math.min,
    math_max = math.max,
    
    -- ZO functions
    zo_callLater = zo_callLater,
    zo_strformat = zo_strformat,
}

-- =====================================================
-- UTILITY FUNCTIONS
-- =====================================================

-- Safe call wrapper (guideline: always use pcall for API calls)
function CM.SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        CM.DebugPrint("SAFECALL", "Error:", result)
        return nil
    end
    return result
end

-- Validate required modules loaded
function CM.ValidateModules()
    local required = {
        "utils",
        "links",
        "collectors",
        "generators",
        "commands",
        "events",
    }
    
    local allLoaded = true
    for _, module in ipairs(required) do
        if not CM[module] then
            CM.Error(string.format("Required module '%s' not loaded!", module))
            allLoaded = false
        end
    end
    
    return allLoaded
end

-- =====================================================
-- SAVEDVARIABLES INITIALIZATION
-- =====================================================

-- Ensure SavedVariables are properly declared and accessible
-- This is called during addon load to ensure ESO creates the SavedVariables
local function InitializeSavedVariables()
    -- Access the SavedVariables to ensure they're created by ESO
    if not CharacterMarkdownSettings then
        -- Try to access via global scope
        CharacterMarkdownSettings = _G.CharacterMarkdownSettings
    end
    if not CharacterMarkdownData then
        CharacterMarkdownData = _G.CharacterMarkdownData
    end
    
    -- If still not available, create temporary tables
    if not CharacterMarkdownSettings then
        CharacterMarkdownSettings = {}
        CM.DebugPrint("SAVEDVARS", "Created temporary CharacterMarkdownSettings - may not persist")
    end
    if not CharacterMarkdownData then
        CharacterMarkdownData = {}
        CM.DebugPrint("SAVEDVARS", "Created temporary CharacterMarkdownData - may not persist")
    end
end

-- Initialize SavedVariables immediately when Core loads
InitializeSavedVariables()

-- =====================================================
-- INITIALIZATION CHECK
-- =====================================================

CM.DebugPrint("INIT", "Core namespace initialized")
