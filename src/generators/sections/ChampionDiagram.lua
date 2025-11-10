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
-- HELPER: Get pale subgraph background color
-- =====================================================
local function GetSubgraphBackgroundColor(tree)
    -- Very pale background colors for subgraph containers
    local paleColors = {
        Craft = "#e8f4f0",      -- Very pale sage/teal
        Warfare = "#f0f4f8",    -- Very pale periwinkle/lavender
        Fitness = "#faf0f0"     -- Very pale coral/peach
    }
    
    return paleColors[tree] or "#f5f5f5"  -- Neutral pale gray fallback
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
    
    -- Organize skills by tree
    local treeSkills = {
        Craft = {},
        Warfare = {},
        Fitness = {}
    }
    
    -- Map skills to trees
    -- Use allStars which contains all skills (including 0 points) for complete diagram
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
                        treeSkills[tree] = {}
                    end
                    table.insert(treeSkills[tree], {
                        skill = skill,
                        starData = starData
                    })
                end
            end
        end
    end
    
    -- Deduplicate skills by node ID (in case aliases like "Wanderer" and "Gifted Rider" both appear)
    -- Keep the one with more points, or the first one if points are equal
    for treeName, skills in pairs(treeSkills) do
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
        
        treeSkills[treeName] = deduplicated
    end
    
    -- Sort skills by points (highest first) for better visual hierarchy
    local totalSkillsInDiagram = 0
    for treeName, skills in pairs(treeSkills) do
        totalSkillsInDiagram = totalSkillsInDiagram + #skills
        CM.DebugPrint("CHAMPION_DIAGRAM", string.format("Tree %s: %d skills (after deduplication)", treeName, #skills))
        table.sort(skills, function(a, b)
            return a.skill.points > b.skill.points
        end)
    end
    
    CM.DebugPrint("CHAMPION_DIAGRAM", string.format("Total skills in diagram: %d", totalSkillsInDiagram))
    
    if totalSkillsInDiagram == 0 then
        CM.DebugPrint("CHAMPION_DIAGRAM", "No skills with points found, returning empty diagram")
        return markdown .. "*No invested Champion Points to visualize*\n\n"
    end
    
    -- Generate diagram
    markdown = markdown .. "```mermaid\n"
    markdown = markdown .. "graph TB\n"  -- Changed to TB (Top-Bottom) for better vertical flow
    markdown = markdown .. "  %% 🎯 Your Champion Point Investment\n"
    markdown = markdown .. "  %% Color intensity shows investment level\n"
    markdown = markdown .. "  %% Shapes indicate star types\n\n"
    
    -- Build discipline map for easy lookup
    local disciplineMap = {}
    for _, discipline in ipairs(cpData.disciplines) do
        if discipline.name then
            disciplineMap[discipline.name] = discipline
        end
    end
    
    -- Generate nodes for each tree
    local treeOrder = {"Craft", "Warfare", "Fitness"}  -- Ensure consistent order
    for _, treeName in ipairs(treeOrder) do
        local skills = treeSkills[treeName]
        local discipline = disciplineMap[treeName]
        
        if skills and #skills > 0 then
            local treeEmoji = {
                Craft = "⚒️",
                Warfare = "⚔️",
                Fitness = "💪"
            }
            
            local treeIcon = treeEmoji[treeName] or ""
            
            markdown = markdown .. "  %% ========================================\n"
            markdown = markdown .. "  %% " .. treeIcon .. " " .. treeName:upper() .. " CONSTELLATION\n"
            markdown = markdown .. "  %% ========================================\n\n"
            
            -- Mermaid subgraph syntax: subgraph id [label text] (no quotes, but emojis work)
            markdown = markdown .. string.format("  subgraph %s [%s %s Constellation]\n", 
                treeName:upper(), treeIcon, treeName)
            markdown = markdown .. "    direction LR\n\n"  -- Horizontal layout within tree
            
            -- Generate nodes with enhanced visuals
            for _, entry in ipairs(skills) do
                local skill = entry.skill
                local starData = entry.starData
                local nodeId = starData.node
                local points = skill.points
                local maxPoints = GetMaxPoints(skill.name)
                local indicator = GetPointIndicator(points, maxPoints)
                
                -- Get enhanced node shape (consistent with star type)
                local prefix, suffix = GetNodeShape(starData, points, maxPoints)
                
                -- Build label with indicator (single line - line breaks not supported reliably in Mermaid)
                local label = string.format("%s %s %d/%d pts", 
                    indicator, skill.name, points, maxPoints)
                
                markdown = markdown .. string.format("    %s%s%s%s\n", 
                    nodeId, prefix, label, suffix)
            end
            
            -- Add unassigned points node for this discipline
            if discipline then
                local available = cpData.available or 0
                local unassignedNodeId = string.format("%s_UNAVAIL", treeName:upper())
                
                -- Create a special node showing unassigned points (shared pool)
                if available > 0 then
                    -- Single line label (no quotes needed in Mermaid)
                    markdown = markdown .. string.format("    %s([💎 Unassigned: %d available])\n", 
                        unassignedNodeId, available)
                end
            end
            
            markdown = markdown .. "\n"
            
            -- Generate enhanced styles with better borders
            for _, entry in ipairs(skills) do
                local skill = entry.skill
                local starData = entry.starData
                local nodeId = starData.node
                local points = skill.points
                local maxPoints = GetMaxPoints(skill.name)
                local isMaxed = points >= maxPoints
                
                -- Use strong node color instead of intensity-based color
                local color = GetStrongNodeColor(treeName)
                
                -- Enhanced styling with better borders
                local strokeWidth = "2px"
                local strokeColor = "#333"
                
                if starData.type == "slottable" then
                    strokeWidth = "3px"
                    strokeColor = isMaxed and "#ffd700" or "#666"  -- Gold border for maxed slottable
                elseif starData.type == "base" then
                    strokeColor = "#ff8c00"  -- Orange border for base stars
                    strokeWidth = "2.5px"
                end
                
                -- Add text styling
                markdown = markdown .. string.format("    style %s fill:%s,stroke:%s,stroke-width:%s,color:#000\n", 
                    nodeId, color, strokeColor, strokeWidth)
            end
            
            -- Style the unassigned points node
            if discipline then
                local available = cpData.available or 0
                if available > 0 then
                    local unassignedNodeId = string.format("%s_UNAVAIL", treeName:upper())
                    local unassignedColor = GetStrongNodeColor(treeName)
                    -- Use a dashed border style to distinguish it as available points
                    markdown = markdown .. string.format("    style %s fill:%s,stroke:#999,stroke-width:2px,stroke-dasharray:5 5,color:#000\n", 
                        unassignedNodeId, unassignedColor)
                end
            end
            
            markdown = markdown .. "  end\n"
            
            -- Add subgraph background color styling (outside subgraph, after closing)
            local subgraphBgColor = GetSubgraphBackgroundColor(treeName)
            markdown = markdown .. string.format("  style %s fill:%s,stroke:#ddd,stroke-width:2px\n\n", 
                treeName:upper(), subgraphBgColor)
        end
    end
    
    -- Add prerequisite connections using pathfinder data
    -- Discover cluster relationships and add edges
    markdown = markdown .. "  %% ========================================\n"
    markdown = markdown .. "  %% PREREQUISITE CONNECTIONS\n"
    markdown = markdown .. "  %% ========================================\n\n"
    
    -- Build skill ID to node ID mapping
    local skillIdToNode = {}
    for _, discipline in ipairs(cpData.disciplines) do
        if discipline.allStars then
            for _, star in ipairs(discipline.allStars) do
                if star.skillId and star.points and star.points > 0 then
                    local starData = STAR_MAP[star.name]
                    if starData then
                        skillIdToNode[star.skillId] = starData.node
                    end
                end
            end
        end
    end
    
    -- Discover cluster relationships and add edges
    local edgesAdded = {}
    local edgesList = {}  -- Track edges in order for linkStyle
    local edgeIndex = 0   -- Track edge index for linkStyle (0-based)
    local disciplineIndexMap = {
        ["Craft"] = 1,
        ["Warfare"] = 2,
        ["Fitness"] = 3
    }
    
    for _, discipline in ipairs(cpData.disciplines) do
        local disciplineIndex = disciplineIndexMap[discipline.name]
        if disciplineIndex and discipline.allStars then
            -- Find cluster roots and their relationships
            for _, star in ipairs(discipline.allStars) do
                if star.skillId then
                    local successRoot, isRoot = pcall(IsChampionSkillClusterRoot, star.skillId)
                    if successRoot and isRoot then
                        -- Get all skills in this cluster
                        local successCluster, clusterSkills = pcall(function()
                            return {GetChampionClusterSkillIds(star.skillId)}
                        end)
                        
                        if successCluster and clusterSkills then
                            local rootNode = skillIdToNode[star.skillId]
                            if rootNode then
                                -- Connect cluster members to root (prerequisite relationship)
                                -- Root is the prerequisite, cluster members are dependents
                                -- Arrow direction: dependent -> prerequisite (e.g., SBS -> MT)
                                for _, clusterSkillId in ipairs(clusterSkills) do
                                    if clusterSkillId ~= star.skillId then
                                        local clusterNode = skillIdToNode[clusterSkillId]
                                        if clusterNode then
                                            -- For prerequisites, arrow goes from dependent to prerequisite
                                            -- So: clusterNode (dependent) -> rootNode (prerequisite)
                                            local edgeKey = clusterNode .. "->" .. rootNode
                                            if not edgesAdded[edgeKey] then
                                                -- Test if cluster skill is unlocked to determine edge style
                                                local successUnlock, isUnlocked = pcall(WouldChampionSkillNodeBeUnlocked, clusterSkillId, 0)
                                                -- Use edge style without labels (labels with pipes cause parse errors in some Mermaid versions)
                                                if successUnlock and isUnlocked then
                                                    markdown = markdown .. string_format("  %s --> %s\n", 
                                                        clusterNode, rootNode)
                                                    table.insert(edgesList, {type = "solid", index = edgeIndex})
                                                    edgeIndex = edgeIndex + 1
                                                else
                                                    markdown = markdown .. string_format("  %s -.-> %s\n", 
                                                        clusterNode, rootNode)
                                                    table.insert(edgesList, {type = "dashed", index = edgeIndex})
                                                    edgeIndex = edgeIndex + 1
                                                end
                                                edgesAdded[edgeKey] = true
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            -- Discover prerequisite relationships beyond clusters
            -- Check for direct prerequisites (e.g., Tumbling -> Mystic Tenacity)
            -- Strategy: For each skill with points, check if other skills in same branch/branch are prerequisites
            for _, star1 in ipairs(discipline.allStars) do
                if star1.skillId and star1.points and star1.points > 0 then
                    local node1 = skillIdToNode[star1.skillId]
                    local star1Data = STAR_MAP[star1.name]
                    if node1 and star1Data then
                        for _, star2 in ipairs(discipline.allStars) do
                            if star2.skillId and star2.skillId ~= star1.skillId and star2.points and star2.points > 0 then
                                local node2 = skillIdToNode[star2.skillId]
                                local star2Data = STAR_MAP[star2.name]
                                if node2 and star2Data and star1Data.tree == star2Data.tree then
                                    -- Both stars are in the same constellation
                                    -- Check if star1 is a prerequisite for star2
                                    -- Heuristic 1: If star1 is a base star and star2 is not, star1 might be prerequisite
                                    if star1Data.type == "base" and star2Data.type ~= "base" then
                                        local edgeKey = node2 .. "->" .. node1
                                        if not edgesAdded[edgeKey] then
                                            markdown = markdown .. string_format("  %s -.-> %s\n", 
                                                node2, node1)
                                            table.insert(edgesList, {type = "dashed", index = edgeIndex})
                                            edgeIndex = edgeIndex + 1
                                            edgesAdded[edgeKey] = true
                                        end
                                    -- Heuristic 2: Check if they're in the same branch and star1 comes before star2
                                    elseif star1Data.node and star2Data.node then
                                        -- Extract branch and number from node IDs (e.g., F_L1, F_L2, F_C1, F_C2)
                                        local branch1 = star1Data.node:match("^([A-Z]_[A-Z])")
                                        local branch2 = star2Data.node:match("^([A-Z]_[A-Z])")
                                        if branch1 and branch2 then
                                            if branch1 == branch2 then
                                                -- Same branch - check if star1 comes before star2 numerically
                                                local num1 = tonumber(star1Data.node:match("%d+"))
                                                local num2 = tonumber(star2Data.node:match("%d+"))
                                                if num1 and num2 and num1 < num2 then
                                                    -- star1 is earlier in the branch, so it might be a prerequisite
                                                    local edgeKey = node2 .. "->" .. node1
                                                    if not edgesAdded[edgeKey] then
                                                        markdown = markdown .. string_format("  %s -.-> %s\n", 
                                                            node2, node1)
                                                        edgesAdded[edgeKey] = true
                                                    end
                                                end
                                            else
                                                -- Different branches - check for cross-branch prerequisites
                                                -- Common pattern: Left branch (L) often prerequisites Center branch (C)
                                                -- Extract branch letters (L, C, R, BASE, IND, etc.)
                                                local branchLetter1 = star1Data.node:match("_[A-Z]+") or ""
                                                local branchLetter2 = star2Data.node:match("_[A-Z]+") or ""
                                                local num1 = tonumber(star1Data.node:match("%d+"))
                                                local num2 = tonumber(star2Data.node:match("%d+"))
                                                
                                                -- Check if star1 is in Left branch (L) and star2 is in Center branch (C)
                                                -- This is a common prerequisite pattern (e.g., Tumbling F_L1 -> Mystic Tenacity F_C1)
                                                if branchLetter1:match("_L") and branchLetter2:match("_C") and num1 and num2 then
                                                    -- Left branch skill might be prerequisite for Center branch skill
                                                    local edgeKey = node2 .. "->" .. node1
                                                    if not edgesAdded[edgeKey] then
                                                        markdown = markdown .. string_format("  %s -.-> %s\n", 
                                                            node2, node1)
                                                        edgesAdded[edgeKey] = true
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            -- Also check for cluster relationships between skills with points
            for _, star1 in ipairs(discipline.allStars) do
                if star1.skillId and star1.points and star1.points > 0 then
                    local node1 = skillIdToNode[star1.skillId]
                    if node1 then
                        for _, star2 in ipairs(discipline.allStars) do
                            if star2.skillId and star2.skillId ~= star1.skillId and star2.points and star2.points > 0 then
                                local node2 = skillIdToNode[star2.skillId]
                                if node2 then
                                    -- Check if they're in a cluster relationship
                                    local successUnlock1, isUnlocked1 = pcall(WouldChampionSkillNodeBeUnlocked, star1.skillId, 0)
                                    local successUnlock2, isUnlocked2 = pcall(WouldChampionSkillNodeBeUnlocked, star2.skillId, 0)
                                    
                                    if successUnlock1 and successUnlock2 and isUnlocked1 and isUnlocked2 then
                                        -- Both are unlocked - check if they're in a cluster relationship
                                        local successRoot1, isRoot1 = pcall(IsChampionSkillClusterRoot, star1.skillId)
                                        if successRoot1 and isRoot1 then
                                            local successCluster, clusterSkills = pcall(function()
                                                return {GetChampionClusterSkillIds(star1.skillId)}
                                            end)
                                            if successCluster and clusterSkills then
                                                for _, clusterSkillId in ipairs(clusterSkills) do
                                                    if clusterSkillId == star2.skillId then
                                                        -- star2 is in star1's cluster, so star2 depends on star1
                                                        -- Arrow: star2 -> star1 (star2 requires star1)
                                                        local edgeKey = node2 .. "->" .. node1
                                                        if not edgesAdded[edgeKey] then
                                                            markdown = markdown .. string_format("  %s -.-> %s\n", 
                                                                node2, node1)
                                                            table.insert(edgesList, {type = "dashed", index = edgeIndex})
                                                            edgeIndex = edgeIndex + 1
                                                            edgesAdded[edgeKey] = true
                                                        end
                                                        break
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
            -- Note: Additional prerequisite relationships beyond clusters would require
            -- more sophisticated pathfinding. The cluster relationships above should cover
            -- most of the visual structure. For detailed unlock paths, use the pathfinder
            -- utility functions directly.
        end
    end
    
    -- Add bold styling to all edges for better visibility
    if #edgesList > 0 then
        markdown = markdown .. "\n  %% ========================================\n"
        markdown = markdown .. "  %% EDGE STYLING (Bold lines for readability)\n"
        markdown = markdown .. "  %% ========================================\n\n"
        for _, edge in ipairs(edgesList) do
            -- Make edges thicker: 3px for solid, 2.5px for dashed
            local strokeWidth = edge.type == "solid" and "3px" or "2.5px"
            markdown = markdown .. string_format("  linkStyle %d stroke-width:%s\n", edge.index, strokeWidth)
        end
    end
    
    markdown = markdown .. "\n"
    
    -- Add enhanced legend with parent subgraph containing three child subgraphs
    markdown = markdown .. "  %% ========================================\n"
    markdown = markdown .. "  %% LEGEND & KEY\n"
    markdown = markdown .. "  %% ========================================\n\n"
    
    -- Parent legend subgraph
    markdown = markdown .. "  subgraph LEGEND [📖 Legend]\n"
    markdown = markdown .. "    direction TB\n\n"
    
    -- Subgraph 1: Maxed Stars
    markdown = markdown .. "    subgraph LEGEND_MAXED [⭐ Maxed Stars]\n"
    markdown = markdown .. "      direction LR\n\n"
    markdown = markdown .. "      LEG_SLOT_CRAFT[[⚒️ Craft: Maxed Slottable]]\n"
    markdown = markdown .. "      LEG_SLOT_WARFARE[[⚔️ Warfare: Maxed Slottable]]\n"
    markdown = markdown .. "      LEG_SLOT_FITNESS[[💪 Fitness: Maxed Slottable]]\n"
    markdown = markdown .. "      LEG_PASS_CRAFT(⚒️ Craft: Maxed Passive)\n"
    markdown = markdown .. "      LEG_PASS_WARFARE(⚔️ Warfare: Maxed Passive)\n"
    markdown = markdown .. "      LEG_PASS_FITNESS(💪 Fitness: Maxed Passive)\n"
    markdown = markdown .. "\n"
    -- Styling for maxed stars
    markdown = markdown .. "      style LEG_SLOT_CRAFT fill:#4a9d7f,stroke:#ffd700,stroke-width:3px,color:#000\n"
    markdown = markdown .. "      style LEG_SLOT_WARFARE fill:#5b7fb8,stroke:#ffd700,stroke-width:3px,color:#000\n"
    markdown = markdown .. "      style LEG_SLOT_FITNESS fill:#b87a7a,stroke:#ffd700,stroke-width:3px,color:#000\n"
    markdown = markdown .. "      style LEG_PASS_CRAFT fill:#4a9d7f,stroke:#333,stroke-width:2px,color:#000\n"
    markdown = markdown .. "      style LEG_PASS_WARFARE fill:#5b7fb8,stroke:#333,stroke-width:2px,color:#000\n"
    markdown = markdown .. "      style LEG_PASS_FITNESS fill:#b87a7a,stroke:#333,stroke-width:2px,color:#000\n"
    markdown = markdown .. "    end\n"
    markdown = markdown .. "    style LEGEND_MAXED fill:#f5f5f5,stroke:#ddd,stroke-width:2px\n\n"
    
    -- Subgraph 2: Independent Stars
    markdown = markdown .. "    subgraph LEGEND_BASE [🔷 Independent Stars]\n"
    markdown = markdown .. "      direction LR\n\n"
    markdown = markdown .. "      LEG_BASE_CRAFT{⚒️ Craft: Independent Star}\n"
    markdown = markdown .. "      LEG_BASE_WARFARE{⚔️ Warfare: Independent Star}\n"
    markdown = markdown .. "      LEG_BASE_FITNESS{💪 Fitness: Independent Star}\n"
    markdown = markdown .. "\n"
    -- Styling for independent stars
    markdown = markdown .. "      style LEG_BASE_CRAFT fill:#4a9d7f,stroke:#ff8c00,stroke-width:2.5px,color:#000\n"
    markdown = markdown .. "      style LEG_BASE_WARFARE fill:#5b7fb8,stroke:#ff8c00,stroke-width:2.5px,color:#000\n"
    markdown = markdown .. "      style LEG_BASE_FITNESS fill:#b87a7a,stroke:#ff8c00,stroke-width:2.5px,color:#000\n"
    markdown = markdown .. "    end\n"
    markdown = markdown .. "    style LEGEND_BASE fill:#f5f5f5,stroke:#ddd,stroke-width:2px\n\n"
    
    -- Subgraph 3: Fraction Indicators
    markdown = markdown .. "    subgraph LEGEND_AMOUNT [📊 Fraction]\n"
    markdown = markdown .. "      direction TB\n\n"
    markdown = markdown .. "      LEG_IND1(⭐ = 100%% Maxed)\n"
    markdown = markdown .. "      LEG_IND2(●●● = 75-99%%)\n"
    markdown = markdown .. "      LEG_IND3(●●○ = 50-74%%)\n"
    markdown = markdown .. "      LEG_IND4(●○○ = 25-49%%)\n"
    markdown = markdown .. "      LEG_IND5(○○○ = 1-24%%)\n"
    markdown = markdown .. "\n"
    -- Styling for fraction indicators (neutral)
    markdown = markdown .. "      style LEG_IND1 fill:#f5f5f5,stroke:#333,stroke-width:1px,color:#000\n"
    markdown = markdown .. "      style LEG_IND2 fill:#f5f5f5,stroke:#333,stroke-width:1px,color:#000\n"
    markdown = markdown .. "      style LEG_IND3 fill:#f5f5f5,stroke:#333,stroke-width:1px,color:#000\n"
    markdown = markdown .. "      style LEG_IND4 fill:#f5f5f5,stroke:#333,stroke-width:1px,color:#000\n"
    markdown = markdown .. "      style LEG_IND5 fill:#f5f5f5,stroke:#333,stroke-width:1px,color:#000\n"
    markdown = markdown .. "    end\n"
    markdown = markdown .. "    style LEGEND_AMOUNT fill:#f5f5f5,stroke:#ddd,stroke-width:2px\n\n"
    
    -- Close parent legend subgraph
    markdown = markdown .. "  end\n"
    markdown = markdown .. "  style LEGEND fill:#fafafa,stroke:#999,stroke-width:2px\n"
    
    markdown = markdown .. "```\n\n"
    
    markdown = markdown .. "**Visual Guide:**\n"
    markdown = markdown .. "- 🎨 **Color Depth** = Investment level (darker = more points)\n"
    markdown = markdown .. "- 🔲 **Node Shape** = Star type and completion status\n"
    markdown = markdown .. "- ⭐ **Gold Border** = Maxed slottable stars (ready for Champion Bar)\n"
    markdown = markdown .. "- 🟠 **Orange Border** = Base/prerequisite stars\n"
    markdown = markdown .. "- 📊 **Points Shown** = Current / Maximum possible\n"
    markdown = markdown .. "- ➡️ **Solid Arrow** = Unlocked connection (cluster relationship)\n"
    markdown = markdown .. "- ⇢ **Dashed Arrow** = Prerequisite path (may unlock)\n\n"
    
    return markdown
end

CM.generators.sections.GenerateChampionDiagram = GenerateChampionDiagram

