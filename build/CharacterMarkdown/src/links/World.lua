-- CharacterMarkdown - World Link Generators
-- UESP links for races, classes, alliances, zones, skill lines

local CM = CharacterMarkdown

-- =====================================================
-- RACE LINKS
-- =====================================================

local function GenerateRaceURL(raceName)
    if not raceName or raceName == "" or raceName == "Unknown" then
        return nil
    end
    local urlName = raceName:gsub(" ", "_")
    return "https://en.uesp.net/wiki/Online:" .. urlName
end

CM.links.GenerateRaceURL = GenerateRaceURL

local function CreateRaceLink(raceName, format)
    if not raceName or raceName == "" or raceName == "Unknown" then
        return raceName or "Unknown"
    end
    
    local settings = CharacterMarkdownSettings or {}
    if settings.enableAbilityLinks == false then
        return raceName
    end
    
    local url = GenerateRaceURL(raceName)
    if url and (format == "github" or format == "discord") then
        return "[" .. raceName .. "](" .. url .. ")"
    else
        return raceName
    end
end

CM.links.CreateRaceLink = CreateRaceLink

-- =====================================================
-- CLASS LINKS
-- =====================================================

local function GenerateClassURL(className)
    if not className or className == "" or className == "Unknown" then
        return nil
    end
    local urlName = className:gsub(" ", "_")
    return "https://en.uesp.net/wiki/Online:" .. urlName
end

CM.links.GenerateClassURL = GenerateClassURL

local function CreateClassLink(className, format)
    if not className or className == "" or className == "Unknown" then
        return className or "Unknown"
    end
    
    local settings = CharacterMarkdownSettings or {}
    if settings.enableAbilityLinks == false then
        return className
    end
    
    local url = GenerateClassURL(className)
    if url and (format == "github" or format == "discord") then
        return "[" .. className .. "](" .. url .. ")"
    else
        return className
    end
end

CM.links.CreateClassLink = CreateClassLink

-- =====================================================
-- ALLIANCE LINKS
-- =====================================================

local function GenerateAllianceURL(allianceName)
    if not allianceName or allianceName == "" or allianceName == "Unknown" then
        return nil
    end
    local urlName = allianceName:gsub(" ", "_")
    return "https://en.uesp.net/wiki/Online:" .. urlName
end

CM.links.GenerateAllianceURL = GenerateAllianceURL

local function CreateAllianceLink(allianceName, format)
    if not allianceName or allianceName == "" or allianceName == "Unknown" then
        return allianceName or "Unknown"
    end
    
    local settings = CharacterMarkdownSettings or {}
    if settings.enableAbilityLinks == false then
        return allianceName
    end
    
    local url = GenerateAllianceURL(allianceName)
    if url and (format == "github" or format == "discord") then
        return "[" .. allianceName .. "](" .. url .. ")"
    else
        return allianceName
    end
end

CM.links.CreateAllianceLink = CreateAllianceLink

-- =====================================================
-- ZONE LINKS
-- =====================================================

local function GenerateZoneURL(zoneName)
    if not zoneName or zoneName == "" or zoneName == "Unknown" then
        return nil
    end
    local urlName = zoneName:gsub(" ", "_")
    urlName = urlName:gsub("%(", "")
    urlName = urlName:gsub("%)", "")
    return "https://en.uesp.net/wiki/Online:" .. urlName
end

CM.links.GenerateZoneURL = GenerateZoneURL

local function CreateZoneLink(zoneName, format)
    if not zoneName or zoneName == "" or zoneName == "Unknown" then
        return zoneName or "Unknown"
    end
    
    local settings = CharacterMarkdownSettings or {}
    if settings.enableAbilityLinks == false then
        return zoneName
    end
    
    local url = GenerateZoneURL(zoneName)
    if url and (format == "github" or format == "discord") then
        return "[" .. zoneName .. "](" .. url .. ")"
    else
        return zoneName
    end
end

CM.links.CreateZoneLink = CreateZoneLink

-- =====================================================
-- SKILL LINE LINKS
-- =====================================================

local function GenerateSkillLineURL(skillLineName)
    if not skillLineName or skillLineName == "" then
        return nil
    end
    
    -- Special handling for certain skill line names
    local urlName = skillLineName
    
    -- Handle "Skills" suffix (e.g., "Imperial Skills" -> "Imperial")
    urlName = urlName:gsub(" Skills$", "")
    
    -- Replace spaces with underscores
    urlName = urlName:gsub(" ", "_")
    
    -- Handle special characters (keep apostrophes as-is, UESP accepts them)
    urlName = urlName:gsub("&", "and")
    
    return "https://en.uesp.net/wiki/Online:" .. urlName
end

CM.links.GenerateSkillLineURL = GenerateSkillLineURL

local function CreateSkillLineLink(skillLineName, format)
    if not skillLineName or skillLineName == "" then
        return skillLineName or ""
    end
    
    local settings = CharacterMarkdownSettings or {}
    if settings.enableAbilityLinks == false then
        return skillLineName
    end
    
    local url = GenerateSkillLineURL(skillLineName)
    if url and (format == "github" or format == "discord") then
        return "[" .. skillLineName .. "](" .. url .. ")"
    else
        return skillLineName
    end
end

CM.links.CreateSkillLineLink = CreateSkillLineLink
