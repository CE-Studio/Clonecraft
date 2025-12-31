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


func setup_seed(new_seed:int) -> void:
	seed = new_seed
	noise.seed = seed
	noise2.seed = seed
	noise.noise_type = FastNoise2.TYPE_CELLULAR
	noise.cellular_return_type = FastNoise2.CELLULAR_RETURN_INDEX_0_MUL_1
	noise.update_generator()
	noise2.update_generator()
	var cave_func := caves.get_main_function()
	var n := cave_func.find_node_by_name("carve0")
	cave_func.get_node_param(n, 0).seed = seed
	assert(cave_func.get_node_param(n, 0).seed == seed, "setting failed")
	n = cave_func.find_node_by_name("carve1")
	cave_func.get_node_param(n, 0).seed = seed + 1
	caves.compile()


func setup_ids() -> void:
	air = BlockManager.block_id_list["clonecraft:air"]
	grass = BlockManager.block_id_list["clonecraft:grassBlock"]
	dirt = BlockManager.block_id_list["clonecraft:dirt"]
	stone = BlockManager.block_id_list["clonecraft:stone"]
	sand = BlockManager.block_id_list["clonecraft:sand"]
	clay = BlockManager.block_id_list["clonecraft:clay"]


func set_sup_buf(x:int, y:int, z:int, val:int, sup_buf:VoxelBuffer, pos:Vector3i, global := true) -> void:
	if global:
		x = (x) - pos.x
		y = (y + MARGIN) - pos.y
		z = (z) - pos.z
	sup_buf.set_voxel(val, x, y, z)


func get_sup_buf(x:int, y:int, z:int, sup_buf:VoxelBuffer, pos:Vector3i, bounds:Vector3i, global := true) -> int:
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
	return sup_buf.get_voxel(x, y, z)


func gen_solid(x:int, y:int, z:int, sup_buf, pos, bounds) -> int:
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
			if get_sup_buf(x, y + 5, z, sup_buf, pos, bounds) == 0:
				if noise.get_noise_3d_single(Vector3(x, y, z) * 3) < 0.3:
					pending = clay
				else:
					pending = sand
			else:
				pending = stone
		else:
			if get_sup_buf(x, y + 1, z, sup_buf, pos, bounds) == 0:
				pending = grass
			elif get_sup_buf(x, y + 5, z, sup_buf, pos, bounds) == 0:
				pending = dirt
			else:
				pending = stone
	return pending


func iterate(sup_buf:VoxelBuffer, pos:Vector3i, bounds:Vector3i) -> void:
	for ix in bounds.x:
		for iz in bounds.z:
			for iy in bounds.y:
				var iiy = bounds.y - iy - 1
				set_sup_buf(ix, iiy, iz, gen_solid(ix + (pos.x), iiy + (pos.y - MARGIN), iz + (pos.z), sup_buf, pos, bounds), sup_buf, pos, false)


func blit(buf:VoxelBuffer, sup_buf:VoxelBuffer, bounds:Vector3i) -> void:
	buf.copy_channel_from_area(
		sup_buf,
		Vector3i(0, MARGIN, 0),
		Vector3i(bounds.x, bounds.y - MARGIN, bounds.z),
		Vector3i.ZERO,
		0
	)


func __generate_block(buf:VoxelBuffer, pos:Vector3i, _lod:int) -> void:
	var sup_buf := VoxelBuffer.new()
	var size := buf.get_size()
	sup_buf.create(size.x, size.y + (MARGIN * 2), size.z)
	var bounds := sup_buf.get_size()
	iterate(sup_buf, pos, bounds)
	blit(buf, sup_buf, bounds)


func _generate_block(buf:VoxelBuffer, rel_pos:Vector3i, lod:int) -> void:
	#var h:gen = gen.new()
	__generate_block(buf, rel_pos, lod)
	var cave_buf = VoxelBuffer.new()
	var buf_size = buf.get_size()
	cave_buf.create(buf_size.x, buf_size.y, buf_size.z)
	caves.generate_block(cave_buf, rel_pos, lod)
	var t := buf.get_voxel_tool()
	t.paste_masked(Vector3i.ZERO, cave_buf, 1 << VoxelBuffer.CHANNEL_TYPE, VoxelBuffer.CHANNEL_TYPE, 1)
