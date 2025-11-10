-- CharacterMarkdown - Equipment Enhancement Markdown Generator
-- Phase 7: Advanced equipment analysis and optimization display

local CM = CharacterMarkdown

-- =====================================================
-- UTILITIES
-- =====================================================

local function InitializeUtilities()
    if not CM.utils then
        CM.utils = {}
    end
    
    -- Lazy load utilities
    if not CM.utils.FormatNumber then
        local Formatters = CM.generators.helpers.Utilities
        CM.utils.FormatNumber = Formatters.FormatNumber
        CM.utils.GenerateProgressBar = Formatters.GenerateProgressBar
    end
    
    -- Load GenerateAnchor
    if not CM.utils.GenerateAnchor and CM.utils.markdown and CM.utils.markdown.GenerateAnchor then
        CM.utils.GenerateAnchor = CM.utils.markdown.GenerateAnchor
    end
end

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

local function GetPriorityEmoji(priority)
    local emojis = {
        ["High"] = "🔴",
        ["Medium"] = "🟡",
        ["Low"] = "🟢"
    }
    return emojis[priority] or "⚪"
end

local function GetCategoryEmoji(category)
    local emojis = {
        ["Set Bonuses"] = "🎯",
        ["Quality Upgrade"] = "⬆️",
        ["Enchantment Analysis"] = "✨",
        ["Trait Optimization"] = "🔧",
        ["Level Requirements"] = "📊",
        ["Crafted vs Dropped"] = "⚒️",
        ["Value Analysis"] = "💰"
    }
    return emojis[category] or "🔧"
end

local function GetQualityEmoji(quality)
    local emojis = {
        [0] = "⚪", -- White
        [1] = "🟢", -- Green
        [2] = "🔵", -- Blue
        [3] = "🟣", -- Purple
        [4] = "🟠", -- Gold
        [5] = "🟡"  -- Legendary
    }
    return emojis[quality] or "⚪"
end

-- =====================================================
-- EQUIPMENT ENHANCEMENT SUMMARY GENERATOR
-- =====================================================

local function GenerateEquipmentEnhancementSummary(enhancementData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Equipment Analysis:**\n"
    else
        local anchorId = CM.utils.GenerateAnchor and CM.utils.GenerateAnchor("⚡ Equipment Enhancement Analysis") or "equipment-enhancement-analysis"
        markdown = markdown .. string.format('<a id="%s"></a>\n\n', anchorId)
        markdown = markdown .. "## ⚡ Equipment Enhancement Analysis\n\n"
    end
    
    local summary = enhancementData.summary
    
    if format == "discord" then
        markdown = markdown .. "Items: " .. CM.utils.FormatNumber(summary.totalItems) .. " | "
        markdown = markdown .. "Value: " .. CM.utils.FormatNumber(summary.totalValue) .. " | "
        markdown = markdown .. "Avg Quality: " .. summary.averageQuality .. " | "
        markdown = markdown .. "Upgradeable: " .. CM.utils.FormatNumber(summary.upgradeableItems) .. "\n"
    else
        markdown = markdown .. "| Metric | Value |\n"
        markdown = markdown .. "|:-------|------:|\n"
        markdown = markdown .. "| **Total Items** | " .. CM.utils.FormatNumber(summary.totalItems) .. " |\n"
        markdown = markdown .. "| **Total Value** | " .. CM.utils.FormatNumber(summary.totalValue) .. " |\n"
        markdown = markdown .. "| **Average Quality** | " .. GetQualityEmoji(summary.averageQuality) .. " " .. summary.averageQuality .. " |\n"
        markdown = markdown .. "| **Active Sets** | " .. CM.utils.FormatNumber(summary.setCount) .. " |\n"
        markdown = markdown .. "| **Upgradeable Items** | " .. CM.utils.FormatNumber(summary.upgradeableItems) .. " |\n"
        markdown = markdown .. "\n"
    end
    
    return markdown
end

-- =====================================================
-- SET BONUS ANALYSIS GENERATOR
-- =====================================================

local function GenerateSetBonusAnalysis(analysisData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Set Bonus Analysis:**\n"
    else
        markdown = markdown .. "### 🎯 Set Bonus Analysis\n\n"
    end
    
    local activeSets = analysisData.activeSets or {}
    local missingPieces = analysisData.missingPieces or {}
    
    if format == "discord" then
        for _, set in ipairs(activeSets) do
            local statusIcon = set.isComplete and "✅" or "🔄"
            markdown = markdown .. statusIcon .. " **" .. set.name .. "**: " .. (set.pieces or 0) .. "/5 pieces\n"
        end
        
        if #missingPieces > 0 then
            markdown = markdown .. "\n**Missing Pieces:**\n"
            for _, missing in ipairs(missingPieces) do
                local priorityIcon = GetPriorityEmoji(missing.priority)
                markdown = markdown .. priorityIcon .. " " .. missing.setName .. " (" .. missing.missingPieces .. " missing)\n"
            end
        end
    else
        markdown = markdown .. "| Set | Pieces | Status |\n"
        markdown = markdown .. "|:----|-------:|:-------|\n"
        
        for _, set in ipairs(activeSets) do
            local statusIcon = set.isComplete and "✅ Complete" or "🔄 " .. (set.pieces or 0) .. "/5"
            markdown = markdown .. "| **" .. set.name .. "** | " .. (set.pieces or 0) .. " | " .. statusIcon .. " |\n"
        end
        
        if #missingPieces > 0 then
            markdown = markdown .. "\n**Missing Pieces:**\n"
            markdown = markdown .. "| Set | Missing | Priority |\n"
            markdown = markdown .. "|:----|--------:|:--------|\n"
            
            for _, missing in ipairs(missingPieces) do
                local priorityIcon = GetPriorityEmoji(missing.priority)
                markdown = markdown .. "| **" .. missing.setName .. "** | " .. missing.missingPieces .. " | " .. priorityIcon .. " " .. missing.priority .. " |\n"
            end
        end
        markdown = markdown .. "\n"
    end
    
    return markdown
end

-- =====================================================
-- QUALITY UPGRADE ANALYSIS GENERATOR
-- =====================================================

local function GenerateQualityUpgradeAnalysis(analysisData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Quality Upgrade Analysis:**\n"
    else
        markdown = markdown .. "### ⬆️ Quality Upgrade Analysis\n\n"
    end
    
    local upgradeable = analysisData.upgradeable or {}
    
    if #upgradeable == 0 then
        markdown = markdown .. "*No upgradeable items found*\n\n"
        return markdown
    end
    
    if format == "discord" then
        for _, item in ipairs(upgradeable) do
            local qualityIcon = GetQualityEmoji(item.currentQuality)
            markdown = markdown .. qualityIcon .. " **" .. item.name .. "**: " .. item.currentQuality .. " → 5 (" .. item.upgradePotential .. " upgrades)\n"
        end
    else
        markdown = markdown .. "| Item | Current | Target | Upgrades | Slot |\n"
        markdown = markdown .. "|:-----|--------:|-------:|---------:|:----|\n"
        
        for _, item in ipairs(upgradeable) do
            local currentIcon = GetQualityEmoji(item.currentQuality)
            local targetIcon = GetQualityEmoji(5)
            markdown = markdown .. "| **" .. item.name .. "** | " .. currentIcon .. " " .. item.currentQuality .. " | " .. targetIcon .. " 5 | " .. item.upgradePotential .. " | " .. item.slot .. " |\n"
        end
        markdown = markdown .. "\n"
    end
    
    return markdown
end

-- =====================================================
-- ENCHANTMENT ANALYSIS GENERATOR
-- =====================================================

local function GenerateEnchantmentAnalysis(analysisData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Enchantment Analysis:**\n"
    else
        markdown = markdown .. "### ✨ Enchantment Analysis\n\n"
    end
    
    local enchantments = analysisData.enchantments or {}
    local recommendations = analysisData.recommendations or {}
    
    if format == "discord" then
        for _, enchant in ipairs(enchantments) do
            local chargeIcon = enchant.chargePercent > 75 and "🟢" or enchant.chargePercent > 50 and "🟡" or "🔴"
            markdown = markdown .. chargeIcon .. " **" .. enchant.name .. "** on " .. enchant.item .. " (" .. enchant.chargePercent .. "%)\n"
        end
        
        if #recommendations > 0 then
            markdown = markdown .. "\n**Recommendations:**\n"
            for _, rec in ipairs(recommendations) do
                local priorityIcon = GetPriorityEmoji(rec.priority)
                markdown = markdown .. priorityIcon .. " " .. rec.enchantment .. " on " .. rec.item .. " (" .. rec.currentPercent .. "%)\n"
            end
        end
    else
        markdown = markdown .. "| Enchantment | Item | Charge | Status |\n"
        markdown = markdown .. "|:------------|:-----|-------:|:-------|\n"
        
        for _, enchant in ipairs(enchantments) do
            local chargeIcon = enchant.chargePercent > 75 and "🟢" or enchant.chargePercent > 50 and "🟡" or "🔴"
            local status = enchant.chargePercent > 75 and "Good" or enchant.chargePercent > 50 and "Low" or "Critical"
            markdown = markdown .. "| **" .. enchant.name .. "** | " .. enchant.item .. " | " .. enchant.chargePercent .. "% | " .. chargeIcon .. " " .. status .. " |\n"
        end
        
        if #recommendations > 0 then
            markdown = markdown .. "\n**Recommendations:**\n"
            markdown = markdown .. "| Priority | Action | Item | Enchantment |\n"
            markdown = markdown .. "|:---------|:-------|:-----|:------------|\n"
            
            for _, rec in ipairs(recommendations) do
                local priorityIcon = GetPriorityEmoji(rec.priority)
                markdown = markdown .. "| " .. priorityIcon .. " " .. rec.priority .. " | " .. rec.type .. " | " .. rec.item .. " | " .. rec.enchantment .. " |\n"
            end
        end
        markdown = markdown .. "\n"
    end
    
    return markdown
end

-- =====================================================
-- TRAIT ANALYSIS GENERATOR
-- =====================================================

local function GenerateTraitAnalysis(analysisData, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Trait Analysis:**\n"
    else
        markdown = markdown .. "### 🔧 Trait Analysis\n\n"
    end
    
    local traits = analysisData.traits or {}
    local recommendations = analysisData.recommendations or {}
    local traitCounts = analysisData.traitCounts or {}
    
    if format == "discord" then
        for traitName, count in pairs(traitCounts) do
            markdown = markdown .. "**" .. traitName .. "**: " .. count .. " items\n"
        end
        
        if #recommendations > 0 then
            markdown = markdown .. "\n**Recommendations:**\n"
            for _, rec in ipairs(recommendations) do
                local priorityIcon = GetPriorityEmoji(rec.priority)
                markdown = markdown .. priorityIcon .. " " .. rec.trait .. " appears " .. rec.count .. " times\n"
            end
        end
    else
        markdown = markdown .. "| Trait | Count | Items |\n"
        markdown = markdown .. "|:------|------:|:------|\n"
        
        for traitName, count in pairs(traitCounts) do
            local items = {}
            for _, trait in ipairs(traits) do
                if trait.name == traitName then
                    table.insert(items, trait.item)
                end
            end
            markdown = markdown .. "| **" .. traitName .. "** | " .. count .. " | " .. table.concat(items, ", ") .. " |\n"
        end
        
        if #recommendations > 0 then
            markdown = markdown .. "\n**Recommendations:**\n"
            markdown = markdown .. "| Priority | Trait | Count | Recommendation |\n"
            markdown = markdown .. "|:---------|:------|------:|:---------------|\n"
            
            for _, rec in ipairs(recommendations) do
                local priorityIcon = GetPriorityEmoji(rec.priority)
                markdown = markdown .. "| " .. priorityIcon .. " " .. rec.priority .. " | " .. rec.trait .. " | " .. rec.count .. " | " .. rec.type .. " |\n"
            end
        end
        markdown = markdown .. "\n"
    end
    
    return markdown
end

-- =====================================================
-- RECOMMENDATIONS GENERATOR
-- =====================================================

local function GenerateRecommendations(recommendations, format)
    InitializeUtilities()
    
    local markdown = ""
    
    if format == "discord" then
        markdown = markdown .. "**Optimization Recommendations:**\n"
    else
        markdown = markdown .. "### 🎯 Optimization Recommendations\n\n"
    end
    
    if #recommendations == 0 then
        markdown = markdown .. "*No recommendations available*\n\n"
        return markdown
    end
    
    -- Group by priority
    local highPriority = {}
    local mediumPriority = {}
    local lowPriority = {}
    
    for _, rec in ipairs(recommendations) do
        if rec.priority == "High" then
            table.insert(highPriority, rec)
        elseif rec.priority == "Medium" then
            table.insert(mediumPriority, rec)
        else
            table.insert(lowPriority, rec)
        end
    end
    
    if format == "discord" then
        if #highPriority > 0 then
            markdown = markdown .. "**High Priority:**\n"
            for _, rec in ipairs(highPriority) do
                markdown = markdown .. "🔴 " .. rec.description .. "\n"
            end
        end
        
        if #mediumPriority > 0 then
            markdown = markdown .. "\n**Medium Priority:**\n"
            for _, rec in ipairs(mediumPriority) do
                markdown = markdown .. "🟡 " .. rec.description .. "\n"
            end
        end
        
        if #lowPriority > 0 then
            markdown = markdown .. "\n**Low Priority:**\n"
            for _, rec in ipairs(lowPriority) do
                markdown = markdown .. "🟢 " .. rec.description .. "\n"
            end
        end
    else
        markdown = markdown .. "| Priority | Category | Recommendation |\n"
        markdown = markdown .. "|:---------|:---------|:---------------|\n"
        
        for _, rec in ipairs(recommendations) do
            local priorityIcon = GetPriorityEmoji(rec.priority)
            local categoryIcon = GetCategoryEmoji(rec.category)
            markdown = markdown .. "| " .. priorityIcon .. " " .. rec.priority .. " | " .. categoryIcon .. " " .. rec.category .. " | " .. rec.description .. " |\n"
        end
        markdown = markdown .. "\n"
    end
    
    return markdown
end

-- =====================================================
-- MAIN EQUIPMENT ENHANCEMENT GENERATOR
-- =====================================================

local function GenerateEquipmentEnhancement(enhancementData, format)
    -- Section disabled - return empty string
    return ""
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.sections = CM.generators.sections or {}
CM.generators.sections.GenerateEquipmentEnhancement = GenerateEquipmentEnhancement

return {
    GenerateEquipmentEnhancement = GenerateEquipmentEnhancement
}
