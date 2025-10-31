-- CharacterMarkdown - Event System

local CM = CharacterMarkdown

local function OnAddOnLoaded(event, addonName)
    if addonName ~= CM.name then return end
    
    -- Update version from manifest now that addon is loaded
    CM.UpdateVersion()
    
    CM.Info("v" .. CM.version .. " Loading...")
    EVENT_MANAGER:UnregisterForEvent(CM.name, EVENT_ADD_ON_LOADED)
    
    if not CM.ValidateModules() then
        CM.Error("Module validation failed! Addon may not work correctly.")
        return
    end
    
    -- Initialize settings with delayed access to SavedVariables
    zo_callLater(function()
        -- Try multiple access methods for SavedVariables
        if not CharacterMarkdownSettings and _G.CharacterMarkdownSettings then
            CharacterMarkdownSettings = _G.CharacterMarkdownSettings
        end
        if not CharacterMarkdownData and _G.CharacterMarkdownData then
            CharacterMarkdownData = _G.CharacterMarkdownData
        end
        
        if not CharacterMarkdownSettings then
            local env = getfenv(2)
            if env.CharacterMarkdownSettings then
                CharacterMarkdownSettings = env.CharacterMarkdownSettings
            end
            if env.CharacterMarkdownData then
                CharacterMarkdownData = env.CharacterMarkdownData
            end
        end
        
        -- If still not available, wait longer
        if not CharacterMarkdownSettings then
            CM.DebugPrint("EVENTS", "SavedVariables not ready yet, waiting longer...")
            zo_callLater(function()
                if CM.Settings and CM.Settings.Initializer then
                    CM.Settings.Initializer:Initialize()
                end
                if CM.Settings and CM.Settings.Panel then
                    CM.Settings.Panel:Initialize()
                end
                CM.isInitialized = true
                CM.Success("Ready! Use /markdown to generate character profile")
            end, 2000)
            return
        end
        
        if CM.Settings and CM.Settings.Initializer then
            CM.Settings.Initializer:Initialize()
        end
        if CM.Settings and CM.Settings.Panel then
            CM.Settings.Panel:Initialize()
        end
        
        CM.isInitialized = true
        CM.Success("Ready! Use /markdown to generate character profile")
    end, 1000)
end

local function OnPlayerActivated(event)
    if not CharacterMarkdownSettings and _G.CharacterMarkdownSettings then
        CharacterMarkdownSettings = _G.CharacterMarkdownSettings
        CharacterMarkdownData = _G.CharacterMarkdownData
        CM.DebugPrint("EVENTS", "SavedVariables found on player activation - reinitializing settings")
        
        if CM.Settings and CM.Settings.Initializer then
            CM.Settings.Initializer:Initialize()
        end
    end
    
    EVENT_MANAGER:UnregisterForEvent(CM.name, EVENT_PLAYER_ACTIVATED)
end

local function RegisterEvents()
    EVENT_MANAGER:RegisterForEvent(CM.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
    EVENT_MANAGER:RegisterForEvent(CM.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

local function UnregisterEvents()
    EVENT_MANAGER:UnregisterForEvent(CM.name, EVENT_ADD_ON_LOADED)
end

CM.events.OnAddOnLoaded = OnAddOnLoaded
CM.events.OnPlayerActivated = OnPlayerActivated
CM.events.RegisterEvents = RegisterEvents
CM.events.UnregisterEvents = UnregisterEvents

RegisterEvents()
