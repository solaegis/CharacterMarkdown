-- CharacterMarkdown - Skills Data Collector
-- Composition logic moved from API layer

local CM = CharacterMarkdown

-- =====================================================
-- SKILL BARS
-- =====================================================

local function CollectSkillBarData()
    -- Use API layer granular functions (composition at collector level)
    local skillPoints = CM.api.skills.GetSkillPoints()
    local primaryBar = CM.api.skills.GetActionBar(HOTBAR_CATEGORY_PRIMARY)
    local backupBar = CM.api.skills.GetActionBar(HOTBAR_CATEGORY_BACKUP)
    
    local bars = {}
    
    local barConfigs = {
        { id = 0, name = "⚔️ Front Bar (Main Hand)", hotbarCategory = HOTBAR_CATEGORY_PRIMARY, apiKey = "primary" },
        { id = 1, name = "🔮 Back Bar (Backup)", hotbarCategory = HOTBAR_CATEGORY_BACKUP, apiKey = "backup" },
    }
    
    for _, config in ipairs(barConfigs) do
        local apiBar = (config.apiKey == "primary") and primaryBar or backupBar
        local bar = {
            id = config.id,
            name = config.name,
            abilities = {}
        }
        
        if apiBar then
            for _, ability in ipairs(apiBar) do
                if ability and ability.id and ability.id > 0 then
                    table.insert(bar.abilities, {
                        name = ability.name or "Empty",
                        id = ability.id,
                        isUltimate = ability.isUltimate or false
                    })
                end
            end
        end
        
        table.insert(bars, bar)
    end
    
    local data = {
        bars = bars,
        points = skillPoints
    }
    
    -- Add computed fields
    local totalAbilities = 0
    local ultimateCount = 0
    for _, bar in ipairs(bars) do
        if bar.abilities then
            for _, ability in ipairs(bar.abilities) do
                totalAbilities = totalAbilities + 1
                if ability.isUltimate then
                    ultimateCount = ultimateCount + 1
                end
            end
        end
    end
    
    data.summary = {
        totalAbilities = totalAbilities,
        ultimateCount = ultimateCount,
        regularAbilities = totalAbilities - ultimateCount
    }
    
    return data
end

CM.collectors.CollectSkillBarData = CollectSkillBarData

-- =====================================================
-- SKILL PROGRESSION
-- =====================================================

local function CollectSkillProgressionData()
    -- Use API layer granular functions (composition at collector level)
    local skillLines = CM.api.skills.GetSkillLines()
    
    local data = {
        lines = skillLines,
        maxedLines = {},
        inProgressLines = {},
        earlyProgressLines = {},
        summary = {
            totalLines = 0,
            totalSkills = 0,
            totalMorphs = 0,
            totalPassives = 0,
            maxedCount = 0,
            inProgressCount = 0,
            earlyProgressCount = 0,
            completionPercent = 0
        }
    }
    
    -- Helper to check if a line is maxed
    -- Logic: If nextXP is 0, it usually means max rank. 
    -- Also check common max ranks (50 for most, 10 for guilds/world, etc)
    local function IsMaxed(line)
        if line.xp and line.xp.max == 0 then return true end
        -- Fallback for when XP info might be weird but rank is clearly high
        if line.rank == 50 then return true end
        -- Guilds/World often max at 10
        if (line.rank == 10) and (line.xp.max == 0 or line.xp.current >= line.xp.max) then return true end
        return false
    end

    -- Calculate summary statistics and categorize
    if skillLines then
        -- CM.Warn("CollectSkillProgressionData found " .. #skillLines .. " total lines")
        -- CM.Warn("First line type: " .. type(skillLines[1]))
        -- if skillLines[1] then CM.Warn("First line name: " .. tostring(skillLines[1].name)) end
        
        data.summary.totalLines = #skillLines
        
        local loopCount = 0
        for i, line in ipairs(skillLines) do
            loopCount = loopCount + 1
            -- Calculate progress percent for the line
            local current = line.xp.current or 0
            local min = line.xp.min or 0
            local max = line.xp.max or 0
            local progress = 0
            
            if max > 0 and max > min then
                progress = math.floor(((current - min) / (max - min)) * 100)
            elseif IsMaxed(line) then
                progress = 100
            end
            line.progress = progress

            -- Categorize
            if IsMaxed(line) then
                -- Fetch passives for maxed lines
                line.passives = CM.api.skills.GetSkillPassives(line.type, line.index)
                table.insert(data.maxedLines, line)
                data.summary.maxedCount = data.summary.maxedCount + 1
                -- CM.Warn("Line MAXED: " .. line.name)
            elseif line.rank > 1 or progress > 0 then
                -- Fetch passives for in-progress lines too
                line.passives = CM.api.skills.GetSkillPassives(line.type, line.index)
                table.insert(data.inProgressLines, line)
                data.summary.inProgressCount = data.summary.inProgressCount + 1
                -- CM.Warn("Line IN PROGRESS: " .. line.name .. " (Rank " .. line.rank .. ", " .. progress .. "%)")
            else
                table.insert(data.earlyProgressLines, line)
                data.summary.earlyProgressCount = data.summary.earlyProgressCount + 1
                -- CM.Warn("Line EARLY: " .. line.name)
            end

            -- Count skills/morphs/passives (using existing logic if available, or just counting)
            -- ...


            -- Count skills/morphs/passives (using existing logic if available, or just counting)
            -- The original logic iterated line.skills, but GetSkillLines doesn't return .skills by default?
            -- Wait, GetSkillLines in API returns list of lines. It does NOT populate .skills.
            -- The original code assumed line.skills existed. 
            -- Let's check src/api/Skills.lua again. GetSkillLines calls GetSkillLinesByType.
            -- GetSkillLinesByType returns { index, name, rank, id }.
            -- GetSkillLines adds { type, index, name, rank, xp }.
            -- It does NOT add .skills.
            -- So the original code: `if line.skills then ... end` was likely doing nothing or I missed something.
            -- Ah, looking at the original file content I read in Step 21:
            -- `local skillLines = CM.api.skills.GetSkillLines()`
            -- `for _, line in ipairs(skillLines) do if line.skills then ... end end`
            -- It seems the original code expected `line.skills` but the API `GetSkillLines` I read in Step 22 does NOT provide it.
            -- This implies the original code might have been incomplete or I missed where `line.skills` comes from.
            -- OR `GetSkillLines` was modified recently?
            -- Regardless, I need to populate summary stats.
            -- I can use GetSkillAbilitiesWithMorphs to count skills/morphs if I want accurate counts.
            -- But that might be expensive to do for ALL lines.
            -- For now, I'll skip detailed skill counting for the summary if it's too expensive, 
            -- or just do it for the lines we care about.
            -- The example output has "Overall Completion 34%", "Abilities with Morphs 35".
            -- So I DO need these counts.
            
            -- Let's fetch abilities for counting
            local abilities = CM.api.skills.GetSkillAbilitiesWithMorphs(line.type, line.index)
            for _, skill in ipairs(abilities) do
                data.summary.totalSkills = data.summary.totalSkills + 1
                if #skill.morphs > 0 then
                    data.summary.totalMorphs = data.summary.totalMorphs + 1
                end
            end
            
            -- Count passives
            local passives = CM.api.skills.GetSkillPassives(line.type, line.index)
            data.summary.totalPassives = data.summary.totalPassives + #passives
        end
        -- CM.Warn("Loop finished. Iterated " .. loopCount .. " times.")
        -- CM.Warn("Summary: Maxed=" .. data.summary.maxedCount .. ", InProgress=" .. data.summary.inProgressCount .. ", Early=" .. data.summary.earlyProgressCount)
        
        -- CRITICAL: Verify arrays are populated
        -- CM.Warn("COLLECTOR RETURN: maxedLines count = " .. #data.maxedLines)
        -- CM.Warn("COLLECTOR RETURN: inProgressLines count = " .. #data.inProgressLines)
        -- CM.Warn("COLLECTOR RETURN: earlyProgressLines count = " .. #data.earlyProgressLines)
        
        -- Calculate overall completion
        if data.summary.totalLines > 0 then
            data.summary.completionPercent = math.floor((data.summary.maxedCount / data.summary.totalLines) * 100)
        end
    end
    
    return data
end

CM.collectors.CollectSkillProgressionData = CollectSkillProgressionData

-- =====================================================
-- SKILL MORPHS
-- =====================================================

local function CollectSkillMorphsData()
    -- Use API layer for skill morphs data
    -- Get player class from Character API to pass to Skills API
    local characterInfo = CM.api.character.GetClass()
    local playerClass = characterInfo and characterInfo.name or "Unknown"
    
    -- Use internal API function for morphs (composition at collector level)
    local morphsData = CM.api.skills._GetMorphsData(playerClass) or {}
    
    -- Add computed fields for morph analysis
    local totalMorphs = 0
    local chosenMorphs = 0
    local availableMorphs = 0
    
    for _, skillType in ipairs(morphsData) do
        if skillType.skillLines then
            for _, line in ipairs(skillType.skillLines) do
                if line.abilities then
                    for _, ability in ipairs(line.abilities) do
                        totalMorphs = totalMorphs + 1
                        -- Check if a morph is chosen (currentMorph > 0)
                        if ability.currentMorph and ability.currentMorph > 0 then
                            chosenMorphs = chosenMorphs + 1
                        else
                            availableMorphs = availableMorphs + 1
                        end
                    end
                end
            end
        end
    end
    
    local data = {
        class = playerClass,
        skillTypes = morphsData,
        summary = {
            totalMorphs = totalMorphs,
            chosenMorphs = chosenMorphs,
            availableMorphs = availableMorphs,
            completionPercent = totalMorphs > 0 and math.floor((chosenMorphs / totalMorphs) * 100) or 0
        }
    }
    
    -- Debug output
    if CM.DebugPrint then
        CM.DebugPrint("SKILL_MORPHS", string.format("Collected %d skill types with morphs", #morphsData))
    end
    
    return data
end

CM.collectors.CollectSkillMorphsData = CollectSkillMorphsData

CM.DebugPrint("COLLECTOR", "Skills collector module loaded")

