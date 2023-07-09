class_name Player
extends Entity

var SENSITIVITY := [200.0, 200.0]
var settingTick := -1

var head:Node3D
var cam:Camera3D
var armPointX:Node3D
var armPointY:Node3D
var blockManager:BlockManager
var voxelTool:VoxelToolTerrain
var lookingAt:VoxelRaycastResult
var blockOutline:MeshInstance3D
var cloudmat:StandardMaterial3D
var cams:Array[Camera3D]
var camRay:RayCast3D
var derg:Dictionary

var camcycle := 0
var moveDist := 0.0
var animCurSpeed := 0.0
var tickRange := 100
var tickNumber := 512
var world:WorldControl 

var abillities := {
    "allowFlight":false,
    "isFlying":false,
    "allowBuild":false
}
var fcheck := 1.0


func _ready():
    SPEED = 0.5
    JUMP_VELOCITY = 8.0
    TERMINAL_VELOCITY = -60.0
    GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")
    head = $"head"
    cam = $"head/Camera3D"
    armPointY = $"armpointy"
    armPointX = $"armpointy/armpointx"
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    blockManager = $"/root/BlockManager"
    voxelTool = $"/root/Node3D/VoxelTerrain".get_voxel_tool()
    blockOutline = $"/root/Node3D/blockOutline"
    cloudmat = $"./clouds".material_override
    world = $"/root/Node3D"
    cams.append($head/Camera3D)
    cams.append($head/Camera3D/Camera3D)
    cams.append($head/Camera3D/Camera3D2)
    camRay = $head/Camera3D/RayCast3D
    derg["root"] = $derg
    derg["body"] = $derg/Node2
    derg["head"] = $derg/Node2/bone2/head


func _process(delta):
    armPointY.rotation.y = lerp_angle(armPointY.rotation.y, head.rotation.y, delta * 20)
    armPointX.rotation.x = lerp_angle(armPointX.rotation.x, cam.rotation.x, delta * 20)
    armPointX.position = Vector3(
        lerpf(armPointX.position.x, sin(moveDist) / 40, delta * 20) * animCurSpeed,
        lerpf(armPointX.position.y, ((1 - abs(cos(moveDist))) / 80)  * animCurSpeed, delta * 20),
        0
    )
    derg["body"].rotation.y = armPointY.rotation.y
    derg["head"].rotation.x = armPointX.rotation.x
    cloudmat.uv1_offset.z += delta / 900
    fcheck += delta


func _input(event):
    if event.is_action_pressed("ui_accept"):
        if fcheck <= 0.2:
            if abillities["allowFlight"] || abillities["isFlying"]:
                abillities["isFlying"] = not abillities["isFlying"]
        fcheck = 0
    elif event is InputEventMouseMotion:
        var mx = -(event.relative.x / SENSITIVITY[0])
        var my = -(event.relative.y / (SENSITIVITY[1] / 2))
        head.rotate_y(mx)
        cam.rotate_x(my)
        cam.rotation.x = clamp(cam.rotation.x, -1.5708, 1.5708)
    elif event.is_action_pressed("game_thirdperson"):
        camcycle += 1
        if camcycle >= cams.size():
            camcycle = 0
        cams[camcycle].make_current()
        if camcycle > 0:
            derg["root"].visible = true
            armPointY.visible = false
        else:
            derg["root"].visible = false
            armPointY.visible = true


func ticks():
    var center = position.floor()
    var area = AABB(
        center - Vector3(tickRange, tickRange, tickRange),
        2 * Vector3(tickRange, tickRange, tickRange)
    )
    voxelTool.run_blocky_random_tick(area, tickNumber, blockManager.runRandomTicks)


func _physics_process(delta):
    # Add the gravity.
    if (not abillities["isFlying"]) && (not is_on_floor()):
        velocity.y -= GRAVITY * delta
        if velocity.y < TERMINAL_VELOCITY:
            velocity.y = TERMINAL_VELOCITY

    # Handle Jump.
    if abillities["isFlying"]:
        if Input.is_action_pressed("ui_accept") and not Input.is_action_pressed("game_sneak"):
            velocity.y = JUMP_VELOCITY
        elif Input.is_action_pressed("game_sneak") and not Input.is_action_pressed("ui_accept"):
            velocity.y = -JUMP_VELOCITY
            if is_on_floor():
                abillities["isFlying"] = false
        else:
            velocity.y = 0
    else:
        if Input.is_action_pressed("ui_accept") and is_on_floor():
            velocity.y = JUMP_VELOCITY

    if Input.is_action_pressed("ui_up"):
        if Input.is_action_pressed("game_sprint"):
            if Input.is_action_pressed("ui_accept"):
                SPEED = 9
            else:
                SPEED = 8
        else:
            SPEED = 5
    else:
        SPEED = 5

    if Input.is_action_pressed("game_sneak"):
        SPEED = 2
        head.position.y = 0.58
        armPointY.position.y = 0.6
    else:
        head.position.y = 0.689
        armPointY.position.y = 0.689

    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
    var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction:
        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED
    else:
        velocity.x = move_toward(velocity.x, 0, SPEED)
        velocity.z = move_toward(velocity.z, 0, SPEED)
    
    if not voxelTool.is_area_editable(AABB(position + (velocity * delta), Vector3.ONE)):
        $"/root/Node3D".startWait(position + (velocity * delta), ((velocity * delta) * 2))
        if velocity == Vector3.ZERO:
            print("bruh")
        velocity = Vector3.ZERO
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

    if abillities["allowBuild"]:
        lookingAt = voxelTool.raycast(cam.global_position, -1 * cam.global_transform.basis.z.normalized(), 5)
    else:
        lookingAt = null

    if lookingAt != null:
        blockOutline.show()
        blockOutline.position = Vector3(lookingAt.position) + Vector3(0.5, 0.5, 0.5)
    else:
        blockOutline.hide()
        
    if camcycle == 0:
        pass
    elif camcycle == 1:
        camRay.target_position = Vector3(0, 0, 5)
        if camRay.is_colliding():
            var dist = camRay.global_position.distance_to(camRay.get_collision_point())
            cams[1].position = Vector3(0, 0, dist - 0.2)
        else:
            cams[1].position = Vector3(0, 0, 5)
    elif camcycle == 2:
        camRay.target_position = Vector3(0, 0, -5)
        if camRay.is_colliding():
            var dist = camRay.global_position.distance_to(camRay.get_collision_point())
            cams[2].position = Vector3(0, 0, -dist + 0.2)
        else:
            cams[2].position = Vector3(0, 0, -5)

    ticks()
