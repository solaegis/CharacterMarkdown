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
        alliance = "",
        allianceName = "",
        campaign = {
            id = 0,
            name = "",
            type = "",
            status = ""
        },
        stats = {
            kills = 0,
            deaths = 0,
            assists = 0,
            damage = 0,
            healing = 0
        }
    }
    
    -- Get PvP rank
    local success, rank = pcall(GetUnitAvARank, "player")
    if success and rank then
        pvpStats.rank = rank
        local success2, rankName = pcall(GetAvARankName, GetUnitGender("player"), rank)
        if success2 and rankName then
            pvpStats.rankName = rankName
        end
    end
    
    -- Get alliance
    local success3, alliance = pcall(GetUnitAlliance, "player")
    if success3 and alliance then
        pvpStats.alliance = alliance
        local success4, allianceName = pcall(GetAllianceName, alliance)
        if success4 and allianceName then
            pvpStats.allianceName = allianceName
        end
    end
    
    -- Get campaign info
    local success5, campaignId = pcall(GetAssignedCampaignId)
    if success5 and campaignId and campaignId > 0 then
        pvpStats.campaign.id = campaignId
        local success6, campaignName = pcall(GetCampaignName, campaignId)
        if success6 and campaignName then
            pvpStats.campaign.name = campaignName
        end
        
        local success7, campaignType = pcall(GetCampaignType, campaignId)
        if success7 and campaignType then
            pvpStats.campaign.type = campaignType
        end
        
        local success8, campaignStatus = pcall(GetCampaignStatus, campaignId)
        if success8 and campaignStatus then
            pvpStats.campaign.status = campaignStatus
        end
    end
    
    -- Get PvP statistics (if available)
    local success9, kills = pcall(GetPlayerKillCount)
    if success9 and kills then
        pvpStats.stats.kills = kills
    end
    
    local success10, deaths = pcall(GetPlayerDeathCount)
    if success10 and deaths then
        pvpStats.stats.deaths = deaths
    end
    
    local success11, assists = pcall(GetPlayerAssistCount)
    if success11 and assists then
        pvpStats.stats.assists = assists
    end
    
    return pvpStats
end

-- =====================================================
-- CAMPAIGN LEADERBOARDS
-- =====================================================

local function CollectCampaignLeaderboardsData()
    local leaderboards = {
        current = {},
        historical = {}
    }
    
    -- Get current campaign leaderboard
    local success, campaignId = pcall(GetAssignedCampaignId)
    if success and campaignId and campaignId > 0 then
        local success2, numAlliances = pcall(GetNumCampaignAlliances, campaignId)
        if success2 and numAlliances then
            for i = 1, numAlliances do
                local success3, allianceId, allianceName, score = pcall(GetCampaignAllianceScore, campaignId, i)
                if success3 and allianceId and allianceName then
                    table.insert(leaderboards.current, {
                        alliance = allianceId,
                        name = allianceName,
                        score = score or 0,
                        rank = i
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
        stats = {
            wins = 0,
            losses = 0,
            ties = 0,
            total = 0
        },
        current = {
            type = "",
            map = "",
            status = ""
        }
    }
    
    -- Get battleground statistics
    local success, wins = pcall(GetBattlegroundStat, BGSTAT_TYPE_WINS)
    if success and wins then
        battlegrounds.stats.wins = wins
    end
    
    local success2, losses = pcall(GetBattlegroundStat, BGSTAT_TYPE_LOSSES)
    if success2 and losses then
        battlegrounds.stats.losses = losses
    end
    
    local success3, ties = pcall(GetBattlegroundStat, BGSTAT_TYPE_TIES)
    if success3 and ties then
        battlegrounds.stats.ties = ties
    end
    
    battlegrounds.stats.total = battlegrounds.stats.wins + battlegrounds.stats.losses + battlegrounds.stats.ties
    
    -- Get current battleground info
    local success4, bgType = pcall(GetCurrentBattlegroundType)
    if success4 and bgType then
        battlegrounds.current.type = bgType
    end
    
    local success5, bgMap = pcall(GetCurrentBattlegroundMap)
    if success5 and bgMap then
        battlegrounds.current.map = bgMap
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
        battlegrounds = CollectBattlegroundsData()
    }
end

CM.collectors.CollectPvPStatsData = CollectPvPStatsDataMain
