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
-- ESO API discipline IDs:
-- 1 = CHAMPION_DISCIPLINE_TYPE_COMBAT (Warfare)
-- 2 = CHAMPION_DISCIPLINE_TYPE_CONDITIONING (Fitness)
-- 3 = CHAMPION_DISCIPLINE_TYPE_WORLD (Craft)
local function GetDisciplineInfo(disciplineId)
    local DisciplineType = CM.constants.DisciplineType
    local emoji, displayName

    if disciplineId == 1 then
        emoji = "⚔️"
        displayName = DisciplineType.WARFARE
    elseif disciplineId == 2 then
        emoji = "💪"
        displayName = DisciplineType.FITNESS
    elseif disciplineId == 3 then
        emoji = "⚒️"
        displayName = DisciplineType.CRAFT
    else
        emoji = "⚔️"
        displayName = "Unknown"
    end

    return emoji, displayName
end

-- Get discipline type constant safely
-- ESO API discipline type constants:
-- CHAMPION_DISCIPLINE_TYPE_COMBAT = 1 (Warfare)
-- CHAMPION_DISCIPLINE_TYPE_CONDITIONING = 2 (Fitness)
-- CHAMPION_DISCIPLINE_TYPE_WORLD = 3 (Craft)
local function GetDisciplineTypeConstant(disciplineId)
    local constSuccess, constValue = false, nil

    if disciplineId == 1 then
        constSuccess, constValue = pcall(function()
            return CHAMPION_DISCIPLINE_TYPE_COMBAT
        end)
        return (constSuccess and constValue) and constValue or 1
    elseif disciplineId == 2 then
        constSuccess, constValue = pcall(function()
            return CHAMPION_DISCIPLINE_TYPE_CONDITIONING
        end)
        return (constSuccess and constValue) and constValue or 2
    elseif disciplineId == 3 then
        constSuccess, constValue = pcall(function()
            return CHAMPION_DISCIPLINE_TYPE_WORLD
        end)
        return (constSuccess and constValue) and constValue or 3
    end

    return disciplineId -- Fallback to ID itself
end

-- Get spent points in discipline (tries multiple methods, returns first success)
local function GetDisciplineSpentPoints(disciplineId, disciplineTypeConstant)
    local methods = {
        function()
            return GetNumSpentChampionPoints(disciplineTypeConstant)
        end,
        function()
            return GetChampionPointsInDiscipline(disciplineTypeConstant)
        end,
        function()
            return GetNumSpentChampionPoints(disciplineId)
        end,
        function()
            return GetChampionPointsInDiscipline(disciplineId)
        end,
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
            investmentLevel = "low",
        },
    }

    -- Get total CP earned (account-wide)
    data.total = CM.SafeCall(GetPlayerChampionPointsEarned) or 0

    -- Get unassigned CP (shared pool available to any discipline)
    local apiCallSuccess, apiAvailable = pcall(GetUnitChampionPoints, "player")
    if apiCallSuccess and apiAvailable ~= nil then
        data.available = apiAvailable -- Unassigned CP (0 is valid)
    else
        data.available = nil -- API call failed, will calculate from total - spent later
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
        local disciplineIds = { 1, 2, 3 } -- Craft, Warfare, Fitness
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

                    -- Get assigned points in this discipline using the correct API
                    -- GetChampionPointsInDiscipline() returns assigned points (not max possible)
                    local disciplineAssigned = 0
                    if disciplineTypeConstant then
                        local successAssigned, assignedValue =
                            pcall(GetChampionPointsInDiscipline, disciplineTypeConstant)
                        if successAssigned and assignedValue and assignedValue >= 0 then
                            disciplineAssigned = assignedValue
                        end
                    end

                    -- Fallback: Try GetDisciplineSpentPoints if assigned is 0 (for backward compatibility)
                    if disciplineAssigned == 0 then
                        disciplineAssigned = GetDisciplineSpentPoints(disciplineId, disciplineTypeConstant)
                    end

                    CM.DebugPrint(
                        "CP",
                        string_format(
                            "Discipline %s (ID %d): %d points assigned",
                            displayName,
                            disciplineId,
                            disciplineAssigned
                        )
                    )

                    local disciplineData = {
                        name = displayName,
                        emoji = emoji,
                        skills = {},
                        allStars = {}, -- All stars including 0 points (for constellation table view)
                        assigned = disciplineAssigned, -- Points assigned to this discipline (from API)
                        total = 0, -- Will be calculated from skill points (may differ from assigned if API is wrong)
                        slottable = 0,
                        passive = 0,
                        slottableSkills = {},
                        passiveSkills = {},
                    }

                    -- Still iterate through skills for detailed breakdown (slottable vs passive)
                    -- CRITICAL: Use disciplineIndex (1-3) for iteration functions, not disciplineId
                    local numSkills = GetNumChampionDisciplineSkills(disciplineIndex)
                    if numSkills then
                        for skillIndex = 1, numSkills do
                            local skillId = GetChampionSkillId(disciplineIndex, skillIndex)
                            if skillId then
                                local pointsSpent = GetNumPointsSpentOnChampionSkill(skillId) or 0
                                local skillName = GetChampionSkillName(skillId) or "Unknown"

                                -- Get max points for this star (useful for display/validation)
                                local maxPoints = 0
                                local successMax, maxValue = pcall(GetChampionSkillMaxPoints, skillId)
                                if successMax and maxValue then
                                    maxPoints = maxValue
                                end

                                -- Always add to allStars array (including 0 points) for constellation table view
                                table.insert(disciplineData.allStars, {
                                    name = skillName,
                                    points = pointsSpent,
                                    maxPoints = maxPoints, -- Max points for this star
                                    skillId = skillId,
                                    skillIndex = skillIndex,
                                })

                                -- Only process skills with points > 0 for the main breakdown
                                if pointsSpent > 0 then
                                    -- Determine if skill is slottable or passive using API
                                    -- GetChampionSkillType() returns the skill type enum
                                    local apiSkillType = nil
                                    local successType, skillTypeValue = pcall(GetChampionSkillType, skillId)
                                    if successType and skillTypeValue then
                                        apiSkillType = skillTypeValue
                                    end

                                    -- Check if skill is slottable using API
                                    -- CHAMPION_SKILL_TYPE_NORMAL = passive, others = slottable
                                    local isSlottable = false
                                    local skillType = "passive"

                                    if apiSkillType then
                                        -- Try to access enum constants safely
                                        local successNormal, normalType = pcall(function()
                                            return CHAMPION_SKILL_TYPE_NORMAL
                                        end)
                                        if successNormal and normalType then
                                            -- If skill type is not NORMAL, it's slottable
                                            isSlottable = (apiSkillType ~= normalType)
                                        else
                                            -- Fallback: if we can't access enum, assume any non-zero/nil value means slottable
                                            -- This is a conservative approach - better to mark as slottable if unsure
                                            isSlottable = (apiSkillType ~= 0 and apiSkillType ~= nil)
                                        end
                                    else
                                        -- API call failed - use fallback: check if skill name matches known slottable patterns
                                        -- This is a last resort fallback
                                        CM.DebugPrint(
                                            "CP",
                                            string_format(
                                                "GetChampionSkillType failed for %s, using fallback",
                                                skillName
                                            )
                                        )
                                        -- Could add minimal hardcoded fallback here if needed, but prefer API
                                    end

                                    if isSlottable then
                                        skillType = "slottable"
                                        slottableCount = slottableCount + 1
                                        disciplineData.slottable = disciplineData.slottable + pointsSpent
                                        table.insert(disciplineData.slottableSkills, {
                                            name = skillName,
                                            points = pointsSpent,
                                            skillId = skillId,
                                        })
                                    else
                                        passiveCount = passiveCount + 1
                                        disciplineData.passive = disciplineData.passive + pointsSpent
                                        table.insert(disciplineData.passiveSkills, {
                                            name = skillName,
                                            points = pointsSpent,
                                            skillId = skillId,
                                        })
                                    end

                                    -- Add to general skills list for backward compatibility
                                    table.insert(disciplineData.skills, {
                                        name = skillName,
                                        points = pointsSpent,
                                        type = skillType,
                                        isSlottable = isSlottable,
                                        skillId = skillId,
                                    })
                                end
                            end
                        end
                    end

                    -- Calculate discipline total from sum of skill points
                    -- This gives us the actual spent points per discipline
                    local calculatedDisciplineTotal = disciplineData.slottable + disciplineData.passive
                    if calculatedDisciplineTotal > 0 then
                        -- Use calculated total if we found any skills with points
                        disciplineData.total = calculatedDisciplineTotal
                        CM.DebugPrint(
                            "CP",
                            string_format(
                                "Discipline %s: Using calculated total %d (API assigned %d)",
                                displayName,
                                calculatedDisciplineTotal,
                                disciplineAssigned
                            )
                        )
                    else
                        -- No skills found with points, use API assigned value (or 0 if API also failed)
                        disciplineData.total = disciplineAssigned or 0
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
            if disc.name == DisciplineType.CRAFT then
                id = 1
            elseif disc.name == DisciplineType.WARFARE then
                id = 2
            elseif disc.name == DisciplineType.FITNESS then
                id = 3
            end
            if id then
                disciplineMap[id] = disc
            end
        end

        -- Add missing disciplines with 0 points and collect their stars
        for _, discId in ipairs({ 1, 2, 3 }) do
            if not disciplineMap[discId] then
                local emoji, displayName = GetDisciplineInfo(discId)

                -- Get assigned points for missing discipline
                local missingDisciplineAssigned = 0
                local disciplineTypeConstant = GetDisciplineTypeConstant(discId)

                local successAssigned, assignedValue = pcall(GetChampionPointsInDiscipline, disciplineTypeConstant)
                if successAssigned and assignedValue and assignedValue >= 0 then
                    missingDisciplineAssigned = assignedValue
                end

                local missingDiscipline = {
                    name = displayName,
                    emoji = emoji,
                    skills = {},
                    allStars = {}, -- All stars including 0 points (for constellation table view)
                    assigned = missingDisciplineAssigned,
                    total = missingDisciplineAssigned, -- Use assigned as total for missing disciplines
                    slottable = 0,
                    passive = 0,
                    slottableSkills = {},
                    passiveSkills = {},
                }

                -- Collect all stars for missing discipline (even if API didn't return it)
                -- CRITICAL: Use discId as disciplineIndex (1-3) for iteration functions
                local numSkills = GetNumChampionDisciplineSkills(discId)
                if numSkills then
                    for skillIndex = 1, numSkills do
                        local skillId = GetChampionSkillId(discId, skillIndex)
                        if skillId then
                            local pointsSpent = GetNumPointsSpentOnChampionSkill(skillId) or 0
                            local skillName = GetChampionSkillName(skillId) or "Unknown"

                            -- Get max points for this star
                            local maxPoints = 0
                            local successMax, maxValue = pcall(GetChampionSkillMaxPoints, skillId)
                            if successMax and maxValue then
                                maxPoints = maxValue
                            end

                            table.insert(missingDiscipline.allStars, {
                                name = skillName,
                                points = pointsSpent,
                                maxPoints = maxPoints,
                                skillId = skillId,
                                skillIndex = skillIndex,
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
            investmentLevel = investmentLevel,
        }
    end)

    if success and allocations then
        -- Calculate totalSpent from discipline totals
        local calculatedSpent = 0
        if allocations.disciplines and #allocations.disciplines > 0 then
            for _, discipline in ipairs(allocations.disciplines) do
                if discipline.total and discipline.total > 0 then
                    calculatedSpent = calculatedSpent + discipline.total
                end
            end
        end

        -- Use calculated spent from disciplines if available, otherwise use allocations.totalSpent
        if calculatedSpent > 0 then
            data.spent = calculatedSpent
        else
            data.spent = allocations.totalSpent
        end

        -- Verify: total = assigned + unassigned
        -- Calculate total assigned from discipline assigned values (more reliable than spent)
        local totalAssigned = 0
        if allocations.disciplines and #allocations.disciplines > 0 then
            for _, discipline in ipairs(allocations.disciplines) do
                if discipline.assigned and discipline.assigned > 0 then
                    totalAssigned = totalAssigned + discipline.assigned
                end
            end
        end

        -- If we have assigned values, use them for verification
        if totalAssigned > 0 then
            -- Verify: total = assigned + unassigned
            if data.available == nil then
                data.available = data.total - totalAssigned
                CM.DebugPrint(
                    "CP",
                    string_format(
                        "Calculated unassigned CP: %d (from total %d - assigned %d)",
                        data.available,
                        data.total,
                        totalAssigned
                    )
                )
            else
                -- Verify consistency
                local calculatedTotal = totalAssigned + data.available
                local diff = math.abs(calculatedTotal - data.total)
                -- Use more lenient tolerance (5 points) since CP calculation can have rounding differences
                -- The API sometimes reports slightly different totals due to how it tracks CP across disciplines
                if diff > 5 then
                    CM.DebugPrint(
                        "CP",
                        string_format(
                            "CP verification: assigned=%d, unassigned=%d, total=%d (diff=%d) - recalculating unassigned",
                            totalAssigned,
                            data.available,
                            data.total,
                            diff
                        )
                    )
                    -- Recalculate unassigned from assigned
                    data.available = data.total - totalAssigned
                end
            end
        else
            -- Fallback: use spent for calculation
            if data.available == nil or (data.spent > 0 and data.available == data.total) then
                data.available = data.total - data.spent
                CM.DebugPrint(
                    "CP",
                    string_format(
                        "Calculated unassigned CP: %d (from total %d - spent %d)",
                        data.available,
                        data.total,
                        data.spent
                    )
                )
            elseif data.spent > 0 then
                -- Validate: available + spent should equal total (within 1 point tolerance)
                local calculatedTotal = data.available + data.spent
                if math.abs(calculatedTotal - data.total) > 1 then
                    CM.DebugPrint("COLLECTOR",
                        string_format(
                            "CP mismatch detected: unassigned=%d, spent=%d, total=%d (diff=%d) - recalculating",
                            data.available,
                            data.spent,
                            data.total,
                            math.abs(calculatedTotal - data.total)
                        )
                    )
                    data.available = data.total - data.spent
                end
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
                            allStars = {}, -- All stars including 0 points (for constellation table view)
                            slottable = 0,
                            passive = 0,
                            slottableSkills = {},
                            passiveSkills = {},
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

    -- Get available skill points - try correct ESO API function first
    -- ESO API: GetNumAvailableSkillPoints() returns the number of unspent skill points
    local availableSkillPoints = 0
    local apiSuccess, apiValue = pcall(GetNumAvailableSkillPoints)
    if apiSuccess and apiValue ~= nil then
        availableSkillPoints = apiValue
    else
        -- Fallback: try alternative function name (for older API versions)
        apiSuccess, apiValue = pcall(GetAvailableSkillPoints)
        if apiSuccess and apiValue ~= nil then
            availableSkillPoints = apiValue
        end
    end

    progression.skillPoints = availableSkillPoints
    progression.unspentSkillPoints = progression.skillPoints -- Alias for consistency with generator
    progression.totalSkillPoints = CM.SafeCall(GetTotalSkillPoints) or 0 -- Total skill points earned
    progression.attributePoints = CM.SafeCall(GetAttributeUnspentPoints) or 0
    progression.unspentAttributePoints = progression.attributePoints -- Alias for consistency with generator
    progression.achievementPoints = CM.SafeCall(GetEarnedAchievementPoints) or 0
    progression.totalAchievements = CM.SafeCall(GetTotalAchievementPoints) or 0
    progression.achievementPercent = progression.totalAchievements > 0
            and math.floor((progression.achievementPoints / progression.totalAchievements) * 100)
        or 0

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
            local vampStage = buffName:match("Stage (%d) Vampirism")
                or buffName:match("Vampirism Stage (%d)")
                or buffName:match("Stage (%d) Vampire")
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
        percent = (enlightenedCap > 0) and math.floor((enlightenedPool / enlightenedCap) * 100) or 0,
    }

    return progression
end

CM.collectors.CollectProgressionData = CollectProgressionData
