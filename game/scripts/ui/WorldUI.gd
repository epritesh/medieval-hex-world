extends CanvasLayer

@onready var _panel: PanelContainer = $Panel
@onready var _radius: SpinBox = $Panel/Margin/VBox/RowRadius/Radius
@onready var _seed: LineEdit = $Panel/Margin/VBox/RowSeed/Seed
@onready var _water: SpinBox = $Panel/Margin/VBox/RowWater/Water
@onready var _hill: SpinBox = $Panel/Margin/VBox/RowHill/Hill
@onready var _high: SpinBox = $Panel/Margin/VBox/RowHigh/High
@onready var _escale: SpinBox = $Panel/Margin/VBox/RowEScale/EScale
@onready var _ambient: SpinBox = $Panel/Margin/VBox/RowAmbient/Ambient
@onready var _exposure: SpinBox = $Panel/Margin/VBox/RowExposure/Exposure
@onready var _var_rotate: CheckBox = $Panel/Margin/VBox/RowVariety/VarRotate
@onready var _var_tint: CheckBox = $Panel/Margin/VBox/RowVariety/VarTint
@onready var _var_strength: SpinBox = $Panel/Margin/VBox/RowVarStrength/VarStrength
@onready var _deco: CheckBox = $Panel/Margin/VBox/RowDecor/DecoToggle
@onready var _regen_btn: Button = $Panel/Margin/VBox/Buttons/Regen
@onready var _rand_btn: Button = $Panel/Margin/VBox/Buttons/RandSeed

var main_ref: Node = null

func _ready() -> void:
	main_ref = get_tree().current_scene
	_panel.visible = true
	_populate_from_config()
	_regen_btn.pressed.connect(_on_regen)
	_rand_btn.pressed.connect(_on_rand_seed)
	_ambient.value_changed.connect(_on_ambient_changed)
	_exposure.value_changed.connect(_on_exposure_changed)
	_var_rotate.toggled.connect(_on_variety_toggle)
	_var_tint.toggled.connect(_on_variety_toggle)
	_var_strength.value_changed.connect(_on_var_strength_changed)
	_deco.toggled.connect(_on_decorations_toggled)

func _get_cfg() -> Resource:
	if main_ref == null:
		return null
	var cfg: Resource = main_ref.world_config if main_ref.has_method("_ready") else null
	if cfg == null:
		cfg = load("res://resources/world_config.tres")
		if cfg != null:
			main_ref.world_config = cfg
	return cfg

func _populate_from_config() -> void:
	var cfg = _get_cfg()
	if cfg == null:
		return
	_radius.value = cfg.map_radius
	_seed.text = str(cfg.seed)
	_water.value = cfg.water_threshold
	_hill.value = cfg.hill_threshold
	_high.value = cfg.high_hill_threshold
	_escale.value = cfg.elevation_scale
	# Environment
	if main_ref != null:
		var env_node := main_ref.get_node_or_null("WorldEnvironment")
		if env_node != null and env_node.environment != null:
			_ambient.value = env_node.environment.ambient_light_energy
			_exposure.value = env_node.environment.tonemap_exposure
		# Variety
		_var_rotate.button_pressed = main_ref.enable_variety_rotation
		_var_tint.button_pressed = main_ref.enable_variety_tint
		_var_strength.value = float(main_ref.variety_tint_jitter)
		# Decorations
		_deco.button_pressed = bool(main_ref.decorations_enabled)

func _push_into_config() -> void:
	var cfg = _get_cfg()
	if cfg == null:
		return
	cfg.map_radius = int(_radius.value)
	cfg.seed = int(_seed.text.to_int())
	cfg.water_threshold = float(_water.value)
	cfg.hill_threshold = float(_hill.value)
	cfg.high_hill_threshold = float(_high.value)
	cfg.elevation_scale = float(_escale.value)
	# Push variety settings into Main
	if main_ref != null:
		main_ref.enable_variety_rotation = _var_rotate.button_pressed
		main_ref.enable_variety_tint = _var_tint.button_pressed
		main_ref.variety_tint_jitter = float(_var_strength.value)

func _on_regen() -> void:
	_push_into_config()
	if main_ref != null and main_ref.has_method("regenerate_world"):
		main_ref.regenerate_world()

func _on_rand_seed() -> void:
	_seed.text = str(randi() % 1000000)

func _on_ambient_changed(v: float) -> void:
	if main_ref == null:
		return
	var env_node := main_ref.get_node_or_null("WorldEnvironment")
	if env_node != null and env_node.environment != null:
		env_node.environment.ambient_light_energy = float(v)

func _on_exposure_changed(v: float) -> void:
	if main_ref == null:
		return
	var env_node := main_ref.get_node_or_null("WorldEnvironment")
	if env_node != null and env_node.environment != null:
		env_node.environment.tonemap_exposure = float(v)

func _on_variety_toggle(_pressed: bool) -> void:
	# Update main variety flags; takes effect on next regenerate
	if main_ref == null:
		return
	main_ref.enable_variety_rotation = _var_rotate.button_pressed
	main_ref.enable_variety_tint = _var_tint.button_pressed

func _on_var_strength_changed(v: float) -> void:
	if main_ref != null:
		main_ref.variety_tint_jitter = float(v)

func _on_decorations_toggled(pressed: bool) -> void:
	if main_ref == null:
		return
	# Update runtime flag and rebuild immediately to reflect change
	main_ref.decorations_enabled = pressed
	if main_ref.has_method("rebuild_decorations"):
		main_ref.rebuild_decorations()
