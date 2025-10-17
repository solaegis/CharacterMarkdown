-- CharacterMarkdown - Skills Data Collector
-- Skill progression and skill bars

local CM = CharacterMarkdown

-- =====================================================
-- SKILL BARS
-- =====================================================

local function CollectSkillBarData()
    local bars = {}
    
    local barConfigs = {
        {id = 0, name = "🗡️ Front Bar (Main Hand)", hotbarCategory = HOTBAR_CATEGORY_PRIMARY},
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
        ["Vengeance"] = true,
        ["Racial"] = true
    }
    local invalidSkillLines = { 
        ["Vengeance"] = true,
        ["Crown Store"] = true,
        [""] = true
    }
    
    for skillType = 1, numSkillTypes do
        local skillTypeName = GetString("SI_SKILLTYPE", skillType) or "Unknown"
        
        if not invalidSkillTypes[skillTypeName] then
            local numSkillLines = GetNumSkillLines(skillType) or 0
            local skills = {}
            local isClassSkillType = skillTypeName:find("Class")
            
            -- Emoji mapping
            local emoji = "⚔️"
            if skillTypeName:find("Class") then emoji = "🔥"
            elseif skillTypeName:find("Weapon") then emoji = "⚔️"
            elseif skillTypeName:find("Armor") then emoji = "🛡️"
            elseif skillTypeName:find("World") then emoji = "🌍"
            elseif skillTypeName:find("Guild") then emoji = "🏰"
            elseif skillTypeName:find("Alliance") then emoji = "🏛️"
            elseif skillTypeName:find("Craft") then emoji = "⚒️"
            end
            
            for skillLineIndex = 1, numSkillLines do
                local skillLineName, skillLineRank = GetSkillLineInfo(skillType, skillLineIndex)
                
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
                
                local isValid = skillLineName and 
                               not invalidSkillLines[skillLineName] and 
                               not hasVengeance and
                               not isWrongClass and
                               skillLineRank and 
                               skillLineRank > 0
                
                if isValid then
                    local lastXP, nextXP, currentXP = GetSkillLineXPInfo(skillType, skillLineIndex)
                    
                    local xpProgress = nil
                    local isMaxed = false
                    
                    if skillLineRank >= 50 then
                        isMaxed = true
                    elseif nextXP and nextXP > 0 and currentXP then
                        xpProgress = math.floor((currentXP / nextXP) * 100)
                    else
                        isMaxed = true
                    end
                    
                    -- Apply skill filters from settings
                    local settings = CharacterMarkdownSettings or {}
                    local minRank = settings.minSkillRank or 1
                    local hideMaxed = settings.hideMaxedSkills or false
                    
                    local passesFilters = true
                    if skillLineRank < minRank then
                        passesFilters = false
                    end
                    if hideMaxed and isMaxed then
                        passesFilters = false
                    end
                    
                    if passesFilters then
                        table.insert(skills, {
                            name = skillLineName, 
                            rank = skillLineRank, 
                            progress = xpProgress, 
                            maxed = isMaxed
                        })
                    end
                end
            end
            
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
