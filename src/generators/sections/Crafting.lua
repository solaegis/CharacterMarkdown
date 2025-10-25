-- CharacterMarkdown - Crafting Section Generators
-- Generates crafting-related markdown sections (motifs, recipes, research)

local CM = CharacterMarkdown

-- Cache for utility functions (lazy-initialized on first use)
local FormatNumber

-- Lazy initialization of cached references
local function InitializeUtilities()
    if not FormatNumber then
        FormatNumber = CM.utils.FormatNumber
    end
end

-- =====================================================
-- CRAFTING KNOWLEDGE
-- =====================================================

local function GenerateCrafting(craftingData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if not craftingData or (not craftingData.motifs or #craftingData.motifs == 0) then
        return ""
    end
    
    if format == "discord" then
        -- Discord: Compact format
        markdown = markdown .. "\n**Crafting Knowledge:**\n"
        
        -- Motifs summary
        local knownMotifs = 0
        local totalMotifs = #craftingData.motifs
        for _, motif in ipairs(craftingData.motifs) do
            if motif.known then
                knownMotifs = knownMotifs + 1
            end
        end
        
        markdown = markdown .. "🎨 **Motifs:** " .. knownMotifs .. "/" .. totalMotifs .. " known\n"
        
        -- Recipe counts
        local totalRecipes = 0
        for craftType, recipes in pairs(craftingData.recipes) do
            totalRecipes = totalRecipes + #recipes
        end
        
        markdown = markdown .. "📜 **Recipes:** " .. totalRecipes .. " total\n"
        
        -- Research summary
        local totalResearchLines = 0
        for craftType, lines in pairs(craftingData.research) do
            totalResearchLines = totalResearchLines + #lines
        end
        
        markdown = markdown .. "🔬 **Research:** " .. totalResearchLines .. " lines\n"
        
    else
        -- GitHub/VSCode: Detailed format
        markdown = markdown .. "## 🔨 Crafting Knowledge\n\n"
        
        -- ===== MOTIFS =====
        if #craftingData.motifs > 0 then
            markdown = markdown .. "### 🎨 Known Motifs\n\n"
            
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
                markdown = markdown .. "**Known Motifs (" .. #knownMotifs .. "):**\n"
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
                markdown = markdown .. "**Unknown Motifs (" .. #unknownMotifs .. "):**\n"
                for _, motif in ipairs(unknownMotifs) do
                    markdown = markdown .. "- ❌ " .. motif.name
                    if motif.category and motif.category ~= "" then
                        markdown = markdown .. " (" .. motif.category .. ")"
                    end
                    markdown = markdown .. "\n"
                end
                markdown = markdown .. "\n"
            end
        end
        
        -- ===== RECIPES =====
        if craftingData.recipes then
            markdown = markdown .. "### 📜 Recipe Knowledge\n\n"
            
            local craftTypes = {
                {name = "Provisioning", key = "provisioning", emoji = "🍳"},
                {name = "Alchemy", key = "alchemy", emoji = "🧪"},
                {name = "Enchanting", key = "enchanting", emoji = "✨"},
                {name = "Blacksmithing", key = "blacksmithing", emoji = "⚒️"},
                {name = "Clothing", key = "clothing", emoji = "🧵"},
                {name = "Woodworking", key = "woodworking", emoji = "🪵"},
                {name = "Jewelry", key = "jewelry", emoji = "💎"}
            }
            
            for _, craftType in ipairs(craftTypes) do
                local recipes = craftingData.recipes[craftType.key]
                if recipes and #recipes > 0 then
                    markdown = markdown .. "#### " .. craftType.emoji .. " " .. craftType.name .. " (" .. #recipes .. " recipes)\n\n"
                    
                    -- Group recipes by quality
                    local qualityGroups = {}
                    for _, recipe in ipairs(recipes) do
                        local quality = recipe.quality or 1
                        if not qualityGroups[quality] then
                            qualityGroups[quality] = {}
                        end
                        table.insert(qualityGroups[quality], recipe)
                    end
                    
                    -- Display recipes by quality
                    for quality = 1, 5 do
                        if qualityGroups[quality] then
                            local qualityNames = {"White", "Green", "Blue", "Purple", "Gold"}
                            local qualityName = qualityNames[quality] or "Unknown"
                            markdown = markdown .. "**" .. qualityName .. " Quality (" .. #qualityGroups[quality] .. "):**\n"
                            
                            for _, recipe in ipairs(qualityGroups[quality]) do
                                markdown = markdown .. "- " .. recipe.name
                                if recipe.type and recipe.type ~= "" then
                                    markdown = markdown .. " (" .. recipe.type .. ")"
                                end
                                markdown = markdown .. "\n"
                            end
                            markdown = markdown .. "\n"
                        end
                    end
                end
            end
        end
        
        -- ===== RESEARCH =====
        if craftingData.research then
            markdown = markdown .. "### 🔬 Research Progress\n\n"
            
            local craftTypes = {
                {name = "Blacksmithing", key = "blacksmithing", emoji = "⚒️"},
                {name = "Clothing", key = "clothing", emoji = "🧵"},
                {name = "Woodworking", key = "woodworking", emoji = "🪵"},
                {name = "Jewelry", key = "jewelry", emoji = "💎"}
            }
            
            for _, craftType in ipairs(craftTypes) do
                local researchLines = craftingData.research[craftType.key]
                if researchLines and #researchLines > 0 then
                    markdown = markdown .. "#### " .. craftType.emoji .. " " .. craftType.name .. "\n\n"
                    
                    for _, line in ipairs(researchLines) do
                        markdown = markdown .. "**" .. line.name .. ":**\n"
                        markdown = markdown .. "- Traits: " .. (line.numTraits or 0) .. "\n"
                        markdown = markdown .. "- Time Required: " .. (line.timeRequired or 0) .. " hours\n"
                        
                        if line.traitTimes and #line.traitTimes > 0 then
                            markdown = markdown .. "- Trait Times: " .. table.concat(line.traitTimes, ", ") .. " hours\n"
                        end
                        markdown = markdown .. "\n"
                    end
                end
            end
        end
        
        markdown = markdown .. "---\n\n"
    end
    
    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateCrafting = GenerateCrafting
