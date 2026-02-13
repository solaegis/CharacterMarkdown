-- CharacterMarkdown - TONL (Token-Oriented Object Notation) Utilities
-- Encodes Lua data structures to TONL format for LLM-friendly output
-- TONL is a compact format that reduces token usage compared to JSON

local CM = CharacterMarkdown
CM.utils = CM.utils or {}
CM.utils.tonl = CM.utils.tonl or {}

-- Localize frequently used functions for performance
local string_format = string.format
local string_rep = string.rep
local table_concat = table.concat
local table_insert = table.insert
local type = type
local tostring = tostring
local tonumber = tonumber

-- =====================================================
-- TONL ENCODING
-- =====================================================

-- Escape special characters in strings
local function EscapeString(str)
    if not str then
        return ""
    end

    str = tostring(str)

    -- Escape backslashes first
    str = str:gsub("\\", "\\\\")
    -- Escape newlines
    str = str:gsub("\n", "\\n")
    -- Escape carriage returns
    str = str:gsub("\r", "\\r")
    -- Escape tabs
    str = str:gsub("\t", "\\t")
    -- Escape quotes
    str = str:gsub('"', '\\"')

    return str
end

-- Check if an array contains uniform objects (all same keys)
local function IsUniformObjectArray(arr)
    if not arr or #arr == 0 then
        return false
    end

    -- Get keys from first object
    local firstKeys = {}
    local firstItem = arr[1]
    if type(firstItem) ~= "table" then
        return false
    end

    for k, _ in pairs(firstItem) do
        firstKeys[k] = true
    end

    -- Check if all items have the same keys
    for i = 2, #arr do
        local item = arr[i]
        if type(item) ~= "table" then
            return false
        end

        -- Check all keys match
        local keyCount = 0
        for k, _ in pairs(item) do
            if not firstKeys[k] then
                return false
            end
            keyCount = keyCount + 1
        end

        -- Check key count matches
        local firstKeyCount = 0
        for _ in pairs(firstKeys) do
            firstKeyCount = firstKeyCount + 1
        end

        if keyCount ~= firstKeyCount then
            return false
        end
    end

    return true, firstKeys
end

-- Encode a value to TONL format
local function EncodeValue(value, indent, visited)
    indent = indent or 0
    visited = visited or {}
    local indentStr = string_rep("  ", indent)

    local valueType = type(value)

    if valueType == "nil" then
        return "null"
    elseif valueType == "boolean" then
        return value and "true" or "false"
    elseif valueType == "number" then
        return tostring(value)
    elseif valueType == "string" then
        -- Check if string contains newlines
        if value:find("\n") then
            -- Split into lines and encode as array
            local lines = {}
            -- Robust split including empty lines
            for line in (value .. "\n"):gmatch("(.-)\n") do
                table_insert(lines, line)
            end

            -- If the original string didn't end with a newline, the last element is correct.
            -- If it DID end with a newline, we get an extra empty string at the end.
            -- e.g. "A\nB" -> "A\nB\n" -> {"A", "B"} (Correct)
            -- e.g. "A\n" -> "A\n\n" -> {"A", ""} (Preserves trailing newline as empty line)
            -- e.g. "A\n\nB" -> "A\n\nB\n" -> {"A", "", "B"} (Correct)

            -- However, if the last line is empty, it might be an artifact of our split method
            -- combined with a trailing newline in the input.
            -- For TONL, we generally want to preserve the exact structure.
            -- "Line 1\n" -> ["Line 1", ""] seems correct if we want to preserve the trailing newline.

            -- Recursively encode as array
            return EncodeValue(lines, indent, visited)
        else
            -- Check if string needs quoting (contains special chars, spaces, or is empty)
            if value == "" or value:match("[%s:,\\[\\]{}]") or value:match("^%d") then
                return string_format('"%s"', EscapeString(value))
            else
                return value
            end
        end
    elseif valueType == "table" then
        -- Prevent circular references
        if visited[value] then
            return '"[circular reference]"'
        end
        visited[value] = true

        -- Check if it's an array (sequential numeric indices starting at 1)
        local isArray = true
        local maxIndex = 0
        local keyCount = 0

        for k, v in pairs(value) do
            keyCount = keyCount + 1
            if type(k) == "number" and k >= 1 and k == math.floor(k) then
                if k > maxIndex then
                    maxIndex = k
                end
            else
                isArray = false
            end
        end

        -- Only treat as array if all keys are sequential 1..n
        if isArray and keyCount > 0 then
            for i = 1, maxIndex do
                if value[i] == nil then
                    isArray = false
                    break
                end
            end
        else
            isArray = false
        end

        if isArray then
            -- Check if array contains uniform objects (can use tabular format)
            local isUniform, keys = IsUniformObjectArray(value)

            if isUniform and #value > 1 then
                -- Tabular format: declare fields once, then list values
                local lines = {}
                table_insert(lines, string_format("%s[", indentStr))

                -- Header row with field names
                local fieldNames = {}
                for k, _ in pairs(keys) do
                    table_insert(fieldNames, k)
                end
                table.sort(fieldNames) -- Sort for consistency

                local headerLine = indentStr .. "  "
                local headerParts = {}
                for _, fieldName in ipairs(fieldNames) do
                    table_insert(headerParts, fieldName)
                end
                headerLine = headerLine .. table_concat(headerParts, " ")
                table_insert(lines, headerLine)

                -- Data rows
                for i, item in ipairs(value) do
                    local rowParts = {}
                    for _, fieldName in ipairs(fieldNames) do
                        local fieldValue = item[fieldName]
                        local encoded = EncodeValue(fieldValue, 0, visited)
                        table_insert(rowParts, encoded)
                    end
                    local rowLine = indentStr .. "  " .. table_concat(rowParts, " ")
                    table_insert(lines, rowLine)
                end

                table_insert(lines, string_format("%s]", indentStr))
                return table_concat(lines, "\n")
            else
                -- Regular array format
                local lines = {}
                table_insert(lines, string_format("%s[", indentStr))

                for i, item in ipairs(value) do
                    local encoded = EncodeValue(item, indent + 1, visited)
                    local isLast = (i == #value)
                    local line = string_format("%s  %s", indentStr, encoded)
                    if not isLast or encoded:match("\n") then
                        -- Multi-line or not last item
                        table_insert(lines, line)
                    else
                        -- Single-line format for simple arrays
                        if #lines == 1 then
                            -- First item, check if we can do inline
                            local allSimple = true
                            for j = 1, #value do
                                local itemType = type(value[j])
                                if itemType == "table" or (itemType == "string" and #value[j] > 20) then
                                    allSimple = false
                                    break
                                end
                            end

                            if allSimple and #value <= 5 then
                                -- Inline format
                                local inlineParts = {}
                                for j = 1, #value do
                                    table_insert(inlineParts, EncodeValue(value[j], 0, visited))
                                end
                                return string_format("%s[%s]", indentStr, table_concat(inlineParts, " "))
                            end
                        end
                        table_insert(lines, line)
                    end
                end

                table_insert(lines, string_format("%s]", indentStr))
                return table_concat(lines, "\n")
            end
        else
            -- Object format (key-value pairs)
            local lines = {}
            local isFirst = true

            -- Sort keys for consistent output
            local sortedKeys = {}
            for k, _ in pairs(value) do
                table_insert(sortedKeys, k)
            end
            table.sort(sortedKeys, function(a, b)
                -- Numbers first, then strings
                local aNum = tonumber(a)
                local bNum = tonumber(b)
                if aNum and bNum then
                    return aNum < bNum
                elseif aNum then
                    return true
                elseif bNum then
                    return false
                else
                    return tostring(a) < tostring(b)
                end
            end)

            for _, k in ipairs(sortedKeys) do
                local v = value[k]
                local keyStr = type(k) == "string"
                        and (k:match("^[%a_][%a%d_]*$") and k or string_format('"%s"', EscapeString(k)))
                    or tostring(k)
                local encodedValue = EncodeValue(v, indent + 1, visited)

                if encodedValue:match("\n") then
                    -- Multi-line value
                    if not isFirst then
                        table_insert(lines, "")
                    end
                    table_insert(lines, string_format("%s%s:", indentStr, keyStr))
                    table_insert(lines, encodedValue)
                else
                    -- Single-line value
                    table_insert(lines, string_format("%s%s: %s", indentStr, keyStr, encodedValue))
                end
                isFirst = false
            end

            if #lines == 0 then
                return "{}"
            end

            return table_concat(lines, "\n")
        end
    else
        return string_format('"[unhandled type: %s]"', valueType)
    end
end

-- Main encoding function
local function Encode(data)
    if data == nil then
        return "null"
    end

    return EncodeValue(data, 0, {})
end

CM.utils.tonl.Encode = Encode

-- =====================================================
-- MINIMAL OUTPUT FOR LLM CONTEXT
-- =====================================================
-- Reduces token usage by keeping high-value data and removing cruft

local function IsTableEmpty(t)
    if not t or type(t) ~= "table" then
        return true
    end
    for _ in pairs(t) do
        return false
    end
    return true
end

local function MinimizeAchievements(achievements)
    if not achievements then
        return nil
    end
    local summary = achievements.summary or {}
    local out = {
        earnedPoints = achievements.points or summary.earnedPoints or 0,
        totalPoints = achievements.total or summary.totalPoints or 0,
        completionPercent = summary.completionPercent or 0,
    }
    -- Top 5 categories by earned (for quick context)
    if achievements.categories and #achievements.categories > 0 then
        local top = {}
        for i, cat in ipairs(achievements.categories) do
            if i <= 5 and (cat.earned or 0) > 0 then
                table_insert(top, { name = cat.name or "", earned = cat.earned or 0, percent = cat.percent or 0 })
            end
        end
        if #top > 0 then
            out.topCategories = top
        end
    end
    return out
end

local function MinimizeStats(stats)
    if not stats or type(stats) ~= "table" then
        return nil
    end
    local out = {}
    -- Keep core stats
    for _, k in ipairs({ "health", "magicka", "stamina", "weaponPower", "spellPower", "weaponCritChance", "spellCritChance",
        "physicalPenetration", "spellPenetration", "physicalResist", "spellResist", "physicalMitigation", "spellMitigation" }) do
        if stats[k] ~= nil then
            out[k] = stats[k]
        end
    end
    -- Collapse elemental resistances if all identical (flame, frost, shock, magic, disease, poison, bleed)
    if stats.resistances and type(stats.resistances) == "table" then
        local elementalKeys = { "flame", "frost", "shock", "magic", "disease", "poison", "bleed" }
        local firstVal = nil
        local allSame = true
        for _, k in ipairs(elementalKeys) do
            local v = stats.resistances[k]
            if v and type(v) == "table" and v.value then
                if firstVal == nil then
                    firstVal = v.value
                elseif v.value ~= firstVal then
                    allSame = false
                    break
                end
            end
        end
        if allSame and firstVal ~= nil then
            out.resist = firstVal
        else
            out.resistances = stats.resistances
        end
    end
    -- Keep effectiveHealth average only
    if stats.effectiveHealth then
        out.effectiveHealth = stats.effectiveHealth.average or stats.effectiveHealth
    end
    return out
end

local function MinimizeTitlesHousing(th)
    if not th then
        return nil
    end
    -- titlesHousing can be CollectTitlesData directly (current, owned, summary)
    local summary = th.summary or {}
    return {
        current = th.current or th.title or "",
        totalOwned = summary.totalOwned or (#(th.owned or {})),
        completionPercent = summary.completionPercent or 0,
    }
end

local function MinimizeCollectibles(col)
    if not col then
        return nil
    end
    return {
        esoPlus = col.esoPlus,
        summary = col.summary,
    }
end

local function MinimizeInventory(inv, settings)
    if not inv then
        return nil
    end
    local out = {}
    -- Backpack: used/max summary
    out.backpack = {
        used = inv.backpackUsed or inv.backpack and inv.backpack.used or 0,
        max = inv.backpackMax or inv.backpack and inv.backpack.max or 0,
    }
    -- Bank: used/max summary
    out.bank = {
        used = inv.bankUsed or inv.bank and inv.bank.used or 0,
        max = inv.bankMax or inv.bank and inv.bank.max or 0,
    }
    if inv.hasCraftingBag ~= nil then
        out.hasCraftingBag = inv.hasCraftingBag
    end
    -- Omit item lists unless explicitly requested (minimal mode drops them)
    if settings and (settings.showBagContents or settings.showBankContents or settings.showCraftingBagContents) then
        out.bagItems = inv.bagItems
        out.bankItems = inv.bankItems
        out.craftingBagItems = inv.craftingBagItems
    end
    return out
end

local function MinimizeUndauntedPledges(up)
    if not up then
        return nil
    end
    local hasData = false
    if up.active and type(up.active) == "table" and #up.active > 0 then
        hasData = true
    end
    if up.daily then
        if (up.daily.normal and #up.daily.normal > 0) or (up.daily.veteran and #up.daily.veteran > 0) then
            hasData = true
        end
    end
    if up.weekly then
        if (up.weekly.normal and #up.weekly.normal > 0) or (up.weekly.veteran and #up.weekly.veteran > 0) then
            hasData = true
        end
    end
    if up.dungeonProgress then
        local dp = up.dungeonProgress
        if (dp.normal and dp.normal.total and dp.normal.total > 0)
            or (dp.veteran and dp.veteran.total and dp.veteran.total > 0)
            or (dp.hardmode and dp.hardmode.total and dp.hardmode.total > 0)
        then
            hasData = true
        end
    end
    if not hasData then
        return nil
    end
    return up
end

local function MinimizeCharacter(char)
    if not char then
        return nil
    end
    local out = {}
    for _, k in ipairs({ "name", "class", "race", "level", "cp", "title", "alliance", "server", "account", "gender", "esoPlus" }) do
        if char[k] ~= nil then
            out[k] = char[k]
        end
    end
    if char.attributes then
        out.attributes = char.attributes
    end
    return out
end

local function MinimizeCp(cp)
    if not cp then
        return nil
    end
    local out = {
        total = cp.total,
        spent = cp.spent,
        available = cp.available,
    }
    if cp.disciplines and #cp.disciplines > 0 then
        out.disciplines = {}
        for _, d in ipairs(cp.disciplines) do
            table_insert(out.disciplines, {
                name = d.name,
                spent = d.spent or d.total,
                available = d.available,
            })
        end
    end
    return out
end

---Minimize collected data for LLM context (reduce token usage)
---@param data table Full collected data
---@param settings table|nil Optional settings (for includeInventory detail)
---@return table Minimal data
function CM.utils.tonl.MinimizeForTONL(data, settings)
    if not data or type(data) ~= "table" then
        return data
    end
    settings = settings or {}
    local out = {}

    -- Copy metadata (minimal)
    if data._metadata then
        out._metadata = data._metadata
    end

    -- Character: keep identity only
    out.character = MinimizeCharacter(data.character)

    -- Core build data: keep as-is (high value)
    out.cp = MinimizeCp(data.cp)
    out.equipment = data.equipment
    out.skillBar = data.skillBar
    out.skillMorphs = data.skillMorphs
    out.stats = MinimizeStats(data.stats)
    out.role = data.role
    out.location = data.location
    out.mundus = data.mundus
    out.buffs = data.buffs

    -- User content
    out.customNotes = (data.customNotes and data.customNotes ~= "") and data.customNotes or nil
    out.customTitle = (data.customTitle and data.customTitle ~= "") and data.customTitle or nil
    out.playStyle = (data.playStyle and data.playStyle ~= "") and data.playStyle or nil

    -- Collapsed/summarized
    out.currency = data.currency
    out.companion = (data.companion and not IsTableEmpty(data.companion)) and data.companion or nil
    out.collectibles = MinimizeCollectibles(data.collectibles)
    out.inventory = MinimizeInventory(data.inventory, settings)
    out.guilds = (data.guilds and not IsTableEmpty(data.guilds)) and data.guilds or nil

    -- Achievements: collapse to summary
    out.achievements = (data.achievements and not IsTableEmpty(data.achievements)) and MinimizeAchievements(data.achievements) or nil

    -- Titles: summary only
    out.titlesHousing = (data.titlesHousing and not IsTableEmpty(data.titlesHousing)) and MinimizeTitlesHousing(data.titlesHousing) or nil

    -- Omit empty sections
    out.antiquities = (data.antiquities and not IsTableEmpty(data.antiquities)) and data.antiquities or nil
    out.quests = (data.quests and not IsTableEmpty(data.quests)) and data.quests or nil
    out.pvp = (data.pvp and not IsTableEmpty(data.pvp)) and data.pvp or nil
    out.progression = (data.progression and not IsTableEmpty(data.progression)) and data.progression or nil
    out.riding = (data.riding and not IsTableEmpty(data.riding)) and data.riding or nil
    out.armoryBuilds = (data.armoryBuilds and not IsTableEmpty(data.armoryBuilds)) and data.armoryBuilds or nil
    out.undauntedPledges = MinimizeUndauntedPledges(data.undauntedPledges)
    out.dlc = (data.dlc and not IsTableEmpty(data.dlc)) and data.dlc or nil
    out.skill = (data.skill and not IsTableEmpty(data.skill)) and data.skill or nil

    -- Remove nil entries
    local cleaned = {}
    for k, v in pairs(out) do
        if v ~= nil then
            cleaned[k] = v
        end
    end
    return cleaned
end

-- =====================================================
-- MODULE INITIALIZATION
-- =====================================================

CM.DebugPrint("UTILS", "TONL module loaded")

return {
    Encode = Encode,
    MinimizeForTONL = CM.utils.tonl.MinimizeForTONL,
}
