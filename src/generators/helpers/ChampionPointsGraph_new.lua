--[[
    ESO Champion Points Graph Data Structures with Mermaid Diagram Generation
    Lua 5.1 Compatible
    Data synchronized with champion_points.yaml (source of truth)
    
    Each discipline contains:
    - nodes: table keyed by star name with node data and adjacency lists
    - getNode(name): returns node by name
    - getNeighbors(name): returns table of connected nodes (prerequisites + dependents)
    - walkPath(from, to): BFS pathfinding between nodes
    - getRoots(): returns nodes with no prerequisites
    - generateMermaidDiagram(characterPoints): generates Mermaid flowchart
]]

local ChampionPointsGraph = {}

--------------------------------------------------------------------------------
-- GRAPH UTILITIES
--------------------------------------------------------------------------------

local function createGraph(nodes)
    local graph = {
        nodes = nodes,
        _byId = {},
    }

    -- Build ID index
    for name, node in pairs(nodes) do
        graph._byId[node.id] = node
    end

    -- Build adjacency lists (dependents)
    for name, node in pairs(nodes) do
        node.dependents = {}
    end

    for name, node in pairs(nodes) do
        for _, prereq in ipairs(node.prerequisites) do
            local prereqNode = nodes[prereq.star]
            if prereqNode then
                prereqNode.dependents[#prereqNode.dependents + 1] = {
                    star = name,
                    min_points = prereq.min_points,
                }
            end
        end
    end

    function graph:getNode(name)
        return self.nodes[name]
    end

    function graph:getNodeById(id)
        return self._byId[id]
    end

    function graph:getNeighbors(name)
        local node = self.nodes[name]
        if not node then
            return nil
        end

        local neighbors = {}
        -- Add prerequisites
        for _, prereq in ipairs(node.prerequisites) do
            neighbors[#neighbors + 1] = {
                star = prereq.star,
                direction = "prerequisite",
                min_points = prereq.min_points,
            }
        end
        -- Add dependents
        for _, dep in ipairs(node.dependents) do
            neighbors[#neighbors + 1] = {
                star = dep.star,
                direction = "dependent",
                min_points = dep.min_points,
            }
        end
        return neighbors
    end

    function graph:getRoots()
        local roots = {}
        for name, node in pairs(self.nodes) do
            if #node.prerequisites == 0 then
                roots[#roots + 1] = name
            end
        end
        return roots
    end

    function graph:walkPath(fromName, toName)
        -- BFS pathfinding (ignores point requirements)
        local visited = {}
        local queue = { { name = fromName, path = { fromName } } }
        visited[fromName] = true

        while #queue > 0 do
            local current = table.remove(queue, 1)

            if current.name == toName then
                return current.path
            end

            local neighbors = self:getNeighbors(current.name)
            if neighbors then
                for _, neighbor in ipairs(neighbors) do
                    if not visited[neighbor.star] then
                        visited[neighbor.star] = true
                        local newPath = {}
                        for i, p in ipairs(current.path) do
                            newPath[i] = p
                        end
                        newPath[#newPath + 1] = neighbor.star
                        queue[#queue + 1] = { name = neighbor.star, path = newPath }
                    end
                end
            end
        end

        return nil -- No path found
    end

    function graph:getPrerequisiteChain(name)
        -- Returns all prerequisites needed to unlock a node (topologically sorted)
        local node = self.nodes[name]
        if not node then
            return nil
        end

        local chain = {}
        local visited = {}

        local function visit(nodeName)
            if visited[nodeName] then
                return
            end
            visited[nodeName] = true

            local n = self.nodes[nodeName]
            if n then
                for _, prereq in ipairs(n.prerequisites) do
                    visit(prereq.star)
                end
                if nodeName ~= name then
                    chain[#chain + 1] = {
                        star = nodeName,
                        min_points = 0,
                    }
                    -- Find the min_points required by the dependent
                    for _, p in ipairs(n.dependents) do
                        if visited[p.star] then
                            for i, c in ipairs(chain) do
                                if c.star == nodeName then
                                    chain[i].min_points = math.max(chain[i].min_points, p.min_points)
                                end
                            end
                        end
                    end
                end
            end
        end

        for _, prereq in ipairs(node.prerequisites) do
            visit(prereq.star)
            -- Add direct prerequisites with their required points
            local found = false
            for _, c in ipairs(chain) do
                if c.star == prereq.star then
                    c.min_points = math.max(c.min_points, prereq.min_points)
                    found = true
                    break
                end
            end
            if not found then
                chain[#chain + 1] = { star = prereq.star, min_points = prereq.min_points }
            end
        end

        return chain
    end

    return graph
end

--------------------------------------------------------------------------------
-- CRAFT CONSTELLATION (Green/Thief) - 29 Stars
-- Data synchronized with champion_points.yaml
--------------------------------------------------------------------------------

ChampionPointsGraph.craft = createGraph({
    ["Friends in Low Places"] = {
        id = 76,
        name = "Friends in Low Places",
        slottable = true,
        stages = 1,
        points_per_stage = 25,
        max_points = 25,
        prerequisites = {},
        notes = "This slotted passive removes 1000 gold from your bounty once per day when you commit a crime that adds bounty, provided you are level 50 or higher and your bounty is at least 1000 gold.",
    },
    ["Discipline Artisan"] = {
        id = 279,
        name = "Discipline Artisan",
        slottable = false,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {},
        notes = "It increases experience gain for currently active skills and their skill lines by 3% per stage, up to 15% at maximum.",
    },
    ["Fade Away"] = {
        id = 84,
        name = "Fade Away",
        slottable = true,
        stages = 1,
        points_per_stage = 50,
        max_points = 50,
        prerequisites = {
            { star = "Cutpurse's Art", min_points = 25 },
            { star = "Meticulous Disassembly", min_points = 50 },
        },
        notes = "Escaping from a guard removes 25% of your current heat, though it does not affect bounty.",
    },
    ["Out of Sight"] = {
        id = 68,
        name = "Out of Sight",
        slottable = false,
        stages = 3,
        points_per_stage = 10,
        max_points = 30,
        prerequisites = {
            { star = "Friends in Low Places", min_points = 25 },
        },
        notes = "",
    },
    ["Shadowstrike"] = {
        id = 80,
        name = "Shadowstrike",
        slottable = true,
        stages = 1,
        points_per_stage = 75,
        max_points = 75,
        prerequisites = {
            { star = "Infamous", min_points = 25 },
        },
        notes = "Killing an enemy with Blade of Woe grants invisibility for 5 seconds after a brief delay.",
    },
    ["Cutpurse's Art"] = {
        id = 90,
        name = "Cutpurse's Art",
        slottable = false,
        stages = 1,
        points_per_stage = 25,
        max_points = 25,
        prerequisites = {
            { star = "Shadowstrike", min_points = 75 },
        },
        notes = "Increases the chance to obtain higher-quality loot when pickpocketing NPCs.",
    },
    ["Master Gatherer"] = {
        id = 78,
        name = "Master Gatherer",
        slottable = true,
        stages = 5,
        points_per_stage = 15,
        max_points = 75,
        prerequisites = {
            { star = "Treasure Hunter", min_points = 25 },
            { star = "Fade Away", min_points = 50 },
            { star = "Meticulous Disassembly", min_points = 50 },
        },
        notes = "Reduces harvesting time from resource nodes by 10% per stage, up to 50% at maximum.",
    },
    ["Treasure Hunter"] = {
        id = 79,
        name = "Treasure Hunter",
        slottable = false,
        stages = 1,
        points_per_stage = 50,
        max_points = 50,
        prerequisites = {
            { star = "Meticulous Disassembly", min_points = 50 },
            { star = "Steadfast Enchantment", min_points = 10 },
        },
        notes = "Increases the quality of items found in treasure chests by one tier.",
    },
    ["Angler's Instincts"] = {
        id = 89,
        name = "Angler's Instincts",
        slottable = true,
        stages = 1,
        points_per_stage = 25,
        max_points = 25,
        prerequisites = {
            { star = "Liquid Efficiency", min_points = 50 },
        },
        notes = "Increases the chance of catching higher-quality fish.",
    },
    ["Steadfast Enchantment"] = {
        id = 75,
        name = "Steadfast Enchantment",
        slottable = false,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Wanderer", min_points = 10 },
        },
        notes = "Weapon enchantments have a 10% chance per stage to not consume a charge when activated.",
    },
    ["Reel Technique"] = {
        id = 88,
        name = "Reel Technique",
        slottable = true,
        stages = 1,
        points_per_stage = 50,
        max_points = 50,
        prerequisites = {
            { star = "Angler's Instincts", min_points = 25 },
        },
        notes = "",
    },
    ["Rationer"] = {
        id = 85,
        name = "Rationer",
        slottable = false,
        stages = 3,
        points_per_stage = 10,
        max_points = 30,
        prerequisites = {
            { star = "Steadfast Enchantment", min_points = 10 },
        },
        notes = "Adds 10 minutes to the duration of any food or drink that increases character stats per stage.",
    },
    ["War Mount"] = {
        id = 82,
        name = "War Mount",
        slottable = true,
        stages = 1,
        points_per_stage = 75,
        max_points = 75,
        prerequisites = {
            { star = "Gifted Rider", min_points = 10 },
            { star = "Plentiful Harvest", min_points = 10 },
        },
        notes = "Removes all mount Stamina costs when outside of combat.",
    },
    ["Liquid Efficiency"] = {
        id = 86,
        name = "Liquid Efficiency",
        slottable = false,
        stages = 1,
        points_per_stage = 50,
        max_points = 50,
        prerequisites = {
            { star = "Rationer", min_points = 10 },
        },
        notes = "Using a potion or poison grants a 10% chance to not consume it.",
    },
    ["Gifted Rider"] = {
        id = 92,
        name = "Gifted Rider",
        slottable = true,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Master Gatherer", min_points = 15 },
        },
        notes = "",
    },
    ["Homemaker"] = {
        id = 91,
        name = "Homemaker",
        slottable = false,
        stages = 1,
        points_per_stage = 25,
        max_points = 25,
        prerequisites = {
            { star = "Reel Technique", min_points = 50 },
        },
        notes = "Grants a 10% chance to find a second furnishing plan.",
    },
    ["Steed's Blessing"] = {
        id = 66,
        name = "Steed's Blessing",
        slottable = true,
        stages = 50,
        points_per_stage = 1,
        max_points = 50,
        prerequisites = {},
        notes = "Increases out-of-combat movement speed by 0.4% per stage, up to 20% at maximum.",
    },
    ["Wanderer"] = {
        id = 70,
        name = "Wanderer",
        slottable = false,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Fortune's Favor", min_points = 10 },
        },
        notes = "Reduces the cost of Wayshrine usage by 10% per stage, up to 50% at maximum.",
    },
    ["Sustaining Shadows"] = {
        id = 65,
        name = "Sustaining Shadows",
        slottable = true,
        stages = 50,
        points_per_stage = 1,
        max_points = 50,
        prerequisites = {},
        notes = "Reduces the cost of Sneak by 1% per stage, up to 50% at maximum.",
    },
    ["Plentiful Harvest"] = {
        id = 81,
        name = "Plentiful Harvest",
        slottable = false,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Master Gatherer", min_points = 15 },
        },
        notes = "Grants a 10% chance per stage to double the yield from normal resource nodes.",
    },
    ["Meticulous Disassembly"] = {
        id = 83,
        name = "Meticulous Disassembly",
        slottable = false,
        stages = 1,
        points_per_stage = 50,
        max_points = 50,
        prerequisites = {
            { star = "Inspiration Boost", min_points = 15 },
        },
        notes = "Improves extraction chances for crafting ingredients from deconstructed gear.",
    },
    ["Inspiration Boost"] = {
        id = 72,
        name = "Inspiration Boost",
        slottable = false,
        stages = 3,
        points_per_stage = 15,
        max_points = 45,
        prerequisites = {
            { star = "Fortune's Favor", min_points = 10 },
        },
        notes = "Increases crafting inspiration gained by 10% per stage, up to 30% at 45 points.",
    },
    ["Fortune's Favor"] = {
        id = 71,
        name = "Fortune's Favor",
        slottable = false,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Gilded Fingers", min_points = 0 },
        },
        notes = "Increases gold found in treasure chests and safeboxes by 10% per stage.",
    },
    ["Infamous"] = {
        id = 77,
        name = "Infamous",
        slottable = false,
        stages = 1,
        points_per_stage = 25,
        max_points = 25,
        prerequisites = {
            { star = "Fleet Phantom", min_points = 8 },
        },
        notes = "Increases the value of fenced items by 25%.",
    },
    ["Fleet Phantom"] = {
        id = 67,
        name = "Fleet Phantom",
        slottable = false,
        stages = 5,
        points_per_stage = 8,
        max_points = 40,
        prerequisites = {
            { star = "Friends in Low Places", min_points = 25 },
        },
        notes = "Reduces the Movement Speed penalty of Sneak by 5% per stage.",
    },
    ["Gilded Fingers"] = {
        id = 74,
        name = "Gilded Fingers",
        slottable = false,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {},
        notes = "Increases gold gained from all sources by 2% per stage, up to 10% at maximum.",
    },
    ["Breakfall"] = {
        id = 69,
        name = "Breakfall",
        slottable = false,
        stages = 5,
        points_per_stage = 10,
        max_points = 50,
        prerequisites = {
            { star = "Wanderer", min_points = 10 },
        },
        notes = "Reduces fall damage by 10% per stage, up to 50% at maximum.",
    },
    ["Soul Reservoir"] = {
        id = 87,
        name = "Soul Reservoir",
        slottable = false,
        stages = 1,
        points_per_stage = 30,
        max_points = 30,
        prerequisites = {
            { star = "Breakfall", min_points = 10 },
        },
        notes = "When resurrecting yourself or another player, gain a 33% chance to not consume a soul gem.",
    },
    ["Professional Upkeep"] = {
        id = 1,
        name = "Professional Upkeep",
        slottable = false,
        stages = 50,
        points_per_stage = 1,
        max_points = 50,
        prerequisites = {},
        notes = "Reduces the cost of repairing armor by 1% per stage, up to 50% at maximum.",
    },
})

-- Continue with warfare and fitness constellations...
-- (This file is getting very long - I'll create it in parts)

--------------------------------------------------------------------------------
-- MODULE EXPORT
--------------------------------------------------------------------------------

return ChampionPointsGraph
