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
                    
                    -- Get total spent points in this discipline using GetNumSpentChampionPoints
                    -- This is more reliable than summing individual skills
                    -- Try multiple methods to ensure we get the data
                    local disciplineTotalSpent = 0
                    
                    -- Method 1: Try discipline type constants (if they exist in ESO API)
                    -- Use pcall to safely check if constants exist
                    local disciplineTypeConstant = nil
                    if disciplineId == 1 then
                        -- Try constant first, fallback to 1
                        local constSuccess, constValue = pcall(function() return CHAMPION_DISCIPLINE_TYPE_WORLD end)
                        disciplineTypeConstant = (constSuccess and constValue) and constValue or 1
                    elseif disciplineId == 2 then
                        local constSuccess, constValue = pcall(function() return CHAMPION_DISCIPLINE_TYPE_COMBAT end)
                        disciplineTypeConstant = (constSuccess and constValue) and constValue or 2
                    elseif disciplineId == 3 then
                        local constSuccess, constValue = pcall(function() return CHAMPION_DISCIPLINE_TYPE_CONDITIONING end)
                        disciplineTypeConstant = (constSuccess and constValue) and constValue or 3
                    end
                    
                    -- Try using discipline type constant/numeric value
                    if disciplineTypeConstant then
                        -- Method 1: GetNumSpentChampionPoints
                        local success2, disciplineSpent = pcall(GetNumSpentChampionPoints, disciplineTypeConstant)
                        if success2 and disciplineSpent then
                            disciplineTotalSpent = disciplineSpent or 0
                        end
                        
                        -- Method 2: GetChampionPointsInDiscipline (alternative API)
                        if disciplineTotalSpent == 0 then
                            local success2b, disciplineSpent2b = pcall(GetChampionPointsInDiscipline, disciplineTypeConstant)
                            if success2b and disciplineSpent2b then
                                disciplineTotalSpent = disciplineSpent2b or 0
                            end
                        end
                    end
                    
                    -- Method 3: Try using disciplineId directly as fallback
                    if disciplineTotalSpent == 0 then
                        local success3, disciplineSpent2 = pcall(GetNumSpentChampionPoints, disciplineId)
                        if success3 and disciplineSpent2 then
                            disciplineTotalSpent = disciplineSpent2 or 0
                        end
                        
                        -- Also try GetChampionPointsInDiscipline with disciplineId
                        if disciplineTotalSpent == 0 then
                            local success3b, disciplineSpent3b = pcall(GetChampionPointsInDiscipline, disciplineId)
                            if success3b and disciplineSpent3b then
                                disciplineTotalSpent = disciplineSpent3b or 0
                            end
                        end
                    end
                    
                    CM.DebugPrint("CP", string_format("Discipline %s (ID %d, constant %s): %d points spent", 
                        displayName, disciplineId, tostring(disciplineTypeConstant), disciplineTotalSpent))
                    
                    local disciplineData = { 
                        name = displayName, 
                        emoji = emoji,
                        skills = {}, 
                        total = disciplineTotalSpent,  -- Use discipline-level API call
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
                                    
                                    -- Note: disciplineData.total is already set from GetNumSpentChampionPoints above
                                    -- Don't modify it here, as individual skill points may not be reliable
                                end
                            end
                        end
                    end
                    
                    -- Add discipline total to overall total spent (use discipline-level API value)
                    totalSpent = totalSpent + disciplineTotalSpent
                    
                    -- Always add discipline to list, even if total is 0 (so we can show structure)
                    -- This ensures disciplines are available for display even if API calls fail
                    table.insert(disciplines, disciplineData)
                end
            end
        end
        
        -- Ensure we always have all 3 disciplines (Craft, Warfare, Fitness) even if API didn't return them
        -- This ensures the Overview section can always show the breakdown format
        local disciplineMap = {}
        for _, disc in ipairs(disciplines) do
            local id = nil
            if disc.name == "Craft" then id = 1
            elseif disc.name == "Warfare" then id = 2
            elseif disc.name == "Fitness" then id = 3
            end
            if id then disciplineMap[id] = disc end
        end
        
        -- Add missing disciplines with 0 points
        for _, discId in ipairs({1, 2, 3}) do
            if not disciplineMap[discId] then
                local emoji = "⚔️"
                local displayName = "Unknown"
                if discId == 1 then
                    emoji = "⚒️"
                    displayName = "Craft"
                elseif discId == 2 then
                    emoji = "⚔️"
                    displayName = "Warfare"
                elseif discId == 3 then
                    emoji = "💪"
                    displayName = "Fitness"
                end
                
                table.insert(disciplines, {
                    name = displayName,
                    emoji = emoji,
                    skills = {},
                    total = 0,
                    slottable = 0,
                    passive = 0,
                    slottableSkills = {},
                    passiveSkills = {}
                })
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
        
        -- Validate available CP: if spent > 0 and available equals total, recalculate
        -- This handles cases where GetUnitChampionPoints might return incorrect values
        if data.available ~= nil and data.spent > 0 and data.available == data.total then
            -- Available CP seems wrong (all available when points are spent), recalculate
            data.available = data.total - data.spent
            CM.DebugPrint("CP", "Recalculated available CP from " .. data.total .. " to " .. data.available .. " (spent: " .. data.spent .. ")")
        elseif data.available == nil then
            -- API call failed, calculate from spent
            data.available = data.total - data.spent
        elseif data.spent > 0 then
            -- If we have spent points, always recalculate available to ensure consistency
            data.available = data.total - data.spent
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
                    -- Try discipline type constants first, then disciplineId
                    local disciplineTypeConstant = nil
                    if disciplineId == 1 then
                        disciplineTypeConstant = CHAMPION_DISCIPLINE_TYPE_WORLD or 1
                    elseif disciplineId == 2 then
                        disciplineTypeConstant = CHAMPION_DISCIPLINE_TYPE_COMBAT or 2
                    elseif disciplineId == 3 then
                        disciplineTypeConstant = CHAMPION_DISCIPLINE_TYPE_CONDITIONING or 3
                    end
                    
                    local spentInDiscipline = 0
                    
                    -- Try using discipline type constant first
                    if disciplineTypeConstant then
                        local success2, spent = pcall(GetNumSpentChampionPoints, disciplineTypeConstant)
                        if success2 and spent and spent > 0 then
                            spentInDiscipline = spent
                        end
                    end
                    
                    -- Fallback to disciplineId if constant didn't work
                    if spentInDiscipline == 0 then
                        local success3, spent2 = pcall(GetNumSpentChampionPoints, disciplineId)
                        if success3 and spent2 and spent2 > 0 then
                            spentInDiscipline = spent2
                        end
                    end
                    
                    if spentInDiscipline > 0 then
                        fallbackSpent = fallbackSpent + spentInDiscipline
                        
                        -- Create discipline entry even without individual skill details
                        local disciplineName = GetChampionDisciplineName(disciplineId) or "Unknown"
                        local emoji = "⚔️"
                        local displayName = disciplineName
                        
                        if disciplineId == 1 then
                            emoji = "⚒️"
                            displayName = "Craft"
                        elseif disciplineId == 2 then
                            emoji = "⚔️"
                            displayName = "Warfare"
                        elseif disciplineId == 3 then
                            emoji = "💪"
                            displayName = "Fitness"
                        end
                        
                        table.insert(fallbackDisciplines, {
                            name = displayName,
                            emoji = emoji,
                            total = spentInDiscipline,
                            skills = {},
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
