extends Node3D
class_name WorldControl


static var packedInv:PackedScene = preload("res://gui/Playerinv.tscn") 


static var seed:int
static var generator:VoxelGenerator
static var worldpath:String
static var streamtype:String
static var instance:WorldControl
static var metastream:VoxelStream
static var localUsername := "__localplayer__" : 
	set(value):
		pass
static var dirtyChunks:Array[Vector3i] = []
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
var _waitaabb := AABB()
var _waitrel := Vector3.ZERO
var waiting := false
var pausing := false
var tree:SceneTree
var _p:Player
var _terrain:VoxelTerrain
var stream:VoxelStream
var dayprogress:float = 0
var invInstance:Node


var _savedata := {
	"daytime": 0.0,
}


static func _reset() -> void:
	packedInv = preload("res://gui/Playerinv.tscn") 
	seed = 0
	generator = null
	worldpath = ""
	streamtype = ""
	instance = null
	metastream = null
	localUsername = "__localplayer__"
	dirtyChunks = []


static func markDirty(pos:Vector3i) -> void:
	mutex.lock()
	if not dirtyChunks.has(pos):
		dirtyChunks.append(pos)
	mutex.unlock()


static func saveDirtyChunks() -> void:
	if is_instance_valid(instance):
		mutex.lock()
		for i in dirtyChunks:
			instance.saveMetaChunk(i)
		dirtyChunks = []
		mutex.unlock()


static func isPaused() -> bool:
	return instance.pausing or instance.waiting


# TODO redo this when adding multiplayer
static func getPlayerList() -> Array[String]:
	return ["__localplayer__"]
	
	
static func getPlayer(player:String) -> Player:
	if player == "__localplayer__":
		return instance.get_node("player")
	else:
		assert(false, "Not yet implemented!")
		return null


func raycheck(_rel:Vector3) -> bool:
	var col:KinematicCollision3D = _p.move_and_collide(_waitrel, true, 0.001, true)
	if col == null:
		return false
	return true


func waitForChunk() -> void:
	if _terrain.is_area_meshed(_waitaabb):
		waiting = false


func startWait(aabb:AABB, rel:Vector3) -> void:
	waiting = true
	get_tree().paused = true
	_waitaabb = aabb
	_waitrel = rel


func saveworld():
	saveDirtyChunks()
	$"/root/Node3D/VoxelTerrain".save_modified_blocks()
	var jsave := JSON.stringify(_p.save(), "  ")
	if !DirAccess.dir_exists_absolute(worldpath + "/playerdata/"):
		DirAccess.make_dir_absolute(worldpath + "/playerdata/")
	# TODO un-hardcode this
	var playsavepath := worldpath + "/playerdata/__localplayer__.json"
	var f := FileAccess.open(playsavepath, FileAccess.WRITE)
	f.store_string(jsave)
	f.close()
	_savedata["daytime"] = daytime
	f = FileAccess.open(worldpath + "/worldData.json", FileAccess.WRITE)
	jsave = JSON.stringify(_savedata, "  ")
	f.store_string(jsave)
	f.close()
	_updateCCWorld()


func _updateCCWorld():
	var f := FileAccess.open(worldpath + "/ccworld.json", FileAccess.READ)
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
	f = FileAccess.open(worldpath + "/ccworld.json", FileAccess.WRITE)
	var jsave = JSON.stringify(dict, "  ")
	f.store_string(jsave)
	f.close()


func pauseUnpause() -> void:
	if SettingManager.isIdle():
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			pausing = false
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			saveworld()
			pausing = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		pauseUnpause()
	elif event.is_action_pressed("game_inventory"):
		openInventory()


func openInventory() -> void:
	if not is_instance_valid(invInstance):
		invInstance = packedInv.instantiate()
		$Control/invlayer.add_child(invInstance)


func _ready() -> void:
	instance = self
	tree = get_tree()
	tree.auto_accept_quit = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_p = $player
	_terrain = BlockManager.terrain
	_tool = BlockManager._tool
	match streamtype:
		"region":
			stream = VoxelStreamRegionFiles.new()
			var dimpath := ProjectSettings.globalize_path(worldpath + "/dims/0/")
			if not DirAccess.dir_exists_absolute(dimpath):
				DirAccess.make_dir_recursive_absolute(dimpath)
			stream.directory = dimpath
			stream.save_generator_output = true
			$"/root/Node3D/VoxelTerrain".stream = stream
			metastream = VoxelStreamRegionFiles.new()
			var metapath := ProjectSettings.globalize_path(worldpath + "/entities/0/")
			if not DirAccess.dir_exists_absolute(metapath):
				DirAccess.make_dir_recursive_absolute(metapath)
			metastream.directory = metapath
		"memory":
			stream = VoxelStreamMemory.new()
			metastream = VoxelStreamMemory.new()
			$"/root/Node3D/VoxelTerrain".stream = stream
		"sql":
			pass
	var playsavepath := worldpath + "/playerdata/__localplayer__.json"
	if FileAccess.file_exists(playsavepath):
		var f := FileAccess.open(playsavepath, FileAccess.READ)
		var dict:Dictionary = JSON.parse_string(f.get_as_text())
		f.close()
		if _p.restore(dict):
			BlockManager.glog("WorldControl", "Loaded player inventory")
		else:
			BlockManager.glog("WorldControl", "Failed to load player inventory")
	if FileAccess.file_exists(worldpath + "/worldData.json"):
		var f := FileAccess.open(worldpath + "/worldData.json", FileAccess.READ)
		var dict:Dictionary = JSON.parse_string(f.get_as_text())
		f.close()
		_savedata.merge(dict, true)
	daytime = _savedata["daytime"]


func _process(_delta) -> void:
	if waiting:
		waitForChunk()
	tree.paused = pausing or waiting
	$Control/waitpanel.visible = waiting
	$Control/pausepanel.visible = pausing
	if not(tree.paused) && processTime:
		daytime += _delta
		if daytime >= dayLength:
			daytime -= dayLength
		dayprogress = remap(daytime, 0, dayLength, 0, 1)
		_p.sunAngle = dayprogress
		sky.sky_top_color = upperSkyColor.sample(dayprogress)
		sky.sky_horizon_color = upperHorizonColor.sample(dayprogress)
		sky.ground_bottom_color = lowerSkyColor.sample(dayprogress)
		sky.ground_horizon_color = lowerHorizonColor.sample(dayprogress)
		_p.sun.light_color = sunlightColor.sample(dayprogress)
		_p.moon.light_color = moonlightColor.sample(dayprogress)
		var intensities := moonSunAndStarIntensity.sample(dayprogress)
		_p.sun.light_energy = intensities.r
		_p.moon.light_energy = intensities.g
		_p.starmat.albedo_color.a = intensities.b


func _on_setting_button_pressed():
	SettingManager.spawnMenu()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_on_quit_desktop_button_pressed()


func _on_quit_desktop_button_pressed():
	saveworld()
	get_tree().quit()


func spawnFallingBlock(pos:Vector3) -> void:
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
			if (info.full_id != replaceWith) and (info.expl_strength < randf_range(0, 10)):
				didHit = true
				BlockManager.set_block(hit.position, replaceWith, drop)
	SoundManager.playSound3D(&"clonecraft:explosion", pos)
	ParticleManager.spawnGPUeffect(&"clonecraft:explosion", pos)
	return didHit


func _on_voxel_terrain_mesh_block_exited(pos: Vector3i) -> void:
	mutex.lock()
	if dirtyChunks.has(pos):
		dirtyChunks.erase(pos)
		mutex.unlock()
		var buf := VoxelBuffer.new()
		var s := metastream.get_block_size()
		buf.create(s.x, s.y, s.z)
		metastream.load_voxel_block(buf, pos, 0)
		var vtool = buf.get_voxel_tool()
		var aabb := AABB(Vector3(pos) * s, s)
		$blockEntities._save(aabb, vtool)
		metastream.save_voxel_block(buf, pos, 0)
	else:
		mutex.unlock()
		var s := metastream.get_block_size()
		var aabb := AABB(Vector3(pos) * s, s)
		$blockEntities._clear(aabb)


func saveMetaChunk(pos:Vector3i) -> void:
	var buf := VoxelBuffer.new()
	var s := metastream.get_block_size()
	buf.create(s.x, s.y, s.z)
	metastream.load_voxel_block(buf, pos, 0)
	var vtool = buf.get_voxel_tool()
	var aabb := AABB(Vector3(pos) * s, s)
	$blockEntities._save_chunk(aabb, vtool)
	metastream.save_voxel_block(buf, pos, 0)


func saveMetaChunkContainingBlock(pos:Vector3i) -> void:
	var p = (Vector3(pos) / 16).floor()
	saveMetaChunk(p)


func _on_voxel_terrain_mesh_block_entered(pos: Vector3i) -> void:
	if metastream == null:
		return
	var buf := VoxelBuffer.new()
	var s := metastream.get_block_size()
	buf.create(s.x, s.y, s.z)
	metastream.load_voxel_block(buf, pos, 0)
	var aabb := AABB(Vector3(pos) * s, s)
	$blockEntities._load(aabb, buf)


func _on_quit_menu_button_pressed() -> void:
	saveworld()
	_reset()
	BlockManager._reset()
	CMDprocessor._reset()
	EntityManager._reset()
	SoundManager._reset()
	ParticleManager._reset()
	InventoryTabs._reset()
	tree.paused = false
	tree.change_scene_to_file("res://titlescreen/title.tscn")
