-- CharacterMarkdown v2.1.1 - Core Namespace
-- Author: solaegis

CharacterMarkdown = CharacterMarkdown or {}
local CM = CharacterMarkdown

-- Addon metadata
CM.name = "CharacterMarkdown"
CM.version = "2.1.6"
CM.author = "solaegis"
CM.apiVersion = 101047

-- Sub-namespaces
CM.utils = CM.utils or {}
CM.links = CM.links or {}
CM.collectors = CM.collectors or {}
CM.generators = CM.generators or {}
CM.commands = CM.commands or {}
CM.events = CM.events or {}
CM.Settings = CM.Settings or {}

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

-- Unified link creation
function CM.CreateLink(text, linkType, format)
    if not text or text == "" or text == "[Empty]" or text == "[Empty Slot]" or text == "Unknown" then
        return text or ""
    end
    
    local settings = CharacterMarkdownSettings or {}
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

-- Initialize SavedVariables
local function InitializeSavedVariables()
    if not CharacterMarkdownSettings then
        CharacterMarkdownSettings = _G.CharacterMarkdownSettings
    end
    if not CharacterMarkdownData then
        CharacterMarkdownData = _G.CharacterMarkdownData
    end
    
    if not CharacterMarkdownSettings then
        CharacterMarkdownSettings = {}
        CM.DebugPrint("SAVEDVARS", "Created temporary CharacterMarkdownSettings - may not persist")
    end
    if not CharacterMarkdownData then
        CharacterMarkdownData = {}
        CM.DebugPrint("SAVEDVARS", "Created temporary CharacterMarkdownData - may not persist")
    end
end

InitializeSavedVariables()

if logger then
    logger:Info("LibDebugLogger initialized for CharacterMarkdown")
    logger:SetEnabled(true)
end

CM.DebugPrint("INIT", "Core namespace initialized")
