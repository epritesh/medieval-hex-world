extends Node3D

@export var world_config: WorldConfig
@export var map_radius: int = 8
@export var tile_size: float = 1.0
@export var pointy_top: bool = true
@export var tile_scene_path: String = "res://art-pack/Assets/gltf/tiles/base/hex_grass.gltf" # legacy/fallback
@export var grass_tile_path: String = "res://art-pack/Assets/gltf/tiles/base/hex_grass.gltf"
@export var hill_low_tile_path: String = "res://art-pack/Assets/gltf/tiles/base/hex_grass_sloped_low.gltf"
@export var hill_high_tile_path: String = "res://art-pack/Assets/gltf/tiles/base/hex_grass_sloped_high.gltf"
@export var water_tile_path: String = "res://art-pack/Assets/gltf/tiles/base/hex_water.gltf"
@export var selection_ring_color: Color = Color(1.0, 0.8, 0.2, 0.55)

var TileScene: PackedScene
var tiles: Dictionary = {} # Dictionary keyed by Vector2(q, r) -> Node3D
var selection_ring: MeshInstance3D
var selected_axial: Vector2 = Vector2.INF
var _tile_cache: Dictionary = {}
var noise: NoiseProvider

func _ready() -> void:
	# Load or assign WorldConfig
	if world_config == null:
		var cfg: Resource = load("res://resources/world_config.tres")
		if cfg != null:
			world_config = cfg as WorldConfig

	# Setup noise if we have config
	if world_config != null:
		noise = NoiseProvider.new()
		noise.setup(world_config.seed, world_config.biome_noise_scale, world_config.elevation_noise_scale)
		map_radius = world_config.map_radius

	# Legacy single-scene fallback for older code paths
	TileScene = load(tile_scene_path)

	_generate_hex_map(map_radius)
	_create_selection_ring()
	# Set camera clamp radius based on map size
	var cam := get_node_or_null("Camera3D")
	if cam and cam.has_method("set_clamp_radius"):
		var world_r := _approx_world_radius(map_radius)
		cam.set_clamp_radius(world_r)

	# Headless diagnostic: dump InputMap and exit for console runs
	if OS.has_feature("headless"):
		_debug_dump_input_map()
		get_tree().quit()

func _axial_to_world(q: float, r: float) -> Vector3:
	if pointy_top:
		# Pointy-top axial to world
		var x: float = tile_size * sqrt(3.0) * (q + r * 0.5)
		var z: float = tile_size * 1.5 * r
		return Vector3(x, 0.0, z)
	else:
		# Flat-top axial to world
		var x: float = tile_size * 1.5 * q
		var z: float = tile_size * sqrt(3.0) * (r + q * 0.5)
		return Vector3(x, 0.0, z)

func _generate_hex_map(radius: int) -> void:
	for q in range(-radius, radius + 1):
		var r1: int = maxi(-radius, -q - radius)
		var r2: int = mini(radius, -q + radius)
		for r in range(r1, r2 + 1):
			var tile_type: String = "grass"
			var height_y: float = 0.0
			if noise != null and world_config != null:
				var b: float = noise.get_biome_value(q, r)
				if b < world_config.water_threshold:
					tile_type = "water"
				else:
					var e: float = noise.get_elevation_value(q, r)
					height_y = _elevation_to_height(e)
					if e > world_config.high_hill_threshold:
						tile_type = "hill_high"
					elif e > world_config.hill_threshold:
						tile_type = "hill_low"

			var scene: PackedScene = _get_tile_scene(tile_type)
			var tile: Node = scene.instantiate()
			if tile is Node3D:
				var pos := _axial_to_world(q, r)
				pos.y = height_y
				var n3 := tile as Node3D
				n3.position = pos
				(tile as Node3D).set_meta("q", q)
				(tile as Node3D).set_meta("r", r)
				_apply_variety(n3, tile_type, q, r)
				tiles[Vector2(q, r)] = tile
				add_child(tile)
			else:
				push_warning("Tile scene root is not Node3D; skipping instance at %s,%s" % [q, r])

func _get_tile_scene(tile_type: String) -> PackedScene:
	if _tile_cache.has(tile_type):
		return _tile_cache[tile_type]
	var path: String = grass_tile_path
	if tile_type == "water":
		path = water_tile_path
	elif tile_type == "hill_low":
		path = hill_low_tile_path
	elif tile_type == "hill_high":
		path = hill_high_tile_path
	var ps: PackedScene = load(path)
	if ps == null:
		# Fallback to legacy TileScene if available
		ps = TileScene
	_tile_cache[tile_type] = ps
	return ps

func _debug_dump_input_map() -> void:
	var lines := []
	lines.append("[InputMap Dump]")
	var actions: Array = InputMap.get_actions()
	for a in actions:
		var evs: Array = InputMap.action_get_events(a)
		var names := []
		for e in evs:
			if e is InputEventKey:
				names.append("key:" + str((e as InputEventKey).keycode))
			elif e is InputEventMouseButton:
				names.append("mouse:" + str((e as InputEventMouseButton).button_index))
			else:
				names.append(e.get_class())
		lines.append(str(" - ", a, " => ", ", ".join(names)))
	# Write under project folder 'user/' so it is visible in workspace
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://user"))
	var f := FileAccess.open("res://user/inputmap_dump.txt", FileAccess.WRITE)
	if f:
		for ln in lines:
			f.store_line(str(ln))
		f.flush()
		f.close()

func _create_selection_ring() -> void:
	selection_ring = MeshInstance3D.new()
	var cyl: CylinderMesh = CylinderMesh.new()
	cyl.top_radius = tile_size * 0.95
	cyl.bottom_radius = tile_size * 0.95
	cyl.height = 0.05
	# Godot 4: CylinderMesh uses radial_segments (not subdivisions)
	cyl.radial_segments = 32
	selection_ring.mesh = cyl
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.albedo_color = selection_ring_color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_texture = null
	selection_ring.material_override = mat
	selection_ring.visible = false
	add_child(selection_ring)

func regenerate_world() -> void:
	# Clear existing tiles
	for key in tiles.keys():
		var n: Node = tiles[key]
		if is_instance_valid(n):
			n.queue_free()
	tiles.clear()
	_tile_cache.clear()

	# Re-seed noise
	if world_config != null:
		if noise == null:
			noise = NoiseProvider.new()
		noise.setup(world_config.seed, world_config.biome_noise_scale, world_config.elevation_noise_scale)
		map_radius = world_config.map_radius

	_generate_hex_map(map_radius)
	selection_ring.visible = false
	# Update camera clamp after regenerate
	var cam := get_node_or_null("Camera3D")
	if cam and cam.has_method("set_clamp_radius"):
		cam.set_clamp_radius(_approx_world_radius(map_radius))

func _approx_world_radius(r: int) -> float:
	# Conservative world radius in meters from origin to edge for given axial radius
	var extra := 0.5
	var rx := tile_size * sqrt(3.0) * (r + extra)
	var rz := tile_size * 1.5 * (r + extra)
	return max(rx, rz) + 5.0

func _elevation_to_height(e: float) -> float:
	# Map elevation noise [0..1] into a vertical offset.
	# Below hill_threshold -> 0, between hill and high_hill -> mid heights, above -> higher.
	if world_config == null:
		return 0.0
	var h: float = 0.0
	if e <= world_config.hill_threshold:
		h = 0.0
	elif e <= world_config.high_hill_threshold:
		var t: float = (e - world_config.hill_threshold) / max(0.0001, (world_config.high_hill_threshold - world_config.hill_threshold))
		h = world_config.elevation_scale * (0.25 + 0.25 * t) # 0.25..0.5
	else:
		var t2: float = (e - world_config.high_hill_threshold) / max(0.0001, (1.0 - world_config.high_hill_threshold))
		h = world_config.elevation_scale * (0.5 + 0.5 * t2) # 0.5..1.0
	return h

func _apply_variety(tile: Node3D, tile_type: String, q: int, r: int) -> void:
	# Random rotation in 60° steps and subtle per-instance tint for hills/grass.
	var rng := RandomNumberGenerator.new()
	var s: int = world_config.seed if world_config != null else 12345
	rng.seed = int( (int(s) * 73856093) ^ (q * 19349663) ^ (r * 83492791) ) & 0x7fffffff

	# Orientation variety (all non-water tiles)
	if tile_type != "water":
		var rot_steps := rng.randi_range(0, 5)
		tile.rotation.y = rot_steps * PI / 3.0

	# Color tint for hills to add visual variety
	if tile_type == "hill_low" or tile_type == "hill_high" or tile_type == "grass":
		var tint_strength := 0.9 + rng.randf() * 0.2 # 0.9 .. 1.1
		var tint := Color(tint_strength, tint_strength, tint_strength, 1.0)
		_tint_meshes_recursive(tile, tint)

func _tint_meshes_recursive(node: Node, tint: Color) -> void:
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		if mi.mesh != null:
			var sc := mi.mesh.get_surface_count()
			for i in range(sc):
				var base_mat: Material = mi.get_surface_override_material(i)
				if base_mat == null:
					base_mat = mi.mesh.surface_get_material(i)
				if base_mat != null:
					var dup := base_mat.duplicate()
					if dup is StandardMaterial3D:
						var sm := dup as StandardMaterial3D
						sm.albedo_color = sm.albedo_color * tint
						mi.set_surface_override_material(i, sm)
	for c in node.get_children():
		_tint_meshes_recursive(c, tint)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_select_tile_under_mouse((event as InputEventMouseButton).position)

func _select_tile_under_mouse(screen_pos: Vector2) -> void:
	var cam: Camera3D = get_viewport().get_camera_3d()
	if cam == null:
		return
	var origin: Vector3 = cam.project_ray_origin(screen_pos)
	var dir: Vector3 = cam.project_ray_normal(screen_pos)
	# Intersect with horizontal plane y=0
	if abs(dir.y) < 0.0001:
		return
	var t: float = -origin.y / dir.y
	if t < 0.0:
		return
	var hit: Vector3 = origin + dir * t
	var axial: Vector2 = _world_to_axial(hit)
	if tiles.has(axial):
		selected_axial = axial
		selection_ring.visible = true
		selection_ring.global_position = tiles[axial].global_position + Vector3(0, 0.025, 0)
	else:
		selection_ring.visible = false

func _world_to_axial(pos: Vector3) -> Vector2:
	# Convert world x,z to axial q,r then round.
	var x: float = pos.x
	var z: float = pos.z
	var q: float
	var r: float
	if pointy_top:
		q = (sqrt(3.0)/3.0 * x - 1.0/3.0 * z) / tile_size
		r = (2.0/3.0 * z) / tile_size
	else:
		q = (2.0/3.0 * x) / tile_size
		r = (-sqrt(3.0)/3.0 * x + sqrt(3.0)/3.0 * z) / tile_size
	return _hex_round(Vector2(q, r))

func _hex_round(frac_axial: Vector2) -> Vector2:
	# Convert axial to cube, round, then back.
	var q: float = frac_axial.x
	var r: float = frac_axial.y
	var x_c: float = q
	var z_c: float = r
	var y_c: float = -x_c - z_c
	var rx: float = round(x_c)
	var ry: float = round(y_c)
	var rz: float = round(z_c)
	var x_diff: float = abs(rx - x_c)
	var y_diff: float = abs(ry - y_c)
	var z_diff: float = abs(rz - z_c)
	if x_diff > y_diff and x_diff > z_diff:
		rx = -ry - rz
	elif y_diff > z_diff:
		ry = -rx - rz
	else:
		rz = -rx - ry
	return Vector2(int(rx), int(rz))
