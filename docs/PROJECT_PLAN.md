# Medieval Hex World – Project Plan

> Living roadmap for building a stylized hex‑based medieval strategy / builder game in Godot 4.
>
> Use this file as the high‑level view. Detailed how‑to guides live beside it (`guide-01-terrain-generation.md`, etc.). Update checkboxes as you progress.

## Vision
A cozy low‑poly hex world where the player explores, gathers resources, builds medieval structures, and manages a small domain. Emphasis on readability, quick iteration, and moddability.

## Guiding Principles
- Hex readability > photorealism.
- Deterministic generation with a seed.
- Systems layered incrementally: terrain → selection → economy → AI.
- Keep data + logic decoupled (resource/data objects vs scene visuals).
- Performance first: profile early (use `MultiMesh`, object pooling).

## Milestones Overview
| # | Milestone | Goal | Est. Duration |
|---|-----------|------|---------------|
| 0 | Foundations & Onboarding | Project setup, base scene, camera, selection | 0.5–1 day |
| 1 | Terrain Generation Core | Procedural hex types (grass, water, hills) | 1–2 days |
| 2 | Terrain Decoration | Place nature props & biome variation | 1–2 days |
| 3 | Structures & Placement | Building placement, validation & removal | 2–3 days |
| 4 | Resource & Economy Loop | Produce/consume resources over time | 3–5 days |
| 5 | Unit / Agent System | Basic pathfinding & worker tasks | 4–7 days |
| 6 | UI & Feedback Layer | Panels, selection info, build menus | 2–4 days |
| 7 | Audio & Atmosphere | Ambient soundtrack, SFX, day/night | 1–2 days |
| 8 | Save/Load & Persistence | Serialize world, buildings, state | 2–3 days |
| 9 | Performance & Polish | Optimize draw calls, finalize art pass | 2–4 days |
| 10 | Packaging & Release Prep | Settings, build scripts, itch.io upload | 1–2 days |

## Detailed Milestones & Checklists

### Milestone 0 – Foundations & Onboarding ✅
- [x] Project created (Forward+ renderer)
- [x] Base scene (`Main.tscn`) with camera & light
- [x] Hex grid spawning script
- [x] Tile selection highlight ring
- [x] Basic input mapping review (actions + camera)
- [ ] Git repository initialized

### Milestone 1 – Terrain Generation Core (Current Focus)
Goal: Generate a hex map with seeded noise producing biome + elevation + water.
Checklist:
- [x] Introduce `WorldConfig` resource (seed, radius, biome weights)
- [x] Implement noise wrapper (`NoiseProvider.gd`) using `FastNoiseLite`
- [x] Assign tile types: grass / water / hill / high hill
- [x] Elevate hills (y offset + slope mesh swap)
- [ ] Flood fill lakes (ensure contiguous water areas)
- [ ] Edge shaping: soften map rim (fade to water or coast)
- [x] Deterministic generation from seed UI field
- [x] Regenerate button in world UI panel
Deliverables:
- Regenerated map differs per seed, stable per same seed.

### Milestone 2 – Terrain Decoration
Goal: Natural visuals for each biome.
Checklist:
- [ ] Decoration loader (config JSON/Resource) per biome
- [ ] Random prop placement with density & collision avoidance
- [ ] Simple pseudo‑random using hashed axial coordinate + seed
- [ ] Performance review (batching / `MultiMeshInstance3D` for trees)
- [ ] Toggle decorations (perf testing)

### Milestone 3 – Structures & Placement
Goal: Player can place and remove medieval buildings.
Checklist:
- [ ] Building data definitions (cost, footprint, category)
- [ ] Placement preview ghost with validity coloring
- [ ] Footprint collision check vs terrain type & existing structures
- [ ] Removal + refund rules
- [ ] Persistent storage of placed buildings

### Milestone 4 – Resource & Economy Loop
Goal: Time‑based production & consumption.
Checklist:
- [ ] Core resources (Wood, Stone, Food, Gold)
- [ ] Production component on buildings (rate / capacity / workers)
- [ ] Tick system (fixed timestep) vs frame
- [ ] Storage & UI inventory panel
- [ ] Balancing pass (spreadsheet or JSON tweaks)

### Milestone 5 – Unit / Agent System
Goal: Simple workers performing tasks.
Checklist:
- [ ] Pathfinding (grid axial → world A* or navigation mesh)
- [ ] Task queue: gather, deliver, construct
- [ ] Worker assignment logic
- [ ] Idle animations / states

### Milestone 6 – UI & Feedback Layer
Goal: Communicative interface.
Checklist:
- [ ] Selection info panel (tile type, elevation, held structure)
- [ ] Build menu (categories + hotkeys)
- [ ] Resource bar + production rate indicators
- [ ] Notifications / floating text events

### Milestone 7 – Audio & Atmosphere
Goal: Mood & immersion.
Checklist:
- [ ] Ambient loop(s) cross‑fade daytime/night
- [ ] SFX triggers (place building, select tile, resource tick)
- [ ] Basic dynamic sky (procedural/skybox swap)
- [ ] Time of day progression

### Milestone 8 – Save/Load & Persistence
Goal: Stable state across sessions.
Checklist:
- [ ] Serialize tile type + elevation + seed only (derivable) vs storing full mesh
- [ ] Serialize building list & worker states
- [ ] Versioning & migration (header with schema version)

### Milestone 9 – Performance & Polish
Goal: Stable FPS on mid hardware.
Checklist:
- [ ] Convert tiles to `MultiMeshInstance3D`
- [ ] Frustum & distance culling of decorations
- [ ] Profiler review (scripts & rendering)
- [ ] Replace debug materials with final palette / shaders

### Milestone 10 – Packaging & Release Prep
Goal: Public playable build.
Checklist:
- [ ] Export presets (Windows / Linux)
- [ ] Basic settings (resolution, full‑screen, audio volume)
- [ ] README & itch.io page assets (screenshots, GIFs)
- [ ] License & attribution (KayKit, Godot)

## Suggested Folder Structure (Future)
```
res://
  scripts/
    world/
    terrain/
    buildings/
    ui/
    systems/
  scenes/
  resources/
    world_config.tres
    buildings/
  data/
  docs/
```

## Risk & Mitigation Snapshot
| Risk | Mitigation |
|------|------------|
| Performance with many props | Early MultiMesh + culling |
| Complex save data | Store minimal seed + deltas |
| Balancing economy | External JSON + quick iteration |
| Pathfinding cost | Precompute regions, limit worker count |

## Next Immediate Actions

1. Flood fill lakes and rim shaping.
2. Add brightness slider + sun angle presets in `WorldUI`.
3. Add variety controls (toggle rotations/tint, strength slider).
4. Prepare decoration system scaffold (config + placement hooks).

---
Update this plan weekly; archive completed milestones.
