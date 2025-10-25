-- CharacterMarkdown - Armory Builds Data Collector
-- Armory system builds, loadouts, and build management

local CM = CharacterMarkdown

-- =====================================================
-- ARMORY BUILDS
-- =====================================================

local function CollectArmoryBuildsData()
    local armory = {
        total = 0,
        active = 0,
        builds = {}
    }
    
    -- Get total number of armory builds
    local success, numBuilds = pcall(GetNumArmoryBuilds)
    if success and numBuilds then
        armory.total = numBuilds
        
        -- Get each build
        for i = 1, numBuilds do
            local success2, buildName, isActive = pcall(GetArmoryBuildInfo, i)
            if success2 and buildName and buildName ~= "" then
                if isActive then
                    armory.active = armory.active + 1
                end
                
                local buildData = {
                    name = buildName,
                    active = isActive or false,
                    index = i,
                    equipment = {},
                    skills = {},
                    champion = {}
                }
                
                -- Get build equipment
                local success3, numSlots = pcall(GetNumArmoryBuildEquipmentSlots, i)
                if success3 and numSlots then
                    for slot = 1, numSlots do
                        local success4, itemId, itemName, quality = pcall(GetArmoryBuildEquipmentSlotInfo, i, slot)
                        if success4 and itemId and itemName then
                            table.insert(buildData.equipment, {
                                slot = slot,
                                id = itemId,
                                name = itemName,
                                quality = quality or 0
                            })
                        end
                    end
                end
                
                -- Get build skills
                local success5, numSkillBars = pcall(GetNumArmoryBuildSkillBars, i)
                if success5 and numSkillBars then
                    for barIndex = 1, numSkillBars do
                        local skillBar = {
                            barIndex = barIndex,
                            skills = {}
                        }
                        
                        for skillSlot = 1, 6 do
                            local success6, skillId, skillName = pcall(GetArmoryBuildSkillBarSlotInfo, i, barIndex, skillSlot)
                            if success6 and skillId and skillName then
                                table.insert(skillBar.skills, {
                                    slot = skillSlot,
                                    id = skillId,
                                    name = skillName
                                })
                            end
                        end
                        
                        table.insert(buildData.skills, skillBar)
                    end
                end
                
                -- Get build champion points
                local success7, championPoints = pcall(GetArmoryBuildChampionPoints, i)
                if success7 and championPoints then
                    buildData.champion = championPoints
                end
                
                table.insert(armory.builds, buildData)
            end
        end
        
        -- Sort by name
        table.sort(armory.builds, function(a, b)
            return a.name < b.name
        end)
    end
    
    return armory
end

-- =====================================================
-- BUILD TEMPLATES
-- =====================================================

local function CollectBuildTemplatesData()
    local templates = {
        total = 0,
        categories = {}
    }
    
    -- Get build template categories
    local success, numCategories = pcall(GetNumBuildTemplateCategories)
    if success and numCategories then
        for categoryIndex = 1, numCategories do
            local success2, categoryName, numTemplates = pcall(GetBuildTemplateCategoryInfo, categoryIndex)
            if success2 and categoryName and numTemplates then
                local categoryData = {
                    name = categoryName,
                    total = numTemplates,
                    templates = {}
                }
                
                -- Get templates in this category
                for templateIndex = 1, numTemplates do
                    local success3, templateName, templateDescription = pcall(GetBuildTemplateInfo, categoryIndex, templateIndex)
                    if success3 and templateName then
                        table.insert(categoryData.templates, {
                            name = templateName,
                            description = templateDescription or "",
                            categoryIndex = categoryIndex,
                            templateIndex = templateIndex
                        })
                    end
                end
                
                templates.categories[categoryName] = categoryData
                templates.total = templates.total + numTemplates
            end
        end
    end
    
    return templates
end

-- =====================================================
-- MAIN ARMORY BUILDS COLLECTOR
-- =====================================================

local function CollectArmoryBuildsDataMain()
    return {
        armory = CollectArmoryBuildsData(),
        templates = CollectBuildTemplatesData()
    }
end

CM.collectors.CollectArmoryBuildsData = CollectArmoryBuildsDataMain
