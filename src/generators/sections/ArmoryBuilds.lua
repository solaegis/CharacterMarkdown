-- CharacterMarkdown - Armory Builds Section Generator
-- Generates armory builds markdown sections (alternate loadouts without restoring)

local CM = CharacterMarkdown

local table_insert = table.insert
local table_concat = table.concat
local string_format = string.format

-- Cache for utility functions (lazy-initialized on first use)
local FormatNumber, GenerateAnchor, CreateSetLink, CreateAbilityLink

local function InitializeUtilities()
    if not FormatNumber then
        if CM.utils then
            FormatNumber = CM.utils.FormatNumber
        end
        GenerateAnchor = CM.utils and CM.utils.markdown and CM.utils.markdown.GenerateAnchor
        CreateSetLink = CM.links and CM.links.CreateSetLink
        CreateAbilityLink = CM.links and CM.links.CreateAbilityLink
    end
end

local REGULAR_ABILITY_SLOTS = 5

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

local function FormatAttributes(attributes)
    if not attributes or (not attributes.health and not attributes.magicka and not attributes.stamina) then
        return "Not configured"
    end

    local parts = {}
    if (attributes.health or 0) > 0 then
        table_insert(parts, attributes.health .. " Health")
    end
    if (attributes.magicka or 0) > 0 then
        table_insert(parts, attributes.magicka .. " Magicka")
    end
    if (attributes.stamina or 0) > 0 then
        table_insert(parts, attributes.stamina .. " Stamina")
    end

    return table_concat(parts, ", ")
end

local function FormatChampionPoints(champion)
    if not champion or not champion.total or champion.total == 0 then
        return "Not configured"
    end

    local parts = {}
    if (champion.craft or 0) > 0 then
        table_insert(parts, champion.craft .. " Craft")
    end
    if (champion.warfare or 0) > 0 then
        table_insert(parts, champion.warfare .. " Warfare")
    end
    if (champion.fitness or 0) > 0 then
        table_insert(parts, champion.fitness .. " Fitness")
    end

    return champion.total .. " total (" .. table_concat(parts, ", ") .. ")"
end

local function FormatMundusStones(mundus)
    if not mundus or (not mundus.primary and not mundus.secondary) then
        return "None"
    end

    local parts = {}
    if mundus.primary then
        table_insert(parts, mundus.primary)
    end
    if mundus.secondary then
        table_insert(parts, mundus.secondary .. " (Secondary)")
    end

    return table_concat(parts, ", ")
end

local function FormatItemType(item)
    if item.armorType then
        local success, armorTypeName = pcall(GetString, "SI_ARMORTYPE", item.armorType)
        if success and armorTypeName and armorTypeName ~= "" then
            return armorTypeName
        end
    end
    if item.weaponType then
        local success, weaponTypeName = pcall(GetString, "SI_WEAPONTYPE", item.weaponType)
        if success and weaponTypeName and weaponTypeName ~= "" then
            return weaponTypeName
        end
    end
    return "-"
end

local function FormatAbilityCell(ability)
    if ability and type(ability) == "table" then
        local abilityName = ability.name or "[Empty Slot]"
        if ability.id and CreateAbilityLink then
            local success, abText = pcall(CreateAbilityLink, abilityName, ability.id)
            if success and abText then
                abilityName = abText
            end
        end
        if ability.scripts and #ability.scripts > 0 then
            local scriptNames = {}
            for _, script in ipairs(ability.scripts) do
                if script.name then
                    table_insert(scriptNames, script.name)
                end
            end
            if #scriptNames > 0 then
                abilityName = abilityName .. "<br>*(" .. table_concat(scriptNames, " / ") .. ")*"
            end
        end
        return abilityName
    end
    return "[Empty Slot]"
end

local function FormatUltimateCell(bar)
    local ultText = "[Empty]"
    if bar.ultimate and bar.ultimate ~= "" then
        if CreateAbilityLink and bar.ultimateId then
            local success, linked = pcall(CreateAbilityLink, bar.ultimate, bar.ultimateId)
            if success and linked then
                ultText = linked
            else
                ultText = bar.ultimate
            end
        else
            ultText = bar.ultimate
        end
        if bar.ultimateScripts and #bar.ultimateScripts > 0 then
            local scriptNames = {}
            for _, script in ipairs(bar.ultimateScripts) do
                if script.name then
                    table_insert(scriptNames, script.name)
                end
            end
            if #scriptNames > 0 then
                ultText = ultText .. "<br>*(" .. table_concat(scriptNames, " / ") .. ")*"
            end
        end
    end
    return ultText
end

local function BarHasSlottedContent(bar)
    if bar.ultimate and bar.ultimate ~= "" then
        return true
    end
    for i = 1, REGULAR_ABILITY_SLOTS do
        local ability = bar.abilities and bar.abilities[i]
        if ability and ability.id and ability.id > 0 then
            return true
        end
        if ability and ability.name and ability.name ~= "[Empty Slot]" and ability.name ~= "Empty" then
            return true
        end
    end
    return false
end

local function AppendSkillBarTable(parts, bar)
    local markdown_utils = CM.utils and CM.utils.markdown
    local CreateStyledTable = markdown_utils and markdown_utils.CreateStyledTable
    local abilities = (bar.abilities and type(bar.abilities) == "table") and bar.abilities or {}

    local headers = {}
    local rowData = {}
    for i = 1, REGULAR_ABILITY_SLOTS do
        table_insert(headers, tostring(i))
        table_insert(rowData, FormatAbilityCell(abilities[i]))
    end
    table_insert(headers, "⚡")
    table_insert(rowData, FormatUltimateCell(bar))

    if CreateStyledTable then
        local alignment = {}
        for _ in ipairs(headers) do
            table_insert(alignment, "center")
        end
        table_insert(
            parts,
            CreateStyledTable(headers, { rowData }, {
                alignment = alignment,
                coloredHeaders = true,
                width = "100%",
            })
        )
        return
    end

    local headerRow = "|"
    local separatorRow = "|"
    for _, header in ipairs(headers) do
        headerRow = headerRow .. " " .. header .. " |"
        separatorRow = separatorRow .. ":--:|"
    end
    table_insert(parts, headerRow .. "\n")
    table_insert(parts, separatorRow .. "\n")
    local abilitiesRow = "|"
    for _, cell in ipairs(rowData) do
        abilitiesRow = abilitiesRow .. " " .. cell .. " |"
    end
    table_insert(parts, abilitiesRow .. "\n\n")
end

local function AppendSetsTable(parts, sets)
    if not sets or #sets == 0 then
        return
    end

    local markdown_utils = CM.utils and CM.utils.markdown
    local CreateStyledTable = markdown_utils and markdown_utils.CreateStyledTable
    local headers = { "Set", "Pieces" }
    local rows = {}

    for _, set in ipairs(sets) do
        local setName = set.name or ""
        local setLink = setName
        if CreateSetLink then
            local success, linked = pcall(CreateSetLink, setName)
            if success and linked then
                setLink = linked
            end
        end
        table_insert(rows, { "**" .. setLink .. "**", tostring(set.count or 0) })
    end

    table_insert(parts, "#### Sets\n\n")
    if CreateStyledTable then
        table_insert(
            parts,
            CreateStyledTable(headers, rows, {
                alignment = { "left", "left" },
                coloredHeaders = true,
            })
        )
    else
        table_insert(parts, "| Set | Pieces |\n|---|---|\n")
        for _, row in ipairs(rows) do
            table_insert(parts, "| " .. row[1] .. " | " .. row[2] .. " |\n")
        end
        table_insert(parts, "\n")
    end
end

local function AppendEquipmentDetails(parts, equipment)
    if not equipment or #equipment == 0 then
        return
    end

    local markdown_utils = CM.utils and CM.utils.markdown
    local CreateStyledTable = markdown_utils and markdown_utils.CreateStyledTable
    local headers = { "Slot", "Item", "Set", "Quality", "Trait", "Type" }
    local rows = {}

    for _, item in ipairs(equipment) do
        local setName = item.setName or "-"
        local setLink = setName
        if setName ~= "-" and CreateSetLink then
            local success, linked = pcall(CreateSetLink, setName)
            if success and linked then
                setLink = linked
            end
        end

        local itemLabel = item.name or "-"
        if item.state and item.state ~= "VALID" and item.state ~= "EMPTY" then
            itemLabel = itemLabel .. " *(" .. item.state .. ")*"
        end

        table_insert(rows, {
            (item.emoji or "📦") .. " **" .. (item.slotName or "Unknown") .. "**",
            itemLabel,
            setLink,
            (item.qualityEmoji or "⚪") .. " " .. (item.quality or "-"),
            item.trait or "-",
            FormatItemType(item),
        })
    end

    table_insert(parts, "#### Equipment\n\n")
    if CreateStyledTable then
        table_insert(
            parts,
            CreateStyledTable(headers, rows, {
                alignment = { "left", "left", "left", "left", "left", "left" },
                coloredHeaders = true,
                width = "100%",
            })
        )
    else
        table_insert(parts, "| Slot | Item | Set | Quality | Trait | Type |\n|---|---|---|---|---|---|\n")
        for _, row in ipairs(rows) do
            table_insert(
                parts,
                string_format(
                    "| %s | %s | %s | %s | %s | %s |\n",
                    row[1],
                    row[2],
                    row[3],
                    row[4],
                    row[5],
                    row[6]
                )
            )
        end
        table_insert(parts, "\n")
    end
end

-- =====================================================
-- STANDARD FORMAT
-- =====================================================

local function GenerateArmoryBuildsStandard(armory)
    local parts = {}

    local anchorId = GenerateAnchor and GenerateAnchor("🏰 Armory Builds") or "armory-builds"
    table_insert(parts, string_format('<a id="%s"></a>\n\n', anchorId))
    table_insert(parts, "## 🏰 Armory Builds\n\n")

    local unlocked = armory.unlocked or (armory.summary and armory.summary.unlockedSlots) or 0
    local maxBuilds = (armory.summary and armory.summary.maxBuilds) or unlocked
    table_insert(parts, string_format("**Unlocked Slots:** %d / %d\n\n", unlocked, maxBuilds))
    table_insert(
        parts,
        "*Saved armory loadouts (gear, skill bars, attributes, mundus). Champion Points show discipline totals only — not per-star maps.*\n\n"
    )

    if not armory.builds or #armory.builds == 0 then
        table_insert(parts, "*No builds configured*\n\n")
        local CreateSeparator = CM.utils and CM.utils.markdown and CM.utils.markdown.CreateSeparator
        if CreateSeparator then
            table_insert(parts, CreateSeparator("hr"))
        else
            table_insert(parts, "---\n\n")
        end
        return table_concat(parts)
    end

    for i, build in ipairs(armory.builds) do
        if i > 1 then
            table_insert(parts, "\n")
        end

        table_insert(parts, "### " .. (build.name or ("Build " .. tostring(i))) .. "\n\n")

        table_insert(parts, "| Property | Value |\n")
        table_insert(parts, "|:---------|:------|\n")

        if (build.skillPoints or 0) > 0 then
            local sp = FormatNumber and FormatNumber(build.skillPoints) or tostring(build.skillPoints)
            table_insert(parts, "| **Skill Points** | " .. sp .. " |\n")
        end

        table_insert(parts, "| **Attributes** | " .. FormatAttributes(build.attributes) .. " |\n")
        table_insert(parts, "| **Champion Points** | " .. FormatChampionPoints(build.champion) .. " |\n")
        table_insert(parts, "| **Mundus Stones** | " .. FormatMundusStones(build.mundus) .. " |\n")

        if build.curse then
            table_insert(parts, "| **Curse** | " .. build.curse .. " |\n")
        end

        if (build.outfitIndex or 0) > 0 then
            table_insert(parts, "| **Outfit Index** | " .. build.outfitIndex .. " |\n")
        end

        table_insert(parts, "\n")

        AppendSetsTable(parts, build.sets)
        AppendEquipmentDetails(parts, build.equipment)

        if build.hotbars and #build.hotbars > 0 then
            table_insert(parts, "#### Skill bars\n\n")
            local hasBarContent = false
            for _, bar in ipairs(build.hotbars) do
                if BarHasSlottedContent(bar) then
                    hasBarContent = true
                    table_insert(parts, "##### " .. (bar.name or "Bar") .. "\n\n")
                    AppendSkillBarTable(parts, bar)
                end
            end
            if not hasBarContent then
                table_insert(parts, "*No skill bars configured*\n\n")
            end
        end
    end

    local CreateSeparator = CM.utils and CM.utils.markdown and CM.utils.markdown.CreateSeparator
    if CreateSeparator then
        table_insert(parts, CreateSeparator("hr"))
    else
        table_insert(parts, "---\n\n")
    end
    return table_concat(parts)
end

-- =====================================================
-- MAIN GENERATOR
-- =====================================================

local function NormalizeArmoryPayload(armoryData)
    if not armoryData or type(armoryData) ~= "table" then
        return nil
    end

    -- Flat collector payload (preferred): { unlocked, builds, summary }
    if armoryData.builds ~= nil or armoryData.unlocked ~= nil or armoryData.summary ~= nil then
        return armoryData
    end

    -- Legacy nested shape: { armory = { ... } }
    if armoryData.armory and type(armoryData.armory) == "table" then
        return armoryData.armory
    end

    return nil
end

local function GenerateArmoryBuilds(armoryData)
    InitializeUtilities()

    local armory = NormalizeArmoryPayload(armoryData)
    if not armory then
        local anchorId = GenerateAnchor and GenerateAnchor("🏰 Armory Builds") or "armory-builds"
        return string_format(
            '<a id="%s"></a>\n\n## 🏰 Armory Builds\n\n*No armory data available*\n\n---\n\n',
            anchorId
        )
    end

    return GenerateArmoryBuildsStandard(armory)
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateArmoryBuilds = GenerateArmoryBuilds

return {
    GenerateArmoryBuilds = GenerateArmoryBuilds,
}
