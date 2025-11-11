-- CharacterMarkdown - PvP Stats Section Generator
-- Generates PvP statistics and campaign data markdown sections

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local FormatNumber, GenerateProgressBar, GenerateAnchor, FormatTime

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        FormatNumber = CM.utils.FormatNumber
        GenerateProgressBar = CM.generators.helpers.GenerateProgressBar
        GenerateAnchor = CM.utils and CM.utils.markdown and CM.utils.markdown.GenerateAnchor
        FormatTime = CM.utils.FormatTime
    end
end

-- Helper: Format seconds to readable time
local function FormatTimeRemaining(seconds)
    if not seconds or seconds <= 0 then
        return "N/A"
    end
    
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    
    if days > 0 then
        return string.format("%dd %dh", days, hours)
    elseif hours > 0 then
        return string.format("%dh %dm", hours, minutes)
    else
        return string.format("%dm", minutes)
    end
end

-- Helper: Generate rank progression text
local function GenerateRankProgression(progression, format)
    if not progression or progression.pointsToNext <= 0 then
        return ""
    end
    
    local progressText = string.format("%s / %s AP", 
        FormatNumber(progression.currentPoints - progression.subRankStart),
        FormatNumber(progression.nextSubRank - progression.subRankStart))
    
    local percentText = string.format("%.1f%%", progression.progressPercent)
    
    if GenerateProgressBar and format ~= "discord" then
        local progressBar = GenerateProgressBar(progression.progressPercent, 10, "▰", "▱")
        return string.format("%s to next grade %s %s", progressText, progressBar, percentText)
    else
        return string.format("%s to next grade (%s)", progressText, percentText)
    end
end

-- Helper: Generate campaign ruleset description
local function GenerateCampaignRuleset(campaign)
    local parts = {}
    
    if campaign.ruleset and campaign.ruleset.name and campaign.ruleset.name ~= "" then
        table.insert(parts, campaign.ruleset.name)
    end
    
    if campaign.ruleset and campaign.ruleset.allowsCP ~= nil then
        if campaign.ruleset.allowsCP then
            table.insert(parts, "CP Enabled")
        else
            table.insert(parts, "No CP")
        end
    end
    
    if #parts > 0 then
        return table.concat(parts, ", ")
    end
    
    return ""
end

-- =====================================================
-- HELPER: GENERATE ALLIANCE WAR COLUMN
-- =====================================================

local function GenerateAllianceWarColumn(pvp, settings, format)
    local markdown = ""
    local showProgression = settings.showPvPProgression or false
    
    markdown = markdown .. "#### Alliance War Status\n\n"
    markdown = markdown .. "| Category | Value |\n"
    markdown = markdown .. "|:---------|:------|\n"
    
    -- Rank
    if pvp.rankName and pvp.rankName ~= "" then
        local rankText = pvp.rankName
        if pvp.rank > 0 then
            rankText = string.format("%s (Rank %d)", rankText, pvp.rank)
        end
        markdown = markdown .. string.format("| **Rank** | %s |\n", rankText)
    end
    
    -- Alliance Points
    if pvp.rankPoints > 0 then
        markdown = markdown .. string.format("| **Alliance Points** | %s |\n", FormatNumber(pvp.rankPoints))
    end
    
    -- Progression
    if showProgression and pvp.progression and pvp.progression.pointsToNext > 0 then
        local progressText = GenerateRankProgression(pvp.progression, format)
        if progressText ~= "" then
            markdown = markdown .. string.format("| **Progress to Next** | %s |\n", progressText)
            markdown = markdown .. string.format("| **AP Needed** | %s |\n", FormatNumber(pvp.progression.pointsToNext))
        end
    end
    
    -- Alliance
    if pvp.allianceName and pvp.allianceName ~= "" then
        markdown = markdown .. string.format("| **Alliance** | %s |\n", pvp.allianceName)
    end
    
    return markdown
end

-- =====================================================
-- HELPER: GENERATE CAMPAIGN COLUMN
-- =====================================================

local function GenerateCampaignColumn(pvp, settings, format)
    local markdown = ""
    local CreateCampaignLink = CM.links and CM.links.CreateCampaignLink
    local showCampaignRewards = settings.showCampaignRewards or false
    local detailedPvP = settings.detailedPvP or false
    
    if not pvp.campaign or not pvp.campaign.name or pvp.campaign.name == "" then
        return markdown
    end
    
    markdown = markdown .. "#### Campaign\n\n"
    markdown = markdown .. "| Category | Value |\n"
    markdown = markdown .. "|:---------|:------|\n"
    
    -- Campaign name
    local campaignLink = pvp.campaign.name
    if CreateCampaignLink then
        campaignLink = CreateCampaignLink(pvp.campaign.name, format) or pvp.campaign.name
    end
    markdown = markdown .. string.format("| **Campaign** | %s", campaignLink)
    if pvp.campaign.isActive then
        markdown = markdown .. " 🟢"
    end
    markdown = markdown .. " |\n"
    
    -- Ruleset
    local ruleset = GenerateCampaignRuleset(pvp.campaign)
    if ruleset ~= "" then
        markdown = markdown .. string.format("| **Ruleset** | %s |\n", ruleset)
    end
    
    -- Campaign Rewards
    if showCampaignRewards and pvp.rewards and pvp.rewards.earnedTier > 0 then
        markdown = markdown .. string.format("| **Reward Tier** | %d / 5 |\n", pvp.rewards.earnedTier)
        
        if pvp.rewards.loyaltyStreak > 0 then
            markdown = markdown .. string.format("| **Loyalty** | %d campaigns |\n", pvp.rewards.loyaltyStreak)
        end
    end
    
    return markdown
end

-- =====================================================
-- HELPER: GENERATE LEADERBOARDS & BATTLEGROUNDS COLUMN
-- =====================================================

local function GenerateLeaderboardsColumn(leaderboards, battlegrounds, settings, format)
    local markdown = ""
    local showLeaderboards = settings.showLeaderboards or false
    local showBattlegrounds = settings.showBattlegrounds or false
    
    -- Leaderboard Position
    if showLeaderboards and leaderboards.playerPosition and leaderboards.playerPosition.found then
        markdown = markdown .. "#### Leaderboard\n\n"
        markdown = markdown .. "| Category | Value |\n"
        markdown = markdown .. "|:---------|:------|\n"
        markdown = markdown .. string.format("| **Rank** | #%d |\n", leaderboards.playerPosition.rank)
        
        if leaderboards.playerPosition.ap > 0 then
            markdown = markdown .. string.format("| **AP** | %s |\n", 
                FormatNumber(leaderboards.playerPosition.ap))
        end
        
        if leaderboards.playerPosition.rank == 1 then
            markdown = markdown .. "| **Status** | 👑 Candidate |\n"
        elseif leaderboards.playerPosition.rank <= 10 then
            markdown = markdown .. "| **Status** | Top 10 |\n"
        end
        
        markdown = markdown .. "\n"
    end
    
    -- Battlegrounds
    if showBattlegrounds and battlegrounds.leaderboards then
        local bg = battlegrounds.leaderboards
        if bg.deathmatch.rank > 0 or bg.flagGames.rank > 0 or bg.landGrab.rank > 0 then
            markdown = markdown .. "#### Battlegrounds\n\n"
            markdown = markdown .. "| Mode | Rank |\n"
            markdown = markdown .. "|:-----|-----:|\n"
            
            if bg.deathmatch.rank > 0 then
                markdown = markdown .. string.format("| **Deathmatch** | #%d |\n", bg.deathmatch.rank)
            end
            
            if bg.flagGames.rank > 0 then
                markdown = markdown .. string.format("| **Flag Games** | #%d |\n", bg.flagGames.rank)
            end
            
            if bg.landGrab.rank > 0 then
                markdown = markdown .. string.format("| **Land Grab** | #%d |\n", bg.landGrab.rank)
            end
        end
    end
    
    return markdown
end

-- =====================================================
-- MAIN GENERATOR
-- =====================================================

local function GeneratePvPStats(pvpData, pvpStatsData, format)
    InitializeUtilities()
    
    local CreateCampaignLink = CM.links and CM.links.CreateCampaignLink
    local settings = CM.GetSettings()
    
    -- Require at least one data source
    if not pvpStatsData or not pvpStatsData.pvp then
        return ""
    end
    
    local pvp = pvpStatsData.pvp
    local leaderboards = pvpStatsData.leaderboards or {}
    local battlegrounds = pvpStatsData.battlegrounds or {}
    
    -- Determine display level based on settings
    local showProgression = settings.showPvPProgression or false
    local showCampaignRewards = settings.showCampaignRewards or false
    local showLeaderboards = settings.showLeaderboards or false
    local showBattlegrounds = settings.showBattlegrounds or false
    local detailedPvP = settings.detailedPvP or false
    
    local markdown = ""
    
    -- =====================================================
    -- DISCORD FORMAT (Compact)
    -- =====================================================
    if format == "discord" then
        markdown = markdown .. "**⚔️ PvP Profile:**\n\n"
        
        -- Alliance War
        if pvp.rankName and pvp.rankName ~= "" then
            markdown = markdown .. "**Alliance War**\n"
            markdown = markdown .. string.format("• Rank: %s", pvp.rankName)
            if pvp.rank > 0 then
                markdown = markdown .. string.format(" (Rank %d)", pvp.rank)
            end
            if pvp.rankPoints > 0 then
                markdown = markdown .. string.format(" • %s AP", FormatNumber(pvp.rankPoints))
            end
            markdown = markdown .. "\n"
            
            -- Progression
            if showProgression and pvp.progression and pvp.progression.pointsToNext > 0 then
                local progressText = GenerateRankProgression(pvp.progression, format)
                if progressText ~= "" then
                    markdown = markdown .. string.format("• Progress: %s\n", progressText)
                end
            end
        end
        
        -- Campaign
        if pvp.campaign and pvp.campaign.name and pvp.campaign.name ~= "" then
            markdown = markdown .. string.format("• Campaign: %s", pvp.campaign.name)
            if pvp.campaign.isActive then
                markdown = markdown .. " [Active]"
            end
            markdown = markdown .. "\n"
            
            local ruleset = GenerateCampaignRuleset(pvp.campaign)
            if ruleset ~= "" then
                markdown = markdown .. string.format("  %s\n", ruleset)
            end
        end
        
        -- Campaign Rewards
        if showCampaignRewards and pvp.rewards and pvp.rewards.earnedTier > 0 then
            markdown = markdown .. "\n**Campaign Standing**\n"
            markdown = markdown .. string.format("• Reward Tier: %d/5\n", pvp.rewards.earnedTier)
            if pvp.rewards.loyaltyStreak > 0 then
                markdown = markdown .. string.format("• Loyalty: %d campaigns\n", pvp.rewards.loyaltyStreak)
            end
        end
        
        -- Leaderboard
        if showLeaderboards and leaderboards.playerPosition and leaderboards.playerPosition.found then
            markdown = markdown .. string.format("• Rank: #%d\n", leaderboards.playerPosition.rank)
        end
        
        -- Battlegrounds
        if showBattlegrounds and battlegrounds.leaderboards then
            local bg = battlegrounds.leaderboards
            if bg.deathmatch.rank > 0 or bg.flagGames.rank > 0 or bg.landGrab.rank > 0 then
                markdown = markdown .. "\n**Battlegrounds**\n"
                if bg.deathmatch.rank > 0 then
                    markdown = markdown .. string.format("• Deathmatch: #%d (%s pts)\n", 
                        bg.deathmatch.rank, FormatNumber(bg.deathmatch.score))
                end
                if bg.flagGames.rank > 0 then
                    markdown = markdown .. string.format("• Flag Games: #%d (%s pts)\n", 
                        bg.flagGames.rank, FormatNumber(bg.flagGames.score))
                end
                if bg.landGrab.rank > 0 then
                    markdown = markdown .. string.format("• Land Grab: #%d (%s pts)\n", 
                        bg.landGrab.rank, FormatNumber(bg.landGrab.score))
                end
            end
        end
        
        markdown = markdown .. "\n"
    
    -- =====================================================
    -- TABLE FORMAT (GitHub/VSCode) with multi-column layout
    -- =====================================================
    else
        local anchorId = GenerateAnchor and GenerateAnchor("⚔️ PvP Profile") or "pvp-profile"
        markdown = markdown .. string.format('<a id="%s"></a>\n\n', anchorId)
        markdown = markdown .. "## ⚔️ PvP Profile\n\n"
        
        -- Use 2-3 column layout for PvP areas
        local CreateTwoColumnLayout = CM.utils.markdown and CM.utils.markdown.CreateTwoColumnLayout
        local CreateThreeColumnLayout = CM.utils.markdown and CM.utils.markdown.CreateThreeColumnLayout
        
        -- Generate columns
        local column1 = GenerateAllianceWarColumn(pvp, settings, format)
        local column2 = GenerateCampaignColumn(pvp, settings, format)
        local column3 = GenerateLeaderboardsColumn(leaderboards, battlegrounds, settings, format)
        
        -- Use 3-column if we have content in the third column, otherwise 2-column
        if CreateThreeColumnLayout and column3 ~= "" then
            markdown = markdown .. CreateThreeColumnLayout(column1, column2, column3)
        elseif CreateTwoColumnLayout then
            markdown = markdown .. CreateTwoColumnLayout(column1, column2)
        else
            -- Fallback to vertical layout
            markdown = markdown .. column1 .. "\n"
            markdown = markdown .. column2 .. "\n"
            if column3 ~= "" then
                markdown = markdown .. column3 .. "\n"
            end
        end
        
        markdown = markdown .. "---\n\n"
    end
    
    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GeneratePvPStats = GeneratePvPStats
-- Also export as GeneratePvP to maintain compatibility
CM.generators.sections.GeneratePvP = GeneratePvPStats

return {
    GeneratePvPStats = GeneratePvPStats,
    GeneratePvP = GeneratePvPStats,  -- Alias for compatibility
}
