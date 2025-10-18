# Collectibles Feature Update

## Changes Required

### 1. Generator Function Replacement

Replace the existing `GenerateCollectibles` function in `/src/generators/Markdown.lua` (currently at line ~850) with the new implementation below.

### 2. New GenerateCollectibles Function

```lua
GenerateCollectibles = function(collectiblesData, format)
    local markdown = ""
    
    -- Check if we have detailed data enabled
    local hasDetailedData = collectiblesData.hasDetailedData
    local settings = CharacterMarkdownSettings or {}
    local includeDetailed = settings.includeCollectiblesDetailed or false
    
    if format == "discord" then
        -- Discord: Always show summary counts only (no detailed lists)
        markdown = markdown .. "**Collectibles:**\n"
        
        if collectiblesData.categories then
            for _, key in ipairs({"mounts", "pets", "costumes", "houses", "emotes", "mementos", "skins", "polymorphs", "personalities"}) do
                local category = collectiblesData.categories[key]
                if category and category.total > 0 then
                    local owned = #category.owned
                    markdown = markdown .. category.emoji .. " " .. category.name .. ": (" .. owned .. " of " .. category.total .. ")\n"
                end
            end
        end
        markdown = markdown .. "\n"
    else
        -- GitHub/VSCode: Show collapsible detailed lists if enabled
        markdown = markdown .. "## 🎨 Collectibles\n\n"
        
        if not includeDetailed or not hasDetailedData then
            -- Fallback: Show simple count table if detailed not enabled
            markdown = markdown .. "| Type | Count |\n"
            markdown = markdown .. "|:-----|------:|\n"
            if collectiblesData.mounts > 0 then
                markdown = markdown .. "| **🐴 Mounts** | " .. collectiblesData.mounts .. " |\n"
            end
            if collectiblesData.pets > 0 then
                markdown = markdown .. "| **🐾 Pets** | " .. collectiblesData.pets .. " |\n"
            end
            if collectiblesData.costumes > 0 then
                markdown = markdown .. "| **👗 Costumes** | " .. collectiblesData.costumes .. " |\n"
            end
            if collectiblesData.houses > 0 then
                markdown = markdown .. "| **🏠 Houses** | " .. collectiblesData.houses .. " |\n"
            end
            markdown = markdown .. "\n"
        else
            -- Detailed mode: Show collapsible sections with (X of Y) format
            if collectiblesData.categories then
                for _, key in ipairs({"mounts", "pets", "costumes", "houses", "emotes", "mementos", "skins", "polymorphs", "personalities"}) do
                    local category = collectiblesData.categories[key]
                    if category and category.total > 0 then
                        local owned = #category.owned
                        
                        -- Collapsible section header
                        markdown = markdown .. "<details>\n"
                        markdown = markdown .. "<summary>" .. category.emoji .. " " .. category.name .. 
                                              " (" .. owned .. " of " .. category.total .. ")</summary>\n\n"
                        
                        -- List owned collectibles (alphabetically sorted)
                        if owned > 0 then
                            for _, collectible in ipairs(category.owned) do
                                markdown = markdown .. "- " .. collectible.name
                                -- Add rarity if available
                                if collectible.quality then
                                    markdown = markdown .. " [" .. collectible.quality .. "]"
                                end
                                markdown = markdown .. "\n"
                            end
                        else
                            markdown = markdown .. "*No " .. category.name:lower() .. " owned*\n"
                        end
                        
                        markdown = markdown .. "</details>\n\n"
                    end
                end
            end
        end
    end
    
    return markdown
end
```

## Implementation Steps

1. **Backup the current file:**
   ```bash
   cp src/generators/Markdown.lua src/generators/Markdown.lua.backup
   ```

2. **Locate the existing GenerateCollectibles function** (around line 850)

3. **Replace the function** with the new implementation above

4. **Test in-game:**
   - `/reloadui` to reload the addon
   - Toggle `includeCollectiblesDetailed` in settings
   - Generate markdown in different formats (GitHub, Discord, VSCode)

## What This Changes

### Before:
- Simple table showing counts only:
  ```markdown
  | Type | Count |
  |:-----|------:|
  | **🐴 Mounts** | 684 |
  | **🐾 Pets** | 664 |
  ```

### After (with includeCollectiblesDetailed = false):
- Same as before (backward compatible)

### After (with includeCollectiblesDetailed = true):
- GitHub/VSCode: Collapsible sections with full lists:
  ```markdown
  <details>
  <summary>🐴 Mounts (12 of 684)</summary>
  
  - Alabaster Charger [Legendary]
  - Alinor Royal Courser [Epic]
  ...
  </details>
  ```

- Discord: Summary counts only (no lists):
  ```markdown
  **Collectibles:**
  🐴 Mounts: (12 of 684)
  🐾 Pets: (45 of 664)
  ```

## Notes

- Rarity is shown only if the ESO API provides it (via `GetCollectibleQuality()`)
- The collector already handles this (in `World.lua`)
- Default setting is `false` to avoid very long outputs
- All collectible categories are supported (Mounts, Pets, Costumes, Houses, Emotes, Mementos, Skins, Polymorphs, Personalities)
