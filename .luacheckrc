-- CharacterMarkdown Luacheck Configuration
-- https://luacheck.readthedocs.io/en/stable/

-- ===========================================================================
-- Global Settings
-- ===========================================================================
std = "lua51"  -- ESO uses Lua 5.1
cache = true
codes = true

-- Maximum line length (ESO convention: 120)
max_line_length = 120

-- Maximum cyclomatic complexity
max_cyclomatic_complexity = 30

-- ===========================================================================
-- Ignore Patterns
-- ===========================================================================
exclude_files = {
    "*.xml",
    "**/*.backup",
    ".task/**",
    "build/**",
    "dist/**",
}

-- ===========================================================================
-- ESO Global Variables (Read-Only API Functions)
-- ===========================================================================
-- These are provided by the ESO game client and should NOT be defined in addon code

read_globals = {
    -- ESO Core Systems
    "EVENT_MANAGER",
    "CHAT_SYSTEM",
    "WINDOW_MANAGER",
    "SCENE_MANAGER",
    "CALLBACK_MANAGER",
    
    -- ESO Events (Selected - Add as needed)
    "EVENT_ADD_ON_LOADED",
    "EVENT_PLAYER_ACTIVATED",
    "EVENT_PLAYER_DEACTIVATED",
    
    -- ESO Global Functions (Commonly Used)
    "d",  -- Debug print to chat
    "zo_callLater",
    "zo_strformat",
    "zo_strlen",
    
    -- Character Data
    "GetUnitName",
    "GetUnitRace",
    "GetUnitClass",
    "GetUnitLevel",
    "GetUnitChampionPoints",
    "GetUnitAlliance",
    "GetPlayerStat",
    
    -- Skill/Ability API
    "GetNumSkillTypes",
    "GetSkillTypeInfo",
    "GetNumSkillLines",
    "GetSkillLineInfo",
    "GetNumSkillAbilities",
    "GetSkillAbilityInfo",
    "GetSlotBoundId",
    "GetAbilityName",
    
    -- Equipment/Inventory
    "GetItemLink",
    "GetItemLinkSetInfo",
    "GetItemLinkQuality",
    "GetItemLinkTraitInfo",
    "GetNumBagSlots",
    "GetBagSize",
    
    -- Champion Points
    "GetChampionPointsInDiscipline",
    "GetNumChampionDisciplines",
    "GetChampionDisciplineAttribute",
    
    -- Buffs/Effects
    "GetNumBuffs",
    "GetUnitBuffInfo",
    
    -- Constants
    "STAT_HEALTH_MAX",
    "STAT_MAGICKA_MAX",
    "STAT_STAMINA_MAX",
    "STAT_SPELL_POWER",
    "STAT_SPELL_CRITICAL",
    "STAT_PHYSICAL_RESIST",
    "STAT_SPELL_RESIST",
    
    "BAG_WORN",
    "BAG_BACKPACK",
    "BAG_BANK",
    
    "HOTBAR_CATEGORY_PRIMARY",
    "HOTBAR_CATEGORY_BACKUP",
    
    "SKILL_TYPE_CLASS",
    "SKILL_TYPE_WEAPON",
    "SKILL_TYPE_ARMOR",
    "SKILL_TYPE_WORLD",
    "SKILL_TYPE_GUILD",
    "SKILL_TYPE_AVA",
    "SKILL_TYPE_RACIAL",
    "SKILL_TYPE_TRADESKILL",
    
    -- Quality levels
    "ITEM_QUALITY_TRASH",
    "ITEM_QUALITY_NORMAL",
    "ITEM_QUALITY_MAGIC",
    "ITEM_QUALITY_ARCANE",
    "ITEM_QUALITY_ARTIFACT",
    "ITEM_QUALITY_LEGENDARY",
    
    -- LibAddonMenu (optional dependency)
    "LibAddonMenu2",
    "LibStub",
    
    -- ZO_Object (ESO's OOP framework)
    "ZO_Object",
    "ZO_InitializingObject",
    
    -- String/Table helpers
    "SafeAddString",
    "GetString",
    "zo_strsplit",
    
    -- UI Elements
    "GuiRoot",
    "TopLevelWindow",
}

-- ===========================================================================
-- Addon Global Variables (Defined by this addon)
-- ===========================================================================
-- These are globals that CharacterMarkdown creates and uses

globals = {
    "CharacterMarkdown",  -- Main namespace
    "CM",  -- Short alias
    "CharacterMarkdownSettings",  -- SavedVariables
    "CharacterMarkdownData",  -- SavedVariablesPerCharacter
}

-- ===========================================================================
-- Per-File Overrides
-- ===========================================================================

files["src/Core.lua"] = {
    -- Core.lua defines the main namespace
    globals = {
        "CharacterMarkdown",
        "CM",
    }
}

files["src/Events.lua"] = {
    -- Events.lua registers global event handlers
    ignore = {
        "212",  -- Unused argument (event, addonName)
    }
}

files["src/Commands.lua"] = {
    -- Commands.lua may have intentionally unused parameters
    ignore = {
        "212",  -- Unused argument
    }
}

files["src/settings/*.lua"] = {
    -- Settings files interact with SavedVariables
    globals = {
        "CharacterMarkdownSettings",
    }
}

-- ===========================================================================
-- Warnings to Suppress
-- ===========================================================================

-- Allow unused loop variables with underscore prefix
ignore = {
    "211/_.*",  -- Unused local variable starting with _
    "212/_.*",  -- Unused argument starting with _
}

-- ===========================================================================
-- Custom Error Messages
-- ===========================================================================

-- Enforce consistent naming for addon namespace
-- files["**/*.lua"] = {
--     -- Ensure no direct access to _G (global table)
--     ignore = { "111", "113" }  -- Setting/accessing undefined global
-- }
