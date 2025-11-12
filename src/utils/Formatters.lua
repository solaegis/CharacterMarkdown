-- CharacterMarkdown - Formatting Utilities
-- Number formatting, progress bars, callouts (ESO Guideline Compliant)

local CM = CharacterMarkdown

-- =====================================================
-- CACHED GLOBALS (PERFORMANCE)
-- =====================================================

local string_format = string.format
local string_gsub = string.gsub
local string_rep = string.rep
local math_floor = math.floor
local tostring = tostring

-- =====================================================
-- NUMBER FORMATTING
-- =====================================================

-- Format number with comma separators
local function FormatNumber(number)
    if not number then
        return "0"
    end

    local formatted = tostring(math_floor(number))
    local k

    while true do
        formatted, k = string_gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then
            break
        end
    end

    return formatted
end

CM.utils.FormatNumber = FormatNumber

-- =====================================================
-- PROGRESS BARS
-- =====================================================

-- Generate progress bar (10 blocks)
local function CreateProgressBar(percentage, style)
    if not percentage then
        return ""
    end

    style = style or "default"

    -- Clamp percentage to 0-100
    percentage = math_floor(percentage)
    if percentage < 0 then
        percentage = 0
    end
    if percentage > 100 then
        percentage = 100
    end

    local filled = math_floor(percentage / 10)
    local empty = 10 - filled

    -- STANDARDIZED: Always use █ (filled) and ░ (empty) for consistency (Issue #6 fix)
    local bar = string_rep("█", filled) .. string_rep("░", empty)
    return bar .. " " .. percentage .. "%"
end

CM.utils.CreateProgressBar = CreateProgressBar

-- =====================================================
-- CALLOUT BOXES
-- =====================================================

-- Create callout box for markdown
local function CreateCallout(type, content, format)
    if not content or content == "" then
        return ""
    end

    local types = {
        info = { emoji = "ℹ️", color = "#0969da", title = "Info" },
        warning = { emoji = "⚠️", color = "#d29922", title = "Warning" },
        success = { emoji = "✅", color = "#1a7f37", title = "Success" },
        error = { emoji = "❌", color = "#d1242f", title = "Error" },
    }

    local info = types[type] or types.info

    if format == "github" then
        return string_format(
            '<blockquote style="border-left: 4px solid %s; background: %s10; padding: 10px;">\n%s <strong>%s</strong>\n\n%s\n</blockquote>',
            info.color,
            info.color,
            info.emoji,
            info.title,
            content
        )
    elseif format == "discord" then
        -- Discord doesn't support HTML, use simple blockquote
        return string_format("> %s **%s**: %s", info.emoji, info.title, content)
    else
        -- VS Code and other formats
        return string_format("> %s **%s**\n> \n> %s", info.emoji, info.title, content:gsub("\n", "\n> "))
    end
end

CM.utils.CreateCallout = CreateCallout

-- =====================================================
-- TEXT TRUNCATION (UTF-8 SAFE)
-- =====================================================

-- Safely truncate text at UTF-8 boundaries
local function SafeTruncate(str, maxBytes)
    if not str or str == "" then
        return ""
    end
    if not maxBytes or maxBytes <= 0 then
        return ""
    end

    local len = string.len(str)
    if len <= maxBytes then
        return str
    end

    -- Walk back to find valid UTF-8 boundary
    while maxBytes > 0 do
        local byte = string.byte(str, maxBytes)
        if not byte then
            break
        end

        -- Check if valid UTF-8 start byte
        -- Start bytes: 0xxxxxxx (ASCII) or 11xxxxxx (multi-byte start)
        if byte < 128 or byte >= 192 then
            break
        end

        maxBytes = maxBytes - 1
    end

    return string.sub(str, 1, maxBytes)
end

CM.utils.SafeTruncate = SafeTruncate

-- =====================================================
-- PLURALIZATION
-- =====================================================

-- Simple pluralization helper
local function Pluralize(count, singular, plural)
    if not count then
        return singular
    end

    plural = plural or (singular .. "s")
    return count == 1 and singular or plural
end

CM.utils.Pluralize = Pluralize

-- =====================================================
-- ESO COLOR CODE STRIPPING
-- =====================================================

-- Strip ESO color codes from strings (e.g., |cffffff75|r becomes empty)
-- Pattern: |c[0-9a-fA-F]{6}|r or |c[0-9a-fA-F]{8}|r (with alpha)
local function StripColorCodes(text)
    if not text or type(text) ~= "string" then
        return text or ""
    end

    -- Try ZO_ClearColor first (ESO built-in function)
    if ZO_ClearColor and type(ZO_ClearColor) == "function" then
        local success, cleared = pcall(ZO_ClearColor, text)
        if success and cleared then
            return cleared
        end
    end

    -- Fallback: manual pattern stripping
    -- Pattern: |c[hex/digits]|r
    -- ESO color codes can be: |cRRGGBB|r, |cRRGGBBAA|r, or |cRRGGBB[digits]|r
    -- FIX: The original pattern %%|c was wrong - it matches %|c, not |c
    -- In Lua patterns, | is only special in alternation, so we can use | directly
    -- However, to be safe and explicit, we use %| to escape the | character
    -- In string literals: "|c" works, but "%|c" is more explicit
    local stripped = text
    -- Strategy: Extract numbers from inside color codes before stripping
    -- Pattern like |cffffff230|r should become 230 (number preserved)
    -- First, extract and preserve numbers that appear after hex in color codes
    -- Match |c + 6 hex + digits + |r and replace with just the digits
    stripped =
        string_gsub(stripped, "|c[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]([0-9]+)|r", "%1")
    -- Now strip remaining color codes (standard format: |cRRGGBB|r or |cRRGGBBAA|r)
    stripped = string_gsub(
        stripped,
        "|c[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]?[0-9a-fA-F]?|r",
        ""
    )
    -- Catch-all: match |c followed by any non-| characters until |r (fallback)
    stripped = string_gsub(stripped, "|c[^|]*|r", "")
    return stripped
end

CM.utils.StripColorCodes = StripColorCodes

-- =====================================================
-- YAML SERIALIZATION
-- =====================================================

-- Convert a Lua table to YAML format (simple implementation)
-- Supports comments via special _comment key
local function TableToYAML(tbl, indent, visited, addComments)
    indent = indent or 0
    visited = visited or {}
    addComments = addComments ~= false -- Default to true
    local indentStr = string_rep("  ", indent)
    local result = {}

    -- Check for circular references
    if visited[tbl] then
        return indentStr .. "... (circular reference)"
    end
    visited[tbl] = true

    -- Handle metadata/comment at top level
    if indent == 0 and tbl._metadata then
        local meta = tbl._metadata
        table.insert(result, "# " .. (meta.note or "Settings Export"))
        if meta.version then
            table.insert(result, "# Version: " .. tostring(meta.version))
        end
        if meta.exported then
            table.insert(result, "# Exported: " .. tostring(meta.exported))
        end
        table.insert(result, "")
    end

    -- Sort keys for consistent output
    local keys = {}
    for k in pairs(tbl) do
        -- Skip internal/metadata keys (but include _comment for comments)
        if type(k) == "string" then
            if k:sub(1, 1) ~= "_" or k == "_comment" then
                table.insert(keys, k)
            end
        else
            table.insert(keys, k)
        end
    end
    table.sort(keys)

    for _, key in ipairs(keys) do
        local value = tbl[key]
        local keyStr = tostring(key)

        -- Handle comments
        if key == "_comment" and addComments then
            if type(value) == "string" then
                table.insert(result, indentStr .. "# " .. value)
            elseif type(value) == "table" then
                for _, comment in ipairs(value) do
                    table.insert(result, indentStr .. "# " .. tostring(comment))
                end
            end
            -- Add blank line after comment section
            if indent == 0 then
                table.insert(result, "")
            end
        else
            -- Quote key if it contains special characters
            if string.find(keyStr, "[^%w_]") then
                keyStr = '"' .. keyStr .. '"'
            end

            if type(value) == "table" then
                -- Check if it's an array (sequential numeric indices)
                local isArray = true
                local maxIndex = 0
                for k in pairs(value) do
                    if type(k) ~= "number" then
                        isArray = false
                        break
                    end
                    if k > maxIndex then
                        maxIndex = k
                    end
                end

                if isArray and maxIndex > 0 then
                    -- Array format
                    table.insert(result, indentStr .. keyStr .. ":")
                    for i = 1, maxIndex do
                        local item = value[i]
                        if type(item) == "table" then
                            table.insert(result, indentStr .. "  -")
                            local subYAML = TableToYAML(item, indent + 2, visited, addComments)
                            -- Indent each line of the nested table
                            for line in string.gmatch(subYAML, "[^\n]+") do
                                table.insert(result, indentStr .. "    " .. line)
                            end
                        else
                            local itemStr = tostring(item)
                            if type(item) == "string" then
                                itemStr = '"' .. itemStr:gsub('"', '\\"') .. '"'
                            end
                            table.insert(result, indentStr .. "  - " .. itemStr)
                        end
                    end
                else
                    -- Object format
                    table.insert(result, indentStr .. keyStr .. ":")
                    local subYAML = TableToYAML(value, indent + 1, visited, addComments)
                    -- Add each line of the nested table (if not empty)
                    if subYAML and subYAML ~= "" then
                        for line in string.gmatch(subYAML, "[^\n]+") do
                            table.insert(result, line)
                        end
                    end
                end
            elseif type(value) == "string" then
                -- Escape quotes and newlines in strings
                local escaped = value:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n")
                table.insert(result, indentStr .. keyStr .. ': "' .. escaped .. '"')
            elseif type(value) == "boolean" then
                table.insert(result, indentStr .. keyStr .. ": " .. (value and "true" or "false"))
            elseif type(value) == "nil" then
                table.insert(result, indentStr .. keyStr .. ": null")
            else
                table.insert(result, indentStr .. keyStr .. ": " .. tostring(value))
            end
        end
    end

    visited[tbl] = nil
    return table.concat(result, "\n")
end

CM.utils.TableToYAML = TableToYAML

-- =====================================================
-- FORMATTED SETTINGS EXPORT (Human-readable YAML)
-- =====================================================

-- Format settings for human-readable export
local function FormatSettingsForExport(settings)
    if not settings then
        return nil
    end

    -- Extract actual settings from ZO_SavedVars structure if needed
    local actualSettings = settings
    if settings.Default and settings.Default["@SOLAEGIS"] and settings.Default["@SOLAEGIS"]["$AccountWide"] then
        actualSettings = settings.Default["@SOLAEGIS"]["$AccountWide"]
    end

    -- Build organized export structure
    local export = {
        -- Header metadata
        _metadata = {
            version = CM.version or "unknown",
            exported = os.date("%Y-%m-%d %H:%M:%S"),
            note = "CharacterMarkdown Settings Export - Edit values and import with /cmdsettings import",
        },

        -- Core settings
        core = {
            currentFormat = actualSettings.currentFormat or "github",
            activeProfile = actualSettings.activeProfile or "Custom",
            chunkSize = actualSettings.chunkSize or 10000,
            -- Per-character data from CM.charData
            customTitle = (CM.charData and CM.charData.customTitle) or "",
            customNotes = (CM.charData and CM.charData.customNotes) or "",
            playStyle = (CM.charData and CM.charData.playStyle) or "",
        },

        -- Link settings
        links = {
            enableAbilityLinks = actualSettings.enableAbilityLinks ~= false,
            enableSetLinks = actualSettings.enableSetLinks ~= false,
        },

        -- Visual settings
        visuals = {
            useMultiColumnLayout = actualSettings.useMultiColumnLayout == true,
        },

        -- Content filters - Main sections
        content = {
            includeHeader = actualSettings.includeHeader ~= false,
            includeFooter = actualSettings.includeFooter ~= false,
            includeTableOfContents = actualSettings.includeTableOfContents ~= false,
            includeQuickStats = actualSettings.includeQuickStats ~= false,
            includeGeneral = actualSettings.includeGeneral ~= false,
            includeCharacterStats = actualSettings.includeCharacterStats ~= false,
            includeAttributes = actualSettings.includeAttributes ~= false,
            includeCombatStats = actualSettings.includeCombatStats ~= false,
            includeEquipment = actualSettings.includeEquipment ~= false,
            includeSkillBars = actualSettings.includeSkillBars ~= false,
            includeSkills = actualSettings.includeSkills ~= false,
            includeChampionPoints = actualSettings.includeChampionPoints ~= false,
            includeProgression = actualSettings.includeProgression ~= false,
            includeLocation = actualSettings.includeLocation ~= false,
            includeCurrency = actualSettings.includeCurrency ~= false,
            includeInventory = actualSettings.includeInventory ~= false,
            showBagContents = actualSettings.showBagContents == true,
            showBankContents = actualSettings.showBankContents == true,
            showCraftingBagContents = actualSettings.showCraftingBagContents == true,
            includeCrafting = actualSettings.includeCrafting ~= false,
            includeDLCAccess = actualSettings.includeDLCAccess ~= false,
        },

        -- Extended content
        extended = {
            includeAchievements = actualSettings.includeAchievements ~= false,
            includeAchievementsInProgress = actualSettings.includeAchievementsInProgress == true,
            includeAntiquities = actualSettings.includeAntiquities ~= false,
            includeAntiquitiesDetailed = actualSettings.includeAntiquitiesDetailed == true,
            includeQuests = actualSettings.includeQuests ~= false,
            includeQuestsDetailed = actualSettings.includeQuestsDetailed == true,
            includeQuestsActiveOnly = actualSettings.includeQuestsActiveOnly == true,
            includeCollectibles = actualSettings.includeCollectibles ~= false,
            includeCollectiblesDetailed = actualSettings.includeCollectiblesDetailed == true,
            includeTitlesHousing = actualSettings.includeTitlesHousing ~= false,
            includeGuilds = actualSettings.includeGuilds ~= false,
            includeCompanion = actualSettings.includeCompanion ~= false,
            includePvP = actualSettings.includePvP ~= false,
            includePvPStats = actualSettings.includePvPStats == true,
            includeUndauntedPledges = actualSettings.includeUndauntedPledges ~= false,
            includeWorldProgress = actualSettings.includeWorldProgress ~= false,
            includeArmoryBuilds = actualSettings.includeArmoryBuilds == true,
        },

        -- Champion Point details
        champion = {
            includeChampionDiagram = actualSettings.includeChampionDiagram == true,
            includeChampionSlottableOnly = actualSettings.includeChampionSlottableOnly == true,
        },

        -- Equipment details
        equipment = {
            includeEquipmentEnhancement = actualSettings.includeEquipmentEnhancement ~= false,
            includeEquipmentAnalysis = actualSettings.includeEquipmentAnalysis == true,
            includeEquipmentRecommendations = actualSettings.includeEquipmentRecommendations == true,
        },

        -- Skill details
        skills = {
            includeSkillMorphs = actualSettings.includeSkillMorphs ~= false,
            includeBuffs = actualSettings.includeBuffs ~= false,
            includeRidingSkills = actualSettings.includeRidingSkills ~= false,
        },

        -- Display options
        display = {
            includeRole = actualSettings.includeRole ~= false,
            includeBuildNotes = actualSettings.includeBuildNotes ~= false,
            includeAttentionNeeded = actualSettings.includeAttentionNeeded ~= false,
            showAllAchievements = actualSettings.showAllAchievements ~= false,
            showAllQuests = actualSettings.showAllQuests ~= false,
        },
    }

    return export
end

CM.utils.FormatSettingsForExport = FormatSettingsForExport

-- Flatten grouped settings structure back to flat format for import
local function FlattenSettingsForImport(groupedSettings)
    if not groupedSettings or type(groupedSettings) ~= "table" then
        return nil
    end

    local flat = {}

    -- Handle grouped structure
    for groupName, groupData in pairs(groupedSettings) do
        if groupName ~= "_metadata" and type(groupData) == "table" then
            -- Flatten this group
            for key, value in pairs(groupData) do
                flat[key] = value
            end
        end
    end

    return flat
end

CM.utils.FlattenSettingsForImport = FlattenSettingsForImport

-- =====================================================
-- YAML PARSING (Simple implementation)
-- =====================================================

-- Parse YAML string into Lua table (simple implementation)
-- Supports basic YAML: key: value, nested objects, arrays, strings, numbers, booleans
local function YAMLToTable(yamlStr)
    if not yamlStr or yamlStr == "" then
        return nil, "Empty YAML string"
    end

    local result = {}
    local lines = {}
    local currentIndent = 0
    local stack = {} -- Stack for nested structures
    local stackIndents = {} -- Track indentation levels

    -- Split into lines
    for line in string.gmatch(yamlStr .. "\n", "(.-)\n") do
        table.insert(lines, line)
    end

    local function trim(str)
        return str:match("^%s*(.-)%s*$")
    end

    local function getIndent(str)
        local indent = 0
        for i = 1, #str do
            if str:sub(i, i) == " " then
                indent = indent + 1
            elseif str:sub(i, i) == "\t" then
                indent = indent + 4 -- Treat tab as 4 spaces
            else
                break
            end
        end
        return indent
    end

    local function parseValue(str)
        str = trim(str)
        if str == "" then
            return nil
        end

        -- Boolean
        if str == "true" then
            return true
        end
        if str == "false" then
            return false
        end
        if str == "null" or str == "nil" then
            return nil
        end

        -- Number
        local num = tonumber(str)
        if num then
            return num
        end

        -- String (remove quotes if present)
        if str:match('^".*"$') then
            return str:sub(2, -2):gsub('\\"', '"'):gsub("\\n", "\n"):gsub("\\\\", "\\")
        elseif str:match("^'.*'$") then
            return str:sub(2, -2)
        end

        -- Unquoted string
        return str
    end

    for i, line in ipairs(lines) do
        local trimmed = trim(line)
        if trimmed == "" or trimmed:match("^#") then
            -- Skip empty lines and comments
            -- (no goto in Lua 5.1, so we just continue to next iteration)
        else
            local indent = getIndent(line)
            local content = trimmed

            -- Pop stack until we're at the right level
            while #stack > 0 and indent <= stackIndents[#stackIndents] do
                table.remove(stack)
                table.remove(stackIndents)
            end

            -- Get current context
            local current = result
            for _, ctx in ipairs(stack) do
                current = ctx
            end

            -- Check for array item
            if content:match("^%-%s+") then
                -- Array item
                local valueStr = content:match("^%-%s+(.+)$")
                local value = parseValue(valueStr)

                -- Ensure current is a table (array)
                if type(current) ~= "table" then
                    -- This shouldn't happen, but handle it
                    current = {}
                    if #stack > 0 then
                        local parent = stack[#stack]
                        local parentKey = nil
                        for k, v in pairs(parent) do
                            if v == current then
                                parentKey = k
                                break
                            end
                        end
                        if parentKey then
                            parent[parentKey] = current
                        end
                    end
                end

                -- Add to array
                table.insert(current, value)
            else
                -- Key-value pair
                local key, valueStr = content:match("^([^:]+):%s*(.*)$")
                if not key then
                    return nil, string.format("Invalid YAML syntax at line %d: %s", i, line)
                end

                key = trim(key)
                -- Remove quotes from key if present
                if key:match('^".*"$') then
                    key = key:sub(2, -2)
                elseif key:match("^'.*'$") then
                    key = key:sub(2, -2)
                end

                valueStr = trim(valueStr)

                if valueStr == "" then
                    -- Nested object - create new table
                    local newTable = {}
                    current[key] = newTable
                    table.insert(stack, newTable)
                    table.insert(stackIndents, indent)
                else
                    -- Value
                    local value = parseValue(valueStr)
                    current[key] = value
                end
            end
        end
    end

    return result, nil
end

CM.utils.YAMLToTable = YAMLToTable

CM.DebugPrint("UTILS", "Formatters module loaded")
