extends VoxelGeneratorScript


@export var thenoise:ZN_FastNoiseLite
@export var noisearray:Array[ZN_FastNoiseLite]


func cave1(out_buffer:VoxelBuffer, x, y, z, xi, yi, zi):
	var n = thenoise.get_noise_3d(x, y, z)
	var nu = thenoise.get_noise_3d(x, y + 8, z)
	var nd = thenoise.get_noise_3d(x, y - 8, z)
	var nl = thenoise.get_noise_3d(x + 8, y, z)
	var nr = thenoise.get_noise_3d(x - 8, y, z)
	var nf = thenoise.get_noise_3d(x, y, z + 8)
	var nb = thenoise.get_noise_3d(x, y, z - 8)
	if (
		(n > nu) and
		(n > nd) and
		(n > nl) and
		(n > nr) and
		(n > nf) and
		(n > nb)
	):
		out_buffer.set_voxel(0, xi, yi, zi)
	else:
		out_buffer.set_voxel(1, xi, yi, zi)


func _generate_block(out_buffer:VoxelBuffer, origin_in_voxels:Vector3i, lod):
	var s := out_buffer.get_size()
	var x
	var y
	var z
	var noisepos = Vector3i(origin_in_voxels / 32)
	var cavepoints:Array = [
		[
			[0, 0, 0],
			[0, 0, 0],
			[0, 0, 0]
		],
		[
			[0, 0, 0],
			[0, 0, 0],
			[0, 0, 0]
		],
		[
			[0, 0, 0],
			[0, 0, 0],
			[0, 0, 0]
		]
	]
	if origin_in_voxels.y > -2:
		for xi in [-1, 0, 1]:
			for yi in [-1, 0, 1]:
				for zi in [-1, 0, 1]:
					cavepoints[xi][yi][zi] = Vector3(
						noisearray[0].get_noise_3d(
							noisepos.x + xi,
							noisepos.y + yi,
							noisepos.z + zi
						),
						noisearray[1].get_noise_3d(
							noisepos.x + xi,
							noisepos.y + yi,
							noisepos.z + zi
						),
						noisearray[2].get_noise_3d(
							noisepos.x + xi,
							noisepos.y + yi,
							noisepos.z + zi
						)
					)
	for xi in s.x:
		x = xi + origin_in_voxels.x
		for yi in s.y:
			y = yi + origin_in_voxels.y
			for zi in s.z:
				z = zi + origin_in_voxels.z
				if y < 0:
					cave1(out_buffer, x, y, z, xi, yi, zi)
				else:
					pass
