extends Camera3D

@export var speed: float = 20.0
@export var mouse_sensitivity: float = 0.15
@export var zoom_step_fov: float = 3.0
@export var min_fov: float = 30.0
@export var max_fov: float = 90.0
@export var use_dolly_zoom: bool = false
@export var dolly_step: float = 3.0
@export var zoom_smooth: bool = true
@export var zoom_lerp_speed: float = 10.0
@export var clamp_camera: bool = true
@export var clamp_radius: float = 100.0
@export var near_plane: float = 0.8
@export var far_plane: float = 500.0
@export var use_taa: bool = false
@export var msaa_samples: Viewport.MSAA = Viewport.MSAA_8X

func set_clamp_radius(r: float) -> void:
	clamp_radius = r

var yaw: float = 0.0
var pitch: float = -0.4
var _target_fov: float = 75.0

func _ready() -> void:
	current = true
	rotation = Vector3(pitch, yaw, 0.0)
	set_process(true)
	_target_fov = fov
	# Improve depth precision and reduce z-fighting shimmer
	near = near_plane
	far = far_plane
	# Configure anti-aliasing. Prefer MSAA to avoid temporal jitter while stationary
	var vp := get_viewport()
	if vp:
		vp.use_taa = use_taa
		vp.msaa_3d = msaa_samples
		# Configure screen-space AA: FXAA when not using TAA; disable otherwise (TAA is controlled by use_taa)
		if not use_taa:
			vp.screen_space_aa = Viewport.ScreenSpaceAA.SCREEN_SPACE_AA_FXAA
		else:
			vp.screen_space_aa = Viewport.ScreenSpaceAA.SCREEN_SPACE_AA_DISABLED

func _reset_camera() -> void:
	# Reset to a sensible vantage over origin
	yaw = 0.0
	pitch = -0.4
	rotation = Vector3(pitch, yaw, 0.0)
	global_position = Vector3(0, 18, 26)
	_target_fov = clamp(_target_fov, min_fov, max_fov)

func _process(delta: float) -> void:
	var dir := Vector3.ZERO
	# Action-based input only
	if Input.is_action_pressed("move_forward"):
		dir.z += 1.0
	if Input.is_action_pressed("move_back"):
		dir.z -= 1.0
	if Input.is_action_pressed("move_left"):
		dir.x -= 1.0
	if Input.is_action_pressed("move_right"):
		dir.x += 1.0
	if Input.is_action_pressed("move_down"):
		dir.y -= 1.0
	if Input.is_action_pressed("move_up"):
		dir.y += 1.0

	if dir != Vector3.ZERO:
		dir = dir.normalized()
		# Build basis from yaw only for horizontal movement
		var yaw_basis := Basis(Vector3.UP, yaw)
		var move_vec := yaw_basis.x * dir.x + (-yaw_basis.z) * dir.z + Vector3.UP * dir.y
		global_position += move_vec * speed * delta

	# Clamp XZ distance from origin if enabled
	if clamp_camera:
		var xz := Vector2(global_position.x, global_position.z)
		var d := xz.length()
		if d > clamp_radius:
			xz = xz.normalized() * clamp_radius
			global_position.x = xz.x
			global_position.z = xz.y

	# Smooth FOV zoom if enabled
	if zoom_smooth and not use_dolly_zoom:
		var t: float = clamp(zoom_lerp_speed * delta, 0.0, 1.0)
		if absf(_target_fov - fov) > 0.01:
			fov = lerp(fov, _target_fov, t)

func _input(event: InputEvent) -> void:
	var rotate_pressed := Input.is_action_pressed("cam_rotate")
	if event is InputEventMouseMotion and rotate_pressed:
		var mm := event as InputEventMouseMotion
		yaw -= mm.relative.x * mouse_sensitivity * 0.01
		pitch -= mm.relative.y * mouse_sensitivity * 0.01
		pitch = clamp(pitch, deg_to_rad(-85), deg_to_rad(5))
		rotation = Vector3(pitch, yaw, 0.0)
	elif event is InputEventMouseButton and event.pressed and (event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
		var scroll_dir: int = -1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1
		if use_dolly_zoom:
			# Move along forward vector
			var forward := -transform.basis.z
			global_position += forward * dolly_step * scroll_dir
		else:
			_target_fov = clamp((_target_fov if zoom_smooth else fov) + zoom_step_fov * scroll_dir, min_fov, max_fov)
			if not zoom_smooth:
				fov = _target_fov
	elif event is InputEventKey and event.pressed and not event.echo:
		var kev := event as InputEventKey
		if kev.keycode == KEY_R:
			_reset_camera()
