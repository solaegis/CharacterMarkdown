-- CharacterMarkdown - Initialization
-- Final setup after all modules loaded

local CM = CharacterMarkdown

d("[CharacterMarkdown] ========================================")
d("[CharacterMarkdown] Final initialization check:")
d("[CharacterMarkdown] - Namespace exists: " .. tostring(CM ~= nil))
d("[CharacterMarkdown] - utils: " .. tostring(CM.utils ~= nil))
d("[CharacterMarkdown] - links: " .. tostring(CM.links ~= nil))
d("[CharacterMarkdown] - collectors: " .. tostring(CM.collectors ~= nil))
d("[CharacterMarkdown] - generators: " .. tostring(CM.generators ~= nil))
d("[CharacterMarkdown] - commands: " .. tostring(CM.commands ~= nil))
d("[CharacterMarkdown] - events: " .. tostring(CM.events ~= nil))
d("[CharacterMarkdown] - CommandHandler: " .. tostring(CM.commands.CommandHandler ~= nil))
d("[CharacterMarkdown] - SLASH_COMMANDS['/markdown']: " .. tostring(SLASH_COMMANDS["/markdown"] ~= nil))
d("[CharacterMarkdown] ========================================")
d("[CharacterMarkdown] All modules loaded successfully")
d("[CharacterMarkdown] Ready to use. Type /markdown to generate a character profile")
