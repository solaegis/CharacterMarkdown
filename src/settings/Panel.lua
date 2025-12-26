-- CharacterMarkdown v@project-version@ - Settings Panel
-- LibAddonMenu UI registration and panel controls (FIXED)
-- Author: solaegis
-- Following CraftStore pattern for proper persistence

CharacterMarkdown = CharacterMarkdown or {}
CharacterMarkdown.Settings = CharacterMarkdown.Settings or {}
CharacterMarkdown.Settings.Panel = {}

local CM = CharacterMarkdown

-- =====================================================
-- HELPER: INVALIDATE CACHE ON SETTING CHANGE
-- =====================================================

-- Helper function to create a setFunc that invalidates cache
local function CreateSetFunc(settingName)
    return function(value)
        CharacterMarkdownSettings[settingName] = value
        CharacterMarkdownSettings._lastModified = GetTimeStamp()
        CM.InvalidateSettingsCache()
    end
end

-- =====================================================
-- PLAY STYLES LIST
-- =====================================================

-- Display names shown to users in dropdown
local PLAY_STYLES = {
    "", -- Empty option (default)
    "Crafter",
    "Healer",
    "Hybrid Build",
    "Magicka DPS",
    "Mule",
    "Off-Tank",
    "Parse DPS",
    "PvP Bomblade",
    "PvP Brawler",
    "PvP Ganker",
    "PvP Support",
    "Resource Farmer",
    "Solo Self-Sufficient",
    "Stamina DPS",
    "Support DPS",
    "Tank",
}

-- Internal values saved to SavedVariables (must match exactly)
local PLAY_STYLE_VALUES = {
    "", -- Empty option (default)
    "crafter",
    "healer",
    "hybrid_build",
    "magicka_dps",
    "mule",
    "off_tank",
    "parse_dps",
    "pvp_bomblade",
    "pvp_brawler",
    "pvp_ganker",
    "pvp_support",
    "resource_farmer",
    "solo_self_sufficient",
    "stamina_dps",
    "support_dps",
    "tank",
}

-- =====================================================
-- PANEL REGISTRATION
-- =====================================================

function CM.Settings.Panel:Initialize()
    -- Wait for LibAddonMenu to be available
    if not LibAddonMenu2 then
        CM.Warn("Settings panel unavailable - LibAddonMenu-2.0 is required for the settings UI")
        CM.Info("To install:")
        CM.Info("  1. Download from: https://www.esoui.com/downloads/info7-LibAddonMenu.html")
        CM.Info("  2. Extract to: Documents/Elder Scrolls Online/live/AddOns/")
        CM.Info("  3. Reload UI with /reloadui")
        CM.Info("The /markdown command still works without settings UI")
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

    -- Create settings panel
    -- NOTE: We do NOT pass defaults to LAM - we handle reset entirely in defaultsFunc
    -- This prevents LibAddonMenu from directly resetting SavedVariables and clearing perCharacterData
    local panelData = {
        type = "panel",
        name = "Character Markdown",
        displayName = "Character Markdown",
        author = "solaegis",
        version = CM.version,
        slashCommand = "/markdown_settings",
        registerForRefresh = true,
        registerForDefaults = true,
        -- CRITICAL: Custom defaults handler to preserve text fields (customNotes, customTitle, playStyle)
        -- LibAddonMenu will call this function when user clicks "Defaults" button
        -- We handle ALL reset logic here to ensure text fields are preserved
        defaultsFunc = function()
            CM.DebugPrint("SETTINGS", "Defaults button clicked - preserving text fields")

            -- CRITICAL: Preserve text fields BEFORE any reset happens
            -- Get current character ID
            local characterId = tostring(GetCurrentCharacterId())
            local preservedTextFields = nil

            -- Preserve text fields from current character
            if
                CharacterMarkdownSettings
                and CharacterMarkdownSettings.perCharacterData
                and CharacterMarkdownSettings.perCharacterData[characterId]
            then
                preservedTextFields = {
                    customNotes = CharacterMarkdownSettings.perCharacterData[characterId].customNotes or "",
                    customTitle = CharacterMarkdownSettings.perCharacterData[characterId].customTitle or "",
                    playStyle = CharacterMarkdownSettings.perCharacterData[characterId].playStyle or "",
                }
                CM.DebugPrint(
                    "SETTINGS",
                    string.format(
                        "Preserved text fields for character %s: notes=%d chars, title='%s', playStyle='%s'",
                        characterId,
                        string.len(preservedTextFields.customNotes or ""),
                        preservedTextFields.customTitle or "",
                        preservedTextFields.playStyle or ""
                    )
                )
            else
                CM.DebugPrint("SETTINGS", "No text fields to preserve for character " .. characterId)
            end

            -- Apply defaults manually to ensure text fields are preserved correctly
            -- We don't call ResetToDefaults() here because we've already preserved the text fields
            -- and want to ensure they're restored after the reset
            local defaults = CM.Settings and CM.Settings.Defaults and CM.Settings.Defaults:GetAll() or {}

            -- Apply defaults, excluding perCharacterData
            for key, value in pairs(defaults) do
                if key ~= "perCharacterData" and key:sub(1, 1) ~= "_" then
                    CharacterMarkdownSettings[key] = value
                end
            end

            -- Restore only the text fields for current character
            if preservedTextFields then
                if not CharacterMarkdownSettings.perCharacterData then
                    CharacterMarkdownSettings.perCharacterData = {}
                end
                if not CharacterMarkdownSettings.perCharacterData[characterId] then
                    CharacterMarkdownSettings.perCharacterData[characterId] = {}
                end
                CharacterMarkdownSettings.perCharacterData[characterId].customNotes = preservedTextFields.customNotes
                CharacterMarkdownSettings.perCharacterData[characterId].customTitle = preservedTextFields.customTitle
                CharacterMarkdownSettings.perCharacterData[characterId].playStyle = preservedTextFields.playStyle
                CM.DebugPrint("SETTINGS", "Restored text fields after reset")
            end

            -- Update other reset-related fields
            CharacterMarkdownSettings.settingsVersion = 1
            CharacterMarkdownSettings.activeProfile = "Custom"
            CharacterMarkdownSettings._lastModified = GetTimeStamp()

            -- Sync formatter to core (REMOVED)
            -- if CharacterMarkdownSettings.currentFormatter then
            --     CM.currentFormatter = CharacterMarkdownSettings.currentFormatter
            -- end

            CM.InvalidateSettingsCache()
            CM.Info("Settings reset to defaults (text fields preserved)")

            -- CRITICAL: Force refresh the panel to update the UI with preserved values
            -- This ensures the text fields show the preserved values after reset
            zo_callLater(function()
                if LAM and self.panelId then
                    LAM:RefreshPanel(self.panelId)
                    CM.DebugPrint("SETTINGS", "Panel refreshed after defaults reset")
                end
            end, 100)
        end,
        website = "https://www.esoui.com/downloads/info4279-CharacterMarkdown.html",
        feedback = "https://www.esoui.com/downloads/info4279-CharacterMarkdown.html#comments",
        donation = "https://www.buymeacoffee.com/lewisvavasw",
        registerForRefresh = true,
    }

    self.panelId = "CharacterMarkdownPanel"
    LAM:RegisterAddonPanel(self.panelId, panelData)

    -- Register options with proper getFunc/setFunc
    local optionsData = self:BuildOptionsData()
    LAM:RegisterOptionControls(self.panelId, optionsData)

    -- Manually resize Build Notes editbox after controls are created
    -- LAM2 doesn't properly support the height parameter for editboxes
    local function ResizeBuildNotesEditbox()
        local editBox = _G["CharacterMarkdown_BuildNotesEditBox"]
        if editBox then
            -- Find the actual text input control (editbox is the container)
            local textControl = editBox.editbox or editBox
            if textControl and textControl.SetHeight then
                textControl:SetHeight(500)
                CM.DebugPrint("SETTINGS", "Build Notes editbox height set to 500px")
            end
        end
    end

    -- Try to resize immediately after registration
    zo_callLater(ResizeBuildNotesEditbox, 500)

    -- Also register callback for when panel is shown/refreshed
    -- Fix for crash in LAM.util.RegisterForRefreshIfNeeded (replaced with standard callback)
    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", function(panel)
        if panel and panel.data and panel.data.name == "Character Markdown" then
            ResizeBuildNotesEditbox()
        end
    end)

    CM.DebugPrint("SETTINGS", "Settings panel registered with LAM")

    return true
end

-- =====================================================
-- OPTIONS DATA BUILDER
-- =====================================================

function CM.Settings.Panel:BuildOptionsData()
    local options = {}

    -- Add sections organized by collector modules (bottom-up refactor)
    self:AddActions(options) -- FIRST: Quick actions and controls

    -- self:AddFormatterSection(options) -- REMOVED: Formatter selection removed
    self:AddCustomNotes(options) -- Character-Specific Settings

    self:AddLayoutSection(options) -- Layout options (Header/Footer/TOC)

    -- Collector-based sections (organized by collector module)
    self:AddCharacterSection(options) -- Character.lua collectors
    self:AddCombatSection(options) -- Combat.lua collectors
    self:AddChampionSection(options) -- Champion.lua collectors
    self:AddSkillsSection(options) -- Skills.lua collectors
    self:AddEquipmentSection(options) -- Equipment.lua collectors
    self:AddInventorySection(options) -- Inventory.lua collectors
    self:AddProgressionSection(options) -- Progression.lua collectors
    self:AddPvPSection(options) -- PvP.lua collectors
    self:AddCompanionSection(options) -- Companion.lua collectors
    self:AddCollectiblesSection(options) -- Collectibles.lua collectors
    self:AddAchievementsSection(options) -- Achievements.lua collectors
    self:AddAntiquitiesSection(options) -- Antiquities.lua collectors
    self:AddQuestsSection(options) -- Quests.lua collectors (includes Undaunted Pledges)
    self:AddArmoryBuildsSection(options) -- ArmoryBuilds.lua collectors
    self:AddCraftingSection(options) -- Crafting.lua collectors
    self:AddSocialSection(options) -- Social.lua collectors (Guilds, Mail)

    self:AddLinkSettings(options)
    self:AddSupportSection(options) -- LAST: Support section

    return options
end

-- =====================================================
-- FORMATTER SETTINGS
-- =====================================================

-- =====================================================
-- FORMATTER SETTINGS (REMOVED)
-- =====================================================

-- function CM.Settings.Panel:AddFormatterSection(options)
--     -- Removed as part of strict format enforcement
-- end

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
        getFunc = function()
            return CharacterMarkdownSettings.includeHeader
        end,
        setFunc = CreateSetFunc("includeHeader"),
        width = "half",
        default = true,
    })

    -- Footer
    table.insert(options, {
        type = "checkbox",
        name = "Include Footer",
        tooltip = "Show format badge, size, and generation date at the bottom of the markdown.",
        getFunc = function()
            return CharacterMarkdownSettings.includeFooter
        end,
        setFunc = CreateSetFunc("includeFooter"),
        width = "half",
        default = true,
    })
end

-- =====================================================
-- COMBAT SECTION (Combat.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddCombatSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Combat statistics, role, active buffs, and attributes.",
        width = "full",
    })

    -- Basic Combat Stats (CollectCombatStatsData - basic stats)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Basic Combat Stats",
        tooltip = "Show basic combat statistics table in Combat Arsenal\\n(Health, Magicka, Stamina, Power, Critical Strike, Penetration, etc.)",
        getFunc = function()
            return CharacterMarkdownSettings.includeBasicCombatStats
        end,
        setFunc = CreateSetFunc("includeBasicCombatStats"),
        width = "half",
        default = true,
    })

    -- Advanced Stats (CollectCombatStatsData - advanced stats)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Advanced Stats",
        tooltip = "Show advanced combat statistics in Combat Arsenal\\n(Core Abilities, Elemental Resistances, Damage Bonuses, Healing Bonuses, etc.)",
        getFunc = function()
            return CharacterMarkdownSettings.includeAdvancedStats
        end,
        setFunc = CreateSetFunc("includeAdvancedStats"),
        width = "half",
        default = true,
    })

    -- Role (CollectRoleData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Role",
        tooltip = "Show selected role (Tank/Healer/DPS) in overview",
        getFunc = function()
            return CharacterMarkdownSettings.includeRole
        end,
        setFunc = CreateSetFunc("includeRole"),
        width = "half",
        default = true,
    })

    -- Active Buffs (CollectActiveBuffs)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Active Buffs",
        tooltip = "Show food, potions, and other active buffs",
        getFunc = function()
            return CharacterMarkdownSettings.includeBuffs
        end,
        setFunc = CreateSetFunc("includeBuffs"),
        width = "half",
        default = true,
    })

    -- Attribute Distribution (from Progression.lua, but shown here for logical grouping)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Attribute Distribution",
        tooltip = "Show magicka/health/stamina attribute points",
        getFunc = function()
            return CharacterMarkdownSettings.includeAttributes
        end,
        setFunc = CreateSetFunc("includeAttributes"),
        width = "half",
        default = true,
    })

    table.insert(options, {
        type = "submenu",
        name = "Combat",
        tooltip = "Combat statistics, role, active buffs, and attributes.",
        controls = controls,
    })
end

-- =====================================================
-- CHARACTER SECTION (Character.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddCharacterSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Character identity, location, and titles.",
        width = "full",
    })

    -- Current Location (CollectLocationData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Current Location",
        tooltip = "Show current zone/location in overview\n(Minimal size impact)",
        getFunc = function()
            return CharacterMarkdownSettings.includeLocation
        end,
        setFunc = CreateSetFunc("includeLocation"),
        width = "half",
        default = true,
    })

    -- Titles (CollectTitlesData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Titles",
        tooltip = "Show character titles.",
        getFunc = function()
            return CharacterMarkdownSettings.includeTitlesHousing
        end,
        setFunc = CreateSetFunc("includeTitlesHousing"),
        width = "half",
        default = false,
    })

    -- Character Attributes (CollectAttributesData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Attributes",
        tooltip = "Show character attributes (age, gender, race, title, etc.)",
        getFunc = function()
            return CharacterMarkdownSettings.includeCharacterAttributes
        end,
        setFunc = CreateSetFunc("includeCharacterAttributes"),
        width = "half",
        default = true,
    })

    table.insert(options, {
        type = "submenu",
        name = "Character",
        tooltip = "Character identity, location, and titles.",
        controls = controls,
    })
end

-- =====================================================
-- CHAMPION SECTION (Champion.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddChampionSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Champion Point allocation and discipline breakdown.",
        width = "full",
    })

    -- Champion Points (CollectChampionPointData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Champion Points",
        tooltip = "Show Champion Point allocation and discipline breakdown",
        getFunc = function()
            return CharacterMarkdownSettings.includeChampionPoints
        end,
        setFunc = CreateSetFunc("includeChampionPoints"),
        width = "half",
        default = true,
    })

    -- CP Visual Diagram
    table.insert(controls, {
        type = "checkbox",
        name = "    Include CP Visual Diagram",
        tooltip = "Show a Mermaid diagram visualizing your invested Champion Points with prerequisite relationships (GitHub/VSCode only). Requires 'Include Champion Points' to be enabled. Uses cluster API to discover skill relationships.",
        getFunc = function()
            return CharacterMarkdownSettings.includeChampionDiagram
        end,
        setFunc = CreateSetFunc("includeChampionDiagram"),
        disabled = function()
            return not CharacterMarkdownSettings.includeChampionPoints
        end,
        width = "half",
        default = false,
    })

    table.insert(options, {
        type = "submenu",
        name = "Champion Points",
        tooltip = "Champion Point allocation and discipline breakdown.",
        controls = controls,
    })
end

-- =====================================================
-- SKILLS SECTION (Skills.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddSkillsSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Skill bars, skill progression, and skill morphs.",
        width = "full",
    })

    -- Skill Bars (CollectSkillBarData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Skill Bars",
        tooltip = "Show front and back bar abilities with ultimates",
        getFunc = function()
            return CharacterMarkdownSettings.includeSkillBars
        end,
        setFunc = CreateSetFunc("includeSkillBars"),
        width = "half",
        default = true,
    })

    -- Character Progress (CollectSkillProgressionData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Character Progress",
        tooltip = "Show Character Progress section with skill line ranks, progress, and passives",
        getFunc = function()
            return CharacterMarkdownSettings.includeSkills
        end,
        setFunc = CreateSetFunc("includeSkills"),
        width = "half",
        default = true,
    })

    -- Skill Morphs (CollectSkillMorphsData)
    table.insert(controls, {
        type = "checkbox",
        name = "    Show All Available Morphs",
        tooltip = "Show all morphable skills with their morph choices (not just equipped abilities).\nWhen enabled, displays comprehensive morph information for all unlocked skills.\nWhen disabled, shows only equipped abilities on bars.\nWARNING: Can generate 2-5KB of additional text for fully skilled characters.",
        getFunc = function()
            return CharacterMarkdownSettings.includeSkillMorphs
        end,
        setFunc = CreateSetFunc("includeSkillMorphs"),
        disabled = function()
            return not CharacterMarkdownSettings.includeSkills
        end,
        width = "half",
        default = false,
    })

    table.insert(options, {
        type = "submenu",
        name = "Skills",
        tooltip = "Skill bars, skill progression, and skill morphs.",
        controls = controls,
    })
end

-- =====================================================
-- EQUIPMENT SECTION (Equipment.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddEquipmentSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Equipped items and armor sets.",
        width = "full",
    })

    -- Equipment (CollectEquipmentData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Equipment",
        tooltip = "Show equipped items and armor sets",
        getFunc = function()
            return CharacterMarkdownSettings.includeEquipment
        end,
        setFunc = CreateSetFunc("includeEquipment"),
        width = "half",
        default = true,
    })

    table.insert(options, {
        type = "submenu",
        name = "Equipment",
        tooltip = "Equipped items and armor sets.",
        controls = controls,
    })
end

-- =====================================================
-- INVENTORY SECTION (Inventory.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddInventorySection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Inventory space, currency, and item lists.",
        width = "full",
    })

    -- Inventory Space (CollectInventoryData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Inventory Space",
        tooltip = "Show backpack and bank space usage\n(~150-200 chars)",
        getFunc = function()
            return CharacterMarkdownSettings.includeInventory
        end,
        setFunc = CreateSetFunc("includeInventory"),
        width = "half",
        default = true,
    })

    -- Bag Contents
    table.insert(controls, {
        type = "checkbox",
        name = "    Show Bag Item List",
        tooltip = "Show detailed list of all items in your backpack\nWarning: Can generate LARGE output with many items!",
        getFunc = function()
            return CharacterMarkdownSettings.showBagContents
        end,
        setFunc = CreateSetFunc("showBagContents"),
        width = "half",
        default = false,
        disabled = function()
            return not CharacterMarkdownSettings.includeInventory
        end,
    })

    -- Bank Contents
    table.insert(controls, {
        type = "checkbox",
        name = "    Show Bank Item List",
        tooltip = "Show detailed list of all items in your bank\nWarning: Can generate LARGE output with many items!",
        getFunc = function()
            return CharacterMarkdownSettings.showBankContents
        end,
        setFunc = CreateSetFunc("showBankContents"),
        width = "half",
        default = false,
        disabled = function()
            return not CharacterMarkdownSettings.includeInventory
        end,
    })

    -- Crafting Bag Contents
    table.insert(controls, {
        type = "checkbox",
        name = "    Show Crafting Bag Item List",
        tooltip = "Show detailed list of all items in your crafting bag (ESO Plus only)\nWarning: Can generate LARGE output with many items!",
        getFunc = function()
            return CharacterMarkdownSettings.showCraftingBagContents
        end,
        setFunc = CreateSetFunc("showCraftingBagContents"),
        width = "half",
        default = false,
        disabled = function()
            return not CharacterMarkdownSettings.includeInventory
        end,
    })

    -- Currency & Resources (CollectCurrencyData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Currency & Resources",
        tooltip = "Show gold, Alliance Points, Tel Var, Transmutes, Writs, Event Tickets, etc.\n(~500-800 chars)",
        getFunc = function()
            return CharacterMarkdownSettings.includeCurrency
        end,
        setFunc = CreateSetFunc("includeCurrency"),
        width = "half",
        default = true,
    })

    table.insert(options, {
        type = "submenu",
        name = "Inventory",
        tooltip = "Inventory space, currency, and item lists.",
        controls = controls,
    })
end

-- =====================================================
-- PROGRESSION SECTION (Progression.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddProgressionSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Character progression metrics and riding skills.",
        width = "full",
    })

    -- Progression Data (CollectProgressionData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Progression Data",
        tooltip = "Show skill points, attribute points, achievement points, available CP, vampire/werewolf status, and enlightenment\n(~200-400 chars)",
        getFunc = function()
            return CharacterMarkdownSettings.includeProgression
        end,
        setFunc = CreateSetFunc("includeProgression"),
        width = "half",
        default = false,
    })

    -- Riding Skills (CollectRidingSkillsData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Riding Skills",
        tooltip = "Show riding speed, stamina, and capacity progress\n(~200-300 chars)",
        getFunc = function()
            return CharacterMarkdownSettings.includeRidingSkills
        end,
        setFunc = CreateSetFunc("includeRidingSkills"),
        width = "half",
        default = false,
    })

    table.insert(options, {
        type = "submenu",
        name = "Progression",
        tooltip = "Character progression metrics and riding skills.",
        controls = controls,
    })
end

-- =====================================================
-- PVP SECTION (PvP.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddPvPSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "PvP statistics, progression, and Alliance War skills.",
        width = "full",
    })

    -- Basic PvP Information (CollectPvPData - basic)
    table.insert(controls, {
        type = "checkbox",
        name = "Include PvP Information",
        tooltip = "Show Alliance War rank and current campaign\n(~150-200 chars)",
        getFunc = function()
            return CharacterMarkdownSettings.includePvP
        end,
        setFunc = CreateSetFunc("includePvP"),
        width = "half",
        default = false,
    })

    -- PvP Statistics (CollectPvPData - stats)
    table.insert(controls, {
        type = "checkbox",
        name = "Include PvP Statistics",
        tooltip = "Show detailed PvP statistics and achievements.",
        getFunc = function()
            return CharacterMarkdownSettings.includePvPStats
        end,
        setFunc = CreateSetFunc("includePvPStats"),
        width = "half",
        default = false,
    })

    -- PvP Detail Options (dependent on includePvPStats)
    table.insert(controls, {
        type = "checkbox",
        name = "    Show PvP Progression",
        tooltip = "Include rank progress bars, percentages, and AP needed to next grade.",
        getFunc = function()
            return CharacterMarkdownSettings.showPvPProgression
        end,
        setFunc = CreateSetFunc("showPvPProgression"),
        width = "half",
        disabled = function()
            return not CharacterMarkdownSettings.includePvPStats
        end,
        default = false,
    })

    table.insert(controls, {
        type = "checkbox",
        name = "    Show Campaign Rewards",
        tooltip = "Display reward tier progress and loyalty streak.",
        getFunc = function()
            return CharacterMarkdownSettings.showCampaignRewards
        end,
        setFunc = CreateSetFunc("showCampaignRewards"),
        width = "half",
        disabled = function()
            return not CharacterMarkdownSettings.includePvPStats
        end,
        default = false,
    })

    table.insert(controls, {
        type = "checkbox",
        name = "    Show Leaderboards",
        tooltip = "Include campaign leaderboard ranking (requires API query).",
        getFunc = function()
            return CharacterMarkdownSettings.showLeaderboards
        end,
        setFunc = CreateSetFunc("showLeaderboards"),
        width = "half",
        disabled = function()
            return not CharacterMarkdownSettings.includePvPStats
        end,
        default = false,
    })

    table.insert(controls, {
        type = "checkbox",
        name = "    Show Battlegrounds",
        tooltip = "Include battleground leaderboard stats and medals.",
        getFunc = function()
            return CharacterMarkdownSettings.showBattlegrounds
        end,
        setFunc = CreateSetFunc("showBattlegrounds"),
        width = "half",
        disabled = function()
            return not CharacterMarkdownSettings.includePvPStats
        end,
        default = false,
    })

    table.insert(controls, {
        type = "checkbox",
        name = "    Detailed PvP Mode",
        tooltip = "Full comprehensive mode with campaign timing, underpop bonus, emperor info, and current match stats.",
        getFunc = function()
            return CharacterMarkdownSettings.showDetailedPvP
        end,
        setFunc = CreateSetFunc("showDetailedPvP"),
        width = "half",
        disabled = function()
            return not CharacterMarkdownSettings.includePvPStats
        end,
        default = false,
    })

    -- Alliance War Skills (independent setting)
    table.insert(controls, {
        type = "checkbox",
        name = "Show Alliance War Skills",
        tooltip = "Display Alliance War skill lines (Assault/Support/Emperor) in PvP section.\nUseful for PvE players who use these skills but don't actively PvP.",
        getFunc = function()
            return CharacterMarkdownSettings.showAllianceWarSkills
        end,
        setFunc = CreateSetFunc("showAllianceWarSkills"),
        width = "half",
        default = false,
    })

    table.insert(options, {
        type = "submenu",
        name = "PvP",
        tooltip = "PvP statistics, progression, and Alliance War skills.",
        controls = controls,
    })
end

-- =====================================================
-- COMPANION SECTION (Companion.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddCompanionSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Active companion information.",
        width = "full",
    })

    -- Companion Info (CollectCompanionData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Companion Info",
        tooltip = "Show active companion details (if summoned)",
        getFunc = function()
            return CharacterMarkdownSettings.includeCompanion
        end,
        setFunc = CreateSetFunc("includeCompanion"),
        width = "half",
        default = true,
    })

    table.insert(options, {
        type = "submenu",
        name = "Companion",
        tooltip = "Active companion information.",
        controls = controls,
    })
end

-- =====================================================
-- COLLECTIBLES SECTION (Collectibles.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddCollectiblesSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Mounts, pets, costumes, collectible items, DLC access, and housing.",
        width = "full",
    })

    -- Collectibles (CollectCollectiblesData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Collectibles",
        tooltip = "Show counts for mounts, pets, costumes, and collectible items\n(~200-300 chars)",
        getFunc = function()
            return CharacterMarkdownSettings.includeCollectibles
        end,
        setFunc = CreateSetFunc("includeCollectibles"),
        width = "half",
        default = true,
    })

    table.insert(controls, {
        type = "checkbox",
        name = "    Detailed Collectibles Lists",
        tooltip = "Show detailed lists of all owned collectibles (mounts, pets, costumes, emotes, mementos, skins, polymorphs, personalities) with progress bars and UESP links.\n(Can add 5000+ chars depending on collection size)",
        getFunc = function()
            return CharacterMarkdownSettings.showCollectiblesDetailed
        end,
        setFunc = CreateSetFunc("showCollectiblesDetailed"),
        disabled = function()
            return not CharacterMarkdownSettings.includeCollectibles
        end,
        width = "half",
        default = false,
    })

    -- DLC/Chapter Access (CollectDLCAccess)
    table.insert(controls, {
        type = "checkbox",
        name = "Include DLC/Chapter Access",
        tooltip = "Show which DLCs and Chapters are accessible\n(~400-600 chars - large section)",
        getFunc = function()
            return CharacterMarkdownSettings.includeDLCAccess
        end,
        setFunc = CreateSetFunc("includeDLCAccess"),
        width = "half",
        default = false,
    })

    -- Housing (CollectHousingData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Housing",
        tooltip = "Show owned houses and primary residence\n(~200-400 chars)",
        getFunc = function()
            return CharacterMarkdownSettings.includeHousing
        end,
        setFunc = CreateSetFunc("includeHousing"),
        width = "half",
        default = false,
    })

    table.insert(options, {
        type = "submenu",
        name = "Collectibles",
        tooltip = "Mounts, pets, costumes, collectible items, DLC access, and housing.",
        controls = controls,
    })
end

-- =====================================================
-- ACHIEVEMENTS SECTION (Achievements.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddAchievementsSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Achievement tracking and progress.",
        width = "full",
    })

    -- Achievement Tracking (CollectAchievementsData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Achievement Tracking",
        tooltip = "Show achievement progress with category breakdown (Combat, PvP, Exploration, Crafting, etc.), in-progress achievements, and recent completions.\n(~1000-2000 chars depending on progress)",
        getFunc = function()
            return CharacterMarkdownSettings.includeAchievements
        end,
        setFunc = CreateSetFunc("includeAchievements"),
        width = "half",
        default = false,
    })

    table.insert(controls, {
        type = "checkbox",
        name = "    Show All Achievements",
        tooltip = "Show all achievements. When disabled, shows only achievements that are currently in progress (have some progress but not completed). Useful for goal tracking when disabled.",
        getFunc = function()
            return CharacterMarkdownSettings.showAllAchievements ~= false
        end,
        setFunc = CreateSetFunc("showAllAchievements"),
        disabled = function()
            return not CharacterMarkdownSettings.includeAchievements
        end,
        width = "half",
        default = true,
    })

    table.insert(options, {
        type = "submenu",
        name = "Achievements",
        tooltip = "Achievement tracking and progress.",
        controls = controls,
    })
end

-- =====================================================
-- ANTIQUITIES SECTION (Antiquities.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddAntiquitiesSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Antiquities progress, active leads, and discovered antiquities.",
        width = "full",
    })

    -- Antiquities (CollectAntiquitiesData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Antiquities",
        tooltip = "Show antiquities progress, active leads, and discovered antiquities.",
        getFunc = function()
            return CharacterMarkdownSettings.includeAntiquities
        end,
        setFunc = CreateSetFunc("includeAntiquities"),
        width = "half",
        default = true,
    })

    table.insert(controls, {
        type = "checkbox",
        name = "    Detailed Antiquity Sets",
        tooltip = "Show detailed breakdown of antiquity sets with progress tracking.",
        getFunc = function()
            return CharacterMarkdownSettings.showAntiquitiesDetailed
        end,
        setFunc = CreateSetFunc("showAntiquitiesDetailed"),
        disabled = function()
            return not CharacterMarkdownSettings.includeAntiquities
        end,
        width = "half",
        default = false,
    })

    table.insert(options, {
        type = "submenu",
        name = "Antiquities",
        tooltip = "Antiquities progress, active leads, and discovered antiquities.",
        controls = controls,
    })
end

-- =====================================================
-- QUESTS SECTION (Quests.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddQuestsSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Quest tracking and Undaunted pledges.",
        width = "full",
    })

    -- Quest Tracking (CollectQuestJournalData)
    --[[ QUEST SECTION DISABLED TEMPORARILY - Issues being investigated
    table.insert(controls, {
        type = "checkbox",
        name = "Include Quest Tracking",
        tooltip = "Show active quests, progress tracking, and quest categorization.",
        getFunc = function() return CharacterMarkdownSettings.includeQuests end,
        setFunc = CreateSetFunc("includeQuests"),
        width = "half",
        default = false,
    })
    
    table.insert(controls, {
        type = "checkbox",
        name = "    Detailed Quest Categories",
        tooltip = "Show quest breakdown by categories (Main Story, Guild Quests, DLC Quests, etc.) with zone tracking.",
        getFunc = function() return CharacterMarkdownSettings.showQuestsDetailed end,
        setFunc = CreateSetFunc("showQuestsDetailed"),
        disabled = function() return not CharacterMarkdownSettings.includeQuests end,
        width = "half",
        default = false,
    })
    
    table.insert(controls, {
        type = "checkbox",
        name = "    Show All Quests",
        tooltip = "Show all quests. When disabled, shows only currently active quests. Useful for current objective tracking when disabled.",
        getFunc = function() return CharacterMarkdownSettings.showAllQuests ~= false end,
        setFunc = CreateSetFunc("showAllQuests"),
        disabled = function() return not CharacterMarkdownSettings.includeQuests end,
        width = "half",
        default = false,
    })
    --]]

    -- Undaunted Pledges (CollectUndauntedPledgesData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Undaunted Pledges",
        tooltip = "Show active Undaunted pledges from quest journal.",
        getFunc = function()
            return CharacterMarkdownSettings.includeUndauntedPledges
        end,
        setFunc = CreateSetFunc("includeUndauntedPledges"),
        width = "half",
        default = false,
    })

    table.insert(options, {
        type = "submenu",
        name = "Quests",
        tooltip = "Quest tracking and Undaunted pledges.",
        controls = controls,
    })
end

-- =====================================================
-- ARMORY BUILDS SECTION (ArmoryBuilds.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddArmoryBuildsSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Saved armory builds and configurations.",
        width = "full",
    })

    -- Armory Builds (CollectArmoryBuildsData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Armory Builds",
        tooltip = "Show saved armory builds and configurations.",
        getFunc = function()
            return CharacterMarkdownSettings.includeArmoryBuilds
        end,
        setFunc = CreateSetFunc("includeArmoryBuilds"),
        width = "half",
        default = false,
    })

    table.insert(options, {
        type = "submenu",
        name = "Armory Builds",
        tooltip = "Saved armory builds and configurations.",
        controls = controls,
    })
end

-- =====================================================
-- CRAFTING SECTION (Crafting.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddCraftingSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Crafting knowledge, research, and styles.",
        width = "full",
    })

    -- Crafting Knowledge (CollectCraftingData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Crafting Knowledge",
        tooltip = "Show known motifs and active research slots\n(~150-200 chars)",
        getFunc = function()
            return CharacterMarkdownSettings.includeCrafting
        end,
        setFunc = CreateSetFunc("includeCrafting"),
        width = "half",
        default = false,
    })

    table.insert(options, {
        type = "submenu",
        name = "Crafting",
        tooltip = "Crafting knowledge, research, and styles.",
        controls = controls,
    })
end

-- =====================================================
-- SOCIAL SECTION (Social.lua collectors)
-- =====================================================

function CM.Settings.Panel:AddSocialSection(options)
    local controls = {}

    table.insert(controls, {
        type = "description",
        text = "Guild membership and mail information.",
        width = "full",
    })

    -- Guild Membership (CollectGuildsData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Guild Membership",
        tooltip = "Show guild membership information including guild names, member counts, and your rank\n(~200-400 chars)",
        getFunc = function()
            return CharacterMarkdownSettings.includeGuilds
        end,
        setFunc = CreateSetFunc("includeGuilds"),
        width = "half",
        default = true,
    })

    -- Mail (CollectMailData)
    table.insert(controls, {
        type = "checkbox",
        name = "Include Mail",
        tooltip = "Show mail information including unread count and attachments\n(~100-200 chars)",
        getFunc = function()
            return CharacterMarkdownSettings.includeMail
        end,
        setFunc = CreateSetFunc("includeMail"),
        width = "half",
        default = false,
    })

    table.insert(options, {
        type = "submenu",
        name = "Social",
        tooltip = "Guild membership and mail information.",
        controls = controls,
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
        getFunc = function()
            return CharacterMarkdownSettings.enableAbilityLinks
        end,
        setFunc = function(value)
            CharacterMarkdownSettings.enableAbilityLinks = value
            CharacterMarkdownSettings.enableSetLinks = value
            CharacterMarkdownSettings._lastModified = GetTimeStamp()
            CM.InvalidateSettingsCache()
        end,
        width = "full",
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

    -- Check for LibCustomIcons
    if LibCustomIcons and LibCustomIcons.GetStatic and GetDisplayName then
        local displayName = GetDisplayName()
        local iconPath = LibCustomIcons.GetStatic(displayName)

        if iconPath then
            table.insert(options, {
                type = "texture",
                image = iconPath,
                width = "full",
                height = 64,
                tooltip = "This icon is provided by LibCustomIcons addon",
            })

            table.insert(options, {
                type = "description",
                text = "|c6BCF7EYou have a custom icon!|r This icon will appear in your character header.",
                width = "full",
            })
        end
    end

    table.insert(options, {
        type = "checkbox",
        name = "Include Build Notes",
        tooltip = "Include custom build notes section (appears after Overview to set context for your build)\nNotes must be entered below to appear in output",
        getFunc = function()
            return CharacterMarkdownSettings.includeBuildNotes
        end,
        setFunc = CreateSetFunc("includeBuildNotes"),
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
            local currentValue = CM.charData.customTitle or ""

            -- Update CM.charData (ZO_SavedVars proxy - automatically persists)
            -- NOTE: CM.charData is a subtable within CharacterMarkdownData, returned by ZO_SavedVars:NewCharacterId
            -- Modifying CM.charData automatically updates the parent CharacterMarkdownData structure
            CM.charData.customTitle = newValue
            CM.charData._lastModified = GetTimeStamp()

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
        -- NOTE: No default value - this is user-entered data that must never be reset
    })

    table.insert(options, {
        type = "dropdown",
        name = "Play Style",
        tooltip = "Select the primary play style for this character.\nPlay style is saved per-character and persists between sessions.\nLeave empty if not applicable.",
        choices = PLAY_STYLES,
        choicesValues = PLAY_STYLE_VALUES,
        getFunc = function()
            -- Ensure character data is initialized
            if not CM.charData and CharacterMarkdownData then
                CM.charData = CharacterMarkdownData
            end
            -- Ensure playStyle exists (initialize if nil)
            if CM.charData and CM.charData.playStyle == nil then
                CM.charData.playStyle = ""
            end
            return CM.charData and CM.charData.playStyle or ""
        end,
        setFunc = function(value)
            -- Ensure character data is initialized
            if not CM.charData and CharacterMarkdownData then
                CM.charData = CharacterMarkdownData
            end

            if not CM.charData then
                CM.Error("Failed to save play style - character data not available")
                return
            end

            -- Normalize value (empty string if nil)
            local newValue = value or ""
            local currentValue = CM.charData.playStyle or ""

            -- Update CM.charData (ZO_SavedVars proxy - automatically persists)
            -- NOTE: CM.charData is a subtable within CharacterMarkdownData, returned by ZO_SavedVars:NewCharacterId
            -- Modifying CM.charData automatically updates the parent CharacterMarkdownData structure
            CM.charData.playStyle = newValue
            CM.charData._lastModified = GetTimeStamp()

            -- Log the save (only log if value actually changed)
            if newValue ~= currentValue then
                CM.DebugPrint("SETTINGS", "Play style changed and saved: " .. tostring(newValue))
            else
                CM.DebugPrint("SETTINGS", "Play style refreshed")
            end
        end,
        width = "full",
        -- NOTE: No default value - this is user-entered data that must never be reset
    })

    table.insert(options, {
        type = "editbox",
        name = "Build Notes",
        tooltip = "Add custom notes (rotation, parse data, build description, etc.)\nNotes are saved per-character and persist between sessions.\n\nLimit: 1,900 characters (ESO SavedVariables restriction)",
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
            local currentValue = CM.charData.customNotes or ""

            -- Update CM.charData (ZO_SavedVars proxy - automatically persists)
            -- NOTE: CM.charData is a subtable within CharacterMarkdownData, returned by ZO_SavedVars:NewCharacterId
            -- Modifying CM.charData automatically updates the parent CharacterMarkdownData structure
            CM.charData.customNotes = newValue
            CM.charData._lastModified = GetTimeStamp()

            -- Log the save (only log if value actually changed)
            if newValue ~= currentValue then
                CM.DebugPrint("SETTINGS", "Build notes changed and saved (" .. string.len(newValue) .. " bytes)")
            else
                CM.DebugPrint("SETTINGS", "Build notes refreshed (" .. string.len(newValue) .. " bytes)")
            end

            -- Update character counter if it exists
            if CM._buildNotesCounterLabel then
                local charCount = string.len(newValue)
                local color = charCount > 1900 and "|cFF6B6B" or (charCount > 1700 and "|cFFD93D" or "|c6BCF7E")
                CM._buildNotesCounterLabel:SetText(color .. "Characters: " .. charCount .. " / 1,900|r")
            end
        end,
        width = "full",
        height = 500, -- Large editbox for better visibility - scrollbar appears when content exceeds this
        isMultiline = true,
        isExtraWide = true,
        maxChars = 1900, -- ESO SavedVariables has a ~2000 character limit per string value
        -- NOTE: No default value - this is user-entered data that must never be reset
        reference = "CharacterMarkdown_BuildNotesEditBox",
    })

    -- Character counter label
    table.insert(options, {
        type = "description",
        text = function()
            local charCount = 0
            if CM.charData and CM.charData.customNotes then
                charCount = string.len(CM.charData.customNotes)
            end
            local color = charCount > 1900 and "|cFF6B6B" or (charCount > 1700 and "|cFFD93D" or "|c6BCF7E")
            return color .. "Characters: " .. charCount .. " / 1,900|r"
        end,
        reference = "CharacterMarkdown_BuildNotesCounter",
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
                CM.Error("Command not available - try /reloadui")
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

    -- Helper function to enable/disable all sections (organized by collector modules)
    local function ToggleAllSections(enable)
        local value = enable == true

        -- LAYOUT
        CharacterMarkdownSettings.includeHeader = value
        CharacterMarkdownSettings.includeFooter = value
        CharacterMarkdownSettings.includeTableOfContents = value
        CharacterMarkdownSettings.includeAttentionNeeded = value

        -- CHARACTER (Character.lua collectors)
        CharacterMarkdownSettings.includeLocation = value
        CharacterMarkdownSettings.includeCharacterAttributes = value
        CharacterMarkdownSettings.includeTitlesHousing = value
        CharacterMarkdownSettings.includeDLCAccess = value

        -- COMBAT (Combat.lua collectors)
        CharacterMarkdownSettings.includeBasicCombatStats = value
        CharacterMarkdownSettings.includeAdvancedStats = value
        CharacterMarkdownSettings.includeRole = value
        CharacterMarkdownSettings.includeBuffs = value
        CharacterMarkdownSettings.includeAttributes = value

        -- CHAMPION (Champion.lua collectors)
        CharacterMarkdownSettings.includeChampionPoints = value
        CharacterMarkdownSettings.includeChampionDiagram = value

        -- SKILLS (Skills.lua collectors)
        CharacterMarkdownSettings.includeSkillBars = value
        CharacterMarkdownSettings.includeSkills = value
        CharacterMarkdownSettings.includeSkillMorphs = value

        -- EQUIPMENT (Equipment.lua collectors)
        CharacterMarkdownSettings.includeEquipment = value

        -- INVENTORY (Inventory.lua collectors)
        CharacterMarkdownSettings.includeInventory = value
        CharacterMarkdownSettings.showBagContents = value
        CharacterMarkdownSettings.showBankContents = value
        CharacterMarkdownSettings.showCraftingBagContents = value
        CharacterMarkdownSettings.includeCurrency = value

        -- PROGRESSION (Progression.lua collectors)
        CharacterMarkdownSettings.includeProgression = value
        CharacterMarkdownSettings.includeRidingSkills = value

        -- PVP (PvP.lua collectors)
        CharacterMarkdownSettings.includePvP = value
        CharacterMarkdownSettings.includePvPStats = value
        CharacterMarkdownSettings.showPvPProgression = value
        CharacterMarkdownSettings.showCampaignRewards = value
        CharacterMarkdownSettings.showLeaderboards = value
        CharacterMarkdownSettings.showBattlegrounds = value
        CharacterMarkdownSettings.showDetailedPvP = value
        CharacterMarkdownSettings.showAllianceWarSkills = value

        -- COMPANION (Companion.lua collectors)
        CharacterMarkdownSettings.includeCompanion = value

        -- COLLECTIBLES (Collectibles.lua collectors)
        CharacterMarkdownSettings.includeCollectibles = value
        CharacterMarkdownSettings.showCollectiblesDetailed = value
        CharacterMarkdownSettings.includeDLCAccess = value
        CharacterMarkdownSettings.includeHousing = value

        -- ACHIEVEMENTS (Achievements.lua collectors)
        CharacterMarkdownSettings.includeAchievements = value
        CharacterMarkdownSettings.showAllAchievements = value

        -- ANTIQUITIES (Antiquities.lua collectors)
        CharacterMarkdownSettings.includeAntiquities = value
        CharacterMarkdownSettings.showAntiquitiesDetailed = value

        -- QUESTS (Quests.lua collectors)
        -- CharacterMarkdownSettings.includeQuests = value  -- DISABLED
        -- CharacterMarkdownSettings.showQuestsDetailed = value  -- DISABLED
        -- CharacterMarkdownSettings.showAllQuests = value  -- DISABLED
        CharacterMarkdownSettings.includeUndauntedPledges = value

        -- ARMORY BUILDS (ArmoryBuilds.lua collectors)
        CharacterMarkdownSettings.includeArmoryBuilds = value

        -- CRAFTING (Crafting.lua collectors)
        CharacterMarkdownSettings.includeCrafting = value

        -- SOCIAL (Social.lua collectors)
        CharacterMarkdownSettings.includeGuilds = value
        CharacterMarkdownSettings.includeMail = value

        -- LINKS
        CharacterMarkdownSettings.enableAbilityLinks = value
        CharacterMarkdownSettings.enableSetLinks = value

        -- NOTES/DISPLAY
        CharacterMarkdownSettings.includeBuildNotes = value

        CharacterMarkdownSettings._lastModified = GetTimeStamp()
        CM.InvalidateSettingsCache()
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
            local LAM = LibStub("LibAddonMenu-2.0", true) -- true = silent, returns nil if not found
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
            local LAM = LibStub("LibAddonMenu-2.0", true) -- true = silent, returns nil if not found
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
                CM.Info("Buy Me a Coffee: https://www.buymeacoffee.com/lewisvavasw")
                CM.Info("(Copy the URL above and paste it in your browser)")
            end
        end,
        width = "full",
    })
end

-- Debug print (deferred until CM.DebugPrint is available)
if CM.DebugPrint then
    CM.DebugPrint("SETTINGS", "Panel module loaded (CraftStore pattern)")
end
