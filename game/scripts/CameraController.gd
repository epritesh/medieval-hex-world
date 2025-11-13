extends Camera3D

@export var move_speed: float = 10.0
@export var sprint_multiplier: float = 2.0
@export var rotate_speed: float = 0.8
@export var zoom_speed: float = 20.0
@export var min_height: float = 2.0
@export var max_height: float = 60.0

var _yaw: float = 0.0
var _pitch: float = -0.5
var _debug_label: Label

func _ready() -> void:
	current = true
	rotation = Vector3(_pitch, _yaw, 0.0)
	_ensure_default_bindings()
	set_process(true)
	set_physics_process(true)
	_create_debug_overlay()
	print("[CameraController] Ready. Processing input...")

func _ensure_default_bindings() -> void:
	# Make sure WASD and Shift work out of the box
	_add_key_to_action("ui_up", KEY_W)
	_add_key_to_action("ui_down", KEY_S)
	_add_key_to_action("ui_left", KEY_A)
	_add_key_to_action("ui_right", KEY_D)
	# Also add arrow keys
	_add_key_to_action("ui_up", KEY_UP)
	_add_key_to_action("ui_down", KEY_DOWN)
	_add_key_to_action("ui_left", KEY_LEFT)
	_add_key_to_action("ui_right", KEY_RIGHT)
	_add_key_to_action("ui_accept", KEY_SHIFT)

func _add_key_to_action(action: String, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	# Avoid duplicates
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey and ev.keycode == keycode:
			return
	var e := InputEventKey.new()
	e.keycode = keycode
	e.physical_keycode = keycode
	InputMap.action_add_event(action, e)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		var mm := event as InputEventMouseMotion
		_yaw -= mm.relative.x * rotate_speed * 0.01
		_pitch -= mm.relative.y * rotate_speed * 0.01
		_pitch = clamp(_pitch, deg_to_rad(-85.0), deg_to_rad(5.0))
		rotation = Vector3(_pitch, _yaw, 0.0)
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_WHEEL_UP and mb.pressed:
			_translate_height(-zoom_speed * 0.1)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and mb.pressed:
			_translate_height(zoom_speed * 0.1)

func _process(delta: float) -> void:
	_update_debug(delta)
	_do_move(delta)

func _physics_process(delta: float) -> void:
	# Keep physics tick updating height clamp in case _process is throttled
	_translate_height(0.0)

func _do_move(delta: float) -> void:
	var sprinting := Input.is_action_pressed("ui_accept") or Input.is_key_pressed(KEY_SHIFT)
	var speed := move_speed * (sprint_multiplier if sprinting else 1.0)
	var input_vec := Vector2.ZERO
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): input_vec.x -= 1.0
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): input_vec.x += 1.0
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): input_vec.y -= 1.0
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): input_vec.y += 1.0
	if input_vec.length_squared() > 0.0:
		input_vec = input_vec.normalized()
		# Fallback: compute planar basis using yaw only to avoid pitch affecting forward vector length.
		var yaw_basis := Basis(Vector3.UP, _yaw)
		var right: Vector3 = yaw_basis.x
		var forward: Vector3 = -yaw_basis.z
		var delta_move: Vector3 = (right * input_vec.x + forward * input_vec.y) * speed * delta
		# Use global_position direct modification instead of translate (in case of unexpected physics/parent constraints)
		global_position += delta_move
		if _debug_label != null:
			_debug_label.text = _debug_label.text + " | moved=" + str(delta_move.length())
	_translate_height(0.0)

func _translate_height(delta_h: float) -> void:
	global_position.y = clamp(global_position.y + delta_h, min_height, max_height)

func _create_debug_overlay() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	_debug_label = Label.new()
	_debug_label.text = "[dbg]"
	_debug_label.position = Vector2(8, 8)
	_debug_label.theme_type_variation = "HeaderSmall"
	layer.add_child(_debug_label)

func _update_debug(delta: float) -> void:
	if _debug_label == null:
		return
	var keys := []
	if Input.is_key_pressed(KEY_W): keys.append("W")
	if Input.is_key_pressed(KEY_A): keys.append("A")
	if Input.is_key_pressed(KEY_S): keys.append("S")
	if Input.is_key_pressed(KEY_D): keys.append("D")
	if Input.is_key_pressed(KEY_UP): keys.append("Up")
	if Input.is_key_pressed(KEY_LEFT): keys.append("Left")
	if Input.is_key_pressed(KEY_DOWN): keys.append("Down")
	if Input.is_key_pressed(KEY_RIGHT): keys.append("Right")
	var txt := "cam (%.2f, %.2f, %.2f) | keys=[%s]" % [global_position.x, global_position.y, global_position.z, ", ".join(keys)]
	_debug_label.text = txt
	_debug_label.modulate = Color(1,1,0)
	if keys.size() > 0:
		print("[CameraController] Keys pressed: ", keys, " position=", global_position)
