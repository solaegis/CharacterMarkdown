-- CharacterMarkdown - Chat output via LibChatMessage (optional)
-- Prefer LibChatMessage so messages use the vanilla chat pipeline.
-- Falls back to colored d() when the library is not installed.

local CM = CharacterMarkdown

local TAG_COLOR_INFO = "FFFFFF"
local TAG_COLOR_WARN = "FFFF00"
local TAG_COLOR_ERROR = "FF0000"
local TAG_COLOR_SUCCESS = "00FF00"

local chatProxy = nil

local function IsLibChatMessageAvailable()
    return LibChatMessage ~= nil and type(LibChatMessage) == "function"
end

local function GetChatProxy()
    if chatProxy then
        return chatProxy
    end
    if not IsLibChatMessageAvailable() then
        return nil
    end
    local ok, proxy = pcall(LibChatMessage, "CharacterMarkdown", "CM")
    if ok and proxy then
        chatProxy = proxy
        return chatProxy
    end
    return nil
end

local function FallbackPrint(colorHex, prefix, text)
    d(string.format("|c%s[CharacterMarkdown]%s|r %s", colorHex, prefix or "", text))
end

local function PrintWithProxy(tagColor, prefix, text)
    local proxy = GetChatProxy()
    if proxy and proxy.SetTagColor and proxy.Print then
        local message = text
        if prefix and prefix ~= "" then
            message = prefix .. " " .. text
        end
        proxy:SetTagColor(tagColor):Print(message)
        return
    end
    FallbackPrint(tagColor, prefix, text)
end

local function PrintInfo(text)
    PrintWithProxy(TAG_COLOR_INFO, nil, text)
end

local function PrintWarn(text)
    PrintWithProxy(TAG_COLOR_WARN, "WARNING:", text)
end

local function PrintError(text)
    PrintWithProxy(TAG_COLOR_ERROR, "ERROR:", text)
end

local function PrintSuccess(text)
    PrintWithProxy(TAG_COLOR_SUCCESS, nil, text)
end

CM.utils = CM.utils or {}
CM.utils.chat = {
    IsLibChatMessageAvailable = IsLibChatMessageAvailable,
    GetChatProxy = GetChatProxy,
    PrintInfo = PrintInfo,
    PrintWarn = PrintWarn,
    PrintError = PrintError,
    PrintSuccess = PrintSuccess,
}

return CM.utils.chat
