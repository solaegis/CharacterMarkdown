-- CharacterMarkdown - Skills Data Collector
-- Skill progression and skill bars

local CM = CharacterMarkdown

-- =====================================================
-- SKILL BARS
-- =====================================================

local function CollectSkillBarData()
    local bars = {}
    
    local barConfigs = {
        {id = 0, name = "⚔️ Front Bar (Main Hand)", hotbarCategory = HOTBAR_CATEGORY_PRIMARY},  -- Changed from 🗡️ for better compatibility
        {id = 1, name = "🔮 Back Bar (Backup)", hotbarCategory = HOTBAR_CATEGORY_BACKUP}
    }
    
    for _, config in ipairs(barConfigs) do
        local bar = { name = config.name, ultimate = nil, ultimateId = nil, abilities = {} }
        
        -- Ultimate
        local ultimateSlotId = GetSlotBoundId(8, config.hotbarCategory)
        if ultimateSlotId and ultimateSlotId > 0 then
            bar.ultimate = GetAbilityName(ultimateSlotId) or "[Empty]"
            bar.ultimateId = ultimateSlotId
        else
            bar.ultimate = "[Empty]"
        end
        
        -- Regular abilities (slots 3-7)
        for slotIndex = 3, 7 do
            local slotId = GetSlotBoundId(slotIndex, config.hotbarCategory)
            if slotId and slotId > 0 then
                local abilityName = GetAbilityName(slotId)
                table.insert(bar.abilities, {
                    name = (abilityName and abilityName ~= "") and abilityName or "[Empty Slot]",
                    id = slotId
                })
            else
                table.insert(bar.abilities, {
                    name = "[Empty Slot]",
                    id = nil
                })
            end
        end
        
        table.insert(bars, bar)
    end
    
    return bars
end

CM.collectors.CollectSkillBarData = CollectSkillBarData

-- =====================================================
-- SKILL PROGRESSION
-- =====================================================

local function CollectSkillProgressionData()
    local skillData = {}
    
    local numSkillTypes = GetNumSkillTypes() or 0
    local playerClass = GetUnitClass("player") or "Unknown"
    
    -- Map of class skill lines
    local classSkillLines = {
        ["Dragonknight"] = {
            ["Ardent Flame"] = true,
            ["Draconic Power"] = true,
            ["Earthen Heart"] = true
        },
        ["Nightblade"] = {
            ["Assassination"] = true,
            ["Shadow"] = true,
            ["Siphoning"] = true
        },
        ["Sorcerer"] = {
            ["Daedric Summoning"] = true,
            ["Dark Magic"] = true,
            ["Storm Calling"] = true
        },
        ["Templar"] = {
            ["Aedric Spear"] = true,
            ["Dawn's Wrath"] = true,
            ["Restoring Light"] = true
        },
        ["Warden"] = {
            ["Animal Companions"] = true,
            ["Green Balance"] = true,
            ["Winter's Embrace"] = true
        },
        ["Necromancer"] = {
            ["Grave Lord"] = true,
            ["Bone Tyrant"] = true,
            ["Living Death"] = true
        },
        ["Arcanist"] = {
            ["Herald of the Tome"] = true,
            ["Apocryphal Soldier"] = true,
            ["Curative Runeforms"] = true
        }
    }
    
    -- Invalid skill types/lines to filter out
    local invalidSkillTypes = { 
        ["Vengeance"] = true
        -- Note: Racial is now included to show racial passives
    }
    local invalidSkillLines = { 
        ["Vengeance"] = true,
        ["Crown Store"] = true,
        [""] = true
    }
    
    for skillType = 1, numSkillTypes do
        local skillTypeName = GetString("SI_SKILLTYPE", skillType) or "Unknown"
        
        -- Debug all skill types to see what we're getting
        if CM.DebugPrint and (skillTypeName:find("Racial") or skillTypeName == "Racial") then
            CM.DebugPrint("SKILLS", string.format("Found skill type: '%s' (type index: %d)", skillTypeName, skillType))
        end
        
        if not invalidSkillTypes[skillTypeName] then
            local numSkillLines = GetNumSkillLines(skillType) or 0
            local skills = {}
            local isClassSkillType = skillTypeName:find("Class")
            
            -- Emoji mapping
            -- Using widely-supported Unicode emojis for maximum compatibility
            local emoji = "⚔️"
            if skillTypeName:find("Class") then emoji = "🔥"
            elseif skillTypeName:find("Weapon") then emoji = "⚔️"
            elseif skillTypeName:find("Armor") then emoji = "🛡️"
            elseif skillTypeName:find("World") then emoji = "🌍"
            elseif skillTypeName:find("Guild") then emoji = "🏰"
            elseif skillTypeName:find("Alliance") then emoji = "🏰"  -- Changed from 🏛️ to 🏰 (more widely supported)
            elseif skillTypeName:find("Craft") then emoji = "⚒️"
            elseif skillTypeName:find("Racial") then emoji = "⭐"   -- Changed from 🧬 (DNA, newer emoji) to ⭐ (widely supported)
            end
            
            for skillLineIndex = 1, numSkillLines do
                local success, skillLineName, skillLineRank = pcall(GetSkillLineInfo, skillType, skillLineIndex)
                
                if not success then
                    if CM.DebugPrint then
                        CM.DebugPrint("SKILLS", string.format("Failed to get skill line info for type %d, index %d", skillType, skillLineIndex))
                    end
                    -- Skip this iteration
                else
                
                local hasVengeance = skillLineName and (
                    skillLineName:find("Vengeance") or 
                    skillLineName:find("^Vengeance") or
                    skillLineName:match("Vengeance")
                )
                
                local isWrongClass = false
                if isClassSkillType and skillLineName then
                    local playerClassLines = classSkillLines[playerClass]
                    if playerClassLines and not playerClassLines[skillLineName] then
                        isWrongClass = true
                    end
                end
                
                -- Special handling for Racial skills - they don't have ranks/progress
                -- Check if skill type is racial (could be "Racial" or contain "Racial")
                local isRacial = skillTypeName == "Racial" or skillTypeName:find("Racial") ~= nil
                
                -- For racial, use race name if skill line name is missing (BEFORE validation)
                if isRacial and (not skillLineName or skillLineName == "") then
                    local playerRace = GetUnitRace("player")
                    if playerRace then
                        skillLineName = GetString("SI_RACE", playerRace) or "Imperial"
                    else
                        skillLineName = "Imperial"  -- Default fallback
                    end
                    if CM.DebugPrint then
                        CM.DebugPrint("RACIAL", string.format("Using race name for skill line: %s", skillLineName))
                    end
                end
                
                -- For racial skills, we want to show them even without rank/progress
                -- Racial skills might have a skill line name like the race name (e.g., "Breton", "Dark Elf", "Imperial")
                local isValid = (isRacial or skillLineName) and 
                               (not skillLineName or not invalidSkillLines[skillLineName]) and 
                               not hasVengeance and
                               not isWrongClass and
                               (isRacial or (skillLineRank and skillLineRank > 0))
                
                if isRacial and CM.DebugPrint then
                    CM.DebugPrint("RACIAL", string.format("Checking validity - isRacial: %s, skillLineName: %s, isValid: %s, skillLineRank: %s", 
                        tostring(isRacial), tostring(skillLineName), tostring(isValid), tostring(skillLineRank)))
                end
                
                if isValid then
                    local lastXP, nextXP, currentXP = GetSkillLineXPInfo(skillType, skillLineIndex)
                    
                    local xpProgress = nil
                    local isMaxed = false
                    local skillLineRankDisplay = skillLineRank or 0
                    
                    -- Racial skills typically don't have ranks, so handle them specially
                    if isRacial then
                        isMaxed = true  -- Consider racial passives as "maxed" for display purposes
                        skillLineRankDisplay = 0
                    elseif skillLineRank >= 50 then
                        isMaxed = true
                    elseif nextXP and nextXP > 0 and currentXP then
                        xpProgress = math.floor((currentXP / nextXP) * 100)
                    else
                        isMaxed = true
                    end
                    
                    -- Always include all skill lines (no filters)
                        -- Collect passives for this skill line
                        local passives = {}
                        local numAbilities = GetNumSkillAbilities(skillType, skillLineIndex) or 0
                        
                        -- Debug for racial skills
                        if isRacial and CM.DebugPrint then
                            CM.DebugPrint("RACIAL", string.format("Processing racial skill line: %s, numAbilities: %d", 
                                tostring(skillLineName), numAbilities))
                        end
                        
                        for abilityIndex = 1, numAbilities do
                            local success, abilityName, icon, earnedRank, isPassive, isUltimate, purchased, 
                                          progressionIndex, rankIndex = pcall(GetSkillAbilityInfo, 
                                                                              skillType, skillLineIndex, abilityIndex)
                            
                            if success and abilityName then
                                -- For racial skills, all abilities are passives (they're not activatables)
                                -- For other skills, check the isPassive flag
                                local shouldInclude = false
                                if isRacial then
                                    -- Racial skills: include all abilities (they're all passive)
                                    shouldInclude = true
                                    if CM.DebugPrint then
                                        CM.DebugPrint("RACIAL", string.format("  Found racial ability: %s (isPassive: %s, purchased: %s)", 
                                            tostring(abilityName), tostring(isPassive), tostring(purchased)))
                                    end
                                elseif isPassive then
                                    -- Regular skills: only include if marked as passive
                                    shouldInclude = true
                                end
                                
                                if shouldInclude then
                                    -- Get max rank for this ability
                                    -- earnedRank from GetSkillAbilityInfo typically represents current rank for passives
                                    -- For passives, most are single rank (max 1), but some have multiple ranks
                                    local currentRank = earnedRank or 0
                                    local maxRank = 1
                                    
                                    -- Try to determine max rank from progression info
                                    if progressionIndex then
                                        local progSuccess, progName, currentMorph, progRank = pcall(GetAbilityProgressionInfo, progressionIndex)
                                        if progSuccess and progRank then
                                            -- If we have progression info, max is typically the earnedRank if it's > 0
                                            -- Otherwise, most passives max at 1
                                            if earnedRank and earnedRank > 0 then
                                                maxRank = earnedRank  -- Current rank is the max for this character
                                            else
                                                maxRank = 1
                                            end
                                        elseif earnedRank and earnedRank > 0 then
                                            maxRank = earnedRank
                                        end
                                    elseif earnedRank and earnedRank > 0 then
                                        maxRank = earnedRank
                                    end
                                    
                                    table.insert(passives, {
                                        name = abilityName,
                                        earnedRank = earnedRank or 0,
                                        currentRank = currentRank,
                                        maxRank = maxRank,
                                        purchased = purchased or false,
                                        abilityId = progressionIndex or nil
                                    })
                                end
                            elseif not success and isRacial and CM.DebugPrint then
                                CM.DebugPrint("RACIAL", string.format("  Failed to get ability %d: %s", abilityIndex, tostring(abilityName)))
                            end
                        end
                        
                        -- Always add the skill line (for racial, even if no passives found, as the skill line itself is valid)
                        -- For regular skills, passives are optional, but the skill line progression should still show
                            table.insert(skills, {
                                name = skillLineName, 
                                rank = skillLineRankDisplay, 
                                progress = xpProgress, 
                                maxed = isMaxed,
                                passives = passives,
                                isRacial = isRacial  -- Flag to help with display formatting
                            })
                            
                            if isRacial and CM.DebugPrint then
                                CM.DebugPrint("RACIAL", string.format("Added racial skill line: %s with %d passives", 
                                    tostring(skillLineName), #passives))
                            end
                end  -- end if isValid
                end  -- end else for success check
            end  -- end for skillLineIndex
            
            if #skills > 0 then
                table.insert(skillData, {
                    name = skillTypeName,
                    emoji = emoji,
                    skills = skills
                })
            end
        end
    end
    
    return skillData
end

CM.collectors.CollectSkillProgressionData = CollectSkillProgressionData
