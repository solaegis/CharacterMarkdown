-- CharacterMarkdown - Settings Defaults
-- Defines default values for all settings

local CM = CharacterMarkdown

CM.Settings = CM.Settings or {}
CM.Settings.Defaults = {}

-- =====================================================
-- DEFAULT SETTINGS
-- =====================================================

function CM.Settings.Defaults:GetAll()
    return {
        -- ====================================
        -- VISUAL ENHANCEMENT (NEW)
        -- ====================================
        enableEnhancedVisuals = true,  -- Use advanced markdown techniques (callouts, badges, collapsible sections, etc.)
        
        -- ====================================
        -- FORMAT SETTINGS
        -- ====================================
        currentFormat = "github",  -- Default format: github, vscode, discord, quick
        
        -- ====================================
        -- CORE CONTENT SECTIONS
        -- ====================================
        includeChampionPoints = true,
        includeChampionDetailed = false,
        -- includeChampionDiagram = false,  -- DISABLED: Experimental feature
        includeSkillBars = true,
        includeSkills = true,
        includeSkillMorphs = false,  -- Show all morphable skills with choices
        includeEquipment = true,
        includeCombatStats = true,
        includeCompanion = true,
        includeBuffs = true,
        includeAttributes = true,
        includeDLCAccess = true,
        includeRole = true,
        includeLocation = true,
        includeBuildNotes = true,  -- Include custom build notes
        includeQuickStats = true,   -- Quick stats at top (GitHub/VSCode only)
        includeAttentionNeeded = true,  -- Attention needed section (GitHub/VSCode only)
        
        -- ====================================
        -- EXTENDED CONTENT SECTIONS
        -- ====================================
        includeCurrency = true,
        includeProgression = false,
        includeRidingSkills = false,
        includeInventory = true,
        includePvP = false,
        includeCollectibles = true,
        includeCollectiblesDetailed = false,  -- Show full lists vs counts
        includeCrafting = false,
        includeAchievements = false,  -- Achievement tracking (Phase 5)
        includeAchievementsDetailed = false,  -- Detailed category breakdown
        showAllAchievements = true,  -- Show all achievements vs in-progress only
        includeQuests = false,  -- Quest tracking (Phase 6)
        includeQuestsDetailed = false,  -- Detailed quest categories
        showAllQuests = true,  -- Show all quests vs active only
        includeEquipmentEnhancement = false,  -- Equipment analysis (Phase 7)
        includeEquipmentAnalysis = false,  -- Detailed equipment analysis
        includeEquipmentRecommendations = false,  -- Optimization recommendations
        includeWorldProgress = false,  -- World progress tracking
        includeTitlesHousing = false,  -- Titles and housing
        includePvPStats = false,  -- PvP statistics
        includeArmoryBuilds = false,  -- Armory builds
        includeTalesOfTribute = false,  -- Tales of Tribute
        includeUndauntedPledges = false,  -- Undaunted pledges
        includeGuilds = false,  -- Guild membership
        
        -- ====================================
        -- LINK SETTINGS
        -- ====================================
        enableAbilityLinks = true,  -- Add UESP wiki links to abilities
        enableSetLinks = true,      -- Add UESP wiki links to armor sets
        
        -- ====================================
        -- SKILL FILTERS
        -- ====================================
        minSkillRank = 1,           -- Minimum skill rank to show
        hideMaxedSkills = false,    -- Hide fully maxed skill lines
        showMaxedSkills = true,     -- Show maxed skills (inverse of hideMaxedSkills for LAM)
        showAllRidingSkills = true, -- Show all riding skills vs incomplete only
        
        -- ====================================
        -- EQUIPMENT FILTERS
        -- ====================================
        minEquipQuality = 0,        -- Minimum equipment quality (0=all, 2=green, 3=blue, 4=purple, 5=gold)
        hideEmptySlots = false,     -- Hide equipment slots with no item
        
        -- ====================================
        -- FILTER MANAGER (Phase 8)
        -- ====================================
        activeFilter = "None",      -- Currently active filter preset
        filters = {},               -- User-saved filter presets
    }
end

CM.DebugPrint("SETTINGS", "Defaults module loaded")
