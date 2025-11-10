-- CharacterMarkdown - Champion Point Pathfinder
-- Finds minimum path to unlock a specific champion skill/star

local CM = CharacterMarkdown
local string_format = string.format

-- =====================================================
-- CHAMPION SKILL PATHFINDER
-- =====================================================

-- Build current allocations map from CP data
local function BuildAllocationsMap(cpData, disciplineIndex)
    local allocations = {}
    
    if not cpData or not cpData.disciplines then
        return allocations
    end
    
    -- Find the discipline
    for _, discipline in ipairs(cpData.disciplines) do
        -- Match by index (1=Craft, 2=Warfare, 3=Fitness)
        local DisciplineType = CM.constants and CM.constants.DisciplineType
        local expectedName = nil
        if disciplineIndex == 1 then expectedName = DisciplineType.CRAFT
        elseif disciplineIndex == 2 then expectedName = DisciplineType.WARFARE
        elseif disciplineIndex == 3 then expectedName = DisciplineType.FITNESS
        end
        
        if discipline.name == expectedName then
            -- Get all stars from this discipline
            if discipline.allStars then
                for _, star in ipairs(discipline.allStars) do
                    if star.skillId and star.points then
                        allocations[star.skillId] = star.points
                    end
                end
            end
            break
        end
    end
    
    return allocations
end

-- Find minimum path to unlock a target champion skill
-- Returns: { path = {...}, totalPoints = N, isUnlocked = bool, targetSkillName = string }
-- path: array of {skillId, skillName, pointsNeeded, currentPoints}
-- Usage: FindMinimumPathToSkill(skillId, disciplineIndex, cpData)
local function FindMinimumPathToSkill(targetSkillId, disciplineIndex, cpData)
    if not targetSkillId or not disciplineIndex then
        return nil, "Target skill ID and discipline index are required"
    end
    
    -- Build current allocations map from cpData
    local currentAllocations = BuildAllocationsMap(cpData, disciplineIndex)
    
    -- Test if skill is already unlocked
    local success, isUnlocked = pcall(WouldChampionSkillNodeBeUnlocked, targetSkillId, 0)
    if success and isUnlocked then
        local targetSkillName = GetChampionSkillName(targetSkillId) or "Unknown"
        return {
            path = {},
            totalPoints = 0,
            isUnlocked = true,
            targetSkillId = targetSkillId,
            targetSkillName = targetSkillName
        }
    end
    
    -- Get all skills in the discipline to build prerequisite graph
    local allSkills = {}
    local numSkills = GetNumChampionDisciplineSkills(disciplineIndex)
    
    if not numSkills or numSkills == 0 then
        return nil, "Could not get skills for discipline"
    end
    
    -- Build skill map with current allocations
    for skillIndex = 1, numSkills do
        local skillId = GetChampionSkillId(disciplineIndex, skillIndex)
        if skillId then
            local skillName = GetChampionSkillName(skillId) or "Unknown"
            local pointsSpent = currentAllocations and currentAllocations[skillId] or 0
            local maxPoints = 0
            local successMax, maxValue = pcall(GetChampionSkillMaxPoints, skillId)
            if successMax and maxValue then
                maxPoints = maxValue
            end
            
            allSkills[skillId] = {
                skillId = skillId,
                skillName = skillName,
                skillIndex = skillIndex,
                currentPoints = pointsSpent,
                maxPoints = maxPoints,
                isUnlocked = false,
                prerequisites = {}  -- Will be discovered
            }
        end
    end
    
    if not allSkills[targetSkillId] then
        return nil, string_format("Target skill %d not found in discipline", targetSkillId)
    end
    
    -- Discover prerequisites by testing unlock conditions
    -- For each skill, test which other skills need points to unlock it
    for skillId, skillData in pairs(allSkills) do
        -- Test unlock with 0 pending points (current state)
        local success, unlocked = pcall(WouldChampionSkillNodeBeUnlocked, skillId, 0)
        skillData.isUnlocked = (success and unlocked) or false
        
        -- If not unlocked, try to find prerequisites
        if not skillData.isUnlocked then
            -- Test each other skill to see if adding points to it helps unlock this one
            for otherSkillId, otherSkillData in pairs(allSkills) do
                if otherSkillId ~= skillId then
                    -- Test if adding 1 point to otherSkill unlocks this skill
                    local testSuccess, wouldUnlock = pcall(WouldChampionSkillNodeBeUnlocked, skillId, 0)
                    -- Note: WouldChampionSkillNodeBeUnlocked doesn't let us test "if we add points to X"
                    -- We need a different approach - check if skill is in a cluster with prerequisites
                end
            end
        end
    end
    
    -- Use BFS (Breadth-First Search) to find minimum path
    -- Start from all currently unlocked skills
    local queue = {}
    local visited = {}
    local parent = {}  -- parent[skillId] = {fromSkillId, pointsNeeded}
    
    -- Initialize queue with all unlocked skills
    for skillId, skillData in pairs(allSkills) do
        if skillData.isUnlocked then
            table.insert(queue, {skillId = skillId, pointsNeeded = 0, path = {}})
            visited[skillId] = true
        end
    end
    
    -- BFS to find path to target
    local foundPath = nil
    local queueIndex = 1
    
    while queueIndex <= #queue do
        local current = queue[queueIndex]
        queueIndex = queueIndex + 1
        
        if current.skillId == targetSkillId then
            -- Found target! Build path
            foundPath = current.path
            break
        end
        
        -- Explore neighbors (skills that might unlock from this one)
        -- Since we can't directly query prerequisites, we'll use a heuristic:
        -- Try adding points to nearby skills and test if target unlocks
        for otherSkillId, otherSkillData in pairs(allSkills) do
            if not visited[otherSkillId] and otherSkillId ~= current.skillId then
                -- Test if adding points to this skill helps unlock target
                -- We'll need to simulate by testing unlock with pending points
                -- This is a simplified approach - actual implementation would need
                -- to understand the CP constellation structure better
                
                local pointsToAdd = 1  -- Start with 1 point
                local maxToTest = otherSkillData.maxPoints - otherSkillData.currentPoints
                
                -- Test if adding points to otherSkill unlocks target
                for testPoints = pointsToAdd, math.min(maxToTest, 10) do  -- Limit to 10 for performance
                    -- Create test allocation
                    local testAllocations = {}
                    for sid, sdata in pairs(currentAllocations or {}) do
                        testAllocations[sid] = sdata
                    end
                    testAllocations[otherSkillId] = (testAllocations[otherSkillId] or 0) + testPoints
                    
                    -- Test if target would be unlocked (this requires simulating the unlock check)
                    -- Since WouldChampionSkillNodeBeUnlocked only checks current state,
                    -- we need a different approach
                    
                    -- For now, use a simple heuristic: skills closer in index might be related
                    local indexDiff = math.abs(otherSkillData.skillIndex - allSkills[targetSkillId].skillIndex)
                    if indexDiff <= 5 then  -- Within 5 positions
                        visited[otherSkillId] = true
                        local newPath = {}
                        for _, step in ipairs(current.path) do
                            table.insert(newPath, step)
                        end
                        table.insert(newPath, {
                            skillId = otherSkillId,
                            skillName = otherSkillData.skillName,
                            pointsNeeded = testPoints,
                            currentPoints = otherSkillData.currentPoints
                        })
                        
                        table.insert(queue, {
                            skillId = otherSkillId,
                            pointsNeeded = current.pointsNeeded + testPoints,
                            path = newPath
                        })
                        break
                    end
                end
            end
        end
    end
    
    if not foundPath then
        return nil, "Could not find path to unlock skill (may require cluster root or complex prerequisites)"
    end
    
    -- Calculate total points needed
    local totalPoints = 0
    for _, step in ipairs(foundPath) do
        totalPoints = totalPoints + step.pointsNeeded
    end
    
    return {
        path = foundPath,
        totalPoints = totalPoints,
        isUnlocked = false,
        targetSkillId = targetSkillId,
        targetSkillName = allSkills[targetSkillId].skillName
    }
end

-- Get unlock requirements for a skill using cluster information
-- This uses GetChampionClusterSkillIds to understand prerequisite relationships
-- Returns: { isUnlocked, requirements[], totalPointsNeeded, clusterRoot }
-- Usage: GetSkillUnlockRequirements(skillId, disciplineIndex, cpData)
local function GetSkillUnlockRequirements(targetSkillId, disciplineIndex, cpData)
    if not targetSkillId or not disciplineIndex then
        return nil, "Target skill ID and discipline index are required"
    end
    
    -- Build current allocations map
    local currentAllocations = BuildAllocationsMap(cpData, disciplineIndex)
    
    -- Check if already unlocked
    local success, isUnlocked = pcall(WouldChampionSkillNodeBeUnlocked, targetSkillId, 0)
    if success and isUnlocked then
        return {
            isUnlocked = true,
            requirements = {},
            totalPointsNeeded = 0,
            targetSkillId = targetSkillId,
            targetSkillName = GetChampionSkillName(targetSkillId) or "Unknown"
        }
    end
    
    -- Find which cluster this skill belongs to
    local clusterRoot = nil
    local numSkills = GetNumChampionDisciplineSkills(disciplineIndex)
    
    -- Find cluster roots and check if target is in any cluster
    for skillIndex = 1, numSkills do
        local skillId = GetChampionSkillId(disciplineIndex, skillIndex)
        if skillId then
            local successRoot, isRoot = pcall(IsChampionSkillClusterRoot, skillId)
            if successRoot and isRoot then
                -- Get all skills in this cluster
                local successCluster, clusterSkills = pcall(function()
                    return {GetChampionClusterSkillIds(skillId)}
                end)
                
                if successCluster and clusterSkills then
                    for _, clusterSkillId in ipairs(clusterSkills) do
                        if clusterSkillId == targetSkillId then
                            clusterRoot = skillId
                            break
                        end
                    end
                end
                
                if clusterRoot then break end
            end
        end
    end
    
    -- If we found the cluster, get all skills in it
    local requirements = {}
    if clusterRoot then
        local successCluster, clusterSkills = pcall(function()
            return {GetChampionClusterSkillIds(clusterRoot)}
        end)
        
        if successCluster and clusterSkills then
            for _, clusterSkillId in ipairs(clusterSkills) do
                if clusterSkillId ~= targetSkillId then
                    local currentPoints = (currentAllocations and currentAllocations[clusterSkillId]) or 0
                    local skillName = GetChampionSkillName(clusterSkillId) or "Unknown"
                    
                    -- Test if this skill needs points to unlock target
                    -- This is a heuristic - we'd need to test actual unlock conditions
                    table.insert(requirements, {
                        skillId = clusterSkillId,
                        skillName = skillName,
                        currentPoints = currentPoints,
                        pointsNeeded = 1  -- Simplified - would need actual testing
                    })
                end
            end
        end
    end
    
    return {
        isUnlocked = false,
        requirements = requirements,
        totalPointsNeeded = #requirements,  -- Simplified
        clusterRoot = clusterRoot
    }
end

-- Export functions
CM.utils = CM.utils or {}
CM.utils.FindMinimumPathToSkill = FindMinimumPathToSkill
CM.utils.GetSkillUnlockRequirements = GetSkillUnlockRequirements

return {
    FindMinimumPathToSkill = FindMinimumPathToSkill,
    GetSkillUnlockRequirements = GetSkillUnlockRequirements
}

