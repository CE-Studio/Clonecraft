class_name Player
extends Entity

## The player controller
##
## Manages player movement, physics, and interaction.

## How reactive the camera is to mouse movement. Supports setting both x and y individually.
var SENSITIVITY := Vector2(200.0, 200.0)

## Refrence to the player's head.
var head:Node3D
## Refrence to the first-person camera.
var cam:Camera3D
## A point used for animation.
var armPointX:Node3D
## A point used for animation.
var armPointY:Node3D
## A [VoxelTool] linked to the current dimension.
var voxelTool:VoxelToolTerrain
## The nearest block that the player is looking at, within their reach.
var lookingAt:VoxelRaycastResult
## The mesh that is used to highlight the block that the player is looking at.
var blockOutline:MeshInstance3D
## The material used to render the clouds.
var cloudmat:StandardMaterial3D
## An array containing the 3rd-person cameras.
var cams:Array[Camera3D]
## A refrence to the currently loaded dimension's terrain.
var terrain:VoxelTerrain
## The player's main inventory.
var inventory := Inventory.new()
## The contents of the hotbar.
var hotbarItems:Array[ItemManager.ItemStack] = []
## The player model
var model:EntityModel

## Keeps track of what camera is being used.
var camcycle := 0
## Keeps strack of how far the player has moved for animation.
var moveDist := 0.0
## Keeps count of how many seconds the world has been loaded for. Used for animation and the day/night cycle.
var time := 0.0
## Keeps strack of how long the player has moved for animation.
var moveTime := 0.0
## Used to smoothly fade the walking animation in/out.
var animCurSpeed := 0.0
## Sets how may blocks away from the player random ticks can be.
var tickRange := 100
## Sets how many random ticks will go off every simulation tick.
var tickNumber := 512
## A reference to the world's [WorldControl].
var world:WorldControl

var _looktrack := Vector2.ZERO

var _fcheck := 1.0
var extraSaveData := {}


@onready var sun:DirectionalLight3D = $sunpoint/sunlight
@onready var sunSprite:Sprite3D = $sunpoint/sunlight/sun
@onready var moon:DirectionalLight3D = $sunpoint/moonlight
@onready var moonSprite:Sprite3D = $sunpoint/moonlight/moon


var sunAngle:float:
	set(value):
		sun.rotation_degrees.x = remap(value, 0, 1, -180, 180)
		moon.rotation_degrees.x = remap(value, 0, 1, -180, 180) + 180
		sunAngle = value


func _saveHotbar() -> Array:
	var h := []
	for i in hotbarItems:
		if i == null:
			h.append(null)
		else:
			h.append([i.itemID, i.metadata])
	return h


func _loadHotbar(a:Array):
	for i in a.size():
		if a[i] is Array:
			var h := ItemManager.ItemStack.new(a[i][0], 1, a[i][1])
			hotbarItems[i] = inventory.getItemFromStack(h)


func getSelectedItem() -> ItemManager.ItemStack:
	return hotbarItems[(Hotbar.layer * 10) + Hotbar.slot]


func save() -> Dictionary:
	return {
		"abilities": abilities,
		"posx": position.x,
		"posy": position.y,
		"posz": position.z,
		"inventory": inventory.save(),
		"extra": extraSaveData,
		"hotbar": _saveHotbar(),
	}


func restore(dict:Dictionary) -> bool:
	if dict.has_all([
		"abilities",
		"posx",
		"posy",
		"posz",
		"inventory",
		"extra",
		"hotbar",
	]):
		abilities = dict["abilities"]
		position.x = dict["posx"]
		position.y = dict["posy"]
		position.z = dict["posz"]
		updateAbilities()
		extraSaveData = dict["extra"]
		var h := inventory.restore(dict["inventory"])
		_loadHotbar(dict["hotbar"])
		return h
	return false
	
	
func setModel(m:EntityModel):
	model = m
	add_child(m)
	m.getFPArm().reparent(armPointX, false)
	if camcycle == 0:
		model.hide()


# TODO make inventory scale with ablilities.
func _ready() -> void:
	hotbarItems.resize(40)
	head = $"head"
	cam = $"head/Camera3D"
	armPointY = $"armpointy"
	armPointX = $"armpointy/armpointx"
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	terrain = BlockManager.terrain
	voxelTool = $"/root/Node3D/VoxelTerrain".get_voxel_tool()
	blockOutline = $"/root/Node3D/blockOutline"
	cloudmat = $"./clouds".material_override
	world = $"/root/Node3D"
	cams.append($head/Camera3D)
	cams.append($head/Camera3D/springArm3d/Camera3D)
	cams.append($head/Camera3D/springArm3d2/Camera3D2)
	call_deferred("setModel", load("res://player/default/Derg.tscn").instantiate())


func _process(delta) -> void:
	time += delta
	if animCurSpeed > 0:
		moveTime += delta
	armPointY.rotation.y = lerp_angle(armPointY.rotation.y, head.rotation.y, delta * 20)
	armPointX.rotation.x = lerp_angle(armPointX.rotation.x, cam.rotation.x, delta * 20)
	armPointX.position = Vector3(
		lerpf(armPointX.position.x, sin(moveDist) / 40, delta * 20) * animCurSpeed,
		lerpf(armPointX.position.y, ((1 - abs(cos(moveDist))) / 80)  * animCurSpeed, delta * 20),
		0
	)
	cloudmat.uv1_offset.z += delta / 900
	_fcheck += delta
	
	model.speed = animCurSpeed
	model.time = time
	model.moveTime = moveTime
	model.moveDistance = moveDist
	var lerpdelta = delta * 10
	_looktrack = Vector2(
		lerp_angle(deg_to_rad(model.look.x), cam.rotation.x, lerpdelta),
		lerp_angle(deg_to_rad(model.look.y), head.rotation.y, lerpdelta)
	)
	model.bodyRotation = clampf((rad_to_deg(_looktrack.y) - model.look.y) + model.bodyRotation, -45, 45)
	model.look = Vector2(
		rad_to_deg(_looktrack.x),
		rad_to_deg(_looktrack.y)
	)
	model.animate(delta)


func _unhandled_input(event) -> void:
	if event.is_action_pressed("ui_accept"):
		if _fcheck <= 0.2:
			if abilities["allowFlight"] || abilities["isFlying"]:
				abilities["isFlying"] = not abilities["isFlying"]
		_fcheck = 0
	elif event is InputEventMouseMotion:
		var mx = -(event.relative.x / SENSITIVITY.x)
		var my = -(event.relative.y / (SENSITIVITY.y / 2))
		head.rotate_y(mx)
		cam.rotate_x(my)
		cam.rotation.x = clamp(cam.rotation.x, -1.5708, 1.5708)
	elif event.is_action_pressed("game_thirdperson"):
		camcycle += 1
		if camcycle >= cams.size():
			camcycle = 0
		cams[camcycle].make_current()
		if camcycle > 0:
			armPointY.visible = false
			model.visible = true
		else:
			armPointY.visible = true
			model.visible = false
	elif event.is_action_pressed("game_screenshot"):
		var sdate:String = Time.get_date_string_from_system()
		var stime:String = Time.get_time_string_from_system().replace(":","-")
		var screenshotPath = "user://screenshots/cc_sc_ymd" + sdate + "_hms" + stime + "_"
		while FileAccess.file_exists(screenshotPath + ".png"):
			screenshotPath = screenshotPath + "e"
		screenshotPath = screenshotPath + ".png"
		var image = get_viewport().get_texture().get_image()
		image.save_png(screenshotPath)
		Chat.pushText("Saved screenshot \"" + ProjectSettings.globalize_path(screenshotPath) + "\"")
	elif event.is_action_pressed("game_hotbar_layer_next"):
		Hotbar.layer += 1
	elif event.is_action_pressed("game_hotbar_layer_prev"):
		Hotbar.layer -= 1
	elif event.is_action_pressed("game_hotbar_next"):
		Hotbar.slot += 1
	elif event.is_action_pressed("game_hotbar_prev"):
		Hotbar.slot -= 1


## Runs random ticks around the player. Called automatically.
func ticks() -> void:
	var center = position.floor()
	var area = AABB(
		center - Vector3(tickRange, tickRange, tickRange),
		2 * Vector3(tickRange, tickRange, tickRange)
	)
	voxelTool.run_blocky_random_tick(area, tickNumber, BlockManager._tickBlock)


func _physics_process(delta) -> void:
	var SPEED:float

	# Add the gravity.
	if (not abilities["isFlying"]) && (not is_on_floor()):
		velocity.y -= GRAVITY * delta
		if velocity.y < TERMINAL_VELOCITY:
			velocity.y = TERMINAL_VELOCITY

	# Handle Jump.
	if abilities["isFlying"]:
		if Input.is_action_pressed("ui_accept") and not Input.is_action_pressed("game_sneak"):
			velocity.y = abilities.size.jump * abilities.scale.jump
		elif Input.is_action_pressed("game_sneak") and not Input.is_action_pressed("ui_accept"):
			velocity.y = -abilities.size.jump * abilities.scale.jump
			if is_on_floor():
				abilities["isFlying"] = false
		else:
			velocity.y = 0
	else:
		if Input.is_action_pressed("ui_accept") and is_on_floor():
			velocity.y = abilities.size.jump * abilities.scale.jump

	if Input.is_action_pressed("ui_up"):
		if Input.is_action_pressed("game_sprint"):
			if Input.is_action_pressed("ui_accept"):
				SPEED = abilities.size.speed * 1.8
			else:
				SPEED = abilities.size.speed * 1.6
		else:
			SPEED = abilities.size.speed
	else:
		SPEED = abilities.size.speed

	if Input.is_action_pressed("game_sneak"):
		SPEED = abilities.size.speed * 0.4
		head.position.y = 0.58
		armPointY.position.y = 0.6
	else:
		head.position.y = 0.689
		armPointY.position.y = 0.689

	var lerpdelta = 30.0 * delta
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("game_left", "game_right", "game_up", "game_down")
	model.bodyRotation = lerpf(model.bodyRotation, 0, abs(input_dir.y) * (delta * 10))
	if input_dir.y <= 0:
		model.bodyRotation = lerpf(model.bodyRotation, 45 * input_dir.x, abs(input_dir.x) * (delta * 10))
	else:
		model.bodyRotation = lerpf(model.bodyRotation, -45 * input_dir.x, abs(input_dir.x) * (delta * 10))
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	# TODO scale with terrain player is on.
	var cvel := Vector2(velocity.x, velocity.z)
	if direction:
		var rvel := Vector2(
			direction.x * SPEED * abilities.scale.speed,
			direction.z * SPEED * abilities.scale.speed,
		)
		cvel = cvel.move_toward(rvel, lerpdelta)
	else:
		cvel = cvel.move_toward(Vector2.ZERO, lerpdelta)
	velocity.x = cvel.x
	velocity.z = cvel.y

	if not terrain.is_area_meshed(AABB(position + (velocity * delta), Vector3.ONE)):
		$"/root/Node3D".startWait(position + (velocity * delta), ((velocity * delta) * 2))
		if velocity == Vector3.ZERO:
			print("bruh")
		#velocity = Vector3.ZERO
		return

	var h := BlockManager.getBlock(position + (velocity * delta))
	if not h.properties.has(&"incompleteHitbox"):
		if not world.raycheck(((velocity * delta) * 2)):
			world.startWait(position + (velocity * delta), ((velocity * delta) * 2))
			velocity = Vector3.ZERO
			return

	move_and_slide()
	moveDist += ((abs(velocity.x) + abs(velocity.z)) * delta)
	animCurSpeed = lerpf(animCurSpeed, clamp((abs(velocity.x) + abs(velocity.z)), 0, 1), delta * 10)

	if abilities["allowBuild"]:
		lookingAt = voxelTool.raycast(cam.global_position, -1 * cam.global_transform.basis.z.normalized(), 5)
	else:
		lookingAt = null

	if lookingAt != null:
		blockOutline.show()
		blockOutline.position = Vector3(lookingAt.position) + Vector3(0.5, 0.5, 0.5)
	else:
		blockOutline.hide()

	ticks()


func _on_enter_item_range(body) -> void:
	if body is WorldItem:
		if body.canPickup():
			if inventory.addItem(body.iStack):
				body.queue_free()
