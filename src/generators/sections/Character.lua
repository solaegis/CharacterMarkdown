-- CharacterMarkdown - Character Section Generators
-- Generates character identity, overview, and header sections

local CM = CharacterMarkdown
CM.generators = CM.generators or {}
CM.generators.sections = CM.generators.sections or {}

local string_format = string.format
local table_concat = table.concat

-- Import advanced markdown utilities (with nil check)
local markdown = (CM.utils and CM.utils.markdown) or nil

-- =====================================================
-- QUICK SUMMARY (One-line format)
-- =====================================================

local function GenerateQuickSummary(charData, equipmentData)
    if not charData then return "ERROR: No character data" end
    
    local name = charData.name or "Unknown"
    local level = charData.level or 1
    -- Fix: Use correct field name (cp, not championPoints)
    local cp = charData.cp or 0
    local race = charData.race or "Unknown"
    local class = charData.class or "Unknown"
    
    -- Get top 2 sets
    local sets = {}
    if equipmentData and equipmentData.sets then
        for setName, count in pairs(equipmentData.sets) do
            if count >= 2 then
                table.insert(sets, string_format("%s(%d)", setName, count))
            end
        end
        table.sort(sets, function(a, b) 
            local countA = tonumber(a:match("%((%d+)%)"))
            local countB = tonumber(b:match("%((%d+)%)"))
            return countA > countB
        end)
    end
    
    local setStr = #sets > 0 and (" • " .. table_concat({sets[1], sets[2]}, ", ")) or ""
    
    return string_format("%s • L%d CP%d • %s %s%s", 
        name, level, cp, race, class, setStr)
end

CM.generators.sections.GenerateQuickSummary = GenerateQuickSummary

-- =====================================================
-- ENHANCED HEADER with Badges
-- =====================================================

local function GenerateHeader(charData, format)
    if not charData then return "# Unknown Character\n\n" end
    
    local enhanced = CM.settings and CM.settings.enableEnhancedVisuals
    
    local name = charData.name or "Unknown"
    local title = charData.title or ""
    local race = charData.race or "Unknown"
    local class = charData.class or "Unknown"
    local alliance = charData.alliance or "Unknown"
    local level = charData.level or 1
    -- Fix: Use correct field name (cp, not championPoints)
    local cp = charData.cp or 0
    local isESOPlus = charData.esoPlus or false
    
    -- Use character name as H1, append title if set (format: "Name" or "Name (Title)")
    local displayTitle = name
    if title ~= "" then
        displayTitle = string_format("%s (%s)", name, title)
    end
    
    if not enhanced or format == "discord" or not markdown then
        -- Classic format
        local header = string_format("# %s\n\n", displayTitle)
        header = header .. string_format("**%s %s**  \n", race, class)
        header = header .. string_format("**Level %d • CP %d • %s**\n\n", level, cp, alliance)
        if isESOPlus then
            header = header .. "✨ *ESO Plus Active*\n\n"
        end
        return header
    end
    
    -- ENHANCED FORMAT with badges (with nil checks)
    if not markdown.CreateBadgeRow or not markdown.CreateCenteredBlock then
        -- Fallback to classic if functions don't exist
        local header = string_format("# %s\n\n", displayTitle)
        header = header .. string_format("**%s %s**  \n", race, class)
        header = header .. string_format("**Level %d • CP %d • %s**\n\n", level, cp, alliance)
        return header
    end
    
    local badges = {
        {label = "Level", value = level, color = "blue"},
        {label = "CP", value = cp, color = "purple"},
        {label = "Class", value = class:gsub(" ", "_"), color = "green"},
    }
    
    if isESOPlus then
        table.insert(badges, {label = "ESO+", value = "Active", color = "gold"})
    end
    
    local badgeRow = markdown.CreateBadgeRow(badges) or ""
    
    local header = markdown.CreateCenteredBlock(string_format([[
# %s

%s

**%s %s • %s Alliance**
]], displayTitle, badgeRow, race, class, alliance)) or string_format("# %s\n\n**%s %s • %s Alliance**\n\n", displayTitle, race, class, alliance)
    
    header = header .. "---\n\n"
    
    return header
end

CM.generators.sections.GenerateHeader = GenerateHeader

-- =====================================================
-- QUICK STATS (At-a-glance info box)
-- =====================================================

local function GenerateQuickStats(charData, statsData, format, equipmentData, progressionData, currencyData, cpData, inventoryData, locationData)
    if not charData then return "" end
    if format == "discord" then return "" end -- Skip for Discord
    
    local enhanced = CM.settings and CM.settings.enableEnhancedVisuals
    local formatNumber = CM.utils and CM.utils.FormatNumber
    local safeFormat = function(val)
        if formatNumber then
            return formatNumber(val)
        else
            return tostring(val)
        end
    end
    
    local level = charData.level or 1
    local cp = charData.cp or 0
    
    -- Build type determination (from attributes)
    local buildType = "Unknown"
    local attrs = charData.attributes or {}
    local magicka = attrs.magicka or 0
    local health = attrs.health or 0
    local stamina = attrs.stamina or 0
    if magicka > health and magicka > stamina then
        buildType = "Magicka DPS"
    elseif stamina > magicka and stamina > health then
        buildType = "Stamina DPS"
    elseif health > magicka and health > stamina then
        buildType = "Tank"
    elseif magicka > 0 and stamina > 0 then
        buildType = "Hybrid"
    end
    
    -- Race/Class/Alliance with links for Build field
    local CreateRaceLink = CM.links and CM.links.CreateRaceLink
    local CreateClassLink = CM.links and CM.links.CreateClassLink
    local CreateAllianceLink = CM.links and CM.links.CreateAllianceLink
    local CreateZoneLink = CM.links and CM.links.CreateZoneLink
    
    local raceLink = (CreateRaceLink and CreateRaceLink(charData.race, format)) or (charData.race or "Unknown")
    local classLink = (CreateClassLink and CreateClassLink(charData.class, format)) or (charData.class or "Unknown")
    local allianceLink = (CreateAllianceLink and CreateAllianceLink(charData.alliance, format)) or (charData.alliance or "Unknown")
    
    -- Format Build: [Race](link) [Class](link) BuildType
    local buildStr = string_format("%s %s %s", raceLink, classLink, buildType)
    
    -- Location formatting
    local locationStr = ""
    if locationData then
        local zone = locationData.zone or "Unknown"
        local subzone = locationData.subzone
        local zoneIndex = locationData.zoneIndex or 0
        
        local zoneLinkText = (CreateZoneLink and CreateZoneLink(zone, format)) or zone
        
        locationStr = zoneLinkText
        if subzone and subzone ~= "" then
            locationStr = string_format("%s (%s)", locationStr, subzone)
        elseif zoneIndex and zoneIndex > 0 then
            locationStr = string_format("%s (%d)", locationStr, zoneIndex)
        end
    end
    
    -- CP breakdown (similar to Attributes format)
    -- Always show breakdown format - matches Attributes display style
    local cp1 = 0  -- Warfare
    local cp2 = 0  -- Fitness
    local cp3 = 0  -- Craft
    
    if cpData then
        -- Disciplines are stored as an array, not an object
        if cpData.disciplines and #cpData.disciplines > 0 then
            for _, discipline in ipairs(cpData.disciplines) do
                local name = discipline.name or ""
                local total = discipline.total or 0
                if name == "Warfare" then
                    cp1 = total
                elseif name == "Fitness" then
                    cp2 = total
                elseif name == "Craft" then
                    cp3 = total
                end
            end
        end
        
        -- If we have spent CP but no discipline breakdown, estimate equal distribution
        if (cp1 == 0 and cp2 == 0 and cp3 == 0) and cpData.spent and cpData.spent > 0 then
            local spent = cpData.spent or 0
            local perDiscipline = math.floor(spent / 3)
            cp1 = perDiscipline
            cp2 = perDiscipline
            cp3 = perDiscipline
        end
    end
    
    -- ALWAYS show breakdown format (like Attributes) - unconditional
    -- This ensures consistency with the Attributes display format
    -- Use emojis: ⚒️ Craft / ⚔️ Warfare / 💪 Fitness
    -- Order: Craft, Warfare, Fitness (cp3, cp1, cp2)
    -- Format: ⚒️ (assigned of total) / ⚔️ (assigned of total) / 💪 (assigned of total)
    local cpTotal = 0
    if cpData and cpData.total then
        cpTotal = cpData.total or 0
    elseif cp then
        cpTotal = cp  -- Fallback to character CP if available
    end
    
    local cpDisplayValue = string_format("⚒️ (%d of %d) / ⚔️ (%d of %d) / 💪 (%d of %d)", 
        cp3, cpTotal, cp1, cpTotal, cp2, cpTotal)
    
    -- Sets (with links)
    local setsStr = "None"
    if equipmentData and equipmentData.sets then
        local CreateSetLink = CM.links and CM.links.CreateSetLink
        local setNames = {}
        for _, set in ipairs(equipmentData.sets) do
            if set.count >= 5 then
                local setLink = (CreateSetLink and CreateSetLink(set.name, format)) or set.name
                table.insert(setNames, setLink)
            end
        end
        if #setNames > 0 then
            setsStr = table_concat(setNames, " • ")
        end
    end
    
    -- Bank status
    local bankStatus = "OK"
    if inventoryData and inventoryData.bankPercent then
        if inventoryData.bankPercent >= 95 then
            bankStatus = "⚠️ Full"
        elseif inventoryData.bankPercent >= 90 then
            bankStatus = "⚠️ Almost Full"
        end
    end
    
    -- Unspent skill points
    local unspentSkillPoints = (progressionData and progressionData.unspentSkillPoints) or 0
    local skillPointsStr = unspentSkillPoints > 0 and string_format("%d available", unspentSkillPoints) or "None"
    
    -- Attributes with emojis (🔵 Magicka, ❤️ Health, ⚡ Stamina)
    local attributesStr = string_format("🔵 %d / ❤️ %d / ⚡ %d", magicka, health, stamina)
    
    -- Achievements percentage
    local achievementPercent = 0
    if progressionData and progressionData.totalAchievements and progressionData.totalAchievements > 0 then
        achievementPercent = math.floor(((progressionData.achievementPoints or 0) / progressionData.totalAchievements) * 100)
    end
    
    -- Transmute crystals
    local transmutes = (currencyData and currencyData.transmuteCrystals) or 0
    
    -- Gold
    local gold = (currencyData and currencyData.gold) or 0
    
    -- Format table with Alliance, Location rows (Race and Class removed)
    local allianceRow = string_format("| **Alliance** | %s |\n", allianceLink)
    local locationRow = ""
    
    if locationStr ~= "" then
        locationRow = string_format("| **Location** | %s |\n", locationStr)
    end
    
    if not enhanced or not markdown then
        -- Classic table format
        return string_format([[
## 📋 Overview

| Attribute | Value |
|:----------|:------|
| **Build** | %s |
%s%s| **Champion Points** | %s |
| **Gold** | %s |
| **Sets** | %s |
| **Bank** | %s |
| **Skill Points** | %s |
| **Attributes** | %s |

]], buildStr, allianceRow, locationRow, cpDisplayValue, safeFormat(gold), setsStr, bankStatus, 
            skillPointsStr, attributesStr)
    end
    
    -- ENHANCED: Use detailed table format (keeping enhanced visuals option)
    return string_format([[
## 📋 Overview

| Attribute | Value |
|:----------|:------|
| **Build** | %s |
%s%s| **Champion Points** | %s |
| **Gold** | %s |
| **Sets** | %s |
| **Bank** | %s |
| **Skill Points** | %s |
| **Attributes** | %s |

]], buildStr, allianceRow, locationRow, cpDisplayValue, safeFormat(gold), setsStr, bankStatus, 
            skillPointsStr, attributesStr)
end

CM.generators.sections.GenerateQuickStats = GenerateQuickStats

-- =====================================================
-- ATTENTION NEEDED (Warnings/Important Info)
-- =====================================================

-- FIX #5: Enhanced attention needed with more warnings
local function GenerateAttentionNeeded(progressionData, inventoryData, ridingData, companionData, currencyData, format)
    if format == "discord" then return "" end
    
    local enhanced = CM.settings and CM.settings.enableEnhancedVisuals
    local warnings = {}
    
    -- Check for unspent points
    if progressionData then
        if progressionData.unspentSkillPoints and progressionData.unspentSkillPoints > 0 then
            table.insert(warnings, string_format("🎯 **%d skill points available** - Ready to spend", progressionData.unspentSkillPoints))
        end
        if progressionData.unspentAttributePoints and progressionData.unspentAttributePoints > 0 then
            table.insert(warnings, string_format("⚠️ **%d unspent attribute points**", progressionData.unspentAttributePoints))
        end
    end
    
    -- Check companion warnings (underleveled, outdated gear, empty slots)
    if companionData and companionData.active then
        local companionName = companionData.name or "Unknown"
        local companionLevel = companionData.level or 0
        
        -- Check if underleveled
        if companionLevel < 20 then
            table.insert(warnings, string_format("👥 **Companion underleveled**: %s (Level %d/20) - Needs XP", companionName, companionLevel))
        end
        
        -- Check for outdated gear
        local outdatedGearCount = 0
        if companionData.equipment and #companionData.equipment > 0 then
            for _, item in ipairs(companionData.equipment) do
                local itemLevel = item.level or 0
                if itemLevel < companionLevel and itemLevel < 20 then
                    outdatedGearCount = outdatedGearCount + 1
                end
            end
        end
        if outdatedGearCount > 0 then
            table.insert(warnings, string_format("👥 **Companion outdated gear**: %d piece%s below level - Upgrade equipment", 
                outdatedGearCount, (outdatedGearCount == 1) and "" or "s"))
        end
        
        -- Check for empty ability slots
        local emptySlots = 0
        if companionData.skills then
            -- Check ultimate
            if companionData.skills.ultimate == "[Empty]" or companionData.skills.ultimate == "Empty" or not companionData.skills.ultimate then
                emptySlots = emptySlots + 1
            end
            -- Check abilities
            if companionData.skills.abilities then
                for _, ability in ipairs(companionData.skills.abilities) do
                    if ability.name == "[Empty]" or ability.name == "Empty" or not ability.name then
                        emptySlots = emptySlots + 1
                    end
                end
            end
        end
        if emptySlots > 0 then
            table.insert(warnings, string_format("👥 **Companion empty ability slots**: %d - Assign abilities", emptySlots))
        end
    end
    
    -- Check inventory capacity warnings (>90%)
    if inventoryData then
        if inventoryData.backpackPercent and inventoryData.backpackPercent >= 90 then
            table.insert(warnings, string_format("🎒 **Backpack nearly full** (%d%%)", inventoryData.backpackPercent))
        end
        if inventoryData.bankPercent and inventoryData.bankPercent >= 90 then
            table.insert(warnings, string_format("🏦 **Bank nearly full** (%d%%)", inventoryData.bankPercent))
        end
    end
    
    -- Check riding skill training available
    if ridingData then
        local speed = ridingData.speed or 0
        local stamina = ridingData.stamina or 0
        local capacity = ridingData.capacity or 0
        if speed < 60 or stamina < 60 or capacity < 60 then
            local incomplete = {}
            if speed < 60 then table.insert(incomplete, "Speed") end
            if stamina < 60 then table.insert(incomplete, "Stamina") end
            if capacity < 60 then table.insert(incomplete, "Capacity") end
            table.insert(warnings, string_format("🐴 **Riding training available**: %s", table_concat(incomplete, ", ")))
        end
    end
    
    -- Check companion rapport low (keep this for rapport-specific warnings)
    if companionData and companionData.active and companionData.rapport then
        if companionData.rapport < 1000 then
            table.insert(warnings, string_format("💔 **Companion rapport low**: %s (%d)", 
                companionData.name or "Unknown", companionData.rapport))
        end
    end
    
    -- Check event tickets at maximum (12 is the cap in ESO)
    if currencyData then
        local eventTickets = currencyData.eventTickets or 0
        if eventTickets >= 12 then
            table.insert(warnings, string_format("🎫 **Event tickets at maximum** (%d/12) - Use tickets to avoid wasting future rewards", eventTickets))
        end
    end
    
    if #warnings == 0 then return "" end
    
    local content = table_concat(warnings, "  \n")
    
    if not enhanced or not markdown then
        return string_format("## ⚠️ Attention Needed\n\n%s\n\n", content)
    end
    
    -- ENHANCED: Use warning callout
    return (markdown and markdown.CreateCallout and markdown.CreateCallout("warning", content, format)) or 
           string_format("## ⚠️ Attention Needed\n\n%s\n\n", content)
end

CM.generators.sections.GenerateAttentionNeeded = GenerateAttentionNeeded

-- =====================================================
-- OVERVIEW SECTION
-- =====================================================

local function GenerateOverview(charData, roleData, locationData, buffsData, mundusData, ridingData, pvpData, progressionData, settings, format, cpData)
    if not charData then return "" end
    
    local enhanced = CM.settings and CM.settings.enableEnhancedVisuals
    local includeRole = CM.settings and CM.settings.includeRole ~= false
    local includeLocation = CM.settings and CM.settings.includeLocation ~= false
    
    -- Check if we should use table format (classic) or collapsible (enhanced)
    local useTableFormat = not enhanced or not markdown
    
    if useTableFormat then
        -- Classic table format (matches old output)
        local result = "## 📊 Character Overview\n\n"
        result = result .. "| Attribute | Value |\n"
        result = result .. "|:----------|:------|\n"
        result = result .. string_format("| **Level** | %d |\n", charData.level or 1)
        
        -- CP with breakdown
        local cpStr = string_format("%d", charData.cp or 0)
        if cpData and cpData.disciplines and #cpData.disciplines > 0 then
            local cp1 = 0  -- Warfare
            local cp2 = 0  -- Fitness
            local cp3 = 0  -- Craft
            for _, discipline in ipairs(cpData.disciplines) do
                local name = discipline.name or ""
                local total = discipline.total or 0
                if name == "Warfare" then
                    cp1 = total
                elseif name == "Fitness" then
                    cp2 = total
                elseif name == "Craft" then
                    cp3 = total
                end
            end
            if cp1 > 0 or cp2 > 0 or cp3 > 0 then
                cpStr = string_format("%d (%d/%d/%d)", charData.cp or 0, cp1, cp2, cp3)
            end
        end
        result = result .. string_format("| **Champion Points** | %s |\n", cpStr)
        
        -- Race/Class/Alliance with links
        local CreateRaceLink = CM.links and CM.links.CreateRaceLink
        local CreateClassLink = CM.links and CM.links.CreateClassLink
        local CreateAllianceLink = CM.links and CM.links.CreateAllianceLink
        
        local raceText = (CreateRaceLink and CreateRaceLink(charData.race, format)) or (charData.race or "Unknown")
        local classText = (CreateClassLink and CreateClassLink(charData.class, format)) or (charData.class or "Unknown")
        local allianceText = (CreateAllianceLink and CreateAllianceLink(charData.alliance, format)) or (charData.alliance or "Unknown")
        
        result = result .. string_format("| **Class** | %s |\n", classText)
        result = result .. string_format("| **Race** | %s |\n", raceText)
        result = result .. string_format("| **Alliance** | %s |\n", allianceText)
        
        -- Server and Account
        local CreateServerLink = CM.links and CM.links.CreateServerLink
        local serverText = (CreateServerLink and CreateServerLink(charData.server, format)) or (charData.server or "Unknown")
        result = result .. string_format("| **Server** | %s |\n", serverText)
        result = result .. string_format("| **Account** | %s |\n", charData.account or "Unknown")
        
        -- ESO Plus
        if charData.esoPlus then
            result = result .. "| **ESO Plus** | ✅ Active |\n"
        end
        
        -- Attributes
        local attrs = charData.attributes or {}
        result = result .. string_format("| **🎯 Attributes** | Magicka: %d • Health: %d • Stamina: %d |\n", 
            attrs.magicka or 0, attrs.health or 0, attrs.stamina or 0)
        
        -- Mundus Stone
        if mundusData and mundusData.active then
            local CreateMundusLink = CM.links and CM.links.CreateMundusLink
            local mundusText = (CreateMundusLink and CreateMundusLink(mundusData.name, format)) or mundusData.name
            result = result .. string_format("| **🪨 Mundus Stone** | %s |\n", mundusText)
        end
        
        -- Active Buffs
        if buffsData and buffsData.buffs and #buffsData.buffs > 0 then
            local buffLines = {}
            for _, buff in ipairs(buffsData.buffs) do
                local CreateBuffLink = CM.links and CM.links.CreateBuffLink
                local buffText = (CreateBuffLink and CreateBuffLink(buff.name, format)) or buff.name
                table.insert(buffLines, buffText)
            end
            if #buffLines > 0 then
                result = result .. string_format("| **🍖 Active Buffs** | %s: %s |\n", 
                    buffsData.categories[1] or "Other", table_concat(buffLines, ", "))
            end
        end
        
        -- Location
        if includeLocation and locationData then
            local zone = locationData.zone or "Unknown"
            local subzone = locationData.subzone
            local zoneIndex = locationData.zoneIndex or 0
            
            local CreateZoneLink = CM.links and CM.links.CreateZoneLink
            local zoneLink = (CreateZoneLink and CreateZoneLink(zone, format)) or zone
            
            local locStr = zoneLink
            if subzone and subzone ~= "" then
                locStr = string_format("%s (%s)", locStr, subzone)
            elseif zoneIndex and zoneIndex > 0 then
                locStr = string_format("%s (%d)", locStr, zoneIndex)
            end
            result = result .. string_format("| **Location** | %s |\n", locStr)
        end
        
        return result .. "\n"
    else
        -- Enhanced collapsible format (new style)
        local lines = {}
        
        -- Use link functions for Race, Class, Alliance
        local CreateRaceLink = CM.links and CM.links.CreateRaceLink
        local CreateClassLink = CM.links and CM.links.CreateClassLink
        local CreateAllianceLink = CM.links and CM.links.CreateAllianceLink
        
        local raceText = (CreateRaceLink and CreateRaceLink(charData.race, format)) or (charData.race or "Unknown")
        local classText = (CreateClassLink and CreateClassLink(charData.class, format)) or (charData.class or "Unknown")
        local allianceText = (CreateAllianceLink and CreateAllianceLink(charData.alliance, format)) or (charData.alliance or "Unknown")
        
        table.insert(lines, string_format("**Race:** %s", raceText))
        table.insert(lines, string_format("**Class:** %s", classText))
        table.insert(lines, string_format("**Alliance:** %s", allianceText))
        
        if includeLocation and locationData then
            local zone = locationData.zone or "Unknown"
            local subzone = locationData.subzone
            local zoneIndex = locationData.zoneIndex or 0
            
            local CreateZoneLink = CM.links and CM.links.CreateZoneLink
            local zoneLink = (CreateZoneLink and CreateZoneLink(zone, format)) or zone
            
            local locStr = zoneLink
            if subzone and subzone ~= "" then
                locStr = string_format("%s (%s)", locStr, subzone)
            elseif zoneIndex and zoneIndex > 0 then
                locStr = string_format("%s (%d)", locStr, zoneIndex)
            end
            table.insert(lines, string_format("**Location:** %s", locStr))
        end
        
        local content = table_concat(lines, "  \n")
        
        if markdown.CreateCollapsible then
            return markdown.CreateCollapsible("Character Overview", content, "📋", true)
        else
            return string_format("## 📋 Character Overview\n\n%s\n\n", content)
        end
    end
end

CM.generators.sections.GenerateOverview = GenerateOverview

-- =====================================================
-- PROGRESSION SECTION
-- =====================================================

local function GenerateProgression(progressionData, cpData, format)
    if not progressionData or (CM.settings and CM.settings.includeProgression == false) then return "" end
    
    local enhanced = CM.settings and CM.settings.enableEnhancedVisuals
    local formatNumber = CM.utils and CM.utils.FormatNumber
    local safeFormat = function(val)
        if formatNumber then
            return formatNumber(val)
        else
            return tostring(val)
        end
    end
    
    if not enhanced or not markdown then
        -- Classic table format (matches old output)
        local result = "## 📈 Progression\n\n"
        result = result .. "| Category | Value |\n"
        result = result .. "|:---------|:------|\n"
        
        if progressionData.unspentSkillPoints then
            result = result .. string_format("| **📚 Unspent Skill Points** | %d |\n", progressionData.unspentSkillPoints)
        end
        if progressionData.unspentAttributePoints then
            result = result .. string_format("| **⭐ Unspent Attribute Points** | %d |\n", progressionData.unspentAttributePoints)
        end
        if cpData and cpData.available then
            result = result .. string_format("| **🎯 Available Champion Points** | %d |\n", cpData.available)
        end
        if progressionData.achievementPoints then
            result = result .. string_format("| **🏆 Achievement Points** | %s |\n", safeFormat(progressionData.achievementPoints))
        end
        
        return result .. "\n"
    else
        -- Enhanced collapsible format (new style) - but still show all fields
        local lines = {}
        
        -- Show all fields in the same order as classic format
        if progressionData.unspentSkillPoints then
            table.insert(lines, string_format("**📚 Unspent Skill Points:** %d", progressionData.unspentSkillPoints))
        end
        if progressionData.unspentAttributePoints then
            table.insert(lines, string_format("**⭐ Unspent Attribute Points:** %d", progressionData.unspentAttributePoints))
        end
        if cpData and cpData.available then
            table.insert(lines, string_format("**🎯 Available Champion Points:** %d", cpData.available))
        end
        if progressionData.achievementPoints then
            table.insert(lines, string_format("**🏆 Achievement Points:** %s", safeFormat(progressionData.achievementPoints)))
        end
        
        -- Vampire/Werewolf
        if progressionData.vampireStage and progressionData.vampireStage > 0 then
            table.insert(lines, string_format("🧛 **Vampire Stage %d**", progressionData.vampireStage))
        end
        if progressionData.werewolfStage and progressionData.werewolfStage > 0 then
            table.insert(lines, string_format("🐺 **Werewolf Stage %d**", progressionData.werewolfStage))
        end
        
        -- Enlightenment
        if progressionData.isEnlightened then
            table.insert(lines, "✨ **Enlightened** (4x CP XP)")
        end
        
        if #lines == 0 then return "" end
        
        local content = table_concat(lines, "  \n")
        
        local result = ""
        if markdown.CreateCollapsible then
            result = markdown.CreateCollapsible("Progression", content, "📈", false) or string_format("## 📈 Progression\n\n%s\n\n", content)
        else
            result = string_format("## 📈 Progression\n\n%s\n\n", content)
        end
        
        -- Enlightenment callout
        if progressionData.isEnlightened and markdown and markdown.CreateCallout then
            local callout = markdown.CreateCallout("tip", 
                "🌟 **Enlightened!** Earning 4x Champion Point XP", format)
            if callout then
                result = result .. callout
            end
        end
        
        return result
    end
end

CM.generators.sections.GenerateProgression = GenerateProgression

-- =====================================================
-- CUSTOM NOTES SECTION
-- =====================================================

local function GenerateCustomNotes(customNotes, format)
    if not customNotes or customNotes == "" then return "" end
    if CM.settings and CM.settings.includeBuildNotes == false then return "" end
    
    local enhanced = CM.settings and CM.settings.enableEnhancedVisuals
    
    if not enhanced or not markdown then
        return string_format("## 📝 Build Notes\n\n%s\n\n", customNotes)
    end
    
    -- ENHANCED: Use collapsible section (with nil check)
    if markdown.CreateCollapsible then
        return markdown.CreateCollapsible("Build Notes", customNotes, "📝", true) or string_format("## 📝 Build Notes\n\n%s\n\n", customNotes)
    else
        return string_format("## 📝 Build Notes\n\n%s\n\n", customNotes)
    end
end

CM.generators.sections.GenerateCustomNotes = GenerateCustomNotes

-- =====================================================
-- MODULE INITIALIZATION
-- =====================================================

CM.DebugPrint("GENERATOR", "Character section generators loaded (enhanced visuals)")
