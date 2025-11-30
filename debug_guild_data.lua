-- Debug script to inspect guild data structure
-- Debug script to inspect guild data structure
CharacterMarkdown = {}
local CM = CharacterMarkdown
CM.collectors = {}
CM.generators = {}
CM.utils = {}
CM.utils.markdown = {}
CM.links = {}

-- Mock DebugPrint
CM.DebugPrint = function(...) end
CM.SafeCall = function(func, ...) return func(...) end


-- Mock API if needed (minimal mock)
if not CM.api then CM.api = {} end
if not CM.api.guilds then CM.api.guilds = {} end

-- Mock GetNumGuilds and GetGuildInfo to return sample data
CM.api.guilds.GetNumGuilds = function() return 2 end
CM.api.guilds.GetGuildInfo = function(index)
    if index == 1 then
        return {
            id = 1,
            name = "Test Guild 1",
            allianceId = 1,
            rankIndex = 1,
            rankName = "Member",
            memberIndex = 1
        }
    elseif index == 2 then
        return {
            id = 2,
            name = "Test Guild 2",
            allianceId = 2,
            rankIndex = 2,
            rankName = "Officer",
            memberIndex = 2
        }
    end
end

-- Mock GetAllianceName
GetAllianceName = function(id)
    if id == 1 then return "Aldmeri Dominion" end
    if id == 2 then return "Ebonheart Pact" end
    return "Daggerfall Covenant"
end

-- Mock zo_strformat
zo_strformat = function(format, value) return value end

-- Load the collector
dofile("src/collectors/Social.lua")

-- Run the collector
local data = CM.collectors.CollectGuildsData()

-- Print the structure
print("Guild Data Structure:")
print("Type of data:", type(data))
if type(data) == "table" then
    for k, v in pairs(data) do
        print("Key:", k, "Type:", type(v))
        if k == "list" and type(v) == "table" then
            print("  List count:", #v)
            if #v > 0 then
                print("  First item keys:")
                for k2, v2 in pairs(v[1]) do
                    print("    ", k2, type(v2))
                end
            end
        end
    end
else
    print("Data is not a table!")
end

-- Test the generator with this data
dofile("src/generators/sections/Guilds.lua")
local markdown = CM.generators.sections.GenerateGuilds(data, "markdown")
print("\nGenerated Markdown:")
print(markdown)
