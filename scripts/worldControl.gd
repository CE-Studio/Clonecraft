extends Node3D
class_name WorldControl


static var packed_inv:PackedScene = preload("res://gui/Playerinv.tscn") 


static var seed:int
static var generator:VoxelGenerator
static var world_path:String
static var stream_type:String
static var instance:WorldControl
static var meta_stream:VoxelStream
static var local_username := "__localplayer__" : 
	set(value):
		pass
static var dirty_chunks:Array[Vector3i] = []
static var mutex := Mutex.new()


@export var dayLength:float
@export var daytime:float = 0
#TODO implement day/night ratio
@export var dayNightRatio:float:
	set(value):
		dayNightRatio = clampf(value, 0, 1)
@export var upperSkyColor:Gradient
@export var upperHorizonColor:Gradient
@export var lowerSkyColor:Gradient
@export var lowerHorizonColor:Gradient
@export var sunlightColor:Gradient
@export var moonlightColor:Gradient
@export var moonSunAndStarIntensity:Gradient
@export var processTime := true


@onready var sky:ProceduralSkyMaterial = $WorldEnvironment.environment.sky.sky_material


var _tool:VoxelToolTerrain
var _wait_aabb := AABB()
var _wait_rel := Vector3.ZERO
var waiting := false
var pausing := false
var tree:SceneTree
var _player:Player
var _terrain:VoxelTerrain
var stream:VoxelStream
var day_progress:float = 0
var inv_instance:Node


var _save_data := {
	"daytime": 0.0,
}


static func _reset() -> void:
	packed_inv = preload("res://gui/Playerinv.tscn") 
	seed = 0
	generator = null
	world_path = ""
	stream_type = ""
	instance = null
	meta_stream = null
	local_username = "__localplayer__"
	dirty_chunks = []


static func mark_dirty(pos:Vector3i) -> void:
	mutex.lock()
	if not dirty_chunks.has(pos):
		dirty_chunks.append(pos)
	mutex.unlock()


static func save_dirty_chunks() -> void:
	if is_instance_valid(instance):
		mutex.lock()
		for i in dirty_chunks:
			instance.save_meta_chunk(i)
		dirty_chunks = []
		mutex.unlock()


static func is_paused() -> bool:
	return instance.pausing or instance.waiting


# TODO redo this when adding multiplayer
static func get_player_list() -> Array[String]:
	return ["__localplayer__"]
	
	
static func get_player(player:String) -> Player:
	if player == "__localplayer__":
		return instance.get_node("player")
	else:
		assert(false, "Not yet implemented!")
		return null


func ray_check(_rel:Vector3) -> bool:
	var col:KinematicCollision3D = _player.move_and_collide(_wait_rel, true, 0.001, true)
	if col == null:
		return false
	return true


func wait_for_chunk() -> void:
	if _terrain.is_area_meshed(_wait_aabb):
		waiting = false


func start_wait(aabb:AABB, rel:Vector3) -> void:
	waiting = true
	get_tree().paused = true
	_wait_aabb = aabb
	_wait_rel = rel


func save_world():
	save_dirty_chunks()
	$"/root/Node3D/VoxelTerrain".save_modified_blocks()
	var j_save := JSON.stringify(_player.save(), "  ")
	if !DirAccess.dir_exists_absolute(world_path + "/playerdata/"):
		DirAccess.make_dir_absolute(world_path + "/playerdata/")
	# TODO un-hardcode this
	var player_save_path := world_path + "/playerdata/__localplayer__.json"
	var f := FileAccess.open(player_save_path, FileAccess.WRITE)
	f.store_string(j_save)
	f.close()
	_save_data["daytime"] = daytime
	f = FileAccess.open(world_path + "/worldData.json", FileAccess.WRITE)
	j_save = JSON.stringify(_save_data, "  ")
	f.store_string(j_save)
	f.close()
	_update_ccworld()


func _update_ccworld():
	var f := FileAccess.open(world_path + "/ccworld.json", FileAccess.READ)
	var dict:Dictionary = JSON.parse_string(f.get_as_text())
	f.close()
	dict["gameversion"] = SettingManager.VERSION
	var t := Time.get_datetime_dict_from_system()
	if t["hour"] > 12:
		t["hour"] -= 12
		t["ampm"] = "PM"
	else:
		t["ampm"] = "AM"
	dict["savetime"] = str(t["month"]) + "/" + str(t["day"]) + "/" + str(t["year"]) + " " + str(t["hour"]) + ":" + str(t["minute"]) + ":" + str(t["second"]) + " " + t["ampm"]
	f = FileAccess.open(world_path + "/ccworld.json", FileAccess.WRITE)
	var json_save = JSON.stringify(dict, "  ")
	f.store_string(json_save)
	f.close()


func pause_unpause() -> void:
	if SettingManager.is_idle():
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			pausing = false
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			save_world()
			pausing = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		pause_unpause()
	elif event.is_action_pressed("game_inventory"):
		open_inventory()


func open_inventory() -> void:
	if not is_instance_valid(inv_instance):
		inv_instance = packed_inv.instantiate()
		$Control/invlayer.add_child(inv_instance)


func _ready() -> void:
	instance = self
	tree = get_tree()
	tree.auto_accept_quit = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_player = $player
	_terrain = BlockManager.terrain
	_tool = BlockManager._tool
	match stream_type:
		"region":
			stream = VoxelStreamRegionFiles.new()
			var dim_path := ProjectSettings.globalize_path(world_path + "/dims/0/")
			if not DirAccess.dir_exists_absolute(dim_path):
				DirAccess.make_dir_recursive_absolute(dim_path)
			stream.directory = dim_path
			stream.save_generator_output = true
			$"/root/Node3D/VoxelTerrain".stream = stream
			meta_stream = VoxelStreamRegionFiles.new()
			var meta_path := ProjectSettings.globalize_path(world_path + "/entities/0/")
			if not DirAccess.dir_exists_absolute(meta_path):
				DirAccess.make_dir_recursive_absolute(meta_path)
			meta_stream.directory = meta_path
		"memory":
			stream = VoxelStreamMemory.new()
			meta_stream = VoxelStreamMemory.new()
			$"/root/Node3D/VoxelTerrain".stream = stream
		"sql":
			pass
	var player_save_path := world_path + "/playerdata/__localplayer__.json"
	if FileAccess.file_exists(player_save_path):
		var f := FileAccess.open(player_save_path, FileAccess.READ)
		var dict:Dictionary = JSON.parse_string(f.get_as_text())
		f.close()
		if _player.restore(dict):
			BlockManager.glog("WorldControl", "Loaded player inventory")
		else:
			BlockManager.glog("WorldControl", "Failed to load player inventory")
	if FileAccess.file_exists(world_path + "/worldData.json"):
		var f := FileAccess.open(world_path + "/worldData.json", FileAccess.READ)
		var dict:Dictionary = JSON.parse_string(f.get_as_text())
		f.close()
		_save_data.merge(dict, true)
	daytime = _save_data["daytime"]


func _process(_delta) -> void:
	if waiting:
		wait_for_chunk()
	tree.paused = pausing or waiting
	$Control/waitpanel.visible = waiting
	$Control/pausepanel.visible = pausing
	if not(tree.paused) && processTime:
		daytime += _delta
		if daytime >= dayLength:
			daytime -= dayLength
		day_progress = remap(daytime, 0, dayLength, 0, 1)
		_player.sun_angle = day_progress
		sky.sky_top_color = upperSkyColor.sample(day_progress)
		sky.sky_horizon_color = upperHorizonColor.sample(day_progress)
		sky.ground_bottom_color = lowerSkyColor.sample(day_progress)
		sky.ground_horizon_color = lowerHorizonColor.sample(day_progress)
		_player.sun.light_color = sunlightColor.sample(day_progress)
		_player.moon.light_color = moonlightColor.sample(day_progress)
		var intensities := moonSunAndStarIntensity.sample(day_progress)
		_player.sun.light_energy = intensities.r
		_player.moon.light_energy = intensities.g
		_player.star_mat.albedo_color.a = intensities.b


func _on_setting_button_pressed():
	SettingManager.spawnMenu()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_on_quit_desktop_button_pressed()


func _on_quit_desktop_button_pressed():
	save_world()
	get_tree().quit()


func spawn_falling_block(pos:Vector3) -> void:
	var i:FallingBlock = preload("res://components/fallingBlock.tscn").instantiate()
	i.position = pos + Vector3(0.5, 0.5, 0.5)
	add_child(i)


static func explode(pos:Vector3, range:float, power:int, drop := true, bias := Vector3.ZERO, replaceWith := &"clonecraft:air") -> bool:
	var didHit := false
	var tool := BlockManager._tool
	for i in power:
		var dir = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1))
		dir += bias
		var hit := tool.raycast(pos, dir, range)
		if hit != null:
			var info := BlockManager.get_block(hit.position)
			if (info.full_id != replaceWith) and (info.explosion_strength < randf_range(0, 10)):
				didHit = true
				BlockManager.set_block(hit.position, replaceWith, drop)
	SoundManager.play_sound_3D(&"clonecraft:explosion", pos)
	ParticleManager.spawn_gpu_effect(&"clonecraft:explosion", pos)
	return didHit


func _on_voxel_terrain_mesh_block_exited(pos: Vector3i) -> void:
	mutex.lock()
	if dirty_chunks.has(pos):
		dirty_chunks.erase(pos)
		mutex.unlock()
		var buf := VoxelBuffer.new()
		var s := meta_stream.get_block_size()
		buf.create(s.x, s.y, s.z)
		meta_stream.load_voxel_block(buf, pos, 0)
		var voxel_tool = buf.get_voxel_tool()
		var aabb := AABB(Vector3(pos) * s, s)
		$blockEntities._save(aabb, voxel_tool)
		meta_stream.save_voxel_block(buf, pos, 0)
	else:
		mutex.unlock()
		var s := meta_stream.get_block_size()
		var aabb := AABB(Vector3(pos) * s, s)
		$blockEntities._clear(aabb)


func save_meta_chunk(pos:Vector3i) -> void:
	var buf := VoxelBuffer.new()
	var s := meta_stream.get_block_size()
	buf.create(s.x, s.y, s.z)
	meta_stream.load_voxel_block(buf, pos, 0)
	var voxel_tool = buf.get_voxel_tool()
	var aabb := AABB(Vector3(pos) * s, s)
	$blockEntities._save_chunk(aabb, voxel_tool)
	meta_stream.save_voxel_block(buf, pos, 0)


func saveMetaChunkContainingBlock(pos:Vector3i) -> void:
	var p = (Vector3(pos) / 16).floor()
	save_meta_chunk(p)


func _on_voxel_terrain_mesh_block_entered(pos: Vector3i) -> void:
	if meta_stream == null:
		return
	var buf := VoxelBuffer.new()
	var s := meta_stream.get_block_size()
	buf.create(s.x, s.y, s.z)
	meta_stream.load_voxel_block(buf, pos, 0)
	var aabb := AABB(Vector3(pos) * s, s)
	$blockEntities._load(aabb, buf)


func _on_quit_menu_button_pressed() -> void:
	save_world()
	_reset()
	BlockManager._reset()
	CMDprocessor._reset()
	EntityManager._reset()
	SoundManager._reset()
	ParticleManager._reset()
	InventoryTabs._reset()
	tree.paused = false
	tree.change_scene_to_file("res://titlescreen/title.tscn")
