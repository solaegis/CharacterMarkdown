-- CharacterMarkdown - Event System
-- Event registration and handlers

d("[CharacterMarkdown] *** Events.lua is being loaded ***")

local CM = CharacterMarkdown

d("[CharacterMarkdown] Events.lua: CM = " .. tostring(CM))
d("[CharacterMarkdown] Events.lua: CM.name = " .. tostring(CM and CM.name))
d("[CharacterMarkdown] Events.lua: CM.version = " .. tostring(CM and CM.version))

-- =====================================================
-- EVENT HANDLERS
-- =====================================================

local function OnAddOnLoaded(event, addonName)
    -- Debug: Show ALL addon loads to see what we're getting
    d("[CharacterMarkdown] EVENT_ADD_ON_LOADED fired for: '" .. tostring(addonName) .. "' (looking for: '" .. tostring(CM.name) .. "')")
    
    if addonName ~= CM.name then
        d("[CharacterMarkdown] Not our addon, skipping...")
        return
    end
    
    d("=================================================")
    d("[CharacterMarkdown] v" .. CM.version .. " LOADED")
    d("=================================================")
    
    -- Debug: Check if Settings modules are loaded
    d("[CharacterMarkdown] Checking Settings modules...")
    d("  CM.Settings = " .. tostring(CM.Settings))
    d("  CM.Settings.Defaults = " .. tostring(CM.Settings and CM.Settings.Defaults))
    d("  CM.Settings.Initializer = " .. tostring(CM.Settings and CM.Settings.Initializer))
    d("  CM.Settings.Panel = " .. tostring(CM.Settings and CM.Settings.Panel))
    
    -- Initialize settings (data defaults and saved variables)
    -- IMPORTANT: Need to wait for ESO to fully initialize saved variables
    -- ESO creates the saved variables table during EVENT_ADD_ON_LOADED but
    -- may not populate it until after the event completes
    
    -- Try multiple times with increasing delays to ensure saved vars are ready
    local function tryInitialize(attempt)
        if attempt > 5 then
            if CHAT_SYSTEM then
                CHAT_SYSTEM:AddMessage("CHARACTER MARKDOWN: ⚠️ Failed to initialize after 5 attempts!")
            end
            return
        end
        
        -- Check if saved variables table exists and is accessible
        local svType = type(CharacterMarkdownSettings)
        local svReady = (svType == "table" or svType == "userdata")
        
        if CHAT_SYSTEM then
            CHAT_SYSTEM:AddMessage("CHARACTER MARKDOWN: Initialization attempt " .. attempt .. ", type = " .. svType .. ", svReady = " .. tostring(svReady))
        end
        
        -- If ESO hasn't created it yet AND we've tried enough times, give up waiting
        -- ESO will create it eventually, so we'll just proceed with initialization
        if not svReady and attempt >= 3 then
            if CHAT_SYSTEM then
                CHAT_SYSTEM:AddMessage("CHARACTER MARKDOWN: ESO hasn't created saved variables yet, proceeding anyway...")
            end
            -- Don't create manually - let InitializeAccountSettings handle it
            svReady = true
        end
        
        if svReady then
            -- Initialize settings UI panel FIRST (LAM might help ESO finalize saved vars)
            if CM.Settings and CM.Settings.Panel then
                if CHAT_SYSTEM then
                    CHAT_SYSTEM:AddMessage("CHARACTER MARKDOWN: Calling Settings.Panel:Initialize()...")
                end
                CM.Settings.Panel:Initialize()
            end
            
            -- Then initialize settings data AFTER panel is registered
            zo_callLater(function()
                if CM.Settings and CM.Settings.Initializer then
                    if CHAT_SYSTEM then
                        CHAT_SYSTEM:AddMessage("CHARACTER MARKDOWN: Calling Settings.Initializer:Initialize() (after panel)...")
                    end
                    CM.Settings.Initializer:Initialize()
                    
                    -- Final check
                    zo_callLater(function()
                        if CHAT_SYSTEM then
                            CHAT_SYSTEM:AddMessage("CHARACTER MARKDOWN: FINAL CHECK - includeChampionPoints = " .. tostring(CharacterMarkdownSettings.includeChampionPoints))
                        end
                    end, 200)
                end
            end, 100)
        else
            -- Not ready yet, try again in 200ms
            zo_callLater(function() tryInitialize(attempt + 1) end, 200)
        end
    end
    
    -- Start first attempt after a short delay
    zo_callLater(function() tryInitialize(1) end, 100)
    
    d("=================================================")
    
    -- Unregister this event
    EVENT_MANAGER:UnregisterForEvent(CM.name, EVENT_ADD_ON_LOADED)
end

CM.events.OnAddOnLoaded = OnAddOnLoaded

-- =====================================================
-- EVENT REGISTRATION
-- =====================================================

local function RegisterEvents()
    d("[CharacterMarkdown] Events.lua: RegisterEvents() called")
    d("[CharacterMarkdown] Events.lua: Registering for EVENT_ADD_ON_LOADED with name '" .. tostring(CM.name) .. "'")
    EVENT_MANAGER:RegisterForEvent(CM.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
    d("[CharacterMarkdown] Events.lua: Event registered successfully")
end

CM.events.RegisterEvents = RegisterEvents

-- Auto-register events
d("[CharacterMarkdown] Events.lua: About to call RegisterEvents()...")
RegisterEvents()
d("[CharacterMarkdown] Events.lua: RegisterEvents() completed")
