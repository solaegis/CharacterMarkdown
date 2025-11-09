-- CharacterMarkdown - Tales of Tribute Section Generator
-- Generates Tales of Tribute progress, decks, and achievements markdown sections

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local FormatNumber, GenerateProgressBar

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        FormatNumber = CM.utils.FormatNumber
        GenerateProgressBar = CM.generators.helpers.GenerateProgressBar
    end
end

-- =====================================================
-- TALES OF TRIBUTE
-- =====================================================

local function GenerateTalesOfTribute(totData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if not totData then
        -- Show placeholder when enabled but no data available
        if format ~= "discord" then
            markdown = markdown .. "## 🎴 Tales of Tribute\n\n"
            markdown = markdown .. "*No Tales of Tribute data available*\n\n---\n\n"
        end
        return markdown
    end
    
    -- Always show section when enabled (even if rank is 0 or minimal data)
    
    local progress = totData.progress or {rank = 0}
    local decks = totData.decks or {total = 0, owned = 0}
    local achievements = totData.achievements or {total = 0, completed = 0}
    local stats = totData.stats or {}
    
    if format == "discord" then
        markdown = markdown .. "**Tales of Tribute:**\n"
        
        if progress.rank and progress.rank > 0 and progress.rankName and progress.rankName ~= "" then
            markdown = markdown .. "• Rank: " .. progress.rankName .. " (Rank " .. progress.rank .. ")\n"
        else
            markdown = markdown .. "• Rank: None (Rank 0)\n"
        end
        
        if progress.level > 0 and progress.maxLevel > 0 then
            markdown = markdown .. "• Level: " .. progress.level .. "/" .. progress.maxLevel .. "\n"
        end
        
        if decks.total > 0 then
            markdown = markdown .. "• Decks: " .. decks.owned .. "/" .. decks.total .. " owned\n"
        end
        
        if achievements.total > 0 then
            local percent = math.floor((achievements.completed / achievements.total) * 100)
            markdown = markdown .. "• Achievements: " .. achievements.completed .. "/" .. achievements.total .. " (" .. percent .. "%)\n"
        end
        
        if stats.gamesPlayed > 0 then
            markdown = markdown .. "• Games Played: " .. FormatNumber(stats.gamesPlayed) .. " (Win Rate: " .. stats.winRate .. "%)\n"
        end
        
        markdown = markdown .. "\n"
    else
        markdown = markdown .. "## 🎴 Tales of Tribute\n\n"
        
        -- Progress section (always show, even if rank is 0)
        markdown = markdown .. "| Category | Value |\n"
        markdown = markdown .. "|:---------|:------|\n"
        
        if progress.rank and progress.rank > 0 and progress.rankName and progress.rankName ~= "" then
            markdown = markdown .. "| **Rank** | " .. progress.rankName .. " (Rank " .. progress.rank .. ") |\n"
        else
            markdown = markdown .. "| **Rank** | None (Rank 0) |\n"
        end
        
        if progress.level and progress.level > 0 and progress.maxLevel and progress.maxLevel > 0 then
            local levelPercent = math.floor((progress.level / progress.maxLevel) * 100)
            local levelProgressBar = GenerateProgressBar(levelPercent, 20)
            markdown = markdown .. "| **Level** | " .. progress.level .. "/" .. progress.maxLevel .. " " .. levelProgressBar .. " " .. levelPercent .. "% |\n"
        end
        
        if progress.experience and progress.experience > 0 and progress.maxExperience and progress.maxExperience > 0 then
            local expPercent = math.floor((progress.experience / progress.maxExperience) * 100)
            markdown = markdown .. "| **Experience** | " .. FormatNumber(progress.experience) .. "/" .. FormatNumber(progress.maxExperience) .. " (" .. expPercent .. "%) |\n"
        end
        
        markdown = markdown .. "\n"
        
        -- Decks section
        if decks.total > 0 then
            markdown = markdown .. "### 📚 Decks\n\n"
            local deckPercent = math.floor((decks.owned / decks.total) * 100)
            local deckProgressBar = GenerateProgressBar(deckPercent, 20)
            markdown = markdown .. "| Progress |\n"
            markdown = markdown .. "| --- |\n"
            markdown = markdown .. "| " .. deckProgressBar .. " " .. deckPercent .. "% (" .. decks.owned .. "/" .. decks.total .. ") |\n\n"
            
            if decks.list and #decks.list > 0 then
                for _, deck in ipairs(decks.list) do
                    local status = deck.owned and "✅" or "❌"
                    markdown = markdown .. "- " .. status .. " " .. deck.name .. "\n"
                end
                markdown = markdown .. "\n"
            end
        end
        
        -- Achievements section
        if achievements.total > 0 then
            markdown = markdown .. "### 🏆 Achievements\n\n"
            local achPercent = math.floor((achievements.completed / achievements.total) * 100)
            local achProgressBar = GenerateProgressBar(achPercent, 20)
            markdown = markdown .. "| Progress |\n"
            markdown = markdown .. "| --- |\n"
            markdown = markdown .. "| " .. achProgressBar .. " " .. achPercent .. "% (" .. achievements.completed .. "/" .. achievements.total .. ") |\n\n"
        end
        
        -- Statistics section
        if stats.gamesPlayed > 0 then
            markdown = markdown .. "### 📊 Statistics\n\n"
            markdown = markdown .. "| Stat | Value |\n"
            markdown = markdown .. "|:-----|:------|\n"
            markdown = markdown .. "| **Games Played** | " .. FormatNumber(stats.gamesPlayed) .. " |\n"
            markdown = markdown .. "| **Games Won** | " .. FormatNumber(stats.gamesWon) .. " |\n"
            markdown = markdown .. "| **Games Lost** | " .. FormatNumber(stats.gamesLost) .. " |\n"
            markdown = markdown .. "| **Win Rate** | " .. stats.winRate .. "% |\n"
            if stats.bestScore > 0 then
                markdown = markdown .. "| **Best Score** | " .. FormatNumber(stats.bestScore) .. " |\n"
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
CM.generators.sections.GenerateTalesOfTribute = GenerateTalesOfTribute

return {
    GenerateTalesOfTribute = GenerateTalesOfTribute,
}

