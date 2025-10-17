-- CharacterMarkdown - Companion Link Generators
-- UESP links for companions

local CM = CharacterMarkdown

-- =====================================================
-- COMPANION LINKS
-- =====================================================

local function GenerateCompanionURL(companionName)
    if not companionName or companionName == "" or companionName == "Unknown" or companionName == "Unknown Companion" then
        return nil
    end
    
    -- Replace spaces with underscores
    local urlName = companionName:gsub(" ", "_")
    
    -- Handle special characters (keep apostrophes and hyphens as-is, UESP accepts them)
    
    return "https://en.uesp.net/wiki/Online:" .. urlName
end

CM.links.GenerateCompanionURL = GenerateCompanionURL

local function CreateCompanionLink(companionName, format)
    if not companionName or companionName == "" or companionName == "Unknown" or companionName == "Unknown Companion" then
        return companionName or "Unknown"
    end
    
    local settings = CharacterMarkdownSettings or {}
    if settings.enableAbilityLinks == false then
        return companionName
    end
    
    local url = GenerateCompanionURL(companionName)
    if url and (format == "github" or format == "discord") then
        return "[" .. companionName .. "](" .. url .. ")"
    else
        return companionName
    end
end

CM.links.CreateCompanionLink = CreateCompanionLink
