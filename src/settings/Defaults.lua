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
    includeChampionDetailed = false,  -- Show detailed CP allocation analysis (Phase 4)
    includeChampionSlottableOnly = false,  -- Show only slottable CP skills (Phase 4)
    includeSkillBars = true,
    includeSkills = true,
    includeSkillMorphs = false,  -- Show all available morphs for unlocked skills (disabled by default due to output size)
    includeEquipment = true,
    includeCompanion = true,
    includeCombatStats = true,
    includeBuffs = true,
    includeAttributes = true,
    includeRole = true,
    includeLocation = true,
    includeBuildNotes = true,  -- Include custom build notes in markdown output
    customTitle = "",  -- Custom title to override character's in-game title
}

-- Extended info sections (DEFAULT: SELECTIVE)
CM.Settings.Defaults.EXTENDED = {
    includeDLCAccess = true,
    includeCurrency = true,
    includeProgression = true,  -- Achievement score, vampire/werewolf, enlightenment
    includeRidingSkills = true,  -- Mount training progress
    includeInventory = true,
    includePvP = true,  -- Alliance War rank and campaign
    includeCollectibles = true,
    includeCollectiblesDetailed = false,  -- Show detailed lists of owned collectibles (off by default due to length)
    includeCrafting = true,  -- Known motifs and research slots
    includeAchievements = false,  -- Show detailed achievement tracking (Phase 5)
    includeAchievementsDetailed = false,  -- Show achievement categories and progress (Phase 5)
    includeAchievementsInProgress = false,  -- Show only in-progress achievements (Phase 5)
    includeQuests = false,  -- Show quest tracking and progress (Phase 6)
    includeQuestsDetailed = false,  -- Show quest categories and zones (Phase 6)
    includeQuestsActiveOnly = false,  -- Show only active quests (Phase 6)
    includeEquipmentEnhancement = false,  -- Show equipment analysis and optimization (Phase 7)
    includeEquipmentAnalysis = false,  -- Show detailed equipment analysis (Phase 7)
    includeEquipmentRecommendations = false,  -- Show optimization recommendations (Phase 7)
    includeWorldProgress = true,  -- Show world progress (skyshards, lorebooks, zone completion, dungeons) (Phase 9)
    includeTitlesHousing = true,  -- Show titles and housing collections (Phase 10)
    includePvPStats = true,  -- Show PvP statistics and campaign data (Phase 10)
    includeArmoryBuilds = true,  -- Show armory builds and templates (Phase 10)
    includeTalesOfTribute = true,  -- Show Tales of Tribute progress (Phase 10)
    includeUndauntedPledges = true,  -- Show Undaunted pledges and dungeon progress (Phase 10)
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

-- Filter manager settings
CM.Settings.Defaults.FILTERS = {
    activeFilter = "None",
    filters = {},
    filterPresets = {},
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
        includeChampionDetailed = true,  -- Enable detailed CP analysis
        includeChampionSlottableOnly = false,
        includeSkillBars = true,
        includeSkills = true,
        includeSkillMorphs = false,
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
        includeAchievements = true,  -- Enable achievement tracking
        includeAchievementsDetailed = true,  -- Enable detailed achievements
        includeAchievementsInProgress = false,  -- Show all achievements
        includeQuests = true,  -- Enable quest tracking
        includeQuestsDetailed = true,  -- Enable detailed quest categories
        includeQuestsActiveOnly = false,  -- Show all quests
        includeEquipmentEnhancement = true,  -- Enable equipment analysis
        includeEquipmentAnalysis = true,  -- Enable detailed equipment analysis
        includeEquipmentRecommendations = true,  -- Enable optimization recommendations
        includeWorldProgress = true,  -- Enable world progress tracking
        includeTitlesHousing = true,  -- Enable titles and housing
        includePvPStats = true,  -- Enable PvP statistics
        includeArmoryBuilds = true,  -- Enable armory builds
        includeTalesOfTribute = true,  -- Enable Tales of Tribute
        includeUndauntedPledges = true,  -- Enable Undaunted pledges
        customTitle = "",  -- Custom title override
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
        includeChampionDetailed = true,  -- Enable detailed CP for PvE builds
        includeChampionSlottableOnly = false,
        includeSkillBars = true,
        includeSkills = true,
        includeSkillMorphs = false,
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
        includeAchievements = true,  -- Enable for PvE builds
        includeAchievementsDetailed = false,  -- Keep compact
        includeAchievementsInProgress = true,  -- Focus on in-progress
        includeQuests = true,  -- Enable for PvE builds
        includeQuestsDetailed = false,  -- Keep compact
        includeQuestsActiveOnly = true,  -- Focus on active quests
        includeEquipmentEnhancement = true,  -- Enable for PvE builds
        includeEquipmentAnalysis = false,  -- Keep compact
        includeEquipmentRecommendations = true,  -- Focus on recommendations
        includeWorldProgress = true,  -- Enable world progress for PvE
        includeTitlesHousing = true,  -- Enable for PvE builds
        includePvPStats = false,  -- Not relevant for PvE
        includeArmoryBuilds = true,  -- Enable for PvE builds
        includeTalesOfTribute = true,  -- Enable for PvE builds
        includeUndauntedPledges = true,  -- Enable for PvE builds
        customTitle = "",  -- Custom title override
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
        includeChampionDetailed = true,  -- Enable detailed CP for PvP builds
        includeChampionSlottableOnly = false,
        includeSkillBars = true,
        includeSkills = true,
        includeSkillMorphs = false,
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
        includeAchievements = true,  -- Enable for PvP builds
        includeAchievementsDetailed = false,  -- Keep compact
        includeAchievementsInProgress = true,  -- Focus on in-progress
        includeQuests = true,  -- Enable for PvP builds
        includeQuestsDetailed = false,  -- Keep compact
        includeQuestsActiveOnly = true,  -- Focus on active quests
        includeEquipmentEnhancement = true,  -- Enable for PvP builds
        includeEquipmentAnalysis = false,  -- Keep compact
        includeEquipmentRecommendations = true,  -- Focus on recommendations
        includeWorldProgress = false,  -- Disable world progress for PvP (not relevant)
        includeTitlesHousing = true,  -- Enable for PvP builds
        includePvPStats = true,  -- Enable for PvP builds
        includeArmoryBuilds = true,  -- Enable for PvP builds
        includeTalesOfTribute = false,  -- Not relevant for PvP
        includeUndauntedPledges = false,  -- Not relevant for PvP
        customTitle = "",  -- Custom title override
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
        includeChampionDetailed = false,  -- Keep compact for Discord
        includeChampionSlottableOnly = true,  -- Show only slottable for Discord
        includeSkillBars = true,
        includeSkills = false,  -- Too long for Discord
        includeSkillMorphs = false,
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
        includeAchievements = false,  -- Keep Discord compact
        includeAchievementsDetailed = false,
        includeAchievementsInProgress = false,
        includeQuests = false,  -- Keep Discord compact
        includeQuestsDetailed = false,
        includeQuestsActiveOnly = false,
        includeEquipmentEnhancement = false,  -- Keep Discord compact
        includeEquipmentAnalysis = false,
        includeEquipmentRecommendations = false,
        includeWorldProgress = true,  -- Enable world progress for Discord (compact format)
        includeTitlesHousing = true,  -- Enable for Discord (compact)
        includePvPStats = true,  -- Enable for Discord (compact)
        includeArmoryBuilds = false,  -- Keep Discord compact
        includeTalesOfTribute = false,  -- Keep Discord compact
        includeUndauntedPledges = false,  -- Keep Discord compact
        customTitle = "",  -- Custom title override
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
        includeSkillMorphs = false,
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
    
    for k, v in pairs(self.NOTES) do
        defaults[k] = v
    end
    
    for k, v in pairs(self.FILTERS) do
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
