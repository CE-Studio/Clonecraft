@tool
extends VoxelGeneratorScript


var seeed:int
var biomeNoise := FastNoiseLite.new()
var riverNoise := FastNoiseLite.new()


var riverwater:int = 0


func setupSeed(newSeed:int) -> void:
	print("setup")
	seeed = newSeed
	biomeNoise.seed = seeed
	biomeNoise.fractal_type = FastNoiseLite.FRACTAL_NONE
	biomeNoise.noise_type = FastNoiseLite.TYPE_CELLULAR
	biomeNoise.cellular_return_type = FastNoiseLite.RETURN_CELL_VALUE
	biomeNoise.domain_warp_enabled = true
	biomeNoise.domain_warp_frequency = 0.018
	biomeNoise.domain_warp_fractal_lacunarity = 2.0
	biomeNoise.frequency = 0.001
	
	riverNoise.seed = seeed
	riverNoise.fractal_type = FastNoiseLite.FRACTAL_NONE
	riverNoise.noise_type = FastNoiseLite.TYPE_CELLULAR
	riverNoise.cellular_return_type = FastNoiseLite.RETURN_DISTANCE2_SUB
	riverNoise.domain_warp_enabled = true
	riverNoise.domain_warp_frequency = 0.018
	riverNoise.domain_warp_fractal_lacunarity = 2.0
	riverNoise.frequency = 0.001


func setupIDS() -> void:
	riverwater = BlockManager.blockIDlist["clonecraft:glass"]


func _generate_block(out_buffer: VoxelBuffer, origin_in_voxels: Vector3i, lod: int) -> void:
	var tool = out_buffer.get_voxel_tool()
	var size := out_buffer.get_size()
	for x in size.x:
		var rx := x + origin_in_voxels.x
		for y in size.y:
			var ry := y + origin_in_voxels.y
			for z in size.z:
				var rz := z + origin_in_voxels.z
				var nv := 0
				var h := 2
				var r := riverNoise.get_noise_2d(rx, rz)
				h = remap(
					clampf(r, -1, -0.985),
					-1, -0.985,
					-8, h
				)
				if ry <= h:
					var i = remap(biomeNoise.get_noise_2d(rx, rz), -1, 1, 0, 27)
					var v = roundi(i) + 2
					assert(v >= 2)
					nv = v
				elif ry <= 0:
					nv = riverwater
				tool.set_voxel(
					Vector3i(x, y, z),
					nv
				)
