#!/usr/bin/env python3
"""
Generate ChampionPointsGraph.lua from champion_points.yaml
This ensures 100% accuracy with the YAML source of truth
"""

import yaml
import sys

def escape_lua_string(s):
    """Escape special characters for Lua strings"""
    if not s:
        return ""
    return s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n')

def generate_star_entry(star):
    """Generate Lua table entry for a single star"""
    prereqs = []
    for p in star.get('prerequisites', []):
        prereqs.append(f'{{star = "{p["star"]}", min_points = {p["min_points"]}}}')
    
    prereq_str = ", ".join(prereqs) if prereqs else ""
    
    return f'''    ["{star['name']}"] = {{
        id = {star['id']},
        name = "{star['name']}",
        slottable = {str(star['slottable']).lower()},
        stages = {star['stages']},
        points_per_stage = {star['points_per_stage']},
        max_points = {star['max_points']},
        prerequisites = {{{prereq_str}}},
        notes = "{escape_lua_string(star.get('notes', ''))}"
    }}'''

def main():
    # Read YAML
    with open('examples/templates/champion_points.yaml', 'r') as f:
        data = yaml.safe_load(f)
    
    # Start building Lua file
    lua_content = '''--[[
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
        _byId = {}
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
                    min_points = prereq.min_points
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
        if not node then return nil end
        
        local neighbors = {}
        -- Add prerequisites
        for _, prereq in ipairs(node.prerequisites) do
            neighbors[#neighbors + 1] = {
                star = prereq.star,
                direction = "prerequisite",
                min_points = prereq.min_points
            }
        end
        -- Add dependents
        for _, dep in ipairs(node.dependents) do
            neighbors[#neighbors + 1] = {
                star = dep.star,
                direction = "dependent",
                min_points = dep.min_points
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
        local queue = {{name = fromName, path = {fromName}}}
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
                        queue[#queue + 1] = {name = neighbor.star, path = newPath}
                    end
                end
            end
        end
        
        return nil -- No path found
    end
    
    function graph:getPrerequisiteChain(name)
        -- Returns all prerequisites needed to unlock a node (topologically sorted)
        local node = self.nodes[name]
        if not node then return nil end
        
        local chain = {}
        local visited = {}
        
        local function visit(nodeName)
            if visited[nodeName] then return end
            visited[nodeName] = true
            
            local n = self.nodes[nodeName]
            if n then
                for _, prereq in ipairs(n.prerequisites) do
                    visit(prereq.star)
                end
                if nodeName ~= name then
                    chain[#chain + 1] = {
                        star = nodeName,
                        min_points = 0
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
                chain[#chain + 1] = {star = prereq.star, min_points = prereq.min_points}
            end
        end
        
        return chain
    end
    
    return graph
end

'''
    
    # Generate each constellation
    for constellation_name in ['craft', 'warfare', 'fitness']:
        stars = data.get(constellation_name, [])
        constellation_title = constellation_name.capitalize()
        
        # Determine color/theme
        if constellation_name == 'craft':
            color_desc = "Green/Thief"
        elif constellation_name == 'warfare':
            color_desc = "Red/Mage"
        else:
            color_desc = "Blue/Warrior"
        
        lua_content += f'''--------------------------------------------------------------------------------
-- {constellation_title.upper()} CONSTELLATION ({color_desc}) - {len(stars)} Stars
-- Data synchronized with champion_points.yaml
--------------------------------------------------------------------------------

ChampionPointsGraph.{constellation_name} = createGraph({{
'''
        
        # Generate star entries
        star_entries = []
        for star in stars:
            star_entries.append(generate_star_entry(star))
        
        lua_content += ",\n".join(star_entries)
        lua_content += "\n})\n\n"
    
    # Add the module export
    lua_content += '''--------------------------------------------------------------------------------
-- MODULE EXPORT
--------------------------------------------------------------------------------

return ChampionPointsGraph
'''
    
    # Write output
    with open('src/generators/helpers/ChampionPointsGraph.lua', 'w') as f:
        f.write(lua_content)
    
    print(f"Generated ChampionPointsGraph.lua successfully!")
    print(f"  Craft: {len(data['craft'])} stars")
    print(f"  Warfare: {len(data['warfare'])} stars")
    print(f"  Fitness: {len(data['fitness'])} stars")

if __name__ == '__main__':
    main()
