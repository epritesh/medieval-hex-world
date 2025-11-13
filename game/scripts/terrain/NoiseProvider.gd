class_name NoiseProvider
extends RefCounted

var biome_noise: FastNoiseLite
var elev_noise: FastNoiseLite

func setup(rnd_seed:int, biome_scale:float, elev_scale:float) -> void:
	biome_noise = FastNoiseLite.new()
	biome_noise.seed = rnd_seed
	biome_noise.frequency = biome_scale

	elev_noise = FastNoiseLite.new()
	elev_noise.seed = rnd_seed + 101
	elev_noise.frequency = elev_scale

func get_biome_value(q:int, r:int) -> float:
	return biome_noise.get_noise_2d(float(q), float(r)) * 0.5 + 0.5

func get_elevation_value(q:int, r:int) -> float:
	return elev_noise.get_noise_2d(float(q), float(r)) * 0.5 + 0.5
