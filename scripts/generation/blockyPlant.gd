class_name BlockyPlant
extends Resource


@export var layers:Array[BlockyPlantLayer]


func generate(seed:int) -> VoxelBuffer:
	var rng := RandomNumberGenerator.new()
	var outp:Array[Dictionary]
	rng.seed = seed
	for layer in layers:
		for i in rng.randi_range(layer.min_count, layer.max_count):
			outp.append(layer.generate(rng))
	print(outp)
	return VoxelBuffer.new()
