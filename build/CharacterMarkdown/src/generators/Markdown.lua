-- CharacterMarkdown - Markdown Generation Engine
-- Generates markdown in multiple formats (GitHub, VSCode, Discord, Quick)

local CM = CharacterMarkdown

-- Import section generators (these modules register themselves to CM.generators.sections)
-- Note: The modules are loaded via CharacterMarkdown.xml

-- Get references to imported section generators for convenience
local function GetGenerators()
    return {
        -- Character sections
        GenerateQuickSummary = CM.generators.sections.GenerateQuickSummary,
        GenerateHeader = CM.generators.sections.GenerateHeader,
        GenerateQuickStats = CM.generators.sections.GenerateQuickStats,
        GenerateAttentionNeeded = CM.generators.sections.GenerateAttentionNeeded,
        GenerateOverview = CM.generators.sections.GenerateOverview,
        GenerateProgression = CM.generators.sections.GenerateProgression,
        GenerateCustomNotes = CM.generators.sections.GenerateCustomNotes,
        
        -- Economy sections
        GenerateCurrency = CM.generators.sections.GenerateCurrency,
        GenerateRidingSkills = CM.generators.sections.GenerateRidingSkills,
        GenerateInventory = CM.generators.sections.GenerateInventory,
        GeneratePvP = CM.generators.sections.GeneratePvP,
        
        -- Equipment sections
        GenerateSkillBars = CM.generators.sections.GenerateSkillBars,
        GenerateEquipment = CM.generators.sections.GenerateEquipment,
        GenerateSkills = CM.generators.sections.GenerateSkills,
        
        -- Combat sections
        GenerateCombatStats = CM.generators.sections.GenerateCombatStats,
        GenerateAttributes = CM.generators.sections.GenerateAttributes,
        GenerateBuffs = CM.generators.sections.GenerateBuffs,
        
        -- Content sections
        GenerateDLCAccess = CM.generators.sections.GenerateDLCAccess,
        GenerateMundus = CM.generators.sections.GenerateMundus,
        GenerateChampionPoints = CM.generators.sections.GenerateChampionPoints,
        -- DISABLED: Champion Diagram (experimental)
        -- GenerateChampionDiagram = CM.generators.GenerateChampionDiagram,
        GenerateCollectibles = CM.generators.sections.GenerateCollectibles,
        GenerateCrafting = CM.generators.sections.GenerateCrafting,
        
        -- Companion sections
        GenerateCompanion = CM.generators.sections.GenerateCompanion,
        
        -- Footer
        GenerateFooter = CM.generators.sections.GenerateFooter,
    }
end

-- =====================================================
-- MAIN GENERATION FUNCTION
-- =====================================================

local function GenerateMarkdown(format)
    format = format or "github"
    
    -- Verify collectors are loaded
    if not CM.collectors then
        d("[CharacterMarkdown] ❌ FATAL: CM.collectors namespace doesn't exist!")
        d("[CharacterMarkdown] The addon did not load correctly. Try /reloadui")
        return "ERROR: Addon not loaded. Type /reloadui and try again."
    end
    
    -- Check if a critical collector exists (test case)
    if not CM.collectors.CollectCharacterData then
        d("[CharacterMarkdown] ❌ FATAL: Collectors not loaded!")
        d("[CharacterMarkdown] Available in CM.collectors:")
        for k, v in pairs(CM.collectors) do
            d("[CharacterMarkdown]   - " .. k)
        end
        return "ERROR: Collectors not loaded. Type /reloadui and try again."
    end
    
    -- Collect all data with error handling
    local characterData = CM.collectors.CollectCharacterData()
    local dlcData = CM.collectors.CollectDLCAccess()
    local mundusData = CM.collectors.CollectMundusData()
    local buffsData = CM.collectors.CollectActiveBuffs()
    local cpData = CM.collectors.CollectChampionPointData()
    local skillBarData = CM.collectors.CollectSkillBarData()
    local statsData = CM.collectors.CollectCombatStatsData()
    local equipmentData = CM.collectors.CollectEquipmentData()
    local skillData = CM.collectors.CollectSkillProgressionData()
    local companionData = CM.collectors.CollectCompanionData()
    local currencyData = CM.collectors.CollectCurrencyData()
    local progressionData = CM.collectors.CollectProgressionData()
    local ridingData = CM.collectors.CollectRidingSkillsData()
    local inventoryData = CM.collectors.CollectInventoryData()
    local pvpData = CM.collectors.CollectPvPData()
    local roleData = CM.collectors.CollectRoleData()
    local locationData = CM.collectors.CollectLocationData()
    local collectiblesData = CM.collectors.CollectCollectiblesData()
    local craftingData = CM.collectors.CollectCraftingKnowledgeData()
    
    local settings = CharacterMarkdownSettings or {}
    
    -- Get section generators
    local gen = GetGenerators()
    
    -- QUICK FORMAT - one-line summary
    if format == "quick" then
        return gen.GenerateQuickSummary(characterData, equipmentData)
    end
    
    -- FULL FORMATS (GitHub, VSCode, Discord)
    local markdown = ""
    
    -- Header
    markdown = markdown .. gen.GenerateHeader(characterData, cpData, format)
    
    -- Quick Stats Summary (non-Discord only)
    if format ~= "discord" and settings.includeQuickStats ~= false then
        markdown = markdown .. gen.GenerateQuickStats(characterData, progressionData, currencyData, equipmentData, cpData, inventoryData, format)
    end
    
    -- Attention Needed (non-Discord only)
    if format ~= "discord" and settings.includeAttentionNeeded ~= false then
        markdown = markdown .. gen.GenerateAttentionNeeded(progressionData, inventoryData, ridingData, format)
    end
    
    -- Overview (skip for Discord) - now includes vampire/werewolf/enlightenment
    if format ~= "discord" then
        markdown = markdown .. gen.GenerateOverview(characterData, roleData, locationData, buffsData, mundusData, ridingData, pvpData, progressionData, settings, format)
    end
    
    -- Currency
    if settings.includeCurrency ~= false then
        markdown = markdown .. gen.GenerateCurrency(currencyData, format)
    end
    
    -- Riding Skills (Discord only - for other formats it's in Overview table)
    if format == "discord" and settings.includeRidingSkills ~= false then
        markdown = markdown .. gen.GenerateRidingSkills(ridingData, format)
    end
    
    -- Inventory
    if settings.includeInventory ~= false then
        markdown = markdown .. gen.GenerateInventory(inventoryData, format)
    end
    
    -- PvP (Discord only - for other formats it's in Overview table)
    if format == "discord" and settings.includePvP ~= false then
        markdown = markdown .. gen.GeneratePvP(pvpData, format)
    end
    
    -- Collectibles
    if settings.includeCollectibles ~= false then
        markdown = markdown .. gen.GenerateCollectibles(collectiblesData, format)
    end
    
    -- Crafting
    if settings.includeCrafting ~= false then
        markdown = markdown .. gen.GenerateCrafting(craftingData, format)
    end
    
    -- Attributes and Buffs are now in Overview table for non-Discord formats
    -- For Discord format, still generate them as separate sections
    if format == "discord" then
        if settings.includeAttributes ~= false then
            markdown = markdown .. gen.GenerateAttributes(characterData, format)
        end
        if settings.includeBuffs ~= false then
            markdown = markdown .. gen.GenerateBuffs(buffsData, format)
        end
    end
    
    -- Custom Notes
    local customNotes = CharacterMarkdownData and CharacterMarkdownData.customNotes or ""
    if customNotes and customNotes ~= "" then
        markdown = markdown .. gen.GenerateCustomNotes(customNotes, format)
    end
    
    if format ~= "discord" then
        markdown = markdown .. "---\n\n"
    end
    
    -- DLC Access
    if settings.includeDLCAccess ~= false then
        markdown = markdown .. gen.GenerateDLCAccess(dlcData, format)
    end
    
    -- Mundus (Discord only - for other formats it's in Overview table)
    if format == "discord" then
        markdown = markdown .. gen.GenerateMundus(mundusData, format)
    end
    
    -- Champion Points
    if settings.includeChampionPoints ~= false then
        markdown = markdown .. gen.GenerateChampionPoints(cpData, format)
    end
    
    -- Champion Points Visual Diagram (DISABLED - experimental feature)
    -- Uncomment the following lines to enable:
    -- if settings.includeChampionDiagram == true and format ~= "discord" and gen.GenerateChampionDiagram then
    --     markdown = markdown .. gen.GenerateChampionDiagram(cpData)
    -- end
    
    -- Skill Bars
    if settings.includeSkillBars ~= false then
        markdown = markdown .. gen.GenerateSkillBars(skillBarData, format)
    end
    
    -- Combat Stats
    if settings.includeCombatStats ~= false then
        markdown = markdown .. gen.GenerateCombatStats(statsData, format)
    end
    
    -- Equipment
    if settings.includeEquipment ~= false then
        markdown = markdown .. gen.GenerateEquipment(equipmentData, format)
    end
    
    -- Skills
    if settings.includeSkills ~= false then
        markdown = markdown .. gen.GenerateSkills(skillData, format)
    end
    
    -- Companion
    if settings.includeCompanion ~= false and companionData.active then
        markdown = markdown .. gen.GenerateCompanion(companionData, format)
    end
    
    -- Footer
    markdown = markdown .. gen.GenerateFooter(format, string.len(markdown))
    
    return markdown
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.generators.GenerateMarkdown = GenerateMarkdown
