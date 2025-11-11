-- CharacterMarkdown - Character Section Generators
-- Generates character identity, overview, and header sections

local CM = CharacterMarkdown
CM.generators = CM.generators or {}
CM.generators.sections = CM.generators.sections or {}

local string_format = string.format
local table_concat = table.concat
local table_insert = table.insert

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
    
    -- Enhanced visuals are now always enabled (baseline)
    if format == "discord" or not markdown then
        -- Classic format
        local header = string_format("# %s\n\n", displayTitle)
        header = header .. string_format("**%s %s**  \n", race, class)
        header = header .. string_format("**Level %d • CP %d • %s**\n\n", level, cp, alliance)
        if isESOPlus then
            header = header .. "✨ *ESO Plus Active*\n\n"
        end
        -- Add leading newline for proper markdown formatting
        return "\n" .. header
    end
    
    -- ENHANCED FORMAT with badges (with nil checks)
    if not markdown.CreateBadgeRow or not markdown.CreateCenteredBlock then
        -- Fallback to classic if functions don't exist
        local header = string_format("# %s\n\n", displayTitle)
        header = header .. string_format("**%s %s**  \n", race, class)
        header = header .. string_format("**Level %d • CP %d • %s**\n\n", level, cp, alliance)
        -- Add leading newline for proper markdown formatting
        return "\n" .. header
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
    
    -- Add leading newline for proper markdown formatting
    return "\n" .. header
end

CM.generators.sections.GenerateHeader = GenerateHeader

-- =====================================================
-- QUICK STATS (At-a-glance info box)
-- =====================================================

local function GenerateQuickStats(charData, statsData, format, equipmentData, progressionData, currencyData, cpData, inventoryData, locationData, buffsData, pvpData, titlesData, mundusData, ridingData)
    if not charData then return "" end
    if format == "discord" then return "" end -- Skip for Discord
    
    -- Enhanced visuals are now always enabled (baseline)
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
    local cp1 = 0  -- Warfare (spent/assigned)
    local cp2 = 0  -- Fitness (spent/assigned)
    local cp3 = 0  -- Craft (spent/assigned)
    
    if cpData then
        -- Disciplines are stored as an array, not an object
        if cpData.disciplines and #cpData.disciplines > 0 then
            local DisciplineType = CM.constants.DisciplineType
            for _, discipline in ipairs(cpData.disciplines) do
                local name = discipline.name or ""
                -- Use assigned from API if available, otherwise use total (spent)
                local assigned = discipline.assigned or discipline.total or 0
                if name == DisciplineType.WARFARE then
                    cp1 = assigned
                elseif name == DisciplineType.FITNESS then
                    cp2 = assigned
                elseif name == DisciplineType.CRAFT then
                    cp3 = assigned
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
    
    -- ALWAYS show breakdown format - show unassigned points per discipline
    -- Use emojis: ⚒️ Craft / ⚔️ Warfare / 💪 Fitness
    -- Order: Craft, Warfare, Fitness (cp3, cp1, cp2)
    -- Format: ⚒️ x - ⚔️ y - 💪 z (where x, y, z are unassigned points)
    local cpTotal = 0
    if cpData and cpData.total then
        cpTotal = cpData.total or 0
    elseif cp then
        cpTotal = cp  -- Fallback to character CP if available
    end
    
    -- Calculate "available capacity" per discipline
    -- Unassigned CP is a shared pool, but we show it per discipline to indicate
    -- "available capacity" (max - assigned) for each discipline
    -- Max per discipline = assigned + unassigned (shared pool)
    -- Available capacity = max - assigned = (assigned + unassigned) - assigned = unassigned
    -- Since unassigned is shared, all disciplines show the same available capacity
    
    -- Get unassigned CP (shared pool)
    local totalUnassigned = 0
    if cpData and cpData.available then
        totalUnassigned = cpData.available or 0
    elseif cpData and cpData.total and cpData.spent then
        totalUnassigned = math.max(0, cpData.total - cpData.spent)
    end
    
    -- All disciplines show the same unassigned value (shared pool)
    -- This represents "how much more can be allocated to this discipline"
    local unassignedCraft = totalUnassigned
    local unassignedWarfare = totalUnassigned
    local unassignedFitness = totalUnassigned
    
    -- Note: We no longer use maxAllocated from API since it was incorrect
    -- Max is simply: assigned + unassigned (shared pool)
    -- All three disciplines show the same unassigned value (shared pool)
    
    local cpDisplayValue = string_format("⚒️ %d - ⚔️ %d - 💪 %d", 
        unassignedCraft, unassignedWarfare, unassignedFitness)
    
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
    
    -- Bank status (show icon and used/max format)
    local bankStatus = "✅ 0/0"
    if inventoryData then
        local bankUsed = inventoryData.bankUsed or 0
        local bankMax = inventoryData.bankMax or 0
        
        -- Debug: Log if we have bank data
        if bankUsed == 0 and bankMax == 0 then
            CM.DebugPrint("BANK", "Warning: Bank data appears empty (used=0, max=0)")
        end
        
        if bankMax > 0 then
            -- Always show used/max format with status icon
            local statusIcon = "✅"
            if inventoryData.bankPercent and inventoryData.bankPercent >= 100 then
                statusIcon = "⚠️"
            elseif inventoryData.bankPercent and inventoryData.bankPercent >= 95 then
                statusIcon = "⚠️"
            elseif inventoryData.bankPercent and inventoryData.bankPercent >= 90 then
                statusIcon = "⚠️"
            end
            bankStatus = string_format("%s %d/%d", statusIcon, bankUsed, bankMax)
        elseif bankUsed > 0 then
            -- Bank has items but max is unknown
            bankStatus = string_format("✅ %d/?", bankUsed)
        end
    else
        CM.DebugPrint("BANK", "Warning: inventoryData is nil in GenerateQuickStats")
    end
    
    -- Unspent skill points
    local unspentSkillPoints = (progressionData and progressionData.unspentSkillPoints) or 0
    local skillPointsStr = unspentSkillPoints > 0 and string_format("%d available", unspentSkillPoints) or "None"
    
    -- Attributes with emojis (🔵 Magicka, ❤️ Health, ⚡ Stamina)
    local attributesStr = string_format("🔵 %d / ❤️ %d / ⚡ %d", magicka, health, stamina)
    
    -- Riding Skills (🏇 Speed, 💨 Stamina, 🎒 Capacity)
    local ridingStr = ""
    if ridingData then
        local speed = ridingData.speed or 0
        local stamina = ridingData.stamina or 0
        local capacity = ridingData.capacity or 0
        ridingStr = string_format("| **Riding Skills** | 🏇 %d / 💨 %d / 🎒 %d |\n", speed, stamina, capacity)
    end
    
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
    
    -- Add Alliance War Rank row if PvP data is available
    local pvpRow = ""
    if pvpData then
        local rank = pvpData.rank or 0
        local rankName = pvpData.rankName or "None"
        if rank > 0 and rankName and rankName ~= "None" and rankName ~= "" then
            pvpRow = string_format("| **Alliance War Rank** | %s (Rank %d) |\n", rankName, rank)
        end
    end
    
    -- Add progression details rows
    local progressionRows = ""
    if progressionData then
        if progressionData.unspentAttributePoints and progressionData.unspentAttributePoints > 0 then
            progressionRows = progressionRows .. string_format("| **⭐ Unspent Attribute Points** | %d |\n", progressionData.unspentAttributePoints)
        end
        if cpData and cpData.available and cpData.available > 0 then
            progressionRows = progressionRows .. string_format("| **🎯 Available Champion Points** | %d |\n", cpData.available)
        end
        if progressionData.achievementPoints then
            local achievementPoints = safeFormat(progressionData.achievementPoints)
            progressionRows = progressionRows .. string_format("| **🏆 Achievement Points** | %s |\n", achievementPoints)
        end
    end
    
    -- Add Current Title row if titles data is available
    local titleRow = ""
    if titlesData and titlesData.current and titlesData.current ~= "" then
        -- Check if this is a custom title (user-entered) - custom titles should never be linked
        local isCustomTitle = false
        if CM.charData and CM.charData.customTitle and CM.charData.customTitle ~= "" then
            isCustomTitle = (titlesData.current == CM.charData.customTitle)
        elseif CharacterMarkdownData and CharacterMarkdownData.customTitle and CharacterMarkdownData.customTitle ~= "" then
            isCustomTitle = (titlesData.current == CharacterMarkdownData.customTitle)
        end
        
        local currentTitleText = titlesData.current
        -- Only link if it's NOT a custom title (game titles can be linked, respecting enableAbilityLinks)
        if not isCustomTitle then
            local CreateTitleLink = CM.links and CM.links.CreateTitleLink
            currentTitleText = (CreateTitleLink and CreateTitleLink(titlesData.current, format)) or titlesData.current
        end
        titleRow = string_format("| **👑 Current Title** | %s |\n", currentTitleText)
    end
    
    -- Add Active Buffs row if buffs data is available
    local buffsRow = ""
    if buffsData and (buffsData.food or buffsData.potion or (buffsData.other and #buffsData.other > 0)) then
        local CreateBuffLink = CM.links and CM.links.CreateBuffLink
        local buffLines = {}
        
        if buffsData.food then
            local foodLink = (CreateBuffLink and CreateBuffLink(buffsData.food, format)) or buffsData.food
            table.insert(buffLines, "Food: " .. foodLink)
        end
        if buffsData.potion then
            local potionLink = (CreateBuffLink and CreateBuffLink(buffsData.potion, format)) or buffsData.potion
            table.insert(buffLines, "Potion: " .. potionLink)
        end
        if buffsData.other and #buffsData.other > 0 then
            local otherBuffs = {}
            for _, buff in ipairs(buffsData.other) do
                local buffLink = (CreateBuffLink and CreateBuffLink(buff, format)) or buff
                table.insert(otherBuffs, buffLink)
            end
            if #otherBuffs > 0 then
                table.insert(buffLines, "Other: " .. table_concat(otherBuffs, ", "))
            end
        end
        
        if #buffLines > 0 then
            buffsRow = string_format("| **🍖 Active Buffs** | %s |\n", table_concat(buffLines, " • "))
        end
    end
    
    -- Add Mundus Stone row if mundus data is available
    local mundusRow = ""
    if mundusData and mundusData.active and mundusData.name then
        local CreateMundusLink = CM.links and CM.links.CreateMundusLink
        local mundusLink = (CreateMundusLink and CreateMundusLink(mundusData.name, format)) or mundusData.name
        mundusRow = string_format("| **🪨 Mundus Stone** | %s |\n", mundusLink)
    end
    
    -- Generate combat stats table for overview section (inline mode)
    local statsTable = ""
    if statsData then
        local GenerateCombatStats = CM.generators.sections.GenerateCombatStats
        if GenerateCombatStats then
            statsTable = GenerateCombatStats(statsData, format, true)  -- true = inline mode
        end
    end
    
    -- Generate currency subsection (simple inline version to avoid dependency issues)
    local currencySection = ""
    if currencyData and format ~= "discord" then
        currencySection = '\n<a id="currency"></a>\n\n### Currency\n\n'
        currencySection = currencySection .. "| Currency | Amount |\n"
        currencySection = currencySection .. "|:---------|-------:|\n"
        
        -- Gold
        if currencyData.gold then
            currencySection = currencySection .. string_format("| 💰 **Gold** | %s |\n", safeFormat(currencyData.gold))
        end
        -- Alliance Points
        if currencyData.alliancePoints and currencyData.alliancePoints > 0 then
            currencySection = currencySection .. string_format("| ⚔️ **Alliance Points** | %s |\n", safeFormat(currencyData.alliancePoints))
        end
        -- Tel Var
        if currencyData.telVar and currencyData.telVar > 0 then
            currencySection = currencySection .. string_format("| 🔮 **Tel Var** | %s |\n", safeFormat(currencyData.telVar))
        end
        -- Transmute Crystals
        if currencyData.transmuteCrystals and currencyData.transmuteCrystals > 0 then
            currencySection = currencySection .. string_format("| 💎 **Transmute Crystals** | %s |\n", safeFormat(currencyData.transmuteCrystals))
        end
        -- Writs
        if currencyData.writs and currencyData.writs > 0 then
            currencySection = currencySection .. string_format("| 📜 **Writs** | %s |\n", safeFormat(currencyData.writs))
        end
        -- Event Tickets
        if currencyData.eventTickets and currencyData.eventTickets > 0 then
            currencySection = currencySection .. string_format("| 🎫 **Event Tickets** | %s |\n", safeFormat(currencyData.eventTickets))
        end
        
        currencySection = currencySection .. "\n"
    end
    
    if not markdown then
        -- Classic table format
        return string_format([[
<a id="general"></a>

### General

| Attribute | Value |
|:----------|:------|
| **Build** | %s |
%s%s%s| **Character Gold** | %s |
| **Sets** | %s |
| **Bank Usage** | %s |
| **Skill Points** | %s |
| **Attributes** | %s |
%s%s%s%s%s
%s
%s]], buildStr, allianceRow, locationRow, pvpRow, safeFormat(gold), setsStr, bankStatus, 
            skillPointsStr, attributesStr, ridingStr, progressionRows, titleRow, buffsRow, mundusRow, statsTable, currencySection)
    end
    
    -- ENHANCED: Use detailed table format (keeping enhanced visuals option)
    return string_format([[
<a id="general"></a>

### General

| Attribute | Value |
|:----------|:------|
| **Build** | %s |
%s%s%s| **Character Gold** | %s |
| **Sets** | %s |
| **Bank Usage** | %s |
| **Skill Points** | %s |
| **Attributes** | %s |
%s%s%s%s%s
%s
%s]], buildStr, allianceRow, locationRow, pvpRow, safeFormat(gold), setsStr, bankStatus, 
            skillPointsStr, attributesStr, ridingStr, progressionRows, titleRow, buffsRow, mundusRow, statsTable, currencySection)
end

CM.generators.sections.GenerateQuickStats = GenerateQuickStats

-- =====================================================
-- ATTENTION NEEDED (Warnings/Important Info)
-- =====================================================

-- FIX #5: Enhanced attention needed with more warnings
local function GenerateAttentionNeeded(progressionData, inventoryData, ridingData, companionData, currencyData, format)
    if format == "discord" then return "" end
    
    -- Enhanced visuals are now always enabled (baseline)
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
    
    if not markdown then
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
    
    -- Enhanced visuals are now always enabled (baseline)
    local includeRole = CM.settings and CM.settings.includeRole ~= false
    local includeLocation = CM.settings and CM.settings.includeLocation ~= false
    
    -- Always use collapsible format (enhanced visuals are baseline)
    local useTableFormat = not markdown
    
    if useTableFormat then
        -- Classic table format (matches old output)
        local result = "## 📊 Character Overview\n\n"
        result = result .. "| Attribute | Value |\n"
        result = result .. "|:----------|:------|\n"
        result = result .. string_format("| **Level** | %d |\n", charData.level or 1)
        
        -- CP removed - now shown in Champion Points section
        
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

CM.generators.sections.GenerateProgression = GenerateProgression

-- =====================================================
-- CUSTOM NOTES SECTION
-- =====================================================

-- Helper function to auto-link sets and abilities in build notes
local function AutoLinkSetsAndAbilities(notes, format, equipmentData, skillBarData)
    if not notes or notes == "" then return notes end
    if format ~= "github" and format ~= "discord" then return notes end  -- Only link in formats that support it
    
    local CreateSetLink = CM.links and CM.links.CreateSetLink
    local CreateAbilityLink = CM.links and CM.links.CreateAbilityLink
    
    if not CreateSetLink and not CreateAbilityLink then return notes end
    
    local processedNotes = notes
    
    -- Extract set names from equipment data
    local setNames = {}
    if equipmentData and equipmentData.sets then
        for _, set in ipairs(equipmentData.sets) do
            if set.name and set.name ~= "" and set.name ~= "-" then
                -- Escape special regex characters in set name for pattern matching
                local escapedName = set.name:gsub("([%(%)%.%+%*%?%[%]%^%$%%])", "%%%1")
                if not setNames[set.name] then
                    setNames[set.name] = true
                    -- Only link if not already linked (avoid double-linking)
                    local pattern = "%f[%w]" .. escapedName .. "%f[%W]"
                    local alreadyLinked = processedNotes:find("%[" .. escapedName .. "%]%(")
                    if not alreadyLinked then
                        local linkedName = CreateSetLink(set.name, format)
                        if linkedName and linkedName ~= set.name then
                            -- Replace set name with linked version (word boundary aware)
                            processedNotes = processedNotes:gsub(pattern, linkedName)
                        end
                    end
                end
            end
        end
    end
    
    -- Extract ability names from skill bar data
    local abilityNames = {}
    if skillBarData and skillBarData.bars then
        for _, bar in ipairs(skillBarData.bars) do
            if bar.abilities then
                for _, ability in ipairs(bar.abilities) do
                    if ability.name and ability.name ~= "" and ability.name ~= "[Empty]" and ability.name ~= "[Empty Slot]" then
                        -- Clean ability name (remove rank suffixes like " IV")
                        local cleanName = ability.name:gsub("%s+IV$", ""):gsub("%s+III$", ""):gsub("%s+II$", ""):gsub("%s+I$", "")
                        if cleanName ~= "" and not abilityNames[cleanName] then
                            abilityNames[cleanName] = true
                            -- Escape special regex characters
                            local escapedName = cleanName:gsub("([%(%)%.%+%*%?%[%]%^%$%%])", "%%%1")
                            -- Only link if not already linked
                            local pattern = "%f[%w]" .. escapedName .. "%f[%W]"
                            local alreadyLinked = processedNotes:find("%[" .. escapedName .. "%]%(")
                            if not alreadyLinked then
                                local linkedName = CreateAbilityLink(cleanName, ability.abilityId, format)
                                if linkedName and linkedName ~= cleanName then
                                    -- Replace ability name with linked version (word boundary aware)
                                    processedNotes = processedNotes:gsub(pattern, linkedName)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return processedNotes
end

local function GenerateCustomNotes(customNotes, format, equipmentData, skillBarData)
    if not customNotes or customNotes == "" then return "" end
    if CM.settings and CM.settings.includeBuildNotes == false then return "" end
    
    -- Auto-link sets and abilities in notes
    local processedNotes = AutoLinkSetsAndAbilities(customNotes, format, equipmentData, skillBarData)
    
    -- Enhanced visuals are now always enabled (baseline)
    -- Use collapsible section (with nil check)
    if markdown and markdown.CreateCollapsible then
        return markdown.CreateCollapsible("Build Notes", processedNotes, "📝", true) or string_format("## 📝 Build Notes\n\n%s\n\n", processedNotes)
    else
        return string_format("## 📝 Build Notes\n\n%s\n\n", processedNotes)
    end
end

CM.generators.sections.GenerateCustomNotes = GenerateCustomNotes

-- =====================================================
-- DYNAMIC TABLE OF CONTENTS (from Registry)
-- =====================================================

-- Generate Table of Contents dynamically from section registry
-- This ensures TOC always matches actual output
local function GenerateDynamicTableOfContents(registry, format)
    if format == "discord" or format == "quick" then return "" end
    
    local tocLines = {}
    
    -- Helper function to generate anchor links (matches GitHub anchor generation)
    local function GenerateAnchor(text)
        if not text then return "" end
        
        -- Keep only ASCII letters, numbers, spaces, and basic punctuation
        -- This removes emojis and other Unicode characters
        local anchor = ""
        for i = 1, #text do
            local byte = text:byte(i)
            if (byte >= 48 and byte <= 57) or  -- 0-9
               (byte >= 65 and byte <= 90) or  -- A-Z
               (byte >= 97 and byte <= 122) or -- a-z
               byte == 32 or byte == 45 then   -- space or hyphen
                anchor = anchor .. text:sub(i, i)
            end
        end
        
        -- Convert to lowercase and replace spaces with hyphens
        anchor = anchor:lower():gsub("%s+", "-")
        
        -- Remove leading/trailing hyphens and collapse multiple hyphens
        anchor = anchor:gsub("^%-+", ""):gsub("%-+$", ""):gsub("%-%-+", "-")
        
        return anchor
    end
    
    -- Loop through registry and build TOC for sections with tocEntry metadata
    for _, section in ipairs(registry) do
        -- Check if section has TOC entry and condition is met
        if section.tocEntry then
            local shouldInclude = false
            
            -- Evaluate condition (can be boolean or function)
            if type(section.condition) == "function" then
                shouldInclude = section.condition()
            else
                shouldInclude = section.condition
            end
            
            if shouldInclude then
                local tocEntry = section.tocEntry
                local anchor = GenerateAnchor(tocEntry.title)
                
                -- Main section entry
                table_insert(tocLines, string_format("- [%s](#%s)", tocEntry.title, anchor))
                
                -- Add subsections if present
                if tocEntry.subsections then
                    for _, subsection in ipairs(tocEntry.subsections) do
                        local subAnchor = GenerateAnchor(subsection)
                        table_insert(tocLines, string_format("  - [%s](#%s)", subsection, subAnchor))
                    end
                end
            end
        end
    end
    
    -- Build final TOC markdown
    if #tocLines == 0 then
        return ""
    end
    
    local tocContent = table_concat(tocLines, "\n")
    return string_format("## 📑 Table of Contents\n\n%s\n\n---\n\n", tocContent)
end

CM.generators.sections.GenerateDynamicTableOfContents = GenerateDynamicTableOfContents

-- =====================================================
-- TABLE OF CONTENTS (Static/Legacy)
-- =====================================================

-- Generate GitHub markdown anchor from section header text
-- GitHub anchors: lowercase, spaces to hyphens, remove emojis and special chars
local function GenerateAnchor(text)
    if not text then return "" end
    
    -- Keep only ASCII letters, numbers, spaces, and basic punctuation
    -- This removes emojis and other Unicode characters
    local anchor = ""
    for i = 1, #text do
        local byte = text:byte(i)
        -- Keep ASCII printable characters (32-126) except special chars we'll handle separately
        if (byte >= 65 and byte <= 90) or  -- A-Z
           (byte >= 97 and byte <= 122) or -- a-z
           (byte >= 48 and byte <= 57) or  -- 0-9
           byte == 32 or                   -- space
           byte == 38 then                 -- &
            anchor = anchor .. string.char(byte)
        end
    end
    
    -- Convert to lowercase
    anchor = anchor:lower()
    
    -- Replace & with "-and-" or just "-" (GitHub handles & specially)
    anchor = anchor:gsub("%s*&%s*", "-")
    
    -- Replace spaces with hyphens
    anchor = anchor:gsub("%s+", "-")
    
    -- Remove any remaining special characters except hyphens
    anchor = anchor:gsub("[^%w%-]", "")
    
    -- Collapse multiple hyphens to single hyphen
    anchor = anchor:gsub("%-+", "-")
    
    -- Remove leading/trailing hyphens
    anchor = anchor:gsub("^%-+", ""):gsub("%-+$", "")
    
    return anchor
end

local function GenerateTableOfContents(format)
    if format == "discord" or format == "quick" then return "" end
    
    -- Enhanced visuals are now always enabled (baseline)
    local tocContent = string_format([[- [📋 Overview](#%s)
  - [General](#%s)
  - [Currency](#%s)
  - [Character Stats](#%s)
- [⚔️ Combat Arsenal](#%s)
  - [🔥 Class](#%s)
  - [⚔️ Weapon](#%s)
  - [🛡️ Armor](#%s)
  - [🌍 World](#%s)
  - [🏰 Guild](#%s)
  - [🏰 Alliance War](#%s)
  - [⭐ Racial](#%s)
  - [⚒️ Craft](#%s)
- [⚔️ Equipment & Active Sets](#%s)
- [👥 Active Companion](#%s)
- [🏰 Guild Membership](#%s)
- [🎨 Collectibles](#%s)
- [⭐ Champion Points](#%s)
- [🐎 Riding Skills](#%s)
- [🎒 Inventory](#%s)
- [⚒️ Crafting](#%s)
- [🌍 World Progress](#%s)
]], 
        GenerateAnchor("📋 Overview"),
        GenerateAnchor("General"),
        GenerateAnchor("Currency"),
        GenerateAnchor("Character Stats"),
        GenerateAnchor("⚔️ Combat Arsenal"),
        GenerateAnchor("🔥 Class"),
        GenerateAnchor("⚔️ Weapon"),
        GenerateAnchor("🛡️ Armor"),
        GenerateAnchor("🌍 World"),
        GenerateAnchor("🏰 Guild"),
        GenerateAnchor("🏰 Alliance War"),
        GenerateAnchor("⭐ Racial"),
        GenerateAnchor("⚒️ Craft"),
        GenerateAnchor("⚔️ Equipment & Active Sets"),
        GenerateAnchor("👥 Active Companion"),
        GenerateAnchor("🏰 Guild Membership"),
        GenerateAnchor("🎨 Collectibles"),
        GenerateAnchor("⭐ Champion Points"),
        GenerateAnchor("🐎 Riding Skills"),
        GenerateAnchor("🎒 Inventory"),
        GenerateAnchor("⚒️ Crafting"),
        GenerateAnchor("🌍 World Progress")
    )
    
    if not markdown then
        -- Classic format (non-collapsible)
        return string_format("## 📑 Table of Contents\n\n%s\n---\n\n", tocContent)
    end
    
    -- ENHANCED: Use collapsible section (with nil check)
    if markdown.CreateCollapsible then
        local collapsible = markdown.CreateCollapsible("Table of Contents", tocContent, "📑", true)
        return collapsible or string_format("## 📑 Table of Contents\n\n%s\n---\n\n", tocContent)
    else
        return string_format("## 📑 Table of Contents\n\n%s\n---\n\n", tocContent)
    end
end

CM.generators.sections.GenerateTableOfContents = GenerateTableOfContents

-- =====================================================
-- MODULE INITIALIZATION
-- =====================================================

CM.DebugPrint("GENERATOR", "Character section generators loaded (enhanced visuals)")
