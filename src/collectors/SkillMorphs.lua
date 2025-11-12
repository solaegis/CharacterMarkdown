-- CharacterMarkdown - Skill Morphs Collector
-- Collects all available skill morphs from unlocked skill lines
-- Uses ESO's AbilityProgression API for accurate morph detection

local CM = CharacterMarkdown

-- =====================================================
-- SKILL MORPHS COLLECTION
-- =====================================================

local function CollectSkillMorphsData()
    local morphsData = {}

    local numSkillTypes = GetNumSkillTypes() or 0
    local playerClass = GetUnitClass("player") or "Unknown"

    -- Map of class skill lines for filtering
    local classSkillLines = {
        ["Dragonknight"] = {
            ["Ardent Flame"] = true,
            ["Draconic Power"] = true,
            ["Earthen Heart"] = true,
        },
        ["Nightblade"] = {
            ["Assassination"] = true,
            ["Shadow"] = true,
            ["Siphoning"] = true,
        },
        ["Sorcerer"] = {
            ["Daedric Summoning"] = true,
            ["Dark Magic"] = true,
            ["Storm Calling"] = true,
        },
        ["Templar"] = {
            ["Aedric Spear"] = true,
            ["Dawn's Wrath"] = true,
            ["Restoring Light"] = true,
        },
        ["Warden"] = {
            ["Animal Companions"] = true,
            ["Green Balance"] = true,
            ["Winter's Embrace"] = true,
        },
        ["Necromancer"] = {
            ["Grave Lord"] = true,
            ["Bone Tyrant"] = true,
            ["Living Death"] = true,
        },
        ["Arcanist"] = {
            ["Herald of the Tome"] = true,
            ["Apocryphal Soldier"] = true,
            ["Curative Runeforms"] = true,
        },
    }

    -- Invalid skill types/lines to filter out
    local invalidSkillTypes = {
        ["Vengeance"] = true,
        ["Racial"] = true,
    }
    local invalidSkillLines = {
        ["Vengeance"] = true,
        ["Crown Store"] = true,
        [""] = true,
    }

    -- Skill type emoji mapping
    local skillTypeEmojis = {
        ["Class"] = "⚔️",
        ["Weapon"] = "⚔️", -- Changed from 🗡️ for better compatibility
        ["Armor"] = "🛡️",
        ["World"] = "🌍",
        ["Guild"] = "🏰", -- Changed from 🏛️ for better compatibility
        ["Alliance War"] = "⚔️",
        ["Racial"] = "⭐", -- Changed from 🎭 for better compatibility
        ["Craft"] = "⚒️", -- Changed from 🔨 for consistency with other files
        ["Champion"] = "⭐",
    }

    -- Track which progression IDs we've already processed (to avoid duplicates)
    local processedProgressions = {}

    -- Iterate through all skill types
    for skillType = 1, numSkillTypes do
        local skillTypeName = GetString("SI_SKILLTYPE", skillType) or "Unknown"

        if not invalidSkillTypes[skillTypeName] then
            local numSkillLines = GetNumSkillLines(skillType) or 0
            local emoji = skillTypeEmojis[skillTypeName] or "📜"
            local skillLines = {}

            -- Iterate through skill lines in this skill type
            for skillLineIndex = 1, numSkillLines do
                local success, skillLineName, skillLineRank = pcall(GetSkillLineInfo, skillType, skillLineIndex)

                if success and skillLineName and not invalidSkillLines[skillLineName] then
                    -- Filter class skills for other classes
                    local isClassSkill = (skillTypeName == "Class")
                    local isPlayerClass = not isClassSkill
                        or (classSkillLines[playerClass] and classSkillLines[playerClass][skillLineName])

                    if isPlayerClass then
                        local abilities = {}
                        local numAbilities = GetNumSkillAbilities(skillType, skillLineIndex) or 0

                        -- Iterate through abilities in this skill line
                        for abilityIndex = 1, numAbilities do
                            local success2, abilityName, icon, earnedRank, passive, ultimate, purchased, progressionIndex, rankIndex =
                                pcall(GetSkillAbilityInfo, skillType, skillLineIndex, abilityIndex)

                            if success2 and abilityName and not passive and progressionIndex then
                                -- Skip if we've already processed this progression
                                if not processedProgressions[progressionIndex] then
                                    processedProgressions[progressionIndex] = true

                                    -- Get progression info (tells us current morph and rank)
                                    local success3, progName, currentMorph, currentRank =
                                        pcall(GetAbilityProgressionInfo, progressionIndex)

                                    if success3 and progName then
                                        -- Get XP info to check if at morph level
                                        local success4, lastXP, nextXP, currXP, atMorph =
                                            pcall(GetAbilityProgressionXPInfo, progressionIndex)

                                        -- Build ability data
                                        local ability = {
                                            name = abilityName,
                                            earnedRank = earnedRank or 0,
                                            purchased = purchased or false,
                                            ultimate = ultimate or false,
                                            progressionIndex = progressionIndex,
                                            currentMorph = currentMorph or 0, -- 0=base, 1=morph1, 2=morph2
                                            currentRank = currentRank or 0,
                                            atMorphChoice = (success4 and atMorph) or false,
                                            morphs = {},
                                        }

                                        -- Get morph options using progression API
                                        -- Morph 1 (upper morph)
                                        local morph1Success, morph1Id =
                                            pcall(GetAbilityProgressionAbilityId, progressionIndex, 1, 1)
                                        if morph1Success and morph1Id and morph1Id > 0 then
                                            local morph1Name = GetAbilityName(morph1Id)
                                            if morph1Name and morph1Name ~= "" then
                                                table.insert(ability.morphs, {
                                                    name = morph1Name,
                                                    morphSlot = 1,
                                                    abilityId = morph1Id,
                                                    selected = (currentMorph == 1),
                                                })
                                            end
                                        end

                                        -- Morph 2 (lower morph)
                                        local morph2Success, morph2Id =
                                            pcall(GetAbilityProgressionAbilityId, progressionIndex, 2, 1)
                                        if morph2Success and morph2Id and morph2Id > 0 then
                                            local morph2Name = GetAbilityName(morph2Id)
                                            if morph2Name and morph2Name ~= "" then
                                                table.insert(ability.morphs, {
                                                    name = morph2Name,
                                                    morphSlot = 2,
                                                    abilityId = morph2Id,
                                                    selected = (currentMorph == 2),
                                                })
                                            end
                                        end

                                        -- Only add ability if it has morphs (removed purchased filter)
                                        if #ability.morphs > 0 then
                                            table.insert(abilities, ability)
                                        end
                                    end
                                end
                            end
                        end

                        -- Only add skill line if it has morphable abilities
                        if #abilities > 0 then
                            table.insert(skillLines, {
                                name = skillLineName,
                                rank = skillLineRank or 0,
                                abilities = abilities,
                            })
                        end
                    end
                end
            end

            -- Only add skill type if it has skill lines with morphs
            if #skillLines > 0 then
                table.insert(morphsData, {
                    name = skillTypeName,
                    emoji = emoji,
                    skillLines = skillLines,
                })
            end
        end
    end

    -- Debug output
    if CM.DebugPrint then
        CM.DebugPrint("SKILL_MORPHS", string.format("Collected %d skill types with morphs", #morphsData))
        for i, skillType in ipairs(morphsData) do
            CM.DebugPrint(
                "SKILL_MORPHS",
                string.format("  %d. %s (%d skill lines)", i, skillType.name, #skillType.skillLines)
            )
        end
    end

    return morphsData
end

CM.collectors.CollectSkillMorphsData = CollectSkillMorphsData
