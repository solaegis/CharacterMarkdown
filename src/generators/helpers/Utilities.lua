-- CharacterMarkdown - Generator Utilities
-- Helper functions for markdown generation

local CM = CharacterMarkdown

-- =====================================================
-- PROGRESS BAR GENERATION
-- =====================================================

-- Generate a text-based progress bar
-- Uses standardized blocks (█) for filled and (░) for empty (Issue #6 fix)
local function GenerateProgressBar(percent, width)
    width = width or 10
    local filled = math.floor((percent / 100) * width)
    local empty = width - filled
    return string.rep("█", filled) .. string.rep("░", empty)
end

-- =====================================================
-- STATUS INDICATORS
-- =====================================================

-- Create a compact skill status indicator
-- Using widely-supported emojis for maximum compatibility
local function GetSkillStatusEmoji(rank, progress)
    if rank >= 50 or progress >= 100 then
        return "✅"
    elseif rank >= 40 or progress >= 80 then
        return "🟠"     -- Changed from 🔶 (orange diamond) to 🟠 (orange circle - more widely supported)
    elseif rank >= 20 or progress >= 40 then
        return "📈"
    else
        return "🔰"     -- Keeping 🔰 (widely supported in modern systems)
    end
end

-- =====================================================
-- TEXT FORMATTING
-- =====================================================

-- Format plural correctly
local function Pluralize(count, singular, plural)
    plural = plural or (singular .. "s")
    return count == 1 and singular or plural
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.helpers = CM.generators.helpers or {}
CM.generators.helpers.GenerateProgressBar = GenerateProgressBar
CM.generators.helpers.GetSkillStatusEmoji = GetSkillStatusEmoji
CM.generators.helpers.Pluralize = Pluralize

