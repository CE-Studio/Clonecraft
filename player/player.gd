class_name Player
extends Entity

## The player controller
##
## Manages player movement, physics, and interaction.

## How reactive the camera is to mouse movement. Supports setting both x and y individually.
var SENSITIVITY := Vector2(200.0, 200.0)

## Reference to the player's head.
var head:Node3D
## Reference to the first-person camera.
var cam:Camera3D
## A point used for animation.
var arm_point_x:Node3D
## A point used for animation.
var arm_point_y:Node3D
## A [VoxelTool] linked to the current dimension.
var voxel_tool:VoxelToolTerrain
## The nearest block that the player is looking at, within their reach.
var looking_at:VoxelRaycastResult
## The mesh that is used to highlight the block that the player is looking at.
var block_outline:MeshInstance3D
## The material used to render the clouds.
var cloud_mat:StandardMaterial3D
## An array containing the 3rd-person cameras.
var cams:Array[Camera3D]
## A reference to the currently loaded dimension's terrain.
var terrain:VoxelTerrain
## The player's main inventory.
var inventory := Inventory.new()
## The contents of the hotbar.
var hotbar_items:Array[ItemManager.ItemStack] = []
## The player model
var model:EntityModel

## Keeps track of what camera is being used.
var cam_cycle := 0
## Keeps track of how far the player has moved for animation.
var move_distance := 0.0
## Keeps count of how many seconds the world has been loaded for. Used for animation and the day/night cycle.
var time := 0.0
## Keeps track of how long the player has moved for animation.
var move_time := 0.0
## Used to smoothly fade the walking animation in/out.
var anim_current_speed := 0.0
## Sets how may blocks away from the player random ticks can be, as a percentage of render distance.
var tick_range := 0.5
## Sets how many random ticks will go off every simulation tick, per chunk in range.
var tick_number := 0.47
## A reference to the world's [WorldControl].
var world:WorldControl

var _look_track := Vector2.ZERO
var _first_person_item:HeldItem = preload("res://scripts/itemAssets/HeldItem.tscn").instantiate()

var _flight_check := 1.0
var extra_save_data := {}
var _phys_fix = false


@onready var sun:DirectionalLight3D = $sunpoint/sunlight
@onready var sun_sprite:Sprite3D = $sunpoint/sunlight/sun
@onready var moon:DirectionalLight3D = $sunpoint/moonlight
@onready var moon_sprite:Sprite3D = $sunpoint/moonlight/moon
@onready var stars:Node3D = $sunpoint/stars
@onready var raycast:RayCast3D = $head/Camera3D/rayCast3d


@export var star_mat:Material


var sun_angle:float:
	set(value):
		sun.rotation_degrees.x = remap(value, 0, 1, -180, 180)
		moon.rotation_degrees.x = remap(value, 0, 1, -180, 180) + 180
		stars.rotation.x = sun.rotation.x
		sun_angle = value


func update_held_items() -> void:
	_first_person_item.assign(get_selected_item())


func _save_hotbar() -> Array:
	var h := []
	for i in hotbar_items:
		if i == null:
			h.append(null)
		else:
			h.append([i.item_ID, i.metadata])
	return h


func _load_hotbar(a:Array):
	for i in a.size():
		if a[i] is Array:
			var j:Dictionary[String, Variant] = {}
			j.assign(a[i][1])
			var h := ItemManager.ItemStack.new(a[i][0], 1, j)
			hotbar_items[i] = inventory.get_item_from_stack(h, Inventory.ANY, true, true)


func throw_item(item:ItemManager.ItemStack, strength := 10.0) -> void:
	var vel = velocity
	vel += cam.global_basis * (Vector3.FORWARD * strength)
	ItemManager.spawn_world_item(item, cam.global_position, vel)


func get_selected_item() -> ItemManager.ItemStack:
	return hotbar_items[(Hotbar.layer * 10) + Hotbar.slot]


func save() -> Dictionary:
	return {
		"abilities": abilities,
		"posx": position.x,
		"posy": position.y,
		"posz": position.z,
		"inventory": inventory.save(),
		"extra": extra_save_data,
		"hotbar": _save_hotbar(),
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
		abilities.merge(dict["abilities"], true)
		position.x = dict["posx"]
		position.y = dict["posy"]
		position.z = dict["posz"]
		update_abilities()
		extra_save_data = dict["extra"]
		var h := inventory.restore(dict["inventory"])
		_load_hotbar(dict["hotbar"])
		return h
	return false
	
	
func set_model(m:EntityModel):
	model = m
	add_child(m)
	var fpa := m.get_first_person_arm()
	fpa.reparent(arm_point_x, false)
	fpa.get_node("handItem").add_child(_first_person_item)
	if cam_cycle == 0:
		model.hide()


func update_abilities() -> void:
	super()
	raycast.target_position.z = -abilities.size.reach * abilities.scale.reach * abilities.scale.uniform


# TODO make inventory scale with abilities.
func _ready() -> void:
	sleeping = false
	hotbar_items.resize(40)
	head = $"head"
	cam = $"head/Camera3D"
	arm_point_y = $"armpointy"
	arm_point_x = $"armpointy/armpointx"
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	terrain = BlockManager.terrain
	voxel_tool = $"/root/Node3D/VoxelTerrain".get_voxel_tool()
	block_outline = $"/root/Node3D/blockOutline"
	cloud_mat = $"./clouds".material_override
	world = $"/root/Node3D"
	cams.append($head/Camera3D)
	cams.append($head/Camera3D/springArm3d/Camera3D)
	cams.append($head/Camera3D/springArm3d2/Camera3D2)
	Hotbar.instance.selection_changed.connect(update_held_items)
	call_deferred("set_model", load("res://player/default/Derg.tscn").instantiate())
	create_stars()
	get_tree().create_timer(1).timeout.connect(func(): _phys_fix = true)


func _process(delta) -> void:
	time += delta
	if anim_current_speed > 0:
		move_time += delta
	arm_point_y.rotation.y = lerp_angle(arm_point_y.rotation.y, head.rotation.y, delta * 20)
	arm_point_x.rotation.x = lerp_angle(arm_point_x.rotation.x, cam.rotation.x, delta * 20)
	arm_point_x.position = Vector3(
		lerpf(arm_point_x.position.x, sin(move_distance) / 40, delta * 20) * anim_current_speed,
		lerpf(arm_point_x.position.y, ((1 - abs(cos(move_distance))) / 80)  * anim_current_speed, delta * 20),
		0
	)
	cloud_mat.uv1_offset.z += delta / 900
	_flight_check += delta
	
	model.speed = anim_current_speed
	model.time = time
	model.moveTime = move_time
	model.move_distance = move_distance
	var lerp_delta = delta * 10
	_look_track = Vector2(
		lerp_angle(deg_to_rad(model.look.x), cam.rotation.x, lerp_delta),
		lerp_angle(deg_to_rad(model.look.y), head.rotation.y, lerp_delta)
	)
	model.body_rotation = clampf((rad_to_deg(_look_track.y) - model.look.y) + model.body_rotation, -45, 45)
	model.look = Vector2(
		rad_to_deg(_look_track.x),
		rad_to_deg(_look_track.y)
	)
	model.animate(delta)


func _unhandled_input(event) -> void:
	if event.is_action_pressed("ui_accept"):
		if _flight_check <= 0.2:
			if abilities["allowFlight"] || abilities["isFlying"]:
				abilities["isFlying"] = not abilities["isFlying"]
		_flight_check = 0
	elif event is InputEventMouseMotion:
		var mx = -(event.relative.x / SENSITIVITY.x)
		var my = -(event.relative.y / (SENSITIVITY.y / 2))
		head.rotate_y(mx)
		cam.rotate_x(my)
		cam.rotation.x = clamp(cam.rotation.x, -1.5708, 1.5708)
	elif event.is_action_pressed("game_thirdperson"):
		cam_cycle += 1
		if cam_cycle >= cams.size():
			cam_cycle = 0
		cams[cam_cycle].make_current()
		if cam_cycle > 0:
			arm_point_y.visible = false
			model.visible = true
		else:
			arm_point_y.visible = true
			model.visible = false
	elif event.is_action_pressed("game_screenshot"):
		var s_date:String = Time.get_date_string_from_system()
		var s_time:String = Time.get_time_string_from_system().replace(":","-")
		var screenshot_path = "user://screenshots/cc_sc_ymd" + s_date + "_hms" + s_time + "_"
		while FileAccess.file_exists(screenshot_path + ".png"):
			screenshot_path = screenshot_path + "e"
		screenshot_path = screenshot_path + ".png"
		var image = get_viewport().get_texture().get_image()
		image.save_png(screenshot_path)
		Chat.push_text("Saved screenshot \"" + ProjectSettings.globalize_path(screenshot_path) + "\"")
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
	var c_tick_range = ceili(ProjectSettings.get_setting("gameplay/video/render_distance") * 16 * tick_range)
	var area = AABB(
		center - Vector3(c_tick_range, c_tick_range, c_tick_range),
		2 * Vector3(c_tick_range, c_tick_range, c_tick_range)
	)
	var c_tick_number = ceili(pow(ceilf((c_tick_range * 2.0) / 16), 3) * tick_number)
	voxel_tool.run_blocky_random_tick(area, c_tick_number, BlockManager._tick_block)


func _physics_process(delta) -> void:
	var SPEED:float

	# Add the gravity.
	if (not abilities["isFlying"]) && (not is_on_floor()) && _phys_fix:
		velocity.y -= GRAVITY * delta
		if velocity.y < TERMINAL_VELOCITY:
			velocity.y = TERMINAL_VELOCITY

	# Handle Jump.
	if abilities["isFlying"]:
		if Input.is_action_pressed("ui_accept") and not Input.is_action_pressed("game_sneak"):
			velocity.y = abilities.size.jump * abilities.scale.jump * abilities.scale.uniform
		elif Input.is_action_pressed("game_sneak") and not Input.is_action_pressed("ui_accept"):
			velocity.y = -abilities.size.jump * abilities.scale.jump * abilities.scale.uniform
			if is_on_floor():
				abilities["isFlying"] = false
		else:
			velocity.y = 0
	else:
		if Input.is_action_pressed("ui_accept") and is_on_floor():
			velocity.y = abilities.size.jump * abilities.scale.jump * abilities.scale.uniform

	if Input.is_action_pressed("ui_up"):
		if Input.is_action_pressed("game_sprint"):
			# TODO: make sprint not hardcoded
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
		arm_point_y.position.y = 0.6
	else:
		head.position.y = 0.689
		arm_point_y.position.y = 0.689
		
	if get_selected_item() != null:
		arm_point_y.position.y -= 0.1

	var lerp_delta = 30.0 * delta
	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("game_left", "game_right", "game_up", "game_down")
	model.body_rotation = lerpf(model.body_rotation, 0, abs(input_dir.y) * (delta * 10))
	if input_dir.y <= 0:
		model.body_rotation = lerpf(model.body_rotation, 45 * input_dir.x, abs(input_dir.x) * (delta * 10))
	else:
		model.body_rotation = lerpf(model.body_rotation, -45 * input_dir.x, abs(input_dir.x) * (delta * 10))
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var vel2 := Vector2(velocity.x, velocity.z)
	var terrain_scale_factor := 1.0
	if is_on_floor():
		var voxel_hit = voxel_tool.raycast(position, Vector3.DOWN)
		if voxel_hit != null:
			terrain_scale_factor = BlockManager.get_block(voxel_hit.position).traction
	elif not abilities["isFlying"]:
		terrain_scale_factor = 0.1
	if direction:
		var relative_vel2 := Vector2(
			direction.x * SPEED * abilities.scale.speed * abilities.scale.uniform,
			direction.z * SPEED * abilities.scale.speed * abilities.scale.uniform,
		)
		vel2 = vel2.move_toward(relative_vel2, lerp_delta * terrain_scale_factor)
	else:
		vel2 = vel2.move_toward(Vector2.ZERO, lerp_delta * terrain_scale_factor)
	velocity.x = vel2.x
	velocity.z = vel2.y
	
	var aabb := get_aabb()
	aabb.position += (velocity * delta)
	if not terrain.is_area_meshed(aabb):
		world.start_wait(aabb, ((velocity * delta) * 2))
		if velocity == Vector3.ZERO:
			BlockManager.glog("Player Physics", "Waiting with no velocity!")
		return

	var h := BlockManager.get_block(position + (velocity * delta))
	if not h.properties.has(&"incompleteHitbox"):
		if not world.ray_check(((velocity * delta) * 2)):
			world.start_wait(aabb, ((velocity * delta) * 2))
			velocity = Vector3.ZERO
			return

	move_and_slide()
	move_distance += ((abs(velocity.x) + abs(velocity.z)) * delta)
	anim_current_speed = lerpf(anim_current_speed, clamp((abs(velocity.x) + abs(velocity.z)), 0, 1), delta * 10)

	if abilities["allowBuild"]:
		looking_at = voxel_tool.raycast(
			cam.global_position,
			-1 * cam.global_transform.basis.z.normalized(),
			abilities.size.reach * abilities.scale.reach * abilities.scale.uniform
		)
	else:
		looking_at = null
	
	if raycast.is_colliding() and (raycast.get_collider() is TileEntity):
		var te:TileEntity = raycast.get_collider()
		block_outline.show()
		block_outline.position = te.global_position + Vector3(0.5, 0.5, 0.5)
	elif looking_at != null:
		block_outline.show()
		block_outline.position = Vector3(looking_at.position) + Vector3(0.5, 0.5, 0.5)
	else:
		block_outline.hide()


func _settings_changed():
	super()
	$head/Camera3D/VoxelViewer.view_distance = 16 * ProjectSettings.get_setting("gameplay/video/render_distance")
	cams[0].fov = ProjectSettings.get_setting("gameplay/video/fov")
	cams[1].fov = ProjectSettings.get_setting("gameplay/video/fov")
	cams[2].fov = ProjectSettings.get_setting("gameplay/video/fov")


func _on_enter_item_range(body) -> void:
	if body is WorldItem:
		if body.can_pickup():
			if inventory.add_item_partial(body.i_stack):
				SoundManager.play_sound_3D(&"clonecraft:pop", body.position)
				if body.i_stack.count == 0:
					body.queue_free()
				else:
					body.set_item(body.i_stack)


func create_stars(seed:int = 0, density:int = 300, star:PackedScene = preload("res://components/Star.tscn"), clear := true):
	if clear:
		for i in stars.get_children():
			i.queue_free()
	var rng = RandomNumberGenerator.new()
	rng.seed = seed
	for i in density:
		var s = star.instantiate()
		stars.add_child(s)
		s.rotate_x(rng.randf_range(-PI, PI))
		s.rotate_y(rng.randf_range(-PI, PI))
		s.rotate_z(rng.randf_range(-PI, PI))
		var c = s.get_child(0)
		c.material_override = star_mat
		var sc = rng.randf_range(8, 11.274)
		c.scale = Vector3(sc, sc, sc)


func get_reach_point() -> Vector3:
	return cam.to_global(Vector3(0, 0, -get_scaled("reach")))


func _movement_process(_delta:float) -> void:
	pass


func die() -> void:
	pass


func animate_damage(amount:float) -> void:
	pass
