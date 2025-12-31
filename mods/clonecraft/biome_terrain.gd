@tool
extends VoxelGeneratorScript


var gen_seed:int
var biome_noise := FastNoiseLite.new()
var river_noise := FastNoiseLite.new()


var river_water:int = 0


func setup_seed(new_seed:int) -> void:
	print("setup")
	gen_seed = new_seed
	biome_noise.seed = gen_seed
	biome_noise.fractal_type = FastNoiseLite.FRACTAL_NONE
	biome_noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	biome_noise.cellular_return_type = FastNoiseLite.RETURN_CELL_VALUE
	biome_noise.domain_warp_enabled = true
	biome_noise.domain_warp_frequency = 0.018
	biome_noise.domain_warp_fractal_lacunarity = 2.0
	biome_noise.frequency = 0.001
	
	river_noise.seed = gen_seed
	river_noise.fractal_type = FastNoiseLite.FRACTAL_NONE
	river_noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	river_noise.cellular_return_type = FastNoiseLite.RETURN_DISTANCE2_SUB
	river_noise.domain_warp_enabled = true
	river_noise.domain_warp_frequency = 0.018
	river_noise.domain_warp_fractal_lacunarity = 2.0
	river_noise.frequency = 0.001


func setup_ids() -> void:
	river_water = BlockManager.block_id_list["clonecraft:glass"]


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
				var r := river_noise.get_noise_2d(rx, rz)
				h = int(remap(
					clampf(r, -1, -0.985),
					-1, -0.985,
					-8, h
				))
				if ry <= h:
					var i = remap(biome_noise.get_noise_2d(rx, rz), -1, 1, 0, 27)
					var v = roundi(i) + 2
					assert(v >= 2)
					nv = v
				elif ry <= 0:
					nv = river_water
				tool.set_voxel(
					Vector3i(x, y, z),
					nv
				)
