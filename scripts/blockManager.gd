extends Node
class_name BlockManager

## Manages the setup of mods, voxels, and the world.

## The list of mods to load when the world starts.[br]
## Static
static var mods_to_load:Array
## The list of loaded mods. Populates automatically.[br]
## Static
static var mods:Array[Mod] = []
## The list of loaded voxels. Populates automatically as voxels are declared.[br]
## Static
static var block_list:Array[BlockInfo] = []
## A dictionary to translate between a voxel's string name and numerical ID.[br]
## Numerical IDs will vary from world to world. Do not hardcode them.
## Caching, however, is strongly encuraged.[br]
## Static
static var block_id_list:Dictionary[StringName, int] = {}
## The world's [VoxelBlockyLibrary].[br]
## Static
static var block_library := VoxelBlockyLibrary.new()
## The world's [VoxelTerrain].[br]
## Static
static var terrain:VoxelTerrain
## Counts the number of registered voxels.[br]
## Static
static var id_counter := 0
## Turns [code]true[/code] when the world is fully initalized.[br]
## Static
static var load_done := false
## A static refrence to the BlockManager singleton.[br]
## [code]null[/code] until the world scene loads.[br]
## You won't typically need to use this.[br]
## Static
static var instance:BlockManager

## A list of voxel positions to update this simulation tick.[br]
## You probably want to use [member pending_block_updates] instead.[br]
## Static
static var block_updates:Array[Vector3i] = []
## A list of voxel positions to update on the next simulation tick.[br]
## Static
static var pending_block_updates:Array[Vector3i] = []
## The time between ticks, in seconds.
## Static
static var TICK_LENGTH:float = 0.05


static var _tick_time:float = 0.0
static var _updates:Array[Callable] = []
static var _physics_updates:Array[Callable] = []
static var _input_list := []
static var _u_input_list := []
static var _adding_block := false
static var _tdisp:PackedScene = preload("res://scripts/helpers/tickDisplay.tscn")
static var _udisp:PackedScene = preload("res://scripts/helpers/updateDisplay.tscn")
static var _tool:VoxelToolTerrain
static var _newmodel:VoxelBlockyModel
static var _check_tile_entites := {}


static func _reset() -> void:
	mods_to_load = []
	mods = []
	block_list = []
	block_id_list = {}
	block_library = VoxelBlockyLibrary.new()
	terrain = null
	id_counter = 0
	load_done = false
	instance = null
	block_updates = []
	pending_block_updates = []
	TICK_LENGTH = 0.05
	_tick_time = 0.0
	_updates = []
	_physics_updates = []
	_input_list = []
	_u_input_list = []
	_adding_block = false
	_tdisp = preload("res://scripts/helpers/tickDisplay.tscn")
	_udisp = preload("res://scripts/helpers/updateDisplay.tscn")
	_tool = null
	_newmodel = null
	_check_tile_entites = {}


## Get the [BlockManager.BlockInfo] tied to a specific ID string.[br]
## Static
static func get_block_id(id:StringName) -> BlockInfo:
	return block_list[block_id_list[id]]


## Register a [Callable] to be called every simulation tick.[br]
## Static
static func add_update(c:Callable) -> void:
	_updates.append(c)


## Register a [Callable] to be called every physics tick.[br]
## Static
static func add_physics_update(c:Callable) -> void:
	_physics_updates.append(c)


static func _tick_block(pos:Vector3i, rawID:int) -> void:
	if ProjectSettings.get_setting("gameplay/debug/show_updates"):
		var disp:MeshInstance3D = _tdisp.instantiate()
		disp.position = (Vector3(pos.x, pos.y, pos.z) + Vector3(0.5, 0.5, 0.5))
		terrain.add_child(disp)

	var block:BlockInfo = block_list[rawID]
	if block.tickable:
		block.tick_callback.call(pos)


static func _tick_meta(pos:Vector3i, meta:Variant) -> void:
	pass


## Run all pending block updates.[br]
## Called automatically every simulation tick.[br]
## Static
static func run_block_updates() -> void:
	block_updates = pending_block_updates
	pending_block_updates = []
	for i in block_updates:
		if ProjectSettings.get_setting("gameplay/debug/show_updates"):
			var disp:MeshInstance3D = _udisp.instantiate()
			disp.position = (Vector3(i.x, i.y, i.z) + Vector3(0.5, 0.5, 0.5))
			terrain.add_child(disp)
		var bi := BlockManager.get_block(i)
		if bi.scripted:
			bi.block_script.call(i)


## The base class for representing information about a voxel.
class BlockInfo extends RefCounted:
	## The ID of the mod the voxel comes from.[br]
	## Identical to the first half of [member full_id].
	var mod_id:StringName
	## The ID of the voxel.[br]
	## Identical to the second half of [member full_id].
	var name_id:StringName
	## The full ID of the voxel, in the format of [code]mod_id:block_id[/code].
	var full_id:StringName
	## The human-readable name of the voxel.
	var name_readable:StringName
	## The [VoxelBlockyModel] of the voxel.[br]
	## Not to be confused with any kind of [Mesh].
	var block_model:VoxelBlockyModel
	## How hard the voxel is for the player to mine.
	var break_strength:float
	## How hard it is to destroy the voxel in an explosion.
	var expl_strength:float
	## If explosions or the player are completely unable to destroy the voxel.
	var unbreakable:bool
	## If the voxel has a custom script attached.
	var scripted:bool
	## The script attached to the voxel.[br]
	## Is empty if [member scripted] is [code]false[/code].[br]
	## Called only on block updates.
	var block_script:Callable
	## The kind of tool most effective at mining the voxel.
	var tool_class:StringName
	## If the voxel can be randomly ticked.
	var tickable := false
	## The script to be called if the voxel is randomly ticked.
	## Is empty if [member tickable] is [code]false[/code].[br]
	var tick_callback:Callable
	## The ID of the sound to be played when the voxel is stepped on.
	var step_sound:StringName
	## The ID of the sound to be played when the voxel is placed.
	var place_sound:StringName
	## The ID of the sound to be played when the voxel is borken.
	var break_sound:StringName
	## The ID of the item the voxel will drop when broken.
	var drop_item:StringName
	## The script used to determine dropped items, if DropItem is set to "script"[br]
	## Return an aray of ItemStacks
	var drop_script:Callable
	# TODO come up with and explain voxel properties
	## A list of various unique properties the voxel may have.[br]
	## The current options that have an effect are "air", "replacable", and "incompleteHitbox"
	var properties:Array[StringName]
	## How slippery the voxel is when being walked on. Lower is more slippery, higher is less.
	var traction:float = 1.0
	
	
	const AIR := &"air"
	const REPLACABLE := &"replacable"
	const INCOMPLETE_HITBOX := &"incompleteHitbox"
	

	func _init(
			fmod_id:StringName,
			fname_id:StringName,
			fname_readable:StringName,
			fblock_model:VoxelBlockyModel,
			fbreak_strength:float,
			fexpl_strength:float,
			funbreakable:bool,
			fscripted:bool,
			fscript:Callable,
			ftool_class:StringName,
			fstep_sound:StringName,
			fplace_sound:StringName,
			fbreak_sound:StringName,
			fdrop_item := &"*"):
		mod_id = fmod_id
		name_id = fname_id
		full_id = fmod_id + ":" + fname_id
		name_readable = fname_readable
		block_model = fblock_model
		break_strength = fbreak_strength
		expl_strength = fexpl_strength
		unbreakable = funbreakable
		scripted = fscripted
		if scripted:
			block_script = fscript
		tool_class = ftool_class
		step_sound = fstep_sound
		place_sound = fplace_sound
		break_sound = fbreak_sound
		drop_item = fdrop_item


	## Set the voxel to be able to be randomly ticked.
	func set_tickable(ftickcb:Callable) -> void:
		tickable = true
		tick_callback = ftickcb
		block_model.random_tickable = true
	
	
	func set_scripted(callable:Callable) -> void:
		scripted = true
		block_script = callable
		
	
	func set_drop_script(callable:Callable) -> void:
		drop_item = &"script"
		drop_script = callable


## Output a message to the debug log.[br]
## [color=red][b]YOU SHOULD USE THIS INSTEAD OF PRINT.[/b][/color][br]
## Static
@warning_ignore("SHADOWED_GLOBAL_IDENTIFIER")
static func log(id:String, message:String) -> String:
	var out:String = "[" + Time.get_datetime_string_from_system() + "] [Mod] [" + id + "] " + message
	print(out)
	if ProjectSettings.get_setting("gameplay/debug/log_to_chat"):
		Chat.pushText(out)
	return out


static func glog(id:String, message:String) -> String:
	var out:String = "[" + Time.get_datetime_string_from_system() + "] [" + id + "] " + message
	print(out)
	if ProjectSettings.get_setting("gameplay/debug/log_to_chat"):
		Chat.pushText(out)
	return out


## Begin registering a new voxel.[br]
## See [Voxdat], [method end_block_register] and [BlockManager.BlockInfo].[br]
## Static
static func start_block_register(block_id:StringName, type:Voxdat.vox) -> VoxelBlockyModel:
	assert(not(_adding_block), "You can only register one block at a time!")
	_adding_block = true
	id_counter += 1
	match type:
		Voxdat.vox.GEOMETRY_CUBE:
			_newmodel = VoxelBlockyModelCube.new()
			_newmodel.atlas_size_in_tiles = Vector2i(10, 10)
		Voxdat.vox.GEOMETRY_MESH:
			_newmodel = VoxelBlockyModelMesh.new()
		Voxdat.vox.GEOMETRY_NONE:
			_newmodel = VoxelBlockyModelEmpty.new()

	return(_newmodel)
	

## Finish registering a voxel.[br]
## See [method start_block_register] and [BlockManager.BlockInfo].[br]
## Static
static func end_block_register(blockInfo:BlockInfo) -> void:
	assert(_adding_block, "You need to call 'start_block_register' first!")
	_adding_block = false
	if block_id_list.has(blockInfo.full_id):
		block_list[block_id_list[blockInfo.full_id]] = blockInfo
	else:
		block_list.append(blockInfo)
		block_id_list[blockInfo.full_id] = block_list.size() - 1
	print(
		"[" + Time.get_datetime_string_from_system() + "] [BlockManager] Registered block '"
		+ blockInfo.full_id + "'"
	)


## Register a function to handle user inputs.[br]
## Analogous to [method Node._input][br]
## Static
static func register_input(callback:Callable) -> void:
	_input_list.append(callback)

## Register a function to handle unhandled user inputs.[br]
## Analogous to [method Node._unhandled_input][br]
## Static
static func register_unhandled_input(callback:Callable) -> void:
	_u_input_list.append(callback)


static func _setup_placeholders():
	var regpath := WorldControl.worldpath + "/setupData/IDregistry.json"
	if FileAccess.file_exists(regpath):
		var f = FileAccess.open(regpath, FileAccess.READ)
		var h = JSON.parse_string(f.get_as_text())
		f.close()
		var count:int = 0
		for i in h:
			count = maxi(count, h[i] + 1)
		block_list.resize(count)
		var mat:StandardMaterial3D = preload("res://mods/clonecraft/baseblocks.tres")
		var m := VoxelBlockyModelCube.new()
		var v = Vector2(9, 9)
		m.atlas_size_in_tiles = Vector2i(10, 10)
		m.tile_left   = v
		m.tile_right  = v
		m.tile_bottom = v
		m.tile_top    = v
		m.tile_back   = v
		m.tile_front  = v
		m.set_material_override(0, mat)
		for i:String in h:
			var j = i.split(":", false, 1)
			var bi = BlockInfo.new(
				j[0],
				j[1],
				"Missing block!",
				m,
				10,
				10,
				false,
				false,
				Callable(),
				&"pickaxe",
				"default",
				"default",
				"default"
			)
			block_list[h[i]] = bi
		var out:Dictionary[StringName, int]
		for i:String in h:
			out[StringName(i)] = roundi(h[i])
		block_id_list = out


# TODO finalize and document the loading order
## Initalize the block manager.[br]
## You probably don't want to call this.[br]
## Static
static func setup() -> void:
	var regpath := WorldControl.worldpath + "/setupData/"
	terrain = Statics.get_node("/root/Node3D/VoxelTerrain")
	_tool = terrain.get_voxel_tool()
	block_library.atlas_size = 10
	_setup_placeholders()
	var air_model = start_block_register(&"clonecraft:air", Voxdat.vox.GEOMETRY_NONE)
	var air_block := BlockInfo.new(
			"clonecraft",
			"air",
			"Air",
			air_model,
			0,
			0,
			true,
			false,
			Callable(),
			"shovel",
			"null",
			"null",
			"null",
			"null"
	)
	air_block.properties.append(&"air")
	air_block.properties.append(&"replaceable")
	air_block.properties.append(&"incompleteHitbox")
	end_block_register(air_block)
	var tile_entity_model = start_block_register(&"clonecraft:tileEntity", Voxdat.vox.GEOMETRY_NONE)
	var tile_entity_block := BlockInfo.new(
			"clonecraft",
			"tileEntity",
			"Tile Entity Parent [Internal use only!]",
			tile_entity_model,
			0,
			0,
			true,
			false,
			Callable(),
			"shovel",
			"null",
			"null",
			"null",
			"null"
	)
	tile_entity_block.properties.append(&"incompleteHitbox")
	end_block_register(tile_entity_block)

	Mod.refman()
	for i in mods_to_load:
		print(
			"[" + Time.get_datetime_string_from_system() +
			"] [BlockManager] Fetching script for mod '" + i + "'..."
		)
		mods.append(load("res://mods/" + i + "/" + i + ".gd").new())
	for i in mods:
		if i.get("MODID") == null:
			print(
				"[" + Time.get_datetime_string_from_system() +
				"] [BlockManager] One of your mods has no mod ID! It can still load," +
				"but this is bad practice. Register phase starting..."
			)
			if i.has_method("registerPhase"):
				i.registerPhase()
			print(
				"[" + Time.get_datetime_string_from_system() +
				"] [BlockManager] Register phase done!"
			)
		else:
			print(
				"[" + Time.get_datetime_string_from_system() +
				"] [BlockManager] Beginning register phase for mod '" + i.MODID + "'..."
			)
			if i.has_method("registerPhase"):
				i.registerPhase()
			print(
				"[" + Time.get_datetime_string_from_system() +
				"] [BlockManager] Register phase for '" + i.MODID + "' done!"
			)
	print(
		"[" + Time.get_datetime_string_from_system() +
		"] [BlockManager] Register phase completed for all mods!"
	)
	
	for i in block_list:
		block_library.add_model(i.block_model)
	block_library.bake()
	terrain.mesher.library = block_library
	
	#Write out the block registry to lock numerical block IDs
	if !DirAccess.dir_exists_absolute(regpath):
		DirAccess.make_dir_absolute(regpath)
	var f = FileAccess.open(regpath + "IDregistry.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(block_id_list, "  "))
	f.close()

	#Ensure every block has an item
	ItemManager.getReady()
	for i in block_list:
		ItemManager.simpleBlockItem(i)

	load_done = true


func _process(delta) -> void:
	if load_done and (not(WorldControl.isPaused())):
		BlockManager._tick_time += delta
		if BlockManager._tick_time >= BlockManager.TICK_LENGTH:
			BlockManager._tick_time -= BlockManager.TICK_LENGTH
			for i in _updates:
				i.call(delta)
			BlockManager.run_block_updates()
			WorldControl.instance._p.ticks()
		


func _physics_process(delta):
	for i in _physics_updates:
		i.call(delta)


func _input(event) -> void:
	for i in _input_list:
		i.call(event)


func _unhandled_input(event: InputEvent) -> void:
	for i in _u_input_list:
		i.call(event)


func _ready() -> void:
	instance = self


# TODO abstract away VoxelBlockyModel to pin the features
# TODO unit testing for abstractions ig??? feels like the right thing to do for compatibillity
## Quickly and easily create a simple voxel that has the same texture on all sides.[br]
## [param mod_id] is typically the ID of your mod, but can be anything if needed.[br]
## [param block_name] is the ID of your voxel.[br]
## [param readable_name] is the name of your voxel that is shown to the player.
## Supports translation keys.[br]
## [param texture_pos] is the UV position of the voxel's texture.[br]
## [param mat] is the [Material] to apply to the voxel. The supplied texture should be a
## 10x10 atlas.[br]
## [param break_strength] is how hard it is for the player to break the voxel.[br]
## [param explosion_strength] is how hard it is for an explosion to break the voxel.[br]
## [param tool] is the kind of tool that is most effective at breaking the voxel.[br]
## [param alpha_channel] see [member VoxelBlockyModel.transparency_index][br]
## Static
static func quick_uniform_block(
		mod_id:StringName,
		block_name:StringName,
		readable_name:String,
		texture_pos:Vector2,
		mat:Material,
		break_strength := 3.0,
		explosion_strength := 5.0,
		tool := &"tools:pickaxe",
		alpha_channel := 0) -> BlockInfo:
	var model = start_block_register(mod_id + block_name, Voxdat.vox.GEOMETRY_CUBE)
	model.set_mesh_collision_enabled(0, true)
	model.transparency_index = alpha_channel
	model.tile_left   = texture_pos
	model.tile_right  = texture_pos
	model.tile_bottom = texture_pos
	model.tile_top    = texture_pos
	model.tile_back   = texture_pos
	model.tile_front  = texture_pos
	model.set_material_override(0, mat)
	var bi = BlockManager.BlockInfo.new(
			mod_id,
			block_name,
			readable_name,
			model,
			break_strength,
			explosion_strength,
			false,
			false,
			Callable(),
			tool,
			"default",
			"default",
			"default"
	)
	end_block_register(bi)
	return(bi)


## Places a voxel at the specified position.
## [param pos] is the position.[br]
## [param block_id] is the id of the voxel you want to place (in [code]mod_id:block_id[/code] format).[br]
## [param drop] determines if the voxel already at the position will drop an item when replaced.[br]
## [param update] determines if the operation will send block updates to neighoring voxels.[br]
## [param force] forces the operation to replace any voxel, not just ones flagged as replaceable.[br]
## Returns [code]true[/code] if the operation succeeded.[br]
## Static
static func set_block(
		pos:Vector3i,
		block_id:StringName,
		drop := true,
		update := true,
		force := false,
		silky := false,
	) -> bool:
	var will_set := force

	var old_block:BlockInfo = block_list[_tool.get_voxel(pos)]
	if not(will_set):
		if old_block.properties.has(&"replaceable") or get_block_id(block_id).properties.has(&"air"):
			will_set = true

	if will_set:
		if silky:
			var item := ItemManager.ItemStack.new(old_block.full_id, 1)
			ItemManager.spawnWorldItem(item, Vector3(pos.x + 0.5, pos.y + 0.5, pos.z + 0.5))
		elif drop:
			var itemID := old_block.drop_item
			if itemID != &"null":
				var item:Array[ItemManager.ItemStack]
				if itemID == &"*":
					item = [ItemManager.ItemStack.new(old_block.full_id, 1)]
				elif itemID == &"script":
					item = old_block.drop_script.call()
				else:
					item = [ItemManager.ItemStack.new(itemID, 1)]
				for i in item:
					ItemManager.spawnWorldItem(i, Vector3(pos.x + 0.5, pos.y + 0.5, pos.z + 0.5))

		_tool.set_voxel(pos, block_id_list[block_id])

		if update:
			pending_block_updates.append(pos)
			pending_block_updates.append(pos + Vector3i.UP)
			pending_block_updates.append(pos + Vector3i.DOWN)
			pending_block_updates.append(pos + Vector3i.FORWARD)
			pending_block_updates.append(pos + Vector3i.BACK)
			pending_block_updates.append(pos + Vector3i.LEFT)
			pending_block_updates.append(pos + Vector3i.RIGHT)

	return will_set


## Gets the [BlockManager.BlockInfo] for the voxel at the specified position.[br]
## Static
static func get_block(pos:Vector3) -> BlockInfo:
	var npos = Vector3i(floor(pos.x), floor(pos.y), floor(pos.z))
	return block_list[_tool.get_voxel(npos)]
