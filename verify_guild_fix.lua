-- Verification script for Guild Membership fix

-- Mock CharacterMarkdown environment
CharacterMarkdown = {
    utils = {
        FormatNumber = function(n) return tostring(n) end,
        markdown = {
            GenerateAnchor = function(s) return s:lower():gsub(" ", "-") end,
            CreateStyledTable = function(h, r, o) 
                local s = "| " .. table.concat(h, " | ") .. " |\n| --- | --- |\n"
                for _, row in ipairs(r) do
                    s = s .. "| " .. table.concat(row, " | ") .. " |\n"
                end
                return s
            end
        }
    },
    links = {
        CreateAllianceLink = function(n) return "[" .. n .. "](#)" end
    },
    generators = { sections = {} }
}
CM = CharacterMarkdown

-- Load the Guilds generator
local GuildsGenerator = dofile("src/generators/sections/Guilds.lua")

-- Test Data 1: Old format (direct list)
local oldData = {
    { name = "Old Guild", rank = "Member", memberCount = 100, alliance = "Aldmeri Dominion" }
}

-- Test Data 2: New format (structured object)
local newData = {
    list = {
        { name = "New Guild", rank = "Officer", memberCount = 200, alliance = "Ebonheart Pact" }
    },
    summary = { totalGuilds = 1 }
}

-- Test Data 3: Empty data
local emptyData = {}

-- Run Tests
print("--- Testing Old Format ---")
local oldOutput = GuildsGenerator.GenerateGuilds(oldData, "markdown", nil)
print(oldOutput)

print("\n--- Testing New Format ---")
local newOutput = GuildsGenerator.GenerateGuilds(newData, "markdown", nil)
print(newOutput)

print("\n--- Testing Empty Data ---")
local emptyOutput = GuildsGenerator.GenerateGuilds(emptyData, "markdown", nil)
print(emptyOutput)

-- Check for success
if oldOutput:find("Old Guild") and newOutput:find("New Guild") and emptyOutput:find("No guild data available") then
    print("\n✅ VERIFICATION SUCCESSFUL: Both formats handled correctly.")
else
    print("\n❌ VERIFICATION FAILED")
end
