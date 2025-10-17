-- CharacterMarkdown - Progression Data Collector
-- Champion Points, achievements, enlightenment

local CM = CharacterMarkdown

-- =====================================================
-- CHAMPION POINTS
-- =====================================================

local function CollectChampionPointData()
    local data = { total = 0, spent = 0, disciplines = {} }
    
    data.total = GetPlayerChampionPointsEarned() or 0
    
    if data.total < 10 then
        return data
    end
    
    local success, allocations = pcall(function()
        local disciplines = {}
        local totalSpent = 0
        local numDisciplines = GetNumChampionDisciplines()
        
        if numDisciplines and numDisciplines > 0 then
            for disciplineIndex = 1, numDisciplines do
                local disciplineId = GetChampionDisciplineId(disciplineIndex)
                if disciplineId then
                    local disciplineName = GetChampionDisciplineName(disciplineId) or "Unknown"
                    
                    -- Add emoji based on discipline name
                    local emoji = "⚔️"
                    if disciplineName:find("Craft") then
                        emoji = "⚒️"
                    elseif disciplineName:find("Fitness") or disciplineName:find("Warfare") then
                        emoji = "💪"
                    end
                    
                    local disciplineData = { 
                        name = disciplineName, 
                        emoji = emoji,
                        skills = {}, 
                        total = 0 
                    }
                    
                    local numSkills = GetNumChampionDisciplineSkills(disciplineId)
                    if numSkills then
                        for skillIndex = 1, numSkills do
                            local skillId = GetChampionSkillId(disciplineId, skillIndex)
                            if skillId then
                                local pointsSpent = GetNumPointsSpentOnChampionSkill(skillId)
                                if pointsSpent and pointsSpent > 0 then
                                    local skillName = GetChampionSkillName(skillId) or "Unknown"
                                    table.insert(disciplineData.skills, { 
                                        name = skillName, 
                                        points = pointsSpent 
                                    })
                                    disciplineData.total = disciplineData.total + pointsSpent
                                    totalSpent = totalSpent + pointsSpent
                                end
                            end
                        end
                    end
                    
                    if disciplineData.total > 0 then
                        table.insert(disciplines, disciplineData)
                    end
                end
            end
        end
        
        return {disciplines = disciplines, totalSpent = totalSpent}
    end)
    
    if success and allocations then
        data.spent = allocations.totalSpent
        data.disciplines = allocations.disciplines
    end
    
    return data
end

CM.collectors.CollectChampionPointData = CollectChampionPointData

-- =====================================================
-- PROGRESSION DATA
-- =====================================================

local function CollectProgressionData()
    local progression = {}
    
    progression.skillPoints = GetAvailableSkillPoints() or 0
    progression.attributePoints = GetAttributeUnspentPoints() or 0
    progression.achievementPoints = GetEarnedAchievementPoints() or 0
    progression.totalAchievements = GetTotalAchievementPoints() or 0
    progression.achievementPercent = progression.totalAchievements > 0 and 
        math.floor((progression.achievementPoints / progression.totalAchievements) * 100) or 0
    
    -- Vampire/Werewolf status detection via buff scanning
    progression.isVampire = false
    progression.isWerewolf = false
    progression.vampireStage = 0
    progression.werewolfStage = 0
    
    local numBuffs = GetNumBuffs("player") or 0
    for i = 1, numBuffs do
        local buffName = GetUnitBuffInfo("player", i)
        if buffName then
            -- Vampire detection
            local vampStage = buffName:match("Stage (%d) Vampirism") or 
                              buffName:match("Vampirism Stage (%d)") or
                              buffName:match("Stage (%d) Vampire")
            if vampStage then
                progression.isVampire = true
                progression.vampireStage = tonumber(vampStage) or 1
            end
            
            if buffName:find("Vampir") and not progression.isVampire then
                progression.isVampire = true
                progression.vampireStage = 1
            end
            
            -- Werewolf detection
            if buffName:find("Lycanthropy") or buffName:find("Werewolf") then
                progression.isWerewolf = true
                progression.werewolfStage = 1
            end
        end
    end
    
    -- Enlightenment
    local enlightenedPool = 0
    local enlightenedCap = 0
    
    local success1, pool = pcall(GetEnlightenedPool)
    if success1 and pool then
        enlightenedPool = pool
    end
    
    local success2, cap = pcall(GetEnlightenedPoolCap)
    if success2 and cap then
        enlightenedCap = cap
    end
    
    progression.enlightenment = {
        current = enlightenedPool,
        max = enlightenedCap,
        percent = (enlightenedCap > 0) and 
            math.floor((enlightenedPool / enlightenedCap) * 100) or 0
    }
    
    return progression
end

CM.collectors.CollectProgressionData = CollectProgressionData
