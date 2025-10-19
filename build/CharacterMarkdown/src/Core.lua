-- CharacterMarkdown v2.1.0 - Core Namespace
-- Author: solaegis

d("[CharacterMarkdown] Initializing Core namespace...")

-- Create the main addon namespace
CharacterMarkdown = CharacterMarkdown or {}

d("[CharacterMarkdown] Core namespace created: " .. tostring(CharacterMarkdown))

-- Version and addon info
CharacterMarkdown.name = "CharacterMarkdown"
CharacterMarkdown.version = "2.1.0"
CharacterMarkdown.author = "solaegis"

-- Sub-namespaces for organized functionality
CharacterMarkdown.utils = {}
CharacterMarkdown.links = {}
CharacterMarkdown.collectors = {}
CharacterMarkdown.generators = {}
CharacterMarkdown.commands = {}
CharacterMarkdown.events = {}

-- Current format (default: github)
CharacterMarkdown.currentFormat = "github"

-- Debug flag
CharacterMarkdown.debug = false

-- Debug print helper
function CharacterMarkdown.DebugPrint(...)
    if CharacterMarkdown.debug then
        d("[CharacterMarkdown]", ...)
    end
end

-- Convenience alias
local CM = CharacterMarkdown
