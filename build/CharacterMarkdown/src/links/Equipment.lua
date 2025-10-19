-- CharacterMarkdown - Equipment Link Generators
-- UESP links for sets and equipment

local CM = CharacterMarkdown

-- =====================================================
-- SET LINKS
-- =====================================================

-- Generate UESP URL for set
local function GenerateSetURL(setName)
    if not setName or setName == "-" or setName == "" then
        return nil
    end
    
    -- UESP format: https://en.uesp.net/wiki/Online:Set_Name_Set
    local urlName = setName:gsub(" ", "_")
    urlName = urlName:gsub("[%(%)%[%]%{%}]", "")
    
    return "https://en.uesp.net/wiki/Online:" .. urlName .. "_Set"
end

CM.links.GenerateSetURL = GenerateSetURL

-- Create markdown link for set
local function CreateSetLink(setName, format)
    if not setName or setName == "-" or setName == "" then
        return setName or "-"
    end
    
    -- Check settings
    local settings = CharacterMarkdownSettings or {}
    if settings.enableSetLinks == false then
        return setName
    end
    
    local url = GenerateSetURL(setName)
    
    if url and (format == "github" or format == "discord") then
        return "[" .. setName .. "](" .. url .. ")"
    else
        return setName
    end
end

CM.links.CreateSetLink = CreateSetLink
