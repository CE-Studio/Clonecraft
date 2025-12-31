class_name BlockyPlant
extends BaseStructure


@export var layers:Array[BlockyPlantLayer]


func generate(seed:int) -> VoxelBuffer:
	var rng := RandomNumberGenerator.new()
	var output:Array[Dictionary]
	rng.seed = seed
	for layer in layers:
		for i in rng.randi_range(layer.min_count, layer.max_count):
			output.append(layer.generate(rng))
	var size := Vector2i.ZERO
	for i in output:
		size = size.max(Vector2i(
			i[&"size"].x + (absi(i[&"drift"].x) * 2),
			i[&"size"].y + (absi(i[&"drift"].y) * 2),
		))
	var buf := VoxelBuffer.new()
	var center := Vector2i(
		ceili(size.x / 2.0),
		ceili(size.y / 2.0),
	)
	for y in output.size():
		var layer := output[y]
		var layer_pos := Vector2i(
			
		)
		for x in size.x:
			for z in size.y:
				var pos := Vector3i(
					x - center.x,
					y,
					z - center.y
				)
	buf.create(size.x, output.size(), size.y)
	return buf
