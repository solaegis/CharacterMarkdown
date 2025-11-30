
-- Mock CM environment
local CM = {
    utils = {
        markdown = {
            CreateStyledTable = function(headers, rows, options) return "| Table |" end
        },
        FormatNumber = function(n) return tostring(n) end
    },
    links = {
        CreateSkillLineLink = function(name) return "**" .. name .. "**" end,
        CreateSkillLink = function(name) return "[" .. name .. "](link)" end
    },
    api = {
        skills = {
            GetSkillTypes = function()
                return {
                    { index = 1, name = "Class" },
                    { index = 2, name = "Weapon" },
                    { index = 3, name = "Armor" },
                    { index = 4, name = "World" },
                    { index = 5, name = "Guild" },
                    { index = 6, name = "Alliance War" },
                    { index = 7, name = "Racial" },
                    { index = 8, name = "Craft" }
                }
            end
        }
    },
    generators = { sections = {} },
    Warn = function() end
}
CharacterMarkdown = CM

-- Load the generator file (we'll just load the function logic here or require the file if possible, 
-- but since we are in a standalone script, we need to mock the environment first then load the file content or copy the function)
-- To properly test the file, I should load it. But `dofile` might fail if it has other dependencies.
-- I'll copy the relevant parts of the generator function or just `dofile` if I can mock everything it needs.
-- Let's try to `dofile` it, assuming I mocked enough.

-- Mock global table_concat etc if needed (Lua standard libs are usually available)
string_format = string.format
table_concat = table.concat
table_insert = table.insert

-- Load the file
dofile("src/generators/sections/CharacterProgress.lua")

-- Test Data
local progressionData = {
    summary = { maxedCount = 1, inProgressCount = 1 },
    maxedLines = {
        {
            name = "Alchemy",
            type = 8, -- Craft
            rank = 50,
            passives = {
                { name = "Medicinal Use", purchased = true, rank = 3, maxRank = 3 }
            }
        }
    },
    inProgressLines = {
        {
            name = "Two Handed",
            type = 2, -- Weapon
            rank = 42,
            progress = 50,
            passives = {
                { name = "Forceful", purchased = true, rank = 1, maxRank = 2 },
                { name = "Heavy Weapons", purchased = false, rank = 0, maxRank = 2 }
            }
        }
    }
}

local morphsData = {}

-- Run Generator
local result = CM.generators.sections.GenerateCharacterProgress(progressionData, morphsData, "github")

-- Output Result
print(result)
