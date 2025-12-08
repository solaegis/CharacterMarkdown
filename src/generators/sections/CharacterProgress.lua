-- CharacterMarkdown - Character Progress Section Generator
-- Generates the Character Progress section with skill morphs, maxed skills, and progress bars

local CM = CharacterMarkdown
CM.generators = CM.generators or {}
CM.generators.sections = CM.generators.sections or {}

local string_format = string.format
local table_concat = table.concat
local table_insert = table.insert

local markdown = (CM.utils and CM.utils.markdown) or nil

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

local function GenerateProgressBar(percent)
    local totalBlocks = 10
    local filledBlocks = math.floor((percent / 100) * totalBlocks)
    local emptyBlocks = totalBlocks - filledBlocks
    
    local bar = ""
    for _ = 1, filledBlocks do
        bar = bar .. "█"
    end
    for _ = 1, emptyBlocks do
        bar = bar .. "░" -- Light shade block
    end
    
    -- Let's adjust for skills
    return string_format("%s %d%%", bar, percent)
end

local function GetSkillTypeEmoji(typeName)
    local emojis = CM.Constants.SKILL_TYPE_EMOJIS
    return emojis[typeName] or CM.Constants.DEFAULT_SKILL_EMOJI
end

-- =====================================================
-- GENERATOR
-- =====================================================

local function GenerateCharacterProgress(progressionData, morphsData)
    -- Defensive checks for data validity
    if not progressionData or type(progressionData) ~= "table" then 
        CM.Warn("GenerateCharacterProgress: Invalid progressionData (type: " .. type(progressionData) .. ")")
        return "" 
    end
    
    if not morphsData or type(morphsData) ~= "table" then
        morphsData = {} -- Provide empty table as fallback
    end
    
    local parts = {}
    table_insert(parts, "## 📜 Character Progress\n\n")
    
    -- 1. Progress Overview Table
    table_insert(parts, "### Progress Overview\n\n")
    
    local summary = progressionData.summary
    if summary then
        local headers = { "Maxed Skill Lines", "In Progress", "Early Progress", "Abilities with Morphs", "Overall Completion" }
        local row = {
            tostring(summary.maxedCount or 0),
            tostring(summary.inProgressCount or 0),
            tostring(summary.earlyProgressCount or 0),
            tostring(summary.totalMorphs or 0),
            string_format("%d%%", summary.completionPercent or 0)
        }
        
        if markdown and markdown.CreateStyledTable then
            local options = { alignment = { "right", "right", "right", "right", "right" } }
            table_insert(parts, markdown.CreateStyledTable(headers, { row }, options) .. "\n")
        else
            table_insert(parts, "| " .. table_concat(headers, " | ") .. " |\n")
            table_insert(parts, "| ---: | ---: | ---: | ---: | ---: |\n")
            table_insert(parts, "| " .. table_concat(row, " | ") .. " |\n\n")
        end
    end
    
    -- 2. Skill Morphs (Collapsible)
    if morphsData and morphsData.skillTypes then
        local totalMorphs = morphsData.summary and morphsData.summary.totalMorphs or 0
        table_insert(parts, string_format("<details>\n<summary>🌿 Skill Morphs (%d abilities with morph choices)</summary>\n\n", totalMorphs))
        
        for _, skillType in ipairs(morphsData.skillTypes) do
            if #skillType.skillLines > 0 then
                local emoji = skillType.emoji or GetSkillTypeEmoji(skillType.name)
                
                -- Count abilities in this type
                local typeAbilityCount = 0
                for _, line in ipairs(skillType.skillLines) do
                    typeAbilityCount = typeAbilityCount + #line.abilities
                end
                
                table_insert(parts, string_format("### %s %s (%d abilities with morph choices)\n\n", emoji, skillType.name, typeAbilityCount))
                
                for _, line in ipairs(skillType.skillLines) do
                    table_insert(parts, string_format("#### %s (Rank %d)\n\n", line.name, line.rank))
                    
                    for _, ability in ipairs(line.abilities) do
                        local icon = ability.ultimate and "⚠️" or (ability.purchased and "✅" or "🔒")
                        local morphName = ability.name
                        
                        -- Find current morph name
                        if ability.morphs then
                            for _, m in ipairs(ability.morphs) do
                                if m.selected then
                                    morphName = m.name
                                    break
                                end
                            end
                        end
                        
                        -- Create link if possible (using UESP link generator if available, otherwise just name)
                        local CreateSkillLink = CM.links and CM.links.CreateSkillLink
                        local link = (CreateSkillLink and CreateSkillLink(morphName)) or string_format("[%s](https://en.uesp.net/wiki/Online:%s)", morphName, morphName:gsub(" ", "_"))
                        
                        table_insert(parts, string_format("%s **%s** (Rank %d)\n\n", icon, link, ability.currentRank))
                        
                        -- Selected morph info (if any)
                        if ability.currentMorph > 0 then
                             -- Already shown in title? The example shows:
                             -- ✅ [Hurricane](...) (Rank 4)
                             --   ✅ Morph 1: [Hurricane](...)
                             --   <details> ... Other morph options ... </details>
                             
                             for _, m in ipairs(ability.morphs) do
                                if m.selected then
                                    local mLink = (CreateSkillLink and CreateSkillLink(m.name)) or string_format("[%s](https://en.uesp.net/wiki/Online:%s)", m.name, m.name:gsub(" ", "_"))
                                    table_insert(parts, string_format("  ✅ **Morph %d**: %s\n\n", m.morphSlot, mLink))
                                end
                             end
                        end
                        
                        -- Other morph options
                        if #ability.morphs > 0 then
                            table_insert(parts, "  <details>\n  <summary>Other morph options</summary>\n\n")
                            for _, m in ipairs(ability.morphs) do
                                if not m.selected then
                                    local mLink = (CreateSkillLink and CreateSkillLink(m.name)) or string_format("[%s](https://en.uesp.net/wiki/Online:%s)", m.name, m.name:gsub(" ", "_"))
                                    table_insert(parts, string_format("  ⚪ **Morph %d**: %s\n", m.morphSlot, mLink))
                                end
                            end
                            table_insert(parts, "\n  </details>\n\n")
                        end
                    end
                end
            end
        end
        
        table_insert(parts, "</details>\n\n")
    end
    
    -- 3. Maxed Skills (Collapsible)
    local maxedLines = progressionData.maxedLines
    if maxedLines and type(maxedLines) == "table" and #maxedLines > 0 then
        local maxedCount = progressionData.summary and progressionData.summary.maxedCount or #maxedLines
        table_insert(parts, string_format("### ✅ Maxed Skills (%d)\n\n", maxedCount))
        
        -- Group by type
        local linesByType = {}
        for _, line in ipairs(maxedLines) do
            if line and type(line) == "table" then
                local typeName = "Unknown"
                local types = CM.api.skills.GetSkillTypes()
                if types and type(types) == "table" then
                    for _, t in ipairs(types) do
                        if t and t.index == line.type then
                            typeName = t.name
                            break
                        end
                    end
                end
                
                linesByType[typeName] = linesByType[typeName] or {}
                table.insert(linesByType[typeName], line)
            end
        end
        
        local typeOrder = CM.Constants.SKILL_TYPE_ORDER
        
        for _, typeName in ipairs(typeOrder) do
            local lines = linesByType[typeName]
            if lines and #lines > 0 then
                local emoji = GetSkillTypeEmoji(typeName)
                table_insert(parts, string_format("<details>\n<summary>%s %s (%d skill lines maxed)</summary>\n\n", emoji, typeName, #lines))
                
                for _, line in ipairs(lines) do
                    local CreateSkillLineLink = CM.links and CM.links.CreateSkillLineLink
                    local link = (CreateSkillLineLink and CreateSkillLineLink(line.name)) or string_format("**[%s](https://en.uesp.net/wiki/Online:%s)**", line.name, line.name:gsub(" ", "_"))
                    
                    table_insert(parts, string_format("- %s\n", link))
                    
                    -- Passives for this line
                    if line.passives and #line.passives > 0 then
                        -- Check if any passives are purchased to decide if we show the details block
                        local hasPurchasedPassives = false
                        for _, p in ipairs(line.passives) do
                            if p.purchased then hasPurchasedPassives = true break end
                        end
                        
                        if hasPurchasedPassives then
                            table_insert(parts, "  <details>\n  <summary>✨ Passives</summary>\n\n")
                            for _, passive in ipairs(line.passives) do
                                if passive and type(passive) == "table" and passive.name then
                                    local status = passive.purchased and "✅" or "🔒"
                                    local CreateSkillLink = CM.links and CM.links.CreateSkillLink
                                    local passiveName = tostring(passive.name)
                                    local pLink = (CreateSkillLink and CreateSkillLink(passiveName)) or string_format("[%s](https://en.uesp.net/wiki/Online:%s)", passiveName, passiveName:gsub(" ", "_"))
                                    
                                    local rankStr = ""
                                    if passive.purchased and passive.rank and passive.rank > 0 then
                                        rankStr = string_format(" (Rank %d)", passive.rank)
                                    end
                                    
                                    table_insert(parts, string_format("  - %s %s%s\n", status, pLink, rankStr))
                                end
                            end
                            table_insert(parts, "\n  </details>\n")
                        end
                    end
                end
                table_insert(parts, "\n")
                table_insert(parts, "</details>\n\n")
            end
        end
    end
    
    -- 4. In-Progress Skills
    local inProgressLines = progressionData.inProgressLines
    if inProgressLines and type(inProgressLines) == "table" and #inProgressLines > 0 then
        table_insert(parts, "### 📈 In-Progress Skills\n\n")
        
        -- Group by type
        local linesByType = {}
        local types = CM.api.skills.GetSkillTypes()
        
        CM.Warn("GenerateCharacterProgress: Processing in-progress skills.")
        
        for _, line in ipairs(inProgressLines) do
            if line and type(line) == "table" then
                local typeName = "Unknown"
                if types and type(types) == "table" then
                    for _, t in ipairs(types) do
                        if t and t.index == line.type then
                            typeName = t.name
                            break
                        end
                    end
                end
                
                linesByType[typeName] = linesByType[typeName] or {}
                table.insert(linesByType[typeName], line)
            end
        end
        
        local typeOrder = CM.Constants.SKILL_TYPE_ORDER
        
        for _, typeName in ipairs(typeOrder) do
            local lines = linesByType[typeName]
            if lines and #lines > 0 then
                local emoji = GetSkillTypeEmoji(typeName)
                table_insert(parts, string_format("<details>\n<summary>%s %s (%d skill lines in progress)</summary>\n\n", emoji, typeName, #lines))
                
                for _, line in ipairs(lines) do
                    local CreateSkillLineLink = CM.links and CM.links.CreateSkillLineLink
                    local link = (CreateSkillLineLink and CreateSkillLineLink(line.name)) or string_format("**[%s](https://en.uesp.net/wiki/Online:%s)**", line.name, line.name:gsub(" ", "_"))
                    local bar = GenerateProgressBar(line.progress)
                    
                    table_insert(parts, string_format("- %s: Rank %d %s\n", link, line.rank, bar))
                    
                    -- Passives for this line
                    if line.passives and #line.passives > 0 then
                        -- Check if any passives are purchased
                        local hasPurchasedPassives = false
                        for _, p in ipairs(line.passives) do
                            if p.purchased then hasPurchasedPassives = true break end
                        end
                        
                        if hasPurchasedPassives then
                            table_insert(parts, "  <details>\n  <summary>✨ Passives</summary>\n\n")
                            for _, passive in ipairs(line.passives) do
                                if passive and type(passive) == "table" and passive.name then
                                    local status = passive.purchased and "✅" or "🔒"
                                    local CreateSkillLink = CM.links and CM.links.CreateSkillLink
                                    local passiveName = tostring(passive.name)
                                    local pLink = (CreateSkillLink and CreateSkillLink(passiveName)) or string_format("[%s](https://en.uesp.net/wiki/Online:%s)", passiveName, passiveName:gsub(" ", "_"))
                                    
                                    local rankStr = ""
                                    if passive.purchased and passive.rank and passive.rank > 0 then
                                        rankStr = string_format(" (Rank %d)", passive.rank)
                                    end
                                    
                                    table_insert(parts, string_format("  - %s %s%s\n", status, pLink, rankStr))
                                end
                            end
                            table_insert(parts, "\n  </details>\n")
                        end
                    end
                end
                
                table_insert(parts, "\n")
                table_insert(parts, "</details>\n\n")
            end
        end
    end
    
    return table_concat(parts)
end

CM.generators.sections.GenerateCharacterProgress = GenerateCharacterProgress
