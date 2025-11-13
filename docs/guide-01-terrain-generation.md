# Guide 01 – Terrain Generation (Hex Map)

> Objective: Produce a deterministic hex map with varied biomes & elevation using a seed. By the end you can regenerate maps and query tile data for later systems.

---
## Step 0: Concepts Recap
- **Axial Coordinates (q,r)**: Already used in `Main.gd`. Useful for direction vectors.
- **Cube Coordinates (x,y,z)**: Temporary conversion for rounding and distance.
- **Biome Layers**: Use noise to classify tiles (e.g., moisture vs temperature).
- **Elevation**: A separate noise sample; drives hill meshes or vertical offset.

---
## Step 1: Create a WorldConfig Resource
1. Create folder: `res://resources/`.
2. Right‑click → **New Resource** → **Script** derived from `Resource` named `WorldConfig.gd`.
3. Exports:
   - `seed: int = 12345`
   - `map_radius: int = 20`
   - `biome_noise_scale: float = 0.08`
   - `elevation_noise_scale: float = 0.05`
   - `water_threshold: float = 0.35`
   - `hill_threshold: float = 0.65`
   - `high_hill_threshold: float = 0.8`
4. Save an instance: Right‑click script → **New Resource** → save as `world_config.tres`.

---
## Step 2: Noise Provider
Create `scripts/terrain/NoiseProvider.gd`:
- Holds `FastNoiseLite` instances (biome & elevation).
- Initialize with seed from `WorldConfig`.
- Helper methods:
  - `get_biome_value(q,r) -> float`
  - `get_elevation_value(q,r) -> float`
Use axial → world or axial directly (feed q,r scaled).

Example snippet (insert into file):
```gdscript
var biome_noise := FastNoiseLite.new()
var elev_noise := FastNoiseLite.new()
func setup(seed:int, biome_scale:float, elev_scale:float):
    biome_noise.seed = seed
    biome_noise.frequency = biome_scale
    elev_noise.seed = seed + 101
    elev_noise.frequency = elev_scale
func get_biome_value(q:int, r:int) -> float:
    return biome_noise.get_noise_2d(q, r)*0.5 + 0.5
func get_elevation_value(q:int, r:int) -> float:
    return elev_noise.get_noise_2d(q, r)*0.5 + 0.5
```

---
## Step 3: Tile Data Structure
Make `scripts/terrain/TileData.gd` (`class_name TileData`):
- Properties: `q`, `r`, `biome_type: String`, `elevation: float`, `tile_type: String`.
- Utility: `is_water()`, `is_hill()` etc.
Keep an in‑memory dictionary on `Main` mapping axial → `TileData`.

---
## Step 4: Generation Flow
Update `Main.gd`:
1. Load `WorldConfig` resource.
2. Instantiate `NoiseProvider` and `setup(...)`.
3. In `_generate_hex_map` before instancing:
   - Sample biome & elevation.
   - Decide tile type:
     - `if biome < water_threshold: water`
     - `elif elevation > high_hill_threshold: high_hill`
     - `elif elevation > hill_threshold: hill`
     - else `grass`
   - Choose appropriate mesh path (e.g., water uses `hex_water.gltf`).
4. Store a `TileData` object.

Mesh selection approach:
```gdscript
var path := base_grass_path
if tile_type == "water":
    path = water_path
elif tile_type == "hill":
    path = hill_path
```
Load once per type (cache PackedScenes in a dictionary).

---
## Step 5: Elevation Application
Two simple methods:
1. **Vertical Offset**: `position.y = elevation * elevation_scale` (fast).
2. **Mesh Swap**: Use sloped/high variants (e.g. `hex_grass_sloped_low.gltf`).
Start with vertical offset, later refine with slope types based on neighbors.

Edge smoothing: For tiles near map border (distance to center > radius-2), push elevation toward water or lower.

---
## Step 6: Regeneration Button
Add a CanvasLayer UI:
- Button "Regenerate"; on pressed:
  - Increment `WorldConfig.seed += 1` (or randomize).
  - Clear children tiles & dictionaries.
  - Call generation again.
Ensure selection ring still works (recreate after clearing if needed).

---
## Step 7: Debug Overlay
Add `Label` listing:
- Seed
- Hovered axial
- Hovered tile type / elevation
Use `_process` + ray similar to selection but not clicking.

---
## Step 8: Validation & Performance
Checklist:
- [ ] Generation under 100ms for radius 30
- [ ] No duplicate tiles
- [ ] Water forms contiguous pools (optional flood fill pass)
- [ ] Memory stable (no leaked nodes after regeneration)

Profile: Use **Debugger → Monitors** & **RenderingStats**. If Node count high, convert stable types (grass) to `MultiMeshInstance3D` later.

---
## Step 9: Next Extensions
- Coast tiles: mark boundary between water & land.
- Moisture second noise → forest vs plains decoration.
- Height‑based fog (volumetric light) for depth.

---
## Quick Troubleshooting
| Symptom | Cause | Fix |
|---------|-------|-----|
| All tiles same type | Thresholds wrong | Log sampled values; adjust config |
| Seams / misaligned heights | Inconsistent axial ↔ world math | Recheck formula for pointy/flat |
| Slow generation | Too many loads per tile | Cache PackedScenes, reuse instances or MultiMesh |

---
## Checklist Summary
- [ ] Resource `WorldConfig.tres`
- [ ] `NoiseProvider` implemented
- [ ] `TileData` class
- [ ] Tile type assignment
- [ ] Mesh path caching
- [ ] Elevation offsets
- [ ] Regenerate button
- [ ] Debug overlay

Complete this guide before moving to **Guide 02 – Terrain Decoration**.
