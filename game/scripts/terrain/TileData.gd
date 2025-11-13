extends Resource
class_name TileData

@export var q: int
@export var r: int
@export var biome_type: String = ""
@export var elevation: float = 0.0
@export var tile_type: String = "grass"

func is_water() -> bool:
	return tile_type == "water"

func is_hill() -> bool:
	return tile_type == "hill" or tile_type == "high_hill"
