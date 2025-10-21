-- CharacterMarkdown - Final Initialization

local CM = CharacterMarkdown

CM.DebugPrint("INIT", "Running final validation...")

-- Validate all required modules
local validationResults = {
    core = (CM ~= nil),
    utils = (CM.utils ~= nil),
    links = (CM.links ~= nil),
    collectors = (CM.collectors ~= nil),
    generators = (CM.generators ~= nil),
    commands = (CM.commands ~= nil),
    events = (CM.events ~= nil),
    settings = (CM.Settings ~= nil),
}

local allValid = true
for module, isValid in pairs(validationResults) do
    if not isValid then
        CM.Error(string.format("Module '%s' failed to load!", module))
        allValid = false
    else
        CM.DebugPrint("INIT", string.format("✓ %s loaded", module))
    end
end

if not allValid then
    CM.Error("Addon initialization incomplete! Some modules failed to load.")
    CM.Error("Try /reloadui to restart the addon.")
    return
end

-- Validate critical functions
local criticalFunctions = {
    {name = "CommandHandler", ref = CM.commands.CommandHandler},
    {name = "GenerateMarkdown", ref = CM.generators.GenerateMarkdown},
    {name = "CollectCharacterData", ref = CM.collectors.CollectCharacterData},
}

for _, func in ipairs(criticalFunctions) do
    if not func.ref or type(func.ref) ~= "function" then
        CM.Error(string.format("Critical function '%s' not available!", func.name))
        allValid = false
    else
        CM.DebugPrint("INIT", string.format("✓ %s available", func.name))
    end
end

if not allValid then
    CM.Error("Critical functions missing! Addon may not work correctly.")
    return
end

-- Validate slash command registered
if not SLASH_COMMANDS["/markdown"] then
    CM.Error("/markdown command not registered!")
    allValid = false
else
    CM.DebugPrint("INIT", "✓ /markdown command registered")
end

if allValid then
    CM.DebugPrint("INIT", "===========================================")
    CM.DebugPrint("INIT", "CharacterMarkdown v" .. CM.version .. " - All modules loaded")
    CM.DebugPrint("INIT", "Type /markdown to generate a character profile")
    CM.DebugPrint("INIT", "===========================================")
else
    CM.Error("Initialization completed with errors")
end
