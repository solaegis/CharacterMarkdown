# ESO Lua API Documentation (API Version 101048)

> Comprehensive OpenAPI-style documentation of Elder Scrolls Online Lua API functions

---

## Table of Contents

- [VM Functions](#vm-functions)
- [Game API](#game-api)
  - [Organized by Function Type](#organized-by-function-type)
  - [Alphabetical Index](#alphabetical-index)
- [Object API](#object-api)
- [Function Protection Levels](#function-protection-levels)

---

## Overview

This document provides comprehensive documentation for the Elder Scrolls Online (ESO) Lua API, extracted from the official ESOUIDocumentation.txt file (API Version 101048).

### API Access Levels

- **Public**: Can be called anytime
- **Protected**: Can only be called out of combat
- **Private**: Cannot be called by addons

---

## VM Functions
Core Virtual Machine functions for script execution and security.
| Function | Parameters | Returns | Protection |
|----------|------------|---------|------------|
| `ScriptBuildInfo` | - | buildInfo: table | - |
| `LoadUntrustedString` | script: string | result: number | - |
| `SecurePostHook` | targetTable: table, functionName: string, hookingFunction: function | - | - |
| `InsecureNext` | table: table, lastKey: type | nextKey: type | - |
| `CallSecureProtected` | functionName: string, arguments: types | success: bool | - |
| `IsTrustedFunction` | function: function | isTrusted: bool | - |

---

## Game API

### Function Categories

| Category | Function Count |
|----------|----------------|
| [Other](#other) | 1733 |
| [Combat](#combat) | 241 |
| [Guild](#guild) | 214 |
| [Map](#map) | 214 |
| [Housing](#housing) | 196 |
| [Inventory](#inventory) | 188 |
| [Quest](#quest) | 161 |
| [Collections](#collections) | 140 |
| [Crafting](#crafting) | 129 |
| [Campaign](#campaign) | 122 |
| [Tribute](#tribute) | 121 |
| [Trading](#trading) | 120 |
| [UI](#ui) | 114 |
| [Character](#character) | 102 |
| [Social](#social) | 91 |
| [Time](#time) | 76 |
| [Antiquities](#antiquities) | 55 |
| [Achievement](#achievement) | 46 |
| [Mail](#mail) | 28 |
| [Settings](#settings) | 22 |
| [Bank](#bank) | 11 |

---

### Organized by Function Type

#### Miscellaneous

*1678 functions*

| Function | Parameters | Returns | Protection |
|----------|------------|---------|------------|
| **AbbreviateNumber** | `number`: integer<br>`precision`: [NumberAbbreviationPrecision|#NumberAbbreviationPrecision]<br>`useUppercaseSuffix`: bool | `abbreviatedValue`: number | Public |
| **AbortVideoPlayback** | - | - | Public |
| **AcceptActivityFindReplacementNotification** | - | - | Public |
| **AcceptAgentChat** | - | - | Public |
| **AcceptDuel** | - | - | Public |
| **AcceptGroupInvite** | - | - | Public |
| **AcceptLFGReadyCheckNotification** | - | - | Public |
| **AcceptResurrect** | - | - | Public |
| **AcceptWorldEventInvite** | `eventId`: integer | - | Public |
| **ActionSlotHasActivationHighlight** | `actionSlotIndex`: luaindex<br>`hotbarCategory`: [HotBarCategory|#HotBarCategory]:nilable | `status`: bool | Public |
| **ActionSlotHasCostFailure** | `actionSlotIndex`: luaindex<br>`hotbarCategory`: [HotBarCategory|#HotBarCategory]:nilable | `status`: bool | Public |
| **ActionSlotHasFallingFailure** | `actionSlotIndex`: luaindex<br>`hotbarCategory`: [HotBarCategory|#HotBarCategory]:nilable | `status`: bool | Public |
| **ActionSlotHasLeapKeepTargetFailure** | `actionSlotIndex`: luaindex<br>`hotbarCategory`: [HotBarCategory|#HotBarCategory]:nilable | `status`: bool | Public |
| **ActionSlotHasMountedFailure** | `actionSlotIndex`: luaindex<br>`hotbarCategory`: [HotBarCategory|#HotBarCategory]:nilable | `status`: bool | Public |
| **ActionSlotHasNonCostStateFailure** | `actionSlotIndex`: luaindex<br>`hotbarCategory`: [HotBarCategory|#HotBarCategory]:nilable | `status`: bool | Public |
| **ActionSlotHasRangeFailure** | `actionSlotIndex`: luaindex<br>`hotbarCategory`: [HotBarCategory|#HotBarCategory]:nilable | `status`: bool | Public |
| **ActionSlotHasReincarnatingFailure** | `actionSlotIndex`: luaindex<br>`hotbarCategory`: [HotBarCategory|#HotBarCategory]:nilable | `status`: bool | Public |
| **ActionSlotHasStatusEffectFailure** | `actionSlotIndex`: luaindex<br>`hotbarCategory`: [HotBarCategory|#HotBarCategory]:nilable | `status`: bool | Public |
| **ActionSlotHasSwimmingFailure** | `actionSlotIndex`: luaindex<br>`hotbarCategory`: [HotBarCategory|#HotBarCategory]:nilable | `status`: bool | Public |
| **ActionSlotHasTargetFailure** | `actionSlotIndex`: luaindex<br>`hotbarCategory`: [HotBarCategory|#HotBarCategory]:nilable | `status`: bool | Public |
| **AddActivityFinderSetSearchEntry** | `activitySetId`: integer | - | Public |
| **AddActivityFinderSpecificSearchEntry** | `activityId`: integer | - | Public |
| **AddBackgroundListFilterEntry** | `taskId`: integer<br>`value1`: integer<br>`value2`: integer<br>*+2 more* | - | Public |
| **AddBackgroundListFilterEntry64** | `taskId`: integer<br>`value`: id64 | - | Public |
| **AddBackgroundListFilterType** | `taskId`: integer<br>`filterType`: [BackgroundListFilterType|#BackgroundListFilterType] | - | Public |
| **AddChatContainer** | - | - | Public |
| **AddChatContainerTab** | `chatContainerIndex`: luaindex<br>`name`: string<br>`isCombatLog`: bool | - | Public |
| **AddItemToConsumeAttunableStationsMessage** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `wasItemAdded`: bool | Public |
| **AddItemToDeconstructMessage** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer<br>`quantity`: integer | `wasItemAdded`: bool | Public |
| **AddPartialPendingNarrationText** | `text`: string | - | Public |
| **AddPendingNarrationText** | `text`: string | - | Public |
| **AddSCTCloudOffset** | `SCTCloudId`: integer<br>`ordering`: integer<br>`UIOffsetX`: number<br>*+1 more* | - | Public |
| **AddSCTSlotAllowedSourceType** | `slotIndex`: luaindex<br>`sourceType`: [SCTUnitType|#SCTUnitType] | - | Public |
| **AddSCTSlotAllowedTargetType** | `slotIndex`: luaindex<br>`targetType`: [SCTUnitType|#SCTUnitType] | - | Public |
| **AddSCTSlotExcludedSourceType** | `slotIndex`: luaindex<br>`sourceType`: [SCTUnitType|#SCTUnitType] | - | Public |
| **AddSCTSlotExcludedTargetType** | `slotIndex`: luaindex<br>`targetType`: [SCTUnitType|#SCTUnitType] | - | Public |
| **AgreeToEULA** | `eulaType`: [EULAType|#EULAType] | - | Public |
| **ApplyChangesToPreviewCollectionShown** | `previewOption`: [PreviewOption|#PreviewOption] | - | Public |
| **ApplyPendingDyes** | `restyleMode`: [RestyleMode|#RestyleMode] | - | Public |
| **ApplyPendingHeraldryChanges** | - | - | Public |
| **AreAllTradingHouseSearchResultsPurchased** | - | `allResultsPurchased`: bool | Public |
| **AreAnyItemsStolen** | `bagId`: [Bag|#Bag] | `anyItemsStolen`: bool | Public |
| **AreCompanionSkillsInitialized** | - | `initialized`: bool | Public |
| **AreDyeChannelsDyeableForOutfitSlotData** | `actorCategory`: [GameplayActorCategory|#GameplayActorCategory]<br>`outfitSlot`: [OutfitSlot|#OutfitSlot]<br>`collectibleId`: integer | `primary`: bool | Public |
| **AreId64sEqual** | `firstId`: id64<br>`secondId`: id64 | `areEqual`: bool | Public |
| **AreItemDyeChannelsDyeable** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `primary`: bool | Public |
| **AreRestyleSlotDyeChannelsDyeable** | `restyleMode`: [RestyleMode|#RestyleMode]<br>`restyleSetIndex`: luaindex<br>`restyleSlot`: integer | `primary`: bool | Public |
| **AreSkillsInitialized** | - | `areInitialized`: bool | Public |
| **AreUnitsCurrentlyAllied** | `unitTag1`: string<br>`unitTag2`: string | `allied`: bool | Public |
| **AreUnitsEqual** | `unitTag`: string<br>`secondUnitTag`: string | `areEqual`: bool | Public |
| **AreUserAddOnsSupported** | - | `areUserAddOnsSupported`: bool | Public |
| **AssignTargetMarkerToReticleTarget** | `targetMarkerType`: [TargetMarkerType|#TargetMarkerType] | - | Public |
| **BCP47StringForZoOfficialLanguage** | `language`: [OfficialLanguage|#OfficialLanguage] | `languageDescriptor`: string | Public |
| **BeginGroupElection** | `electionType`: [GroupElectionType|#GroupElectionType]<br>`electionDescriptor`: string<br>`targetUnitTag`: string<br>*+1 more* | `sentSuccessfully`: bool | Public |
| **BeginItemPreviewSpin** | - | - | Public |
| **BeginRestyling** | `restyleMode`: [RestyleMode|#RestyleMode] | - | Public |
| **BindItem** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | - | Public |
| **BitAnd** | `valueA`: integer53<br>`valueB`: integer53 | `result`: integer53 | Public |
| **BitLShift** | `value`: integer53<br>`numBits`: integer | `result`: integer53 | Public |
| **BitNot** | `value`: integer53<br>`numBits`: integer | `result`: integer53 | Public |
| **BitOr** | `valueA`: integer53<br>`valueB`: integer53 | `result`: integer53 | Public |
| **BitRShift** | `value`: integer53<br>`numBits`: integer | `result`: integer53 | Public |
| **BitXor** | `valueA`: integer53<br>`valueB`: integer53 | `result`: integer53 | Public |
| **BlockAutomaticInputModeChange** | `shouldBlock`: bool | - | Public |
| **BroadcastAddOnDataToGroup** | `authKey`: integer<br>`data`: integer | `result`: [GroupAddOnDataBroadcastResult|#GroupAddOnDataBroadcastResult] | Public |
| **BuyBagSpace** | - | - | Public |
| **BuybackItem** | `entryIndex`: luaindex | - | Public |
| **CalculateCubicBezierEase** | `progress`: number<br>`x1`: number<br>`y1`: number<br>*+2 more* | `result`: number | Public |
| **CameraZoomIn** | - | - | Public |
| **CameraZoomOut** | - | - | Public |
| **CanBuyFromTradingHouse** | `guildId`: integer | `canBuy`: bool | Public |
| **CanChampionSkillTypeBeSlotted** | `championSkillType`: [ChampionSkillType|#ChampionSkillType] | `isSlottable`: bool | Public |
| **CanChangeBattleLevelPreference** | - | `canChangeBattleLevelPreference`: bool | Public |
| **CanCombinationFragmentBeUnlocked** | `collectibleId`: integer | `canBeUnlocked`: bool | Public |
| **CanCommunicateWith** | `characterOrDisplayName`: string<br>`consoleId`: id64 | `isCommunicationPermitted`: bool | Public |
| **CanConvertItemStyle** | `itemToBagId`: [Bag|#Bag]<br>`itemToSlotIndex`: integer<br>`newStyle`: integer | `canConvert`: bool | Public |
| **CanExitInstanceImmediately** | - | `canExitInstanceImmediately`: bool | Public |
| **CanFavoriteHouses** | - | `canFavorite`: bool | Public |
| **CanInteractWithCrownCratesSystem** | - | `canInteractWithCrownCratesSystem`: bool | Public |
| **CanInteractWithItem** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `canInteract`: bool | Public |
| **CanItemBeDeconstructed** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer<br>`craftingSkillType`: [TradeskillType|#TradeskillType]:nilable | `canItemBeDeconstructed`: bool | Public |
| **CanItemBeMarkedAsJunk** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `canBeMarkedAsJunk`: bool | Public |
| **CanItemBePlayerLocked** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `canBePlayerLocked`: bool | Public |
| **CanItemBeRefined** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer<br>`craftingSkillType`: [TradeskillType|#TradeskillType] | `canItemBeRefined`: bool | Public |
| **CanItemBeRetraited** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `canBeRetraited`: bool | Public |
| **CanItemBeUsedToLearn** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `canBeUsedToLearn`: bool | Public |
| **CanItemBeVirtual** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `canBeVirtualItem`: bool | Public |
| **CanItemLinkBePreviewed** | `itemLink`: string | `canPreview`: bool | Public |
| **CanItemLinkBeTraitResearched** | `itemLink`: string | `canBeResearched`: bool | Public |
| **CanItemLinkBeUsedToLearn** | `itemLink`: string | `canBeUsedToLearn`: bool | Public |
| **CanItemLinkBeVirtual** | `itemLink`: string | `canBeVirtual`: bool | Public |
| **CanJumpToGroupMember** | `unitTag`: string | `canJump`: bool | Public |
| **CanKeepBeFastTravelledTo** | `keepId`: integer<br>`battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType] | `canKeepBeFastTravelledTo`: bool | Public |
| **CanPerkBeSlottedInSlotForRole** | `slotIndex`: luaindex<br>`aSlotFlag`: [VengeancePerkSlotFlags|#VengeancePerkSlotFlags]<br>`roleIndex`: luaindex:nilable | `result`: [VengeanceActionResult|#VengeanceActionResult] | Public |
| **CanPlayerChangeGroupDifficulty** | - | `canChange`: bool | Public |
| **CanPlayerUseCostumeDyeStamp** | `dyeStampId`: integer | `dyeStampUseResult`: [DyeStampUseResult|#DyeStampUseResult] | Public |
| **CanPlayerUseItemDyeStamp** | `dyeStampId`: integer | `dyeStampUseResult`: [DyeStampUseResult|#DyeStampUseResult] | Public |
| **CanPreviewReward** | `rewardId`: integer | `canPreview`: bool | Public |
| **CanQueueItemAttachment** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer<br>`attachmentSlot`: luaindex | `canAttach`: bool | Public |
| **CanRecommendHouses** | - | `canRecommendedHouses`: bool | Public |

*... and 1578 more functions in this category*

#### Combat & Abilities

*242 functions*

| Function | Parameters | Returns | Protection |
|----------|------------|---------|------------|
| **ActionSlotHasEffectiveSlotAbilityData** | `actionSlotIndex`: luaindex<br>`hotbarCategory`: [HotBarCategory|#HotBarCategory]:nilable | `hasEffectiveSlotAbilityData`: bool | Public |
| **ActionSlotHasWeaponSlotFailure** | `actionSlotIndex`: luaindex<br>`hotbarCategory`: [HotBarCategory|#HotBarCategory]:nilable | `status`: bool | Public |
| **ArePlayerWeaponsSheathed** | - | `weaponsAreSheathed`: bool | Public |
| **CanAbilityBeUsedFromHotbar** | `abilityId`: integer<br>`hotbarCategory`: [HotBarCategory|#HotBarCategory] | `canBeUsed`: bool | Public |
| **CanSiegeWeaponAim** | - | `canAim`: bool | Public |
| **CanSiegeWeaponFire** | - | `canFire`: bool | Public |
| **CanSiegeWeaponPackUp** | - | `canPackup`: bool | Public |
| **CanSmithingWeaponPatternsBeCraftedHere** | - | `canBeCrafted`: bool | Public |
| **ChooseAbilityProgressionMorph** | `progressionIndex`: luaindex<br>`morph`: integer | - | Public |
| **DidDeathCauseDurabilityDamage** | - | `causedDurabilityDamage`: bool | Public |
| **DoesAbilityExist** | `abilityId`: integer | `exists`: bool | Public |
| **DoesItemHaveDurability** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `hasDurability`: bool | Public |
| **DoesKillingAttackHaveAttacker** | `index`: luaindex | `hasAttacker`: bool | Public |
| **GenerateCraftedAbilityScriptSlotDescriptionForAbilityDescription** | `abilityId`: integer<br>`slotType`: [ScribingSlot|#ScribingSlot]<br>`casterUnitTag`: string | `description`: string | Public |
| **GetAbilityAdvancedStatAndEffectByIndex** | `abilityId`: integer<br>`index`: luaindex | `advancedStat`: [AdvancedStatDisplayType|#AdvancedStatDisplayType] | Public |
| **GetAbilityAngleDistance** | `abilityId`: integer | `angleDistance`: integer:nilable | Public |
| **GetAbilityBaseCostInfo** | `abilityId`: integer<br>`overrideRank`: integer:nilable<br>`casterUnitTag`: string | `baseCost`: integer:nilable | Public |
| **GetAbilityBuffType** | `abilityId`: integer<br>`casterUnitTag`: string | `buffType`: [BuffType|#BuffType] | Public |
| **GetAbilityCastInfo** | `abilityId`: integer<br>`overrideRank`: integer:nilable<br>`casterUnitTag`: string | `channeled`: bool:nilable | Public |
| **GetAbilityCooldown** | `abilityId`: integer<br>`casterUnitTag`: string | `durationMs`: integer:nilable | Public |
| **GetAbilityCost** | `abilityId`: integer<br>`mechanicFlag`: [CombatMechanicFlags|#CombatMechanicFlags]<br>`overrideRank`: integer:nilable<br>*+1 more* | `cost`: integer | Public |
| **GetAbilityCostPerTick** | `abilityId`: integer<br>`mechanic`: [CombatMechanicFlags|#CombatMechanicFlags]<br>`overrideRank`: integer:nilable | `costPerTick`: integer | Public |
| **GetAbilityCraftedAbilityId** | `abilityId`: integer | `craftedAbilityId`: integer | Public |
| **GetAbilityDerivedStatAndEffectByIndex** | `abilityId`: integer<br>`index`: luaindex | `derivedStat`: [DerivedStats|#DerivedStats] | Public |
| **GetAbilityDescription** | `abilityId`: integer<br>`overrideRank`: integer:nilable<br>`casterUnitTag`: string | `description`: string | Public |
| **GetAbilityDescriptionHeader** | `abilityId`: integer<br>`casterUnitTag`: string | `header`: string | Public |
| **GetAbilityDuration** | `abilityId`: integer<br>`overrideRank`: integer:nilable<br>`casterUnitTag`: string | `durationMs`: integer:nilable | Public |
| **GetAbilityEffectDescription** | `effectSlotId`: integer | `description`: string | Public |
| **GetAbilityEndlessDungeonBuffBucketType** | `abilityId`: integer | `buffBucketType`: [EndlessDungeonBuffBucketType|#EndlessDungeonBuffBucketType] | Public |
| **GetAbilityEndlessDungeonBuffType** | `abilityId`: integer | `buffType`: [EndlessDungeonBuffType|#EndlessDungeonBuffType] | Public |
| **GetAbilityFrequencyMS** | `abilityId`: integer<br>`casterUnitTag`: string | `frequencyMS`: integer:nilable | Public |
| **GetAbilityFxOverrideProgressionId** | `abilityFxOverrideId`: integer | `progressionId`: integer | Public |
| **GetAbilityIcon** | `abilityId`: integer | `icon`: textureName | Public |
| **GetAbilityIdByIndex** | `abilityIndex`: luaindex | `abilityId`: integer | Public |
| **GetAbilityIdForCraftedAbilityId** | `craftedAbilityId`: integer | `abilityId`: integer | Public |
| **GetAbilityIdForHotbarSlotAtIndex** | `roleIndex`: luaindex<br>`hotbar`: [HotBarCategory|#HotBarCategory]<br>`slot`: luaindex | `abilityId`: integer | Public |
| **GetAbilityIdFromLink** | `link`: string | `abilityId`: integer | Public |
| **GetAbilityInfoByIndex** | `abilityIndex`: luaindex | `name`: string | Public |
| **GetAbilityLink** | `abilityId`: integer<br>`linkStyle`: [LinkStyle|#LinkStyle] | `link`: string | Public |
| **GetAbilityMundusStoneType** | `abilityId`: integer | `mundusStoneType`: [MundusStone|#MundusStone] | Public |
| **GetAbilityName** | `abilityId`: integer<br>`casterUnitTag`: string | `abilityName`: string | Public |
| **GetAbilityNewEffectLines** | `abilityId`: integer | `newEffect`: string | Public |
| **GetAbilityNumAdvancedStats** | `abilityId`: integer | `numAdvancedStats`: integer | Public |
| **GetAbilityNumDerivedStats** | `abilityId`: integer | `numDerivedStats`: integer | Public |
| **GetAbilityProgressionAbilityId** | `progressionIndex`: luaindex<br>`morph`: integer<br>`rank`: integer | `abilityId`: integer | Public |
| **GetAbilityProgressionAbilityInfo** | `progressionIndex`: luaindex<br>`morph`: integer<br>`rank`: integer | `name`: string | Public |
| **GetAbilityProgressionInfo** | `progressionIndex`: luaindex | `name`: string | Public |
| **GetAbilityProgressionRankFromAbilityId** | `abilityId`: integer | `rank`: integer:nilable | Public |
| **GetAbilityProgressionXPInfo** | `progressionIndex`: luaindex | `lastRankXp`: integer | Public |
| **GetAbilityProgressionXPInfoFromAbilityId** | `abilityId`: integer | `hasProgression`: bool | Public |
| **GetAbilityRadius** | `abilityId`: integer<br>`overrideRank`: integer:nilable<br>`casterUnitTag`: string | `radius`: integer:nilable | Public |
| **GetAbilityRange** | `abilityId`: integer<br>`overrideRank`: integer:nilable<br>`casterUnitTag`: string | `minRangeCM`: integer:nilable | Public |
| **GetAbilityRoles** | `abilityId`: integer | `isTankRoleAbility`: bool | Public |
| **GetAbilityTargetDescription** | `abilityId`: integer<br>`overrideRank`: integer:nilable<br>`casterUnitTag`: string | `targetDescription`: string:nilable | Public |
| **GetAbilityUpgradeLines** | `abilityId`: integer | `label`: string | Public |
| **GetActionBarLockedReason** | - | `actionBarLockedReason`: [ActionBarLockedReason|#ActionBarLockedReason] | Public |
| **GetActionBindingInfo** | `layerIndex`: luaindex<br>`categoryIndex`: luaindex<br>`actionIndex`: luaindex<br>*+1 more* | `keyCode`: [KeyCode|#KeyCode] | Public |
| **GetActionDefaultBindingInfo** | `layerIndex`: luaindex<br>`categoryIndex`: luaindex<br>`actionIndex`: luaindex<br>*+1 more* | `keyCode`: [KeyCode|#KeyCode] | Public |
| **GetActionIndicesFromName** | `actionName`: string | `layerIndex`: luaindex:nilable | Public |
| **GetActionInfo** | `layerIndex`: luaindex<br>`categoryIndex`: luaindex<br>`actionIndex`: luaindex | `actionName`: string | Public |
| **GetActionLayerCategoryInfo** | `layerIndex`: luaindex<br>`categoryIndex`: luaindex | `categoryName`: string | Public |
| **GetActionLayerInfo** | `layerIndex`: luaindex | `layerName`: string | Public |
| **GetActionLayerNameByIndex** | `layerIndex`: luaindex | `layerName`: string | Public |
| **GetActionNameFromKey** | `layerName`: string<br>`keyCode`: [KeyCode|#KeyCode] | `actionName`: string | Public |
| **GetActionSlotEffectDuration** | `actionSlotIndex`: luaindex<br>`hotbarCategory`: [HotBarCategory|#HotBarCategory]:nilable | `durationMilliseconds`: integer | Public |
| **GetActionSlotEffectStackCount** | `actionSlotIndex`: luaindex<br>`hotbarCategory`: [HotBarCategory|#HotBarCategory]:nilable | `stackCount`: integer | Public |
| **GetActionSlotEffectTimeRemaining** | `actionSlotIndex`: luaindex<br>`hotbarCategory`: [HotBarCategory|#HotBarCategory]:nilable | `timeRemainingMilliseconds`: integer | Public |
| **GetActionSlotUnlockText** | `actionSlotIndex`: luaindex<br>`hotbarCategory`: [HotBarCategory|#HotBarCategory] | `slotUnlockText`: string | Public |
| **GetActiveCombatTipInfo** | `activeCombatTipId`: integer | `name`: string | Public |
| **GetActiveProgressionSkillAbilityFxOverrideCollectibleId** | `progressionId`: integer | `collectibleId`: integer | Public |
| **GetActiveWeaponPairInfo** | - | `activeWeaponPair`: [ActiveWeaponPair|#ActiveWeaponPair] | Public |
| **GetArtifactScoreBonusAbilityId** | `alliance`: [Alliance|#Alliance]<br>`artifactType`: [ObjectiveType|#ObjectiveType]<br>`index`: luaindex | `abilityId`: integer | Public |
| **GetAssignableAbilityBarStartAndEndSlots** | - | `startActionSlotIndex`: luaindex | Public |
| **GetAssignedSlotFromSkillAbility** | `skillType`: [SkillType|#SkillType]<br>`skillLineIndex`: luaindex<br>`skillIndex`: luaindex | `actionSlotIndex`: luaindex:nilable | Public |
| **GetChampionAbilityId** | `championSkillId`: integer | `abilityId`: integer | Public |
| **GetChampionClusterBackgroundTexture** | `rootChampionSkillId`: integer | `texture`: textureName | Public |
| **GetChampionClusterName** | `rootChampionSkillId`: integer | `clusterName`: string | Public |
| **GetChampionClusterRootOffset** | `championSkillId`: integer | `normalizedOffsetX`: number | Public |
| **GetChampionClusterSkillIds** | `rootChampionSkillId`: integer | `championSkillIds`: integer | Public |
| **GetChampionDisciplineId** | `disciplineIndex`: luaindex | `disciplineId`: integer | Public |
| **GetChampionDisciplineName** | `disciplineId`: integer | `name`: string | Public |
| **GetChampionDisciplineSelectedZoomedOutOverlay** | `disciplineId`: integer | `texture`: textureName | Public |
| **GetChampionDisciplineType** | `disciplineId`: integer | `disciplineType`: [ChampionDisciplineType|#ChampionDisciplineType] | Public |
| **GetChampionDisciplineZoomedInBackground** | `disciplineId`: integer | `texture`: textureName | Public |
| **GetChampionDisciplineZoomedOutBackground** | `disciplineId`: integer | `texture`: textureName | Public |
| **GetChampionPointPoolForRank** | `rank`: integer | `disciplineType`: [ChampionDisciplineType|#ChampionDisciplineType] | Public |
| **GetChampionPointsPlayerProgressionCap** | - | `maxRank`: integer | Public |
| **GetChampionPurchaseAvailability** | - | `result`: [ChampionPurchaseResult|#ChampionPurchaseResult] | Public |
| **GetChampionRespecCost** | - | `cost`: integer | Public |
| **GetChampionSkillCurrentBonusText** | `championSkillId`: integer<br>`numPendingPoints`: integer | `currentBonus`: string | Public |
| **GetChampionSkillDescription** | `championSkillId`: integer<br>`numPendingPoints`: integer | `description`: string | Public |
| **GetChampionSkillId** | `disciplineIndex`: luaindex<br>`championSkillIndex`: luaindex | `championSkillId`: integer | Public |
| **GetChampionSkillJumpPoints** | `championSkillId`: integer | `jumpPoint`: integer | Public |
| **GetChampionSkillLinkIds** | `championSkillId`: integer | `linkedSkillId`: integer | Public |
| **GetChampionSkillMaxPoints** | `championSkillId`: integer | `maxPoints`: integer | Public |
| **GetChampionSkillName** | `championSkillId`: integer | `skillName`: string | Public |
| **GetChampionSkillPosition** | `championSkillId`: integer | `normalizedX`: number | Public |
| **GetChampionSkillType** | `championSkillId`: integer | `championSkillType`: [ChampionSkillType|#ChampionSkillType] | Public |
| **GetCollectiblePlayerFxOverrideAbilityType** | `collectibleId`: integer | `playerFxOverrideAbilityType`: [PlayerFxOverrideAbilityType|#PlayerFxOverrideAbilityType]:nilable | Public |
| **GetCompanionAbilityId** | `skillLineId`: integer<br>`abilityIndex`: luaindex | `abilityId`: integer | Public |

*... and 142 more functions in this category*

#### Map & Navigation

*221 functions*

| Function | Parameters | Returns | Protection |
|----------|------------|---------|------------|
| **ActionSlotHasSubzoneFailure** | `actionSlotIndex`: luaindex<br>`hotbarCategory`: [HotBarCategory|#HotBarCategory]:nilable | `status`: bool | Public |
| **ActivateSkillLinesInAllocationRequest** | `skillLineIdsToDeactivate`: integer | - | Public |
| **AddActiveChangeToAllocationRequest** | `skillLineId`: integer<br>`progressionId`: integer<br>`morphSlot`: [MorphSlot|#MorphSlot]<br>*+1 more* | - | Public |
| **AddHotbarSlotChangeToAllocationRequest** | `actionSlotIndex`: luaindex<br>`hotbarCategory`: [HotBarCategory|#HotBarCategory]<br>`actionType`: [ActionBarSlotType|#ActionBarSlotType]<br>*+1 more* | - | Public |
| **AddMapAntiquityDigSitePins** | - | - | Public |
| **AddMapPin** | `pinType`: [MapDisplayPinType|#MapDisplayPinType]<br>`param1`: integer<br>`param2`: integer<br>*+1 more* | - | Public |
| **AddMapQuestPins** | `journalQuestIndex`: luaindex<br>`trackingLevel`: [TrackingLevel|#TrackingLevel] | - | Public |
| **AddMapZoneStoryPins** | - | - | Public |
| **AddPassiveChangeToAllocationRequest** | `skillLineId`: integer<br>`abilityId`: integer<br>`isRemoval`: bool | - | Public |
| **AddTrainingToAllocationRequest** | `skillLineIdsToTrain`: integer | - | Public |
| **AreAllZoneStoryActivitiesCompleteForZoneCompletionType** | `zoneId`: integer<br>`zoneCompletionType`: [ZoneCompletionType|#ZoneCompletionType] | `isComplete`: bool | Public |
| **CanJumpToHouseFromCurrentLocation** | - | `canJumpToHouseFromCurrentLocation`: bool | Public |
| **CanJumpToPlayerInZone** | `zoneId`: integer | `canJump`: bool | Public |
| **CanLeaveCurrentLocationViaTeleport** | - | `canLeaveCurrentLocationViaTeleport`: bool | Public |
| **CanZoneStoryContinueTrackingActivities** | `zoneId`: integer | `canContinueTracking`: bool | Public |
| **CanZoneStoryContinueTrackingActivitiesForCompletionType** | `zoneId`: integer<br>`zoneCompletionType`: [ZoneCompletionType|#ZoneCompletionType] | `canContinueTracking`: bool | Public |
| **ClearAutoMapNavigationTarget** | - | - | Public |
| **ClearTrackedZoneStory** | - | - | Public |
| **DeactivateSkillLinesInAllocationRequest** | `skillLineIdsToDeactivate`: integer | - | Public |
| **DoesCurrentMapMatchMapForPlayerLocation** | - | `matches`: bool | Public |
| **DoesCurrentMapShowPlayerWorld** | - | `isInMap`: bool | Public |
| **DoesCurrentZoneAllowBattleLevelScaling** | - | `allowsBattleLevelScaling`: bool | Public |
| **DoesCurrentZoneAllowScalingByLevel** | - | `allowsScaling`: bool | Public |
| **DoesCurrentZoneHaveTelvarStoneBehavior** | - | `telvarBehaviorEnabled`: bool | Public |
| **DoesHistoryRequireMapRebuild** | `battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType]<br>`oldHistoryPercent`: number<br>`newHistoryPercent`: number | `needsRebuild`: bool | Public |
| **DoesKeepPassCompassVisibilitySubzoneCheck** | `keepId`: integer<br>`battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType] | `doesPassVisibilityCheck`: bool | Public |
| **DoesObjectivePassCompassVisibilitySubzoneCheck** | `keepId`: integer<br>`objectiveId`: integer<br>`battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType] | `doesPassVisiblityCheck`: bool | Public |
| **DoesZoneCompletionTypeInZoneHaveBranchesWithDifferentLengths** | `zoneId`: integer<br>`zoneCompletionType`: [ZoneCompletionType|#ZoneCompletionType] | `hasBranchesWithDifferentLengths`: bool | Public |
| **GenerateMapPingTooltipLine** | `mapPingType`: [MapDisplayPinType|#MapDisplayPinType]<br>`unitTag`: string | `text`: string | Public |
| **GetActiveSpectacleEventIdsForZoneIndex** | `zoneIndex`: luaindex | `activeSpectacleEventId`: integer | Public |
| **GetActivityZoneId** | `activityId`: integer | `zoneId`: integer | Public |
| **GetAntiquityZoneId** | `antiquityId`: integer | `zoneId`: integer | Public |
| **GetAssociatedAchievementIdForZoneCompletionType** | `zoneId`: integer<br>`zoneCompletionType`: [ZoneCompletionType|#ZoneCompletionType]<br>`associatedAchievementIndex`: luaindex | `associatedAchievementId`: integer | Public |
| **GetAutoMapNavigationCommonZoomOutMapIndex** | - | `commonMapIndex`: luaindex:nilable | Public |
| **GetAutoMapNavigationNormalizedPositionForCurrentMap** | - | `normalizedX`: number | Public |
| **GetCadwellZoneInfo** | `cadwellProgressionLevel`: [CadwellProgressionLevel|#CadwellProgressionLevel]<br>`zoneIndex`: luaindex | `zoneName`: string | Public |
| **GetCadwellZonePOIInfo** | `cadwellProgressionLevel`: [CadwellProgressionLevel|#CadwellProgressionLevel]<br>`zoneIndex`: luaindex<br>`poiIndex`: luaindex | `poiName`: string | Public |
| **GetCollectibleIdForZone** | `zoneIndex`: luaindex | `collectibleId`: integer | Public |
| **GetCompletedQuestLocationInfo** | `questId`: integer | `zoneName`: string | Public |
| **GetCurrentMapId** | - | `mapId`: integer | Public |
| **GetCurrentMapIndex** | - | `index`: luaindex:nilable | Public |
| **GetCurrentMapZoneIndex** | - | `zoneIndex`: luaindex | Public |
| **GetCurrentSubZonePOIIndices** | - | `zoneIndex`: luaindex:nilable | Public |
| **GetCurrentZoneDungeonDifficulty** | - | `isVeteranDifficulty`: [DungeonDifficulty|#DungeonDifficulty] | Public |
| **GetCurrentZoneHouseId** | - | `houseId`: integer | Public |
| **GetCurrentZoneLevelScalingConstraints** | - | `scaleLevelContraintType`: [ScaleLevelConstraintType|#ScaleLevelConstraintType] | Public |
| **GetCyrodiilMapIndex** | - | `index`: luaindex:nilable | Public |
| **GetFastTravelNodeMapPriority** | `nodeIndex`: luaindex | `mapPriority`: integer:nilable | Public |
| **GetHouseFoundInZoneId** | `houseId`: integer | `zoneId`: integer | Public |
| **GetHouseZoneId** | `houseId`: integer | `zoneId`: integer | Public |
| **GetImperialCityMapIndex** | - | `index`: luaindex:nilable | Public |
| **GetJournalQuestLocationInfo** | `journalQuestIndex`: luaindex | `zoneName`: string | Public |
| **GetJournalQuestStartingZone** | `journalQuestIndex`: luaindex | `zoneIndex`: luaindex | Public |
| **GetJournalQuestZoneDisplayType** | `journalQuestIndex`: luaindex | `zoneDisplayType`: [ZoneDisplayType|#ZoneDisplayType] | Public |
| **GetJournalQuestZoneStoryZoneId** | `journalQuestIndex`: luaindex | `zoneId`: integer | Public |
| **GetKeepAccessible** | `keepId`: integer<br>`bgContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType] | `accessible`: bool | Public |
| **GetKeepAlliance** | `keepId`: integer<br>`battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType] | `alliance`: integer | Public |
| **GetKeepArtifactObjectiveId** | `keepId`: integer | `objectiveId`: integer | Public |
| **GetKeepCaptureBonusPercent** | `keepId`: integer<br>`battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType] | `keepCaptureBonusPercent`: integer | Public |
| **GetKeepDefensiveLevel** | `keepId`: integer<br>`battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType] | `defensiveLevel`: integer | Public |
| **GetKeepDirectionalAccess** | `keepId`: integer<br>`battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType] | `directionalAccess`: [KeepPieceDirectionalAccess|#KeepPieceDirectionalAccess] | Public |
| **GetKeepFastTravelInteraction** | - | `startKeepId`: integer:nilable | Public |
| **GetKeepHasResourcesForTravel** | `keepId`: integer<br>`bgContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType] | `hasResources`: bool | Public |
| **GetKeepKeysByIndex** | `index`: luaindex | `keepId`: integer | Public |
| **GetKeepMaxUpgradeLevel** | `keepId`: integer | `maxLevel`: integer | Public |
| **GetKeepName** | `keepId`: integer | `keepName`: string | Public |
| **GetKeepPinInfo** | `keepId`: integer<br>`battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType] | `pinType`: integer | Public |
| **GetKeepProductionLevel** | `keepId`: integer<br>`battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType] | `productionLevel`: integer | Public |
| **GetKeepRecallAvailable** | `keepId`: integer<br>`battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType] | `canRecall`: bool | Public |
| **GetKeepResourceInfo** | `keepId`: integer<br>`battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType]<br>`resourceType`: [KeepResourceType|#KeepResourceType]<br>*+1 more* | `currentAmount`: integer | Public |
| **GetKeepResourceLevel** | `keepId`: integer<br>`battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType]<br>`resourceType`: [KeepResourceType|#KeepResourceType] | `resourceLevel`: integer | Public |
| **GetKeepResourceType** | `keepId`: integer | `resourceType`: [KeepResourceType|#KeepResourceType] | Public |
| **GetKeepThatHasCapturedThisArtifactScrollObjective** | `keepId`: integer<br>`objectiveId`: integer<br>`battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType] | `capturedAtKeepId`: integer | Public |
| **GetKeepTravelNetworkLinkEndpoints** | `linkIndex`: luaindex<br>`bgContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType] | `keepAIndex`: luaindex | Public |
| **GetKeepTravelNetworkLinkInfo** | `linkIndex`: luaindex<br>`bgContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType] | `linkType`: integer | Public |
| **GetKeepTravelNetworkNodeInfo** | `nodeIndex`: luaindex<br>`bgContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType] | `keepId`: integer | Public |
| **GetKeepTravelNetworkNodeKeepId** | `nodeIndex`: luaindex<br>`bgContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType] | `keepId`: integer | Public |
| **GetKeepTravelNetworkNodePosition** | `nodeIndex`: luaindex<br>`bgContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType] | `normalizedX`: number | Public |
| **GetKeepType** | `keepId`: integer | `keepType`: [KeepType|#KeepType] | Public |
| **GetKeepUpgradeDetails** | `keepId`: integer<br>`battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType]<br>`resourceType`: [KeepResourceType|#KeepResourceType]<br>*+2 more* | `upgradeName`: string | Public |
| **GetKeepUpgradeInfo** | `keepId`: integer<br>`battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType]<br>`upgradePath`: [KeepUpgradePath|#KeepUpgradePath]<br>*+1 more* | `currentAmount`: integer | Public |
| **GetKeepUpgradeLineFromResourceType** | `resourceType`: [KeepResourceType|#KeepResourceType] | `upgradeLine`: [KeepUpgradeLine|#KeepUpgradeLine] | Public |
| **GetKeepUpgradeLineFromUpgradePath** | `upgradePath`: [KeepUpgradePath|#KeepUpgradePath] | `upgradeLine`: [KeepUpgradeLine|#KeepUpgradeLine] | Public |
| **GetKeepUpgradePathDetails** | `keepId`: integer<br>`battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType]<br>`upgradePath`: [KeepUpgradePath|#KeepUpgradePath]<br>*+2 more* | `upgradeName`: string | Public |
| **GetKeepUpgradeRate** | `keepId`: integer<br>`battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType]<br>`upgradeLine`: [KeepUpgradeLine|#KeepUpgradeLine] | `rate`: integer | Public |
| **GetKillLocationPinInfo** | `index`: luaindex | `pinType`: integer | Public |
| **GetLocationName** | `worldId`: integer | `worldName`: string | Public |
| **GetMapBlobNameInfo** | `blobIndex`: luaindex | `locationName`: string | Public |
| **GetMapContentType** | - | `mapContentType`: [MapContentType|#MapContentType] | Public |
| **GetMapCustomMaxZoom** | - | `customMaxZoom`: number:nilable | Public |
| **GetMapFilterType** | - | `mapFilterType`: [MapFilterType|#MapFilterType] | Public |
| **GetMapFloorInfo** | - | `currentFloor`: luaindex | Public |
| **GetMapIdByIndex** | `mapIndex`: luaindex | `mapId`: integer | Public |
| **GetMapIdByZoneId** | `zoneId`: integer | `mapId`: integer | Public |
| **GetMapIndexById** | `mapId`: integer | `index`: luaindex:nilable | Public |
| **GetMapIndexByZoneId** | `zoneId`: integer | `index`: luaindex:nilable | Public |
| **GetMapInfoById** | `mapId`: integer | `name`: string | Public |
| **GetMapInfoByIndex** | `index`: luaindex | `name`: string | Public |
| **GetMapKeySectionName** | `sectionIndex`: luaindex | `sectionName`: string | Public |
| **GetMapKeySectionSymbolInfo** | `sectionIndex`: luaindex<br>`symbolIndex`: luaindex | `name`: string | Public |

*... and 121 more functions in this category*

#### Guild

*214 functions*

| Function | Parameters | Returns | Protection |
|----------|------------|---------|------------|
| **AcceptGuildApplication** | `guildId`: integer<br>`index`: luaindex | `acceptedResult`: [GuildProcessApplicationResponse|#GuildProcessApplicationResponse] | Public |
| **AcceptGuildInvite** | `guildId`: integer | - | Public |
| **AddPendingGuildRank** | `rankId`: integer<br>`name`: string<br>`permissions`: integer<br>*+1 more* | - | Public |
| **AddToGuildBlacklistByDisplayName** | `guildId`: integer<br>`displayName`: string<br>`note`: string | `result`: [GuildBlacklistResponse|#GuildBlacklistResponse] | Public |
| **BuyGuildSpecificItem** | `slotIndex`: luaindex | - | Public |
| **CanEditGuildRankPermission** | `rankId`: integer<br>`permission`: [GuildPermission|#GuildPermission] | `hasPermission`: bool | Public |
| **CanWriteGuildChannel** | `channelId`: integer | `canWrite`: bool | Public |
| **CancelKeepGuildClaimInteraction** | - | - | Public |
| **CancelKeepGuildReleaseInteraction** | - | - | Public |
| **CheckGuildKeepClaim** | `guildId`: integer<br>`keepId`: integer | `result`: integer | Public |
| **CheckGuildKeepRelease** | `guildId`: integer | `result`: integer | Public |
| **ClaimInteractionKeepForGuild** | `guildId`: integer | - | Public |
| **ClearGuildHasNewApplicationsNotification** | `guildId`: integer | - | Public |
| **ClearGuildHistoryCache** | `guildId`: integer<br>`category`: [GuildHistoryEventCategory|#GuildHistoryEventCategory]:nilable<br>`keepResultsFromLastNumSeconds`: integer | `success`: bool | Public |
| **ComposeGuildRankPermissions** | `permissions`: integer<br>`permission`: integer<br>`enabled`: bool | `newPermissions`: integer | Public |
| **CreateGuildHistoryRequest** | `guildId`: integer<br>`category`: [GuildHistoryEventCategory|#GuildHistoryEventCategory]<br>`newestTimeS`: integer53<br>*+1 more* | `requestId`: integer | Public |
| **DeclineGuildApplication** | `guildId`: integer<br>`index`: luaindex<br>`declineMessage`: string<br>*+2 more* | `declinedResult`: [GuildProcessApplicationResponse|#GuildProcessApplicationResponse] | Public |
| **DestroyGuildHistoryRequest** | `requestId`: integer | `successfullyDestroyed`: bool | Public |
| **DoesGuildDataHaveInitializedAttributes** | `guildId`: integer<br>`attribute`: [GuildMetaDataAttribute|#GuildMetaDataAttribute] | `hasAllData`: bool | Public |
| **DoesGuildHaveActivityAttribute** | `guildId`: integer<br>`activity`: [GuildActivityAttributeValue|#GuildActivityAttributeValue] | `hasActivity`: bool | Public |
| **DoesGuildHaveClaimedKeep** | `guildId`: integer | `hasClaimedKeep`: bool | Public |
| **DoesGuildHaveNewApplicationsNotification** | `guildId`: integer | `doesHaveNotification`: bool | Public |
| **DoesGuildHavePrivilege** | `guildId`: integer<br>`privilege`: [GuildPrivilege|#GuildPrivilege] | `hasPrivilege`: bool | Public |
| **DoesGuildHaveRoleAttribute** | `guildId`: integer<br>`role`: [LFGRole|#LFGRole] | `hasRole`: bool | Public |
| **DoesGuildHistoryEventCategoryHaveUpToDateEvents** | `guildId`: integer<br>`category`: [GuildHistoryEventCategory|#GuildHistoryEventCategory] | `hasUpToDateEvents`: bool | Public |
| **DoesGuildHistoryHaveOutstandingRequest** | - | `hasOutstandingRequest`: bool | Public |
| **DoesGuildRankHavePermission** | `guildId`: integer<br>`rankIndex`: luaindex<br>`permission`: [GuildPermission|#GuildPermission] | `hasPermission`: bool | Public |
| **DoesPlayerHaveGuildPermission** | `guildId`: integer<br>`permission`: [GuildPermission|#GuildPermission] | `hasPermission`: bool | Public |
| **DumpGuildHistoryChunkInformation** | `guildId`: integer:nilable | - | Public |
| **GetClaimedKeepGuildName** | `keepId`: integer<br>`battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType] | `guildName`: string | Public |
| **GetCurrentTradingHouseGuildDetails** | - | `guildId`: integer | Public |
| **GetDefaultsForGuildLanguageAttributeFilter** | - | `language`: [GuildLanguageAttributeValue|#GuildLanguageAttributeValue] | Public |
| **GetGuildAlliance** | `guildId`: integer | `alliance`: [Alliance|#Alliance] | Public |
| **GetGuildAllianceAttribute** | `guildId`: integer | `guildAlliance`: [Alliance|#Alliance] | Public |
| **GetGuildBlacklistInfoAt** | `guildId`: integer<br>`index`: luaindex | `accountName`: string | Public |
| **GetGuildClaimInteractionKeepId** | - | `keepId`: integer | Public |
| **GetGuildClaimedKeep** | `guildId`: integer | `claimedKeepId`: integer | Public |
| **GetGuildDescription** | `guildId`: integer | `description`: string | Public |
| **GetGuildFinderAccountApplicationDuration** | `index`: luaindex | `timeRemainingS`: integer | Public |
| **GetGuildFinderAccountApplicationInfo** | `index`: luaindex | `guildId`: integer | Public |
| **GetGuildFinderGuildApplicationDuration** | `guildId`: integer<br>`index`: luaindex | `timeRemainingS`: integer | Public |
| **GetGuildFinderGuildApplicationInfoAt** | `guildId`: integer<br>`index`: luaindex | `level`: integer | Public |
| **GetGuildFinderNumAccountApplications** | - | `numApplications`: integer | Public |
| **GetGuildFinderNumGuildApplications** | `guildId`: integer | `numApplications`: integer | Public |
| **GetGuildFoundedDate** | `guildId`: integer | `foundedDate`: string | Public |
| **GetGuildFoundedDateAttribute** | `guildId`: integer | `foundedDate`: string | Public |
| **GetGuildHeaderMessageAttribute** | `guildId`: integer | `headerMessage`: string | Public |
| **GetGuildHeraldryAttribute** | `guildId`: integer | `backgroundCategoryIndex`: luaindex | Public |
| **GetGuildHistoryActivityEventInfo** | `guildId`: integer<br>`eventIndex`: luaindex | `eventId`: integer53 | Public |
| **GetGuildHistoryAvAActivityEventInfo** | `guildId`: integer<br>`eventIndex`: luaindex | `eventId`: integer53 | Public |
| **GetGuildHistoryBankedCurrencyEventInfo** | `guildId`: integer<br>`eventIndex`: luaindex | `eventId`: integer53 | Public |
| **GetGuildHistoryBankedItemEventInfo** | `guildId`: integer<br>`eventIndex`: luaindex | `eventId`: integer53 | Public |
| **GetGuildHistoryCacheDefaultMaxNumDays** | `category`: [GuildHistoryEventCategory|#GuildHistoryEventCategory] | `numDays`: integer | Public |
| **GetGuildHistoryEventBasicInfo** | `guildId`: integer<br>`category`: [GuildHistoryEventCategory|#GuildHistoryEventCategory]<br>`eventIndex`: luaindex | `eventId`: integer53 | Public |
| **GetGuildHistoryEventCategoryAndIndex** | `guildId`: integer<br>`eventId`: integer53 | `category`: [GuildHistoryEventCategory|#GuildHistoryEventCategory]:nilable | Public |
| **GetGuildHistoryEventId** | `guildId`: integer<br>`category`: [GuildHistoryEventCategory|#GuildHistoryEventCategory]<br>`eventIndex`: luaindex | `eventId`: integer53 | Public |
| **GetGuildHistoryEventIndex** | `guildId`: integer<br>`category`: [GuildHistoryEventCategory|#GuildHistoryEventCategory]<br>`eventId`: integer53 | `eventIndex`: luaindex:nilable | Public |
| **GetGuildHistoryEventIndicesForTimeRange** | `guildId`: integer<br>`category`: [GuildHistoryEventCategory|#GuildHistoryEventCategory]<br>`newestTimeS`: integer53<br>*+1 more* | `newestEventIndex`: luaindex:nilable | Public |
| **GetGuildHistoryEventRangeIndexForEventId** | `guildId`: integer<br>`category`: [GuildHistoryEventCategory|#GuildHistoryEventCategory]<br>`eventId`: integer53 | `rangeIndex`: luaindex:nilable | Public |
| **GetGuildHistoryEventRangeInfo** | `guildId`: integer<br>`category`: [GuildHistoryEventCategory|#GuildHistoryEventCategory]<br>`rangeIndex`: luaindex | `newestTimeS`: integer53 | Public |
| **GetGuildHistoryEventTimestamp** | `guildId`: integer<br>`category`: [GuildHistoryEventCategory|#GuildHistoryEventCategory]<br>`eventIndex`: luaindex | `timestamp`: integer53 | Public |
| **GetGuildHistoryMilestoneEventInfo** | `guildId`: integer<br>`eventIndex`: luaindex | `eventId`: integer53 | Public |
| **GetGuildHistoryRequestFlags** | `requestId`: integer | `flags`: [GuildHistoryRequestFlags|#GuildHistoryRequestFlags] | Public |
| **GetGuildHistoryRequestMinCooldownMs** | - | `minCooldownMs`: integer | Public |
| **GetGuildHistoryRosterEventInfo** | `guildId`: integer<br>`eventIndex`: luaindex | `eventId`: integer53 | Public |
| **GetGuildHistoryTraderEventInfo** | `guildId`: integer<br>`eventIndex`: luaindex | `eventId`: integer53 | Public |
| **GetGuildId** | `guildIndex`: luaindex | `guildId`: integer | Public |
| **GetGuildInfo** | `guildId`: integer | `numMembers`: integer | Public |
| **GetGuildInviteInfo** | `index`: luaindex | `guildId`: integer | Public |
| **GetGuildInviteeInfo** | `guildId`: integer<br>`inviteeIndex`: luaindex | `name`: string | Public |
| **GetGuildKioskActiveBidInfo** | `guildId`: integer<br>`index`: luaindex | `timeSinceBidS`: integer | Public |
| **GetGuildKioskAttribute** | `guildId`: integer | `ownedKioskName`: string:nilable | Public |
| **GetGuildKioskCycleTimes** | - | `despawnTimestampS`: integer | Public |
| **GetGuildLanguageAttribute** | `guildId`: integer | `language`: [GuildLanguageAttributeValue|#GuildLanguageAttributeValue] | Public |
| **GetGuildLocalEndTimeAttribute** | `guildId`: integer | `localEndTimeHour`: integer | Public |
| **GetGuildLocalStartTimeAttribute** | `guildId`: integer | `localStartTimeHour`: integer | Public |
| **GetGuildMemberIndexFromDisplayName** | `guildId`: integer<br>`displayName`: string | `memberIndex`: luaindex:nilable | Public |
| **GetGuildMemberInfo** | `guildId`: integer<br>`memberIndex`: luaindex | `name`: string | Public |
| **GetGuildMinimumCPAttribute** | `guildId`: integer | `minimumCP`: integer | Public |
| **GetGuildMotD** | `guildId`: integer | `motd`: string | Public |
| **GetGuildName** | `guildId`: integer | `name`: string | Public |
| **GetGuildNameAttribute** | `guildId`: integer | `guildName`: string | Public |
| **GetGuildOwnedKioskInfo** | `guildId`: integer | `ownedKioskName`: string:nilable | Public |
| **GetGuildPermissionDependency** | `permission`: [GuildPermission|#GuildPermission]<br>`index`: luaindex | `dependentPermission`: [GuildPermission|#GuildPermission] | Public |
| **GetGuildPermissionRequisite** | `permission`: [GuildPermission|#GuildPermission]<br>`index`: luaindex | `requisitePermission`: [GuildPermission|#GuildPermission] | Public |
| **GetGuildPersonalityAttribute** | `guildId`: integer | `personality`: [GuildPersonalityAttributeValue|#GuildPersonalityAttributeValue] | Public |
| **GetGuildPrimaryFocusAttribute** | `guildId`: integer | `primaryFocus`: [GuildFocusAttributeValue|#GuildFocusAttributeValue] | Public |
| **GetGuildRankCustomName** | `guildId`: integer<br>`rankIndex`: luaindex | `rankName`: string | Public |
| **GetGuildRankIconIndex** | `guildId`: integer<br>`rankIndex`: luaindex | `iconIndex`: luaindex | Public |
| **GetGuildRankId** | `guildId`: integer<br>`rankIndex`: luaindex | `rankId`: integer | Public |
| **GetGuildRankIndex** | `guildId`: integer<br>`rankId`: integer | `rankIndex`: luaindex:nilable | Public |
| **GetGuildRankLargeIcon** | `iconIndex`: luaindex | `icon`: textureName | Public |
| **GetGuildRankListDownIcon** | `iconIndex`: luaindex | `icon`: textureName | Public |
| **GetGuildRankListHighlightIcon** | `iconIndex`: luaindex | `icon`: textureName | Public |
| **GetGuildRankListUpIcon** | `iconIndex`: luaindex | `icon`: textureName | Public |
| **GetGuildRankSmallIcon** | `iconIndex`: luaindex | `icon`: textureName | Public |
| **GetGuildRecruitmentActivityValue** | `guildId`: integer<br>`activity`: [GuildActivityAttributeValue|#GuildActivityAttributeValue] | `selected`: bool | Public |
| **GetGuildRecruitmentEndTime** | `guildId`: integer | `localEndTimeHours`: integer | Public |
| **GetGuildRecruitmentInfo** | `guildId`: integer | `recruitmentMessage`: string | Public |
| **GetGuildRecruitmentLink** | `guildId`: integer<br>`linkStyle`: [LinkStyle|#LinkStyle] | `link`: string | Public |

*... and 114 more functions in this category*

#### Housing & Furniture

*196 functions*

| Function | Parameters | Returns | Protection |
|----------|------------|---------|------------|
| **AddHousingPermission** | `houseId`: integer<br>`permissionCategory`: [HousePermissionUserGroup|#HousePermissionUserGroup]<br>`grantAccess`: bool<br>*+3 more* | - | Public |
| **AreHousingPermissionsChangesPending** | - | `changesPending`: bool | Public |
| **CanRedoLastHousingEditorCommand** | - | `canRedo`: bool | Public |
| **CanStowFurnitureItem** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `canBeStowed`: bool | Public |
| **CanUndoLastHousingEditorCommand** | - | `canUndo`: bool | Public |
| **DoesFurnitureThemeShowInBrowser** | `furnitureTheme`: [FurnitureThemeType|#FurnitureThemeType] | `showInBrowser`: bool | Public |
| **DoesHousingUserGroupHaveAccess** | `houseId`: integer<br>`permissionCategory`: [HousePermissionUserGroup|#HousePermissionUserGroup]<br>`index`: luaindex | `hasAccess`: bool | Public |
| **GetCollectibleAsFurniturePreviewActionDisplayName** | `collectibleDefId`: integer<br>`variation`: luaindex<br>`action`: luaindex | `previewActionDisplayName`: string | Public |
| **GetCollectibleAsFurniturePreviewVariationDisplayName** | `collectibleDefId`: integer<br>`variation`: luaindex | `variationDisplayName`: string | Public |
| **GetCollectibleFurnitureDataId** | `collectibleId`: integer | `furnitureDataId`: integer | Public |
| **GetCollectibleFurnitureDataIdForPreview** | `collectibleId`: integer | `furnitureDataId`: integer | Public |
| **GetCollectibleIdFromFurnitureId** | `furnitureId`: id64 | `collectibleId`: integer | Public |
| **GetCurrentHouseTourListingFurnitureCount** | - | `numFurnishings`: integer:nilable | Public |
| **GetCurrentHousingEditorHistoryCommandIndex** | - | `index`: integer | Public |
| **GetFurnitureCategoryGamepadIcon** | `furnitureCategoryId`: integer | `gamepadIcon`: textureName | Public |
| **GetFurnitureCategoryId** | `categoryIndex`: luaindex | `categoryId`: integer | Public |
| **GetFurnitureCategoryInfo** | `furnitureCategoryId`: integer | `displayName`: string | Public |
| **GetFurnitureCategoryKeyboardIcons** | `furnitureCategoryId`: integer | `normalIcon`: textureName | Public |
| **GetFurnitureCategoryName** | `furnitureCategoryId`: integer | `displayName`: string | Public |
| **GetFurnitureDataCategoryInfo** | `furnitureDataId`: integer | `categoryId`: integer:nilable | Public |
| **GetFurnitureDataInfo** | `furnitureDataId`: integer | `categoryId`: integer:nilable | Public |
| **GetFurnitureIdFromCollectibleId** | `collectibleId`: integer | `furnitureId`: id64 | Public |
| **GetFurnitureIdFromItemUniqueId** | `itemUniqueId`: id64 | `furnitureId`: id64 | Public |
| **GetFurnitureSubcategoryId** | `categoryIndex`: luaindex<br>`subcategoryIndex`: luaindex | `subcategoryId`: integer | Public |
| **GetFurnitureVaultCollectibleId** | - | `collectibleId`: integer | Public |
| **GetHouseFurnitureCount** | `houseId`: integer | `furnitureCount`: integer:nilable | Public |
| **GetHouseToursListingFurnitureCountByIndex** | `listingType`: [HouseTourListingType|#HouseTourListingType]<br>`listingIndex`: luaindex | `furnitureCount`: integer:nilable | Public |
| **GetHousingEditorConstants** | - | `pushSpeedPerSecond`: number | Public |
| **GetHousingEditorHistoryCommandInfo** | `index`: integer | `commandType`: [HousingEditorCommandType|#HousingEditorCommandType] | Public |
| **GetHousingEditorMode** | - | `mode`: [HousingEditorMode|#HousingEditorMode] | Public |
| **GetHousingLink** | `houseId`: integer<br>`ownerDisplayName`: string<br>`linkStyle`: [LinkStyle|#LinkStyle] | `link`: string | Public |
| **GetHousingPermissionPresetType** | `houseId`: integer<br>`permissionCategory`: [HousePermissionUserGroup|#HousePermissionUserGroup]<br>`index`: luaindex | `preset`: [HousePermissionPresetSetting|#HousePermissionPresetSetting] | Public |
| **GetHousingPrimaryHouse** | - | `houseId`: integer | Public |
| **GetHousingStarterQuestId** | - | `questId`: integer | Public |
| **GetHousingUserGroupDisplayName** | `houseId`: integer<br>`permissionCategory`: [HousePermissionUserGroup|#HousePermissionUserGroup]<br>`index`: luaindex | `displayName`: string | Public |
| **GetHousingVisitorRole** | - | `role`: [HousingVisitorRole|#HousingVisitorRole] | Public |
| **GetNextFurnitureVaultSlotId** | `lastSlotId`: integer:nilable | `nextSlotId`: integer:nilable | Public |
| **GetNextPathedHousingFurnitureId** | `lastFurnitureId`: id64:nilable | `nextFurnitureId`: id64:nilable | Public |
| **GetNextPlacedHousingFurnitureId** | `lastFurnitureId`: id64:nilable | `nextFurnitureId`: id64:nilable | Public |
| **GetNumCollectibleAsFurniturePreviewActions** | `collectibleDefId`: integer<br>`variation`: luaindex | `numActions`: integer | Public |
| **GetNumCollectibleAsFurniturePreviewVariations** | `collectibleDefId`: integer | `numVariations`: integer | Public |
| **GetNumFurnitureCategories** | - | `numCategories`: integer | Public |
| **GetNumFurnitureSubcategories** | `categoryIndex`: luaindex | `numSubcategories`: integer | Public |
| **GetNumHousingEditorHistoryCommands** | - | `numCommands`: integer | Public |
| **GetNumHousingPermissions** | `houseId`: integer<br>`permissionCategory`: [HousePermissionUserGroup|#HousePermissionUserGroup] | `numPermissions`: integer | Public |
| **GetNumPlacedFurniturePreviewVariations** | `furnitureId`: id64 | `numVariations`: integer | Public |
| **GetPlacedFurnitureChildren** | `furnitureId`: id64 | `childFurnitureId`: id64 | Public |
| **GetPlacedFurnitureLink** | `placedFurnitureId`: id64<br>`linkStyle`: [LinkStyle|#LinkStyle] | `itemLink`: string | Public |
| **GetPlacedFurnitureParent** | `furnitureId`: id64 | `parentFurnitureId`: id64:nilable | Public |
| **GetPlacedFurniturePreviewVariationDisplayName** | `furnitureId`: id64<br>`variation`: luaindex | `variationDisplayName`: string | Public |
| **GetPlacedHousingFurnitureCurrentObjectStateIndex** | `furnitureId`: id64 | `currentObjectStateIndex`: integer | Public |
| **GetPlacedHousingFurnitureDisplayQuality** | `furnitureId`: id64 | `displayQuality`: [ItemDisplayQuality|#ItemDisplayQuality] | Public |
| **GetPlacedHousingFurnitureInfo** | `furnitureId`: id64 | `itemName`: string | Public |
| **GetPlacedHousingFurnitureNumObjectStates** | `furnitureId`: id64 | `numStates`: integer | Public |
| **HousingEditorAdjustPrecisionEditingPosition** | `aWorldX`: integer<br>`aWorldY`: integer<br>`aWorldZ`: integer | - | Public |
| **HousingEditorAdjustSelectedObjectRotation** | `aPitchRadians`: number<br>`aYawRadians`: number<br>`aRollRadians`: number | - | Public |
| **HousingEditorAlignFurnitureToSurface** | - | `result`: [HousingRequestResult|#HousingRequestResult] | Public |
| **HousingEditorAlignSelectedObjectToSurface** | - | `result`: [HousingRequestResult|#HousingRequestResult] | Public |
| **HousingEditorAlignSelectedPathNodeToSurface** | - | `result`: [HousingRequestResult|#HousingRequestResult] | Public |
| **HousingEditorBeginLinkingTargettedFurniture** | - | `result`: [HousingRequestResult|#HousingRequestResult] | Public |
| **HousingEditorBeginPlaceNewPathNode** | `index`: luaindex | `result`: [HousingRequestResult|#HousingRequestResult] | Public |
| **HousingEditorCalculateRotationAboutAxis** | `aAxis`: [AxisTypes|#AxisTypes]<br>`aOffsetRadians`: number<br>`aInitialPitchRadians`: number<br>*+2 more* | `pitchRadians`: number | Public |
| **HousingEditorCanCollectibleBePathed** | `collectibleId`: integer | `canBePathed`: bool | Public |
| **HousingEditorCanFurnitureBePathed** | `furnitureId`: id64 | `canBePathed`: bool | Public |
| **HousingEditorCanPlaceCollectible** | `collectibleId`: integer | `success`: bool | Public |
| **HousingEditorCanRemoveAllChildrenFromPendingFurniture** | - | `result`: [HousingRequestResult|#HousingRequestResult] | Public |
| **HousingEditorCanRemoveParentFromPendingFurniture** | - | `result`: [HousingRequestResult|#HousingRequestResult] | Public |
| **HousingEditorCanSelectTargettedFurniture** | - | `hasTarget`: bool | Public |
| **HousingEditorClipLineSegmentToViewFrustum** | `aWorldX1`: integer<br>`aWorldY1`: integer<br>`aWorldZ1`: integer<br>*+3 more* | `aClippedWorldX1`: integer | Public |
| **HousingEditorCreateCollectibleFurnitureForPlacement** | `collectibleId`: integer | `success`: bool | Public |
| **HousingEditorCreateItemFurnitureForPlacement** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `success`: bool | Public |
| **HousingEditorCycleTarget** | - | `result`: [HousingRequestResult|#HousingRequestResult] | Public |
| **HousingEditorEditTargettedFurniturePath** | - | `result`: [HousingRequestResult|#HousingRequestResult] | Public |
| **HousingEditorEndCurrentPreview** | - | - | Public |
| **HousingEditorEndLocalPlayerPairedFurnitureInteraction** | - | - | Public |
| **HousingEditorGetFurnitureLocalBounds** | `furnitureId`: id64 | `minLocalX`: number | Public |
| **HousingEditorGetFurnitureOrientation** | `furnitureId`: id64 | `pitchRadians`: number | Public |
| **HousingEditorGetFurniturePathFollowType** | `furnitureId`: id64 | `followType`: [PathFollowType|#PathFollowType] | Public |
| **HousingEditorGetFurniturePathState** | `furnitureId`: id64 | `pathState`: [FurniturePathState|#FurniturePathState] | Public |
| **HousingEditorGetFurnitureWorldBounds** | `furnitureId`: id64 | `minWorldX`: integer | Public |
| **HousingEditorGetFurnitureWorldCenter** | `furnitureId`: id64 | `centerX`: number | Public |
| **HousingEditorGetFurnitureWorldOffset** | `furnitureId`: id64 | `offsetX`: number | Public |
| **HousingEditorGetFurnitureWorldPosition** | `furnitureId`: id64 | `worldX`: integer | Public |
| **HousingEditorGetLinkRelationshipFromSelectedChildToPendingFurniture** | - | `result`: [HousingPendingLinkRelationship|#HousingPendingLinkRelationship] | Public |
| **HousingEditorGetNumCyclableTargets** | - | `numTargets`: integer | Public |
| **HousingEditorGetNumPathNodesForFurniture** | `furnitureId`: id64 | `numNodes`: integer | Public |
| **HousingEditorGetNumPathNodesInSelectedFurniture** | - | `numPathNodes`: integer | Public |
| **HousingEditorGetPathNodeDelayTimeFromValue** | `pathDelayTime`: [HousingPathDelayTime|#HousingPathDelayTime] | `timeMS`: integer | Public |
| **HousingEditorGetPathNodeOrientation** | `furnitureId`: id64<br>`index`: luaindex | `pitchRadians`: number | Public |
| **HousingEditorGetPathNodeValueFromDelayTime** | `timeMS`: integer | `pathDelayTime`: [HousingPathDelayTime|#HousingPathDelayTime] | Public |
| **HousingEditorGetPathNodeWorldPosition** | `furnitureId`: id64<br>`index`: luaindex | `worldX`: integer | Public |
| **HousingEditorGetPendingBadLinkResult** | - | `result`: [HousingRequestResult|#HousingRequestResult] | Public |
| **HousingEditorGetPlacementType** | - | `placementType`: [HousingEditorPlacementType|#HousingEditorPlacementType] | Public |
| **HousingEditorGetPrecisionMoveUnits** | - | `aMovementCentimeters`: integer | Public |
| **HousingEditorGetPrecisionPlacementMode** | - | `precisionPlacementMode`: [HousingEditorPrecisionPlacementMode|#HousingEditorPrecisionPlacementMode] | Public |
| **HousingEditorGetPrecisionRotateUnits** | - | `aRotationRadians`: number | Public |
| **HousingEditorGetRetrieveToBag** | - | `bagId`: [Bag|#Bag] | Public |
| **HousingEditorGetScreenPointWorldPlaneIntersection** | `aScreenX`: integer<br>`aScreenY`: integer<br>`aWorldX1`: integer<br>*+8 more* | `aWorldX`: integer | Public |
| **HousingEditorGetSelectedFurnitureId** | - | `furnitureId`: id64:nilable | Public |
| **HousingEditorGetSelectedFurniturePathConformToGround** | - | `conformToGround`: bool | Public |

*... and 96 more functions in this category*

#### Inventory & Items

*191 functions*

| Function | Parameters | Returns | Protection |
|----------|------------|---------|------------|
| **CanInventoryItemBePreviewed** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `canPreview`: bool | Public |
| **CheckInventorySpaceAndWarn** | `numItems`: integer | `haveSpace`: bool | Public |
| **CheckInventorySpaceSilently** | `numItems`: integer | `haveSpace`: bool | Public |
| **DoesInventoryContainEmptySoulGem** | - | `hasEmptyGem`: bool | Public |
| **GetBagForCollectible** | `collectibleId`: integer | `bagId`: [Bag|#Bag]:nilable | Public |
| **GetBagSize** | `bagId`: [Bag|#Bag] | `bagSlots`: integer | Public |
| **GetBagUseableSize** | `bagId`: [Bag|#Bag] | `bagSlots`: integer | Public |
| **GetEquipSlotForOutfitSlot** | `outfitSlot`: [OutfitSlot|#OutfitSlot] | `equipSlot`: [EquipSlot|#EquipSlot] | Public |
| **GetEquipmentBonusRating** | `bagId`: [Bag|#Bag]<br>`equipSlot`: [EquipSlot|#EquipSlot] | `equipmentBonusRating`: number | Public |
| **GetEquipmentBonusThreshold** | `unitLevel`: integer<br>`unitChampionPoints`: integer<br>`index`: integer | `thresholdValue`: number | Public |
| **GetEquipmentFilterTypeForItemSetCollectionSlot** | `slot`: [ItemSetCollectionSlot_id64|#ItemSetCollectionSlot_id64] | `equipmentFilterType`: [EquipmentFilterType|#EquipmentFilterType] | Public |
| **GetEquippedItemInfo** | `equipSlot`: [EquipSlot|#EquipSlot] | `icon`: string | Public |
| **GetEquippedOutfitIndex** | `actorCategory`: [GameplayActorCategory|#GameplayActorCategory] | `outfitIndex`: luaindex:nilable | Public |
| **GetInventoryItemPreviewCollectibleActionDisplayName** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer<br>`variation`: luaindex<br>*+1 more* | `actionDisplayName`: string | Public |
| **GetInventoryItemPreviewVariationDisplayName** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer<br>`variation`: luaindex | `variationDisplayName`: string | Public |
| **GetInventorySpaceRequiredToOpenCrownCrate** | `crateId`: integer | `inventorySpaceRequired`: integer | Public |
| **GetItemActorCategory** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `actorCategory`: [GameplayActorCategory|#GameplayActorCategory] | Public |
| **GetItemArmorType** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `armorType`: [ArmorType|#ArmorType] | Public |
| **GetItemArmoryBuildList** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `buildList`: string | Public |
| **GetItemBindType** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `bindType`: [BindType|#BindType] | Public |
| **GetItemBoPTimeRemainingSeconds** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `timeRemainingS`: integer | Public |
| **GetItemBoPTradeableDisplayNamesString** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `namesString`: string | Public |
| **GetItemBoPTradeableEligibleNameByIndex** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer<br>`nameIndex`: luaindex | `name`: string | Public |
| **GetItemBoPTradeableNumEligibleNames** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `numNames`: integer | Public |
| **GetItemBonusSuppressionName** | `suppressionType`: [ItemBonusSuppressionType|#ItemBonusSuppressionType]<br>`refId`: integer | `text`: string | Public |
| **GetItemCombinationId** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `combinationId`: integer | Public |
| **GetItemComparisonEquipSlots** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `equipSlot1`: [EquipSlot|#EquipSlot] | Public |
| **GetItemCondition** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `condition`: integer | Public |
| **GetItemCooldownInfo** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `remain`: integer | Public |
| **GetItemCraftingInfo** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `usedInCraftingType`: [TradeskillType|#TradeskillType] | Public |
| **GetItemCreatorName** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `creatorName`: string | Public |
| **GetItemDisplayQuality** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `displayQuality`: [ItemDisplayQuality|#ItemDisplayQuality] | Public |
| **GetItemEnchantSuppressionInfo** | - | `suppressionType`: [ItemBonusSuppressionType|#ItemBonusSuppressionType] | Public |
| **GetItemEquipType** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `equipType`: [EquipType|#EquipType] | Public |
| **GetItemEquipmentFilterType** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `equipmentFilterType`: [EquipmentFilterType|#EquipmentFilterType] | Public |
| **GetItemEquippedComparisonEquipSlots** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `equipSlot1`: [EquipSlot|#EquipSlot] | Public |
| **GetItemFilterTypeInfo** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `itemFilterType`: [ItemFilterType|#ItemFilterType] | Public |
| **GetItemFunctionalQuality** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `functionalQuality`: [ItemQuality|#ItemQuality] | Public |
| **GetItemFurnitureDataId** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `furnitureDataId`: integer | Public |
| **GetItemGlyphMinLevels** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `minLevel`: integer:nilable | Public |
| **GetItemId** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `itemId`: integer | Public |
| **GetItemInfo** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `icon`: textureName | Public |
| **GetItemInstanceId** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `id`: integer:nilable | Public |
| **GetItemLaunderPrice** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `launderCost`: integer | Public |
| **GetItemLevel** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `level`: integer | Public |
| **GetItemLink** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer<br>`linkStyle`: [LinkStyle|#LinkStyle] | `link`: string | Public |
| **GetItemLinkActorCategory** | `itemLink`: string | `actorCategory`: [GameplayActorCategory|#GameplayActorCategory] | Public |
| **GetItemLinkAppliedEnchantId** | `itemLink`: string | `enchantId`: integer | Public |
| **GetItemLinkArmorRating** | `itemLink`: string<br>`considerCondition`: bool | `armorRating`: integer | Public |
| **GetItemLinkArmorType** | `itemLink`: string | `armorType`: [ArmorType|#ArmorType] | Public |
| **GetItemLinkBindType** | `itemLink`: string | `bindType`: [BindType|#BindType] | Public |
| **GetItemLinkBookTitle** | `itemLink`: string | `bookTitle`: string:nilable | Public |
| **GetItemLinkCombinationDescription** | `itemLink`: string | `combinationDescription`: string | Public |
| **GetItemLinkCombinationId** | `itemLink`: string | `combinationId`: integer | Public |
| **GetItemLinkComparisonEquipSlots** | `itemLink`: string | `equipSlot1`: [EquipSlot|#EquipSlot] | Public |
| **GetItemLinkCondition** | `itemLink`: string | `conditionPercent`: integer | Public |
| **GetItemLinkContainerCollectibleId** | `itemLink`: string | `containerCollectibleId`: integer | Public |
| **GetItemLinkContainerSetBonusInfo** | `itemLink`: string<br>`containerSetIndex`: luaindex<br>`bonusIndex`: luaindex | `numRequired`: integer | Public |
| **GetItemLinkContainerSetInfo** | `itemLink`: string<br>`containerSetIndex`: luaindex | `hasSet`: bool | Public |
| **GetItemLinkCraftingSkillType** | `itemLink`: string | `tradeskillType`: [TradeskillType|#TradeskillType] | Public |
| **GetItemLinkDefaultEnchantId** | `itemLink`: string | `enchantId`: integer | Public |
| **GetItemLinkDisplayQuality** | `itemLink`: string | `displayQuality`: [ItemDisplayQuality|#ItemDisplayQuality] | Public |
| **GetItemLinkDyeIds** | `itemLink`: string | `primaryDefId`: integer | Public |
| **GetItemLinkDyeStampId** | `itemLink`: string | `dyeStampId`: integer | Public |
| **GetItemLinkEnchantInfo** | `itemLink`: string | `hasCharges`: bool | Public |
| **GetItemLinkEnchantingRuneClassification** | `itemLink`: string | `runeClassification`: [EnchantingRuneClassification|#EnchantingRuneClassification] | Public |
| **GetItemLinkEnchantingRuneName** | `itemLink`: string | `known`: bool:nilable | Public |
| **GetItemLinkEquipType** | `itemLink`: string | `equipType`: [EquipType|#EquipType] | Public |
| **GetItemLinkEquippedComparisonEquipSlots** | `itemLink`: string | `equipSlot1`: [EquipSlot|#EquipSlot] | Public |
| **GetItemLinkFilterTypeInfo** | `itemLink`: string | `itemFilterType`: [ItemFilterType|#ItemFilterType] | Public |
| **GetItemLinkFinalEnchantId** | `itemLink`: string | `enchantId`: integer | Public |
| **GetItemLinkFlavorText** | `itemLink`: string | `flavorText`: string | Public |
| **GetItemLinkFunctionalQuality** | `itemLink`: string | `functionalQuality`: [ItemQuality|#ItemQuality] | Public |
| **GetItemLinkFurnishingLimitType** | `itemLink`: string | `furnishingLimitType`: [HousingFurnishingLimitType|#HousingFurnishingLimitType] | Public |
| **GetItemLinkFurnitureDataId** | `itemLink`: string | `furnitureDataId`: integer | Public |
| **GetItemLinkGlyphMinLevels** | `itemLink`: string | `minLevel`: integer:nilable | Public |
| **GetItemLinkGrantedRecipeIndices** | `itemLink`: string | `recipeListIndex`: luaindex:nilable | Public |
| **GetItemLinkIcon** | `itemLink`: string | `itemIcon`: textureName | Public |
| **GetItemLinkInfo** | `itemLink`: string | `icon`: string | Public |
| **GetItemLinkInventoryCount** | `itemLink`: string<br>`countType`: [InventoryCountBagOption|#InventoryCountBagOption] | `inventoryCount`: integer | Public |
| **GetItemLinkItemId** | `itemLink`: string | `itemId`: integer | Public |
| **GetItemLinkItemSetCollectionSlot** | `itemLink`: string | `slot`: id64 | Public |
| **GetItemLinkItemStyle** | `itemLink`: string | `style`: integer | Public |
| **GetItemLinkItemTagInfo** | `itemLink`: string<br>`itemTagIndex`: luaindex | `itemTagDescription`: string | Public |
| **GetItemLinkItemType** | `itemLink`: string | `itemType`: [ItemType|#ItemType] | Public |
| **GetItemLinkItemUseReferenceId** | `itemLink`: string | `onUseReferenceId`: integer | Public |
| **GetItemLinkItemUseType** | `itemLink`: string | `onUseType`: [ItemUseType|#ItemUseType] | Public |
| **GetItemLinkMaterialLevelDescription** | `itemLink`: string | `levelsDescription`: string | Public |
| **GetItemLinkMaxEnchantCharges** | `itemLink`: string | `maxCharges`: integer | Public |
| **GetItemLinkName** | `itemLink`: string | `itemName`: string | Public |
| **GetItemLinkNumConsolidatedSmithingStationUnlockedSets** | `itemLink`: string | `numUnlockedSets`: integer | Public |
| **GetItemLinkNumContainerSetIds** | `itemLink`: string | `numSetIds`: integer | Public |
| **GetItemLinkNumEnchantCharges** | `itemLink`: string | `numCharges`: integer | Public |
| **GetItemLinkNumItemTags** | `itemLink`: string | `numItemTags`: integer | Public |
| **GetItemLinkOutfitStyleId** | `itemLink`: string | `outfitStyleId`: integer | Public |
| **GetItemLinkPreviewVariationDisplayName** | `itemLink`: string<br>`variation`: luaindex | `variationDisplayName`: string | Public |
| **GetItemLinkReagentTraitInfo** | `itemLink`: string<br>`index`: luaindex | `known`: bool:nilable | Public |
| **GetItemLinkRecipeCraftingSkillType** | `itemLink`: string | `craftingSkillType`: [TradeskillType|#TradeskillType] | Public |
| **GetItemLinkRecipeIngredientInfo** | `itemLink`: string<br>`index`: luaindex | `ingredientName`: string | Public |
| **GetItemLinkRecipeIngredientItemLink** | `itemLink`: string<br>`index`: luaindex<br>`linkStyle`: [LinkStyle|#LinkStyle] | `link`: string | Public |

*... and 91 more functions in this category*

#### Quest & Journal

*161 functions*

| Function | Parameters | Returns | Protection |
|----------|------------|---------|------------|
| **AbandonQuest** | `journalQuestIndex`: luaindex | - | Public |
| **AcceptOfferedQuest** | - | - | Public |
| **AcceptSharedQuest** | `questId`: integer | - | Public |
| **AddHotbarSlotToChampionPurchaseRequest** | `slotIndex`: luaindex<br>`championSkillId`: integer | - | Public |
| **AddSkillToChampionPurchaseRequest** | `championSkillId`: integer<br>`newPendingPoints`: integer | - | Public |
| **AssistedQuestPinForTracked** | `trackedPinType`: [MapDisplayPinType|#MapDisplayPinType] | `assistedPinType`: [MapDisplayPinType|#MapDisplayPinType] | Public |
| **BestowActivityTypeGatingQuest** | `activity`: [LFGActivity|#LFGActivity] | - | Public |
| **BestowSubclassingQuest** | - | - | Public |
| **CanAbandonJournalQuest** | `journalQuestIndex`: luaindex | `canAbandon`: bool | Public |
| **CanAcceptActiveSpectacleEventQuest** | `activeSpectacleEventId`: integer | `canAcceptQuest`: bool | Public |
| **CanQuickslotQuestItemById** | `questItemId`: integer | `canQuickslot`: bool | Public |
| **CanSendLFMRequest** | - | `canSendLFMRequest`: bool | Public |
| **CanUseQuestItem** | `journalQuestIndex`: luaindex<br>`stepIndex`: luaindex<br>`conditionIndex`: luaindex | `canUse`: bool | Public |
| **CanUseQuestTool** | `journalQuestIndex`: luaindex<br>`toolIndex`: luaindex | `canUse`: bool | Public |
| **CancelRequestJournalQuestConditionAssistance** | `taskId`: integer | - | Public |
| **CompleteQuest** | - | - | Public |
| **DeclineSharedQuest** | `questId`: integer | - | Public |
| **DidCurrentBattlegroundRequestLFM** | - | `lfmRequested`: bool | Public |
| **DoesGroupFinderFilterAutoAcceptRequests** | - | `setState`: bool | Public |
| **DoesGroupFinderSearchListingAutoAcceptRequests** | `index`: luaindex | `autoAcceptsRequests`: bool | Public |
| **DoesGroupFinderUserTypeGroupListingAutoAcceptRequests** | `userType`: [GroupFinderGroupListingUserType|#GroupFinderGroupListingUserType] | `autoAcceptRequests`: bool | Public |
| **DoesItemFulfillJournalQuestCondition** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer<br>`journalQuestIndex`: luaindex<br>*+2 more* | `fulfillsCondition`: bool | Public |
| **DoesItemLinkFinishQuest** | `itemLink`: string | `finishesQuest`: bool | Public |
| **DoesItemLinkFulfillJournalQuestCondition** | `link`: string<br>`journalQuestIndex`: luaindex<br>`stepIndex`: luaindex<br>*+2 more* | `fulfillsCondition`: bool | Public |
| **DoesItemLinkStartQuest** | `itemLink`: string | `startsQuest`: bool | Public |
| **DoesJournalQuestConditionHavePosition** | `journalQuestIndex`: luaindex<br>`stepIndex`: luaindex<br>`conditionIndex`: luaindex | `hasPosition`: bool | Public |
| **GenerateQuestConditionTooltipLine** | `questIndex`: luaindex<br>`stepIndex`: luaindex<br>`conditionIndex`: luaindex<br>*+1 more* | `text`: string | Public |
| **GenerateQuestEndingTooltipLine** | `questIndex`: luaindex | `text`: string | Public |
| **GenerateQuestNameTooltipLine** | `questIndex`: luaindex | `text`: string | Public |
| **GetActiveSpectacleEventQuestIndex** | `activeSpectacleEventId`: integer | `questIndex`: luaindex:nilable | Public |
| **GetActivityRequestIds** | `requestIndex`: luaindex | `activityId`: integer | Public |
| **GetActivityTypeGatingQuest** | `activity`: [LFGActivity|#LFGActivity] | `questId`: integer | Public |
| **GetAgentChatRequestInfo** | - | `isChatRequested`: bool | Public |
| **GetCollectibleAssociatedQuestState** | `collectibleId`: integer | `questState`: [CollectibleAssociatedQuestState|#CollectibleAssociatedQuestState] | Public |
| **GetCollectibleQuestPreviewInfo** | `collectibleId`: integer | `questName`: string | Public |
| **GetCompanionIntroQuestId** | `companionId`: integer | `questId`: integer | Public |
| **GetCompletedQuestInfo** | `questId`: integer | `name`: string | Public |
| **GetCursorQuestItemId** | - | `questItemId`: integer:nilable | Public |
| **GetExpectedResultForChampionPurchaseRequest** | - | `result`: [ChampionPurchaseResult|#ChampionPurchaseResult] | Public |
| **GetHelpOverviewQuestionAnswerPair** | `index`: luaindex | `question`: string | Public |
| **GetIsQuestSharable** | `journalQuestIndex`: luaindex | `isSharable`: bool | Public |
| **GetJournalQuestConditionInfo** | `journalQuestIndex`: luaindex<br>`stepIndex`: luaindex<br>`conditionIndex`: luaindex<br>*+1 more* | `conditionText`: string | Public |
| **GetJournalQuestConditionType** | `journalQuestIndex`: luaindex<br>`stepIndex`: luaindex<br>`conditionIndex`: luaindex<br>*+1 more* | `pinType`: integer | Public |
| **GetJournalQuestConditionValues** | `journalQuestIndex`: luaindex<br>`stepIndex`: luaindex<br>`conditionIndex`: luaindex | `current`: integer | Public |
| **GetJournalQuestEnding** | `journalQuestIndex`: luaindex | `goal`: string | Public |
| **GetJournalQuestId** | `journalQuestIndex`: luaindex | `questId`: integer | Public |
| **GetJournalQuestInfo** | `journalQuestIndex`: luaindex | `questName`: string | Public |
| **GetJournalQuestIsComplete** | `journalQuestIndex`: luaindex | `completed`: bool | Public |
| **GetJournalQuestLevel** | `journalQuestIndex`: luaindex | `level`: integer | Public |
| **GetJournalQuestName** | `journalQuestIndex`: luaindex | `questName`: string | Public |
| **GetJournalQuestNumConditions** | `journalQuestIndex`: luaindex<br>`stepIndex`: luaindex | `conditionCount`: integer | Public |
| **GetJournalQuestNumRewards** | `journalQuestIndex`: luaindex | `count`: integer | Public |
| **GetJournalQuestNumSteps** | `journalQuestIndex`: luaindex | `numSteps`: integer | Public |
| **GetJournalQuestRepeatType** | `journalQuestIndex`: luaindex | `repeatType`: [QuestRepeatableType|#QuestRepeatableType] | Public |
| **GetJournalQuestRewardActiveSpectacleEventId** | `journalQuestIndex`: luaindex<br>`rewardIndex`: luaindex | `activeSpectacleEventId`: integer | Public |
| **GetJournalQuestRewardCollectibleId** | `journalQuestIndex`: luaindex<br>`rewardIndex`: luaindex | `rewardCollectibleDefId`: integer | Public |
| **GetJournalQuestRewardInfo** | `journalQuestIndex`: luaindex<br>`rewardIndex`: luaindex | `type`: [RewardType|#RewardType] | Public |
| **GetJournalQuestRewardItemId** | `journalQuestIndex`: luaindex<br>`rewardIndex`: luaindex | `rewardItemDefId`: integer | Public |
| **GetJournalQuestRewardSkillLine** | `journalQuestIndex`: luaindex<br>`rewardIndex`: luaindex | `skillType`: [SkillType|#SkillType] | Public |
| **GetJournalQuestRewardTributeCardUpgradeInfo** | `journalQuestIndex`: luaindex<br>`rewardIndex`: luaindex | `patronDefId`: integer | Public |
| **GetJournalQuestStepInfo** | `journalQuestIndex`: luaindex<br>`stepIndex`: luaindex | `journalText`: string | Public |
| **GetJournalQuestTimerCaption** | `journalQuestIndex`: luaindex | `caption`: string | Public |
| **GetJournalQuestTimerInfo** | `journalQuestIndex`: luaindex | `timerStart`: number | Public |
| **GetJournalQuestType** | `journalQuestIndex`: luaindex | `type`: [QuestType|#QuestType] | Public |
| **GetLootQuestItemId** | `lootId`: integer | `questItemId`: integer | Public |
| **GetNameOfGameCameraQuestToolTarget** | - | `name`: string | Public |
| **GetNearestQuestCondition** | `considerType`: integer | `foundValidCondition`: bool | Public |
| **GetNextCompletedQuestId** | `lastQuestId`: integer:nilable | `nextQuestId`: integer:nilable | Public |
| **GetNumActivityRequests** | - | `numRequests`: integer | Public |
| **GetNumHelpOverviewQuestionAnswers** | - | `length`: integer | Public |
| **GetNumJournalQuests** | - | `numQuests`: integer | Public |
| **GetOfferedQuestInfo** | - | `dialogue`: string | Public |
| **GetOfferedQuestShareIds** | - | `questId`: integer | Public |
| **GetOfferedQuestShareInfo** | `questId`: integer | `questName`: string | Public |
| **GetQuestConditionItemInfo** | `journalQuestIndex`: luaindex<br>`stepIndex`: luaindex<br>`conditionIndex`: luaindex | `itemId`: integer | Public |
| **GetQuestConditionMasterWritInfo** | `journalQuestIndex`: luaindex<br>`stepIndex`: luaindex<br>`conditionIndex`: luaindex | `itemId`: integer:nilable | Public |
| **GetQuestConditionQuestItemId** | `journalQuestIndex`: luaindex<br>`stepIndex`: luaindex<br>`conditionIndex`: luaindex | `questItemId`: integer | Public |
| **GetQuestItemCooldownInfo** | `journalQuestIndex`: luaindex<br>`stepIndex`: luaindex<br>`conditionIndex`: luaindex | `remain`: integer | Public |
| **GetQuestItemIcon** | `questItemId`: integer | `iconFilename`: textureName | Public |
| **GetQuestItemInfo** | `journalQuestIndex`: luaindex<br>`stepIndex`: luaindex<br>`conditionIndex`: luaindex | `iconFilename`: textureName | Public |
| **GetQuestItemLink** | `aQuestIndex`: luaindex<br>`aStepIndex`: luaindex<br>`aConditionIndex`: luaindex<br>*+1 more* | `link`: string | Public |
| **GetQuestItemName** | `questItemId`: integer | `itemName`: string | Public |
| **GetQuestItemNameFromLink** | `link`: string | `name`: string | Public |
| **GetQuestItemTooltipText** | `questItemId`: integer | `tooltipText`: string | Public |
| **GetQuestName** | `questId`: integer | `name`: string<br>`numCategories`: integer<br>*+2 more* | Public |
| **GetQuestPinTypeForTrackingLevel** | `pinType`: [MapDisplayPinType|#MapDisplayPinType]<br>`trackingLevel`: [TrackingLevel|#TrackingLevel] | `pinTypeForTrackingLevel`: [MapDisplayPinType|#MapDisplayPinType] | Public |
| **GetQuestRepeatableType** | `questId`: integer | `repeatType`: [QuestRepeatableType|#QuestRepeatableType] | Public |
| **GetQuestRewardItemLink** | `rewardIndex`: luaindex<br>`linkStyle`: [LinkStyle|#LinkStyle] | `link`: string | Public |
| **GetQuestToolCooldownInfo** | `journalQuestIndex`: luaindex<br>`toolIndex`: luaindex | `remain`: integer | Public |
| **GetQuestToolCount** | `journalQuestIndex`: luaindex | `toolCount`: integer | Public |
| **GetQuestToolInfo** | `journalQuestIndex`: luaindex<br>`toolIndex`: luaindex | `iconFilename`: textureName | Public |
| **GetQuestToolLink** | `aQuestIndex`: luaindex<br>`aToolIndex`: luaindex<br>`linkStyle`: [LinkStyle|#LinkStyle] | `link`: string | Public |
| **GetQuestToolQuestItemId** | `journalQuestIndex`: luaindex<br>`toolIndex`: luaindex | `questItemId`: integer | Public |
| **GetQuestType** | `questId`: integer | `questType`: [QuestType|#QuestType] | Public |
| **GetSubclassingQuestId** | - | `questId`: integer | Public |
| **GetTributeRequiredQuestId** | - | `requiredQuestId`: integer | Public |
| **HasCompletedQuest** | `questId`: integer | `hasCompleted`: bool | Public |
| **HasQuest** | `questId`: integer | `hasQuest`: bool | Public |
| **IsGroupFinderRoleChangeRequested** | - | `isRoleChangeRequested`: bool | Public |
| **IsJournalQuestStepEnding** | `journalQuestIndex`: luaindex<br>`stepIndex`: luaindex | `isEnding`: bool | Public |

*... and 61 more functions in this category*

#### Collections

*152 functions*

| Function | Parameters | Returns | Protection |
|----------|------------|---------|------------|
| **CanAcquireCollectibleByDefId** | `collectibleId`: integer | `canAcquire`: bool | Public |
| **CanCollectibleBePreviewed** | `collectibleId`: integer | `canCollectibleBePreviewed`: bool | Public |
| **CanUseCollectibleDyeing** | - | `collectibleDyeingAllowed`: bool | Public |
| **ClearCollectibleCategoryNewStatuses** | `categoryIndex`: luaindex<br>`subcategoryIndex`: luaindex:nilable | - | Public |
| **ClearCollectibleNewStatus** | `collectibleId`: integer | - | Public |
| **DoesCollectibleCategoryContainAnyCollectiblesWithUserFlags** | `categoryType`: [CollectibleCategoryType|#CollectibleCategoryType]<br>`userFlags`: [CollectibleUserFlags|#CollectibleUserFlags] | `containsCollectible`: bool | Public |
| **DoesCollectibleCategoryContainSlottableCollectibles** | `topLevelIndex`: luaindex<br>`categoryIndex`: luaindex:nilable | `containsSlottableCollectibles`: bool | Public |
| **DoesCollectibleCategoryTypeHaveDefault** | `collectibleCategoryType`: [CollectibleCategoryType|#CollectibleCategoryType]<br>`actorCategory`: [GameplayActorCategory|#GameplayActorCategory] | `hasDefault`: bool | Public |
| **DoesCollectibleHaveVisibleAppearance** | `collectibleId`: integer | `hasVisibleAppearance`: bool | Public |
| **DoesESOPlusUnlockCollectible** | `collectibleId`: integer | `unlockedViaSubscription`: bool | Public |
| **GetActiveCollectibleByType** | `categoryType`: [CollectibleCategoryType|#CollectibleCategoryType]<br>`actorCategory`: [GameplayActorCategory|#GameplayActorCategory] | `collectibleId`: integer | Public |
| **GetAntiquityScryingToolCollectibleId** | - | `collectibleId`: integer | Public |
| **GetCategoryInfoFromCollectibleCategoryId** | `collectibleCategoryId`: integer | `topLevelIndex`: luaindex:nilable | Public |
| **GetCategoryInfoFromCollectibleId** | `collectibleId`: integer | `topLevelIndex`: luaindex:nilable | Public |
| **GetChapterCollectibleId** | `chapterUpgradeId`: integer | `collectibleId`: integer | Public |
| **GetClassAccessCollectibleId** | `classId`: integer | `collectibleId`: integer | Public |
| **GetCollectibleBlockReason** | `collectibleId`: integer<br>`actorCategory`: [GameplayActorCategory|#GameplayActorCategory] | `usageBlockReason`: [CollectibleUsageBlockReason|#CollectibleUsageBlockReason] | Public |
| **GetCollectibleCategoryGamepadIcon** | `topLevelIndex`: luaindex<br>`subCategoryIndex`: luaindex:nilable | `gamepadIcon`: textureName | Public |
| **GetCollectibleCategoryId** | `topLevelIndex`: luaindex<br>`subCategoryIndex`: luaindex:nilable | `categoryId`: integer | Public |
| **GetCollectibleCategoryInfo** | `topLevelIndex`: luaindex | `name`: string | Public |
| **GetCollectibleCategoryKeyboardIcons** | `topLevelIndex`: luaindex<br>`subCategoryIndex`: luaindex:nilable | `normalIcon`: textureName | Public |
| **GetCollectibleCategoryNameByCategoryId** | `categoryId`: integer | `categoryName`: string | Public |
| **GetCollectibleCategoryNameByCollectibleId** | `collectibleId`: integer | `categoryName`: string | Public |
| **GetCollectibleCategorySortOrder** | `topLevelIndex`: luaindex<br>`categoryIndex`: luaindex:nilable | `sortOrder`: integer | Public |
| **GetCollectibleCategorySpecialization** | `topLevelIndex`: luaindex | `specialization`: [CollectibleCategorySpecialization|#CollectibleCategorySpecialization] | Public |
| **GetCollectibleCategoryType** | `collectibleId`: integer | `categoryType`: [CollectibleCategoryType|#CollectibleCategoryType] | Public |
| **GetCollectibleCategoryTypeFromLink** | `link`: string | `categoryType`: [CollectibleCategoryType|#CollectibleCategoryType] | Public |
| **GetCollectibleCooldownAndDuration** | `collectibleId`: integer | `cooldownRemaining`: integer | Public |
| **GetCollectibleDefaultNickname** | `collectibleId`: integer | `name`: string | Public |
| **GetCollectibleDescription** | `collectibleId`: integer | `description`: string | Public |
| **GetCollectibleForBag** | `bagId`: [Bag|#Bag] | `collectibleId`: integer | Public |
| **GetCollectibleFurnishingLimitType** | `collectibleId`: integer | `furnishingLimitType`: [HousingFurnishingLimitType|#HousingFurnishingLimitType] | Public |
| **GetCollectibleGamepadBackgroundImage** | `collectibleId`: integer | `backgroundImage`: textureName | Public |
| **GetCollectibleHelpIndices** | `collectibleId`: integer | `helpCategoryIndex`: luaindex:nilable | Public |
| **GetCollectibleHideMode** | `collectibleId`: integer | `hideMode`: [CollectibleHideMode|#CollectibleHideMode] | Public |
| **GetCollectibleHint** | `collectibleId`: integer | `hint`: string | Public |
| **GetCollectibleIcon** | `collectibleId`: integer | `icon`: textureName | Public |
| **GetCollectibleId** | `topLevelIndex`: luaindex<br>`categoryIndex`: luaindex:nilable<br>`collectibleIndex`: luaindex | `collectibleId`: integer | Public |
| **GetCollectibleIdForHouse** | `houseId`: integer | `collectibleId`: integer | Public |
| **GetCollectibleIdFromLink** | `link`: string | `collectibleId`: integer:nilable | Public |
| **GetCollectibleIdFromType** | `collectibleCategoryType`: [CollectibleCategoryType|#CollectibleCategoryType]<br>`index`: luaindex | `collectibleId`: integer | Public |
| **GetCollectibleInfo** | `collectibleId`: integer | `name`: string | Public |
| **GetCollectibleKeyboardBackgroundImage** | `collectibleId`: integer | `backgroundImage`: textureName | Public |
| **GetCollectibleLink** | `collectibleId`: integer<br>`linkStyle`: [LinkStyle|#LinkStyle] | `link`: string | Public |
| **GetCollectibleName** | `collectibleId`: integer | `name`: string | Public |
| **GetCollectibleNickname** | `collectibleId`: integer | `name`: string | Public |
| **GetCollectibleNotificationInfo** | `notificationIndex`: luaindex | `notificationId`: integer | Public |
| **GetCollectiblePersonalityOverridenEmoteDisplayNames** | `collectibleId`: integer | `overriddenEmoteDisplayName`: string | Public |
| **GetCollectiblePersonalityOverridenEmoteSlashCommandNames** | `collectibleId`: integer | `overriddenEmoteSlashCommandName`: string | Public |
| **GetCollectiblePlayerFxOverrideType** | `collectibleId`: integer | `playerFxOverrideType`: [PlayerFxOverrideType|#PlayerFxOverrideType]:nilable | Public |
| **GetCollectiblePlayerFxWhileHarvestingType** | `collectibleId`: integer | `playerFxWhileHarvestingType`: [PlayerFxWhileHarvestingType|#PlayerFxWhileHarvestingType]:nilable | Public |
| **GetCollectiblePreviewActionDisplayName** | `collectibleDefId`: integer<br>`variation`: luaindex<br>`action`: luaindex | `previewActionDisplayName`: string | Public |
| **GetCollectiblePreviewVariationDisplayName** | `collectibleDefId`: integer<br>`variation`: luaindex | `variationDisplayName`: string | Public |
| **GetCollectibleReferenceId** | `collectibleId`: integer | `referenceId`: integer | Public |
| **GetCollectibleRestrictionsByType** | `collectibleId`: integer<br>`restrictionType`: [CollectibleRestrictionType|#CollectibleRestrictionType]<br>`actorCategory`: [GameplayActorCategory|#GameplayActorCategory] | `hasRestrictions`: bool | Public |
| **GetCollectibleRewardCollectibleId** | `rewardId`: integer | `collectibleId`: integer | Public |
| **GetCollectibleSortOrder** | `collectibleId`: integer | `sortOrder`: integer | Public |
| **GetCollectibleSubCategoryInfo** | `topLevelIndex`: luaindex<br>`subCategoryIndex`: luaindex | `name`: string | Public |
| **GetCollectibleTagInfo** | `collectibleId`: integer<br>`tagIndex`: luaindex | `tagDescription`: string | Public |
| **GetCollectibleUnlockStateById** | `collectibleId`: integer | `unlockState`: [CollectibleUnlockState|#CollectibleUnlockState] | Public |
| **GetCollectibleUserFlags** | `collectibleId`: integer | `userFlags`: [CollectibleUserFlags|#CollectibleUserFlags] | Public |
| **GetCollectiblesSearchResult** | `searchResultIndex`: luaindex | `categoryIndex`: luaindex | Public |
| **GetCombinationCollectibleComponentId** | `combinationId`: integer<br>`componentIndex`: luaindex | `collectibleId`: integer | Public |
| **GetCombinationNonFragmentComponentCollectibleIds** | `combinationId`: integer | `nonFragmentCollectibleId`: integer | Public |
| **GetCombinationNumCollectibleComponents** | `combinationId`: integer | `numCollectibleComponents`: integer | Public |
| **GetCombinationNumNonFragmentCollectibleComponents** | `combinationId`: integer | `numNonFragmentCollectibleComponents`: integer | Public |
| **GetCombinationNumUnlockedCollectibles** | `combinationId`: integer | `numUnlockedCollectibles`: integer | Public |
| **GetCombinationUnlockedCollectibleId** | `combinationId`: integer<br>`unlockedCollectibleIndex`: luaindex | `unlockedCollectibleId`: integer | Public |
| **GetCompanionCollectibleId** | `companionId`: integer | `collectibleId`: integer | Public |
| **GetCurrentCollectibleDyes** | `restyleMode`: [RestyleMode|#RestyleMode]<br>`collectibleId`: integer | `primaryDyeIndex`: integer | Public |
| **GetCurrentHouseTourListingCollectibleId** | - | `collectibleId`: integer | Public |
| **GetCursorCollectibleId** | - | `collectibleId`: integer:nilable | Public |
| **GetDyeColorsById** | `dyeId`: integer | `r`: number | Public |
| **GetDyeInfo** | `dyeIndex`: luaindex | `dyeName`: string | Public |
| **GetDyeInfoById** | `dyeId`: integer | `dyeName`: string | Public |
| **GetDyesSearchResult** | `searchResultIndex`: luaindex | `dyeIndex`: luaindex | Public |
| **GetEligibleOutfitSlotsForCollectible** | `collectibleId`: integer | `outfitSlot`: [OutfitSlot|#OutfitSlot] | Public |
| **GetEmoteCollectibleId** | `emoteIndex`: luaindex | `collectibleId`: integer:nilable | Public |
| **GetErrorStringLockedByCollectibleId** | `errorStringId`: integer | `lockedByCollectibleId`: integer | Public |
| **GetFastTravelNodeLinkedCollectibleId** | `nodeIndex`: luaindex | `collectibleId`: integer | Public |
| **GetHouseToursListingCollectibleIdByIndex** | `listingType`: [HouseTourListingType|#HouseTourListingType]<br>`listingIndex`: luaindex | `collectibleId`: integer | Public |
| **GetImperialCityCollectibleId** | - | `collectibleId`: integer | Public |
| **GetMountSkinId** | - | `skinId`: integer | Public |
| **GetNextDirtyBlacklistCollectibleId** | `lastCollectibleId`: integer:nilable | `nextCollectibleId`: integer:nilable | Public |
| **GetNextDirtyUnlockStateCollectibleId** | `lastCollectibleId`: integer:nilable | `nextCollectibleId`: integer:nilable | Public |
| **GetNumCollectibleCategories** | - | `numCategories`: integer | Public |
| **GetNumCollectibleNotifications** | - | `count`: integer | Public |
| **GetNumCollectiblePreviewActions** | `collectibleDefId`: integer<br>`variation`: luaindex | `numActions`: integer | Public |
| **GetNumCollectiblePreviewVariations** | `collectibleDefId`: integer | `numVariations`: integer | Public |
| **GetNumCollectibleTags** | `collectibleId`: integer | `numTags`: integer | Public |
| **GetNumCollectiblesInCollectibleCategory** | `topLevelIndex`: luaindex<br>`subCategoryIndex`: luaindex:nilable | `numCollectibles`: integer | Public |
| **GetNumCollectiblesSearchResults** | - | `numSearchResults`: integer | Public |
| **GetNumNewCollectibles** | - | `count`: integer | Public |
| **GetNumNewCollectiblesByCategoryType** | `collectibleCategoryType`: [CollectibleCategoryType|#CollectibleCategoryType] | `count`: integer | Public |
| **GetNumRewardPreviewCollectibleActions** | `rewardId`: integer<br>`variation`: luaindex | `numActions`: integer | Public |
| **GetNumSubcategoriesInCollectibleCategory** | `topLevelIndex`: luaindex | `numSubcategories`: integer | Public |
| **GetNumTradingHouseSearchResultItemPreviewCollectibleActions** | `index`: luaindex<br>`variation`: luaindex | `numActions`: integer | Public |
| **GetOutfitChangeFlatCost** | - | `flatCostStyleStones`: integer | Public |
| **GetOutfitName** | `actorCategory`: [GameplayActorCategory|#GameplayActorCategory]<br>`outfitIndex`: luaindex | `name`: string | Public |
| **GetOutfitSlotClearCost** | `outfitSlot`: [OutfitSlot|#OutfitSlot] | `cost`: integer | Public |

*... and 52 more functions in this category*

#### Campaign & PvP

*142 functions*

| Function | Parameters | Returns | Protection |
|----------|------------|---------|------------|
| **AreAllPromotionalEventCampaignRewardsClaimed** | `campaignKey`: id64 | `areAllClaimed`: bool | Public |
| **AssignCampaignToPlayer** | `campaignId`: integer<br>`reassignOnEnd`: [CampaignReassignmentRequestType|#CampaignReassignmentRequestType] | - | Public |
| **CanCampaignBeAllianceLocked** | `campaignId`: integer | `canCampaignBeAllianceLocked`: bool | Public |
| **CanLeaveCampaignQueue** | `campaignId`: integer<br>`queueAsGroup`: bool | `result`: [LeaveCampaignQueueResponseType|#LeaveCampaignQueueResponseType] | Public |
| **ConfirmCampaignEntry** | `campaignId`: integer<br>`queueAsGroup`: bool<br>`accept`: bool | - | Public |
| **DoesCampaignHaveEmperor** | `campaignId`: integer | `hasEmperor`: bool | Public |
| **DoesCurrentCampaignRulesetAllowChampionPoints** | - | `allowsChampionPoints`: bool | Public |
| **DoesPlayerMeetCampaignRequirements** | `campaignId`: integer | `meetsJoiningRequirements`: bool | Public |
| **GetActivePromotionalEventCampaignKey** | `campaignIndex`: luaindex | `campaignKey`: id64 | Public |
| **GetAllianceLockPendingNotificationInfo** | - | `campaignId`: integer:nilable | Public |
| **GetAllianceName** | `alliance`: [Alliance|#Alliance] | `name`: string | Public |
| **GetArtifactScrollObjectiveOriginalOwningAlliance** | `keepId`: integer<br>`objectiveId`: integer<br>`battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType] | `originalOwningAlliance`: [Alliance|#Alliance] | Public |
| **GetAssignedCampaignId** | - | `assignedCampaignId`: integer | Public |
| **GetBattlegroundCumulativeNumEarnedMedalsById** | `medalId`: integer | `count`: integer | Public |
| **GetBattlegroundCumulativeScoreForScoreboardEntryByType** | `entryIndex`: luaindex<br>`scoreType`: [ScoreTrackerEntryType|#ScoreTrackerEntryType]<br>`roundIndex`: luaindex:nilable | `score`: integer | Public |
| **GetBattlegroundDescription** | `battlegroundId`: integer | `description`: string | Public |
| **GetBattlegroundGameType** | `battlegroundId`: integer<br>`roundIndex`: luaindex:nilable | `gameType`: [BattlegroundGameType|#BattlegroundGameType] | Public |
| **GetBattlegroundInfoTexture** | `battlegroundId`: integer | `path`: textureName | Public |
| **GetBattlegroundLeaderboardEntryInfo** | `battlegroundLeaderboardType`: [BattlegroundLeaderboardType|#BattlegroundLeaderboardType]<br>`entryIndex`: luaindex | `rank`: integer | Public |
| **GetBattlegroundLeaderboardLocalPlayerInfo** | `lastBattlegroundLeaderboardType`: [BattlegroundLeaderboardType|#BattlegroundLeaderboardType] | `currentRank`: integer | Public |
| **GetBattlegroundLeaderboardsSchedule** | `leaderboardType`: [BattlegroundLeaderboardType|#BattlegroundLeaderboardType] | `secondsUntilEnd`: integer | Public |
| **GetBattlegroundMaxPlayerLives** | `battlegroundId`: integer | `maxPlayerLives`: integer | Public |
| **GetBattlegroundMedalIdByIndex** | `battlegroundId`: integer<br>`medalIndex`: luaindex | `medalId`: integer | Public |
| **GetBattlegroundName** | `battlegroundId`: integer | `name`: string | Public |
| **GetBattlegroundNumRounds** | `battlegroundId`: integer | `numRounds`: integer | Public |
| **GetBattlegroundNumTeams** | `battlegroundId`: integer | `numTeams`: integer | Public |
| **GetBattlegroundNumUsedMedals** | `battlegroundId`: integer | `numMedals`: integer | Public |
| **GetBattlegroundResultForTeam** | `battlegroundTeam`: [BattlegroundTeam|#BattlegroundTeam] | `result`: [BattlegroundResult|#BattlegroundResult] | Public |
| **GetBattlegroundRoundMaxActiveSequencedObjectives** | `battlegroundId`: integer<br>`roundIndex`: luaindex:nilable | `maxActiveSequencedObjectives`: integer | Public |
| **GetBattlegroundRoundNearingVictoryPercent** | `battlegroundId`: integer<br>`roundIndex`: luaindex:nilable | `nearingVictoryPercent`: number | Public |
| **GetBattlegroundTeamByIndex** | `battlegroundId`: integer<br>`teamIndex`: luaindex | `battlegroundTeam`: [BattlegroundTeam|#BattlegroundTeam]:nilable | Public |
| **GetBattlegroundTeamName** | `battlegroundTeam`: [BattlegroundTeam|#BattlegroundTeam] | `name`: string | Public |
| **GetBattlegroundTeamSize** | `battlegroundId`: integer | `teamSize`: integer | Public |
| **GetCampaignAbdicationStatus** | `campaignId`: integer | `abdicatedAlliance`: [Alliance|#Alliance] | Public |
| **GetCampaignAllianceLeaderboardEntryInfo** | `campaignId`: integer<br>`alliance`: [Alliance|#Alliance]<br>`entryIndex`: luaindex | `isPlayer`: bool | Public |
| **GetCampaignAlliancePotentialScore** | `campaignId`: integer<br>`alliance`: [Alliance|#Alliance] | `potentialScore`: integer | Public |
| **GetCampaignAllianceScore** | `campaignId`: integer<br>`alliance`: [Alliance|#Alliance] | `score`: integer | Public |
| **GetCampaignEmperorInfo** | `campaignId`: integer | `emperorAlliance`: [Alliance|#Alliance] | Public |
| **GetCampaignEmperorReignDuration** | `campaignId`: integer | `durationInSeconds`: integer | Public |
| **GetCampaignHistoryWindow** | `battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType] | `windowStartSecsAgo`: integer | Public |
| **GetCampaignHoldingScoreValues** | `campaignId`: integer | `keepValue`: integer | Public |
| **GetCampaignHoldings** | `campaignId`: integer<br>`holdingType`: [CampaignHoldingType|#CampaignHoldingType]<br>`alliance`: [Alliance|#Alliance]<br>*+1 more* | `holdingsControlled`: integer | Public |
| **GetCampaignKeyForNextReturningPlayerCampaign** | `campaignId`: integer | `campaignKey`: id64:nilable | Public |
| **GetCampaignLeaderboardEntryInfo** | `campaignId`: integer<br>`entryIndex`: luaindex | `isPlayer`: bool | Public |
| **GetCampaignLeaderboardMaxRank** | `campaignId`: integer | `maxRank`: integer | Public |
| **GetCampaignMatchResultFromHistoryByMatchIndex** | `matchIndex`: luaindex<br>`campaignKey`: id64:nilable | `hasRecord`: bool | Public |
| **GetCampaignName** | `campaignId`: integer | `campaignName`: string | Public |
| **GetCampaignPlacementRank** | `campaignKey`: id64:nilable | `tributeCampaignRank`: [TributeTier|#TributeTier] | Public |
| **GetCampaignQueueConfirmationDuration** | - | `numSeconds`: integer | Public |
| **GetCampaignQueueEntry** | `entryIndex`: luaindex | `campaignId`: integer | Public |
| **GetCampaignQueuePosition** | `campaignId`: integer<br>`queueAsGroup`: bool | `queuePosition`: integer | Public |
| **GetCampaignQueueRemainingConfirmationSeconds** | `campaignId`: integer<br>`queueAsGroup`: bool | `confirmationTimeRemainingInSeconds`: integer | Public |
| **GetCampaignQueueState** | `campaignId`: integer<br>`queueAsGroup`: bool | `currentState`: [CampaignQueueRequestStateType|#CampaignQueueRequestStateType] | Public |
| **GetCampaignReassignCooldown** | - | `cooldownSeconds`: integer | Public |
| **GetCampaignReassignCost** | `reassignType`: [CampaignReassignmentRequestType|#CampaignReassignmentRequestType] | `cost`: integer | Public |
| **GetCampaignReassignInitialCooldown** | - | `cooldownSeconds`: integer | Public |
| **GetCampaignRulesetDescription** | `rulesetId`: integer | `description`: string | Public |
| **GetCampaignRulesetDurationInSeconds** | `rulesetId`: integer | `duration`: integer | Public |
| **GetCampaignRulesetId** | `campaignId`: integer | `rulesetId`: integer | Public |
| **GetCampaignRulesetImperialKeepId** | `rulesetId`: integer<br>`alliance`: [Alliance|#Alliance]<br>`index`: luaindex | `keepId`: integer | Public |
| **GetCampaignRulesetName** | `rulesetId`: integer | `name`: string | Public |
| **GetCampaignRulesetNumImperialKeeps** | `rulesetId`: integer<br>`alliance`: [Alliance|#Alliance] | `numKeeps`: integer | Public |
| **GetCampaignRulesetType** | `rulesetId`: integer | `rulesetType`: [CampaignRulesetType|#CampaignRulesetType] | Public |
| **GetCampaignRulsetMinEmperorAlliancePoints** | `rulesetId`: integer<br>`alliance`: [Alliance|#Alliance] | `minPoints`: integer | Public |
| **GetCampaignSequenceId** | `campaignId`: integer | `sequenceId`: integer | Public |
| **GetCampaignUnassignCooldown** | - | `cooldownSeconds`: integer | Public |
| **GetCampaignUnassignCost** | `campaignUnassignType`: [CampaignUnassignRequestType|#CampaignUnassignRequestType] | `cost`: integer | Public |
| **GetCampaignUnassignInitialCooldown** | - | `cooldownSeconds`: integer | Public |
| **GetCampaignUnderdogLeaderAlliance** | `campaignId`: integer | `alliance`: [Alliance|#Alliance] | Public |
| **GetCaptureFlagObjectiveOriginalOwningAlliance** | `keepId`: integer<br>`objectiveId`: integer<br>`battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType] | `originalOwningAlliance`: [Alliance|#Alliance] | Public |
| **GetCarryableObjectiveHoldingAllianceInfo** | `keepId`: integer<br>`objectiveId`: integer<br>`battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType] | `holdingAlliance`: [Alliance|#Alliance] | Public |
| **GetCurrentCampaignId** | - | `currentCampaignId`: integer | Public |
| **GetCurrentCampaignLoyaltyStreak** | - | `currentLoyaltyStreak`: integer | Public |
| **GetCurrentCampaignMatchStreak** | `campaignKey`: id64:nilable | `currentStreak`: integer | Public |
| **GetHistoricalKeepAlliance** | `keepId`: integer<br>`battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType]<br>`historyPercent`: number | `alliance`: integer | Public |
| **GetImperialStyleId** | - | `imperialStyleId`: integer | Public |
| **GetMinLevelForCampaignTutorial** | - | `minLevelForCampaignTutorial`: integer | Public |
| **GetNumActivePromotionalEventCampaigns** | - | `numActiveCampaigns`: integer | Public |
| **GetNumCampaignAllianceLeaderboardEntries** | `campaignId`: integer<br>`alliance`: [Alliance|#Alliance] | `entryCount`: integer | Public |
| **GetNumCampaignLeaderboardEntries** | `campaignId`: integer | `entryCount`: integer | Public |
| **GetNumCampaignQueueEntries** | - | `entryCount`: integer | Public |
| **GetNumCampaignRulesetTypes** | - | `numRulesetTypes`: integer | Public |
| **GetNumFreeAnytimeCampaignReassigns** | - | `reassignCount`: integer | Public |
| **GetNumFreeAnytimeCampaignUnassigns** | - | `unassignCount`: integer | Public |
| **GetNumFreeEndCampaignReassigns** | - | `reassignCount`: integer | Public |
| **GetNumPromotionalEventCampaignActivities** | `campaignKey`: id64 | `numActivities`: integer | Public |
| **GetNumPromotionalEventCampaignMilestoneRewards** | `campaignKey`: id64 | `numMilestoneRewards`: integer | Public |
| **GetNumSelectionCampaignGroupMembers** | `campaignIndex`: luaindex | `numGroupmates`: integer | Public |
| **GetNumSelectionCampaigns** | - | `campaignCount`: integer | Public |
| **GetPendingAssignedCampaign** | - | `campaignId`: integer | Public |
| **GetPromotionalEventCampaignActivityDescription** | `campaignKey`: id64<br>`activityIndex`: luaindex | `description`: string | Public |
| **GetPromotionalEventCampaignActivityInfo** | `campaignKey`: id64<br>`activityIndex`: luaindex | `activityId`: integer | Public |
| **GetPromotionalEventCampaignActivityProgress** | `campaignKey`: id64<br>`activityIndex`: luaindex | `progress`: integer | Public |
| **GetPromotionalEventCampaignAnnouncementBackgroundFileIndex** | `campaignId`: integer | `backgroundFile`: textureName | Public |
| **GetPromotionalEventCampaignAnnouncementBannerOverrideType** | `campaignKey`: id64 | `overrideType`: [AnnouncementBannerOverrideType|#AnnouncementBannerOverrideType] | Public |
| **GetPromotionalEventCampaignDescription** | `campaignId`: integer | `description`: string | Public |
| **GetPromotionalEventCampaignDisplayName** | `campaignId`: integer | `displayName`: string | Public |
| **GetPromotionalEventCampaignInfo** | `campaignKey`: id64 | `campaignId`: integer | Public |
| **GetPromotionalEventCampaignLargeBackgroundFileIndex** | `campaignId`: integer | `backgroundFile`: textureName | Public |
| **GetPromotionalEventCampaignMilestoneInfo** | `campaignKey`: id64<br>`milestoneIndex`: luaindex | `completionThreshold`: integer | Public |

*... and 42 more functions in this category*

#### Crafting

*129 functions*

| Function | Parameters | Returns | Protection |
|----------|------------|---------|------------|
| **AreAllEnchantingRunesKnown** | `potencyRuneBagId`: [Bag|#Bag]<br>`potencyRuneSlotIndex`: integer<br>`essenceRuneBagId`: [Bag|#Bag]<br>*+3 more* | `isKnown`: bool | Public |
| **CanItemBeSmithingImproved** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer<br>`craftingSkillType`: [TradeskillType|#TradeskillType] | `canBeImproved`: bool | Public |
| **CanItemBeSmithingTraitResearched** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer<br>`craftingSkillType`: [TradeskillType|#TradeskillType]<br>*+2 more* | `canBeResearched`: bool | Public |
| **CanItemTakeEnchantment** | `itemToEnchantBagId`: [Bag|#Bag]<br>`itemToEnchantSlotIndex`: integer<br>`enchantmentToUseBagId`: [Bag|#Bag]<br>*+1 more* | `canEnchant`: bool | Public |
| **CanSmithingApparelPatternsBeCraftedHere** | - | `canBeCrafted`: bool | Public |
| **CanSmithingJewelryPatternsBeCraftedHere** | - | `canBeCrafted`: bool | Public |
| **CanSmithingSetPatternsBeCraftedHere** | - | `canBeCrafted`: bool | Public |
| **CanSmithingStyleBeUsedOnPattern** | `itemStyleId`: integer<br>`patternIndex`: luaindex<br>`materialIndex`: luaindex<br>*+1 more* | `canBeUsed`: bool | Public |
| **CanSpecificSmithingItemSetPatternBeCraftedHere** | `itemSetId`: integer | `canBeCrafted`: bool | Public |
| **CancelSmithingTraitResearch** | `tradeskillType`: [TradeskillType|#TradeskillType]<br>`researchLineIndex`: luaindex<br>`traitIndex`: luaindex | - | Public |
| **ClearCraftBagAutoTransferNotification** | - | - | Public |
| **CraftAlchemyItem** | `solventBagId`: [Bag|#Bag]<br>`solventSlotIndex`: integer<br>`reagent1BagId`: [Bag|#Bag]<br>*+6 more* | - | Public |
| **CraftEnchantingItem** | `potencyRuneBagId`: [Bag|#Bag]<br>`potencyRuneSlotIndex`: integer<br>`essenceRuneBagId`: [Bag|#Bag]<br>*+4 more* | - | Public |
| **CraftProvisionerItem** | `recipeListIndex`: luaindex<br>`recipeIndex`: luaindex<br>`numIterations`: integer | - | Public |
| **CraftSmithingItem** | `patternIndex`: luaindex<br>`materialIndex`: luaindex<br>`materialQuantity`: integer<br>*+4 more* | - | Public |
| **DoesAlchemyItemHaveKnownEncodedTrait** | `reagentBagId`: [Bag|#Bag]<br>`reagentSlotIndex`: integer<br>`encodedTraits`: integer | `isKnown`: bool | Public |
| **DoesAlchemyItemHaveKnownTrait** | `reagentBagId`: [Bag|#Bag]<br>`reagentSlotIndex`: integer<br>`traitId`: integer | `isKnown`: bool | Public |
| **DoesItemLinkHaveEnchantCharges** | `itemLink`: string | `hasCharges`: bool | Public |
| **DoesItemMatchSmithingMaterialTraitAndStyle** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer<br>`materialItemId`: integer<br>*+2 more* | `isMatchingItem`: bool | Public |
| **DoesPlayerHaveRunesForEnchanting** | `aspectItemId`: integer<br>`essenceItemId`: integer<br>`potencyItemId`: integer | `hasRunes`: bool | Public |
| **DoesSmithingTypeIgnoreStyleItems** | `tradeskillType`: [TradeskillType|#TradeskillType] | `ignoresStyleItems`: bool | Public |
| **EnchantItem** | `itemToEnchantBagId`: [Bag|#Bag]<br>`itemToEnchantSlotIndex`: integer<br>`enchantmentToUseBagId`: [Bag|#Bag]<br>*+1 more* | - | Public |
| **GetActiveConsolidatedSmithingItemSetId** | - | `itemSetId`: integer | Public |
| **GetAlchemyItemTraits** | `reagentBagId`: [Bag|#Bag]<br>`reagentSlotIndex`: integer | `trait`: string:nilable | Public |
| **GetAlchemyResultInspiration** | `solventBagId`: [Bag|#Bag]<br>`solventSlotIndex`: integer<br>`reagent1BagId`: [Bag|#Bag]<br>*+5 more* | `inspiration`: integer | Public |
| **GetAlchemyResultQuantity** | `solventBagId`: [Bag|#Bag]<br>`solventSlotIndex`: integer<br>`numIterations`: integer | `resultQuantity`: integer | Public |
| **GetAlchemyResultingItemIdIfKnown** | `solventBagId`: [Bag|#Bag]<br>`solventSlotIndex`: integer<br>`reagent1BagId`: [Bag|#Bag]<br>*+6 more* | `resultingItemId`: integer:nilable | Public |
| **GetAlchemyResultingItemInfo** | `solventBagId`: [Bag|#Bag]<br>`solventSlotIndex`: integer<br>`reagent1BagId`: [Bag|#Bag]<br>*+5 more* | `name`: string | Public |
| **GetAlchemyResultingItemLink** | `solventBagId`: [Bag|#Bag]<br>`solventSlotIndex`: integer<br>`reagent1BagId`: [Bag|#Bag]<br>*+6 more* | `link`: string | Public |
| **GetConsolidatedSmithingItemSetIdByIndex** | `setIndex`: luaindex | `itemSetId`: integer | Public |
| **GetConsolidatedSmithingItemSetSearchResult** | `index`: luaindex | `itemSetId`: integer | Public |
| **GetCostToCraftAlchemyItem** | `solventBagId`: [Bag|#Bag]<br>`solventSlotIndex`: integer<br>`numIterations`: integer | `cost`: integer | Public |
| **GetCostToCraftEnchantingItem** | `potencyRuneBagId`: [Bag|#Bag]<br>`potencyRuneSlotIndex`: integer<br>`essenceRuneBagId`: [Bag|#Bag]<br>*+4 more* | `cost`: integer | Public |
| **GetCostToCraftProvisionerItem** | `recipeListIndex`: luaindex<br>`recipeIndex`: luaindex<br>`numIterations`: integer | `cost`: integer | Public |
| **GetCostToCraftSmithingItem** | `patternIndex`: luaindex<br>`materialIndex`: luaindex<br>`materialQuantity`: integer<br>*+4 more* | `cost`: integer | Public |
| **GetCraftingInteractionMode** | - | `currentCraftingInteractionMode`: [CraftingInteractionMode|#CraftingInteractionMode] | Public |
| **GetCraftingInteractionType** | - | `currentCraftingInteractionType`: [TradeskillType|#TradeskillType] | Public |
| **GetCraftingSkillName** | `craftingSkillType`: [TradeskillType|#TradeskillType] | `name`: string | Public |
| **GetCurrentSmithingMaterialItemCount** | `patternIndex`: luaindex<br>`materialIndex`: luaindex | `count`: integer | Public |
| **GetCurrentSmithingStyleItemCount** | `itemStyleId`: integer | `count`: integer | Public |
| **GetCurrentSmithingTraitItemCount** | `traitItemIndex`: luaindex | `count`: integer | Public |
| **GetEnchantSearchCategoryType** | `enchantId`: integer | `searchCategory`: [EnchantmentSearchCategoryType|#EnchantmentSearchCategoryType] | Public |
| **GetEnchantedItemResultingItemLink** | `itemBagId`: [Bag|#Bag]<br>`itemSlotIndex`: integer<br>`enchantmentBagId`: [Bag|#Bag]<br>*+2 more* | `link`: string | Public |
| **GetEnchantingResultingItemInfo** | `potencyRuneBagId`: [Bag|#Bag]<br>`potencyRuneSlotIndex`: integer<br>`essenceRuneBagId`: [Bag|#Bag]<br>*+3 more* | `name`: string | Public |
| **GetEnchantingResultingItemLink** | `potencyRuneBagId`: [Bag|#Bag]<br>`potencyRuneSlotIndex`: integer<br>`essenceRuneBagId`: [Bag|#Bag]<br>*+4 more* | `link`: string | Public |
| **GetEnchantmentSearchCategories** | `itemType`: [ItemType|#ItemType] | `category`: integer | Public |
| **GetJewelrycraftingCollectibleId** | - | `jewelrycraftingCollectibleId`: integer | Public |
| **GetLastCraftingResultCurrencyInfo** | `resultIndex`: luaindex | `currencyType`: [CurrencyType|#CurrencyType] | Public |
| **GetLastCraftingResultItemInfo** | `resultIndex`: luaindex | `name`: string | Public |
| **GetLastCraftingResultItemLink** | `resultIndex`: luaindex<br>`linkStyle`: [LinkStyle|#LinkStyle] | `link`: string | Public |
| **GetLastCraftingResultLearnedTraitInfo** | `resultIndex`: luaindex | `traitName`: string | Public |
| **GetLastCraftingResultLearnedTranslationInfo** | `resultIndex`: luaindex | `translationName`: string | Public |
| **GetLastCraftingResultTotalInspiration** | - | `totalInspiration`: integer | Public |
| **GetMaxIterationsPossibleForAlchemyItem** | `solventBagId`: [Bag|#Bag]<br>`solventSlotIndex`: integer<br>`reagent1BagId`: [Bag|#Bag]<br>*+5 more* | `numIterations`: integer | Public |
| **GetMaxIterationsPossibleForEnchantingItem** | `potencyRuneBagId`: [Bag|#Bag]<br>`potencyRuneSlotIndex`: integer<br>`essenceRuneBagId`: [Bag|#Bag]<br>*+3 more* | `numIterations`: integer | Public |
| **GetMaxIterationsPossibleForSmithingItem** | `patternIndex`: luaindex<br>`materialIndex`: luaindex<br>`materialQuantity`: integer<br>*+3 more* | `numIterations`: integer | Public |
| **GetMaxSimultaneousSmithingResearch** | `craftingSkillType`: [TradeskillType|#TradeskillType] | `maxSimultaneousResearch`: integer | Public |
| **GetNextDirtyUnlockedConsolidatedSmithingItemSetId** | `lastItemSetId`: integer:nilable | `nextItemSetId`: integer:nilable | Public |
| **GetNextKnownRecipeForCraftingStation** | `recipeListIndex`: luaindex<br>`requiredCraftingStationType`: [TradeskillType|#TradeskillType]<br>`lastRecipeIndex`: luaindex:nilable | `nextRecipeIndex`: luaindex:nilable | Public |
| **GetNumConsolidatedSmithingItemSetSearchResults** | - | `numSearchResults`: integer | Public |
| **GetNumConsolidatedSmithingSets** | - | `numSets`: integer | Public |
| **GetNumCraftedAbilities** | - | `numCraftedAbilities`: integer | Public |
| **GetNumLastCraftingResultCurrencies** | - | `numCurrencies`: integer | Public |
| **GetNumLastCraftingResultItemsAndPenalty** | - | `numItems`: integer | Public |
| **GetNumLastCraftingResultLearnedTraits** | - | `numLearnedTraits`: integer | Public |
| **GetNumLastCraftingResultLearnedTranslations** | - | `numLearnedTranslations`: integer | Public |
| **GetNumProvisionerItemAsFurniturePreviewVariations** | `recipeListIndex`: luaindex<br>`recipeIndex`: luaindex | `numVariations`: integer | Public |
| **GetNumSmithingImprovementItems** | - | `numImprovementItems`: integer | Public |
| **GetNumSmithingPatterns** | - | `smithingPatterns`: integer | Public |
| **GetNumSmithingResearchLines** | `craftingSkillType`: [TradeskillType|#TradeskillType] | `numLines`: integer | Public |
| **GetNumSmithingTraitItems** | - | `numTraitItems`: integer | Public |
| **GetNumUnlockedConsolidatedSmithingSets** | - | `numUnlocked`: integer | Public |
| **GetProvisionerItemAsFurniturePreviewVariationDisplayName** | `recipeListIndex`: luaindex<br>`recipeIndex`: luaindex<br>`variation`: luaindex | `variationDisplayName`: string | Public |
| **GetRecipeInfo** | `recipeListIndex`: luaindex<br>`recipeIndex`: luaindex | `known`: bool | Public |
| **GetRecipeInfoFromItemId** | `itemId`: integer | `craftingStationType`: [TradeskillType|#TradeskillType]:nilable | Public |
| **GetRecipeIngredientItemInfo** | `recipeListIndex`: luaindex<br>`recipeIndex`: luaindex<br>`ingredientIndex`: luaindex | `name`: string | Public |
| **GetRecipeIngredientItemLink** | `recipeListIndex`: luaindex<br>`recipeIndex`: luaindex<br>`ingredientIndex`: luaindex<br>*+1 more* | `link`: string | Public |
| **GetRecipeIngredientRequiredQuantity** | `recipeListIndex`: luaindex<br>`recipeIndex`: luaindex<br>`ingredientIndex`: luaindex | `requiredQuantity`: integer | Public |
| **GetRecipeListInfo** | `recipeListIndex`: luaindex | `name`: string | Public |
| **GetRecipeResultItemInfo** | `recipeListIndex`: luaindex<br>`recipeIndex`: luaindex | `name`: string | Public |
| **GetRecipeResultItemLink** | `recipeListIndex`: luaindex<br>`recipeIndex`: luaindex<br>`linkStyle`: [LinkStyle|#LinkStyle] | `link`: string | Public |
| **GetRecipeResultQuantity** | `recipeListIndex`: luaindex<br>`recipeIndex`: luaindex<br>`numIterations`: integer | `quantity`: integer | Public |
| **GetRequiredSmithingRefinementStackSize** | - | `requiredStackSize`: integer | Public |
| **GetSmithingGuaranteedImprovementItemAmount** | `craftingSkillType`: [TradeskillType|#TradeskillType]<br>`improvementItemIndex`: luaindex | `numImprovementItemsRequired`: integer | Public |
| **GetSmithingImprovedItemInfo** | `itemToImproveBagId`: [Bag|#Bag]<br>`itemToImproveSlotIndex`: integer<br>`craftingSkillType`: [TradeskillType|#TradeskillType] | `itemName`: string | Public |
| **GetSmithingImprovedItemLink** | `itemToImproveBagId`: [Bag|#Bag]<br>`itemToImproveSlotIndex`: integer<br>`craftingSkillType`: [TradeskillType|#TradeskillType]<br>*+1 more* | `link`: string | Public |
| **GetSmithingImprovementChance** | `itemToImproveBagId`: [Bag|#Bag]<br>`itemToImproveSlotIndex`: integer<br>`numBoostersToUse`: integer<br>*+1 more* | `chance`: number | Public |
| **GetSmithingImprovementItemInfo** | `craftingSkillType`: [TradeskillType|#TradeskillType]<br>`improvementItemIndex`: luaindex | `itemName`: string | Public |
| **GetSmithingImprovementItemLink** | `craftingSkillType`: [TradeskillType|#TradeskillType]<br>`improvementItemIndex`: luaindex<br>`linkStyle`: [LinkStyle|#LinkStyle] | `link`: string | Public |
| **GetSmithingPatternArmorType** | `patternIndex`: luaindex | `armorType`: [ArmorType|#ArmorType] | Public |
| **GetSmithingPatternInfo** | `patternIndex`: luaindex<br>`materialIndexOverride`: luaindex:nilable<br>`materialQuanityOverride`: integer:nilable<br>*+2 more* | `patternName`: string | Public |
| **GetSmithingPatternInfoForItemId** | `itemId`: integer<br>`materialItemId`: integer<br>`craftingSkillType`: [TradeskillType|#TradeskillType] | `patternIndex`: luaindex:nilable | Public |
| **GetSmithingPatternInfoForItemSet** | `itemTemplateId`: integer<br>`itemSetId`: integer<br>`materialItemId`: integer<br>*+1 more* | `patternIndex`: luaindex:nilable | Public |
| **GetSmithingPatternMaterialItemInfo** | `patternIndex`: luaindex<br>`materialIndex`: luaindex | `itemName`: string | Public |
| **GetSmithingPatternMaterialItemLink** | `patternIndex`: luaindex<br>`materialIndex`: luaindex<br>`linkStyle`: [LinkStyle|#LinkStyle] | `link`: string | Public |
| **GetSmithingPatternResultLink** | `patternIndex`: luaindex<br>`materialIndex`: luaindex<br>`materialQuantity`: integer<br>*+3 more* | `link`: string | Public |
| **GetSmithingRefinedItemId** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `refinedItemId`: integer:nilable | Public |
| **GetSmithingRefinementMaxRawMaterial** | - | `maxRawMaterial`: integer | Public |
| **GetSmithingRefinementMinRawMaterial** | - | `minRawMaterial`: integer | Public |
| **GetSmithingResearchLineInfo** | `craftingSkillType`: [TradeskillType|#TradeskillType]<br>`researchLineIndex`: luaindex | `name`: string | Public |

*... and 29 more functions in this category*

#### Trading & Market

*120 functions*

| Function | Parameters | Returns | Protection |
|----------|------------|---------|------------|
| **BuyStoreItem** | `entryIndex`: luaindex<br>`quantity`: integer | - | Public |
| **CanAnyItemsBeStoredInCraftBag** | `bagId`: [Bag|#Bag] | `canBeStoredInCraftBag`: bool | Public |
| **CanCurrencyBeStoredInLocation** | `currencyType`: [CurrencyType|#CurrencyType]<br>`currencyLocation`: [CurrencyLocation|#CurrencyLocation] | `canBeStored`: bool | Public |
| **CanHousingEditorPlacementPreviewMarketProduct** | `marketProductId`: integer | `canPreview`: bool | Public |
| **CanPreviewMarketProduct** | `marketProductId`: integer | `isPreviewable`: bool | Public |
| **CanStoreRepair** | - | `canRepair`: bool | Public |
| **CanUnitTrade** | `unitTag`: string | `canTrade`: bool | Public |
| **ClearExpiringMarketCurrencyNotification** | - | - | Public |
| **ClearMarketProductUnlockNotifications** | - | - | Public |
| **CloseStore** | - | - | Public |
| **DoesAnyMarketProductPresentationMatchFilter** | `marketProductId`: integer<br>`filterTypes`: integer | `matchesFilter`: bool<br>`name`: string<br>*+1 more* | Public |
| **DoesMarketProductCategoryContainFilteredProducts** | `displayGroup`: [MarketDisplayGroup|#MarketDisplayGroup]<br>`topLevelIndex`: luaindex<br>`categoryIndex`: luaindex:nilable<br>*+1 more* | `containsProducts`: bool | Public |
| **DoesMarketProductCategoryOrSubcategoriesContainFilteredProducts** | `displayGroup`: [MarketDisplayGroup|#MarketDisplayGroup]<br>`topLevelIndex`: luaindex<br>`categoryIndex`: luaindex:nilable<br>*+1 more* | `containsProducts`: bool | Public |
| **DoesMarketProductMatchFilter** | `marketProductId`: integer<br>`presentationIndex`: luaindex:nilable<br>`filterTypes`: integer | `matchesFilter`: bool | Public |
| **DoesPlatformStoreUseExternalLinks** | - | `usesExternalLinks`: bool | Public |
| **FlagMarketAnnouncementSeen** | - | - | Public |
| **GetActiveAnnouncementMarketProductListingsForHouseTemplate** | `houseTemplateId`: integer | `marketProductId`: integer | Public |
| **GetActiveChapterUpgradeMarketProductListings** | `displayGroup`: [MarketDisplayGroup|#MarketDisplayGroup] | `marketProductId`: integer | Public |
| **GetActiveMarketProductListingsForHouseTemplate** | `houseTemplateId`: integer<br>`displayGroup`: [MarketDisplayGroup|#MarketDisplayGroup] | `marketProductId`: integer | Public |
| **GetCategoryIndicesFromMarketProductPresentation** | `marketProductId`: integer<br>`presentationIndex`: luaindex:nilable | `topLevelIndex`: luaindex:nilable<br>`expectedPurchaseResult`: [MarketPurchasableResult|#MarketPurchasableResult]<br>*+3 more* | Public |
| **GetChapterMarketBackgroundFileImage** | `chapterUpgradeId`: integer | `marketBackgroundFileIndex`: textureName | Public |
| **GetCurrencyPlayerStoredLocation** | `currencyType`: [CurrencyType|#CurrencyType] | `currencyLocation`: [CurrencyLocation|#CurrencyLocation] | Public |
| **GetCurrencyTypeFromMarketCurrencyType** | `marketCurrencyType`: [MarketCurrencyType|#MarketCurrencyType] | `currencyType`: [CurrencyType|#CurrencyType] | Public |
| **GetExpiringMarketCurrencyInfo** | `index`: luaindex | `marketCurrencyAmount`: integer | Public |
| **GetGiftMarketProductId** | `giftId`: id64 | `marketProductId`: integer | Public |
| **GetMarketAnnouncementCompletedDailyLoginRewardClaimsBackground** | - | `completedDailyLoginRewardClaimsBackground`: textureName | Public |
| **GetMarketAnnouncementDailyLoginLockedBackground** | - | `dailyLoginLockedAnnouncementBackground`: textureName | Public |
| **GetMarketAnnouncementHelpLinkIndices** | `marketProductId`: integer | `helpCategoryIndex`: luaindex:nilable | Public |
| **GetMarketCurrencyTypeFromCurrencyType** | `currencyType`: [CurrencyType|#CurrencyType] | `marketCurrencyType`: [MarketCurrencyType|#MarketCurrencyType] | Public |
| **GetMarketProductAssociatedAchievementId** | `marketProductId`: integer | `associatedAchievementId`: integer<br>`hasDLC`: bool<br>*+5 more* | Public |
| **GetMarketProductChapterUpgradeId** | `marketProductId`: integer | `chapterUpgradeId`: integer | Public |
| **GetMarketProductCollectiblePreviewActionDisplayName** | `marketProductId`: integer<br>`variation`: luaindex<br>`action`: luaindex | `actionDisplayName`: string | Public |
| **GetMarketProductCrownCrateRewardInfo** | `marketProductId`: integer | `rewardName`: string | Public |
| **GetMarketProductCrownCrateTierId** | `marketProductId`: integer | `crownCrateTierId`: integer | Public |
| **GetMarketProductCurrencyType** | `marketProductId`: integer | `currencyType`: [CurrencyType|#CurrencyType]<br>`expectedPurchaseResult`: [MarketPurchasableResult|#MarketPurchasableResult]<br>*+1 more* | Public |
| **GetMarketProductDisplayName** | `marketProductId`: integer | `displayName`: string<br>`description`: string<br>*+13 more* | Public |
| **GetMarketProductMaxGiftQuantity** | `marketProductId`: integer | `maxQuantity`: integer<br>`marketState`: [MarketState|#MarketState] | Public |
| **GetMarketProductPresentationIds** | `displayGroup`: [MarketDisplayGroup|#MarketDisplayGroup]<br>`topLevelIndex`: luaindex<br>`categoryIndex`: luaindex:nilable<br>*+1 more* | `marketProductId`: integer<br>`icon`: textureName<br>*+2 more* | Public |
| **GetMarketProductPreviewVariationDisplayName** | `marketProductId`: integer<br>`variation`: luaindex | `variationDisplayName`: string | Public |
| **GetMarketProductUnlockNotificationProductId** | `notificationIndex`: luaindex | `marketProductId`: integer | Public |
| **GetMarketProductUnlockedByAchievementId** | `marketProductId`: integer | `achievementId`: integer | Public |
| **GetMarketProductUnlockedByCollectibleIds** | `marketProductId`: integer | `collectibleIds`: integer | Public |
| **GetMarketProductUnlockedHelpIndices** | `marketProductId`: integer | `helpCategoryIndex`: luaindex:nilable<br>`isNew`: bool<br>*+13 more* | Public |
| **GetMarketProductsForItem** | `itemId`: integer<br>`onlyActiveListings`: bool | `marketProductId`: integer | Public |
| **GetNumExpiringMarketCurrencyInfos** | - | `numExpiringMarketCurrencyInfos`: integer | Public |
| **GetNumMarketProductCollectiblePreviewActions** | `marketProductId`: integer<br>`variation`: luaindex | `numActions`: integer | Public |
| **GetNumMarketProductPreviewVariations** | `marketProductId`: integer | `numVariations`: integer | Public |
| **GetNumMarketProductUnlockNotifications** | - | `numNotifications`: integer | Public |
| **GetNumRecipeTradeskillRequirements** | `recipeListIndex`: luaindex<br>`recipeIndex`: luaindex | `numTradeskillRequirements`: integer | Public |
| **GetNumStoreEntryPreviewCollectibleActions** | `entryIndex`: luaindex<br>`variation`: luaindex | `numActions`: integer | Public |
| **GetNumStoreEntryPreviewVariations** | `entryIndex`: luaindex | `numVariations`: integer | Public |
| **GetNumStoreItems** | - | `numItems`: integer | Public |
| **GetRecipeTradeskillRequirement** | `recipeListIndex`: luaindex<br>`recipeIndex`: luaindex<br>`tradeskillIndex`: luaindex | `tradeskill`: [TradeskillType|#TradeskillType] | Public |
| **GetStoreCollectibleInfo** | `entryIndex`: luaindex | `collectibleId`: integer | Public |
| **GetStoreCurrencyTypes** | - | `usesMoney`: bool | Public |
| **GetStoreDefaultSortField** | - | `defaultSortField`: [StoreDefaultSortField|#StoreDefaultSortField] | Public |
| **GetStoreEntryAntiquityId** | `entryIndex`: luaindex | `antiquityId`: integer | Public |
| **GetStoreEntryHouseTemplateId** | `entryIndex`: luaindex | `houseTemplateId`: integer | Public |
| **GetStoreEntryInfo** | `entryIndex`: luaindex | `icon`: textureName | Public |
| **GetStoreEntryMaxBuyable** | `entryIndex`: luaindex | `quantity`: integer | Public |
| **GetStoreEntryPreviewCollectibleActionDisplayName** | `entryIndex`: luaindex<br>`variation`: luaindex<br>`action`: luaindex | `actionDisplayName`: string | Public |
| **GetStoreEntryPreviewVariationDisplayName** | `entryIndex`: luaindex<br>`variation`: luaindex | `variationDisplayName`: string | Public |
| **GetStoreEntryQuestItemId** | `entryIndex`: luaindex | `questItemId`: integer | Public |
| **GetStoreEntryStatValue** | `entryIndex`: luaindex | `statValue`: integer | Public |
| **GetStoreEntryTypeInfo** | `entryIndex`: luaindex | `itemFilterType`: [ItemFilterType|#ItemFilterType] | Public |
| **GetStoreItemLink** | `entryIndex`: luaindex<br>`linkStyle`: [LinkStyle|#LinkStyle] | `link`: string | Public |
| **GetStoreUsedCurrencyTypes** | - | `currencyType`: [CurrencyType|#CurrencyType] | Public |
| **GetTradeInviteInfo** | - | `characterName`: string | Public |
| **GetTradeItemBagAndSlot** | `who`: [TradeParticipant|#TradeParticipant]<br>`tradeIndex`: luaindex | `bagId`: [Bag|#Bag]:nilable | Public |
| **GetTradeItemBoPTimeRemainingSeconds** | `who`: [TradeParticipant|#TradeParticipant]<br>`tradeIndex`: luaindex | `timeRemainingS`: integer | Public |
| **GetTradeItemBoPTradeableDisplayNamesString** | `who`: [TradeParticipant|#TradeParticipant]<br>`tradeIndex`: luaindex | `namesString`: string | Public |
| **GetTradeItemInfo** | `who`: [TradeParticipant|#TradeParticipant]<br>`tradeIndex`: luaindex | `name`: string | Public |
| **GetTradeItemLink** | `who`: [TradeParticipant|#TradeParticipant]<br>`tradeIndex`: luaindex<br>`linkStyle`: [LinkStyle|#LinkStyle] | `link`: string | Public |
| **GetTradeMoneyOffer** | `who`: [TradeParticipant|#TradeParticipant] | `moneyOffer`: integer | Public |
| **GetTradeskillRecipeCraftingSystem** | `tradeskillType`: [TradeskillType|#TradeskillType] | `recipeCraftingSystem`: [RecipeCraftingSystem|#RecipeCraftingSystem] | Public |
| **GetTradingHouseCooldownRemaining** | - | `cooldownMilliseconds`: integer | Public |
| **GetTradingHouseCutPercentage** | - | `cutPercentage`: number | Public |
| **GetTradingHouseListingCounts** | - | `currentListingCount`: integer | Public |
| **GetTradingHouseListingItemInfo** | `index`: luaindex | `icon`: textureName | Public |
| **GetTradingHouseListingItemLink** | `index`: luaindex<br>`linkStyle`: [LinkStyle|#LinkStyle] | `link`: string | Public |
| **GetTradingHouseListingPercentage** | - | `listingPercentage`: number | Public |
| **GetTradingHousePostPriceInfo** | `desiredPostPrice`: integer | `listingFee`: integer | Public |
| **GetTradingHouseSearchResultItemInfo** | `index`: luaindex | `icon`: textureName | Public |
| **GetTradingHouseSearchResultItemLink** | `index`: luaindex<br>`linkStyle`: [LinkStyle|#LinkStyle] | `link`: string | Public |
| **GetTradingHouseSearchResultItemPreviewCollectibleActionDisplayName** | `index`: luaindex<br>`variation`: luaindex<br>`action`: luaindex | `actionDisplayName`: string | Public |
| **GetTradingHouseSearchResultItemPreviewVariationDisplayName** | `index`: luaindex<br>`variation`: luaindex | `variationDisplayName`: string | Public |
| **GetTradingHouseSearchResultsInfo** | - | `numItemsOnPage`: integer | Public |
| **HasExpiringMarketCurrency** | - | `hasExpiringMarketCurrency`: bool | Public |
| **HasExpiringMarketCurrencyNotification** | - | `hasNotification`: bool | Public |
| **HasShownMarketAnnouncement** | - | `hasShownAnnouncement`: bool | Public |
| **HousingEditorCreateFurnitureForPlacementFromMarketProduct** | `marketProductId`: integer | `success`: bool | Public |
| **IsHousingEditorPreviewingMarketProductPlacement** | - | `isPreviewingMarketProductPlacement`: bool<br>`result`: [HousingRequestResult|#HousingRequestResult] | Public |
| **IsItemBoPAndTradeable** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `isBoPAndTradeable`: bool | Public |
| **IsItemFromCrownStore** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `isFromCrownStore`: bool | Public |
| **IsItemLinkFromCrownStore** | `itemLink`: string | `isFromCrownStore`: bool | Public |
| **IsLTODisabledForMarketProductCategory** | `displayGroup`: [MarketDisplayGroup|#MarketDisplayGroup]<br>`topLevelIndex`: luaindex<br>`categoryIndex`: luaindex:nilable | `isDisabled`: bool | Public |
| **IsPreviewingMarketProduct** | `marketProductId`: integer | `isBeingPreviewed`: bool | Public |
| **IsStoreEmpty** | - | `isEmpty`: bool | Public |
| **IsTradeItemBoPAndTradeable** | `who`: [TradeParticipant|#TradeParticipant]<br>`tradeIndex`: luaindex | `isBoPAndTradeable`: bool | Public |
| **PreviewStoreEntry** | `entryIndex`: luaindex<br>`variation`: luaindex<br>`dyeBrushId`: integer | - | Public |

*... and 20 more functions in this category*

#### UI & Interface

*117 functions*

| Function | Parameters | Returns | Protection |
|----------|------------|---------|------------|
| **ActionSlotHasRequirementFailure** | `actionSlotIndex`: luaindex<br>`hotbarCategory`: [HotBarCategory|#HotBarCategory]:nilable | `status`: bool | Public |
| **AreKeyboardBindingsSupportedInGamepadUI** | - | `keyboardBindingsSupported`: bool | Public |
| **CanEquippedItemBeShownInOutfitSlot** | `actorCategory`: [GameplayActorCategory|#GameplayActorCategory]<br>`equipSlot`: [EquipSlot|#EquipSlot]<br>`outfitSlot`: [OutfitSlot|#OutfitSlot] | `canShowItem`: bool | Public |
| **CanLoadoutRoleBeEquippedByIndex** | `index`: luaindex | `result`: [VengeanceActionResult|#VengeanceActionResult] | Public |
| **ClearActiveActionRequiredTutorial** | - | - | Public |
| **CompareBagItemToCurrentlyEquipped** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer<br>`equipSlot`: [EquipSlot|#EquipSlot] | `derivedStat`: [DerivedStats|#DerivedStats] | Public |
| **CompareItemLinkToCurrentlyEquipped** | `itemLink`: string<br>`equipSlot`: [EquipSlot|#EquipSlot] | `derivedStat`: [DerivedStats|#DerivedStats] | Public |
| **ComputeDepthAtWhichWorldHeightRendersAsUIHeight** | `worldHeight`: number<br>`UIHeight`: number | `depth`: number | Public |
| **ComputeDepthAtWhichWorldWidthRendersAsUIWidth** | `worldWidth`: number<br>`UIWidth`: number | `depth`: number | Public |
| **ConvertItemGlyphTierRangeToRequiredLevelRange** | `isChampionRank`: bool<br>`minTierLevel`: integer:nilable<br>`maxTierLevel`: integer:nilable | `minRequiredLevel`: integer | Public |
| **DoesActivitySetHaveAvailablityRequirementList** | `activitySetId`: integer | `hasAvailablityReq`: bool | Public |
| **DoesActivitySetPassAvailablityRequirementList** | `activitySetId`: integer | `passesAvailablityReq`: bool | Public |
| **DoesCurrentLanguageRequireIME** | - | `requiresIME`: bool | Public |
| **DoesGroupFinderFilterRequireChampion** | - | `setState`: bool | Public |
| **DoesGroupFinderFilterRequireEnforceRoles** | - | `setState`: bool | Public |
| **DoesGroupFinderFilterRequireInviteCode** | - | `setState`: bool | Public |
| **DoesGroupFinderFilterRequireVOIP** | - | `setState`: bool | Public |
| **DoesGroupFinderSearchListingRequireChampion** | `index`: luaindex | `requiresChampion`: bool | Public |
| **DoesGroupFinderSearchListingRequireInviteCode** | `index`: luaindex | `requiresInviteCode`: bool | Public |
| **DoesGroupFinderSearchListingRequireVOIP** | `index`: luaindex | `requiresVOIP`: bool | Public |
| **DoesGroupFinderUserTypeGroupListingRequireChampion** | `userType`: [GroupFinderGroupListingUserType|#GroupFinderGroupListingUserType] | `requiresChampion`: bool | Public |
| **DoesGroupFinderUserTypeGroupListingRequireDLC** | `userType`: [GroupFinderGroupListingUserType|#GroupFinderGroupListingUserType] | `requiresDLC`: bool | Public |
| **DoesGroupFinderUserTypeGroupListingRequireInviteCode** | `userType`: [GroupFinderGroupListingUserType|#GroupFinderGroupListingUserType] | `requiresInviteCode`: bool | Public |
| **DoesGroupFinderUserTypeGroupListingRequireVOIP** | `userType`: [GroupFinderGroupListingUserType|#GroupFinderGroupListingUserType] | `setState`: bool | Public |
| **DoesGroupMeetActivityLevelRequirements** | `activityId`: integer | `meetsLevelRequirements`: bool | Public |
| **DoesGroupModificationRequireVote** | - | `doesRequireVote`: bool | Public |
| **DoesPlayerMeetActivityLevelRequirements** | `activityId`: integer | `meetsLevelRequirements`: bool | Public |
| **EquipOutfit** | `actorCategory`: [GameplayActorCategory|#GameplayActorCategory]<br>`outfitIndex`: luaindex | - | Public |
| **GetActiveCutsceneVideoDataId** | - | `videoDataId`: integer | Public |
| **GetActiveCutsceneVideoPath** | - | `videoPath`: string | Public |
| **GetArmoryBuildChampionSpentPointsByDiscipline** | `buildIndex`: luaindex<br>`disciplineId`: integer | `spentPoints`: integer | Public |
| **GetArmoryBuildCurseType** | `buildIndex`: luaindex | `curseType`: [CurseType|#CurseType] | Public |
| **GetArmoryBuildEquipSlotInfo** | `buildIndex`: luaindex<br>`equipSlot`: [EquipSlot|#EquipSlot] | `equipSlotState`: [ArmoryBuildEquipSlotState|#ArmoryBuildEquipSlotState] | Public |
| **GetArmoryBuildEquippedOutfitIndex** | `buildIndex`: luaindex | `outfitIndex`: luaindex:nilable | Public |
| **GetArmoryBuildIconIndex** | `buildIndex`: luaindex | `buildIconIndex`: luaindex | Public |
| **GetArmoryBuildName** | `buildIndex`: luaindex | `buildName`: string | Public |
| **GetArmoryBuildPrimaryMundusStone** | `buildIndex`: luaindex | `mundusStone`: [MundusStone|#MundusStone] | Public |
| **GetArmoryBuildSecondaryMundusStone** | `buildIndex`: luaindex | `mundusStone`: [MundusStone|#MundusStone] | Public |
| **GetArmoryBuildSkillsTotalSpentPoints** | `buildIndex`: luaindex | `spentPoints`: integer | Public |
| **GetArmoryBuildSlotBoundId** | `buildIndex`: luaindex<br>`actionSlotIndex`: luaindex<br>`hotbarCategory`: [HotBarCategory|#HotBarCategory] | `actionId`: integer | Public |
| **GetAvailableSkillBuildIdByIndex** | `skillBuildIndex`: luaindex | `skillBuildId`: integer | Public |
| **GetChromaKeyboardKeyByZoGuiKey** | `zoGuiKeyCode`: [KeyCode|#KeyCode] | `chromaKeyboardKey`: [ChromaKeyboardKey|#ChromaKeyboardKey] | Public |
| **GetCurrencyAcquiredUISound** | `currencyType`: [CurrencyType|#CurrencyType] | `soundId`: string | Public |
| **GetCurrencyTransactUISound** | `currencyType`: [CurrencyType|#CurrencyType] | `soundId`: string | Public |
| **GetCurrentQuickslot** | - | `actionSlotIndex`: luaindex | Public |
| **GetCursorBagId** | - | `originatingBagId`: [Bag|#Bag]:nilable | Public |
| **GetCursorChampionSkillId** | - | `championSkillId`: integer:nilable | Public |
| **GetCursorContentType** | - | `cursorType`: integer | Public |
| **GetCursorEmoteId** | - | `emoteId`: integer:nilable | Public |
| **GetCursorQuickChatId** | - | `quickChatId`: integer:nilable | Public |
| **GetCursorSlotIndex** | - | `slotIndex`: integer:nilable | Public |
| **GetCursorVengeancePerkData** | - | `vengeancePerkIndex`: luaindex:nilable | Public |
| **GetDefaultQuickChatMessage** | `index`: luaindex | `message`: string | Public |
| **GetDefaultQuickChatName** | `index`: luaindex | `name`: string | Public |
| **GetDefaultSkillBuildId** | - | `skillBuildId`: integer | Public |
| **GetDigPowerBarUIPosition** | - | `x`: number | Public |
| **GetDigToolUIKeybindPosition** | `diggingActiveSkill`: [DiggingActiveSkills|#DiggingActiveSkills] | `x`: number | Public |
| **GetGuiHidden** | `guiName`: string | `hidden`: bool | Public |
| **GetLFGActivityRewardUINodeInfo** | `rewardUIDataId`: integer<br>`nodeIndex`: luaindex | `displayName`: string | Public |
| **GetNumAvailableSkillBuilds** | - | `numSkillBuilds`: integer | Public |
| **GetNumDefaultQuickChats** | - | `numQuickChats`: integer | Public |
| **GetNumLFGActivityRewardUINodes** | `rewardUIDataId`: integer | `numNodes`: integer | Public |
| **GetNumLevelUpGuiParticleEffects** | `level`: integer | `numEffects`: integer | Public |
| **GetNumRequiredPlacementMatches** | `campaignKey`: id64:nilable | `requiredMatches`: integer | Public |
| **GetNumSkillBuildAbilities** | `skillBuildId`: integer | `numSkillBuilds`: integer | Public |
| **GetNumUnlockedArmoryBuilds** | - | `numBuilds`: integer | Public |
| **GetQuickChatCategoryKeyboardIcons** | - | `unpressedButtonIcon`: textureName | Public |
| **GetRadarCountUIPosition** | - | `x`: number | Public |
| **GetRaidLeaderboardUISortIndex** | `raidCategory`: [RaidCategory|#RaidCategory]<br>`raidId`: integer | `uiSortIndex`: luaindex | Public |
| **GetRequiredChampionDisciplineIdForSlot** | `actionSlotIndex`: luaindex<br>`hotbarCategory`: [HotBarCategory|#HotBarCategory] | `requiredDisciplineId`: integer | Public |
| **GetSharedQuickChatIcon** | - | `sharedQuickChatIcon`: textureName | Public |
| **GetUIPlatform** | - | `platform`: [UIPlatform|#UIPlatform] | Public |
| **GetUISystemAssociatedWithHelpEntry** | `helpCategoryIndex`: luaindex<br>`helpIndex`: luaindex | `uiSystem`: [UISystem|#UISystem] | Public |
| **GuiRender3DPositionToWorldPosition** | `renderX`: number<br>`renderY`: number<br>`renderZ`: number | `worldX`: integer | Public |
| **HandleReturningPlayerUISystemShown** | `uiSystem`: [UISystem|#UISystem] | - | Public |
| **IsConsoleUI** | - | `isConsoleUI`: bool | Public |
| **IsCutsceneActive** | - | `isCutsceneActive`: bool | Public |
| **IsEquipSlotVisualCategoryHidden** | `equipSlotVisualCategory`: [EquipSlotVisualCategory|#EquipSlotVisualCategory]<br>`actorCategory`: [GameplayActorCategory|#GameplayActorCategory] | `isHidden`: bool | Public |
| **IsEquipable** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `isEquipable`: bool | Public |
| **IsGUIResizing** | - | `isGUIResizing`: bool | Public |
| **IsGameCameraUIModeActive** | - | `active`: bool | Public |
| **IsGamepadUISupported** | - | `isGamepadUISupported`: bool | Public |
| **IsInUI** | `guiName`: string | `isInUI`: bool | Public |
| **IsInternalBuild** | - | `isInternalBuild`: bool | Public |
| **IsItemLinkOnlyUsableFromQuickslot** | `itemLink`: string | `onlyUsableFromQuickslot`: bool | Public |
| **IsItemLinkUniqueEquipped** | `itemLink`: string | `isUniqueEquipped`: bool | Public |
| **IsKeyboardUISupported** | - | `isKeyboardUISupported`: bool | Public |
| **IsLoadoutRoleEquippedAtIndex** | `index`: luaindex | `isEquipped`: bool | Public |
| **IsMacUI** | - | `isMacUI`: bool | Public |
| **IsSkillBuildAdvancedMode** | - | `isSkillBuildAdvancedMode`: bool | Public |
| **IsTutorialActionRequired** | `tutorialIndex`: luaindex | `isActionRequired`: bool | Public |
| **IsValidArmoryBuildName** | `buildName`: string | `violationCode`: [NamingError|#NamingError] | Public |
| **IsValidQuickChatForSlot** | `quickChatId`: integer<br>`actionSlotIndex`: luaindex<br>`hotbarCategory`: [HotBarCategory|#HotBarCategory] | `valid`: bool | Public |
| **Quit** | - | - | Public |
| **ReloadUI** | `guiName`: string | - | Public |
| **SaveArmoryBuild** | `buildIndex`: luaindex | - | Public |
| **SelectSkillBuild** | `skillBuildId`: integer<br>`isAdvancedMode`: bool | - | Public |
| **SetArmoryBuildIconIndex** | `buildIndex`: luaindex<br>`iconIndex`: luaindex | - | Public |
| **SetArmoryBuildName** | `buildIndex`: luaindex<br>`buildName`: string | - | Public |
| **SetCrownCrateUIMenuActive** | `active`: bool | - | Public |

*... and 17 more functions in this category*

#### Tribute (Card Game)

*116 functions*

| Function | Parameters | Returns | Protection |
|----------|------------|---------|------------|
| **AcceptTribute** | - | - | Public |
| **CanSkipCurrentTributeTutorialStep** | - | `canSkip`: bool | Public |
| **ChallengeTargetToTribute** | `characterOrDisplayName`: string | - | Public |
| **DeclineTribute** | - | - | Public |
| **DoesTributeCardChooseOneMechanic** | `cardDefId`: integer | `chooseOneMechanic`: bool | Public |
| **DoesTributeCardHaveMechanicType** | `cardDefId`: integer<br>`mechanicType`: [TributeMechanic|#TributeMechanic] | `hasMechanicType`: bool | Public |
| **DoesTributeCardHaveSetbackMechanic** | `cardDefId`: integer | `hasSetbackMechanic`: bool | Public |
| **DoesTributeCardHaveTriggerMechanic** | `cardDefId`: integer | `hasTriggerMechanic`: bool | Public |
| **DoesTributeCardTaunt** | `cardDefId`: integer | `taunts`: bool | Public |
| **DoesTributePatronSkipNeutralFavorState** | `patronId`: integer | `doesSkipNeutral`: bool | Public |
| **DoesTributeSkipPatronDrafting** | - | `skipsDrafting`: bool | Public |
| **GetActiveTributeCampaignKey** | - | `tributeCampaignKey`: id64 | Public |
| **GetActiveTributeCampaignLeaderboardTierRewardListId** | `tributeCampaignRank`: [TributeLeaderboardTier|#TributeLeaderboardTier] | `rewardListId`: integer | Public |
| **GetActiveTributeCampaignTierRewardListId** | `tributeCampaignRank`: [TributeTier|#TributeTier] | `rewardListId`: integer | Public |
| **GetActiveTributeCampaignTimeRemainingS** | - | `timeRemainingS`: integer | Public |
| **GetActiveTributePlayerPerspective** | - | `playerPerspective`: [TributePlayerPerspective|#TributePlayerPerspective] | Public |
| **GetAllUnitAttributeVisualizerEffectInfo** | `unitTag`: string | `unitAttributeVisual`: [UnitAttributeVisual|#UnitAttributeVisual] | Public |
| **GetArmoryBuildAttributeSpentPoints** | `buildIndex`: luaindex<br>`attributeType`: [Attributes|#Attributes] | `spentPoints`: integer | Public |
| **GetLootTributeCardUpgradeInfo** | `lootId`: integer | `tributePatronDefId`: integer | Public |
| **GetMaxSpendableChampionPointsInAttribute** | - | `maxSpendableChampionPointsInAttribute`: integer | Public |
| **GetNewTributeCampaignRank** | - | `newTributeCampaignRank`: [TributeTier|#TributeTier] | Public |
| **GetNextTributeLeaderboardType** | `lastTributeLeaderboardType`: [TributeLeaderboardType|#TributeLeaderboardType]:nilable | `nextTributeLeaderboardType`: [TributeLeaderboardType|#TributeLeaderboardType]:nilable | Public |
| **GetNumAttributes** | - | `numAttributes`: integer | Public |
| **GetNumTributeCardMechanics** | `cardDefId`: integer<br>`activationSource`: [TributeMechanicActivationSource|#TributeMechanicActivationSource] | `numMechanics`: integer | Public |
| **GetNumTributeClubRankRewardLists** | - | `numTributeClubRankRewardLists`: integer | Public |
| **GetNumTributeLeaderboardEntries** | `tributeLeaderboardType`: [TributeLeaderboardType|#TributeLeaderboardType] | `numLeaderboardEntries`: integer | Public |
| **GetNumTributePatronMechanicsForFavorState** | `patronId`: integer<br>`favorState`: [TributePatronPerspectiveFavorState|#TributePatronPerspectiveFavorState] | `numMechanics`: integer | Public |
| **GetNumTributePatronPassiveMechanicsForFavorState** | `patronId`: integer<br>`favorState`: [TributePatronPerspectiveFavorState|#TributePatronPerspectiveFavorState] | `numPassiveMechanics`: integer | Public |
| **GetNumTributePatronRequirementsForFavorState** | `patronId`: integer<br>`favorState`: [TributePatronPerspectiveFavorState|#TributePatronPerspectiveFavorState] | `numRequirements`: integer | Public |
| **GetNumTributePatrons** | - | `numPatrons`: integer | Public |
| **GetPendingAttributeRespecScrollItemLink** | - | `itemLink`: string | Public |
| **GetPendingTributeCampaignExperience** | - | `pendingCampaignXP`: integer | Public |
| **GetPendingTributeClubExperience** | - | `pendingClubXP`: integer | Public |
| **GetTributeCampaignRankExperienceRequirement** | `tributeCampaignRank`: [TributeTier|#TributeTier]<br>`campaignKey`: id64:nilable | `experienceRequirement`: integer | Public |
| **GetTributeCardAcquireCost** | `cardDefId`: integer | `resource`: [TributeResource|#TributeResource] | Public |
| **GetTributeCardDefeatCost** | `cardDefId`: integer | `resource`: [TributeResource|#TributeResource] | Public |
| **GetTributeCardFlavorText** | `cardDefId`: integer | `flavorText`: string | Public |
| **GetTributeCardMechanicInfo** | `cardDefId`: integer<br>`activationSource`: [TributeMechanicActivationSource|#TributeMechanicActivationSource]<br>`mechanicIndex`: luaindex | `mechanicType`: [TributeMechanic|#TributeMechanic] | Public |
| **GetTributeCardMechanicText** | `cardDefId`: integer<br>`activationSource`: [TributeMechanicActivationSource|#TributeMechanicActivationSource]<br>`mechanicIndex`: luaindex<br>*+1 more* | `mechanicText`: string | Public |
| **GetTributeCardName** | `cardDefId`: integer | `name`: string | Public |
| **GetTributeCardPortrait** | `cardDefId`: integer | `portrait`: textureName | Public |
| **GetTributeCardPortraitIcon** | `cardDefId`: integer | `portraitIcon`: textureName | Public |
| **GetTributeCardRarity** | `cardDefId`: integer | `itemRarity`: [ItemDisplayQuality|#ItemDisplayQuality] | Public |
| **GetTributeCardType** | `cardDefId`: integer | `cardType`: [TributeCardType|#TributeCardType] | Public |
| **GetTributeCardUpgradeHintText** | `patronId`: integer<br>`cardIndex`: luaindex | `updateHintText`: string | Public |
| **GetTributeCardUpgradeRewardTributeCardUpgradeInfo** | `rewardId`: integer | `tributePatronDefId`: integer | Public |
| **GetTributeClubRankExperienceRequirement** | `tributeClubRank`: [TributeClubRank|#TributeClubRank] | `experienceRequirement`: integer | Public |
| **GetTributeClubRankNPCSkillLevelEquivalent** | `tributeClubRank`: [TributeClubRank|#TributeClubRank] | `npcSkillLevel`: [TributeNPCSkillLevel|#TributeNPCSkillLevel] | Public |
| **GetTributeClubRankRewardListIdByIndex** | `rewardListIndex`: luaindex | `rewardListId`: integer | Public |
| **GetTributeForfeitPenaltyDurationMs** | - | `forfeitPenaltyMs`: integer | Public |
| **GetTributeGeneralMatchLFGRewardUIDataId** | - | `rewardUIDataId`: integer | Public |
| **GetTributeGeneralMatchRewardListId** | - | `rewardListId`: integer | Public |
| **GetTributeInviteInfo** | - | `tributeInviteState`: [TributeInviteState|#TributeInviteState] | Public |
| **GetTributeLeaderboardEntryInfo** | `tributeLeaderboardType`: [TributeLeaderboardType|#TributeLeaderboardType]<br>`entryIndex`: luaindex | `rank`: integer | Public |
| **GetTributeLeaderboardLocalPlayerInfo** | `tributeLeaderboardType`: [TributeLeaderboardType|#TributeLeaderboardType] | `currentRank`: integer | Public |
| **GetTributeLeaderboardRankInfo** | - | `playerLeaderboardRank`: integer | Public |
| **GetTributeLeaderboardsSchedule** | - | `secondsUntilEnd`: integer | Public |
| **GetTributeMatchCampaignKey** | - | `tributeMatchCampaignKey`: id64 | Public |
| **GetTributeMatchStatistics** | - | `matchDurationMS`: integer | Public |
| **GetTributeMatchType** | - | `matchType`: [TributeMatchType|#TributeMatchType] | Public |
| **GetTributeMechanicIconPath** | `mechanicType`: [TributeMechanic|#TributeMechanic]<br>`param1`: integer<br>`param2`: integer<br>*+1 more* | `iconPath`: string | Public |
| **GetTributeMechanicSetbackTypeForPlayer** | `mechanicType`: [TributeMechanic|#TributeMechanic]<br>`targetPlayer`: [TributePlayerPerspective|#TributePlayerPerspective] | `mechanicSetbackType`: [TributeMechanicSetbackType|#TributeMechanicSetbackType] | Public |
| **GetTributeMechanicTargetingText** | `mechanicType`: [TributeMechanic|#TributeMechanic]<br>`quantity`: integer<br>`param1`: integer<br>*+3 more* | `targetingText`: string | Public |
| **GetTributePatronAcquireHint** | `patronId`: integer | `acquireHint`: string | Public |
| **GetTributePatronCategoryGamepadIcon** | `categoryId`: integer | `gamepadIcon`: textureName | Public |
| **GetTributePatronCategoryId** | `patronId`: integer | `categoryId`: integer | Public |
| **GetTributePatronCategoryKeyboardIcons** | `categoryId`: integer | `unpressedButtonIcon`: textureName | Public |
| **GetTributePatronCategoryName** | `categoryId`: integer | `categoryName`: string | Public |
| **GetTributePatronCategorySortOrder** | `categoryId`: integer | `sortOrder`: integer | Public |
| **GetTributePatronDockCardInfoByIndex** | `patronId`: integer<br>`cardIndex`: luaindex | `baseCardId`: integer | Public |
| **GetTributePatronFamily** | `patronId`: integer | `family`: integer | Public |
| **GetTributePatronIdAtIndex** | `index`: luaindex | `patronId`: integer | Public |
| **GetTributePatronLargeIcon** | `patronId`: integer | `largeIcon`: textureName | Public |
| **GetTributePatronLargeRingIcon** | `patronId`: integer | `largeRingIcon`: textureName | Public |
| **GetTributePatronLoreDescription** | `patronId`: integer | `loreDescription`: string | Public |
| **GetTributePatronMechanicInfo** | `patronId`: integer<br>`favorState`: [TributePatronPerspectiveFavorState|#TributePatronPerspectiveFavorState]<br>`mechanicIndex`: luaindex | `mechanicType`: [TributeMechanic|#TributeMechanic] | Public |
| **GetTributePatronMechanicText** | `patronId`: integer<br>`favorState`: [TributePatronPerspectiveFavorState|#TributePatronPerspectiveFavorState]<br>`mechanicIndex`: luaindex<br>*+1 more* | `mechanicText`: string | Public |
| **GetTributePatronMechanicsText** | `patronId`: integer<br>`favorState`: [TributePatronPerspectiveFavorState|#TributePatronPerspectiveFavorState] | `mechanicsText`: string | Public |
| **GetTributePatronName** | `patronId`: integer | `patronName`: string | Public |
| **GetTributePatronNumDockCards** | `patronId`: integer | `numStarterCards`: integer | Public |
| **GetTributePatronNumStarterCards** | `patronId`: integer | `numStarterCards`: integer | Public |
| **GetTributePatronPassiveMechanicInfo** | `patronId`: integer<br>`favorState`: [TributePatronPerspectiveFavorState|#TributePatronPerspectiveFavorState]<br>`mechanicIndex`: luaindex | `mechanicType`: [TributeMechanic|#TributeMechanic] | Public |
| **GetTributePatronPassiveMechanicText** | `patronId`: integer<br>`favorState`: [TributePatronPerspectiveFavorState|#TributePatronPerspectiveFavorState]<br>`mechanicIndex`: luaindex<br>*+1 more* | `passiveMechanicText`: string | Public |
| **GetTributePatronPlayStyleDescription** | `patronId`: integer | `playStyleDescription`: string | Public |
| **GetTributePatronRarity** | `patronId`: integer | `itemRarity`: [ItemDisplayQuality|#ItemDisplayQuality] | Public |
| **GetTributePatronRequirementIconPath** | `requirementType`: [TributePatronRequirement|#TributePatronRequirement]<br>`param1`: integer<br>`param2`: integer | `iconPath`: string | Public |
| **GetTributePatronRequirementInfo** | `patronId`: integer<br>`favorState`: [TributePatronPerspectiveFavorState|#TributePatronPerspectiveFavorState]<br>`requirementIndex`: luaindex | `requirementType`: [TributePatronRequirement|#TributePatronRequirement] | Public |
| **GetTributePatronRequirementTargetingText** | `requirementType`: [TributePatronRequirement|#TributePatronRequirement]<br>`quantity`: integer<br>`param1`: integer<br>*+2 more* | `targetingText`: string | Public |
| **GetTributePatronRequirementText** | `patronId`: integer<br>`favorState`: [TributePatronPerspectiveFavorState|#TributePatronPerspectiveFavorState]<br>`requirementIndex`: luaindex | `requirementText`: string | Public |
| **GetTributePatronRequirementsText** | `patronId`: integer<br>`favorState`: [TributePatronPerspectiveFavorState|#TributePatronPerspectiveFavorState] | `requirementsText`: string | Public |
| **GetTributePatronSmallIcon** | `patronId`: integer | `smallIcon`: textureName | Public |
| **GetTributePatronStarterCardIdByIndex** | `patronId`: integer<br>`cardIndex`: luaindex | `cardId`: integer | Public |
| **GetTributePatronSuitAtlas** | `patronId`: integer<br>`cardType`: [TributeCardType|#TributeCardType] | `suitAtlas`: textureName | Public |
| **GetTributePatronSuitIcon** | `patronId`: integer | `suitIcon`: textureName | Public |
| **GetTributePlayerCampaignRank** | `campaignKey`: id64:nilable | `tributeCampaignRank`: [TributeTier|#TributeTier] | Public |
| **GetTributePlayerCampaignTotalExperience** | `campaignKey`: id64:nilable | `totalTributeCampaignExperience`: integer | Public |
| **GetTributePlayerClubRank** | - | `tributeClubRank`: [TributeClubRank|#TributeClubRank] | Public |
| **GetTributePlayerClubTotalExperience** | - | `totalTributeClubExperience`: integer | Public |
| **GetTributePlayerExperienceInCurrentCampaignRank** | `campaignKey`: id64:nilable | `experience`: integer | Public |
| **GetTributePlayerExperienceInCurrentClubRank** | - | `experience`: integer | Public |

*... and 16 more functions in this category*

#### Character & Stats

*107 functions*

| Function | Parameters | Returns | Protection |
|----------|------------|---------|------------|
| **CanSpinPreviewCharacter** | - | `canSpin`: bool<br>`showHiddenGear`: bool | Public |
| **GetAttributeDerivedStatPerPointValue** | `attribute`: integer<br>`stat`: integer | `amountPerPoint`: number | Public |
| **GetAttributePointsAwardedForLevel** | `level`: integer | `numAttributePoints`: integer | Public |
| **GetAttributeRespecGoldCost** | - | `cost`: integer | Public |
| **GetAttributeSpentPoints** | `attributeType`: integer | `points`: integer | Public |
| **GetAttributeUnspentPoints** | - | `points`: integer | Public |
| **GetCarryableObjectiveHoldingCharacterInfo** | `keepId`: integer<br>`objectiveId`: integer<br>`battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType] | `rawCharacterName`: string | Public |
| **GetCarryableObjectiveLastHoldingCharacterInfo** | `keepId`: integer<br>`objectiveId`: integer<br>`battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType] | `rawCharacterName`: string | Public |
| **GetCharacterInfo** | `index`: luaindex | `name`: string | Public |
| **GetCharacterNameById** | `charId`: id64 | `name`: string | Public |
| **GetCurrentCharacterId** | - | `id`: string | Public |
| **GetCurrentCharacterSlotsUpgrade** | - | `currentCharacterSlotsUpgrade`: integer | Public |
| **GetFriendCharacterInfo** | `friendIndex`: luaindex | `hasCharacter`: bool | Public |
| **GetGroupFinderSearchListingLeaderCharacterNameByIndex** | `index`: luaindex | `characterName`: string | Public |
| **GetGroupFinderUserTypeGroupListingLeaderCharacterName** | `userType`: [GroupFinderGroupListingUserType|#GroupFinderGroupListingUserType] | `characterName`: string | Public |
| **GetGroupListingApplicationInfoByCharacterId** | `applicantCharId`: id64 | `displayName`: string | Public |
| **GetGroupListingApplicationNoteByCharacterId** | `applicantCharId`: id64 | `note`: string | Public |
| **GetGroupListingApplicationTimeRemainingSecondsByCharacterId** | `applicantCharId`: id64 | `timeRemainingSeconds`: integer | Public |
| **GetGuildMemberCharacterInfo** | `guildId`: integer<br>`memberIndex`: luaindex | `hasCharacter`: bool | Public |
| **GetIsNewCharacter** | - | `isNewCharacter`: bool | Public |
| **GetLevelUpBackground** | `level`: integer | `background`: textureName | Public |
| **GetLevelUpGuiParticleEffectInfo** | `level`: integer<br>`index`: luaindex | `texture`: textureName | Public |
| **GetLevelUpHelpIndicesForLevel** | `level`: integer | `helpCategoryIndex`: luaindex:nilable | Public |
| **GetLevelUpTextureLayerRevealAnimation** | `level`: integer<br>`index`: luaindex | `animationId`: integer | Public |
| **GetLevelUpTextureLayerRevealAnimationsMinDuration** | `level`: integer | `minDurationMS`: integer | Public |
| **GetMaxCharacterSlotsUpgrade** | - | `maxCharacterSlotsUpgrade`: integer | Public |
| **GetNextGroupListingApplicationCharacterId** | `lastApplicantCharId`: id64:nilable | `nextApplicantCharId`: id64:nilable | Public |
| **GetNumCharacterSlotsPerUpgrade** | - | `numSlots`: integer | Public |
| **GetNumCharacters** | - | `numCharacters`: integer | Public |
| **GetNumOwnedCharacterSlots** | - | `numOwnedCharacterSlots`: integer | Public |
| **GetPlayerActiveSubzoneName** | - | `subzoneName`: string | Public |
| **GetPlayerActiveZoneName** | - | `zoneName`: string | Public |
| **GetPlayerApplicationNotificationInfo** | `index`: luaindex | `declineReason`: string | Public |
| **GetPlayerCameraHeading** | - | `heading`: number | Public |
| **GetPlayerCampaignRewardTierInfo** | `campaignId`: integer | `earnedTier`: integer | Public |
| **GetPlayerChampionPointsEarned** | - | `points`: integer | Public |
| **GetPlayerChampionXP** | - | `championExp`: integer | Public |
| **GetPlayerCurseType** | - | `curseType`: [CurseType|#CurseType] | Public |
| **GetPlayerEndlessDungeonOfTheWeekParticipationInfo** | `endlessDungeonGroupType`: [EndlessDungeonGroupType|#EndlessDungeonGroupType] | `isParticipating`: bool | Public |
| **GetPlayerEndlessDungeonOfTheWeekProgressInfo** | `endlessDungeonGroupType`: [EndlessDungeonGroupType|#EndlessDungeonGroupType] | `inProgress`: bool | Public |
| **GetPlayerEndlessDungeonParticipationInfo** | `endlessDungeonGroupType`: [EndlessDungeonGroupType|#EndlessDungeonGroupType]<br>`endlessDungeonId`: integer | `isParticipating`: bool | Public |
| **GetPlayerEndlessDungeonProgressInfo** | `endlessDungeonGroupType`: [EndlessDungeonGroupType|#EndlessDungeonGroupType]<br>`endlessDungeonId`: integer | `inProgress`: bool | Public |
| **GetPlayerGuildMemberIndex** | `guildId`: integer | `memberIndex`: luaindex | Public |
| **GetPlayerInfamyData** | - | `heat`: integer | Public |
| **GetPlayerLocationName** | - | `mapName`: string | Public |
| **GetPlayerMMRByType** | `activity`: [LFGActivity|#LFGActivity] | `mmrRating`: integer | Public |
| **GetPlayerMarketCurrency** | `type`: [MarketCurrencyType|#MarketCurrencyType] | `currencyAmount`: integer | Public |
| **GetPlayerRaidOfTheWeekParticipationInfo** | `raidCategory`: [RaidCategory|#RaidCategory] | `isParticipating`: bool | Public |
| **GetPlayerRaidOfTheWeekProgressInfo** | `raidCategory`: [RaidCategory|#RaidCategory] | `inProgress`: bool | Public |
| **GetPlayerRaidParticipationInfo** | `raidId`: integer | `isParticipating`: bool | Public |
| **GetPlayerRaidProgressInfo** | `raidId`: integer | `inProgress`: bool | Public |
| **GetPlayerStat** | `derivedStat`: [DerivedStats|#DerivedStats]<br>`statBonusOption`: [StatBonusOption|#StatBonusOption] | `value`: integer | Public |
| **GetPlayerStatus** | - | `status`: [PlayerStatus|#PlayerStatus] | Public |
| **GetPlayerWorldPositionInHouse** | - | `worldX`: integer | Public |
| **GetSelectionCampaignAllianceLockConflictingCharacterName** | `campaignIndex`: luaindex | `conflictingCharacterName`: string:nilable | Public |
| **GetTargetMountedStateInfo** | `characterOrDisplayName`: string | `mountedState`: [MountedState|#MountedState] | Public |
| **GetUniqueNameForCharacter** | `characterName`: string | `uniqueName`: string | Public |
| **GetUnitActiveMundusStoneBuffIndices** | `unitTag`: string | `mundusStoneBuffIndex`: luaindex | Public |
| **GetUnitAlliance** | `unitTag`: string | `alliance`: integer | Public |
| **GetUnitAttributeVisualizerEffectInfo** | `unitTag`: string<br>`unitAttributeVisual`: [UnitAttributeVisual|#UnitAttributeVisual]<br>`statType`: [DerivedStats|#DerivedStats]<br>*+2 more* | `value`: number:nilable | Public |
| **GetUnitAvARank** | `unitTag`: string | `rank`: integer | Public |
| **GetUnitAvARankPoints** | `unitTag`: string | `AvARankPoints`: integer | Public |
| **GetUnitBankAccessBag** | `unitTag`: string | `bankBag`: [Bag|#Bag]:nilable | Public |
| **GetUnitBattleLevel** | `unitTag`: string | `battleLevel`: integer | Public |
| **GetUnitBattlegroundTeam** | `unitTag`: string | `battlegroundTeam`: [BattlegroundTeam|#BattlegroundTeam] | Public |
| **GetUnitBuffInfo** | `unitTag`: string<br>`buffIndex`: luaindex | `buffName`: string | Public |
| **GetUnitCaption** | `unitTag`: string | `caption`: string | Public |
| **GetUnitChampionBattleLevel** | `unitTag`: string | `champBattleLevel`: integer | Public |
| **GetUnitChampionPoints** | `unitTag`: string | `championPoints`: integer | Public |
| **GetUnitClass** | `unitTag`: string | `className`: string | Public |
| **GetUnitClassId** | `unitTag`: string | `classId`: integer | Public |
| **GetUnitDifficulty** | `unitTag`: string | `difficult`: [UIMonsterDifficulty|#UIMonsterDifficulty] | Public |
| **GetUnitDisguiseState** | `unitTag`: string | `disguiseState`: integer | Public |
| **GetUnitDisplayName** | `unitTag`: string | `displayName`: string | Public |
| **GetUnitDrownTime** | `unitTag`: string | `startTime`: number | Public |
| **GetUnitEffectiveChampionPoints** | `unitTag`: string | `championPoints`: integer | Public |
| **GetUnitEffectiveLevel** | `unitTag`: string | `level`: integer | Public |
| **GetUnitGender** | `unitTag`: string | `gender`: [Gender|#Gender] | Public |
| **GetUnitGuildKioskOwner** | `unitTag`: string | `ownerGuildId`: integer | Public |
| **GetUnitHidingEndTime** | `unitTag`: string | `endTime`: number | Public |
| **GetUnitLevel** | `unitTag`: string | `level`: integer | Public |
| **GetUnitName** | `unitTag`: string | `name`: string | Public |
| **GetUnitNameHighlightedByReticle** | - | `name`: string | Public |
| **GetUnitPower** | `unitTag`: string<br>`powerType`: [CombatMechanicFlags|#CombatMechanicFlags] | `current`: integer | Public |
| **GetUnitPowerInfo** | `unitTag`: string<br>`poolIndex`: luaindex | `type`: integer:nilable | Public |
| **GetUnitRace** | `unitTag`: string | `race`: string | Public |
| **GetUnitRaceId** | `unitTag`: string | `raceId`: integer | Public |
| **GetUnitRawWorldPosition** | `unitTag`: string | `zoneId`: integer | Public |
| **GetUnitReaction** | `unitTag`: string | `unitReaction`: [UnitReactionType|#UnitReactionType] | Public |
| **GetUnitReactionColor** | `unitTag`: string | `red`: number | Public |
| **GetUnitReactionColorType** | `unitTag`: string | `reactionColorType`: [UnitReactionColor|#UnitReactionColor] | Public |
| **GetUnitSilhouetteTexture** | `unitTag`: string | `icon`: string | Public |
| **GetUnitStealthState** | `unitTag`: string | `stealthState`: integer | Public |
| **GetUnitTargetMarkerType** | `unitTag`: string | `targetMarkerType`: [TargetMarkerType|#TargetMarkerType] | Public |
| **GetUnitTitle** | `unitTag`: string | `title`: string | Public |
| **GetUnitType** | `unitTag`: string | `type`: integer | Public |
| **GetUnitWorldPosition** | `unitTag`: string | `zoneId`: integer | Public |
| **GetUnitXP** | `unitTag`: string | `exp`: integer | Public |
| **GetUnitXPMax** | `unitTag`: string | `maxExp`: integer | Public |
| **GetUnitZone** | `unitTag`: string | `zoneName`: string | Public |

*... and 7 more functions in this category*

#### Social

*94 functions*

| Function | Parameters | Returns | Protection |
|----------|------------|---------|------------|
| **AcceptFriendRequest** | `displayName`: string | - | Public |
| **AddIgnore** | `charOrDisplayName`: string | - | Public |
| **CancelFriendRequest** | `index`: luaindex | - | Public |
| **ClearSessionIgnores** | - | - | Public |
| **GetChatCategoryColor** | `category`: [ChatChannelCategories|#ChatChannelCategories] | `red`: number | Public |
| **GetChatChannelId** | `name`: string | `channelId`: [ChannelType|#ChannelType] | Public |
| **GetChatContainerColors** | `chatContainerIndex`: luaindex | `bgRed`: number | Public |
| **GetChatContainerTabInfo** | `chatContainerIndex`: luaindex<br>`tabIndex`: luaindex | `name`: string | Public |
| **GetChatFontSize** | - | `fontSize`: integer | Public |
| **GetChatterData** | - | `text`: string | Public |
| **GetChatterFarewell** | - | `backToTOCString`: string | Public |
| **GetChatterGreeting** | - | `optionString`: string | Public |
| **GetChatterOption** | `optionIndex`: luaindex | `optionString`: string | Public |
| **GetChatterOptionCount** | - | `optionCount`: integer | Public |
| **GetChatterOptionWaypoints** | `optionIndex`: luaindex | `waypointId`: integer | Public |
| **GetFriendInfo** | `friendIndex`: luaindex | `displayName`: string | Public |
| **GetGroupAddOnDataBroadcastCooldownRemainingMS** | - | `cooldownRemainingMS`: integer | Public |
| **GetGroupElectionInfo** | - | `electionType`: [GroupElectionType|#GroupElectionType] | Public |
| **GetGroupElectionUnreadyUnitTags** | - | `unreadyPlayers`: string | Public |
| **GetGroupElectionVoteByUnitTag** | `unitTag`: string | `choice`: [GroupVoteChoice|#GroupVoteChoice] | Public |
| **GetGroupFinderCreateGroupListingChampionPoints** | `userType`: [GroupFinderGroupListingUserType|#GroupFinderGroupListingUserType] | `championPoints`: integer | Public |
| **GetGroupFinderFilterCategory** | - | `category`: [GroupFinderCategory|#GroupFinderCategory] | Public |
| **GetGroupFinderFilterChampionPoints** | - | `championPoints`: integer | Public |
| **GetGroupFinderFilterGroupSizeIterationEnd** | - | `groupSize`: [GroupFinderGroupSize|#GroupFinderGroupSize] | Public |
| **GetGroupFinderFilterGroupSizes** | - | `groupSizes`: [GroupFinderGroupSize|#GroupFinderGroupSize] | Public |
| **GetGroupFinderFilterNumPrimaryOptions** | - | `numOptions`: integer | Public |
| **GetGroupFinderFilterNumSecondaryOptions** | - | `numOptions`: integer | Public |
| **GetGroupFinderFilterPlaystyles** | - | `playstyle`: [GroupFinderPlaystyle|#GroupFinderPlaystyle] | Public |
| **GetGroupFinderFilterPrimaryOptionByIndex** | `index`: luaindex | `name`: string | Public |
| **GetGroupFinderFilterSecondaryOptionByIndex** | `index`: luaindex | `name`: string | Public |
| **GetGroupFinderGroupFilterSearchString** | - | `searchString`: string | Public |
| **GetGroupFinderSearchListingCategoryByIndex** | `index`: luaindex | `category`: [GroupFinderCategory|#GroupFinderCategory] | Public |
| **GetGroupFinderSearchListingChampionPointsByIndex** | `index`: luaindex | `championPoints`: integer | Public |
| **GetGroupFinderSearchListingDescriptionByIndex** | `index`: luaindex | `description`: string | Public |
| **GetGroupFinderSearchListingFirstLockingCollectibleId** | `index`: luaindex | `collectibleId`: integer | Public |
| **GetGroupFinderSearchListingGroupSizeByIndex** | `index`: luaindex | `groupSize`: [GroupFinderGroupSize|#GroupFinderGroupSize] | Public |
| **GetGroupFinderSearchListingLeaderDisplayNameByIndex** | `index`: luaindex | `displayName`: string | Public |
| **GetGroupFinderSearchListingNumRolesByIndex** | `index`: luaindex | `numRoles`: integer | Public |
| **GetGroupFinderSearchListingOptionsSelectionTextByIndex** | `index`: luaindex | `primaryOption`: string | Public |
| **GetGroupFinderSearchListingPlaystyleByIndex** | `index`: luaindex | `playstyle`: [GroupFinderPlaystyle|#GroupFinderPlaystyle] | Public |
| **GetGroupFinderSearchListingRoleStatusCount** | `index`: luaindex<br>`role`: [LFGRole|#LFGRole] | `desiredCount`: integer | Public |
| **GetGroupFinderSearchListingTitleByIndex** | `index`: luaindex | `title`: string | Public |
| **GetGroupFinderSearchNumListings** | - | `numListings`: integer | Public |
| **GetGroupFinderStatusReason** | - | `statusReason`: [GroupFinderActionResult|#GroupFinderActionResult] | Public |
| **GetGroupFinderUserTypeGroupListingAttainedRoleCount** | `userType`: [GroupFinderGroupListingUserType|#GroupFinderGroupListingUserType]<br>`role`: [LFGRole|#LFGRole] | `count`: integer | Public |
| **GetGroupFinderUserTypeGroupListingCategory** | `userType`: [GroupFinderGroupListingUserType|#GroupFinderGroupListingUserType] | `category`: [GroupFinderCategory|#GroupFinderCategory] | Public |
| **GetGroupFinderUserTypeGroupListingDescription** | `userType`: [GroupFinderGroupListingUserType|#GroupFinderGroupListingUserType] | `description`: string | Public |
| **GetGroupFinderUserTypeGroupListingDesiredRoleCount** | `userType`: [GroupFinderGroupListingUserType|#GroupFinderGroupListingUserType]<br>`role`: [LFGRole|#LFGRole] | `count`: integer | Public |
| **GetGroupFinderUserTypeGroupListingGroupSize** | `userType`: [GroupFinderGroupListingUserType|#GroupFinderGroupListingUserType] | `groupSize`: [GroupFinderGroupSize|#GroupFinderGroupSize] | Public |
| **GetGroupFinderUserTypeGroupListingInviteCode** | `userType`: [GroupFinderGroupListingUserType|#GroupFinderGroupListingUserType] | `inviteCode`: integer | Public |
| **GetGroupFinderUserTypeGroupListingLeaderDisplayName** | `userType`: [GroupFinderGroupListingUserType|#GroupFinderGroupListingUserType] | `displayName`: string | Public |
| **GetGroupFinderUserTypeGroupListingNumPrimaryOptions** | `userType`: [GroupFinderGroupListingUserType|#GroupFinderGroupListingUserType] | `numOptions`: integer | Public |
| **GetGroupFinderUserTypeGroupListingNumRoles** | `userType`: [GroupFinderGroupListingUserType|#GroupFinderGroupListingUserType] | `numRoles`: integer | Public |
| **GetGroupFinderUserTypeGroupListingNumSecondaryOptions** | `userType`: [GroupFinderGroupListingUserType|#GroupFinderGroupListingUserType] | `numOptions`: integer | Public |
| **GetGroupFinderUserTypeGroupListingOptionsSelectionText** | `userType`: [GroupFinderGroupListingUserType|#GroupFinderGroupListingUserType] | `primaryOptionText`: string | Public |
| **GetGroupFinderUserTypeGroupListingPlaystyle** | `userType`: [GroupFinderGroupListingUserType|#GroupFinderGroupListingUserType] | `playstyle`: [GroupFinderPlaystyle|#GroupFinderPlaystyle] | Public |
| **GetGroupFinderUserTypeGroupListingPrimaryOptionByIndex** | `userType`: [GroupFinderGroupListingUserType|#GroupFinderGroupListingUserType]<br>`index`: luaindex | `name`: string | Public |
| **GetGroupFinderUserTypeGroupListingSecondaryOptionByIndex** | `userType`: [GroupFinderGroupListingUserType|#GroupFinderGroupListingUserType]<br>`index`: luaindex | `name`: string | Public |
| **GetGroupFinderUserTypeGroupListingTitle** | `userType`: [GroupFinderGroupListingUserType|#GroupFinderGroupListingUserType] | `title`: string | Public |
| **GetGroupFinderUserTypeGroupSizeIterationBegin** | `userType`: [GroupFinderGroupListingUserType|#GroupFinderGroupListingUserType] | `groupSize`: [GroupFinderGroupSize|#GroupFinderGroupSize] | Public |
| **GetGroupFinderUserTypeGroupSizeIterationEnd** | `userType`: [GroupFinderGroupListingUserType|#GroupFinderGroupListingUserType] | `groupSize`: [GroupFinderGroupSize|#GroupFinderGroupSize] | Public |
| **GetGroupIndexByUnitTag** | `unitTag`: string | `sortIndex`: luaindex | Public |
| **GetGroupInviteInfo** | - | `characterName`: string | Public |
| **GetGroupLeaderUnitTag** | - | `leaderUnitTag`: string | Public |
| **GetGroupMemberSelectedRole** | `unitTag`: string | `role`: [LFGRole|#LFGRole] | Public |
| **GetGroupSize** | - | `groupSize`: integer | Public |
| **GetGroupSizeFromLFGGroupType** | `groupType`: [LFGGroupType|#LFGGroupType] | `size`: integer | Public |
| **GetGroupUnitTagByCompanionUnitTag** | `companionUnitTag`: string | `groupUnitTag`: string:nilable | Public |
| **GetGroupUnitTagByIndex** | `sortIndex`: luaindex | `unitTag`: string:nilable | Public |
| **GetIgnoredInfo** | `index`: luaindex | `displayName`: string | Public |
| **GetIncomingFriendRequestInfo** | `index`: luaindex | `displayName`: string | Public |
| **GetLeaderboardCampaignSequenceId** | `campaignId`: integer | `campaignSequenceId`: integer | Public |
| **GetLeaderboardScoreNotificationInfo** | `notificationId`: integer | `contentType`: [LeaderboardScoreNotificationType|#LeaderboardScoreNotificationType] | Public |
| **GetLeaderboardScoreNotificationMemberInfo** | `notificationId`: integer<br>`memberIndex`: luaindex | `displayName`: string | Public |
| **GetNumFriendlyKeepNPCs** | `keepId`: integer<br>`battlegroundContext`: [BattlegroundQueryContextType|#BattlegroundQueryContextType] | `numFriendlyNPC`: integer | Public |
| **GetNumFriends** | - | `numFriends`: integer | Public |
| **GetNumIgnored** | - | `numIgnored`: integer | Public |
| **GetNumIncomingFriendRequests** | - | `numRequests`: integer | Public |
| **GetNumOutgoingFriendRequests** | - | `numRequests`: integer | Public |
| **GetNumSelectionCampaignFriends** | `campaignIndex`: luaindex | `numFriends`: integer | Public |
| **GetOutgoingFriendRequestInfo** | `index`: luaindex | `displayName`: string | Public |
| **IsFriend** | `charOrDisplayName`: string | `isFriend`: bool | Public |
| **IsIgnored** | `charOrDisplayName`: string | `isIgnored`: bool | Public |
| **IsUnitFriend** | `unitTag`: string | `isOnFriendList`: bool | Public |
| **IsUnitFriendlyFollower** | `unitTag`: string | `isFollowing`: bool | Public |
| **IsUnitIgnored** | `unitTag`: string | `isIgnored`: bool | Public |
| **JumpToFriend** | `displayName`: string | - | Public |
| **RejectFriendRequest** | `displayName`: string | - | Public |
| **RemoveFriend** | `displayName`: string | - | Public |
| **RemoveIgnore** | `displayName`: string | - | Public |
| **RequestFriend** | `charOrDisplayName`: string<br>`message`: string | - | Public |
| **SetFriendNote** | `friendIndex`: luaindex<br>`note`: string | - | Public |
| **SetIgnoreNote** | `ignoreIndex`: luaindex<br>`note`: string | - | Public |
| **SetSessionIgnore** | `userName`: string<br>`isIgnoredThisSession`: bool | - | Public |

#### Time & Date

*80 functions*

| Function | Parameters | Returns | Protection |
|----------|------------|---------|------------|
| **CanItemBeConsumedByConsolidatedStation** | `bagId`: [Bag|#Bag]<br>`slotIndex`: integer | `canBeConsumed`: bool | Public |
| **CanUpdateSelectedLFGRole** | - | `canUpdateSelectedLFGRole`: bool | Public |
| **FormatTimeMilliseconds** | `timeValueInMilliseconds`: integer<br>`formatType`: [TimeFormatStyleCode|#TimeFormatStyleCode]<br>`precisionType`: [TimeFormatPrecisionCode|#TimeFormatPrecisionCode]<br>*+1 more* | `formattedTimeString`: string | Public |
| **FormatTimeSeconds** | `timeValueInSeconds`: number<br>`formatType`: [TimeFormatStyleCode|#TimeFormatStyleCode]<br>`precisionType`: [TimeFormatPrecisionCode|#TimeFormatPrecisionCode]<br>*+1 more* | `formattedTimeString`: string | Public |
| **GetActivityAverageRoleTime** | `activityId`: integer<br>`role`: [LFGRole|#LFGRole] | `hasData`: bool | Public |
| **GetChapterReleaseDateString** | `chapterUpgradeId`: integer | `releaseDateString`: string | Public |
| **GetCurrentBattlegroundShutdownTimer** | - | `timeLeftMS`: integer:nilable | Public |
| **GetCurrentBattlegroundStateTimeRemaining** | - | `timeRemaining`: integer | Public |
| **GetDate** | - | `currentTime`: integer | Public |
| **GetDateElementsFromTimestamp** | `timestamp`: integer53 | `year`: integer | Public |
| **GetDateStringFromTimestamp** | `timestamp`: integer | `dateString`: string | Public |
| **GetDiffBetweenTimeStamps** | `laterTime`: integer53<br>`earlierTime`: integer53 | `difference`: number | Public |
| **GetEndlessDungeonFinalRunTimeMilliseconds** | - | `finalRunTimeMilliseconds`: integer53 | Public |
| **GetEndlessDungeonOfTheWeekTimes** | - | `secondsUntilEnd`: integer | Public |
| **GetEndlessDungeonStartTimeMilliseconds** | - | `startTimeMilliseconds`: integer53 | Public |
| **GetFormattedTime** | - | `formattedTime`: integer | Public |
| **GetFrameDeltaMilliseconds** | - | `deltaMilliseconds`: integer | Public |
| **GetFrameDeltaNormalizedForTargetFramerate** | `targetFramesPerSecond`: number | `frameDeltaNormalizedForTargetFramerate`: number | Public |
| **GetFrameDeltaSeconds** | - | `deltaSeconds`: number | Public |
| **GetFrameDeltaTimeMilliseconds** | - | `frameDeltaTimeInMilliseconds`: integer | Public |
| **GetFrameDeltaTimeSeconds** | - | `frameDeltaTimeInSeconds`: number | Public |
| **GetFrameTimeMilliseconds** | - | `frameTimeInMilliseconds`: integer | Public |
| **GetFrameTimeSeconds** | - | `frameTimeInSeconds`: number | Public |
| **GetFramerate** | - | `currentFramerate`: number | Public |
| **GetGameTimeMilliseconds** | - | `gameTimeInMilliseconds`: integer | Public |
| **GetGameTimeSeconds** | - | `gameTimeInSeconds`: number | Public |
| **GetGiftingGracePeriodTime** | - | `gracePeriodTime`: integer | Public |
| **GetGlobalTimeOfDay** | - | `hours`: integer | Public |
| **GetHouseToursRecommendationsTimeRemainingS** | - | `timeRemainingS`: integer | Public |
| **GetInstanceKickTime** | - | `remainingTimeMs`: integer:nilable | Public |
| **GetLFGCooldownTimeRemainingSeconds** | `cooldownType`: [LFGCooldownType|#LFGCooldownType] | `timeRemainingSeconds`: integer | Public |
| **GetLFGSearchTimes** | - | `startTimeMs`: integer | Public |
| **GetLocalTimeOfDay** | - | `hours`: integer | Public |
| **GetLockpickingCompanionBonusTimeMS** | - | `lockpickingCompanionBonusTime`: integer | Public |
| **GetLockpickingTimeLeft** | - | `timeLeftMs`: integer | Public |
| **GetNextForwardCampRespawnTime** | - | `nextForwardCampRespawnTime`: integer | Public |
| **GetNumEndlessDungeonLifetimeVerseAndVisionStackCounts** | - | `totalVerseStacks`: integer | Public |
| **GetNumTimedActivities** | - | `numTimedActivities`: integer | Public |
| **GetNumTimedActivitiesCompleted** | `activityType`: [TimedActivityType|#TimedActivityType]:nilable | `numTimedActivities`: integer | Public |
| **GetNumTimedActivityRewards** | `index`: luaindex | `numRewards`: integer | Public |
| **GetNumUpdatedRecipes** | - | `numRecipes`: integer | Public |
| **GetRaidOfTheWeekTimes** | - | `secondsUntilEnd`: integer | Public |
| **GetRaidTargetTime** | - | `raidTargetTime`: integer | Public |
| **GetSCTSlotAnimationTimeline** | `slotIndex`: luaindex | `animationTimelineName`: string | Public |
| **GetScriptedEventInviteTimeRemainingMS** | `eventId`: integer | `timeRemainingMS`: integer | Public |
| **GetSecondsUntilArrestTimeout** | - | `secondsUntilArrestTimeout`: integer | Public |
| **GetTimeStamp** | - | `timestamp`: integer53 | Public |
| **GetTimeStamp32** | - | `timestamp`: integer | Public |
| **GetTimeString** | - | `currentTimeString`: string | Public |
| **GetTimeToClemencyResetInSeconds** | - | `timeRemaining`: integer | Public |
| **GetTimeToShadowyConnectionsResetInSeconds** | - | `timeRemaining`: integer | Public |
| **GetTimeUntilCanBeTrained** | - | `timeMs`: integer | Public |
| **GetTimeUntilNextDailyLoginMonthS** | - | `timeUntilNextMonthS`: integer | Public |
| **GetTimeUntilNextDailyLoginRewardClaimS** | - | `timeUntilNextRewardClaimS`: integer | Public |
| **GetTimeUntilNextReturningPlayerDailyLoginRewardClaimS** | - | `timeUntilNextRewardClaimS`: integer | Public |
| **GetTimeUntilStuckAvailable** | - | `millisecondsUntilAvailable`: integer | Public |
| **GetTimedActivityDescription** | `index`: luaindex | `activityDescription`: string | Public |
| **GetTimedActivityDifficulty** | `index`: luaindex | `difficulty`: [TimedActivityDifficulty|#TimedActivityDifficulty] | Public |
| **GetTimedActivityId** | `index`: luaindex | `timedActivityId`: integer | Public |
| **GetTimedActivityMaxProgress** | `index`: luaindex | `maxProgress`: integer | Public |
| **GetTimedActivityName** | `index`: luaindex | `activityName`: string | Public |
| **GetTimedActivityProgress** | `index`: luaindex | `progress`: integer | Public |
| **GetTimedActivityRewardInfo** | `index`: luaindex<br>`rewardIndex`: luaindex | `rewardId`: integer | Public |
| **GetTimedActivityTimeRemainingSeconds** | `index`: luaindex | `timeRemainingSeconds`: integer | Public |
| **GetTimedActivityType** | `index`: luaindex | `activityType`: [TimedActivityType|#TimedActivityType] | Public |
| **GetTimedActivityTypeLimit** | `activityType`: [TimedActivityType|#TimedActivityType] | `maxActivities`: integer | Public |
| **GetTimestampForStartOfDate** | `year`: integer<br>`month`: integer<br>`day`: integer<br>*+1 more* | `timestamp`: integer53 | Public |
| **GetTotalUserAddOnCPUTimeAvailableEachFrameMS** | - | `totalUserAddOnCPUTimeAvailableEachFrameMS`: number | Public |
| **GetTotalUserAddOnCPUTimeUsedLastFrameMS** | - | `totalUserAddOnCPUTimeUsedLastFrameMS`: number | Public |
| **GetTotalUserAddOnCPUTimeUsedNowMS** | - | `totalUserAddOnCPUTimeUsedThisFrameMS`: number | Public |
| **GetUpdatedRecipeIndices** | `index`: luaindex | `recipeListIndex`: luaindex | Public |
| **HasReceivedPromotionalEventUpdate** | - | `hasReceivedUpdate`: bool | Public |
| **IsCreatingHeraldryForFirstTime** | - | `creatingForFirstTime`: bool | Public |
| **IsCurrentBattlegroundStateTimed** | - | `isTimed`: bool | Public |
| **IsTimedActivitySystemAvailable** | - | `available`: bool | Public |
| **SetFlashWaitTime** | `waitTimeMs`: integer | - | Public |
| **SetSCTSlotAnimationTimeline** | `slotIndex`: luaindex<br>`animationTimelineName`: string | - | Public |
| **UpdateGroupFinderFilterOptions** | `resetDifficulty`: bool | - | Public |
| **UpdateGroupFinderUserTypeGroupListingOptions** | `userType`: [GroupFinderGroupListingUserType|#GroupFinderGroupListingUserType] | - | Public |
| **UpdateSelectedLFGRole** | `role`: [LFGRole|#LFGRole] | - | Public |

#### Antiquities

*57 functions*

| Function | Parameters | Returns | Protection |
|----------|------------|---------|------------|
| **AreAntiquitySkillLinesDiscovered** | - | `isUnlocked`: bool | Public |
| **CanScryForAntiquity** | `antiquityId`: integer | `scryingResult`: [AntiquityScryingResult|#AntiquityScryingResult] | Public |
| **DoesAntiquityHaveLead** | `antiquityId`: integer | `hasLead`: bool | Public |
| **DoesAntiquityNeedCombination** | `antiquityId`: integer | `needsCombination`: bool | Public |
| **DoesAntiquityPassVisibilityRequirements** | `antiquityId`: integer | `isVisible`: bool | Public |
| **DoesAntiquityRequireLead** | `antiquityId`: integer | `requiresLead`: bool | Public |
| **GetAntiquityCategoryGamepadIcon** | `antiquityCategoryId`: integer | `gamepadIcon`: textureName | Public |
| **GetAntiquityCategoryId** | `antiquityId`: integer | `categoryId`: integer | Public |
| **GetAntiquityCategoryKeyboardIcons** | `antiquityCategoryId`: integer | `unpressedButtonIcon`: textureName | Public |
| **GetAntiquityCategoryName** | `antiquityCategoryId`: integer | `name`: string | Public |
| **GetAntiquityCategoryOrder** | `antiquityCategoryId`: integer | `order`: integer | Public |
| **GetAntiquityCategoryParentId** | `antiquityCategoryId`: integer | `setId`: integer | Public |
| **GetAntiquityDifficulty** | `antiquityId`: integer | `difficulty`: [AntiquityDifficulty|#AntiquityDifficulty] | Public |
| **GetAntiquityDiggingSkillLineId** | - | `diggingSkillLineId`: integer | Public |
| **GetAntiquityIcon** | `antiquityId`: integer | `iconFileIndex`: textureName | Public |
| **GetAntiquityLeadIcon** | - | `leadIcon`: textureName | Public |
| **GetAntiquityLeadTimeRemainingSeconds** | `antiquityId`: integer | `leadTimeRemainingSeconds`: integer | Public |
| **GetAntiquityLoreEntry** | `antiquityId`: integer<br>`loreEntryIndex`: luaindex | `displayName`: string | Public |
| **GetAntiquityName** | `antiquityId`: integer | `name`: string | Public |
| **GetAntiquityQuality** | `antiquityId`: integer | `antiquityQuality`: [AntiquityQuality|#AntiquityQuality] | Public |
| **GetAntiquityRewardId** | `antiquityId`: integer | `rewardId`: integer | Public |
| **GetAntiquityScryingSkillLineId** | - | `scryingSkillLineId`: integer | Public |
| **GetAntiquitySearchResult** | `aIndex`: luaindex | `aAntiquityId`: integer | Public |
| **GetAntiquitySetAntiquityId** | `antiquitySetId`: integer<br>`antiquityIndex`: luaindex | `antiquityId`: integer | Public |
| **GetAntiquitySetIcon** | `antiquitySetId`: integer | `iconFileIndex`: textureName | Public |
| **GetAntiquitySetId** | `antiquityId`: integer | `setId`: integer | Public |
| **GetAntiquitySetName** | `antiquitySetId`: integer | `name`: string | Public |
| **GetAntiquitySetQuality** | `antiquitySetId`: integer | `antiquityQuality`: [AntiquityQuality|#AntiquityQuality] | Public |
| **GetAntiquitySetRewardId** | `antiquitySetId`: integer | `rewardId`: integer | Public |
| **GetDigSpotAntiquityId** | - | `antiquityId`: integer | Public |
| **GetDiggingAntiquityHasNewLoreEntryToShow** | - | `hasNewLoreEntryToShow`: bool | Public |
| **GetInProgressAntiquitiesForDigSite** | `digSiteId`: integer | `antiquityId`: integer | Public |
| **GetInProgressAntiquityDigSiteId** | `inProgressAntiquityIndex`: luaindex<br>`digSiteIndex`: luaindex | `digSiteId`: integer | Public |
| **GetInProgressAntiquityId** | `inProgressAntiquityIndex`: luaindex | `antiquityId`: integer | Public |
| **GetLootAntiquityLeadId** | `lootId`: integer | `antiquityId`: integer | Public |
| **GetNextAntiquityId** | `lastAntiquityId`: integer:nilable | `nextAntiquityId`: integer:nilable | Public |
| **GetNumAntiquitiesRecovered** | `antiquityId`: integer | `numRecovered`: integer | Public |
| **GetNumAntiquityDigSites** | `antiquityId`: integer | `numDigSites`: integer | Public |
| **GetNumAntiquityLoreEntries** | `antiquityId`: integer | `numLoreEntries`: integer | Public |
| **GetNumAntiquityLoreEntriesAcquired** | `antiquityId`: integer | `numLoreEntriesAcquired`: integer | Public |
| **GetNumAntiquitySearchResults** | - | `numSearchResults`: integer | Public |
| **GetNumAntiquitySetAntiquities** | `antiquitySetId`: integer | `numAntiquities`: integer | Public |
| **GetNumDigSitesForInProgressAntiquity** | `inProgressAntiquityIndex`: luaindex | `numDigSitesForInProgressAntiquity`: integer | Public |
| **GetNumGoalsAchievedForAntiquity** | `antiquityId`: integer | `numAchievedGoals`: integer | Public |
| **GetNumInProgressAntiquities** | - | `numInProgressAntiquities`: integer | Public |
| **GetScryingCurrentAntiquityId** | - | `antiquityId`: integer | Public |
| **GetScryingPassiveSkillIndex** | `scryingPassiveSkill`: [ScryingPassiveSkill|#ScryingPassiveSkill] | `scryingPassiveSkillIndex`: luaindex | Public |
| **GetTotalNumGoalsForAntiquity** | `antiquityId`: integer | `numGoals`: integer | Public |
| **GetTrackedAntiquityId** | - | `antiquityId`: integer | Public |
| **IsAntiquityRepeatable** | `antiquityId`: integer | `allowsRepeats`: bool | Public |
| **IsDigSiteAssociatedWithTrackedAntiquity** | `digSiteId`: integer | `isAssociated`: bool | Public |
| **IsScryingInProgress** | - | `isInProgress`: bool | Public |
| **MeetsAntiquityRequirementsForScrying** | `antiquityId`: integer<br>`zoneId`: integer:nilable | `scryingResult`: [AntiquityScryingResult|#AntiquityScryingResult] | Public |
| **MeetsAntiquitySkillRequirementsForScrying** | `antiquityId`: integer | `meetsSkillRequirements`: bool | Public |
| **ScryForAntiquity** | `antiquityId`: integer | - | Public |
| **SetTrackedAntiquityId** | `antiquityId`: integer | - | Public |
| **StartAntiquitySearch** | `searchString`: string | - | Public |

#### Achievement

*46 functions*

| Function | Parameters | Returns | Protection |
|----------|------------|---------|------------|
| **FormatAchievementLinkTimestamp** | `timestamp`: string | `date`: string | Public |
| **GetAchievementCategoryGamepadIcon** | `categoryIndex`: luaindex | `gamepadIcon`: textureName | Public |
| **GetAchievementCategoryInfo** | `topLevelIndex`: luaindex | `name`: string | Public |
| **GetAchievementCategoryKeyboardIcons** | `categoryIndex`: luaindex | `normalIcon`: textureName | Public |
| **GetAchievementCriterion** | `achievementId`: integer<br>`criterionIndex`: luaindex | `description`: string | Public |
| **GetAchievementId** | `topLevelIndex`: luaindex<br>`categoryIndex`: luaindex:nilable<br>`achievementIndex`: luaindex | `achievementId`: integer | Public |
| **GetAchievementIdFromLink** | `link`: string | `achievementId`: integer | Public |
| **GetAchievementInfo** | `achievementId`: integer | `name`: string | Public |
| **GetAchievementItemLink** | `achievementId`: integer<br>`linkStyle`: [LinkStyle|#LinkStyle] | `link`: string | Public |
| **GetAchievementLink** | `achievementId`: integer<br>`linkStyle`: [LinkStyle|#LinkStyle] | `link`: string | Public |
| **GetAchievementLinkedBookCollectionId** | `achievementId`: integer | `bookCollectionId`: integer | Public |
| **GetAchievementName** | `achievementId`: integer | `name`: string | Public |
| **GetAchievementNameFromLink** | `link`: string | `name`: string | Public |
| **GetAchievementNumCriteria** | `achievementId`: integer | `numCriteria`: integer | Public |
| **GetAchievementNumRewards** | `achievementId`: integer | `numRewards`: integer | Public |
| **GetAchievementPersistenceLevel** | `achievementId`: integer | `persistenceLevel`: [AchievementPersistenceLevel|#AchievementPersistenceLevel] | Public |
| **GetAchievementProgress** | `achievementId`: integer | `progress`: id64 | Public |
| **GetAchievementProgressFromLinkData** | `achievementId`: integer<br>`progress`: string | `numCompleted`: integer | Public |
| **GetAchievementRewardCollectible** | `achievementId`: integer | `hasRewardOfType`: bool | Public |
| **GetAchievementRewardDye** | `achievementId`: integer | `hasRewardOfType`: bool | Public |
| **GetAchievementRewardItem** | `achievementId`: integer | `hasRewardOfType`: bool | Public |
| **GetAchievementRewardPoints** | `achievementId`: integer | `points`: integer | Public |
| **GetAchievementRewardTitle** | `achievementId`: integer | `hasRewardOfType`: bool | Public |
| **GetAchievementRewardTributeCardUpgradeInfo** | `achievementId`: integer | `hasRewardOfType`: bool | Public |
| **GetAchievementSubCategoryInfo** | `topLevelIndex`: luaindex<br>`subCategoryIndex`: luaindex | `name`: string | Public |
| **GetAchievementTimestamp** | `achievementId`: integer | `timestamp`: integer53 | Public |
| **GetAchievementsSearchResult** | `searchResultIndex`: luaindex | `categoryIndex`: luaindex | Public |
| **GetActiveSpectacleEventFeaturedAchievementsId** | `activeSpectacleEventId`: integer<br>`achievementIndex`: luaindex | `achievementId`: integer | Public |
| **GetActiveSpectacleEventNumFeaturedAchievements** | `activeSpectacleEventId`: integer | `numFeaturedAchievements`: integer | Public |
| **GetCategoryInfoFromAchievementId** | `achievementId`: integer | `topLevelIndex`: luaindex:nilable | Public |
| **GetCharIdForCompletedAchievement** | `achievementId`: integer | `charId`: id64 | Public |
| **GetCollectibleLinkedAchievement** | `collectibleId`: integer | `achievementId`: integer | Public |
| **GetEarnedAchievementPoints** | - | `points`: integer | Public |
| **GetFirstAchievementInLine** | `achievementId`: integer | `firstAchievementId`: integer | Public |
| **GetLoreBookCollectionLinkedAchievement** | `categoryIndex`: luaindex<br>`collectionIndex`: luaindex | `achievementId`: integer | Public |
| **GetNextAchievementInLine** | `achievementId`: integer | `nextAchievementId`: integer | Public |
| **GetNumAchievementCategories** | - | `numCategories`: integer | Public |
| **GetNumAchievementsSearchResults** | - | `numSearchResults`: integer | Public |
| **GetNumAttainSkillLineRanksInAchievement** | `achievementId`: integer | `numAttainSkillLineRanks`: integer | Public |
| **GetNumSkyshardsInAchievement** | `achievementId`: integer | `numSkyshards`: integer | Public |
| **GetPreviousAchievementInLine** | `achievementId`: integer | `previousAchievementId`: integer | Public |
| **GetRecentlyCompletedAchievements** | `numAchievementsToGet`: integer | `achievementId`: integer | Public |
| **GetSubclassingAchievementId** | - | `achievementId`: integer | Public |
| **GetTotalAchievementPoints** | - | `points`: integer | Public |
| **IsAchievementComplete** | `achievementId`: integer | `completed`: bool | Public |
| **StartAchievementSearch** | `searchString`: string<br>`forceRefresh`: bool | - | Public |

#### Mail

*28 functions*

| Function | Parameters | Returns | Protection |
|----------|------------|---------|------------|
| **CanTryTakeAllMailAttachmentsInCategory** | `category`: [MailCategory|#MailCategory]<br>`deleteOnClaim`: bool | `canTakeAttachments`: bool | Public |
| **ClearQueuedMail** | - | - | Public |
| **CloseMailbox** | - | - | Public |
| **DeleteMail** | `mailId`: id64 | - | Public |
| **GetMailAttachmentInfo** | `mailId`: id64 | `numAttachments`: integer | Public |
| **GetMailFlags** | `mailId`: id64 | `unread`: bool | Public |
| **GetMailIdByIndex** | `category`: [MailCategory|#MailCategory]<br>`index`: luaindex | `mailId`: id64 | Public |
| **GetMailItemInfo** | `mailId`: id64 | `senderDisplayName`: string | Public |
| **GetMailItemRewardMailInfo** | `rewardId`: integer | `sender`: string | Public |
| **GetMailQueuedAttachmentLink** | `attachmentSlot`: luaindex<br>`linkStyle`: [LinkStyle|#LinkStyle] | `link`: string | Public |
| **GetMailSender** | `mailId`: id64 | `senderDisplayName`: string | Public |
| **GetNextMailId** | `lastMailId`: id64:nilable | `nextMailId`: id64:nilable | Public |
| **GetNumMailItems** | - | `numMail`: integer | Public |
| **GetNumMailItemsByCategory** | `category`: [MailCategory|#MailCategory] | `numMail`: integer | Public |
| **GetNumUnreadMail** | - | `numUnread`: integer | Public |
| **GetQueuedMailPostage** | - | `postage`: integer | Public |
| **HasUnreadMail** | - | `unread`: bool | Public |
| **HasUnreceivedMail** | - | `unreceived`: bool | Public |
| **IsLocalMailboxFull** | `category`: [MailCategory|#MailCategory] | `isFull`: bool | Public |
| **IsMailReturnable** | `mailId`: id64 | `isReturnable`: bool | Public |
| **IsReadMailInfoReady** | `mailId`: id64 | `isReady`: bool | Public |
| **ReadMail** | `mailId`: id64 | `body`: string | Public |
| **ReturnMail** | `mailId`: id64 | - | Public |
| **SendMail** | `to`: string<br>`subject`: string<br>`body`: string | - | Public |
| **TakeAllMailAttachmentsInCategory** | `category`: [MailCategory|#MailCategory]<br>`deleteOnClaim`: bool | - | Public |
| **TakeMailAttachedItems** | `mailId`: id64 | - | Public |
| **TakeMailAttachedMoney** | `mailId`: id64 | - | Public |
| **TakeMailAttachments** | `mailId`: id64<br>`deleteOnClaim`: bool | - | Public |

#### Settings & Config

*22 functions*

| Function | Parameters | Returns | Protection |
|----------|------------|---------|------------|
| **ApplySettings** | - | - | Public |
| **DoesPlatformSupportGraphicSetting** | `settingId`: integer | `isSettingSupported`: bool | Public |
| **GetCVar** | `CVarName`: string | `value`: string | Public |
| **GetSetting** | `system`: [SettingSystemType|#SettingSystemType]<br>`settingId`: integer | `value`: string | Public |
| **GetSettingChamberStress** | - | `stress`: number | Public |
| **GetSetting_Bool** | `system`: [SettingSystemType|#SettingSystemType]<br>`settingId`: integer | `value`: bool | Public |
| **GetTooltipStringForRenderQualitySetting** | - | `tooltipText`: string | Public |
| **HasPermissionSettingForCurrentHouse** | `setting`: [HousePermissionSetting|#HousePermissionSetting] | `hasSetting`: bool | Public |
| **IsDeferredSettingLoaded** | `system`: [SettingSystemType|#SettingSystemType]<br>`settingId`: integer | `isLoaded`: bool | Public |
| **IsDeferredSettingLoading** | `system`: [SettingSystemType|#SettingSystemType]<br>`settingId`: integer | `isLoaded`: bool | Public |
| **IsHouseDefaultAccessSettingValidForHouseToursListing** | `housePermissionDefaultAccessSetting`: [HousePermissionDefaultAccessSetting|#HousePermissionDefaultAccessSetting] | `isValid`: bool | Public |
| **IsSettingDeferred** | `system`: [SettingSystemType|#SettingSystemType]<br>`settingId`: integer | `isDeferred`: bool | Public |
| **IsSettingTemplate** | - | `isSettingTemplate`: bool | Public |
| **RefreshSettings** | - | - | Public |
| **ResetConsolePublicUserSettingsToDefault** | - | - | Public |
| **ResetSettingToDefault** | `system`: [SettingSystemType|#SettingSystemType]<br>`settingId`: integer | - | Public |
| **ResetToDefaultSettings** | `system`: [SettingSystemType|#SettingSystemType] | - | Public |
| **SendAllCachedSettingMessages** | - | - | Public |
| **SetCVar** | `CVarName`: string<br>`value`: string | - | Public |
| **SetSetting** | `system`: [SettingSystemType|#SettingSystemType]<br>`settingId`: integer<br>`value`: string<br>*+1 more* | - | Public |
| **ShouldShowDLSSSetting** | - | `shouldShowDLSSSetting`: bool | Public |
| **ShouldShowFSRSetting** | - | `shouldShowFSRSetting`: bool | Public |

#### Bank & Storage

*11 functions*

| Function | Parameters | Returns | Protection |
|----------|------------|---------|------------|
| **BuyBankSpace** | - | - | Public |
| **DisplayBankUpgrade** | - | - | Public |
| **DoesBankHoldCurrency** | `bagId`: [Bag|#Bag] | `doesBankHoldCurrency`: bool | Public |
| **GetBankingBag** | - | `bagId`: [Bag|#Bag] | Public |
| **GetCurrentBankUpgrade** | - | `currentBankUpgrade`: integer | Public |
| **GetMaxBankUpgrade** | - | `maxBankUpgrade`: integer | Public |
| **GetNextBankUpgradePrice** | - | `cost`: integer | Public |
| **GetNumBankSlotsPerUpgrade** | - | `numSlots`: integer | Public |
| **IsBankOpen** | - | `isBankOpen`: bool | Public |
| **IsBankUpgradeAvailable** | - | `isAvailable`: bool | Public |
| **IsHouseBankBag** | `bagId`: [Bag|#Bag] | `isHouseBankBag`: bool | Public |


---

## Object API

The Object API provides methods on specific object types. Total: **0 classes**

### Classes

| Class | Method Count |
|-------|-------------|

---


---

## Object API

The Object API provides methods on specific object types. Total: **49 classes**

### Classes

| Class | Method Count |
|-------|-------------|
| [Control](#control) | 209 |
| [TooltipControl](#tooltipcontrol) | 104 |
| [WindowManager](#windowmanager) | 67 |
| [AnimationTimeline](#animationtimeline) | 53 |
| [EditControl](#editcontrol) | 53 |
| [LabelControl](#labelcontrol) | 46 |
| [TextureControl](#texturecontrol) | 38 |
| [ButtonControl](#buttoncontrol) | 34 |
| [PolygonControl](#polygoncontrol) | 33 |
| [AddOnManager](#addonmanager) | 27 |
| [TextureCompositeControl](#texturecompositecontrol) | 27 |
| [StatusBarControl](#statusbarcontrol) | 26 |
| [CanvasControl](#canvascontrol) | 24 |
| [TextBufferControl](#textbuffercontrol) | 24 |
| [AnimationObject3DTranslate](#animationobject3dtranslate) | 23 |
| [SliderControl](#slidercontrol) | 22 |
| [AnimationObjectTranslate](#animationobjecttranslate) | 21 |
| [LineControl](#linecontrol) | 20 |
| [CooldownControl](#cooldowncontrol) | 18 |
| [BackdropControl](#backdropcontrol) | 17 |
| [AnimationObject](#animationobject) | 16 |
| [AnimationObject3DRotate](#animationobject3drotate) | 13 |
| [CompassDisplayControl](#compassdisplaycontrol) | 13 |
| [ColorSelectControl](#colorselectcontrol) | 12 |
| [AnimationObjectTransformOffset](#animationobjecttransformoffset) | 11 |
| [ScrollControl](#scrollcontrol) | 11 |
| [AnimationObjectTexture](#animationobjecttexture) | 10 |
| [AnimationObjectTransformRotation](#animationobjecttransformrotation) | 10 |
| [SynchronizingObject](#synchronizingobject) | 9 |
| [ScriptEventManager](#scripteventmanager) | 9 |
| [AnimationObjectColor](#animationobjectcolor) | 7 |
| [AnimationObjectScroll](#animationobjectscroll) | 6 |
| [AnimationObjectSize](#animationobjectsize) | 6 |
| [AnimationObjectTransformScale](#animationobjecttransformscale) | 6 |
| [AnimationObjectAlpha](#animationobjectalpha) | 5 |
| [AnimationObjectDesaturation](#animationobjectdesaturation) | 5 |
| [AnimationObjectScale](#animationobjectscale) | 5 |
| [AnimationObjectTextureRotate](#animationobjecttexturerotate) | 5 |
| [MapDisplayControl](#mapdisplaycontrol) | 5 |
| [AnimationObjectTextureSlide](#animationobjecttextureslide) | 4 |
| [AnimationObjectTransformSkew](#animationobjecttransformskew) | 4 |
| [VectorControl](#vectorcontrol) | 4 |
| [AnimationManager](#animationmanager) | 2 |
| [DebugTextControl](#debugtextcontrol) | 2 |
| [FontObject](#fontobject) | 2 |
| [TopLevelWindow](#toplevelwindow) | 2 |
| [AnimationObjectCustom](#animationobjectcustom) | 1 |
| [GuiTexture](#guitexture) | 0 |
| [RootWindow](#rootwindow) | 0 |

---

### Control

*209 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **AddFilterForEvent** | `event`: integer<br>`filterParameter`: variant | `success`: bool | Public |
| **AddTransformRotation** | `deltaXRadians`: number<br>`deltaYRadians`: number<br>`deltaZRadians`: number | - | Public |
| **AddTransformRotationX** | `deltaXRadians`: number | - | Public |
| **AddTransformRotationY** | `deltaYRadians`: number | - | Public |
| **AddTransformRotationZ** | `deltaZRadians`: number | - | Public |
| **ClearCircularClip** | - | - | Public |
| **ClearClips** | - | - | Public |
| **ClearFadeGradients** | - | - | Public |
| **ClearMask** | - | - | Public |
| **ClearRectangularClip** | - | - | Public |
| **ClearShaderEffectOptions** | - | - | Public |
| **ClearTransform** | - | - | Public |
| **ClearTransformOffset** | - | - | Public |
| **ClearTransformRotation** | - | - | Public |
| **ClearTransformScale** | - | - | Public |
| **ClearTransformSkew** | - | - | Public |
| **Convert3DLocalOrientationToWorldOrientation** | `localPitch`: number<br>`localYaw`: number<br>`localRoll`: number | `worldPitch`: number | Public |
| **Convert3DLocalPositionToWorldPosition** | `localX`: number<br>`localY`: number<br>`localZ`: number | `worldX`: number | Public |
| **Convert3DWorldOrientationToLocalOrientation** | `worldPitch`: number<br>`worldYaw`: number<br>`worldRoll`: number | `localPitch`: number | Public |
| **Convert3DWorldPositionToLocalPosition** | `worldX`: number<br>`worldY`: number<br>`worldZ`: number | `localX`: number | Public |
| **Create3DRenderSpace** | - | - | Public |
| **CreateControl** | `childControlName`: string<br>`childControlType`: [ControlType|#ControlType] | `childControl`: object | Public |
| **Destroy3DRenderSpace** | - | - | Public |
| **Does3DRenderSpaceUseDepthBuffer** | - | `usesDepthBuffer`: bool | Public |
| **DoesControlDescendFrom** | `root`: object | `doesControlDescendFromRoot`: bool | Public |
| **Get3DRenderSpaceAxisRotationOrder** | - | `axisRotationOrder`: [AxisRotationOrder|#AxisRotationOrder] | Public |
| **Get3DRenderSpaceForward** | - | `x`: number | Public |
| **Get3DRenderSpaceOrientation** | - | `pitchRadians`: number | Public |
| **Get3DRenderSpaceOrigin** | - | `x`: number | Public |
| **Get3DRenderSpaceRight** | - | `x`: number | Public |
| **Get3DRenderSpaceSystem** | - | `system`: [GuiRender3DSpaceSystem|#GuiRender3DSpaceSystem] | Public |
| **Get3DRenderSpaceUp** | - | `x`: number | Public |
| **GetAlpha** | - | `alpha`: number | Public |
| **GetAncestor** | `ancestorIndex`: luaindex | `ancestorControl`: object | Public |
| **GetAnchor** | `anchorIndex`: integer | `isValidAnchor`: bool | Public |
| **GetAutoRectClipChildren** | - | `autoRectClipChildren`: bool | Public |
| **GetBottom** | - | `bottom`: number | Public |
| **GetCaustic** | - | `frequencyX`: number | Public |
| **GetCausticOffset** | - | `offset`: number | Public |
| **GetCenter** | - | `centerX`: number | Public |
| **GetChild** | `childIndex`: luaindex | `childControl`: object | Public |
| **GetChildFlexContentAlignment** | - | `alignment`: [FlexAlignment|#FlexAlignment] | Public |
| **GetChildFlexDirection** | - | `direction`: [FlexDirection|#FlexDirection] | Public |
| **GetChildFlexItemAlignment** | - | `alignment`: [FlexAlignment|#FlexAlignment] | Public |
| **GetChildFlexJustification** | - | `justification`: [FlexJustification|#FlexJustification] | Public |
| **GetChildFlexWrap** | - | `wrap`: [FlexWrap|#FlexWrap] | Public |
| **GetChildLayout** | - | `childLayoutType`: [ChildLayoutType|#ChildLayoutType] | Public |
| **GetClampedToScreen** | - | `clamped`: bool | Public |
| **GetClampedToScreenInsets** | - | `left`: number | Public |
| **GetControlAlpha** | - | `alpha`: number | Public |

*... and 159 more methods*

### TooltipControl

*104 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **AddControl** | `control`: object<br>`cell`: integer<br>`useLastRow`: bool | - | Public |
| **AddHeaderControl** | `control`: object<br>`headerRow`: integer<br>`headerSide`: [TooltipHeaderSide|#TooltipHeaderSide] | - | Public |
| **AddHeaderLine** | `text`: string<br>`font`: string<br>`headerRow`: integer<br>*+4 more* | - | Public |
| **AddLine** | `text`: string<br>`font`: string<br>`r`: number<br>*+8 more* | - | Public |
| **AddVerticalPadding** | `paddingY`: number | - | Public |
| **AppendAvAObjective** | `queryType`: integer<br>`keepId`: integer<br>`objectiveId`: integer<br>*+1 more* | - | Public |
| **AppendDigSiteAntiquities** | `digSiteId`: integer | - | Public |
| **AppendMapPing** | `pingType`: integer<br>`unitTag`: string | - | Public |
| **AppendQuestCondition** | `questIndex`: luaindex<br>`stepIndex`: luaindex<br>`conditionIndex`: luaindex | - | Public |
| **AppendQuestEnding** | `questIndex`: luaindex | - | Public |
| **AppendQuestName** | `questIndex`: luaindex | - | Public |
| **AppendSkyshardHint** | `skyshardId`: integer | - | Public |
| **AppendUnitName** | `unitTag`: string | - | Public |
| **AppendZoneSpectacleTooltip** | `spectacleId`: integer | - | Public |
| **ClearLines** | - | - | Public |
| **GetOwner** | - | `owner`: object | Public |
| **HideComparativeTooltips** | - | - | Public |
| **SetAbility** | `abilityIndex`: luaindex<br>`showBase`: bool | - | Public |
| **SetAbilityId** | `abilityId`: integer | - | Public |
| **SetAchievement** | `achievementId`: integer | - | Public |
| **SetAchievementRewardItem** | `achievementId`: integer | - | Public |
| **SetAction** | `slotId`: luaindex<br>`hotbarCategory`: [HotBarCategory|#HotBarCategory]:nilable | - | Public |
| **SetActiveSkill** | `skillType`: [SkillType|#SkillType]<br>`skillLineIndex`: luaindex<br>`skillIndex`: luaindex<br>*+11 more* | - | Public |
| **SetAntiquityLead** | `antiquityId`: integer | - | Public |
| **SetAntiquitySetFragment** | `antiquityId`: integer | - | Public |
| **SetAsComparativeTooltip1** | - | - | Public |
| **SetAsComparativeTooltip2** | - | - | Public |
| **SetAttachedMailItem** | `mailId`: id64<br>`attachSlot`: luaindex | - | Public |
| **SetBagItem** | `bagIndex`: [Bag|#Bag]<br>`slotIndex`: integer<br>`displayFlags`: [ItemTooltipDisplayFlags|#ItemTooltipDisplayFlags] | - | Public |
| **SetBook** | `categoryIndex`: luaindex<br>`collectionIndex`: luaindex<br>`bookIndex`: luaindex | - | Public |
| **SetBuff** | `buffSlotId`: integer<br>`unitTag`: string | - | Public |
| **SetBuybackItem** | `entryIndex`: luaindex | - | Public |
| **SetChampionSkill** | `championSkillId`: integer<br>`numPendingPoints`: integer<br>`nextJumpPoint`: integer<br>*+1 more* | - | Public |
| **SetCollectible** | `collectibleId`: integer<br>`addNickname`: bool<br>`showPurchasableHint`: bool<br>*+2 more* | - | Public |
| **SetCompanionSkill** | `abilityId`: integer | - | Public |
| **SetCraftedAbility** | `craftedAbilityId`: integer<br>`primaryScriptId`: integer<br>`secondaryScriptId`: integer<br>*+2 more* | - | Public |
| **SetCraftedAbilityScript** | `craftedAbilityId`: integer<br>`craftedAbilityScriptId`: integer<br>`primaryScriptId`: integer<br>*+3 more* | - | Public |
| **SetCrownCrateReward** | `rewardIndex`: luaindex | - | Public |
| **SetCurrency** | `currencyType`: [CurrencyType|#CurrencyType]<br>`quantity`: integer | - | Public |
| **SetDailyLoginRewardEntry** | `rewardIndex`: luaindex | - | Public |
| **SetEdgeKeepBonusAbility** | `bonusIndex`: luaindex | - | Public |
| **SetEmperorBonusAbility** | `rankIndex`: integer | - | Public |
| **SetEndlessDungeonBuff** | `buffAbilityId`: integer<br>`includeLifetimeStacks`: bool | - | Public |
| **SetFont** | `fontStr`: string | - | Public |
| **SetGenericItemSet** | `itemSetId`: integer | - | Public |
| **SetGuildSpecificItem** | `guildSpecificItemIndex`: luaindex | - | Public |
| **SetHeaderCellEmptyHorizontalSpace** | `headerCellEmptyHorizontalSpace`: number | - | Public |
| **SetHeaderRowSpacing** | `spacing`: number | - | Public |
| **SetHeaderVerticalOffset** | `verticalOffset`: number | - | Public |
| **SetItemSetCollectionPieceLink** | `link`: string<br>`hideTrait`: bool | - | Public |

*... and 54 more methods*

### WindowManager

*67 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **ApplyTemplateToControl** | `control`: object<br>`virtualName`: string | - | Public |
| **CompareControlVisualOrder** | `controlA`: object<br>`controlB`: object | `order`: integer | Public |
| **ConvertRGBToHSL** | `red`: number<br>`green`: number<br>`blue`: number | `hue`: number | Public |
| **ConvertRGBToHSV** | `red`: number<br>`green`: number<br>`blue`: number | `hue`: number | Public |
| **CreateControl** | `name`: string<br>`parent`: object<br>`type`: [ControlType|#ControlType] | `control`: object | Public |
| **CreateControlFromVirtual** | `controlName`: string<br>`parent`: object<br>`virtualName`: string<br>*+1 more* | `control`: object | Public |
| **CreateCursor** | `x`: layout_measurement<br>`y`: layout_measurement | `cursorId`: integer | Public |
| **CreateFont** | `fontSymbolName`: string<br>`fontDescriptor`: string | `fontObject`: object | Public |
| **CreateTopLevelWindow** | `name`: string | `control`: object | Public |
| **DestroyCursor** | `cursorId`: integer | - | Public |
| **EscapeMarkup** | `text`: string<br>`allowMarkupType`: [AllowMarkupType|#AllowMarkupType] | `escapedText`: string | Public |
| **GetAddOnManager** | - | `addOnManager`: object | Public |
| **GetAnimationManager** | - | `animationManager`: object | Public |
| **GetCameraForward** | `space`: [Space|#Space] | `forwardX`: number | Public |
| **GetControlAtCursor** | `cursorId`: integer<br>`desiredHandlers`: [HitTestingDesiredHandlers|#HitTestingDesiredHandlers] | `controlAtCursor`: object | Public |
| **GetControlByName** | `name`: string<br>`suffix`: string | `ret`: object | Public |
| **GetControlCreatingSourceCallSiteInfo** | `sourceName`: string<br>`index`: luaindex | `creationStack`: string | Public |
| **GetControlCreatingSourceName** | `index`: luaindex | `sourceName`: string | Public |
| **GetCursorPosition** | `cursorId`: integer | `x`: number | Public |
| **GetFocusControl** | - | `focusControl`: object | Public |
| **GetHandler** | `handlerName`: string<br>`name`: string | `functionRef`: function | Public |
| **GetIMECandidate** | `index`: luaindex | `candidate`: string | Public |
| **GetIMECandidatePageInfo** | - | `selectedIndex`: luaindex | Public |
| **GetInterfaceVerticalFieldOfView** | - | `FoVYRadians`: number | Public |
| **GetMinUICanvasHeight** | - | `minHeight`: number | Public |
| **GetMinUICanvasWidth** | - | `minWidth`: number | Public |
| **GetMouseFocusControl** | - | `mouseFocusControl`: object | Public |
| **GetMouseOverControl** | - | `mouseOverControl`: object | Public |
| **GetNumControlCreatingSourceCallSites** | `sourceName`: string | `numCallSites`: integer | Public |
| **GetNumControlCreatingSources** | - | `numFiles`: integer | Public |
| **GetNumIMECandidates** | - | `numCandidates`: integer | Public |
| **GetScriptProfilerCFunctionInfo** | `recordDataIndex`: luaindex | `functionName`: string | Public |
| **GetScriptProfilerClosureInfo** | `recordDataIndex`: luaindex | `displayName`: string | Public |
| **GetScriptProfilerFrameNumRecords** | `frameIndex`: luaindex | `numRecords`: integer | Public |
| **GetScriptProfilerGarbageCollectionInfo** | `recordDataIndex`: luaindex | `GarbageCollectionType`: [ScriptProfilerGarbageCollectionType|#ScriptProfilerGarbageCollectionType] | Public |
| **GetScriptProfilerNumCFunctions** | - | `numCFunctions`: integer | Public |
| **GetScriptProfilerNumClosures** | - | `numClosures`: integer | Public |
| **GetScriptProfilerNumFrames** | - | `numFrames`: integer | Public |
| **GetScriptProfilerNumGarbageCollectionTypes** | - | `numGarbageCollectionTypes`: integer | Public |
| **GetScriptProfilerNumUserEvents** | - | `numUserEvents`: integer | Public |
| **GetScriptProfilerRecordInfo** | `frameIndex`: luaindex<br>`recordIndex`: luaindex | `recordDataIndex`: luaindex | Public |
| **GetScriptProfilerUserEventInfo** | `recordDataIndex`: luaindex | `userEventData`: string | Public |
| **GetUICustomScale** | - | `scale`: number | Public |
| **GetUIGlobalScale** | - | `scale`: number | Public |
| **GetUIMouseDeltas** | - | `deltaX`: number | Public |
| **GetUIMousePosition** | - | `x`: number | Public |
| **GetWindowManager** | - | `windowManager`: object | Public |
| **HasFocusControl** | - | `hasFocusControl`: bool | Public |
| **IsChoosingIMECandidate** | - | `isChoosingCandidate`: bool | Public |
| **IsHandlingHardwareEvent** | - | `isHandlingHardwareEvent`: bool | Public |

*... and 17 more methods*

### AnimationTimeline

*53 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **ApplyAllAnimationsToControl** | `animatedControl`: object | - | Public |
| **ClearAllCallbacks** | - | - | Public |
| **ClearAnimatedControlFromAllAnimations** | - | - | Public |
| **GetAnimation** | `animationIndex`: luaindex | `animation`: object | Public |
| **GetAnimationOffset** | `animation`: object | `offset`: integer | Public |
| **GetAnimationTimeline** | `timelineIndex`: luaindex | `timeline`: object | Public |
| **GetAnimationTimelineOffset** | `animation`: object | `offset`: integer | Public |
| **GetDuration** | - | `duration`: integer | Public |
| **GetFirstAnimation** | - | `animation`: object | Public |
| **GetFirstAnimationOfType** | `animationType`: [AnimationType|#AnimationType] | `animation`: object | Public |
| **GetFirstAnimationTimeline** | - | `timeline`: object | Public |
| **GetFullProgress** | - | `progress`: number | Public |
| **GetHandler** | `eventName`: string<br>`name`: string | `functionRef`: function | Public |
| **GetLastAnimation** | - | `animation`: object | Public |
| **GetLastAnimationTimeline** | - | `timeline`: object | Public |
| **GetMinDuration** | - | `minDuration`: integer | Public |
| **GetNumAnimationTimelines** | - | `numTimelines`: integer | Public |
| **GetNumAnimations** | - | `numAnimations`: integer | Public |
| **GetParent** | - | `timeline`: object | Public |
| **GetPlaybackLoopsRemaining** | - | `loopsRemaining`: integer | Public |
| **GetProgress** | - | `progress`: number | Public |
| **GetSkipAnimationsBehindPlayheadOnInitialPlay** | - | `skipAnimations`: bool | Public |
| **InsertAnimation** | `animationType`: [AnimationType|#AnimationType]<br>`animatedControl`: object<br>`offset`: integer | `animation`: object | Public |
| **InsertAnimationFromVirtual** | `animationVirtualName`: string<br>`animatedControl`: object | `animation`: object | Public |
| **InsertAnimationTimeline** | `offset`: integer<br>`animatedControl`: object | `animation`: object | Public |
| **InsertAnimationTimelineFromVirtual** | `animationVirtualName`: string<br>`animatedControl`: object | `animation`: object | Public |
| **InsertCallback** | `functionRef`: function<br>`offset`: integer | `functionRefRet`: function | Public |
| **IsEnabled** | - | `isEnabled`: bool | Public |
| **IsPaused** | - | `isPaused`: bool | Public |
| **IsPlaying** | - | `isPlaying`: bool | Public |
| **IsPlayingBackward** | - | `reversed`: bool | Public |
| **Pause** | - | - | Public |
| **PlayBackward** | - | - | Public |
| **PlayForward** | - | - | Public |
| **PlayFromEnd** | `offsetMs`: integer | - | Public |
| **PlayFromStart** | `offsetMs`: integer | - | Public |
| **PlayInstantlyToEnd** | `ignoreCallbacks`: bool | - | Public |
| **PlayInstantlyToStart** | `ignoreCallbacks`: bool | - | Public |
| **Resume** | - | - | Public |
| **SetAllAnimationOffsets** | `offset`: integer | - | Public |
| **SetAnimationOffset** | `animation`: object<br>`offset`: integer | - | Public |
| **SetAnimationTimelineOffset** | `animation`: object<br>`offset`: integer | - | Public |
| **SetCallbackOffset** | `callback`: function<br>`offset`: integer | - | Public |
| **SetEnabled** | `enabled`: bool | - | Public |
| **SetHandler** | `eventName`: string<br>`functionRef`: function<br>`name`: string<br>*+2 more* | - | Public |
| **SetMinDuration** | `minDuration`: integer | - | Public |
| **SetOffsetInParent** | `offset`: integer | - | Public |
| **SetPlaybackLoopCount** | `maxLoopCount`: integer | - | Public |
| **SetPlaybackLoopsRemaining** | `loopsRemaining`: integer | - | Public |
| **SetPlaybackType** | `playbackType`: [AnimationPlayback|#AnimationPlayback]<br>`maxLoopCount`: integer | - | Public |

*... and 3 more methods*

### EditControl

*53 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **AddValidCharacter** | `validCharacter`: string | - | Public |
| **Clear** | - | - | Public |
| **ClearSelection** | - | - | Public |
| **GetAllowMarkupType** | - | `allowMarkupType`: [AllowMarkupType|#AllowMarkupType] | Public |
| **GetCopyEnabled** | - | `enabled`: bool | Public |
| **GetCursorPosition** | - | `cursorPosition`: integer | Public |
| **GetDefaultText** | - | `defaultText`: string | Public |
| **GetEditEnabled** | - | `enabled`: bool | Public |
| **GetFont** | - | `text`: string | Public |
| **GetFontFaceName** | - | `text`: string | Public |
| **GetFontHeight** | - | `fontHeightUIUnits`: number | Public |
| **GetFontSize** | - | `fontSize`: number | Public |
| **GetFontStyle** | - | `text`: string | Public |
| **GetIMECompositionExclusionArea** | - | `leftControlSpace`: number | Public |
| **GetMaxInputChars** | - | `maxChars`: integer | Public |
| **GetNewLineEnabled** | - | `enabled`: bool | Public |
| **GetPasteEnabled** | - | `enabled`: bool | Public |
| **GetScrollExtents** | - | `numLines`: integer | Public |
| **GetSelectAllOnFocus** | - | `enabled`: bool | Public |
| **GetText** | - | `text`: string | Public |
| **GetTextType** | - | `textType`: [TextType|#TextType] | Public |
| **GetTopLineIndex** | - | `index`: luaindex | Public |
| **HasFocus** | - | `focused`: bool | Public |
| **HasSelection** | - | `hasSelection`: bool | Public |
| **InsertText** | `text`: string | - | Public |
| **IsComposingIMEText** | - | `isComposing`: bool | Public |
| **IsMultiLine** | - | `isMultiLine`: bool | Public |
| **IsPassword** | - | `isPassword`: bool | Public |
| **LoseFocus** | - | - | Public |
| **RemoveAllValidCharacters** | - | - | Public |
| **SelectAll** | - | - | Public |
| **SetAllowMarkupType** | `allowMarkupType`: [AllowMarkupType|#AllowMarkupType] | - | Public |
| **SetAsPassword** | `isPassword`: bool | - | Public |
| **SetColor** | `r`: number<br>`g`: number<br>`b`: number<br>*+1 more* | - | Public |
| **SetCopyEnabled** | `enabled`: bool | - | Public |
| **SetCursorPosition** | `cursorPosition`: integer | - | Public |
| **SetDefaultText** | `defaultText`: string | - | Public |
| **SetDefaultTextColor** | `r`: number<br>`g`: number<br>`b`: number<br>*+1 more* | - | Public |
| **SetEditEnabled** | `enabled`: bool | - | Public |
| **SetFont** | `font`: string | - | Public |
| **SetMaxInputChars** | `maxChars`: integer | - | Public |
| **SetMultiLine** | `isMultiLine`: bool | - | Public |
| **SetNewLineEnabled** | `enabled`: bool | - | Public |
| **SetPasteEnabled** | `enabled`: bool | - | Public |
| **SetSelectAllOnFocus** | `enabled`: bool | - | Public |
| **SetSelection** | `selectionStartIndex`: integer<br>`selectionEndIndex`: integer | - | Public |
| **SetSelectionColor** | `r`: number<br>`g`: number<br>`b`: number<br>*+1 more* | - | Public |
| **SetText** | `text`: string<br>`suppressCallbackHandler`: bool | - | Public |
| **SetTextType** | `textType`: [TextType|#TextType] | - | Public |
| **SetTopLineIndex** | `index`: luaindex | - | Public |

*... and 3 more methods*

### LabelControl

*46 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **AnchorToBaseline** | `toLabel`: object<br>`offsetX`: layout_measurement<br>`anchorSide`: [AnchorPosition|#AnchorPosition] | - | Public |
| **Clean** | - | - | Public |
| **ClearAnchorToBaseline** | `toLabel`: object | - | Public |
| **DidLineWrap** | - | `didLineWrap`: bool | Public |
| **GetColor** | - | `r`: number | Public |
| **GetControlColor** | - | `r`: number | Public |
| **GetFont** | - | `text`: string | Public |
| **GetFontFaceName** | - | `text`: string | Public |
| **GetFontHeight** | - | `fontHeightUIUnits`: number | Public |
| **GetFontSize** | - | `fontSize`: number | Public |
| **GetFontStyle** | - | `text`: string | Public |
| **GetHorizontalAlignment** | - | `align`: [TextAlignment|#TextAlignment] | Public |
| **GetLinkEnabled** | - | `linkEnabed`: bool | Public |
| **GetModifyTextType** | - | `modifyTextType`: [ModifyTextType|#ModifyTextType] | Public |
| **GetNumLines** | - | `numLines`: integer | Public |
| **GetShaderEffectType** | - | `shaderEffectType`: [ShaderEffectType|#ShaderEffectType] | Public |
| **GetStringWidth** | `text`: string | `scaledWidthTextLayoutNative`: number | Public |
| **GetStyleColor** | - | `r`: number | Public |
| **GetText** | - | `text`: string | Public |
| **GetTextDimensions** | - | `stringWidthUIUnits`: number | Public |
| **GetTextForLines** | `startLine`: luaindex<br>`endLine`: luaindex | `text`: string | Public |
| **GetTextHeight** | - | `stringHeightUIUnits`: number | Public |
| **GetTextWidth** | - | `stringWidthUIUnits`: number | Public |
| **GetVerticalAlignment** | - | `align`: [TextAlignment|#TextAlignment] | Public |
| **SetColor** | `r`: number<br>`g`: number<br>`b`: number<br>*+1 more* | - | Public |
| **SetControlColor** | `r`: number<br>`g`: number<br>`b`: number<br>*+1 more* | - | Public |
| **SetDesaturation** | `desaturation`: number | - | Public |
| **SetFont** | `fontString`: string | - | Public |
| **SetHorizontalAlignment** | `align`: [TextAlignment|#TextAlignment] | - | Public |
| **SetLineSpacing** | `lineSpacing`: layout_measurement | - | Public |
| **SetLinkEnabled** | `linkEnabed`: bool | - | Public |
| **SetMaxLineCount** | `maxLineCount`: integer | - | Public |
| **SetMinLineCount** | `minLineCount`: integer | - | Public |
| **SetModifyTextType** | `modifyTextType`: [ModifyTextType|#ModifyTextType] | - | Public |
| **SetNewLineX** | `newLineX`: layout_measurement | - | Public |
| **SetPixelRoundingEnabled** | `pixelRoundingEnabled`: bool | - | Public |
| **SetShaderEffectType** | `shaderEffectType`: [ShaderEffectType|#ShaderEffectType] | - | Public |
| **SetSmallCaps** | `smallCaps`: bool | - | Public |
| **SetStoreLineEndingCharacterIndices** | `storeLineEndingCharacterIndices`: bool | - | Public |
| **SetStrikethrough** | `strikethrough`: bool | - | Public |
| **SetStyleColor** | `r`: number<br>`g`: number<br>`b`: number<br>*+1 more* | - | Public |
| **SetText** | `text`: string | - | Public |
| **SetUnderline** | `underline`: bool | - | Public |
| **SetVerticalAlignment** | `align`: [TextAlignment|#TextAlignment] | - | Public |
| **SetWrapMode** | `wrapMode`: integer | - | Public |
| **WasTruncated** | - | `wasTruncated`: bool | Public |

### TextureControl

*38 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **ClearGradientColors** | - | - | Public |
| **Get3DLocalDimensions** | - | `width`: number | Public |
| **GetAddressMode** | - | `addressMode`: [TextureAddressMode|#TextureAddressMode] | Public |
| **GetBlendMode** | - | `blendMode`: [TextureBlendMode|#TextureBlendMode] | Public |
| **GetColor** | - | `r`: number | Public |
| **GetControlColor** | - | `r`: number | Public |
| **GetDesaturation** | - | `desaturation`: number | Public |
| **GetResizeToFitFile** | - | `resizesToFitFile`: bool | Public |
| **GetShaderEffectType** | - | `shaderEffectType`: [ShaderEffectType|#ShaderEffectType] | Public |
| **GetTextureCoords** | - | `left`: number | Public |
| **GetTextureCoordsInPixels** | - | `left`: integer | Public |
| **GetTextureFileDimensions** | - | `pixelWidth`: integer | Public |
| **GetTextureFileName** | - | `filename`: string | Public |
| **GetVertexUV** | `vertex`: [VERTEX_POINTS|#VERTEX_POINTS] | `u`: number | Public |
| **Is3DQuadFacingCamera** | - | `isFacing`: bool | Public |
| **IsPixelRoundingEnabled** | - | `pixelRoundingEnabled`: bool | Public |
| **IsTextureLoaded** | - | `loaded`: bool | Public |
| **Set3DLocalDimensions** | `width`: number<br>`height`: number | - | Public |
| **SetAddressMode** | `addressMode`: [TextureAddressMode|#TextureAddressMode] | - | Public |
| **SetAutoAdjustWrappedCoords** | `enabled`: bool | - | Public |
| **SetBlendMode** | `blendMode`: [TextureBlendMode|#TextureBlendMode] | - | Public |
| **SetColor** | `r`: number<br>`g`: number<br>`b`: number<br>*+1 more* | - | Public |
| **SetControlColor** | `r`: number<br>`g`: number<br>`b`: number<br>*+1 more* | - | Public |
| **SetDesaturation** | `desaturation`: number | - | Public |
| **SetGradientColors** | `orientation`: [ControlOrientation|#ControlOrientation]<br>`startR`: number<br>`startG`: number<br>*+6 more* | - | Public |
| **SetPixelRoundingEnabled** | `pixelRoundingEnabled`: bool | - | Public |
| **SetResizeToFitFile** | `resizesToFitFile`: bool | - | Public |
| **SetShaderEffectType** | `shaderEffectType`: [ShaderEffectType|#ShaderEffectType] | - | Public |
| **SetTexture** | `filename`: string | - | Public |
| **SetTextureCoords** | `left`: number<br>`right`: number<br>`top`: number<br>*+1 more* | - | Public |
| **SetTextureCoordsRotation** | `angleInRadians`: number | - | Public |
| **SetTextureFileName** | `filename`: string | - | Public |
| **SetTextureFromGuiTexture** | `guiTexture`: object | - | Public |
| **SetTextureReleaseOption** | `releaseOption`: [ReleaseReferenceOptions|#ReleaseReferenceOptions] | - | Public |
| **SetTextureRotation** | `angleInRadians`: number<br>`normalizedRotationPointX`: number<br>`normalizedRotationPointY`: number | - | Public |
| **SetTextureSampleProcessingWeight** | `sampleProcessingType`: [TextureSampleProcessing|#TextureSampleProcessing]<br>`weight`: number | - | Public |
| **SetVertexColors** | `vertexPoints`: integer<br>`red`: number<br>`green`: number<br>*+2 more* | - | Public |
| **SetVertexUV** | `vertex`: [VERTEX_POINTS|#VERTEX_POINTS]<br>`u`: number<br>`v`: number | - | Public |

### ButtonControl

*34 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **EnableMouseButton** | `button`: [MouseButtonIndex|#MouseButtonIndex]<br>`enabled`: bool | - | Public |
| **GetHorizontalAlignment** | - | `horizontalAlign`: [TextAlignment|#TextAlignment] | Public |
| **GetLabelControl** | - | `labelControl`: object | Public |
| **GetState** | - | `state`: [ButtonState|#ButtonState] | Public |
| **GetVerticalAlignment** | - | `verticalAlign`: [TextAlignment|#TextAlignment] | Public |
| **IsPixelRoundingEnabled** | - | `pixelRoundingEnabled`: bool | Public |
| **SetClickSound** | `clickSound`: string | - | Public |
| **SetDesaturation** | `desaturation`: number | - | Public |
| **SetDisabledFontColor** | `r`: number<br>`g`: number<br>`b`: number<br>*+1 more* | - | Public |
| **SetDisabledPressedFontColor** | `r`: number<br>`g`: number<br>`b`: number<br>*+1 more* | - | Public |
| **SetDisabledPressedTexture** | `textureFilename`: string | - | Public |
| **SetDisabledTexture** | `textureFilename`: string | - | Public |
| **SetEnabled** | `enabled`: bool | - | Public |
| **SetEndCapWidth** | `endCapWidth`: layout_measurement | - | Public |
| **SetFont** | `text`: string | - | Public |
| **SetHorizontalAlignment** | `horizontalAlign`: [TextAlignment|#TextAlignment] | - | Public |
| **SetModifyTextType** | `modifyTextType`: [ModifyTextType|#ModifyTextType] | - | Public |
| **SetMouseOverBlendMode** | `blendMode`: [TextureBlendMode|#TextureBlendMode] | - | Public |
| **SetMouseOverFontColor** | `r`: number<br>`g`: number<br>`b`: number<br>*+1 more* | - | Public |
| **SetMouseOverTexture** | `textureFilename`: string | - | Public |
| **SetNormalFontColor** | `r`: number<br>`g`: number<br>`b`: number<br>*+1 more* | - | Public |
| **SetNormalOffset** | `x`: layout_measurement<br>`y`: layout_measurement | - | Public |
| **SetNormalTexture** | `textureFilename`: string | - | Public |
| **SetPixelRoundingEnabled** | `pixelRoundingEnabled`: bool | - | Public |
| **SetPressedFontColor** | `r`: number<br>`g`: number<br>`b`: number<br>*+1 more* | - | Public |
| **SetPressedMouseOverTexture** | `textureFilename`: string | - | Public |
| **SetPressedOffset** | `x`: layout_measurement<br>`y`: layout_measurement | - | Public |
| **SetPressedTexture** | `textureFilename`: string | - | Public |
| **SetShowingHighlight** | `showingHighlight`: bool | - | Public |
| **SetState** | `newState`: [ButtonState|#ButtonState]<br>`locked`: bool | - | Public |
| **SetText** | `text`: string | - | Public |
| **SetTextureCoords** | `left`: number<br>`right`: number<br>`top`: number<br>*+1 more* | - | Public |
| **SetTextureReleaseOption** | `releaseOption`: [ReleaseReferenceOptions|#ReleaseReferenceOptions] | - | Public |
| **SetVerticalAlignment** | `verticalAlign`: [TextAlignment|#TextAlignment] | - | Public |

### PolygonControl

*33 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **AddPoint** | `normalizedX`: number<br>`normalizedY`: number | - | Public |
| **ClearPoints** | - | - | Public |
| **GetBorderBlendMode** | - | `blendMode`: [TextureBlendMode|#TextureBlendMode] | Public |
| **GetBorderDesaturation** | - | `desaturation`: number | Public |
| **GetBorderDirection** | - | `direction`: [PolygonBorderDirection|#PolygonBorderDirection] | Public |
| **GetBorderTexture** | - | `textureFile`: string | Public |
| **GetBorderThickness** | - | `mins`: number | Public |
| **GetCenterBlendMode** | - | `blendMode`: [TextureBlendMode|#TextureBlendMode] | Public |
| **GetCenterColor** | - | `r`: number | Public |
| **GetCenterDesaturation** | - | `desaturation`: number | Public |
| **GetCenterTexture** | - | `textureFile`: string | Public |
| **GetCenterTextureAddressMode** | - | `addressMode`: [TextureAddressMode|#TextureAddressMode] | Public |
| **GetCenterTextureCoords** | - | `left`: number | Public |
| **GetNumPoints** | - | `numPoints`: integer | Public |
| **GetPoint** | `index`: luaindex | `normalizedX`: number | Public |
| **GetPointLayout** | - | `pointLayout`: [PolygonPointLayout|#PolygonPointLayout] | Public |
| **IsSmoothingEnabled** | - | `isSmoothingEnabled`: bool | Public |
| **SetBorder** | `minThickness`: layout_measurement<br>`maxThickness`: layout_measurement<br>`thicknessPercent`: number<br>*+5 more* | - | Public |
| **SetBorderBlendMode** | `blendMode`: [TextureBlendMode|#TextureBlendMode] | - | Public |
| **SetBorderColor** | `r`: number<br>`g`: number<br>`b`: number<br>*+1 more* | - | Public |
| **SetBorderDesaturation** | `desaturation`: number | - | Public |
| **SetBorderDirection** | `direction`: [PolygonBorderDirection|#PolygonBorderDirection] | - | Public |
| **SetBorderTexture** | `textureFile`: string | - | Public |
| **SetBorderThickness** | `min`: layout_measurement<br>`max`: layout_measurement<br>`percent`: number | - | Public |
| **SetCenterBlendMode** | `blendMode`: [TextureBlendMode|#TextureBlendMode] | - | Public |
| **SetCenterColor** | `r`: number<br>`g`: number<br>`b`: number<br>*+1 more* | - | Public |
| **SetCenterDesaturation** | `desaturation`: number | - | Public |
| **SetCenterTexture** | `textureFile`: string | - | Public |
| **SetCenterTextureAddressMode** | `addressMode`: [TextureAddressMode|#TextureAddressMode] | - | Public |
| **SetCenterTextureCoords** | `left`: number<br>`right`: number<br>`top`: number<br>*+1 more* | - | Public |
| **SetPoint** | `index`: luaindex<br>`normalizedX`: number<br>`normalizedY`: number | - | Public |
| **SetPointLayout** | `pointLayout`: [PolygonPointLayout|#PolygonPointLayout] | - | Public |
| **SetSmoothingEnabled** | `isSmoothingEnabled`: bool | - | Public |

### AddOnManager

*27 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **AddRelevantFilter** | `relevantFilter`: string | - | Public |
| **AreAddOnsEnabled** | - | `areAddOnsEnabled`: bool | Public |
| **ClearForceDisabledAddOnNotification** | `disabledAddonIndex`: luaindex | - | Public |
| **ClearUnusedAddOnSavedVariables** | - | - | Public |
| **ClearWarnOutOfDateAddOns** | - | - | Public |
| **GetAddOnDependencyInfo** | `addOnIndex`: luaindex<br>`addOnDependencyIndex`: luaindex | `name`: string | Public |
| **GetAddOnFilter** | - | `settingFilter`: string | Public |
| **GetAddOnInfo** | `addOnIndex`: luaindex | `name`: string | Public |
| **GetAddOnNumDependencies** | `addOnIndex`: luaindex | `numDependencies`: integer | Public |
| **GetAddOnRootDirectoryPath** | `addOnIndex`: luaindex | `directoryPath`: string | Public |
| **GetAddOnVersion** | `addOnIndex`: luaindex | `version`: integer | Public |
| **GetForceDisabledAddOnInfo** | `disabledAddonIndex`: luaindex | `addonName`: string | Public |
| **GetLoadOutOfDateAddOns** | - | `loadOutOfDateAddons`: bool | Public |
| **GetNumAddOns** | - | `numAddOns`: integer | Public |
| **GetNumForceDisabledAddOns** | - | `numDisabledAddons`: integer | Public |
| **GetTotalUnusedAddOnSavedVariablesDiskUsageMB** | - | `totalUnusedAddOnSavedVariablesDiskUsageMB`: number | Public |
| **GetTotalUserAddOnSavedVariablesDiskCapacityMB** | - | `totalUserAddOnSavedVariablesDiskCapacityMB`: number | Public |
| **GetTotalUserAddOnSavedVariablesDiskUsageMB** | - | `totalUserAddOnSavedVariablesDiskUsageMB`: number | Public |
| **GetUserAddOnSavedVariablesDiskUsageMB** | `addOnIndex`: luaindex | `userAddOnSavedVariablesDiskUsageMB`: number | Public |
| **RemoveAddOnFilter** | - | - | Public |
| **RequestAddOnSavedVariablesPrioritySave** | `addOnName`: string | - | Public |
| **ResetRelevantFilters** | - | - | Public |
| **SetAddOnEnabled** | `addOnIndex`: luaindex<br>`enabled`: bool | - | Public |
| **SetAddOnFilter** | `settingFilter`: string | - | Public |
| **SetAddOnsEnabled** | `enabled`: bool | - | Public |
| **ShouldWarnOutOfDateAddOns** | - | `warnOutOfDateAddons`: bool | Public |
| **WasAddOnDetected** | `addOnName`: string | `wasDetected`: bool | Public |

### TextureCompositeControl

*27 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **AddSurface** | `left`: number<br>`right`: number<br>`top`: number<br>*+1 more* | `surfaceIndex`: luaindex | Public |
| **ClearAllSurfaces** | - | - | Public |
| **GetBlendMode** | - | `blendMode`: [TextureBlendMode|#TextureBlendMode] | Public |
| **GetColor** | `surfaceIndex`: luaindex | `r`: number | Public |
| **GetDesaturation** | - | `desaturation`: number | Public |
| **GetInsets** | `surfaceIndex`: luaindex | `left`: number | Public |
| **GetNumSurfaces** | - | `surfaces`: integer | Public |
| **GetSurfaceAlpha** | `surfaceIndex`: luaindex | `a`: number | Public |
| **GetTextureCoords** | `surfaceIndex`: luaindex | `left`: number | Public |
| **GetTextureFileDimensions** | - | `pixelWidth`: integer | Public |
| **GetTextureFileName** | - | `filename`: string | Public |
| **IsPixelRoundingEnabled** | - | `pixelRoundingEnabled`: bool | Public |
| **IsSurfaceHidden** | `surfaceIndex`: luaindex | `hidden`: bool | Public |
| **IsTextureLoaded** | - | `loaded`: bool | Public |
| **RemoveSurface** | `surfaceIndex`: luaindex | - | Public |
| **SetBlendMode** | `blendMode`: [TextureBlendMode|#TextureBlendMode] | - | Public |
| **SetColor** | `surfaceIndex`: luaindex<br>`r`: number<br>`g`: number<br>*+2 more* | - | Public |
| **SetDesaturation** | `desaturation`: number | - | Public |
| **SetInsets** | `surfaceIndex`: luaindex<br>`left`: number<br>`right`: number<br>*+2 more* | - | Public |
| **SetPixelRoundingEnabled** | `pixelRoundingEnabled`: bool | - | Public |
| **SetSurfaceAlpha** | `surfaceIndex`: luaindex<br>`a`: number | - | Public |
| **SetSurfaceHidden** | `surfaceIndex`: luaindex<br>`hidden`: bool | - | Public |
| **SetSurfaceScale** | `surfaceIndex`: luaindex<br>`scale`: number | - | Public |
| **SetSurfaceTextureRotation** | `surfaceIndex`: luaindex<br>`angleInRadians`: number<br>`normalizedRotationPointX`: number<br>*+1 more* | - | Public |
| **SetTexture** | `filename`: string | - | Public |
| **SetTextureCoords** | `surfaceIndex`: luaindex<br>`left`: number<br>`right`: number<br>*+2 more* | - | Public |
| **SetTextureReleaseOption** | `releaseOption`: [ReleaseReferenceOptions|#ReleaseReferenceOptions] | - | Public |

### StatusBarControl

*26 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **CalculateSizeWithoutLeadingEdgeForValue** | `value`: number | `mainBarSize`: number | Public |
| **ClearFadeOutLossAdjustedTopValue** | - | - | Public |
| **EnableFadeOut** | `enabled`: bool | - | Public |
| **EnableLeadingEdge** | `enabled`: bool | - | Public |
| **EnableScrollingOverlay** | `enabled`: bool | - | Public |
| **GetMinMax** | - | `min`: number | Public |
| **GetValue** | - | `value`: number | Public |
| **IsPixelRoundingEnabled** | - | `pixelRoundingEnabled`: bool | Public |
| **SetBarAlignment** | `barAlignment`: [BarAlignment|#BarAlignment] | - | Public |
| **SetColor** | `r`: number<br>`g`: number<br>`b`: number<br>*+1 more* | - | Public |
| **SetFadeOutGainColor** | `r`: number<br>`g`: number<br>`b`: number<br>*+1 more* | - | Public |
| **SetFadeOutLossAdjustedTopValue** | `topValue`: number | - | Public |
| **SetFadeOutLossColor** | `r`: number<br>`g`: number<br>`b`: number<br>*+1 more* | - | Public |
| **SetFadeOutLossSetValueToAdjust** | `adjustValue`: number | - | Public |
| **SetFadeOutTexture** | `filename`: string | - | Public |
| **SetFadeOutTime** | `fadeOutSeconds`: number<br>`fadeOutDelaySeconds`: number | - | Public |
| **SetGradientColors** | `startR`: number<br>`startG`: number<br>`startB`: number<br>*+5 more* | - | Public |
| **SetLeadingEdge** | `textureFile`: string<br>`width`: number<br>`height`: number | - | Public |
| **SetLeadingEdgeTextureCoords** | `left`: number<br>`right`: number<br>`top`: number<br>*+1 more* | - | Public |
| **SetMinMax** | `aMin`: number<br>`aMax`: number | - | Public |
| **SetOrientation** | `orientation`: [ControlOrientation|#ControlOrientation] | - | Public |
| **SetPixelRoundingEnabled** | `pixelRoundingEnabled`: bool | - | Public |
| **SetTexture** | `filename`: string | - | Public |
| **SetTextureCoords** | `left`: number<br>`right`: number<br>`top`: number<br>*+1 more* | - | Public |
| **SetValue** | `aValue`: number | - | Public |
| **SetupScrollingOverlay** | `textureFile`: string<br>`width`: number<br>`height`: number<br>*+1 more* | - | Public |

### CanvasControl

*24 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **Arc** | `centerX`: number<br>`centerY`: number<br>`radius`: number<br>*+3 more* | - | Public |
| **ArcTo** | `controlPoint1X`: number<br>`controlPoint1Y`: number<br>`controlPoint2X`: number<br>*+2 more* | - | Public |
| **BeginPath** | - | - | Public |
| **Clear** | - | - | Public |
| **ClosePath** | - | - | Public |
| **Fill** | - | - | Public |
| **FillRect** | `x`: number<br>`y`: number<br>`width`: number<br>*+1 more* | - | Public |
| **GetObjectFit** | - | `objectFit`: [ObjectFit|#ObjectFit] | Public |
| **LineTo** | `x`: number<br>`y`: number | - | Public |
| **MoveTo** | `x`: number<br>`y`: number | - | Public |
| **QuadraticCurveTo** | `controlPointX`: number<br>`controlPointY`: number<br>`endPointX`: number<br>*+1 more* | - | Public |
| **Rect** | `x`: number<br>`y`: number<br>`width`: number<br>*+1 more* | - | Public |
| **RoundRect** | `x`: number<br>`y`: number<br>`width`: number<br>*+5 more* | - | Public |
| **SetCanvasSize** | `width`: number<br>`height`: number | - | Public |
| **SetFillColor** | `r`: number<br>`g`: number<br>`b`: number<br>*+1 more* | - | Public |
| **SetObjectFit** | `objectFit`: [ObjectFit|#ObjectFit] | - | Public |
| **SetStrokeCapStyle** | `capStyle`: [StrokeCapStyle|#StrokeCapStyle] | - | Public |
| **SetStrokeColor** | `r`: number<br>`g`: number<br>`b`: number<br>*+1 more* | - | Public |
| **SetStrokeJoinType** | `joinType`: [StrokeJoinType|#StrokeJoinType]<br>`miterLimit`: number | - | Public |
| **SetStrokeLineDash** | `lineDashArray`: number | - | Public |
| **SetStrokeLineDashOffset** | `lineDashOffset`: number | - | Public |
| **SetStrokeWidth** | `width`: number | - | Public |
| **Stroke** | - | - | Public |
| **StrokeRect** | `x`: number<br>`y`: number<br>`width`: number<br>*+1 more* | - | Public |

### TextBufferControl

*24 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **AddMessage** | `text`: string<br>`r`: number<br>`g`: number<br>*+2 more* | - | Public |
| **Clear** | - | - | Public |
| **GetDrawLastEntryIfOutOfRoom** | - | `drawLastIfOutOfRoom`: bool | Public |
| **GetHorizontalAlignment** | - | `horizontalAlign`: [TextAlignment|#TextAlignment] | Public |
| **GetLineFade** | - | `timeBeforeLineBeginsToFade`: number | Public |
| **GetLinkEnabled** | - | `linkEnabed`: bool | Public |
| **GetMaxHistoryLines** | - | `numLines`: integer | Public |
| **GetNumHistoryLines** | - | `numLines`: integer | Public |
| **GetNumVisibleLines** | - | `numLines`: integer | Public |
| **GetScrollPosition** | - | `scrollPosition`: integer | Public |
| **IsSplittingLongMessages** | - | `isSplitting`: bool | Public |
| **MoveScrollPosition** | `numLines`: integer | - | Public |
| **SetClearBufferAfterFadeout** | `clearAfterFade`: bool | - | Public |
| **SetColorById** | `colorId`: integer<br>`r`: number<br>`g`: number<br>*+1 more* | - | Public |
| **SetDrawLastEntryIfOutOfRoom** | `drawLastIfOutOfRoom`: bool | - | Public |
| **SetFont** | `fontString`: string | - | Public |
| **SetHorizontalAlignment** | `horizontalAlign`: [TextAlignment|#TextAlignment] | - | Public |
| **SetLineFade** | `timeBeforeLineFadeBegins`: number<br>`timeForLineToFade`: number | - | Public |
| **SetLinesInheritAlpha** | `linesInheritAlpha`: bool | - | Public |
| **SetLinkEnabled** | `linkEnabed`: bool | - | Public |
| **SetMaxHistoryLines** | `numLines`: integer | - | Public |
| **SetScrollPosition** | `line`: integer | - | Public |
| **SetSplitLongMessages** | `splitLongMessages`: bool | - | Public |
| **ShowFadedLines** | - | - | Public |

### AnimationObject3DTranslate

*23 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **ClearBezierControlPoints** | - | - | Public |
| **GetDeltaOffsetX** | - | `deltaX`: number | Public |
| **GetDeltaOffsetY** | - | `deltaY`: number | Public |
| **GetDeltaOffsetZ** | - | `deltaZ`: number | Public |
| **GetEndOffsetX** | - | `endX`: number | Public |
| **GetEndOffsetY** | - | `endY`: number | Public |
| **GetEndOffsetZ** | - | `endZ`: number | Public |
| **GetStartOffsetX** | - | `startX`: number | Public |
| **GetStartOffsetY** | - | `startY`: number | Public |
| **GetStartOffsetZ** | - | `startZ`: number | Public |
| **GetTranslateDeltas** | - | `deltaX`: number | Public |
| **SetBezierControlPoint** | `index`: luaindex<br>`x`: number<br>`y`: number<br>*+1 more* | - | Public |
| **SetDeltaOffsetX** | `deltaX`: number<br>`translateAnimationDeltaType`: [TranslateAnimationDeltaType|#TranslateAnimationDeltaType] | - | Public |
| **SetDeltaOffsetY** | `deltaY`: number<br>`translateAnimationDeltaType`: [TranslateAnimationDeltaType|#TranslateAnimationDeltaType] | - | Public |
| **SetDeltaOffsetZ** | `deltaZ`: number<br>`translateAnimationDeltaType`: [TranslateAnimationDeltaType|#TranslateAnimationDeltaType] | - | Public |
| **SetEndOffsetX** | `endX`: number | - | Public |
| **SetEndOffsetY** | `endY`: number | - | Public |
| **SetEndOffsetZ** | `endZ`: number | - | Public |
| **SetStartOffsetX** | `startX`: number | - | Public |
| **SetStartOffsetY** | `startY`: number | - | Public |
| **SetStartOffsetZ** | `startZ`: number | - | Public |
| **SetTranslateDeltas** | `deltaX`: number<br>`deltaY`: number<br>`deltaZ`: number<br>*+1 more* | - | Public |
| **SetTranslateOffsets** | `startX`: number<br>`startY`: number<br>`startZ`: number<br>*+3 more* | - | Public |

### SliderControl

*22 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **DoesAllowDraggingFromThumb** | - | `allow`: bool | Public |
| **GetEnabled** | - | `isEnabled`: bool | Public |
| **GetMinMax** | - | `min`: number | Public |
| **GetOrientation** | - | `orientation`: [ControlOrientation|#ControlOrientation] | Public |
| **GetThumbTextureControl** | - | `textureControl`: object | Public |
| **GetValue** | - | `value`: number | Public |
| **GetValueStep** | - | `step`: number | Public |
| **IsThumbFlushWithExtents** | - | `flush`: bool | Public |
| **SetAllowDraggingFromThumb** | `allow`: bool | - | Public |
| **SetBackgroundBottomTexture** | `fileName`: string<br>`texTop`: number<br>`texLeft`: number<br>*+2 more* | - | Public |
| **SetBackgroundMiddleTexture** | `fileName`: string<br>`texTop`: number<br>`texLeft`: number<br>*+2 more* | - | Public |
| **SetBackgroundTopTexture** | `fileName`: string<br>`texTop`: number<br>`texLeft`: number<br>*+2 more* | - | Public |
| **SetColor** | `r`: number<br>`g`: number<br>`b`: number<br>*+1 more* | - | Public |
| **SetEnabled** | `enable`: bool | - | Public |
| **SetMinMax** | `min`: number<br>`max`: number | - | Public |
| **SetOrientation** | `orientation`: [ControlOrientation|#ControlOrientation] | - | Public |
| **SetThumbFlushWithExtents** | `flush`: bool | - | Public |
| **SetThumbTexture** | `filename`: string<br>`disabledFilename`: string<br>`highlightedFilename`: string<br>*+6 more* | - | Public |
| **SetThumbTextureAndFlush** | `filename`: string<br>`disabledFilename`: string<br>`highlightedFilename`: string<br>*+7 more* | - | Public |
| **SetThumbTextureHeight** | `height`: layout_measurement | - | Public |
| **SetValue** | `value`: number | - | Public |
| **SetValueStep** | `step`: number | - | Public |

### AnimationObjectTranslate

*21 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **GetAnchorIndex** | - | `anchorIndex`: integer | Public |
| **GetDeltaOffsetX** | - | `deltaX`: number | Public |
| **GetDeltaOffsetY** | - | `deltaY`: number | Public |
| **GetEndOffsetX** | - | `endX`: number | Public |
| **GetEndOffsetY** | - | `endY`: number | Public |
| **GetStartOffsetX** | - | `startX`: number | Public |
| **GetStartOffsetY** | - | `startY`: number | Public |
| **GetTranslateDeltas** | - | `deltaX`: number | Public |
| **SetAnchorIndex** | `anchorIndex`: integer | - | Public |
| **SetDeltaOffsetX** | `deltaX`: layout_measurement<br>`translateAnimationDeltaType`: [TranslateAnimationDeltaType|#TranslateAnimationDeltaType] | - | Public |
| **SetDeltaOffsetXFromEnd** | `deltaX`: layout_measurement | - | Public |
| **SetDeltaOffsetXFromStart** | `deltaX`: layout_measurement | - | Public |
| **SetDeltaOffsetY** | `deltaY`: layout_measurement<br>`translateAnimationDeltaType`: [TranslateAnimationDeltaType|#TranslateAnimationDeltaType] | - | Public |
| **SetDeltaOffsetYFromEnd** | `deltaY`: layout_measurement | - | Public |
| **SetDeltaOffsetYFromStart** | `deltaY`: layout_measurement | - | Public |
| **SetEndOffsetX** | `endX`: layout_measurement | - | Public |
| **SetEndOffsetY** | `endY`: layout_measurement | - | Public |
| **SetStartOffsetX** | `startX`: layout_measurement | - | Public |
| **SetStartOffsetY** | `startY`: layout_measurement | - | Public |
| **SetTranslateDeltas** | `deltaX`: layout_measurement<br>`deltaY`: layout_measurement<br>`translateAnimationDeltaType`: [TranslateAnimationDeltaType|#TranslateAnimationDeltaType] | - | Public |
| **SetTranslateOffsets** | `startX`: layout_measurement<br>`startY`: layout_measurement<br>`endX`: layout_measurement<br>*+1 more* | - | Public |

### LineControl

*20 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **ClearGradientColors** | - | - | Public |
| **GetBlendMode** | - | `blendMode`: [TextureBlendMode|#TextureBlendMode] | Public |
| **GetColor** | - | `r`: number | Public |
| **GetDesaturation** | - | `desaturation`: number | Public |
| **GetTextureCoords** | - | `left`: number | Public |
| **GetTextureCoordsInPixels** | - | `left`: integer | Public |
| **GetTextureFileDimensions** | - | `pixelWidth`: integer | Public |
| **GetTextureFileName** | - | `filename`: string | Public |
| **GetThickness** | - | `thickness`: number | Public |
| **IsPixelRoundingEnabled** | - | `pixelRoundingEnabled`: bool | Public |
| **IsTextureLoaded** | - | `loaded`: bool | Public |
| **SetBlendMode** | `blendMode`: [TextureBlendMode|#TextureBlendMode] | - | Public |
| **SetColor** | `r`: number<br>`g`: number<br>`b`: number<br>*+1 more* | - | Public |
| **SetDesaturation** | `desaturation`: number | - | Public |
| **SetGradientColors** | `orientation`: [ControlOrientation|#ControlOrientation]<br>`startR`: number<br>`startG`: number<br>*+6 more* | - | Public |
| **SetPixelRoundingEnabled** | `pixelRoundingEnabled`: bool | - | Public |
| **SetTexture** | `filename`: string | - | Public |
| **SetTextureCoords** | `left`: number<br>`right`: number<br>`top`: number<br>*+1 more* | - | Public |
| **SetThickness** | `thickness`: layout_measurement | - | Public |
| **SetVertexColors** | `vertexPoints`: integer<br>`red`: number<br>`green`: number<br>*+2 more* | - | Public |

### CooldownControl

*18 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **GetDuration** | - | `duration`: integer | Public |
| **GetPercentCompleteFixed** | - | `percentComplete`: number | Public |
| **GetTimeLeft** | - | `time`: integer | Public |
| **ResetCooldown** | - | - | Public |
| **SetBlendMode** | `blendMode`: integer | - | Public |
| **SetCooldownRemainTime** | `remain`: integer | - | Public |
| **SetDesaturation** | `desaturation`: number | - | Public |
| **SetFillColor** | `r`: number<br>`g`: number<br>`b`: number<br>*+1 more* | - | Public |
| **SetLeadingEdgeTexture** | `filename`: string | - | Public |
| **SetPercentCompleteFixed** | `percentComplete`: number | - | Public |
| **SetRadialCooldownClockwise** | `clockwise`: bool | - | Public |
| **SetRadialCooldownGradient** | `startAlpha`: number<br>`angularDistance`: number | - | Public |
| **SetRadialCooldownOriginAngle** | `originAngle`: number | - | Public |
| **SetTexture** | `filename`: string | - | Public |
| **SetTextureReleaseOption** | `releaseOption`: [ReleaseReferenceOptions|#ReleaseReferenceOptions] | - | Public |
| **SetVerticalCooldownLeadingEdgeHeight** | `leadingEdgeHeight`: integer | - | Public |
| **StartCooldown** | `remain`: integer<br>`duration`: integer<br>`cooldownType`: integer<br>*+2 more* | - | Public |
| **StartFixedCooldown** | `percentComplete`: number<br>`cooldownType`: integer<br>`cooldownTimeType`: integer<br>*+1 more* | - | Public |

### BackdropControl

*17 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **GetBlendMode** | - | `blendMode`: [TextureBlendMode|#TextureBlendMode] | Public |
| **GetCenterColor** | - | `r`: number | Public |
| **GetCenterTextureFileName** | - | `filename`: string | Public |
| **GetEdgeColor** | - | `r`: number | Public |
| **GetEdgeTextureFileName** | - | `filename`: string | Public |
| **IsPixelRoundingEnabled** | - | `pixelRoundingEnabled`: bool | Public |
| **SetBlendMode** | `blendMode`: [TextureBlendMode|#TextureBlendMode] | - | Public |
| **SetCenterColor** | `r`: number<br>`g`: number<br>`b`: number<br>*+1 more* | - | Public |
| **SetCenterTexture** | `filename`: string<br>`tilingInterval`: layout_measurement<br>`addressMode`: [TextureAddressMode|#TextureAddressMode] | - | Public |
| **SetCenterTextureFileName** | `filename`: string | - | Public |
| **SetEdgeColor** | `r`: number<br>`g`: number<br>`b`: number<br>*+1 more* | - | Public |
| **SetEdgeTexture** | `filename`: string<br>`edgeFileWidth`: integer<br>`edgeFileHeight`: integer<br>*+2 more* | - | Public |
| **SetEdgeTextureFileName** | `filename`: string | - | Public |
| **SetInsets** | `left`: layout_measurement<br>`top`: layout_measurement<br>`right`: layout_measurement<br>*+1 more* | - | Public |
| **SetIntegralWrapping** | `integralWrappingEnabled`: bool | - | Public |
| **SetPixelRoundingEnabled** | `enabled`: bool | - | Public |
| **SetTextureReleaseOption** | `releaseOption`: [ReleaseReferenceOptions|#ReleaseReferenceOptions] | - | Public |

### AnimationObject

*16 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **GetAnimatedControl** | - | `animatedControl`: object | Public |
| **GetApplyToChildControlName** | - | `applyToChildControlName`: string | Public |
| **GetDuration** | - | `durationMs`: integer | Public |
| **GetEasingFunction** | - | `functionRef`: function | Public |
| **GetHandler** | `eventName`: string<br>`name`: string | `functionRef`: function | Public |
| **GetTimeline** | - | `owningTimeline`: object | Public |
| **GetType** | - | `animationObjectType`: [AnimationType|#AnimationType] | Public |
| **IsEnabled** | - | `isEnabled`: bool | Public |
| **IsPlaying** | - | `isPlaying`: bool | Public |
| **SetAnimatedControl** | `animatedControl`: object | - | Public |
| **SetApplyToChildControlName** | `applyToChildControlName`: string | - | Public |
| **SetDuration** | `durationMs`: integer | - | Public |
| **SetEasingFunction** | `functionRef`: function | - | Public |
| **SetEnabled** | `enabled`: bool | - | Public |
| **SetHandler** | `eventName`: string<br>`functionRef`: function<br>`name`: string<br>*+2 more* | - | Public |
| **SetOffsetInParent** | `offset`: integer | - | Public |

### AnimationObject3DRotate

*13 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **GetEndPitch** | - | `endPitchRadians`: number | Public |
| **GetEndRoll** | - | `endRollRadians`: number | Public |
| **GetEndYaw** | - | `endYawRadians`: number | Public |
| **GetStartPitch** | - | `startPitchRadians`: number | Public |
| **GetStartRoll** | - | `startRollRadians`: number | Public |
| **GetStartYaw** | - | `startYawRadians`: number | Public |
| **SetEndPitch** | `endPitchRadians`: number | - | Public |
| **SetEndRoll** | `endRollRadians`: number | - | Public |
| **SetEndYaw** | `endYawRadians`: number | - | Public |
| **SetRotationValues** | `startPitchRadians`: number<br>`startYawRadians`: number<br>`startRollRadians`: number<br>*+3 more* | - | Public |
| **SetStartPitch** | `startPitchRadians`: number | - | Public |
| **SetStartRoll** | `startRollRadians`: number | - | Public |
| **SetStartYaw** | `startYawRadians`: number | - | Public |

### CompassDisplayControl

*13 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **GetAlphaDropoffBehavior** | `pinType`: [MapDisplayPinType|#MapDisplayPinType] | `closeAlpha`: number | Public |
| **GetCenterOveredPinDescription** | `centerOveredPinIndex`: luaindex | `description`: string | Public |
| **GetCenterOveredPinDistance** | `centerOveredPinIndex`: luaindex | `distanceFromPlayerCM`: number | Public |
| **GetCenterOveredPinInfo** | `centerOveredPinIndex`: luaindex | `description`: string | Public |
| **GetCenterOveredPinLayerAndLevel** | `centerOveredPinIndex`: luaindex | `drawLayer`: [DrawLayer|#DrawLayer] | Public |
| **GetCenterOveredPinType** | `centerOveredPinIndex`: luaindex | `type`: [MapDisplayPinType|#MapDisplayPinType] | Public |
| **GetNumCenterOveredPins** | - | `numCenterOveredPins`: integer | Public |
| **GetScaleDropoffBehavior** | `pinType`: [MapDisplayPinType|#MapDisplayPinType] | `closeScale`: number | Public |
| **IsCenterOveredPinSuppressed** | `centerOveredPinIndex`: luaindex | `suppressed`: bool | Public |
| **SetAlphaDropoffBehavior** | `pinType`: [MapDisplayPinType|#MapDisplayPinType]<br>`closeAlpha`: number<br>`farAlpha`: number<br>*+2 more* | - | Public |
| **SetCardinalDirection** | `directionName`: string<br>`font`: string<br>`cardinalDirection`: integer | - | Public |
| **SetPinInfo** | `type`: [MapDisplayPinType|#MapDisplayPinType]<br>`pinSize`: number<br>`pinTexture`: string<br>*+20 more* | - | Public |
| **SetScaleDropoffBehavior** | `pinType`: [MapDisplayPinType|#MapDisplayPinType]<br>`closeScale`: number<br>`farScale`: number<br>*+2 more* | - | Public |

### ColorSelectControl

*12 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **GetColorAsHSV** | - | `hue`: number | Public |
| **GetColorAsRGB** | - | `red`: number | Public |
| **GetColorWheelTextureControl** | - | `textureControl`: object | Public |
| **GetColorWheelThumbTextureControl** | - | `textureControl`: object | Public |
| **GetFullValuedColorAsRGB** | - | `red`: number | Public |
| **GetThumbNormalizedPosition** | - | `normalizedX`: number | Public |
| **GetValue** | - | `value`: number | Public |
| **SetColorAsHSV** | `hue`: number<br>`saturation`: number<br>`value`: number | - | Public |
| **SetColorAsRGB** | `red`: number<br>`green`: number<br>`blue`: number | - | Public |
| **SetColorWheelThumbTextureControl** | `textureControl`: object | - | Public |
| **SetThumbNormalizedPosition** | `normalizedX`: number<br>`normalizedY`: number | - | Public |
| **SetValue** | `value`: number | - | Public |

### AnimationObjectTransformOffset

*11 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **GetEndOffset** | - | `endX`: number:nilable | Public |
| **GetStartOffset** | - | `startX`: number:nilable | Public |
| **SetEndOffset** | `endX`: layout_measurement<br>`endY`: layout_measurement<br>`endZ`: layout_measurement | - | Public |
| **SetEndOffsetX** | `endX`: layout_measurement | - | Public |
| **SetEndOffsetY** | `endY`: layout_measurement | - | Public |
| **SetEndOffsetZ** | `endZ`: layout_measurement | - | Public |
| **SetOffsets** | `startX`: layout_measurement<br>`startY`: layout_measurement<br>`startZ`: layout_measurement<br>*+3 more* | - | Public |
| **SetStartOffset** | `startX`: layout_measurement<br>`startY`: layout_measurement<br>`startZ`: layout_measurement | - | Public |
| **SetStartOffsetX** | `startX`: layout_measurement | - | Public |
| **SetStartOffsetY** | `startY`: layout_measurement | - | Public |
| **SetStartOffsetZ** | `startZ`: layout_measurement | - | Public |

### ScrollControl

*11 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **GetHorizontalScroll** | - | `offset`: number | Public |
| **GetHorizontalScrollExtent** | - | `horizontal`: number | Public |
| **GetScrollBounding** | - | `bounding`: [ScrollBounding|#ScrollBounding] | Public |
| **GetScrollExtents** | - | `horizontal`: number | Public |
| **GetScrollOffsets** | - | `horizontal`: number | Public |
| **GetVerticalScroll** | - | `offset`: number | Public |
| **GetVerticalScrollExtent** | - | `vertical`: number | Public |
| **RestoreToExtents** | `duration`: integer | - | Public |
| **SetHorizontalScroll** | `offset`: layout_measurement | - | Public |
| **SetScrollBounding** | `bounding`: [ScrollBounding|#ScrollBounding] | - | Public |
| **SetVerticalScroll** | `offset`: layout_measurement | - | Public |

### AnimationObjectTexture

*10 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **GetCellsHigh** | - | `aNumCellsHigh`: integer | Public |
| **GetCellsWide** | - | `aNumCellsWide`: integer | Public |
| **IsMirroringAlongX** | - | `mirroring`: bool | Public |
| **IsMirroringAlongY** | - | `mirroring`: bool | Public |
| **SetCellsHigh** | `aNumCellsHigh`: integer | - | Public |
| **SetCellsWide** | `aNumCellsWide`: integer | - | Public |
| **SetFramerate** | `framesPerSecond`: number | - | Public |
| **SetImageData** | `aNumCellsWide`: integer<br>`aNumCellsHigh`: integer | - | Public |
| **SetMirrorAlongX** | `mirroring`: bool | - | Public |
| **SetMirrorAlongY** | `mirroring`: bool | - | Public |

### AnimationObjectTransformRotation

*10 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **SetEndRotation** | `endXRadians`: number<br>`endYRadians`: number<br>`endZRadians`: number | - | Public |
| **SetEndX** | `endXRadians`: number | - | Public |
| **SetEndY** | `endYRadians`: number | - | Public |
| **SetEndZ** | `endZRadians`: number | - | Public |
| **SetMode** | `mode`: [RotationAnimationMode|#RotationAnimationMode] | - | Public |
| **SetRotations** | `startXRadians`: number<br>`startYRadians`: number<br>`startZRadians`: number<br>*+3 more* | - | Public |
| **SetStartRotation** | `startXRadians`: number<br>`startYRadians`: number<br>`startZRadians`: number | - | Public |
| **SetStartX** | `startXRadians`: number | - | Public |
| **SetStartY** | `startYRadians`: number | - | Public |
| **SetStartZ** | `startZRadians`: number | - | Public |

### SynchronizingObject

*9 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **Broadcast** | `message`: string | - | Public |
| **GetState** | - | `state`: string | Public |
| **GetStateAsTable** | - | `stateTable`: table | Public |
| **Hide** | - | - | Public |
| **IsShown** | - | `isShown`: bool | Public |
| **SetHandler** | `handlerName`: string<br>`functionRef`: function<br>`name`: string<br>*+2 more* | - | Public |
| **SetState** | `state`: string | - | Public |
| **SetStateFromTable** | `stateTable`: table | - | Public |
| **Show** | - | - | Public |

### ScriptEventManager

*9 methods*

| Method | Parameters | Returns | Protection |
|--------|------------|---------|------------|
| **AddFilterForEvent** | `name`: string<br>`event`: integer<br>`filterParameter`: variant | `success`: bool | Public |
| **RegisterForAllEvents** | `name`: string<br>`callback`: function | `ret`: bool | Public |
| **RegisterForEvent** | `name`: string<br>`event`: integer<br>`callback`: function<br>*+1 more* | `ret`: bool | Public |
| **RegisterForPostEffectsUpdate** | `name`: string<br>`minInterval`: integer<br>`callback`: function | `ret`: bool | Public |
| **RegisterForUpdate** | `name`: string<br>`minInterval`: integer<br>`callback`: function | `ret`: bool | Public |
| **UnregisterForAllEvents** | `name`: string | `ret`: bool | Public |
| **UnregisterForEvent** | `name`: string<br>`event`: integer | `ret`: bool | Public |
| **UnregisterForPostEffectsUpdate** | `name`: string | `ret`: bool | Public |
| **UnregisterForUpdate** | `name`: string | `ret`: bool | Public |


---

## Alphabetical Function Index

Complete alphabetical listing of all 4124 Game API functions.

### A

`AbandonQuest` | `AbbreviateNumber` | `AbortVideoPlayback` | `AcceptActivityFindReplacementNotification`
`AcceptAgentChat` | `AcceptDuel` | `AcceptFriendRequest` | `AcceptGroupInvite`
`AcceptGuildApplication` | `AcceptGuildInvite` | `AcceptLFGReadyCheckNotification` | `AcceptOfferedQuest`
`AcceptResurrect` | `AcceptSharedQuest` | `AcceptTribute` | `AcceptWorldEventInvite`
`ActionSlotHasActivationHighlight` | `ActionSlotHasCostFailure` | `ActionSlotHasEffectiveSlotAbilityData` | `ActionSlotHasFallingFailure`
`ActionSlotHasLeapKeepTargetFailure` | `ActionSlotHasMountedFailure` | `ActionSlotHasNonCostStateFailure` | `ActionSlotHasRangeFailure`
`ActionSlotHasReincarnatingFailure` | `ActionSlotHasRequirementFailure` | `ActionSlotHasStatusEffectFailure` | `ActionSlotHasSubzoneFailure`
`ActionSlotHasSwimmingFailure` | `ActionSlotHasTargetFailure` | `ActionSlotHasWeaponSlotFailure` | `ActivateSkillLinesInAllocationRequest`
`AddActiveChangeToAllocationRequest` | `AddActivityFinderSetSearchEntry` | `AddActivityFinderSpecificSearchEntry` | `AddBackgroundListFilterEntry`
`AddBackgroundListFilterEntry64` | `AddBackgroundListFilterType` | `AddChatContainer` | `AddChatContainerTab`
`AddHotbarSlotChangeToAllocationRequest` | `AddHotbarSlotToChampionPurchaseRequest` | `AddHousingPermission` | `AddIgnore`
`AddItemToConsumeAttunableStationsMessage` | `AddItemToDeconstructMessage` | `AddMapAntiquityDigSitePins` | `AddMapPin`
`AddMapQuestPins` | `AddMapZoneStoryPins` | `AddPartialPendingNarrationText` | `AddPassiveChangeToAllocationRequest`
`AddPendingGuildRank` | `AddPendingNarrationText` | `AddSCTCloudOffset` | `AddSCTSlotAllowedSourceType`
`AddSCTSlotAllowedTargetType` | `AddSCTSlotExcludedSourceType` | `AddSCTSlotExcludedTargetType` | `AddSkillToChampionPurchaseRequest`
`AddToGuildBlacklistByDisplayName` | `AddTrainingToAllocationRequest` | `AgreeToEULA` | `ApplyChangesToPreviewCollectionShown`
`ApplyPendingDyes` | `ApplyPendingHeraldryChanges` | `ApplySettings` | `AreAllEnchantingRunesKnown`
`AreAllPromotionalEventCampaignRewardsClaimed` | `AreAllTradingHouseSearchResultsPurchased` | `AreAllZoneStoryActivitiesCompleteForZoneCompletionType` | `AreAntiquitySkillLinesDiscovered`
`AreAnyItemsStolen` | `AreCompanionSkillsInitialized` | `AreDyeChannelsDyeableForOutfitSlotData` | `AreHousingPermissionsChangesPending`
`AreId64sEqual` | `AreItemDyeChannelsDyeable` | `AreKeyboardBindingsSupportedInGamepadUI` | `ArePlayerWeaponsSheathed`
`AreRestyleSlotDyeChannelsDyeable` | `AreSkillsInitialized` | `AreUnitsCurrentlyAllied` | `AreUnitsEqual`
`AreUserAddOnsSupported` | `AssignCampaignToPlayer` | `AssignTargetMarkerToReticleTarget` | `AssistedQuestPinForTracked`

### B

`BCP47StringForZoOfficialLanguage` | `BeginGroupElection` | `BeginItemPreviewSpin` | `BeginRestyling`
`BestowActivityTypeGatingQuest` | `BestowSubclassingQuest` | `BindItem` | `BitAnd`
`BitLShift` | `BitNot` | `BitOr` | `BitRShift`
`BitXor` | `BlockAutomaticInputModeChange` | `BroadcastAddOnDataToGroup` | `BuyBagSpace`
`BuyBankSpace` | `BuyGuildSpecificItem` | `BuyStoreItem` | `BuybackItem`

### C

`CalculateCubicBezierEase` | `CameraZoomIn` | `CameraZoomOut` | `CanAbandonJournalQuest`
`CanAbilityBeUsedFromHotbar` | `CanAcceptActiveSpectacleEventQuest` | `CanAcquireCollectibleByDefId` | `CanAnyItemsBeStoredInCraftBag`
`CanBuyFromTradingHouse` | `CanCampaignBeAllianceLocked` | `CanChampionSkillTypeBeSlotted` | `CanChangeBattleLevelPreference`
`CanCollectibleBePreviewed` | `CanCombinationFragmentBeUnlocked` | `CanCommunicateWith` | `CanConvertItemStyle`
`CanCurrencyBeStoredInLocation` | `CanEditGuildRankPermission` | `CanEquippedItemBeShownInOutfitSlot` | `CanExitInstanceImmediately`
`CanFavoriteHouses` | `CanHousingEditorPlacementPreviewMarketProduct` | `CanInteractWithCrownCratesSystem` | `CanInteractWithItem`
`CanInventoryItemBePreviewed` | `CanItemBeConsumedByConsolidatedStation` | `CanItemBeDeconstructed` | `CanItemBeMarkedAsJunk`
`CanItemBePlayerLocked` | `CanItemBeRefined` | `CanItemBeRetraited` | `CanItemBeSmithingImproved`
`CanItemBeSmithingTraitResearched` | `CanItemBeUsedToLearn` | `CanItemBeVirtual` | `CanItemLinkBePreviewed`
`CanItemLinkBeTraitResearched` | `CanItemLinkBeUsedToLearn` | `CanItemLinkBeVirtual` | `CanItemTakeEnchantment`
`CanJumpToGroupMember` | `CanJumpToHouseFromCurrentLocation` | `CanJumpToPlayerInZone` | `CanKeepBeFastTravelledTo`
`CanLeaveCampaignQueue` | `CanLeaveCurrentLocationViaTeleport` | `CanLoadoutRoleBeEquippedByIndex` | `CanPerkBeSlottedInSlotForRole`
`CanPlayerChangeGroupDifficulty` | `CanPlayerUseCostumeDyeStamp` | `CanPlayerUseItemDyeStamp` | `CanPreviewMarketProduct`
`CanPreviewReward` | `CanQueueItemAttachment` | `CanQuickslotQuestItemById` | `CanRecommendHouses`
`CanRedoLastHousingEditorCommand` | `CanReplayLastInteractVO` | `CanRerollCurrentBuffSelectorOptions` | `CanRespawnAtKeep`
`CanScryForAntiquity` | `CanSellOnTradingHouse` | `CanSendLFMRequest` | `CanSiegeWeaponAim`
`CanSiegeWeaponFire` | `CanSiegeWeaponPackUp` | `CanSkipCurrentTributeTutorialStep` | `CanSmithingApparelPatternsBeCraftedHere`
`CanSmithingJewelryPatternsBeCraftedHere` | `CanSmithingSetPatternsBeCraftedHere` | `CanSmithingStyleBeUsedOnPattern` | `CanSmithingWeaponPatternsBeCraftedHere`
`CanSpecificSmithingItemSetPatternBeCraftedHere` | `CanSpinPreviewCharacter` | `CanStoreRepair` | `CanStowFurnitureItem`
`CanTrack` | `CanTryTakeAllMailAttachmentsInCategory` | `CanTutorialBeSeen` | `CanUndoLastHousingEditorCommand`
`CanUnitGainChampionPoints` | `CanUnitTrade` | `CanUpdateSelectedLFGRole` | `CanUseCollectibleDyeing`
`CanUseKeepRecallStone` | `CanUseQuestItem` | `CanUseQuestTool` | `CanUseStuck`
`CanUseSynergyAtIndex` | `CanWriteGuildChannel` | `CanZoneStoryContinueTrackingActivities` | `CanZoneStoryContinueTrackingActivitiesForCompletionType`
`CancelBuff` | `CancelCast` | `CancelCurrentVideoPlayback` | `CancelEditGroupListing`
`CancelFriendRequest` | `CancelGroupFinderFilterOptionsChanges` | `CancelGroupSearches` | `CancelKeepGuildClaimInteraction`
`CancelKeepGuildReleaseInteraction` | `CancelLogout` | `CancelMatchTradingHouseItemNames` | `CancelRequestJournalQuestConditionAssistance`
`CancelSmithingTraitResearch` | `CancelTradingHouseListing` | `CancelTradingHouseListingByItemUniqueId` | `CastGroupVote`
`ChallengeTargetToDuel` | `ChallengeTargetToTribute` | `ChangeRemoteTopLevel` | `ChargeItemWithSoulGem`
`CheckGuildKeepClaim` | `CheckGuildKeepRelease` | `CheckInventorySpaceAndWarn` | `CheckInventorySpaceSilently`
`CheckPlayerCanPerformCombinationAndWarn` | `ChooseAbilityProgressionMorph` | `ChooseEndlessDungeonBuff` | `ChooseSkillProgressionMorphSlot`
`ChromaApplyCustomEffectCellColor` | `ChromaApplyCustomEffectColumnColor` | `ChromaApplyCustomEffectFullColor` | `ChromaApplyCustomEffectId`
`ChromaApplyCustomEffectRowColor` | `ChromaClearHeadsetEffect` | `ChromaClearKeyboardEffect` | `ChromaClearKeypadEffect`
`ChromaClearMouseEffect` | `ChromaClearMousepadEffect` | `ChromaCreateHeadsetBreathingEffect` | `ChromaCreateHeadsetStaticEffect`
`ChromaCreateKeyboardBreathingEffect` | `ChromaCreateKeyboardReactiveEffect` | `ChromaCreateKeyboardSpectrumCyclingEffect` | `ChromaCreateKeyboardStaticEffect`
`ChromaCreateKeyboardWaveEffect` | `ChromaCreateKeypadBreathingEffect` | `ChromaCreateKeypadReactiveEffect` | `ChromaCreateKeypadSpectrumCyclingEffect`
`ChromaCreateKeypadStaticEffect` | `ChromaCreateKeypadWaveEffect` | `ChromaCreateMouseBreathingEffect` | `ChromaCreateMouseReactiveEffect`
`ChromaCreateMouseSpectrumCyclingEffect` | `ChromaCreateMouseStaticEffect` | `ChromaCreateMouseWaveEffect` | `ChromaCreateMousepadBreathingEffect`
`ChromaCreateMousepadSpectrumCyclingEffect` | `ChromaCreateMousepadStaticEffect` | `ChromaCreateMousepadWaveEffect` | `ChromaDeleteAllCustomEffectIds`
`ChromaDeleteCustomEffectById` | `ChromaFinalizeCustomEffect` | `ChromaGenerateCustomEffect` | `ChromaGetCustomEffectCellColor`
`ChromaGetCustomEffectDimensions` | `ChromaResetCustomEffectObject` | `ChromaSetCustomEffectCellActive` | `ChromaSetCustomEffectSingleColorBlendMode`
`ChromaSetCustomEffectSingleColorRGBA` | `ChromaSetCustomSingleColorFadingEffectUsesAlphaChannel` | `ChromaSetCustomSingleColorFadingEffectValue` | `ClaimCurrentDailyLoginReward`
`ClaimCurrentReturningPlayerDailyLoginReward` | `ClaimInteractionKeepForGuild` | `ClaimPendingLevelUpReward` | `ClearActiveActionRequiredTutorial`
`ClearActiveNarration` | `ClearActivityFinderSearch` | `ClearAllNarrationQueues` | `ClearAllOutfitSlotPreviewElementsFromPreviewCollection`
`ClearAllSynergyPriorityOverrides` | `ClearAllTradingHouseSearchTerms` | `ClearAutoMapNavigationTarget` | `ClearBindsForUnknownActions`
`ClearCollectibleCategoryNewStatuses` | `ClearCollectibleNewStatus` | `ClearCraftBagAutoTransferNotification` | `ClearCurrentItemPreviewCollection`
`ClearCursor` | `ClearEsoPlusFreeTrialNotification` | `ClearExpiringMarketCurrencyNotification` | `ClearGuildHasNewApplicationsNotification`
`ClearGuildHistoryCache` | `ClearHealthWarnings` | `ClearItemSetCollectionSlotNew` | `ClearLastSlottedItem`
`ClearMarketProductUnlockNotifications` | `ClearNarrationQueue` | `ClearOutfitSlotPreviewElementFromPreviewCollection` | `ClearPendingItemPurchase`
`ClearPlayerApplicationNotification` | `ClearPreviewingOutfitIndexInPreviewCollection` | `ClearQueuedMail` | `ClearSCTCloudOffsets`
`ClearSCTSlotAllowedSourceTypes` | `ClearSCTSlotAllowedTargetTypes` | `ClearSCTSlotExcludedSourceTypes` | `ClearSCTSlotExcludedTargetTypes`
`ClearSessionIgnores` | `ClearSynergyPriorityOverride` | `ClearTrackedPromotionalEventActivity` | `ClearTrackedZoneStory`
`ClearWarnConsoleAddOnMemoryLimit` | `ClearWarnConsoleAddOnSavedVariableLimit` | `CloseMailbox` | `CloseStore`
`CompareBagItemToCurrentlyEquipped` | `CompareId64ToNumber` | `CompareId64s` | `CompareItemLinkToCurrentlyEquipped`
`CompleteQuest` | `ComposeGuildRankPermissions` | `ComputeDepthAtWhichWorldHeightRendersAsUIHeight` | `ComputeDepthAtWhichWorldWidthRendersAsUIWidth`
`ComputeStringDistance` | `ConfirmCampaignEntry` | `ConfirmLogout` | `ConfirmPendingItemPurchase`
`ConvertHoldKeyPressToNonHold` | `ConvertItemGlyphTierRangeToRequiredLevelRange` | `ConvertKeyPressToHold` | `ConvertMouseButtonToKeyCode`
`CopyHousePermissions` | `CraftAlchemyItem` | `CraftEnchantingItem` | `CraftProvisionerItem`
`CraftSmithingItem` | `CreateBackgroundListFilter` | `CreateDefaultActionBind` | `CreateGuildHistoryRequest`
`CreateNewSCTCloud` | `CreateNewSCTEventVisualInfo` | `CreateNewSCTSlot`

### D

`DeactivateSkillLinesInAllocationRequest` | `DeclineActivityFindReplacementNotification` | `DeclineAgentChat` | `DeclineDuel`
`DeclineGroupInvite` | `DeclineGuildApplication` | `DeclineLFGReadyCheckNotification` | `DeclineResurrect`
`DeclineSharedQuest` | `DeclineTribute` | `DeclineWorldEventInvite` | `DecorateDisplayName`
`DecoratePlatformDisplayName` | `DeleteGift` | `DeleteMail` | `DeleteSavedVariablesForAddonIndex`
`DestroyAllJunk` | `DestroyBackgroundListFilter` | `DestroyGuildHistoryRequest` | `DestroyItem`
`DidCurrentBattlegroundRequestLFM` | `DidCurrentBattlegroundTeamWinOrTieRound` | `DidDeathCauseDurabilityDamage` | `DidLocalPlayerJoinBattlegroundInProgress`
`DisablePreviewMode` | `DisplayBankUpgrade` | `DoAllValidLevelUpRewardChoicesHaveSelections` | `DoBattlegroundContextsIntersect`
`DoesAbilityExist` | `DoesActivitySetHaveAvailablityRequirementList` | `DoesActivitySetHaveMMR` | `DoesActivitySetHaveRewardData`
`DoesActivitySetPassAvailablityRequirementList` | `DoesAlchemyItemHaveKnownEncodedTrait` | `DoesAlchemyItemHaveKnownTrait` | `DoesAntiquityHaveLead`
`DoesAntiquityNeedCombination` | `DoesAntiquityPassVisibilityRequirements` | `DoesAntiquityRequireLead` | `DoesAnyMarketProductPresentationMatchFilter`
`DoesBagHaveSpaceFor` | `DoesBagHaveSpaceForItemLink` | `DoesBankHoldCurrency` | `DoesBattlegroundHaveLimitedPlayerLives`
`DoesBattlegroundHaveRounds` | `DoesBattlegroundHaveTeam` | `DoesCampaignHaveEmperor` | `DoesChampionSkillHaveJumpPoints`
`DoesCollectibleCategoryContainAnyCollectiblesWithUserFlags` | `DoesCollectibleCategoryContainSlottableCollectibles` | `DoesCollectibleCategoryTypeHaveDefault` | `DoesCollectibleHaveVisibleAppearance`
`DoesCurrencyAmountMeetConfirmationThreshold` | `DoesCurrentBattlegroundImpactMMR` | `DoesCurrentCampaignRulesetAllowChampionPoints` | `DoesCurrentLanguageRequireIME`
`DoesCurrentMapMatchMapForPlayerLocation` | `DoesCurrentMapShowPlayerWorld` | `DoesCurrentZoneAllowBattleLevelScaling` | `DoesCurrentZoneAllowScalingByLevel`
`DoesCurrentZoneHaveTelvarStoneBehavior` | `DoesESOPlusUnlockCollectible` | `DoesFurnitureThemeShowInBrowser` | `DoesGameHaveFocus`
`DoesGroupFinderFilterAutoAcceptRequests` | `DoesGroupFinderFilterRequireChampion` | `DoesGroupFinderFilterRequireEnforceRoles` | `DoesGroupFinderFilterRequireInviteCode`
`DoesGroupFinderFilterRequireVOIP` | `DoesGroupFinderSearchListingAutoAcceptRequests` | `DoesGroupFinderSearchListingEnforceRoles` | `DoesGroupFinderSearchListingRequireChampion`
`DoesGroupFinderSearchListingRequireInviteCode` | `DoesGroupFinderSearchListingRequireVOIP` | `DoesGroupFinderUserTypeGroupListingAutoAcceptRequests` | `DoesGroupFinderUserTypeGroupListingDesiredRolesMatchAttainedRoles`
`DoesGroupFinderUserTypeGroupListingEnforceRoles` | `DoesGroupFinderUserTypeGroupListingRequireChampion` | `DoesGroupFinderUserTypeGroupListingRequireDLC` | `DoesGroupFinderUserTypeGroupListingRequireInviteCode`
`DoesGroupFinderUserTypeGroupListingRequireVOIP` | `DoesGroupMeetActivityLevelRequirements` | `DoesGroupModificationRequireVote` | `DoesGuildDataHaveInitializedAttributes`
`DoesGuildHaveActivityAttribute` | `DoesGuildHaveClaimedKeep` | `DoesGuildHaveNewApplicationsNotification` | `DoesGuildHavePrivilege`
`DoesGuildHaveRoleAttribute` | `DoesGuildHistoryEventCategoryHaveUpToDateEvents` | `DoesGuildHistoryHaveOutstandingRequest` | `DoesGuildRankHavePermission`
`DoesHistoryRequireMapRebuild` | `DoesHousingUserGroupHaveAccess` | `DoesInventoryContainEmptySoulGem` | `DoesItemFulfillJournalQuestCondition`
`DoesItemHaveDurability` | `DoesItemLinkFinishQuest` | `DoesItemLinkFulfillJournalQuestCondition` | `DoesItemLinkHaveArmorDecay`
`DoesItemLinkHaveEnchantCharges` | `DoesItemLinkStartQuest` | `DoesItemMatchSmithingMaterialTraitAndStyle` | `DoesItemSetCollectionsHaveAnyNewPieces`
`DoesJournalQuestConditionHavePosition` | `DoesKeepPassCompassVisibilitySubzoneCheck` | `DoesKeepTypeHaveSiegeLimit` | `DoesKillingAttackHaveAttacker`
`DoesMarketProductCategoryContainFilteredProducts` | `DoesMarketProductCategoryOrSubcategoriesContainFilteredProducts` | `DoesMarketProductMatchFilter` | `DoesObjectiveExist`
`DoesObjectivePassCompassVisibilitySubzoneCheck` | `DoesPlatformAllowConfiguringAutomaticInputChanging` | `DoesPlatformStoreUseExternalLinks` | `DoesPlatformSupportCodeRedemption`
`DoesPlatformSupportDisablingShareFeatures` | `DoesPlatformSupportFramerateCapInMenus` | `DoesPlatformSupportGraphicSetting` | `DoesPlatformSupportModBrowser`
`DoesPlatformSupportScreenDimAndResolutionDrop` | `DoesPlatformSupportSpatialSound` | `DoesPlatformSupportSpatialSoundQuality` | `DoesPlayerHaveGuildPermission`
`DoesPlayerHaveLockpickingCompanionBonus` | `DoesPlayerHaveRunesForEnchanting` | `DoesPlayerMeetActivityLevelRequirements` | `DoesPlayerMeetCampaignRequirements`
`DoesSCTSlotAllowSourceType` | `DoesSCTSlotAllowTargetType` | `DoesSCTSlotExcludeSourceType` | `DoesSCTSlotExcludeTargetType`
`DoesSmithingTypeIgnoreStyleItems` | `DoesSystemSupportConsoleEnhancedRenderQuality` | `DoesSystemSupportHDR` | `DoesTributeCardChooseOneMechanic`
`DoesTributeCardHaveMechanicType` | `DoesTributeCardHaveSetbackMechanic` | `DoesTributeCardHaveTriggerMechanic` | `DoesTributeCardTaunt`
`DoesTributePatronSkipNeutralFavorState` | `DoesTributeSkipPatronDrafting` | `DoesUnitExist` | `DoesUnitHaveResurrectPending`
`DoesZoneCompletionTypeInZoneHaveBranchesWithDifferentLengths` | `DumpGuildHistoryChunkInformation`

### E

`EnablePreviewMode` | `EnchantItem` | `EndCurrentItemPreview` | `EndHeraldryCustomization`
`EndInteraction` | `EndItemPreviewSpin` | `EndLooting` | `EndPendingInteraction`
`EndRestyling` | `EquipOutfit` | `ExecuteChatCommand` | `ExecuteTradingHouseSearch`
`ExitInstanceImmediately`

### F

`FastTravelToNode` | `FinalizePartialPendingNarrationText` | `FindActionSlotMatchingItem` | `FindActionSlotMatchingSimpleAction`
`FindFirstEmptySlotInBag` | `FlagMarketAnnouncementSeen` | `FlagReturningPlayerAnnouncementSeen` | `FlashHealthWarningStage`
`FormatAchievementLinkTimestamp` | `FormatFloatRelevantFraction` | `FormatIntegerWithDigitGrouping` | `FormatTimeMilliseconds`
`FormatTimeSeconds`

### G

`GemifyItem` | `GenerateAvAObjectiveConditionTooltipLine` | `GenerateCraftedAbilityScriptSlotDescriptionForAbilityDescription` | `GenerateCumulativeMedalInfoForScoreboardEntry`
`GenerateMapPingTooltipLine` | `GenerateMasterWritBaseText` | `GenerateMasterWritRewardText` | `GenerateQuestConditionTooltipLine`
`GenerateQuestEndingTooltipLine` | `GenerateQuestNameTooltipLine` | `GenerateUnitNameTooltipLine` | `GetAPIVersion`
`GetAbilityAdvancedStatAndEffectByIndex` | `GetAbilityAngleDistance` | `GetAbilityBaseCostInfo` | `GetAbilityBuffType`
`GetAbilityCastInfo` | `GetAbilityCooldown` | `GetAbilityCost` | `GetAbilityCostPerTick`
`GetAbilityCraftedAbilityId` | `GetAbilityDerivedStatAndEffectByIndex` | `GetAbilityDescription` | `GetAbilityDescriptionHeader`
`GetAbilityDuration` | `GetAbilityEffectDescription` | `GetAbilityEndlessDungeonBuffBucketType` | `GetAbilityEndlessDungeonBuffType`
`GetAbilityFrequencyMS` | `GetAbilityFxOverrideProgressionId` | `GetAbilityIcon` | `GetAbilityIdByIndex`
`GetAbilityIdForCraftedAbilityId` | `GetAbilityIdForHotbarSlotAtIndex` | `GetAbilityIdFromLink` | `GetAbilityInfoByIndex`
`GetAbilityLink` | `GetAbilityMundusStoneType` | `GetAbilityName` | `GetAbilityNewEffectLines`
`GetAbilityNumAdvancedStats` | `GetAbilityNumDerivedStats` | `GetAbilityProgressionAbilityId` | `GetAbilityProgressionAbilityInfo`
`GetAbilityProgressionInfo` | `GetAbilityProgressionRankFromAbilityId` | `GetAbilityProgressionXPInfo` | `GetAbilityProgressionXPInfoFromAbilityId`
`GetAbilityRadius` | `GetAbilityRange` | `GetAbilityRoles` | `GetAbilityTargetDescription`
`GetAbilityUpgradeLines` | `GetAchievementCategoryGamepadIcon` | `GetAchievementCategoryInfo` | `GetAchievementCategoryKeyboardIcons`
`GetAchievementCriterion` | `GetAchievementId` | `GetAchievementIdFromLink` | `GetAchievementInfo`
`GetAchievementItemLink` | `GetAchievementLink` | `GetAchievementLinkedBookCollectionId` | `GetAchievementName`
`GetAchievementNameFromLink` | `GetAchievementNumCriteria` | `GetAchievementNumRewards` | `GetAchievementPersistenceLevel`
`GetAchievementProgress` | `GetAchievementProgressFromLinkData` | `GetAchievementRewardCollectible` | `GetAchievementRewardDye`
`GetAchievementRewardItem` | `GetAchievementRewardPoints` | `GetAchievementRewardTitle` | `GetAchievementRewardTributeCardUpgradeInfo`
`GetAchievementSubCategoryInfo` | `GetAchievementTimestamp` | `GetAchievementsSearchResult` | `GetActionBarLockedReason`
`GetActionBindingInfo` | `GetActionDefaultBindingInfo` | `GetActionIndicesFromName` | `GetActionInfo`
`GetActionLayerCategoryInfo` | `GetActionLayerInfo` | `GetActionLayerNameByIndex` | `GetActionNameFromKey`
`GetActionSlotEffectDuration` | `GetActionSlotEffectStackCount` | `GetActionSlotEffectTimeRemaining` | `GetActionSlotUnlockText`
`GetActiveActionLayerIndex` | `GetActiveAnnouncementMarketProductListingsForHouseTemplate` | `GetActiveChapterUpgradeMarketProductListings` | `GetActiveCollectibleByType`
`GetActiveCombatTipInfo` | `GetActiveCompanionDefId` | `GetActiveCompanionLevelForExperiencePoints` | `GetActiveCompanionLevelInfo`
`GetActiveCompanionRapport` | `GetActiveCompanionRapportLevel` | `GetActiveCompanionRapportLevelDescription` | `GetActiveConsolidatedSmithingItemSetId`
`GetActiveCutsceneVideoDataId` | `GetActiveCutsceneVideoPath` | `GetActiveHotbarCategory` | `GetActiveLoadoutRoleIndex`
`GetActiveMarketProductListingsForHouseTemplate` | `GetActiveProgressionSkillAbilityFxOverrideCollectibleId` | `GetActivePromotionalEventCampaignKey` | `GetActiveSpectacleEventActivityFinderBackgroundGamepad`
`GetActiveSpectacleEventActivityFinderBackgroundKeyboard` | `GetActiveSpectacleEventDisplayName` | `GetActiveSpectacleEventFeaturedAchievementsId` | `GetActiveSpectacleEventId`
`GetActiveSpectacleEventIdsForPOI` | `GetActiveSpectacleEventIdsForWhichPOIIsPrimary` | `GetActiveSpectacleEventIdsForZoneIndex` | `GetActiveSpectacleEventLootIconGamepad`
`GetActiveSpectacleEventLootIconKeyboard` | `GetActiveSpectacleEventNumFeaturedAchievements` | `GetActiveSpectacleEventPhaseCompleteNotificationMessage` | `GetActiveSpectacleEventPhaseDescription`
`GetActiveSpectacleEventPhaseDisplayName` | `GetActiveSpectacleEventPhaseInfo` | `GetActiveSpectacleEventPhaseProgressPercentage` | `GetActiveSpectacleEventPhaseStartedNotificationMessage`
`GetActiveSpectacleEventQuestIndex` | `GetActiveTributeCampaignKey` | `GetActiveTributeCampaignLeaderboardTierRewardListId` | `GetActiveTributeCampaignTierRewardListId`
`GetActiveTributeCampaignTimeRemainingS` | `GetActiveTributePlayerPerspective` | `GetActiveWeaponPairInfo` | `GetActivityAverageRoleTime`
`GetActivityBattlegroundId` | `GetActivityFindReplacementNotificationInfo` | `GetActivityFinderStatus` | `GetActivityGamepadDescriptionTexture`
`GetActivityGroupType` | `GetActivityIdByTypeAndIndex` | `GetActivityInfo` | `GetActivityKeyboardDescriptionTextures`
`GetActivityName` | `GetActivityRequestIds` | `GetActivitySetActivityIdByIndex` | `GetActivitySetGamepadDescriptionTexture`
`GetActivitySetIcon` | `GetActivitySetIdByTypeAndIndex` | `GetActivitySetInfo` | `GetActivitySetKeyboardDescriptionTextures`
`GetActivitySetRewardData` | `GetActivityType` | `GetActivityTypeAndIndex` | `GetActivityTypeGatingQuest`
`GetActivityZoneId` | `GetAddCurrencyRewardInfo` | `GetAdditionalLevelUpUnlockDescription` | `GetAdditionalLevelUpUnlockDisplayName`
`GetAdditionalLevelUpUnlockGamepadIcon` | `GetAdditionalLevelUpUnlockKeyboardIcon` | `GetAdvancedStatCategoryInfo` | `GetAdvancedStatInfo`
`GetAdvancedStatValue` | `GetAdvancedStatsCategoryId` | `GetAgentChatRequestInfo` | `GetAlchemyItemTraits`
`GetAlchemyResultInspiration` | `GetAlchemyResultQuantity` | `GetAlchemyResultingItemIdIfKnown` | `GetAlchemyResultingItemInfo`
`GetAlchemyResultingItemLink` | `GetAllUnitAttributeVisualizerEffectInfo` | `GetAllianceLockPendingNotificationInfo` | `GetAllianceName`
`GetAllyUnitBlockState` | `GetAmountRepairKitWouldRepairItem` | `GetAmountSoulGemWouldChargeItem` | `GetAntiquityCategoryGamepadIcon`
`GetAntiquityCategoryId` | `GetAntiquityCategoryKeyboardIcons` | `GetAntiquityCategoryName` | `GetAntiquityCategoryOrder`
`GetAntiquityCategoryParentId` | `GetAntiquityDifficulty` | `GetAntiquityDiggingSkillLineId` | `GetAntiquityIcon`
`GetAntiquityLeadIcon` | `GetAntiquityLeadTimeRemainingSeconds` | `GetAntiquityLoreEntry` | `GetAntiquityName`
`GetAntiquityQuality` | `GetAntiquityRewardId` | `GetAntiquityScryingSkillLineId` | `GetAntiquityScryingToolCollectibleId`
`GetAntiquitySearchResult` | `GetAntiquitySetAntiquityId` | `GetAntiquitySetIcon` | `GetAntiquitySetId`
`GetAntiquitySetName` | `GetAntiquitySetQuality` | `GetAntiquitySetRewardId` | `GetAntiquityZoneId`
`GetApplyCostForIndividualOutfitSlot` | `GetArmoryBuildAttributeSpentPoints` | `GetArmoryBuildChampionSpentPointsByDiscipline` | `GetArmoryBuildCurseType`
`GetArmoryBuildEquipSlotInfo` | `GetArmoryBuildEquippedOutfitIndex` | `GetArmoryBuildIconIndex` | `GetArmoryBuildName`
`GetArmoryBuildPrimaryMundusStone` | `GetArmoryBuildSecondaryMundusStone` | `GetArmoryBuildSkillsTotalSpentPoints` | `GetArmoryBuildSlotBoundId`
`GetArmoryOperationsCooldownDurationMs` | `GetArmoryOperationsCooldownRemaining` | `GetArtifactReturnObjectiveOwner` | `GetArtifactScoreBonusAbilityId`
`GetArtifactScrollObjectiveOriginalOwningAlliance` | `GetArtificialEffectInfo` | `GetArtificialEffectTooltipText` | `GetAssignableAbilityBarStartAndEndSlots`
`GetAssignableChampionBarStartAndEndSlots` | `GetAssignedCampaignId` | `GetAssignedSlotFromSkillAbility` | `GetAssociatedAchievementIdForZoneCompletionType`
`GetAttachedItemInfo` | `GetAttachedItemLink` | `GetAttributeDerivedStatPerPointValue` | `GetAttributePointsAwardedForLevel`
`GetAttributeRespecGoldCost` | `GetAttributeSpentPoints` | `GetAttributeUnspentPoints` | `GetAutoMapNavigationCommonZoomOutMapIndex`
`GetAutoMapNavigationNormalizedPositionForCurrentMap` | `GetAvAArtifactScore` | `GetAvAKeepScore` | `GetAvAKeepsHeld`
`GetAvARankIcon` | `GetAvARankName` | `GetAvARankProgress` | `GetAvailableSkillBuildIdByIndex`
`GetAvailableSkillPoints` | `GetBackgroundListFilterResult` | `GetBackgroundListFilterResult64` | `GetBagForCollectible`
`GetBagSize` | `GetBagUseableSize` | `GetBankingBag` | `GetBattlegroundCumulativeNumEarnedMedalsById`
`GetBattlegroundCumulativeScoreForScoreboardEntryByType` | `GetBattlegroundDescription` | `GetBattlegroundGameType` | `GetBattlegroundInfoTexture`
`GetBattlegroundLeaderboardEntryInfo` | `GetBattlegroundLeaderboardLocalPlayerInfo` | `GetBattlegroundLeaderboardsSchedule` | `GetBattlegroundMaxPlayerLives`
`GetBattlegroundMedalIdByIndex` | `GetBattlegroundName` | `GetBattlegroundNumRounds` | `GetBattlegroundNumTeams`
`GetBattlegroundNumUsedMedals` | `GetBattlegroundResultForTeam` | `GetBattlegroundRoundMaxActiveSequencedObjectives` | `GetBattlegroundRoundNearingVictoryPercent`
`GetBattlegroundTeamByIndex` | `GetBattlegroundTeamName` | `GetBattlegroundTeamSize` | `GetBindingIndicesFromKeys`
`GetBookMediumFontInfo` | `GetBookMediumInfo` | `GetBounty` | `GetBountyDecayInfo`
`GetBuybackItemInfo` | `GetBuybackItemLink` | `GetCVar` | `GetCadwellProgressionLevel`
`GetCadwellZoneInfo` | `GetCadwellZonePOIInfo` | `GetCampaignAbdicationStatus` | `GetCampaignAllianceLeaderboardEntryInfo`
`GetCampaignAlliancePotentialScore` | `GetCampaignAllianceScore` | `GetCampaignEmperorInfo` | `GetCampaignEmperorReignDuration`
`GetCampaignHistoryWindow` | `GetCampaignHoldingScoreValues` | `GetCampaignHoldings` | `GetCampaignKeyForNextReturningPlayerCampaign`
`GetCampaignLeaderboardEntryInfo` | `GetCampaignLeaderboardMaxRank` | `GetCampaignMatchResultFromHistoryByMatchIndex` | `GetCampaignName`
`GetCampaignPlacementRank` | `GetCampaignQueueConfirmationDuration` | `GetCampaignQueueEntry` | `GetCampaignQueuePosition`
`GetCampaignQueueRemainingConfirmationSeconds` | `GetCampaignQueueState` | `GetCampaignReassignCooldown` | `GetCampaignReassignCost`
`GetCampaignReassignInitialCooldown` | `GetCampaignRulesetDescription` | `GetCampaignRulesetDurationInSeconds` | `GetCampaignRulesetId`
`GetCampaignRulesetImperialKeepId` | `GetCampaignRulesetName` | `GetCampaignRulesetNumImperialKeeps` | `GetCampaignRulesetType`
`GetCampaignRulsetMinEmperorAlliancePoints` | `GetCampaignSequenceId` | `GetCampaignUnassignCooldown` | `GetCampaignUnassignCost`
`GetCampaignUnassignInitialCooldown` | `GetCampaignUnderdogLeaderAlliance` | `GetCaptureAreaObjectiveLastInfluenceState` | `GetCaptureAreaObjectiveOwner`
`GetCaptureFlagObjectiveOriginalOwningAlliance` | `GetCarryableObjectiveHoldingAllianceInfo` | `GetCarryableObjectiveHoldingCharacterInfo` | `GetCarryableObjectiveLastHoldingCharacterInfo`
`GetCategoryIndicesFromMarketProductPresentation` | `GetCategoryInfoFromAchievementId` | `GetCategoryInfoFromCollectibleCategoryId` | `GetCategoryInfoFromCollectibleId`
`GetChallengeLeaderboardEntryInfo` | `GetChallengeOfTheWeekLeaderboardEntryInfo` | `GetChamberState` | `GetChampionAbilityId`
`GetChampionClusterBackgroundTexture` | `GetChampionClusterName` | `GetChampionClusterRootOffset` | `GetChampionClusterSkillIds`
`GetChampionDisciplineId` | `GetChampionDisciplineName` | `GetChampionDisciplineSelectedZoomedOutOverlay` | `GetChampionDisciplineType`
`GetChampionDisciplineZoomedInBackground` | `GetChampionDisciplineZoomedOutBackground` | `GetChampionPointPoolForRank` | `GetChampionPointsPlayerProgressionCap`
`GetChampionPurchaseAvailability` | `GetChampionRespecCost` | `GetChampionSkillCurrentBonusText` | `GetChampionSkillDescription`
`GetChampionSkillId` | `GetChampionSkillJumpPoints` | `GetChampionSkillLinkIds` | `GetChampionSkillMaxPoints`
`GetChampionSkillName` | `GetChampionSkillPosition` | `GetChampionSkillType` | `GetChanceToForceLock`
`GetChannelCategoryFromChannel` | `GetChapterBasicRewardInfo` | `GetChapterCollectibleId` | `GetChapterEnumFromUpgradeId`
`GetChapterMarketBackgroundFileImage` | `GetChapterOverrideDisplayName` | `GetChapterPreOrdereRewardInfo` | `GetChapterPrePurchaseRewardInfo`
`GetChapterReleaseDateString` | `GetChapterSummary` | `GetCharIdForCompletedAchievement` | `GetCharacterInfo`
`GetCharacterNameById` | `GetChargeInfoForItem` | `GetChatCategoryColor` | `GetChatChannelId`
`GetChatContainerColors` | `GetChatContainerTabInfo` | `GetChatFontSize` | `GetChatterData`
`GetChatterFarewell` | `GetChatterGreeting` | `GetChatterOption` | `GetChatterOptionCount`
`GetChatterOptionWaypoints` | `GetChoiceRewardDisplayName` | `GetChoiceRewardIcon` | `GetChoiceRewardListId`
`GetChromaKeyboardCellByChromaKeyboardKey` | `GetChromaKeyboardKeyByZoGuiKey` | `GetChromaMouseCellByLED` | `GetChromaMousepadCellByLED`
`GetClaimedKeepGuildName` | `GetClassAccessCollectibleId` | `GetClassIdByIndex` | `GetClassIndexById`
`GetClassInfo` | `GetClassName` | `GetClubMatchResultFromHistoryByIndex` | `GetClubMatchResultFromHistoryByMatchNumber`
`GetCollectibleAsFurniturePreviewActionDisplayName` | `GetCollectibleAsFurniturePreviewVariationDisplayName` | `GetCollectibleAssociatedQuestState` | `GetCollectibleBlockReason`
`GetCollectibleCategoryGamepadIcon` | `GetCollectibleCategoryId` | `GetCollectibleCategoryInfo` | `GetCollectibleCategoryKeyboardIcons`
`GetCollectibleCategoryNameByCategoryId` | `GetCollectibleCategoryNameByCollectibleId` | `GetCollectibleCategorySortOrder` | `GetCollectibleCategorySpecialization`
`GetCollectibleCategoryType` | `GetCollectibleCategoryTypeFromLink` | `GetCollectibleCooldownAndDuration` | `GetCollectibleDefaultNickname`
`GetCollectibleDescription` | `GetCollectibleForBag` | `GetCollectibleFurnishingLimitType` | `GetCollectibleFurnitureDataId`
`GetCollectibleFurnitureDataIdForPreview` | `GetCollectibleGamepadBackgroundImage` | `GetCollectibleHelpIndices` | `GetCollectibleHideMode`
`GetCollectibleHint` | `GetCollectibleIcon` | `GetCollectibleId` | `GetCollectibleIdForHouse`
`GetCollectibleIdForZone` | `GetCollectibleIdFromFurnitureId` | `GetCollectibleIdFromLink` | `GetCollectibleIdFromType`
`GetCollectibleInfo` | `GetCollectibleKeyboardBackgroundImage` | `GetCollectibleLink` | `GetCollectibleLinkedAchievement`
`GetCollectibleName` | `GetCollectibleNickname` | `GetCollectibleNotificationInfo` | `GetCollectiblePersonalityOverridenEmoteDisplayNames`
`GetCollectiblePersonalityOverridenEmoteSlashCommandNames` | `GetCollectiblePlayerFxOverrideAbilityType` | `GetCollectiblePlayerFxOverrideType` | `GetCollectiblePlayerFxWhileHarvestingType`
`GetCollectiblePreviewActionDisplayName` | `GetCollectiblePreviewVariationDisplayName` | `GetCollectibleQuestPreviewInfo` | `GetCollectibleReferenceId`
`GetCollectibleRestrictionsByType` | `GetCollectibleRewardCollectibleId` | `GetCollectibleSortOrder` | `GetCollectibleSubCategoryInfo`
`GetCollectibleTagInfo` | `GetCollectibleUnlockStateById` | `GetCollectibleUserFlags` | `GetCollectiblesSearchResult`
`GetCombinationCollectibleComponentId` | `GetCombinationDescription` | `GetCombinationNonFragmentComponentCollectibleIds` | `GetCombinationNumCollectibleComponents`
`GetCombinationNumNonFragmentCollectibleComponents` | `GetCombinationNumUnlockedCollectibles` | `GetCombinationUnlockedCollectibleId` | `GetCompanionAbilityId`
`GetCompanionAbilityRankRequired` | `GetCompanionCollectibleId` | `GetCompanionGender` | `GetCompanionIntroQuestId`
`GetCompanionName` | `GetCompanionNumSlotsUnlockedForLevel` | `GetCompanionPassivePerkAbilityId` | `GetCompanionRace`
`GetCompanionSkillLineDynamicInfo` | `GetCompanionSkillLineId` | `GetCompanionSkillLineNameById` | `GetCompanionSkillLineXPInfo`
`GetCompanionUnitTagByGroupUnitTag` | `GetCompletedQuestInfo` | `GetCompletedQuestLocationInfo` | `GetCon`
`GetConsolidatedSmithingItemSetIdByIndex` | `GetConsolidatedSmithingItemSetSearchResult` | `GetCostToCraftAlchemyItem` | `GetCostToCraftEnchantingItem`
`GetCostToCraftProvisionerItem` | `GetCostToCraftSmithingItem` | `GetCostToScribeScripts` | `GetCraftedAbilityAcquireHint`
`GetCraftedAbilityActiveScriptIds` | `GetCraftedAbilityDescription` | `GetCraftedAbilityDisplayName` | `GetCraftedAbilityIcon`
`GetCraftedAbilityIdAtIndex` | `GetCraftedAbilityIdsFromLink` | `GetCraftedAbilityLink` | `GetCraftedAbilityRepresentativeAbilityId`
`GetCraftedAbilityScriptAcquireHint` | `GetCraftedAbilityScriptDescription` | `GetCraftedAbilityScriptDisplayName` | `GetCraftedAbilityScriptGeneralDescription`
`GetCraftedAbilityScriptIcon` | `GetCraftedAbilityScriptScribingSlot` | `GetCraftedAbilityScriptSelectionOverride` | `GetCraftedAbilitySkillCraftedAbilityId`
`GetCraftingInteractionMode` | `GetCraftingInteractionType` | `GetCraftingSkillName` | `GetCriticalStrikeChance`
`GetCrownCrateCardTextures` | `GetCrownCrateCount` | `GetCrownCrateDescription` | `GetCrownCrateIcon`
`GetCrownCrateNPCBoneWorldPosition` | `GetCrownCrateNPCCardThrowingBoneName` | `GetCrownCrateName` | `GetCrownCratePackNormalTexture`
`GetCrownCrateRewardCrateId` | `GetCrownCrateRewardInfo` | `GetCrownCrateRewardItemLink` | `GetCrownCrateRewardProductReferenceData`
`GetCrownCrateRewardStackCount` | `GetCrownCrateTierOrdering` | `GetCrownCrateTierQualityColor` | `GetCrownCrateTierReactionNPCAnimation`
`GetCrownCratesSystemState` | `GetCurrencyAcquiredUISound` | `GetCurrencyAmount` | `GetCurrencyDescription`
`GetCurrencyGamepadColor` | `GetCurrencyGamepadIcon` | `GetCurrencyKeyboardColor` | `GetCurrencyKeyboardIcon`
`GetCurrencyLootGamepadIcon` | `GetCurrencyLootKeyboardIcon` | `GetCurrencyName` | `GetCurrencyPlayerStoredLocation`
`GetCurrencyTransactUISound` | `GetCurrencyTypeFromMarketCurrencyType` | `GetCurrencyTypeFromRewardType` | `GetCurrentBackpackUpgrade`
`GetCurrentBankUpgrade` | `GetCurrentBattlegroundGameType` | `GetCurrentBattlegroundId` | `GetCurrentBattlegroundMMRLossReductionBonus`
`GetCurrentBattlegroundMMRReductionBonusTypes` | `GetCurrentBattlegroundRoundIndex` | `GetCurrentBattlegroundRoundMaxActiveSequencedObjectives` | `GetCurrentBattlegroundRoundNearingVictoryPercent`
`GetCurrentBattlegroundRoundResult` | `GetCurrentBattlegroundRoundsWonByTeam` | `GetCurrentBattlegroundScore` | `GetCurrentBattlegroundShutdownTimer`
`GetCurrentBattlegroundState` | `GetCurrentBattlegroundStateTimeRemaining` | `GetCurrentCampaignId` | `GetCurrentCampaignLoyaltyStreak`
`GetCurrentCampaignMatchStreak` | `GetCurrentChainedAbility` | `GetCurrentChapterUpgradeId` | `GetCurrentCharacterId`
`GetCurrentCharacterSlotsUpgrade` | `GetCurrentClubMatchStreak` | `GetCurrentCollectibleDyes` | `GetCurrentCrownCrateId`
`GetCurrentDailyLoginMonth` | `GetCurrentGroupFinderUserType` | `GetCurrentHouseOwner` | `GetCurrentHousePopulation`
`GetCurrentHousePopulationCap` | `GetCurrentHousePreviewTemplateId` | `GetCurrentHouseTourListingCollectibleId` | `GetCurrentHouseTourListingFurnitureCount`
`GetCurrentHouseTourListingHouseId` | `GetCurrentHouseTourListingNickname` | `GetCurrentHouseTourListingOwnerDisplayName` | `GetCurrentHouseTourListingTags`
`GetCurrentHousingEditorHistoryCommandIndex` | `GetCurrentItemDyes` | `GetCurrentLFGActivityId` | `GetCurrentMapId`
`GetCurrentMapIndex` | `GetCurrentMapZoneIndex` | `GetCurrentParticipatingRaidId` | `GetCurrentQuickslot`
`GetCurrentRaidDeaths` | `GetCurrentRaidLifeScoreBonus` | `GetCurrentRaidScore` | `GetCurrentRaidStartingReviveCounters`
`GetCurrentRecipeIngredientCount` | `GetCurrentSmithingMaterialItemCount` | `GetCurrentSmithingStyleItemCount` | `GetCurrentSmithingTraitItemCount`
`GetCurrentSubZonePOIIndices` | `GetCurrentSynergyInfo` | `GetCurrentTitleIndex` | `GetCurrentTradingHouseGuildDetails`
`GetCurrentZoneDungeonDifficulty` | `GetCurrentZoneHouseId` | `GetCurrentZoneLevelScalingConstraints` | `GetCursorAbilityId`
`GetCursorBagId` | `GetCursorChampionSkillId` | `GetCursorCollectibleId` | `GetCursorContentType`
`GetCursorCraftedAbilityId` | `GetCursorCraftedAbilityScriptId` | `GetCursorEmoteId` | `GetCursorQuestItemId`
`GetCursorQuickChatId` | `GetCursorSlotIndex` | `GetCursorVengeancePerkData` | `GetCyrodiilMapIndex`
`GetDaedricArtifactDisplayName` | `GetDaedricArtifactVisualType` | `GetDailyLoginClaimableRewardIndex` | `GetDailyLoginNumRewardsClaimedInMonth`
`GetDailyLoginRewardInfoForCurrentMonth` | `GetDate` | `GetDateElementsFromTimestamp` | `GetDateStringFromTimestamp`
`GetDayOfTheWeekIndex` | `GetDeathInfo` | `GetDeathRecapHintInfo` | `GetDefaultHouseTemplateIdForHouse`
`GetDefaultQuickChatMessage` | `GetDefaultQuickChatName` | `GetDefaultSkillBuildId` | `GetDefaultsForGuildLanguageAttributeFilter`
`GetDerivedStatValueForRoleAtIndex` | `GetDiffBetweenTimeStamps` | `GetDigPowerBarUIPosition` | `GetDigSiteNormalizedBorderPoints`
`GetDigSiteNormalizedCenterPosition` | `GetDigSpotAntiquityId` | `GetDigSpotDigPower` | `GetDigSpotDurability`
`GetDigSpotMinPowerPerSpender` | `GetDigSpotNumRadars` | `GetDigSpotStability` | `GetDigSpotStabilityTimeRemainingSeconds`
`GetDigToolUIKeybindPosition` | `GetDiggingActiveSkillIndices` | `GetDiggingAntiquityHasNewLoreEntryToShow` | `GetDigitGroupingSize`
`GetDisplayModes` | `GetDisplayName` | `GetDistrictOwnershipTelVarBonusPercent` | `GetDraftedPatronId`
`GetDuelInfo` | `GetDyeColorsById` | `GetDyeInfo` | `GetDyeInfoById`
`GetDyesSearchResult` | `GetDynamicChatChannelName` | `GetESOFullVersionString` | `GetESOVersionString`
`GetEULADetails` | `GetEarnedAchievementPoints` | `GetEdgeKeepBonusAbilityId` | `GetEffectiveAbilityIdForAbilityOnHotbar`
`GetEffectiveAbilityIdForAbilityOnHotbarForArmoryBuild` | `GetEligibleOutfitSlotsForCollectible` | `GetEmoteCategoryKeyboardIcons` | `GetEmoteCollectibleId`
`GetEmoteIndex` | `GetEmoteInfo` | `GetEmoteSlashNameByIndex` | `GetEmperorAllianceBonusAbilityId`
`GetEnchantProcAbilityId` | `GetEnchantSearchCategoryType` | `GetEnchantedItemResultingItemLink` | `GetEnchantingResultingItemInfo`
`GetEnchantingResultingItemLink` | `GetEnchantmentSearchCategories` | `GetEncounterLogVersion` | `GetEndlessDungeonActiveVerseAbility`
`GetEndlessDungeonBuffSelectorBucketTypeChoice` | `GetEndlessDungeonBuffSelectorRerollCost` | `GetEndlessDungeonCounterValue` | `GetEndlessDungeonDuoLeaderboardEntryInfo`
`GetEndlessDungeonFinalRunTimeMilliseconds` | `GetEndlessDungeonGroupType` | `GetEndlessDungeonLeaderboardLocalPlayerInfo` | `GetEndlessDungeonOfTheWeekDuoLeaderboardEntryInfo`
`GetEndlessDungeonOfTheWeekLeaderboardLocalPlayerInfo` | `GetEndlessDungeonOfTheWeekSoloLeaderboardEntryInfo` | `GetEndlessDungeonOfTheWeekTimes` | `GetEndlessDungeonScore`
`GetEndlessDungeonSoloLeaderboardEntryInfo` | `GetEndlessDungeonStartTimeMilliseconds` | `GetEnlightenedMultiplier` | `GetEnlightenedPool`
`GetEquipSlotForOutfitSlot` | `GetEquipmentBonusRating` | `GetEquipmentBonusThreshold` | `GetEquipmentFilterTypeForItemSetCollectionSlot`
`GetEquippedItemInfo` | `GetEquippedOutfitIndex` | `GetErrorString` | `GetErrorStringLockedByCollectibleId`
`GetEsoPlusSubscriptionBenefitsInfoHelpIndices` | `GetEsoPlusSubscriptionLapsedBenefitsInfoHelpIndices` | `GetExpectedGroupElectionResult` | `GetExpectedGroupQueueResult`
`GetExpectedJumpToReturningPlayerIntroGameplayResult` | `GetExpectedResultForChampionPurchaseRequest` | `GetExpiringMarketCurrencyInfo` | `GetFallbackReward`
`GetFastTravelNodeDrawLevelOffset` | `GetFastTravelNodeHouseId` | `GetFastTravelNodeInfo` | `GetFastTravelNodeLinkedCollectibleId`
`GetFastTravelNodeMapPriority` | `GetFastTravelNodeOutboundOnlyInfo` | `GetFastTravelNodePOIIndicies` | `GetFeedbackIdByIndex`
`GetFeedbackType` | `GetFenceLaunderTransactionInfo` | `GetFenceSellTransactionInfo` | `GetFirstAchievementInLine`
`GetFirstFreeValidSlotForItem` | `GetFirstFreeValidSlotForSimpleAction` | `GetFirstFreeValidSlotForSkillAbility` | `GetFirstKnownItemStyleId`
`GetFishingLure` | `GetFishingLureInfo` | `GetFormattedTime` | `GetForwardCampPinInfo`
`GetFrameDeltaMilliseconds` | `GetFrameDeltaNormalizedForTargetFramerate` | `GetFrameDeltaSeconds` | `GetFrameDeltaTimeMilliseconds`
`GetFrameDeltaTimeSeconds` | `GetFrameTimeMilliseconds` | `GetFrameTimeSeconds` | `GetFramerate`
`GetFriendCharacterInfo` | `GetFriendInfo` | `GetFullBountyPayoffAmount` | `GetFurnitureCategoryGamepadIcon`
`GetFurnitureCategoryId` | `GetFurnitureCategoryInfo` | `GetFurnitureCategoryKeyboardIcons` | `GetFurnitureCategoryName`
`GetFurnitureDataCategoryInfo` | `GetFurnitureDataInfo` | `GetFurnitureIdFromCollectibleId` | `GetFurnitureIdFromItemUniqueId`
`GetFurnitureSubcategoryId` | `GetFurnitureVaultCollectibleId` | `GetGameCameraInteractableActionInfo` | `GetGameCameraInteractableInfo`
`GetGameCameraInteractableUnitAudioInfo` | `GetGameCameraNonInteractableName` | `GetGameCameraPickpocketingBonusInfo` | `GetGameCameraTargetHoverTutorial`
`GetGameTimeMilliseconds` | `GetGameTimeSeconds` | `GetGamepadBothDpadDownAndRightStickScrollIcon` | `GetGamepadChatFontSize`
`GetGamepadIconPathForKeyCode` | `GetGamepadLeftStickDeltaX` | `GetGamepadLeftStickDeltaY` | `GetGamepadLeftStickSlideAndScrollIcon`
`GetGamepadLeftStickSlideIcon` | `GetGamepadLeftStickX` | `GetGamepadLeftStickY` | `GetGamepadLeftTriggerMagnitude`
`GetGamepadLevelUpTipDescription` | `GetGamepadLevelUpTipOverview` | `GetGamepadOrKeyboardLeftStickX` | `GetGamepadOrKeyboardLeftStickY`
`GetGamepadOrKeyboardRightStickX` | `GetGamepadOrKeyboardRightStickY` | `GetGamepadRightStickDeltaX` | `GetGamepadRightStickDeltaY`
`GetGamepadRightStickScrollIcon` | `GetGamepadRightStickX` | `GetGamepadRightStickY` | `GetGamepadRightTriggerMagnitude`
`GetGamepadTemplate` | `GetGamepadTouchpadX` | `GetGamepadTouchpadY` | `GetGamepadType`
`GetGamepadVisualReferenceArt` | `GetGenderFromNameDescriptor` | `GetGiftClaimableQuantity` | `GetGiftInfo`
`GetGiftMarketProductId` | `GetGiftQuantity` | `GetGiftingAccountLockedHelpIndices` | `GetGiftingGracePeriodTime`
`GetGiftingGraceStartedHelpIndices` | `GetGiftingUnlockedHelpIndices` | `GetGlobalTimeOfDay` | `GetGroundTargetingError`
`GetGroupAddOnDataBroadcastCooldownRemainingMS` | `GetGroupElectionInfo` | `GetGroupElectionUnreadyUnitTags` | `GetGroupElectionVoteByUnitTag`
`GetGroupFinderCreateGroupListingChampionPoints` | `GetGroupFinderFilterCategory` | `GetGroupFinderFilterChampionPoints` | `GetGroupFinderFilterGroupSizeIterationEnd`
`GetGroupFinderFilterGroupSizes` | `GetGroupFinderFilterNumPrimaryOptions` | `GetGroupFinderFilterNumSecondaryOptions` | `GetGroupFinderFilterPlaystyles`
`GetGroupFinderFilterPrimaryOptionByIndex` | `GetGroupFinderFilterSecondaryOptionByIndex` | `GetGroupFinderGroupFilterSearchString` | `GetGroupFinderSearchListingCategoryByIndex`
`GetGroupFinderSearchListingChampionPointsByIndex` | `GetGroupFinderSearchListingDescriptionByIndex` | `GetGroupFinderSearchListingFirstLockingCollectibleId` | `GetGroupFinderSearchListingGroupSizeByIndex`
`GetGroupFinderSearchListingJoinabilityResult` | `GetGroupFinderSearchListingLeaderCharacterNameByIndex` | `GetGroupFinderSearchListingLeaderDisplayNameByIndex` | `GetGroupFinderSearchListingNumRolesByIndex`
`GetGroupFinderSearchListingOptionsSelectionTextByIndex` | `GetGroupFinderSearchListingPlaystyleByIndex` | `GetGroupFinderSearchListingRoleStatusCount` | `GetGroupFinderSearchListingTitleByIndex`
`GetGroupFinderSearchNumListings` | `GetGroupFinderStatusReason` | `GetGroupFinderUserTypeGroupListingAttainedRoleCount` | `GetGroupFinderUserTypeGroupListingCategory`
`GetGroupFinderUserTypeGroupListingDescription` | `GetGroupFinderUserTypeGroupListingDesiredRoleCount` | `GetGroupFinderUserTypeGroupListingGroupSize` | `GetGroupFinderUserTypeGroupListingInviteCode`
`GetGroupFinderUserTypeGroupListingLeaderCharacterName` | `GetGroupFinderUserTypeGroupListingLeaderDisplayName` | `GetGroupFinderUserTypeGroupListingNumPrimaryOptions` | `GetGroupFinderUserTypeGroupListingNumRoles`
`GetGroupFinderUserTypeGroupListingNumSecondaryOptions` | `GetGroupFinderUserTypeGroupListingOptionsSelectionText` | `GetGroupFinderUserTypeGroupListingPlaystyle` | `GetGroupFinderUserTypeGroupListingPrimaryOptionByIndex`
`GetGroupFinderUserTypeGroupListingSecondaryOptionByIndex` | `GetGroupFinderUserTypeGroupListingTitle` | `GetGroupFinderUserTypeGroupSizeIterationBegin` | `GetGroupFinderUserTypeGroupSizeIterationEnd`
`GetGroupIndexByUnitTag` | `GetGroupInviteInfo` | `GetGroupLeaderUnitTag` | `GetGroupListingApplicationInfoByCharacterId`
`GetGroupListingApplicationNoteByCharacterId` | `GetGroupListingApplicationTimeRemainingSecondsByCharacterId` | `GetGroupMemberSelectedRole` | `GetGroupSize`
`GetGroupSizeFromLFGGroupType` | `GetGroupUnitTagByCompanionUnitTag` | `GetGroupUnitTagByIndex` | `GetGuiHidden`
`GetGuildAlliance` | `GetGuildAllianceAttribute` | `GetGuildBlacklistInfoAt` | `GetGuildClaimInteractionKeepId`
`GetGuildClaimedKeep` | `GetGuildDescription` | `GetGuildFinderAccountApplicationDuration` | `GetGuildFinderAccountApplicationInfo`
`GetGuildFinderGuildApplicationDuration` | `GetGuildFinderGuildApplicationInfoAt` | `GetGuildFinderNumAccountApplications` | `GetGuildFinderNumGuildApplications`
`GetGuildFoundedDate` | `GetGuildFoundedDateAttribute` | `GetGuildHeaderMessageAttribute` | `GetGuildHeraldryAttribute`
`GetGuildHistoryActivityEventInfo` | `GetGuildHistoryAvAActivityEventInfo` | `GetGuildHistoryBankedCurrencyEventInfo` | `GetGuildHistoryBankedItemEventInfo`
`GetGuildHistoryCacheDefaultMaxNumDays` | `GetGuildHistoryEventBasicInfo` | `GetGuildHistoryEventCategoryAndIndex` | `GetGuildHistoryEventId`
`GetGuildHistoryEventIndex` | `GetGuildHistoryEventIndicesForTimeRange` | `GetGuildHistoryEventRangeIndexForEventId` | `GetGuildHistoryEventRangeInfo`
`GetGuildHistoryEventTimestamp` | `GetGuildHistoryMilestoneEventInfo` | `GetGuildHistoryRequestFlags` | `GetGuildHistoryRequestMinCooldownMs`
`GetGuildHistoryRosterEventInfo` | `GetGuildHistoryTraderEventInfo` | `GetGuildId` | `GetGuildInfo`
`GetGuildInviteInfo` | `GetGuildInviteeInfo` | `GetGuildKioskActiveBidInfo` | `GetGuildKioskAttribute`
`GetGuildKioskCycleTimes` | `GetGuildLanguageAttribute` | `GetGuildLocalEndTimeAttribute` | `GetGuildLocalStartTimeAttribute`
`GetGuildMemberCharacterInfo` | `GetGuildMemberIndexFromDisplayName` | `GetGuildMemberInfo` | `GetGuildMinimumCPAttribute`
`GetGuildMotD` | `GetGuildName` | `GetGuildNameAttribute` | `GetGuildOwnedKioskInfo`
`GetGuildPermissionDependency` | `GetGuildPermissionRequisite` | `GetGuildPersonalityAttribute` | `GetGuildPrimaryFocusAttribute`
`GetGuildRankCustomName` | `GetGuildRankIconIndex` | `GetGuildRankId` | `GetGuildRankIndex`
`GetGuildRankLargeIcon` | `GetGuildRankListDownIcon` | `GetGuildRankListHighlightIcon` | `GetGuildRankListUpIcon`
`GetGuildRankSmallIcon` | `GetGuildRecruitmentActivityValue` | `GetGuildRecruitmentEndTime` | `GetGuildRecruitmentInfo`
`GetGuildRecruitmentLink` | `GetGuildRecruitmentMessageAttribute` | `GetGuildRecruitmentRoleValue` | `GetGuildRecruitmentStartTime`
`GetGuildRecruitmentStatus` | `GetGuildRecruitmentStatusAttribute` | `GetGuildReleaseInteractionKeepId` | `GetGuildSecondaryFocusAttribute`
`GetGuildSizeAttribute` | `GetGuildSizeAttributeRangeValues` | `GetGuildSpecificItemInfo` | `GetGuildSpecificItemLink`
`GetHeatDecayInfo` | `GetHeldSlots` | `GetHeldWeaponPair` | `GetHelpCategoryInfo`
`GetHelpId` | `GetHelpIndicesFromHelpLink` | `GetHelpInfo` | `GetHelpLink`
`GetHelpOverviewIntroParagraph` | `GetHelpOverviewQuestionAnswerPair` | `GetHelpSearchResults` | `GetHeraldryBackgroundCategoryInfo`
`GetHeraldryBackgroundStyleInfo` | `GetHeraldryColorInfo` | `GetHeraldryCrestCategoryInfo` | `GetHeraldryCrestStyleInfo`
`GetHeraldryCustomizationCosts` | `GetHeraldryGuildBankedMoney` | `GetHeraldryGuildFinderBackgroundCategoryIcon` | `GetHeraldryGuildFinderBackgroundStyleIcon`
`GetHeraldryGuildFinderCrestStyleIcon` | `GetHiddenByStringForVisualLayer` | `GetHighestClaimedLevelUpReward` | `GetHighestItemStyleId`
`GetHighestPriorityActionBindingInfoFromName` | `GetHighestPriorityActionBindingInfoFromNameAndInputDevice` | `GetHighestScryableDifficulty` | `GetHirelingCorrespondenceInfoByIndex`
`GetHistoricalAvAObjectivePinInfo` | `GetHistoricalKeepAlliance` | `GetHistoricalKeepPinInfo` | `GetHistoricalKeepTravelNetworkLinkInfo`
`GetHistoricalKeepUnderAttack` | `GetHotbarForCollectibleCategoryId` | `GetHouseCategoryType` | `GetHouseFlags`
`GetHouseFoundInZoneId` | `GetHouseFurnishingPlacementLimit` | `GetHouseFurnitureCount` | `GetHouseOccupantName`
`GetHousePreviewBackgroundImage` | `GetHouseTemplateBaseFurnishingCountInfo` | `GetHouseTemplateIdByIndexForHouse` | `GetHouseToursListingCollectibleIdByIndex`
`GetHouseToursListingFurnitureCountByIndex` | `GetHouseToursListingHouseIdByIndex` | `GetHouseToursListingNicknameByIndex` | `GetHouseToursListingOwnerDisplayNameByIndex`
`GetHouseToursListingTagsByIndex` | `GetHouseToursPlayerListingTagsByHouseId` | `GetHouseToursRecommendationsTimeRemainingS` | `GetHouseToursStatus`
`GetHouseToursTopRecommendedHouseNotification` | `GetHouseZoneId` | `GetHousingEditorConstants` | `GetHousingEditorHistoryCommandInfo`
`GetHousingEditorMode` | `GetHousingLink` | `GetHousingPermissionPresetType` | `GetHousingPrimaryHouse`
`GetHousingStarterQuestId` | `GetHousingUserGroupDisplayName` | `GetHousingVisitorRole` | `GetIgnoredInfo`
`GetImperialCityCollectibleId` | `GetImperialCityMapIndex` | `GetImperialStyleId` | `GetImportantDerivedStatDisplayInfoForRoleAtIndex`
`GetImportantMiscStatDisplayInfoForRoleAtIndex` | `GetInProgressAntiquitiesForDigSite` | `GetInProgressAntiquityDigSiteId` | `GetInProgressAntiquityId`
`GetIncomingFriendRequestInfo` | `GetIndexOfPerkInSlotForRole` | `GetInfamy` | `GetInfamyLevel`
`GetInfamyMeterSize` | `GetInstanceKickReason` | `GetInstanceKickTime` | `GetInstantUnlockRewardCategory`
`GetInstantUnlockRewardDescription` | `GetInstantUnlockRewardDisplayName` | `GetInstantUnlockRewardIcon` | `GetInstantUnlockRewardInstantUnlockId`
`GetInstantUnlockRewardType` | `GetInteractionKeepId` | `GetInteractionType` | `GetInterfaceColor`
`GetInventoryItemPreviewCollectibleActionDisplayName` | `GetInventoryItemPreviewVariationDisplayName` | `GetInventorySpaceRequiredToOpenCrownCrate` | `GetIsNewCharacter`
`GetIsQuestSharable` | `GetIsTracked` | `GetIsTrackedForContentId` | `GetIsWorldEventInstanceUnitPinIconAnimated`
`GetItemActorCategory` | `GetItemArmorType` | `GetItemArmoryBuildList` | `GetItemBindType`
`GetItemBoPTimeRemainingSeconds` | `GetItemBoPTradeableDisplayNamesString` | `GetItemBoPTradeableEligibleNameByIndex` | `GetItemBoPTradeableNumEligibleNames`
`GetItemBonusSuppressionName` | `GetItemCombinationId` | `GetItemComparisonEquipSlots` | `GetItemCondition`
`GetItemCooldownInfo` | `GetItemCraftingInfo` | `GetItemCreatorName` | `GetItemDisplayQuality`
`GetItemEnchantSuppressionInfo` | `GetItemEquipType` | `GetItemEquipmentFilterType` | `GetItemEquippedComparisonEquipSlots`
`GetItemFilterTypeInfo` | `GetItemFunctionalQuality` | `GetItemFurnitureDataId` | `GetItemGlyphMinLevels`
`GetItemId` | `GetItemInfo` | `GetItemInstanceId` | `GetItemLaunderPrice`
`GetItemLevel` | `GetItemLink` | `GetItemLinkActorCategory` | `GetItemLinkAppliedEnchantId`
`GetItemLinkArmorRating` | `GetItemLinkArmorType` | `GetItemLinkBindType` | `GetItemLinkBookTitle`
`GetItemLinkCombinationDescription` | `GetItemLinkCombinationId` | `GetItemLinkComparisonEquipSlots` | `GetItemLinkCondition`
`GetItemLinkContainerCollectibleId` | `GetItemLinkContainerSetBonusInfo` | `GetItemLinkContainerSetInfo` | `GetItemLinkCraftingSkillType`
`GetItemLinkDefaultEnchantId` | `GetItemLinkDisplayQuality` | `GetItemLinkDyeIds` | `GetItemLinkDyeStampId`
`GetItemLinkEnchantInfo` | `GetItemLinkEnchantingRuneClassification` | `GetItemLinkEnchantingRuneName` | `GetItemLinkEquipType`
`GetItemLinkEquippedComparisonEquipSlots` | `GetItemLinkFilterTypeInfo` | `GetItemLinkFinalEnchantId` | `GetItemLinkFlavorText`
`GetItemLinkFunctionalQuality` | `GetItemLinkFurnishingLimitType` | `GetItemLinkFurnitureDataId` | `GetItemLinkGlyphMinLevels`
`GetItemLinkGrantedRecipeIndices` | `GetItemLinkIcon` | `GetItemLinkInfo` | `GetItemLinkInventoryCount`
`GetItemLinkItemId` | `GetItemLinkItemSetCollectionSlot` | `GetItemLinkItemStyle` | `GetItemLinkItemTagInfo`
`GetItemLinkItemType` | `GetItemLinkItemUseReferenceId` | `GetItemLinkItemUseType` | `GetItemLinkMaterialLevelDescription`
`GetItemLinkMaxEnchantCharges` | `GetItemLinkName` | `GetItemLinkNumConsolidatedSmithingStationUnlockedSets` | `GetItemLinkNumContainerSetIds`
`GetItemLinkNumEnchantCharges` | `GetItemLinkNumItemTags` | `GetItemLinkOnUseAbilityInfo` | `GetItemLinkOutfitStyleId`
`GetItemLinkPreviewVariationDisplayName` | `GetItemLinkReagentTraitInfo` | `GetItemLinkRecipeCraftingSkillType` | `GetItemLinkRecipeIngredientInfo`
`GetItemLinkRecipeIngredientItemLink` | `GetItemLinkRecipeNumIngredients` | `GetItemLinkRecipeNumTradeskillRequirements` | `GetItemLinkRecipeQualityRequirement`
`GetItemLinkRecipeResultItemLink` | `GetItemLinkRecipeTradeskillRequirement` | `GetItemLinkRefinedMaterialItemLink` | `GetItemLinkRequiredChampionPoints`
`GetItemLinkRequiredCraftingSkillRank` | `GetItemLinkRequiredLevel` | `GetItemLinkSellInformation` | `GetItemLinkSetBonusInfo`
`GetItemLinkSetInfo` | `GetItemLinkShowItemStyleInTooltip` | `GetItemLinkSiegeMaxHP` | `GetItemLinkSiegeType`
`GetItemLinkStacks` | `GetItemLinkTooltipRequiresCollectibleId` | `GetItemLinkTradingHouseItemSearchName` | `GetItemLinkTraitCategory`
`GetItemLinkTraitInfo` | `GetItemLinkTraitOnUseAbilityInfo` | `GetItemLinkTraitType` | `GetItemLinkValue`
`GetItemLinkWeaponPower` | `GetItemLinkWeaponType` | `GetItemName` | `GetItemPairedPoisonInfo`
`GetItemPoisonSuppressionInfo` | `GetItemReconstructionCurrencyOptionCost` | `GetItemReconstructionCurrencyOptionType` | `GetItemRepairCost`
`GetItemRequiredChampionPoints` | `GetItemRequiredLevel` | `GetItemRetraitCost` | `GetItemRewardItemId`
`GetItemRewardItemLink` | `GetItemSellInformation` | `GetItemSellValueWithBonuses` | `GetItemSetBonusInfo`
`GetItemSetClassRestrictions` | `GetItemSetCollectionCategoryGamepadIcon` | `GetItemSetCollectionCategoryId` | `GetItemSetCollectionCategoryKeyboardIcons`
`GetItemSetCollectionCategoryName` | `GetItemSetCollectionCategoryOrder` | `GetItemSetCollectionCategoryParentId` | `GetItemSetCollectionPieceInfo`
`GetItemSetCollectionPieceItemLink` | `GetItemSetCollectionSlotsInMask` | `GetItemSetInfo` | `GetItemSetName`
`GetItemSetSuppressionInfo` | `GetItemSetType` | `GetItemSetUnperfectedSetId` | `GetItemSoundCategory`
`GetItemSoundCategoryFromLink` | `GetItemStatValue` | `GetItemStyleInfo` | `GetItemStyleMaterialLink`
`GetItemStyleName` | `GetItemTotalCount` | `GetItemTrait` | `GetItemTraitCategory`
`GetItemTraitInformation` | `GetItemTraitInformationFromItemLink` | `GetItemTraitSuppressionInfo` | `GetItemTraitTypeCategory`
`GetItemType` | `GetItemUniqueId` | `GetItemUniqueIdFromFurnitureId` | `GetItemUseType`
`GetItemWeaponType` | `GetJewelrycraftingCollectibleId` | `GetJournalQuestConditionInfo` | `GetJournalQuestConditionType`
`GetJournalQuestConditionValues` | `GetJournalQuestEnding` | `GetJournalQuestId` | `GetJournalQuestInfo`
`GetJournalQuestIsComplete` | `GetJournalQuestLevel` | `GetJournalQuestLocationInfo` | `GetJournalQuestName`
`GetJournalQuestNumConditions` | `GetJournalQuestNumRewards` | `GetJournalQuestNumSteps` | `GetJournalQuestRepeatType`
`GetJournalQuestRewardActiveSpectacleEventId` | `GetJournalQuestRewardCollectibleId` | `GetJournalQuestRewardInfo` | `GetJournalQuestRewardItemId`
`GetJournalQuestRewardSkillLine` | `GetJournalQuestRewardTributeCardUpgradeInfo` | `GetJournalQuestStartingZone` | `GetJournalQuestStepInfo`
`GetJournalQuestTimerCaption` | `GetJournalQuestTimerInfo` | `GetJournalQuestType` | `GetJournalQuestZoneDisplayType`
`GetJournalQuestZoneStoryZoneId` | `GetKeepAccessible` | `GetKeepAlliance` | `GetKeepArtifactObjectiveId`
`GetKeepCaptureBonusPercent` | `GetKeepDefensiveLevel` | `GetKeepDirectionalAccess` | `GetKeepFastTravelInteraction`
`GetKeepHasResourcesForTravel` | `GetKeepKeysByIndex` | `GetKeepMaxUpgradeLevel` | `GetKeepName`
`GetKeepPinInfo` | `GetKeepProductionLevel` | `GetKeepRecallAvailable` | `GetKeepResourceInfo`
`GetKeepResourceLevel` | `GetKeepResourceType` | `GetKeepScoreBonusAbilityId` | `GetKeepThatHasCapturedThisArtifactScrollObjective`
`GetKeepTravelNetworkLinkEndpoints` | `GetKeepTravelNetworkLinkInfo` | `GetKeepTravelNetworkNodeInfo` | `GetKeepTravelNetworkNodeKeepId`
`GetKeepTravelNetworkNodePosition` | `GetKeepType` | `GetKeepUnderAttack` | `GetKeepUpgradeDetails`
`GetKeepUpgradeInfo` | `GetKeepUpgradeLineFromResourceType` | `GetKeepUpgradeLineFromUpgradePath` | `GetKeepUpgradePathDetails`
`GetKeepUpgradeRate` | `GetKeyChordsFromSingleKey` | `GetKeyName` | `GetKeyNarrationText`
`GetKeyboardIconPathForKeyCode` | `GetKeyboardLayout` | `GetKeyboardLevelUpTipDescription` | `GetKeyboardLevelUpTipOverview`
`GetKillLocationPinInfo` | `GetKillingAttackInfo` | `GetKillingAttackerBattlegroundTeam` | `GetKillingAttackerInfo`
`GetKioskBidWindowSecondsRemaining` | `GetKioskGuildInfo` | `GetKioskPurchaseCost` | `GetLFGActivityRewardDescriptionOverride`
`GetLFGActivityRewardUINodeInfo` | `GetLFGCooldownTimeRemainingSeconds` | `GetLFGReadyCheckActivityType` | `GetLFGReadyCheckCounts`
`GetLFGReadyCheckNotificationInfo` | `GetLFGSearchTimes` | `GetLargeAvARankIcon` | `GetLastCraftingResultAbilityId`
`GetLastCraftingResultCurrencyInfo` | `GetLastCraftingResultItemInfo` | `GetLastCraftingResultItemLink` | `GetLastCraftingResultLearnedTraitInfo`
`GetLastCraftingResultLearnedTranslationInfo` | `GetLastCraftingResultTotalInspiration` | `GetLastObjectiveControlEvent` | `GetLastSlottedItemLink`
`GetLatency` | `GetLeaderboardCampaignSequenceId` | `GetLeaderboardScoreNotificationInfo` | `GetLeaderboardScoreNotificationMemberInfo`
`GetLevelUpBackground` | `GetLevelUpGuiParticleEffectInfo` | `GetLevelUpHelpIndicesForLevel` | `GetLevelUpTextureLayerRevealAnimation`
`GetLevelUpTextureLayerRevealAnimationsMinDuration` | `GetLinkType` | `GetLocalPlayerBattlegroundLivesRemaining` | `GetLocalPlayerDaedricArtifactId`
`GetLocalPlayerGroupUnitTag` | `GetLocalTimeOfDay` | `GetLocationName` | `GetLockQuality`
`GetLockpickingCompanionBonusName` | `GetLockpickingCompanionBonusTimeMS` | `GetLockpickingDefaultGamepadVibration` | `GetLockpickingTimeLeft`
`GetLootAntiquityLeadId` | `GetLootCurrency` | `GetLootItemInfo` | `GetLootItemLink`
`GetLootItemType` | `GetLootMoney` | `GetLootQuestItemId` | `GetLootTargetInfo`
`GetLootTributeCardUpgradeInfo` | `GetLoreBookCategoryIndexFromCategoryId` | `GetLoreBookCollectionIndicesFromCollectionId` | `GetLoreBookCollectionLinkedAchievement`
`GetLoreBookIndicesFromBookId` | `GetLoreBookInfo` | `GetLoreBookLink` | `GetLoreBookOverrideImageFromBookId`
`GetLoreBookTitleFromLink` | `GetLoreCategoryInfo` | `GetLoreCollectionInfo` | `GetMailAttachmentInfo`
`GetMailFlags` | `GetMailIdByIndex` | `GetMailItemInfo` | `GetMailItemRewardMailInfo`
`GetMailQueuedAttachmentLink` | `GetMailSender` | `GetMapBlobNameInfo` | `GetMapContentType`
`GetMapCustomMaxZoom` | `GetMapFilterType` | `GetMapFloorInfo` | `GetMapIdByIndex`
`GetMapIdByZoneId` | `GetMapIndexById` | `GetMapIndexByZoneId` | `GetMapInfoById`
`GetMapInfoByIndex` | `GetMapKeySectionName` | `GetMapKeySectionSymbolInfo` | `GetMapLocationIcon`
`GetMapLocationTooltipHeader` | `GetMapLocationTooltipLineInfo` | `GetMapMouseoverInfo` | `GetMapName`
`GetMapNameById` | `GetMapNameByIndex` | `GetMapNumTiles` | `GetMapNumTilesForMapId`
`GetMapParentCategories` | `GetMapPing` | `GetMapPlayerPosition` | `GetMapPlayerWaypoint`
`GetMapRallyPoint` | `GetMapTileTexture` | `GetMapTileTextureForMapId` | `GetMapType`
`GetMarketAnnouncementCompletedDailyLoginRewardClaimsBackground` | `GetMarketAnnouncementDailyLoginLockedBackground` | `GetMarketAnnouncementHelpLinkIndices` | `GetMarketCurrencyTypeFromCurrencyType`
`GetMarketProductAssociatedAchievementId` | `GetMarketProductChapterUpgradeId` | `GetMarketProductCollectiblePreviewActionDisplayName` | `GetMarketProductCrownCrateRewardInfo`
`GetMarketProductCrownCrateTierId` | `GetMarketProductCurrencyType` | `GetMarketProductDisplayName` | `GetMarketProductMaxGiftQuantity`
`GetMarketProductPresentationIds` | `GetMarketProductPreviewVariationDisplayName` | `GetMarketProductUnlockNotificationProductId` | `GetMarketProductUnlockedByAchievementId`
`GetMarketProductUnlockedByCollectibleIds` | `GetMarketProductUnlockedHelpIndices` | `GetMarketProductsForItem` | `GetMatchTradingHouseItemNamesResult`
`GetMaxBackpackUpgrade` | `GetMaxBags` | `GetMaxBankUpgrade` | `GetMaxBindingsPerAction`
`GetMaxCharacterSlotsUpgrade` | `GetMaxCurrencyTransfer` | `GetMaxIterationsPossibleForAlchemyItem` | `GetMaxIterationsPossibleForEnchantingItem`
`GetMaxIterationsPossibleForRecipe` | `GetMaxIterationsPossibleForSmithingItem` | `GetMaxKeepNPCs` | `GetMaxKeepSieges`
`GetMaxKioskBidsPerGuild` | `GetMaxLevel` | `GetMaxNumSavedKeybindings` | `GetMaxPossibleCurrency`
`GetMaxPossiblePointsInChampionSkill` | `GetMaxRecipeIngredients` | `GetMaxRidingTraining` | `GetMaxSimultaneousSmithingResearch`
`GetMaxSpendableChampionPointsInAttribute` | `GetMaxTradingHouseFilterExactTerms` | `GetMaxTraits` | `GetMaximumRapport`
`GetMedalInfo` | `GetMedalName` | `GetMedalScoreReward` | `GetMinLettersInTradingHouseItemNameForCurrentLanguage`
`GetMinLevelForCampaignTutorial` | `GetMinMaxRamEscorts` | `GetMinimumRapport` | `GetMoragTongStyleId`
`GetMostRecentGamepadType` | `GetMountSkinId` | `GetMouseIconPathForKeyCode` | `GetMouseOverDiggingActiveSkill`
`GetMundusStoneHelpIndices` | `GetMundusWarningLevel` | `GetNameOfGameCameraQuestToolTarget` | `GetNameplateGamepadFont`
`GetNameplateKeyboardFont` | `GetNearestQuestCondition` | `GetNewTributeCampaignRank` | `GetNewestAndOldestRedactedGuildHistoryEventIds`
`GetNextAbilityMechanicFlag` | `GetNextAchievementInLine` | `GetNextActiveArtificialEffectId` | `GetNextAntiquityId`
`GetNextBackpackUpgradePrice` | `GetNextBankUpgradePrice` | `GetNextBattlegroundCumulativeMedalId` | `GetNextBattlegroundLeaderboardType`
`GetNextCompletedQuestId` | `GetNextDirtyBlacklistCollectibleId` | `GetNextDirtyUnlockStateCollectibleId` | `GetNextDirtyUnlockedConsolidatedSmithingItemSetId`
`GetNextEndlessDungeonLifetimeVerseAbilityAndStackCount` | `GetNextEndlessDungeonVisionAbilityAndStackCount` | `GetNextForwardCampRespawnTime` | `GetNextFurnitureVaultSlotId`
`GetNextGiftId` | `GetNextGroupListingApplicationCharacterId` | `GetNextGuildBankSlotId` | `GetNextItemSetCollectionId`
`GetNextKnownRecipeForCraftingStation` | `GetNextLeaderboardScoreNotificationId` | `GetNextLevelUpRewardMilestoneLevel` | `GetNextMailId`
`GetNextOwnedCrownCrateId` | `GetNextPathedHousingFurnitureId` | `GetNextPlacedHousingFurnitureId` | `GetNextRaidLeaderboardId`
`GetNextScoreboardEntryMedalId` | `GetNextTributeLeaderboardType` | `GetNextVirtualBagSlotId` | `GetNextWorldEventInstanceId`
`GetNextZoneStoryZoneId` | `GetNonCombatBonus` | `GetNonCombatBonusLevelTypeForTradeskillType` | `GetNormalizedPositionForSkyshardId`
`GetNormalizedPositionForZoneStoryActivityId` | `GetNormalizedWorldPosition` | `GetNumAbilities` | `GetNumAbilitiesInCompanionSkillLine`
`GetNumAchievementCategories` | `GetNumAchievementsSearchResults` | `GetNumActionLayers` | `GetNumActiveActionLayers`
`GetNumActivePromotionalEventCampaigns` | `GetNumActiveSpectacleEvents` | `GetNumActivitiesByType` | `GetNumActivityRequests`
`GetNumActivitySetActivities` | `GetNumActivitySetsByType` | `GetNumAdditionalLevelUpUnlocks` | `GetNumAdvancedStatCategories`
`GetNumAntiquitiesRecovered` | `GetNumAntiquityDigSites` | `GetNumAntiquityLoreEntries` | `GetNumAntiquityLoreEntriesAcquired`
`GetNumAntiquitySearchResults` | `GetNumAntiquitySetAntiquities` | `GetNumArtifactScoreBonuses` | `GetNumAssociatedAchievementsForZoneCompletionType`
`GetNumAttainSkillLineRanksInAchievement` | `GetNumAttributes` | `GetNumAvailableMundusStoneSlots` | `GetNumAvailableSkillBuilds`
`GetNumBackgroundListFilterResults` | `GetNumBackpackSlotsPerUpgrade` | `GetNumBagFreeSlots` | `GetNumBagUsedSlots`
`GetNumBankSlotsPerUpgrade` | `GetNumBattlegroundLeaderboardEntries` | `GetNumBuffs` | `GetNumBuybackItems`
`GetNumCampaignAllianceLeaderboardEntries` | `GetNumCampaignLeaderboardEntries` | `GetNumCampaignQueueEntries` | `GetNumCampaignRulesetTypes`
`GetNumChallengeLeaderboardEntries` | `GetNumChallengeOfTheWeekLeaderboardEntries` | `GetNumChampionDisciplineSkills` | `GetNumChampionDisciplines`
`GetNumChampionLinksToPreallocate` | `GetNumChampionNodesToPreallocate` | `GetNumChampionXPInChampionPoint` | `GetNumChapterBasicRewards`
`GetNumChapterPreOrderRewards` | `GetNumChapterPrePurchaseRewards` | `GetNumCharacterSlotsPerUpgrade` | `GetNumCharacters`
`GetNumChatCategories` | `GetNumChatContainerTabs` | `GetNumChatContainers` | `GetNumClaimableDailyLoginRewardsInCurrentMonth`
`GetNumClaimableReturningPlayerRewards` | `GetNumClasses` | `GetNumCollectibleAsFurniturePreviewActions` | `GetNumCollectibleAsFurniturePreviewVariations`
`GetNumCollectibleCategories` | `GetNumCollectibleNotifications` | `GetNumCollectiblePreviewActions` | `GetNumCollectiblePreviewVariations`
`GetNumCollectibleTags` | `GetNumCollectiblesInCollectibleCategory` | `GetNumCollectiblesSearchResults` | `GetNumCompanionSkillLines`
`GetNumCompanionsInGroup` | `GetNumCompletedZoneActivitiesForZoneCompletionType` | `GetNumConsolidatedSmithingItemSetSearchResults` | `GetNumConsolidatedSmithingSets`
`GetNumCraftedAbilities` | `GetNumCrownGemsFromItemManualGemification` | `GetNumCurrentCrownCrateBonusRewards` | `GetNumCurrentCrownCratePrimaryRewards`
`GetNumCurrentCrownCrateTotalRewards` | `GetNumDaysInMonth` | `GetNumDeathRecapHints` | `GetNumDefaultQuickChats`
`GetNumDigSitesForInProgressAntiquity` | `GetNumDisplays` | `GetNumDyes` | `GetNumDyesSearchResults`
`GetNumEdgeKeepBonuses` | `GetNumEmotes` | `GetNumEndlessDungeonActiveVerses` | `GetNumEndlessDungeonDuoLeaderboardEntries`
`GetNumEndlessDungeonLifetimeVerseAndVisionStackCounts` | `GetNumEndlessDungeonOfTheWeekDuoLeaderboardEntries` | `GetNumEndlessDungeonOfTheWeekSoloLeaderboardEntries` | `GetNumEndlessDungeonSoloLeaderboardEntries`
`GetNumExperiencePointsInCompanionLevel` | `GetNumExperiencePointsInLevel` | `GetNumExpiringMarketCurrencyInfos` | `GetNumFastTravelNodes`
`GetNumFavoriteHouses` | `GetNumFishingLures` | `GetNumForwardCamps` | `GetNumFreeAnytimeCampaignReassigns`
`GetNumFreeAnytimeCampaignUnassigns` | `GetNumFreeEndCampaignReassigns` | `GetNumFriendlyKeepNPCs` | `GetNumFriends`
`GetNumFurnitureCategories` | `GetNumFurnitureSubcategories` | `GetNumGoalsAchievedForAntiquity` | `GetNumGuildBlacklistEntries`
`GetNumGuildHistoryEventRanges` | `GetNumGuildHistoryEvents` | `GetNumGuildInvitees` | `GetNumGuildInvites`
`GetNumGuildKioskActiveBids` | `GetNumGuildMembers` | `GetNumGuildMembersRequiredForPrivilege` | `GetNumGuildPermissionDependencies`
`GetNumGuildPermissionRequisites` | `GetNumGuildRankIcons` | `GetNumGuildRanks` | `GetNumGuildSpecificItems`
`GetNumGuilds` | `GetNumHelpCategories` | `GetNumHelpEntriesWithinCategory` | `GetNumHelpOverviewQuestionAnswers`
`GetNumHeraldryBackgroundCategories` | `GetNumHeraldryBackgroundStyles` | `GetNumHeraldryColors` | `GetNumHeraldryCrestCategories`
`GetNumHeraldryCrestStyles` | `GetNumHouseFurnishingsPlaced` | `GetNumHouseTemplatesForHouse` | `GetNumHouseToursPlayerListingRecommendations`
`GetNumHouseToursSearchListings` | `GetNumHouseToursTopRecommendedHouseNotifications` | `GetNumHouseToursUnfilteredListings` | `GetNumHousesRecommendedByLocalPlayer`
`GetNumHousingEditorHistoryCommands` | `GetNumHousingPermissions` | `GetNumIgnored` | `GetNumInProgressAntiquities`
`GetNumIncomingFriendRequests` | `GetNumInventoryItemPreviewCollectibleActions` | `GetNumInventoryItemPreviewVariations` | `GetNumInventorySlotsNeededForDailyLoginRewardInCurrentMonth`
`GetNumInventorySlotsNeededForLevelUpReward` | `GetNumItemLinkPreviewVariations` | `GetNumItemReconstructionCurrencyOptions` | `GetNumItemSetCollectionPieces`
`GetNumItemSetCollectionSlotsUnlocked` | `GetNumJournalQuests` | `GetNumKeepResourceTypes` | `GetNumKeepScoreBonuses`
`GetNumKeepTravelNetworkLinks` | `GetNumKeepTravelNetworkNodes` | `GetNumKeepUpgradePaths` | `GetNumKeeps`
`GetNumKillLocationAllianceKills` | `GetNumKillLocations` | `GetNumKillingAttacks` | `GetNumLFGActivityRewardUINodes`
`GetNumLastCraftingResultCurrencies` | `GetNumLastCraftingResultItemsAndPenalty` | `GetNumLastCraftingResultLearnedTraits` | `GetNumLastCraftingResultLearnedTranslations`
`GetNumLevelUpGuiParticleEffects` | `GetNumLevelUpTextureLayerRevealAnimations` | `GetNumLockpicksLeft` | `GetNumLootItems`
`GetNumLoreCategories` | `GetNumMailItems` | `GetNumMailItemsByCategory` | `GetNumMapBlobs`
`GetNumMapKeySectionSymbols` | `GetNumMapKeySections` | `GetNumMapLocationTooltipLines` | `GetNumMapLocations`
`GetNumMaps` | `GetNumMarketProductCollectiblePreviewActions` | `GetNumMarketProductPreviewVariations` | `GetNumMarketProductUnlockNotifications`
`GetNumMatchTradingHouseItemNamesResults` | `GetNumNewCollectibles` | `GetNumNewCollectiblesByCategoryType` | `GetNumObjectives`
`GetNumOutfitStyleItemMaterials` | `GetNumOutgoingFriendRequests` | `GetNumOwnedCharacterSlots` | `GetNumOwnedCrownCrateTypes`
`GetNumPOIs` | `GetNumPOIsForCadwellProgressionLevelAndZone` | `GetNumPassiveSkillRanks` | `GetNumPatronsFavoringPlayerPerspective`
`GetNumPendingFeedback` | `GetNumPlacedFurniturePreviewVariations` | `GetNumPlayerApplicationNotifications` | `GetNumPlayerStatuses`
`GetNumPlayersEscortingRam` | `GetNumPointsNeededForAvARank` | `GetNumPointsSpentOnChampionSkill` | `GetNumProgressionSkillAbilityFxOverrides`
`GetNumPromotionalEventCampaignActivities` | `GetNumPromotionalEventCampaignMilestoneRewards` | `GetNumProvisionerItemAsFurniturePreviewVariations` | `GetNumRaidLeaderboards`
`GetNumRecipeLists` | `GetNumRecipeTradeskillRequirements` | `GetNumRequiredPlacementMatches` | `GetNumReturningPlayerDailyLoginRewards`
`GetNumReturningPlayerDailyLoginRewardsClaimed` | `GetNumReturningPlayerPrimaryRewards` | `GetNumRewardListEntries` | `GetNumRewardPreviewCollectibleActions`
`GetNumRewardPreviewVariations` | `GetNumRewardsForLevel` | `GetNumRewardsInCurrentDailyLoginMonth` | `GetNumSCTCloudOffsets`
`GetNumSCTSlots` | `GetNumSavedDyeSets` | `GetNumSavedKeybindings` | `GetNumScoreboardEntries`
`GetNumScriptedEventInvites` | `GetNumScriptsInSlotForCraftedAbility` | `GetNumSelectionCampaignFriends` | `GetNumSelectionCampaignGroupMembers`
`GetNumSelectionCampaignGuildMembers` | `GetNumSelectionCampaigns` | `GetNumServiceTokens` | `GetNumSieges`
`GetNumSkillAbilities` | `GetNumSkillBuildAbilities` | `GetNumSkillLines` | `GetNumSkillLinesForClass`
`GetNumSkillTypes` | `GetNumSkyShards` | `GetNumSkyshardsInAchievement` | `GetNumSkyshardsInZone`
`GetNumSmithingImprovementItems` | `GetNumSmithingPatterns` | `GetNumSmithingResearchLines` | `GetNumSmithingTraitItems`
`GetNumSpectatableUnits` | `GetNumSpentChampionPoints` | `GetNumStacksForEndlessDungeonBuff` | `GetNumStats`
`GetNumStoreEntryPreviewCollectibleActions` | `GetNumStoreEntryPreviewVariations` | `GetNumStoreItems` | `GetNumSubcategoriesInCollectibleCategory`
`GetNumTelvarStonesLost` | `GetNumTimedActivities` | `GetNumTimedActivitiesCompleted` | `GetNumTimedActivityRewards`
`GetNumTitles` | `GetNumTracked` | `GetNumTradingHouseGuilds` | `GetNumTradingHouseListings`
`GetNumTradingHouseSearchResultItemPreviewCollectibleActions` | `GetNumTradingHouseSearchResultItemPreviewVariations` | `GetNumTrialLeaderboardEntries` | `GetNumTrialOfTheWeekLeaderboardEntries`
`GetNumTributeCardMechanics` | `GetNumTributeClubRankRewardLists` | `GetNumTributeLeaderboardEntries` | `GetNumTributePatronMechanicsForFavorState`
`GetNumTributePatronPassiveMechanicsForFavorState` | `GetNumTributePatronRequirementsForFavorState` | `GetNumTributePatrons` | `GetNumTutorials`
`GetNumUnblockedZoneStoryActivitiesForZoneCompletionType` | `GetNumUnlockedArmoryBuilds` | `GetNumUnlockedConsolidatedSmithingSets` | `GetNumUnlockedHirelingCorrespondence`
`GetNumUnlockedOutfits` | `GetNumUnreadMail` | `GetNumUnspentChampionPoints` | `GetNumUpdatedRecipes`
`GetNumUpgradesForKeepAtPathLevel` | `GetNumUpgradesForKeepAtResourceLevel` | `GetNumValidItemStyles` | `GetNumViewableTreasureMaps`
`GetNumWorldEventInstanceUnits` | `GetNumZoneActivitiesForZoneCompletionType` | `GetNumZones` | `GetNumZonesForCadwellProgressionLevel`
`GetNumberOfAvailableSynergies` | `GetNumberOfImportantDerivedStatDisplaysForRoleAtIndex` | `GetNumberOfImportantMiscStatDisplaysForRoleAtIndex` | `GetNumberOfPerksAvailableToLoadoutRoleDef`
`GetNumberOfPerksAvailableToLoadoutRoleDefInSlot` | `GetNumberOfSlotFlagsForPerkAtIndex` | `GetNumberOfVengeanceRolesAvailableToPlayer` | `GetObjectiveAuraPinInfo`
`GetObjectiveControlState` | `GetObjectiveDesignation` | `GetObjectiveIdsForIndex` | `GetObjectiveInfo`
`GetObjectivePinInfo` | `GetObjectiveReturnPinInfo` | `GetObjectiveSpawnPinInfo` | `GetObjectiveType`
`GetObjectiveVirtualId` | `GetOfferedQuestInfo` | `GetOfferedQuestShareIds` | `GetOfferedQuestShareInfo`
`GetOldestGuildHistoryEventIndexForUpToDateEventsWithoutGaps` | `GetOnSaleCrownCrateId` | `GetOpeningCinematicVideoDataId` | `GetOrCreateSynchronizingObject`
`GetOutfitChangeFlatCost` | `GetOutfitName` | `GetOutfitSlotClearCost` | `GetOutfitSlotDataCollectibleCategoryId`
`GetOutfitSlotDataHiddenOutfitStyleCollectibleId` | `GetOutfitSlotInfo` | `GetOutfitSlotInfoForOutfitSlotInPreviewCollection` | `GetOutfitSlotsForCurrentlyHeldWeapons`
`GetOutfitSlotsForEquippedWeapons` | `GetOutfitStyleCost` | `GetOutfitStyleFreeConversionCollectibleId` | `GetOutfitStyleItemMaterialName`
`GetOutfitStyleItemStyleId` | `GetOutfitStyleVisualArmorType` | `GetOutfitStyleWeaponModelType` | `GetOutgoingFriendRequestInfo`
`GetOverrideMusicMode` | `GetOverscanOffsets` | `GetPOIIndices` | `GetPOIInfo`
`GetPOIInstanceType` | `GetPOIMapFilterOverride` | `GetPOIMapInfo` | `GetPOIPinIcon`
`GetPOISkyshardId` | `GetPOIType` | `GetPOIWorldEventInstanceId` | `GetPOIZoneCompletionType`
`GetParentZoneId` | `GetPendingAssignedCampaign` | `GetPendingAttributeRespecScrollItemLink` | `GetPendingCompanionDefId`
`GetPendingHeraldryCost` | `GetPendingHeraldryIndices` | `GetPendingItemPost` | `GetPendingLevelUpRewardLevel`
`GetPendingResurrectInfo` | `GetPendingSkillRespecScrollItemLink` | `GetPendingSlotDyes` | `GetPendingTributeCampaignExperience`
`GetPendingTributeClubExperience` | `GetPerkIndexForSlotAtSlotIndex` | `GetPlacedFurnitureChildren` | `GetPlacedFurnitureLink`
`GetPlacedFurnitureParent` | `GetPlacedFurniturePreviewVariationDisplayName` | `GetPlacedHousingFurnitureCurrentObjectStateIndex` | `GetPlacedHousingFurnitureDisplayQuality`
`GetPlacedHousingFurnitureInfo` | `GetPlacedHousingFurnitureNumObjectStates` | `GetPlatformServiceType` | `GetPlayerActiveSubzoneName`
`GetPlayerActiveZoneName` | `GetPlayerApplicationNotificationInfo` | `GetPlayerCameraHeading` | `GetPlayerCampaignRewardTierInfo`
`GetPlayerChampionPointsEarned` | `GetPlayerChampionXP` | `GetPlayerCurseType` | `GetPlayerEndlessDungeonOfTheWeekParticipationInfo`
`GetPlayerEndlessDungeonOfTheWeekProgressInfo` | `GetPlayerEndlessDungeonParticipationInfo` | `GetPlayerEndlessDungeonProgressInfo` | `GetPlayerGuildMemberIndex`
`GetPlayerInfamyData` | `GetPlayerLocationName` | `GetPlayerMMRByType` | `GetPlayerMarketCurrency`
`GetPlayerRaidOfTheWeekParticipationInfo` | `GetPlayerRaidOfTheWeekProgressInfo` | `GetPlayerRaidParticipationInfo` | `GetPlayerRaidProgressInfo`
`GetPlayerStat` | `GetPlayerStatus` | `GetPlayerWorldPositionInHouse` | `GetPledgeOfMaraOfferInfo`
`GetPreviewModeEnabled` | `GetPreviousAchievementInLine` | `GetProgressionSkillAbilityFxOverrideCollectibleIdByIndex` | `GetProgressionSkillCurrentMorphSlot`
`GetProgressionSkillMorphSlotAbilityId` | `GetProgressionSkillMorphSlotChainedAbilityIds` | `GetProgressionSkillMorphSlotCurrentXP` | `GetProgressionSkillMorphSlotRankXPExtents`
`GetProgressionSkillProgressionId` | `GetProgressionSkillProgressionIndex` | `GetProgressionSkillProgressionName` | `GetPromotionalEventCampaignActivityDescription`
`GetPromotionalEventCampaignActivityInfo` | `GetPromotionalEventCampaignActivityProgress` | `GetPromotionalEventCampaignAnnouncementBackgroundFileIndex` | `GetPromotionalEventCampaignAnnouncementBannerOverrideType`
`GetPromotionalEventCampaignDescription` | `GetPromotionalEventCampaignDisplayName` | `GetPromotionalEventCampaignInfo` | `GetPromotionalEventCampaignLargeBackgroundFileIndex`
`GetPromotionalEventCampaignMilestoneInfo` | `GetPromotionalEventCampaignMilestoneRewardFlags` | `GetPromotionalEventCampaignProgress` | `GetPromotionalEventCampaignUIPriority`
`GetProvisionerItemAsFurniturePreviewVariationDisplayName` | `GetPurchasableCollectibleIdForCollectible` | `GetQuestConditionItemInfo` | `GetQuestConditionMasterWritInfo`
`GetQuestConditionQuestItemId` | `GetQuestItemCooldownInfo` | `GetQuestItemIcon` | `GetQuestItemInfo`
`GetQuestItemLink` | `GetQuestItemName` | `GetQuestItemNameFromLink` | `GetQuestItemTooltipText`
`GetQuestName` | `GetQuestPinTypeForTrackingLevel` | `GetQuestRepeatableType` | `GetQuestRewardItemLink`
`GetQuestToolCooldownInfo` | `GetQuestToolCount` | `GetQuestToolInfo` | `GetQuestToolLink`
`GetQuestToolQuestItemId` | `GetQuestType` | `GetQuestZoneId` | `GetQueuedCOD`
`GetQueuedItemAttachmentInfo` | `GetQueuedMailPostage` | `GetQueuedMoneyAttachment` | `GetQuickChatCategoryKeyboardIcons`
`GetRaceAndGenderSilhouetteTexture` | `GetRaceName` | `GetRadarCountUIPosition` | `GetRaidBonusMultiplier`
`GetRaidDuration` | `GetRaidLeaderboardLocalPlayerInfo` | `GetRaidLeaderboardName` | `GetRaidLeaderboardUISortIndex`
`GetRaidName` | `GetRaidOfTheWeekLeaderboardInfo` | `GetRaidOfTheWeekLeaderboardLocalPlayerInfo` | `GetRaidOfTheWeekTimes`
`GetRaidReviveCountersRemaining` | `GetRaidTargetTime` | `GetRandomGiftSendNoteText` | `GetRandomGiftThankYouNoteText`
`GetRandomMountType` | `GetRawNormalizedWorldPosition` | `GetRawUnitName` | `GetRearchLineInfoFromRetraitItem`
`GetRecallCooldown` | `GetRecallCost` | `GetRecallCurrency` | `GetRecentlyClaimedPromotionalEventRewards`
`GetRecentlyCompletedAchievements` | `GetRecipeInfo` | `GetRecipeInfoFromItemId` | `GetRecipeIngredientItemInfo`
`GetRecipeIngredientItemLink` | `GetRecipeIngredientRequiredQuantity` | `GetRecipeListInfo` | `GetRecipeResultItemInfo`
`GetRecipeResultItemLink` | `GetRecipeResultQuantity` | `GetRecipeTradeskillRequirement` | `GetReducedBountyPayoffAmount`
`GetRemainingCooldownForRoleSwapMs` | `GetRepairAllCost` | `GetRepairKitTier` | `GetRequiredActivityCollectibleId`
`GetRequiredChampionDisciplineIdForSlot` | `GetRequiredSmithingRefinementStackSize` | `GetResourceKeepForKeep` | `GetRestyleSlotCurrentDyes`
`GetRestyleSlotDyeData` | `GetRestyleSlotIcon` | `GetRestyleSlotId` | `GetResultingItemLinkAfterRetrait`
`GetReturnObjectiveOwner` | `GetReturningPlayerCampaignDisplayName` | `GetReturningPlayerDailyLoginClaimableRewardIndex` | `GetReturningPlayerDailyLoginRewardInfo`
`GetReturningPlayerIntroGameplayData` | `GetReturningPlayerIntroGameplayDescription` | `GetReturningPlayerIntroGameplayDisplayName` | `GetReturningPlayerPrimaryRewardData`
`GetRewardAnnouncementBackgroundFileIndex` | `GetRewardInfoForLevel` | `GetRewardListDescription` | `GetRewardListDisplayName`
`GetRewardListEntryInfo` | `GetRewardListIdFromReward` | `GetRewardPreviewCollectibleActionDisplayName` | `GetRewardPreviewVariationDisplayName`
`GetRewardType` | `GetRidingStats` | `GetRingOfMaraExperienceBonus` | `GetRunesForItemIdIfKnown`
`GetRunestoneSoundInfo` | `GetRunestoneTranslatedName` | `GetSCTCloudAnimationOverlapPercent` | `GetSCTCloudOffset`
`GetSCTEventVisualInfoHideWhenValueIsZero` | `GetSCTEventVisualInfoId` | `GetSCTEventVisualInfoTextColor` | `GetSCTEventVisualInfoTextFontSizes`
`GetSCTEventVisualInfoTextFormat` | `GetSCTGamepadFont` | `GetSCTKeyboardFont` | `GetSCTSlotAnimationMinimumSpacing`
`GetSCTSlotAnimationTimeline` | `GetSCTSlotClamping` | `GetSCTSlotEventControlScales` | `GetSCTSlotEventVisualInfo`
`GetSCTSlotGamepadCloudId` | `GetSCTSlotKeyboardCloudId` | `GetSCTSlotPosition` | `GetSCTSlotSourceReputationTypes`
`GetSCTSlotTargetReputationTypes` | `GetSCTSlotZoomedInPosition` | `GetSavedDyeSetDyes` | `GetScoreToWinBattlegroundRound`
`GetScoreToWinCurrentBattlegroundRound` | `GetScoreboardEntryBattlegroundTeam` | `GetScoreboardEntryClassId` | `GetScoreboardEntryInfo`
`GetScoreboardEntryNumEarnedMedalsById` | `GetScoreboardEntryNumLivesRemaining` | `GetScoreboardEntryScoreByType` | `GetScoreboardLocalPlayerEntryIndex`
`GetScribingCollectibleId` | `GetScribingInkItemLink` | `GetScriptIdAtSlotIndexForCraftedAbility` | `GetScriptedEventInviteIdFromIndex`
`GetScriptedEventInviteInfo` | `GetScriptedEventInviteTimeRemainingMS` | `GetScryingCurrentAntiquityId` | `GetScryingPassiveSkillIndex`
`GetSecondsInCampaignQueue` | `GetSecondsPlayed` | `GetSecondsRemainingInPromotionalEventCampaign` | `GetSecondsRemainingUntilNextActiveSpectacleEventPhase`
`GetSecondsSinceMidnight` | `GetSecondsUntilArrestTimeout` | `GetSecondsUntilBountyDecaysToZero` | `GetSecondsUntilCampaignEnd`
`GetSecondsUntilCampaignScoreReevaluation` | `GetSecondsUntilCampaignStart` | `GetSecondsUntilCampaignUnderdogReevaluation` | `GetSecondsUntilHeatDecaysToZero`
`GetSecondsUntilKeepClaimAvailable` | `GetSelectedDiggingActiveSkill` | `GetSelectedGuildBankId` | `GetSelectedLFGRole`
`GetSelectedTradingHouseGuildId` | `GetSelectionCampaignAllianceLockConflictingCharacterName` | `GetSelectionCampaignAllianceLockReason` | `GetSelectionCampaignAllianceScore`
`GetSelectionCampaignCurrentAllianceLock` | `GetSelectionCampaignId` | `GetSelectionCampaignPopulationData` | `GetSelectionCampaignQueueWaitTime`
`GetSelectionCampaignTimes` | `GetSelectionCampaignUnderdogLeaderAlliance` | `GetServiceTokenDescription` | `GetSetting`
`GetSettingChamberStress` | `GetSetting_Bool` | `GetSharedEmoteIconForCategory` | `GetSharedPersonalityEmoteIconForCategory`
`GetSharedQuickChatIcon` | `GetSkillAbilityCharacterLevelNeededToUnlock` | `GetSkillAbilityId` | `GetSkillAbilityIndicesFromCraftedAbilityId`
`GetSkillAbilityIndicesFromProgressionIndex` | `GetSkillAbilityInfo` | `GetSkillAbilityLineRankNeededToUnlock` | `GetSkillAbilityNextUpgradeInfo`
`GetSkillAbilityUpgradeInfo` | `GetSkillBuildEntryInfo` | `GetSkillBuildId` | `GetSkillBuildInfo`
`GetSkillBuildTutorialLevel` | `GetSkillLineAnnouncementIconById` | `GetSkillLineClassId` | `GetSkillLineCraftingGrowthTypeById`
`GetSkillLineDetailedIconById` | `GetSkillLineDynamicInfo` | `GetSkillLineExperienceRewardSkillLineId` | `GetSkillLineGameplayActorCategory`
`GetSkillLineId` | `GetSkillLineIdForClass` | `GetSkillLineIndicesFromSkillId` | `GetSkillLineIndicesFromSkillLineId`
`GetSkillLineMasteryCollectibleId` | `GetSkillLineNameById` | `GetSkillLineOrderingIndex` | `GetSkillLinePointCostMultiplier`
`GetSkillLineProgressionAbilityRank` | `GetSkillLineRankXPExtents` | `GetSkillLineUnlockTextById` | `GetSkillLineXPInfo`
`GetSkillPointsAwardedForLevel` | `GetSkillProgressionIdForHotbarSlotOverrideRule` | `GetSkillRespecCost` | `GetSkillTypeForCraftedAbilityId`
`GetSkillsAdvisorSuggestionLimit` | `GetSkyshardAchievementZoneId` | `GetSkyshardDiscoveryDistanceM` | `GetSkyshardDiscoveryStatus`
`GetSkyshardHint` | `GetSlotAbilityCost` | `GetSlotBoundId` | `GetSlotCooldownInfo`
`GetSlotFlagForSlotAtIndex` | `GetSlotIndexOfPerkInSlotForRole` | `GetSlotItemCount` | `GetSlotItemDisplayQuality`
`GetSlotItemLink` | `GetSlotItemSound` | `GetSlotName` | `GetSlotStackSize`
`GetSlotTexture` | `GetSlotType` | `GetSmithingGuaranteedImprovementItemAmount` | `GetSmithingImprovedItemInfo`
`GetSmithingImprovedItemLink` | `GetSmithingImprovementChance` | `GetSmithingImprovementItemInfo` | `GetSmithingImprovementItemLink`
`GetSmithingPatternArmorType` | `GetSmithingPatternInfo` | `GetSmithingPatternInfoForItemId` | `GetSmithingPatternInfoForItemSet`
`GetSmithingPatternMaterialItemInfo` | `GetSmithingPatternMaterialItemLink` | `GetSmithingPatternResultLink` | `GetSmithingRefinedItemId`
`GetSmithingRefinementMaxRawMaterial` | `GetSmithingRefinementMinRawMaterial` | `GetSmithingResearchLineInfo` | `GetSmithingResearchLineTraitDescriptions`
`GetSmithingResearchLineTraitInfo` | `GetSmithingResearchLineTraitTimes` | `GetSmithingStationItemSetIdFromItem` | `GetSmithingTraitItemInfo`
`GetSmithingTraitItemLink` | `GetSoulGemInfo` | `GetSoulGemItemInfo` | `GetSpecializedCollectibleType`
`GetSpecificSkillAbilityInfo` | `GetSpecificSkillAbilityKeysByAbilityId` | `GetSpectacleEventPhaseCompleteAnnouncementInfo` | `GetSpectacleEventPhaseStartedAnnouncementInfo`
`GetSpectatableUnitName` | `GetSpectatorCameraTargetIndex` | `GetStoreCollectibleInfo` | `GetStoreCurrencyTypes`
`GetStoreDefaultSortField` | `GetStoreEntryAntiquityId` | `GetStoreEntryHouseTemplateId` | `GetStoreEntryInfo`
`GetStoreEntryMaxBuyable` | `GetStoreEntryPreviewCollectibleActionDisplayName` | `GetStoreEntryPreviewVariationDisplayName` | `GetStoreEntryQuestItemId`
`GetStoreEntryStatValue` | `GetStoreEntryTypeInfo` | `GetStoreItemLink` | `GetStoreUsedCurrencyTypes`
`GetString` | `GetStringWidthScaled` | `GetStuckCooldown` | `GetSubclassingAccessLevel`
`GetSubclassingAchievementId` | `GetSubclassingHelpIndices` | `GetSubclassingQuestId` | `GetSynergyInfoAtIndex`
`GetSynergyPriorityOverride` | `GetTargetMountedStateInfo` | `GetTelvarStoneMultiplier` | `GetTelvarStoneMultiplierThresholdIndex`
`GetTelvarStonePercentLossOnNonPvpDeath` | `GetTelvarStonePercentLossOnPvpDeath` | `GetTelvarStoneThresholdAmount` | `GetTextureLayerRevealAnimationBlendMode`
`GetTextureLayerRevealAnimationTexture` | `GetTextureLayerRevealAnimationWindowDimensions` | `GetTextureLayerRevealAnimationWindowEndPoints` | `GetTextureLayerRevealAnimationWindowFadeGradientInfo`
`GetTextureLayerRevealAnimationWindowMovementDuration` | `GetTextureLayerRevealAnimationWindowMovementOffset` | `GetTimeStamp` | `GetTimeStamp32`
`GetTimeString` | `GetTimeToClemencyResetInSeconds` | `GetTimeToShadowyConnectionsResetInSeconds` | `GetTimeUntilCanBeTrained`
`GetTimeUntilNextDailyLoginMonthS` | `GetTimeUntilNextDailyLoginRewardClaimS` | `GetTimeUntilNextReturningPlayerDailyLoginRewardClaimS` | `GetTimeUntilStuckAvailable`
`GetTimedActivityDescription` | `GetTimedActivityDifficulty` | `GetTimedActivityId` | `GetTimedActivityMaxProgress`
`GetTimedActivityName` | `GetTimedActivityProgress` | `GetTimedActivityRequiredCollectible` | `GetTimedActivityRewardInfo`
`GetTimedActivityTimeRemainingSeconds` | `GetTimedActivityType` | `GetTimedActivityTypeLimit` | `GetTimestampForStartOfDate`
`GetTitle` | `GetTooltipStringForRenderQualitySetting` | `GetTotalAchievementPoints` | `GetTotalApplyCostForOutfitSlots`
`GetTotalCampaignHoldings` | `GetTotalCampaignMatchesPlayed` | `GetTotalClubMatchesPlayed` | `GetTotalCollectiblesByCategoryType`
`GetTotalFenceHagglingBonus` | `GetTotalNumGoalsForAntiquity` | `GetTotalUnlockedCollectiblesByCategoryType` | `GetTotalUserAddOnCPUTimeAvailableEachFrameMS`
`GetTotalUserAddOnCPUTimeUsedLastFrameMS` | `GetTotalUserAddOnCPUTimeUsedNowMS` | `GetTotalUserAddOnMemoryPoolCapacityMB` | `GetTotalUserAddOnMemoryPoolUsageMB`
`GetTrackedAntiquityId` | `GetTrackedByIndex` | `GetTrackedIsAssisted` | `GetTrackedPromotionalEventActivityInfo`
`GetTrackedZoneStoryActivityInfo` | `GetTrackingLevel` | `GetTradeInviteInfo` | `GetTradeItemBagAndSlot`
`GetTradeItemBoPTimeRemainingSeconds` | `GetTradeItemBoPTradeableDisplayNamesString` | `GetTradeItemInfo` | `GetTradeItemLink`
`GetTradeMoneyOffer` | `GetTradeskillLevelPassiveAbilityId` | `GetTradeskillRecipeCraftingSystem` | `GetTradeskillTypeForNonCombatBonusLevelType`
`GetTradingHouseCooldownRemaining` | `GetTradingHouseCutPercentage` | `GetTradingHouseGuildDetails` | `GetTradingHouseListingCounts`
`GetTradingHouseListingItemInfo` | `GetTradingHouseListingItemLink` | `GetTradingHouseListingPercentage` | `GetTradingHousePostPriceInfo`
`GetTradingHouseSearchResultItemInfo` | `GetTradingHouseSearchResultItemLink` | `GetTradingHouseSearchResultItemPreviewCollectibleActionDisplayName` | `GetTradingHouseSearchResultItemPreviewVariationDisplayName`
`GetTradingHouseSearchResultsInfo` | `GetTrainingCost` | `GetTraitIdFromBasePotion` | `GetTreasureMapInfo`
`GetTrialChatIsRestrictedAndWarn` | `GetTrialChatRestriction` | `GetTrialInfo` | `GetTrialLeaderboardEntryInfo`
`GetTrialOfTheWeekLeaderboardEntryInfo` | `GetTributeCampaignRankExperienceRequirement` | `GetTributeCardAcquireCost` | `GetTributeCardDefeatCost`
`GetTributeCardFlavorText` | `GetTributeCardMechanicInfo` | `GetTributeCardMechanicText` | `GetTributeCardName`
`GetTributeCardPortrait` | `GetTributeCardPortraitIcon` | `GetTributeCardRarity` | `GetTributeCardType`
`GetTributeCardUpgradeHintText` | `GetTributeCardUpgradeRewardTributeCardUpgradeInfo` | `GetTributeClubRankExperienceRequirement` | `GetTributeClubRankNPCSkillLevelEquivalent`
`GetTributeClubRankRewardListIdByIndex` | `GetTributeForfeitPenaltyDurationMs` | `GetTributeGeneralMatchLFGRewardUIDataId` | `GetTributeGeneralMatchRewardListId`
`GetTributeInviteInfo` | `GetTributeLeaderboardEntryInfo` | `GetTributeLeaderboardLocalPlayerInfo` | `GetTributeLeaderboardRankInfo`
`GetTributeLeaderboardsSchedule` | `GetTributeMatchCampaignKey` | `GetTributeMatchStatistics` | `GetTributeMatchType`
`GetTributeMechanicIconPath` | `GetTributeMechanicSetbackTypeForPlayer` | `GetTributeMechanicTargetingText` | `GetTributePatronAcquireHint`
`GetTributePatronCategoryGamepadIcon` | `GetTributePatronCategoryId` | `GetTributePatronCategoryKeyboardIcons` | `GetTributePatronCategoryName`
`GetTributePatronCategorySortOrder` | `GetTributePatronCollectibleId` | `GetTributePatronDockCardInfoByIndex` | `GetTributePatronFamily`
`GetTributePatronIdAtIndex` | `GetTributePatronLargeIcon` | `GetTributePatronLargeRingIcon` | `GetTributePatronLoreDescription`
`GetTributePatronMechanicInfo` | `GetTributePatronMechanicText` | `GetTributePatronMechanicsText` | `GetTributePatronName`
`GetTributePatronNumDockCards` | `GetTributePatronNumStarterCards` | `GetTributePatronPassiveMechanicInfo` | `GetTributePatronPassiveMechanicText`
`GetTributePatronPlayStyleDescription` | `GetTributePatronRarity` | `GetTributePatronRequirementIconPath` | `GetTributePatronRequirementInfo`
`GetTributePatronRequirementTargetingText` | `GetTributePatronRequirementText` | `GetTributePatronRequirementsText` | `GetTributePatronSmallIcon`
`GetTributePatronStarterCardIdByIndex` | `GetTributePatronSuitAtlas` | `GetTributePatronSuitIcon` | `GetTributePlayerCampaignRank`
`GetTributePlayerCampaignTotalExperience` | `GetTributePlayerClubRank` | `GetTributePlayerClubTotalExperience` | `GetTributePlayerExperienceInCurrentCampaignRank`
`GetTributePlayerExperienceInCurrentClubRank` | `GetTributePlayerInfo` | `GetTributePlayerPerspectiveResource` | `GetTributePrestigeRequiredToWin`
`GetTributeRemainingTimeForTurn` | `GetTributeRequiredCollectibleId` | `GetTributeRequiredQuestId` | `GetTributeResultsWinnerInfo`
`GetTributeTriggerDescription` | `GetTutorialDisplayPriority` | `GetTutorialId` | `GetTutorialIndex`
`GetTutorialInfo` | `GetTutorialLinkedHelpInfo` | `GetTutorialTrigger` | `GetTutorialType`
`GetUIPlatform` | `GetUISystemAssociatedWithHelpEntry` | `GetUniqueNameForCharacter` | `GetUnitActiveMundusStoneBuffIndices`
`GetUnitAlliance` | `GetUnitAttributeVisualizerEffectInfo` | `GetUnitAvARank` | `GetUnitAvARankPoints`
`GetUnitBankAccessBag` | `GetUnitBattleLevel` | `GetUnitBattlegroundTeam` | `GetUnitBuffInfo`
`GetUnitCaption` | `GetUnitChampionBattleLevel` | `GetUnitChampionPoints` | `GetUnitClass`
`GetUnitClassId` | `GetUnitDifficulty` | `GetUnitDisguiseState` | `GetUnitDisplayName`
`GetUnitDrownTime` | `GetUnitEffectiveChampionPoints` | `GetUnitEffectiveLevel` | `GetUnitEquipmentBonusRatingRelativeToLevel`
`GetUnitGender` | `GetUnitGuildKioskOwner` | `GetUnitHidingEndTime` | `GetUnitLevel`
`GetUnitName` | `GetUnitNameHighlightedByReticle` | `GetUnitPower` | `GetUnitPowerInfo`
`GetUnitRace` | `GetUnitRaceId` | `GetUnitRawWorldPosition` | `GetUnitReaction`
`GetUnitReactionColor` | `GetUnitReactionColorType` | `GetUnitSilhouetteTexture` | `GetUnitStealthState`
`GetUnitTargetMarkerType` | `GetUnitTitle` | `GetUnitType` | `GetUnitWorldPosition`
`GetUnitXP` | `GetUnitXPMax` | `GetUnitZone` | `GetUnitZoneIndex`
`GetUniversalStyleId` | `GetUniversallyNormalizedMapInfo` | `GetUpcomingLevelUpRewardLevel` | `GetUpdatedRecipeIndices`
`GetUpgradeSkillHighestRankAvailableAtSkillLineRank` | `GetValidItemStyleId` | `GetVengeancePerkIcon` | `GetVengeancePerkIconAtIndex`
`GetVengeancePerkNameAtIndex` | `GetVengeancePerkTooltipTextAtIndex` | `GetVengeanceRoleIcon` | `GetVengeanceRoleIconAtIndex`
`GetVengeanceRoleNameAtIndex` | `GetVibrationInfoFromTrigger` | `GetWeaponPairFromHotbarCategory` | `GetWeaponSwapUnlockedLevel`
`GetWorldDimensionsOfViewFrustumAtDepth` | `GetWorldEventId` | `GetWorldEventInstanceUnitPinIcon` | `GetWorldEventInstanceUnitPinType`
`GetWorldEventInstanceUnitTag` | `GetWorldEventLocationContext` | `GetWorldEventPOIInfo` | `GetWorldEventType`
`GetWorldName` | `GetWornBagForGameplayActorCategory` | `GetWornItemInfo` | `GetZoneActivityIdForZoneCompletionType`
`GetZoneDescription` | `GetZoneDescriptionById` | `GetZoneId` | `GetZoneIndex`
`GetZoneIndexByMapId` | `GetZoneNameById` | `GetZoneNameByIndex` | `GetZoneSkyshardId`
`GetZoneStoriesHelpIndices` | `GetZoneStoryActivityNameByActivityId` | `GetZoneStoryActivityNameByActivityIndex` | `GetZoneStoryGamepadBackground`
`GetZoneStoryKeyboardBackground` | `GetZoneStoryShortDescriptionByActivityId` | `GetZoneStoryZoneIdForZoneId` | `GroupDisband`
`GroupFinderUserTypeGroupListingClearDesiredRoles` | `GroupInvite` | `GroupInviteByName` | `GroupKick`
`GroupKickByName` | `GroupLeave` | `GroupPromote` | `GuiRender3DPositionToWorldPosition`
`GuildCreate` | `GuildDemote` | `GuildFinderGetNumSearchResults` | `GuildFinderGetSearchResultGuildId`
`GuildFinderIsSearchOnCooldown` | `GuildFinderRequestSearch` | `GuildInvite` | `GuildKioskBid`
`GuildKioskPurchase` | `GuildLeave` | `GuildPromote` | `GuildRemove`
`GuildSetRank` | `GuildUninvite`

### H

`HandleReturningPlayerUISystemShown` | `HasAcceptedLFGReadyCheck` | `HasAccessToSubclassing` | `HasActiveCampaignStarted`
`HasActiveCompanion` | `HasActiveEditControl` | `HasActivityFindReplacementNotification` | `HasAgreedToEULA`
`HasAllianceLockPendingNotification` | `HasAnyEditingPermissionsForCurrentHouse` | `HasAnyJunk` | `HasAnyUnlockedCollectiblesAvailableToActorCategoryByCategoryType`
`HasAnyUnlockedCollectiblesByCategoryType` | `HasAutoMapNavigationTarget` | `HasBlockedCompanion` | `HasClaimedAccountReward`
`HasCompletedFastTravelNodePOI` | `HasCompletedQuest` | `HasCraftBagAccess` | `HasCraftBagAutoTransferNotification`
`HasEsoPlusFreeTrialNotification` | `HasExpiringMarketCurrency` | `HasExpiringMarketCurrencyNotification` | `HasFishInBag`
`HasGroupFinderFilterChanged` | `HasGroupListingForUserType` | `HasGuildRecruitmentDataChanged` | `HasItemInSlot`
`HasItemToImproveForWrit` | `HasLFGReadyCheckNotification` | `HasMountSkin` | `HasPendingAcceptedGroupFinderApplication`
`HasPendingCompanion` | `HasPendingGroupElectionVote` | `HasPendingHeraldryChanges` | `HasPendingLevelUpReward`
`HasPermissionSettingForCurrentHouse` | `HasPlayerConfirmedEndlessDungeonCompanionSummoning` | `HasPoisonInBag` | `HasQuest`
`HasRaidEnded` | `HasReceivedPromotionalEventUpdate` | `HasSeenTutorial` | `HasShownMarketAnnouncement`
`HasShownReturningPlayerAnnouncement` | `HasSuppressedCompanion` | `HasSynergyEffects` | `HasTeamWonBattlegroundEarly`
`HasTradingHouseListings` | `HasUnreadMail` | `HasUnreceivedMail` | `HasUpcomingLevelUpReward`
`HasUserTypeGroupListingChanged` | `HasViewedEULA` | `HashString` | `HideMouse`
`HousingEditorAdjustPrecisionEditingPosition` | `HousingEditorAdjustSelectedObjectRotation` | `HousingEditorAlignFurnitureToSurface` | `HousingEditorAlignSelectedObjectToSurface`
`HousingEditorAlignSelectedPathNodeToSurface` | `HousingEditorBeginLinkingTargettedFurniture` | `HousingEditorBeginPlaceNewPathNode` | `HousingEditorCalculateRotationAboutAxis`
`HousingEditorCanCollectibleBePathed` | `HousingEditorCanFurnitureBePathed` | `HousingEditorCanPlaceCollectible` | `HousingEditorCanRemoveAllChildrenFromPendingFurniture`
`HousingEditorCanRemoveParentFromPendingFurniture` | `HousingEditorCanSelectTargettedFurniture` | `HousingEditorClipLineSegmentToViewFrustum` | `HousingEditorCreateCollectibleFurnitureForPlacement`
`HousingEditorCreateFurnitureForPlacementFromMarketProduct` | `HousingEditorCreateItemFurnitureForPlacement` | `HousingEditorCycleTarget` | `HousingEditorEditTargettedFurniturePath`
`HousingEditorEndCurrentPreview` | `HousingEditorEndLocalPlayerPairedFurnitureInteraction` | `HousingEditorGetFurnitureLocalBounds` | `HousingEditorGetFurnitureOrientation`
`HousingEditorGetFurniturePathFollowType` | `HousingEditorGetFurniturePathState` | `HousingEditorGetFurnitureWorldBounds` | `HousingEditorGetFurnitureWorldCenter`
`HousingEditorGetFurnitureWorldOffset` | `HousingEditorGetFurnitureWorldPosition` | `HousingEditorGetLinkRelationshipFromSelectedChildToPendingFurniture` | `HousingEditorGetNumCyclableTargets`
`HousingEditorGetNumPathNodesForFurniture` | `HousingEditorGetNumPathNodesInSelectedFurniture` | `HousingEditorGetPathNodeDelayTimeFromValue` | `HousingEditorGetPathNodeOrientation`
`HousingEditorGetPathNodeValueFromDelayTime` | `HousingEditorGetPathNodeWorldPosition` | `HousingEditorGetPendingBadLinkResult` | `HousingEditorGetPlacementType`
`HousingEditorGetPrecisionMoveUnits` | `HousingEditorGetPrecisionPlacementMode` | `HousingEditorGetPrecisionRotateUnits` | `HousingEditorGetRetrieveToBag`
`HousingEditorGetScreenPointWorldPlaneIntersection` | `HousingEditorGetSelectedFurnitureId` | `HousingEditorGetSelectedFurniturePathConformToGround` | `HousingEditorGetSelectedFurniturePathFollowType`
`HousingEditorGetSelectedFurniturePathState` | `HousingEditorGetSelectedFurnitureStackCount` | `HousingEditorGetSelectedFurnitureYAxisRotationOffset` | `HousingEditorGetSelectedObjectOrientation`
`HousingEditorGetSelectedObjectWorldCenter` | `HousingEditorGetSelectedObjectWorldPosition` | `HousingEditorGetSelectedOrTargetObjectDistanceM` | `HousingEditorGetSelectedPathNodeDelayTime`
`HousingEditorGetSelectedPathNodeFurnitureId` | `HousingEditorGetSelectedPathNodeIndex` | `HousingEditorGetSelectedPathNodeSpeed` | `HousingEditorGetStartingNodeIndexForPath`
`HousingEditorGetTargetInfo` | `HousingEditorHasSelectablePathNode` | `HousingEditorIsLocalPlayerInPairedFurnitureInteraction` | `HousingEditorIsPlacingNewNode`
`HousingEditorIsPreviewInspectionEnabled` | `HousingEditorIsSelectingHousingObject` | `HousingEditorIsSurfaceDragModeEnabled` | `HousingEditorJumpToSafeLocation`
`HousingEditorMoveSelectedObject` | `HousingEditorPathNodeDelayTime` | `HousingEditorPathNodeSpeed` | `HousingEditorPerformPendingLinkOperation`
`HousingEditorPreviewTemplate` | `HousingEditorPushSelectedObject` | `HousingEditorReleaseSelectedPathNode` | `HousingEditorRemoveAllChildrenFromPendingFurniture`
`HousingEditorRemoveParentFromPendingFurniture` | `HousingEditorRequestChangeFurniturePathData` | `HousingEditorRequestChangeOrientation` | `HousingEditorRequestChangePosition`
`HousingEditorRequestChangePositionAndOrientation` | `HousingEditorRequestChangeState` | `HousingEditorRequestClearFurnitureParent` | `HousingEditorRequestCollectiblePlacement`
`HousingEditorRequestInsertPathNode` | `HousingEditorRequestItemPlacement` | `HousingEditorRequestKickOccupant` | `HousingEditorRequestModeChange`
`HousingEditorRequestModifyPathNode` | `HousingEditorRequestPlaceSelectedPathNode` | `HousingEditorRequestRemoveFurniture` | `HousingEditorRequestRemovePathNode`
`HousingEditorRequestRemoveSelectedFurniture` | `HousingEditorRequestRemoveSelectedPathNode` | `HousingEditorRequestReplacePathCollectible` | `HousingEditorRequestResetEngagedTargetDummies`
`HousingEditorRequestRestartAllFurniturePaths` | `HousingEditorRequestSelectedPlacement` | `HousingEditorRequestSetFurnitureParent` | `HousingEditorRequestSetStartingNodeIndex`
`HousingEditorRotatePathNode` | `HousingEditorRotateSelectedObject` | `HousingEditorSelectFurnitureById` | `HousingEditorSelectPathNodeByIndex`
`HousingEditorSelectTargetUnderReticle` | `HousingEditorSelectTargettedFurniture` | `HousingEditorSelectTargettedPathNode` | `HousingEditorSetPlacementType`
`HousingEditorSetPrecisionMoveUnits` | `HousingEditorSetPrecisionPlacementMode` | `HousingEditorSetPrecisionRotateUnits` | `HousingEditorSetPreviewInspectionEnabled`
`HousingEditorSetRetrieveToBag` | `HousingEditorSetSelectedFurniturePathFollowType` | `HousingEditorStraightenSelectedObject` | `HousingEditorTogglePlacementType`
`HousingEditorTogglePrecisionPlacementMode` | `HousingEditorTogglePreviewInspectionEnabled` | `HousingEditorToggleSelectedFurniturePathConformToGround` | `HousingEditorToggleSelectedFurniturePathState`
`HousingEditorToggleSelectedPathNodeDelayTime` | `HousingEditorToggleSelectedPathNodeSpeed` | `HousingEditorToggleSurfaceDragMode`

### I

`Id64ToNumber` | `Id64ToString` | `ImproveSmithingItem` | `InitializePendingDyes`
`InitializePendingGuildRanks` | `InsertActionLayerByName` | `InsertNamedActionLayerAbove` | `InviteToTributeByDisplayName`
`Is64BitClient` | `IsAbilityDurationToggled` | `IsAbilityPassive` | `IsAbilityPermanent`
`IsAbilityUltimate` | `IsAchievementComplete` | `IsActionBarRespeccable` | `IsActionLayerActiveByName`
`IsActionLayerTopLayerByName` | `IsActionSlotLocked` | `IsActionSlotMutable` | `IsActionSlotRestricted`
`IsActiveAbilityHotBarCategory` | `IsActiveCombatRelatedEquipmentSlot` | `IsActiveDisplayEnabledOnPlatform` | `IsActiveSpectacleEventPhaseTransitionEnabled`
`IsActiveWorldBattleground` | `IsActiveWorldGroupOwnable` | `IsActiveWorldStarterWorld` | `IsActivityAvailableFromPlayerLocation`
`IsActivityEligibleForDailyReward` | `IsAgentChatActive` | `IsAlchemyItemTraitKnown` | `IsAlchemySolvent`
`IsAlchemySolventForItemAndMaterialId` | `IsAltKeyDown` | `IsAntiquityRepeatable` | `IsAnyGroupMemberInDungeon`
`IsAnyPromotionalEventCampaignRewardClaimable` | `IsAnyVideoPlaying` | `IsArmorEffectivenessReduced` | `IsAssignedBattlegroundContext`
`IsAwaitingCraftingProcessResponse` | `IsBankOpen` | `IsBankUpgradeAvailable` | `IsBattlegroundObjective`
`IsBlockActive` | `IsCapsLockOn` | `IsCaptureAreaObjectiveCaptured` | `IsCarryableObjectiveCarriedByLocalPlayer`
`IsChamberSolved` | `IsChampionSkillClusterRoot` | `IsChampionSkillRootNode` | `IsChampionSystemUnlocked`
`IsChannelCategoryCommunicationRestricted` | `IsChapterContentPass` | `IsChapterOwned` | `IsChapterPreRelease`
`IsCharacterInGroup` | `IsCharacterPreviewingAvailable` | `IsCharmAbility` | `IsChatBubbleCategoryEnabled`
`IsChatContainerTabCategoryEnabled` | `IsChatLogEnabled` | `IsChatSystemAvailableForCurrentPlatform` | `IsChromaSystemAvailable`
`IsCollectibleActive` | `IsCollectibleAvailableToActorCategory` | `IsCollectibleBlacklisted` | `IsCollectibleBlocked`
`IsCollectibleCategoryFavoritable` | `IsCollectibleCategoryPlaceableFurniture` | `IsCollectibleCategorySlottable` | `IsCollectibleCategoryTypeSetToDefault`
`IsCollectibleCategoryUsable` | `IsCollectibleDynamicallyHidden` | `IsCollectibleNew` | `IsCollectibleOwnedByDefId`
`IsCollectiblePresentInEffectivelyEquippedOutfit` | `IsCollectiblePurchasable` | `IsCollectibleRenameable` | `IsCollectibleSlottable`
`IsCollectibleTributePatronBookCardUpgraded` | `IsCollectibleUnlocked` | `IsCollectibleUsable` | `IsCollectibleValidForPlayer`
`IsCommandKeyDown` | `IsCommunicationRestricted` | `IsCommunicationRestrictedAccount` | `IsCompanionAbilityUnlocked`
`IsConsoleUI` | `IsConsolidatedSmithingItemSetIdUnlocked` | `IsConsolidatedSmithingSetIndexUnlocked` | `IsControlKeyDown`
`IsCountSingularForm` | `IsCraftedAbilityDisabled` | `IsCraftedAbilityScribed` | `IsCraftedAbilityScriptActive`
`IsCraftedAbilityScriptCompatibleWithSelections` | `IsCraftedAbilityScriptDisabled` | `IsCraftedAbilityScriptUnlocked` | `IsCraftedAbilitySkill`
`IsCraftedAbilityUnlocked` | `IsCreatingHeraldryForFirstTime` | `IsCurrencyCapped` | `IsCurrencyDefaultNameLowercase`
`IsCurrencyValid` | `IsCurrentActiveSpectacleEventPhaseComplete` | `IsCurrentBattlegroundStateTimed` | `IsCurrentBindingDefault`
`IsCurrentCampaignVengeanceRuleset` | `IsCurrentHouseFavorite` | `IsCurrentHouseListed` | `IsCurrentHouseRecommended`
`IsCurrentLFGActivityComplete` | `IsCurrentlyCustomizingHeraldry` | `IsCurrentlyPreviewing` | `IsCurrentlyPreviewingFurnitureCollectible`
`IsCurrentlyPreviewingInventoryItem` | `IsCurrentlyPreviewingPlacedFurniture` | `IsCurrentlySearchingForGroup` | `IsCutsceneActive`
`IsDailyLoginRewardInCurrentMonthClaimed` | `IsDecoratedDisplayName` | `IsDeferredSettingLoaded` | `IsDeferredSettingLoading`
`IsDigSiteAssociatedWithTrackedAntiquity` | `IsDigSpotRadarLimited` | `IsDiggingActiveSkillUnlocked` | `IsDiggingGameActive`
`IsDiggingGameOver` | `IsDisplayNameInItemBoPAccountTable` | `IsDuelingDeath` | `IsDyeIndexKnown`
`IsESOPlusSubscriber` | `IsEncounterLogAbilityInfoInline` | `IsEncounterLogEnabled` | `IsEncounterLogVerboseFormat`
`IsEndlessDungeonCompleted` | `IsEndlessDungeonStarted` | `IsEnlightenedAvailableForAccount` | `IsEnlightenedAvailableForCharacter`
`IsEquipSlotVisualCategoryHidden` | `IsEquipable` | `IsFastTravelNodeAutoDiscovered` | `IsFeedbackGatheringEnabled`
`IsFriend` | `IsFurnitureVault` | `IsGUIResizing` | `IsGameCameraActive`
`IsGameCameraClickableFixture` | `IsGameCameraClickableFixtureActive` | `IsGameCameraInteractableUnitMonster` | `IsGameCameraPreferredTargetValid`
`IsGameCameraSiegeControlled` | `IsGameCameraUIModeActive` | `IsGameCameraUnitHighlightedAttackable` | `IsGameInWindowedMode`
`IsGamepadHelpOption` | `IsGamepadTouchpadActive` | `IsGamepadUISupported` | `IsGiftRecipientNameValid`
`IsGroupCompanionUnitTag` | `IsGroupCrossAlliance` | `IsGroupFinderFilterDefault` | `IsGroupFinderRoleChangeRequested`
`IsGroupFinderSearchListingActiveApplication` | `IsGroupFinderSearchOnCooldown` | `IsGroupListingApplicationPendingByCharacterId` | `IsGroupMemberInRemoteRegion`
`IsGroupMemberInSameInstanceAsPlayer` | `IsGroupMemberInSameLayerAsPlayer` | `IsGroupMemberInSameWorldAsPlayer` | `IsGroupModificationAvailable`
`IsGroupMountPassenger` | `IsGroupMountPassengerForTarget` | `IsGroupUsingVeteranDifficulty` | `IsGuildBankOpen`
`IsGuildBlacklistAccountNameValid` | `IsGuildHistoryEventRedacted` | `IsGuildHistoryRequestComplete` | `IsGuildHistoryRequestTargetingEvents`
`IsGuildMate` | `IsGuildRankGuildMaster` | `IsHouseBankBag` | `IsHouseDefaultAccessSettingValidForHouseToursListing`
`IsHouseListed` | `IsHouseToursListingFavoriteByIndex` | `IsHouseToursListingListedByIndex` | `IsHouseToursListingOnCooldown`
`IsHouseToursSearchOnCooldown` | `IsHousingEditorPreviewingMarketProductPlacement` | `IsHousingPermissionEnabled` | `IsHousingPermissionMarkedForDelete`
`IsId64EqualToNumber` | `IsIgnored` | `IsImperialCityCampaign` | `IsInAvAZone`
`IsInCampaign` | `IsInCyrodiil` | `IsInGamepadPreferredMode` | `IsInHousingEditorPlacementMode`
`IsInImperialCity` | `IsInJusticeEnabledZone` | `IsInLFGGroup` | `IsInOutlawZone`
`IsInReturningPlayerIntroWorld` | `IsInUI` | `IsInstanceEndlessDungeon` | `IsInstantUnlockRewardServiceToken`
`IsInstantUnlockRewardUpgrade` | `IsInteractVOPlaying` | `IsInteracting` | `IsInteractingWithMyAssistant`
`IsInteractingWithMyCompanion` | `IsInteractionCameraActive` | `IsInteractionPending` | `IsInteractionUsingInteractCamera`
`IsInternalBuild` | `IsItemAffectedByPairedPoison` | `IsItemBoPAndTradeable` | `IsItemBound`
`IsItemChargeable` | `IsItemConsumable` | `IsItemDyeable` | `IsItemEnchantable`
`IsItemEnchantment` | `IsItemFromCrownCrate` | `IsItemFromCrownStore` | `IsItemInArmory`
`IsItemJunk` | `IsItemLinkBook` | `IsItemLinkBookKnown` | `IsItemLinkBookPartOfCollection`
`IsItemLinkBound` | `IsItemLinkConsolidatedSmithingStation` | `IsItemLinkConsumable` | `IsItemLinkContainer`
`IsItemLinkCrafted` | `IsItemLinkEnchantingRune` | `IsItemLinkForcedNotDeconstructable` | `IsItemLinkFromCrownCrate`
`IsItemLinkFromCrownStore` | `IsItemLinkFurnitureRecipe` | `IsItemLinkLockedSetPiece` | `IsItemLinkOnlyUsableFromQuickslot`
`IsItemLinkPlaceableFurniture` | `IsItemLinkPrioritySell` | `IsItemLinkRecipeKnown` | `IsItemLinkReconstructed`
`IsItemLinkSetCollectionPiece` | `IsItemLinkStackable` | `IsItemLinkStolen` | `IsItemLinkUnique`
`IsItemLinkUniqueEquipped` | `IsItemLinkUsableOutsideVengeance` | `IsItemLinkVendorTrash` | `IsItemLinkVisuallyDisabledInVengeance`
`IsItemLockedSetPiece` | `IsItemNonCrownRepairKit` | `IsItemNonGroupRepairKit` | `IsItemPlaceableFurniture`
`IsItemPlayerLocked` | `IsItemPrioritySell` | `IsItemReconstructed` | `IsItemRepairKit`
`IsItemSellableOnTradingHouse` | `IsItemSetCollectionPieceUnlocked` | `IsItemSetCollectionSlotNew` | `IsItemSetCollectionSlotUnlocked`
`IsItemSoulGem` | `IsItemStolen` | `IsItemTraitKnownForRetraitResult` | `IsItemUsable`
`IsItemVisuallyDisabledInVengeance` | `IsJournalQuestInCurrentMapZone` | `IsJournalQuestIndexInTrackedZoneStory` | `IsJournalQuestStepEnding`
`IsJusticeEnabled` | `IsJusticeEnabledForZone` | `IsKeepPassable` | `IsKeepTravelBlockedByDaedricArtifact`
`IsKeepTypeCapturable` | `IsKeepTypeClaimable` | `IsKeepTypePassable` | `IsKeyCodeArrowKey`
`IsKeyCodeChordKey` | `IsKeyCodeGamepadKey` | `IsKeyCodeHoldKey` | `IsKeyCodeKeyboardKey`
`IsKeyCodeMouseKey` | `IsKeyboardHelpOption` | `IsKeyboardUISupported` | `IsKillOnSight`
`IsLFGAccountDisabled` | `IsLFGActivityDisabled` | `IsLFGActivitySetDisabled` | `IsLTODisabledForMarketProductCategory`
`IsLevelUpRewardChoiceSelected` | `IsLevelUpRewardMilestoneForLevel` | `IsLevelUpRewardValidForPlayer` | `IsLoadoutRoleEquippedAtIndex`
`IsLocalBattlegroundContext` | `IsLocalMailboxFull` | `IsLockedWeaponSlot` | `IsLooting`
`IsMacUI` | `IsMailReturnable` | `IsMapLocationTooltipLineVisible` | `IsMapLocationVisible`
`IsMaxTelvarStoneMultiplierThreshold` | `IsMinSpecMachine` | `IsMounted` | `IsMouseWithinClientArea`
`IsNearDuelBoundary` | `IsNewCharacterNotificationSuppressionActive` | `IsObjectiveEnabled` | `IsObjectiveObjectVisible`
`IsOutfitStyleArmor` | `IsOutfitStyleArmor` | `IsOutfitStyleWeapon` | `IsOwnerOfCurrentHouse`
`IsPendingInteractionConfirmationValid` | `IsPlacedInCampaign` | `IsPlayerActivated` | `IsPlayerAllowedToEditHeraldry`
`IsPlayerAllowedToOpenCrownCrates` | `IsPlayerClassSkillLineById` | `IsPlayerControllingSiegeWeapon` | `IsPlayerEmoteOverridden`
`IsPlayerEscortingRam` | `IsPlayerGroundTargeting` | `IsPlayerGuildMaster` | `IsPlayerInAvAWorld`
`IsPlayerInGroup` | `IsPlayerInGuild` | `IsPlayerInRaid` | `IsPlayerInRaidStagingArea`
`IsPlayerInReviveCounterRaid` | `IsPlayerInWerewolfForm` | `IsPlayerInsidePinArea` | `IsPlayerInteractingWithObject`
`IsPlayerMoving` | `IsPlayerStunned` | `IsPlayerTryingToMove` | `IsPreviewingMarketProduct`
`IsPreviewingReward` | `IsPrimaryHouse` | `IsPrivateFunction` | `IsProgrammableCameraActive`
`IsPromotionalEventSystemLocked` | `IsProtectedFunction` | `IsQueuedForCampaign` | `IsQueuedForCyclicRespawn`
`IsRaidInProgress` | `IsReadMailInfoReady` | `IsRestyleEquipmentSlotBound` | `IsRestyleSlotDataDyeable`
`IsRestyleSlotTypeDyeable` | `IsResurrectPending` | `IsReticleHidden` | `IsReturningPlayer`
`IsReturningPlayerPromotionalEventsCampaign` | `IsRuneKnown` | `IsSCTSlotEventTypeShown` | `IsScribableScriptCombinationForCraftedAbility`
`IsScribingEnabled` | `IsScryingInProgress` | `IsSettingDeferred` | `IsSettingTemplate`
`IsShiftKeyDown` | `IsSkillAbilityAutoGrant` | `IsSkillAbilityPassive` | `IsSkillAbilityPurchased`
`IsSkillAbilityUltimate` | `IsSkillBuildAdvancedMode` | `IsSlotItemConsumable` | `IsSlotSoulTrap`
`IsSlotToggled` | `IsSlotUsable` | `IsSlotUsed` | `IsSmithingCraftingType`
`IsSmithingStyleKnown` | `IsSmithingTraitItemValidForPattern` | `IsSmithingTraitKnownForPattern` | `IsSpectatorCameraActive`
`IsStoreEmpty` | `IsStuckFixPending` | `IsSubmitFeedbackSupported` | `IsSystemUsingHDR`
`IsTargetCyclingSupportedInCurrentHousingEditorMode` | `IsTargetSameAsLastValidTarget` | `IsTimedActivitySystemAvailable` | `IsTrackingDataAvailable`
`IsTradeItemBoPAndTradeable` | `IsTraitKnownForItem` | `IsTrespassing` | `IsTributeCardContract`
`IsTributeCardCurse` | `IsTributePatronNeutral` | `IsTributeTutorialGame` | `IsTutorialActionRequired`
`IsUnderArrest` | `IsUnderpopBonusEnabled` | `IsUnitActivelyEngaged` | `IsUnitAttackable`
`IsUnitBattleLeveled` | `IsUnitBeingResurrected` | `IsUnitChampion` | `IsUnitChampionBattleLeveled`
`IsUnitDead` | `IsUnitDeadOrReincarnating` | `IsUnitFalling` | `IsUnitFriend`
`IsUnitFriendlyFollower` | `IsUnitGroupLeader` | `IsUnitGrouped` | `IsUnitGuildKiosk`
`IsUnitIgnored` | `IsUnitInAir` | `IsUnitInCombat` | `IsUnitInDungeon`
`IsUnitInGroupSupportRange` | `IsUnitInspectableSiege` | `IsUnitInvulnerableGuard` | `IsUnitJusticeGuard`
`IsUnitLivestock` | `IsUnitOnline` | `IsUnitPlayer` | `IsUnitPvPFlagged`
`IsUnitReincarnating` | `IsUnitResurrectableByPlayer` | `IsUnitSoloOrGroupLeader` | `IsUnitSwimming`
`IsUnitUsingVeteranDifficulty` | `IsUnitWorldMapPositionBreadcrumbed` | `IsUserAdjustingClientWindow` | `IsValidAbilityForSlot`
`IsValidArmoryBuildName` | `IsValidCollectibleForSlot` | `IsValidCollectibleName` | `IsValidCraftedAbilityForSlot`
`IsValidEmoteForSlot` | `IsValidGroupFinderListingTitle` | `IsValidGuildName` | `IsValidHouseName`
`IsValidItemForSlot` | `IsValidItemForSlotByItemId` | `IsValidName` | `IsValidOutfitName`
`IsValidQuestIndex` | `IsValidQuestItemForSlot` | `IsValidQuickChatForSlot` | `IsVengeancePerkAtIndexDisabled`
`IsVengeancePerkAtSlotIndexDisabled` | `IsVengeancePerkDisabled` | `IsVirtualKeyboardOnScreen` | `IsWerewolfSkillLineById`
`IsZoneCollectibleLocked` | `IsZoneStoryActivityComplete` | `IsZoneStoryAssisted` | `IsZoneStoryComplete`
`IsZoneStoryStarted` | `IsZoneStoryTracked` | `IsZoneStoryZoneAvailable` | `ItemSetCollectionHasNewPieces`

### J

`JoinRespawnQueue` | `JumpToFriend` | `JumpToGroupLeader` | `JumpToGroupMember`
`JumpToGuildMember` | `JumpToHouse` | `JumpToSpecificHouse`

### L

`LaunderItem` | `LeaveBattleground` | `LeaveCampaignQueue` | `LocaleAwareToLower`
`LocaleAwareToUpper` | `LockCameraRotation` | `Logout` | `LootAll`
`LootCurrency` | `LootItemById` | `LootMoney`

### M

`MakeLevelUpRewardChoice` | `MakeRemoteSceneRequest` | `MapZoomOut` | `MarkAllianceLockPendingNotificationSeen`
`MarkEULAAsViewed` | `MarkReturningPlayerLeaveIntroPromptShown` | `MatchTradingHouseItemNames` | `MeetsAntiquityRequirementsForScrying`
`MeetsAntiquitySkillRequirementsForScrying`

### N

`NotifyThatFollowerFinishedFragmentTransition` | `NumberToId64`

### O

`OnMapUpdateComplete` | `OnSelectedDigToolChanged`

### P

`PingMap` | `PlainStringFind` | `PlayCrownCrateSpecificParticleSoundAndVibration` | `PlayCrownCrateTierSpecificParticleSoundAndVibration`
`PlayEmoteByIndex` | `PlayGiftClaimFanfare` | `PlayGiftThankedFanfare` | `PlayItemSound`
`PlayLootSound` | `PlaySound` | `PlayVideo` | `PlayVideoById`
`PlayerHasAttributeUpgrades` | `PopActionLayer` | `PrepareChampionPurchaseRequest` | `PrepareConsumeAttunableStationsMessage`
`PrepareDeconstructMessage` | `PrepareSkillPointAllocationRequest` | `PreviewCraftItem` | `PreviewDyeStamp`
`PreviewDyeStampByItemLink` | `PreviewInventoryItem` | `PreviewInventoryItemCollectibleAction` | `PreviewItemLink`
`PreviewPlacedFurniture` | `PreviewReward` | `PreviewRewardCollectibleAction` | `PreviewStoreEntry`
`PreviewStoreEntryCollectibleAction` | `PreviewTradingHouseSearchResultItem` | `PreviewTradingHouseSearchResultItemCollectibleAction` | `ProcessMapClick`
`PurchaseAttributes` | `PushActionLayerByName`

### Q

`QueryBattlegroundLeaderboardData` | `QueryCampaignLeaderboardData` | `QueryCampaignSelectionData` | `QueryEndlessDungeonLeaderboardData`
`QueryRaidLeaderboardData` | `QueryTributeLeaderboardData` | `QueueCOD` | `QueueCraftingErrorAfterResultReceived`
`QueueForCampaign` | `QueueItemAttachment` | `QueueMoneyAttachment` | `Quit`

### R

`ReadLoreBook` | `ReadMail` | `RedoLastHousingEditorCommand` | `RefreshCardsInCrownCrateNPCsHand`
`RefreshSettings` | `RegisterForAssignedCampaignData` | `RegisterForGroupAddOnDataBroadcastAuthKey` | `RejectFriendRequest`
`RejectGuildInvite` | `Release` | `ReleaseInteractionKeepForGuild` | `ReleaseKeepForGuild`
`ReloadUI` | `RemoveActionLayerByName` | `RemoveChatContainer` | `RemoveChatContainerTab`
`RemoveCollectibleNotification` | `RemoveCollectibleNotificationByCollectibleId` | `RemoveFriend` | `RemoveFromGuildBlacklist`
`RemoveHousingPermission` | `RemoveIgnore` | `RemoveLeaderboardScoreNotification` | `RemoveMapAntiquityDigSitePins`
`RemoveMapPin` | `RemoveMapPinsByType` | `RemoveMapPinsInRange` | `RemoveMapQuestPins`
`RemoveMapZoneStoryPins` | `RemovePendingFeedback` | `RemovePlayerWaypoint` | `RemoveQueuedItemAttachment`
`RemoveRallyPoint` | `RemoveScriptedEventInviteForQuest` | `RemoveTutorial` | `RenameCollectible`
`RenameOutfit` | `RepairAll` | `RepairItem` | `RepairItemWithRepairKit`
`ReplayLastInteractVO` | `ReplyToPendingInteraction` | `ReportFeedback` | `RequestAbandonAntiquity`
`RequestActiveTributeCampaignData` | `RequestAntiquityDiggingExit` | `RequestApplyToGroupListing` | `RequestBestowActiveSpectacleEventQuest`
`RequestBestowHousingStarterQuest` | `RequestCreateGroupListing` | `RequestCreateHouseToursListing` | `RequestDeleteHouseToursListing`
`RequestEditGroupListing` | `RequestEndCutscene` | `RequestEquipItem` | `RequestEventAnnouncements`
`RequestExpiringMarketCurrencyInfo` | `RequestFriend` | `RequestGroupFinderSearch` | `RequestGuildFinderAccountApplications`
`RequestGuildFinderAttributesForGuild` | `RequestGuildKioskActiveBids` | `RequestHouseToursSearch` | `RequestItemReconstruction`
`RequestItemTraitChange` | `RequestJournalQuestConditionAssistance` | `RequestJumpToHouse` | `RequestJumpToHousePreviewWithTemplate`
`RequestLoadDeferredSetting` | `RequestMarketAnnouncement` | `RequestMoreGuildHistoryEvents` | `RequestOfflineGuildMembers`
`RequestOpenHouseStore` | `RequestOpenMailbox` | `RequestOpenUnsafeURL` | `RequestPostItemOnTradingHouse`
`RequestPurchaseMarketProduct` | `RequestReadMail` | `RequestReadPendingNarrationTextToClient` | `RequestReadTextChatToClient`
`RequestRecommendCurrentHouse` | `RequestReframeLocalPlayerInGameCamera` | `RequestRemoveGroupListing` | `RequestResendGift`
`RequestResolveGroupListingApplication` | `RequestScribe` | `RequestScryingExit` | `RequestSetGroupFinderExpectingUpdates`
`RequestSetLoadoutRoleByIndex` | `RequestSetPerkSelectionForRoleByIndex` | `RequestShowMarketChapterUpgrade` | `RequestTradingHouseListings`
`RequestTributeCampaignData` | `RequestTributeClubData` | `RequestTributeExit` | `RequestTributeLeaderboardRank`
`RequestUnequipItem` | `RequestUpdateCurrentHouseFavoriteStatus` | `RequestUpdateHouseToursListing` | `RequestUpdateHouseToursListingFavoriteStatusByIndex`
`RescindGuildFinderApplication` | `ResearchSmithingTrait` | `ResetAllBindsToDefault` | `ResetAllTutorials`
`ResetCampaignHistoryWindow` | `ResetChatCategoryColorToDefault` | `ResetChatContainerColorsToDefault` | `ResetChatContainerTabToDefault`
`ResetChatFontSizeToDefault` | `ResetChatToDefaults` | `ResetChatter` | `ResetConsolePublicUserSettingsToDefault`
`ResetCraftedAbilityScriptSelectionOverride` | `ResetCustomerServiceTicket` | `ResetGamepadBindsToDefault` | `ResetGamepadDeadzonesToDefault`
`ResetGroupFinderFilterAndDraftDifficultyToDefault` | `ResetGroupFinderFilterOptionsToDefault` | `ResetHousingEditorTrackedFurnitureOrNode` | `ResetKeyboardBindsToDefault`
`ResetSCTDataToDefaults` | `ResetSettingToDefault` | `ResetToDefaultSettings` | `ResetVideoCancelConfirmation`
`RespawnAtForwardCamp` | `RespawnAtKeep` | `RespondToSendPartiallyOwnedGift` | `RestoreArmoryBuild`
`ReturnGift` | `ReturnMail` | `RevertToSavedHeraldry` | `Revive`

### S

`SaveArmoryBuild` | `SaveGuildRecruitmentPendingChanges` | `SaveLoadDialogResult` | `SavePendingGuildRanks`
`ScryForAntiquity` | `SelectChatterOption` | `SelectGuildBank` | `SelectPlayerStatus`
`SelectSkillBuild` | `SelectTitle` | `SelectTradingHouseGuildId` | `SellAllJunk`
`SellInventoryItem` | `SendAllCachedSettingMessages` | `SendAttributePointAllocationRequest` | `SendChampionPurchaseRequest`
`SendConsumeAttunableStationsMessage` | `SendCrownCrateOpenRequest` | `SendDeconstructMessage` | `SendLFMRequest`
`SendLeaderToFollowerSync` | `SendMail` | `SendOutfitChangeRequest` | `SendPledgeOfMaraResponse`
`SendSkillPointAllocationRequest` | `Set3DRenderSpaceToCurrentCamera` | `SetActiveConsolidatedSmithingSetByIndex` | `SetAdviseSkillLine`
`SetArmoryBuildIconIndex` | `SetArmoryBuildName` | `SetCVar` | `SetCameraOptionsPreviewModeEnabled`
`SetCenterScreenAnnounceNarrationQueueEnabled` | `SetChatBubbleCategoryEnabled` | `SetChatCategoryColor` | `SetChatContainerColors`
`SetChatContainerTabCategoryEnabled` | `SetChatContainerTabInfo` | `SetChatFontSize` | `SetChatLogEnabled`
`SetCollectibleCategoryTypeToDefault` | `SetCraftedAbilityScriptSelectionOverride` | `SetCrownCrateNPCVisible` | `SetCrownCrateUIMenuActive`
`SetCurrentQuickslot` | `SetCurrentVideoPlaybackVolume` | `SetCursorItemSoundsEnabled` | `SetCustomerServiceTicketAppliedGroupListingTarget`
`SetCustomerServiceTicketBody` | `SetCustomerServiceTicketCategory` | `SetCustomerServiceTicketGroupListingTarget` | `SetCustomerServiceTicketHouseListingCurrentHouseTarget`
`SetCustomerServiceTicketHouseListingTarget` | `SetCustomerServiceTicketIncludeScreenshot` | `SetCustomerServiceTicketItemTarget` | `SetCustomerServiceTicketItemTargetByLink`
`SetCustomerServiceTicketPlayerTarget` | `SetCustomerServiceTicketQuestTarget` | `SetEncounterLogAbilityInfoInline` | `SetEncounterLogEnabled`
`SetEncounterLogVerboseFormat` | `SetFishingLure` | `SetFlashWaitTime` | `SetFloatingMarkerGlobalAlpha`
`SetFloatingMarkerInfo` | `SetFrameInteractionTarget` | `SetFrameLocalPlayerInGameCamera` | `SetFrameLocalPlayerLookAtDistanceFactor`
`SetFrameLocalPlayerTarget` | `SetFramingScreenType` | `SetFriendNote` | `SetFullscreenEffect`
`SetGameCameraUIMode` | `SetGamepadChatFontSize` | `SetGamepadLeftStickConsumedByUI` | `SetGamepadRightStickConsumedByUI`
`SetGamepadVibration` | `SetGroupFinderFilterAutoAcceptRequests` | `SetGroupFinderFilterCategory` | `SetGroupFinderFilterChampionPoints`
`SetGroupFinderFilterEnforceRoles` | `SetGroupFinderFilterGroupSizeFlags` | `SetGroupFinderFilterPlaystyleFlags` | `SetGroupFinderFilterPrimaryOptionByIndex`
`SetGroupFinderFilterRequiresChampion` | `SetGroupFinderFilterRequiresInviteCode` | `SetGroupFinderFilterRequiresVOIP` | `SetGroupFinderFilterSecondaryOptionByIndex`
`SetGroupFinderGroupFilterSearchString` | `SetGroupFinderUserTypeGroupListingAutoAcceptRequests` | `SetGroupFinderUserTypeGroupListingCategory` | `SetGroupFinderUserTypeGroupListingChampionPoints`
`SetGroupFinderUserTypeGroupListingDescription` | `SetGroupFinderUserTypeGroupListingEnforceRoles` | `SetGroupFinderUserTypeGroupListingGroupSize` | `SetGroupFinderUserTypeGroupListingInviteCode`
`SetGroupFinderUserTypeGroupListingPlaystyle` | `SetGroupFinderUserTypeGroupListingPrimaryOption` | `SetGroupFinderUserTypeGroupListingRequiresChampion` | `SetGroupFinderUserTypeGroupListingRequiresInviteCode`
`SetGroupFinderUserTypeGroupListingRequiresVOIP` | `SetGroupFinderUserTypeGroupListingRoleCount` | `SetGroupFinderUserTypeGroupListingSecondaryOption` | `SetGroupFinderUserTypeGroupListingSecondaryOptionDefault`
`SetGroupFinderUserTypeGroupListingTitle` | `SetGuiHidden` | `SetGuildApplicationAttributeValue` | `SetGuildBlacklistNote`
`SetGuildDescription` | `SetGuildFinderActivityFilterValue` | `SetGuildFinderAllianceFilterValue` | `SetGuildFinderChampionPointsFilterValues`
`SetGuildFinderFocusSearchFilter` | `SetGuildFinderHasTradersSearchFilter` | `SetGuildFinderLanguageFilterValue` | `SetGuildFinderPersonalityFilterValue`
`SetGuildFinderPlayTimeFilters` | `SetGuildFinderRoleFilterValue` | `SetGuildFinderSizeFilterValue` | `SetGuildMemberNote`
`SetGuildMotD` | `SetGuildRecruitmentActivityValue` | `SetGuildRecruitmentEndTime` | `SetGuildRecruitmentHeaderMessage`
`SetGuildRecruitmentLanguage` | `SetGuildRecruitmentMinimumCP` | `SetGuildRecruitmentPersonality` | `SetGuildRecruitmentPrimaryFocus`
`SetGuildRecruitmentRecruitmentMessage` | `SetGuildRecruitmentRecruitmentStatus` | `SetGuildRecruitmentRoleValue` | `SetGuildRecruitmentSecondaryFocus`
`SetGuildRecruitmentStartTime` | `SetHealthWarningStage` | `SetHouseToursCategoryTypeFilter` | `SetHouseToursDisplayNameFilter`
`SetHouseToursHouseIdFilter` | `SetHouseToursTagFilter` | `SetHousingEditorTrackedFurnitureId` | `SetHousingEditorTrackedPathNode`
`SetHousingPermissionPreset` | `SetHousingPrimaryHouse` | `SetIgnoreNote` | `SetInteractionUsingInteractCamera`
`SetItemIsJunk` | `SetItemIsPlayerLocked` | `SetMapFloor` | `SetMapPinAssisted`
`SetMapPinContinuousPositionUpdate` | `SetMapQuestPinsTrackingLevel` | `SetMapToAutoMapNavigationTargetPosition` | `SetMapToDigSitePosition`
`SetMapToMapId` | `SetMapToMapListIndex` | `SetMapToPlayerLocation` | `SetMapToQuestCondition`
`SetMapToQuestStepEnding` | `SetMapToQuestZone` | `SetNameplateGamepadFont` | `SetNameplateKeyboardFont`
`SetOrClearCollectibleUserFlag` | `SetOverrideMusicMode` | `SetOverscanOffsets` | `SetPendingHeraldryIndices`
`SetPendingItemPost` | `SetPendingItemPurchase` | `SetPendingItemPurchaseByItemUniqueId` | `SetPendingSlotDyes`
`SetPinTint` | `SetPlayerConfirmedEndlessDungeonCompanionSummoning` | `SetPlayerWaypointByWorldLocation` | `SetPreviewDynamicFramingOpening`
`SetPreviewInEmptyWorld` | `SetPreviewingOutfitIndexInPreviewCollection` | `SetPreviewingUnequippedOutfitInPreviewCollection` | `SetRandomMountType`
`SetRestylePreviewMode` | `SetSCTAnimationOffsetX` | `SetSCTAnimationOffsetY` | `SetSCTCloudAnimationOverlapPercent`
`SetSCTEventVisualInfo` | `SetSCTEventVisualInfoHideWhenValueIsZero` | `SetSCTEventVisualInfoTextColor` | `SetSCTEventVisualInfoTextFontSizes`
`SetSCTEventVisualInfoTextFormat` | `SetSCTGamepadFont` | `SetSCTKeyboardFont` | `SetSCTSlotAnimationMinimumSpacing`
`SetSCTSlotAnimationTimeline` | `SetSCTSlotClamping` | `SetSCTSlotEventControlScales` | `SetSCTSlotEventTypeShown`
`SetSCTSlotEventVisualInfo` | `SetSCTSlotGamepadCloud` | `SetSCTSlotKeyboardCloud` | `SetSCTSlotPosition`
`SetSCTSlotSourceReputationTypes` | `SetSCTSlotTargetReputationTypes` | `SetSCTSlotZoomedInPosition` | `SetSavedDyeSetDyes`
`SetSessionIgnore` | `SetSetting` | `SetShouldRenderWorld` | `SetSpectatorCameraTargetIndex`
`SetSynergyPriorityOverride` | `SetTextChatNarrationQueueEnabled` | `SetTracked` | `SetTrackedAntiquityId`
`SetTrackedIsAssisted` | `SetTrackedZoneStoryAssisted` | `SetTradingHouseFilter` | `SetTradingHouseFilterRange`
`SetTutorialSeen` | `SetVeteranDifficulty` | `SetVideoCancelAllOnCancelAny` | `SetupDyeStampPreview`
`ShareQuest` | `ShouldAbilityShowAsUsableWithDuration` | `ShouldAbilityShowStacks` | `ShouldActivityForceFullPanelKeyboard`
`ShouldActivitySetForceFullPanelKeyboard` | `ShouldDisplayGuildMemberRemoveAlert` | `ShouldDisplaySelfKickedFromGuildAlert` | `ShouldHideTooltipRequiredLevel`
`ShouldKeyCodeUseKeyMarkup` | `ShouldMapShowPriorityFastTravelOnly` | `ShouldPromotionalEventCampaignBeVisible` | `ShouldShowAdvancedUIErrors`
`ShouldShowCurrencyInCurrencyPanel` | `ShouldShowCurrencyInLootHistory` | `ShouldShowDLSSSetting` | `ShouldShowEULA`
`ShouldShowFSRSetting` | `ShouldShowLeaderboardForBattlegroundLeaderboardType` | `ShouldShowReturningPlayerLeaveIntroPrompt` | `ShouldUseFallbackReward`
`ShouldWarnConsoleAddOnMemoryLimit` | `ShouldWarnConsoleAddOnSavedVariableLimit` | `ShowEsoPlusPage` | `ShowMarketAndSearch`
`ShowMarketProduct` | `ShowMouse` | `SlotSkillAbilityInSlot` | `SpectatorCameraTargetNext`
`SpectatorCameraTargetPrev` | `SplitString` | `StackBag` | `StartAchievementSearch`
`StartActivityFinderSearch` | `StartAntiquitySearch` | `StartBackgroundListFilter` | `StartCollectibleSearch`
`StartConsolidatedSmithingItemSetSearch` | `StartDyesSearch` | `StartHelpSearch` | `StartHeraldryCustomization`
`StartMapPinAnimation` | `StopAllMovement` | `StopMapPinAnimation` | `StowAllFurnitureItems`
`StowAllVirtualItems` | `StringToId64` | `SubmitCustomerServiceTicket` | `SubmitGuildFinderApplication`

### T

`TakeAllMailAttachmentsInCategory` | `TakeGift` | `TakeMailAttachedItems` | `TakeMailAttachedMoney`
`TakeMailAttachments` | `TakeScreenshot` | `ToggleFullScreen` | `ToggleGameCameraFirstPerson`
`TogglePlayerWield` | `ToggleShowIngameGui` | `TrackNextActivityForZoneStory` | `TrackPromotionalEventActivity`
`TrackedQuestPinForAssisted` | `TradeAccept` | `TradeAddItem` | `TradeCancel`
`TradeEdit` | `TradeInvite` | `TradeInviteAccept` | `TradeInviteByName`
`TradeInviteCancel` | `TradeInviteDecline` | `TradeRemoveItem` | `TradeSetMoney`
`TrainRiding` | `TransferChatContainerTab` | `TransferCurrency` | `TransferFromGuildBank`
`TransferToGuildBank` | `TravelToKeep` | `TributeMatchEndSummaryComplete` | `TriggerCrownCrateNPCAnimation`
`TriggerTutorial` | `TriggerTutorialWithParam` | `TriggerTutorialWithPosition` | `TryAutoTrackNextPromotionalEventActivity`
`TryAutoTrackNextPromotionalEventCampaign` | `TryClaimAllAvailablePromotionalEventCampaignRewards` | `TryClaimPromotionalEventActivityReward` | `TryClaimPromotionalEventCapstoneReward`
`TryClaimPromotionalEventMilestoneReward` | `TryCleanExistingGuildHistoryRequestParameters` | `TrySkipCurrentTributeTutorialStep`

### U

`UnassignCampaignForPlayer` | `UndecorateDisplayName` | `UndoLastHousingEditorCommand` | `UnequipOutfit`
`UnregisterForAssignedCampaignData` | `UpdateGroupFinderFilterOptions` | `UpdateGroupFinderUserTypeGroupListingOptions` | `UpdateSelectedLFGRole`
`UseCollectible` | `UseMountAsPassenger` | `UseQuestItem` | `UseQuestTool`

### V

`ViewGifts`

### W

`WasGamepadLeftStickConsumedByOverlay` | `WasLastInputGamepad` | `WasRaidSuccessful` | `WhatIsVisualSlotShowing`
`WorldPositionToGuiRender3DPosition` | `WouldChampionSkillNodeBeUnlocked` | `WouldCollectibleBeHidden` | `WouldEquipmentBeHidden`
`WouldOutfitBeHidden` | `WouldProcessMapClick`

### Z

`ZoGetOfficialGameLanguage` | `ZoGetOfficialGameLanguageDescriptor` | `ZoIsIgnoringPatcherLanguage` | `ZoIsOfficialLanguageSupported`
`ZoUTF8StringLength`


---

## Function Protection Levels

### Protection Level Summary

| Level | Description | Usage |
|-------|-------------|-------|
| **Public** | Can be called anytime | Default for most functions |
| **Protected** | Can only be called out of combat | Restricted during combat |
| **Private** | Cannot be called by addons | Internal use only |

### Function Count by Protection Level

| Protection Level | Count | Percentage |
|------------------|-------|------------|
| Public | 4124 | 100.0% |
| Protected | 0 | 0.0% |
| Private | 0 | 0.0% |

---

## Document Information

- **Source**: ESOUIDocumentation.txt
- **API Version**: 101048
- **Total Game API Functions**: 4124
- **Total Object API Classes**: 49
- **Total Object API Methods**: 1,071
- **Generated**: 2025

### Usage Notes

- Function signatures use ESO's type notation (e.g., `*string*`, `*integer*`, `*bool*`)
- Type annotations in brackets (e.g., `[Alliance|#Alliance]`) reference enum constants
- Optional parameters are typically indicated in the type
- Variable returns means the function can return different numbers of values
- Object API methods are called on specific object instances (e.g., `control:SetHidden(true)`)

