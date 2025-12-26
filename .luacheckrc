-- Luacheck configuration for CharacterMarkdown
-- Comprehensive ESO API globals for Lua 5.1 compatibility

std = "lua51"

ignore = {
    "212", -- unused argument (common with ESO event callbacks)
    "631", -- line too long (common with markdown generation)
}

-- Addon-specific globals (read/write)
globals = {
    "CharacterMarkdown",
    "CharacterMarkdownSettings",
    "CharacterMarkdownData",
}

-- ESO API globals (read-only)
read_globals = {
    -- ===========================================
    -- ESO CORE OBJECTS
    -- ===========================================
    "EVENT_MANAGER",
    "SLASH_COMMANDS",
    "CALLBACK_MANAGER",
    "WINDOW_MANAGER",
    "SCENE_MANAGER",
    "LINK_HANDLER",

    -- ===========================================
    -- ESO UTILITY FUNCTIONS
    -- ===========================================
    "d",                              -- Debug print
    "zo_callLater",
    "zo_strformat",
    "zo_strsplit",
    "zo_strmatch",
    "zo_strlen",
    "zo_min",
    "zo_max",
    "zo_clamp",
    "zo_floor",
    "zo_ceil",
    "zo_round",
    "zo_abs",
    "zo_iconFormat",
    "zo_iconFormatInheritColor",
    "zo_strjoin",
    "ZO_SavedVars",
    "ZO_ClearColor",
    "ZO_CreateStringId",
    "ZO_ColorDef",
    "ZO_GenerateCommaSeparatedList",
    "ZO_CommaDelimitNumber",
    "ZO_LocalizeDecimalNumber",
    "ZO_FastFormatDecimalNumber",
    "ZO_FormatTimeMilliseconds",
    "ZO_FormatTime",
    "ZO_CachedStrFormat",
    "ZO_GetPlatformAccountLabel",
    "ZO_GAMEPAD_CURRENCY_FORMAT_AMOUNT_ICON",
    "ZO_LinkHandler_CreateLink",
    "ZO_LinkHandler_ParseLink",
    "ZO_GetNextBagSlotIndex",
    "ZO_ScrollList_GetSelectedData",
    "ZO_GetCraftingSkillName",
    "ZO_GetChampionDisciplineName",

    -- ===========================================
    -- UNIT/PLAYER FUNCTIONS
    -- ===========================================
    "GetWorldName",
    "GetCurrentWorldId",
    "GetUnitName",
    "GetUnitRace",
    "GetUnitClass",
    "GetUnitAlliance",
    "GetAllianceName",
    "GetUnitLevel",
    "GetUnitEffectiveLevel",
    "GetUnitGender",
    "GetPlayerChampionPointsEarned",
    "GetCurrentTitleIndex",
    "GetTitle",
    "GetNumTitles",
    "GetDisplayName",
    "GetCurrentCharacterId",
    "IsESOPlusSubscriber",
    "GetAttributeSpentPoints",
    "GetTimeStamp",
    "GetDateStringFromTimestamp",
    "GetTimeString",
    "GetFrameTimeSeconds",
    "GetGameTimeMilliseconds",
    "CanJumpToPlayerInZone",
    "GetAPIVersion",
    "GetAddOnMetadata",

    -- ===========================================
    -- ATTRIBUTE/STAT CONSTANTS
    -- ===========================================
    "ATTRIBUTE_MAGICKA",
    "ATTRIBUTE_HEALTH",
    "ATTRIBUTE_STAMINA",
    "STAT_HEALTH_MAX",
    "STAT_MAGICKA_MAX",
    "STAT_STAMINA_MAX",
    "STAT_HEALTH_REGEN_COMBAT",
    "STAT_MAGICKA_REGEN_COMBAT",
    "STAT_STAMINA_REGEN_COMBAT",
    "STAT_HEALTH_REGEN_IDLE",
    "STAT_MAGICKA_REGEN_IDLE",
    "STAT_STAMINA_REGEN_IDLE",
    "STAT_POWER",
    "STAT_WEAPON_POWER",
    "STAT_SPELL_POWER",
    "STAT_CRITICAL_STRIKE",
    "STAT_WEAPON_AND_SPELL_CRITICAL",
    "STAT_CRITICAL_RESISTANCE",
    "STAT_PHYSICAL_RESIST",
    "STAT_SPELL_RESIST",
    "STAT_PHYSICAL_PENETRATION",
    "STAT_SPELL_PENETRATION",
    "STAT_ARMOR_RATING",
    "STAT_DODGE",
    "STAT_MITIGATION",
    "STAT_HEALING_DONE",
    "STAT_HEALING_TAKEN",
    "STAT_DAMAGE_SHIELD_EFFECTIVENESS",
    "GetPlayerStat",

    -- ===========================================
    -- SKILL/ABILITY FUNCTIONS
    -- ===========================================
    "GetSlotBoundId",
    "GetNumSkillTypes",
    "GetSkillTypeInfo",
    "GetNumSkillLines",
    "GetSkillLineInfo",
    "GetNumSkillAbilities",
    "GetSkillAbilityInfo",
    "GetAbilityProgressionInfo",
    "GetAbilityProgressionXPInfo",
    "GetAbilityProgressionAbilityId",
    "GetAbilityName",
    "GetAbilityIcon",
    "GetAbilityCost",
    "GetAbilityDescription",
    "GetSkillCostInfo",
    "GetSkillLineName",
    "GetSkillLineRankXPExtents",
    "GetSkillAbilityId",
    "GetSkillAbilityNextUpgradeInfo",
    "GetAbilityProgressionRankFromAbilityId",
    "GetNumAvailableSkillPoints",
    "GetAvailableSkillPoints",
    "GetTotalSkillPointsEarned",

    -- ===========================================
    -- HOTBAR CONSTANTS
    -- ===========================================
    "HOTBAR_CATEGORY_PRIMARY",
    "HOTBAR_CATEGORY_BACKUP",
    "HOTBAR_CATEGORY_CONSUMABLE",
    "HOTBAR_CATEGORY_QUICKSLOT_WHEEL",
    "ACTION_BAR_FIRST_NORMAL_SLOT_INDEX",
    "ACTION_BAR_ULTIMATE_SLOT_INDEX",

    -- ===========================================
    -- EQUIPMENT FUNCTIONS
    -- ===========================================
    "GetBagInfo",
    "GetBagSize",
    "GetSlotStackSize",
    "GetItemLink",
    "GetItemLinkInfo",
    "GetItemLinkName",
    "GetItemLinkQuality",
    "GetItemLinkSetInfo",
    "GetItemLinkTraitInfo",
    "GetItemLinkEnchantInfo",
    "GetItemLinkArmorType",
    "GetItemLinkWeaponType",
    "GetItemLinkEquipType",
    "GetItemLinkWeaponPower",
    "GetItemLinkArmorRating",
    "GetItemLinkRequiredLevel",
    "GetItemLinkRequiredChampionPoints",
    "GetItemLinkBindType",
    "GetItemLinkValue",
    "GetItemLinkIcon",
    "GetItemLinkFlavorText",
    "GetItemLinkClothierOriginalItem",
    "GetItemLinkStolen",
    "GetItemLinkCraftedQuality",
    "GetItemInfo",
    "GetItemName",
    "GetItemQuality",
    "GetItemQualityColor",
    "GetEquippedItemInfo",
    "GetEquippedItemLink",
    "GetNumEquippedBagsSlots",
    "GetBagUseableSize",
    "GetBagAvailableSpace",

    -- ===========================================
    -- EQUIPMENT SLOT CONSTANTS
    -- ===========================================
    "EQUIP_SLOT_HEAD",
    "EQUIP_SLOT_NECK",
    "EQUIP_SLOT_CHEST",
    "EQUIP_SLOT_SHOULDERS",
    "EQUIP_SLOT_MAIN_HAND",
    "EQUIP_SLOT_OFF_HAND",
    "EQUIP_SLOT_WAIST",
    "EQUIP_SLOT_LEGS",
    "EQUIP_SLOT_FEET",
    "EQUIP_SLOT_RING1",
    "EQUIP_SLOT_RING2",
    "EQUIP_SLOT_HAND",
    "EQUIP_SLOT_BACKUP_MAIN",
    "EQUIP_SLOT_BACKUP_OFF",
    "EQUIP_SLOT_COSTME",
    "EQUIP_SLOT_POISON",
    "EQUIP_SLOT_BACKUP_POISON",

    -- ===========================================
    -- BAG CONSTANTS
    -- ===========================================
    "BAG_BACKPACK",
    "BAG_BANK",
    "BAG_WORN",
    "BAG_SUBSCRIBER_BANK",
    "BAG_VIRTUAL",
    "BAG_HOUSE_BANK_ONE",
    "BAG_HOUSE_BANK_TWO",
    "BAG_HOUSE_BANK_THREE",
    "BAG_HOUSE_BANK_FOUR",
    "BAG_HOUSE_BANK_FIVE",
    "BAG_HOUSE_BANK_SIX",
    "BAG_HOUSE_BANK_SEVEN",
    "BAG_HOUSE_BANK_EIGHT",
    "BAG_HOUSE_BANK_NINE",
    "BAG_HOUSE_BANK_TEN",

    -- ===========================================
    -- ITEM QUALITY CONSTANTS
    -- ===========================================
    "ITEM_QUALITY_TRASH",
    "ITEM_QUALITY_NORMAL",
    "ITEM_QUALITY_MAGIC",
    "ITEM_QUALITY_ARCANE",
    "ITEM_QUALITY_ARTIFACT",
    "ITEM_QUALITY_LEGENDARY",
    "ITEM_QUALITY_MYTHIC",
    "GetItemQualityColor",
    "GetItemLinkQualityColor",
    "ITEM_DISPLAY_QUALITY_TRASH",
    "ITEM_DISPLAY_QUALITY_NORMAL",
    "ITEM_DISPLAY_QUALITY_MAGIC",
    "ITEM_DISPLAY_QUALITY_ARCANE",
    "ITEM_DISPLAY_QUALITY_ARTIFACT",
    "ITEM_DISPLAY_QUALITY_LEGENDARY",
    "ITEM_DISPLAY_QUALITY_MYTHIC_OVERRIDE",

    -- ===========================================
    -- BIND TYPE CONSTANTS
    -- ===========================================
    "BIND_TYPE_NONE",
    "BIND_TYPE_ON_EQUIP",
    "BIND_TYPE_ON_PICKUP",
    "BIND_TYPE_ON_PICKUP_BACKPACK",

    -- ===========================================
    -- CHAMPION POINT FUNCTIONS
    -- ===========================================
    "GetChampionPointsEarned",
    "GetChampionXPInRank",
    "GetNumChampionDisciplines",
    "GetChampionDisciplineInfo",
    "GetChampionDisciplineId",
    "GetChampionDisciplineName",
    "GetNumChampionDisciplineSkills",
    "GetChampionSkillInfo",
    "GetChampionSkillName",
    "GetChampionSkillDesc",
    "GetChampionSkillSlotIndex",
    "GetChampionAbilityId",
    "GetNumSlottedChampionSkills",
    "GetSlottedChampionSkillId",
    "GetChampionBarSlotSkillId",
    "GetAssignedChampionPoints",
    "GetPlayerChampionXP",
    "CanChampionSkillTypeBeSlotted",
    "GetChampionDisciplineType",
    "CHAMPION_DISCIPLINE_TYPE_COMBAT",
    "CHAMPION_DISCIPLINE_TYPE_CONDITIONING",
    "CHAMPION_DISCIPLINE_TYPE_WORLD",

    -- ===========================================
    -- CURRENCY FUNCTIONS
    -- ===========================================
    "GetCurrencyAmount",
    "GetMaxPossibleCurrency",
    "CURT_MONEY",
    "CURT_TELVAR_STONES",
    "CURT_ALLIANCE_POINTS",
    "CURT_WRIT_VOUCHERS",
    "CURT_CHAOTIC_CREATIA",
    "CURT_SEALS_OF_ENDEAVOR",
    "CURT_CROWN_GEMS",
    "CURT_EVENT_TICKETS",
    "CURT_TRANSMUTE_CRYSTALS",
    "CURT_UNDAUNTED_KEYS",
    "CURT_ENDEAVOR_SEALS",

    -- ===========================================
    -- COLLECTIBLE FUNCTIONS
    -- ===========================================
    "GetCollectibleInfo",
    "GetCollectibleName",
    "GetCollectibleCategoryInfo",
    "GetNumCollectibleCategories",
    "GetNumCollectibles",
    "IsCollectibleUnlocked",
    "GetCollectibleCategoryType",
    "GetTotalCollectiblesByCategoryType",
    "GetUnlockedCollectiblesByCategoryType",
    "COLLECTIBLE_CATEGORY_TYPE_MOUNT",
    "COLLECTIBLE_CATEGORY_TYPE_VANITY_PET",
    "COLLECTIBLE_CATEGORY_TYPE_COSTUME",
    "COLLECTIBLE_CATEGORY_TYPE_PERSONALITY",
    "COLLECTIBLE_CATEGORY_TYPE_MEMENTO",
    "COLLECTIBLE_CATEGORY_TYPE_HOUSE",
    "COLLECTIBLE_CATEGORY_TYPE_FACIAL_ACCESSORY",
    "COLLECTIBLE_CATEGORY_TYPE_HAT",
    "COLLECTIBLE_CATEGORY_TYPE_SKIN",
    "COLLECTIBLE_CATEGORY_TYPE_POLYMORPH",
    "COLLECTIBLE_CATEGORY_TYPE_HAIR",
    "COLLECTIBLE_CATEGORY_TYPE_BODY_MARKING",
    "COLLECTIBLE_CATEGORY_TYPE_FACIAL_HAIR_HORNS",
    "COLLECTIBLE_CATEGORY_TYPE_HEAD_MARKING",
    "COLLECTIBLE_CATEGORY_TYPE_ASSISTANT",
    "COLLECTIBLE_CATEGORY_TYPE_DLC",

    -- ===========================================
    -- GUILD FUNCTIONS
    -- ===========================================
    "GetNumGuilds",
    "GetGuildId",
    "GetGuildName",
    "GetGuildDescription",
    "GetGuildMotD",
    "GetNumGuildMembers",
    "GetGuildMemberInfo",
    "GetGuildMemberCharacterInfo",
    "GetGuildRankInfo",
    "GetNumGuildRanks",
    "DoesPlayerHaveGuildPermission",
    "GetPlayerGuildMemberIndex",

    -- ===========================================
    -- PVP FUNCTIONS
    -- ===========================================
    "GetCampaignInfo",
    "GetCurrentCampaignId",
    "GetCampaignName",
    "GetPlayerAlliance",
    "GetAlliance",
    "GetAvARank",
    "GetAvARankProgress",
    "GetAvARankName",
    "GetNumCampaigns",
    "GetCampaignScoringBonus",
    "GetPlayerCampaignRewardData",
    "GetCampaignLeaderboardRankInfo",
    "IsBattlegroundInProgress",
    "GetCurrentBattlegroundId",

    -- ===========================================
    -- ACHIEVEMENT FUNCTIONS
    -- ===========================================
    "GetNumAchievements",
    "GetAchievementInfo",
    "GetAchievementCategoryInfo",
    "GetNumAchievementCategories",
    "GetAchievementRewardPoints",
    "GetAchievementPriorAchievementId",
    "GetAchievementNumCriteria",
    "GetAchievementCriterion",
    "GetEarnedAchievementPoints",
    "GetTotalAchievementPoints",

    -- ===========================================
    -- CRAFTING FUNCTIONS
    -- ===========================================
    "GetSkillLineCraftingGrowthType",
    "GetCraftingInteractionType",
    "GetLastCraftingResultItem",

    -- ===========================================
    -- COMPANION FUNCTIONS
    -- ===========================================
    "GetActiveCompanionDefId",
    "HasActiveCompanion",
    "GetCompanionName",
    "GetCompanionRapport",
    "GetCompanionRapportLevel",
    "GetCompanionRapportLevelName",
    "GetCompanionLevel",
    "GetCompanionXP",
    "GetCompanionXPForNextLevel",
    "GetNumUnlockedCompanions",
    "GetCompanionInfo",
    "GetCompanionCollectibleInfo",
    "COMPANION_RAPPORT_LEVEL_MIN",
    "COMPANION_RAPPORT_LEVEL_MAX",

    -- ===========================================
    -- ANTIQUITY FUNCTIONS
    -- ===========================================
    "GetNumAntiquityCategories",
    "GetAntiquityCategoryInfo",
    "GetNumAntiquities",
    "GetAntiquityInfo",
    "GetAntiquityName",
    "GetAntiquityQuality",
    "GetAntiquityType",
    "GetAntiquitySetInfo",
    "IsAntiquityComplete",

    -- ===========================================
    -- QUEST FUNCTIONS
    -- ===========================================
    "GetNumJournalQuests",
    "GetJournalQuestInfo",
    "GetJournalQuestName",
    "GetJournalQuestType",
    "GetJournalQuestZoneDisplayName",
    "GetJournalQuestConditionInfo",
    "IsJournalQuestComplete",
    "GetJournalQuestRepeatType",
    "GetJournalQuestNumSteps",
    "GetJournalQuestStepInfo",
    "GetJournalQuestNumConditions",

    -- ===========================================
    -- ZONE/WORLD FUNCTIONS
    -- ===========================================
    "GetCurrentMapId",
    "GetMapName",
    "GetZoneId",
    "GetZoneNameById",
    "GetPlayerActiveZoneName",
    "GetPlayerLocationName",
    "GetPlayerActiveSubzoneName",
    "GetUnitZone",
    "IsInCyrodiil",
    "IsInImperialCity",
    "IsInBattleground",
    "GetCurrentZoneHouseId",
    "GetHousingPrimaryHouseId",
    "GetHouseName",
    "GetCollectibleIdForHouse",
    "GetNumHousesTours",
    "GetNumOwnedHouses",
    
    -- ===========================================
    -- RIDING SKILL FUNCTIONS
    -- ===========================================
    "GetRidingStats",
    "GetMaxRidingTraining",
    "GetTimeUntilCanBeTrained",
    
    -- ===========================================
    -- BUFF/EFFECT FUNCTIONS
    -- ===========================================
    "GetNumBuffs",
    "GetUnitBuffInfo",
    "GetAbilityEffectDescription",
    "GetMundusStoneInfo",
    "GetNumMundusStones",
    "GetActiveMundusStoneId",

    -- ===========================================
    -- EVENT CONSTANTS
    -- ===========================================
    "EVENT_ADD_ON_LOADED",
    "EVENT_PLAYER_ACTIVATED",
    "EVENT_COLLECTIBLE_UNLOCKED",
    "EVENT_SKILL_RANK_UPDATE",
    "EVENT_SKILL_POINTS_CHANGED",
    "EVENT_TITLE_UNLOCKED",
    "EVENT_ANTIQUITY_UNLOCKED",
    "EVENT_HOUSE_OWNERSHIP_CHANGED",
    "EVENT_KEY_DOWN",
    "EVENT_KEY_UP",

    -- ===========================================
    -- KEYBOARD CONSTANTS
    -- ===========================================
    "KEY_ESCAPE",
    "KEY_A",
    "KEY_C",
    "KEY_V",
    "KEY_ENTER",

    -- ===========================================
    -- ARMORY FUNCTIONS
    -- ===========================================
    "GetNumUnlockedArmoryBuilds",
    "GetArmoryBuildInfo",
    "GetArmoryBuildName",
    "GetArmoryBuildIcon",
    "CanArmoryBuildBeApplied",
    "GetArmoryBuildData",

    -- ===========================================
    -- UNDAUNTED PLEDGE FUNCTIONS
    -- ===========================================
    "GetNumTotalUndauntedPledges",
    "GetUndauntedPledgeInfo",
    "GetDailyPledgeQuestIndex",
    "GetActivityFinderCurrentCooldowns",

    -- ===========================================
    -- MAIL FUNCTIONS
    -- ===========================================
    "GetNumUnreadMail",
    "GetMailItemInfo",

    -- ===========================================
    -- MISCELLANEOUS
    -- ===========================================
    "IsUnitInCombat",
    "IsUnitOnline",
    "IsUnitDead",
    "IsPlayerInGroup",
    "GetGroupSize",
    "GetEnlightenedMultiplier",
    "IsEnlightenedAvailableForCharacter",
    "GetEnlightenedPool",
    "GetCraftingSkillLineIndices",
    "SI_BINDING_NAME_TOGGLE_GUILD_MENU",
    "SI_CHAMPION_CONSTELLATION_NAME",
    "SI_ALLIANCE_NAME",

    -- ===========================================
    -- LIBRARY GLOBALS (Optional Dependencies)
    -- ===========================================
    "LibAddonMenu2",
    "LibDebugLogger",
    "LibSets",
    "LibSlashCommander",
    "LibCustomIcons",
}

-- Exclude test files and backup files
exclude_files = {
    "*.backup",
    ".task/**",
    "archive/**",
}