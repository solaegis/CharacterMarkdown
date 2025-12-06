-- Test script for ChampionDiagram.lua

-- Mock CharacterMarkdown environment
CharacterMarkdown = {
    generators = {
        sections = {}
    },
    DebugPrint = function(category, message)
        -- print("[" .. category .. "] " .. message)
    end
}

-- Load the generator
dofile("src/generators/sections/ChampionDiagram.lua")

-- Sample Data
local sampleData = {
    disciplines = {
        {
            name = "Craft",
            available = 10,
            slottableSkills = {
                { name = "Friends in Low Places", points = 25, maxPoints = 25 },
                { name = "Fade Away", points = 50, maxPoints = 50 },
                { name = "Shadowstrike", points = 75, maxPoints = 75 },
                { name = "Master Gatherer", points = 75, maxPoints = 75 },
                { name = "War Mount", points = 120, maxPoints = 120 },
                { name = "Gifted Rider", points = 100, maxPoints = 100 },
            },
            passiveSkills = {
                { name = "Out of Sight", points = 30, maxPoints = 30 },
                { name = "Cutpurse's Art", points = 25, maxPoints = 25 },
                { name = "Infamous", points = 25, maxPoints = 25 },
                { name = "Treasure Hunter", points = 50, maxPoints = 50 },
                { name = "Meticulous Disassembly", points = 50, maxPoints = 50 },
                { name = "Plentiful Harvest", points = 50, maxPoints = 50 },
            }
        },
        {
            name = "Warfare",
            available = 5,
            slottableSkills = {
                { name = "Fighting Finesse", points = 50, maxPoints = 50 },
                { name = "Deadly Aim", points = 50, maxPoints = 50 },
            },
            passiveSkills = {
                { name = "Precision", points = 20, maxPoints = 20 },
                { name = "Piercing", points = 20, maxPoints = 20 },
            }
        }
    }
}

-- Generate Diagram
local diagram = CharacterMarkdown.generators.sections.GenerateChampionDiagram(sampleData)

-- Print Result
print(diagram)
