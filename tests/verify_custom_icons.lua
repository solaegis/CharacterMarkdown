-- Mock Environment
CharacterMarkdown = {
    utils = {
        markdown = {
            CreateBadgeRow = function(badges) return "BADGE_ROW" end,
            CreateCenteredBlock = function(content) return "CENTERED_BLOCK:\n" .. content end,
            CreateSeparator = function() return "---\n\n" end
        }
    },
    generators = { sections = {} },
    DebugPrint = function(...) end
}

-- Mock LibCustomIcons
LibCustomIcons = {
    GetStatic = function(displayName)
        if displayName == "@TestUser" then
            return "LibCustomIcons/icons/test_icon.dds"
        end
        return nil
    end
}

-- Mock ESO API
function GetDisplayName()
    return "@TestUser"
end

-- Load the generator file
-- We need to read the file content and execute it, but since it returns a table, we can just require it if it was a module.
-- However, it modifies the global CharacterMarkdown table.
-- Let's simulate loading it by reading the file and executing it.
-- Since we are in a standalone script, we'll just copy the function logic we want to test or load the file.
-- Loading the file is better but requires handling the file path.
-- For simplicity in this environment, I will copy the relevant parts of the file content or try to load it if I can.
-- Actually, I can use `dofile` if I know the path.

-- Let's just define the function as it is in the file (I'll read it from the file in the real run, but here I'll just paste the logic I modified to test it in isolation, or better, I will try to load the actual file).

-- To load the actual file, I need to make sure it doesn't have other dependencies that will crash.
-- The file `src/generators/sections/Character.lua` uses `CharacterMarkdown` global.
-- It returns a table.

local chunk = loadfile("/Users/lvavasour/git/CharacterMarkdown/src/generators/sections/Character.lua")
if not chunk then
    print("Error loading file")
    os.exit(1)
end
chunk()

-- Now test GenerateHeader
local GenerateHeader = CharacterMarkdown.generators.sections.GenerateHeader

local charData = {
    name = "TestChar",
    race = "Breton",
    class = "Templar",
    alliance = "Daggerfall Covenant",
    level = 50,
    cp = 160,
    esoPlus = true
}

local result = GenerateHeader(charData, "github")

print("Generated Header:")
print(result)

-- Verify
if string.find(result, "https://raw.githubusercontent.com/m00nyONE/LibCustomIcons/main/icons/test_icon.dds") then
    print("SUCCESS: Icon URL found")
else
    print("FAILURE: Icon URL not found")
    os.exit(1)
end

if string.find(result, "!%[Custom Icon%]") then
    print("SUCCESS: Image markdown found")
else
    print("FAILURE: Image markdown not found")
    os.exit(1)
end
