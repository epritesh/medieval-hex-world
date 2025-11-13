extends Resource
class_name DecorationConfig

@export var enable_decorations: bool = true
# Map biome/type -> list of PackedScene resource paths
@export var biome_scenes: Dictionary = {
	"grass": [],
	"hill_low": [],
	"hill_high": []
}
# Map biome/type -> spawn chance per tile (0..1). For now 0 or 1 instance per tile.
@export var biome_density: Dictionary = {
	"grass": 0.15,
	"hill_low": 0.10,
	"hill_high": 0.08
}
# Random radial offset scale within tile (0..1) times tile_size*0.5
@export var offset_scale: float = 0.8
