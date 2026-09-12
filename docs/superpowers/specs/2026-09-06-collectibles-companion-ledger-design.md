# Design: Collectibles & Companion Ledger

**Date:** 2026-09-06  
**Status:** Approved for implementation planning  
**Repo:** CharacterMarkdown (solaegis example build plans)

## Problem

Solaegis `*_plan.md` files already recommend mounts, pets, costumes, and companions, but there is no shared ledger. Agents over-reuse strong thematic favorites (e.g. Golden Eagle, Psijic Escort Charger, Sapiarchic Senche-Serval, Mannimarco) and companion stage rows are uneven across older plans.

## Goals

- Track primary **mount**, **flavor pet**, and **costume** plus companion **Primary / Secondary / Goal** per plan, per megaserver.
- Prefer the most appropriate owned collectibles; diversify when appropriateness is roughly equal.
- Always recommend the best companion for each build stage (no diversity soft-cap).
- Process first: ship ledger + rules now; rebalance existing plans only when each plan is next touched.

## Non-goals

- Mass rewrite of all existing plans in the first implementation pass.
- Numeric hard caps on shared primaries.
- YAML SoT, validators, or CI checks (may come later).
- Diversity pressure on companion picks or on alt/ideal collectibles.

## Decisions (locked)

| Topic | Decision |
| :--- | :--- |
| Delivery shape | Single markdown ledger + short rules in existing SoT docs |
| Diversity scope | Soft preference **per megaserver** (NA and EU separate pools) |
| Soft-cap style | No numeric cap — consult ledger; diversify when roughly equal |
| Companions | Always best-fit by stage; reuse across plans is fine |
| Rebalance pace | Only when a plan is next created or heavily revised |

## Architecture

### 1. Ledger file

**Path:** `docs/collectibles_companion_ledger.md`

**Contents:**

1. Purpose blurb + selection rule summary (full rules also live in `docs/plan_structure.md`).
2. **NA Megaserver** H2 and **EU Megaserver** H2, each with:

| Slug | Primary Mount | Flavor Pet | Costume | Companion Primary | Companion Secondary | Companion Goal | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |

3. Per-server **Frequency** subsection listing primary mounts/pets/costumes that appear more than once (awareness only — not a hard block).
4. **Not yet ledgered** list: solaegis plan slugs that lack full glance rows until next touched.

Initial seed = current glance rows from existing plans (snapshot at implementation time). Incomplete glance rows (missing costume, non-stage companion wording) are recorded as-is with a Notes flag such as `incomplete glance`.

### 2. Selection rules (mount / pet / costume)

When writing or heavily revising a solaegis `*_plan.md`:

1. **Owned first** — primary costume/mount/pet must come from that character’s profile export (existing costume ownership rule remains).
2. **Appropriateness first** — theme, race/class identity, roleplay, and build archetype beat diversity.
3. **Consult the ledger** for the same megaserver before locking primaries.
4. **Diversify when roughly equal** — if two owned options are both highly appropriate, prefer the one that is not already a primary on another plan on that megaserver. No numeric cap.
5. **Reuse is allowed** when no strong owned alternative exists; explain why in the ledger Notes column.
6. **Alts / ideals** may freely share popular picks; diversity pressure applies to **primaries** only.
7. **Rebalance only when the plan is next touched** — do not mass-edit existing plans solely for diversity.

### 3. Companion stages (mandatory; no diversity soft-cap)

Every new or heavily revised plan must recommend companions by stage in Build at a glance and Companion strategy:

| Stage | When | Pick for |
| :--- | :--- | :--- |
| **Primary (now)** | Live CP / companion rank / current content | Best mechanical + RP fit today |
| **Secondary** | Swap for specific content or rapport | Best alternate for that niche |
| **Goal (20/20 @ CP160)** | End-state solo kit | Best long-term partner for the finished build |

Rules:

- Always **best-fit**; reuse across plans is fine.
- Stage rows remain mandatory even when Primary == Goal.
- Companion gear/acquisition rules stay as documented in `plan_structure.md` (companion-only items).
- Ledger records all three stages for visibility, not for diversity pressure.

### 4. Docs wiring + update workflow

**Wire into:**

| File | Change |
| :--- | :--- |
| `docs/collectibles_companion_ledger.md` | Create and seed from current plans |
| `docs/plan_structure.md` | Collectibles + Companion Strategy: ledger consult, diversity-when-equal, mandatory stage companions |
| `examples/templates/template_plan.md` | One-line author note pointing at the ledger |
| `AGENTS.md` | Short preference: consult/update ledger on plan create/revise; no mass rebalance; companions best-fit by stage |
| `docs/README.md` or `docs/SUMMARY.md` | Optional one-line index pointer |

**Update workflow (when a plan is next touched):**

1. Read profile export for owned mount/pet/costume.
2. Read the megaserver table in the ledger.
3. Choose primaries (appropriateness → diversify if roughly equal).
4. Choose companion Primary / Secondary / Goal (best-fit only).
5. Write plan glance + Collectibles + Companion strategy.
6. Update the ledger row + Frequency notes for that megaserver.

## Seed inventory (current glance — for implementation)

### NA — ledgered (partial or full)

| Slug | Primary Mount | Flavor Pet | Costume | Comp Primary | Comp Secondary | Comp Goal |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| heka_ankh | Dwarven War Horse | Alik'r Jackal | *(missing)* | Mirri Elendis | Zerith-var | Isobel Veloise |
| kellen_dysart | Flame Atronach Senche | Golden Eagle | *(missing)* | Zerith-var | Isobel Veloise | Isobel Veloise |
| lei_tun | Sapiarchic Senche-Serval | Abecean Ratter Cat | *(missing)* | Ember | Azandar al-Cybiades | Sharp-as-Night |
| pelatiah | Imperial Horse | Imperial War Mastiff | *(missing)* | Bastian Hallix | Isobel Veloise | Bastian Hallix |
| rilis_toxil | Sapiarchic Senche-Serval | Dwarven Spider | *(missing)* | Sharp-as-Night | Bastian Hallix | Sharp-as-Night |
| silent_snow_falls | Swamp Senche | *(tip only)* | *(missing)* | Sharp-as-Night | Mirri Elendis | *(unspecified)* |
| stoirmgheal | Faunfrolic Great Elk | Ambersheen Vale Fawn | Crystal Tower Sapiarchs' Gown | Tanlorin | *(group: dismiss)* | *(unspecified)* |

### EU — ledgered

| Slug | Primary Mount | Flavor Pet | Costume | Comp Primary | Comp Secondary | Comp Goal |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| alpha_top | Skulltooth Coastal Durzog | Golden Eagle | Covenant Scout | Bastian Hallix | Mirri Elendis | Tanlorin |
| karakadin | Pyrodraconic Camel-Lizard | Alik'r Dune-Hound | Forebear Dishdasha | Bastian Hallix | Mirri Elendis | Zerith-var |
| lord_elric_of_melnibone | Nightmare Senche | Long-Winged Bat | Mannimarco | Mirri Elendis | Tanlorin | Zerith-var |
| masisi | Psijic Escort Charger | Psijic Mascot Bear Cub | Imperial Chancellor | Tanlorin | Mirri Elendis | Tanlorin |
| taranis_kotu | Psijic Escort Charger | Coldharbour Bantam Guar | Mannimarco | Bastian Hallix | Mirri Elendis | Tanlorin |
| zirhli | Nightmare Senche | Alik'r Dune-Hound | Shrouded Armor | Tanlorin | Bastian Hallix | Tanlorin |

### Not yet ledgered (examples)

NA: `dextera_dei`, `dolu_tenasi`, `hya_cinthe`, `karakedi`, `karakum`, `masisi`, `nekhtarhebi`, `talon_valois` (and any other plan lacking glance collectible rows).

### Known primary collisions (awareness)

- **NA mount:** Sapiarchic Senche-Serval (`lei_tun`, `rilis_toxil`)
- **EU mount:** Psijic Escort Charger (`masisi`, `taranis_kotu`); Nightmare Senche (`lord_elric_of_melnibone`, `zirhli`)
- **EU costume:** Mannimarco (`lord_elric_of_melnibone`, `taranis_kotu`)
- **Pets:** Golden Eagle appears as primary on NA `kellen_dysart` and EU `alpha_top` (separate megaserver pools — OK)

## Success criteria

- Ledger file exists and is indexed from plan docs / agent notes.
- New and heavily revised plans consult and update the ledger.
- Companion Primary / Secondary / Goal is mandatory on those plans.
- Existing plans are not mass-rewritten solely for diversity in the first pass.

## Implementation follow-up

After this spec is approved as written, create an implementation plan (writing-plans) covering: create ledger seed, patch `plan_structure.md` / template / `AGENTS.md`, optional SUMMARY pointer — no plan-content rebalances unless a named plan is in scope for that work session.
