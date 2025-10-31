-- CharacterMarkdown - Guilds Section Generator
-- Generates guild membership information markdown sections

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local FormatNumber

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        FormatNumber = CM.utils.FormatNumber
    end
end

-- =====================================================
-- GUILDS
-- =====================================================

local function GenerateGuilds(guildsData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if not guildsData or #guildsData == 0 then
        return ""  -- No guild data available
    end
    
    if format == "discord" then
        markdown = markdown .. "**Guilds:**\n"
        
        for _, guild in ipairs(guildsData) do
            markdown = markdown .. "• " .. guild.name
            if guild.rank and guild.rank ~= "" then
                markdown = markdown .. " - " .. guild.rank
            end
            if guild.memberCount and guild.memberCount > 0 then
                markdown = markdown .. " (" .. FormatNumber(guild.memberCount) .. " members)"
            end
            markdown = markdown .. "\n"
        end
        
        markdown = markdown .. "\n"
    else
        markdown = markdown .. "## 🏛️ Guild Membership\n\n"
        
        if #guildsData > 0 then
            markdown = markdown .. "| Guild Name | Rank | Members | Alliance |\n"
            markdown = markdown .. "|:-----------|:-----|:--------|:---------|\n"
            
            for _, guild in ipairs(guildsData) do
                markdown = markdown .. "| **" .. (guild.name or "Unknown") .. "** | "
                markdown = markdown .. (guild.rank or "Member") .. " | "
                markdown = markdown .. (guild.memberCount and FormatNumber(guild.memberCount) or "0") .. " | "
                markdown = markdown .. (guild.alliance or "Cross-Alliance") .. " |\n"
            end
            
            markdown = markdown .. "\n"
        end
        
        markdown = markdown .. "---\n\n"
    end
    
    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateGuilds = GenerateGuilds

return {
    GenerateGuilds = GenerateGuilds,
}

