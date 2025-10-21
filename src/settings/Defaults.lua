-- CharacterMarkdown v2.1.1 - Settings Defaults
-- Default values and schema for all addon settings
-- Author: solaegis
-- Enhanced with profiles support

CharacterMarkdown = CharacterMarkdown or {}
CharacterMarkdown.Settings = CharacterMarkdown.Settings or {}
CharacterMarkdown.Settings.Defaults = {}

local CM = CharacterMarkdown

-- =====================================================
-- DEFAULT VALUES
-- =====================================================

-- Core build sections (DEFAULT: ENABLED)
CM.Settings.Defaults.CORE = {
    includeChampionPoints = true,
    includeChampionDiagram = false,  -- Visual mermaid diagram of invested CP (DISABLED - experimental feature)
    includeSkillBars = true,
    includeSkills = true,
    includeEquipment = true,
    includeCompanion = true,
    includeCombatStats = true,
    includeBuffs = true,
    includeAttributes = true,
    includeRole = true,
    includeLocation = true,
    includeBuildNotes = true,  -- Include custom build notes in markdown output
}

-- Extended info sections (DEFAULT: SELECTIVE)
CM.Settings.Defaults.EXTENDED = {
    includeDLCAccess = true,
    includeCurrency = true,
    includeProgression = false,  -- Achievement score, vampire/werewolf, enlightenment
    includeRidingSkills = false,  -- Mount training progress
    includeInventory = true,
    includePvP = false,  -- Alliance War rank and campaign
    includeCollectibles = true,
    includeCollectiblesDetailed = false,  -- Show detailed lists of owned collectibles (off by default due to length)
    includeCrafting = false,  -- Known motifs and research slots
}

-- Link settings
CM.Settings.Defaults.LINKS = {
    enableAbilityLinks = true,
    enableSetLinks = true,
}

-- Skill filters
CM.Settings.Defaults.SKILL_FILTERS = {
    minSkillRank = 1,
    hideMaxedSkills = false,
}

-- Equipment filters
CM.Settings.Defaults.EQUIPMENT_FILTERS = {
    minEquipQuality = 0,  -- 0=All, 2=Green, 3=Blue, 4=Purple, 5=Gold
    hideEmptySlots = false,
}

-- Output format
CM.Settings.Defaults.FORMAT = {
    currentFormat = "github",  -- "github", "vscode", "discord", "quick"
}

-- Custom notes (per-character)
CM.Settings.Defaults.NOTES = {
    customNotes = "",
}

-- =====================================================
-- PRESET PROFILES
-- =====================================================

CM.Settings.Defaults.PROFILES = {
    -- Full profile (everything enabled)
    ["Full Documentation"] = {
        name = "Full Documentation",
        description = "Maximum detail with all sections enabled",
        includeChampionPoints = true,
        includeChampionDiagram = false,
        includeSkillBars = true,
        includeSkills = true,
        includeEquipment = true,
        includeCompanion = true,
        includeCombatStats = true,
        includeBuffs = true,
        includeAttributes = true,
        includeRole = true,
        includeLocation = true,
        includeBuildNotes = true,
        includeDLCAccess = true,
        includeCurrency = true,
        includeProgression = true,
        includeRidingSkills = true,
        includeInventory = true,
        includePvP = true,
        includeCollectibles = true,
        includeCollectiblesDetailed = false,
        includeCrafting = true,
        enableAbilityLinks = true,
        enableSetLinks = true,
        minSkillRank = 1,
        hideMaxedSkills = false,
        minEquipQuality = 0,
        hideEmptySlots = false,
        currentFormat = "github",
    },
    
    -- PvE build profile
    ["PvE Build"] = {
        name = "PvE Build",
        description = "Focus on build essentials for trials/dungeons",
        includeChampionPoints = true,
        includeChampionDiagram = false,
        includeSkillBars = true,
        includeSkills = true,
        includeEquipment = true,
        includeCompanion = false,
        includeCombatStats = true,
        includeBuffs = true,
        includeAttributes = true,
        includeRole = true,
        includeLocation = false,
        includeBuildNotes = true,
        includeDLCAccess = true,
        includeCurrency = false,
        includeProgression = false,
        includeRidingSkills = false,
        includeInventory = false,
        includePvP = false,
        includeCollectibles = false,
        includeCollectiblesDetailed = false,
        includeCrafting = false,
        enableAbilityLinks = true,
        enableSetLinks = true,
        minSkillRank = 1,
        hideMaxedSkills = false,
        minEquipQuality = 4,  -- Purple+
        hideEmptySlots = true,
        currentFormat = "github",
    },
    
    -- PvP build profile
    ["PvP Build"] = {
        name = "PvP Build",
        description = "Optimized for Cyrodiil/Battlegrounds",
        includeChampionPoints = true,
        includeChampionDiagram = false,
        includeSkillBars = true,
        includeSkills = true,
        includeEquipment = true,
        includeCompanion = false,
        includeCombatStats = true,
        includeBuffs = true,
        includeAttributes = true,
        includeRole = false,
        includeLocation = true,
        includeBuildNotes = true,
        includeDLCAccess = false,
        includeCurrency = false,
        includeProgression = false,
        includeRidingSkills = true,  -- Important for PvP
        includeInventory = false,
        includePvP = true,
        includeCollectibles = false,
        includeCollectiblesDetailed = false,
        includeCrafting = false,
        enableAbilityLinks = true,
        enableSetLinks = true,
        minSkillRank = 1,
        hideMaxedSkills = false,
        minEquipQuality = 4,  -- Purple+
        hideEmptySlots = true,
        currentFormat = "github",
    },
    
    -- Discord share profile (compact)
    ["Discord Share"] = {
        name = "Discord Share",
        description = "Compact format for Discord servers",
        includeChampionPoints = true,
        includeChampionDiagram = false,
        includeSkillBars = true,
        includeSkills = false,  -- Too long for Discord
        includeEquipment = true,
        includeCompanion = false,
        includeCombatStats = true,
        includeBuffs = false,
        includeAttributes = true,
        includeRole = true,
        includeLocation = false,
        includeBuildNotes = true,
        includeDLCAccess = false,
        includeCurrency = false,
        includeProgression = false,
        includeRidingSkills = false,
        includeInventory = false,
        includePvP = false,
        includeCollectibles = false,
        includeCollectiblesDetailed = false,
        includeCrafting = false,
        enableAbilityLinks = true,
        enableSetLinks = true,
        minSkillRank = 1,
        hideMaxedSkills = false,
        minEquipQuality = 4,  -- Purple+
        hideEmptySlots = true,
        currentFormat = "discord",
    },
    
    -- Quick reference (minimal)
    ["Quick Reference"] = {
        name = "Quick Reference",
        description = "Just the essentials",
        includeChampionPoints = false,
        includeChampionDiagram = false,
        includeSkillBars = true,
        includeSkills = false,
        includeEquipment = true,
        includeCompanion = false,
        includeCombatStats = false,
        includeBuffs = false,
        includeAttributes = false,
        includeRole = true,
        includeLocation = false,
        includeBuildNotes = false,  -- Omit notes in quick reference
        includeDLCAccess = false,
        includeCurrency = false,
        includeProgression = false,
        includeRidingSkills = false,
        includeInventory = false,
        includePvP = false,
        includeCollectibles = false,
        includeCollectiblesDetailed = false,
        includeCrafting = false,
        enableAbilityLinks = false,
        enableSetLinks = false,
        minSkillRank = 1,
        hideMaxedSkills = false,
        minEquipQuality = 0,
        hideEmptySlots = true,
        currentFormat = "quick",
    },
}

-- =====================================================
-- COMBINED DEFAULTS
-- =====================================================

function CM.Settings.Defaults:GetAll()
    local defaults = {}
    
    -- Merge all settings categories
    for k, v in pairs(self.CORE) do
        defaults[k] = v
    end
    
    for k, v in pairs(self.EXTENDED) do
        defaults[k] = v
    end
    
    for k, v in pairs(self.LINKS) do
        defaults[k] = v
    end
    
    for k, v in pairs(self.SKILL_FILTERS) do
        defaults[k] = v
    end
    
    for k, v in pairs(self.EQUIPMENT_FILTERS) do
        defaults[k] = v
    end
    
    for k, v in pairs(self.FORMAT) do
        defaults[k] = v
    end
    
    return defaults
end

-- =====================================================
-- PROFILE HELPERS
-- =====================================================

function CM.Settings.Defaults:GetProfileNames()
    local names = {}
    for name, _ in pairs(self.PROFILES) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

function CM.Settings.Defaults:GetProfile(name)
    return self.PROFILES[name]
end

-- =====================================================
-- VALIDATION HELPERS
-- =====================================================

CM.Settings.Defaults.VALID_FORMATS = {
    "github",
    "vscode",
    "discord",
    "quick",
}

CM.Settings.Defaults.VALID_QUALITIES = {
    [0] = "All",
    [2] = "Green",
    [3] = "Blue",
    [4] = "Purple",
    [5] = "Gold",
}

function CM.Settings.Defaults:IsValidFormat(format)
    for _, validFormat in ipairs(self.VALID_FORMATS) do
        if format == validFormat then
            return true
        end
    end
    return false
end

function CM.Settings.Defaults:IsValidQuality(quality)
    return self.VALID_QUALITIES[quality] ~= nil
end

-- Debug print (deferred until CM.DebugPrint is available)
if CM.DebugPrint then
    CM.DebugPrint("SETTINGS", "Defaults module loaded with " .. #CM.Settings.Defaults:GetProfileNames() .. " preset profiles")
end
