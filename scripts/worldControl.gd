extends Node3D
class_name WorldControl


static var worldpath:String
static var streamtype:String
static var instance:WorldControl
static var localUsername := "__localplayer__" : 
	set(value):
		pass


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
var _waitpos := Vector3.ZERO
var _waitrel := Vector3.ZERO
var waiting := false
var pausing := false
var tree:SceneTree
var _p:Player
var _terrain:VoxelTerrain
var stream:VoxelStream
var dayprogress:float = 0

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
	if _terrain.is_area_meshed(AABB(_waitpos, Vector3.ONE)):
		waiting = false


func startWait(pos:Vector3, rel:Vector3) -> void:
	waiting = true
	get_tree().paused = true
	_waitpos = pos
	_waitrel = rel


func saveworld():
	$"/root/Node3D/VoxelTerrain".save_modified_blocks()
	var jsave := JSON.stringify(_p.save(), "  ")
	if !DirAccess.dir_exists_absolute(worldpath + "/playerdata/"):
		DirAccess.make_dir_absolute(worldpath + "/playerdata/")
	# TODO un-hardcode this
	var playsavepath := worldpath + "/playerdata/__localplayer__.json"
	var f := FileAccess.open(playsavepath, FileAccess.WRITE)
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


func _input(event) -> void:
	if event.is_action_pressed("ui_cancel"):
		pauseUnpause()


func _ready() -> void:
	instance = self
	tree = get_tree()
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
		"sql":
			pass
	var playsavepath := worldpath + "/playerdata/__localplayer__.json"
	if FileAccess.file_exists(playsavepath):
		var f := FileAccess.open(playsavepath, FileAccess.READ)
		var dict:Dictionary = JSON.parse_string(f.get_as_text())
		f.close()
		BlockManager.log("WorldControl", str(_p.restore(dict)))


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


func _on_setting_button_pressed():
	SettingManager.spawnMenu()


func _on_quit_desktop_button_pressed():
	saveworld()
	get_tree().quit()
