-- CharacterMarkdown - Advanced Markdown Utilities
-- Implements GitHub callouts, badges, collapsible sections, styled tables, and visual enhancements
-- Based on: https://github.com/DavidWells/advanced-markdown

local CM = CharacterMarkdown
CM.utils = CM.utils or {}
CM.utils.markdown = CM.utils.markdown or {}

-- Localize frequently used functions for performance
local string_format = string.format
local string_gsub = string.gsub
local string_rep = string.rep
local table_concat = table.concat

-- =====================================================
-- GITHUB CALLOUTS (Native Markdown Alerts)
-- =====================================================
-- GitHub/GitLab/Azure DevOps native callout syntax:
-- > [!NOTE], > [!TIP], > [!IMPORTANT], > [!WARNING], > [!CAUTION]

local CALLOUT_TYPES = {
    note = {
        tag = "NOTE",
        emoji = "ℹ️",
        desc = "Information that users should take into account"
    },
    tip = {
        tag = "TIP",
        emoji = "💡",
        desc = "Optional information to help user success"
    },
    important = {
        tag = "IMPORTANT",
        emoji = "❗",
        desc = "Crucial information necessary for users to succeed"
    },
    warning = {
        tag = "WARNING",
        emoji = "⚠️",
        desc = "Critical content demanding immediate attention"
    },
    caution = {
        tag = "CAUTION",
        emoji = "🔥",
        desc = "Negative potential consequences of an action"
    },
    success = {
        tag = "TIP", -- Map to TIP for GitHub compatibility
        emoji = "✅",
        desc = "Successful completion or positive outcome"
    },
    danger = {
        tag = "CAUTION", -- Map to CAUTION for GitHub compatibility
        emoji = "❌",
        desc = "Critical danger or failure state"
    }
}

--[[
    Create a GitHub-native callout box
    @param type string - "note", "tip", "important", "warning", "caution", "success", "danger"
    @param content string - The content to display in the callout
    @param format string - Target format ("github", "vscode", "discord")
    @return string - Formatted callout
]]
local function CreateCallout(type, content, format)
    if not content or content == "" then return "" end
    
    local callout = CALLOUT_TYPES[type] or CALLOUT_TYPES.note
    format = format or "github"
    
    -- Escape newlines in content for proper rendering
    -- Prefix all lines (including first) with "> "
    local escaped_content = string_gsub(content, "\n", "\n> ")
    -- Ensure first line also has "> " prefix
    if not string_match(escaped_content, "^> ") then
        escaped_content = "> " .. escaped_content
    end
    
    if format == "github" or format == "vscode" then
        -- GitHub/VS Code native callout syntax
        return string_format("> [!%s]\n%s\n\n", callout.tag, escaped_content)
    elseif format == "discord" then
        -- Discord uses simple blockquote with emoji
        return string_format("> %s **%s**\n> %s\n\n", callout.emoji, callout.tag, escaped_content)
    else
        -- Fallback: simple blockquote
        return string_format("> %s %s\n\n", callout.emoji, escaped_content)
    end
end

CM.utils.markdown.CreateCallout = CreateCallout

-- =====================================================
-- BADGES (shields.io style)
-- =====================================================

--[[
    Create a badge using shields.io
    @param label string - Badge label
    @param value string or number - Badge value
    @param color string - Badge color (blue, green, red, yellow, orange, purple, etc.)
    @param style string - Badge style ("flat", "flat-square", "plastic", "for-the-badge")
    @return string - Markdown badge
]]
local function CreateBadge(label, value, color, style)
    color = color or "blue"
    style = style or "flat"
    
    -- Sanitize label and value: remove control characters and ensure they're strings
    local safe_label = tostring(label or "")
    local safe_value = tostring(value or "")
    
    -- Remove control characters that could break URLs
    safe_label = safe_label:gsub("[\r\n\t<>]", "")
    safe_value = safe_value:gsub("[\r\n\t<>]", "")
    
    -- URL-encode label and value (spaces to %20)
    local encoded_label = string_gsub(safe_label, " ", "%%20")
    local encoded_value = string_gsub(safe_value, " ", "%%20")
    
    -- Ensure URL is complete and valid
    local url = string_format(
        "https://img.shields.io/badge/%s-%s-%s?style=%s",
        encoded_label, encoded_value, color, style
    )
    
    -- Validate URL is complete before returning
    if url:find("^https://img.shields.io/badge/") and url:find("?style=") then
        return string_format("![%s](<%s>)", safe_label, url)
    else
        -- Fallback: return plain text if URL generation fails
        return string_format("**%s:** %s", safe_label, safe_value)
    end
end

CM.utils.markdown.CreateBadge = CreateBadge

--[[
    Create a series of badges on one line
    @param badges table - Array of badge definitions {label, value, color, style}
    @param separator string - Separator between badges (default: " ")
    @return string - Space-separated badges
]]
local function CreateBadgeRow(badges, separator)
    separator = separator or " "
    local badge_strings = {}
    
    for _, badge in ipairs(badges) do
        table.insert(badge_strings, CreateBadge(
            badge.label or badge[1],
            badge.value or badge[2],
            badge.color or badge[3],
            badge.style or badge[4]
        ))
    end
    
    return table_concat(badge_strings, separator)
end

CM.utils.markdown.CreateBadgeRow = CreateBadgeRow

-- =====================================================
-- COLLAPSIBLE SECTIONS
-- =====================================================

--[[
    Create a collapsible HTML details section
    @param title string - Summary/title of the section
    @param content string - Content to show when expanded
    @param emoji string - Optional emoji prefix
    @param defaultOpen boolean - Whether section is open by default
    @return string - HTML details/summary block
]]
local function CreateCollapsible(title, content, emoji, defaultOpen)
    if not content or content == "" then return "" end
    
    local open_attr = defaultOpen and " open" or ""
    local emoji_prefix = emoji and (emoji .. " ") or ""
    
    return string_format([[
<details%s>
<summary><strong>%s%s</strong></summary>

%s

</details>

]], open_attr, emoji_prefix, title, content)
end

CM.utils.markdown.CreateCollapsible = CreateCollapsible

-- =====================================================
-- ALIGNED CONTENT
-- =====================================================

--[[
    Create centered content block
    @param content string - Content to center
    @return string - HTML-centered content
]]
local function CreateCenteredBlock(content)
    if not content or content == "" then return "" end
    
    return string_format([[
<div align="center">

%s

</div>

]], content)
end

CM.utils.markdown.CreateCenteredBlock = CreateCenteredBlock

--[[
    Create a two-column layout
    @param left_content string - Content for left column
    @param right_content string - Content for right column
    @param left_width number - Width percentage for left column (default: 50)
    @return string - HTML table with two columns
]]
local function CreateTwoColumns(left_content, right_content, left_width)
    left_width = left_width or 50
    local right_width = 100 - left_width
    
    return string_format([[
<table>
<tr>
<td width="%d%%" valign="top">

%s

</td>
<td width="%d%%" valign="top">

%s

</td>
</tr>
</table>

]], left_width, left_content, right_width, right_content)
end

CM.utils.markdown.CreateTwoColumns = CreateTwoColumns

-- =====================================================
-- FANCY BOXES & CARDS
-- =====================================================

--[[
    Create a highlighted info box (always uses page width for responsiveness)
    @param content string - Content to display
    @param width number - Deprecated: ignored (always uses 100% page width)
    @return string - HTML table-based box
]]
local function CreateInfoBox(content, width)
    if not content or content == "" then return "" end
    -- width parameter is deprecated - always use page width (100%) for responsive design
    
    -- Clean content: remove leading/trailing whitespace, replace newlines with spaces for inline display
    local cleanContent = tostring(content)
    cleanContent = cleanContent:gsub("^%s+", "")  -- Remove leading whitespace
    cleanContent = cleanContent:gsub("%s+$", "")  -- Remove trailing whitespace
    cleanContent = cleanContent:gsub("%s+", " ")  -- Replace all whitespace sequences with single space
    cleanContent = cleanContent:gsub("\n", " ")   -- Replace newlines with spaces
    
    -- Convert markdown to HTML (markdown doesn't work inside HTML tags)
    cleanContent = cleanContent:gsub("%*%*(.-)%*%*", "<strong>%1</strong>")  -- **bold**
    cleanContent = cleanContent:gsub("%*(.-)%*", "<em>%1</em>")  -- *italic*
    
    -- Escape remaining HTML-breaking characters (but keep the HTML we just created)
    cleanContent = cleanContent:gsub("<", "&lt;"):gsub(">", "&gt;")
    cleanContent = cleanContent:gsub("&lt;strong&gt;", "<strong>")
    cleanContent = cleanContent:gsub("&lt;/strong&gt;", "</strong>")
    cleanContent = cleanContent:gsub("&lt;em&gt;", "<em>")
    cleanContent = cleanContent:gsub("&lt;/em&gt;", "</em>")
    
    -- Use 100% width for responsive page width
    return string_format([[
<div align="center">
<table width="100%%">
<tbody>
<tr>
<td align="center">
<sub>%s</sub>
</td>
</tr>
</tbody>
</table>
</div>

]], cleanContent)
end

CM.utils.markdown.CreateInfoBox = CreateInfoBox

-- =====================================================
-- VISUAL STAT BARS
-- =====================================================

--[[
    Create a progress bar with percentage
    @param current number - Current value
    @param max number - Maximum value
    @param width number - Character width of bar (default: 20)
    @param style string - Bar style ("github", "vscode", "discord")
    @param label string - Optional label
    @return string - Text-based progress bar
]]
local function CreateProgressBar(current, max, width, style, label)
    if not current or not max or max == 0 then return "" end
    
    width = width or 20
    style = style or "github"
    
    local percentage = math.floor((current / max) * 100)
    local filled = math.floor((percentage / 100) * width)
    local empty = width - filled
    
    -- STANDARDIZED: Always use █ (filled) and ░ (empty) for consistency across all sections
    local bar = string_rep("█", filled) .. string_rep("░", empty)
    
    if label then
        return string_format("%s: %s %d%% (%d/%d)", label, bar, percentage, current, max)
    else
        return string_format("%s %d%%", bar, percentage)
    end
end

CM.utils.markdown.CreateProgressBar = CreateProgressBar

-- =====================================================
-- VISUAL INDICATORS
-- =====================================================

--[[
    Get a visual indicator emoji based on completion/status
    @param value number - Current value
    @param max number - Maximum value
    @param thresholds table - Optional custom thresholds {complete, high, medium, low}
    @return string - Emoji indicator
]]
local function GetProgressIndicator(value, max, thresholds)
    if not value or not max or max == 0 then return "⚪" end
    
    thresholds = thresholds or {complete = 100, high = 75, medium = 50, low = 25}
    local percentage = (value / max) * 100
    
    -- Using widely-supported emoji circles (🟢🟡🟠🔴 may not render on all systems)
    -- Fallback to simpler symbols for maximum compatibility
    if percentage >= thresholds.complete then
        return "🟢" -- Complete/Full (green circle - widely supported)
    elseif percentage >= thresholds.high then
        return "🟡" -- High/Almost full (yellow circle - widely supported)
    elseif percentage >= thresholds.medium then
        return "🟠" -- Medium/Half (orange circle - widely supported)
    elseif percentage >= thresholds.low then
        return "🔴" -- Low/Quarter (red circle - widely supported)
    else
        return "⚪" -- Empty/None (white circle - widely supported, changed from ⚫)
    end
end

CM.utils.markdown.GetProgressIndicator = GetProgressIndicator

--[[
    Get quality/tier indicator emoji
    @param quality string - Quality tier ("legendary", "epic", "superior", "fine", "normal", "trash")
    @return string - Emoji + quality name
]]
local function GetQualityIndicator(quality)
    -- Using widely-supported quality indicators (avoiding newer colored squares)
    local indicators = {
        legendary = "⭐",    -- Gold/Star (changed from 🟨 - more widely supported)
        epic = "💜",         -- Purple heart (changed from 🟪 - more widely supported)
        superior = "💙",     -- Blue heart (changed from 🟦 - more widely supported)
        fine = "💚",         -- Green heart (changed from 🟩 - more widely supported)
        normal = "⚪",       -- White circle (changed from ⬜ - more widely supported)
        trash = "⚫",        -- Black circle (changed from ⬛ - more widely supported)
        artifact = "🟠",     -- Orange circle (for ESO artifacts - widely supported)
        mythic = "💜✨"      -- Purple heart with sparkle (more widely supported)
    }
    
    return indicators[quality:lower()] or "⚪"
end

CM.utils.markdown.GetQualityIndicator = GetQualityIndicator

-- =====================================================
-- FORMATTED LISTS
-- =====================================================

--[[
    Create a compact grid list (for currencies, small stats)
    @param items table - Array of {emoji, label, value}
    @param columns number - Number of columns (default: 4)
    @param format string - Target format
    @return string - HTML table or markdown list
]]
-- Helper function to convert markdown links to HTML links
local function ConvertMarkdownLinksToHTML(text)
    if not text or text == "" then return text end
    -- Convert [text](url) to <a href="url">text</a>
    return string_gsub(text, "%[(.-)%]%((.-)%)", '<a href="%2">%1</a>')
end

local function CreateCompactGrid(items, columns, format)
    if not items or #items == 0 then return "" end
    
    columns = columns or 4
    format = format or "github"
    
    if format ~= "github" and format ~= "vscode" then
        -- Fallback to simple list for Discord
        local lines = {}
        for _, item in ipairs(items) do
            table.insert(lines, string_format("%s **%s**: %s", 
                item.emoji or "•", item.label, item.value))
        end
        return table_concat(lines, "\n") .. "\n\n"
    end
    
    -- HTML table for GitHub/VSCode
    local rows = {}
    table.insert(rows, "<div align=\"center\">")
    table.insert(rows, "<table>")
    table.insert(rows, "<tr>")
    
    for i, item in ipairs(items) do
        -- Convert markdown links in label to HTML links for table cells
        local labelHTML = ConvertMarkdownLinksToHTML(item.label or "")
        
        table.insert(rows, string_format(
            "<td align=\"center\">%s<br><strong>%s</strong><br>%s</td>",
            item.emoji or "", item.value, labelHTML
        ))
        
        -- New row after every N columns
        if i % columns == 0 and i < #items then
            table.insert(rows, "</tr>\n<tr>")
        end
    end
    
    table.insert(rows, "</tr>")
    table.insert(rows, "</table>")
    table.insert(rows, "</div>\n\n")
    
    return table_concat(rows, "\n")
end

CM.utils.markdown.CreateCompactGrid = CreateCompactGrid

-- =====================================================
-- ENHANCED TABLES
-- =====================================================

--[[
    Create a styled table with alternating row colors (GitHub only)
    @param headers table - Array of header strings
    @param rows table - Array of row arrays
    @param alignment table - Optional alignment for each column ("left", "center", "right")
    @return string - Markdown table
]]
local function CreateStyledTable(headers, rows, alignment)
    if not headers or #headers == 0 then return "" end
    
    alignment = alignment or {}
    local lines = {}
    
    -- Header row
    table.insert(lines, "| " .. table_concat(headers, " | ") .. " |")
    
    -- Separator row with alignment
    local separators = {}
    for i = 1, #headers do
        local align = alignment[i] or "left"
        if align == "center" then
            table.insert(separators, ":---:")
        elseif align == "right" then
            table.insert(separators, "---:")
        else
            table.insert(separators, "---")
        end
    end
    table.insert(lines, "| " .. table_concat(separators, " | ") .. " |")
    
    -- Data rows
    for _, row in ipairs(rows) do
        table.insert(lines, "| " .. table_concat(row, " | ") .. " |")
    end
    
    return table_concat(lines, "\n") .. "\n\n"
end

CM.utils.markdown.CreateStyledTable = CreateStyledTable

-- =====================================================
-- VISUAL SEPARATORS
-- =====================================================

--[[
    Create a visual section separator
    @param style string - "hr" (horizontal rule), "emoji", "box", "fade"
    @param emoji string - Optional emoji for emoji style
    @return string - Separator line
]]
local function CreateSeparator(style, emoji)
    style = style or "hr"
    
    if style == "hr" then
        return "---\n\n"
    elseif style == "emoji" then
        emoji = emoji or "⚔️"
        return string_format("\n%s %s %s\n\n", string_rep("━", 15), emoji, string_rep("━", 15))
    elseif style == "box" then
        return "\n" .. string_rep("═", 60) .. "\n\n"
    elseif style == "fade" then
        return "\n・・・\n\n"
    else
        return "\n\n"
    end
end

CM.utils.markdown.CreateSeparator = CreateSeparator

-- =====================================================
-- TEXT FORMATTING
-- =====================================================

--[[
    Create a header with emoji and optional subtitle
    @param title string - Main title
    @param emoji string - Optional emoji prefix
    @param subtitle string - Optional subtitle
    @param level number - Header level (1-6, default: 2)
    @return string - Formatted header
]]
local function CreateHeader(title, emoji, subtitle, level)
    level = level or 2
    local prefix = string_rep("#", level)
    local emoji_prefix = emoji and (emoji .. " ") or ""
    
    local header = string_format("%s %s%s\n\n", prefix, emoji_prefix, title)
    
    if subtitle and subtitle ~= "" then
        header = header .. string_format("*%s*\n\n", subtitle)
    end
    
    return header
end

CM.utils.markdown.CreateHeader = CreateHeader

--[[
    Format text with multiple styles
    @param text string - Text to format
    @param styles table - Array of style names: "bold", "italic", "code", "strikethrough"
    @return string - Formatted text
]]
local function FormatText(text, styles)
    if not text or text == "" then return "" end
    if not styles or #styles == 0 then return text end
    
    local result = text
    
    for _, style in ipairs(styles) do
        if style == "bold" then
            result = "**" .. result .. "**"
        elseif style == "italic" then
            result = "*" .. result .. "*"
        elseif style == "code" then
            result = "`" .. result .. "`"
        elseif style == "strikethrough" then
            result = "~~" .. result .. "~~"
        elseif style == "underline" then
            result = "<ins>" .. result .. "</ins>"
        elseif style == "highlight" then
            result = "<mark>" .. result .. "</mark>"
        end
    end
    
    return result
end

CM.utils.markdown.FormatText = FormatText

-- =====================================================
-- MODULE INITIALIZATION
-- =====================================================

CM.DebugPrint("UTILS", "AdvancedMarkdown module loaded with " .. 
    "callouts, badges, collapsible sections, progress bars, and styled tables")

-- Functions are already exported to CM.utils.markdown above
-- No need to return (this is not a module requiring return)
