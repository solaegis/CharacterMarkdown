-- CharacterMarkdown - Crafting Data Collector
-- Comprehensive crafting knowledge (Tier 1 - Motifs, recipes, traits, research)

local CM = CharacterMarkdown

-- =====================================================
-- CACHED GLOBALS (PERFORMANCE)
-- =====================================================

local GetNumSmithingStylePages = GetNumSmithingStylePages
local GetSmithingStylePageInfo = GetSmithingStylePageInfo
local IsSmithingStyleKnown = IsSmithingStyleKnown
local GetNumSmithingResearchLines = GetNumSmithingResearchLines
local GetSmithingResearchLineInfo = GetSmithingResearchLineInfo
local GetSmithingResearchLineTraitTimes = GetSmithingResearchLineTraitTimes
local GetNumRecipeLists = GetNumRecipeLists
local GetRecipeListInfo = GetRecipeListInfo
local GetNumRecipesInRecipeList = GetNumRecipesInRecipeList
local GetRecipeInfo = GetRecipeInfo
local GetRecipeResultItemInfo = GetRecipeResultItemInfo
local DoesRecipeResultMatchSearch = DoesRecipeResultMatchSearch
local GetNumAlchemyRecipes = GetNumAlchemyRecipes
local GetAlchemyRecipeInfo = GetAlchemyRecipeInfo
local GetNumEnchantingRecipes = GetNumEnchantingRecipes
local GetEnchantingRecipeInfo = GetEnchantingRecipeInfo
local GetNumProvisioningRecipes = GetNumProvisioningRecipes
local GetProvisioningRecipeInfo = GetProvisioningRecipeInfo
local GetNumWoodworkingRecipes = GetNumWoodworkingRecipes
local GetWoodworkingRecipeInfo = GetWoodworkingRecipeInfo
local GetNumClothingRecipes = GetNumClothingRecipes
local GetClothingRecipeInfo = GetClothingRecipeInfo
local GetNumBlacksmithingRecipes = GetNumBlacksmithingRecipes
local GetBlacksmithingRecipeInfo = GetBlacksmithingRecipeInfo
local GetNumJewelryCraftingRecipes = GetNumJewelryCraftingRecipes
local GetJewelryCraftingRecipeInfo = GetJewelryCraftingRecipeInfo

-- =====================================================
-- CRAFTING KNOWLEDGE COLLECTION
-- =====================================================

local function CollectCraftingData()
    local crafting = {
        motifs = {},
        recipes = {},
        research = {},
        timers = {}
    }
    
    -- ===== MOTIFS =====
    local function CollectMotifs()
        local motifs = {}
        
        -- Get all style pages
        local numPages = GetNumSmithingStylePages()
        for pageIndex = 1, numPages do
            local pageName, pageCategory, pageSubcategory = GetSmithingStylePageInfo(pageIndex)
            if pageName and pageName ~= "" then
                local isKnown = IsSmithingStyleKnown(pageIndex)
                table.insert(motifs, {
                    name = pageName,
                    category = pageCategory,
                    subcategory = pageSubcategory,
                    known = isKnown,
                    pageIndex = pageIndex
                })
            end
        end
        
        return motifs
    end
    
    -- ===== RECIPES =====
    local function CollectRecipes()
        local recipes = {
            provisioning = {},
            alchemy = {},
            enchanting = {},
            blacksmithing = {},
            clothing = {},
            woodworking = {},
            jewelry = {}
        }
        
        -- Provisioning recipes
        local numProvisioning = GetNumProvisioningRecipes()
        for i = 1, numProvisioning do
            local recipeName, recipeType, provisionerType, quality = GetProvisioningRecipeInfo(i)
            if recipeName and recipeName ~= "" then
                table.insert(recipes.provisioning, {
                    name = recipeName,
                    type = recipeType,
                    provisionerType = provisionerType,
                    quality = quality,
                    index = i
                })
            end
        end
        
        -- Alchemy recipes
        local numAlchemy = GetNumAlchemyRecipes()
        for i = 1, numAlchemy do
            local recipeName, recipeType, quality = GetAlchemyRecipeInfo(i)
            if recipeName and recipeName ~= "" then
                table.insert(recipes.alchemy, {
                    name = recipeName,
                    type = recipeType,
                    quality = quality,
                    index = i
                })
            end
        end
        
        -- Enchanting recipes
        local numEnchanting = GetNumEnchantingRecipes()
        for i = 1, numEnchanting do
            local recipeName, recipeType, quality = GetEnchantingRecipeInfo(i)
            if recipeName and recipeName ~= "" then
                table.insert(recipes.enchanting, {
                    name = recipeName,
                    type = recipeType,
                    quality = quality,
                    index = i
                })
            end
        end
        
        -- Blacksmithing recipes
        local numBlacksmithing = GetNumBlacksmithingRecipes()
        for i = 1, numBlacksmithing do
            local recipeName, recipeType, quality = GetBlacksmithingRecipeInfo(i)
            if recipeName and recipeName ~= "" then
                table.insert(recipes.blacksmithing, {
                    name = recipeName,
                    type = recipeType,
                    quality = quality,
                    index = i
                })
            end
        end
        
        -- Clothing recipes
        local numClothing = GetNumClothingRecipes()
        for i = 1, numClothing do
            local recipeName, recipeType, quality = GetClothingRecipeInfo(i)
            if recipeName and recipeName ~= "" then
                table.insert(recipes.clothing, {
                    name = recipeName,
                    type = recipeType,
                    quality = quality,
                    index = i
                })
            end
        end
        
        -- Woodworking recipes
        local numWoodworking = GetNumWoodworkingRecipes()
        for i = 1, numWoodworking do
            local recipeName, recipeType, quality = GetWoodworkingRecipeInfo(i)
            if recipeName and recipeName ~= "" then
                table.insert(recipes.woodworking, {
                    name = recipeName,
                    type = recipeType,
                    quality = quality,
                    index = i
                })
            end
        end
        
        -- Jewelry crafting recipes
        local numJewelry = GetNumJewelryCraftingRecipes()
        for i = 1, numJewelry do
            local recipeName, recipeType, quality = GetJewelryCraftingRecipeInfo(i)
            if recipeName and recipeName ~= "" then
                table.insert(recipes.jewelry, {
                    name = recipeName,
                    type = recipeType,
                    quality = quality,
                    index = i
                })
            end
        end
        
        return recipes
    end
    
    -- ===== RESEARCH =====
    local function CollectResearch()
        local research = {
            blacksmithing = {},
            clothing = {},
            woodworking = {},
            jewelry = {}
        }
        
        -- Get research lines for each craft
        local craftTypes = {
            {name = "blacksmithing", func = GetNumSmithingResearchLines},
            {name = "clothing", func = GetNumSmithingResearchLines},
            {name = "woodworking", func = GetNumSmithingResearchLines},
            {name = "jewelry", func = GetNumSmithingResearchLines}
        }
        
        for _, craftType in ipairs(craftTypes) do
            local numLines = craftType.func()
            for lineIndex = 1, numLines do
                local lineName, numTraits, timeRequired = GetSmithingResearchLineInfo(lineIndex)
                if lineName and lineName ~= "" then
                    local traitTimes = GetSmithingResearchLineTraitTimes(lineIndex)
                    table.insert(research[craftType.name], {
                        name = lineName,
                        numTraits = numTraits,
                        timeRequired = timeRequired,
                        traitTimes = traitTimes,
                        lineIndex = lineIndex
                    })
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
            total = 0
        }
        
        -- This would need to be implemented based on available API
        -- For now, return empty structure
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
