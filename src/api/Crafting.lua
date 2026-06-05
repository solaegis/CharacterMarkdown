-- CharacterMarkdown - API Layer - Crafting
-- Abstraction for research, motifs, and recipes

local CM = CharacterMarkdown
CM.api = CM.api or {}
CM.api.crafting = {}

local api = CM.api.crafting

-- =====================================================
-- GRANULAR GETTERS
-- =====================================================

function api.GetResearchInfo(craftingType)
    -- craftingType: CRAFTING_TYPE_BLACKSMITHING, etc.
    local numLines = CM.SafeCall(GetNumSmithingResearchLines, craftingType) or 0
    local lines = {}

    for i = 1, numLines do
        local _, name = CM.SafeCallMulti(GetSmithingResearchLineInfo, craftingType, i)
        if name then
            local traits = {}
            -- Check traits
            -- GetNumSmithingResearchLineTraits usually 9
            local numTraitItems = CM.SafeCall(GetNumSmithingResearchLineTraits, craftingType, i) or 9
            for j = 1, numTraitItems do
                local _, traitType, _, known = CM.SafeCallMulti(GetSmithingResearchLineTraitInfo, craftingType, i, j)
                table.insert(traits, {
                    id = traitType,
                    known = known,
                })
            end
            table.insert(lines, {
                name = name,
                traits = traits,
            })
        end
    end

    return lines
end

function api.GetActiveTimers()
    -- Get active research timers
    local numTimers = CM.SafeCall(GetNumCurrentResearchTimers) or 0
    local timers = {}
    for i = 1, numTimers do
        local _, craftType, _, _, secondsRemaining = CM.SafeCallMulti(GetCurrentResearchTimerInfo, i)
        if craftType then
            table.insert(timers, {
                craftType = craftType,
                seconds = secondsRemaining,
            })
        end
    end
    return timers
end

function api.GetKnownStyles()
    -- Get total number of item styles
    local highestId = CM.SafeCall(GetHighestItemStyleId) or 0
    local known = {}
    local count = 0

    for i = 1, highestId do
        -- Use pattern index 1 (Axes) as a probe for basic style knowledge
        -- For non-chaptered styles, any pattern works.
        -- For chaptered motifs, chapter 1 is usually learned first or along with others.
        local isKnown = CM.SafeCall(IsSmithingStyleKnown, i, 1)
        if isKnown then
            local name = CM.SafeCall(GetItemStyleName, i)
            if name and name ~= "" then
                table.insert(known, {
                    id = i,
                    name = name,
                })
                count = count + 1
            end
        end
    end

    return {
        count = count,
        list = known,
    }
end

function api.GetMotifKnowledge()
    -- We can use Lore Library to get organized motif data
    local loreApi = CM.api.lore
    if not loreApi then
        return {}
    end

    -- "Crafting Motifs" is usually category index 4, but we'll find it by name for safety
    local catIndex = loreApi.FindCategoryByName("Crafting Motifs")
    if not catIndex then
        -- Fallback to common index if name search fails (locale issues)
        catIndex = 4
    end

    local catInfo = loreApi.GetCategoryInfo(catIndex)
    if not catInfo then
        return {}
    end

    local motifs = {}
    for i = 1, catInfo.numCollections do
        local collInfo = loreApi.GetCollectionInfo(catIndex, i)
        if collInfo and not collInfo.hidden then
            local chapters = {}
            for j = 1, collInfo.totalBooks do
                local bookInfo = loreApi.GetBookInfo(catIndex, i, j)
                if bookInfo then
                    table.insert(chapters, {
                        name = bookInfo.title,
                        known = bookInfo.known,
                    })
                end
            end

            table.insert(motifs, {
                name = collInfo.name,
                numKnown = collInfo.numKnownBooks,
                total = collInfo.totalBooks,
                chapters = chapters,
                isCompleted = (collInfo.numKnownBooks == collInfo.totalBooks),
            })
        end
    end

    return motifs
end

function api.GetRecipeKnowledge()
    local numLists = CM.SafeCall(GetNumRecipeLists) or 0
    local allRecipes = {}
    local byList = {}

    for i = 1, numLists do
        local success, name, numRecipes = CM.SafeCallMulti(GetRecipeListInfo, i)
        if success and numRecipes > 0 then
            local listRecipes = {}
            for j = 1, numRecipes do
                local success_r, known, r_name, _, _, r_quality, _, r_craftType, r_resultId =
                    CM.SafeCallMulti(GetRecipeInfo, i, j)

                -- Note: GetRecipeInfo returns known as its first return value
                if success_r and known and r_name then
                    local recipe = {
                        name = r_name,
                        quality = r_quality,
                        craftType = r_craftType,
                        resultId = r_resultId,
                    }
                    table.insert(allRecipes, recipe)
                    table.insert(listRecipes, recipe)
                end
            end

            if #listRecipes > 0 then
                byList[name] = listRecipes
            end
        end
    end

    return {
        all = allRecipes,
        byList = byList,
        count = #allRecipes,
    }
end

CM.DebugPrint("API", "Crafting API updated with motif and recipe knowledge")
