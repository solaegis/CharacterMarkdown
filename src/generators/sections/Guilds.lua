-- CharacterMarkdown - Guilds Section Generator
-- Generates guild membership information markdown sections

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local FormatNumber, GenerateAnchor

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        FormatNumber = CM.utils.FormatNumber
        GenerateAnchor = CM.utils and CM.utils.markdown and CM.utils.markdown.GenerateAnchor
    end
end

-- =====================================================
-- GUILDS
-- =====================================================

local function GenerateGuilds(guildsData, format, undauntedPledgesData)
    InitializeUtilities()
    
    local markdown = ""
    
    if not guildsData or #guildsData == 0 then
        -- Show placeholder when enabled but no data available
        if format ~= "discord" then
            local anchorId = GenerateAnchor and GenerateAnchor("🏰 Guild Membership") or "guild-membership"
            markdown = markdown .. string.format('<a id="%s"></a>\n\n', anchorId)
            markdown = markdown .. "## 🏰 Guild Membership\n\n"  -- Changed from 🏛️ for better compatibility
            markdown = markdown .. "*No guild data available*\n\n"
            
            -- Still show Undaunted Pledges subsection even if no guilds
            if undauntedPledgesData and undauntedPledgesData.pledges and undauntedPledgesData.pledges.active and #undauntedPledgesData.pledges.active > 0 then
                markdown = markdown .. GenerateUndauntedActivePledges(undauntedPledgesData, format)
            end
            
            markdown = markdown .. "---\n\n"
        end
        return markdown
    end
    
    if format == "discord" then
        markdown = markdown .. "**Guilds:**\n"
        
        for _, guild in ipairs(guildsData) do
            markdown = markdown .. "• " .. guild.name
            if guild.rank and guild.rank ~= "" then
                markdown = markdown .. " - " .. guild.rank
            end
            if guild.memberCount and guild.memberCount > 0 then
                markdown = markdown .. " (" .. FormatNumber(guild.memberCount) .. " members)"
            end
            markdown = markdown .. "\n"
        end
        
        markdown = markdown .. "\n"
    else
        local anchorId = GenerateAnchor and GenerateAnchor("🏰 Guild Membership") or "guild-membership"
        markdown = markdown .. string.format('<a id="%s"></a>\n\n', anchorId)
        markdown = markdown .. "## 🏰 Guild Membership\n\n"  -- Changed from 🏛️ for better compatibility
        
        if #guildsData > 0 then
            markdown = markdown .. "| Guild Name | Rank | Members | Alliance |\n"
            markdown = markdown .. "|:-----------|:-----|:--------|:---------|\n"
            
            local CreateAllianceLink = CM.links and CM.links.CreateAllianceLink
            for _, guild in ipairs(guildsData) do
                local allianceName = guild.alliance or "Cross-Alliance"
                -- Only link actual alliances (not "Cross-Alliance")
                local allianceText = allianceName
                if allianceName ~= "Cross-Alliance" and allianceName ~= "" then
                    allianceText = (CreateAllianceLink and CreateAllianceLink(allianceName, format)) or allianceName
                end
                
                markdown = markdown .. "| **" .. (guild.name or "Unknown") .. "** | "
                markdown = markdown .. (guild.rank or "Member") .. " | "
                markdown = markdown .. (guild.memberCount and FormatNumber(guild.memberCount) or "0") .. " | "
                markdown = markdown .. allianceText .. " |\n"
            end
            
            markdown = markdown .. "\n"
        end
        
        -- Add Undaunted Active Pledges as subsection
        if undauntedPledgesData and undauntedPledgesData.pledges and undauntedPledgesData.pledges.active and #undauntedPledgesData.pledges.active > 0 then
            markdown = markdown .. GenerateUndauntedActivePledges(undauntedPledgesData, format)
        end
        
        markdown = markdown .. "---\n\n"
    end
    
    return markdown
end

-- =====================================================
-- UNDAUNTED ACTIVE PLEDGES (Subsection)
-- =====================================================

local function GenerateUndauntedActivePledges(undauntedPledgesData, format)
    if format == "discord" then
        return ""  -- Don't show in Discord format as subsection
    end
    
    local markdown = ""
    local pledges = undauntedPledgesData.pledges or {}
    
    if not pledges.active or #pledges.active == 0 then
        return ""
    end
    
    markdown = markdown .. "### 📋 Undaunted Active Pledges\n\n"
    
    local CreateZoneLink = CM.links and CM.links.CreateZoneLink
    for _, pledge in ipairs(pledges.active) do
        -- Parse pledge name: "Pledge: Darkshade II - Deshaan" -> extract dungeon and zone
        local pledgeText = pledge.name or ""
        local locationText = pledge.location or ""
        
        -- Extract dungeon name (part after "Pledge: " and before " - ")
        local dungeonName = pledgeText
        if pledgeText:find("Pledge: ") and pledgeText:find(" - ") then
            -- Format: "Pledge: DUNGEON - ZONE"
            dungeonName = pledgeText:match("Pledge: (.+) %-") or pledgeText:gsub("^Pledge: ", ""):match("(.+) %-") or pledgeText:gsub("^Pledge: ", "")
        elseif pledgeText:find("Pledge: ") then
            -- Format: "Pledge: DUNGEON" (no location separator)
            dungeonName = pledgeText:gsub("^Pledge: ", "")
        end
        
        -- Clean up dungeon name
        dungeonName = dungeonName:gsub("^%s+", ""):gsub("%s+$", "")
        
        -- Create links for dungeon and location
        local dungeonLink = (CreateZoneLink and CreateZoneLink(dungeonName, format)) or dungeonName
        local locationLink = ""
        if locationText ~= "" then
            locationLink = (CreateZoneLink and CreateZoneLink(locationText, format)) or locationText
        elseif pledgeText:find(" - ") then
            -- Extract zone from pledge name if location field is empty
            local zoneName = pledgeText:match("%- (.+)$")
            if zoneName then
                zoneName = zoneName:gsub("^%s+", ""):gsub("%s+$", "")
                locationLink = (CreateZoneLink and CreateZoneLink(zoneName, format)) or zoneName
            end
        end
        
        markdown = markdown .. "- Pledge: " .. dungeonLink
        if locationLink ~= "" and locationLink ~= dungeonLink then
            markdown = markdown .. " - " .. locationLink
        end
        markdown = markdown .. "\n"
    end
    
    markdown = markdown .. "\n"
    
    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateGuilds = GenerateGuilds

return {
    GenerateGuilds = GenerateGuilds,
}

