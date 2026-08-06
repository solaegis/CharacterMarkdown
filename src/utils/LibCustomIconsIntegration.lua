-- CharacterMarkdown - LibCustomIcons Integration Helper
-- Safe wrapper for custom account icons. Gracefully degrades when unavailable.

local CM = CharacterMarkdown

local GITHUB_RAW_BASE = "https://raw.githubusercontent.com/m00nyONE/LibCustomIcons/main/"

local function IsLibCustomIconsAvailable()
    return LibCustomIcons ~= nil
        and type(LibCustomIcons) == "table"
        and type(LibCustomIcons.GetStatic) == "function"
end

--- Return texture path for the current (or given) @account, or nil.
-- GetStatic may return multiple values (path + UV coords); only the path is needed here.
local function GetStaticIconPath(displayName)
    if not IsLibCustomIconsAvailable() then
        return nil
    end

    displayName = displayName or (GetDisplayName and GetDisplayName()) or nil
    if not displayName or displayName == "" then
        return nil
    end

    local success, iconPath = pcall(LibCustomIcons.GetStatic, displayName)
    if not success or not iconPath or iconPath == "" then
        return nil
    end

    return iconPath
end

--- Relative path suitable for GitHub raw URLs (strip leading LibCustomIcons/).
local function GetRelativeIconPath(displayName)
    local iconPath = GetStaticIconPath(displayName)
    if not iconPath then
        return nil
    end
    return iconPath:gsub("^LibCustomIcons/", "")
end

--- Markdown image URL for the account's custom icon, or nil.
local function GetStaticIconUrl(displayName)
    local relativePath = GetRelativeIconPath(displayName)
    if not relativePath then
        return nil
    end
    return GITHUB_RAW_BASE .. relativePath
end

--- Markdown image snippet for character header, or empty string.
local function GetStaticIconMarkdown(displayName)
    local iconUrl = GetStaticIconUrl(displayName)
    if not iconUrl then
        return ""
    end
    return string.format("\n![Custom Icon](%s)\n\n", iconUrl)
end

CM.utils = CM.utils or {}
CM.utils.LibCustomIconsIntegration = {
    IsLibCustomIconsAvailable = IsLibCustomIconsAvailable,
    GetStaticIconPath = GetStaticIconPath,
    GetRelativeIconPath = GetRelativeIconPath,
    GetStaticIconUrl = GetStaticIconUrl,
    GetStaticIconMarkdown = GetStaticIconMarkdown,
}

return CM.utils.LibCustomIconsIntegration
