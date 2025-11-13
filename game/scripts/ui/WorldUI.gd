extends CanvasLayer

@onready var _panel: PanelContainer = $Panel
@onready var _radius: SpinBox = $Panel/Margin/VBox/RowRadius/Radius
@onready var _seed: LineEdit = $Panel/Margin/VBox/RowSeed/Seed
@onready var _water: SpinBox = $Panel/Margin/VBox/RowWater/Water
@onready var _hill: SpinBox = $Panel/Margin/VBox/RowHill/Hill
@onready var _high: SpinBox = $Panel/Margin/VBox/RowHigh/High
@onready var _escale: SpinBox = $Panel/Margin/VBox/RowEScale/EScale
@onready var _regen_btn: Button = $Panel/Margin/VBox/Buttons/Regen
@onready var _rand_btn: Button = $Panel/Margin/VBox/Buttons/RandSeed

var main_ref: Node = null

func _ready() -> void:
	main_ref = get_tree().current_scene
	_panel.visible = true
	_populate_from_config()
	_regen_btn.pressed.connect(_on_regen)
	_rand_btn.pressed.connect(_on_rand_seed)

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

func _on_regen() -> void:
	_push_into_config()
	if main_ref != null and main_ref.has_method("regenerate_world"):
		main_ref.regenerate_world()

func _on_rand_seed() -> void:
	_seed.text = str(randi() % 1000000)
