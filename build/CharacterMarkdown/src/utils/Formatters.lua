-- CharacterMarkdown - Formatting Utilities
-- Number formatting, progress bars, callouts

local CM = CharacterMarkdown

-- =====================================================
-- NUMBER FORMATTING
-- =====================================================

-- Format number with comma separators
local function FormatNumber(number)
    if not number then return "0" end
    local formatted = tostring(math.floor(number))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- Make FormatNumber global for backward compatibility
_G.FormatNumber = FormatNumber
CM.utils.FormatNumber = FormatNumber

-- =====================================================
-- PROGRESS BARS
-- =====================================================

-- Generate progress bar (10 blocks)
local function CreateProgressBar(percentage, style)
    style = style or "default"
    local filled = math.floor(percentage / 10)
    local empty = 10 - filled
    
    if style == "github" then
        local bar = string.rep("█", filled) .. string.rep("░", empty)
        return bar .. " " .. percentage .. "%"
    elseif style == "vscode" then
        local bar = string.rep("▓", filled) .. string.rep("░", empty)
        return bar .. " " .. percentage .. "%"
    else
        return string.rep("█", filled) .. string.rep("░", empty)
    end
end

CM.utils.CreateProgressBar = CreateProgressBar

-- =====================================================
-- CALLOUT BOXES
-- =====================================================

-- Create callout box for markdown
local function CreateCallout(type, content, format)
    local types = {
        info = {emoji = "ℹ️", color = "#0969da", title = "Info"},
        warning = {emoji = "⚠️", color = "#d29922", title = "Warning"},
        success = {emoji = "✅", color = "#1a7f37", title = "Success"},
    }
    
    local info = types[type] or types.info
    
    if format == "github" then
        return string.format(
            "<blockquote style=\"border-left: 4px solid %s; background: %s10; padding: 10px;\">\n%s <strong>%s</strong>\n\n%s\n</blockquote>",
            info.color, info.color, info.emoji, info.title, content
        )
    else
        return string.format("> %s **%s**\n> \n> %s", info.emoji, info.title, content:gsub("\n", "\n> "))
    end
end

CM.utils.CreateCallout = CreateCallout
