-- CharacterMarkdown v2.1.0 - Settings Initializer
-- Handles settings initialization and saved variables setup
-- Author: solaegis

CharacterMarkdown = CharacterMarkdown or {}
CharacterMarkdown.Settings = CharacterMarkdown.Settings or {}
CharacterMarkdown.Settings.Initializer = {}

-- =====================================================
-- INITIALIZATION
-- =====================================================

function CharacterMarkdown.Settings.Initializer:Initialize()
    -- Use delayed message to ensure it shows up
    zo_callLater(function()
        if CHAT_SYSTEM then
            CHAT_SYSTEM:AddMessage("CHARACTER MARKDOWN: Initialize() called")
        end
    end, 100)
    
    -- Initialize account-wide settings with defaults
    self:InitializeAccountSettings()
    
    -- Initialize per-character data
    self:InitializeCharacterData()
    
    -- Sync format to core if available
    if CharacterMarkdown.currentFormat then
        CharacterMarkdown.currentFormat = CharacterMarkdownSettings.currentFormat
    end
    
    zo_callLater(function()
        if CHAT_SYSTEM then
            CHAT_SYSTEM:AddMessage("CHARACTER MARKDOWN: Settings initialized, includeChampionPoints = " .. tostring(CharacterMarkdownSettings.includeChampionPoints))
        end
    end, 200)
    
    return true
end

-- =====================================================
-- ACCOUNT-WIDE SETTINGS
-- =====================================================

function CharacterMarkdown.Settings.Initializer:InitializeAccountSettings()
    zo_callLater(function()
        if CHAT_SYSTEM then
            CHAT_SYSTEM:AddMessage("CHARACTER MARKDOWN: InitializeAccountSettings() called")
        end
    end, 150)
    
    -- Ensure the saved variable table exists
    CharacterMarkdownSettings = CharacterMarkdownSettings or {}
    
    local defaults = CharacterMarkdown.Settings.Defaults
    
    -- Check if this is a fresh install (no version number means never initialized)
    local isFirstRun = (CharacterMarkdownSettings.settingsVersion == nil)
    
    zo_callLater(function()
        if CHAT_SYSTEM then
            CHAT_SYSTEM:AddMessage("CHARACTER MARKDOWN: isFirstRun = " .. tostring(isFirstRun))
        end
    end, 160)
    
    if isFirstRun then
        CharacterMarkdownSettings.settingsVersion = 1
        
        zo_callLater(function()
            if CHAT_SYSTEM then
                CHAT_SYSTEM:AddMessage("CHARACTER MARKDOWN: Setting all defaults for first run...")
                CHAT_SYSTEM:AddMessage("  defaults = " .. tostring(defaults))
                CHAT_SYSTEM:AddMessage("  defaults.CORE = " .. tostring(defaults.CORE))
                CHAT_SYSTEM:AddMessage("  defaults.CORE.includeChampionPoints = " .. tostring(defaults.CORE and defaults.CORE.includeChampionPoints))
            end
        end, 170)
        
        -- On first run, explicitly set ALL defaults immediately
        -- This ensures LAM sees proper values even before saved variables are written
        
        -- Debug: Check if we can iterate
        local coreCount = 0
        for key, value in pairs(defaults.CORE) do
            coreCount = coreCount + 1
            CharacterMarkdownSettings[key] = value
        end
        
        -- Check IMMEDIATELY after setting (not delayed)
        local immediateCheck = CharacterMarkdownSettings.includeChampionPoints
        
        zo_callLater(function()
            if CHAT_SYSTEM then
                CHAT_SYSTEM:AddMessage("  Set " .. coreCount .. " CORE settings")
                CHAT_SYSTEM:AddMessage("  IMMEDIATE check after loop: includeChampionPoints = " .. tostring(immediateCheck))
                CHAT_SYSTEM:AddMessage("  CharacterMarkdownSettings table = " .. tostring(CharacterMarkdownSettings))
            end
        end, 175)
        
        for key, value in pairs(defaults.EXTENDED) do
            CharacterMarkdownSettings[key] = value
        end
        for key, value in pairs(defaults.LINKS) do
            CharacterMarkdownSettings[key] = value
        end
        for key, value in pairs(defaults.SKILL_FILTERS) do
            CharacterMarkdownSettings[key] = value
        end
        for key, value in pairs(defaults.EQUIPMENT_FILTERS) do
            CharacterMarkdownSettings[key] = value
        end
        CharacterMarkdownSettings.currentFormat = defaults.FORMAT.currentFormat
        
        zo_callLater(function()
            if CHAT_SYSTEM then
                CHAT_SYSTEM:AddMessage("CHARACTER MARKDOWN: Defaults set! includeChampionPoints = " .. tostring(CharacterMarkdownSettings.includeChampionPoints))
            end
        end, 180)
    else
        zo_callLater(function()
            if CHAT_SYSTEM then
                CHAT_SYSTEM:AddMessage("CHARACTER MARKDOWN: Existing settings found (version " .. tostring(CharacterMarkdownSettings.settingsVersion) .. ")")
            end
        end, 170)
    end
    
    -- Initialize format setting
    CharacterMarkdownSettings.currentFormat = CharacterMarkdownSettings.currentFormat or defaults.FORMAT.currentFormat
    
    -- Validate format
    if not defaults:IsValidFormat(CharacterMarkdownSettings.currentFormat) then
        CharacterMarkdownSettings.currentFormat = defaults.FORMAT.currentFormat
    end
    
    -- Initialize core sections
    for key, defaultValue in pairs(defaults.CORE) do
        if CharacterMarkdownSettings[key] == nil then
            CharacterMarkdownSettings[key] = defaultValue
            d("  Setting " .. key .. " = " .. tostring(defaultValue))
        end
    end
    
    -- Initialize extended sections
    for key, defaultValue in pairs(defaults.EXTENDED) do
        if CharacterMarkdownSettings[key] == nil then
            CharacterMarkdownSettings[key] = defaultValue
            d("  Setting " .. key .. " = " .. tostring(defaultValue))
        end
    end
    
    -- Initialize link settings
    for key, defaultValue in pairs(defaults.LINKS) do
        if CharacterMarkdownSettings[key] == nil then
            CharacterMarkdownSettings[key] = defaultValue
            d("  Setting " .. key .. " = " .. tostring(defaultValue))
        end
    end
    
    -- Initialize skill filters with explicit defaults
    if CharacterMarkdownSettings.minSkillRank == nil then
        CharacterMarkdownSettings.minSkillRank = defaults.SKILL_FILTERS.minSkillRank
    end
    if CharacterMarkdownSettings.hideMaxedSkills == nil then
        CharacterMarkdownSettings.hideMaxedSkills = defaults.SKILL_FILTERS.hideMaxedSkills
    end
    
    -- Initialize equipment filters with explicit defaults
    if CharacterMarkdownSettings.minEquipQuality == nil then
        CharacterMarkdownSettings.minEquipQuality = defaults.EQUIPMENT_FILTERS.minEquipQuality
    end
    if CharacterMarkdownSettings.hideEmptySlots == nil then
        CharacterMarkdownSettings.hideEmptySlots = defaults.EQUIPMENT_FILTERS.hideEmptySlots
    end
    
    -- Validate quality setting
    if not defaults:IsValidQuality(CharacterMarkdownSettings.minEquipQuality) then
        CharacterMarkdownSettings.minEquipQuality = defaults.EQUIPMENT_FILTERS.minEquipQuality
    end
    
    -- Debug: Log a few settings to verify they were set
    d("[CharacterMarkdown] Sample settings initialized:")
    d("  includeChampionPoints = " .. tostring(CharacterMarkdownSettings.includeChampionPoints))
    d("  includeEquipment = " .. tostring(CharacterMarkdownSettings.includeEquipment))
    d("  includeCurrency = " .. tostring(CharacterMarkdownSettings.includeCurrency))
    d("  currentFormat = " .. tostring(CharacterMarkdownSettings.currentFormat))
end

-- =====================================================
-- PER-CHARACTER DATA
-- =====================================================

function CharacterMarkdown.Settings.Initializer:InitializeCharacterData()
    -- Ensure the saved variable table exists
    CharacterMarkdownData = CharacterMarkdownData or {}
    
    -- Initialize custom notes
    CharacterMarkdownData.customNotes = CharacterMarkdownData.customNotes or CharacterMarkdown.Settings.Defaults.NOTES.customNotes
end

-- =====================================================
-- RESET TO DEFAULTS
-- =====================================================

function CharacterMarkdown.Settings.Initializer:ResetToDefaults()
    local defaults = CharacterMarkdown.Settings.Defaults
    
    -- Reset format
    CharacterMarkdownSettings.currentFormat = defaults.FORMAT.currentFormat
    
    -- Reset core sections
    for key, value in pairs(defaults.CORE) do
        CharacterMarkdownSettings[key] = value
    end
    
    -- Reset extended sections
    for key, value in pairs(defaults.EXTENDED) do
        CharacterMarkdownSettings[key] = value
    end
    
    -- Reset link settings
    for key, value in pairs(defaults.LINKS) do
        CharacterMarkdownSettings[key] = value
    end
    
    -- Reset skill filters
    for key, value in pairs(defaults.SKILL_FILTERS) do
        CharacterMarkdownSettings[key] = value
    end
    
    -- Reset equipment filters
    for key, value in pairs(defaults.EQUIPMENT_FILTERS) do
        CharacterMarkdownSettings[key] = value
    end
    
    -- Reset custom notes
    CharacterMarkdownData.customNotes = defaults.NOTES.customNotes
    
    -- Sync to core
    if CharacterMarkdown.currentFormat then
        CharacterMarkdown.currentFormat = CharacterMarkdownSettings.currentFormat
    end
    
    d("[CharacterMarkdown] All settings reset to defaults")
end

-- =====================================================
-- MIGRATION (Future-proofing)
-- =====================================================

function CharacterMarkdown.Settings.Initializer:MigrateFromVersion(oldVersion)
    -- Placeholder for future version migrations
    -- Example:
    -- if oldVersion < 2.1 then
    --     self:MigrateFrom20To21()
    -- end
end
