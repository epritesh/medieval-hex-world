
# 🏰 Kingdom of Clay — Game Design Document (GDD)

## 🎨 Overview
**Kingdom of Clay** is a cozy 3D hex-based medieval builder created in **Godot 4** using the **KayKit Medieval Hexagon Pack**.  
Players shape the land, build villages, and nurture a thriving kingdom atop modular hex tiles.  
The tone is whimsical, peaceful, and deeply satisfying — every tile placement feels like painting with little worlds.

---

## 🧱 Core Concept
The player builds a kingdom tile-by-tile on a floating hex world.  
Each tile can represent **terrain**, **structure**, or **decoration**, and each has adjacency bonuses that influence resource production.

**Tagline:** _“A sandbox of clay and color, where kingdoms bloom one hex at a time.”_

Note: Title is a working name and may change as the project evolves.

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

## 🎮 Controls (Current Prototype)
- Move: `W/A/S/D`
- Rise/Fall: `E` / `Q`
- Look: Hold Right Mouse Button and move mouse
- Zoom: Mouse Wheel (smooth FOV)
- Select Tile: Left Mouse Button
- UI: World generation panel (seed, thresholds, elevation, brightness/exposure, variety), Regenerate/Randomize Seed

---

## ⚙️ Systems & Implementation (Godot)

| System | Status & Description |
|---------|-----------------------|
| **Hex World Generation** | Implemented. Procedural axial hex grid using noise for biome/elevation; tile scenes instantiated as `Node3D` with deterministic seed. |
| **Water & Rim Shaping** | Implemented. Flood-fill style lake smoothing and rim softening toward water at map edges. |
| **Variety & Materials** | Implemented. Per-tile 60° rotations and subtle tinting; slight roughness boost to reduce specular aliasing. |
| **Lighting & AA** | Implemented. Tuned directional light + ambient; MSAA+FXAA configurable; camera near/far planes adjusted to reduce shimmer. |
| **World UI** | Implemented. Runtime controls for seed, radius, thresholds, elevation scale, ambient/exposure, variety toggles/strength; regenerate/randomize. Decorations toggle scaffolded. |
| **Decorations** | In progress (Milestone 2). `DecorationConfig` resource, per-biome density and scene lists, deterministic placement; UI toggle. |
| **Buildings & Economy** | Planned. Placement validity, resource simulation, and adjacency bonuses (see Gameplay Loop). |
| **Save System** | Planned. Minimal JSON of seed + deltas. |
| **Camera Control** | Implemented. Free-cam with RMB look, smooth zoom, optional map clamp. |

---

## 🌎 Biomes & Progression

Prototype scope focuses on Grass/Water/Hills. Future phases add Forest, Snow, Desert, and Highlands using alternate materials from the KayKit pack. Biomes expand with player growth and scenario goals.

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
| **Prototype (Current)** | Procedural hex world (grass/water/hills), flood-fill lakes, rim softening, free camera, selection ring, World UI (seed/radius/thresholds/elevation, ambient/exposure, variety), lighting/AA tuning. |
| **Alpha (Next)** | Decoration system (props per biome), save/load seed+config, basic building placement preview, initial resource loop. |
| **Beta** | Extended biomes, events, trade, polish and performance (MultiMesh), improved UI. |
| **Full Release** | Campaign scenarios, progression, audio pass, achievements. |

---

## 🎯 Why It Works Perfectly with KayKit

- Uses **every folder** in the asset pack (tiles, nature, buildings, props).  
- Matches the **whimsical tone** of the low-poly art.  
- Runs smoothly on integrated GPUs.  
- The pack’s **color variants** (red/blue/green roofs) are perfect for tiers or factions.  
- Expansion-ready: new biomes and units can slot in easily.

---

## 🌟 Final Thought
This project is art-driven by design — the visuals *lead* the gameplay.  
Your task as developer is to make the player feel the joy of “click → build → beauty.”  

_“Kingdom of Clay” isn’t about conquering — it’s about caring for your creation._ 🏰💫
