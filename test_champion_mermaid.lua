-- Test script for ChampionPointsGraph Mermaid generation
-- Run this in ESO to test the diagram generation

local ChampionPointsGraph = require("src/generators/helpers/ChampionPointsGraph")

-- Sample character points data (simulating a character's allocations)
local sampleCraftPoints = {
    ["Friends in Low Places"] = 25,
    ["Out of Sight"] = 30,
    ["Fleet Phantom"] = 40,
    ["Infamous"] = 25,
    ["Cutpurse's Art"] = 25,
    ["Discipline Artisan"] = 50,
    ["Treasure Hunter"] = 50,
    ["Plentiful Harvest"] = 50,
    ["Meticulous Disassembly"] = 50,
    ["Inspiration Boost"] = 45,
    ["Rationer"] = 30,
    ["Liquid Efficiency"] = 50,
    ["Homemaker"] = 25,
    ["Wanderer"] = 50,
    ["Steadfast Enchantment"] = 50,
    ["Fortune's Favor"] = 50,
    ["Gilded Fingers"] = 50,
    ["Breakfall"] = 50,
    ["Soul Reservoir"] = 30
}

-- Test 1: Generate Craft constellation diagram with character points
print("=== Test 1: Craft Constellation with Character Points ===")
local craftDiagram = ChampionPointsGraph.generateMermaidDiagram("craft", sampleCraftPoints)
print(craftDiagram)
print("\n\n")

-- Test 2: Generate Warfare constellation diagram without character points (all unallocated)
print("=== Test 2: Warfare Constellation (No Allocations) ===")
local warfareDiagram = ChampionPointsGraph.generateMermaidDiagram("warfare", nil)
print(warfareDiagram)
print("\n\n")

-- Test 3: Generate Fitness constellation diagram with empty character points
print("=== Test 3: Fitness Constellation (Empty Allocations) ===")
local fitnessDiagram = ChampionPointsGraph.generateMermaidDiagram("fitness", {})
print(fitnessDiagram)
print("\n\n")

-- Test 4: Error handling - invalid constellation name
print("=== Test 4: Error Handling ===")
local errorDiagram = ChampionPointsGraph.generateMermaidDiagram("invalid", {})
print(errorDiagram)

print("\n=== All Tests Complete ===")
