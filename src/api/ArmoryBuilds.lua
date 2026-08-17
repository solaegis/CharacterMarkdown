-- CharacterMarkdown - API Layer - Armory Builds
-- Abstraction for armory system builds and loadouts

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.armoryBuilds = {}

local api = CM.api.armoryBuilds
local table_insert = table.insert

-- =====================================================
-- HELPERS
-- =====================================================

local function MapEquipSlotState(equipSlotState)
    if not equipSlotState then
        return "UNKNOWN"
    end
    if ARMORY_BUILD_EQUIP_SLOT_STATE_VALID and equipSlotState == ARMORY_BUILD_EQUIP_SLOT_STATE_VALID then
        return "VALID"
    end
    if ARMORY_BUILD_EQUIP_SLOT_STATE_EMPTY and equipSlotState == ARMORY_BUILD_EQUIP_SLOT_STATE_EMPTY then
        return "EMPTY"
    end
    if ARMORY_BUILD_EQUIP_SLOT_STATE_MISSING and equipSlotState == ARMORY_BUILD_EQUIP_SLOT_STATE_MISSING then
        return "MISSING"
    end
    if ARMORY_BUILD_EQUIP_SLOT_STATE_INACCESSIBLE and equipSlotState == ARMORY_BUILD_EQUIP_SLOT_STATE_INACCESSIBLE then
        return "INACCESSIBLE"
    end
    return "UNKNOWN"
end

local function GetMundusStoneName(stoneId)
    if not stoneId or stoneId <= 0 then
        return nil
    end
    local name = CM.SafeCall(GetString, "SI_MUNDUSSTONE", stoneId)
    if name and name ~= "" then
        return name
    end
    return "Mundus Stone " .. tostring(stoneId)
end

local function ResolveAbilityInfo(abilityId, buildIndex, hotbarCategory)
    if not abilityId or abilityId <= 0 then
        return nil
    end

    local displayId = abilityId
    if GetEffectiveAbilityIdForAbilityOnHotbarForArmoryBuild then
        local effectiveId =
            CM.SafeCall(GetEffectiveAbilityIdForAbilityOnHotbarForArmoryBuild, abilityId, buildIndex, hotbarCategory)
        if effectiveId and effectiveId > 0 then
            displayId = effectiveId
        end
    end

    local name = CM.SafeCall(GetAbilityName, displayId, "player")
    local isCrafted = false
    local scripts = nil

    if (not name or name == "") and GetCraftedAbilityDisplayName then
        local craftedName = CM.SafeCall(GetCraftedAbilityDisplayName, displayId)
        if craftedName and craftedName ~= "" then
            name = craftedName
            isCrafted = true
            if GetCraftedAbilityActiveScriptIds then
                local ok, primaryId, secondaryId, tertiaryId =
                    CM.SafeCallMulti(GetCraftedAbilityActiveScriptIds, displayId)
                if ok then
                    scripts = {}
                    for _, scriptId in ipairs({ primaryId, secondaryId, tertiaryId }) do
                        if scriptId and scriptId > 0 then
                            local scriptName = CM.SafeCall(GetCraftedAbilityScriptDisplayName, scriptId)
                            table_insert(scripts, {
                                id = scriptId,
                                name = scriptName or ("Script " .. tostring(scriptId)),
                            })
                        end
                    end
                end
            end
        end
    end

    if not name or name == "" then
        name = "Unknown"
    end

    return {
        id = displayId,
        name = name,
        isCrafted = isCrafted,
        scripts = scripts,
    }
end

local function EnrichItemFromBagSlot(bagId, slotIndex)
    local itemInfo = CM.api.equipment and CM.api.equipment.GetItemInfo and CM.api.equipment.GetItemInfo(bagId, slotIndex)
    if not itemInfo then
        local link = CM.SafeCall(GetItemLink, bagId, slotIndex, LINK_STYLE_DEFAULT)
        if not link or link == "" then
            return nil
        end
        local itemName = CM.SafeCall(GetItemLinkName, link)
        return {
            name = itemName or "Unknown",
            link = link,
            setName = "-",
            quality = "Normal",
            qualityNumeric = 0,
            qualityEmoji = "⚪",
            trait = "None",
            enchantment = false,
            armorType = nil,
            weaponType = nil,
        }
    end

    local qualityNumeric = itemInfo.quality or 0
    local setName = "-"
    if itemInfo.set and itemInfo.set.hasSet and itemInfo.set.name and itemInfo.set.name ~= "" then
        setName = itemInfo.set.name
    end

    local traitName = "None"
    if itemInfo.trait and itemInfo.trait.name and itemInfo.trait.name ~= "" then
        traitName = itemInfo.trait.name
    end

    local enchantment = false
    if itemInfo.enchant and itemInfo.enchant.hasEnchant and itemInfo.enchant.name and itemInfo.enchant.name ~= "" then
        enchantment = itemInfo.enchant.name
    end

    local armorType = nil
    local weaponType = nil
    if itemInfo.link and itemInfo.link ~= "" then
        armorType = CM.SafeCall(GetItemLinkArmorType, itemInfo.link)
        weaponType = CM.SafeCall(GetItemLinkWeaponType, itemInfo.link)
    end

    return {
        name = itemInfo.name or "Unknown",
        link = itemInfo.link or "",
        setName = setName,
        quality = (CM.utils and CM.utils.GetQualityColor and CM.utils.GetQualityColor(qualityNumeric)) or "Normal",
        qualityNumeric = qualityNumeric,
        qualityEmoji = (CM.utils and CM.utils.GetQualityEmoji and CM.utils.GetQualityEmoji(qualityNumeric)) or "⚪",
        trait = traitName,
        enchantment = enchantment,
        armorType = armorType,
        weaponType = weaponType,
    }
end

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

function api.GetNumUnlocked()
    return CM.SafeCall(GetNumUnlockedArmoryBuilds) or 0
end

function api.GetMaxBuilds()
    if MAX_NUM_ARMORY_BUILDS and type(MAX_NUM_ARMORY_BUILDS) == "number" and MAX_NUM_ARMORY_BUILDS > 0 then
        return MAX_NUM_ARMORY_BUILDS
    end
    local maxBuilds = CM.SafeCall(function()
        return MAX_NUM_ARMORY_BUILDS
    end)
    if maxBuilds and type(maxBuilds) == "number" and maxBuilds > 0 then
        return maxBuilds
    end
    return 10
end

function api.GetBuildName(buildIndex)
    return CM.SafeCall(GetArmoryBuildName, buildIndex) or ""
end

function api.GetBuildIconIndex(buildIndex)
    return CM.SafeCall(GetArmoryBuildIconIndex, buildIndex) or 0
end

function api.GetBuildAttributePoints(buildIndex)
    local health = CM.SafeCall(GetArmoryBuildAttributeSpentPoints, buildIndex, ATTRIBUTE_HEALTH) or 0
    local magicka = CM.SafeCall(GetArmoryBuildAttributeSpentPoints, buildIndex, ATTRIBUTE_MAGICKA) or 0
    local stamina = CM.SafeCall(GetArmoryBuildAttributeSpentPoints, buildIndex, ATTRIBUTE_STAMINA) or 0

    if health > 0 or magicka > 0 or stamina > 0 then
        return {
            health = health,
            magicka = magicka,
            stamina = stamina,
        }
    end

    return {}
end

function api.GetBuildChampionPoints(buildIndex)
    local craft, warfare, fitness = 0, 0, 0
    for disciplineIndex = 1, 3 do
        local disciplineId = CM.SafeCall(GetChampionDisciplineId, disciplineIndex)
        if disciplineId then
            local spent = CM.SafeCall(GetArmoryBuildChampionSpentPointsByDiscipline, buildIndex, disciplineId) or 0
            if disciplineIndex == 1 then
                craft = spent
            elseif disciplineIndex == 2 then
                warfare = spent
            elseif disciplineIndex == 3 then
                fitness = spent
            end
        end
    end

    if craft > 0 or warfare > 0 or fitness > 0 then
        return {
            craft = craft,
            warfare = warfare,
            fitness = fitness,
            total = craft + warfare + fitness,
        }
    end

    return {}
end

function api.GetBuildEquipment(buildIndex)
    local equipment = {}
    local setCounts = {}
    local equipSlots = {
        EQUIP_SLOT_HEAD,
        EQUIP_SLOT_NECK,
        EQUIP_SLOT_CHEST,
        EQUIP_SLOT_SHOULDERS,
        EQUIP_SLOT_MAIN_HAND,
        EQUIP_SLOT_OFF_HAND,
        EQUIP_SLOT_WAIST,
        EQUIP_SLOT_LEGS,
        EQUIP_SLOT_FEET,
        EQUIP_SLOT_RING1,
        EQUIP_SLOT_RING2,
        EQUIP_SLOT_HAND,
        EQUIP_SLOT_BACKUP_MAIN,
        EQUIP_SLOT_BACKUP_OFF,
    }

    for _, slot in ipairs(equipSlots) do
        local success, equipSlotState, bagId, slotIndex =
            CM.SafeCallMulti(GetArmoryBuildEquipSlotInfo, buildIndex, slot)
        local state = success and MapEquipSlotState(equipSlotState) or "UNKNOWN"
        local slotName = (CM.utils and CM.utils.GetEquipSlotName and CM.utils.GetEquipSlotName(slot)) or ("Slot " .. tostring(slot))
        local emoji = (CM.utils and CM.utils.GetSlotEmoji and CM.utils.GetSlotEmoji(slot)) or "📦"

        local entry = {
            slot = slot,
            slotName = slotName,
            emoji = emoji,
            state = state,
            bagId = bagId,
            slotIndex = slotIndex,
        }

        if state == "VALID" and bagId and slotIndex then
            local enriched = EnrichItemFromBagSlot(bagId, slotIndex)
            if enriched then
                entry.name = enriched.name
                entry.link = enriched.link
                entry.setName = enriched.setName
                entry.quality = enriched.quality
                entry.qualityNumeric = enriched.qualityNumeric
                entry.qualityEmoji = enriched.qualityEmoji
                entry.trait = enriched.trait
                entry.enchantment = enriched.enchantment
                entry.armorType = enriched.armorType
                entry.weaponType = enriched.weaponType

                if enriched.setName and enriched.setName ~= "-" then
                    setCounts[enriched.setName] = (setCounts[enriched.setName] or 0) + 1
                end
            else
                entry.name = "(Unresolved item)"
                entry.setName = "-"
                entry.trait = "None"
                entry.quality = "Normal"
                entry.qualityEmoji = "⚪"
            end
        elseif state == "EMPTY" then
            entry.name = "[Empty]"
            entry.setName = "-"
            entry.trait = "-"
            entry.quality = "-"
            entry.qualityEmoji = "⚪"
        elseif state == "MISSING" then
            entry.name = "[Missing]"
            entry.setName = "-"
            entry.trait = "-"
            entry.quality = "-"
            entry.qualityEmoji = "⚪"
        elseif state == "INACCESSIBLE" then
            entry.name = "[Inaccessible]"
            entry.setName = "-"
            entry.trait = "-"
            entry.quality = "-"
            entry.qualityEmoji = "⚪"
        else
            entry.name = "[Unavailable]"
            entry.setName = "-"
            entry.trait = "-"
            entry.quality = "-"
            entry.qualityEmoji = "⚪"
        end

        table_insert(equipment, entry)
    end

    local sets = {}
    for setName, count in pairs(setCounts) do
        table_insert(sets, { name = setName, count = count })
    end
    table.sort(sets, function(a, b)
        if (a.count or 0) == (b.count or 0) then
            return (a.name or "") < (b.name or "")
        end
        return (a.count or 0) > (b.count or 0)
    end)

    return equipment, sets
end

function api.GetBuildHotbars(buildIndex)
    local hotbars = {}

    local firstNormal = 3
    local ultimateSlot = 8
    if CM.api.skills then
        if CM.api.skills.GetFirstNormalActionBarSlotIndex then
            firstNormal = CM.api.skills.GetFirstNormalActionBarSlotIndex() or firstNormal
        end
        if CM.api.skills.GetUltimateActionBarSlotIndex then
            ultimateSlot = CM.api.skills.GetUltimateActionBarSlotIndex() or ultimateSlot
        end
    end

    local barConfigs = {
        {
            id = 0,
            name = (CM.Constants and CM.Constants.BAR_NAMES and CM.Constants.BAR_NAMES.PRIMARY)
                or "Front Bar (Main Hand)",
            hotbarCategory = HOTBAR_CATEGORY_PRIMARY,
        },
        {
            id = 1,
            name = (CM.Constants and CM.Constants.BAR_NAMES and CM.Constants.BAR_NAMES.BACKUP)
                or "Back Bar (Backup)",
            hotbarCategory = HOTBAR_CATEGORY_BACKUP,
        },
    }

    for _, config in ipairs(barConfigs) do
        local bar = {
            id = config.id,
            name = config.name,
            category = config.hotbarCategory,
            abilities = {},
        }

        local displayIndex = 0
        for slotIndex = firstNormal, ultimateSlot - 1 do
            displayIndex = displayIndex + 1
            local abilityId = CM.SafeCall(GetArmoryBuildSlotBoundId, buildIndex, slotIndex, config.hotbarCategory)
            local abilityInfo = ResolveAbilityInfo(abilityId, buildIndex, config.hotbarCategory)
            if abilityInfo then
                table_insert(bar.abilities, {
                    index = displayIndex,
                    slot = slotIndex,
                    name = abilityInfo.name,
                    id = abilityInfo.id,
                    isUltimate = false,
                    isCrafted = abilityInfo.isCrafted or false,
                    scripts = abilityInfo.scripts,
                })
            else
                table_insert(bar.abilities, {
                    index = displayIndex,
                    slot = slotIndex,
                    name = "[Empty Slot]",
                    id = nil,
                    isUltimate = false,
                })
            end
        end

        local ultAbilityId = CM.SafeCall(GetArmoryBuildSlotBoundId, buildIndex, ultimateSlot, config.hotbarCategory)
        local ultInfo = ResolveAbilityInfo(ultAbilityId, buildIndex, config.hotbarCategory)
        if ultInfo then
            bar.ultimate = ultInfo.name
            bar.ultimateId = ultInfo.id
            bar.ultimateIsCrafted = ultInfo.isCrafted or false
            bar.ultimateScripts = ultInfo.scripts
        end

        table_insert(hotbars, bar)
    end

    return hotbars
end

function api.GetBuildMundusStones(buildIndex)
    local mundus = {}

    local primary = CM.SafeCall(GetArmoryBuildPrimaryMundusStone, buildIndex)
    if primary and primary > 0 then
        local primaryName = GetMundusStoneName(primary)
        if primaryName and primaryName ~= "" then
            mundus.primary = primaryName
        end
    end

    local secondary = CM.SafeCall(GetArmoryBuildSecondaryMundusStone, buildIndex)
    if secondary and secondary > 0 then
        local secondaryName = GetMundusStoneName(secondary)
        if secondaryName and secondaryName ~= "" then
            mundus.secondary = secondaryName
        end
    end

    return mundus
end

function api.GetBuildCurse(buildIndex)
    local curseType = CM.SafeCall(GetArmoryBuildCurseType, buildIndex)
    if curseType and curseType > 0 then
        if curseType == 1 then
            return "Vampire"
        elseif curseType == 2 then
            return "Werewolf"
        end
    end
    return nil
end

function api.GetBuildInfo(buildIndex)
    local name = api.GetBuildName(buildIndex)
    if not name or name == "" then
        return nil
    end

    local equipment, sets = api.GetBuildEquipment(buildIndex)

    return {
        index = buildIndex,
        name = name,
        iconIndex = api.GetBuildIconIndex(buildIndex),
        attributes = api.GetBuildAttributePoints(buildIndex),
        champion = api.GetBuildChampionPoints(buildIndex),
        equipment = equipment,
        sets = sets,
        hotbars = api.GetBuildHotbars(buildIndex),
        mundus = api.GetBuildMundusStones(buildIndex),
        curse = api.GetBuildCurse(buildIndex),
        skillPoints = CM.SafeCall(GetArmoryBuildSkillsTotalSpentPoints, buildIndex) or 0,
        outfitIndex = CM.SafeCall(GetArmoryBuildEquippedOutfitIndex, buildIndex) or 0,
    }
end

CM.DebugPrint("API", "ArmoryBuilds API module loaded")
