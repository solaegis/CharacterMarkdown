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
        -- FORMAT SETTINGS
        -- ====================================
        currentFormat = "github",  -- Default format: github, vscode, discord, quick
        
        -- ====================================
        -- CORE CONTENT SECTIONS
        -- ====================================
        includeChampionPoints = true,
        includeChampionDetailed = false,
        includeChampionDiagram = false,  -- Mermaid diagram (GitHub/VSCode only - Mermaid doesn't render in Discord)
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
        includeTableOfContents = true,  -- Table of contents (GitHub/VSCode only)
        
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
        includeAchievements = true,  -- Achievement tracking (Phase 5)
        includeAchievementsDetailed = true,  -- Detailed category breakdown
        showAllAchievements = true,  -- Show all achievements vs in-progress only
        includeAntiquities = true,  -- Antiquities tracking
        includeAntiquitiesDetailed = false,  -- Detailed antiquity sets breakdown
        -- includeQuests = true,  -- Quest tracking (Phase 6) - DISABLED
        -- includeQuestsDetailed = true,  -- Detailed quest categories - DISABLED
        -- showAllQuests = true,  -- Show all quests vs active only - DISABLED
        includeQuests = false,  -- Quest tracking disabled temporarily
        includeQuestsDetailed = false,
        showAllQuests = false,
        includeEquipmentEnhancement = false,  -- Equipment analysis (Phase 7)
        includeEquipmentAnalysis = false,  -- Detailed equipment analysis
        includeEquipmentRecommendations = false,  -- Optimization recommendations
        includeWorldProgress = false,  -- World progress tracking
        includeTitlesHousing = false,  -- Titles and housing
        includePvPStats = false,  -- PvP statistics
        includeArmoryBuilds = false,  -- Armory builds
        includeUndauntedPledges = false,  -- Undaunted pledges
        includeGuilds = false,  -- Guild membership
        
        -- ====================================
        -- PVP DISPLAY SETTINGS
        -- ====================================
        showPvPProgression = false,  -- Include rank progress bars and percentages
        showCampaignRewards = false,  -- Display reward tier and loyalty streak
        showLeaderboards = false,  -- Include leaderboard ranking (requires API query)
        showBattlegrounds = false,  -- Include BG leaderboard stats
        detailedPvP = false,  -- Full comprehensive mode with all PvP details
        
        -- ====================================
        -- LINK SETTINGS
        -- ====================================
        enableAbilityLinks = false,  -- Add UESP wiki links to abilities
        enableSetLinks = false,      -- Add UESP wiki links to armor sets
    }
end

CM.DebugPrint("SETTINGS", "Defaults module loaded")
