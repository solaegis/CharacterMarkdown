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

    local progressText = string.format(
        "%s / %s AP",
        FormatNumber(progression.currentPoints - progression.subRankStart),
        FormatNumber(progression.nextSubRank - progression.subRankStart)
    )

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

    -- Build table rows
    local headers = { "Category", "Value" }
    local rows = {}

    -- Rank
    if pvp.rankName and pvp.rankName ~= "" then
        local rankText = pvp.rankName
        if pvp.rank > 0 then
            rankText = string.format("%s (Rank %d)", rankText, pvp.rank)
        end
        table.insert(rows, { "Rank", rankText })
    end

    -- Alliance Points
    if pvp.rankPoints > 0 then
        table.insert(rows, { "Alliance Points", FormatNumber(pvp.rankPoints) })
    end

    -- Progression
    if showProgression and pvp.progression and pvp.progression.pointsToNext > 0 then
        local progressText = GenerateRankProgression(pvp.progression, format)
        if progressText ~= "" then
            table.insert(rows, { "Progress to Next", progressText })
            table.insert(rows, { "AP Needed", FormatNumber(pvp.progression.pointsToNext) })
        end
    end

    -- Alliance
    if pvp.allianceName and pvp.allianceName ~= "" then
        table.insert(rows, { "Alliance", pvp.allianceName })
    end

    local CreateStyledTable = CM.utils.markdown.CreateStyledTable
    local options = {
        alignment = { "left", "left" },
        format = format,
        coloredHeaders = true,
    }
    markdown = markdown .. CreateStyledTable(headers, rows, options)

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

    -- Build table rows
    local headers = { "Category", "Value" }
    local rows = {}

    -- Campaign name
    local campaignLink = pvp.campaign.name
    if CreateCampaignLink then
        campaignLink = CreateCampaignLink(pvp.campaign.name, format) or pvp.campaign.name
    end
    if pvp.campaign.isActive then
        campaignLink = campaignLink .. " 🟢"
    end
    table.insert(rows, { "Campaign", campaignLink })

    -- Ruleset
    local ruleset = GenerateCampaignRuleset(pvp.campaign)
    if ruleset ~= "" then
        table.insert(rows, { "Ruleset", ruleset })
    end

    -- Campaign Rewards
    if showCampaignRewards and pvp.rewards and pvp.rewards.earnedTier > 0 then
        table.insert(rows, { "Reward Tier", string.format("%d / 5", pvp.rewards.earnedTier) })

        if pvp.rewards.loyaltyStreak > 0 then
            table.insert(rows, { "Loyalty", string.format("%d campaigns", pvp.rewards.loyaltyStreak) })
        end
    end

    local CreateStyledTable = CM.utils.markdown.CreateStyledTable
    local options = {
        alignment = { "left", "left" },
        format = format,
        coloredHeaders = true,
    }
    markdown = markdown .. CreateStyledTable(headers, rows, options)

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

        local headers = { "Category", "Value" }
        local rows = {
            { "Rank", string.format("#%d", leaderboards.playerPosition.rank) },
        }

        if leaderboards.playerPosition.ap > 0 then
            table.insert(rows, { "AP", FormatNumber(leaderboards.playerPosition.ap) })
        end

        if leaderboards.playerPosition.rank == 1 then
            table.insert(rows, { "Status", "👑 Candidate" })
        elseif leaderboards.playerPosition.rank <= 10 then
            table.insert(rows, { "Status", "Top 10" })
        end

        local CreateStyledTable = CM.utils.markdown.CreateStyledTable
        local options = {
            alignment = { "left", "left" },
            format = format,
            coloredHeaders = true,
        }
        markdown = markdown .. CreateStyledTable(headers, rows, options)
    end

    -- Battlegrounds
    if showBattlegrounds and battlegrounds.leaderboards then
        local bg = battlegrounds.leaderboards
        if bg.deathmatch.rank > 0 or bg.flagGames.rank > 0 or bg.landGrab.rank > 0 then
            markdown = markdown .. "#### Battlegrounds\n\n"

            local headers = { "Mode", "Rank" }
            local rows = {}

            if bg.deathmatch.rank > 0 then
                table.insert(rows, { "Deathmatch", string.format("#%d", bg.deathmatch.rank) })
            end

            if bg.flagGames.rank > 0 then
                table.insert(rows, { "Flag Games", string.format("#%d", bg.flagGames.rank) })
            end

            if bg.landGrab.rank > 0 then
                table.insert(rows, { "Land Grab", string.format("#%d", bg.landGrab.rank) })
            end

            local CreateStyledTable = CM.utils.markdown.CreateStyledTable
            local options = {
                alignment = { "left", "right" },
                format = format,
                coloredHeaders = true,
            }
            markdown = markdown .. CreateStyledTable(headers, rows, options)
        end
    end

    return markdown
end

-- =====================================================
-- HELPER: GENERATE ALLIANCE WAR SKILLS
-- =====================================================

local function GenerateAllianceWarSkills(skillProgressionData, format)
    if not skillProgressionData or #skillProgressionData == 0 then
        return ""
    end

    local CreateSkillLineLink = CM.links and CM.links.CreateSkillLineLink
    local CreateAbilityLink = CM.links and CM.links.CreateAbilityLink
    local CreateCollapsible = CM.utils and CM.utils.markdown and CM.utils.markdown.CreateCollapsible

    -- Find Alliance War category
    local allianceWarCategory = nil
    for _, category in ipairs(skillProgressionData) do
        if category.name == "Alliance War" then
            allianceWarCategory = category
            break
        end
    end

    if not allianceWarCategory or not allianceWarCategory.skills or #allianceWarCategory.skills == 0 then
        return ""
    end

    local markdown = ""
    local categoryEmoji = allianceWarCategory.emoji or "🏰"

    -- Group skills by status
    local maxedSkills = {}
    local inProgressSkills = {}
    local lowLevelSkills = {}

    for _, skill in ipairs(allianceWarCategory.skills) do
        if skill.maxed or (skill.rank and skill.rank >= 50) then
            table.insert(maxedSkills, skill)
        elseif skill.rank and skill.rank >= 20 then
            table.insert(inProgressSkills, skill)
        else
            table.insert(lowLevelSkills, skill)
        end
    end

    -- Show maxed skills first (compact)
    if #maxedSkills > 0 then
        local maxedNames = {}
        for _, skill in ipairs(maxedSkills) do
            local skillNameLinked = (CreateSkillLineLink and CreateSkillLineLink(skill.name, format)) or skill.name
            table.insert(maxedNames, "**" .. skillNameLinked .. "**")
        end
        markdown = markdown .. "#### ✅ Maxed\n"
        markdown = markdown .. table.concat(maxedNames, ", ") .. "\n\n"
    end

    -- Show in-progress skills with progress bars
    if #inProgressSkills > 0 then
        markdown = markdown .. "#### 📈 In Progress\n"
        for _, skill in ipairs(inProgressSkills) do
            local skillNameLinked = (CreateSkillLineLink and CreateSkillLineLink(skill.name, format)) or skill.name
            local progressPercent = skill.progress or 0
            local progressBar = GenerateProgressBar(progressPercent, 10)
            markdown = markdown
                .. "- **"
                .. skillNameLinked
                .. "**: Rank "
                .. (skill.rank or 0)
                .. " "
                .. progressBar
                .. " "
                .. progressPercent
                .. "%\n"
        end
        markdown = markdown .. "\n"
    end

    -- Show low-level skills
    if #lowLevelSkills > 0 then
        markdown = markdown .. "#### ⚪ Early Progress\n"
        for _, skill in ipairs(lowLevelSkills) do
            local skillNameLinked = (CreateSkillLineLink and CreateSkillLineLink(skill.name, format)) or skill.name
            local progressPercent = skill.progress or 0
            local progressBar = GenerateProgressBar(progressPercent, 10)
            markdown = markdown
                .. "- **"
                .. skillNameLinked
                .. "**: Rank "
                .. (skill.rank or 0)
                .. " "
                .. progressBar
                .. " "
                .. progressPercent
                .. "%\n"
        end
        markdown = markdown .. "\n"
    end

    -- Show passives for all skills in this category
    local allPassives = {}
    for _, skill in ipairs(allianceWarCategory.skills or {}) do
        if skill.passives and #skill.passives > 0 then
            for _, passive in ipairs(skill.passives) do
                table.insert(allPassives, {
                    name = passive.name,
                    abilityId = passive.abilityId,
                    purchased = passive.purchased,
                    currentRank = passive.currentRank,
                    maxRank = passive.maxRank,
                    skillLineName = skill.name,
                })
            end
        end
    end

    if #allPassives > 0 then
        markdown = markdown .. "#### ✨ Passives\n"
        for _, passive in ipairs(allPassives) do
            local passiveName = (CreateAbilityLink and CreateAbilityLink(passive.name, passive.abilityId, format))
                or passive.name
            local passiveStatus = passive.purchased and "✅" or "🔒"
            local rankInfo = ""
            if passive.currentRank and passive.maxRank and passive.maxRank > 1 then
                rankInfo = string.format(" (%d/%d)", passive.currentRank or 0, passive.maxRank)
            end
            local skillLineLink = (CreateSkillLineLink and CreateSkillLineLink(passive.skillLineName, format))
                or passive.skillLineName
            -- Build entire line as single string to prevent merging
            local line = string.format("- %s %s%s *(from %s)*", passiveStatus, passiveName, rankInfo, skillLineLink)
            -- Remove trailing whitespace and add explicit newline
            line = line:gsub("%s+$", "") .. "\n"
            markdown = markdown .. line
        end
        markdown = markdown .. "\n"
    end

    -- Wrap in collapsible
    if CreateCollapsible and markdown ~= "" then
        return CreateCollapsible("Alliance War", markdown, categoryEmoji, false) or ""
    end

    return markdown
end

-- =====================================================
-- MAIN GENERATOR
-- =====================================================

local function GeneratePvPStats(pvpData, pvpStatsData, format, skillProgressionData, settings)
    InitializeUtilities()

    local CreateCampaignLink = CM.links and CM.links.CreateCampaignLink
    local CreateSkillLineLink = CM.links and CM.links.CreateSkillLineLink
    local CreateAbilityLink = CM.links and CM.links.CreateAbilityLink
    local CreateCollapsible = CM.utils and CM.utils.markdown and CM.utils.markdown.CreateCollapsible

    -- Use provided settings or get current settings
    if not settings then
        settings = CM.GetSettings()
    end

    -- Check what to show
    local showPvPStats = settings.includePvPStats or false
    local showAllianceWarSkills = settings.showAllianceWarSkills or false

    -- Return empty if nothing to show
    if not showPvPStats and not showAllianceWarSkills then
        return ""
    end

    -- Require at least one data source for PvP stats
    if showPvPStats and (not pvpStatsData or not pvpStatsData.pvp) then
        showPvPStats = false
    end

    local pvp = showPvPStats and pvpStatsData and pvpStatsData.pvp or nil
    local leaderboards = showPvPStats and pvpStatsData and pvpStatsData.leaderboards or {}
    local battlegrounds = showPvPStats and pvpStatsData and pvpStatsData.battlegrounds or {}

    -- Determine display level based on settings
    local showProgression = settings.showPvPProgression or false
    local showCampaignRewards = settings.showCampaignRewards or false
    local showLeaderboardsDetail = settings.showLeaderboards or false
    local showBattlegroundsDetail = settings.showBattlegrounds or false
    local detailedPvP = settings.detailedPvP or false

    local markdown = ""

    -- =====================================================
    -- DISCORD FORMAT (Compact)
    -- =====================================================
    if format == "discord" then
        markdown = markdown .. "**⚔️ PvP:**\n\n"

        -- Alliance War Skills section (if enabled)
        if showAllianceWarSkills and skillProgressionData then
            local allianceWarSkills = GenerateAllianceWarSkills(skillProgressionData, format)
            if allianceWarSkills ~= "" then
                markdown = markdown .. allianceWarSkills .. "\n"
            end
        end

        -- PvP Stats section (if enabled)
        if not showPvPStats then
            -- Only Alliance War skills, no PvP stats
            return markdown
        end

        markdown = markdown .. "**PvP Profile:**\n\n"

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
                    markdown = markdown
                        .. string.format(
                            "• Deathmatch: #%d (%s pts)\n",
                            bg.deathmatch.rank,
                            FormatNumber(bg.deathmatch.score)
                        )
                end
                if bg.flagGames.rank > 0 then
                    markdown = markdown
                        .. string.format(
                            "• Flag Games: #%d (%s pts)\n",
                            bg.flagGames.rank,
                            FormatNumber(bg.flagGames.score)
                        )
                end
                if bg.landGrab.rank > 0 then
                    markdown = markdown
                        .. string.format(
                            "• Land Grab: #%d (%s pts)\n",
                            bg.landGrab.rank,
                            FormatNumber(bg.landGrab.score)
                        )
                end
            end
        end

        -- Add Alliance War skills if available
        local allianceWarSkills = GenerateAllianceWarSkills(skillProgressionData, format)
        if allianceWarSkills ~= "" then
            markdown = markdown .. "\n**Alliance War Skills**\n"
            markdown = markdown .. allianceWarSkills
        end

        markdown = markdown .. "\n"

    -- =====================================================
    -- TABLE FORMAT (GitHub/VSCode) with multi-column layout
    -- =====================================================
    -- =====================================================
    -- TABLE FORMAT (GitHub/VSCode) with multi-column layout
    -- =====================================================
    else
        -- Generate content first to check if we have anything to show
        local pvpContent = ""
        local skillsContent = ""
        
        -- PvP Stats section (if enabled)
        if showPvPStats then
            local pvpSection = ""
            pvpSection = pvpSection .. "### PvP Profile\n\n"

            -- Use 2-3 column layout for PvP areas
            local CreateTwoColumnLayout = CM.utils.markdown and CM.utils.markdown.CreateTwoColumnLayout
            local CreateThreeColumnLayout = CM.utils.markdown and CM.utils.markdown.CreateThreeColumnLayout

            -- Generate columns
            local column1 = GenerateAllianceWarColumn(pvp, settings, format)
            local column2 = GenerateCampaignColumn(pvp, settings, format)
            local column3 = GenerateLeaderboardsColumn(leaderboards, battlegrounds, settings, format)

            -- Only add if we have at least one column with content
            if column1 ~= "" or column2 ~= "" or column3 ~= "" then
                -- Use 3-column if we have content in the third column, otherwise 2-column
                if CreateThreeColumnLayout and column3 ~= "" then
                    pvpSection = pvpSection .. CreateThreeColumnLayout(column1, column2, column3)
                elseif CreateTwoColumnLayout then
                    pvpSection = pvpSection .. CreateTwoColumnLayout(column1, column2)
                else
                    -- Fallback to vertical layout
                    pvpSection = pvpSection .. column1 .. "\n"
                    pvpSection = pvpSection .. column2 .. "\n"
                    if column3 ~= "" then
                        pvpSection = pvpSection .. column3 .. "\n"
                    end
                end
                pvpContent = pvpSection
            end
        end

        -- Alliance War Skills section (if enabled)
        if showAllianceWarSkills and skillProgressionData then
            local allianceWarSkills = GenerateAllianceWarSkills(skillProgressionData, format)
            if allianceWarSkills ~= "" then
                skillsContent = allianceWarSkills .. "\n"
            end
        end

        -- Only output the main header if we have content
        if pvpContent ~= "" or skillsContent ~= "" then
            markdown = markdown .. "## ⚔️ PvP\n\n"
            
            if pvpContent ~= "" then
                markdown = markdown .. pvpContent
            end
            
            if skillsContent ~= "" then
                markdown = markdown .. skillsContent
            end

            -- Use CreateSeparator for consistent separator styling
            local CreateSeparator = CM.utils.markdown and CM.utils.markdown.CreateSeparator
            if CreateSeparator then
                markdown = markdown .. CreateSeparator("hr")
            else
                markdown = markdown .. "---\n\n"
            end
        end
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
    GeneratePvP = GeneratePvPStats, -- Alias for compatibility
}
