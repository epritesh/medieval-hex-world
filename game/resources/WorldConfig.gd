class_name WorldConfig
extends Resource

# The identifier `seed` shadows a global function name; suppress the warning intentionally.
@warning_ignore("shadowed_global_identifier")
@export var seed: int = 12345
@export var map_radius: int = 20

# Noise scales are frequencies for FastNoiseLite (smaller = smoother)
@export var biome_noise_scale: float = 0.08
@export var elevation_noise_scale: float = 0.05

# Thresholds [0..1]
@export_range(0.0, 1.0, 0.01) var water_threshold: float = 0.35
@export_range(0.0, 1.0, 0.01) var hill_threshold: float = 0.75
@export_range(0.0, 1.0, 0.01) var high_hill_threshold: float = 0.85

# Visual tuning
@export var elevation_scale: float = 0.6
