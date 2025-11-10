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
    
    LAM:RegisterAddonPanel("CharacterMarkdownPanel", panelData)
    
    -- Register options with proper getFunc/setFunc
    local optionsData = self:BuildOptionsData()
    LAM:RegisterOptionControls("CharacterMarkdownPanel", optionsData)
    
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
        getFunc = function() return CharacterMarkdownSettings.enableEnhancedVisuals end,
        setFunc = function(value) 
            CharacterMarkdownSettings.enableEnhancedVisuals = value
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
        local choices = {""}  -- Empty option for "no filter"
        local choicesValues = {""}
        
        -- Add user filters
        if CharacterMarkdownSettings and CharacterMarkdownSettings.filters then
            for name, _ in pairs(CharacterMarkdownSettings.filters) do
                table.insert(choices, name)
                table.insert(choicesValues, name)
            end
        end
        
        -- Add preset filters (exclude "None" and "All" which are removed)
        if CM.Settings.FilterManager and CM.Settings.FilterManager.FILTER_PRESETS then
            for name, _ in pairs(CM.Settings.FilterManager.FILTER_PRESETS) do
                -- Skip "None" and "All" as they're removed
                if name ~= "None" and name ~= "All" then
                    table.insert(choices, name .. " (Preset)")
                    table.insert(choicesValues, name)
                end
            end
        end
        
        return choices, choicesValues
    end
    
    -- Active filter dropdown
    local filterChoices, filterChoicesValues = GetFilterChoices()
    table.insert(options, {
        type = "dropdown",
        name = "Active Filter",
        tooltip = "Select an active filter to apply to your character data display. Empty means no filter is applied.",
        choices = filterChoices,
        choicesValues = filterChoicesValues,
        getFunc = function() return CharacterMarkdownSettings.activeFilter or "" end,
        setFunc = function(value)
            if value and value ~= "" then
                CM.Settings.FilterManager:ApplyFilter(value)
            else
                CharacterMarkdownSettings.activeFilter = ""
            end
        end,
        width = "full",
        default = "",
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
    -- Helper function to wrap setFunc and reset filter if active
    -- Must be defined first before it's used
    local function WrapSetFunc(originalSetFunc)
        return function(value)
            -- Reset filter if one is active
            if CM.Settings.FilterManager then
                CM.Settings.FilterManager:ResetIfFilterActive()
            end
            -- Call original setFunc
            if originalSetFunc then
                originalSetFunc(value)
            end
        end
    end
    
    table.insert(options, {
        type = "header",
        name = "Core Content Sections",
        width = "full",
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Champion Points",
        tooltip = "Show Champion Point allocation and discipline breakdown",
        getFunc = function() return CharacterMarkdownSettings.includeChampionPoints end,
        setFunc = WrapSetFunc(function(value) CharacterMarkdownSettings.includeChampionPoints = value end),
        width = "half",
        default = true,
    })
    
    -- CP Visual Diagram (Mermaid) - Enabled with pathfinder support
    table.insert(options, {
        type = "checkbox",
        name = "  ↳ Include CP Visual Diagram",
        tooltip = "Show a Mermaid diagram visualizing your invested Champion Points with prerequisite relationships (GitHub/VSCode only). Requires 'Include Champion Points' to be enabled. Uses cluster API to discover skill relationships.",
        getFunc = function() return CharacterMarkdownSettings.includeChampionDiagram end,
        setFunc = function(value) CharacterMarkdownSettings.includeChampionDiagram = value end,
        disabled = function() return not CharacterMarkdownSettings.includeChampionPoints end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "  ↳ Detailed CP Analysis",
        tooltip = "Show detailed Champion Point allocation analysis including slottable vs passive breakdown, investment levels, and optimization suggestions (Phase 4).",
        getFunc = function() return CharacterMarkdownSettings.includeChampionDetailed end,
        setFunc = function(value) CharacterMarkdownSettings.includeChampionDetailed = value end,
        disabled = function() return not CharacterMarkdownSettings.includeChampionPoints end,
        width = "half",
        default = false,
    })
    
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Skill Bars",
        tooltip = "Show front and back bar abilities with ultimates",
        getFunc = function() return CharacterMarkdownSettings.includeSkillBars end,
        setFunc = function(value) CharacterMarkdownSettings.includeSkillBars = value end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Skill Progression",
        tooltip = "Show skill line ranks and progress",
        getFunc = function() return CharacterMarkdownSettings.includeSkills end,
        setFunc = function(value) CharacterMarkdownSettings.includeSkills = value end,
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
        getFunc = function() return CharacterMarkdownSettings.includeSkillMorphs end,
        setFunc = function(value) CharacterMarkdownSettings.includeSkillMorphs = value end,
        disabled = function() return not CharacterMarkdownSettings.includeSkills end,
        width = "half",
        default = false,
    })
    
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
        name = "Include Combat Statistics",
        tooltip = "Show health, resources, weapon/spell power, resistances",
        getFunc = function() return CharacterMarkdownSettings.includeCombatStats end,
        setFunc = function(value) CharacterMarkdownSettings.includeCombatStats = value end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Companion Info",
        tooltip = "Show active companion details (if summoned)",
        getFunc = function() return CharacterMarkdownSettings.includeCompanion end,
        setFunc = function(value) CharacterMarkdownSettings.includeCompanion = value end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Active Buffs",
        tooltip = "Show food, potions, and other active buffs",
        getFunc = function() return CharacterMarkdownSettings.includeBuffs end,
        setFunc = function(value) CharacterMarkdownSettings.includeBuffs = value end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Attribute Distribution",
        tooltip = "Show magicka/health/stamina attribute points",
        getFunc = function() return CharacterMarkdownSettings.includeAttributes end,
        setFunc = function(value) CharacterMarkdownSettings.includeAttributes = value end,
        width = "half",
        default = true,
    })
    
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
        getFunc = function() return CharacterMarkdownSettings.includeCurrency end,
        setFunc = function(value) CharacterMarkdownSettings.includeCurrency = value end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Progression Info",
        tooltip = "Show unspent skill/attribute points, achievement score, vampire/werewolf status, enlightenment\n(~300-500 chars)",
        getFunc = function() return CharacterMarkdownSettings.includeProgression end,
        setFunc = function(value) CharacterMarkdownSettings.includeProgression = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Riding Skills",
        tooltip = "Show riding speed, stamina, and capacity progress\n(~200-300 chars)",
        getFunc = function() return CharacterMarkdownSettings.includeRidingSkills end,
        setFunc = function(value) CharacterMarkdownSettings.includeRidingSkills = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Inventory Space",
        tooltip = "Show backpack and bank space usage\n(~150-200 chars)",
        getFunc = function() return CharacterMarkdownSettings.includeInventory end,
        setFunc = function(value) CharacterMarkdownSettings.includeInventory = value end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include PvP Information",
        tooltip = "Show Alliance War rank and current campaign\n(~150-200 chars)",
        getFunc = function() return CharacterMarkdownSettings.includePvP end,
        setFunc = function(value) CharacterMarkdownSettings.includePvP = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Role",
        tooltip = "Show selected role (Tank/Healer/DPS) in overview",
        getFunc = function() return CharacterMarkdownSettings.includeRole end,
        setFunc = function(value) CharacterMarkdownSettings.includeRole = value end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Current Location",
        tooltip = "Show current zone/location in overview\n(Minimal size impact)",
        getFunc = function() return CharacterMarkdownSettings.includeLocation end,
        setFunc = function(value) CharacterMarkdownSettings.includeLocation = value end,
        width = "half",
        default = true,
    })
    
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
        name = "Include Crafting Knowledge",
        tooltip = "Show known motifs and active research slots\n(~150-200 chars)",
        getFunc = function() return CharacterMarkdownSettings.includeCrafting end,
        setFunc = function(value) CharacterMarkdownSettings.includeCrafting = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Achievement Tracking",
        tooltip = "Show detailed achievement progress, categories, and completion status (Phase 5).",
        getFunc = function() return CharacterMarkdownSettings.includeAchievements end,
        setFunc = function(value) CharacterMarkdownSettings.includeAchievements = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "  ↳ Detailed Achievement Categories",
        tooltip = "Show achievement breakdown by categories (Combat, PvP, Exploration, Crafting, etc.) with progress tracking.",
        getFunc = function() return CharacterMarkdownSettings.includeAchievementsDetailed end,
        setFunc = function(value) CharacterMarkdownSettings.includeAchievementsDetailed = value end,
        disabled = function() return not CharacterMarkdownSettings.includeAchievements end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "  ↳ Show All Achievements",
        tooltip = "Show all achievements. When disabled, shows only achievements that are currently in progress (have some progress but not completed). Useful for goal tracking when disabled.",
        getFunc = function() return CharacterMarkdownSettings.showAllAchievements ~= false end,
        setFunc = function(value) CharacterMarkdownSettings.showAllAchievements = value end,
        disabled = function() return not CharacterMarkdownSettings.includeAchievements end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Quest Tracking",
        tooltip = "Show active quests, progress tracking, and quest categorization (Phase 6).",
        getFunc = function() return CharacterMarkdownSettings.includeQuests end,
        setFunc = function(value) CharacterMarkdownSettings.includeQuests = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "  ↳ Detailed Quest Categories",
        tooltip = "Show quest breakdown by categories (Main Story, Guild Quests, DLC Quests, etc.) with zone tracking.",
        getFunc = function() return CharacterMarkdownSettings.includeQuestsDetailed end,
        setFunc = function(value) CharacterMarkdownSettings.includeQuestsDetailed = value end,
        disabled = function() return not CharacterMarkdownSettings.includeQuests end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "  ↳ Show All Quests",
        tooltip = "Show all quests. When disabled, shows only currently active quests. Useful for current objective tracking when disabled.",
        getFunc = function() return CharacterMarkdownSettings.showAllQuests ~= false end,
        setFunc = function(value) CharacterMarkdownSettings.showAllQuests = value end,
        disabled = function() return not CharacterMarkdownSettings.includeQuests end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Equipment Enhancement",
        tooltip = "Show equipment analysis, optimization suggestions, and upgrade tracking (Phase 7).",
        getFunc = function() return CharacterMarkdownSettings.includeEquipmentEnhancement end,
        setFunc = function(value) CharacterMarkdownSettings.includeEquipmentEnhancement = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "  ↳ Detailed Equipment Analysis",
        tooltip = "Show detailed equipment analysis including set bonuses, quality upgrades, and enchantment analysis.",
        getFunc = function() return CharacterMarkdownSettings.includeEquipmentAnalysis end,
        setFunc = function(value) CharacterMarkdownSettings.includeEquipmentAnalysis = value end,
        disabled = function() return not CharacterMarkdownSettings.includeEquipmentEnhancement end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "  ↳ Optimization Recommendations",
        tooltip = "Show equipment optimization recommendations and upgrade suggestions.",
        getFunc = function() return CharacterMarkdownSettings.includeEquipmentRecommendations end,
        setFunc = function(value) CharacterMarkdownSettings.includeEquipmentRecommendations = value end,
        disabled = function() return not CharacterMarkdownSettings.includeEquipmentEnhancement end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include World Progress",
        tooltip = "Show lorebook collection, zone completion, and world exploration progress.",
        getFunc = function() return CharacterMarkdownSettings.includeWorldProgress end,
        setFunc = function(value) CharacterMarkdownSettings.includeWorldProgress = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Titles & Housing",
        tooltip = "Show character titles and owned houses.",
        getFunc = function() return CharacterMarkdownSettings.includeTitlesHousing end,
        setFunc = function(value) CharacterMarkdownSettings.includeTitlesHousing = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include PvP Statistics",
        tooltip = "Show detailed PvP statistics and achievements.",
        getFunc = function() return CharacterMarkdownSettings.includePvPStats end,
        setFunc = function(value) CharacterMarkdownSettings.includePvPStats = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Armory Builds",
        tooltip = "Show saved armory builds and configurations.",
        getFunc = function() return CharacterMarkdownSettings.includeArmoryBuilds end,
        setFunc = function(value) CharacterMarkdownSettings.includeArmoryBuilds = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Tales of Tribute",
        tooltip = "Show Tales of Tribute progress and deck information.",
        getFunc = function() return CharacterMarkdownSettings.includeTalesOfTribute end,
        setFunc = function(value) CharacterMarkdownSettings.includeTalesOfTribute = value end,
        width = "half",
        default = false,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Undaunted Pledges",
        tooltip = "Show active Undaunted pledges from quest journal.",
        getFunc = function() return CharacterMarkdownSettings.includeUndauntedPledges end,
        setFunc = function(value) CharacterMarkdownSettings.includeUndauntedPledges = value end,
        width = "half",
        default = false,
    })
    
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
        getFunc = function() return CharacterMarkdownSettings.minSkillRank end,
        setFunc = function(value) CharacterMarkdownSettings.minSkillRank = value end,
        width = "half",
        default = 1,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Show Maxed Skills",
        tooltip = "Show maxed (fully leveled) skills. When disabled, only shows skills that are still progressing.",
        getFunc = function() return CharacterMarkdownSettings.showMaxedSkills ~= false end,
        setFunc = function(value) CharacterMarkdownSettings.showMaxedSkills = value end,
        width = "half",
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Show All Riding Skills",
        tooltip = "Show all riding skills. When disabled, only shows skills that are not maxed (still need training).",
        getFunc = function() return CharacterMarkdownSettings.showAllRidingSkills ~= false end,
        setFunc = function(value) CharacterMarkdownSettings.showAllRidingSkills = value end,
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
        getFunc = function() return CharacterMarkdownSettings.minEquipQuality end,
        setFunc = function(value) CharacterMarkdownSettings.minEquipQuality = value end,
        width = "half",
        default = 0,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Hide Empty Slots",
        tooltip = "Don't show equipment slots with no item equipped",
        getFunc = function() return CharacterMarkdownSettings.hideEmptySlots end,
        setFunc = function(value) CharacterMarkdownSettings.hideEmptySlots = value end,
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
    
    -- Helper function to check if any sections are enabled
    local function AreAnySectionsEnabled()
        return CharacterMarkdownSettings.includeChampionPoints or
               CharacterMarkdownSettings.includeChampionDiagram or
               CharacterMarkdownSettings.includeChampionDetailed or
               CharacterMarkdownSettings.includeChampionConstellationTable or
               CharacterMarkdownSettings.includeChampionPointStarTables or
               CharacterMarkdownSettings.includeSkillBars or
               CharacterMarkdownSettings.includeSkillBars or
               CharacterMarkdownSettings.includeSkillMorphs or
               CharacterMarkdownSettings.includeEquipment or
               CharacterMarkdownSettings.includeCompanion or
               CharacterMarkdownSettings.includeCombatStats or
               CharacterMarkdownSettings.includeBuffs or
               CharacterMarkdownSettings.includeAttributes or
               CharacterMarkdownSettings.includeDLCAccess or
               CharacterMarkdownSettings.includeRole or
               CharacterMarkdownSettings.includeLocation or
               CharacterMarkdownSettings.includeQuickStats or
               CharacterMarkdownSettings.includeAttentionNeeded or
               CharacterMarkdownSettings.includeTableOfContents or
               CharacterMarkdownSettings.includeCurrency or
               CharacterMarkdownSettings.includeProgression or
               CharacterMarkdownSettings.includeRidingSkills or
               CharacterMarkdownSettings.includeInventory or
               CharacterMarkdownSettings.includePvP or
               CharacterMarkdownSettings.includeCollectibles or
               CharacterMarkdownSettings.includeCollectiblesDetailed or
               CharacterMarkdownSettings.includeCrafting or
               CharacterMarkdownSettings.includeAchievements or
               CharacterMarkdownSettings.includeAchievementsDetailed or
               CharacterMarkdownSettings.showAllAchievements or
               CharacterMarkdownSettings.includeQuests or
               CharacterMarkdownSettings.includeQuestsDetailed or
               CharacterMarkdownSettings.showAllQuests or
               CharacterMarkdownSettings.includeEquipmentEnhancement or
               CharacterMarkdownSettings.includeEquipmentAnalysis or
               CharacterMarkdownSettings.includeEquipmentRecommendations or
               CharacterMarkdownSettings.includeWorldProgress or
               CharacterMarkdownSettings.includeTitlesHousing or
               CharacterMarkdownSettings.includePvPStats or
               CharacterMarkdownSettings.includeArmoryBuilds or
               CharacterMarkdownSettings.includeTalesOfTribute or
               CharacterMarkdownSettings.includeUndauntedPledges or
               CharacterMarkdownSettings.includeGuilds or
               CharacterMarkdownSettings.enableAbilityLinks or
               CharacterMarkdownSettings.enableSetLinks
    end
    
    -- Helper function to enable/disable all sections
    local function ToggleAllSections(enable)
        -- Reset filter if active
        if CM.Settings.FilterManager then
            CM.Settings.FilterManager:ResetIfFilterActive()
        end
        
        local value = enable == true
        -- Core sections
        CharacterMarkdownSettings.includeChampionPoints = value
        CharacterMarkdownSettings.includeChampionDiagram = value
        CharacterMarkdownSettings.includeChampionDetailed = value
        CharacterMarkdownSettings.includeChampionConstellationTable = value
        CharacterMarkdownSettings.includeChampionPointStarTables = value
        CharacterMarkdownSettings.includeSkillBars = value
        CharacterMarkdownSettings.includeSkills = value
        CharacterMarkdownSettings.includeSkillMorphs = value
        CharacterMarkdownSettings.includeEquipment = value
        CharacterMarkdownSettings.includeCompanion = value
        CharacterMarkdownSettings.includeCombatStats = value
        CharacterMarkdownSettings.includeBuffs = value
        CharacterMarkdownSettings.includeAttributes = value
        CharacterMarkdownSettings.includeDLCAccess = value
        CharacterMarkdownSettings.includeRole = value
        CharacterMarkdownSettings.includeLocation = value
        -- Note: includeBuildNotes is intentionally excluded - custom title and build notes
        -- text fields should remain visible and editable even when toggled off
        CharacterMarkdownSettings.includeQuickStats = value
        CharacterMarkdownSettings.includeAttentionNeeded = value
        CharacterMarkdownSettings.includeTableOfContents = value
        
        -- Extended sections
        CharacterMarkdownSettings.includeCurrency = value
        CharacterMarkdownSettings.includeProgression = value
        CharacterMarkdownSettings.includeRidingSkills = value
        CharacterMarkdownSettings.includeInventory = value
        CharacterMarkdownSettings.includePvP = value
        CharacterMarkdownSettings.includeCollectibles = value
        CharacterMarkdownSettings.includeCollectiblesDetailed = value
        CharacterMarkdownSettings.includeCrafting = value
        CharacterMarkdownSettings.includeAchievements = value
        CharacterMarkdownSettings.includeAchievementsDetailed = value
        CharacterMarkdownSettings.showAllAchievements = value
        CharacterMarkdownSettings.includeQuests = value
        CharacterMarkdownSettings.includeQuestsDetailed = value
        CharacterMarkdownSettings.showAllQuests = value
        CharacterMarkdownSettings.includeEquipmentEnhancement = value
        CharacterMarkdownSettings.includeEquipmentAnalysis = value
        CharacterMarkdownSettings.includeEquipmentRecommendations = value
        CharacterMarkdownSettings.includeWorldProgress = value
        CharacterMarkdownSettings.includeTitlesHousing = value
        CharacterMarkdownSettings.includePvPStats = value
        CharacterMarkdownSettings.includeArmoryBuilds = value
        CharacterMarkdownSettings.includeTalesOfTribute = value
        CharacterMarkdownSettings.includeUndauntedPledges = value
        CharacterMarkdownSettings.includeGuilds = value
        
        -- Links
        CharacterMarkdownSettings.enableAbilityLinks = value
        CharacterMarkdownSettings.enableSetLinks = value
        
        -- Quality filters
        if value then
            CharacterMarkdownSettings.minSkillRank = 0
            CharacterMarkdownSettings.showMaxedSkills = true
            CharacterMarkdownSettings.showAllRidingSkills = true
            CharacterMarkdownSettings.minEquipQuality = 0
            CharacterMarkdownSettings.hideEmptySlots = false
        else
            CharacterMarkdownSettings.minSkillRank = 999
            CharacterMarkdownSettings.showMaxedSkills = false
            CharacterMarkdownSettings.showAllRidingSkills = false
            CharacterMarkdownSettings.minEquipQuality = 999
            CharacterMarkdownSettings.hideEmptySlots = true
        end
        
        CharacterMarkdownSettings._lastModified = GetTimeStamp()
        CM.Info(value and "All sections enabled!" or "All sections disabled!")
    end
    
    -- Toggle button for Enable All / Disable All
    table.insert(options, {
        type = "button",
        name = function() return AreAnySectionsEnabled() and "Disable All Sections" or "Enable All Sections" end,
        tooltip = function() return AreAnySectionsEnabled() and "Turn off all content sections" or "Turn on all content sections (Champion Points, Equipment, Currency, etc.)" end,
        func = function()
            local shouldEnable = not AreAnySectionsEnabled()
            ToggleAllSections(shouldEnable)
            -- Note: Button name is a function, so it will update automatically when panel is next shown
            -- No need to manually refresh
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
    
    -- Support section
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
        name = "☕ Buy Me a Coffee",
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
