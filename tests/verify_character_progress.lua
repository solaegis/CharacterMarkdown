-- Test script for Character Progress Generator

-- Mock Global CharacterMarkdown
CharacterMarkdown = {
    generators = {
        sections = {}
    },
    utils = {
        markdown = {
            CreateStyledTable = function(headers, rows) return "| Table |" end
        }
    },
    links = {
        CreateSkillLink = function(name) return "[" .. name .. "](link)" end,
        CreateSkillLineLink = function(name) return "**[" .. name .. "](link)**" end
    },
    Warn = function() end,
    Constants = {
        SKILL_TYPE_EMOJIS = {
            ["Class"] = "⚔️",
            ["Weapon"] = "⚔️",
            ["Armor"] = "🛡️",
        },
        DEFAULT_SKILL_EMOJI = "📜",
        SKILL_TYPE_ORDER = { "Class" }
    }
}

-- Load the generator file
local generatorFile = "src/generators/sections/CharacterProgress.lua"
local f = io.open(generatorFile, "r")
local content = f:read("*all")
f:close()

-- Execute the generator file to register the function
local chunk, err = load(content)
if not chunk then
    print("Error loading generator: " .. err)
    os.exit(1)
end
chunk()

-- Mock Data
local progressionData = {
    summary = {
        maxedCount = 0,
        inProgressCount = 1,
        earlyProgressCount = 0,
        totalMorphs = 0,
        completionPercent = 0
    },
    inProgressLines = {
        {
            name = "Test Skill Line",
            rank = 25,
            progress = 50,
            type = 1, -- Class
            passives = {
                {
                    name = "Test Passive",
                    rank = 1,
                    purchased = true
                },
                {
                    name = "Locked Passive",
                    rank = 0,
                    purchased = false
                }
            }
        }
    }
}

-- Mock API for GetSkillTypes (used in generator)
CharacterMarkdown.api = {
    skills = {
        GetSkillTypes = function()
            return {
                { index = 1, name = "Class" }
            }
        end
    }
}

-- Run Generator
local result = CharacterMarkdown.generators.sections.GenerateCharacterProgress(progressionData, {}, "markdown")

-- Verify Output
print("Generated Output:")
print(result)

-- Check for expected strings
if string.find(result, "Test Passive") and string.find(result, "Locked Passive") then
    print("\n✅ SUCCESS: Passives found in output.")
else
    print("\n❌ FAILURE: Passives NOT found in output.")
end
