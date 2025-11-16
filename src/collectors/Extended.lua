-- CharacterMarkdown - Extended Data Collectors
-- Additional optional data points (defaults OFF for performance)
-- Author: solaegis

local CM = CharacterMarkdown

-- =====================================================
-- MAIL COUNT
-- =====================================================

local function CollectMailData()
    local mail = {}

    mail.count = GetNumMail() or 0
    mail.unread = 0

    -- Count unread mail
    for i = 1, mail.count do
        local _, _, _, _, unread = GetMailItemInfo(i)
        if unread then
            mail.unread = mail.unread + 1
        end
    end

    return mail
end

CM.collectors.CollectMailData = CollectMailData

-- =====================================================
-- GUILD MEMBERSHIP
-- =====================================================

local function CollectGuildData()
    local guilds = {}

    -- Cached globals - standard ESO APIs
    local GetNumGuilds = GetNumGuilds
    local GetGuildId = GetGuildId
    local GetGuildName = GetGuildName
    local GetNumGuildMembers = GetNumGuildMembers
    local GetGuildMemberInfo = GetGuildMemberInfo
    local GetGuildRankCustomName = GetGuildRankCustomName
    local GetDisplayName = GetDisplayName
    local GetAllianceName = GetAllianceName

    -- Get number of guilds
    local numGuilds = CM.SafeCall(GetNumGuilds)

    if not numGuilds or numGuilds == 0 then
        -- No guilds
        return guilds
    end

    -- Loop through guild indices (1 to numGuilds) and get the actual guild ID
    for i = 1, numGuilds do
        -- Get the actual guild ID for this index
        local guildId = CM.SafeCall(GetGuildId, i)

        if guildId then
            -- Get guild name using the actual guild ID
            local guildName = CM.SafeCall(GetGuildName, guildId)

            -- Skip if we can't get a guild name
            if guildName and guildName ~= "" then
                -- Get number of members using the actual guild ID
                local numMembers = CM.SafeCall(GetNumGuildMembers, guildId) or 0

                -- Get guild alliance (if available)
                local guildAlliance = nil
                local GetGuildAllianceFunc = rawget(_G, "GetGuildAlliance")
                if GetGuildAllianceFunc and type(GetGuildAllianceFunc) == "function" then
                    local success, alliance = pcall(GetGuildAllianceFunc, guildId)
                    if success and alliance and type(alliance) == "number" then
                        guildAlliance = alliance
                    end
                end

                -- Get player's rank info using GetGuildMemberInfo (the correct API function)
                -- Returns: displayName, note, rankIndex, playerStatus, secsSinceLogoff
                local rankName = "Member"

                local displayName = CM.SafeCall(GetDisplayName) or ""
                if displayName and displayName ~= "" and numMembers > 0 then
                    -- Search through guild members to find the player
                    -- Note: GetGuildMemberInfo returns multiple values, so we must use pcall
                    for memberIndex = 1, numMembers do
                        local success, memberDisplayName, note, rankIndex, playerStatus, secsSinceLogoff =
                            pcall(GetGuildMemberInfo, guildId, memberIndex)
                        if success and memberDisplayName == displayName and rankIndex then
                            -- Found the player! Now get the rank name using GetGuildRankCustomName
                            local rankNameResult = CM.SafeCall(GetGuildRankCustomName, guildId, rankIndex)
                            if rankNameResult and rankNameResult ~= "" then
                                rankName = rankNameResult
                            end
                            -- Break once we found the player
                            break
                        end
                    end
                end

                local allianceName = "Cross-Alliance"
                if guildAlliance then
                    local nameResult = CM.SafeCall(GetAllianceName, guildAlliance)
                    if nameResult and nameResult ~= "" then
                        allianceName = nameResult
                    end
                end

                table.insert(guilds, {
                    name = guildName,
                    memberCount = numMembers,
                    rank = rankName,
                    alliance = allianceName,
                    guildId = guildId,
                    index = i,
                })
            end
        end
    end

    return guilds
end

CM.collectors.CollectGuildData = CollectGuildData

-- =====================================================
-- BOUNTY / JUSTICE SYSTEM
-- =====================================================

local function CollectBountyData()
    local bounty = {}

    bounty.amount = GetBounty() or 0
    bounty.infamy = GetInfamy() or 0
    bounty.heatLevel = bounty.amount > 0 and "Active" or "Clean"

    -- Determine bounty severity
    if bounty.amount == 0 then
        bounty.severity = "None"
    elseif bounty.amount < 1000 then
        bounty.severity = "Minor"
    elseif bounty.amount < 5000 then
        bounty.severity = "Moderate"
    else
        bounty.severity = "High"
    end

    return bounty
end

CM.collectors.CollectBountyData = CollectBountyData

-- =====================================================
-- CHARACTER AGE / PLAYTIME
-- =====================================================

local function CollectCharacterAgeData()
    local age = {}

    -- Get current timestamp
    local currentTime = GetTimeStamp()

    -- Character creation timestamp (from savedvariables if available)
    if CharacterMarkdownData and CharacterMarkdownData.characterCreated then
        age.createdTimestamp = CharacterMarkdownData.characterCreated
        age.ageSeconds = currentTime - age.createdTimestamp
        age.ageDays = math.floor(age.ageSeconds / 86400)
        age.ageReadable =
            FormatTimeSeconds(age.ageSeconds, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, TIME_FORMAT_PRECISION_TWELVE_HOUR)
    else
        -- First time tracking - store creation time (approximate)
        CharacterMarkdownData = CharacterMarkdownData or {}
        CharacterMarkdownData.characterCreated = currentTime
        age.createdTimestamp = currentTime
        age.ageSeconds = 0
        age.ageDays = 0
        age.ageReadable = "Just created"
    end

    return age
end

CM.collectors.CollectCharacterAgeData = CollectCharacterAgeData

-- =====================================================
-- ACTIVE QUESTS
-- =====================================================

local function CollectQuestData()
    local quests = {}

    local numQuests = GetNumJournalQuests() or 0
    quests.activeCount = numQuests
    quests.active = {}

    local settings = CharacterMarkdownSettings or {}
    local maxQuests = settings.maxQuestsToShow or 5 -- Configurable limit

    for i = 1, math.min(numQuests, maxQuests) do
        local success, questInfo = pcall(function()
            local questName, _, _, _, _, _, questLevel, questType = GetJournalQuestInfo(i)
            local stepText, _, stepTracker = GetJournalQuestStepInfo(i, 1)

            return {
                name = questName or "Unknown Quest",
                level = questLevel or 0,
                type = questType and GetString("SI_QUESTTYPE", questType) or "Quest",
                currentStep = stepText or "",
            }
        end)

        if success and questInfo then
            table.insert(quests.active, questInfo)
        end
    end

    return quests
end

CM.collectors.CollectQuestData = CollectQuestData

-- =====================================================
-- RESEARCH TIMERS (CRAFTING)
-- =====================================================

local function CollectResearchData()
    local research = {}

    local craftingTypes = {
        [CRAFTING_TYPE_BLACKSMITHING] = "Blacksmithing",
        [CRAFTING_TYPE_CLOTHIER] = "Clothier",
        [CRAFTING_TYPE_WOODWORKING] = "Woodworking",
        [CRAFTING_TYPE_JEWELRYCRAFTING] = "Jewelry Crafting",
    }

    research.active = {}
    research.totalActive = 0

    for craftingType, craftingName in pairs(craftingTypes) do
        local numLines = CM.SafeCall(GetNumSmithingResearchLines, craftingType) or 0

        for lineIndex = 1, numLines do
            -- Use pcall because GetSmithingResearchLineInfo returns multiple values (name, icon)
            local success, name, icon = pcall(GetSmithingResearchLineInfo, craftingType, lineIndex)
            if not success or not name then
                break -- Skip this line if API call failed
            end
            local numTraits = CM.SafeCall(GetNumSmithingResearchLineTraits, craftingType, lineIndex) or 0

            for traitIndex = 1, numTraits do
                -- Use pcall because GetSmithingResearchLineTraitInfo returns multiple values
                local traitSuccess, traitType, _, known = pcall(GetSmithingResearchLineTraitInfo, craftingType, lineIndex, traitIndex)
                if not traitSuccess then
                    break -- Skip this trait if API call failed
                end
                -- Use pcall because GetSmithingResearchLineTraitTimes returns multiple values
                local timeSuccess, duration, timeRemaining = pcall(GetSmithingResearchLineTraitTimes, craftingType, lineIndex, traitIndex)
                if not timeSuccess then
                    duration = nil
                    timeRemaining = nil
                end

                if not known and duration and duration > 0 and timeRemaining and timeRemaining > 0 then
                    table.insert(research.active, {
                        craft = craftingName,
                        item = name,
                        trait = GetString("SI_ITEMTRAITTYPE", traitType),
                        timeRemaining = timeRemaining,
                        timeRemainingReadable = FormatTimeSeconds(timeRemaining, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL),
                    })
                    research.totalActive = research.totalActive + 1
                end
            end
        end
    end

    return research
end

CM.collectors.CollectResearchData = CollectResearchData

-- =====================================================
-- DYE KNOWLEDGE
-- =====================================================

local function CollectDyeData()
    local dyes = {}

    local numDyes = GetNumDyes() or 0
    dyes.total = numDyes
    dyes.unlocked = 0

    for dyeIndex = 1, numDyes do
        local dyeId = GetDyeId(dyeIndex)
        if IsPlayerDyeUnlocked(dyeId) then
            dyes.unlocked = dyes.unlocked + 1
        end
    end

    dyes.percent = numDyes > 0 and math.floor((dyes.unlocked / numDyes) * 100) or 0

    return dyes
end

CM.collectors.CollectDyeData = CollectDyeData

-- =====================================================
-- MOTIF KNOWLEDGE (DETAILED)
-- =====================================================

local function CollectMotifData()
    local motifs = {}

    motifs.knownChapters = 0
    motifs.totalChapters = 0
    motifs.byStyle = {}

    local settings = CharacterMarkdownSettings or {}
    if not settings.includeMotifDetailed then
        -- Just count totals
        local numStyles = GetNumValidItemStyleIds() or 0
        for styleIndex = 1, numStyles do
            local styleId = GetValidItemStyleId(styleIndex)
            if styleId then
                local numChapters = GetNumSmithingPatterns(styleId) or 0
                motifs.totalChapters = motifs.totalChapters + numChapters

                for chapterIndex = 1, numChapters do
                    if IsSmithingPatternKnown(chapterIndex, styleId) then
                        motifs.knownChapters = motifs.knownChapters + 1
                    end
                end
            end
        end
    else
        -- Collect detailed breakdown (potentially large)
        local numStyles = GetNumValidItemStyleIds() or 0
        for styleIndex = 1, numStyles do
            local styleId = GetValidItemStyleId(styleIndex)
            if styleId then
                local styleName = GetItemStyleName(styleId)
                local numChapters = GetNumSmithingPatterns(styleId) or 0
                local knownCount = 0

                for chapterIndex = 1, numChapters do
                    if IsSmithingPatternKnown(chapterIndex, styleId) then
                        knownCount = knownCount + 1
                    end
                end

                if knownCount > 0 then
                    table.insert(motifs.byStyle, {
                        name = styleName,
                        known = knownCount,
                        total = numChapters,
                    })
                end

                motifs.knownChapters = motifs.knownChapters + knownCount
                motifs.totalChapters = motifs.totalChapters + numChapters
            end
        end
    end

    motifs.percent = motifs.totalChapters > 0 and math.floor((motifs.knownChapters / motifs.totalChapters) * 100) or 0

    return motifs
end

CM.collectors.CollectMotifData = CollectMotifData

-- =====================================================
-- RECIPE KNOWLEDGE
-- =====================================================

local function CollectRecipeData()
    local recipes = {}

    recipes.known = 0
    recipes.total = 0

    local numRecipeLists = GetNumRecipeLists() or 0

    for recipeListIndex = 1, numRecipeLists do
        local recipeListName, numRecipes = GetRecipeListInfo(recipeListIndex)
        if numRecipes then
            recipes.total = recipes.total + numRecipes

            for recipeIndex = 1, numRecipes do
                local known = GetRecipeInfo(recipeListIndex, recipeIndex)
                if known then
                    recipes.known = recipes.known + 1
                end
            end
        end
    end

    recipes.percent = recipes.total > 0 and math.floor((recipes.known / recipes.total) * 100) or 0

    return recipes
end

CM.collectors.CollectRecipeData = CollectRecipeData

-- =====================================================
-- SOUL GEMS
-- =====================================================

local function CollectSoulGemData()
    local soulGems = {}

    soulGems.filled = 0
    soulGems.empty = 0

    local numSlots = GetBagSize(BAG_BACKPACK) or 0

    for slotIndex = 0, numSlots - 1 do
        local itemType = GetItemType(BAG_BACKPACK, slotIndex)

        if itemType == ITEMTYPE_SOUL_GEM then
            local stackCount = GetSlotStackSize(BAG_BACKPACK, slotIndex)
            local itemLink = GetItemLink(BAG_BACKPACK, slotIndex)

            -- Check if filled (contains "Filled" in name typically)
            local itemName = GetItemLinkName(itemLink)
            if itemName and itemName:find("Filled") then
                soulGems.filled = soulGems.filled + stackCount
            else
                soulGems.empty = soulGems.empty + stackCount
            end
        end
    end

    return soulGems
end

CM.collectors.CollectSoulGemData = CollectSoulGemData

-- =====================================================
-- FRIENDS LIST
-- =====================================================

local function CollectFriendsData()
    local friends = {}

    friends.total = GetNumFriends() or 0
    friends.online = 0

    for i = 1, friends.total do
        local _, _, online = GetFriendInfo(i)
        if online then
            friends.online = friends.online + 1
        end
    end

    return friends
end

CM.collectors.CollectFriendsData = CollectFriendsData

-- =====================================================
-- SKYSHARDS
-- =====================================================

local function CollectSkyshardsData()
    local skyshards = {}

    -- Get skyshard achievement data
    local numAchievements = GetNumAchievements() or 0
    skyshards.collected = 0
    skyshards.total = 0

    -- Scan for skyshard-related achievements
    for i = 1, numAchievements do
        local name = GetAchievementInfo(i)
        if name and name:find("Skyshard") then
            local numCriteria = GetAchievementNumCriteria(i) or 0
            for j = 1, numCriteria do
                local _, numCompleted, numRequired = GetAchievementCriterion(i, j)
                if numRequired and numRequired > 0 then
                    skyshards.total = skyshards.total + numRequired
                    skyshards.collected = skyshards.collected + (numCompleted or 0)
                end
            end
        end
    end

    skyshards.skillPointsEarned = math.floor(skyshards.collected / 3)

    return skyshards
end

CM.collectors.CollectSkyshardsData = CollectSkyshardsData

CM.DebugPrint("COLLECTOR", "Extended collectors module loaded")
