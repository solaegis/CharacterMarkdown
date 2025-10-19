```mermaid
graph TD
  %% ========================================
  %% ESO CHAMPION POINT SYSTEM - FULL DIAGRAM
  %% ========================================
  %% 
  %% LEGEND:
  %% • Yellow nodes = Base Stars (prerequisite nodes)
  %% • Green nodes = Craft tree stars
  %% • Blue nodes = Warfare tree stars  
  %% • Red nodes = Fitness tree stars
  %% • Purple nodes = Sub-constellation portals
  %% • Square brackets [[]] = Slottable stars (must be placed in Champion Bar)
  %% • Round parentheses () = Passive stars (always active)
  %% • Edge labels show minimum point prerequisites
  %%
  %% ========================================

  %% ========================================
  %% CRAFT CONSTELLATION (GREEN TREE)
  %% 28 Stars Total | No Sub-Constellations
  %% Focus: Utility, Crafting, Thieving, Quality of Life
  %% ========================================
  
  subgraph CRAFT["🗡️ CRAFT CONSTELLATION (Green/Thief)"]
    direction TB
    
    %% === BASE STARS (Yellow - Prerequisites) ===
    C_BASE1("Fleet Phantom
(Max: 40 pts, 8 stages)
Base Star")
    
    C_BASE2("Steadfast Enchantment
(Max: 50 pts, 10 stages)
Base Star")
    
    C_BASE3("Rationer
(Max: 75 pts, 15 stages)
Base Star")
    
    %% === INDEPENDENT STARS (Can unlock immediately) ===
    C_IND1[["Steed's Blessing
(Max: 50 pts, 10 stages)
[Slot]"]]
    
    C_IND2[["Breakfall
(Max: 50 pts, 10 stages)
[Slot]"]]
    
    C_IND3("Soul Reservoir
(Max: 50 pts, 10 stages)")
    
    %% === LEFT BRANCH: Thieving/Stealth Path ===
    C_L1("Friends in Low Places
(Max: 50 pts)")
    
    C_L2[["Infamous
(Max: 50 pts)
[Slot] → Passive (U45)"]]
    
    C_L3("Fleet Phantom
(Max: 40 pts, 8 stages)")
    
    C_L4[["Cutpurse's Art
(Max: 50 pts, 10 stages)
[Slot] → Passive (U45)"]]
    
    C_L5("Shadowstrike
(Max: 50 pts, 10 stages)")
    
    %% === CENTER BRANCH: Crafting Path ===
    C_C1("Inspiration Boost
(Max: 45 pts, 9 stages)")
    
    C_C2[["Meticulous Disassembly
(Max: 50 pts, 10 stages)
[Slot] → Passive (U45)"]]
    
    C_C3("Master Gatherer
(Max: 75 pts, 15 stages)")
    
    C_C4[["Plentiful Harvest
(Max: 50 pts, 10 stages)
[Slot] → Passive (U45)"]]
    
    C_C5[["Treasure Hunter
(Max: 50 pts, 10 stages)
[Slot] → Passive (U45)"]]
    
    %% === RIGHT BRANCH: Quality of Life Path ===
    C_R1[["Gilded Fingers
(Max: 50 pts, 10 stages)
[Slot]"]]
    
    C_R2("Haggler
(Max: 50 pts, 10 stages)")
    
    C_R3[["Liquid Efficiency
(Max: 50 pts, 10 stages)
[Slot] → Passive (U45)"]]
    
    C_R4[["Homemaker
(Max: 50 pts, 10 stages)
[Slot] → Passive (U45)"]]
    
    C_R5[["Professional Upkeep
(Max: 50 pts)
[Slot] → Passive (U45)"]]
    
    C_R6[["Gifted Rider
(Max: 100 pts, 20 stages)
[Slot]"]]
    
    C_R7[["War Mount
(Max: 120 pts)
[Slot]"]]
    
    %% === CRAFT TREE PREREQUISITES ===
    C_BASE1 -->|"Min 8 pts"| C_L1
    C_L1 --> C_L2
    C_L1 --> C_L3
    C_L3 --> C_L4
    C_L3 --> C_L5
    
    C_BASE2 -->|"Min 10 pts"| C_C1
    C_C1 --> C_C2
    C_BASE2 --> C_C3
    C_C3 --> C_C4
    C_C3 --> C_C5
    
    C_BASE3 -->|"Min 15 pts"| C_R1
    C_R1 --> C_R2
    C_BASE3 --> C_R3
    C_R3 --> C_R4
    C_R4 --> C_R5
    C_BASE3 --> C_R6
    C_R6 --> C_R7
    
    %% === STYLING: CRAFT TREE ===
    style C_BASE1 fill:#ffff99,stroke:#333,stroke-width:3px
    style C_BASE2 fill:#ffff99,stroke:#333,stroke-width:3px
    style C_BASE3 fill:#ffff99,stroke:#333,stroke-width:3px
    
    style C_IND1 fill:#99ff99,stroke:#2d662d,stroke-width:2px
    style C_IND2 fill:#99ff99,stroke:#2d662d,stroke-width:2px
    style C_IND3 fill:#ccffcc,stroke:#2d662d,stroke-width:1.5px
    
    style C_L1 fill:#ccffcc,stroke:#2d662d,stroke-width:1.5px
    style C_L2 fill:#ccffcc,stroke:#2d662d,stroke-width:1.5px
    style C_L3 fill:#ccffcc,stroke:#2d662d,stroke-width:1.5px
    style C_L4 fill:#99ff99,stroke:#2d662d,stroke-width:2px
    style C_L5 fill:#ccffcc,stroke:#2d662d,stroke-width:1.5px
    
    style C_C1 fill:#ccffcc,stroke:#2d662d,stroke-width:1.5px
    style C_C2 fill:#99ff99,stroke:#2d662d,stroke-width:2px
    style C_C3 fill:#ccffcc,stroke:#2d662d,stroke-width:1.5px
    style C_C4 fill:#99ff99,stroke:#2d662d,stroke-width:2px
    style C_C5 fill:#99ff99,stroke:#2d662d,stroke-width:2px
    
    style C_R1 fill:#99ff99,stroke:#2d662d,stroke-width:2px
    style C_R2 fill:#ccffcc,stroke:#2d662d,stroke-width:1.5px
    style C_R3 fill:#99ff99,stroke:#2d662d,stroke-width:2px
    style C_R4 fill:#99ff99,stroke:#2d662d,stroke-width:2px
    style C_R5 fill:#99ff99,stroke:#2d662d,stroke-width:2px
    style C_R6 fill:#99ff99,stroke:#2d662d,stroke-width:2px
    style C_R7 fill:#99ff99,stroke:#2d662d,stroke-width:2px
  end
  
  %% ========================================
  %% WARFARE CONSTELLATION (BLUE TREE)
  %% 46 Stars Total + 3 Sub-Constellations
  %% Focus: Damage, Healing, Defense
  %% ========================================
  
  subgraph WARFARE["🔮 WARFARE CONSTELLATION (Blue/Mage)"]
    direction TB
    
    %% === BASE STARS (Yellow - Prerequisites) ===
    W_BASE1("Eldritch Insight
(Max: 50 pts, 10 stages)
Base Star")
    
    W_BASE2("Tireless Discipline
(Max: 50 pts, 10 stages)
Base Star")
    
    W_BASE3("Siphoning Spells
(Max: 50 pts, 10 stages)
Base Star")
    
    %% === INDEPENDENT STARS ===
    W_IND1[["Deadly Aim
(Max: 50 pts, 10 stages)
[Slot]"]]
    
    W_IND2[["Master-at-Arms
(Max: 50 pts, 10 stages)
[Slot]"]]
    
    W_IND3[["Thaumaturge
(Max: 50 pts, 10 stages)
[Slot]"]]
    
    %% === SUB-CONSTELLATION PORTALS (Purple) ===
    W_PORTAL1{{"Mastered Curation
Sub-Constellation
(Healing/Support)"}}
    
    W_PORTAL2{{"Staving Death
Sub-Constellation
(Defense/Mitigation)"}}
    
    W_PORTAL3{{"Extended Might
Sub-Constellation
(Offense/Penetration)"}}
    
    %% === LEFT BRANCH: Healing Path ===
    W_L1("Blessed
(Max: 50 pts, 10 stages)")
    
    W_L2[["Rejuvenating Boon
(Max: 50 pts)
[Slot]"]]
    
    W_L3("Quick Recovery
(Max: 50 pts, 10 stages)")
    
    %% === CENTER BRANCH: Core Combat ===
    W_C1("Fighting Finesse
(Max: 50 pts, 10 stages)")
    
    W_C2[["Ironclad
(Max: 50 pts, 10 stages)
[Slot]"]]
    
    W_C3("Hardy
(Max: 50 pts, 10 stages)")
    
    W_C4("Elemental Aegis
(Max: 50 pts, 10 stages)")
    
    %% === RIGHT BRANCH: Damage Path ===
    W_R1("Piercing
(Max: 50 pts, 10 stages)")
    
    W_R2[["Deadly Aim
(Max: 50 pts, 10 stages)
[Slot]"]]
    
    W_R3("Backstabber
(Max: 50 pts, 10 stages)")
    
    W_R4[["Biting Aura
(Max: 50 pts, 10 stages)
[Slot]"]]
    
    %% === WARFARE PREREQUISITES ===
    W_BASE1 -->|"Min 10 pts"| W_L1
    W_L1 -->|"Min 10 pts"| W_PORTAL1
    W_L1 --> W_L2
    W_L1 --> W_L3
    
    W_BASE2 -->|"Min 10 pts"| W_C1
    W_C1 --> W_C2
    W_BASE2 -->|"Min 10 pts"| W_PORTAL2
    W_BASE2 --> W_C3
    W_C3 --> W_C4
    
    W_BASE3 -->|"Min 10 pts"| W_R1
    W_R1 -->|"Min 10 pts"| W_PORTAL3
    W_R1 --> W_R2
    W_R1 --> W_R3
    W_R3 --> W_R4
    
    %% === STYLING: WARFARE TREE ===
    style W_BASE1 fill:#ffff99,stroke:#333,stroke-width:3px
    style W_BASE2 fill:#ffff99,stroke:#333,stroke-width:3px
    style W_BASE3 fill:#ffff99,stroke:#333,stroke-width:3px
    
    style W_IND1 fill:#99ccff,stroke:#1a4d7a,stroke-width:2px
    style W_IND2 fill:#99ccff,stroke:#1a4d7a,stroke-width:2px
    style W_IND3 fill:#99ccff,stroke:#1a4d7a,stroke-width:2px
    
    style W_PORTAL1 fill:#cc99ff,stroke:#4d1a7a,stroke-width:3px
    style W_PORTAL2 fill:#cc99ff,stroke:#4d1a7a,stroke-width:3px
    style W_PORTAL3 fill:#cc99ff,stroke:#4d1a7a,stroke-width:3px
    
    style W_L1 fill:#cce6ff,stroke:#1a4d7a,stroke-width:1.5px
    style W_L2 fill:#99ccff,stroke:#1a4d7a,stroke-width:2px
    style W_L3 fill:#cce6ff,stroke:#1a4d7a,stroke-width:1.5px
    
    style W_C1 fill:#cce6ff,stroke:#1a4d7a,stroke-width:1.5px
    style W_C2 fill:#99ccff,stroke:#1a4d7a,stroke-width:2px
    style W_C3 fill:#cce6ff,stroke:#1a4d7a,stroke-width:1.5px
    style W_C4 fill:#cce6ff,stroke:#1a4d7a,stroke-width:1.5px
    
    style W_R1 fill:#cce6ff,stroke:#1a4d7a,stroke-width:1.5px
    style W_R2 fill:#99ccff,stroke:#1a4d7a,stroke-width:2px
    style W_R3 fill:#cce6ff,stroke:#1a4d7a,stroke-width:1.5px
    style W_R4 fill:#99ccff,stroke:#1a4d7a,stroke-width:2px
  end
  
  %% === SUB-CONSTELLATION: MASTERED CURATION ===
  subgraph MASTERED_CURATION["⚕️ MASTERED CURATION (Warfare Sub)"]
    direction LR
    
    MC_ENTRY("Blessed
Entry Point
(Min 10 pts)")
    
    MC1[["Enlivening Overflow
(Max: 50 pts, 10 stages)
[Slot]"]]
    
    MC2("Spirit Mastery
(Max: 50 pts, 10 stages)")
    
    MC3[["Salvation
(Max: 75 pts)
[Slot]"]]
    
    MC4("Radiating Regen
(Max: 50 pts, 10 stages)")
    
    MC_ENTRY --> MC1
    MC_ENTRY --> MC2
    MC2 --> MC3
    MC2 --> MC4
    
    style MC_ENTRY fill:#ffff99,stroke:#333,stroke-width:2px
    style MC1 fill:#d9b3ff,stroke:#4d1a7a,stroke-width:2px
    style MC2 fill:#e6ccff,stroke:#4d1a7a,stroke-width:1.5px
    style MC3 fill:#d9b3ff,stroke:#4d1a7a,stroke-width:2px
    style MC4 fill:#e6ccff,stroke:#4d1a7a,stroke-width:1.5px
  end
  
  %% === SUB-CONSTELLATION: STAVING DEATH ===
  subgraph STAVING_DEATH["🛡️ STAVING DEATH (Warfare Sub)"]
    direction LR
    
    SD_ENTRY("Tireless Discipline
Entry Point
(Min 10 pts)")
    
    SD1[["Bastion
(Max: 50 pts, 10 stages)
[Slot]"]]
    
    SD2("Bulwark
(Max: 50 pts, 10 stages)")
    
    SD3[["Bulwark
(Max: 50 pts, 10 stages)
[Slot]"]]
    
    SD4("Fortified
(Max: 50 pts, 10 stages)")
    
    SD_ENTRY --> SD1
    SD_ENTRY --> SD2
    SD2 --> SD3
    SD2 --> SD4
    
    style SD_ENTRY fill:#ffff99,stroke:#333,stroke-width:2px
    style SD1 fill:#d9b3ff,stroke:#4d1a7a,stroke-width:2px
    style SD2 fill:#e6ccff,stroke:#4d1a7a,stroke-width:1.5px
    style SD3 fill:#d9b3ff,stroke:#4d1a7a,stroke-width:2px
    style SD4 fill:#e6ccff,stroke:#4d1a7a,stroke-width:1.5px
  end
  
  %% === SUB-CONSTELLATION: EXTENDED MIGHT ===
  subgraph EXTENDED_MIGHT["⚔️ EXTENDED MIGHT (Warfare Sub)"]
    direction LR
    
    EM_ENTRY("Piercing
Entry Point
(Min 10 pts)")
    
    EM1[["Wrathful Strikes
(Max: 50 pts, 10 stages)
[Slot]"]]
    
    EM2("Critical Precision
(Max: 50 pts, 10 stages)")
    
    EM3[["Exploiter
(Max: 50 pts, 10 stages)
[Slot]"]]
    
    EM4("Focused Might
(Max: 50 pts, 10 stages)")
    
    EM5[["Deadly Precision
(Max: 75 pts)
[Slot]"]]
    
    EM_ENTRY --> EM1
    EM_ENTRY --> EM2
    EM2 --> EM3
    EM2 --> EM4
    EM4 --> EM5
    
    style EM_ENTRY fill:#ffff99,stroke:#333,stroke-width:2px
    style EM1 fill:#d9b3ff,stroke:#4d1a7a,stroke-width:2px
    style EM2 fill:#e6ccff,stroke:#4d1a7a,stroke-width:1.5px
    style EM3 fill:#d9b3ff,stroke:#4d1a7a,stroke-width:2px
    style EM4 fill:#e6ccff,stroke:#4d1a7a,stroke-width:1.5px
    style EM5 fill:#d9b3ff,stroke:#4d1a7a,stroke-width:2px
  end
  
  %% ========================================
  %% FITNESS CONSTELLATION (RED TREE)
  %% 25 Stars Total + 3 Sub-Constellations
  %% Focus: Health, Defense, Resources
  %% ========================================
  
  subgraph FITNESS["⚔️ FITNESS CONSTELLATION (Red/Warrior)"]
    direction TB
    
    %% === BASE STARS (Yellow - Prerequisites) ===
    F_BASE1("Boundless Vitality
(Max: 50 pts, 10 stages)
Base Star")
    
    F_BASE2("Fortified
(Max: 50 pts, 10 stages)
Base Star")
    
    F_BASE3("Rejuvenation
(Max: 50 pts, 10 stages)
Base Star")
    
    %% === INDEPENDENT STARS ===
    F_IND1[["Siphoning Spells
(Max: 50 pts, 10 stages)
[Slot]"]]
    
    F_IND2[["Strategic Reserve
(Max: 50 pts, 10 stages)
[Slot]"]]
    
    F_IND3[["Sustained by Suffering
(Max: 50 pts, 10 stages)
[Slot]"]]
    
    %% === SUB-CONSTELLATION PORTALS (Purple) ===
    F_PORTAL1{{"Survivor's Spite
Sub-Constellation
(Damage Mitigation)"}}
    
    F_PORTAL2{{"Wind Chaser
Sub-Constellation
(Movement Speed)"}}
    
    F_PORTAL3{{"Walking Fortress
Sub-Constellation
(Blocking/Tanking)"}}
    
    %% === LEFT BRANCH: Recovery Path ===
    F_L1("Tumbling
(Max: 50 pts, 10 stages)")
    
    F_L2[["Rolling Rhapsody
(Max: 50 pts, 10 stages)
[Slot]"]]
    
    F_L3("Hero's Vigor
(Max: 50 pts, 10 stages)")
    
    %% === CENTER BRANCH: Resistance Path ===
    F_C1("Fortified
(Max: 50 pts, 10 stages)")
    
    F_C2[["Defiance
(Max: 50 pts)
[Slot]"]]
    
    F_C3("Slippery
(Max: 50 pts, 10 stages)")
    
    %% === RIGHT BRANCH: Sprint/Movement Path ===
    F_R1("Celerity
(Max: 50 pts, 10 stages)")
    
    F_R2[["Hasty
(Max: 50 pts, 10 stages)
[Slot]"]]
    
    F_R3("Sprint Racer
(Max: 50 pts, 10 stages)")
    
    %% === FITNESS PREREQUISITES ===
    F_BASE1 -->|"Min 10 pts"| F_L1
    F_L1 -->|"Min 10 pts"| F_PORTAL1
    F_L1 --> F_L2
    F_L1 --> F_L3
    
    F_BASE2 -->|"Min 10 pts"| F_C1
    F_C1 -->|"Min 10 pts"| F_PORTAL3
    F_C1 --> F_C2
    F_C1 --> F_C3
    
    F_BASE3 -->|"Min 10 pts"| F_R1
    F_R1 -->|"Min 10 pts"| F_PORTAL2
    F_R1 --> F_R2
    F_R1 --> F_R3
    
    %% === STYLING: FITNESS TREE ===
    style F_BASE1 fill:#ffff99,stroke:#333,stroke-width:3px
    style F_BASE2 fill:#ffff99,stroke:#333,stroke-width:3px
    style F_BASE3 fill:#ffff99,stroke:#333,stroke-width:3px
    
    style F_IND1 fill:#ff9999,stroke:#7a1a1a,stroke-width:2px
    style F_IND2 fill:#ff9999,stroke:#7a1a1a,stroke-width:2px
    style F_IND3 fill:#ff9999,stroke:#7a1a1a,stroke-width:2px
    
    style F_PORTAL1 fill:#cc99ff,stroke:#4d1a7a,stroke-width:3px
    style F_PORTAL2 fill:#cc99ff,stroke:#4d1a7a,stroke-width:3px
    style F_PORTAL3 fill:#cc99ff,stroke:#4d1a7a,stroke-width:3px
    
    style F_L1 fill:#ffcccc,stroke:#7a1a1a,stroke-width:1.5px
    style F_L2 fill:#ff9999,stroke:#7a1a1a,stroke-width:2px
    style F_L3 fill:#ffcccc,stroke:#7a1a1a,stroke-width:1.5px
    
    style F_C1 fill:#ffcccc,stroke:#7a1a1a,stroke-width:1.5px
    style F_C2 fill:#ff9999,stroke:#7a1a1a,stroke-width:2px
    style F_C3 fill:#ffcccc,stroke:#7a1a1a,stroke-width:1.5px
    
    style F_R1 fill:#ffcccc,stroke:#7a1a1a,stroke-width:1.5px
    style F_R2 fill:#ff9999,stroke:#7a1a1a,stroke-width:2px
    style F_R3 fill:#ffcccc,stroke:#7a1a1a,stroke-width:1.5px
  end
  
  %% === SUB-CONSTELLATION: SURVIVOR'S SPITE ===
  subgraph SURVIVORS_SPITE["💀 SURVIVOR'S SPITE (Fitness Sub)"]
    direction LR
    
    SS_ENTRY("Tumbling
Entry Point
(Min 10 pts)")
    
    SS1[["Pain's Refuge
(Max: 50 pts, 10 stages)
[Slot]"]]
    
    SS2("Relentlessness
(Max: 50 pts, 10 stages)")
    
    SS3[["Bloody Renewal
(Max: 75 pts)
[Slot]"]]
    
    SS_ENTRY --> SS1
    SS_ENTRY --> SS2
    SS2 --> SS3
    
    style SS_ENTRY fill:#ffff99,stroke:#333,stroke-width:2px
    style SS1 fill:#ffb3b3,stroke:#7a1a1a,stroke-width:2px
    style SS2 fill:#ffcccc,stroke:#7a1a1a,stroke-width:1.5px
    style SS3 fill:#ffb3b3,stroke:#7a1a1a,stroke-width:2px
  end
  
  %% === SUB-CONSTELLATION: WIND CHASER ===
  subgraph WIND_CHASER["💨 WIND CHASER (Fitness Sub)"]
    direction LR
    
    WC_ENTRY("Celerity
Entry Point
(Min 10 pts)")
    
    WC1[["Hasty
(Max: 50 pts, 10 stages)
[Slot]"]]
    
    WC2("Celerity Boost
(Max: 50 pts, 10 stages)")
    
    WC3[["Piercing Gaze
(Max: 50 pts, 10 stages)
[Slot]"]]
    
    WC_ENTRY --> WC1
    WC_ENTRY --> WC2
    WC2 --> WC3
    
    style WC_ENTRY fill:#ffff99,stroke:#333,stroke-width:2px
    style WC1 fill:#ffb3b3,stroke:#7a1a1a,stroke-width:2px
    style WC2 fill:#ffcccc,stroke:#7a1a1a,stroke-width:1.5px
    style WC3 fill:#ffb3b3,stroke:#7a1a1a,stroke-width:2px
  end
  
  %% === SUB-CONSTELLATION: WALKING FORTRESS ===
  subgraph WALKING_FORTRESS["🏰 WALKING FORTRESS (Fitness Sub)"]
    direction LR
    
    WF_ENTRY("Fortified
Entry Point
(Min 10 pts)")
    
    WF1[["Bracing Anchor
(Max: 50 pts, 10 stages)
[Slot]"]]
    
    WF2("Duelist's Rebuff
(Max: 50 pts, 10 stages)")
    
    WF3[["Unassailable
(Max: 75 pts)
[Slot]"]]
    
    WF4("Stalwart Guard
(Max: 50 pts, 10 stages)")
    
    WF_ENTRY --> WF1
    WF_ENTRY --> WF2
    WF2 --> WF3
    WF2 --> WF4
    
    style WF_ENTRY fill:#ffff99,stroke:#333,stroke-width:2px
    style WF1 fill:#ffb3b3,stroke:#7a1a1a,stroke-width:2px
    style WF2 fill:#ffcccc,stroke:#7a1a1a,stroke-width:1.5px
    style WF3 fill:#ffb3b3,stroke:#7a1a1a,stroke-width:2px
    style WF4 fill:#ffcccc,stroke:#7a1a1a,stroke-width:1.5px
  end
  
  %% ========================================
  %% VISUAL LEGEND
  %% ========================================
  
  subgraph LEGEND["📋 LEGEND"]
    direction TB
    
    LEG_BASE("Base Star
Yellow/Required")
    LEG_PASSIVE("Passive Star
Always Active")
    LEG_SLOT[["Slottable Star
Must Equip [Slot]"]]
    LEG_PORTAL{{"Sub-Constellation
Purple Portal"}}
    LEG_IND[["Independent Star
No Prerequisites"]]
    
    style LEG_BASE fill:#ffff99,stroke:#333,stroke-width:3px
    style LEG_PASSIVE fill:#e6e6e6,stroke:#666,stroke-width:1.5px
    style LEG_SLOT fill:#b3d9ff,stroke:#1a4d7a,stroke-width:2px
    style LEG_PORTAL fill:#cc99ff,stroke:#4d1a7a,stroke-width:3px
    style LEG_IND fill:#99ffcc,stroke:#2d7a4d,stroke-width:2px
  end

  %% ========================================
  %% NOTES
  %% ========================================
  %% 
  %% KEY FEATURES:
  %% 1. Three main constellation subgraphs (Craft, Warfare, Fitness)
  %% 2. Six sub-constellation subgraphs for Warfare and Fitness
  %% 3. Edge labels show minimum point prerequisites
  %% 4. Multi-line node labels with max points clearly displayed
  %% 5. Visual distinction: Yellow (base), Constellation color (main), Purple (sub-constellations)
  %% 6. Square brackets indicate slottable nodes
  %% 7. Update 45 passive conversions noted in Craft tree
  %% 
  %% EXPANSION INSTRUCTIONS:
  %% - Add remaining stars following same naming pattern (C_XX, W_XX, F_XX)
  %% - Maintain consistent max point notation: (Max: XX pts, Y stages)
  %% - Add [Slot] marker for slottable stars
  %% - Use edge labels for prerequisites: -->|"Min X pts"|
  %% - Independent stars have no incoming edges
  %% - Sub-constellation portals connect via minimum 10 pt requirement
  %%
  %% ========================================
  ```