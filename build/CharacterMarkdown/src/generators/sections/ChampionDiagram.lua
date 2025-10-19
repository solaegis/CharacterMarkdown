-- CharacterMarkdown - Champion Points Mermaid Diagram Generator
-- Generates personalized CP diagrams showing invested stars

local CM = CharacterMarkdown

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
    
    -- Sub-Constellation: Staving Death
    ["Bastion"] = { tree = "Warfare", type = "slottable", node = "SD1", sub = "Staving Death" },
    ["Bulwark"] = { tree = "Warfare", type = "passive", node = "SD2", sub = "Staving Death" },
    ["Fortified"] = { tree = "Warfare", type = "passive", node = "SD4", sub = "Staving Death" },
    
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
    
    -- Alternative/Old names that might appear
    ["Precision"] = { tree = "Warfare", type = "passive", node = "W_R1" },  -- Alias for Piercing
    ["Wanderer"] = { tree = "Craft", type = "passive", node = "C_R6" },  -- Old name for Gifted Rider
    ["Mystic Tenacity"] = { tree = "Warfare", type = "passive", node = "W_C1" },  -- Alternative name
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
-- HELPER: Get tree color with improved palette
-- =====================================================
local function GetTreeColor(tree, intensity)
    local colors = {
        Craft = {
            high = "#00b359",        -- Rich green (maxed)
            ["medium-high"] = "#00cc66",  -- Bright green
            medium = "#4dd98f",      -- Medium green
            low = "#a6e6c7"          -- Pale green
        },
        Warfare = {
            high = "#0052cc",        -- Deep blue (maxed)
            ["medium-high"] = "#0066ff",  -- Bright blue
            medium = "#4d94ff",      -- Medium blue
            low = "#b3d9ff"          -- Pale blue
        },
        Fitness = {
            high = "#cc0000",        -- Deep red (maxed)
            ["medium-high"] = "#ff1a1a", -- Bright red
            medium = "#ff6666",      -- Medium red
            low = "#ffb3b3"          -- Pale red
        }
    }
    
    return colors[tree] and colors[tree][intensity] or "#cccccc"
end

-- =====================================================
-- HELPER: Get enhanced node shape based on points
-- =====================================================
local function GetNodeShape(starData, points)
    local maxPoints = GetMaxPoints("")  -- Get default max
    local isMaxed = points >= maxPoints
    
    if starData.type == "slottable" then
        if isMaxed then
            return "[[", "]]"  -- Maxed slottable - double square
        else
            return "[", "]"    -- Partial slottable - single square
        end
    elseif starData.type == "base" then
        return "{", "}"        -- Base stars - hexagon
    else
        if isMaxed then
            return "(", ")"    -- Maxed passive - circle
        else
            return "([", "])"  -- Partial passive - stadium shape
        end
    end
end

-- =====================================================
-- MAIN: Generate Champion Points Diagram
-- =====================================================
local function GenerateChampionDiagram(cpData)
    if not cpData or not cpData.disciplines or #cpData.disciplines == 0 then
        return ""
    end
    
    local markdown = "## 🎯 Champion Points Visual\n\n"
    markdown = markdown .. string.format("**Your CP Investment:** %d earned • %d spent • %d available\n\n", 
        cpData.total or 0, cpData.spent or 0, (cpData.total or 0) - (cpData.spent or 0))
    
    -- Organize skills by tree
    local treeSkills = {
        Craft = {},
        Warfare = {},
        Fitness = {}
    }
    
    -- Map skills to trees
    for _, discipline in ipairs(cpData.disciplines) do
        if discipline.skills then
            for _, skill in ipairs(discipline.skills) do
                local starData = STAR_MAP[skill.name]
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
    
    -- Sort skills by points (highest first) for better visual hierarchy
    for treeName, skills in pairs(treeSkills) do
        table.sort(skills, function(a, b)
            return a.skill.points > b.skill.points
        end)
    end
    
    -- Generate diagram
    markdown = markdown .. "```mermaid\n"
    markdown = markdown .. "graph TB\n"  -- Changed to TB (Top-Bottom) for better vertical flow
    markdown = markdown .. "  %% 🎯 Your Champion Point Investment\n"
    markdown = markdown .. "  %% Color intensity shows investment level\n"
    markdown = markdown .. "  %% Shapes indicate star types\n\n"
    
    -- Generate nodes for each tree
    local treeOrder = {"Craft", "Warfare", "Fitness"}  -- Ensure consistent order
    for _, treeName in ipairs(treeOrder) do
        local skills = treeSkills[treeName]
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
            
            markdown = markdown .. string.format("  subgraph %s[\"<b>%s %s Constellation</b>\"]\n", 
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
                
                -- Get enhanced node shape
                local prefix, suffix = GetNodeShape(starData, points)
                
                -- Build enhanced label with indicator
                local label = string.format("%s %s<br/>%d/%d pts", 
                    indicator, skill.name, points, maxPoints)
                
                markdown = markdown .. string.format("    %s%s\"%s\"%s\n", 
                    nodeId, prefix, label, suffix)
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
                
                local intensity = GetColorIntensity(points)
                local color = GetTreeColor(treeName, intensity)
                
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
            
            markdown = markdown .. "  end\n\n"
        end
    end
    
    -- Add enhanced legend
    markdown = markdown .. "  %% ========================================\n"
    markdown = markdown .. "  %% LEGEND & KEY\n"
    markdown = markdown .. "  %% ========================================\n\n"
    
    markdown = markdown .. "  subgraph LEGEND[\"<b>📋 Legend & Investment Guide</b>\"]\n"
    markdown = markdown .. "    direction TB\n\n"
    
    -- Star types
    markdown = markdown .. "    LEG_SLOT[[\"⭐ Maxed Slottable<br/>Must Equip to Bar\"]]\n"
    markdown = markdown .. "    LEG_SLOT_PART[\"●●○ Partial Slottable<br/>Can Equip to Bar\"]\n"
    markdown = markdown .. "    LEG_PASS(\"●●● Maxed Passive<br/>Always Active\")\n"
    markdown = markdown .. "    LEG_PASS_PART([\"●○○ Partial Passive<br/>Always Active\"])\n"
    markdown = markdown .. "    LEG_BASE{\"Base Star<br/>Prerequisite\"}\n"
    markdown = markdown .. "\n"
    
    -- Investment indicators
    markdown = markdown .. "    LEG_IND1[\"⭐ = 100%% Maxed\"]\n"
    markdown = markdown .. "    LEG_IND2[\"●●● = 75-99%%\"]\n"
    markdown = markdown .. "    LEG_IND3[\"●●○ = 50-74%%\"]\n"
    markdown = markdown .. "    LEG_IND4[\"●○○ = 25-49%%\"]\n"
    markdown = markdown .. "    LEG_IND5[\"○○○ = 1-24%%\"]\n"
    markdown = markdown .. "\n"
    
    -- Styling for legend items
    markdown = markdown .. "    style LEG_SLOT fill:#00cc66,stroke:#ffd700,stroke-width:3px,color:#000\n"
    markdown = markdown .. "    style LEG_SLOT_PART fill:#4dd98f,stroke:#666,stroke-width:3px,color:#000\n"
    markdown = markdown .. "    style LEG_PASS fill:#00b359,stroke:#333,stroke-width:2px,color:#fff\n"
    markdown = markdown .. "    style LEG_PASS_PART fill:#a6e6c7,stroke:#333,stroke-width:2px,color:#000\n"
    markdown = markdown .. "    style LEG_BASE fill:#ffffcc,stroke:#ff8c00,stroke-width:2.5px,color:#000\n"
    
    markdown = markdown .. "    style LEG_IND1 fill:#f0f0f0,stroke:#333,stroke-width:1px,color:#000\n"
    markdown = markdown .. "    style LEG_IND2 fill:#f0f0f0,stroke:#333,stroke-width:1px,color:#000\n"
    markdown = markdown .. "    style LEG_IND3 fill:#f0f0f0,stroke:#333,stroke-width:1px,color:#000\n"
    markdown = markdown .. "    style LEG_IND4 fill:#f0f0f0,stroke:#333,stroke-width:1px,color:#000\n"
    markdown = markdown .. "    style LEG_IND5 fill:#f0f0f0,stroke:#333,stroke-width:1px,color:#000\n"
    markdown = markdown .. "  end\n"
    
    markdown = markdown .. "```\n\n"
    
    markdown = markdown .. "**Visual Guide:**\n"
    markdown = markdown .. "- 🎨 **Color Depth** = Investment level (darker = more points)\n"
    markdown = markdown .. "- 🔲 **Node Shape** = Star type and completion status\n"
    markdown = markdown .. "- ⭐ **Gold Border** = Maxed slottable stars (ready for Champion Bar)\n"
    markdown = markdown .. "- 🟠 **Orange Border** = Base/prerequisite stars\n"
    markdown = markdown .. "- 📊 **Points Shown** = Current / Maximum possible\n\n"
    
    return markdown
end

CM.generators.GenerateChampionDiagram = GenerateChampionDiagram

return CM.generators.GenerateChampionDiagram

