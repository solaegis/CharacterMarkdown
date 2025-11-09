-- CharacterMarkdown - Progression Data Collector
-- Champion Points, achievements, enlightenment

local CM = CharacterMarkdown
local string_format = string.format

-- =====================================================
-- CHAMPION POINTS CONSTANTS
-- =====================================================

local CP_CONSTANTS = {
    MIN_CP_FOR_SYSTEM = 10,
    CP_THRESHOLD_HIGH = 1200,
    CP_THRESHOLD_MEDIUM = 900,
    MAX_CP_PER_DISCIPLINE = 660,
}

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Get discipline info (emoji and display name) by ID
local function GetDisciplineInfo(disciplineId)
    local DisciplineType = CM.constants.DisciplineType
    local emoji, displayName
    
    if disciplineId == 1 then
        emoji = "⚒️"
        displayName = DisciplineType.CRAFT
    elseif disciplineId == 2 then
        emoji = "⚔️"
        displayName = DisciplineType.WARFARE
    elseif disciplineId == 3 then
        emoji = "💪"
        displayName = DisciplineType.FITNESS
    else
        emoji = "⚔️"
        displayName = "Unknown"
    end
    
    return emoji, displayName
end

-- Get discipline type constant safely
local function GetDisciplineTypeConstant(disciplineId)
    local constSuccess, constValue = false, nil
    
    if disciplineId == 1 then
        constSuccess, constValue = pcall(function() return CHAMPION_DISCIPLINE_TYPE_WORLD end)
        return (constSuccess and constValue) and constValue or 1
    elseif disciplineId == 2 then
        constSuccess, constValue = pcall(function() return CHAMPION_DISCIPLINE_TYPE_COMBAT end)
        return (constSuccess and constValue) and constValue or 2
    elseif disciplineId == 3 then
        constSuccess, constValue = pcall(function() return CHAMPION_DISCIPLINE_TYPE_CONDITIONING end)
        return (constSuccess and constValue) and constValue or 3
    end
    
    return disciplineId  -- Fallback to ID itself
end

-- Get spent points in discipline (tries multiple methods, returns first success)
local function GetDisciplineSpentPoints(disciplineId, disciplineTypeConstant)
    local methods = {
        function() return GetNumSpentChampionPoints(disciplineTypeConstant) end,
        function() return GetChampionPointsInDiscipline(disciplineTypeConstant) end,
        function() return GetNumSpentChampionPoints(disciplineId) end,
        function() return GetChampionPointsInDiscipline(disciplineId) end,
    }
    
    for _, method in ipairs(methods) do
        local success, value = pcall(method)
        if success and value and value > 0 then
            return value
        end
    end
    
    return 0
end

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
    
    data.total = CM.SafeCall(GetPlayerChampionPointsEarned) or 0
    -- Get available (unspent) CP
    -- Use pcall to track whether API call succeeded (to distinguish between "returned 0" vs "failed")
    -- Note: In Lua, 0 is falsy, so we check apiCallSuccess explicitly, not the value
    local apiCallSuccess, apiAvailable = pcall(GetUnitChampionPoints, "player")
    if apiCallSuccess and apiAvailable ~= nil then
        data.available = apiAvailable  -- API call succeeded and returned a value (0 is valid)
    else
        data.available = nil  -- API call failed or returned nil, we'll calculate from total - spent later
    end
    
    if data.total < CP_CONSTANTS.MIN_CP_FOR_SYSTEM then
        return data
    end
    
    -- Determine slottable limits based on total CP
    -- CP 3.0: 4 slottable per discipline at 900+ CP, 3 below that
    if data.total >= CP_CONSTANTS.CP_THRESHOLD_MEDIUM then
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
        
        -- Always ensure we have 3 disciplines (Craft, Warfare, Fitness)
        -- Even if API calls fail, we want the structure for display
        local disciplineIds = {1, 2, 3}  -- Craft, Warfare, Fitness
        local processedDisciplines = {}
        
        -- First, try to get disciplines from API
        if numDisciplines and numDisciplines > 0 then
            for disciplineIndex = 1, numDisciplines do
                local disciplineId = GetChampionDisciplineId(disciplineIndex)
                if disciplineId then
                    processedDisciplines[disciplineId] = true
                    local disciplineName = GetChampionDisciplineName(disciplineId) or "Unknown"
                    
                    -- Map discipline by ID (ESO API: 1=Craft, 2=Warfare, 3=Fitness)
                    local emoji, displayName = GetDisciplineInfo(disciplineId)
                    
                    -- Get discipline type constant safely
                    local disciplineTypeConstant = GetDisciplineTypeConstant(disciplineId)
                    
                    -- Get total spent points in this discipline (tries multiple methods, returns first success)
                    local disciplineTotalSpent = GetDisciplineSpentPoints(disciplineId, disciplineTypeConstant)
                    
                    CM.DebugPrint("CP", string_format("Discipline %s (ID %d, constant %s): %d points spent", 
                        displayName, disciplineId, tostring(disciplineTypeConstant), disciplineTotalSpent))
                    
                    -- Get maximum allocated CP for this discipline
                    -- In ESO CP 3.0, each discipline has its own independent maximum
                    -- Try multiple API methods to get the allocated maximum
                    local disciplineMaxAllocated = 0
                    if disciplineTypeConstant then
                        -- Method 1: Try GetChampionPointsInDiscipline
                        -- IMPORTANT: In CP 3.0, this API returns the MAXIMUM CP that CAN be allocated to this discipline
                        -- This is based on total CP earned, NOT the current allocated amount (spent + unassigned)
                        -- The maximum per discipline = total CP / 3 (approximately, with rounding)
                        -- To get current allocated (spent + unassigned), we need to use a different approach
                        local successMax, maxValue = pcall(GetChampionPointsInDiscipline, disciplineTypeConstant)
                        if successMax and maxValue then
                            -- Check if this value represents the maximum possible (based on total CP)
                            -- or the current allocated amount (spent + unassigned)
                            -- If it's greater than spent, it might be current allocated
                            -- If it equals spent, it might be maximum possible or current allocated with 0 unassigned
                            if maxValue > disciplineTotalSpent then
                                -- Likely current allocated (spent + unassigned)
                                disciplineMaxAllocated = maxValue
                                CM.DebugPrint("CP", string_format("Discipline %s: API returned current allocated %d (spent %d, unassigned %d)", 
                                    displayName, maxValue, disciplineTotalSpent, maxValue - disciplineTotalSpent))
                            elseif maxValue == disciplineTotalSpent then
                                -- Could be maximum possible (if user has allocated all available to this discipline)
                                -- Or could be API limitation (returning spent instead of allocated)
                                -- Check if this matches the theoretical maximum (total CP / 3)
                                local theoreticalMax = math.floor((data.total or 0) / 3)
                                if maxValue == theoreticalMax or maxValue == theoreticalMax + 1 then
                                    -- This is likely the maximum possible, not current allocated
                                    -- Calculate current allocated as spent + (portion of available)
                                    -- But we don't know the distribution yet, so leave as 0 for generator to calculate
                                    CM.DebugPrint("CP", string_format("Discipline %s: API returned %d (matches theoretical max %d), will calculate allocated from totalAvailable", 
                                        displayName, maxValue, theoreticalMax))
                                else
                                    -- Might be current allocated with 0 unassigned, or API limitation
                                    -- Leave as 0 and let generator calculate
                                    CM.DebugPrint("CP", string_format("Discipline %s: API returned %d (same as spent, not theoretical max), will calculate from totalAvailable", 
                                        displayName, maxValue))
                                end
                            else
                                -- API returned less than spent - invalid, don't use
                                CM.DebugPrint("CP", string_format("Discipline %s: API returned %d (less than spent %d), invalid, will calculate from totalAvailable", 
                                    displayName, maxValue, disciplineTotalSpent))
                            end
                        end
                        
                        -- Method 2: Try GetNumChampionPointsAllocatedToDiscipline if it exists
                        if disciplineMaxAllocated == 0 then
                            local successMax2, maxValue2 = pcall(function() 
                                if GetNumChampionPointsAllocatedToDiscipline then
                                    return GetNumChampionPointsAllocatedToDiscipline(disciplineTypeConstant)
                                end
                                return nil
                            end)
                            if successMax2 and maxValue2 and maxValue2 >= disciplineTotalSpent then
                                disciplineMaxAllocated = maxValue2
                                CM.DebugPrint("CP", string_format("Discipline %s: Method 2 returned max allocated %d", displayName, maxValue2))
                            end
                        end
                        
                        -- Method 3: If API returned same as spent, it might mean API limitation
                        -- In CP 3.0, GetChampionPointsInDiscipline might return the maximum that CAN be allocated
                        -- (based on total CP), not the current allocated amount
                        -- We need to calculate maxAllocated as spent + unassigned, where unassigned comes from totalAvailable
                        -- But we don't know the distribution yet, so leave as 0 and let generator calculate
                        if disciplineMaxAllocated == 0 then
                            CM.DebugPrint("CP", string_format("Discipline %s: No API max found, will calculate from totalAvailable in generator", displayName))
                        end
                    end
                    
                    CM.DebugPrint("CP", string_format("Discipline %s: maxAllocated=%d, spent=%d", 
                        displayName, disciplineMaxAllocated, disciplineTotalSpent))
                    
                    local disciplineData = { 
                        name = displayName, 
                        emoji = emoji,
                        skills = {}, 
                        allStars = {},  -- All stars including 0 points (for constellation table view)
                        total = 0,  -- Will be calculated from skill points (spent points)
                        maxAllocated = disciplineMaxAllocated,  -- Maximum CP allocated to this discipline
                        slottable = 0,
                        passive = 0,
                        slottableSkills = {},
                        passiveSkills = {}
                    }
                    
                    -- Still iterate through skills for detailed breakdown (slottable vs passive)
                    local numSkills = GetNumChampionDisciplineSkills(disciplineId)
                    if numSkills then
                        for skillIndex = 1, numSkills do
                            local skillId = GetChampionSkillId(disciplineId, skillIndex)
                            if skillId then
                                local pointsSpent = GetNumPointsSpentOnChampionSkill(skillId) or 0
                                local skillName = GetChampionSkillName(skillId) or "Unknown"
                                
                                -- Always add to allStars array (including 0 points) for constellation table view
                                table.insert(disciplineData.allStars, {
                                    name = skillName,
                                    points = pointsSpent,
                                    skillId = skillId,
                                    skillIndex = skillIndex
                                })
                                
                                -- Only process skills with points > 0 for the main breakdown
                                if pointsSpent > 0 then
                                    -- Determine if skill is slottable or passive using hardcoded mapping
                                    local isSlottable = false
                                    local skillType = "passive"
                                    
                                    -- Hardcoded mapping of slottable champion skills (ESO CP 2.0/Update 45)
                                    local slottableSkills = {
                                        -- Craft constellation slottable skills (Update 45: many converted to passives)
                                        ["Steed's Blessing"] = true,
                                        ["Shadowstrike"] = true,
                                        ["Gifted Rider"] = true,
                                        ["Reel Technique"] = true,
                                        ["Master Gatherer"] = true,
                                        
                                        -- Warfare constellation slottable skills - Main Constellation
                                        ["Deadly Aim"] = true,
                                        ["Master-at-Arms"] = true,
                                        ["Wrathful Strikes"] = true,
                                        ["Thaumaturge"] = true,
                                        ["Backstabber"] = true,
                                        ["Fighting Finesse"] = true,
                                        
                                        -- Warfare - Mastered Curation (Healing Sub-constellation)
                                        ["Blessed"] = true,
                                        ["Eldritch Insight"] = true,
                                        ["Cleansing Revival"] = true,
                                        ["Foresight"] = true,
                                        
                                        -- Warfare - Extended Might (Damage Sub-constellation)
                                        ["Arcane Supremacy"] = true,
                                        ["Ironclad"] = true,
                                        ["Preparation"] = true,
                                        ["Exploiter"] = true,
                                        
                                        -- Warfare - Staving Death (Defense Sub-constellation)
                                        ["Fortified"] = true,
                                        ["Boundless Vitality"] = true,
                                        ["Survival Instincts"] = true,
                                        ["Rejuvenation"] = true,
                                        
                                        -- Fitness constellation slottable skills - Main Constellation
                                        ["Tumbling"] = true,
                                        ["Defiance"] = true,
                                        ["Siphoning Spells"] = true,
                                        ["Fortification"] = true,
                                        ["Hero's Vigor"] = true,
                                        ["Strategic Reserve"] = true,
                                        
                                        -- Fitness - Survivor's Spite (Recovery Sub-constellation)
                                        ["Bloody Renewal"] = true,
                                        ["Tireless Discipline"] = true,
                                        ["Relentlessness"] = true,
                                        ["Mystic Tenacity"] = true,
                                        ["Hasty"] = true,
                                        
                                        -- Fitness - Wind Chaser (Movement Sub-constellation)
                                        ["Celerity"] = true,
                                        ["Piercing Gaze"] = true,
                                        
                                        -- Fitness - Walking Fortress (Block Sub-constellation)
                                        ["Bracing Anchor"] = true,
                                        ["Shield Expert"] = true,
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
                                end
                            end
                        end
                    end
                    
                    -- Calculate discipline total from sum of skill points (more reliable than API call)
                    -- This gives us the actual assigned points per discipline
                    local calculatedDisciplineTotal = disciplineData.slottable + disciplineData.passive
                    if calculatedDisciplineTotal > 0 then
                        -- Use calculated total if we found any skills with points
                        disciplineData.total = calculatedDisciplineTotal
                        CM.DebugPrint("CP", string_format("Discipline %s: Using calculated total %d (API returned %d)", 
                            displayName, calculatedDisciplineTotal, disciplineTotalSpent))
                    else
                        -- No skills found with points, use API value (or 0 if API also failed)
                        disciplineData.total = disciplineTotalSpent or 0
                    end
                    
                    -- Add discipline total to overall total spent (use calculated value)
                    totalSpent = totalSpent + disciplineData.total
                    
                    -- Always add discipline to list, even if total is 0 (so we can show structure)
                    -- This ensures disciplines are available for display even if API calls fail
                    table.insert(disciplines, disciplineData)
                end
            end
        end
        
        -- Ensure we always have all 3 disciplines (Craft, Warfare, Fitness) even if API didn't return them
        -- This ensures the Overview section can always show the breakdown format
        local DisciplineType = CM.constants.DisciplineType
        local disciplineMap = {}
        for _, disc in ipairs(disciplines) do
            local id = nil
            if disc.name == DisciplineType.CRAFT then id = 1
            elseif disc.name == DisciplineType.WARFARE then id = 2
            elseif disc.name == DisciplineType.FITNESS then id = 3
            end
            if id then disciplineMap[id] = disc end
        end
        
        -- Add missing disciplines with 0 points and collect their stars
        for _, discId in ipairs({1, 2, 3}) do
            if not disciplineMap[discId] then
                local emoji, displayName = GetDisciplineInfo(discId)
                
                -- Try to get max allocated for missing discipline
                local missingDisciplineMax = 0
                local disciplineTypeConstant = GetDisciplineTypeConstant(discId)
                
                local successMax, maxValue = pcall(GetChampionPointsInDiscipline, disciplineTypeConstant)
                if successMax and maxValue and maxValue > 0 then
                    missingDisciplineMax = maxValue
                end
                
                local missingDiscipline = {
                    name = displayName,
                    emoji = emoji,
                    skills = {},
                    allStars = {},  -- All stars including 0 points (for constellation table view)
                    total = 0,
                    maxAllocated = missingDisciplineMax,
                    slottable = 0,
                    passive = 0,
                    slottableSkills = {},
                    passiveSkills = {}
                }
                
                -- Collect all stars for missing discipline (even if API didn't return it)
                local numSkills = GetNumChampionDisciplineSkills(discId)
                if numSkills then
                    for skillIndex = 1, numSkills do
                        local skillId = GetChampionSkillId(discId, skillIndex)
                        if skillId then
                            local pointsSpent = GetNumPointsSpentOnChampionSkill(skillId) or 0
                            local skillName = GetChampionSkillName(skillId) or "Unknown"
                            
                            table.insert(missingDiscipline.allStars, {
                                name = skillName,
                                points = pointsSpent,
                                skillId = skillId,
                                skillIndex = skillIndex
                            })
                        end
                    end
                end
                
                table.insert(disciplines, missingDiscipline)
            end
        end
        
        -- Calculate investment level
        local investmentLevel = "low"
        if data.total >= 1500 then
            investmentLevel = "very-high"
        elseif data.total >= CP_CONSTANTS.CP_THRESHOLD_HIGH then
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
        -- Calculate totalSpent from discipline totals if individual skills failed
        -- This is more reliable than summing individual skills which may return 0
        local calculatedSpent = 0
        if allocations.disciplines and #allocations.disciplines > 0 then
            for _, discipline in ipairs(allocations.disciplines) do
                if discipline.total and discipline.total > 0 then
                    calculatedSpent = calculatedSpent + discipline.total
                end
            end
        end
        
        -- Use calculated spent from disciplines if it's greater than allocations.totalSpent
        -- This handles cases where individual skill queries return 0 but discipline totals are correct
        if calculatedSpent > 0 then
            data.spent = calculatedSpent
        else
            data.spent = allocations.totalSpent
        end
        
        -- Calculate available CP with priority: API value > calculated from spent > calculated from available
        -- Validate consistency: available + spent should equal total (within 1 point tolerance)
        if data.available == nil or (data.spent > 0 and data.available == data.total) then
            -- API failed or returned invalid value (all available when points are spent), calculate from spent
            data.available = data.total - data.spent
            CM.DebugPrint("CP", string_format("Calculated available CP: %d (from total %d - spent %d)", 
                data.available, data.total, data.spent))
        elseif data.spent > 0 then
            -- Validate: available + spent should equal total (within 1 point tolerance for rounding)
            local calculatedTotal = data.available + data.spent
            if math.abs(calculatedTotal - data.total) > 1 then
                -- Mismatch detected, recalculate from spent (more reliable)
                CM.Warn(string_format("CP mismatch detected: available=%d, spent=%d, total=%d (diff=%d) - recalculating", 
                    data.available, data.spent, data.total, math.abs(calculatedTotal - data.total)))
                data.available = data.total - data.spent
            end
        end
        
        data.disciplines = allocations.disciplines
        data.analysis.slottableSkills = allocations.slottableCount
        data.analysis.passiveSkills = allocations.passiveCount
        data.analysis.investmentLevel = allocations.investmentLevel
    else
        -- Allocations failed - try alternative methods to get spent CP and disciplines
        local fallbackDisciplines = {}
        local fallbackSpent = 0
        
        -- Try to get spent points per discipline as fallback
        local numDisciplines = GetNumChampionDisciplines()
        if numDisciplines and numDisciplines > 0 then
            for disciplineIndex = 1, numDisciplines do
                local disciplineId = GetChampionDisciplineId(disciplineIndex)
                if disciplineId then
                    -- Get discipline info and spent points
                    local disciplineTypeConstant = GetDisciplineTypeConstant(disciplineId)
                    local spentInDiscipline = GetDisciplineSpentPoints(disciplineId, disciplineTypeConstant)
                    
                    if spentInDiscipline > 0 then
                        fallbackSpent = fallbackSpent + spentInDiscipline
                        
                        -- Create discipline entry even without individual skill details
                        local emoji, displayName = GetDisciplineInfo(disciplineId)
                        
                        table.insert(fallbackDisciplines, {
                            name = displayName,
                            emoji = emoji,
                            total = spentInDiscipline,
                            skills = {},
                            allStars = {},  -- All stars including 0 points (for constellation table view)
                            slottable = 0,
                            passive = 0,
                            slottableSkills = {},
                            passiveSkills = {}
                        })
                    end
                end
            end
        end
        
        if fallbackSpent > 0 then
            data.spent = fallbackSpent
            data.disciplines = fallbackDisciplines
            if data.available == nil then
                data.available = data.total - data.spent
            end
        elseif data.available ~= nil then
            -- Calculate spent from total - available (most reliable when available CP is known)
            data.spent = data.total - data.available
        else
            -- Both methods failed - calculate available from spent (which will be 0)
            data.available = data.total - data.spent
        end
    end
    
    return data
end

CM.collectors.CollectChampionPointData = CollectChampionPointData

-- =====================================================
-- PROGRESSION DATA
-- =====================================================

local function CollectProgressionData()
    local progression = {}
    
    progression.skillPoints = CM.SafeCall(GetAvailableSkillPoints) or 0
    progression.unspentSkillPoints = progression.skillPoints  -- Alias for consistency with generator
    progression.totalSkillPoints = CM.SafeCall(GetTotalSkillPoints) or 0  -- Total skill points earned
    progression.attributePoints = CM.SafeCall(GetAttributeUnspentPoints) or 0
    progression.unspentAttributePoints = progression.attributePoints  -- Alias for consistency with generator
    progression.achievementPoints = CM.SafeCall(GetEarnedAchievementPoints) or 0
    progression.totalAchievements = CM.SafeCall(GetTotalAchievementPoints) or 0
    progression.achievementPercent = progression.totalAchievements > 0 and 
        math.floor((progression.achievementPoints / progression.totalAchievements) * 100) or 0
    
    -- Available Champion Points (unspent)
    progression.availableChampionPoints = CM.SafeCall(GetUnitChampionPoints, "player") or 0
    
    -- Vampire/Werewolf status detection via buff scanning
    progression.isVampire = false
    progression.isWerewolf = false
    progression.vampireStage = 0
    progression.werewolfStage = 0
    
    local numBuffs = CM.SafeCall(GetNumBuffs, "player") or 0
    for i = 1, numBuffs do
        local buffName = CM.SafeCall(GetUnitBuffInfo, "player", i)
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


