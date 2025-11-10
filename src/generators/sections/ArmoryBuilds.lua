-- CharacterMarkdown - Armory Builds Section Generator
-- Generates armory builds and templates markdown sections

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
-- ARMORY BUILDS
-- =====================================================

local function GenerateArmoryBuilds(armoryData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if not armoryData or not armoryData.armory then
        -- Show placeholder when enabled but no data available
        if format ~= "discord" then
            local anchorId = GenerateAnchor and GenerateAnchor("🏰 Armory Builds") or "armory-builds"
            markdown = markdown .. string.format('<a id="%s"></a>\n\n', anchorId)
            markdown = markdown .. "## 🏰 Armory Builds\n\n"
            markdown = markdown .. "*No armory builds available*\n\n---\n\n"
        end
        return markdown
    end
    
    -- Always show section when enabled (even if total is 0)
    
    local armory = armoryData.armory or {total = 0, active = 0, builds = {}}
    local templates = armoryData.templates or {total = 0}
    
    if format == "discord" then
        markdown = markdown .. "**Armory Builds:** " .. (armory.total or 0) .. " total"
        if armory.active and armory.active > 0 then
            markdown = markdown .. " (" .. armory.active .. " active)"
        end
        markdown = markdown .. "\n"
        
        if armory.builds and #armory.builds > 0 then
            for _, build in ipairs(armory.builds) do
                local status = build.active and "✅" or ""
                markdown = markdown .. "• " .. status .. " " .. build.name .. "\n"
            end
        end
        
        if templates and templates.total > 0 then
            markdown = markdown .. "**Templates:** " .. templates.total .. " available\n"
        end
        
        markdown = markdown .. "\n"
    else
        local anchorId = GenerateAnchor and GenerateAnchor("🏰 Armory Builds") or "armory-builds"
        markdown = markdown .. string.format('<a id="%s"></a>\n\n', anchorId)
        markdown = markdown .. "## 🏰 Armory Builds\n\n"
        
        if armory.total and armory.total > 0 then
            markdown = markdown .. "| Build Name | Status |\n"
            markdown = markdown .. "|:-----------|:-------|\n"
            
            if armory.builds and #armory.builds > 0 then
                for _, build in ipairs(armory.builds) do
                    local status = build.active and "✅ **Active**" or "Inactive"
                    markdown = markdown .. "| " .. build.name .. " | " .. status .. " |\n"
                end
            end
            
            markdown = markdown .. "\n"
        else
            markdown = markdown .. "*No armory builds configured*\n\n"
        end
        
        if templates and templates.total > 0 then
            markdown = markdown .. "### 📋 Build Templates\n\n"
            markdown = markdown .. "**Available Templates:** " .. templates.total .. "\n\n"
            
            if templates.categories then
                for categoryName, categoryData in pairs(templates.categories) do
                    if categoryData.total > 0 then
                        markdown = markdown .. "#### " .. categoryName .. " (" .. categoryData.total .. ")\n\n"
                        if categoryData.templates and #categoryData.templates > 0 then
                            for _, template in ipairs(categoryData.templates) do
                                markdown = markdown .. "- " .. template.name
                                if template.description and template.description ~= "" then
                                    markdown = markdown .. " - " .. template.description
                                end
                                markdown = markdown .. "\n"
                            end
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
CM.generators.sections.GenerateArmoryBuilds = GenerateArmoryBuilds

return {
    GenerateArmoryBuilds = GenerateArmoryBuilds,
}

