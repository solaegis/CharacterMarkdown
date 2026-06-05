# CharacterMarkdown — Settings & Presets Matrix

Settings panel labels from **LibAddonMenu** (`/markdown settings`), with **Reset to Defaults** (factory values from `src/settings/Defaults.lua`) and each **Actions → Preset** button in `src/settings/Panel.lua`.

**Maintainer rule:** Update this file whenever you change settings defaults, panel options, or presets in `src/settings/Defaults.lua` or `src/settings/Panel.lua` (see `AGENTS.md`).

**Not included:** action buttons (**Generate Profile Now**, **Reload UI**, **Enable All Sections**, **Reset to Defaults**), **Custom Title**, **Play Style**, and **Build Notes** body text. Presets do not change per-character text fields.

**Legend:** On / Off

**How presets work:** Every preset calls `ToggleAllSections(false)` first, then turns selected flags back **On**. Anything not listed in that preset’s additions stays **Off** (even if factory default is On).

---

## Preset summaries

| Preset | Summary |
|--------|---------|
| **Reset to Defaults** | Factory `Defaults.lua`; preserves build notes, custom title, play style text |
| **Enable All Sections** | Every toggle **On** (not the same as factory defaults) |
| **Minimal** | Lean build share: header, combat, gear, skills, CP, currency, overview helpers — **no UESP links** |
| **Solo PvE** | Minimal + UESP links + quests [BETA] + armory [BETA] + social + progression + riding + companion + morphs + CP diagram + titles + full collectibles + full PvP |
| **PvP Build** | Minimal + UESP links + core PvP + Alliance War skills + skill morphs + CP diagram + titles + armory [BETA] + social |
| **Achievement Hunter** | Minimal + UESP links + full achievements + antiquities + collectibles (counts) + full crafting + crafting UESP links |
| **Crafter** | Minimal + UESP links + full crafting + crafting UESP links + inventory + bag/bank/crafting bag lists + full collectibles |

---

## Layout

| Setting | Saved variable | Default | Minimal | Solo PvE | PvP Build | Ach. Hunter | Crafter |
|---------|----------------|---------|---------|----------|-----------|-------------|---------|
| Include Header | `includeHeader` | On | On | On | On | On | On |
| Include Footer | `includeFooter` | On | On | On | On | On | On |

---

## Character Profile

| Setting | Saved variable | Default | Minimal | Solo PvE | PvP Build | Ach. Hunter | Crafter |
|---------|----------------|---------|---------|----------|-----------|-------------|---------|
| Include Build Notes | `includeBuildNotes` | On | On | On | On | On | On |

---

## Combat

| Setting | Saved variable | Default | Minimal | Solo PvE | PvP Build | Ach. Hunter | Crafter |
|---------|----------------|---------|---------|----------|-----------|-------------|---------|
| Include Basic Combat Stats | `includeBasicCombatStats` | On | On | On | On | On | On |
| Include Advanced Stats | `includeAdvancedStats` | On | On | On | On | On | On |
| Include Role | `includeRole` | On | On | On | On | On | On |
| Include Active Buffs | `includeBuffs` | On | On | On | On | On | On |
| Include Attribute Distribution | `includeAttributes` | On | On | On | On | On | On |

---

## Equipment

| Setting | Saved variable | Default | Minimal | Solo PvE | PvP Build | Ach. Hunter | Crafter |
|---------|----------------|---------|---------|----------|-----------|-------------|---------|
| Include Equipment | `includeEquipment` | On | On | On | On | On | On |

---

## Skills

| Setting | Saved variable | Default | Minimal | Solo PvE | PvP Build | Ach. Hunter | Crafter |
|---------|----------------|---------|---------|----------|-----------|-------------|---------|
| Include Skill Bars | `includeSkillBars` | On | On | On | On | On | On |
| Include Character Progress | `includeSkills` | On | On | On | On | On | On |
| Show All Available Morphs | `includeSkillMorphs` | Off | Off | On | On | Off | Off |

---

## Champion Points

| Setting | Saved variable | Default | Minimal | Solo PvE | PvP Build | Ach. Hunter | Crafter |
|---------|----------------|---------|---------|----------|-----------|-------------|---------|
| Include Champion Points | `includeChampionPoints` | On | On | On | On | On | On |
| Include CP Visual Diagram | `includeChampionDiagram` | Off | Off | On | On | Off | Off |

---

## Character

| Setting | Saved variable | Default | Minimal | Solo PvE | PvP Build | Ach. Hunter | Crafter |
|---------|----------------|---------|---------|----------|-----------|-------------|---------|
| Include Current Location | `includeLocation` | On | On | On | On | On | On |
| Include Titles | `includeTitlesHousing` | Off | Off | On | On | Off | Off |
| Include Attributes | `includeCharacterAttributes` | On | On | On | On | On | On |

When **Include Collectibles** is on, titles appear inside the Collectibles section instead of the standalone Titles block (if `includeTitlesHousing` is also on).

---

## Inventory

| Setting | Saved variable | Default | Minimal | Solo PvE | PvP Build | Ach. Hunter | Crafter |
|---------|----------------|---------|---------|----------|-----------|-------------|---------|
| Include Inventory Space | `includeInventory` | On | Off | Off | Off | Off | On |
| Show Bag Item List | `showBagContents` | Off | Off | Off | Off | Off | On |
| Show Bank Item List | `showBankContents` | Off | Off | Off | Off | Off | On |
| Show Crafting Bag Item List | `showCraftingBagContents` | Off | Off | Off | Off | Off | On |
| Include Currency & Resources | `includeCurrency` | On | On | On | On | On | On |

---

## Companion

| Setting | Saved variable | Default | Minimal | Solo PvE | PvP Build | Ach. Hunter | Crafter |
|---------|----------------|---------|---------|----------|-----------|-------------|---------|
| Include Companion Info | `includeCompanion` | On | Off | On | Off | Off | Off |

---

## Collectibles

| Setting | Saved variable | Default | Minimal | Solo PvE | PvP Build | Ach. Hunter | Crafter |
|---------|----------------|---------|---------|----------|-----------|-------------|---------|
| Include Collectibles | `includeCollectibles` | On | Off | On | Off | On | On |
| Detailed Collectibles Lists | `showCollectiblesDetailed` | Off | Off | On | Off | Off | On |
| Include DLC/Chapter Access | `includeDLCAccess` | Off | Off | On | Off | Off | On |
| Include Housing | `includeHousing` | Off | Off | On | Off | Off | On |

**Achievement Hunter** enables collectibles counts only (not detailed lists, DLC, or housing).

---

## Progression

| Setting | Saved variable | Default | Minimal | Solo PvE | PvP Build | Ach. Hunter | Crafter |
|---------|----------------|---------|---------|----------|-----------|-------------|---------|
| Include Progression Data | `includeProgression` | Off | Off | On | Off | Off | Off |
| Include Riding Skills | `includeRidingSkills` | Off | Off | On | Off | Off | Off |

---

## PvP

| Setting | Saved variable | Default | Minimal | Solo PvE | PvP Build | Ach. Hunter | Crafter |
|---------|----------------|---------|---------|----------|-----------|-------------|---------|
| Include PvP Information | `includePvP` | Off | Off | On | On | Off | Off |
| Include PvP Statistics | `includePvPStats` | Off | Off | On | On | Off | Off |
| Show PvP Progression | `showPvPProgression` | Off | Off | On | Off | Off | Off |
| Show Campaign Rewards | `showCampaignRewards` | Off | Off | On | Off | Off | Off |
| Show Leaderboards | `showLeaderboards` | Off | Off | On | Off | Off | Off |
| Show Battlegrounds | `showBattlegrounds` | Off | Off | On | Off | Off | Off |
| Detailed PvP Mode | `showDetailedPvP` | Off | Off | On | Off | Off | Off |
| Show Alliance War Skills | `showAllianceWarSkills` | Off | Off | On | On | Off | Off |

**PvP Build** enables core PvP + Alliance War skills only (not progression, campaigns, leaderboards, BG, or detailed mode).

---

## Achievements

| Setting | Saved variable | Default | Minimal | Solo PvE | PvP Build | Ach. Hunter | Crafter |
|---------|----------------|---------|---------|----------|-----------|-------------|---------|
| Include Achievement Tracking | `includeAchievements` | Off | Off | Off | Off | On | Off |
| Show All Achievements | `showAllAchievements` | On | Off | Off | Off | On | Off |

---

## Antiquities

| Setting | Saved variable | Default | Minimal | Solo PvE | PvP Build | Ach. Hunter | Crafter |
|---------|----------------|---------|---------|----------|-----------|-------------|---------|
| Include Antiquities | `includeAntiquities` | Off | Off | Off | Off | On | Off |
| Detailed Antiquity Sets | `showAntiquitiesDetailed` | Off | Off | Off | Off | On | Off |

---

## Quests [BETA]

| Setting | Saved variable | Default | Minimal | Solo PvE | PvP Build | Ach. Hunter | Crafter |
|---------|----------------|---------|---------|----------|-----------|-------------|---------|
| [BETA] Include Quest Tracking | `includeQuests` | Off | Off | On | Off | Off | Off |
| Detailed Quest Categories | `showQuestsDetailed` | Off | Off | On | Off | Off | Off |
| Show All Quests | `showAllQuests` | Off | Off | On | Off | Off | Off |
| [BETA] Include Undaunted Pledges | `includeUndauntedPledges` | Off | Off | On | Off | Off | Off |

Quest tracking checkboxes are **commented out** in the settings UI; flags are still set by **Solo PvE** for when export is re-enabled. The standalone Quests generator is currently disabled in `src/generators/Markdown.lua`.

---

## Armory Builds [BETA]

| Setting | Saved variable | Default | Minimal | Solo PvE | PvP Build | Ach. Hunter | Crafter |
|---------|----------------|---------|---------|----------|-----------|-------------|---------|
| [BETA] Include Armory Builds | `includeArmoryBuilds` | Off | Off | On | On | Off | Off |

---

## Crafting

| Setting | Saved variable | Default | Minimal | Solo PvE | PvP Build | Ach. Hunter | Crafter |
|---------|----------------|---------|---------|----------|-----------|-------------|---------|
| Include Crafting Knowledge | `includeCrafting` | On | Off | Off | Off | On | On |
| Include Motifs | `includeMotifs` | On | Off | Off | Off | On | On |
| Show Motifs Detailed | `showMotifsDetailed` | Off | Off | Off | Off | On | On |
| Include Outfit Styles | `includeStyles` | On | Off | Off | Off | On | On |
| Show Styles Detailed | `showStylesDetailed` | Off | Off | Off | Off | On | On |
| Include Recipes | `includeRecipes` | On | Off | Off | Off | On | On |
| Show Recipes Detailed *(no menu checkbox)* | `showRecipesDetailed` | Off | Off | Off | Off | On | On |

---

## Social

| Setting | Saved variable | Default | Minimal | Solo PvE | PvP Build | Ach. Hunter | Crafter |
|---------|----------------|---------|---------|----------|-----------|-------------|---------|
| Include Guild Membership | `includeGuilds` | On | Off | On | On | Off | Off |
| Include Mail | `includeMail` | Off | Off | On | On | Off | Off |

---

## External Links

| Setting | Saved variable | Default | Minimal | Solo PvE | PvP Build | Ach. Hunter | Crafter |
|---------|----------------|---------|---------|----------|-----------|-------------|---------|
| Enable UESP Links *(abilities + sets)* | `enableAbilityLinks`, `enableSetLinks` | On | Off | On | On | On | On |
| Motif UESP Links | `enableMotifLinks` | On | Off | Off | Off | On | On |
| Style UESP Links | `enableStyleLinks` | On | Off | Off | Off | On | On |
| Recipe UESP Links | `enableRecipeLinks` | On | Off | Off | Off | On | On |

The **Enable UESP Links** checkbox sets ability and set links together. Motif, style, and recipe links are separate checkboxes in the same section.

---

## Hidden toggles (no menu checkbox)

These are changed by **Enable All Sections**, **Reset to Defaults**, and presets, but do not appear as separate LAM controls.

| Internal setting | Default | Minimal | Solo PvE | PvP Build | Ach. Hunter | Crafter |
|------------------|---------|---------|----------|-----------|-------------|---------|
| `includeTableOfContents` | On | On | On | On | On | On |
| `includeQuickStats` | On | On | On | On | On | On |
| `includeGeneral` | On | On | On | On | On | On |
| `includeAttentionNeeded` | On | Off | Off | Off | Off | Off |

---

## Play Style (dropdown, per character)

Default: *(empty)*. Presets do not change this.

Crafter, Healer, Hybrid Build, Magicka DPS, Mule, Off-Tank, Parse DPS, PvP Bomblade, PvP Brawler, PvP Ganker, PvP Support, Resource Farmer, Solo Self-Sufficient, Stamina DPS, Support DPS, Tank.

---

## Source

- Defaults: `src/settings/Defaults.lua` — `CM.Settings.Defaults:GetAll()`
- Panel labels & presets: `src/settings/Panel.lua` — `ToggleAllSections`, `ApplyMinimalPreset`, `ApplySoloPvEPreset`, `ApplyPvPBuildPreset`, `ApplyAchievementHunterPreset`, `ApplyCrafterPreset`
- Keep this matrix aligned with `Defaults.lua` and `Panel.lua` on every settings-related PR or commit
