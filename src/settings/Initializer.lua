-- CharacterMarkdown v2.1.1 - Settings Initializer
-- Handles settings initialization with proper SavedVariables (ESO Guideline Compliant)
-- Author: solaegis
-- Enhanced with ZO_SavedVars, profiles, and import/export

CharacterMarkdown = CharacterMarkdown or {}
CharacterMarkdown.Settings = CharacterMarkdown.Settings or {}
CharacterMarkdown.Settings.Initializer = {}

local CM = CharacterMarkdown

-- =====================================================
-- MODULE STATE
-- =====================================================

-- Track if ZO_SavedVars initialization was successful
local zo_savedvars_available = false

-- =====================================================
-- INITIALIZATION
-- =====================================================

function CM.Settings.Initializer:Initialize()
    CM.DebugPrint("SETTINGS", "Initializing settings system...")
    
    -- Try ZO_SavedVars first (preferred method)
    local success = self:TryZOSavedVars()
    
    if not success then
        -- Fallback to direct assignment
        CM.Warn("ZO_SavedVars initialization failed - using fallback method")
        self:InitializeFallback()
    end
    
    -- Initialize per-character data
    self:InitializeCharacterData()
    
    -- Initialize profile system
    self:InitializeProfiles()
    
    -- Sync format to core
    if CM.currentFormat and CharacterMarkdownSettings then
        CM.currentFormat = CharacterMarkdownSettings.currentFormat or "github"
    end
    
    CM.DebugPrint("SETTINGS", "Settings initialization complete")
    return true
end

-- =====================================================
-- ZO_SAVEDVARS INITIALIZATION (PREFERRED)
-- =====================================================

function CM.Settings.Initializer:TryZOSavedVars()
    -- Check if ZO_SavedVars is available
    if not ZO_SavedVars or type(ZO_SavedVars.NewAccountWide) ~= "function" then
        CM.Warn("ZO_SavedVars not available - addon loaded too early?")
        return false
    end
    
    -- Get defaults
    local defaults = CM.Settings.Defaults:GetAll()
    
    -- Initialize account-wide settings
    local success, result = pcall(function()
        CM.settings = ZO_SavedVars:NewAccountWide(
            "CharacterMarkdownSettings",  -- SavedVariables name
            1,  -- Version (increment when changing structure)
            nil,  -- Namespace (nil = root)
            defaults  -- Default values
        )
    end)
    
    if not success then
        CM.Error("Failed to initialize ZO_SavedVars: " .. tostring(result))
        return false
    end
    
    -- Verify initialization
    if not CM.settings or type(CM.settings) ~= "table" then
        CM.Error("ZO_SavedVars returned invalid settings table")
        return false
    end
    
    -- Also create global reference for backwards compatibility
    if not CharacterMarkdownSettings then
        CharacterMarkdownSettings = CM.settings
    end
    
    zo_savedvars_available = true
    CM.DebugPrint("SETTINGS", "✓ ZO_SavedVars initialized successfully")
    return true
end

-- =====================================================
-- FALLBACK INITIALIZATION (DIRECT ASSIGNMENT)
-- =====================================================

function CM.Settings.Initializer:InitializeFallback()
    CM.DebugPrint("SETTINGS", "Using fallback initialization method")
    
    -- Access the global SavedVariables (created by ESO)
    if not CharacterMarkdownSettings then
        CM.Error("CRITICAL: CharacterMarkdownSettings not created by ESO!")
        CharacterMarkdownSettings = {}
    end
    
    -- Set reference
    CM.settings = CharacterMarkdownSettings
    
    -- Initialize settings with defaults
    local defaults = CM.Settings.Defaults:GetAll()
    
    -- Version tracking
    if CM.settings.settingsVersion == nil then
        CM.settings.settingsVersion = 1
        CM.settings._initialized = true
        CM.settings._lastModified = GetTimeStamp()
    end
    
    -- Apply defaults for any missing settings
    for key, defaultValue in pairs(defaults) do
        if CM.settings[key] == nil then
            CM.settings[key] = defaultValue
        end
    end
    
    CM.DebugPrint("SETTINGS", "✓ Fallback initialization complete")
    
    -- Initialize filter manager
    if not CM.Settings.FilterManager then
        local FilterManager = require("src/settings/FilterManager")
        CM.Settings.FilterManager = FilterManager
        CM.Settings.FilterManager:Initialize()
    end
end

-- =====================================================
-- PER-CHARACTER DATA
-- =====================================================

function CM.Settings.Initializer:InitializeCharacterData()
    -- Access the global per-character SavedVariables
    if not CharacterMarkdownData then
        CM.Error("CRITICAL: CharacterMarkdownData not created by ESO!")
        CharacterMarkdownData = {}
    end
    
    CM.charData = CharacterMarkdownData
    
    -- Initialize custom notes
    if CM.charData.customNotes == nil then
        CM.charData.customNotes = ""
    end
    
    -- Force character data save on first run
    if not CM.charData._initialized then
        CM.charData._initialized = true
        CM.charData._lastModified = GetTimeStamp()
    end
    
    CM.DebugPrint("SETTINGS", "✓ Character data initialized (notes: " .. string.len(CM.charData.customNotes) .. " bytes)")
end

-- =====================================================
-- CUSTOM NOTES HELPERS
-- =====================================================

function CM.Settings.Initializer:SaveCustomNotes(notes)
    if not CM.charData then
        CM.Error("Character data not initialized")
        return false
    end
    
    -- Validate input
    if type(notes) ~= "string" then
        CM.Error("Custom notes must be a string")
        return false
    end
    
    -- Save notes
    CM.charData.customNotes = notes
    CM.charData._lastModified = GetTimeStamp()
    
    CM.DebugPrint("SETTINGS", "Custom notes saved (" .. string.len(notes) .. " bytes)")
    return true
end

function CM.Settings.Initializer:GetCustomNotes()
    if not CM.charData then
        CM.Error("Character data not initialized")
        return ""
    end
    
    return CM.charData.customNotes or ""
end

-- =====================================================
-- PROFILE SYSTEM INITIALIZATION
-- =====================================================

function CM.Settings.Initializer:InitializeProfiles()
    -- Initialize profiles storage
    if not CM.settings.profiles then
        CM.settings.profiles = {}
    end
    
    -- Track active profile
    if not CM.settings.activeProfile then
        CM.settings.activeProfile = "Custom"  -- Default to custom (user's current settings)
    end
    
    CM.DebugPrint("SETTINGS", "✓ Profile system initialized")
end

-- =====================================================
-- SETTINGS VALIDATION
-- =====================================================

function CM.Settings.Initializer:ValidateSettings()
    local defaults = CM.Settings.Defaults:GetAll()
    local fixed = 0
    
    -- Ensure all required settings exist
    for key, defaultValue in pairs(defaults) do
        if CM.settings[key] == nil then
            CM.settings[key] = defaultValue
            CM.DebugPrint("SETTINGS", "Restored missing setting: " .. key)
            fixed = fixed + 1
        end
    end
    
    -- Validate format choice
    if not CM.Settings.Defaults:IsValidFormat(CM.settings.currentFormat) then
        CM.Warn("Invalid format '" .. tostring(CM.settings.currentFormat) .. "', resetting to github")
        CM.settings.currentFormat = "github"
        fixed = fixed + 1
    end
    
    -- Validate numeric ranges
    if CM.settings.minSkillRank < 0 or CM.settings.minSkillRank > 50 then
        CM.settings.minSkillRank = 1
        fixed = fixed + 1
    end
    
    if not CM.Settings.Defaults:IsValidQuality(CM.settings.minEquipQuality) then
        CM.settings.minEquipQuality = 0
        fixed = fixed + 1
    end
    
    if fixed > 0 then
        CM.DebugPrint("SETTINGS", "Validated and fixed " .. fixed .. " settings")
    end
    
    return fixed == 0
end

-- =====================================================
-- PROFILE MANAGEMENT
-- =====================================================

function CM.Settings.Initializer:SaveProfile(profileName, includeNotes)
    if not profileName or profileName == "" then
        CM.Error("Profile name cannot be empty")
        return false
    end
    
    -- Create profile snapshot
    local profile = {
        name = profileName,
        created = GetTimeStamp(),
        version = CM.version,
    }
    
    -- Copy all settings (except meta fields)
    local excludeKeys = {
        profiles = true,
        activeProfile = true,
        settingsVersion = true,
        _initialized = true,
        _lastModified = true,
        _panelOpened = true,
        _firstRun = true,
    }
    
    for key, value in pairs(CM.settings) do
        if not excludeKeys[key] then
            profile[key] = value
        end
    end
    
    -- Optionally include character notes
    if includeNotes and CM.charData.customNotes then
        profile.customNotes = CM.charData.customNotes
    end
    
    -- Save profile
    CM.settings.profiles[profileName] = profile
    CM.settings._lastModified = GetTimeStamp()
    
    CM.Info("Profile '" .. profileName .. "' saved")
    CM.DebugPrint("SETTINGS", "Profile saved with " .. self:CountProfileSettings(profile) .. " settings")
    
    return true
end

function CM.Settings.Initializer:LoadProfile(profileName)
    local profile = CM.settings.profiles[profileName]
    
    if not profile then
        -- Check if it's a preset profile
        profile = CM.Settings.Defaults:GetProfile(profileName)
        if not profile then
            CM.Error("Profile '" .. profileName .. "' not found")
            return false
        end
    end
    
    CM.DebugPrint("SETTINGS", "Loading profile: " .. profileName)
    
    -- Apply profile settings
    local applied = 0
    for key, value in pairs(profile) do
        if key ~= "name" and key ~= "created" and key ~= "version" and key ~= "description" and key ~= "customNotes" then
            CM.settings[key] = value
            applied = applied + 1
        end
    end
    
    -- Apply notes if present
    if profile.customNotes and CM.charData then
        CM.charData.customNotes = profile.customNotes
    end
    
    -- Update active profile
    CM.settings.activeProfile = profileName
    CM.settings._lastModified = GetTimeStamp()
    
    -- Sync format to core
    CM.currentFormat = CM.settings.currentFormat
    
    CM.Info("Profile '" .. profileName .. "' loaded (" .. applied .. " settings applied)")
    CM.DebugPrint("SETTINGS", "Profile loaded successfully")
    
    return true
end

function CM.Settings.Initializer:DeleteProfile(profileName)
    if not CM.settings.profiles[profileName] then
        CM.Error("Profile '" .. profileName .. "' not found")
        return false
    end
    
    CM.settings.profiles[profileName] = nil
    CM.settings._lastModified = GetTimeStamp()
    
    -- If this was the active profile, switch to Custom
    if CM.settings.activeProfile == profileName then
        CM.settings.activeProfile = "Custom"
    end
    
    CM.Info("Profile '" .. profileName .. "' deleted")
    return true
end

function CM.Settings.Initializer:GetProfileList()
    local profiles = {}
    
    -- Add user profiles
    for name, profile in pairs(CM.settings.profiles) do
        table.insert(profiles, {
            name = name,
            created = profile.created,
            version = profile.version,
            isPreset = false,
        })
    end
    
    -- Add preset profiles
    for name, profile in pairs(CM.Settings.Defaults.PROFILES) do
        table.insert(profiles, {
            name = name,
            description = profile.description,
            isPreset = true,
        })
    end
    
    return profiles
end

function CM.Settings.Initializer:CountProfileSettings(profile)
    local count = 0
    for _, _ in pairs(profile) do
        count = count + 1
    end
    return count
end

-- =====================================================
-- IMPORT/EXPORT
-- =====================================================

function CM.Settings.Initializer:ExportSettings()
    local export = {
        version = CM.version,
        timestamp = GetTimeStamp(),
        settings = {},
    }
    
    -- Copy all settings except meta fields
    local excludeKeys = {
        profiles = true,  -- Don't export profiles
        settingsVersion = true,
        _initialized = true,
        _lastModified = true,
        _panelOpened = true,
        _firstRun = true,
    }
    
    for key, value in pairs(CM.settings) do
        if not excludeKeys[key] then
            export.settings[key] = value
        end
    end
    
    -- Include character notes if present
    if CM.charData.customNotes and CM.charData.customNotes ~= "" then
        export.customNotes = CM.charData.customNotes
    end
    
    -- Serialize to string
    local serialized = self:SerializeTable(export)
    
    CM.Info("Settings exported to clipboard format")
    CM.DebugPrint("SETTINGS", "Export size: " .. string.len(serialized) .. " bytes")
    
    return serialized
end

function CM.Settings.Initializer:ImportSettings(importString)
    if not importString or importString == "" then
        CM.Error("Import string is empty")
        return false
    end
    
    -- Deserialize
    local success, import = pcall(function()
        return self:DeserializeTable(importString)
    end)
    
    if not success then
        CM.Error("Failed to parse import string: " .. tostring(import))
        return false
    end
    
    if not import or not import.settings then
        CM.Error("Invalid import format")
        return false
    end
    
    CM.DebugPrint("SETTINGS", "Importing settings from version: " .. tostring(import.version))
    
    -- Apply imported settings
    local applied = 0
    for key, value in pairs(import.settings) do
        CM.settings[key] = value
        applied = applied + 1
    end
    
    -- Apply notes if present
    if import.customNotes and CM.charData then
        CM.charData.customNotes = import.customNotes
    end
    
    -- Validate settings
    self:ValidateSettings()
    
    -- Mark as modified
    CM.settings._lastModified = GetTimeStamp()
    
    -- Sync format to core
    CM.currentFormat = CM.settings.currentFormat
    
    CM.Info("Settings imported successfully (" .. applied .. " settings)")
    return true
end

-- =====================================================
-- SERIALIZATION HELPERS
-- =====================================================

function CM.Settings.Initializer:SerializeTable(tbl, indent)
    indent = indent or 0
    local output = {}
    local prefix = string.rep("  ", indent)
    
    table.insert(output, "{\n")
    
    for k, v in pairs(tbl) do
        local key = type(k) == "string" and ("[\"%s\"]"):format(k) or ("[%d]"):format(k)
        local value
        
        if type(v) == "table" then
            value = self:SerializeTable(v, indent + 1)
        elseif type(v) == "string" then
            value = ("%q"):format(v)
        elseif type(v) == "number" or type(v) == "boolean" then
            value = tostring(v)
        else
            value = "nil"
        end
        
        table.insert(output, prefix .. "  " .. key .. " = " .. value .. ",\n")
    end
    
    table.insert(output, prefix .. "}")
    
    return table.concat(output)
end

function CM.Settings.Initializer:DeserializeTable(str)
    -- Wrap in return statement for loadstring
    local funcStr = "return " .. str
    
    -- Load as function
    local func, err = loadstring(funcStr)
    if not func then
        error("Parse error: " .. tostring(err))
    end
    
    -- Execute and return table
    return func()
end

-- =====================================================
-- RESET TO DEFAULTS
-- =====================================================

function CM.Settings.Initializer:ResetToDefaults()
    CM.Info("Resetting all settings to defaults...")
    
    local defaults = CM.Settings.Defaults:GetAll()
    
    -- Apply defaults
    for key, value in pairs(defaults) do
        CM.settings[key] = value
    end
    
    -- Reset version
    CM.settings.settingsVersion = 1
    CM.settings.activeProfile = "Custom"
    
    -- Reset character notes
    if CM.charData then
        CM.charData.customNotes = ""
    end
    
    -- Sync format to core
    CM.currentFormat = CM.settings.currentFormat
    
    CM.settings._lastModified = GetTimeStamp()
    
    CM.Success("All settings reset to defaults")
end

