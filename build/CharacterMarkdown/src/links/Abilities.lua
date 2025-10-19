-- CharacterMarkdown - Ability Link Generators
-- UESP links for abilities and skills

local CM = CharacterMarkdown

-- =====================================================
-- ABILITY LINKS
-- =====================================================

-- Generate UESP URL for ability
local function GenerateAbilityURL(abilityName, abilityId)
    if not abilityName or abilityName == "[Empty]" or abilityName == "[Empty Slot]" then
        return nil
    end
    
    -- UESP format: https://en.uesp.net/wiki/Online:Ability_Name
    -- Strip rank suffixes (I, II, III, IV) from the end
    local urlName = abilityName
    urlName = urlName:gsub("%s+IV$", "")   -- Remove " IV" at end
    urlName = urlName:gsub("%s+III$", "")  -- Remove " III" at end
    urlName = urlName:gsub("%s+II$", "")   -- Remove " II" at end
    urlName = urlName:gsub("%s+I$", "")    -- Remove " I" at end
    
    -- Replace spaces with underscores, handle special characters
    urlName = urlName:gsub(" ", "_")
    -- Remove problematic characters
    urlName = urlName:gsub("[%(%)%[%]%{%}]", "")
    
    return "https://en.uesp.net/wiki/Online:" .. urlName
end

CM.links.GenerateAbilityURL = GenerateAbilityURL

-- Create markdown link for ability
local function CreateAbilityLink(abilityName, abilityId, format)
    if not abilityName or abilityName == "[Empty]" or abilityName == "[Empty Slot]" then
        return abilityName or "[Empty]"
    end
    
    -- Check settings
    local settings = CharacterMarkdownSettings or {}
    if settings.enableAbilityLinks == false then
        return abilityName
    end
    
    local url = GenerateAbilityURL(abilityName, abilityId)
    
    if url and (format == "github" or format == "discord") then
        return "[" .. abilityName .. "](" .. url .. ")"
    else
        return abilityName
    end
end

CM.links.CreateAbilityLink = CreateAbilityLink
