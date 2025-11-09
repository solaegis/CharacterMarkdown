-- CharacterMarkdown - Equipment Enhancement Data Collector
-- Phase 7: Advanced equipment analysis and optimization

local CM = CharacterMarkdown

-- =====================================================
-- QUALITY CONVERSION HELPER
-- =====================================================

local function GetNumericQuality(qualityString)
    if not qualityString then return 0 end
    
    if qualityString == "Trash" then return 0
    elseif qualityString == "Normal" then return 1
    elseif qualityString == "Magic" then return 2
    elseif qualityString == "Arcane" then return 3
    elseif qualityString == "Artifact" then return 4
    elseif qualityString == "Legendary" then return 5
    else return 0
    end
end

-- =====================================================
-- EQUIPMENT ANALYSIS CATEGORIES
-- =====================================================

local EQUIPMENT_ANALYSIS = {
    -- Set Analysis
    ["Set Bonuses"] = {
        emoji = "🎯",
        description = "Set bonus analysis and optimization"
    },
    ["Set Synergy"] = {
        emoji = "⚡",
        description = "Set combination synergy analysis"
    },
    
    -- Quality Analysis
    ["Quality Upgrade"] = {
        emoji = "⬆️",
        description = "Equipment quality upgrade suggestions"
    },
    ["Enchantment Analysis"] = {
        emoji = "✨",
        description = "Enchantment optimization and suggestions"
    },
    
    -- Optimization
    ["Trait Optimization"] = {
        emoji = "🔧",
        description = "Trait optimization suggestions"
    },
    ["Level Requirements"] = {
        emoji = "📊",
        description = "Level and CP requirement analysis"
    },
    
    -- Specialized Analysis
    ["Crafted vs Dropped"] = {
        emoji = "⚒️",
        description = "Crafted vs dropped equipment analysis"
    },
    ["Value Analysis"] = {
        emoji = "💰",
        description = "Equipment value and investment analysis"
    }
}

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

local function AnalyzeSetBonuses(equipmentData)
    local analysis = {
        activeSets = {},
        setBonuses = {},
        missingPieces = {},
        recommendations = {}
    }
    
    -- Analyze active sets
    for _, set in ipairs(equipmentData.sets or {}) do
        if set.count >= 2 then
            table.insert(analysis.activeSets, {
                name = set.name,
                pieces = set.count,
                maxPieces = 5, -- Most sets have 5 pieces
                bonusLevel = math.min(set.count, 5),
                isComplete = set.count >= 5
            })
        end
    end
    
    -- Identify missing pieces for incomplete sets
    for _, set in ipairs(equipmentData.sets or {}) do
        if set.count < 5 and set.count >= 2 then
            table.insert(analysis.missingPieces, {
                setName = set.name,
                currentPieces = set.count,
                missingPieces = 5 - set.count,
                priority = set.count >= 3 and "High" or "Medium"
            })
        end
    end
    
    return analysis
end

local function AnalyzeQualityUpgrades(equipmentData)
    local analysis = {
        upgradeable = {},
        recommendations = {},
        totalValue = 0
    }
    
    for _, item in ipairs(equipmentData.items or {}) do
        if item.name and item.name ~= "-" then
            -- Convert quality string to numeric value
            local numericQuality = GetNumericQuality(item.quality)
            
            local upgradePotential = 0
            
            -- Calculate upgrade potential
            if numericQuality < 5 then -- Less than legendary
                upgradePotential = 5 - numericQuality
                table.insert(analysis.upgradeable, {
                    name = item.name,
                    currentQuality = numericQuality,
                    maxQuality = 5,
                    upgradePotential = upgradePotential,
                    slot = item.slotName,
                    value = item.value or 0
                })
            end
            
            analysis.totalValue = analysis.totalValue + (item.value or 0)
        end
    end
    
    -- Sort by upgrade potential
    table.sort(analysis.upgradeable, function(a, b)
        return a.upgradePotential > b.upgradePotential
    end)
    
    return analysis
end

local function AnalyzeEnchantments(equipmentData)
    local analysis = {
        enchantments = {},
        recommendations = {},
        totalCharges = 0,
        maxCharges = 0
    }
    
    for _, item in ipairs(equipmentData.items or {}) do
        -- Check if item has an enchantment (enchantment is truthy and not false, and has charge data)
        -- Items with enchantments should have either enchantment name or enchantCharge > 0
        local hasEnchantment = (item.enchantment and item.enchantment ~= false and item.enchantment ~= "") or 
                               (item.enchantCharge and (type(item.enchantCharge) == "number" and item.enchantCharge > 0) or 
                                (type(item.enchantCharge) == "string" and item.enchantCharge ~= ""))
        
        if item.name and item.name ~= "-" and hasEnchantment then
            -- Convert enchantCharge to number for calculations
            local numericCharge = 0
            if type(item.enchantCharge) == "number" then
                numericCharge = item.enchantCharge
            elseif type(item.enchantCharge) == "string" then
                -- Extract number from string like "Adds 802 Maximum Mag..."
                local number = string.match(item.enchantCharge, "(%d+)")
                if number then
                    numericCharge = tonumber(number) or 0
                end
            end
            
            -- Get enchantment name - try multiple sources
            -- Strip ESO color codes from enchantment names
            local StripColorCodes = CM.utils and CM.utils.StripColorCodes
            local stripColors = StripColorCodes or function(text) return text end
            
            local enchantName = "Unknown Enchantment"
            if type(item.enchantment) == "string" and item.enchantment ~= "" then
                enchantName = stripColors(item.enchantment)
            elseif item.enchantCharge and type(item.enchantCharge) == "string" and item.enchantCharge ~= "" then
                -- Try to extract enchantment name from charge string if available
                -- Format might be like "Adds 802 Maximum Magicka" - use the description as name
                enchantName = stripColors(item.enchantCharge)
            end
            
            local enchantData = {
                name = enchantName,
                item = item.name,
                slot = item.slotName,
                currentCharge = numericCharge,
                maxCharge = item.enchantMaxCharge or 0,
                chargePercent = (item.enchantMaxCharge or 0) > 0 and 
                    math.floor((numericCharge / (item.enchantMaxCharge or 1)) * 100) or 0
            }
            
            table.insert(analysis.enchantments, enchantData)
            analysis.totalCharges = analysis.totalCharges + numericCharge
            analysis.maxCharges = analysis.maxCharges + (item.enchantMaxCharge or 0)
        end
    end
    
    -- Identify low charge enchantments
    -- Only recommend recharge if charge is actually low (not unknown/100%)
    for _, enchant in ipairs(analysis.enchantments) do
        -- Only recommend if we have valid charge data and it's actually low
        -- chargePercent of 0 might mean unknown (maxCharge = 0) or depleted (charge = 0, maxCharge > 0)
        if enchant.maxCharge > 0 and enchant.chargePercent < 50 then
            table.insert(analysis.recommendations, {
                type = "Recharge",
                item = enchant.item,
                enchantment = enchant.name,
                currentPercent = enchant.chargePercent,
                priority = enchant.chargePercent < 25 and "High" or "Medium"
            })
        end
    end
    
    return analysis
end

local function AnalyzeTraits(equipmentData)
    local analysis = {
        traits = {},
        recommendations = {},
        traitCounts = {}
    }
    
    for _, item in ipairs(equipmentData.items or {}) do
        if item.name and item.name ~= "-" and item.trait then
            local traitName = item.trait
            analysis.traitCounts[traitName] = (analysis.traitCounts[traitName] or 0) + 1
            
            table.insert(analysis.traits, {
                name = traitName,
                item = item.name,
                slot = item.slotName,
                quality = GetNumericQuality(item.quality)
            })
        end
    end
    
    -- Identify trait optimization opportunities
    for traitName, count in pairs(analysis.traitCounts) do
        if count > 1 then
            table.insert(analysis.recommendations, {
                type = "Trait Diversity",
                trait = traitName,
                count = count,
                priority = count > 2 and "High" or "Medium"
            })
        end
    end
    
    return analysis
end

local function AnalyzeLevelRequirements(equipmentData)
    local analysis = {
        requirements = {},
        recommendations = {},
        maxLevel = 0,
        maxCP = 0
    }
    
    for _, item in ipairs(equipmentData.items or {}) do
        if item.name and item.name ~= "-" then
            local level = item.requiredLevel or 0
            local cp = item.requiredCP or 0
            
            analysis.maxLevel = math.max(analysis.maxLevel, level)
            analysis.maxCP = math.max(analysis.maxCP, cp)
            
            if level > 0 or cp > 0 then
                table.insert(analysis.requirements, {
                    name = item.name,
                    slot = item.slotName,
                    level = level,
                    cp = cp,
                    quality = GetNumericQuality(item.quality)
                })
            end
        end
    end
    
    return analysis
end

local function AnalyzeCraftedVsDropped(equipmentData)
    local analysis = {
        crafted = 0,
        dropped = 0,
        total = 0,
        craftedItems = {},
        droppedItems = {}
    }
    
    for _, item in ipairs(equipmentData.items or {}) do
        if item.name and item.name ~= "-" then
            analysis.total = analysis.total + 1
            
            if item.isCrafted then
                analysis.crafted = analysis.crafted + 1
                table.insert(analysis.craftedItems, {
                    name = item.name,
                    slot = item.slotName,
                    quality = GetNumericQuality(item.quality)
                })
            else
                analysis.dropped = analysis.dropped + 1
                table.insert(analysis.droppedItems, {
                    name = item.name,
                    slot = item.slotName,
                    quality = GetNumericQuality(item.quality)
                })
            end
        end
    end
    
    return analysis
end

-- =====================================================
-- MAIN EQUIPMENT ENHANCEMENT COLLECTOR
-- =====================================================

local function CollectEquipmentEnhancementData()
    local data = {
        summary = {
            totalItems = 0,
            totalValue = 0,
            averageQuality = 0,
            setCount = 0,
            upgradeableItems = 0
        },
        analysis = {
            setBonuses = {},
            qualityUpgrades = {},
            enchantments = {},
            traits = {},
            levelRequirements = {},
            craftedVsDropped = {}
        },
        recommendations = {},
        optimization = {}
    }
    
    -- Get base equipment data
    local equipmentData = CM.collectors.CollectEquipmentData()
    if not equipmentData then
        return data
    end
    
    -- Calculate summary statistics
    local totalQuality = 0
    local qualityCount = 0
    
    for _, item in ipairs(equipmentData.items or {}) do
        if item.name and item.name ~= "-" then
            data.summary.totalItems = data.summary.totalItems + 1
            data.summary.totalValue = data.summary.totalValue + (item.value or 0)
            
            -- Get numeric quality value from the original quality constant
            -- item.quality is a string, we need to convert it back to numeric
            local numericQuality = GetNumericQuality(item.quality)
            if numericQuality > 0 then
                totalQuality = totalQuality + numericQuality
                qualityCount = qualityCount + 1
            end
        end
    end
    
    data.summary.averageQuality = qualityCount > 0 and math.floor(totalQuality / qualityCount) or 0
    data.summary.setCount = #(equipmentData.sets or {})
    
    -- Perform detailed analysis
    data.analysis.setBonuses = AnalyzeSetBonuses(equipmentData)
    data.analysis.qualityUpgrades = AnalyzeQualityUpgrades(equipmentData)
    data.analysis.enchantments = AnalyzeEnchantments(equipmentData)
    data.analysis.traits = AnalyzeTraits(equipmentData)
    data.analysis.levelRequirements = AnalyzeLevelRequirements(equipmentData)
    data.analysis.craftedVsDropped = AnalyzeCraftedVsDropped(equipmentData)
    
    -- Calculate upgradeable items
    data.summary.upgradeableItems = #data.analysis.qualityUpgrades.upgradeable
    
    -- Generate recommendations
    local recommendations = {}
    
    -- Set bonus recommendations
    for _, missing in ipairs(data.analysis.setBonuses.missingPieces) do
        table.insert(recommendations, {
            type = "Set Completion",
            priority = missing.priority,
            description = "Complete " .. missing.setName .. " set (" .. missing.missingPieces .. " pieces missing)",
            category = "Set Bonuses"
        })
    end
    
    -- Quality upgrade recommendations
    for _, upgrade in ipairs(data.analysis.qualityUpgrades.upgradeable) do
        if upgrade.upgradePotential >= 2 then
            table.insert(recommendations, {
                type = "Quality Upgrade",
                priority = "High",
                description = "Upgrade " .. upgrade.name .. " from quality " .. upgrade.currentQuality .. " to legendary",
                category = "Quality Upgrade"
            })
        end
    end
    
    -- Enchantment recommendations
    for _, rec in ipairs(data.analysis.enchantments.recommendations) do
        local enchantmentName = (type(rec.enchantment) == "string" and rec.enchantment) or "Unknown Enchantment"
        table.insert(recommendations, {
            type = "Enchantment Recharge",
            priority = rec.priority,
            description = "Recharge " .. enchantmentName .. " on " .. rec.item .. " (" .. rec.currentPercent .. "% charge)",
            category = "Enchantment Analysis"
        })
    end
    
    -- Trait recommendations
    for _, rec in ipairs(data.analysis.traits.recommendations) do
        table.insert(recommendations, {
            type = "Trait Diversity",
            priority = rec.priority,
            description = "Diversify traits - " .. rec.trait .. " appears " .. rec.count .. " times",
            category = "Trait Optimization"
        })
    end
    
    data.recommendations = recommendations
    
    return data
end

-- =====================================================
-- SPECIALIZED COLLECTORS
-- =====================================================

local function CollectSetSynergyAnalysis()
    local synergy = {
        combinations = {},
        recommendations = {},
        metaSets = {}
    }
    
    -- This would require a database of known set combinations
    -- For now, we'll provide a basic framework
    
    return synergy
end

local function CollectOptimizationSuggestions()
    local optimization = {
        immediate = {},
        shortTerm = {},
        longTerm = {},
        priority = {}
    }
    
    -- This would analyze the current build and suggest optimizations
    -- For now, we'll provide a basic framework
    
    return optimization
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.collectors.CollectEquipmentEnhancementData = CollectEquipmentEnhancementData
CM.collectors.CollectSetSynergyAnalysis = CollectSetSynergyAnalysis
CM.collectors.CollectOptimizationSuggestions = CollectOptimizationSuggestions

return {
    CollectEquipmentEnhancementData = CollectEquipmentEnhancementData,
    CollectSetSynergyAnalysis = CollectSetSynergyAnalysis,
    CollectOptimizationSuggestions = CollectOptimizationSuggestions
}
