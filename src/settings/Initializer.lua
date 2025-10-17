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
    -- Initialize account-wide settings with defaults
    self:InitializeAccountSettings()
    
    -- Initialize per-character data
    self:InitializeCharacterData()
    
    -- Sync format to core if available
    if CharacterMarkdown.currentFormat then
        CharacterMarkdown.currentFormat = CharacterMarkdownSettings.currentFormat
    end
    
    d("[CharacterMarkdown] Settings initialized")
    return true
end

-- =====================================================
-- ACCOUNT-WIDE SETTINGS
-- =====================================================

function CharacterMarkdown.Settings.Initializer:InitializeAccountSettings()
    -- Ensure the saved variable table exists
    CharacterMarkdownSettings = CharacterMarkdownSettings or {}
    
    local defaults = CharacterMarkdown.Settings.Defaults
    
    -- Initialize format setting
    CharacterMarkdownSettings.currentFormat = CharacterMarkdownSettings.currentFormat or defaults.FORMAT.currentFormat
    
    -- Validate format
    if not defaults:IsValidFormat(CharacterMarkdownSettings.currentFormat) then
        CharacterMarkdownSettings.currentFormat = defaults.FORMAT.currentFormat
    end
    
    -- Initialize core sections (DEFAULT: ENABLED)
    -- Use ~= false pattern to default to true
    for key, defaultValue in pairs(defaults.CORE) do
        CharacterMarkdownSettings[key] = CharacterMarkdownSettings[key] ~= false
    end
    
    -- Initialize extended sections (DEFAULT: ENABLED)
    for key, defaultValue in pairs(defaults.EXTENDED) do
        CharacterMarkdownSettings[key] = CharacterMarkdownSettings[key] ~= false
    end
    
    -- Initialize link settings (DEFAULT: ENABLED)
    for key, defaultValue in pairs(defaults.LINKS) do
        CharacterMarkdownSettings[key] = CharacterMarkdownSettings[key] ~= false
    end
    
    -- Initialize skill filters with explicit defaults
    CharacterMarkdownSettings.minSkillRank = CharacterMarkdownSettings.minSkillRank or defaults.SKILL_FILTERS.minSkillRank
    CharacterMarkdownSettings.hideMaxedSkills = CharacterMarkdownSettings.hideMaxedSkills or defaults.SKILL_FILTERS.hideMaxedSkills
    
    -- Initialize equipment filters with explicit defaults
    CharacterMarkdownSettings.minEquipQuality = CharacterMarkdownSettings.minEquipQuality or defaults.EQUIPMENT_FILTERS.minEquipQuality
    CharacterMarkdownSettings.hideEmptySlots = CharacterMarkdownSettings.hideEmptySlots or defaults.EQUIPMENT_FILTERS.hideEmptySlots
    
    -- Validate quality setting
    if not defaults:IsValidQuality(CharacterMarkdownSettings.minEquipQuality) then
        CharacterMarkdownSettings.minEquipQuality = defaults.EQUIPMENT_FILTERS.minEquipQuality
    end
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
