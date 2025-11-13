
# 🏰 Godot 4 + KayKit Medieval Hexagon Onboarding Instructions

## 🚀 Quick Start

### 1. Install
1. Go to [**godotengine.org/download**](https://godotengine.org/download).
2. Download **Godot 4.3 Stable** (standard edition, not .NET unless you need C#).
3. Unzip it somewhere convenient — no installation required.
DONE
---

### 2. Create a Project
1. Launch Godot → **New Project** → name it `HexRealm`.
2. Choose a folder, renderer: **Forward+ (Vulkan)**.
3. Click **Create & Edit** to open.
DONE
---

### 3. Import the KayKit Assets
1. Copy your `assets/fileformat` folder from the KayKit pack into `res://KayKit/`.
2. In the **FileSystem** panel, right-click → *Reimport* to generate previews.
3. You’ll see folders like `tiles`, `buildings`, and `decoration`.
DONE
---

### 4. Create a Scene
1. Add a **Node3D** → rename it `World`.
2. Add a **Camera3D** → set position `(10, 15, 10)` and rotation `(-45°, 45°, 0)`.
3. Add a **DirectionalLight3D** → rotation `(-60°, 0°, 0°)`.
PENDING
---

### 5. Build the Hex Grid
- Add a **GridMap** node under `World`.
- In the **MeshLibrary** tab, click **New Library** → drag a hex-tile model into it.
- Paint tiles in the 3D view using the GridMap tool.

> 💡 You can later script procedural tile placement with GDScript.

---

### 6. Add Buildings & Nature
Drag KayKit buildings or trees (`.glb` or `.fbx`) into your scene. Position them to decorate your world.

---

### 7. Add Camera Controls

Attach this script to your `Camera3D` node:

```gdscript
extends Camera3D

@export var orbit_speed := 0.3
@export var zoom_speed := 2.0

var distance := 20.0

func _unhandled_input(event):
    if event is InputEventMouseMotion and event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
        rotate_y(-event.relative.x * orbit_speed * 0.01)
        rotate_x(-event.relative.y * orbit_speed * 0.01)
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            distance -= zoom_speed
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            distance += zoom_speed
    distance = clamp(distance, 5, 50)
    translate_local(Vector3(0, 0, distance - transform.origin.z))
```

**Usage:** Right-click to orbit, scroll to zoom.

---

### 8. Run & Test
Press **F5** to run the scene. You should see your 3D world rendered smoothly.

If performance dips:
- Disable VSync in Project Settings.
- Turn off SSAO or Glow.
- Use FXAA instead of MSAA.

---

### 9. Next Fun Steps
- Add click selection with `RayCast3D`.
- Randomize terrain heights for variation.
- Implement a build mode (click to place buildings).
- Add ambient music and skybox for atmosphere.

---

## 💡 System Tips (Windows)
- Works perfectly on Intel Iris/Arc GPUs.
- Update your Intel graphics drivers for best Vulkan support.
- Turn off MSAA if you see frame drops.
- Enable multithreaded rendering: **Project Settings → Rendering → Threading → Model: Multithreaded.**

---

### 🎯 Summary
✅ Lightweight and instant setup  
✅ Perfect match for KayKit low-poly style  
✅ Great performance on your ThinkPad X1 Carbon  
✅ Encourages fast, creative prototyping

---

Enjoy building your cozy hex kingdom in **Godot 4**! 🏰💫
