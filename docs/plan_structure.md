# Build Plan (`*_plan.md`) Structure Reference

Canonical layout for Solaegis character build plans under `examples/{account}/{location}/{slug}_plan.md`. Use this document when **creating**, **auditing**, or **aligning** plan files.

**Working template:** [`examples/templates/template_plan.md`](../examples/templates/template_plan.md)  
**Exemplar (filled):** [`examples/solaegis/na/silent_snow_falls_plan.md`](../examples/solaegis/na/silent_snow_falls_plan.md)  
**Subclassing theory:** [`docs/subclassing.md`](subclassing.md)

---

## Inventory (current `*_plan.md` files)

| File | Title style | Layout tier | Notes |
| :--- | :--- | :--- | :--- |
| `silent_snow_falls_plan.md` | Build Plan | **Canonical** | Structure exemplar |
| `kellen_dysart_plan.md` | Build Plan | **Canonical** | Includes Custom Title + Build Notes |
| `stoirmgheal_plan.md` | Walkthrough | Legacy | Pillar/trinity split; visual identity before CP |
| `hya_cinthe_plan.md` | Walkthrough | Legacy | Same legacy pattern as Stoirmgheal |
| `karakedi_plan.md` | Walkthrough | Legacy | Gear before combat; subclass table inside rotation |
| `dolu_tenasi_plan.md` | Build Plan | Mixed | Has trinity H2 but old section order |
| `dextera_dei_plan.md` | Walkthrough | Legacy | Duplicate vampire H2; aesthetic outside Collectibles |
| `talon_valois_plan.md` | Walkthrough | Legacy | Incomplete CP; dye under gear |
| `karakum_plan.md` | Walkthrough | Legacy | Werewolf alt bar; no Collectibles H2 |
| `nekhtarhebi_plan.md` | Walkthrough | Legacy | Gear-first; no Collectibles H2 |
| `masisi_plan.md` | Walkthrough | **Crafter variant** | No combat trinity; resource/farming focus |

**Alignment goal:** New plans and heavy revisions use the **Canonical** layout. Legacy files are migrated opportunistically — do not bulk-reformat unless explicitly requested.

---

## Canonical H2 order (required)

Every combat-focused build plan should use **exactly this H2 sequence** (H3 children as shown):

```
H1  Build Plan - {CharacterName}: {Archetype Title} ({Build Tag})
    > Profile link blockquote
    Pitch paragraph(s)
    ---

H2  Build at a glance
    | Attribute | Recommendation | table (live vs target where applicable)
    Read-next anchor links
    ---

H2  Roleplay: {Identity Title}
    Identity prose
    > [!TIP] Suggested Custom Title (≤100 chars)
    > [!NOTE] Build Notes paste block (≤1,900 chars)
    > [!TIP] Flavor Pet (optional; detail in Collectibles)
    ---

H2  Trinity configuration
    Bahtra / Uber Tier intro + link to subclassing.md
    ```mermaid``` graph (three lines → archetype)
    | Pillar | Line | Origin | Slot action | Function | unified table ONLY
    ---

H2  Combat kit: {Cycle Name}
    H3  Skill bars
        H4  Front Bar ({Weapon}): "{Bar Name}" — slot table incl. ultimate
        H4  Back Bar ({Weapon}): "{Bar Name}" — slot table incl. ultimate
    H3  Rotation and combat tips
        ```mermaid``` flowchart (optional)
        Numbered solo/group tips
    H3  Passive skills
        H4  {Class} — {Line}
        H4  Weapon — {Line}
        H4  Guild / Race / etc.
    ---

H2  Gear and crafting: "{Gear Theme Name}"
    H3  Set rationale
        ```mermaid``` or prose; rejected-set callouts
    H3  Target loadout
        | Slot | Set | Weight | Trait | Enchantment | Quality |
        Front/back bar weapon notes
    H3  Crafting handoff (@masisi)
        Style, station, traits, interim bridge set, research gates
    ---

H2  Champion Point Mapping (CP {budget})
    H3  Warfare (Blue — {N} Points)
    H3  Fitness (Red — {N} Points)
    H3  Craft (Green — {N} Points)
    ---

H2  Companion Strategy: "{Companion Theme}"
    H3  {Companion Name}: {Subtitle}
        Role table + support skill bar
        Fallback companion (optional)
    ---

H2  Collectibles
    H3  Mount
        Primary + backups + avoid-thematically tables
    H3  Pet
    H3  Dye and style
    ---

H2  Next Steps & In-Game Action Checklist
    H3  Phase 0 — Today (functional build)
    H3  Phase 1 — Craft (interim)
    H3  Phase 2 — Craft (target)
    H3  Phase 3 — Polish
    H3  Finish (companion config, regenerate profile)
```

---

## Section-by-section requirements

### H1 + front matter

| Element | Required | Guidance |
| :--- | :---: | :--- |
| Title | Yes | `Build Plan - {Name}: {Archetype} ({Tag})` — prefer over legacy `Walkthrough -` |
| Profile link | Yes | Blockquote linking to paired `{slug}.md` with level, race, class, CP, account |
| Pitch | Yes | 1–2 paragraphs: subclass merge, content target, playstyle hook |

### Build at a glance

Single summary table. Include **live** vs **target** labels when the profile export differs from the planned end state.

| Row (typical) | Notes |
| :--- | :--- |
| Primary Stat | Attribute spread + key pools at CP160 |
| Mundus Stone | Target; note if live differs |
| Vampirism | Cured / Stage N / N/A |
| Sets | Craftable pairing; **100% craftable** unless documented exception |
| Bars | Front + back weapon types and bar nicknames |
| Food / Potion / Poisons / Enchants | Consumables and bar enchants |
| Companion | Primary + fallback |
| Primary Mount | Name + anchor to Collectibles |

Follow with **Read next:** inline anchor links to every major H2.

### Roleplay

| Element | Required | Guidance |
| :--- | :---: | :--- |
| Identity prose | Yes | Who the character is in fiction; how the build reads |
| Suggested Custom Title | Yes | ≤100 characters; backtick-wrapped for LAM Custom Title |
| Build Notes | Yes | ≤1,900 characters; single paste block for LAM Build Notes |
| Flavor Pet | Optional | Short tip; full mount/pet/dye detail lives under Collectibles |

### Trinity configuration

- **One** mermaid diagram: three skill lines converging on the archetype name.
- **One** unified pillar table — no separate third “slot-only” table.
- Columns: Pillar, Line, Origin, Slot action (KEEP / SUBCLASS), Function.
- Reference [`docs/subclassing.md`](subclassing.md) for Uber Tier / Bahtra quest context.

### Combat kit

| H3 | Content |
| :--- | :--- |
| **Skill bars** | Two H4 subsections (front/back). Tables: Slot, Class/Line, Base → Morph, Role, Profile (Live/Respec). **Include ultimates in slot 6.** **Slot 5** is always the summon slot when Daedric pets are used (same ability on both bars). Document **slotted morph names as shown in the skills UI**. |
| **Rotation and combat tips** | Opener → setup → swap → loop. Mermaid flowchart encouraged. Numbered tips for solo, bosses, etc. |
| **Passive skills** | Priority-ordered by skill line. Rank II/III notation. Group by class, weapon, armor, guild, race, world soul. |

**Mechanical rules:** Bars must match equipped weapon types. Each morph at most once across bars. Use real ESO ability lines only (base → sibling morphs). **Daedric summons:** when used, the same summon occupies **slot 5 on both bars** (bar swap otherwise despawns it); if slot 5 cannot be dedicated on both bars, omit Daedric summons and use other skills in slot 5 — never plan a summon on only one bar or outside slot 5.

### Gear and crafting

| H3 | Content |
| :--- | :--- |
| **Set rationale** | Why this craftable pairing; mermaid or table; optional “why not X” callout |
| **Target loadout** | Full 12-slot + weapons table; label interim vs target pieces |
| **Crafting handoff** | @masisi coordination: motif, station traits, Divines/Arcane/etc., interim Seducer-style bridge |

**Craftable-only default:** Primary loadouts use account crafter / crafting stations. No overland/dungeon/trial drops unless user explicitly requests an exception.

### Champion Point Mapping

- State full budget split (Warfare / Craft / Fitness).
- Per discipline H3: slotted stars table + passive point list.
- Use **exact star names, max points, and slottable/passive type** from [`examples/templates/champion_points_reference.md`](../examples/templates/champion_points_reference.md) (generated from [`champion_points.yaml`](../examples/templates/champion_points.yaml)).
- **Spend** values must not exceed the catalog **Max**; partial spends use catalog **Stages** increments.
- Below 900 total CP: 3 slotted stars per discipline; at 900+: 4 per discipline. Only catalog **Slottable** stars use a slot.

### Companion Strategy

- Companion **gear is separate** from player gear — only **Companion's** weapons/armor with **companion-only traits** (Quickened, Aggressive, Bolstered, etc.).
- No fictional **"Companion's {player set}"** names, player sets (Julianos, Clever Alchemist, Divines), or **5-piece set bonuses** on companions.
- Acquisition: merchant white basics + **Superior+** drops while companion is active — **not** player crafting handoff from Gear and crafting.
- Include role, gear weight, trait, loadout, acquisition, and a numbered support skill bar.

### Collectibles

Mount, pet, and visual identity **always** live here — never between Gear and Champion Points.

| H3 | Content |
| :--- | :--- |
| **Mount** | Primary, backups, avoid-thematically |
| **Pet** | Thematic matches |
| **Dye and style** | Motif table + dye palette |

### Next Steps & In-Game Action Checklist

- **One** execution checklist only — gear phases are **labeled steps inside this H2**, not a separate “Gear Phases” H2.
- Phases: 0 (today/functional) → 1 (interim craft) → 2 (target craft) → 3 (polish) → Finish (companion, `/markdown` profile sync).

---

## Optional H2/H3 blocks (use when relevant)

Insert **after** the nearest canonical section, or as an extra H3 inside Combat kit / Gear — never reorder core H2s.

| Block | When to use | Typical placement |
| :--- | :--- | :--- |
| Vampire Management | Stage 1–4 builds | H3 under Roleplay or own H2 before Trinity |
| Stamina / resource management | Hybrid or sustain-heavy | H3 under Rotation |
| Alternative setup | Delve runner, one-bar lazy, corpse exploder | H3 at end of Combat kit |
| Werewolf bar | Karakum-style transforms | H4 under Skill bars |
| Rapport & ethics | Companion rapport gates | H3 under Companion Strategy |
| Resource / gathering strategy | Masisi crafter builds | Replaces or supplements Combat kit |
| Master's Forge & assets | Account crafter inventory | After Gear or as Collectibles extension |

---

## Crafter-variant layout (`masisi_plan.md` pattern)

Account crafter / farmer plans **omit** Trinity configuration and full combat rotation. Suggested H2 order:

1. H1 + profile link + pitch (crafter role, not DPS)
2. Roleplay
3. Build at a glance (farming sets, mount speed, gathering CP)
4. Resource strategy (gathering routine, CP passives)
5. Equipment and style (movement/stealth sets)
6. Skill strategy (utility bar only)
7. Companion strategy (gathering assistant)
8. Master's forge and assets (stations, surveys, motifs)
9. Next steps

Use the **Crafter variant** section in [`template_plan.md`](../examples/templates/template_plan.md) when authoring.

---

## Legacy → canonical mapping

Use this when aligning an older plan without rewriting flavor prose.

| Legacy section (common) | Canonical destination |
| :--- | :--- |
| `Final Build Summary` table | **Build at a glance** |
| `The Pillar of…` / `Trinity of Power` | **Trinity configuration** (merge tables → one) |
| `The "Uber" Rotation` / `Skill Rotation & Strategy` | **Combat kit** → Skill bars + Rotation |
| `Passive Mastery` / `Passive Skills to Spend` | **Combat kit** → Passive skills |
| `Equipment Strategy` | **Gear and crafting** → Set rationale + Target loadout |
| `Visual Identity` / `Aesthetic Design` | **Collectibles** → Dye and style |
| `Crafter's Procurement List` | **Gear and crafting** → Crafting handoff |
| `Champion Point Investment` | **Champion Point Mapping** |
| `Recommended Companion` | **Companion Strategy** |
| `Collectibles: The … Menagerie` | **Collectibles** (split Mount / Pet) |
| `Next Steps` (unphased) | **Next Steps** with Phase 0–3 + Finish |

---

## Structural anti-patterns (avoid)

| Anti-pattern | Fix |
| :--- | :--- |
| Duplicate H2 (e.g. two Vampire Management sections) | Merge into one |
| Gear H2 before Combat kit | Reorder to canonical sequence |
| Visual identity / mount between Gear and CP | Move to Collectibles |
| Separate “Gear Phases” H2 | Fold phases into Next Steps checklist |
| Third trinity slot-only table | Merge into unified pillar table |
| `Walkthrough -` title on new plans | Use `Build Plan -` |
| Wiki-only or unmorphed skill names on bars | Use in-game slotted morph names |
| Player set pieces on companion | Companion-specific gear section |
| Non-craftable primary sets | Replace or document explicit exception |

---

## Alignment checklist

When reviewing any `{slug}_plan.md`:

- [ ] H2 order matches canonical sequence (or documented crafter variant)
- [ ] Profile link and paired `{slug}.md` exist
- [ ] Build at a glance labels **live** vs **target** where they differ
- [ ] Roleplay includes Custom Title (≤100) and Build Notes (≤1,900)
- [ ] Trinity = one mermaid + one table
- [ ] Skill bars match equipped weapons; ultimates on slot 6; summons on slot 5 (both bars, same ability) when used; morph names from UI
- [ ] Gear is craftable; crafting handoff references @masisi
- [ ] CP recommendations use [`champion_points_reference.md`](../examples/templates/champion_points_reference.md) names, max points, and slottable/passive type
- [ ] Companion gear is companion-specific
- [ ] Mount / pet / dye under Collectibles only
- [ ] Single phased checklist at end
- [ ] Plan file not edited when implementing from an attached plan (update profile + artifacts only)

---

## Related files

| Path | Purpose |
| :--- | :--- |
| `examples/templates/template_plan.md` | Copy-paste skeleton for new plans |
| `examples/templates/build_plan_template.md` | Alias / legacy name; points to `template_plan.md` |
| `examples/solaegis/na/silent_snow_falls_plan.md` | Filled canonical exemplar |
| `examples/solaegis/na/kellen_dysart_plan.md` | Canonical + Custom Title / Build Notes |
| `examples/solaegis/na/masisi_plan.md` | Crafter-variant exemplar |
| `AGENTS.md` | Agent rules for plan implementation |
