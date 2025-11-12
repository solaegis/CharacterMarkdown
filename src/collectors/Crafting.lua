-- CharacterMarkdown - Crafting Data Collector
-- Comprehensive crafting knowledge (Tier 1 - Motifs, recipes, traits, research)

local CM = CharacterMarkdown

-- =====================================================
-- USING CORRECT ESO API FUNCTIONS (verified working)
-- Based on actual ESO Lua API testing
-- =====================================================

-- =====================================================
-- CRAFTING KNOWLEDGE COLLECTION
-- =====================================================

local function CollectCraftingData()
    local crafting = {
        motifs = {},
        recipes = {},
        research = {},
        timers = {},
    }

    -- ===== MOTIFS =====
    local function CollectMotifs()
        local motifs = {}

        -- CORRECT API: GetHighestItemStyleId() + IsItemStyleKnown(styleId) + GetItemStyleName(styleId)
        local maxStyleId = CM.SafeCall(GetHighestItemStyleId) or 200

        local knownCount = 0
        for styleId = 1, maxStyleId do
            -- Check if this style is known
            local isKnown = CM.SafeCall(IsItemStyleKnown, styleId)
            if isKnown then
                -- Get style name
                local styleName = CM.SafeCall(GetItemStyleName, styleId)
                if styleName and styleName ~= "" then
                    knownCount = knownCount + 1
                    table.insert(motifs, {
                        name = styleName,
                        styleId = styleId,
                        known = true,
                        category = nil,
                        subcategory = nil,
                    })
                end
            end
        end

        CM.Info(string.format("Motifs: %d known", knownCount))

        -- Sort by name
        if #motifs > 0 then
            table.sort(motifs, function(a, b)
                return (a.name or ""):lower() < (b.name or ""):lower()
            end)
        end

        return motifs
    end

    -- ===== RECIPES =====
    local function CollectRecipes()
        local recipes = {
            all = {},
            byList = {},
        }

        -- CORRECT API: GetNumRecipeLists() + GetRecipeInfo(listIndex, recipeIndex)
        local numLists = CM.SafeCall(GetNumRecipeLists) or 0
        local totalRecipes = 0

        -- Loop through all recipe lists
        for listIndex = 1, numLists do
            local listRecipes = {}
            local listCount = 0

            -- Loop through recipes in this list until we get nil
            for recipeIndex = 1, 1000 do -- arbitrary high limit
                local success, known, recipeName, numIngredients, provisionerType, qualityReq, specialType =
                    pcall(GetRecipeInfo, listIndex, recipeIndex)

                if not success or not recipeName then
                    -- No more recipes in this list
                    break
                end

                if known then
                    listCount = listCount + 1
                    totalRecipes = totalRecipes + 1

                    local recipeData = {
                        name = recipeName,
                        listIndex = listIndex,
                        recipeIndex = recipeIndex,
                        numIngredients = numIngredients,
                        provisionerType = provisionerType,
                        quality = qualityReq,
                        specialType = specialType,
                        known = true,
                    }

                    table.insert(listRecipes, recipeData)
                    table.insert(recipes.all, recipeData)
                end
            end

            if listCount > 0 then
                recipes.byList[listIndex] = listRecipes
            end
        end

        CM.Info(string.format("Recipes: %d total", totalRecipes))

        return recipes
    end

    -- ===== RESEARCH =====
    local function CollectResearch()
        local research = {
            blacksmithing = {},
            clothing = {},
            woodworking = {},
            jewelry = {},
        }

        -- Get research lines for each craft
        local craftingTypes = {
            { type = CRAFTING_TYPE_BLACKSMITHING, name = "blacksmithing", list = research.blacksmithing },
            { type = CRAFTING_TYPE_CLOTHIER, name = "clothing", list = research.clothing },
            { type = CRAFTING_TYPE_WOODWORKING, name = "woodworking", list = research.woodworking },
            { type = CRAFTING_TYPE_JEWELRYCRAFTING, name = "jewelry", list = research.jewelry },
        }

        for _, craftInfo in ipairs(craftingTypes) do
            if craftInfo.type then
                local numLines = CM.SafeCall(GetNumSmithingResearchLines, craftInfo.type) or 0

                for lineIndex = 1, numLines do
                    local success, lineName, icon, numTraits, timeRequired =
                        pcall(GetSmithingResearchLineInfo, craftInfo.type, lineIndex)
                    if success and lineName and lineName ~= "" then
                        local lineData = {
                            name = lineName,
                            numTraits = numTraits or 0,
                            traits = {},
                        }

                        -- Get trait info for this line
                        local numTraitsForLine = CM.SafeCall(
                            GetNumSmithingResearchLineTraits,
                            craftInfo.type,
                            lineIndex
                        ) or 0
                        for traitIndex = 1, numTraitsForLine do
                            local success2, traitType, traitDesc, known =
                                pcall(GetSmithingResearchLineTraitInfo, craftInfo.type, lineIndex, traitIndex)
                            if success2 and traitType then
                                table.insert(lineData.traits, {
                                    type = traitType,
                                    description = traitDesc,
                                    known = known or false,
                                })
                            end
                        end

                        table.insert(craftInfo.list, lineData)
                    end
                end
            end
        end

        return research
    end

    -- ===== RESEARCH TIMERS =====
    local function CollectResearchTimers()
        local timers = {
            active = {},
            completed = {},
            total = 0,
        }

        -- Get active research timers
        local numTimers = CM.SafeCall(GetNumCurrentResearchTimers) or 0

        for i = 1, numTimers do
            local success, craftingType, lineIndex, traitIndex, timeRemaining = pcall(GetCurrentResearchTimerInfo, i)
            if success and craftingType then
                table.insert(timers.active, {
                    craftingType = craftingType,
                    lineIndex = lineIndex,
                    traitIndex = traitIndex,
                    timeRemaining = timeRemaining or 0,
                })
            end
        end

        timers.total = numTimers

        return timers
    end

    -- Collect all crafting data
    crafting.motifs = CollectMotifs()
    crafting.recipes = CollectRecipes()
    crafting.research = CollectResearch()
    crafting.timers = CollectResearchTimers()

    return crafting
end

CM.collectors.CollectCraftingKnowledgeData = CollectCraftingData
