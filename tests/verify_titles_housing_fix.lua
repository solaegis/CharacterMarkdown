-- Verification script for Titles and Housing fix in GenerateCollectibles

-- Mock CharacterMarkdown environment
CharacterMarkdown = {
    generators = {
        sections = {},
        helpers = {
            GenerateProgressBar = function(progress, length) return "[" .. progress .. "%]" end
        }
    },
    links = {
        CreateCollectibleLink = function(name) return "[" .. name .. "]" end,
        CreateMundusLink = function(name) return "[" .. name .. "]" end
    },
    utils = {
        FormatNumber = function(n) return tostring(n) end,
        markdown = {
            GenerateAnchor = function(text) return text:lower():gsub(" ", "-") end,
            CreateSeparator = function() return "\n---\n\n" end
        }
    }
}
CM = CharacterMarkdown

-- Mock Settings
CharacterMarkdownSettings = {
    includeCollectiblesDetailed = true,
    includeDLCAccess = true
}

-- Load the file to test
local function LoadFile(path)
    local file = io.open(path, "r")
    if not file then return nil end
    local content = file:read("*a")
    file:close()
    return content
end

-- We need to load DLCAndMundus.lua, but it depends on CM being defined (which it is)
-- We'll manually execute the content of the file
local filePath = "src/generators/sections/DLCAndMundus.lua"
local fileContent = LoadFile(filePath)
if not fileContent then
    print("Error: Could not load " .. filePath)
    return
end

-- Execute the file content
local chunk, err = load(fileContent)
if not chunk then
    print("Error loading chunk: " .. err)
    return
end
chunk()

-- Mock GenerateTitles and GenerateHousing since they are called by GenerateCollectibles
CM.generators.sections.GenerateTitles = function(data, format)
    return "MOCK TITLES SECTION"
end

CM.generators.sections.GenerateHousing = function(data, format)
    return "MOCK HOUSING SECTION"
end

-- Test Data (New Structure)
local testData = {
    collectibles = {
        collections = {}
    },
    titlesHousing = {
        titles = {
            current = "Daedric Lord",
            owned = {
                { id = 1, name = "Daedric Lord" },
                { id = 2, name = "Hero of Wrothgar" }
            },
            summary = {
                totalOwned = 2,
                totalAvailable = 100,
                completionPercent = 2
            }
        },
        housing = {
            primary = { name = "Grand Psijic Villa" },
            owned = {
                { id = 1, name = "Grand Psijic Villa", nickname = "My Villa" },
                { id = 2, name = "Snugpod" }
            },
            summary = {
                totalOwned = 2,
                hasPrimary = true
            }
        }
    }
}

-- Run Test
print("Testing GenerateCollectibles with new data structure...")
local result = CM.generators.sections.GenerateCollectibles(
    testData.collectibles,
    "markdown",
    nil, -- dlcData
    nil, -- lorebooksData
    testData.titlesHousing,
    nil -- ridingData
)

-- Verify Output
local hasTitles = string.find(result, "MOCK TITLES SECTION")
local hasHousing = string.find(result, "MOCK HOUSING SECTION")

if hasTitles then
    print("✅ Titles section generated successfully")
else
    print("❌ Titles section MISSING")
end

if hasHousing then
    print("✅ Housing section generated successfully")
else
    print("❌ Housing section MISSING")
end

-- Test with Empty Data (Should not generate)
print("\nTesting with empty data...")
local emptyData = {
    collectibles = { collections = {} },
    titlesHousing = {
        titles = { owned = {}, summary = { totalOwned = 0 } },
        housing = { owned = {}, summary = { totalOwned = 0 } }
    }
}

local emptyResult = CM.generators.sections.GenerateCollectibles(
    emptyData.collectibles,
    "markdown",
    nil, nil, emptyData.titlesHousing, nil
)

if emptyResult == "" then
    print("✅ Empty result correctly returned for empty data")
else
    print("❌ Expected empty result, got: " .. #emptyResult .. " chars")
end
