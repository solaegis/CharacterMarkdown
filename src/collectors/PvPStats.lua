-- CharacterMarkdown - PvP Stats & Campaign Data Collector
-- PvP statistics, campaign data, and Alliance War progress

local CM = CharacterMarkdown

-- =====================================================
-- PVP STATISTICS
-- =====================================================

local function CollectPvPStatsData()
    local pvpStats = {
        rank = 0,
        rankName = "",
        rankPoints = 0,
        alliance = "",
        allianceName = "",
        campaign = {
            id = 0,
            name = "",
            type = "",
            status = "",
            isActive = false,
            ruleset = {
                id = 0,
                name = "",
                type = "",
                allowsCP = false,
            },
            timing = {
                secondsToStart = 0,
                secondsToEnd = 0,
            },
            underpop = {
                underdogAlliance = 0,
                hasBonus = false,
            },
        },
        progression = {
            currentPoints = 0,
            subRankStart = 0,
            nextSubRank = 0,
            rankStart = 0,
            nextRank = 0,
            pointsToNext = 0,
            progressPercent = 0,
        },
        rewards = {
            earnedTier = 0,
            nextProgress = 0,
            nextTotal = 0,
            loyaltyStreak = 0,
        },
        emperor = {
            hasCampaignEmperor = false,
            empAlliance = 0,
            empName = "",
            empDisplay = "",
            reignDuration = 0,
        },
        stats = {
            kills = 0,
            deaths = 0,
            assists = 0,
            damage = 0,
            healing = 0,
        },
    }

    -- Get PvP rank
    local rank = CM.SafeCall(GetUnitAvARank, "player") or 0
    CM.DebugPrint("PVPSTATS", string.format("CollectPvPStatsData: rank=%d", rank))
    if rank and rank > 0 then
        pvpStats.rank = rank
        local gender = CM.SafeCall(GetUnitGender, "player")
        local rankName = CM.SafeCall(GetAvARankName, gender, rank)
        CM.DebugPrint("PVPSTATS", string.format("  rankName=%s, gender=%s", tostring(rankName), tostring(gender)))
        if rankName and rankName ~= "" then
            pvpStats.rankName = rankName
        end
    end

    -- Get rank points
    local rankPoints = CM.SafeCall(GetUnitAvARankPoints, "player") or 0
    pvpStats.rankPoints = rankPoints
    pvpStats.progression.currentPoints = rankPoints

    -- Get rank progression
    if rankPoints > 0 then
        local success, subRankStart, nextSubRank, rankStart, nextRank = pcall(GetAvARankProgress, rankPoints)
        if success then
            pvpStats.progression.subRankStart = subRankStart or 0
            pvpStats.progression.nextSubRank = nextSubRank or 0
            pvpStats.progression.rankStart = rankStart or 0
            pvpStats.progression.nextRank = nextRank or 0

            if nextSubRank and subRankStart and nextSubRank > subRankStart then
                pvpStats.progression.pointsToNext = nextSubRank - rankPoints
                local progress = ((rankPoints - subRankStart) / (nextSubRank - subRankStart)) * 100
                pvpStats.progression.progressPercent = progress
            end
        end
    end

    -- Get alliance
    local alliance = CM.SafeCall(GetUnitAlliance, "player")
    if alliance then
        pvpStats.alliance = alliance
        local allianceName = CM.SafeCall(GetAllianceName, alliance)
        if allianceName then
            pvpStats.allianceName = allianceName
        end
    end

    -- Get campaign info
    local campaignId = CM.SafeCall(GetAssignedCampaignId)
    if campaignId and campaignId > 0 then
        pvpStats.campaign.id = campaignId

        local campaignName = CM.SafeCall(GetCampaignName, campaignId)
        if campaignName then
            pvpStats.campaign.name = campaignName
        end

        -- Check if active in campaign
        local isActive = CM.SafeCall(IsInCampaign)
        pvpStats.campaign.isActive = isActive or false

        -- Get campaign ruleset
        local rulesetId = CM.SafeCall(GetCampaignRulesetId, campaignId)
        if rulesetId then
            pvpStats.campaign.ruleset.id = rulesetId

            local rulesetName = CM.SafeCall(GetCampaignRulesetName, rulesetId)
            if rulesetName then
                pvpStats.campaign.ruleset.name = rulesetName
            end

            local rulesetType = CM.SafeCall(GetCampaignRulesetType, rulesetId)
            if rulesetType then
                pvpStats.campaign.ruleset.type = rulesetType
            end
        end

        -- Check if CP is allowed
        local allowsCP = CM.SafeCall(DoesCurrentCampaignRulesetAllowChampionPoints)
        pvpStats.campaign.ruleset.allowsCP = allowsCP or false

        -- Get campaign timing
        local secondsToStart = CM.SafeCall(GetSecondsUntilCampaignStart, campaignId) or 0
        pvpStats.campaign.timing.secondsToStart = secondsToStart

        local secondsToEnd = CM.SafeCall(GetSecondsUntilCampaignEnd, campaignId) or 0
        pvpStats.campaign.timing.secondsToEnd = secondsToEnd

        -- Get underpop bonus info
        if alliance then
            local underdogAlliance = CM.SafeCall(GetCampaignUnderdogLeaderAlliance, campaignId) or 0
            pvpStats.campaign.underpop.underdogAlliance = underdogAlliance

            local hasBonus = CM.SafeCall(IsUnderpopBonusEnabled, campaignId, alliance) or false
            pvpStats.campaign.underpop.hasBonus = hasBonus
        end

        -- Get campaign rewards
        local success, earnedTier, nextProgress, nextTotal = pcall(GetPlayerCampaignRewardTierInfo, campaignId)
        if success and earnedTier then
            pvpStats.rewards.earnedTier = earnedTier
            pvpStats.rewards.nextProgress = nextProgress or 0
            pvpStats.rewards.nextTotal = nextTotal or 0
        end

        local loyaltyStreak = CM.SafeCall(GetCurrentCampaignLoyaltyStreak) or 0
        pvpStats.rewards.loyaltyStreak = loyaltyStreak

        -- Get emperor info
        local hasCampaignEmperor = CM.SafeCall(DoesCampaignHaveEmperor, campaignId) or false
        pvpStats.emperor.hasCampaignEmperor = hasCampaignEmperor

        if hasCampaignEmperor then
            local success2, empAlliance, empName, empDisplay = pcall(GetCampaignEmperorInfo, campaignId)
            if success2 then
                pvpStats.emperor.empAlliance = empAlliance or 0
                pvpStats.emperor.empName = empName or ""
                pvpStats.emperor.empDisplay = empDisplay or ""
            end

            local reignDuration = CM.SafeCall(GetCampaignEmperorReignDuration, campaignId) or 0
            pvpStats.emperor.reignDuration = reignDuration
        end
    end

    CM.DebugPrint(
        "PVPSTATS",
        string.format(
            "CollectPvPStatsData result: rank=%d, rankName=%s, rankPoints=%d, allianceName=%s",
            pvpStats.rank,
            pvpStats.rankName or "nil",
            pvpStats.rankPoints,
            pvpStats.allianceName or "nil"
        )
    )

    return pvpStats
end

-- =====================================================
-- CAMPAIGN LEADERBOARDS
-- =====================================================

local function CollectCampaignLeaderboardsData()
    local leaderboards = {
        playerPosition = {
            rank = 0,
            ap = 0,
            found = false,
        },
        allianceScores = {},
    }

    -- Get player alliance
    local alliance = CM.SafeCall(GetUnitAlliance, "player")
    local campaignId = CM.SafeCall(GetAssignedCampaignId)

    if campaignId and campaignId > 0 then
        -- Query campaign leaderboard for player's alliance
        if alliance then
            -- Note: QueryCampaignLeaderboardData must be called to populate data
            -- This is async, so data may not be immediately available
            CM.SafeCall(QueryCampaignLeaderboardData, alliance)

            -- Try to find player in leaderboard
            local numEntries = CM.SafeCall(GetNumCampaignLeaderboardEntries, campaignId) or 0
            for i = 1, numEntries do
                local success, isPlayer, ranking, charName, ap, classId, entryAlliance, displayName =
                    pcall(GetCampaignLeaderboardEntryInfo, campaignId, i)

                if success and isPlayer then
                    leaderboards.playerPosition.found = true
                    leaderboards.playerPosition.rank = ranking or 0
                    leaderboards.playerPosition.ap = ap or 0
                    break
                end
            end
        end

        -- Get alliance scores
        local success, numAlliances = pcall(GetNumCampaignAlliances, campaignId)
        if success and numAlliances then
            for i = 1, numAlliances do
                local success2, allianceId, allianceName, score = pcall(GetCampaignAllianceScore, campaignId, i)
                if success2 and allianceId and allianceName then
                    table.insert(leaderboards.allianceScores, {
                        alliance = allianceId,
                        name = allianceName,
                        score = score or 0,
                        rank = i,
                    })
                end
            end
        end
    end

    return leaderboards
end

-- =====================================================
-- BATTLEGROUNDS
-- =====================================================

local function CollectBattlegroundsData()
    local battlegrounds = {
        leaderboards = {
            deathmatch = {
                rank = 0,
                score = 0,
            },
            flagGames = {
                rank = 0,
                score = 0,
            },
            landGrab = {
                rank = 0,
                score = 0,
            },
        },
        currentMatch = {
            isActive = false,
            kills = 0,
            deaths = 0,
            assists = 0,
            medals = {},
        },
    }

    -- Query battleground leaderboards (async, data may not be immediately available)
    CM.SafeCall(QueryBattlegroundLeaderboardData, BATTLEGROUND_LEADERBOARD_TYPE_DEATHMATCH)
    CM.SafeCall(QueryBattlegroundLeaderboardData, BATTLEGROUND_LEADERBOARD_TYPE_FLAG_GAMES)
    CM.SafeCall(QueryBattlegroundLeaderboardData, BATTLEGROUND_LEADERBOARD_TYPE_LAND_GRAB)

    -- Get leaderboard positions
    local success, dmRank, dmScore =
        pcall(GetBattlegroundLeaderboardLocalPlayerInfo, BATTLEGROUND_LEADERBOARD_TYPE_DEATHMATCH)
    if success and dmRank then
        battlegrounds.leaderboards.deathmatch.rank = dmRank
        battlegrounds.leaderboards.deathmatch.score = dmScore or 0
    end

    local success2, fgRank, fgScore =
        pcall(GetBattlegroundLeaderboardLocalPlayerInfo, BATTLEGROUND_LEADERBOARD_TYPE_FLAG_GAMES)
    if success2 and fgRank then
        battlegrounds.leaderboards.flagGames.rank = fgRank
        battlegrounds.leaderboards.flagGames.score = fgScore or 0
    end

    local success3, lgRank, lgScore =
        pcall(GetBattlegroundLeaderboardLocalPlayerInfo, BATTLEGROUND_LEADERBOARD_TYPE_LAND_GRAB)
    if success3 and lgRank then
        battlegrounds.leaderboards.landGrab.rank = lgRank
        battlegrounds.leaderboards.landGrab.score = lgScore or 0
    end

    -- Check if currently in a battleground
    local isActive = CM.SafeCall(IsActiveWorldBattleground) or false
    battlegrounds.currentMatch.isActive = isActive

    if isActive then
        -- Get current match stats
        local playerIndex = CM.SafeCall(GetScoreboardLocalPlayerEntryIndex)
        if playerIndex then
            local kills = CM.SafeCall(GetScoreboardEntryScoreByType, playerIndex, SCORE_TRACKER_TYPE_KILL_COUNT) or 0
            battlegrounds.currentMatch.kills = kills

            local deaths = CM.SafeCall(GetScoreboardEntryScoreByType, playerIndex, SCORE_TRACKER_TYPE_DEATH_COUNT) or 0
            battlegrounds.currentMatch.deaths = deaths

            local assists = CM.SafeCall(GetScoreboardEntryScoreByType, playerIndex, SCORE_TRACKER_TYPE_ASSIST_COUNT)
                or 0
            battlegrounds.currentMatch.assists = assists

            -- Get medals earned
            local medalId = CM.SafeCall(GetNextScoreboardEntryMedalId, playerIndex, nil, nil)
            while medalId do
                local count = CM.SafeCall(GetScoreboardEntryNumEarnedMedalsById, playerIndex, medalId) or 0
                if count > 0 then
                    local success4, name, icon, condition, scoreReward = pcall(GetMedalInfo, medalId)
                    if success4 and name then
                        table.insert(battlegrounds.currentMatch.medals, {
                            name = name,
                            count = count,
                            icon = icon,
                            scoreReward = scoreReward or 0,
                        })
                    end
                end
                medalId = CM.SafeCall(GetNextScoreboardEntryMedalId, playerIndex, nil, medalId)
            end
        end
    end

    return battlegrounds
end

-- =====================================================
-- MAIN PVP STATS COLLECTOR
-- =====================================================

local function CollectPvPStatsDataMain()
    return {
        pvp = CollectPvPStatsData(),
        leaderboards = CollectCampaignLeaderboardsData(),
        battlegrounds = CollectBattlegroundsData(),
    }
end

CM.collectors.CollectPvPStatsData = CollectPvPStatsDataMain
