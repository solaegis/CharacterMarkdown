-- CharacterMarkdown - Progression Data Collector
-- Champion Points, achievements, enlightenment

local CM = CharacterMarkdown

-- =====================================================
-- CHAMPION POINTS
-- =====================================================

local function CollectChampionPointData()
    local data = { 
        total = 0, 
        spent = 0, 
        available = 0,
        disciplines = {},
        analysis = {
            slottableSkills = 0,
            passiveSkills = 0,
            maxSlottablePerDiscipline = 0,
            investmentLevel = "low"
        }
    }
    
    data.total = GetPlayerChampionPointsEarned() or 0
    -- Get available (unspent) CP
    -- Use pcall to track whether API call succeeded (to distinguish between "returned 0" vs "failed")
    -- Note: In Lua, 0 is falsy, so we check apiCallSuccess explicitly, not the value
    local apiCallSuccess, apiAvailable = pcall(GetUnitChampionPoints, "player")
    if apiCallSuccess and apiAvailable ~= nil then
        data.available = apiAvailable  -- API call succeeded and returned a value (0 is valid)
    else
        data.available = nil  -- API call failed or returned nil, we'll calculate from total - spent later
    end
    
    if data.total < 10 then
        return data
    end
    
    -- Determine slottable limits based on total CP
    if data.total >= 1200 then
        data.analysis.maxSlottablePerDiscipline = 4
    elseif data.total >= 900 then
        data.analysis.maxSlottablePerDiscipline = 4
    else
        data.analysis.maxSlottablePerDiscipline = 3
    end
    
    local success, allocations = pcall(function()
        local disciplines = {}
        local totalSpent = 0
        local slottableCount = 0
        local passiveCount = 0
        local numDisciplines = GetNumChampionDisciplines()
        
        if numDisciplines and numDisciplines > 0 then
            for disciplineIndex = 1, numDisciplines do
                local disciplineId = GetChampionDisciplineId(disciplineIndex)
                if disciplineId then
                    local disciplineName = GetChampionDisciplineName(disciplineId) or "Unknown"
                    
                    -- Map discipline by ID (ESO API: 1=Craft, 2=Warfare, 3=Fitness)
                    local emoji = "⚔️"  -- Default fallback
                    local displayName = disciplineName
                    
                    if disciplineId == 1 then
                        emoji = "⚒️"  -- Craft (Green/Thief)
                        displayName = "Craft"
                    elseif disciplineId == 2 then
                        emoji = "⚔️"  -- Warfare (Blue/Mage)
                        displayName = "Warfare"
                    elseif disciplineId == 3 then
                        emoji = "💪"  -- Fitness (Red/Warrior)
                        displayName = "Fitness"
                    end
                    
                    local disciplineData = { 
                        name = displayName, 
                        emoji = emoji,
                        skills = {}, 
                        total = 0,
                        slottable = 0,
                        passive = 0,
                        slottableSkills = {},
                        passiveSkills = {}
                    }
                    
                    local numSkills = GetNumChampionDisciplineSkills(disciplineId)
                    if numSkills then
                        for skillIndex = 1, numSkills do
                            local skillId = GetChampionSkillId(disciplineId, skillIndex)
                            if skillId then
                                local pointsSpent = GetNumPointsSpentOnChampionSkill(skillId)
                                if pointsSpent and pointsSpent > 0 then
                                    local skillName = GetChampionSkillName(skillId) or "Unknown"
                                    
                                    -- Determine if skill is slottable or passive using hardcoded mapping
                                    local isSlottable = false
                                    local skillType = "passive"
                                    
                                    -- Hardcoded mapping of slottable champion skills (based on ESO CP 3.0 system)
                                    local slottableSkills = {
                                        -- Craft constellation slottable skills
                                        ["Steed's Blessing"] = true,
                                        ["Breakfall"] = true,
                                        ["Infamous"] = true,
                                        ["Cutpurse's Art"] = true,
                                        ["Meticulous Disassembly"] = true,
                                        ["Plentiful Harvest"] = true,
                                        ["Treasure Hunter"] = true,
                                        ["Gilded Fingers"] = true,
                                        ["Liquid Efficiency"] = true,
                                        ["Homemaker"] = true,
                                        ["Professional Upkeep"] = true,
                                        ["Gifted Rider"] = true,
                                        ["War Mount"] = true,
                                        
                                        -- Warfare constellation slottable skills
                                        ["Deadly Aim"] = true,
                                        ["Master-at-Arms"] = true,
                                        ["Thaumaturge"] = true,
                                        ["Rejuvenating Boon"] = true,
                                        ["Ironclad"] = true,
                                        ["Biting Aura"] = true,
                                        ["Enlivening Overflow"] = true,
                                        ["Salvation"] = true,
                                        ["Bastion"] = true,
                                        ["Wrathful Strikes"] = true,
                                        ["Exploiter"] = true,
                                        ["Deadly Precision"] = true,
                                        
                                        -- Fitness constellation slottable skills
                                        ["Strategic Reserve"] = true,
                                        ["Sustained by Suffering"] = true,
                                        ["Rolling Rhapsody"] = true,
                                        ["Defiance"] = true,
                                        ["Hasty"] = true,
                                        ["Pain's Refuge"] = true,
                                        ["Bloody Renewal"] = true,
                                        ["Piercing Gaze"] = true,
                                        ["Bracing Anchor"] = true,
                                        ["Unassailable"] = true,
                                    }
                                    
                                    if slottableSkills[skillName] then
                                        isSlottable = true
                                        skillType = "slottable"
                                        slottableCount = slottableCount + 1
                                        disciplineData.slottable = disciplineData.slottable + pointsSpent
                                        table.insert(disciplineData.slottableSkills, {
                                            name = skillName,
                                            points = pointsSpent,
                                            skillId = skillId
                                        })
                                    else
                                        passiveCount = passiveCount + 1
                                        disciplineData.passive = disciplineData.passive + pointsSpent
                                        table.insert(disciplineData.passiveSkills, {
                                            name = skillName,
                                            points = pointsSpent,
                                            skillId = skillId
                                        })
                                    end
                                    
                                    -- Add to general skills list for backward compatibility
                                    table.insert(disciplineData.skills, { 
                                        name = skillName, 
                                        points = pointsSpent,
                                        type = skillType,
                                        isSlottable = isSlottable,
                                        skillId = skillId
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
        
        -- Calculate investment level
        local investmentLevel = "low"
        if data.total >= 1500 then
            investmentLevel = "very-high"
        elseif data.total >= 1200 then
            investmentLevel = "high"
        elseif data.total >= 800 then
            investmentLevel = "medium-high"
        elseif data.total >= 400 then
            investmentLevel = "medium"
        end
        
        return {
            disciplines = disciplines, 
            totalSpent = totalSpent,
            slottableCount = slottableCount,
            passiveCount = passiveCount,
            investmentLevel = investmentLevel
        }
    end)
    
    if success and allocations then
        data.spent = allocations.totalSpent
        -- Only recalculate if API call failed (data.available is nil)
        -- If API returned 0, trust it (don't overwrite)
        if data.available == nil then
            data.available = data.total - data.spent
        end
        data.disciplines = allocations.disciplines
        data.analysis.slottableSkills = allocations.slottableCount
        data.analysis.passiveSkills = allocations.passiveCount
        data.analysis.investmentLevel = allocations.investmentLevel
    elseif data.available == nil then
        -- Allocations failed, but we still need a value for available
        -- Calculate as fallback (spent will be 0 since allocations failed)
        data.available = data.total - data.spent
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
    progression.totalSkillPoints = CM.SafeCall(GetTotalSkillPoints) or 0  -- Total skill points earned
    progression.attributePoints = GetAttributeUnspentPoints() or 0
    progression.achievementPoints = GetEarnedAchievementPoints() or 0
    progression.totalAchievements = GetTotalAchievementPoints() or 0
    progression.achievementPercent = progression.totalAchievements > 0 and 
        math.floor((progression.achievementPoints / progression.totalAchievements) * 100) or 0
    
    -- Available Champion Points (unspent)
    progression.availableChampionPoints = CM.SafeCall(GetUnitChampionPoints, "player") or 0
    
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
