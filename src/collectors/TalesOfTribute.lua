-- CharacterMarkdown - Tales of Tribute Data Collector
-- Tales of Tribute progress, decks, and achievements

local CM = CharacterMarkdown

-- =====================================================
-- TALES OF TRIBUTE PROGRESS
-- =====================================================

local function CollectTalesOfTributeData()
    local tot = {
        rank = 0,
        rankName = "",
        experience = 0,
        maxExperience = 0,
        level = 0,
        maxLevel = 0,
        decks = {},
        achievements = {}
    }
    
    -- Get Tales of Tribute rank
    local success, rank = pcall(GetTalesOfTributeRank)
    if success and rank then
        tot.rank = rank
        local success2, rankName = pcall(GetTalesOfTributeRankName, rank)
        if success2 and rankName then
            tot.rankName = rankName
        end
    end
    
    -- Get experience
    local success3, exp, maxExp = pcall(GetTalesOfTributeExperience)
    if success3 and exp and maxExp then
        tot.experience = exp
        tot.maxExperience = maxExp
    end
    
    -- Get level
    local success4, level, maxLevel = pcall(GetTalesOfTributeLevel)
    if success4 and level and maxLevel then
        tot.level = level
        tot.maxLevel = maxLevel
    end
    
    return tot
end

-- =====================================================
-- TALES OF TRIBUTE DECKS
-- =====================================================

local function CollectTalesOfTributeDecksData()
    local decks = {
        total = 0,
        owned = 0,
        list = {}
    }
    
    -- Get total number of decks
    local success, numDecks = pcall(GetNumTalesOfTributeDecks)
    if success and numDecks then
        decks.total = numDecks
        
        -- Get each deck
        for i = 1, numDecks do
            local success2, deckName, isOwned = pcall(GetTalesOfTributeDeckInfo, i)
            if success2 and deckName then
                if isOwned then
                    decks.owned = decks.owned + 1
                end
                
                table.insert(decks.list, {
                    name = deckName,
                    owned = isOwned or false,
                    index = i
                })
            end
        end
        
        -- Sort by name
        table.sort(decks.list, function(a, b)
            return a.name < b.name
        end)
    end
    
    return decks
end

-- =====================================================
-- TALES OF TRIBUTE ACHIEVEMENTS
-- =====================================================

local function CollectTalesOfTributeAchievementsData()
    local achievements = {
        total = 0,
        completed = 0,
        categories = {}
    }
    
    -- Get Tales of Tribute achievement categories
    local success, numCategories = pcall(GetNumTalesOfTributeAchievementCategories)
    if success and numCategories then
        for categoryIndex = 1, numCategories do
            local success2, categoryName, numAchievements = pcall(GetTalesOfTributeAchievementCategoryInfo, categoryIndex)
            if success2 and categoryName and numAchievements then
                local categoryData = {
                    name = categoryName,
                    total = numAchievements,
                    completed = 0,
                    achievements = {}
                }
                
                -- Get achievements in this category
                for achievementIndex = 1, numAchievements do
                    local success3, achievementName, isCompleted = pcall(GetTalesOfTributeAchievementInfo, categoryIndex, achievementIndex)
                    if success3 and achievementName then
                        if isCompleted then
                            categoryData.completed = categoryData.completed + 1
                        end
                        
                        table.insert(categoryData.achievements, {
                            name = achievementName,
                            completed = isCompleted or false,
                            categoryIndex = categoryIndex,
                            achievementIndex = achievementIndex
                        })
                    end
                end
                
                achievements.categories[categoryName] = categoryData
                achievements.total = achievements.total + numAchievements
                achievements.completed = achievements.completed + categoryData.completed
            end
        end
    end
    
    return achievements
end

-- =====================================================
-- TALES OF TRIBUTE STATISTICS
-- =====================================================

local function CollectTalesOfTributeStatsData()
    local stats = {
        gamesPlayed = 0,
        gamesWon = 0,
        gamesLost = 0,
        winRate = 0,
        totalScore = 0,
        bestScore = 0
    }
    
    -- Get game statistics
    local success, gamesPlayed = pcall(GetTalesOfTributeGamesPlayed)
    if success and gamesPlayed then
        stats.gamesPlayed = gamesPlayed
    end
    
    local success2, gamesWon = pcall(GetTalesOfTributeGamesWon)
    if success2 and gamesWon then
        stats.gamesWon = gamesWon
    end
    
    local success3, gamesLost = pcall(GetTalesOfTributeGamesLost)
    if success3 and gamesLost then
        stats.gamesLost = gamesLost
    end
    
    -- Calculate win rate
    if stats.gamesPlayed > 0 then
        stats.winRate = math.floor((stats.gamesWon / stats.gamesPlayed) * 100)
    end
    
    -- Get score statistics
    local success4, totalScore = pcall(GetTalesOfTributeTotalScore)
    if success4 and totalScore then
        stats.totalScore = totalScore
    end
    
    local success5, bestScore = pcall(GetTalesOfTributeBestScore)
    if success5 and bestScore then
        stats.bestScore = bestScore
    end
    
    return stats
end

-- =====================================================
-- MAIN TALES OF TRIBUTE COLLECTOR
-- =====================================================

local function CollectTalesOfTributeDataMain()
    return {
        progress = CollectTalesOfTributeData(),
        decks = CollectTalesOfTributeDecksData(),
        achievements = CollectTalesOfTributeAchievementsData(),
        stats = CollectTalesOfTributeStatsData()
    }
end

CM.collectors.CollectTalesOfTributeData = CollectTalesOfTributeDataMain
