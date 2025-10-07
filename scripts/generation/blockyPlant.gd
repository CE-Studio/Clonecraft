class_name BlockyPlant
extends BaseStructure


@export var layers:Array[BlockyPlantLayer]


func generate(seed:int) -> VoxelBuffer:
	var rng := RandomNumberGenerator.new()
	var outp:Array[Dictionary]
	rng.seed = seed
	for layer in layers:
		for i in rng.randi_range(layer.min_count, layer.max_count):
			outp.append(layer.generate(rng))
	var size := Vector2i.ZERO
	for i in outp:
		size = size.max(Vector2i(
			i[&"size"].x + absi(i[&"drift"].x),
			i[&"size"].y + absi(i[&"drift"].y),
		))
	var buf := VoxelBuffer.new()
	buf.create(size.x, outp.size(), size.y)
	return buf
