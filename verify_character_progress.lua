-- Verification script for Character Progress Generator

-- Mock CharacterMarkdown environment
CharacterMarkdown = {
    generators = { sections = {} },
    utils = {
        markdown = {
            CreateStyledTable = function(headers, rows, options)
                local result = "| " .. table.concat(headers, " | ") .. " |\n"
                result = result .. "| --- | --- |\n"
                for _, row in ipairs(rows) do
                    result = result .. "| " .. table.concat(row, " | ") .. " |\n"
                end
                return result
            end,
            CreateSeparator = function() return "\n---\n\n" end
        }
    },
    links = {
        CreateSkillLink = function(name) return "[" .. name .. "](link)" end,
        CreateSkillLineLink = function(name) return "**[" .. name .. "](link)**" end
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
                    { index = 8, name = "Craft" },
                    { index = 9, name = "Champion" }
                }
            end
        }
    }
}

-- Load the generator
dofile("src/generators/sections/CharacterProgress.lua")

-- Mock Data
local progressionData = {
    summary = {
        maxedCount = 15,
        inProgressCount = 6,
        earlyProgressCount = 23,
        totalMorphs = 35,
        completionPercent = 34
    },
    maxedLines = {
        { type = 1, index = 1, name = "Daedric Summoning", rank = 50, passives = {
            { name = "Rebate", rank = 2, purchased = true },
            { name = "Power Stone", rank = 2, purchased = true }
        }},
        { type = 2, index = 1, name = "Dual Wield", rank = 50, passives = {
            { name = "Slaughter", rank = 2, purchased = true }
        }}
    },
    inProgressLines = {
        { type = 2, index = 2, name = "Two Handed", rank = 48, progress = 99, passives = {} }
    }
}

local morphsData = {
    summary = { totalMorphs = 35 },
    skillTypes = {
        {
            name = "Class",
            emoji = "⚔️",
            skillLines = {
                {
                    name = "Dark Magic",
                    rank = 25,
                    abilities = {
                        {
                            name = "Negate Magic",
                            currentRank = 4,
                            purchased = true,
                            ultimate = true,
                            currentMorph = 0,
                            morphs = {
                                { name = "Suppression Field", morphSlot = 1, selected = false },
                                { name = "Absorption Field", morphSlot = 2, selected = false }
                            }
                        },
                        {
                            name = "Crystal Shard",
                            currentRank = 4,
                            purchased = true,
                            currentMorph = 0,
                            morphs = {
                                { name = "Crystal Weapon", morphSlot = 1, selected = false },
                                { name = "Crystal Fragments", morphSlot = 2, selected = false }
                            }
                        }
                    }
                }
            }
        }
    }
}

-- Run Generator
local output = CharacterMarkdown.generators.sections.GenerateCharacterProgress(progressionData, morphsData, "markdown")

-- Print Output
print(output)
