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
        d("|cFF0000[CharacterMarkdown] ⚠️ Settings panel unavailable|r")
        d("|cFFFF00LibAddonMenu-2.0 is required for the settings UI|r")
        d("|cFFFFFFTo install:|r")
        d("  1. Download from: https://www.esoui.com/downloads/info7-LibAddonMenu.html")
        d("  2. Extract to: Documents/Elder Scrolls Online/live/AddOns/")
        d("  3. Reload UI with /reloadui")
        d("|c00FF00The /markdown command still works without settings UI|r")
        return false
    end
    
    -- Ensure settings are initialized
    if not CM.settings then
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
    }
    
    LAM:RegisterAddonPanel("CharacterMarkdownPanel", panelData)
    
    -- Register options with proper getFunc/setFunc
    local optionsData = self:BuildOptionsData()
    LAM:RegisterOptionControls("CharacterMarkdownPanel", optionsData)
    
    CM.DebugPrint("SETTINGS", "Settings panel registered with LAM")
    return true
end

-- =====================================================
-- OPTIONS DATA BUILDER
-- =====================================================

function CM.Settings.Panel:BuildOptionsData()
    local options = {}
    
    -- Add sections in order
    self:AddVisualEnhancementSection(options)  -- FIRST: Enhanced visuals toggle
    self:AddFormatSection(options)
    self:AddCustomNotes(options)
    self:AddFilterManagerSection(options)
    self:AddCoreSections(options)
    self:AddExtendedSections(options)
    self:AddLinkSettings(options)
    self:AddSkillFilters(options)
    self:AddEquipmentFilters(options)
    self:AddActions(options)
    
    return options
end

-- =====================================================
-- VISUAL ENHANCEMENT TOGGLE (FIRST SETTING)
-- =====================================================

function CM.Settings.Panel:AddVisualEnhancementSection(options)
    table.insert(options, {
        type = "header",
        name = "Visual Enhancement Mode",
        width = "full",
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Enable Enhanced Visual Mode",
        tooltip = "Use advanced markdown techniques for stunning visual output:\n" ..
                 "• GitHub callouts (NOTE, TIP, IMPORTANT, WARNING, CAUTION)\n" ..
                 "• Status badges with colors\n" ..
                 "• Collapsible sections for better organization\n" ..
                 "• Enhanced progress bars with color coding\n" ..
                 "• Two-column layouts for stats\n" ..
                 "• Visual separators and styled tables\n" ..
                 "• Emoji indicators for status\n" ..
                 "• Info boxes for important messages\n\n" ..
                 "When disabled, uses classic markdown format.",
        getFunc = function() return CM.settings.enableEnhancedVisuals end,
        setFunc = function(value) 
            CM.settings.enableEnhancedVisuals = value
            CM.Info(value and "Enhanced visuals ENABLED" or "Enhanced visuals DISABLED")
        end,
        width = "full",
        default = true,
    })
    
    table.insert(options, {
        type = "description",
        text = "|cFFD700✨ Enhanced Visual Mode is ENABLED by default!|r\n\n" ..
               "|c00FF00This new mode creates stunning, professional markdown output with:\n" ..
               "• Native GitHub callouts for notes, tips, and warnings\n" ..
               "• Colorful status badges and progress indicators\n" ..
               "• Collapsible sections to reduce clutter\n" ..
               "• Enhanced tables and layouts\n" ..
               "• Visual hierarchy and organization\n\n" ..
               "|cFFFFFF📝 Perfect for GitHub READMEs, documentation, and sharing builds!\n\n" ..
               "Toggle OFF for classic plain markdown format.|r",
        width = "full",
    })
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
        getFunc = function() return CM.settings.currentFormat end,
        setFunc = function(value)
            CM.settings.currentFormat = value
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
-- FILTER MANAGER SECTION
-- =====================================================

function CM.Settings.Panel:AddFilterManagerSection(options)
    table.insert(options, {
        type = "header",
        name = "Filter Manager (Phase 8)",
        width = "full",
    })
    
    -- Initialize filter manager if needed
    if not CM.Settings.FilterManager then
        local FilterManager = require("src/settings/FilterManager")
        CM.Settings.FilterManager = FilterManager
        if CM.Settings.FilterManager.Initialize then
            CM.Settings.FilterManager:Initialize()
        end
    end
    
    -- Build choices list for dropdown
    local function GetFilterChoices()
        local choices = {"None"}
        local choicesValues = {"None"}
        
        -- Add user filters
        if CM.settings and CM.settings.filters then
            for name, _ in pairs(CM.settings.filters) do
                table.insert(choices, name)
                table.insert(choicesValues, name)
            end
        end
        
        -- Add preset filters
        if CM.Settings.FilterManager and CM.Settings.FilterManager.FILTER_PRESETS then
            for name, _ in pairs(CM.Settings.FilterManager.FILTER_PRESETS) do
                table.insert(choices, name .. " (Preset)")
                table.insert(choicesValues, name)
            end
        end
        
        return choices, choicesValues
    end
    
    -- Active filter dropdown
    local filterChoices, filterChoicesValues = GetFilterChoices()
    table.insert(options, {
        type = "dropdown",
        name = "Active Filter",
        tooltip = "Select an active filter to apply to your character data display",
        choices = filterChoices,
        choicesValues = filterChoicesValues,
        getFunc = function() return CM.settings.activeFilter or "None" end,
        setFunc = function(value)
            if value ~= "None" then
                CM.Settings.FilterManager:ApplyFilter(value)
            else
                CM.settings.activeFilter = "None"
            end
        end,
        width = "full",
        default = "None",
    })
    
    -- Filter management buttons
    table.insert(options, {
        type = "button",
        name = "Save Current as Filter",
        tooltip = "Save your current settings as a custom filter",
        func = function()
            local dialog = {
                title = "Save Filter",
                mainText = "Enter a name for your custom filter:",
                editBox = true,
                buttons = {
                    {
                        text = "Save",
                        callback = function(dialog)
                            local name = dialog.editBox:GetText()
                            if name and name ~= "" then
                                CM.Settings.FilterManager:SaveCurrentAsFilter(name, "Custom filter", "Custom")
                                -- Refresh the dropdown
                                LAM:RefreshPanel("CharacterMarkdownPanel")
                            end
                        end
                    },
                    {
                        text = "Cancel",
                        callback = function() end
                    }
                }
            }
            ZO_Dialogs_ShowDialog("CHARACTERMARKDOWN_SAVE_FILTER", dialog)
        end,
        width = "half",
    })
    
    table.insert(options, {
        type = "button",
        name = "Filter Analysis",
        tooltip = "Analyze your current filter settings and get recommendations",
        func = function()
            local analysis = CM.Settings.FilterManager:AnalyzeCurrentSettings()
            local message = "Filter Analysis:\n\n"
            
            message = message .. "Enabled Sections: " .. analysis.enabledSections .. "/" .. analysis.totalSections .. "\n\n"
            
            for category, data in pairs(analysis.categories) do
                message = message .. category .. ": " .. data.enabled .. "/" .. data.total .. " (" .. data.percentage .. "%)\n"
            end
            
            if #analysis.recommendations > 0 then
                message = message .. "\nRecommendations:\n"
                for _, rec in ipairs(analysis.recommendations) do
                    message = message .. "• " .. rec.message .. "\n"
                end
            end
            
            ZO_Dialogs_ShowDialog("CHARACTERMARKDOWN_FILTER_ANALYSIS", {
                title = "Filter Analysis",
                mainText = message,
                buttons = {
                    {
                        text = "OK",
                        callback = function() end
                    }
                }
            })
        end,
        width = "half",
    })
    
    table.insert(options, {
        type = "description",
        text = "|c00FF00Filter Manager allows you to create, save, and apply custom filter presets.|r Use filters to quickly switch between different display configurations for different purposes (PvE, PvP, Crafting, etc.).",
        width = "full",
    })
end

-- =====================================================
-- CORE CONTENT SECTIONS
-- =====================================================

function CM.Settings.Panel:AddCoreSections(options)
    table.insert(options, {
        type = "header",
        name = "Core Content Sections",
        width = "full",
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Champion Points",
        tooltip = "Show Champion Point allocation and discipline breakdown",
        getFunc = function() return CM.settings.includeChampionPoints end,
        setFunc = function(value) CM.settings.includeChampionPoints = value end,
        width = "half",
        default = true,
    })
    
    -- EXPERIMENTAL: CP Visual Diagram - Hidden from UI for now, code kept for future work
    -- table.insert(options, {
    --     type = "checkbox",
    --     name = "  ↳ Include CP Visual Diagram",
    --     tooltip = "Show a Mermaid diagram visualizing your invested Champion Points (GitHub/VSCode only). Requires 'Include Champion Points' to be enabled. ⚠️ EXPERIMENTAL FEATURE - May not render correctly in all viewers.",
    --     getFunc = function() return CM.settings.includeChampionDiagram end,
    --     setFunc = function(value) CM.settings.includeChampionDiagram = value end,
    --     disabled = function() return not CM.settings.includeChampionPoints end,
    --     width = "half",
    --     default = false,
    --     warning = "Experimental feature - Code is complete but not fully tested.",
    -- })
    
    table.insert(options, {
        type = "checkbox",
        name = "  ↳ Detailed CP Analysis",
        tooltip = "Show detailed Champion Point allocation analysis including slottable vs passive breakdown, investment levels, and optimization suggestions (Phase 4).",
        getFunc = function() return CM.settings.includeChampionDetailed end,
        setFunc = function(value) CM.settings.includeChampionDetailed = value end,
        disabled = function() return not CM.settings.includeChampionPoints end,
        width = "half",
        default = false,
    })
    
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Skill Bars",
        tooltip = "Show front and back bar abilities with ultimates",
        getFunc = function() return CM.settings.includeSkillBars end,
        setFunc = function(value) CM.settings.includeSkillBars = value end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Skill Progression",
        tooltip = "Show skill line ranks and progress",
        getFunc = function() return CM.settings.includeSkills end,
        setFunc = function(value) CM.settings.includeSkills = value end,
        width = "half",
        default = true,
    })
    
    -- NEW: Skill Morphs Toggle
    table.insert(options, {
        type = "checkbox",
        name = "  ↳ Show All Available Morphs",
        tooltip = "Show all morphable skills with their morph choices (not just equipped abilities).\n" ..
                 "When enabled, displays comprehensive morph information for all unlocked skills.\n" ..
                 "When disabled, shows only equipped abilities on bars.\n" ..
                 "⚠️ Note: Can generate 2-5KB of additional text for fully skilled characters.",
        getFunc = function() return CM.settings.includeSkillMorphs end,
        setFunc = function(value) CM.settings.includeSkillMorphs = value end,
        disabled = function() return not CM.settings.includeSkills end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Equipment",
        tooltip = "Show equipped items and armor sets",
        getFunc = function() return CM.settings.includeEquipment end,
        setFunc = function(value) CM.settings.includeEquipment = value end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Combat Statistics",
        tooltip = "Show health, resources, weapon/spell power, resistances",
        getFunc = function() return CM.settings.includeCombatStats end,
        setFunc = function(value) CM.settings.includeCombatStats = value end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Companion Info",
        tooltip = "Show active companion details (if summoned)",
        getFunc = function() return CM.settings.includeCompanion end,
        setFunc = function(value) CM.settings.includeCompanion = value end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Active Buffs",
        tooltip = "Show food, potions, and other active buffs",
        getFunc = function() return CM.settings.includeBuffs end,
        setFunc = function(value) CM.settings.includeBuffs = value end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Attribute Distribution",
        tooltip = "Show magicka/health/stamina attribute points",
        getFunc = function() return CM.settings.includeAttributes end,
        setFunc = function(value) CM.settings.includeAttributes = value end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include DLC/Chapter Access",
        tooltip = "Show which DLCs and Chapters are accessible\n(~400-600 chars - large section)",
        getFunc = function() return CM.settings.includeDLCAccess end,
        setFunc = function(value) CM.settings.includeDLCAccess = value end,
        width = "half",
        default = true,
    })
end

-- =====================================================
-- EXTENDED CONTENT SECTIONS
-- =====================================================

function CM.Settings.Panel:AddExtendedSections(options)
    table.insert(options, {
        type = "header",
        name = "Extended Character Information",
        width = "full",
    })
    
    table.insert(options, {
        type = "description",
        text = "|c00FF00Core sections are enabled by default.|r Extended sections match a typical character profile. You can customize to add or remove sections as needed.",
        width = "full",
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Currency & Resources",
        tooltip = "Show gold, Alliance Points, Tel Var, Transmutes, Writs, Event Tickets, etc.\n(~500-800 chars)",
        getFunc = function() return CM.settings.includeCurrency end,
        setFunc = function(value) CM.settings.includeCurrency = value end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Progression Info",
        tooltip = "Show unspent skill/attribute points, achievement score, vampire/werewolf status, enlightenment\n(~300-500 chars)",
        getFunc = function() return CM.settings.includeProgression end,
        setFunc = function(value) CM.settings.includeProgression = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Riding Skills",
        tooltip = "Show riding speed, stamina, and capacity progress\n(~200-300 chars)",
        getFunc = function() return CM.settings.includeRidingSkills end,
        setFunc = function(value) CM.settings.includeRidingSkills = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Inventory Space",
        tooltip = "Show backpack and bank space usage\n(~150-200 chars)",
        getFunc = function() return CM.settings.includeInventory end,
        setFunc = function(value) CM.settings.includeInventory = value end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include PvP Information",
        tooltip = "Show Alliance War rank and current campaign\n(~150-200 chars)",
        getFunc = function() return CM.settings.includePvP end,
        setFunc = function(value) CM.settings.includePvP = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Role",
        tooltip = "Show selected role (Tank/Healer/DPS) in overview",
        getFunc = function() return CM.settings.includeRole end,
        setFunc = function(value) CM.settings.includeRole = value end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Current Location",
        tooltip = "Show current zone/location in overview\n(Minimal size impact)",
        getFunc = function() return CM.settings.includeLocation end,
        setFunc = function(value) CM.settings.includeLocation = value end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Collectibles",
        tooltip = "Show counts for mounts, pets, costumes, and houses owned\n(~200-300 chars)",
        getFunc = function() return CM.settings.includeCollectibles end,
        setFunc = function(value) CM.settings.includeCollectibles = value end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Crafting Knowledge",
        tooltip = "Show known motifs and active research slots\n(~150-200 chars)",
        getFunc = function() return CM.settings.includeCrafting end,
        setFunc = function(value) CM.settings.includeCrafting = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Achievement Tracking",
        tooltip = "Show detailed achievement progress, categories, and completion status (Phase 5).",
        getFunc = function() return CM.settings.includeAchievements end,
        setFunc = function(value) CM.settings.includeAchievements = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "  ↳ Detailed Achievement Categories",
        tooltip = "Show achievement breakdown by categories (Combat, PvP, Exploration, Crafting, etc.) with progress tracking.",
        getFunc = function() return CM.settings.includeAchievementsDetailed end,
        setFunc = function(value) CM.settings.includeAchievementsDetailed = value end,
        disabled = function() return not CM.settings.includeAchievements end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "  ↳ Show All Achievements",
        tooltip = "Show all achievements. When disabled, shows only achievements that are currently in progress (have some progress but not completed). Useful for goal tracking when disabled.",
        getFunc = function() return CM.settings.showAllAchievements ~= false end,
        setFunc = function(value) CM.settings.showAllAchievements = value end,
        disabled = function() return not CM.settings.includeAchievements end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Quest Tracking",
        tooltip = "Show active quests, progress tracking, and quest categorization (Phase 6).",
        getFunc = function() return CM.settings.includeQuests end,
        setFunc = function(value) CM.settings.includeQuests = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "  ↳ Detailed Quest Categories",
        tooltip = "Show quest breakdown by categories (Main Story, Guild Quests, DLC Quests, etc.) with zone tracking.",
        getFunc = function() return CM.settings.includeQuestsDetailed end,
        setFunc = function(value) CM.settings.includeQuestsDetailed = value end,
        disabled = function() return not CM.settings.includeQuests end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "  ↳ Show All Quests",
        tooltip = "Show all quests. When disabled, shows only currently active quests. Useful for current objective tracking when disabled.",
        getFunc = function() return CM.settings.showAllQuests ~= false end,
        setFunc = function(value) CM.settings.showAllQuests = value end,
        disabled = function() return not CM.settings.includeQuests end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Equipment Enhancement",
        tooltip = "Show equipment analysis, optimization suggestions, and upgrade tracking (Phase 7).",
        getFunc = function() return CM.settings.includeEquipmentEnhancement end,
        setFunc = function(value) CM.settings.includeEquipmentEnhancement = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "  ↳ Detailed Equipment Analysis",
        tooltip = "Show detailed equipment analysis including set bonuses, quality upgrades, and enchantment analysis.",
        getFunc = function() return CM.settings.includeEquipmentAnalysis end,
        setFunc = function(value) CM.settings.includeEquipmentAnalysis = value end,
        disabled = function() return not CM.settings.includeEquipmentEnhancement end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "  ↳ Optimization Recommendations",
        tooltip = "Show equipment optimization recommendations and upgrade suggestions.",
        getFunc = function() return CM.settings.includeEquipmentRecommendations end,
        setFunc = function(value) CM.settings.includeEquipmentRecommendations = value end,
        disabled = function() return not CM.settings.includeEquipmentEnhancement end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include World Progress",
        tooltip = "Show lorebook collection, zone completion, and world exploration progress.",
        getFunc = function() return CM.settings.includeWorldProgress end,
        setFunc = function(value) CM.settings.includeWorldProgress = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Titles & Housing",
        tooltip = "Show character titles and owned houses.",
        getFunc = function() return CM.settings.includeTitlesHousing end,
        setFunc = function(value) CM.settings.includeTitlesHousing = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include PvP Statistics",
        tooltip = "Show detailed PvP statistics and achievements.",
        getFunc = function() return CM.settings.includePvPStats end,
        setFunc = function(value) CM.settings.includePvPStats = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Armory Builds",
        tooltip = "Show saved armory builds and configurations.",
        getFunc = function() return CM.settings.includeArmoryBuilds end,
        setFunc = function(value) CM.settings.includeArmoryBuilds = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Tales of Tribute",
        tooltip = "Show Tales of Tribute progress and deck information.",
        getFunc = function() return CM.settings.includeTalesOfTribute end,
        setFunc = function(value) CM.settings.includeTalesOfTribute = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Undaunted Pledges",
        tooltip = "Show active Undaunted pledges from quest journal.",
        getFunc = function() return CM.settings.includeUndauntedPledges end,
        setFunc = function(value) CM.settings.includeUndauntedPledges = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Guild Membership",
        tooltip = "Show guild membership information including guild names, member counts, and your rank.",
        getFunc = function() return CM.settings.includeGuilds end,
        setFunc = function(value) CM.settings.includeGuilds = value end,
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
        getFunc = function() return CM.settings.enableAbilityLinks end,
        setFunc = function(value) 
            CM.settings.enableAbilityLinks = value
            CM.settings.enableSetLinks = value
        end,
        width = "full",
        default = true,
    })
end

-- =====================================================
-- SKILL FILTERS
-- =====================================================

function CM.Settings.Panel:AddSkillFilters(options)
    table.insert(options, {
        type = "header",
        name = "Skill Progression Filters",
        width = "full",
    })
    
    table.insert(options, {
        type = "slider",
        name = "Minimum Skill Rank",
        tooltip = "Show skills at this rank or higher (filters out lower rank skills to reduce clutter)",
        min = 1,
        max = 50,
        step = 1,
        getFunc = function() return CM.settings.minSkillRank end,
        setFunc = function(value) CM.settings.minSkillRank = value end,
        width = "half",
        default = 1,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Show Maxed Skills",
        tooltip = "Show maxed (fully leveled) skills. When disabled, only shows skills that are still progressing.",
        getFunc = function() return CM.settings.showMaxedSkills ~= false end,
        setFunc = function(value) CM.settings.showMaxedSkills = value end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Show All Riding Skills",
        tooltip = "Show all riding skills. When disabled, only shows skills that are not maxed (still need training).",
        getFunc = function() return CM.settings.showAllRidingSkills ~= false end,
        setFunc = function(value) CM.settings.showAllRidingSkills = value end,
        width = "half",
        default = true,
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
        getFunc = function() return CM.settings.includeBuildNotes end,
        setFunc = function(value) CM.settings.includeBuildNotes = value end,
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
            
            -- CRITICAL: Always save to both CM.charData AND CharacterMarkdownData
            -- LibAddonMenu may call setFunc multiple times during UI lifecycle, but we need to persist every change
            local currentValue = CM.charData.customTitle or ""
            
            -- Update CM.charData first (this is the active reference)
            CM.charData.customTitle = newValue
            CM.charData._lastModified = GetTimeStamp()
            
            -- Then ALWAYS update CharacterMarkdownData (this is the SavedVariables that persists)
            -- This ensures data persists even if CM.charData gets reset
            if CharacterMarkdownData then
                CharacterMarkdownData.customTitle = newValue
                CharacterMarkdownData._lastModified = GetTimeStamp()
            else
                CM.Warn("CharacterMarkdownData not available - custom title may not persist!")
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
            
            -- CRITICAL: Always save to both CM.charData AND CharacterMarkdownData
            -- LibAddonMenu may call setFunc multiple times during UI lifecycle, but we need to persist every change
            local currentValue = CM.charData.customNotes or ""
            
            -- Update CM.charData first (this is the active reference)
            CM.charData.customNotes = newValue
            CM.charData._lastModified = GetTimeStamp()
            
            -- Then ALWAYS update CharacterMarkdownData (this is the SavedVariables that persists)
            -- This ensures data persists even if CM.charData gets reset
            if CharacterMarkdownData then
                CharacterMarkdownData.customNotes = newValue
                CharacterMarkdownData._lastModified = GetTimeStamp()
            else
                CM.Warn("CharacterMarkdownData not available - notes may not persist!")
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
-- EQUIPMENT FILTERS
-- =====================================================

function CM.Settings.Panel:AddEquipmentFilters(options)
    table.insert(options, {
        type = "header",
        name = "Equipment Filters",
        width = "full",
    })
    
    table.insert(options, {
        type = "dropdown",
        name = "Minimum Equipment Quality",
        tooltip = "Show items of this quality or higher (filters out lower quality items)",
        choices = {"All", "Green", "Blue", "Purple", "Gold"},
        choicesValues = {0, 2, 3, 4, 5},
        getFunc = function() return CM.settings.minEquipQuality end,
        setFunc = function(value) CM.settings.minEquipQuality = value end,
        width = "half",
        default = 0,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Hide Empty Slots",
        tooltip = "Don't show equipment slots with no item equipped",
        getFunc = function() return CM.settings.hideEmptySlots end,
        setFunc = function(value) CM.settings.hideEmptySlots = value end,
        width = "half",
        default = false,
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
                d("[CharacterMarkdown] ❌ Command not available - try /reloadui")
            end
        end,
        width = "half",
    })
    
    table.insert(options, {
        type = "button",
        name = "Enable All Sections",
        tooltip = "Turn on all content sections (Champion Points, Equipment, Currency, etc.)",
        func = function()
            -- Core sections
            CM.settings.includeChampionPoints = true
            -- CM.settings.includeChampionDiagram = true  -- Keep disabled (experimental)
            CM.settings.includeChampionDetailed = true  -- Enable detailed CP analysis
            CM.settings.includeSkillBars = true
            CM.settings.includeSkills = true
            CM.settings.includeSkillMorphs = true  -- Enable morphs when enabling all
            CM.settings.includeEquipment = true
            CM.settings.includeCompanion = true
            CM.settings.includeCombatStats = true
            CM.settings.includeBuffs = true
            CM.settings.includeAttributes = true
            CM.settings.includeRole = true
            CM.settings.includeLocation = true
            CM.settings.includeBuildNotes = true
            CM.settings.includeQuickStats = true  -- Explicitly enable (defaults to true but explicit for clarity)
            CM.settings.includeAttentionNeeded = true  -- Explicitly enable (defaults to true but explicit for clarity)
            
            -- Extended sections
            CM.settings.includeDLCAccess = true
            CM.settings.includeCurrency = true
            CM.settings.includeProgression = true
            CM.settings.includeRidingSkills = true
            CM.settings.includeInventory = true
            CM.settings.includePvP = true
            CM.settings.includeCollectibles = true
            CM.settings.includeCollectiblesDetailed = false  -- Optional: enable for full detail
            CM.settings.includeCrafting = true
            CM.settings.includeAchievements = true  -- Enable achievement tracking
            CM.settings.includeAchievementsDetailed = true  -- Enable detailed achievements
            CM.settings.showAllAchievements = true  -- Show all achievements
            CM.settings.includeQuests = true  -- Enable quest tracking
            CM.settings.includeQuestsDetailed = true  -- Enable detailed quest categories
            CM.settings.showAllQuests = true  -- Show all quests
            CM.settings.includeEquipmentEnhancement = true  -- Enable equipment analysis
            CM.settings.includeEquipmentAnalysis = true  -- Enable detailed equipment analysis
            CM.settings.includeEquipmentRecommendations = true  -- Enable optimization recommendations
            CM.settings.includeWorldProgress = true  -- Enable world progress tracking
            CM.settings.includeTitlesHousing = true  -- Enable titles and housing
            CM.settings.includePvPStats = true  -- Enable PvP statistics
            CM.settings.includeArmoryBuilds = true  -- Enable armory builds
            CM.settings.includeTalesOfTribute = true  -- Enable Tales of Tribute
            CM.settings.includeUndauntedPledges = true  -- Enable Undaunted pledges
            CM.settings.includeGuilds = true  -- Enable guild membership
            
            -- Note: includeQuickStats and includeAttentionNeeded are controlled by format (non-Discord only)
            -- They default to true and don't need explicit enabling here
            
            -- Links
            CM.settings.enableAbilityLinks = true
            CM.settings.enableSetLinks = true
            
            CM.Info("All sections enabled!")
            SCENE_MANAGER:Show("gameMenuInGame")  -- Refresh UI
        end,
        width = "half",
    })
    
    table.insert(options, {
        type = "button",
        name = "Reset All Settings",
        tooltip = "Restore all settings to default values",
        func = function()
            if CM.Settings.Initializer then
                CM.Settings.Initializer:ResetToDefaults()
                SCENE_MANAGER:Show("gameMenuInGame")
            end
        end,
        width = "half",
        warning = "This will reset all settings to defaults!",
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
end

-- Debug print (deferred until CM.DebugPrint is available)
if CM.DebugPrint then
    CM.DebugPrint("SETTINGS", "Panel module loaded (CraftStore pattern)")
end
