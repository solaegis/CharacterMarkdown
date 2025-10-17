-- CharacterMarkdown v2.1.0 - Settings Defaults
-- Default values and schema for all addon settings
-- Author: solaegis

CharacterMarkdown = CharacterMarkdown or {}
CharacterMarkdown.Settings = CharacterMarkdown.Settings or {}
CharacterMarkdown.Settings.Defaults = {}

-- =====================================================
-- DEFAULT VALUES
-- =====================================================

-- Core build sections (DEFAULT: ENABLED)
CharacterMarkdown.Settings.Defaults.CORE = {
    includeChampionPoints = true,
    includeSkills = true,
    includeEquipment = true,
    includeCompanion = true,
    includeCombatStats = true,
    includeBuffs = true,
    includeAttributes = true,
    includeRole = true,
    includeLocation = true,
}

-- Extended info sections (DEFAULT: ENABLED)
CharacterMarkdown.Settings.Defaults.EXTENDED = {
    includeDLCAccess = true,
    includeCurrency = true,
    includeProgression = true,
    includeRidingSkills = true,
    includeInventory = true,
    includePvP = true,
    includeCollectibles = true,
    includeCrafting = true,
}

-- Link settings
CharacterMarkdown.Settings.Defaults.LINKS = {
    enableAbilityLinks = true,
    enableSetLinks = true,
}

-- Skill filters
CharacterMarkdown.Settings.Defaults.SKILL_FILTERS = {
    minSkillRank = 1,
    hideMaxedSkills = false,
}

-- Equipment filters
CharacterMarkdown.Settings.Defaults.EQUIPMENT_FILTERS = {
    minEquipQuality = 0,  -- 0=All, 2=Green, 3=Blue, 4=Purple, 5=Gold
    hideEmptySlots = false,
}

-- Output format
CharacterMarkdown.Settings.Defaults.FORMAT = {
    currentFormat = "github",  -- "github", "vscode", "discord", "quick"
}

-- Custom notes (per-character)
CharacterMarkdown.Settings.Defaults.NOTES = {
    customNotes = "",
}

-- =====================================================
-- COMBINED DEFAULTS
-- =====================================================

function CharacterMarkdown.Settings.Defaults:GetAll()
    local defaults = {}
    
    -- Merge all categories
    for _, value in pairs(self.CORE) do
        for k, v in pairs(value) do
            defaults[k] = v
        end
    end
    
    for _, value in pairs(self.EXTENDED) do
        for k, v in pairs(value) do
            defaults[k] = v
        end
    end
    
    for _, value in pairs(self.LINKS) do
        for k, v in pairs(value) do
            defaults[k] = v
        end
    end
    
    for _, value in pairs(self.SKILL_FILTERS) do
        for k, v in pairs(value) do
            defaults[k] = v
        end
    end
    
    for _, value in pairs(self.EQUIPMENT_FILTERS) do
        for k, v in pairs(value) do
            defaults[k] = v
        end
    end
    
    for _, value in pairs(self.FORMAT) do
        for k, v in pairs(value) do
            defaults[k] = v
        end
    end
    
    return defaults
end

-- =====================================================
-- VALIDATION HELPERS
-- =====================================================

CharacterMarkdown.Settings.Defaults.VALID_FORMATS = {
    "github",
    "vscode",
    "discord",
    "quick",
}

CharacterMarkdown.Settings.Defaults.VALID_QUALITIES = {
    [0] = "All",
    [2] = "Green",
    [3] = "Blue",
    [4] = "Purple",
    [5] = "Gold",
}

function CharacterMarkdown.Settings.Defaults:IsValidFormat(format)
    for _, validFormat in ipairs(self.VALID_FORMATS) do
        if format == validFormat then
            return true
        end
    end
    return false
end

function CharacterMarkdown.Settings.Defaults:IsValidQuality(quality)
    return self.VALID_QUALITIES[quality] ~= nil
end
