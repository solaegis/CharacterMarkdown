-- CharacterMarkdown - AI / Build-Coach compact export
-- Purpose-built paste schema for ChatGPT/Claude (not pretty profile docs)

local CM = CharacterMarkdown

local table_insert = table.insert
local table_concat = table.concat
local string_format = string.format
local tostring = tostring

CM.generators = CM.generators or {}

local EMPTY_SLOT_NAME = "[Empty Slot]"

-- =====================================================
-- HELPERS
-- =====================================================

local function SafeStr(value, fallback)
    if value == nil or value == "" then
        return fallback or ""
    end
    return tostring(value)
end

local function IsEmptyNotes(notes)
    if notes == nil then
        return true
    end
    local trimmed = tostring(notes):gsub("^%s+", ""):gsub("%s+$", "")
    return trimmed == ""
end

local function FormatNumber(n)
    if type(n) ~= "number" then
        return SafeStr(n, "0")
    end
    return string_format("%d", n)
end

local function GetWeaponLabelForBar(equipment, barId)
    if not equipment or not equipment.items then
        return nil
    end
    local targetSlot = (barId == 1) and EQUIP_SLOT_BACKUP_MAIN or EQUIP_SLOT_MAIN_HAND
    -- Fallback numeric slot indices used by ESO when globals missing in tests
    if not targetSlot then
        targetSlot = (barId == 1) and 20 or 4
    end
    for _, item in ipairs(equipment.items) do
        if item.slotIndex == targetSlot and item.name and item.name ~= "" then
            local label = item.name
            if item.weaponType and item.weaponType ~= 0 and GetWeaponTypeName then
                local ok, wtName = pcall(GetWeaponTypeName, item.weaponType)
                if ok and wtName and wtName ~= "" then
                    label = wtName
                end
            end
            return label
        end
    end
    return nil
end

local function AbilityIsEmpty(ability)
    if not ability then
        return true
    end
    if ability.id == nil or ability.id == 0 then
        return true
    end
    local name = ability.name or ""
    return name == "" or name == EMPTY_SLOT_NAME
end

-- =====================================================
-- GAPS (exported for unit tests)
-- =====================================================

--- Detect mechanical gaps from collected coach data. Facts only — no meta judgment.
-- @return gaps table of strings, intent table with notes/title/playStyle when present
function CM.generators.BuildCoachDetectGaps(data)
    data = data or {}
    local gaps = {}
    local intent = {}

    local skillBar = data.skillBar
    local bars = skillBar and (skillBar.bars or skillBar) or nil
    if bars and type(bars) == "table" then
        for _, bar in ipairs(bars) do
            local barName = SafeStr(bar.name, "Bar")
            local abilities = bar.abilities or {}
            for _, ability in ipairs(abilities) do
                if AbilityIsEmpty(ability) then
                    table_insert(
                        gaps,
                        string_format("Empty skill slot %s on %s", tostring(ability.index or "?"), barName)
                    )
                end
            end
            if not bar.ultimate or bar.ultimate == "" or bar.ultimate == "Empty" then
                table_insert(gaps, string_format("Empty ultimate on %s", barName))
            end
        end
    else
        table_insert(gaps, "No skill bars configured")
    end

    local equipment = data.equipment
    if equipment and equipment.sets and #equipment.sets > 0 then
        for _, setData in ipairs(equipment.sets) do
            local count = setData.count or 0
            local name = SafeStr(setData.name, "Unknown set")
            local setTypeName = setData.setTypeName and tostring(setData.setTypeName):lower() or ""
            local isMonster = setTypeName:find("monster", 1, true) ~= nil
                or name:lower():find("monster", 1, true) ~= nil
            if isMonster then
                if count > 0 and count < 2 then
                    table_insert(gaps, string_format("Incomplete monster set %s (%d/2)", name, count))
                end
            else
                if count > 0 and count < 5 then
                    table_insert(gaps, string_format("Incomplete set %s (%d/5)", name, count))
                end
            end
        end
    elseif not equipment or not equipment.items or #equipment.items == 0 then
        table_insert(gaps, "No equipment data")
    end

    local cpAvailable = (data.cp and data.cp.available) or 0
    if type(cpAvailable) == "number" and cpAvailable > 0 then
        table_insert(gaps, string_format("Unspent Champion Points: %d", cpAvailable))
    end

    local progression = data.progression or {}
    local unspentSkills = progression.unspentSkillPoints or progression.skillPoints or 0
    if type(unspentSkills) == "number" and unspentSkills > 0 then
        table_insert(gaps, string_format("Unspent skill points: %d", unspentSkills))
    elseif
        skillBar
        and skillBar.points
        and type(skillBar.points.unspent) == "number"
        and skillBar.points.unspent > 0
    then
        table_insert(gaps, string_format("Unspent skill points: %d", skillBar.points.unspent))
    end

    local unspentAttrs = progression.unspentAttributePoints or progression.attributePoints or 0
    if type(unspentAttrs) == "number" and unspentAttrs > 0 then
        table_insert(gaps, string_format("Unspent attribute points: %d", unspentAttrs))
    end

    local mundus = data.mundus
    local mundusName = mundus and (mundus.name or mundus.primary or (mundus.names and mundus.names[1]))
    if not mundus or mundus.active == false or not mundusName or mundusName == "" then
        table_insert(gaps, "No active Mundus stone")
    end

    local notes = data.customNotes or ""
    if IsEmptyNotes(notes) then
        table_insert(gaps, "Build Notes empty — add goals in settings for better AI advice")
    end

    local playStyle = data.playStyle or ""
    if playStyle == "" then
        table_insert(gaps, "Play Style unset — set one in settings for better AI advice")
    end

    if not IsEmptyNotes(notes) then
        intent.notes = tostring(notes)
    end
    local customTitle = data.customTitle or ""
    if customTitle ~= "" then
        intent.customTitle = customTitle
    end
    if playStyle ~= "" then
        intent.playStyle = playStyle
    end

    return gaps, intent
end

-- =====================================================
-- SECTION BUILDERS
-- =====================================================

local function AppendIdentity(parts, data)
    table_insert(parts, "## Identity\n\n")
    local c = data.character or {}
    local role = data.role and data.role.selected or nil
    local playStyle = data.playStyle or ""
    local customTitle = data.customTitle or ""
    local title = customTitle ~= "" and customTitle or (c.title or "")
    local mundus = data.mundus
    local mundusName = mundus and (mundus.name or mundus.primary or (mundus.names and mundus.names[1])) or "(none)"

    table_insert(parts, string_format("- **Name:** %s\n", SafeStr(c.name, "Unknown")))
    table_insert(parts, string_format("- **Class:** %s\n", SafeStr(c.class, "Unknown")))
    table_insert(parts, string_format("- **Race:** %s\n", SafeStr(c.race, "Unknown")))
    table_insert(parts, string_format("- **Level:** %s\n", FormatNumber(c.level or 0)))
    table_insert(parts, string_format("- **CP total:** %s\n", FormatNumber(c.cp or (data.cp and data.cp.total) or 0)))
    table_insert(parts, string_format("- **Mundus:** %s\n", SafeStr(mundusName, "(none)")))
    if role and role ~= "" and role ~= "None" then
        table_insert(parts, string_format("- **Role:** %s\n", role))
    end
    if playStyle ~= "" then
        table_insert(parts, string_format("- **Play style:** %s\n", playStyle))
    end
    if title ~= "" then
        table_insert(parts, string_format("- **Title:** %s\n", title))
    end
    if c.subclass and c.subclass.lines then
        local lineNames = {}
        for _, line in ipairs(c.subclass.lines) do
            if line.name then
                table_insert(lineNames, line.name)
            end
        end
        if #lineNames > 0 then
            table_insert(parts, string_format("- **Skill lines:** %s\n", table_concat(lineNames, ", ")))
        end
    end
    table_insert(parts, "\n")
end

local function AppendStats(parts, data)
    table_insert(parts, "## Stats snapshot\n\n")
    local s = data.stats or {}
    table_insert(parts, string_format("- **Health:** %s\n", FormatNumber(s.health)))
    table_insert(parts, string_format("- **Magicka:** %s\n", FormatNumber(s.magicka)))
    table_insert(parts, string_format("- **Stamina:** %s\n", FormatNumber(s.stamina)))
    table_insert(parts, string_format("- **Weapon damage:** %s\n", FormatNumber(s.weaponPower)))
    table_insert(parts, string_format("- **Spell damage:** %s\n", FormatNumber(s.spellPower)))
    table_insert(
        parts,
        string_format(
            "- **Weapon crit:** %s%% (%s)\n",
            FormatNumber(s.weaponCritChance),
            FormatNumber(s.weaponCritRating)
        )
    )
    table_insert(
        parts,
        string_format("- **Spell crit:** %s%% (%s)\n", FormatNumber(s.spellCritChance), FormatNumber(s.spellCritRating))
    )
    table_insert(parts, string_format("- **Physical pen:** %s\n", FormatNumber(s.physicalPenetration)))
    table_insert(parts, string_format("- **Spell pen:** %s\n", FormatNumber(s.spellPenetration)))
    table_insert(parts, string_format("- **Physical resist:** %s\n", FormatNumber(s.physicalResist)))
    table_insert(parts, string_format("- **Spell resist:** %s\n", FormatNumber(s.spellResist)))
    table_insert(parts, "\n")
end

local function AppendSkillBars(parts, data)
    table_insert(parts, "## Skill bars\n\n")
    local skillBar = data.skillBar
    local bars = skillBar and (skillBar.bars or skillBar) or nil
    if not bars or #bars == 0 then
        table_insert(parts, "*No skill bars configured*\n\n")
        return
    end

    for _, bar in ipairs(bars) do
        local barName = SafeStr(bar.name, "Bar")
        local weapon = GetWeaponLabelForBar(data.equipment, bar.id)
        if weapon then
            table_insert(parts, string_format("### %s — %s\n\n", barName, weapon))
        else
            table_insert(parts, string_format("### %s\n\n", barName))
        end
        local abilities = bar.abilities or {}
        for i = 1, 5 do
            local ability = abilities[i]
            local slotLabel = ability and ability.index or i
            local name = AbilityIsEmpty(ability) and "(empty)" or SafeStr(ability.name, "(empty)")
            table_insert(parts, string_format("%d. %s\n", slotLabel, name))
        end
        local ult = bar.ultimate
        if not ult or ult == "" or ult == "Empty" then
            table_insert(parts, "- **Ultimate:** (empty)\n\n")
        else
            table_insert(parts, string_format("- **Ultimate:** %s\n\n", ult))
        end
    end
end

local function AppendSetsGear(parts, data)
    table_insert(parts, "## Sets / gear\n\n")
    local equipment = data.equipment
    if not equipment then
        table_insert(parts, "*No equipment data*\n\n")
        return
    end

    if equipment.sets and #equipment.sets > 0 then
        table_insert(parts, "### Active sets\n\n")
        for _, setData in ipairs(equipment.sets) do
            table_insert(parts, string_format("- **%s:** %d pieces\n", SafeStr(setData.name, "?"), setData.count or 0))
        end
        table_insert(parts, "\n")
    end

    if equipment.items and #equipment.items > 0 then
        table_insert(parts, "### Loadout\n\n")
        table_insert(parts, "| Slot | Set | Trait | Enchant |\n")
        table_insert(parts, "|------|-----|-------|---------|\n")
        for _, item in ipairs(equipment.items) do
            local enchant = item.enchantment
            if enchant == false or enchant == nil or enchant == "" then
                enchant = "-"
            end
            table_insert(
                parts,
                string_format(
                    "| %s | %s | %s | %s |\n",
                    SafeStr(item.slotName, "?"),
                    SafeStr(item.setName, "-"),
                    SafeStr(item.trait, "-"),
                    SafeStr(enchant, "-")
                )
            )
        end
        table_insert(parts, "\n")
    else
        table_insert(parts, "*No equipped items*\n\n")
    end
end

local function CollectibleNamesList(collection)
    if not collection or not collection.list or #collection.list == 0 then
        return nil, 0
    end
    local names = {}
    for _, entry in ipairs(collection.list) do
        local name = entry and (entry.name or entry.fullName)
        if name and name ~= "" then
            table_insert(names, name)
        end
    end
    table.sort(names)
    return names, #names
end

local function AppendOwnedCollectibleLine(parts, label, collection)
    local names, count = CollectibleNamesList(collection)
    if not names or count == 0 then
        local reported = collection and (collection.count or 0) or 0
        table_insert(parts, string_format("- **%s (%d):** (none listed)\n", label, reported))
        return
    end
    table_insert(parts, string_format("- **%s (%d):** %s\n", label, count, table_concat(names, ", ")))
end

local function AppendCollectibles(parts, data)
    table_insert(parts, "## Collectibles\n\n")

    local appearance = data.appearance or {}
    local active = appearance.active or {}
    local mount = appearance.mount
    local hasActive = false

    table_insert(parts, "### Active\n\n")
    if mount and mount.name and mount.name ~= "" then
        table_insert(parts, string_format("- **Mount:** %s\n", mount.name))
        hasActive = true
    end
    if active.costume and active.costume.name and active.costume.name ~= "" then
        table_insert(parts, string_format("- **Costume:** %s\n", active.costume.name))
        hasActive = true
    end
    if active.pet and active.pet.name and active.pet.name ~= "" then
        table_insert(parts, string_format("- **Pet:** %s\n", active.pet.name))
        hasActive = true
    end
    if active.personality and active.personality.name and active.personality.name ~= "" then
        table_insert(parts, string_format("- **Personality:** %s\n", active.personality.name))
        hasActive = true
    end
    if not hasActive then
        table_insert(parts, "- (none reported)\n")
    end
    table_insert(parts, "\n")

    table_insert(parts, "### Owned (build-relevant)\n\n")
    local collections = data.collectibles and data.collectibles.collections or nil
    if not collections then
        table_insert(parts, "*No collectibles data*\n\n")
        return
    end
    AppendOwnedCollectibleLine(parts, "Mounts", collections.mounts)
    AppendOwnedCollectibleLine(parts, "Pets", collections.pets)
    AppendOwnedCollectibleLine(parts, "Costumes", collections.costumes)
    table_insert(parts, "\n")
end

local function AppendChampionPoints(parts, data)
    table_insert(parts, "## Champion Points\n\n")
    local cp = data.cp
    if not cp then
        table_insert(parts, "*No Champion Point data*\n\n")
        return
    end

    table_insert(parts, string_format("- **Total:** %s\n", FormatNumber(cp.total)))
    table_insert(parts, string_format("- **Unspent:** %s\n\n", FormatNumber(cp.available)))

    local disciplines = cp.disciplines or {}
    for _, disc in ipairs(disciplines) do
        local discName = SafeStr(disc.name, "Discipline")
        table_insert(parts, string_format("### %s (%s spent)\n\n", discName, FormatNumber(disc.spent or disc.assigned)))

        local slottables = disc.slottableSkills or {}
        if #slottables > 0 then
            table_insert(parts, "**Slotted:**\n")
            for _, skill in ipairs(slottables) do
                table_insert(parts, string_format("- %s (%s)\n", SafeStr(skill.name, "?"), FormatNumber(skill.points)))
            end
        else
            table_insert(parts, "*No slotted stars*\n")
        end

        local passives = disc.passiveSkills or {}
        if #passives > 0 then
            table_insert(parts, "\n**Passives (allocated):**\n")
            local shown = 0
            local totalAllocated = 0
            for _, skill in ipairs(passives) do
                if (skill.points or 0) > 0 then
                    totalAllocated = totalAllocated + 1
                end
            end
            for _, skill in ipairs(passives) do
                local pts = skill.points or 0
                if pts > 0 then
                    table_insert(parts, string_format("- %s (%s)\n", SafeStr(skill.name, "?"), FormatNumber(pts)))
                    shown = shown + 1
                    if shown >= 12 then
                        local remaining = totalAllocated - shown
                        if remaining > 0 then
                            table_insert(parts, string_format("- ... +%d more\n", remaining))
                        end
                        break
                    end
                end
            end
        end
        table_insert(parts, "\n")
    end
end

local function AppendNotes(parts, data)
    table_insert(parts, "## Notes\n\n")
    if IsEmptyNotes(data.customNotes) then
        table_insert(parts, "(empty)\n\n")
    else
        table_insert(parts, tostring(data.customNotes))
        if not tostring(data.customNotes):match("\n$") then
            table_insert(parts, "\n")
        end
        table_insert(parts, "\n")
    end
end

local function AppendGaps(parts, data)
    table_insert(parts, "## Gaps\n\n")
    local gaps, intent = CM.generators.BuildCoachDetectGaps(data)

    if #gaps == 0 then
        table_insert(parts, "- None detected\n")
    else
        for _, gap in ipairs(gaps) do
            table_insert(parts, string_format("- %s\n", gap))
        end
    end

    if intent.playStyle or intent.customTitle or intent.notes then
        table_insert(parts, "\n### Player intent\n\n")
        if intent.playStyle then
            table_insert(parts, string_format("- **Play style:** %s\n", intent.playStyle))
        end
        if intent.customTitle then
            table_insert(parts, string_format("- **Custom title:** %s\n", intent.customTitle))
        end
        if intent.notes then
            table_insert(parts, "- **Build notes:** (see Notes section)\n")
        end
    end
    table_insert(parts, "\n")
end

local function AppendCoachFooter(parts, data)
    local focus = data.playStyle
    if not focus or focus == "" then
        focus = data.role and data.role.selected
    end
    if not focus or focus == "" or focus == "None" then
        focus = "this character's role"
    end
    table_insert(
        parts,
        string_format("Ask: review this build for %s; prioritize concrete gear/skill/CP changes.\n", focus)
    )
end

-- =====================================================
-- PUBLIC API
-- =====================================================

--- Build compact coach markdown from collected data.
-- @param data table from CollectBuildCoachData
-- @return string markdown
function CM.generators.GenerateBuildCoachMarkdown(data)
    data = data or {}
    local parts = {
        "<!-- CharacterMarkdown build-coach v1 -->\n\n",
        "# Build Coach Export\n\n",
    }

    AppendIdentity(parts, data)
    AppendStats(parts, data)
    AppendSkillBars(parts, data)
    AppendSetsGear(parts, data)
    AppendCollectibles(parts, data)
    AppendChampionPoints(parts, data)
    AppendNotes(parts, data)
    AppendGaps(parts, data)
    AppendCoachFooter(parts, data)

    return table_concat(parts)
end
