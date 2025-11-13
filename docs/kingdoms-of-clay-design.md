
# 🏰 GAME NAME PENDING TBD, currently = "Kingdom of Clay" — Game Design Document (GDD)

## 🎨 Overview
**Kingdoms of Clay** is a cozy 3D hex-based medieval builder created in **Godot 4** using the **KayKit Medieval Hexagon Pack**.  
Players shape the land, build villages, and nurture a thriving kingdom atop modular hex tiles.  
The tone is whimsical, peaceful, and deeply satisfying — every tile placement feels like painting with little worlds.

---

## 🧱 Core Concept
The player builds a kingdom tile-by-tile on a floating hex world.  
Each tile can represent **terrain**, **structure**, or **decoration**, and each has adjacency bonuses that influence resource production.

**Tagline:** _“A sandbox of clay and color, where kingdoms bloom one hex at a time.”_

---

## 🧩 Gameplay Loop

1. **Shape the Land**
   - Place base terrain tiles (grass, river, coast, cliff, mountain).
   - Terrain affects building placement and yield.

2. **Build the Kingdom**
   - Place buildings (houses, mills, markets, towers, castles).
   - Buildings consume and produce resources each turn.
   - Roads connect tiles and spread population growth.

3. **Decorate the Realm**
   - Place trees, rocks, and props to beautify the environment.
   - Higher beauty = higher happiness = faster growth.

4. **Collect & Grow**
   - Gain resources automatically over time.
   - Unlock new tile types and biomes as happiness and population rise.

5. **Optional Objectives**
   - Scenario goals: “Reach 300 population”, “Export 50 wood”, “Build on all floating islands.”
   - Endless sandbox mode for pure creativity.

---

## 💰 Resources & Economy

| Resource | Produced By | Consumed By | Affected By |
|-----------|--------------|-------------|--------------|
| 🍞 Food | Farms, Mills | Population | Fertile terrain (grass) |
| 🪵 Wood | Forest tiles, Lumbermills | Construction | Nearby trees |
| 🪨 Stone | Quarries | Walls, Towers | Mountain adjacency |
| 💰 Gold | Markets, Trade Routes | Upgrades | Population & roads |
| 😊 Happiness | Decorations, Taverns | Growth speed | Balanced resources |

Each tick (turn or time interval), production runs through adjacency and terrain modifiers.

---

## 🏗 Tile & Building Types

### Terrain
- **Grass Hex** — base tile for most buildings.
- **River Hex** — generates food & beauty; blocks heavy structures.
- **Road Hex** — connects structures; boosts trade.
- **Mountain Hex** — increases stone output; limits building.
- **Coast Hex** — allows docks and shipyards.

### Buildings
- **House** — increases population capacity.
- **Mill** — converts farms’ food to resources.
- **Market** — generates gold; links to roads.
- **Castle** — boosts nearby morale & production.
- **Shipyard** — produces trade ships; must border coast.
- **Tavern** — increases happiness.

### Decorations
- Trees, rocks, barrels, carts, fences, wells — pure aesthetic or small happiness bonuses.

---

## 🎮 Controls
- **Right Mouse:** Orbit camera.  
- **Mouse Wheel:** Zoom.  
- **Left Mouse:** Select/Place tiles or buildings.  
- **Middle Mouse Drag:** Pan view.  
- **UI:** Floating buttons for building menus.

---

## ⚙️ Systems & Implementation (Godot)

| System | Description |
|---------|--------------|
| **Grid System** | Based on `GridMap` for hex tiles. Each tile stores its type, height, and adjacency. |
| **Building Placement** | Instanced `Scenes` dropped on grid cells; validity check before placement. |
| **Resource Simulation** | Timer-driven global manager calculating production per tick. |
| **UI** | Minimal — diegetic icons (floating above buildings). |
| **Save System** | Simple JSON save/load of tile states and resources. |
| **Camera Control** | Orbit + zoom (already in onboarding guide). |

---

## 🌎 Biomes & Progression

Players unlock new biomes as they grow:
- **Grasslands → Forest → Snow → Desert → Highlands**  
- Each biome reuses the same KayKit tiles with alternate materials.

**Example progression:**
- Start on green plains.  
- Unlock snowy peaks (using alternate textures).  
- Eventually expand into floating isles.

---

## 🧠 Design Pillars

1. **Visual Joy** — The art is the reward. Players should feel good just looking at their creation.
2. **Gentle Depth** — Layers of strategy without stress.
3. **Creative Freedom** — No wrong moves; everything makes the world more alive.
4. **Expandability** — Systems (resources, trade, diplomacy) can layer in naturally over time.

---

## 🧭 Roadmap (Prototype → Alpha → Full)

| Phase | Goals |
|--------|--------|
| **Prototype (You Now)** | Basic hex placement, simple resources, UI test. |
| **Alpha** | Resource simulation, happiness, save/load, sound. |
| **Beta** | Biomes, events, trade, polish. |
| **Full Release** | Campaign goals, progression, music, achievements. |

---

## 🎯 Why It Works Perfectly with KayKit

- Uses **every folder** in the asset pack (tiles, nature, buildings, props).  
- Matches the **whimsical tone** of the low-poly art.  
- Runs smoothly on integrated GPUs.  
- The pack’s **color variants** (red/blue/green roofs) are perfect for population tiers or factions.  
- Expansion-ready: new biomes and units can slot in easily.

---

## 🌟 Final Thought
This project is art-driven by design — the visuals *lead* the gameplay.  
Your task as developer is to make the player feel the joy of “click → build → beauty.”  

_“Kingdoms of Clay” isn’t about conquering — it’s about caring for your creation._ 🏰💫
