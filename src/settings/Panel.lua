-- CharacterMarkdown v2.1.1 - Settings Panel
-- LibAddonMenu UI registration and panel controls (FIXED)
-- Author: solaegis
-- Following CraftStore pattern for proper persistence

CharacterMarkdown = CharacterMarkdown or {}
CharacterMarkdown.Settings = CharacterMarkdown.Settings or {}
CharacterMarkdown.Settings.Panel = {}

local CM = CharacterMarkdown

-- =====================================================
-- PANEL REGISTRATION
-- =====================================================

function CM.Settings.Panel:Initialize()
    -- Wait for LibAddonMenu to be available
    if not LibAddonMenu2 then
        d("|cFF0000[CharacterMarkdown] WARNING: Settings panel unavailable|r")
        d("|cFFFF00LibAddonMenu-2.0 is required for the settings UI|r")
        d("|cFFFFFFTo install:|r")
        d("  1. Download from: https://www.esoui.com/downloads/info7-LibAddonMenu.html")
        d("  2. Extract to: Documents/Elder Scrolls Online/live/AddOns/")
        d("  3. Reload UI with /reloadui")
        d("|c00FF00The /markdown command still works without settings UI|r")
        return false
    end
    
    -- Ensure settings are initialized
    if not CharacterMarkdownSettings then
        CM.Error("Settings not initialized! Cannot create panel.")
        return false
    end
    
    -- Ensure character data is initialized
    if not CM.charData and CharacterMarkdownData then
        CM.charData = CharacterMarkdownData
        CM.DebugPrint("SETTINGS", "Character data initialized in panel")
    end
    
    local LAM = LibAddonMenu2
    
    -- Get defaults for LAM
    local defaults = CM.Settings.Defaults:GetAll()
    
    -- Create settings panel
    local panelData = {
        type = "panel",
        name = "Character Markdown",
        displayName = "Character Markdown",
        author = "solaegis",
        version = CM.version,
        slashCommand = "/cmdsettings",
        registerForRefresh = true,
        registerForDefaults = true,
        website = "https://www.esoui.com/downloads/info4279-CharacterMarkdown.html",
        feedback = "https://www.esoui.com/downloads/info4279-CharacterMarkdown.html#comments",
        donation = "https://www.buymeacoffee.com/lewisvavasw",
    }
    
    self.panelId = "CharacterMarkdownPanel"
    LAM:RegisterAddonPanel(self.panelId, panelData)
    
    -- Register options with proper getFunc/setFunc
    local optionsData = self:BuildOptionsData()
    LAM:RegisterOptionControls(self.panelId, optionsData)
    
    CM.DebugPrint("SETTINGS", "Settings panel registered with LAM")
    
    -- Register /cmdsettings command handler AFTER LibAddonMenu has registered
    -- This ensures our handler wraps LibAddonMenu's handler
    -- LibAddonMenu registers the slash command when RegisterAddonPanel is called,
    -- but we use a small delay to ensure it's registered
    if CM.commands and CM.commands.RegisterCmdSettingsCommand then
        zo_callLater(function()
            -- Retry logic in case LibAddonMenu hasn't registered yet
            local attempts = 0
            local maxAttempts = 5
            local function TryRegister()
                attempts = attempts + 1
                local existingHandler = SLASH_COMMANDS["/cmdsettings"]
                -- If handler exists and it's not our wrapper, LibAddonMenu has registered
                if existingHandler or attempts >= maxAttempts then
                    CM.commands.RegisterCmdSettingsCommand()
                else
                    -- Wait a bit longer and try again
                    zo_callLater(TryRegister, 50)
                end
            end
            TryRegister()
        end, 50)
    end
    
    return true
end

-- =====================================================
-- OPTIONS DATA BUILDER
-- =====================================================

function CM.Settings.Panel:BuildOptionsData()
    local options = {}
    
    -- Add sections in order (workflow-based organization)
    self:AddActions(options)  -- FIRST: Quick actions and controls
    self:AddFormatSection(options)
    self:AddCustomNotes(options)
    self:AddLayoutSection(options)  -- Layout options (Header/Footer)
    self:AddCombatBuildSection(options)  -- Combat & Build
    self:AddCharacterIdentitySection(options)  -- Character Identity & Progression
    self:AddEconomyResourcesSection(options)  -- Economy & Resources
    self:AddContentActivitiesSection(options)  -- Content & Activities
    self:AddPvPSocialSection(options)  -- PvP & Social
    self:AddLinkSettings(options)
    self:AddSupportSection(options)  -- LAST: Support section
    
    return options
end

-- =====================================================
-- FORMAT SETTINGS
-- =====================================================

function CM.Settings.Panel:AddFormatSection(options)
    table.insert(options, {
        type = "header",
        name = "Output Format",
        width = "full",
    })
    
    table.insert(options, {
        type = "dropdown",
        name = "Default Format",
        tooltip = "Select the default output format for /markdown command",
        choices = {"GitHub", "VS Code", "Discord", "Quick Summary"},
        choicesValues = {"github", "vscode", "discord", "quick"},
        getFunc = function() return CharacterMarkdownSettings.currentFormat end,
        setFunc = function(value)
            CharacterMarkdownSettings.currentFormat = value
            CM.currentFormat = value  -- Sync to core
        end,
        width = "full",
        default = "github",
    })
    
    table.insert(options, {
        type = "description",
        text = "|cFFFFFF==============================================================|r\n\n" ..
               "|cFFD700GitHub Format|r\n" ..
               "• Full HTML/CSS styling with colors and gradients\n" ..
               "• Clickable UESP links (abilities, sets, race, class, mundus, CP)\n" ..
               "• Styled tables and cards\n" ..
               "• Collapsible sections and rich formatting\n" ..
               "• Preview at: markdownlivepreview.com\n" ..
               "• Best for: GitHub README, GitLab, web platforms\n\n" ..
               "|c3B88C3VS Code Format|r\n" ..
               "• Pure markdown (no HTML)\n" ..
               "• Enhanced ASCII art and Unicode box drawing\n" ..
               "• Emoji-based visual indicators\n" ..
               "• Clean, readable in any markdown viewer\n" ..
               "• Best for: VS Code preview, plain text viewers, editors\n\n" ..
               "|c7289DADiscord Format|r\n" ..
               "• Discord-optimized markdown with code blocks\n" ..
               "• Clickable UESP links for all game content\n" ..
               "• Compact layout with character count warning\n" ..
               "• Paste directly in Discord channels\n" ..
               "• Best for: Discord channels, guild recruitment, LFG posts\n\n" ..
               "|cFF8C00Quick Summary|r\n" ..
               "• Ultra-compact one-line format\n" ..
               "• Name, level, CP, class, top 2 sets\n" ..
               "• Perfect for quick shares and status updates\n" ..
               "• Best for: Quick references, alt lists, spreadsheets\n\n" ..
               "|cFFFFFF==============================================================|r",
        width = "full",
    })
end

-- =====================================================
-- LAYOUT SECTION
-- =====================================================

function CM.Settings.Panel:AddLayoutSection(options)
    table.insert(options, {
        type = "header",
        name = "Layout",
        width = "full",
    })
    
    table.insert(options, {
        type = "description",
        text = "Control which structural elements appear in your markdown output.",
        width = "full",
    })
    
    -- Header
    table.insert(options, {
        type = "checkbox",
        name = "Include Header",
        tooltip = "Show character name, level, CP, class, and alliance at the top of the markdown.",
        getFunc = function() return CharacterMarkdownSettings.includeHeader end,
        setFunc = function(value) CharacterMarkdownSettings.includeHeader = value end,
        width = "half",
        default = true,
    })
    
    -- Footer
    table.insert(options, {
        type = "checkbox",
        name = "Include Footer",
        tooltip = "Show format badge, size, and generation date at the bottom of the markdown.",
        getFunc = function() return CharacterMarkdownSettings.includeFooter end,
        setFunc = function(value) CharacterMarkdownSettings.includeFooter = value end,
        width = "half",
        default = true,
    })
end

-- =====================================================
-- COMBAT & BUILD SECTION
-- =====================================================

function CM.Settings.Panel:AddCombatBuildSection(options)
    table.insert(options, {
        type = "header",
        name = "Combat & Build",
        width = "full",
    })
    
    table.insert(options, {
        type = "description",
        text = "Everything you need to share a build or understand combat readiness.",
        width = "full",
    })
    
    -- Champion Points
    table.insert(options, {
        type = "checkbox",
        name = "Include Champion Points",
        tooltip = "Show Champion Point allocation and discipline breakdown",
        getFunc = function() return CharacterMarkdownSettings.includeChampionPoints end,
        setFunc = function(value) CharacterMarkdownSettings.includeChampionPoints = value end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "    Include CP Visual Diagram",
        tooltip = "Show a Mermaid diagram visualizing your invested Champion Points with prerequisite relationships (GitHub/VSCode only). Requires 'Include Champion Points' to be enabled. Uses cluster API to discover skill relationships.",
        getFunc = function() return CharacterMarkdownSettings.includeChampionDiagram end,
        setFunc = function(value) CharacterMarkdownSettings.includeChampionDiagram = value end,
        disabled = function() return not CharacterMarkdownSettings.includeChampionPoints end,
        width = "half",
        default = false,
    })
    
    -- Skill Bars
    table.insert(options, {
        type = "checkbox",
        name = "Include Skill Bars",
        tooltip = "Show front and back bar abilities with ultimates",
        getFunc = function() return CharacterMarkdownSettings.includeSkillBars end,
        setFunc = function(value) CharacterMarkdownSettings.includeSkillBars = value end,
        width = "half",
        default = true,
    })
    
    -- Character Progress (Skills)
    table.insert(options, {
        type = "checkbox",
        name = "Include Character Progress",
        tooltip = "Show Character Progress section with skill line ranks, progress, and passives",
        getFunc = function() return CharacterMarkdownSettings.includeSkills end,
        setFunc = function(value) CharacterMarkdownSettings.includeSkills = value end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "    Show All Available Morphs",
        tooltip = "Show all morphable skills with their morph choices (not just equipped abilities).\nWhen enabled, displays comprehensive morph information for all unlocked skills.\nWhen disabled, shows only equipped abilities on bars.\nWARNING: Can generate 2-5KB of additional text for fully skilled characters.",
        getFunc = function() return CharacterMarkdownSettings.includeSkillMorphs end,
        setFunc = function(value) CharacterMarkdownSettings.includeSkillMorphs = value end,
        disabled = function() return not CharacterMarkdownSettings.includeSkills end,
        width = "half",
        default = false,
    })
    
    -- Equipment
    table.insert(options, {
        type = "checkbox",
        name = "Include Equipment",
        tooltip = "Show equipped items and armor sets",
        getFunc = function() return CharacterMarkdownSettings.includeEquipment end,
        setFunc = function(value) CharacterMarkdownSettings.includeEquipment = value end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "    Equipment Enhancement",
        tooltip = "Show equipment analysis, optimization suggestions, and upgrade tracking.",
        getFunc = function() return CharacterMarkdownSettings.includeEquipmentEnhancement end,
        setFunc = function(value) CharacterMarkdownSettings.includeEquipmentEnhancement = value end,
        disabled = function() return not CharacterMarkdownSettings.includeEquipment end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "        Detailed Equipment Analysis",
        tooltip = "Show detailed equipment analysis including set bonuses, quality upgrades, and enchantment analysis.",
        getFunc = function() return CharacterMarkdownSettings.includeEquipmentAnalysis end,
        setFunc = function(value) CharacterMarkdownSettings.includeEquipmentAnalysis = value end,
        disabled = function() return not CharacterMarkdownSettings.includeEquipmentEnhancement end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "        Optimization Recommendations",
        tooltip = "Show equipment optimization recommendations and upgrade suggestions.",
        getFunc = function() return CharacterMarkdownSettings.includeEquipmentRecommendations end,
        setFunc = function(value) CharacterMarkdownSettings.includeEquipmentRecommendations = value end,
        disabled = function() return not CharacterMarkdownSettings.includeEquipmentEnhancement end,
        width = "half",
        default = false,
    })
    
    -- Combat Stats
    table.insert(options, {
        type = "checkbox",
        name = "Include Combat Statistics",
        tooltip = "Show health, resources, weapon/spell power, resistances",
        getFunc = function() return CharacterMarkdownSettings.includeCombatStats end,
        setFunc = function(value) CharacterMarkdownSettings.includeCombatStats = value end,
        width = "half",
        default = true,
    })
    
    -- Active Buffs
    table.insert(options, {
        type = "checkbox",
        name = "Include Active Buffs",
        tooltip = "Show food, potions, and other active buffs",
        getFunc = function() return CharacterMarkdownSettings.includeBuffs end,
        setFunc = function(value) CharacterMarkdownSettings.includeBuffs = value end,
        width = "half",
        default = true,
    })
    
    -- Attribute Distribution
    table.insert(options, {
        type = "checkbox",
        name = "Include Attribute Distribution",
        tooltip = "Show magicka/health/stamina attribute points",
        getFunc = function() return CharacterMarkdownSettings.includeAttributes end,
        setFunc = function(value) CharacterMarkdownSettings.includeAttributes = value end,
        width = "half",
        default = true,
    })
    
    -- Armory Builds
    table.insert(options, {
        type = "checkbox",
        name = "Include Armory Builds",
        tooltip = "Show saved armory builds and configurations.",
        getFunc = function() return CharacterMarkdownSettings.includeArmoryBuilds end,
        setFunc = function(value) CharacterMarkdownSettings.includeArmoryBuilds = value end,
        width = "half",
        default = false,
    })
end

-- =====================================================
-- CHARACTER IDENTITY & PROGRESSION SECTION
-- =====================================================

function CM.Settings.Panel:AddCharacterIdentitySection(options)
    table.insert(options, {
        type = "header",
        name = "Character Identity & Progression",
        width = "full",
    })
    
    table.insert(options, {
        type = "description",
        text = "Character background, achievements, and long-term goals.",
        width = "full",
    })
    
    -- Role
    table.insert(options, {
        type = "checkbox",
        name = "Include Role",
        tooltip = "Show selected role (Tank/Healer/DPS) in overview",
        getFunc = function() return CharacterMarkdownSettings.includeRole end,
        setFunc = function(value) CharacterMarkdownSettings.includeRole = value end,
        width = "half",
        default = true,
    })
    
    -- Current Location
    table.insert(options, {
        type = "checkbox",
        name = "Include Current Location",
        tooltip = "Show current zone/location in overview\n(Minimal size impact)",
        getFunc = function() return CharacterMarkdownSettings.includeLocation end,
        setFunc = function(value) CharacterMarkdownSettings.includeLocation = value end,
        width = "half",
        default = true,
    })
    
    -- Progression Info
    table.insert(options, {
        type = "checkbox",
        name = "Include Progression Info",
        tooltip = "Show unspent skill/attribute points, achievement score, vampire/werewolf status, enlightenment\n(~300-500 chars)",
        getFunc = function() return CharacterMarkdownSettings.includeProgression end,
        setFunc = function(value) CharacterMarkdownSettings.includeProgression = value end,
        width = "half",
        default = false,
    })
    
    -- Achievement Tracking
    table.insert(options, {
        type = "checkbox",
        name = "Include Achievement Tracking",
        tooltip = "Show detailed achievement progress, categories, and completion status.",
        getFunc = function() return CharacterMarkdownSettings.includeAchievements end,
        setFunc = function(value) CharacterMarkdownSettings.includeAchievements = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "    Detailed Achievement Categories",
        tooltip = "Show achievement breakdown by categories (Combat, PvP, Exploration, Crafting, etc.) with progress tracking.",
        getFunc = function() return CharacterMarkdownSettings.includeAchievementsDetailed end,
        setFunc = function(value) CharacterMarkdownSettings.includeAchievementsDetailed = value end,
        disabled = function() return not CharacterMarkdownSettings.includeAchievements end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "    Show All Achievements",
        tooltip = "Show all achievements. When disabled, shows only achievements that are currently in progress (have some progress but not completed). Useful for goal tracking when disabled.",
        getFunc = function() return CharacterMarkdownSettings.showAllAchievements ~= false end,
        setFunc = function(value) CharacterMarkdownSettings.showAllAchievements = value end,
        disabled = function() return not CharacterMarkdownSettings.includeAchievements end,
        width = "half",
        default = true,
    })
    
    -- World Progress
    table.insert(options, {
        type = "checkbox",
        name = "Include World Progress",
        tooltip = "Show lorebook collection, zone completion, and world exploration progress.",
        getFunc = function() return CharacterMarkdownSettings.includeWorldProgress end,
        setFunc = function(value) CharacterMarkdownSettings.includeWorldProgress = value end,
        width = "half",
        default = false,
    })
    
    -- Titles & Housing
    table.insert(options, {
        type = "checkbox",
        name = "Include Titles & Housing",
        tooltip = "Show character titles and owned houses.",
        getFunc = function() return CharacterMarkdownSettings.includeTitlesHousing end,
        setFunc = function(value) CharacterMarkdownSettings.includeTitlesHousing = value end,
        width = "half",
        default = false,
    })
    
    -- DLC/Chapter Access
    table.insert(options, {
        type = "checkbox",
        name = "Include DLC/Chapter Access",
        tooltip = "Show which DLCs and Chapters are accessible\n(~400-600 chars - large section)",
        getFunc = function() return CharacterMarkdownSettings.includeDLCAccess end,
        setFunc = function(value) CharacterMarkdownSettings.includeDLCAccess = value end,
        width = "half",
        default = true,
    })
end

-- =====================================================
-- ECONOMY & RESOURCES SECTION
-- =====================================================

function CM.Settings.Panel:AddEconomyResourcesSection(options)
    table.insert(options, {
        type = "header",
        name = "Economy & Resources",
        width = "full",
    })
    
    table.insert(options, {
        type = "description",
        text = "Character wealth, inventory, and crafting capabilities.",
        width = "full",
    })
    
    -- Currency & Resources
    table.insert(options, {
        type = "checkbox",
        name = "Include Currency & Resources",
        tooltip = "Show gold, Alliance Points, Tel Var, Transmutes, Writs, Event Tickets, etc.\n(~500-800 chars)",
        getFunc = function() return CharacterMarkdownSettings.includeCurrency end,
        setFunc = function(value) CharacterMarkdownSettings.includeCurrency = value end,
        width = "half",
        default = true,
    })
    
    -- Inventory Space
    table.insert(options, {
        type = "checkbox",
        name = "Include Inventory Space",
        tooltip = "Show backpack and bank space usage\n(~150-200 chars)",
        getFunc = function() return CharacterMarkdownSettings.includeInventory end,
        setFunc = function(value) CharacterMarkdownSettings.includeInventory = value end,
        width = "half",
        default = true,
    })
    
    -- Crafting Knowledge
    table.insert(options, {
        type = "checkbox",
        name = "Include Crafting Knowledge",
        tooltip = "Show known motifs and active research slots\n(~150-200 chars)",
        getFunc = function() return CharacterMarkdownSettings.includeCrafting end,
        setFunc = function(value) CharacterMarkdownSettings.includeCrafting = value end,
        width = "half",
        default = false,
    })
    
    -- Collectibles
    table.insert(options, {
        type = "checkbox",
        name = "Include Collectibles",
        tooltip = "Show counts for mounts, pets, costumes, and houses owned\n(~200-300 chars)",
        getFunc = function() return CharacterMarkdownSettings.includeCollectibles end,
        setFunc = function(value) CharacterMarkdownSettings.includeCollectibles = value end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "    Detailed Collectibles Lists",
        tooltip = "Show detailed lists of all owned collectibles (mounts, pets, costumes, emotes, mementos, skins, polymorphs, personalities) with progress bars and UESP links. Includes DLC/Chapter access, Titles, and Housing.\n(Can add 5000+ chars depending on collection size)",
        getFunc = function() return CharacterMarkdownSettings.includeCollectiblesDetailed end,
        setFunc = function(value) CharacterMarkdownSettings.includeCollectiblesDetailed = value end,
        disabled = function() return not CharacterMarkdownSettings.includeCollectibles end,
        width = "half",
        default = false,
    })
    
    -- Riding Skills
    table.insert(options, {
        type = "checkbox",
        name = "Include Riding Skills",
        tooltip = "Show riding speed, stamina, and capacity progress\n(~200-300 chars)",
        getFunc = function() return CharacterMarkdownSettings.includeRidingSkills end,
        setFunc = function(value) CharacterMarkdownSettings.includeRidingSkills = value end,
        width = "half",
        default = false,
    })
end

-- =====================================================
-- CONTENT & ACTIVITIES SECTION
-- =====================================================

function CM.Settings.Panel:AddContentActivitiesSection(options)
    table.insert(options, {
        type = "header",
        name = "Content & Activities",
        width = "full",
    })
    
    table.insert(options, {
        type = "description",
        text = "Active content, quests, and repeatable activities.",
        width = "full",
    })
    
    -- Antiquities
    table.insert(options, {
        type = "checkbox",
        name = "Include Antiquities",
        tooltip = "Show antiquities progress, active leads, and discovered antiquities.",
        getFunc = function() return CharacterMarkdownSettings.includeAntiquities end,
        setFunc = function(value) CharacterMarkdownSettings.includeAntiquities = value end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "    Detailed Antiquity Sets",
        tooltip = "Show detailed breakdown of antiquity sets with progress tracking.",
        getFunc = function() return CharacterMarkdownSettings.includeAntiquitiesDetailed end,
        setFunc = function(value) CharacterMarkdownSettings.includeAntiquitiesDetailed = value end,
        disabled = function() return not CharacterMarkdownSettings.includeAntiquities end,
        width = "half",
        default = false,
    })
    
    -- Undaunted Pledges
    table.insert(options, {
        type = "checkbox",
        name = "Include Undaunted Pledges",
        tooltip = "Show active Undaunted pledges from quest journal.",
        getFunc = function() return CharacterMarkdownSettings.includeUndauntedPledges end,
        setFunc = function(value) CharacterMarkdownSettings.includeUndauntedPledges = value end,
        width = "half",
        default = false,
    })
    
    -- Companion Info
    table.insert(options, {
        type = "checkbox",
        name = "Include Companion Info",
        tooltip = "Show active companion details (if summoned)",
        getFunc = function() return CharacterMarkdownSettings.includeCompanion end,
        setFunc = function(value) CharacterMarkdownSettings.includeCompanion = value end,
        width = "half",
        default = true,
    })
    
    --[[ QUEST SECTION DISABLED TEMPORARILY - Issues being investigated
    table.insert(options, {
        type = "checkbox",
        name = "Include Quest Tracking",
        tooltip = "Show active quests, progress tracking, and quest categorization.",
        getFunc = function() return CharacterMarkdownSettings.includeQuests end,
        setFunc = function(value) CharacterMarkdownSettings.includeQuests = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "    Detailed Quest Categories",
        tooltip = "Show quest breakdown by categories (Main Story, Guild Quests, DLC Quests, etc.) with zone tracking.",
        getFunc = function() return CharacterMarkdownSettings.includeQuestsDetailed end,
        setFunc = function(value) CharacterMarkdownSettings.includeQuestsDetailed = value end,
        disabled = function() return not CharacterMarkdownSettings.includeQuests end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "    Show All Quests",
        tooltip = "Show all quests. When disabled, shows only currently active quests. Useful for current objective tracking when disabled.",
        getFunc = function() return CharacterMarkdownSettings.showAllQuests ~= false end,
        setFunc = function(value) CharacterMarkdownSettings.showAllQuests = value end,
        disabled = function() return not CharacterMarkdownSettings.includeQuests end,
        width = "half",
        default = false,
    })
    --]]
end

-- =====================================================
-- PVP & SOCIAL SECTION
-- =====================================================

function CM.Settings.Panel:AddPvPSocialSection(options)
    table.insert(options, {
        type = "header",
        name = "PvP & Social",
        width = "full",
    })
    
    table.insert(options, {
        type = "description",
        text = "All multiplayer and competitive aspects.",
        width = "full",
    })
    
    -- Basic PvP Information
    table.insert(options, {
        type = "checkbox",
        name = "Include PvP Information",
        tooltip = "Show Alliance War rank and current campaign\n(~150-200 chars)",
        getFunc = function() return CharacterMarkdownSettings.includePvP end,
        setFunc = function(value) CharacterMarkdownSettings.includePvP = value end,
        width = "half",
        default = false,
    })
    
    -- PvP Statistics
    table.insert(options, {
        type = "checkbox",
        name = "Include PvP Statistics",
        tooltip = "Show detailed PvP statistics and achievements.",
        getFunc = function() return CharacterMarkdownSettings.includePvPStats end,
        setFunc = function(value) CharacterMarkdownSettings.includePvPStats = value end,
        width = "half",
        default = false,
    })
    
    -- PvP Detail Options (dependent on includePvPStats)
    table.insert(options, {
        type = "checkbox",
        name = "    Show PvP Progression",
        tooltip = "Include rank progress bars, percentages, and AP needed to next grade.",
        getFunc = function() return CharacterMarkdownSettings.showPvPProgression end,
        setFunc = function(value) CharacterMarkdownSettings.showPvPProgression = value end,
        width = "half",
        disabled = function() return not CharacterMarkdownSettings.includePvPStats end,
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "    Show Campaign Rewards",
        tooltip = "Display reward tier progress and loyalty streak.",
        getFunc = function() return CharacterMarkdownSettings.showCampaignRewards end,
        setFunc = function(value) CharacterMarkdownSettings.showCampaignRewards = value end,
        width = "half",
        disabled = function() return not CharacterMarkdownSettings.includePvPStats end,
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "    Show Leaderboards",
        tooltip = "Include campaign leaderboard ranking (requires API query).",
        getFunc = function() return CharacterMarkdownSettings.showLeaderboards end,
        setFunc = function(value) CharacterMarkdownSettings.showLeaderboards = value end,
        width = "half",
        disabled = function() return not CharacterMarkdownSettings.includePvPStats end,
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "    Show Battlegrounds",
        tooltip = "Include battleground leaderboard stats and medals.",
        getFunc = function() return CharacterMarkdownSettings.showBattlegrounds end,
        setFunc = function(value) CharacterMarkdownSettings.showBattlegrounds = value end,
        width = "half",
        disabled = function() return not CharacterMarkdownSettings.includePvPStats end,
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "    Detailed PvP Mode",
        tooltip = "Full comprehensive mode with campaign timing, underpop bonus, emperor info, and current match stats.",
        getFunc = function() return CharacterMarkdownSettings.detailedPvP end,
        setFunc = function(value) CharacterMarkdownSettings.detailedPvP = value end,
        width = "half",
        disabled = function() return not CharacterMarkdownSettings.includePvPStats end,
        default = false,
    })
    
    -- Guild Membership
    table.insert(options, {
        type = "checkbox",
        name = "Include Guild Membership",
        tooltip = "Show guild membership information including guild names, member counts, and your rank.",
        getFunc = function() return CharacterMarkdownSettings.includeGuilds end,
        setFunc = function(value) CharacterMarkdownSettings.includeGuilds = value end,
        width = "half",
        default = false,
    })
end


-- =====================================================
-- LINK SETTINGS
-- =====================================================

function CM.Settings.Panel:AddLinkSettings(options)
    table.insert(options, {
        type = "header",
        name = "External Links (GitHub format only)",
        width = "full",
    })
    
    table.insert(options, {
        type = "description",
        text = "Enable clickable UESP wiki links for game elements. All links respect the same toggle below.",
        width = "full",
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Enable UESP Links",
        tooltip = "Make game elements clickable links to UESP wiki:\n• Abilities (skills on bars)\n• Armor sets\n• Race, Class, Alliance\n• Mundus stones\n• Champion Point skills\n• Zones/Locations\n• PvP Campaigns\n• Companions",
        getFunc = function() return CharacterMarkdownSettings.enableAbilityLinks end,
        setFunc = function(value) 
            CharacterMarkdownSettings.enableAbilityLinks = value
            CharacterMarkdownSettings.enableSetLinks = value
        end,
        width = "full",
        default = false,
    })
end

-- =====================================================
-- CUSTOM NOTES
-- =====================================================

function CM.Settings.Panel:AddCustomNotes(options)
    table.insert(options, {
        type = "header",
        name = "Character-Specific Settings",
        width = "full",
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Build Notes",
        tooltip = "Include custom build notes in the markdown output\nNotes must be entered below to appear in output",
        getFunc = function() return CharacterMarkdownSettings.includeBuildNotes end,
        setFunc = function(value) CharacterMarkdownSettings.includeBuildNotes = value end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "editbox",
        name = "Custom Title",
        tooltip = "Override your character's in-game title with a custom one.\nTitle is saved per-character and persists between sessions.\nLeave empty to use your character's current title.",
        getFunc = function() 
            -- Ensure character data is initialized
            if not CM.charData and CharacterMarkdownData then
                CM.charData = CharacterMarkdownData
            end
            -- Ensure customTitle exists (initialize if nil)
            if CM.charData and CM.charData.customTitle == nil then
                CM.charData.customTitle = ""
            end
            return CM.charData and CM.charData.customTitle or ""
        end,
        setFunc = function(value) 
            -- Ensure character data is initialized
            if not CM.charData and CharacterMarkdownData then
                CM.charData = CharacterMarkdownData
            end
            
            if not CM.charData then
                CM.Error("Failed to save custom title - character data not available")
                return
            end
            
            -- Normalize value (empty string if nil)
            local newValue = value or ""
            
            -- CRITICAL: Save to CM.charData (ZO_SavedVars proxy - automatically persists)
            -- Also update CharacterMarkdownData for backwards compatibility with fallback method
            -- With ZO_SavedVars, CM.charData is the proxy table and changes persist automatically
            -- (same persistence mechanism as boolean settings)
            local currentValue = CM.charData.customTitle or ""
            
            -- Update CM.charData (ZO_SavedVars proxy - automatically persists)
            CM.charData.customTitle = newValue
            CM.charData._lastModified = GetTimeStamp()
            
            -- Also update CharacterMarkdownData for backwards compatibility
            -- (With ZO_SavedVars, this is the same reference, but safe to update for fallback compatibility)
            if CharacterMarkdownData and CharacterMarkdownData ~= CM.charData then
                CharacterMarkdownData.customTitle = newValue
                CharacterMarkdownData._lastModified = GetTimeStamp()
            end
            
            -- Log the save (only log if value actually changed)
            if newValue ~= currentValue then
                CM.DebugPrint("SETTINGS", "Custom title changed and saved")
            else
                CM.DebugPrint("SETTINGS", "Custom title refreshed")
            end
        end,
        width = "full",
        textType = TEXT_TYPE_ALL,
        maxChars = 100,
        default = "",
    })
    
    table.insert(options, {
        type = "editbox",
        name = "Build Notes",
        tooltip = "Add custom notes (rotation, parse data, build description, etc.)\nNotes are saved per-character and persist between sessions.",
        getFunc = function() 
            -- Ensure character data is initialized
            if not CM.charData and CharacterMarkdownData then
                CM.charData = CharacterMarkdownData
            end
            -- Ensure customNotes exists (initialize if nil)
            if CM.charData and CM.charData.customNotes == nil then
                CM.charData.customNotes = ""
            end
            return CM.charData and CM.charData.customNotes or "" 
        end,
        setFunc = function(value) 
            -- Ensure character data is initialized
            if not CM.charData and CharacterMarkdownData then
                CM.charData = CharacterMarkdownData
            end
            
            if not CM.charData then
                CM.Error("Failed to save build notes - character data not available")
                return
            end
            
            -- Normalize value (empty string if nil)
            local newValue = value or ""
            
            -- CRITICAL: Save to CM.charData (ZO_SavedVars proxy - automatically persists)
            -- Also update CharacterMarkdownData for backwards compatibility with fallback method
            -- With ZO_SavedVars, CM.charData is the proxy table and changes persist automatically
            -- (same persistence mechanism as boolean settings)
            local currentValue = CM.charData.customNotes or ""
            
            -- Update CM.charData (ZO_SavedVars proxy - automatically persists)
            CM.charData.customNotes = newValue
            CM.charData._lastModified = GetTimeStamp()
            
            -- Also update CharacterMarkdownData for backwards compatibility
            -- (With ZO_SavedVars, this is the same reference, but safe to update for fallback compatibility)
            if CharacterMarkdownData and CharacterMarkdownData ~= CM.charData then
                CharacterMarkdownData.customNotes = newValue
                CharacterMarkdownData._lastModified = GetTimeStamp()
            end
            
            -- Log the save (only log if value actually changed)
            if newValue ~= currentValue then
                CM.DebugPrint("SETTINGS", "Build notes changed and saved (" .. string.len(newValue) .. " bytes)")
            else
                CM.DebugPrint("SETTINGS", "Build notes refreshed (" .. string.len(newValue) .. " bytes)")
            end
        end,
        width = "full",
        height = 300,  -- Increased height - scrollbar should appear automatically when content exceeds this
        isMultiline = true,
        isExtraWide = true,
        maxChars = 10000,
        default = "",
    })
end

-- =====================================================
-- ACTIONS
-- =====================================================

function CM.Settings.Panel:AddActions(options)
    table.insert(options, {
        type = "header",
        name = "Actions",
        width = "full",
    })
    
    table.insert(options, {
        type = "button",
        name = "Generate Profile Now",
        tooltip = "Open the copy window with current settings",
        func = function()
            if SLASH_COMMANDS and SLASH_COMMANDS["/markdown"] then
                SLASH_COMMANDS["/markdown"]("")
            else
                d("[CharacterMarkdown] ERROR: Command not available - try /reloadui")
            end
        end,
        width = "half",
    })
    
    table.insert(options, {
        type = "button",
        name = "Reload UI",
        tooltip = "Reload the user interface (useful after making changes)",
        func = function()
            ReloadUI()
        end,
        width = "half",
    })
    
    -- Helper function to enable/disable all sections
    local function ToggleAllSections(enable)
        local value = enable == true
        
        -- LAYOUT
        CharacterMarkdownSettings.includeHeader = value
        CharacterMarkdownSettings.includeFooter = value
        
        -- COMBAT & BUILD
        CharacterMarkdownSettings.includeChampionPoints = value
        CharacterMarkdownSettings.includeChampionDiagram = value
        CharacterMarkdownSettings.includeSkillBars = value
        CharacterMarkdownSettings.includeSkills = value
        CharacterMarkdownSettings.includeSkillMorphs = value
        CharacterMarkdownSettings.includeEquipment = value
        CharacterMarkdownSettings.includeEquipmentEnhancement = value
        CharacterMarkdownSettings.includeEquipmentAnalysis = value
        CharacterMarkdownSettings.includeEquipmentRecommendations = value
        CharacterMarkdownSettings.includeCombatStats = value
        CharacterMarkdownSettings.includeBuffs = value
        CharacterMarkdownSettings.includeAttributes = value
        CharacterMarkdownSettings.includeArmoryBuilds = value
        
        -- CHARACTER IDENTITY & PROGRESSION
        CharacterMarkdownSettings.includeRole = value
        CharacterMarkdownSettings.includeLocation = value
        CharacterMarkdownSettings.includeProgression = value
        CharacterMarkdownSettings.includeAchievements = value
        CharacterMarkdownSettings.includeAchievementsDetailed = value
        CharacterMarkdownSettings.showAllAchievements = value
        CharacterMarkdownSettings.includeWorldProgress = value
        CharacterMarkdownSettings.includeTitlesHousing = value
        CharacterMarkdownSettings.includeDLCAccess = value
        
        -- ECONOMY & RESOURCES
        CharacterMarkdownSettings.includeCurrency = value
        CharacterMarkdownSettings.includeInventory = value
        CharacterMarkdownSettings.includeCrafting = value
        CharacterMarkdownSettings.includeCollectibles = value
        CharacterMarkdownSettings.includeCollectiblesDetailed = value
        CharacterMarkdownSettings.includeRidingSkills = value
        
        -- CONTENT & ACTIVITIES
        CharacterMarkdownSettings.includeAntiquities = value
        CharacterMarkdownSettings.includeAntiquitiesDetailed = value
        CharacterMarkdownSettings.includeUndauntedPledges = value
        CharacterMarkdownSettings.includeCompanion = value
        -- CharacterMarkdownSettings.includeQuests = value  -- DISABLED
        -- CharacterMarkdownSettings.includeQuestsDetailed = value  -- DISABLED
        -- CharacterMarkdownSettings.showAllQuests = value  -- DISABLED
        
        -- PVP & SOCIAL
        CharacterMarkdownSettings.includePvP = value
        CharacterMarkdownSettings.includePvPStats = value
        CharacterMarkdownSettings.showPvPProgression = value
        CharacterMarkdownSettings.showCampaignRewards = value
        CharacterMarkdownSettings.showLeaderboards = value
        CharacterMarkdownSettings.showBattlegrounds = value
        CharacterMarkdownSettings.detailedPvP = value
        CharacterMarkdownSettings.includeGuilds = value
        
        -- LINKS
        CharacterMarkdownSettings.enableAbilityLinks = value
        CharacterMarkdownSettings.enableSetLinks = value
        
        -- Note: includeBuildNotes is intentionally excluded - custom title and build notes
        -- should remain visible and editable even when sections are toggled off
        
        CharacterMarkdownSettings._lastModified = GetTimeStamp()
        CM.Info(value and "All sections enabled!" or "All sections disabled!")
    end
    
    -- Enable All Sections button
    table.insert(options, {
        type = "button",
        name = "Enable All Sections",
        tooltip = "Turn on all content sections (Champion Points, Equipment, Currency, etc.)",
        func = function()
            ToggleAllSections(true)
            -- Force panel refresh
            local LAM = LibStub("LibAddonMenu-2.0", true)  -- true = silent, returns nil if not found
            if LAM and CM.Settings.Panel.panelId then
                LAM:RefreshPanel(CM.Settings.Panel.panelId)
            end
        end,
        width = "half",
    })
    
    -- Disable All Sections button
    table.insert(options, {
        type = "button",
        name = "Disable All Sections",
        tooltip = "Turn off all content sections",
        func = function()
            ToggleAllSections(false)
            -- Force panel refresh
            local LAM = LibStub("LibAddonMenu-2.0", true)  -- true = silent, returns nil if not found
            if LAM and CM.Settings.Panel.panelId then
                LAM:RefreshPanel(CM.Settings.Panel.panelId)
            end
        end,
        width = "half",
    })
end

-- =====================================================
-- SUPPORT SECTION
-- =====================================================

function CM.Settings.Panel:AddSupportSection(options)
    table.insert(options, {
        type = "header",
        name = "Support",
        width = "full",
    })
    
    table.insert(options, {
        type = "description",
        text = "|cFFD700Enjoying CharacterMarkdown?|r\n\nIf you find this addon useful, consider supporting its development!",
        width = "full",
    })
    
    table.insert(options, {
        type = "button",
        name = "Buy Me a Coffee",
        tooltip = "Support the development of CharacterMarkdown\n\nOpens your browser to the Buy Me a Coffee page",
        func = function()
            -- Try to open URL using ESO's RequestOpenURL if available
            local success, result = pcall(function()
                if RequestOpenURL then
                    RequestOpenURL("https://www.buymeacoffee.com/lewisvavasw")
                    return true
                end
                return false
            end)
            
            if success and result then
                CM.Info("Opening Buy Me a Coffee page...")
            else
                -- Fallback: Show URL in chat
                d("|cFFD700[CharacterMarkdown]|r |cFFFFFFBuy Me a Coffee:|r")
                d("|c3B88C3https://www.buymeacoffee.com/lewisvavasw|r")
                d("|cFFFF00(Copy the URL above and paste it in your browser)|r")
            end
        end,
        width = "full",
    })
end

-- Debug print (deferred until CM.DebugPrint is available)
if CM.DebugPrint then
    CM.DebugPrint("SETTINGS", "Panel module loaded (CraftStore pattern)")
end
