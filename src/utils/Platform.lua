-- CharacterMarkdown - Platform Detection
-- Detects operating system based on file paths

local CM = CharacterMarkdown

CM.utils = CM.utils or {}

-- Detect OS based on saved variables path structure
local function DetectOperatingSystem(forceRedetect)
    local settings = CM.GetSettings()
    
    -- Get the path first to verify cached OS if it exists
    local svPath = GetAddOnSavedVariablesDirectory and GetAddOnSavedVariablesDirectory()
    
    -- Quick verification: if we have a cached OS and a path, verify they match
    if not forceRedetect and settings and settings.detectedOS and settings.detectedOS ~= "unknown" and svPath then
        local cachedOS = settings.detectedOS
        -- Quick check: does the path match the cached OS?
        local startsWithSlash = string.sub(svPath, 1, 1) == "/"
        local hasMacUsersPath = string.find(svPath, "/Users/", 1, true) ~= nil
        local hasMacDocumentsPath = string.find(svPath, "/Documents/", 1, true) ~= nil
        local hasWindowsBackslashes = string.find(svPath, "\\Users\\", 1, true) ~= nil or string.find(svPath, "\\Documents\\", 1, true) ~= nil
        local startsWithWindowsDrive = string.find(svPath, "^[A-Z]:\\", 1, false) ~= nil
        
        -- Check for forward slashes vs backslashes
        local hasForwardSlashes = string.find(svPath, "/", 1, true) ~= nil
        local hasBackslashes = string.find(svPath, "\\", 1, true) ~= nil
        
        local pathSuggestsMac = startsWithSlash or hasMacUsersPath or hasMacDocumentsPath or (hasForwardSlashes and not hasBackslashes)
        local pathSuggestsWindows = startsWithWindowsDrive or hasWindowsBackslashes or (hasBackslashes and not hasForwardSlashes)
        
        -- CRITICAL: If path clearly suggests Mac (starts with /) but cached OS is Windows, force re-detection
        -- This catches the common case where Mac was incorrectly detected as Windows
        if startsWithSlash and cachedOS == "windows" then
            CM.DebugPrint("PLATFORM", string.format("Path starts with / (Mac) but cached OS is Windows, forcing re-detection. Path: %s", svPath))
            forceRedetect = true
        -- If cached OS doesn't match path, force re-detection
        elseif (cachedOS == "mac" and pathSuggestsWindows) or (cachedOS == "windows" and pathSuggestsMac) then
            CM.DebugPrint("PLATFORM", string.format("Cached OS (%s) doesn't match path, forcing re-detection. Path: %s", cachedOS, svPath))
            forceRedetect = true
        elseif (cachedOS == "mac" and pathSuggestsMac) or (cachedOS == "windows" and pathSuggestsWindows) then
            -- Cached OS matches path, return it
            CM.DebugPrint("PLATFORM", string.format("Cached OS (%s) matches path, using cached value", cachedOS))
            return cachedOS
        else
            -- Path is ambiguous, but we have a cached value - verify it's still valid
            CM.DebugPrint("PLATFORM", string.format("Path is ambiguous, but using cached OS: %s", cachedOS))
            return cachedOS
        end
    end
    
    -- Check if already detected and saved (unless forcing re-detection)
    if not forceRedetect and settings and settings.detectedOS and settings.detectedOS ~= "unknown" then
        return settings.detectedOS
    end
    
    -- Try to auto-detect based on filesystem path
    local detectedOS = "unknown"
    
    -- GetAddOnSavedVariablesDirectory() returns paths like:
    -- Mac:     /Users/username/Documents/Elder Scrolls Online/live/SavedVariables/
    -- Windows: C:\Users\username\Documents\Elder Scrolls Online\live\SavedVariables\
    if not svPath then
        svPath = GetAddOnSavedVariablesDirectory and GetAddOnSavedVariablesDirectory()
    end
    
    CM.DebugPrint("PLATFORM", "GetAddOnSavedVariablesDirectory function exists: " .. tostring(GetAddOnSavedVariablesDirectory ~= nil))
    CM.DebugPrint("PLATFORM", "SavedVariables path: " .. tostring(svPath))
    
    if svPath then
        -- Mac paths start with / and use forward slashes
        -- Check if path starts with / (Unix/Mac style) or contains /Users/ with forward slashes
        local startsWithSlash = string.sub(svPath, 1, 1) == "/"
        local hasMacUsersPath = string.find(svPath, "/Users/", 1, true) ~= nil
        local hasMacDocumentsPath = string.find(svPath, "/Documents/", 1, true) ~= nil
        
        -- Windows paths typically start with C:\ or use backslashes
        local startsWithWindowsDrive = string.find(svPath, "^[A-Z]:\\", 1, false) ~= nil  -- Pattern mode for drive letter
        local hasWindowsBackslashes = string.find(svPath, "\\Users\\", 1, true) ~= nil or string.find(svPath, "\\Documents\\", 1, true) ~= nil
        
        -- Prioritize Mac detection - check Mac patterns first
        if startsWithSlash or hasMacUsersPath or hasMacDocumentsPath then
            detectedOS = "mac"
            CM.DebugPrint("PLATFORM", "Auto-detected Mac from path: " .. svPath)
        elseif startsWithWindowsDrive or hasWindowsBackslashes then
            detectedOS = "windows"
            CM.DebugPrint("PLATFORM", "Auto-detected Windows from path: " .. svPath)
        else
            -- If we can't determine, check if path contains forward slashes (more likely Mac)
            -- or backslashes (more likely Windows)
            local hasForwardSlashes = string.find(svPath, "/", 1, true) ~= nil
            local hasBackslashes = string.find(svPath, "\\", 1, true) ~= nil
            
            if hasForwardSlashes and not hasBackslashes then
                detectedOS = "mac"
                CM.DebugPrint("PLATFORM", "Auto-detected Mac from forward slashes in path: " .. svPath)
            elseif hasBackslashes and not hasForwardSlashes then
                detectedOS = "windows"
                CM.DebugPrint("PLATFORM", "Auto-detected Windows from backslashes in path: " .. svPath)
            else
                -- Last resort: default to unknown instead of assuming Windows
                detectedOS = "unknown"
                CM.DebugPrint("PLATFORM", "Could not detect OS from path: " .. svPath)
            end
        end
    else
        -- Fallback if API not available - don't assume Windows
        detectedOS = "unknown"
        CM.DebugPrint("PLATFORM", "GetAddOnSavedVariablesDirectory not available, cannot detect OS")
    end
    
    -- Save the detected OS (and verify it matches cached value if it exists)
    if settings then
        local previousOS = settings.detectedOS
        settings.detectedOS = detectedOS
        
        if previousOS and previousOS ~= "unknown" and previousOS ~= detectedOS then
            CM.Info(string.format("OS auto-detected: %s (was previously: %s)", detectedOS, previousOS))
        else
            CM.Info("OS auto-detected: " .. detectedOS)
        end
    end
    
    return detectedOS
end

-- Get keyboard shortcut text for current OS
local function GetShortcutText(action)
    local os = DetectOperatingSystem()
    
    CM.DebugPrint("PLATFORM", string.format("GetShortcutText called: action=%s, os=%s", tostring(action), tostring(os)))
    
    if action == "select_all" then
        if os == "mac" then
            return "Cmd+A"
        else
            return "Ctrl+A"
        end
    elseif action == "copy" then
        if os == "mac" then
            return "Cmd+C"
        else
            return "Ctrl+C"
        end
    elseif action == "paste" then
        if os == "mac" then
            return "Cmd+V"
        else
            return "Ctrl+V"
        end
    elseif action == "select_copy" then
        if os == "mac" then
            return "Cmd+A then Cmd+C"
        else
            return "Ctrl+A then Ctrl+C"
        end
    end
    
    return ""
end

-- Allow manual OS override (useful for initial setup or if detection fails)
local function SetOperatingSystem(os)
    if os ~= "windows" and os ~= "mac" then
        CM.Error("Invalid OS. Use 'windows' or 'mac'")
        return false
    end
    
    local settings = CM.GetSettings()
    if settings then
        settings.detectedOS = os
        CM.Info("OS set to: " .. os)
        return true
    end
    
    return false
end

-- Reset cached OS detection to force re-detection
local function ResetOperatingSystem()
    local settings = CM.GetSettings()
    if settings then
        settings.detectedOS = "unknown"
        CM.Info("OS detection reset - re-detecting...")
        -- Force immediate re-detection
        return DetectOperatingSystem(true) ~= "unknown"
    end
    return false
end

CM.utils.Platform = {
    DetectOperatingSystem = DetectOperatingSystem,
    GetShortcutText = GetShortcutText,
    SetOperatingSystem = SetOperatingSystem,
    ResetOperatingSystem = ResetOperatingSystem,
}

