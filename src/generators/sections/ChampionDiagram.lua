-- CharacterMarkdown - Champion Points Mermaid Diagram Generator
-- Generates personalized CP diagrams showing invested stars with prerequisite relationships

local CM = CharacterMarkdown
local string_format = string.format

-- =====================================================
-- STAR MAPPING
-- =====================================================
-- Map skill names to their tree positions and types

local STAR_MAP = {
    -- CRAFT CONSTELLATION
    -- Base Stars
    ["Fleet Phantom"] = { tree = "Craft", type = "base", node = "C_BASE1" },
    ["Steadfast Enchantment"] = { tree = "Craft", type = "base", node = "C_BASE2" },
    ["Rationer"] = { tree = "Craft", type = "base", node = "C_BASE3" },
    
    -- Independent Stars
    ["Steed's Blessing"] = { tree = "Craft", type = "slottable", node = "C_IND1" },
    ["Breakfall"] = { tree = "Craft", type = "slottable", node = "C_IND2" },
    ["Soul Reservoir"] = { tree = "Craft", type = "passive", node = "C_IND3" },
    
    -- Left Branch (Thieving)
    ["Friends in Low Places"] = { tree = "Craft", type = "passive", node = "C_L1" },
    ["Infamous"] = { tree = "Craft", type = "slottable", node = "C_L2" },
    ["Shadowstrike"] = { tree = "Craft", type = "passive", node = "C_L5" },
    ["Cutpurse's Art"] = { tree = "Craft", type = "slottable", node = "C_L4" },
    
    -- Center Branch (Crafting)
    ["Inspiration Boost"] = { tree = "Craft", type = "passive", node = "C_C1" },
    ["Meticulous Disassembly"] = { tree = "Craft", type = "slottable", node = "C_C2" },
    ["Master Gatherer"] = { tree = "Craft", type = "passive", node = "C_C3" },
    ["Plentiful Harvest"] = { tree = "Craft", type = "slottable", node = "C_C4" },
    ["Treasure Hunter"] = { tree = "Craft", type = "slottable", node = "C_C5" },
    
    -- Right Branch (QoL)
    ["Gilded Fingers"] = { tree = "Craft", type = "slottable", node = "C_R1" },
    ["Haggler"] = { tree = "Craft", type = "passive", node = "C_R2" },
    ["Liquid Efficiency"] = { tree = "Craft", type = "slottable", node = "C_R3" },
    ["Homemaker"] = { tree = "Craft", type = "slottable", node = "C_R4" },
    ["Professional Upkeep"] = { tree = "Craft", type = "slottable", node = "C_R5" },
    ["Gifted Rider"] = { tree = "Craft", type = "slottable", node = "C_R6" },
    ["War Mount"] = { tree = "Craft", type = "slottable", node = "C_R7" },
    
    -- WARFARE CONSTELLATION
    -- Base Stars
    ["Eldritch Insight"] = { tree = "Warfare", type = "base", node = "W_BASE1" },
    ["Tireless Discipline"] = { tree = "Warfare", type = "base", node = "W_BASE2" },
    ["Siphoning Spells"] = { tree = "Warfare", type = "base", node = "W_BASE3" },
    
    -- Independent Stars
    ["Deadly Aim"] = { tree = "Warfare", type = "slottable", node = "W_IND1" },
    ["Master-at-Arms"] = { tree = "Warfare", type = "slottable", node = "W_IND2" },
    ["Thaumaturge"] = { tree = "Warfare", type = "slottable", node = "W_IND3" },
    
    -- Left Branch (Healing)
    ["Blessed"] = { tree = "Warfare", type = "passive", node = "W_L1" },
    ["Rejuvenating Boon"] = { tree = "Warfare", type = "slottable", node = "W_L2" },
    ["Quick Recovery"] = { tree = "Warfare", type = "passive", node = "W_L3" },
    
    -- Center Branch (Defense)
    ["Fighting Finesse"] = { tree = "Warfare", type = "passive", node = "W_C1" },
    ["Ironclad"] = { tree = "Warfare", type = "slottable", node = "W_C2" },
    ["Hardy"] = { tree = "Warfare", type = "passive", node = "W_C3" },
    ["Elemental Aegis"] = { tree = "Warfare", type = "passive", node = "W_C4" },
    
    -- Right Branch (Damage)
    ["Piercing"] = { tree = "Warfare", type = "passive", node = "W_R1" },
    ["Backstabber"] = { tree = "Warfare", type = "passive", node = "W_R3" },
    ["Biting Aura"] = { tree = "Warfare", type = "slottable", node = "W_R4" },
    
    -- Sub-Constellation: Mastered Curation
    ["Enlivening Overflow"] = { tree = "Warfare", type = "slottable", node = "MC1", sub = "Mastered Curation" },
    ["Spirit Mastery"] = { tree = "Warfare", type = "passive", node = "MC2", sub = "Mastered Curation" },
    ["Salvation"] = { tree = "Warfare", type = "slottable", node = "MC3", sub = "Mastered Curation" },
    ["Radiating Regen"] = { tree = "Warfare", type = "passive", node = "MC4", sub = "Mastered Curation" },
    
    -- Sub-Constellation: Extended Might
    ["Wrathful Strikes"] = { tree = "Warfare", type = "slottable", node = "EM1", sub = "Extended Might" },
    ["Critical Precision"] = { tree = "Warfare", type = "passive", node = "EM2", sub = "Extended Might" },
    ["Exploiter"] = { tree = "Warfare", type = "slottable", node = "EM3", sub = "Extended Might" },
    ["Focused Might"] = { tree = "Warfare", type = "passive", node = "EM4", sub = "Extended Might" },
    ["Deadly Precision"] = { tree = "Warfare", type = "slottable", node = "EM5", sub = "Extended Might" },
    
    -- FITNESS CONSTELLATION
    -- Base Stars
    ["Boundless Vitality"] = { tree = "Fitness", type = "base", node = "F_BASE1" },
    ["Rejuvenation"] = { tree = "Fitness", type = "base", node = "F_BASE3" },
    
    -- Independent Stars
    ["Strategic Reserve"] = { tree = "Fitness", type = "slottable", node = "F_IND2" },
    ["Sustained by Suffering"] = { tree = "Fitness", type = "slottable", node = "F_IND3" },
    
    -- Left Branch (Recovery)
    ["Tumbling"] = { tree = "Fitness", type = "passive", node = "F_L1" },
    ["Rolling Rhapsody"] = { tree = "Fitness", type = "slottable", node = "F_L2" },
    ["Hero's Vigor"] = { tree = "Fitness", type = "passive", node = "F_L3" },
    
    -- Center Branch (Resistance)
    ["Defiance"] = { tree = "Fitness", type = "slottable", node = "F_C2" },
    ["Slippery"] = { tree = "Fitness", type = "passive", node = "F_C3" },
    
    -- Right Branch (Movement)
    ["Celerity"] = { tree = "Fitness", type = "passive", node = "F_R1" },
    ["Hasty"] = { tree = "Fitness", type = "slottable", node = "F_R2" },
    ["Sprint Racer"] = { tree = "Fitness", type = "passive", node = "F_R3" },
    
    -- Sub-Constellation: Survivor's Spite
    ["Pain's Refuge"] = { tree = "Fitness", type = "slottable", node = "SS1", sub = "Survivor's Spite" },
    ["Relentlessness"] = { tree = "Fitness", type = "passive", node = "SS2", sub = "Survivor's Spite" },
    ["Bloody Renewal"] = { tree = "Fitness", type = "slottable", node = "SS3", sub = "Survivor's Spite" },
    
    -- Sub-Constellation: Wind Chaser
    ["Celerity Boost"] = { tree = "Fitness", type = "passive", node = "WC2", sub = "Wind Chaser" },
    ["Piercing Gaze"] = { tree = "Fitness", type = "slottable", node = "WC3", sub = "Wind Chaser" },
    
    -- Sub-Constellation: Walking Fortress
    ["Bracing Anchor"] = { tree = "Fitness", type = "slottable", node = "WF1", sub = "Walking Fortress" },
    ["Duelist's Rebuff"] = { tree = "Fitness", type = "passive", node = "WF2", sub = "Walking Fortress" },
    ["Unassailable"] = { tree = "Fitness", type = "slottable", node = "WF3", sub = "Walking Fortress" },
    ["Stalwart Guard"] = { tree = "Fitness", type = "passive", node = "WF4", sub = "Walking Fortress" },
    
    -- Sub-Constellation: Staving Death (FITNESS, not Warfare!)
    ["Bastion"] = { tree = "Fitness", type = "slottable", node = "SD1", sub = "Staving Death" },
    ["Bulwark"] = { tree = "Fitness", type = "passive", node = "SD2", sub = "Staving Death" },
    ["Fortified"] = { tree = "Fitness", type = "passive", node = "SD4", sub = "Staving Death" },
    
    -- Alternative/Old names that might appear
    -- NOTE: These are aliases for the same stars - they share node IDs and will be deduplicated
    ["Precision"] = { tree = "Warfare", type = "passive", node = "W_R1" },  -- Alias for Piercing (same node ID)
    ["Wanderer"] = { tree = "Craft", type = "passive", node = "C_R6" },  -- Old name for Gifted Rider (same node ID, will be deduplicated)
    ["Mystic Tenacity"] = { tree = "Fitness", type = "passive", node = "F_C1" },  -- FITNESS star, requires Tumbling
}

-- =====================================================
-- HELPER: Get color intensity based on points
-- =====================================================
local function GetColorIntensity(points)
    if points >= 50 then
        return "high"  -- Maxed or near-max
    elseif points >= 30 then
        return "medium-high"
    elseif points >= 15 then
        return "medium"
    else
        return "low"
    end
end

-- =====================================================
-- HELPER: Get visual point indicator
-- =====================================================
local function GetPointIndicator(points, maxPoints)
    maxPoints = maxPoints or 50
    local percentage = (points / maxPoints) * 100
    
    if percentage >= 100 then
        return "⭐"  -- Maxed
    elseif percentage >= 75 then
        return "●●●"  -- High
    elseif percentage >= 50 then
        return "●●○"  -- Medium-High
    elseif percentage >= 25 then
        return "●○○"  -- Medium
    else
        return "○○○"  -- Low
    end
end

-- =====================================================
-- HELPER: Determine max points for a star
-- =====================================================
local function GetMaxPoints(skillName)
    -- Common max values based on star names
    local maxMap = {
        ["Master Gatherer"] = 75,
        ["Boundless Vitality"] = 50,
        ["Rejuvenation"] = 50,
        ["War Mount"] = 120,
        ["Gifted Rider"] = 100,
        ["Wanderer"] = 100,
        ["Salvation"] = 75,
        ["Bloody Renewal"] = 75,
        ["Unassailable"] = 75,
        ["Deadly Precision"] = 75,
        ["Rationer"] = 75,
    }
    return maxMap[skillName] or 50  -- Default to 50
end

-- =====================================================
-- HELPER: Generate node definition
-- =====================================================
local function GenerateNode(skill, starData)
    local nodeId = starData.node
    local skillName = skill.name
    local points = skill.points
    
    -- Node shape based on type
    local prefix, suffix
    if starData.type == "slottable" then
        prefix = "[["
        suffix = "]]"
    elseif starData.type == "base" then
        prefix = "("
        suffix = ")"
    else  -- passive
        prefix = "("
        suffix = ")"
    end
    
    -- Build node label with points
    local label = string.format("%s%s\\n%d pts%s", prefix, skillName, points, suffix)
    
    return string.format("    %s%s", nodeId, label)
end

-- =====================================================
-- HELPER: Get tree color with complementary pale palette
-- =====================================================
local function GetTreeColor(tree, intensity)
    -- Complementary color scheme with pale, harmonious backgrounds
    -- Craft: Soft sage/teal greens (complementary to coral)
    -- Warfare: Soft periwinkle/lavender blues (complementary to peach)
    -- Fitness: Soft coral/peach (complementary to teal)
    local colors = {
        Craft = {
            high = "#7fb3a8",        -- Soft teal (maxed) - deeper but still pale
            ["medium-high"] = "#9fc5bb",  -- Medium teal
            medium = "#b8d4cc",      -- Light teal
            low = "#d4e8e1"          -- Very pale sage green
        },
        Warfare = {
            high = "#8b9dc3",        -- Soft periwinkle (maxed) - deeper but still pale
            ["medium-high"] = "#a5b3d1",  -- Medium periwinkle
            medium = "#bfc9df",      -- Light periwinkle
            low = "#d9dfed"          -- Very pale lavender blue
        },
        Fitness = {
            high = "#d4a5a5",        -- Soft coral (maxed) - deeper but still pale
            ["medium-high"] = "#e0b8b8",  -- Medium coral
            medium = "#eccbcb",      -- Light coral
            low = "#f8dede"          -- Very pale peach
        }
    }
    
    return colors[tree] and colors[tree][intensity] or "#e8e8e8"  -- Neutral pale gray fallback
end

-- =====================================================
-- HELPER: Get strong node color (for individual stars)
-- =====================================================
local function GetStrongNodeColor(tree)
    -- Stronger, more saturated colors for individual nodes
    local strongColors = {
        Craft = "#4a9d7f",      -- Strong teal/green
        Warfare = "#5b7fb8",    -- Strong periwinkle/blue
        Fitness = "#b87a7a"     -- Strong coral/rose
    }
    
    return strongColors[tree] or "#888888"  -- Neutral gray fallback
end

-- =====================================================
-- HELPER: Get subgraph background color
-- =====================================================
local function GetSubgraphBackgroundColor(tree)
    -- Transparent backgrounds for subgraph containers
    -- This allows the diagram to blend with any background (GitHub, VS Code, Discord, etc.)
    return "transparent"
end

-- =====================================================
-- HELPER: Get enhanced node shape based on points and star type
-- =====================================================
local function GetNodeShape(starData, points, maxPoints)
    maxPoints = maxPoints or 50  -- Default to 50 if not provided
    local isMaxed = points >= maxPoints
    
    -- Shape is determined by star type to ensure consistency
    -- Slottables: squares, Passives: circles, Base: hexagons
    if starData.type == "slottable" then
        if isMaxed then
            return "[[", "]]"  -- Maxed slottable - double square brackets
        else
            return "[", "]"    -- Partial slottable - single square brackets
        end
    elseif starData.type == "base" then
        return "{", "}"        -- Base stars - hexagon (curly braces)
    else
        -- Passive stars - always use circles for consistency
        return "(", ")"       -- Passive (maxed or partial) - circle (parentheses)
    end
end

-- =====================================================
-- MAIN: Generate Champion Points Diagram
-- =====================================================
local function GenerateChampionDiagram(cpData)
    CM.DebugPrint("CHAMPION_DIAGRAM", "GenerateChampionDiagram called")
    if not cpData or not cpData.disciplines or #cpData.disciplines == 0 then
        CM.DebugPrint("CHAMPION_DIAGRAM", "No CP data or disciplines, returning empty")
        return ""
    end
    
    CM.DebugPrint("CHAMPION_DIAGRAM", string.format("Processing %d disciplines", #cpData.disciplines))
    local markdown = "## 🎯 Champion Points Visual\n\n"
    
    -- Organize skills by tree and type
    local treeSkills = {
        Craft = { slottable = {}, passive = {}, base = {} },
        Warfare = { slottable = {}, passive = {}, base = {} },
        Fitness = { slottable = {}, passive = {}, base = {} }
    }
    
    -- Track total points per constellation (564 max per constellation)
    local treePoints = {
        Craft = 0,
        Warfare = 0,
        Fitness = 0
    }
    
    -- Map skills to trees and organize by type
    for _, discipline in ipairs(cpData.disciplines) do
        CM.DebugPrint("CHAMPION_DIAGRAM", string.format("Processing discipline: %s", discipline.name or "Unknown"))
        -- Check allStars first (most complete), then fall back to slottableSkills + passiveSkills
        local skillsToProcess = {}
        if discipline.allStars and #discipline.allStars > 0 then
            CM.DebugPrint("CHAMPION_DIAGRAM", string.format("Using allStars: %d skills", #discipline.allStars))
            skillsToProcess = discipline.allStars
        elseif discipline.slottableSkills or discipline.passiveSkills then
            -- Combine slottable and passive skills
            if discipline.slottableSkills then
                CM.DebugPrint("CHAMPION_DIAGRAM", string.format("Adding %d slottable skills", #discipline.slottableSkills))
                for _, skill in ipairs(discipline.slottableSkills) do
                    table.insert(skillsToProcess, skill)
                end
            end
            if discipline.passiveSkills then
                CM.DebugPrint("CHAMPION_DIAGRAM", string.format("Adding %d passive skills", #discipline.passiveSkills))
                for _, skill in ipairs(discipline.passiveSkills) do
                    table.insert(skillsToProcess, skill)
                end
            end
        else
            CM.DebugPrint("CHAMPION_DIAGRAM", "No skills found in discipline")
        end
        
        for _, skill in ipairs(skillsToProcess) do
            -- Only include skills with points invested (for diagram clarity)
            local points = skill.points or 0
            if points > 0 then
                local starData = STAR_MAP[skill.name]
                if not starData then
                    -- Fallback for unmapped stars
                    CM.DebugPrint("CP", string_format("Star '%s' not in STAR_MAP, using default mapping", skill.name))
                    starData = {
                        tree = discipline.name,  -- Use discipline name as fallback
                        type = "passive",  -- Default to passive
                        node = string.format("%s_%s", discipline.name:sub(1,1), skill.name:gsub(" ", "_"))
                    }
                end
                
                if starData then
                    local tree = starData.tree
                    if not treeSkills[tree] then
                        treeSkills[tree] = { slottable = {}, passive = {}, base = {} }
                    end
                    
                    -- Categorize by type
                    local category = starData.type
                    if category == "slottable" or category == "passive" or category == "base" then
                        table.insert(treeSkills[tree][category], {
                            skill = skill,
                            starData = starData
                        })
                        treePoints[tree] = treePoints[tree] + points
                    end
                end
            end
        end
    end
    
    -- Deduplicate skills by node ID within each category (in case aliases like "Wanderer" and "Gifted Rider" both appear)
    -- Keep the one with more points, or the first one if points are equal
    for treeName, categories in pairs(treeSkills) do
        for categoryName, skills in pairs(categories) do
            local nodeIdMap = {}
            local deduplicated = {}
            
            for _, entry in ipairs(skills) do
                local nodeId = entry.starData.node
                if not nodeIdMap[nodeId] then
                    -- First occurrence of this node ID
                    nodeIdMap[nodeId] = entry
                    table.insert(deduplicated, entry)
                else
                    -- Duplicate node ID - keep the one with more points
                    local existing = nodeIdMap[nodeId]
                    if entry.skill.points > existing.skill.points then
                        -- Replace with the one that has more points
                        for i, dedupEntry in ipairs(deduplicated) do
                            if dedupEntry.starData.node == nodeId then
                                deduplicated[i] = entry
                                nodeIdMap[nodeId] = entry
                                break
                            end
                        end
                        CM.DebugPrint("CHAMPION_DIAGRAM", string.format("Deduplicated node %s: kept %s (%d pts) over %s (%d pts)", 
                            nodeId, entry.skill.name, entry.skill.points, existing.skill.name, existing.skill.points))
                    else
                        CM.DebugPrint("CHAMPION_DIAGRAM", string.format("Deduplicated node %s: kept %s (%d pts) over %s (%d pts)", 
                            nodeId, existing.skill.name, existing.skill.points, entry.skill.name, entry.skill.points))
                    end
                end
            end
            
            -- Sort by points (highest first) for better visual hierarchy
            table.sort(deduplicated, function(a, b)
                return a.skill.points > b.skill.points
            end)
            
            treeSkills[treeName][categoryName] = deduplicated
        end
    end
    
    -- Count total skills for diagram
    local totalSkillsInDiagram = 0
    for treeName, categories in pairs(treeSkills) do
        for categoryName, skills in pairs(categories) do
            totalSkillsInDiagram = totalSkillsInDiagram + #skills
            CM.DebugPrint("CHAMPION_DIAGRAM", string.format("Tree %s - %s: %d skills", treeName, categoryName, #skills))
        end
    end
    
    CM.DebugPrint("CHAMPION_DIAGRAM", string.format("Total skills in diagram: %d", totalSkillsInDiagram))
    
    if totalSkillsInDiagram == 0 then
        CM.DebugPrint("CHAMPION_DIAGRAM", "No skills with points found, returning empty diagram")
        return markdown .. "*No invested Champion Points to visualize*\n\n"
    end
    
    -- Generate diagram with new cleaner format
    markdown = markdown .. "```mermaid\n"
    markdown = markdown .. "%%{init: {'theme':'base', 'themeVariables': { 'background':'transparent','fontSize':'14px','primaryColor':'#e8f4f0','primaryTextColor':'#000','primaryBorderColor':'#4a9d7f','lineColor':'#999','secondaryColor':'#f0f4f8','tertiaryColor':'#faf0f0'}}}%%\n\n"
    markdown = markdown .. "graph LR\n"
    markdown = markdown .. "  %%%% Champion Point Investment Visualization\n"
    markdown = markdown .. "  %%%% Enhanced readability with clear visual hierarchy\n\n"
    
    -- Build discipline map for easy lookup
    local disciplineMap = {}
    for _, discipline in ipairs(cpData.disciplines) do
        if discipline.name then
            disciplineMap[discipline.name] = discipline
        end
    end
    
    -- Generate nodes for each tree
    local treeOrder = {"Craft", "Warfare", "Fitness"}  -- Ensure consistent order
    local MAX_POINTS_PER_CONSTELLATION = 564
    local available = cpData.available or 0
    
    for _, treeName in ipairs(treeOrder) do
        local categories = treeSkills[treeName]
        local discipline = disciplineMap[treeName]
        
        -- Count skills in this tree
        local skillCount = 0
        for _, skills in pairs(categories) do
            skillCount = skillCount + #skills
        end
        
        if skillCount > 0 then
            local treeEmoji = {
                Craft = "⚒️",
                Warfare = "⚔️",
                Fitness = "💪"
            }
            
            local treeIcon = treeEmoji[treeName] or ""
            local pointsInvested = treePoints[treeName]
            
            markdown = markdown .. "  %%%% ========================================\n"
            markdown = markdown .. string.format("  %%%% %s %s CONSTELLATION (%d/%d pts)\n", 
                treeIcon, treeName:upper(), pointsInvested, MAX_POINTS_PER_CONSTELLATION)
            markdown = markdown .. "  %%%% ========================================\n\n"
            
            -- Mermaid subgraph with simplified title
            markdown = markdown .. string.format("  subgraph %s [\"%s %s CONSTELLATION\"]\n", 
                treeName:upper(), treeIcon, treeName:upper())
            markdown = markdown .. "    direction TB\n    \n"
            
            -- Generate category title nodes and skill nodes
            local categoryOrder = {"slottable", "passive", "base"}
            local categoryTitles = {
                slottable = "<b>Slottable Stars</b>",
                passive = "<b>Passive Stars</b>",
                base = "<b>Independent Stars</b>"
            }
            local nodeSuffix = {
                slottable = "_TITLE",
                passive = "_PASS",
                base = "_BASE"
            }
            local titleNodeIds = {}
            local skillNodeIds = {}
            
            for _, category in ipairs(categoryOrder) do
                local skills = categories[category]
                if #skills > 0 then
                    -- Create title node
                    local titleNodeId = string.format("%s%s", treeName:upper(), nodeSuffix[category])
                    markdown = markdown .. string.format("    %s[\"%s\"]\n", 
                        titleNodeId, categoryTitles[category])
                    table.insert(titleNodeIds, titleNodeId)
                    skillNodeIds[titleNodeId] = {}
                    
                    -- Create skill nodes
                    for _, entry in ipairs(skills) do
                        local skill = entry.skill
                        local starData = entry.starData
                        local nodeId = starData.node
                        local points = skill.points
                        local maxPoints = GetMaxPoints(skill.name)
                        local indicator = GetPointIndicator(points, maxPoints)
                        local percentage = math.floor((points / maxPoints) * 100)
                        
                        -- Determine if maxed
                        local isMaxed = points >= maxPoints
                        local maxedText = isMaxed and " | MAXED" or string.format(" | %s %d%%", indicator, percentage)
                        
                        -- Build label with HTML line break
                        local label = string.format("%s%s<br/><b>%d/%d pts</b>%s", 
                            isMaxed and "⭐ " or "", 
                            skill.name, 
                            points, 
                            maxPoints,
                            maxedText)
                        
                        -- Use square brackets for all nodes (consistent shape)
                        markdown = markdown .. string.format("    %s[\"%s\"]\n", nodeId, label)
                        table.insert(skillNodeIds[titleNodeId], nodeId)
                    end
                    markdown = markdown .. "    \n"
                end
            end
            
            -- Add available points node
            markdown = markdown .. string.format("    %s_AVAIL[\"💎 <b>%d points available</b>\"]\n", 
                treeName:upper(), available)
            markdown = markdown .. "    \n"
            
            -- Create connections from title nodes to skill nodes (dashed arrows for visual organization)
            for _, titleNodeId in ipairs(titleNodeIds) do
                local skillIds = skillNodeIds[titleNodeId]
                if #skillIds > 0 then
                    markdown = markdown .. string.format("    %s -.-> %s", 
                        titleNodeId, table.concat(skillIds, " & "))
                    markdown = markdown .. "\n"
                end
            end
            
            -- Add title node styles
            -- Using transparent backgrounds for title nodes to blend with any environment
            -- Bright text colors for visibility against transparent backgrounds
            local titleBgColor = {
                Craft = "transparent",
                Warfare = "transparent",
                Fitness = "transparent"
            }
            local titleTextColor = {
                Craft = "#4a9d7f",   -- Bright teal (matches craft theme)
                Warfare = "#5b7fb8",  -- Bright blue (matches warfare theme)
                Fitness = "#b87a7a"   -- Bright coral (matches fitness theme)
            }
            
            markdown = markdown .. "\n"
            for _, titleNodeId in ipairs(titleNodeIds) do
                markdown = markdown .. string.format("    style %s fill:%s,stroke:none,color:%s\n", 
                    titleNodeId, titleBgColor[treeName], titleTextColor[treeName])
            end
            
            -- Add skill node styles
            local nodeColor = GetStrongNodeColor(treeName)
            for _, category in ipairs(categoryOrder) do
                local skills = categories[category]
                for _, entry in ipairs(skills) do
                    local skill = entry.skill
                    local starData = entry.starData
                    local nodeId = starData.node
                    local points = skill.points
                    local maxPoints = GetMaxPoints(skill.name)
                    local isMaxed = points >= maxPoints
                    
                    -- Determine stroke based on type and completion
                    local strokeWidth = "2px"
                    local strokeColor = nodeColor
                    
                    if category == "slottable" then
                        strokeWidth = isMaxed and "4px" or "3px"
                        strokeColor = isMaxed and "#ffd700" or nodeColor
                    elseif category == "base" then
                        strokeWidth = "3px"
                        strokeColor = "#ff8c00"
                    end
                    
                    markdown = markdown .. string.format("    style %s fill:%s,stroke:%s,stroke-width:%s,color:#fff\n", 
                        nodeId, nodeColor, strokeColor, strokeWidth)
                end
            end
            
            -- Style the available points node with subtle background
            local availBgColor = {
                Craft = "#d4e8df",
                Warfare = "#d4e4f0",
                Fitness = "#f0d4d4"
            }
            markdown = markdown .. string.format("    style %s_AVAIL fill:%s,stroke:%s,stroke-width:2px,stroke-dasharray:5 5,color:%s\n", 
                treeName:upper(), availBgColor[treeName], nodeColor, titleTextColor[treeName])
            
            markdown = markdown .. "\n  end\n"
            
            -- Add subgraph background styling
            local subgraphBgColor = GetSubgraphBackgroundColor(treeName)
            markdown = markdown .. string.format("  style %s fill:%s,stroke:%s,stroke-width:3px\n\n", 
                treeName:upper(), subgraphBgColor, nodeColor)
        end
    end
    
    -- Add simplified legend matching the example format
    markdown = markdown .. "  %%%% ========================================\n"
    markdown = markdown .. "  %%%% LEGEND\n"
    markdown = markdown .. "  %%%% ========================================\n\n"
    
    -- Parent legend subgraph
    markdown = markdown .. "  subgraph LEGEND [\"📖 LEGEND & VISUAL GUIDE\"]\n"
    markdown = markdown .. "    direction TB\n    \n"
    
    -- Star Types subsection
    markdown = markdown .. "    LEG_STARS[\"<b>Star Types</b>\"]\n"
    markdown = markdown .. "    LEG_S1[\"⭐ Gold Border = Maxed Slottable\"]\n"
    markdown = markdown .. "    LEG_S2[\"🔶 Orange Border = Independent Star\"]\n"
    markdown = markdown .. "    LEG_S3[\"Standard Border = In Progress\"]\n"
    markdown = markdown .. "    \n"
    
    -- Progress Indicators subsection
    markdown = markdown .. "    LEG_FILL[\"<b>Progress Indicators</b>\"]\n"
    markdown = markdown .. "    LEG_F1[\"⭐ = 100% Maxed\"]\n"
    markdown = markdown .. "    LEG_F2[\"●●● = 75-99%\"]\n"
    markdown = markdown .. "    LEG_F3[\"●●○ = 50-74%\"]\n"
    markdown = markdown .. "    LEG_F4[\"●○○ = 25-49%\"]\n"
    markdown = markdown .. "    LEG_F5[\"○○○ = 1-24%\"]\n"
    markdown = markdown .. "    \n"
    
    -- Connections for visual organization
    markdown = markdown .. "    LEG_STARS -.-> LEG_S1 & LEG_S2 & LEG_S3\n"
    markdown = markdown .. "    LEG_FILL -.-> LEG_F1 & LEG_F2 & LEG_F3 & LEG_F4 & LEG_F5\n\n"
    
    -- Styling for legend elements
    -- Title nodes are transparent with bright text, example nodes have fills with dark text
    markdown = markdown .. "    style LEG_STARS fill:transparent,stroke:none,color:#ccc\n"
    markdown = markdown .. "    style LEG_FILL fill:transparent,stroke:none,color:#ccc\n"
    markdown = markdown .. "    style LEG_S1 fill:#fff,stroke:#ffd700,stroke-width:3px,color:#333\n"
    markdown = markdown .. "    style LEG_S2 fill:#fff,stroke:#ff8c00,stroke-width:3px,color:#333\n"
    markdown = markdown .. "    style LEG_S3 fill:#fff,stroke:#999,stroke-width:2px,color:#333\n"
    markdown = markdown .. "    style LEG_F1 fill:#eee,stroke:#333,stroke-width:1px,color:#333\n"
    markdown = markdown .. "    style LEG_F2 fill:#eee,stroke:#333,stroke-width:1px,color:#333\n"
    markdown = markdown .. "    style LEG_F3 fill:#eee,stroke:#333,stroke-width:1px,color:#333\n"
    markdown = markdown .. "    style LEG_F4 fill:#eee,stroke:#333,stroke-width:1px,color:#333\n"
    markdown = markdown .. "    style LEG_F5 fill:#eee,stroke:#333,stroke-width:1px,color:#333\n"
    
    -- Close legend subgraph
    markdown = markdown .. "  end\n"
    markdown = markdown .. "  style LEGEND fill:transparent,stroke:#999,stroke-width:3px\n"
    
    markdown = markdown .. "```\n\n"
    
    return markdown
end

CM.generators.sections.GenerateChampionDiagram = GenerateChampionDiagram

