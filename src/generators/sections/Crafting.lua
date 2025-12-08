-- CharacterMarkdown - Crafting Section Generators
-- Generates crafting-related markdown sections (motifs, recipes, research)

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
-- HELPER: GENERATE MOTIFS COLUMN
-- =====================================================

local function GenerateMotifsColumn(craftingData)
    local markdown = ""

    if not craftingData.motifs or #craftingData.motifs == 0 then
        return markdown
    end

    markdown = markdown .. "#### 🎨 Known Motifs\n\n"

    local knownMotifs = {}
    local unknownMotifs = {}

    for _, motif in ipairs(craftingData.motifs) do
        if motif.known then
            table.insert(knownMotifs, motif)
        else
            table.insert(unknownMotifs, motif)
        end
    end

    if #knownMotifs > 0 then
        markdown = markdown .. "**Known (" .. #knownMotifs .. "):**\n"
        for _, motif in ipairs(knownMotifs) do
            markdown = markdown .. "- ✅ " .. motif.name
            if motif.category and motif.category ~= "" then
                markdown = markdown .. " (" .. motif.category .. ")"
            end
            markdown = markdown .. "\n"
        end
        markdown = markdown .. "\n"
    end

    if #unknownMotifs > 0 then
        markdown = markdown .. "**Unknown (" .. #unknownMotifs .. "):**\n"
        for _, motif in ipairs(unknownMotifs) do
            markdown = markdown .. "- ❌ " .. motif.name
            if motif.category and motif.category ~= "" then
                markdown = markdown .. " (" .. motif.category .. ")"
            end
            markdown = markdown .. "\n"
        end
    end

    return markdown
end

-- =====================================================
-- HELPER: GENERATE RECIPES COLUMN
-- =====================================================

local function GenerateRecipesColumn(craftingData)
    local markdown = ""

    if not craftingData.recipes then
        return markdown
    end

    markdown = markdown .. "#### 📜 Recipe Knowledge\n\n"

    -- New collector structure: recipes.all contains all known recipes
    if craftingData.recipes.all and #craftingData.recipes.all > 0 then
        markdown = markdown .. "**Total Known Recipes:** " .. #craftingData.recipes.all .. "\n\n"

        -- Group by list index for organized display
        if craftingData.recipes.byList then
            local listIndexes = {}
            for listIndex, _ in pairs(craftingData.recipes.byList) do
                table.insert(listIndexes, listIndex)
            end
            table.sort(listIndexes)

            for _, listIndex in ipairs(listIndexes) do
                local listRecipes = craftingData.recipes.byList[listIndex]
                if listRecipes and #listRecipes > 0 then
                    markdown = markdown .. "- List " .. listIndex .. ": " .. #listRecipes .. " recipes\n"
                end
            end
        end
    else
        markdown = markdown .. "*No recipes learned yet*\n"
    end

    return markdown
end

-- =====================================================
-- HELPER: GENERATE RESEARCH COLUMN
-- =====================================================

local function GenerateResearchColumn(craftingData)
    local markdown = ""

    if not craftingData.research then
        return markdown
    end

    markdown = markdown .. "#### 🔬 Research Progress\n\n"

    local craftTypes = {
        { name = "Blacksmithing", key = "blacksmithing", emoji = "⚒️" },
        { name = "Clothing", key = "clothing", emoji = "🧵" },
        { name = "Woodworking", key = "woodworking", emoji = "🪵" },
        { name = "Jewelry", key = "jewelry", emoji = "💎" },
    }

    for _, craftType in ipairs(craftTypes) do
        local researchLines = craftingData.research[craftType.key]
        if researchLines and #researchLines > 0 then
            markdown = markdown .. "**" .. craftType.emoji .. " " .. craftType.name .. "**\n"

            for _, line in ipairs(researchLines) do
                markdown = markdown .. "- " .. line.name .. ": " .. (line.numTraits or 0) .. " traits\n"
            end
            markdown = markdown .. "\n"
        end
    end

    return markdown
end

-- =====================================================
-- CRAFTING KNOWLEDGE
-- =====================================================

local function GenerateCrafting(craftingData)
    InitializeUtilities()

    local markdown = ""

    if not craftingData or (not craftingData.motifs or #craftingData.motifs == 0) then
        return ""
    end

    if false then
        -- Legacy Discord block removed
    else
        -- GitHub/VSCode: Detailed format with 3-column layout
        local anchorId = GenerateAnchor and GenerateAnchor("🔨 Crafting Knowledge") or "crafting-knowledge"
        markdown = markdown .. string.format('<a id="%s"></a>\n\n', anchorId)
        markdown = markdown .. "## 🔨 Crafting Knowledge\n\n"

        -- Use 3-column layout for crafting areas (GitHub/VSCode only)
        local CreateThreeColumnLayout = CM.utils.markdown and CM.utils.markdown.CreateThreeColumnLayout

        if CreateThreeColumnLayout then
            -- Generate each crafting area in its own column
            local column1 = GenerateMotifsColumn(craftingData)
            local column2 = GenerateRecipesColumn(craftingData)
            local column3 = GenerateResearchColumn(craftingData)

            -- Wrap in 3-column layout
            markdown = markdown .. CreateThreeColumnLayout(column1, column2, column3)
        else
            -- Fallback to vertical layout if multi-column not available
            markdown = markdown .. GenerateMotifsColumn(craftingData) .. "\n"
            markdown = markdown .. GenerateRecipesColumn(craftingData) .. "\n"
            markdown = markdown .. GenerateResearchColumn(craftingData) .. "\n"
        end

        -- Use CreateSeparator for consistent separator styling
        local CreateSeparator = CM.utils.markdown and CM.utils.markdown.CreateSeparator
        if CreateSeparator then
            markdown = markdown .. CreateSeparator("hr")
        else
            markdown = markdown .. "---\n\n"
        end
    end

    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateCrafting = GenerateCrafting
