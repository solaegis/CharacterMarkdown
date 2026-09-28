# Collectibles & Companion Ledger

Living ledger of **primary** mount / flavor pet / costume and companion stages across Solaegis build plans, plus **account collectible tiers** and **per-character shortlists**. Consult this file before locking collectible primaries on a new or heavily revised `*_plan.md`.

**Design:** [`docs/superpowers/specs/2026-09-06-collectibles-companion-ledger-design.md`](superpowers/specs/2026-09-06-collectibles-companion-ledger-design.md)  
**Structure rules:** [`docs/plan_structure.md`](plan_structure.md)  
**Skill:** personal `eso-collectibles-tier-ledger` (`~/.cursor/skills/eso-collectibles-tier-ledger/`)

When locking primaries: consult **account tiers → character shortlist → primary table** (same megaserver).

## Selection rules (summary)

1. **Owned first** — primaries must appear in that character’s profile export (or the account Collectibles pool when the profile’s Collectibles section is incomplete but ownership is account-wide).
2. **Appropriateness first** — theme and build identity beat diversity.
3. **Consult this ledger** for the **same megaserver** before locking primaries (tiers + shortlist + primary table).
4. **Diversify when roughly equal** — prefer a primary not already used on that megaserver. No numeric cap.
5. **Reuse is allowed** when no strong owned alternative exists — note why in **Notes**.
6. **Alts / ideals** may freely share popular picks; diversity pressure applies to **primaries** only.
7. **Companions** — always best-fit by stage (Primary now / Secondary / Goal); reuse across plans is fine. Companions are **not** S/A/B/C-tiered here.
8. **Update this ledger** whenever a plan’s glance rows change, or after re-running the collectibles tier skill. Rebalance existing plans only when next touched.

**Tier rubric:** **S** signature / high impact · **A** strong multi-archetype · **B** situational · **C** starter / low priority (C often collapsed to a count).

**Owned data snapshot:** 2026-09-12 from `examples/solaegis/{na,eu}/` profile Collectibles details. EU pool SoT: `sabir_al_rih.md`. NA pool SoT: `dolu_tenasi.md` (+ union of extra owned names from other usable exports).

---

## EU Megaserver

| Slug | Primary Mount | Flavor Pet | Costume | Companion Primary | Companion Secondary | Companion Goal | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| alpha_top | Snow Bear | Golden Eagle | Covenant Scout | Bastian Hallix | Mirri Elendis | Tanlorin | Mount moved to Snow Bear 2026-09-27 (newly owned) |
| karakadin | Pyrodraconic Camel-Lizard | Alik'r Dune-Hound | Forebear Dishdasha | Bastian Hallix | Mirri Elendis | Zerith-var | Shortlist S aligns |
| lord_elric_of_melnibone | Nightmare Senche | Long-Winged Bat | Mannimarco | Mirri Elendis | Tanlorin | Zerith-var | Profile Collectibles incomplete; ownership from account pool |
| masisi | Psijic Escort Charger | Psijic Mascot Bear Cub | Imperial Chancellor | Tanlorin | Mirri Elendis | Zerith-var | Hybrid farmer-DPS; Goal Zerith for PD filler; primary Psijic kit retained (theme over diversity with taranis) |
| taranis_kotu | Psijic Escort Charger | Coldharbour Bantam Guar | Mannimarco | Bastian Hallix | Mirri Elendis | Tanlorin | Shares mount+costume primaries with masisi / elric — revisit when next touched |
| zirhli | Rahd-m'Athra | Verdigris Haj Mota | Shrouded Armor | Tanlorin | Bastian Hallix | Tanlorin | Diversified 2026-09-06 off Nightmare Senche / Dune-Hound |
| sabir_al_rih | Hammerfell Camel (Ideal) | Fennec Fox (Ideal) | Claw-Dance Acolyte Style (Ideal) | Ember | Mirri Elendis | Zerith-var | Greenfield Ideals **not** in EU owned pool; best owned bridges: Pyrodraconic Camel-Lizard / Alik'r Dune-Hound / Forebear Dishdasha; alt costume Priest of the Green unowned |
| dolu_tanesi | Noweyr Steed | Haunted House Cat | Austere Warden Outfit | Mirri Elendis | Bastian Hallix | Tanlorin | Magicka life-broker NB; Snape-coded; profile Collectibles incomplete; distinct from NA dolu_tenasi |
| s_katib_asrar | Dwarven War Horse | Scintillant Dovah-Fly | Court of Bedlam | Mirri Elendis | Bastian Hallix | Tanlorin | Greenfield Mag Arcanist Lexarch; diversified off Psijic/Mannimarco; stub profile until /cm |
| hastein_sea_wolf | Bleakrock Snowdog | Nenalata Ayleid Wolf Pup | Sea Drake Garb | Mirri Elendis | Tanlorin | Mirri Elendis | Greenfield Nord DK Uber tank (DC, sea-wolf raider); Bleakrock Snowdog bought 2026-09-27 as the wolf mount (Durzog backup); pet + costume unused primaries; stub until /cm |

### EU frequency (primaries appearing more than once)

| Kind | Name | Plans |
| :--- | :--- | :--- |
| Mount | Psijic Escort Charger | masisi, taranis_kotu |
| Costume | Mannimarco | lord_elric_of_melnibone, taranis_kotu |

### Account collectible tiers

Pool SoT: `sabir_al_rih.md` (8 mounts / 36 pets / 23 costumes) + **Snow Bear** (seen in `s_katib_asrar.md`, 2026-09-27 export) + **Bleakrock Snowdog** (bought 2026-09-27; not yet in an export). Shared across @SOLAEGIS EU.

#### Mounts

| Tier | Names |
| :--- | :--- |
| S | Bleakrock Snowdog, Nightmare Senche, Psijic Escort Charger, Pyrodraconic Camel-Lizard, Rahd-m'Athra |
| A | Dwarven War Horse, Noweyr Steed, Skulltooth Coastal Durzog, Snow Bear |
| B | — |
| C | Sorrel Horse |

#### Pets

| Tier | Names |
| :--- | :--- |
| S | Alik'r Dune-Hound, Coldharbour Bantam Guar, Golden Eagle, Haunted House Cat, Long-Winged Bat, Psijic Mascot Bear Cub, Verdigris Haj Mota |
| A | Blue Dragon Imp, Craglorn Welwa, Dwarven Spider, Fledgling Terror Bird, Green Dragon Imp, Infernium Dwarven Spiderling, Jackal, Nenalata Ayleid Wolf Pup, Noweyr Pony, Psijic Mascot Pony, Scintillant Dovah-Fly |
| B | Abecean Ratter Cat, Akaviri Potentate Bear Cub, Ambersheen Vale Fawn, Covenant Breton Terrier, Crimson Torchbug, Dominion Breton Terrier, Dwarven War Dog, Echalette, Hay-Crown Chub Loon, Imgakin Monkey, Mottled Sheep, Pocket Salamander, Ringtail Jerboa, Shezarr's Chicken, Tan Morthal Mastiff, Vermilion Scuttler, Viridescent Dragon Frog |
| C | Housecat |

#### Costumes

| Tier | Names |
| :--- | :--- |
| S | Court of Bedlam, Dark Seducer, Golden Saint, Grim Harvester, Imperial Chancellor, Mannimarco, Shrouded Armor |
| A | Austere Warden Outfit, Bloodthorn Robes, Covenant Scout, Crown Dishdasha, Forebear Dishdasha, Lion Guard Knight, Mages Guild Formal Robes, Noble Clan-Chief, Red Rook Armor |
| B | Dominion Scout, Imperial Guard Centurion Uniform, Marshlord Formal Bugshell Robes, Sea Drake Garb, Vulkhel Guard Marine Armor, Wood Elf Vanguard |
| C | Servant's Robes |

### Per-character shortlists

#### alpha_top

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Snow Bear (A, primary) | Skulltooth Coastal Durzog, Sorrel Horse | Breton Warden / DC; Snow Bear fits Winter's Embrace frost kit |
| Pet | Golden Eagle | Alik'r Dune-Hound, Blue Dragon Imp | |
| Costume | Covenant Scout | Austere Warden Outfit, Red Rook Armor, Shrouded Armor | |

#### dolu_tanesi

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Noweyr Steed | Nightmare Senche, Psijic Escort Charger | Profile Collectibles incomplete; use account pool |
| Pet | Haunted House Cat | Long-Winged Bat, Housecat | Snape / life-broker vibe |
| Costume | Austere Warden Outfit | Mages Guild Formal Robes, Mannimarco, Shrouded Armor | |

#### karakadin

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Pyrodraconic Camel-Lizard | Rahd-m'Athra, Skulltooth Coastal Durzog | Redguard Necro |
| Pet | Alik'r Dune-Hound | Coldharbour Bantam Guar, Long-Winged Bat | |
| Costume | Forebear Dishdasha | Crown Dishdasha, Grim Harvester | |

#### lord_elric_of_melnibone

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Nightmare Senche | Rahd-m'Athra, Psijic Escort Charger | Profile Collectibles incomplete |
| Pet | Long-Winged Bat | Blue Dragon Imp, Haunted House Cat | |
| Costume | Mannimarco | Court of Bedlam, Dark Seducer, Grim Harvester | Shares Mannimarco primary with taranis |

#### masisi

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Psijic Escort Charger | Dwarven War Horse, Noweyr Steed | Crafter / Psijic kit; shares mount with taranis |
| Pet | Psijic Mascot Bear Cub | Psijic Mascot Pony, Noweyr Pony | |
| Costume | Imperial Chancellor | Crown Dishdasha, Court of Bedlam | |

#### sabir_al_rih

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Pyrodraconic Camel-Lizard (owned bridge) | Rahd-m'Athra, Skulltooth Coastal Durzog | Ideal Hammerfell Camel **unowned**; keep Ideal in primary until acquired |
| Pet | Alik'r Dune-Hound (owned bridge) | Jackal, Ringtail Jerboa | Ideal Fennec Fox **unowned** |
| Costume | Forebear Dishdasha (owned bridge) | Crown Dishdasha, Wood Elf Vanguard | Ideal Claw-Dance / Priest of the Green **unowned** |

#### taranis_kotu

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Psijic Escort Charger | Noweyr Steed, Nightmare Senche | Shares Psijic mount with masisi |
| Pet | Coldharbour Bantam Guar | Blue Dragon Imp, Long-Winged Bat | |
| Costume | Mannimarco | Court of Bedlam, Bloodthorn Robes | Shares Mannimarco with elric |

#### zirhli

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Rahd-m'Athra | Nightmare Senche, Skulltooth Coastal Durzog | Argonian DK / EP |
| Pet | Verdigris Haj Mota | Alik'r Dune-Hound, Blue Dragon Imp | |
| Costume | Shrouded Armor | Red Rook Armor, Bloodthorn Robes | |

#### s_katib_asrar

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Dwarven War Horse | Noweyr Steed, Sorrel Horse | Khajiit Mag Arcanist; unused mount primary |
| Pet | Scintillant Dovah-Fly | Blue Dragon Imp, Haunted House Cat | Ink-mote scribe familiar |
| Costume | Court of Bedlam | Bloodthorn Robes, Mages Guild Formal Robes | Apocrypha-court; not Misrule |

#### hastein_sea_wolf

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Bleakrock Snowdog (primary) | Skulltooth Coastal Durzog; C: Sorrel Horse | Sea-wolf theme: Nord-isle wolf-hound |
| Pet | — | Nenalata Ayleid Wolf Pup (primary); B: Abecean Ratter Cat, Hay-Crown Chub Loon, Tan Morthal Mastiff | Pack + ship's cat |
| Costume | — | Noble Clan-Chief; B: Sea Drake Garb (primary), Vulkhel Guard Marine Armor | Theme over tier: Sea Drake Garb is the raider |

### Incomplete collectibles exports (EU)

Profiles with no parseable Mounts/Pets/Costumes details (ownership still account-wide via SoT export): `dolu_tanesi`, `lord_elric_of_melnibone`, `s_katib_asrar` (greenfield stub until `/cm`), `hastein_sea_wolf` (plan only; character not yet created).

---

## NA Megaserver

| Slug | Primary Mount | Flavor Pet | Costume | Companion Primary | Companion Secondary | Companion Goal | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| heka_ankh | Dwarven War Horse | Alik'r Jackal | — | Mirri Elendis | Zerith-var | Isobel Veloise | incomplete glance (no costume row); profile Collectibles incomplete |
| kellen_dysart | Flame Atronach Senche | Golden Eagle | — | Zerith-var | Isobel Veloise | Isobel Veloise | incomplete glance (no costume row); shortlist S aligns |
| lei_tun | Sapiarchic Senche-Serval | Abecean Ratter Cat | — | Ember | Azandar al-Cybiades | Sharp-as-Night | incomplete glance (no costume row) |
| pelatiah | Imperial Horse | Imperial War Mastiff | — | Bastian Hallix | Isobel Veloise | Bastian Hallix | incomplete glance (no costume row); profile Collectibles incomplete; Imperial War Mastiff not in NA pet pool export |
| rilis_toxil | Sapiarchic Senche-Serval | Dwarven Spider | — | Sharp-as-Night | Bastian Hallix | Sharp-as-Night | incomplete glance (no costume row); shares mount primary with lei_tun |
| silent_snow_falls | Swamp Senche | — | — | Sharp-as-Night | Mirri Elendis | — | incomplete glance; Swamp Senche **not** in current owned mount pool — treat as Ideal until export confirms |
| stoirmgheal | Faunfrolic Great Elk | Ambersheen Vale Fawn | Crystal Tower Sapiarchs' Gown | Tanlorin | (dismiss in group) | — | incomplete companion Goal; Crystal Tower gown not in owned costume pool — Ideal/alt |

### NA frequency (primaries appearing more than once)

| Kind | Name | Plans |
| :--- | :--- | :--- |
| Mount | Sapiarchic Senche-Serval | lei_tun, rilis_toxil |

### Account collectible tiers

Pool SoT: `dolu_tenasi.md` unioned with other usable NA exports (gender suffixes stripped; assistants excluded from Pets).

#### Mounts

| Tier | Names |
| :--- | :--- |
| S | Flame Atronach Senche, Nightmare Senche, Psijic Escort Charger, Pyrodraconic Camel-Lizard, Rahd-m'Athra, Sapiarchic Senche-Serval, Skulltooth Coastal Durzog, Wormwrithe Bear-Lizard |
| A | Ashbone Sabre Cat, Dwarven War Horse, Ebon Dwarven Horse, Faunfrolic Great Elk, Frostborn Durzog Mangler, Hammerfell Camel, Highland Spotted Lynx, Ja'zennji Siir Fox, Nix-Ox War-Steed, Noble Riverhold Senche-Lion, Noweyr Steed, Rimmen Ringtailed Wolf, Rubyflare Torchnix, Senche-Leopard, Shadowghost Guar, Snow Bear, Spotted Duneracer Senche-raht, Warparty Timber Mammoth |
| B | Bleakrock Snowdog, Green Narsis Guar, Hearthfire Kagouti, Imperial Horse, Midnight Steed, Tessellated Guar, Timber Mammoth, Yorgrim River Ram |
| C | 5 names — Bay Dun Horse, Brown Paint Horse, Sorrel Horse, and remaining generic horses; see `dolu_tenasi.md` Collectibles |

#### Pets

| Tier | Names |
| :--- | :--- |
| S | Alik'r Dune-Hound, Autumnal Indrik, Coldharbour Dremnaken Runt, Dusky Fennec Fox, Dwarven Spider, Golden Eagle, Haunted House Cat, Long-Winged Bat, Mad God's Tomeshell, Psijic Mascot Bear Cub, Steam-Driven Brassilisk, Verdigris Haj Mota, Wormwrithe Haj Mota Hatchling |
| A | Abecean Ratter Cat, Ambersheen Vale Fawn, Blue Dragon Imp, Coldharbour Bantam Guar, Fledgling Terror Bird, Frost Atronach Kagouti Calf, Green Dragon Imp, Grisly Banekin Mummy, Infernium Dwarven Spiderling, Jackal, Nenalata Ayleid Wolf Pup, Noweyr Pony, Psijic Mascot Guar Calf, Psijic Mascot Pony, Scintillant Dovah-Fly, Sep Adder, Stonefire Scamp, Sylvan Nixad |
| B | Bal Foyen Nix-Hound, Big-Eared Ginger Kitten, Bravil Retriever, Covenant Breton Terrier, Crimson Torchbug, Dawngold Corgi, Dominion Breton Terrier, Dozen-Banded Vvardvark, Dwarven War Dog, Echalette, Hot Pepper Bantam Guar, Imgakin Monkey, Nibenay Mudcrab, Orchid Whisper Moth, Pact Breton Terrier, Pocket Mammoth, Pocket Salamander, Riverwood White Hen, Silent Moons Sheep, Spectral Mudcrab, Vermilion Scuttler, Viridescent Dragon Frog, Vvardvark |
| C | Housecat + remaining filler pets — see `dolu_tenasi.md` Collectibles |

#### Costumes

| Tier | Names |
| :--- | :--- |
| S | Ashlander Kagesh Tribe Armor, Black Hand Robe, Court of Bedlam, Dark Seducer, Golden Saint, Grim Harvester, Imperial Chancellor, Mannimarco, Regalia of the Scarlet Judge, Shrouded Armor, Thieves Guild Leathers |
| A | Ashlander Mabrigash Travel Wear, Austere Warden Outfit, Bloodthorn Robes, Covenant Scout, Crown Dishdasha, Dunmer Cultural Garb, Elven Hero Armor, Forebear Dishdasha, Hollow Moon Garb, Lion Guard Knight, Mages Guild Formal Robes, Mages Guild Research Robes, Merchant Lord's Formal Regalia, Midnight Union Garb, Noble Clan-Chief, Quendelunn Veiled Heritance Garb, Red Rook Armor, Sea Viper Armor, Timbercrow Wanderer |
| B | 10-Year Anniversary Breton Hero, Breton Hero Armor, Colovian Uniform, Cyrod Patrician Formal Gown, Fort Amol Guard Armor, Frostedge Bandit Armor, Holiday in Balmora Outfit, Keeper's Garb, Mages Guild Leggings Uniform, New Life Fish Boon Angler, New Life Winter Storm Robes, Phaer Mercenary Armor, Satakalaaam Imperial Armor, Sea Drake Garb, Seventh Legion Armor, Siegemaster's Uniform, Skald's Damask Jerkin, Steel Shrike Uniform, Stormfist Uniform, Upriver Striped Sash-Kilt, Vanguard Uniform, Vengeance Day Dress, Vulkhel Guard Marine Armor |
| C | 8+ starter/service outfits (Courier Uniform, Nordic Bather's Towel, Servant's Outfit, Servant's Robes, …) — see `dolu_tenasi.md` Collectibles |

### Per-character shortlists

Shortlists below cover ledgered plans plus Not-yet-ledgered slugs that have usable profiles. Incomplete-export characters still use the account pool.

#### heka_ankh

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Dwarven War Horse, Hammerfell Camel | Pyrodraconic Camel-Lizard, Rahd-m'Athra | Profile Collectibles incomplete; Ideal Dune Stalker Senche unowned |
| Pet | Alik'r Dune-Hound | Jackal, Dusky Fennec Fox | Ideal Alik'r Jackal / Sand Wisp — Jackal is closest owned |
| Costume | Forebear Dishdasha, Grim Harvester | Crown Dishdasha, Imperial Chancellor | No glance costume yet |

#### kellen_dysart

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Flame Atronach Senche | Nightmare Senche, Psijic Escort Charger | Storm / lightning sovereign |
| Pet | Golden Eagle | Blue Dragon Imp, Long-Winged Bat | |
| Costume | Mannimarco, Imperial Chancellor | Court of Bedlam, Lion Guard Knight | No glance costume yet |

#### lei_tun

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Sapiarchic Senche-Serval | Highland Spotted Lynx, Noble Riverhold Senche-Lion | Khajiit Warden; Ideal Abyssal Quasigriff unowned |
| Pet | Abecean Ratter Cat | Psijic Mascot Bear Cub, Sylvan Nixad | Ideal Sea Sload Dorsal Fin unowned |
| Costume | Hollow Moon Garb, Austere Warden Outfit | Quendelunn Veiled Heritance Garb, Elven Hero Armor | No glance costume yet |

#### pelatiah

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Imperial Horse | Dwarven War Horse, Midnight Steed | Profile Collectibles incomplete |
| Pet | Golden Eagle, Bravil Retriever | Dwarven War Dog, Tan-adjacent N/A | Imperial War Mastiff not in pool |
| Costume | Imperial Chancellor, Lion Guard Knight | Seventh Legion Armor, Satakalaaam Imperial Armor | No glance costume yet |

#### rilis_toxil

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Sapiarchic Senche-Serval | Psijic Escort Charger, Nightmare Senche | Shares Senche-Serval primary with lei_tun |
| Pet | Dwarven Spider | Coldharbour Dremnaken Runt, Mad God's Tomeshell | |
| Costume | Mannimarco, Mages Guild Formal Robes | Court of Bedlam, Quendelunn Veiled Heritance Garb | No glance costume yet |

#### silent_snow_falls

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Skulltooth Coastal Durzog, Wormwrithe Bear-Lizard | Shadowghost Guar, Noweyr Steed | Ideal Swamp Senche unowned in pool |
| Pet | Verdigris Haj Mota, Haunted House Cat | Coldharbour Bantam Guar, Sylvan Nixad | |
| Costume | Austere Warden Outfit, Shrouded Armor | Ashlander Mabrigash Travel Wear, Timbercrow Wanderer | |

#### stoirmgheal

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Faunfrolic Great Elk | Sapiarchic Senche-Serval, Noweyr Steed | Breton / nature-storm |
| Pet | Ambersheen Vale Fawn | Autumnal Indrik, Sylvan Nixad | |
| Costume | Mages Guild Formal Robes, Court of Bedlam | Quendelunn Veiled Heritance Garb, Austere Warden Outfit | Crystal Tower gown Ideal / unowned in pool |

#### dextera_dei

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Nightmare Senche | Imperial Horse, Dwarven War Horse | Not yet ledgered primary row |
| Pet | Abecean Ratter Cat | Golden Eagle, Long-Winged Bat | Plan tips cite Ratter Cat |
| Costume | Imperial Chancellor, Lion Guard Knight | Seventh Legion Armor, Shrouded Armor | |

#### dolu_tenasi

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Nightmare Senche, Rahd-m'Athra | Skulltooth Coastal Durzog, Frostborn Durzog Mangler | Orc Sorc; richest pool SoT |
| Pet | Haunted House Cat, Long-Winged Bat | Blue Dragon Imp, Golden Eagle | |
| Costume | Shrouded Armor, Thieves Guild Leathers | Red Rook Armor, Mannimarco | |

#### hya_cinthe

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Sapiarchic Senche-Serval, Ja'zennji Siir Fox | Highland Spotted Lynx, Spotted Duneracer Senche-raht | Khajiit Arcanist |
| Pet | Abecean Ratter Cat, Dusky Fennec Fox | Psijic Mascot Bear Cub, Scintillant Dovah-Fly | |
| Costume | Hollow Moon Garb, Quendelunn Veiled Heritance Garb | Elven Hero Armor, Court of Bedlam | |

#### karakedi

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Rahd-m'Athra, Sapiarchic Senche-Serval | Highland Spotted Lynx, Nightmare Senche | Khajiit NB |
| Pet | Haunted House Cat, Long-Winged Bat | Dusky Fennec Fox, Abecean Ratter Cat | |
| Costume | Black Hand Robe, Thieves Guild Leathers | Shrouded Armor, Hollow Moon Garb | |

#### karakum

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Nightmare Senche, Hammerfell Camel | Pyrodraconic Camel-Lizard, Rahd-m'Athra | Redguard DK desert |
| Pet | Alik'r Dune-Hound, Dusky Fennec Fox | Jackal, Golden Eagle | |
| Costume | Forebear Dishdasha, Crown Dishdasha | Grim Harvester, Red Rook Armor | |

#### masisi

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Psijic Escort Charger, Imperial Horse | Dwarven War Horse, Flame Atronach Senche | NA Imperial DK crafter |
| Pet | Psijic Mascot Bear Cub | Golden Eagle, Autumnal Indrik | Plan Ideals (Milky Dragonette etc.) may be unowned |
| Costume | Imperial Chancellor, Merchant Lord's Formal Regalia | Court of Bedlam, Noble Clan-Chief | |

#### nekhtarhebi

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Wormwrithe Bear-Lizard, Skulltooth Coastal Durzog | Nightmare Senche, Rahd-m'Athra | Necro spectral |
| Pet | Haunted House Cat, Blue Dragon Imp | Coldharbour Dremnaken Runt, Mad God's Tomeshell | |
| Costume | Grim Harvester, Mannimarco | Dark Seducer, Shrouded Armor | |

#### talon_valois

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Rahd-m'Athra, Nightmare Senche | Shadowghost Guar, Skulltooth Coastal Durzog | Imperial NB spectral |
| Pet | Haunted House Cat, Long-Winged Bat | Blue Dragon Imp, Grisly Banekin Mummy | |
| Costume | Black Hand Robe, Shrouded Armor | Thieves Guild Leathers, Mannimarco | |

#### laetha

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Psijic Escort Charger, Sapiarchic Senche-Serval | Flame Atronach Senche, Noweyr Steed | High Elf Sorc |
| Pet | Golden Eagle, Long-Winged Bat | Blue Dragon Imp, Psijic Mascot Bear Cub | |
| Costume | Mannimarco, Mages Guild Formal Robes | Court of Bedlam, Quendelunn Veiled Heritance Garb | |

#### tziyad

| Kind | S | A | Notes |
| :--- | :--- | :--- | :--- |
| Mount | Ashbone Sabre Cat, Skulltooth Coastal Durzog | Shadowghost Guar, Noweyr Steed | Dark Elf Warden |
| Pet | Verdigris Haj Mota, Haunted House Cat | Coldharbour Bantam Guar, Sylvan Nixad | |
| Costume | Dunmer Cultural Garb, Ashlander Kagesh Tribe Armor | Austere Warden Outfit, Shrouded Armor | |

### Incomplete collectibles exports (NA)

Profiles with no parseable Mounts/Pets/Costumes details: `heka_ankh`, `pelatiah`.

---

## Not yet ledgered

Plans without full glance collectible rows (add when next touched):

**NA:** `dextera_dei`, `dolu_tenasi`, `hya_cinthe`, `karakedi`, `karakum`, `masisi`, `nekhtarhebi`, `talon_valois`

**EU:** *(none — all current EU combat plans are in the table above)*

Shortlists for Not-yet-ledgered NA slugs are already seeded above; promote to the primary table when those plans are next revised.
