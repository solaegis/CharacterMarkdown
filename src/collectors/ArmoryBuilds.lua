-- CharacterMarkdown - Armory Builds Data Collector
-- Armory system builds, loadouts, and build management

local CM = CharacterMarkdown

-- =====================================================
-- CONSTANTS
-- =====================================================

-- Equipment slots (based on ESO API)
local EQUIP_SLOT_HEAD = 0
local EQUIP_SLOT_NECK = 1
local EQUIP_SLOT_CHEST = 2
local EQUIP_SLOT_SHOULDERS = 3
local EQUIP_SLOT_MAIN_HAND = 4
local EQUIP_SLOT_OFF_HAND = 5
local EQUIP_SLOT_WAIST = 6
local EQUIP_SLOT_LEGS = 7
local EQUIP_SLOT_FEET = 8
local EQUIP_SLOT_COSTUME = 9
local EQUIP_SLOT_RING1 = 11
local EQUIP_SLOT_RING2 = 12
local EQUIP_SLOT_HAND = 13
local EQUIP_SLOT_BACKUP_MAIN = 20
local EQUIP_SLOT_BACKUP_OFF = 21

-- Attribute types
local ATTRIBUTE_HEALTH = 1
local ATTRIBUTE_MAGICKA = 2
local ATTRIBUTE_STAMINA = 3

-- Hotbar categories
local HOTBAR_CATEGORY_PRIMARY = 1
local HOTBAR_CATEGORY_BACKUP = 2

-- Champion Point disciplines
local CHAMPION_DISCIPLINE_CRAFT = 1
local CHAMPION_DISCIPLINE_WARFARE = 2
local CHAMPION_DISCIPLINE_FITNESS = 3

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Get attribute points for a build
local function GetBuildAttributePoints(buildIndex)
    local attributes = {}

    local health = CM.SafeCall(GetArmoryBuildAttributeSpentPoints, buildIndex, ATTRIBUTE_HEALTH) or 0
    local magicka = CM.SafeCall(GetArmoryBuildAttributeSpentPoints, buildIndex, ATTRIBUTE_MAGICKA) or 0
    local stamina = CM.SafeCall(GetArmoryBuildAttributeSpentPoints, buildIndex, ATTRIBUTE_STAMINA) or 0

    if health > 0 or magicka > 0 or stamina > 0 then
        attributes.health = health
        attributes.magicka = magicka
        attributes.stamina = stamina
    end

    return attributes
end

-- Get champion points for a build
local function GetBuildChampionPoints(buildIndex)
    local champion = {}

    local craft = CM.SafeCall(GetArmoryBuildChampionSpentPointsByDiscipline, buildIndex, CHAMPION_DISCIPLINE_CRAFT) or 0
    local warfare = CM.SafeCall(GetArmoryBuildChampionSpentPointsByDiscipline, buildIndex, CHAMPION_DISCIPLINE_WARFARE)
        or 0
    local fitness = CM.SafeCall(GetArmoryBuildChampionSpentPointsByDiscipline, buildIndex, CHAMPION_DISCIPLINE_FITNESS)
        or 0

    if craft > 0 or warfare > 0 or fitness > 0 then
        champion.craft = craft
        champion.warfare = warfare
        champion.fitness = fitness
        champion.total = craft + warfare + fitness
    end

    return champion
end

-- Get equipment slots for a build
local function GetBuildEquipment(buildIndex)
    local equipment = {}
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
        local itemLink = CM.SafeCall(GetArmoryBuildEquipSlotItemLinkInfo, buildIndex, slot)
        if itemLink and itemLink ~= "" then
            local itemName = CM.SafeCall(GetItemLinkName, itemLink)
            if itemName and itemName ~= "" then
                table.insert(equipment, {
                    slot = slot,
                    name = itemName,
                    link = itemLink,
                })
            end
        end
    end

    return equipment
end

-- Get hotbar abilities for a build
local function GetBuildHotbars(buildIndex)
    local hotbars = {}

    -- Primary bar
    local primaryBar = {
        category = HOTBAR_CATEGORY_PRIMARY,
        abilities = {},
    }
    for slotIndex = 3, 8 do -- Slots 3-8 are ability slots (skipping quick slots 1-2)
        local abilityId = CM.SafeCall(GetArmoryBuildSlotBoundId, buildIndex, slotIndex, HOTBAR_CATEGORY_PRIMARY)
        if abilityId and abilityId > 0 then
            local abilityName = CM.SafeCall(GetAbilityName, abilityId)
            if abilityName and abilityName ~= "" then
                table.insert(primaryBar.abilities, {
                    slot = slotIndex,
                    id = abilityId,
                    name = abilityName,
                })
            end
        end
    end
    if #primaryBar.abilities > 0 then
        table.insert(hotbars, primaryBar)
    end

    -- Backup bar
    local backupBar = {
        category = HOTBAR_CATEGORY_BACKUP,
        abilities = {},
    }
    for slotIndex = 3, 8 do
        local abilityId = CM.SafeCall(GetArmoryBuildSlotBoundId, buildIndex, slotIndex, HOTBAR_CATEGORY_BACKUP)
        if abilityId and abilityId > 0 then
            local abilityName = CM.SafeCall(GetAbilityName, abilityId)
            if abilityName and abilityName ~= "" then
                table.insert(backupBar.abilities, {
                    slot = slotIndex,
                    id = abilityId,
                    name = abilityName,
                })
            end
        end
    end
    if #backupBar.abilities > 0 then
        table.insert(hotbars, backupBar)
    end

    return hotbars
end

-- Get mundus stones for a build
local function GetBuildMundusStones(buildIndex)
    local mundus = {}

    local primary = CM.SafeCall(GetArmoryBuildPrimaryMundusStone, buildIndex)
    if primary and primary > 0 then
        local primaryName = CM.SafeCall(GetMundusStoneDisplayName, primary)
        if primaryName and primaryName ~= "" then
            mundus.primary = primaryName
        end
    end

    local secondary = CM.SafeCall(GetArmoryBuildSecondaryMundusStone, buildIndex)
    if secondary and secondary > 0 then
        local secondaryName = CM.SafeCall(GetMundusStoneDisplayName, secondary)
        if secondaryName and secondaryName ~= "" then
            mundus.secondary = secondaryName
        end
    end

    return mundus
end

-- Get curse type for a build
local function GetBuildCurse(buildIndex)
    local curseType = CM.SafeCall(GetArmoryBuildCurseType, buildIndex)
    if curseType and curseType > 0 then
        -- CURSE_TYPE_NONE = 0, CURSE_TYPE_VAMPIRE = 1, CURSE_TYPE_WEREWOLF = 2
        if curseType == 1 then
            return "Vampire"
        elseif curseType == 2 then
            return "Werewolf"
        end
    end
    return nil
end

-- =====================================================
-- ARMORY BUILDS COLLECTOR
-- =====================================================

local function CollectArmoryBuildsData()
    local armory = {
        unlocked = 0,
        builds = {},
    }

    -- Get number of unlocked armory build slots
    local numUnlocked = CM.SafeCall(GetNumUnlockedArmoryBuilds) or 0
    armory.unlocked = numUnlocked

    if numUnlocked == 0 then
        return armory
    end

    -- Iterate through all build slots
    for buildIndex = 1, numUnlocked do
        local buildName = CM.SafeCall(GetArmoryBuildName, buildIndex)

        -- Check if build slot has a name (is configured)
        if buildName and buildName ~= "" then
            local buildData = {
                index = buildIndex,
                name = buildName,
                iconIndex = CM.SafeCall(GetArmoryBuildIconIndex, buildIndex) or 0,
                attributes = GetBuildAttributePoints(buildIndex),
                champion = GetBuildChampionPoints(buildIndex),
                equipment = GetBuildEquipment(buildIndex),
                hotbars = GetBuildHotbars(buildIndex),
                mundus = GetBuildMundusStones(buildIndex),
                curse = GetBuildCurse(buildIndex),
                skillPoints = CM.SafeCall(GetArmoryBuildSkillsTotalSpentPoints, buildIndex) or 0,
                outfitIndex = CM.SafeCall(GetArmoryBuildEquippedOutfitIndex, buildIndex) or 0,
            }

            table.insert(armory.builds, buildData)
        end
    end

    -- Sort builds by name
    if #armory.builds > 0 then
        table.sort(armory.builds, function(a, b)
            return a.name < b.name
        end)
    end

    return armory
end

-- =====================================================
-- MAIN ARMORY BUILDS COLLECTOR
-- =====================================================

local function CollectArmoryBuildsDataMain()
    return {
        armory = CollectArmoryBuildsData(),
    }
end

CM.collectors.CollectArmoryBuildsData = CollectArmoryBuildsDataMain
