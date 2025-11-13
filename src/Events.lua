-- CharacterMarkdown - Event System

local CM = CharacterMarkdown

local function OnAddOnLoaded(event, addonName)
    if addonName ~= CM.name then
        return
    end
    
    -- Update version from manifest now that addon is loaded
    CM.UpdateVersion()

    CM.Info("v" .. CM.version .. " Loading...")
    EVENT_MANAGER:UnregisterForEvent(CM.name, EVENT_ADD_ON_LOADED)

    if not CM.ValidateModules() then
        CM.Error("Module validation failed! Addon may not work correctly.")
        return
    end

    -- Initialize SavedVariables in ADD_ON_LOADED
    -- Per ESO best practices, SavedVariables MUST be initialized during ADD_ON_LOADED
    if CM.Settings and CM.Settings.Initializer then
        -- Use full Initialize() method which handles all initialization including format sync
        local success = CM.Settings.Initializer:Initialize()
        if not success then
            CM.Error("Settings initialization failed!")
        end
    else
        CM.Error("Settings.Initializer not available!")
    end

end

local function OnPlayerActivated(event)
    
    if not CM.isInitialized then
        if CM.Settings and CM.Settings.Panel then
            CM.Settings.Panel:Initialize()
        end
        
        CM.isInitialized = true
        CM.Success("Ready! Use /markdown to generate character profile")
        
        EVENT_MANAGER:UnregisterForEvent(CM.name, EVENT_PLAYER_ACTIVATED)
        return
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

-- Register event handlers
RegisterEvents()
