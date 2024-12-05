extends VoxelGeneratorScript

const MARGIN = 5
static var caves:VoxelGeneratorGraph = load("res://mods/clonecraft/caves.tres")
static var noise := FastNoise2.new()
static var noise2 := FastNoise2.new()
static var seed:int


static var air:int
static var grass:int
static var dirt:int
static var stone:int
static var sand:int
static var clay:int


func setupSeed(newSeed:int) -> void:
	seed = newSeed
	noise.seed = seed
	noise2.seed = seed
	noise.noise_type = FastNoise2.TYPE_CELLULAR
	noise.cellular_return_type = FastNoise2.CELLULAR_RETURN_INDEX_0_MUL_1
	noise.update_generator()
	noise2.update_generator()
	var cavefunc := caves.get_main_function()
	var n := cavefunc.find_node_by_name("carve0")
	cavefunc.get_node_param(n, 0).seed = seed
	assert(cavefunc.get_node_param(n, 0).seed == seed, "setting failed")
	n = cavefunc.find_node_by_name("carve1")
	cavefunc.get_node_param(n, 0).seed = seed + 1
	caves.compile()


func setupIDS() -> void:
	air = BlockManager.blockIDlist["clonecraft:air"]
	grass = BlockManager.blockIDlist["clonecraft:grassBlock"]
	dirt = BlockManager.blockIDlist["clonecraft:dirt"]
	stone = BlockManager.blockIDlist["clonecraft:stone"]
	sand = BlockManager.blockIDlist["clonecraft:sand"]
	clay = BlockManager.blockIDlist["clonecraft:clay"]


func setSupBuf(x:int, y:int, z:int, val:int, supBuf:VoxelBuffer, pos:Vector3i, global := true) -> void:
	if global:
		x = (x) - pos.x
		y = (y + MARGIN) - pos.y
		z = (z) - pos.z
	supBuf.set_voxel(val, x, y, z)


func getSupBuf(x:int, y:int, z:int, supBuf:VoxelBuffer, pos:Vector3i, bounds:Vector3i, global := true) -> int:
	if global:
		x = (x) - pos.x
		y = (y + MARGIN) - pos.y
		z = (z) - pos.z
	if x < 0:
		return 0
	if y < 0:
		return 0
	if z < 0:
		return 0
	if x > bounds.x - 1:
		return 0
	if y > bounds.y - 1:
		return 0
	if z > bounds.z - 1:
		return 0
	return supBuf.get_voxel(x, y, z)


func genSolid(x:int, y:int, z:int, supBuf, pos, bounds) -> int:
	var pending:int = air
	var smoothness = clampf((noise2.get_noise_2d_single(Vector2(x, z) * 0.4) * 2) - 1, 0, 1)
	var density = noise.get_noise_3d_single(Vector3(x, y, z) * 0.3) * 30
	var river = clampf(abs(noise.get_noise_2d_single(Vector2(
		x + noise2.get_noise_2d_single(Vector2(x, z)) * 5, 
		z + noise2.get_noise_2d_single(Vector2(x + 324425, z + 23480)) * 5
	) * 0.1) - 0.5), 0.005, 0.02) * 50
	density += ((noise.get_noise_3d_single(Vector3(x, y, z) * 3) * 10) - 5) * smoothness
	density += noise.get_noise_3d_single(Vector3(x, y, z) * 5) 
	if y < remap(river, 0.5, 1, 0, density):
		if river < 1:
			if getSupBuf(x, y + 5, z, supBuf, pos, bounds) == 0:
				if noise.get_noise_3d_single(Vector3(x, y, z) * 3) < 0.3:
					pending = clay
				else:
					pending = sand
			else:
				pending = stone
		else:
			if getSupBuf(x, y + 1, z, supBuf, pos, bounds) == 0:
				pending = grass
			elif getSupBuf(x, y + 5, z, supBuf, pos, bounds) == 0:
				pending = dirt
			else:
				pending = stone
	return pending


func iterate(supBuf:VoxelBuffer, pos:Vector3i, bounds:Vector3i) -> void:
	for ix in bounds.x:
		for iz in bounds.z:
			for iy in bounds.y:
				var iiy = bounds.y - iy - 1
				setSupBuf(ix, iiy, iz, genSolid(ix + (pos.x), iiy + (pos.y - MARGIN), iz + (pos.z), supBuf, pos, bounds), supBuf, pos, false)


func blit(buf:VoxelBuffer, supBuf:VoxelBuffer, bounds:Vector3i) -> void:
	buf.copy_channel_from_area(
		supBuf,
		Vector3i(0, MARGIN, 0),
		Vector3i(bounds.x, bounds.y - MARGIN, bounds.z),
		Vector3i.ZERO,
		0
	)


func __generate_block(buf:VoxelBuffer, pos:Vector3i, _lod:int) -> void:
	var supBuf := VoxelBuffer.new()
	var size := buf.get_size()
	supBuf.create(size.x, size.y + (MARGIN * 2), size.z)
	var bounds := supBuf.get_size()
	iterate(supBuf, pos, bounds)
	blit(buf, supBuf, bounds)


func _generate_block(buf:VoxelBuffer, rpos:Vector3i, lod:int) -> void:
	#var h:gen = gen.new()
	__generate_block(buf, rpos, lod)
	var cavebuf = VoxelBuffer.new()
	var bufsize = buf.get_size()
	cavebuf.create(bufsize.x, bufsize.y, bufsize.z)
	caves.generate_block(cavebuf, rpos, lod)
	var t := buf.get_voxel_tool()
	t.paste_masked(Vector3i.ZERO, cavebuf, 1 << VoxelBuffer.CHANNEL_TYPE, VoxelBuffer.CHANNEL_TYPE, 1)
