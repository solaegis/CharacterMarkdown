-- CharacterMarkdown v2.1.0 - Settings Panel
-- LibAddonMenu UI registration and panel controls
-- Author: solaegis

CharacterMarkdown = CharacterMarkdown or {}
CharacterMarkdown.Settings = CharacterMarkdown.Settings or {}
CharacterMarkdown.Settings.Panel = {}

-- =====================================================
-- PANEL REGISTRATION
-- =====================================================

function CharacterMarkdown.Settings.Panel:Initialize()
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
    
    local LAM = LibAddonMenu2
    
    -- Create settings panel
    local panelData = {
        type = "panel",
        name = "Character Markdown",
        displayName = "Character Markdown",
        author = "solaegis",
        version = "2.1.0",
        slashCommand = "/cmdsettings",
        registerForRefresh = true,
        registerForDefaults = true,
    }
    
    LAM:RegisterAddonPanel("CharacterMarkdownSettings", panelData)
    
    -- Register options
    local optionsData = self:BuildOptionsData()
    LAM:RegisterOptionControls("CharacterMarkdownSettings", optionsData)
    
    d("[CharacterMarkdown] Settings panel registered")
    return true
end

-- =====================================================
-- OPTIONS DATA BUILDER
-- =====================================================

function CharacterMarkdown.Settings.Panel:BuildOptionsData()
    local options = {}
    
    -- Add sections in order
    self:AddFormatSection(options)
    self:AddCoreSections(options)
    self:AddExtendedSections(options)
    self:AddLinkSettings(options)
    self:AddSkillFilters(options)
    self:AddCustomNotes(options)
    self:AddEquipmentFilters(options)
    self:AddActions(options)
    
    return options
end

-- =====================================================
-- FORMAT SETTINGS
-- =====================================================

function CharacterMarkdown.Settings.Panel:AddFormatSection(options)
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
        getFunc = function() return CharacterMarkdownSettings.currentFormat or "github" end,
        setFunc = function(value)
            CharacterMarkdownSettings.currentFormat = value
            if CharacterMarkdown then CharacterMarkdown.currentFormat = value end
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
-- CORE CONTENT SECTIONS
-- =====================================================

function CharacterMarkdown.Settings.Panel:AddCoreSections(options)
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
        setFunc = function(value) CharacterMarkdownSettings.includeChampionPoints = value end,
        width = "half",
        default = true,
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

function CharacterMarkdown.Settings.Panel:AddExtendedSections(options)
    table.insert(options, {
        type = "header",
        name = "Extended Character Information",
        width = "full",
    })
    
    table.insert(options, {
        type = "description",
        text = "|c00FF00All sections are enabled by default.|r You can disable sections you don't need to reduce profile size.",
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
        default = true,
    })
    
    table.insert(options, {
        type = "checkbox",
        name = "Include Riding Skills",
        tooltip = "Show riding speed, stamina, and capacity progress\n(~200-300 chars)",
        getFunc = function() return CharacterMarkdownSettings.includeRidingSkills end,
        setFunc = function(value) CharacterMarkdownSettings.includeRidingSkills = value end,
        width = "half",
        default = true,
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
        default = true,
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
        default = true,
    })
end

-- =====================================================
-- LINK SETTINGS
-- =====================================================

function CharacterMarkdown.Settings.Panel:AddLinkSettings(options)
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

function CharacterMarkdown.Settings.Panel:AddSkillFilters(options)
    table.insert(options, {
        type = "header",
        name = "Skill Progression Filters",
        width = "full",
    })
    
    table.insert(options, {
        type = "slider",
        name = "Minimum Skill Rank",
        tooltip = "Only show skills at this rank or higher (reduces clutter)",
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
        name = "Hide Maxed Skills",
        tooltip = "Only show skills that are still progressing",
        getFunc = function() return CharacterMarkdownSettings.hideMaxedSkills end,
        setFunc = function(value) CharacterMarkdownSettings.hideMaxedSkills = value end,
        width = "half",
        default = false,
    })
end

-- =====================================================
-- CUSTOM NOTES
-- =====================================================

function CharacterMarkdown.Settings.Panel:AddCustomNotes(options)
    table.insert(options, {
        type = "header",
        name = "Custom Notes",
        width = "full",
    })
    
    table.insert(options, {
        type = "editbox",
        name = "Build Notes",
        tooltip = "Add custom notes (rotation, parse data, build description, etc.)\nNotes are saved per-character and persist between sessions.",
        getFunc = function() return CharacterMarkdownData.customNotes end,
        setFunc = function(value) CharacterMarkdownData.customNotes = value end,
        width = "full",
        isMultiline = true,
        default = "",
    })
end

-- =====================================================
-- EQUIPMENT FILTERS
-- =====================================================

function CharacterMarkdown.Settings.Panel:AddEquipmentFilters(options)
    table.insert(options, {
        type = "header",
        name = "Equipment Filters",
        width = "full",
    })
    
    table.insert(options, {
        type = "dropdown",
        name = "Minimum Equipment Quality",
        tooltip = "Only show items of this quality or higher",
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

function CharacterMarkdown.Settings.Panel:AddActions(options)
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
            CharacterMarkdownSettings.includeChampionPoints = true
            CharacterMarkdownSettings.includeSkillBars = true
            CharacterMarkdownSettings.includeSkills = true
            CharacterMarkdownSettings.includeEquipment = true
            CharacterMarkdownSettings.includeCompanion = true
            CharacterMarkdownSettings.includeCombatStats = true
            CharacterMarkdownSettings.includeBuffs = true
            CharacterMarkdownSettings.includeAttributes = true
            CharacterMarkdownSettings.includeRole = true
            CharacterMarkdownSettings.includeLocation = true
            
            -- Extended sections
            CharacterMarkdownSettings.includeDLCAccess = true
            CharacterMarkdownSettings.includeCurrency = true
            CharacterMarkdownSettings.includeProgression = true
            CharacterMarkdownSettings.includeRidingSkills = true
            CharacterMarkdownSettings.includeInventory = true
            CharacterMarkdownSettings.includePvP = true
            CharacterMarkdownSettings.includeCollectibles = true
            CharacterMarkdownSettings.includeCrafting = true
            
            -- Links
            CharacterMarkdownSettings.enableAbilityLinks = true
            CharacterMarkdownSettings.enableSetLinks = true
            
            d("[CharacterMarkdown] ✅ All sections enabled!")
            SCENE_MANAGER:Show("gameMenuInGame")  -- Refresh UI
        end,
        width = "half",
    })
    
    table.insert(options, {
        type = "button",
        name = "Reset All Settings",
        tooltip = "Restore all settings to default values",
        func = function()
            if CharacterMarkdown.Settings.Initializer then
                CharacterMarkdown.Settings.Initializer:ResetToDefaults()
                SCENE_MANAGER:Show("gameMenuInGame")
            end
        end,
        width = "half",
        warning = "This will reset all settings to defaults!",
    })
end
