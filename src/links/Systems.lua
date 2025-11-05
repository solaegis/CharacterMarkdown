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
    
    -- Check settings: if enableAbilityLinks is explicitly false, return plain text
    -- Try CM.settings first, then fallback to CharacterMarkdownSettings
    local settings = (CM and CM.settings) or CharacterMarkdownSettings or {}
    if settings and settings.enableAbilityLinks == false then
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
    
    -- Check settings: if enableAbilityLinks is explicitly false, return plain text
    local settings = CharacterMarkdownSettings or {}
    if settings and settings.enableAbilityLinks == false then
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
    
    -- Check settings: if enableAbilityLinks is explicitly false, return plain text
    local settings = CharacterMarkdownSettings or {}
    if settings and settings.enableAbilityLinks == false then
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
    
    -- Check settings: if enableAbilityLinks is explicitly false, return plain text
    local settings = CharacterMarkdownSettings or {}
    if settings and settings.enableAbilityLinks == false then
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

-- =====================================================
-- CURRENCY LINKS
-- =====================================================

local function GenerateCurrencyURL(currencyName)
    if not currencyName or currencyName == "" then
        return nil
    end
    
    -- Map currency names to UESP URLs
    local currencyMap = {
        ["Gold"] = "https://en.uesp.net/wiki/Online:Gold",
        ["Gold (On Hand)"] = "https://en.uesp.net/wiki/Online:Gold",
        ["Gold (Bank)"] = "https://en.uesp.net/wiki/Online:Gold",
        ["Gold (Total)"] = "https://en.uesp.net/wiki/Online:Gold",
        ["Alliance Points"] = "https://en.uesp.net/wiki/Online:Alliance_Points",
        ["AP"] = "https://en.uesp.net/wiki/Online:Alliance_Points",
        ["Tel Var Stones"] = "https://en.uesp.net/wiki/Online:Tel_Var_Stones",
        ["Tel Var"] = "https://en.uesp.net/wiki/Online:Tel_Var_Stones",
        ["Transmute Crystals"] = "https://en.uesp.net/wiki/Online:Transmute_Crystals",
        ["Crystals"] = "https://en.uesp.net/wiki/Online:Transmute_Crystals",
        ["Event Tickets"] = "https://en.uesp.net/wiki/Online:Event_Tickets",
        ["Tickets"] = "https://en.uesp.net/wiki/Online:Event_Tickets",
        ["Writs"] = "https://en.uesp.net/wiki/Online:Writ_Vouchers",
        ["Crowns"] = "https://en.uesp.net/wiki/Online:Crowns",
        ["Crown Gems"] = "https://en.uesp.net/wiki/Online:Crown_Gems",
        ["Seals of Endeavor"] = "https://en.uesp.net/wiki/Online:Seals_of_Endeavor",
    }
    
    -- Check if we have a direct mapping
    if currencyMap[currencyName] then
        return currencyMap[currencyName]
    end
    
    -- Fallback: try to construct URL from name
    local urlName = currencyName:gsub(" ", "_")
    urlName = urlName:gsub("[%(%)%[%]%{%}]", "")
    return "https://en.uesp.net/wiki/Online:" .. urlName
end

CM.links.GenerateCurrencyURL = GenerateCurrencyURL

local function CreateCurrencyLink(currencyName, format)
    if not currencyName or currencyName == "" then
        return currencyName or ""
    end
    
    -- Check settings: if enableAbilityLinks is explicitly false, return plain text
    -- Try CM.settings first, then fallback to CharacterMarkdownSettings
    local settings = (CM and CM.settings) or CharacterMarkdownSettings or {}
    if settings and settings.enableAbilityLinks == false then
        return currencyName
    end
    
    local url = GenerateCurrencyURL(currencyName)
    if url and (format == "github" or format == "discord") then
        return "[" .. currencyName .. "](" .. url .. ")"
    else
        return currencyName
    end
end

CM.links.CreateCurrencyLink = CreateCurrencyLink

-- =====================================================
-- COLLECTIBLE LINKS
-- =====================================================

local function GenerateCollectibleURL(collectibleName)
    if not collectibleName or collectibleName == "" then
        return nil
    end
    
    -- UESP format for collectibles: https://en.uesp.net/wiki/Online:Collectible_Name
    -- Replace spaces with underscores and remove special characters that break URLs
    local urlName = collectibleName:gsub(" ", "_")
    -- Remove parentheses, brackets, and braces that might cause URL issues
    urlName = urlName:gsub("[%(%)%[%]%{%}]", "")
    -- Note: Hyphens and apostrophes are kept as UESP accepts them in URLs
    
    return "https://en.uesp.net/wiki/Online:" .. urlName
end

CM.links.GenerateCollectibleURL = GenerateCollectibleURL

local function CreateCollectibleLink(collectibleName, format)
    if not collectibleName or collectibleName == "" then
        return collectibleName or ""
    end
    
    -- Check settings: if enableAbilityLinks is explicitly false, return plain text
    -- Try CM.settings first, then fallback to CharacterMarkdownSettings
    local settings = (CM and CM.settings) or CharacterMarkdownSettings or {}
    if settings and settings.enableAbilityLinks == false then
        return collectibleName
    end
    
    local url = GenerateCollectibleURL(collectibleName)
    if url and (format == "github" or format == "discord") then
        return "[" .. collectibleName .. "](" .. url .. ")"
    else
        return collectibleName
    end
end

CM.links.CreateCollectibleLink = CreateCollectibleLink
