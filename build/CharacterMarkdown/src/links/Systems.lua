-- CharacterMarkdown - System Link Generators
-- UESP links for mundus stones, champion points, campaigns, buffs

local CM = CharacterMarkdown

-- =====================================================
-- MUNDUS STONE LINKS
-- =====================================================

local function GenerateMundusURL(mundusName)
    if not mundusName or mundusName == "" or mundusName == "Unknown" then
        return nil
    end
    local urlName = mundusName:gsub(" ", "_")
    return "https://en.uesp.net/wiki/Online:" .. urlName .. "_(Mundus_Stone)"
end

CM.links.GenerateMundusURL = GenerateMundusURL

local function CreateMundusLink(mundusName, format)
    if not mundusName or mundusName == "" or mundusName == "Unknown" then
        return mundusName or "Unknown"
    end
    
    local settings = CharacterMarkdownSettings or {}
    if settings.enableAbilityLinks == false then
        return mundusName
    end
    
    local url = GenerateMundusURL(mundusName)
    if url and (format == "github" or format == "discord") then
        return "[" .. mundusName .. "](" .. url .. ")"
    else
        return mundusName
    end
end

CM.links.CreateMundusLink = CreateMundusLink

-- =====================================================
-- CHAMPION POINT SKILL LINKS
-- =====================================================

local function GenerateCPSkillURL(skillName)
    if not skillName or skillName == "" then
        return nil
    end
    local urlName = skillName:gsub(" ", "_")
    -- Keep apostrophes as-is (UESP accepts them in URLs)
    return "https://en.uesp.net/wiki/Online:" .. urlName
end

CM.links.GenerateCPSkillURL = GenerateCPSkillURL

local function CreateCPSkillLink(skillName, format)
    if not skillName or skillName == "" then
        return skillName or ""
    end
    
    local settings = CharacterMarkdownSettings or {}
    if settings.enableAbilityLinks == false then
        return skillName
    end
    
    local url = GenerateCPSkillURL(skillName)
    if url and (format == "github" or format == "discord") then
        return "[" .. skillName .. "](" .. url .. ")"
    else
        return skillName
    end
end

CM.links.CreateCPSkillLink = CreateCPSkillLink

-- =====================================================
-- CAMPAIGN LINKS
-- =====================================================

local function GenerateCampaignURL(campaignName)
    if not campaignName or campaignName == "" or campaignName == "None" then
        return nil
    end
    local urlName = campaignName:gsub(" ", "_")
    return "https://en.uesp.net/wiki/Online:Campaigns#" .. urlName
end

CM.links.GenerateCampaignURL = GenerateCampaignURL

local function CreateCampaignLink(campaignName, format)
    if not campaignName or campaignName == "" or campaignName == "None" then
        return campaignName or "None"
    end
    
    local settings = CharacterMarkdownSettings or {}
    if settings.enableAbilityLinks == false then
        return campaignName
    end
    
    local url = GenerateCampaignURL(campaignName)
    if url and (format == "github" or format == "discord") then
        return "[" .. campaignName .. "](" .. url .. ")"
    else
        return campaignName
    end
end

CM.links.CreateCampaignLink = CreateCampaignLink

-- =====================================================
-- BUFF/EFFECT LINKS
-- =====================================================

local function GenerateBuffURL(buffName)
    if not buffName or buffName == "" then
        return nil
    end
    
    -- Special cases for vampire/werewolf
    if buffName:find("Vampir") or buffName:find("Stage %d") then
        return "https://en.uesp.net/wiki/Online:Vampire"
    end
    if buffName:find("Lycanthropy") or buffName:find("Werewolf") then
        return "https://en.uesp.net/wiki/Online:Werewolf"
    end
    
    -- Standard effect page
    local urlName = buffName:gsub(" ", "_")
    urlName = urlName:gsub("[%(%)%[%]%{%}]", "")
    return "https://en.uesp.net/wiki/Online:" .. urlName
end

CM.links.GenerateBuffURL = GenerateBuffURL

local function CreateBuffLink(buffName, format)
    if not buffName or buffName == "" then
        return buffName or ""
    end
    
    local settings = CharacterMarkdownSettings or {}
    if settings.enableAbilityLinks == false then
        return buffName
    end
    
    local url = GenerateBuffURL(buffName)
    if url and (format == "github" or format == "discord") then
        return "[" .. buffName .. "](" .. url .. ")"
    else
        return buffName
    end
end

CM.links.CreateBuffLink = CreateBuffLink
