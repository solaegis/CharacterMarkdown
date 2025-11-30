-- Mock Environment
CharacterMarkdown = {
    Settings = { Panel = {} },
    DebugPrint = function(...) end
}
CharacterMarkdown.Settings.Panel.AddCustomNotes = nil -- Will be populated by loading the file

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

-- Mock table.insert
local options = {}
local original_insert = table.insert
table.insert = function(t, v)
    if t == options then
        original_insert(t, v)
    end
end

-- Load the file to get the function
-- We need to extract the function AddCustomNotes from the file because loading the whole file might fail due to missing dependencies (LAM, etc.)
-- However, AddCustomNotes is a method of CM.Settings.Panel.
-- Let's try to load the file but mock everything it needs.

-- Mocking dependencies for Panel.lua
LibAddonMenu2 = {}
CharacterMarkdownSettings = {}
GetTimeStamp = function() return 0 end
GetCurrentCharacterId = function() return "123" end
ZO_SavedVars = { NewCharacterId = function() return {} end }
SLASH_COMMANDS = {}
CALLBACK_MANAGER = { RegisterCallback = function() end }

-- Load the file
local chunk, err = loadfile("/Users/lvavasour/git/CharacterMarkdown/src/settings/Panel.lua")
if not chunk then
    print("Error loading file: " .. err)
    os.exit(1)
end
chunk()

-- Now call AddCustomNotes
CharacterMarkdown.Settings.Panel:AddCustomNotes(options)

-- Verify results
local iconFound = false
local descriptionFound = false

for _, option in ipairs(options) do
    if option.type == "texture" and option.image == "LibCustomIcons/icons/test_icon.dds" then
        iconFound = true
    end
    if option.type == "description" and type(option.text) == "string" and string.find(option.text, "You have a custom icon!") then
        descriptionFound = true
    end
end

if iconFound then
    print("SUCCESS: Icon texture control found")
else
    print("FAILURE: Icon texture control not found")
    os.exit(1)
end

if descriptionFound then
    print("SUCCESS: Description control found")
else
    print("FAILURE: Description control not found")
    os.exit(1)
end
