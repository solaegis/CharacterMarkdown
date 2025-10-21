-- CharacterMarkdown v2.1.1 - Settings Initializer
-- Handles settings initialization with proper SavedVariables (ESO Guideline Compliant)
-- Author: solaegis
-- FIX: Direct assignment to avoid pairs() on userdata

CharacterMarkdown = CharacterMarkdown or {}
CharacterMarkdown.Settings = CharacterMarkdown.Settings or {}
CharacterMarkdown.Settings.Initializer = {}

local CM = CharacterMarkdown

-- =====================================================
-- INITIALIZATION
-- =====================================================

function CharacterMarkdown.Settings.Initializer:Initialize()
    -- Initialize account-wide settings
    self:InitializeAccountSettings()
    
    -- Initialize per-character data
    self:InitializeCharacterData()
    
    -- Sync format to core
    if CharacterMarkdown.currentFormat and CharacterMarkdownSettings then
        CharacterMarkdown.currentFormat = CharacterMarkdownSettings.currentFormat
    end
    
    return true
end

-- =====================================================
-- ACCOUNT-WIDE SETTINGS (DIRECT ASSIGNMENT)
-- =====================================================

function CharacterMarkdown.Settings.Initializer:InitializeAccountSettings()
    -- ESO automatically creates CharacterMarkdownSettings as userdata
    -- DO NOT initialize it ourselves: CharacterMarkdownSettings = CharacterMarkdownSettings or {}
    -- That would create a local table and prevent ESO from saving it!
    
    -- Check if ESO created the SavedVariables (should always exist after EVENT_ADD_ON_LOADED)
    if not CharacterMarkdownSettings then
        CM.Error("CRITICAL: CharacterMarkdownSettings not created by ESO!")
        CM.Error("SavedVariables file will not be created until settings are changed.")
        
        -- Create a temporary table for this session only
        -- This allows the addon to function but settings won't persist
        CharacterMarkdownSettings = {}
        CharacterMarkdownData = {}
        
        CM.DebugPrint("SETTINGS", "Using temporary settings - changes will not persist until SavedVariables are created")
        return
    end
    
    -- Access the settings directly
    local settings = CharacterMarkdownSettings
    
    -- Check version for migrations
    local savedVersion = settings.settingsVersion
    local isFirstRun = (savedVersion == nil)
    
    -- Set version and force save on first run
    if settings.settingsVersion == nil then
        settings.settingsVersion = 1
        -- Force ESO to recognize this as a change that needs saving
        settings._initialized = true
    end
    
    -- Format
    if settings.currentFormat == nil then
        settings.currentFormat = "github"
    end
    
    -- Core sections (DEFAULT: ENABLED)
    if settings.includeChampionPoints == nil then
        settings.includeChampionPoints = true
    end
    
    if settings.includeChampionDiagram == nil then
        settings.includeChampionDiagram = false
    end
    
    if settings.includeSkillBars == nil then
        settings.includeSkillBars = true
    end
    
    if settings.includeSkills == nil then
        settings.includeSkills = true
    end
    
    if settings.includeEquipment == nil then
        settings.includeEquipment = true
    end
    
    if settings.includeCompanion == nil then
        settings.includeCompanion = true
    end
    
    if settings.includeCombatStats == nil then
        settings.includeCombatStats = true
    end
    
    if settings.includeBuffs == nil then
        settings.includeBuffs = true
    end
    
    if settings.includeAttributes == nil then
        settings.includeAttributes = true
    end
    
    if settings.includeRole == nil then
        settings.includeRole = true
    end
    
    if settings.includeLocation == nil then
        settings.includeLocation = true
    end
    
    -- Extended sections (DEFAULT: SELECTIVE)
    if settings.includeDLCAccess == nil then
        settings.includeDLCAccess = true
    end
    
    if settings.includeCurrency == nil then
        settings.includeCurrency = true
    end
    
    if settings.includeProgression == nil then
        settings.includeProgression = false
    end
    
    if settings.includeRidingSkills == nil then
        settings.includeRidingSkills = false
    end
    
    if settings.includeInventory == nil then
        settings.includeInventory = true
    end
    
    if settings.includePvP == nil then
        settings.includePvP = false
    end
    
    if settings.includeCollectibles == nil then
        settings.includeCollectibles = true
    end
    
    if settings.includeCollectiblesDetailed == nil then
        settings.includeCollectiblesDetailed = false
    end
    
    if settings.includeCrafting == nil then
        settings.includeCrafting = false
    end
    
    -- Link settings
    if settings.enableAbilityLinks == nil then
        settings.enableAbilityLinks = true
    end
    
    if settings.enableSetLinks == nil then
        settings.enableSetLinks = true
    end
    
    -- Skill filters
    if settings.minSkillRank == nil then
        settings.minSkillRank = 1
    end
    
    if settings.hideMaxedSkills == nil then
        settings.hideMaxedSkills = false
    end
    
    -- Equipment filters
    if settings.minEquipQuality == nil then
        settings.minEquipQuality = 0
    end
    
    if settings.hideEmptySlots == nil then
        settings.hideEmptySlots = false
    end
    
    -- MIGRATION: Force-enable settings that should be true
    local shouldBeEnabled = {
        "includeChampionPoints",
        "includeSkillBars",
        "includeSkills",
        "includeEquipment",
        "includeCompanion",
        "includeCombatStats",
        "includeBuffs",
        "includeAttributes",
        "includeRole",
        "includeLocation",
        "includeDLCAccess",
        "includeCurrency",
        "includeInventory",
        "includeCollectibles",
    }
    
    for _, key in ipairs(shouldBeEnabled) do
        if settings[key] == false then
            settings[key] = true
        CM.DebugPrint("SETTINGS", "Migrated setting to enabled:", key)
        end
    end
    
    -- CRITICAL FIX: Force ESO to save the settings by marking them as "dirty"
    -- ESO only saves SavedVariables when they're modified after initial load
    if isFirstRun then
        -- Force a save by making a real change that ESO will recognize
        settings._initialized = true
        settings._firstRun = true
        
        -- Force ESO to recognize this as a change that needs saving
        -- This is the key: we need to modify the SavedVariables after they're created
        zo_callLater(function()
            if CharacterMarkdownSettings then
                -- Make a small change to trigger ESO's save mechanism
                local originalVersion = CharacterMarkdownSettings.settingsVersion or 1
                CharacterMarkdownSettings.settingsVersion = originalVersion + 0.1
                CharacterMarkdownSettings.settingsVersion = originalVersion
                
                -- Add a timestamp to force save
                CharacterMarkdownSettings._lastModified = GetTimeStamp()
                
                CM.DebugPrint("SETTINGS", "Forced SavedVariables save - file should be created")
            end
        end, 1000)
        
        CM.DebugPrint("SETTINGS", "Settings initialized - SavedVariables file will be created")
    end
    
end

-- =====================================================
-- PER-CHARACTER DATA
-- =====================================================

function CharacterMarkdown.Settings.Initializer:InitializeCharacterData()
    -- ESO automatically creates CharacterMarkdownData as userdata
    -- DO NOT initialize it: CharacterMarkdownData = CharacterMarkdownData or {}
    
    if not CharacterMarkdownData then
        CM.Error("CRITICAL: CharacterMarkdownData not created by ESO!")
        CM.Error("Character data will not persist between sessions.")
        
        -- Create a temporary table for this session only
        CharacterMarkdownData = {}
        
        CM.DebugPrint("SETTINGS", "Using temporary character data - changes will not persist")
    end
    
    -- Initialize custom notes
    if CharacterMarkdownData.customNotes == nil then
        CharacterMarkdownData.customNotes = ""
    end
    
    -- Force character data save on first run
    if CharacterMarkdownData and not CharacterMarkdownData._initialized then
        CharacterMarkdownData._initialized = true
        CharacterMarkdownData._lastModified = GetTimeStamp()
    end
end

-- =====================================================
-- RESET TO DEFAULTS
-- =====================================================

function CharacterMarkdown.Settings.Initializer:ResetToDefaults()
    CM.Info("Resetting all settings to defaults...")
    
    -- Direct access to settings
    local settings = CharacterMarkdownSettings
    
    -- Reset all settings to defaults (direct assignment)
    settings.currentFormat = "github"
    settings.settingsVersion = 1
    
    -- Core sections
    settings.includeChampionPoints = true
    settings.includeChampionDiagram = false
    settings.includeSkillBars = true
    settings.includeSkills = true
    settings.includeEquipment = true
    settings.includeCompanion = true
    settings.includeCombatStats = true
    settings.includeBuffs = true
    settings.includeAttributes = true
    settings.includeRole = true
    settings.includeLocation = true
    
    -- Extended sections
    settings.includeDLCAccess = true
    settings.includeCurrency = true
    settings.includeProgression = false
    settings.includeRidingSkills = false
    settings.includeInventory = true
    settings.includePvP = false
    settings.includeCollectibles = true
    settings.includeCollectiblesDetailed = false
    settings.includeCrafting = false
    
    -- Link settings
    settings.enableAbilityLinks = true
    settings.enableSetLinks = true
    
    -- Filters
    settings.minSkillRank = 1
    settings.hideMaxedSkills = false
    settings.minEquipQuality = 0
    settings.hideEmptySlots = false
    
    -- Reset custom notes
    CharacterMarkdownData.customNotes = ""
    
    -- Sync to core
    if CharacterMarkdown.currentFormat and CharacterMarkdownSettings then
        CharacterMarkdown.currentFormat = CharacterMarkdownSettings.currentFormat
    end
    
    CM.Success("All settings reset to defaults")
end

-- =====================================================
-- MIGRATION (Future-proofing)
-- =====================================================

function CharacterMarkdown.Settings.Initializer:MigrateFromVersion(oldVersion)
    CM.DebugPrint("SETTINGS", "Checking migrations from version:", oldVersion)
    
    -- Currently no migrations needed
    CM.DebugPrint("SETTINGS", "No migrations required")
end