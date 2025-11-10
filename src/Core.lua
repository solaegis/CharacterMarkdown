-- CharacterMarkdown v2.1.7 - Core Namespace
-- Author: solaegis

CharacterMarkdown = CharacterMarkdown or {}
local CM = CharacterMarkdown

-- Addon metadata
CM.name = "CharacterMarkdown"
-- Initialize version - will be updated after addon loads when GetAddOnMetadata is available
CM.version = "2.1.7"  -- Fallback version
CM.author = "solaegis"
CM.apiVersion = 101047

-- Update version and metadata from manifest after addon loads
-- This function will be called from Events.lua after EVENT_ADD_ON_LOADED
function CM.UpdateVersion()
    if not GetAddOnMetadata then
        CM.DebugPrint("CORE", "GetAddOnMetadata not available yet")
        return false
    end
    
    -- Get version from manifest
    local version = GetAddOnMetadata(CM.name, "Version")
    if version and version ~= "" then
        if version == "@project-version@" then
            -- Placeholder detected - try to get version from Git or use fallback
            -- In development, this means the manifest hasn't been processed
            -- We'll keep the fallback version but log a warning
            CM.DebugPrint("CORE", "Version placeholder @project-version@ detected - using fallback version")
            CM.DebugPrint("CORE", string.format("Using fallback version: %s (run 'task build' to replace placeholder)", CM.version))
        else
            -- Valid version found - update it
            CM.version = version
            CM.DebugPrint("CORE", string.format("Version updated from manifest: %s", version))
        end
    else
        CM.DebugPrint("CORE", string.format("Version from manifest invalid or empty: %s", tostring(version)))
    end
    
    -- Also update author from manifest if available
    local author = GetAddOnMetadata(CM.name, "Author")
    if author and author ~= "" then
        CM.author = author
    end
    
    -- Also update API version from manifest if available
    local apiVersion = GetAddOnMetadata(CM.name, "APIVersion")
    if apiVersion and apiVersion ~= "" then
        local apiVersionNum = tonumber(apiVersion)
        if apiVersionNum then
            CM.apiVersion = apiVersionNum
            CM.DebugPrint("CORE", string.format("API version updated from manifest: %d", apiVersionNum))
        end
    end
    
    -- Also try to get API version from game API as verification/fallback
    if GetAPIVersion then
        local gameApiVersion = CM.SafeCall(GetAPIVersion)
        if gameApiVersion and gameApiVersion > 0 then
            if gameApiVersion ~= CM.apiVersion then
                CM.DebugPrint("CORE", string.format("API version mismatch: manifest=%d, game=%d", CM.apiVersion, gameApiVersion))
                -- Optionally update to match game API (uncomment if desired)
                -- CM.apiVersion = gameApiVersion
            else
                CM.DebugPrint("CORE", string.format("API version verified: %d", gameApiVersion))
            end
        end
    end
    
    return true
end

-- Sub-namespaces
CM.utils = CM.utils or {}
CM.links = CM.links or {}
CM.collectors = CM.collectors or {}
CM.generators = CM.generators or {}
CM.commands = CM.commands or {}
CM.events = CM.events or {}
CM.Settings = CM.Settings or {}
CM.constants = CM.constants or {}

-- Constants
-- Champion Points Discipline Types
CM.constants.DisciplineType = {
    WARFARE = "Warfare",
    FITNESS = "Fitness",
    CRAFT = "Craft"
}

-- State management
CM.currentFormat = "github"
CM.isInitialized = false

-- Debug system with LibDebugLogger integration
local logger = LibDebugLogger and LibDebugLogger.Create(CM.name) or nil
CM.debug = false

function CM.DebugPrint(category, ...)
    if logger then
        local args = {...}
        local parts = {}
        for i, v in ipairs(args) do
            parts[i] = tostring(v)
        end
        local message = table.concat(parts, " ")
        logger:Debug(string.format("[%s] %s", category or "CORE", message))
    elseif CM.debug then
        d(string.format("[CharacterMarkdown:%s]", category or "CORE"), ...)
    end
end

function CM.Verbose(category, ...)
    if logger then
        local args = {...}
        local parts = {}
        for i, v in ipairs(args) do
            parts[i] = tostring(v)
        end
        local message = table.concat(parts, " ")
        logger:Verbose(string.format("[%s] %s", category or "CORE", message))
    elseif CM.debug then
        CM.DebugPrint(category, ...)
    end
end

function CM.Info(message)
    if logger then logger:Info(message) end
end

function CM.Warn(message)
    if logger then logger:Warn(message) end
end

function CM.Error(message)
    if logger then logger:Error(message) end
    d("|cFF0000[CharacterMarkdown] ERROR:|r", message)
end

function CM.Success(message)
    if logger then logger:Info(message) end
end

-- Cache frequently used globals for performance
CM.cached = {
    EVENT_MANAGER = EVENT_MANAGER,
    string_format = string.format,
    string_gsub = string.gsub,
    string_sub = string.sub,
    string_len = string.len,
    string_lower = string.lower,
    string_upper = string.upper,
    table_insert = table.insert,
    table_concat = table.concat,
    math_floor = math.floor,
    math_ceil = math.ceil,
    math_min = math.min,
    math_max = math.max,
    zo_callLater = zo_callLater,
    zo_strformat = zo_strformat,
}

-- Safe call wrapper
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
    local required = {"utils", "links", "collectors", "generators", "commands", "events"}
    local allLoaded = true
    
    for _, module in ipairs(required) do
        if not CM[module] then
            CM.Error(string.format("Required module '%s' not loaded!", module))
            allLoaded = false
        end
    end
    
    return allLoaded
end

-- Unified settings access helper
-- Always returns a valid settings table, merging SavedVariables with defaults
-- This ensures settings are NEVER nil - they're always true or false
function CM.GetSettings()
    local settings = CharacterMarkdownSettings
    if not settings then
        -- Return defaults if settings not available
        if CM.Settings and CM.Settings.Defaults then
            return CM.Settings.Defaults:GetAll()
        else
            -- Last resort: return empty table
            return {}
        end
    end
    
    -- CRITICAL: Merge with defaults to ensure no nil values
    -- This guarantees that every setting is either true or false, never nil
    if CM.Settings and CM.Settings.Defaults then
        local defaults = CM.Settings.Defaults:GetAll()
        local merged = {}
        
        -- First, copy all defaults
        for key, defaultValue in pairs(defaults) do
            merged[key] = defaultValue
        end
        
        -- Then, overlay saved values (which may be true, false, or other types)
        -- IMPORTANT: We must overlay ALL saved values, including false, to respect user settings
        local overlayCount = 0
        for key, savedValue in pairs(settings) do
            -- Only merge keys that exist in defaults (ignore internal keys like _metadata, filters, etc.)
            if defaults[key] ~= nil then
                -- Overlay saved value (even if it's false - this respects user's disabled settings)
                local oldValue = merged[key]
                merged[key] = savedValue
                overlayCount = overlayCount + 1
                -- Debug: Log important setting overrides
                if key == "includeSkillBars" or key == "includeSkills" or key == "includeEquipment" or 
                   key == "includeQuickStats" or key == "includeTableOfContents" or 
                   key == "includeChampionPoints" or key == "includeChampionDiagram" then
                    CM.DebugPrint("SETTINGS_MERGE", string.format("Overlayed '%s': default=%s -> saved=%s -> final=%s", 
                        key, tostring(oldValue), tostring(savedValue), tostring(merged[key])))
                end
            end
        end
        CM.DebugPrint("SETTINGS_MERGE", string.format("Merged settings: %d keys overlaid from SavedVariables", overlayCount))
        
        return merged
    end
    
    return settings
end

-- Unified link creation
function CM.CreateLink(text, linkType, format)
    if not text or text == "" or text == "[Empty]" or text == "[Empty Slot]" or text == "Unknown" then
        return text or ""
    end
    
    local settings = CM.GetSettings()
    local linksEnabled = true
    
    if linkType == "ability" and settings.enableAbilityLinks == false then
        linksEnabled = false
    elseif linkType == "set" and settings.enableSetLinks == false then
        linksEnabled = false
    end
    
    if not linksEnabled or (format ~= "github" and format ~= "discord") then
        return text
    end
    
    local urlText = text
    
    -- Clean ability names (remove rank suffixes)
    if linkType == "ability" then
        urlText = urlText:gsub("%s+IV$", ""):gsub("%s+III$", ""):gsub("%s+II$", ""):gsub("%s+I$", "")
    end
    
    -- Clean mundus stone names
    if linkType == "mundus" then
        urlText = urlText:gsub("^The ", ""):gsub("^Boon: The ", ""):gsub("^Boon: ", "")
    end
    
    urlText = urlText:gsub(" ", "_"):gsub("[%(%)%[%]%{%}]", "")
    
    local url = "https://en.uesp.net/wiki/Online:" .. urlText
    return "[" .. text .. "](" .. url .. ")"
end

-- Initialize SavedVariables (deferred - will be properly initialized in Events.lua)
-- Don't create temporary tables here as they might interfere with real SavedVariables
local function InitializeSavedVariables()
    -- Only try to access if they already exist - don't create temporary ones
    if not CharacterMarkdownSettings and _G.CharacterMarkdownSettings then
        CharacterMarkdownSettings = _G.CharacterMarkdownSettings
        CM.DebugPrint("SAVEDVARS", "CharacterMarkdownSettings found in _G")
    end
    if not CharacterMarkdownData and _G.CharacterMarkdownData then
        CharacterMarkdownData = _G.CharacterMarkdownData
        CM.DebugPrint("SAVEDVARS", "CharacterMarkdownData found in _G")
    end
    
    -- Don't create temporary tables - wait for proper initialization in Events.lua
    -- This prevents race conditions where temporary tables might interfere with real SavedVariables
    if not CharacterMarkdownSettings then
        CM.DebugPrint("SAVEDVARS", "CharacterMarkdownSettings not yet available - will initialize in Events.lua")
    end
    if not CharacterMarkdownData then
        CM.DebugPrint("SAVEDVARS", "CharacterMarkdownData not yet available - will initialize in Events.lua")
    end
end

InitializeSavedVariables()

if logger then
    logger:Info("LibDebugLogger initialized for CharacterMarkdown")
    logger:SetEnabled(true)
end

CM.DebugPrint("INIT", "Core namespace initialized")
