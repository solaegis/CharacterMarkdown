-- CharacterMarkdown v2.1.0 - Settings Panel
-- In-game addon settings configuration
-- Author: solaegis

local CharacterMarkdown_Settings = {}

-- Settings panel reference
local settingsPanel = nil

-- =====================================================
-- SETTINGS INITIALIZATION
-- =====================================================

function CharacterMarkdown_Settings:Initialize()
    -- Wait for LibAddonMenu to be available
    if not LibAddonMenu2 then
        d("[CharacterMarkdown] LibAddonMenu2 not found, settings panel unavailable")
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
    
    settingsPanel = LAM:RegisterAddonPanel("CharacterMarkdownSettings", panelData)
    
    -- Initialize default settings
    -- Core build info defaults to TRUE, account/progression info defaults to FALSE to reduce size
    CharacterMarkdownSettings.currentFormat = CharacterMarkdownSettings.currentFormat or "github"
    
    -- Core build sections (DEFAULT: ENABLED)
    CharacterMarkdownSettings.includeChampionPoints = CharacterMarkdownSettings.includeChampionPoints ~= false
    CharacterMarkdownSettings.includeSkills = CharacterMarkdownSettings.includeSkills ~= false
    CharacterMarkdownSettings.includeEquipment = CharacterMarkdownSettings.includeEquipment ~= false
    CharacterMarkdownSettings.includeCompanion = CharacterMarkdownSettings.includeCompanion ~= false
    CharacterMarkdownSettings.includeCombatStats = CharacterMarkdownSettings.includeCombatStats ~= false
    CharacterMarkdownSettings.includeBuffs = CharacterMarkdownSettings.includeBuffs ~= false
    CharacterMarkdownSettings.includeAttributes = CharacterMarkdownSettings.includeAttributes ~= false
    CharacterMarkdownSettings.includeRole = CharacterMarkdownSettings.includeRole ~= false
    CharacterMarkdownSettings.includeLocation = CharacterMarkdownSettings.includeLocation ~= false
    
    -- Extended info sections (DEFAULT: ENABLED)
    CharacterMarkdownSettings.includeDLCAccess = CharacterMarkdownSettings.includeDLCAccess ~= false
    CharacterMarkdownSettings.includeCurrency = CharacterMarkdownSettings.includeCurrency ~= false
    CharacterMarkdownSettings.includeProgression = CharacterMarkdownSettings.includeProgression ~= false
    CharacterMarkdownSettings.includeRidingSkills = CharacterMarkdownSettings.includeRidingSkills ~= false
    CharacterMarkdownSettings.includeInventory = CharacterMarkdownSettings.includeInventory ~= false
    CharacterMarkdownSettings.includePvP = CharacterMarkdownSettings.includePvP ~= false
    CharacterMarkdownSettings.includeCollectibles = CharacterMarkdownSettings.includeCollectibles ~= false
    CharacterMarkdownSettings.includeCrafting = CharacterMarkdownSettings.includeCrafting ~= false
    CharacterMarkdownSettings.enableAbilityLinks = CharacterMarkdownSettings.enableAbilityLinks ~= false
    CharacterMarkdownSettings.enableSetLinks = CharacterMarkdownSettings.enableSetLinks ~= false
    CharacterMarkdownSettings.minSkillRank = CharacterMarkdownSettings.minSkillRank or 1
    CharacterMarkdownSettings.hideMaxedSkills = CharacterMarkdownSettings.hideMaxedSkills or false
    CharacterMarkdownSettings.minEquipQuality = CharacterMarkdownSettings.minEquipQuality or 0
    CharacterMarkdownSettings.hideEmptySlots = CharacterMarkdownSettings.hideEmptySlots or false
    
    -- Initialize per-character data (custom notes)
    CharacterMarkdownData = CharacterMarkdownData or {}
    CharacterMarkdownData.customNotes = CharacterMarkdownData.customNotes or ""
    
    -- Options data
    local optionsData = {
        -- ===== FORMAT SETTINGS =====
        {
            type = "header",
            name = "Output Format",
            width = "full",
        },
        {
            type = "dropdown",
            name = "Default Format",
            tooltip = "Select the default output format for /markdown command",
            choices = {"GitHub", "VS Code", "Discord", "Quick Summary"},
            choicesValues = {"github", "vscode", "discord", "quick"},
            getFunc = function() return CharacterMarkdownSettings.currentFormat end,
            setFunc = function(value)
                CharacterMarkdownSettings.currentFormat = value
                if CharacterMarkdown then CharacterMarkdown.currentFormat = value end
            end,
            width = "full",
            default = "github",
        },
        {
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
        },
        
        -- ===== CORE CONTENT SECTIONS =====
        {
            type = "header",
            name = "Core Content Sections",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Include Champion Points",
            tooltip = "Show Champion Point allocation and discipline breakdown",
            getFunc = function() return CharacterMarkdownSettings.includeChampionPoints end,
            setFunc = function(value) CharacterMarkdownSettings.includeChampionPoints = value end,
            width = "half",
            default = true,
        },
        {
            type = "checkbox",
            name = "Include Skill Progression",
            tooltip = "Show skill line ranks and progress",
            getFunc = function() return CharacterMarkdownSettings.includeSkills end,
            setFunc = function(value) CharacterMarkdownSettings.includeSkills = value end,
            width = "half",
            default = true,
        },
        {
            type = "checkbox",
            name = "Include Equipment",
            tooltip = "Show equipped items and armor sets",
            getFunc = function() return CharacterMarkdownSettings.includeEquipment end,
            setFunc = function(value) CharacterMarkdownSettings.includeEquipment = value end,
            width = "half",
            default = true,
        },
        {
            type = "checkbox",
            name = "Include Combat Statistics",
            tooltip = "Show health, resources, weapon/spell power, resistances",
            getFunc = function() return CharacterMarkdownSettings.includeCombatStats end,
            setFunc = function(value) CharacterMarkdownSettings.includeCombatStats = value end,
            width = "half",
            default = true,
        },
        {
            type = "checkbox",
            name = "Include Companion Info",
            tooltip = "Show active companion details (if summoned)",
            getFunc = function() return CharacterMarkdownSettings.includeCompanion end,
            setFunc = function(value) CharacterMarkdownSettings.includeCompanion = value end,
            width = "half",
            default = true,
        },
        {
            type = "checkbox",
            name = "Include Active Buffs",
            tooltip = "Show food, potions, and other active buffs",
            getFunc = function() return CharacterMarkdownSettings.includeBuffs end,
            setFunc = function(value) CharacterMarkdownSettings.includeBuffs = value end,
            width = "half",
            default = true,
        },
        {
            type = "checkbox",
            name = "Include Attribute Distribution",
            tooltip = "Show magicka/health/stamina attribute points",
            getFunc = function() return CharacterMarkdownSettings.includeAttributes end,
            setFunc = function(value) CharacterMarkdownSettings.includeAttributes = value end,
            width = "half",
            default = true,
        },
        {
            type = "checkbox",
            name = "Include DLC/Chapter Access",
            tooltip = "Show which DLCs and Chapters are accessible\n(~400-600 chars - large section)",
            getFunc = function() return CharacterMarkdownSettings.includeDLCAccess end,
            setFunc = function(value) CharacterMarkdownSettings.includeDLCAccess = value end,
            width = "half",
            default = true,
        },
        
        -- ===== NEW EXTENDED CONTENT =====
        {
            type = "header",
            name = "Extended Character Information",
            width = "full",
        },
        {
            type = "description",
            text = "|c00FF00All sections are enabled by default.|r You can disable sections you don't need to reduce profile size.",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Include Currency & Resources",
            tooltip = "Show gold, Alliance Points, Tel Var, Transmutes, Writs, Event Tickets, etc.\n(~500-800 chars)",
            getFunc = function() return CharacterMarkdownSettings.includeCurrency end,
            setFunc = function(value) CharacterMarkdownSettings.includeCurrency = value end,
            width = "half",
            default = true,
        },
        {
            type = "checkbox",
            name = "Include Progression Info",
            tooltip = "Show unspent skill/attribute points, achievement score, vampire/werewolf status, enlightenment\n(~300-500 chars)",
            getFunc = function() return CharacterMarkdownSettings.includeProgression end,
            setFunc = function(value) CharacterMarkdownSettings.includeProgression = value end,
            width = "half",
            default = true,
        },
        {
            type = "checkbox",
            name = "Include Riding Skills",
            tooltip = "Show riding speed, stamina, and capacity progress\n(~200-300 chars)",
            getFunc = function() return CharacterMarkdownSettings.includeRidingSkills end,
            setFunc = function(value) CharacterMarkdownSettings.includeRidingSkills = value end,
            width = "half",
            default = true,
        },
        {
            type = "checkbox",
            name = "Include Inventory Space",
            tooltip = "Show backpack and bank space usage\n(~150-200 chars)",
            getFunc = function() return CharacterMarkdownSettings.includeInventory end,
            setFunc = function(value) CharacterMarkdownSettings.includeInventory = value end,
            width = "half",
            default = true,
        },
        {
            type = "checkbox",
            name = "Include PvP Information",
            tooltip = "Show Alliance War rank and current campaign\n(~150-200 chars)",
            getFunc = function() return CharacterMarkdownSettings.includePvP end,
            setFunc = function(value) CharacterMarkdownSettings.includePvP = value end,
            width = "half",
            default = true,
        },
        {
            type = "checkbox",
            name = "Include Role",
            tooltip = "Show selected role (Tank/Healer/DPS) in overview",
            getFunc = function() return CharacterMarkdownSettings.includeRole end,
            setFunc = function(value) CharacterMarkdownSettings.includeRole = value end,
            width = "half",
            default = true,
        },
        {
            type = "checkbox",
            name = "Include Current Location",
            tooltip = "Show current zone/location in overview\n(Minimal size impact)",
            getFunc = function() return CharacterMarkdownSettings.includeLocation end,
            setFunc = function(value) CharacterMarkdownSettings.includeLocation = value end,
            width = "half",
            default = true,
        },
        {
            type = "checkbox",
            name = "Include Collectibles",
            tooltip = "Show counts for mounts, pets, costumes, and houses owned\n(~200-300 chars)",
            getFunc = function() return CharacterMarkdownSettings.includeCollectibles end,
            setFunc = function(value) CharacterMarkdownSettings.includeCollectibles = value end,
            width = "half",
            default = true,
        },
        {
            type = "checkbox",
            name = "Include Crafting Knowledge",
            tooltip = "Show known motifs and active research slots\n(~150-200 chars)",
            getFunc = function() return CharacterMarkdownSettings.includeCrafting end,
            setFunc = function(value) CharacterMarkdownSettings.includeCrafting = value end,
            width = "half",
            default = true,
        },
        
        -- ===== LINK SETTINGS =====
        {
            type = "header",
            name = "External Links (GitHub format only)",
            width = "full",
        },
        {
            type = "description",
            text = "Enable clickable UESP wiki links for game elements. All links respect the same toggle below.",
            width = "full",
        },
        {
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
        },
        
        -- ===== SKILL FILTERS =====
        {
            type = "header",
            name = "Skill Progression Filters",
            width = "full",
        },
        {
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
        },
        {
            type = "checkbox",
            name = "Hide Maxed Skills",
            tooltip = "Only show skills that are still progressing",
            getFunc = function() return CharacterMarkdownSettings.hideMaxedSkills end,
            setFunc = function(value) CharacterMarkdownSettings.hideMaxedSkills = value end,
            width = "half",
            default = true,
        },
        
        -- ===== CUSTOM NOTES =====
        {
            type = "header",
            name = "Custom Notes",
            width = "full",
        },
        {
            type = "editbox",
            name = "Build Notes",
            tooltip = "Add custom notes (rotation, parse data, build description, etc.)\nNotes are saved per-character and persist between sessions.",
            getFunc = function() return CharacterMarkdownData.customNotes end,
            setFunc = function(value) CharacterMarkdownData.customNotes = value end,
            width = "full",
            isMultiline = true,
            default = "",
        },
        
        -- ===== EQUIPMENT FILTERS =====
        {
            type = "header",
            name = "Equipment Filters",
            width = "full",
        },
        {
            type = "dropdown",
            name = "Minimum Equipment Quality",
            tooltip = "Only show items of this quality or higher",
            choices = {"All", "Green", "Blue", "Purple", "Gold"},
            choicesValues = {0, 2, 3, 4, 5},
            getFunc = function() return CharacterMarkdownSettings.minEquipQuality end,
            setFunc = function(value) CharacterMarkdownSettings.minEquipQuality = value end,
            width = "half",
            default = 0,
        },
        {
            type = "checkbox",
            name = "Hide Empty Slots",
            tooltip = "Don't show equipment slots with no item equipped",
            getFunc = function() return CharacterMarkdownSettings.hideEmptySlots end,
            setFunc = function(value) CharacterMarkdownSettings.hideEmptySlots = value end,
            width = "half",
            default = true,
        },
        
        -- ===== ACTIONS =====
        {
            type = "header",
            name = "Actions",
            width = "full",
        },
        {
            type = "button",
            name = "Generate Profile Now",
            tooltip = "Open the copy window with current settings",
            func = function()
                if CharacterMarkdown and CharacterMarkdown.CommandHandler then
                    CharacterMarkdown.CommandHandler("")
                end
            end,
            width = "half",
        },
        {
            type = "button",
            name = "Reset All Settings",
            tooltip = "Restore all settings to default values",
            func = function()
                CharacterMarkdownSettings.currentFormat = "github"
                CharacterMarkdownSettings.includeChampionPoints = true
                CharacterMarkdownSettings.includeSkills = true
                CharacterMarkdownSettings.includeEquipment = true
                CharacterMarkdownSettings.includeCompanion = true
                CharacterMarkdownSettings.includeCombatStats = true
                CharacterMarkdownSettings.includeBuffs = true
                CharacterMarkdownSettings.includeAttributes = true
                CharacterMarkdownSettings.includeDLCAccess = false
                CharacterMarkdownSettings.includeCurrency = false
                CharacterMarkdownSettings.includeProgression = false
                CharacterMarkdownSettings.includeRidingSkills = false
                CharacterMarkdownSettings.includeInventory = false
                CharacterMarkdownSettings.includePvP = false
                CharacterMarkdownSettings.includeRole = true
                CharacterMarkdownSettings.includeLocation = true
                CharacterMarkdownSettings.includeCollectibles = false
                CharacterMarkdownSettings.includeCrafting = false
                CharacterMarkdownSettings.enableAbilityLinks = true
                CharacterMarkdownSettings.enableSetLinks = true
                CharacterMarkdownSettings.minSkillRank = 1
                CharacterMarkdownSettings.hideMaxedSkills = false
                CharacterMarkdownSettings.minEquipQuality = 0
                CharacterMarkdownSettings.hideEmptySlots = false
                CharacterMarkdownData.customNotes = ""
                d("[CharacterMarkdown] Settings reset to defaults")
                SCENE_MANAGER:Show("gameMenuInGame")
            end,
            width = "half",
            warning = "This will reset all settings to defaults!",
        },
    }
    
    LAM:RegisterOptionControls("CharacterMarkdownSettings", optionsData)
    
    d("[CharacterMarkdown] Settings panel registered")
    return true
end

-- Export
_G.CharacterMarkdown_Settings = CharacterMarkdown_Settings
