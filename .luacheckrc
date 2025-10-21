-- Luacheck configuration for Elder Scrolls Online addon development
-- https://luacheck.readthedocs.io/en/stable/config.html

std = "lua51"

-- Ignore certain warning codes
ignore = {
    "211", -- Unused local variable
    "212", -- Unused argument
    "213", -- Unused loop variable
    "311", -- Value assigned to variable is unused
    "611", -- Line contains only whitespace
    "612", -- Line contains trailing whitespace
}

-- Allow slightly longer lines (ESO API calls and tooltip strings can be verbose)
max_line_length = 240

-- Don't check cyclomatic complexity (ESO functions can be complex)
max_cyclomatic_complexity = false

-- ESO API Globals - read/write allowed
globals = {
    "SLASH_COMMANDS",
    "CharacterMarkdown",
    "CharacterMarkdownSettings",
    "CharacterMarkdownData",
    "CharacterMarkdown_ShowWindow",
    "CharacterMarkdown_CopyToClipboard",
    "CharacterMarkdown_CloseWindow",
    "CharacterMarkdown_RegenerateMarkdown",
}

-- ESO API Globals - read-only
read_globals = {
    -- Debug function (common in ESO addons)
    "d",
    
    -- UI Controls
    "CharacterMarkdownWindow",
    "CharacterMarkdownWindowTextContainerEditBox",
    "CharacterMarkdownWindowTextContainerClipboardEditBox",
    
    -- ESO API Constants - Alliance
    "ALLIANCE_ALDMERI_DOMINION",
    "ALLIANCE_DAGGERFALL_COVENANT",
    "ALLIANCE_EBONHEART_PACT",
    
    -- ESO API Constants - Attributes
    "ATTRIBUTE_HEALTH",
    "ATTRIBUTE_MAGICKA",
    "ATTRIBUTE_STAMINA",
    
    -- ESO API Constants - Bags
    "BAG_BACKPACK",
    "BAG_BANK",
    "BAG_COMPANION_WORN",
    "BAG_WORN",
    
    -- ESO API Constants - Collectibles
    "COLLECTIBLE_CATEGORY_TYPE_COSTUME",
    "COLLECTIBLE_CATEGORY_TYPE_EMOTE",
    "COLLECTIBLE_CATEGORY_TYPE_HOUSE",
    "COLLECTIBLE_CATEGORY_TYPE_MEMENTO",
    "COLLECTIBLE_CATEGORY_TYPE_MOUNT",
    "COLLECTIBLE_CATEGORY_TYPE_PERSONALITY",
    "COLLECTIBLE_CATEGORY_TYPE_POLYMORPH",
    "COLLECTIBLE_CATEGORY_TYPE_SKIN",
    "COLLECTIBLE_CATEGORY_TYPE_VANITY_PET",
    
    -- ESO API Constants - Currency
    "CURRENCY_LOCATION_ACCOUNT",
    "CURRENCY_LOCATION_CHARACTER",
    "CURT_ALLIANCE_POINTS",
    "CURT_CHAOTIC_CREATIA",
    "CURT_CROWN_GEMS",
    "CURT_CROWNS",
    "CURT_ENDEAVOR_SEALS",
    "CURT_EVENT_TICKETS",
    "CURT_TELVAR_STONES",
    "CURT_UNDAUNTED_KEYS",
    "CURT_WRIT_VOUCHERS",
    
    -- ESO API Constants - Equipment
    "EQUIP_SLOT_BACKUP_MAIN",
    "EQUIP_SLOT_BACKUP_OFF",
    "EQUIP_SLOT_CHEST",
    "EQUIP_SLOT_COSTUME",
    "EQUIP_SLOT_FEET",
    "EQUIP_SLOT_HAND",
    "EQUIP_SLOT_HEAD",
    "EQUIP_SLOT_LEGS",
    "EQUIP_SLOT_MAIN_HAND",
    "EQUIP_SLOT_NECK",
    "EQUIP_SLOT_OFF_HAND",
    "EQUIP_SLOT_RING1",
    "EQUIP_SLOT_RING2",
    "EQUIP_SLOT_SHOULDERS",
    "EQUIP_SLOT_WAIST",
    
    -- ESO API Constants - Hotbar
    "HOTBAR_CATEGORY_BACKUP",
    "HOTBAR_CATEGORY_COMPANION",
    "HOTBAR_CATEGORY_PRIMARY",
    
    -- ESO API Constants - Item Quality
    "ITEM_QUALITY_ARCANE",
    "ITEM_QUALITY_ARTIFACT",
    "ITEM_QUALITY_LEGENDARY",
    "ITEM_QUALITY_MAGIC",
    "ITEM_QUALITY_MYTHIC",
    "ITEM_QUALITY_NORMAL",
    "ITEM_QUALITY_TRASH",
    
    -- ESO API Constants - Jump to Player
    "JUMP_TO_PLAYER_RESULT_ZONE_COLLECTIBLE_LOCKED",
    
    -- ESO API Constants - LFG Roles
    "LFG_ROLE_DPS",
    "LFG_ROLE_HEAL",
    "LFG_ROLE_TANK",
    
    -- ESO API Constants - Links
    "LINK_STYLE_BRACKETS",
    "LINK_STYLE_DEFAULT",
    
    -- ESO API Constants - Riding
    "RIDING_TRAIN_CARRYING_CAPACITY",
    "RIDING_TRAIN_SPEED",
    "RIDING_TRAIN_STAMINA",
    
    -- ESO API Constants - Skills
    "SKILL_TYPE_ARMOR",
    "SKILL_TYPE_AVA",
    "SKILL_TYPE_CLASS",
    "SKILL_TYPE_GUILD",
    "SKILL_TYPE_RACIAL",
    "SKILL_TYPE_TRADESKILL",
    "SKILL_TYPE_WEAPON",
    "SKILL_TYPE_WORLD",
    
    -- ESO API Constants - Stats
    "STAT_HEALTH_MAX",
    "STAT_MAGICKA_MAX",
    "STAT_PHYSICAL_RESIST",
    "STAT_POWER",
    "STAT_SPELL_POWER",
    "STAT_SPELL_RESIST",
    "STAT_STAMINA_MAX",
    
    -- ESO API Functions - Character
    "CanJumpToPlayerInZone",
    "GetAbilityName",
    "GetAllianceName",
    "GetAttributeSpentPoints",
    "GetAttributeUnspentPoints",
    "GetCurrentTitleIndex",
    "GetNumBuffs",
    "GetPlayerChampionPointsEarned",
    "GetPlayerStat",
    "GetSlotBoundId",
    "GetString",
    "GetTitle",
    "GetTimeStamp",
    "GetUnitAlliance",
    "GetUnitBuffInfo",
    "GetUnitClass",
    "GetUnitGender",
    "GetUnitLevel",
    "GetUnitName",
    "GetUnitRace",
    "GetUnitZone",
    
    -- ESO API Functions - Champion
    "GetChampionDisciplineId",
    "GetChampionDisciplineName",
    "GetChampionSkillId",
    "GetChampionSkillName",
    "GetEnlightenedPool",
    "GetEnlightenedPoolCap",
    "GetNumChampionDisciplines",
    "GetNumChampionDisciplineSkills",
    "GetNumPointsSpentOnChampionSkill",
    
    -- ESO API Functions - Collectibles
    "GetCollectibleIdFromType",
    "GetCollectibleInfo",
    "GetCollectibleNickname",
    "GetCollectibleQuality",
    "GetTotalCollectiblesByCategoryType",
    
    -- ESO API Functions - Companion
    "HasActiveCompanion",
    
    -- ESO API Functions - Currency
    "GetCurrencyAmount",
    "GetCurrentMoney",
    
    -- ESO API Functions - Date/Time
    "GetDateStringFromTimestamp",
    
    -- ESO API Functions - Group
    "GetGroupMemberSelectedRole",
    
    -- ESO API Functions - Inventory
    "GetBagSize",
    "GetItemLink",
    "GetItemLinkQuality",
    "GetItemLinkRequiredLevel",
    "GetItemLinkSetInfo",
    "GetItemLinkTraitInfo",
    "GetItemName",
    "GetNumBagUsedSlots",
    "HasCraftBagAccess",
    
    -- ESO API Functions - PvP
    "GetAssignedCampaignId",
    "GetAvARankName",
    "GetCampaignName",
    "GetUnitAvARank",
    
    -- ESO API Functions - Progression
    "GetEarnedAchievementPoints",
    "GetTotalAchievementPoints",
    "GetAvailableSkillPoints",
    
    -- ESO API Functions - Riding
    "GetRidingStats",
    "GetTimeUntilCanBeTrained",
    
    -- ESO API Functions - Skills
    "GetNumSkillLines",
    "GetNumSkillTypes",
    "GetSkillLineInfo",
    "GetSkillLineXPInfo",
    
    -- ESO API Functions - Smithing
    "GetNumSmithingResearchLines",
    "GetSmithingResearchLineInfo",
    "GetSmithingResearchLineTraitTimes",
    
    -- ESO API Functions - Subscription
    "IsESOPlusSubscriber",
    
    -- ESO API Functions - World
    "GetPlayerActiveSubzoneName",
    
    -- ESO Event Constants
    "EVENT_ADD_ON_LOADED",
    "EVENT_PLAYER_ACTIVATED",
    
    -- ESO Managers
    "CHAT_SYSTEM",
    "EVENT_MANAGER",
    "SCENE_MANAGER",
    
    -- ESO Libraries
    "LibAddonMenu2",
    "LibDebugLogger",
    
    -- Standard Lua globals used in ESO
    "zo_callLater",
    "zo_strformat",
    "ZO_Object",
    "ZO_SavedVars",
}

-- Files to exclude from checking
exclude_files = {
    "**/*.backup",
    ".task/**",
}
